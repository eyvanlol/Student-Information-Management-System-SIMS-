using System;
using System.Data;
using System.Data.SqlClient;

namespace StudentManagementSystem
{
    public partial class StudentDashboard : System.Web.UI.Page
    {
        // ══════════════════════════════════════════════════════
        // PAGE LOAD
        // ══════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Student")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (Session["UserName"] != null)
            {
                string name = Session["UserName"].ToString();
                lblUserName.Text = name;
                lblTopUserName.Text = name;
                lblWelcomeName.Text = name.Split(' ')[0]; // first name only
            }

            // Student ID shown under the name in the top bar
            if (Session["UserID"] != null)
            {
                try
                {
                    using (SqlConnection conn = DbHelper.GetConnection())
                    using (SqlCommand cmd = new SqlCommand("SELECT studentCode FROM STUDENT WHERE studentID = @sid", conn))
                    {
                        cmd.Parameters.AddWithValue("@sid", Convert.ToInt32(Session["UserID"]));
                        conn.Open();
                        object code = cmd.ExecuteScalar();
                        lblTopStudentId.Text = code != null ? code.ToString() : "";
                    }
                }
                catch { lblTopStudentId.Text = ""; }
            }

            if (!IsPostBack)
            {
                LoadDashboard();
            }
        }

        // ══════════════════════════════════════════════════════
        // LOAD ALL DASHBOARD DATA
        // ══════════════════════════════════════════════════════
        private void LoadDashboard()
        {
            int studentId = Convert.ToInt32(Session["UserID"]);

            LoadProgramme(studentId);
            LoadCurrentSemester();
            LoadEnrolledCourses(studentId);
            LoadAttendanceOverview(studentId);
            LoadGPA(studentId);
            LoadNotifications(studentId);
        }

        // ══════════════════════════════════════════════════════
        // LOAD PROGRAMME NAME FOR SIDEBAR
        // ══════════════════════════════════════════════════════
        private void LoadProgramme(int studentId)
        {
            try
            {
                string sql = @"
                    SELECT p.programmeName
                    FROM   STUDENT s
                    JOIN   PROGRAMME p ON s.programmeID = p.programmeID
                    WHERE  s.studentID = @sid";

                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    lblProgramme.Text = result != null ? result.ToString() : "";
                }
            }
            catch { lblProgramme.Text = ""; }
        }

        // ══════════════════════════════════════════════════════
        // LOAD CURRENT OPEN SEMESTER
        // ══════════════════════════════════════════════════════
        private void LoadCurrentSemester()
        {
            try
            {
                string sql = @"
                    SELECT TOP 1 semesterName + ' ' + academicYear AS semLabel
                    FROM   SEMESTER_SESSION
                    WHERE  status = 'Open'
                    ORDER  BY sessionID DESC";

                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    lblWelcomeSemester.Text = result != null
                        ? "Current semester: " + result.ToString()
                        : "No active semester at the moment";
                }
            }
            catch { lblWelcomeSemester.Text = ""; }
        }

        // ══════════════════════════════════════════════════════
        // LOAD ENROLLED COURSES FOR CURRENT SEMESTER
        // ══════════════════════════════════════════════════════
        private void LoadEnrolledCourses(int studentId)
        {
            try
            {
                string sql = @"
                    SELECT c.courseCode,
                           c.courseName,
                           c.creditHour,
                           e.status,
                           CASE
                               WHEN COUNT(a.attendanceID) = 0 THEN NULL
                               ELSE CAST(
                                   ROUND(
                                       100.0 * SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END)
                                       / COUNT(a.attendanceID), 0)
                                   AS INT)
                           END AS attendancePct
                    FROM   ENROLMENT e
                    JOIN   COURSE    c ON e.courseID  = c.courseID
                    LEFT JOIN ATTENDANCE a ON a.studentID = e.studentID AND a.courseID = e.courseID
                    WHERE  e.studentID = @sid
                    AND    e.semester  = (
                        SELECT TOP 1 semesterName FROM SEMESTER_SESSION
                        WHERE status = 'Open' ORDER BY sessionID DESC
                    )
                    AND    e.status IN ('enrolled','pending','confirmed')
                    GROUP  BY c.courseCode, c.courseName, c.creditHour, e.status
                    ORDER  BY c.courseCode";

                DataTable dt = new DataTable();
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        da.Fill(dt);
                }

                lblEnrolledCount.Text = dt.Rows.Count.ToString();
                gvCourses.DataSource = dt;
                gvCourses.DataBind();

                // Check if any course is below 80%
                bool hasWarning = false;
                string warningCourses = "";
                foreach (DataRow row in dt.Rows)
                {
                    if (row["attendancePct"] != DBNull.Value)
                    {
                        int pct = Convert.ToInt32(row["attendancePct"]);
                        if (pct < 80)
                        {
                            hasWarning = true;
                            warningCourses += row["courseName"].ToString() + " (" + pct + "%), ";
                        }
                    }
                }

                if (hasWarning)
                {
                    pnlAttendanceWarning.Visible = true;
                    lblAttendanceWarning.Text = "⚠ Your attendance is below 80% in: " +
                        warningCourses.TrimEnd(',', ' ') + ". Please attend remaining classes.";
                }
            }
            catch (Exception ex)
            {
                lblEnrolledCount.Text = "0";
            }
        }

        // ══════════════════════════════════════════════════════
        // LOAD OVERALL ATTENDANCE %
        // ══════════════════════════════════════════════════════
        private void LoadAttendanceOverview(int studentId)
        {
            try
            {
                string sql = @"
                    SELECT CASE
                               WHEN COUNT(*) = 0 THEN NULL
                               ELSE CAST(ROUND(100.0 * SUM(CASE WHEN status='Present' THEN 1 ELSE 0 END) / COUNT(*), 0) AS INT)
                           END
                    FROM   ATTENDANCE
                    WHERE  studentID = @sid";

                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    lblAttendancePct.Text = (result != null && result != DBNull.Value)
                        ? result.ToString() + "%"
                        : "—";
                }
            }
            catch { lblAttendancePct.Text = "N/A"; }
        }

        // ══════════════════════════════════════════════════════
        // LOAD GPA FROM PUBLISHED RESULTS
        // ══════════════════════════════════════════════════════
        private void LoadGPA(int studentId)
        {
            try
            {
                string sql = @"
                    SELECT CASE
                               WHEN COUNT(*) = 0 THEN NULL
                               ELSE CAST(ROUND(AVG(CAST(GPA AS FLOAT)), 2) AS DECIMAL(3,2))
                           END
                    FROM   RESULT
                    WHERE  studentID       = @sid
                    AND    publishedStatus = 'Published'";

                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    lblGPA.Text = (result != null && result != DBNull.Value)
                        ? result.ToString()
                        : "—";
                }
            }
            catch { lblGPA.Text = "N/A"; }
        }

        // ══════════════════════════════════════════════════════
        // LOAD RECENT 3 NOTIFICATIONS
        // ══════════════════════════════════════════════════════
        private void LoadNotifications(int studentId)
        {
            try
            {
                string sql = @"
                    SELECT TOP 3 notifType, title, message, createdAt
                    FROM   NOTIFICATION
                    WHERE  recipientID   = @sid
                    AND    recipientRole = 'student'
                    ORDER  BY createdAt DESC";

                DataTable dt = new DataTable();
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        da.Fill(dt);
                }

                // Unread count
                string countSql = @"
                    SELECT COUNT(*) FROM NOTIFICATION
                    WHERE  recipientID = @sid AND recipientRole = 'student' AND isRead = 0";

                int unread = 0;
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(countSql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    object r = cmd.ExecuteScalar();
                    unread = (r != null && r != DBNull.Value) ? Convert.ToInt32(r) : 0;
                }

                lblUnreadNotif.Text = unread.ToString();
                //lblNotifCount.Text = unread > 0 ? $" ({unread})" : "";

                if (dt.Rows.Count > 0)
                {
                    rptNotifications.DataSource = dt;
                    rptNotifications.DataBind();
                    pnlNoNotif.Visible = false;
                }
                else
                {
                    pnlNoNotif.Visible = true;
                }
            }
            catch
            {
                pnlNoNotif.Visible = true;
                lblUnreadNotif.Text = "0";
            }
        }

        // ══════════════════════════════════════════════════════
        // HELPER METHODS (used in .aspx bindings)
        // ══════════════════════════════════════════════════════
        public string GetAttendanceBadge(object pct)
        {
            if (pct == null || pct == DBNull.Value) return "badge-info";
            int val = Convert.ToInt32(pct);
            if (val >= 80) return "badge-good";
            if (val >= 60) return "badge-warn";
            return "badge-danger";
        }

        public string GetEnrolmentBadge(string status)
        {
            switch (status)
            {
                case "enrolled": return "badge-good";
                case "confirmed": return "badge-info";
                case "pending": return "badge-warn";
                case "drop_requested": return "badge-warn";
                case "dropped": return "badge-danger";
                default: return "badge-info";
            }
        }

        public string GetNotifDot(string type)
        {
            switch (type)
            {
                case "grade": return "dot-green";
                case "attendance": return "dot-amber";
                case "enrolment": return "dot-blue";
                case "announcement": return "dot-blue";
                case "drop_approved": return "dot-green";
                case "drop_rejected": return "dot-red";
                default: return "dot-gray";
            }
        }

        public string TruncateMsg(string msg)
        {
            if (string.IsNullOrEmpty(msg)) return "";
            return msg.Length > 60 ? msg.Substring(0, 60) + "..." : msg;
        }

        public string TimeAgo(object dateObj)
        {
            if (dateObj == null || dateObj == DBNull.Value) return "";
            DateTime date = Convert.ToDateTime(dateObj);
            TimeSpan diff = DateTime.Now - date;
            if (diff.TotalMinutes < 60) return (int)diff.TotalMinutes + " min ago";
            if (diff.TotalHours < 24) return (int)diff.TotalHours + " hours ago";
            if (diff.TotalDays < 7) return (int)diff.TotalDays + " days ago";
            return date.ToString("d MMM yyyy");
        }

        // ══════════════════════════════════════════════════════
        // LOGOUT
        // ══════════════════════════════════════════════════════
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}