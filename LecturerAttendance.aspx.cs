using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class LecturerAttendance : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["SIMSConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Lecturer")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            string name = Session["UserName"]?.ToString() ?? "Lecturer";
            lblUserName.Text = name;
            lblTopUserName.Text = name;

            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                LoadCourses();
                LoadSemesters();
            }
        }

        // ───────────────────────── dropdown loaders ─────────────────────────
        private void LoadCourses()
        {
            int lecturerID = Convert.ToInt32(Session["UserID"]);
            DataTable dt = DbHelper.ExecuteQuery(
                @"SELECT courseID, courseCode + ' - ' + courseName AS courseDisplay
                  FROM COURSE WHERE lecturerID = @lid AND status = 'Active' ORDER BY courseName",
                new SqlParameter("@lid", lecturerID));
            ddlCourse.DataSource = dt;
            ddlCourse.DataTextField = "courseDisplay";
            ddlCourse.DataValueField = "courseID";
            ddlCourse.DataBind();
            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", ""));
        }

        private void LoadSemesters()
        {
            DataTable dt = DbHelper.ExecuteQuery(
                "SELECT sessionID, semesterName + ' (' + semesterType + ')' AS label FROM SEMESTER_SESSION ORDER BY sessionID DESC");
            ddlSemester.DataSource = dt;
            ddlSemester.DataTextField = "label";
            ddlSemester.DataValueField = "sessionID";
            ddlSemester.DataBind();
            ddlSemester.Items.Insert(0, new ListItem("-- Select Semester --", ""));
        }

        protected void ddlCourse_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Refresh the warnings list whenever the chosen course changes.
            if (ddlCourse.SelectedValue != "")
                LoadWarnings();
            else
            {
                gvWarnings.DataSource = null;
                gvWarnings.DataBind();
            }
        }

        // ───────────────────────── marking ─────────────────────────
        protected void btnLoadStudents_Click(object sender, EventArgs e)
        {
            if (ddlCourse.SelectedValue == "") { ShowMessage("Please select a course.", false); return; }
            LoadStudents();
            LoadWarnings();
        }

        private void LoadStudents()
        {
            DataTable dt = DbHelper.ExecuteQuery(
                @"SELECT s.studentID,
                         ISNULL(s.studentCode, CAST(s.studentID AS VARCHAR)) AS studentCode,
                         s.name, s.email
                  FROM ENROLMENT e
                  JOIN STUDENT s ON e.studentID = s.studentID
                  WHERE e.courseID = @cid AND e.status IN ('enrolled','confirmed')
                  ORDER BY s.name",
                new SqlParameter("@cid", Convert.ToInt32(ddlCourse.SelectedValue)));
            gvStudents.DataSource = dt;
            gvStudents.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (ddlCourse.SelectedValue == "") { ShowMessage("Please select a course.", false); return; }
            if (gvStudents.Rows.Count == 0) { ShowMessage("Please load students first.", false); return; }

            DateTime attendanceDate;
            if (!DateTime.TryParse(txtDate.Text, out attendanceDate))
            { ShowMessage("Please enter a valid date.", false); return; }

            int lecturerID = Convert.ToInt32(Session["UserID"]);
            int courseID = Convert.ToInt32(ddlCourse.SelectedValue);
            string sessionType = ddlSessionType.SelectedValue;

            // Duplicate guard: same course/date/session can't be recorded twice
            object dup = DbHelper.ExecuteScalar(
                @"SELECT COUNT(*) FROM ATTENDANCE
                  WHERE lecturerID=@lid AND courseID=@cid AND attendanceDate=@d AND sessionType=@st",
                new SqlParameter("@lid", lecturerID),
                new SqlParameter("@cid", courseID),
                new SqlParameter("@d", attendanceDate),
                new SqlParameter("@st", sessionType));
            if (Convert.ToInt32(dup) > 0)
            { ShowMessage("Attendance has already been recorded for this course, date, and session type.", false); return; }

            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();
                foreach (GridViewRow row in gvStudents.Rows)
                {
                    if (row.RowType != DataControlRowType.DataRow) continue;
                    int studentID = Convert.ToInt32(gvStudents.DataKeys[row.RowIndex].Value);
                    DropDownList ddlStatus = (DropDownList)row.FindControl("ddlStatus");
                    string status = ddlStatus.SelectedValue;

                    using (SqlCommand cmd = new SqlCommand(
                        @"INSERT INTO ATTENDANCE (studentID, courseID, lecturerID, attendanceDate, sessionType, status)
                          VALUES (@sid, @cid, @lid, @d, @st, @status)", con))
                    {
                        cmd.Parameters.AddWithValue("@sid", studentID);
                        cmd.Parameters.AddWithValue("@cid", courseID);
                        cmd.Parameters.AddWithValue("@lid", lecturerID);
                        cmd.Parameters.AddWithValue("@d", attendanceDate);
                        cmd.Parameters.AddWithValue("@st", sessionType);
                        cmd.Parameters.AddWithValue("@status", status);
                        cmd.ExecuteNonQuery();
                    }

                    CheckAttendanceWarning(studentID, courseID, con);
                }
            }

            ShowMessage("Attendance saved successfully.", true);
            LoadStudents();
            LoadWarnings();
        }

        // Posts an in-app notification when a student drops below 80% (existing behaviour).
        private void CheckAttendanceWarning(int studentID, int courseID, SqlConnection con)
        {
            int present = 0, total = 0; string courseName = "";
            using (SqlCommand cmd = new SqlCommand(
                @"SELECT SUM(CASE WHEN a.status='Present' THEN 1 ELSE 0 END) AS PresentCount,
                         COUNT(*) AS TotalSessions, c.courseName
                  FROM ATTENDANCE a JOIN COURSE c ON a.courseID=c.courseID
                  WHERE a.studentID=@sid AND a.courseID=@cid
                  GROUP BY c.courseName", con))
            {
                cmd.Parameters.AddWithValue("@sid", studentID);
                cmd.Parameters.AddWithValue("@cid", courseID);
                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        present = Convert.ToInt32(dr["PresentCount"]);
                        total = Convert.ToInt32(dr["TotalSessions"]);
                        courseName = dr["courseName"].ToString();
                    }
                }
            }
            if (total == 0) return;
            int percent = (int)Math.Round((present / (double)total) * 100);
            if (percent < 80) InsertNotification(studentID, courseName, percent, con);
        }

        private void InsertNotification(int studentID, string courseName, int percent, SqlConnection con)
        {
            using (SqlCommand cmd = new SqlCommand(
                @"INSERT INTO NOTIFICATION (recipientID, recipientRole, title, message, isRead, notifType)
                  VALUES (@sid, 'student', @title, @msg, 0, 'attendance')", con))
            {
                cmd.Parameters.AddWithValue("@sid", studentID);
                cmd.Parameters.AddWithValue("@title", "Attendance warning - " + courseName);
                cmd.Parameters.AddWithValue("@msg",
                    "Your attendance for " + courseName + " is below 80%. Current attendance: " + percent + "%.");
                cmd.ExecuteNonQuery();
            }
        }

        // ───────────────────────── schedule ─────────────────────────
        protected void btnGenerateSchedule_Click(object sender, EventArgs e)
        {
            if (ddlSemester.SelectedValue == "") { ShowMessage("Please select a semester session.", false); return; }

            DataTable info = DbHelper.ExecuteQuery(
                "SELECT semesterName, semesterType, classStartDate, enrolEndDate FROM SEMESTER_SESSION WHERE sessionID=@id",
                new SqlParameter("@id", Convert.ToInt32(ddlSemester.SelectedValue)));
            if (info.Rows.Count == 0) { ShowMessage("Semester not found.", false); return; }

            DataRow r = info.Rows[0];
            string semType = r["semesterType"].ToString();                 // 'Long' or 'Short'
            string semName = r["semesterName"].ToString();
            DateTime start = r["classStartDate"] != DBNull.Value ? Convert.ToDateTime(r["classStartDate"])
                            : r["enrolEndDate"] != DBNull.Value ? Convert.ToDateTime(r["enrolEndDate"])
                            : DateTime.Today;

            int weeks = string.Equals(semType, "Short", StringComparison.OrdinalIgnoreCase) ? 12 : 15;

            DataTable sched = new DataTable();
            sched.Columns.Add("Week", typeof(int));
            sched.Columns.Add("ClassNo", typeof(string));
            sched.Columns.Add("Day", typeof(string));
            sched.Columns.Add("DateText", typeof(string));
            sched.Columns.Add("DateIso", typeof(string));

            // Two classes a week: same weekday as the start date, and 3 days later.
            for (int w = 0; w < weeks; w++)
            {
                DateTime d1 = start.AddDays(7 * w);
                DateTime d2 = start.AddDays(7 * w + 3);
                sched.Rows.Add(w + 1, "Class 1", d1.DayOfWeek.ToString(), d1.ToString("d MMM yyyy"), d1.ToString("yyyy-MM-dd"));
                sched.Rows.Add(w + 1, "Class 2", d2.DayOfWeek.ToString(), d2.ToString("d MMM yyyy"), d2.ToString("yyyy-MM-dd"));
            }

            gvSchedule.DataSource = sched;
            gvSchedule.DataBind();

            lblScheduleInfo.Text =
                $"<strong>{semName}</strong> — {semType} semester: {weeks} weeks × 2 classes/week = " +
                $"<strong>{weeks * 2} sessions</strong>. 4 credit hours. First class: {start:dddd, d MMM yyyy}. " +
                "Click \"Mark this class\" on any row to load that date into the marking sheet.";
            lblScheduleInfo.Visible = true;
        }

        protected void gvSchedule_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "PickDate") return;
            txtDate.Text = e.CommandArgument.ToString();   // yyyy-MM-dd
            if (ddlCourse.SelectedValue == "")
            { ShowMessage("Date set to " + txtDate.Text + ". Now select a course and load students.", true); return; }
            LoadStudents();
            ShowMessage("Marking sheet set to " + txtDate.Text + ". Set each status and click Save Attendance.", true);
        }

        // ───────────────────────── warnings ─────────────────────────
        protected void btnRefreshWarnings_Click(object sender, EventArgs e)
        {
            if (ddlCourse.SelectedValue == "") { ShowMessage("Please select a course.", false); return; }
            LoadWarnings();
        }

        private void LoadWarnings()
        {
            if (ddlCourse.SelectedValue == "") return;

            DataTable dt = DbHelper.ExecuteQuery(
                @"SELECT s.studentID,
                         ISNULL(s.studentCode, CAST(s.studentID AS VARCHAR)) AS studentCode,
                         s.name,
                         SUM(CASE WHEN a.status='Present' THEN 1 ELSE 0 END) AS attended,
                         COUNT(a.attendanceID) AS total
                  FROM ENROLMENT e
                  JOIN STUDENT s ON e.studentID = s.studentID
                  LEFT JOIN ATTENDANCE a ON a.studentID = e.studentID AND a.courseID = e.courseID
                  WHERE e.courseID = @cid AND e.status IN ('enrolled','confirmed')
                  GROUP BY s.studentID, s.studentCode, s.name
                  ORDER BY s.name",
                new SqlParameter("@cid", Convert.ToInt32(ddlCourse.SelectedValue)));

            dt.Columns.Add("percent", typeof(int));
            dt.Columns.Add("level", typeof(int));
            foreach (DataRow row in dt.Rows)
            {
                int attended = Convert.ToInt32(row["attended"]);
                int total = Convert.ToInt32(row["total"]);
                int percent = total > 0 ? (int)Math.Round(attended * 100.0 / total) : 100;
                row["percent"] = percent;
                row["level"] = LevelFor(percent, total);
            }

            gvWarnings.DataSource = dt;
            gvWarnings.DataBind();
        }

        private int LevelFor(int percent, int total)
        {
            if (total == 0) return 0;        // no classes held yet
            if (percent < 40) return 3;      // auto drop
            if (percent < 60) return 2;      // second warning + barred
            if (percent < 80) return 1;      // first warning
            return 0;
        }

        protected void gvWarnings_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "SendWarn") return;
            int studentID = Convert.ToInt32(e.CommandArgument);
            string outcome = ProcessWarning(studentID, Convert.ToInt32(ddlCourse.SelectedValue));
            ShowMessage(outcome, true);
            LoadWarnings();
        }

        protected void btnSendAllWarnings_Click(object sender, EventArgs e)
        {
            if (ddlCourse.SelectedValue == "") { ShowMessage("Please select a course.", false); return; }
            int courseID = Convert.ToInt32(ddlCourse.SelectedValue);

            // Snapshot the flagged students first, then process each.
            DataTable dt = DbHelper.ExecuteQuery(
                @"SELECT s.studentID,
                         SUM(CASE WHEN a.status='Present' THEN 1 ELSE 0 END) AS attended,
                         COUNT(a.attendanceID) AS total
                  FROM ENROLMENT e
                  JOIN STUDENT s ON e.studentID = s.studentID
                  LEFT JOIN ATTENDANCE a ON a.studentID = e.studentID AND a.courseID = e.courseID
                  WHERE e.courseID = @cid AND e.status IN ('enrolled','confirmed')
                  GROUP BY s.studentID",
                new SqlParameter("@cid", courseID));

            int sent = 0, dropped = 0;
            foreach (DataRow row in dt.Rows)
            {
                int attended = Convert.ToInt32(row["attended"]);
                int total = Convert.ToInt32(row["total"]);
                int percent = total > 0 ? (int)Math.Round(attended * 100.0 / total) : 100;
                int level = LevelFor(percent, total);
                if (level == 0) continue;
                ProcessWarning(Convert.ToInt32(row["studentID"]), courseID);
                sent++;
                if (level >= 3) dropped++;
            }

            ShowMessage(sent == 0
                ? "No students are currently below the warning thresholds."
                : $"Processed {sent} warning letter(s). {dropped} student(s) auto-dropped (below 40%).", true);
            LoadWarnings();
        }

        // Sends the right letter for one student and applies the consequence.
        private string ProcessWarning(int studentID, int courseID)
        {
            DataTable dt = DbHelper.ExecuteQuery(
                @"SELECT s.name, ISNULL(s.personalEmail,'') AS personalEmail,
                         ISNULL(p.programmeName,'') AS programmeName,
                         c.courseCode, c.courseName,
                         SUM(CASE WHEN a.status='Present' THEN 1 ELSE 0 END) AS attended,
                         COUNT(a.attendanceID) AS total
                  FROM ENROLMENT e
                  JOIN STUDENT s  ON e.studentID = s.studentID
                  JOIN COURSE  c  ON e.courseID  = c.courseID
                  LEFT JOIN PROGRAMME p ON s.programmeID = p.programmeID
                  LEFT JOIN ATTENDANCE a ON a.studentID = e.studentID AND a.courseID = e.courseID
                  WHERE e.studentID = @sid AND e.courseID = @cid AND e.status IN ('enrolled','confirmed')
                  GROUP BY s.name, s.personalEmail, p.programmeName, c.courseCode, c.courseName",
                new SqlParameter("@sid", studentID),
                new SqlParameter("@cid", courseID));

            if (dt.Rows.Count == 0)
                return "That student is no longer active in this course (already dropped?).";

            DataRow r = dt.Rows[0];
            string name = r["name"].ToString();
            string email = r["personalEmail"].ToString();
            string programme = r["programmeName"].ToString();
            string courseCode = r["courseCode"].ToString();
            string courseName = r["courseName"].ToString();
            int attended = Convert.ToInt32(r["attended"]);
            int total = Convert.ToInt32(r["total"]);
            int percent = total > 0 ? (int)Math.Round(attended * 100.0 / total) : 100;
            int level = LevelFor(percent, total);

            if (level == 0) return $"{name} is at {percent}% — no warning needed.";

            // 1. Email the letter (reuses EmailHelper -> Web.config SMTP). Resilient.
            string emailNote;
            try
            {
                if (string.IsNullOrWhiteSpace(email))
                    emailNote = " (no personal email on file — letter not emailed)";
                else
                {
                    EmailHelper.SendAttendanceWarningLetter(
                        email, name, programme, courseCode, courseName, percent, attended, total, level);
                    emailNote = " Letter emailed to " + email + ".";
                }
            }
            catch (Exception ex) { emailNote = " (email failed: " + ex.Message + ")"; }

            // 2. Apply the consequence + record the warning level on the enrolment.
            if (level >= 3)
            {
                DbHelper.ExecuteNonQuery(
                    @"UPDATE ENROLMENT SET status='dropped', warningLevel=3, warningSentAt=GETDATE()
                      WHERE studentID=@sid AND courseID=@cid AND status IN ('enrolled','confirmed')",
                    new SqlParameter("@sid", studentID), new SqlParameter("@cid", courseID));
            }
            else
            {
                DbHelper.ExecuteNonQuery(
                    @"UPDATE ENROLMENT SET warningLevel=@lvl, warningSentAt=GETDATE()
                      WHERE studentID=@sid AND courseID=@cid AND status IN ('enrolled','confirmed')",
                    new SqlParameter("@lvl", level),
                    new SqlParameter("@sid", studentID), new SqlParameter("@cid", courseID));
            }

            // 3. In-app notification
            string title = level >= 3 ? "Dropped from " + courseCode + " (attendance)"
                         : level == 2 ? "Second attendance warning - " + courseCode
                                      : "First attendance warning - " + courseCode;
            string msg = level >= 3
                ? $"Your attendance for {courseName} fell below 40% ({percent}%). You have been dropped from the course."
                : level == 2
                ? $"Second warning: attendance for {courseName} is {percent}% (below 60%). You may be barred from the final exam."
                : $"First warning: attendance for {courseName} is {percent}% (below 80%). Please attend all remaining classes.";
            DbHelper.ExecuteNonQuery(
                @"INSERT INTO NOTIFICATION (recipientID, recipientRole, title, message, isRead, createdAt, notifType)
                  VALUES (@sid,'student',@t,@m,0,GETDATE(),'attendance')",
                new SqlParameter("@sid", studentID),
                new SqlParameter("@t", title),
                new SqlParameter("@m", msg));

            string levelName = level >= 3 ? "AUTO-DROP" : level == 2 ? "Second warning (barred)" : "First warning";
            return $"{name}: {levelName} at {percent}%." + emailNote;
        }

        // ── grid binding helpers ──
        public string PctClass(object percent)
        {
            int p = percent == null || percent == DBNull.Value ? 100 : Convert.ToInt32(percent);
            return p < 60 ? "pct-bad" : p < 80 ? "pct-warn" : "pct-good";
        }
        public string LevelText(object level)
        {
            switch (level == null || level == DBNull.Value ? 0 : Convert.ToInt32(level))
            {
                case 3: return "Auto-drop (<40%)";
                case 2: return "2nd warning (<60%)";
                case 1: return "1st warning (<80%)";
                default: return "OK";
            }
        }
        public string LevelBadge(object level)
        {
            switch (level == null || level == DBNull.Value ? 0 : Convert.ToInt32(level))
            {
                case 3: return "lvl-3";
                case 2: return "lvl-2";
                case 1: return "lvl-1";
                default: return "lvl-ok";
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();
            Response.Redirect("Login.aspx");
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMsg.Text = "<div class='alert " + (success ? "alert-success" : "alert-danger") + "'>" + msg + "</div>";
        }
    }
}
