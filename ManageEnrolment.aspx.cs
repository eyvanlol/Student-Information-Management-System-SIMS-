using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class ManageEnrolment : System.Web.UI.Page
    {
        // ══════════════════════════════════════════════════════
        // PAGE LOAD
        // ══════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            // Auth guard — same pattern as AdminDashboard
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            lblUserName.Text = Session["UserName"].ToString();
            lblTopUserName.Text = Session["UserName"].ToString();

            if (!IsPostBack)
            {
                LoadSemesters();
                LoadDropRequests();
                LoadFilterDropDowns();
                LoadEnrolmentRecords();
                LoadAssignDropDowns();

                // TASK 1 — Results & Retake tab
                LoadResultCourses();
                LoadResults();
            }
        }

        // ══════════════════════════════════════════════════════
        // HELPER — show feedback message
        // ══════════════════════════════════════════════════════
        private void ShowMessage(string text, bool success)
        {
            lblMessage.Text = "<i class='fas fa-" + (success ? "check" : "exclamation") + "-circle me-2'></i>" + text;
            lblMessage.CssClass = "alert-msg " + (success ? "alert-success-custom" : "alert-danger-custom");
        }

        // ══════════════════════════════════════════════════════
        // HELPER — status badge CSS class (used in .aspx)
        // ══════════════════════════════════════════════════════
        public string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "enrolled": return "badge-enrolled";
                case "pending": return "badge-pending";
                case "dropped":
                case "drop_requested": return "badge-dropped";
                case "confirmed": return "badge-confirmed";
                case "rejected": return "badge-rejected";
                default: return "badge-pending";
            }
        }

        // ══════════════════════════════════════════════════════
        // TAB 1 — SEMESTER CONTROL
        // ══════════════════════════════════════════════════════
        private void LoadSemesters()
        {
            string sql = @"
                SELECT sessionID, semesterName, academicYear, semesterType,
                       enrolStartDate, enrolEndDate, status
                FROM   SEMESTER_SESSION
                ORDER  BY sessionID DESC";

            DataTable dt = DbHelper.ExecuteQuery(sql);
            rptSemesters.DataSource = dt;
            rptSemesters.DataBind();
        }

        protected void btnToggleSemester_Command(object sender, CommandEventArgs e)
        {
            // CommandArgument = "sessionID|currentStatus"
            string[] parts = e.CommandArgument.ToString().Split('|');
            int sessionId = Convert.ToInt32(parts[0]);
            string current = parts[1].Trim();
            string newStatus = (current == "Open") ? "Closed" : "Open";

            using (SqlConnection conn = DbHelper.GetConnection())
            {
                conn.Open();
                using (SqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        // 1. Toggle the semester status
                        using (SqlCommand cmd = new SqlCommand(
                            "UPDATE SEMESTER_SESSION SET status = @s WHERE sessionID = @id", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@s", newStatus);
                            cmd.Parameters.AddWithValue("@id", sessionId);
                            cmd.ExecuteNonQuery();
                        }

                        // 2. If CLOSING — bulk-confirm all pending enrolments for this semester
                        if (newStatus == "Closed")
                        {
                            // Get semester name so we can match ENROLMENT.semester column
                            string semName = "";
                            using (SqlCommand cmd = new SqlCommand(
                                "SELECT semesterName FROM SEMESTER_SESSION WHERE sessionID = @id", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@id", sessionId);
                                semName = cmd.ExecuteScalar()?.ToString() ?? "";
                            }

                            // Bulk-confirm all pending records for that semester
                            using (SqlCommand cmd = new SqlCommand(
                                @"UPDATE ENROLMENT
                                  SET    status = 'confirmed'
                                  WHERE  status = 'pending'
                                  AND    semester = @sem", conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@sem", semName);
                                int rows = cmd.ExecuteNonQuery();
                                ShowMessage($"Enrolment closed. {rows} pending record(s) auto-confirmed.", true);
                            }
                        }
                        else
                        {
                            ShowMessage("Enrolment window opened. Students can now confirm their courses.", true);
                        }

                        tx.Commit();
                    }
                    catch (Exception ex)
                    {
                        tx.Rollback();
                        ShowMessage("Error: " + ex.Message, false);
                    }
                }
            }

            LoadSemesters(); // refresh repeater
        }

        // ══════════════════════════════════════════════════════
        // TAB 2 — ASSIGN COURSES TO PROGRAMME
        // ══════════════════════════════════════════════════════
        private void LoadAssignDropDowns()
        {
            // Semester sessions dropdown
            DataTable dtSem = DbHelper.ExecuteQuery(
                "SELECT sessionID, semesterName + ' (' + academicYear + ')' AS label " +
                "FROM SEMESTER_SESSION ORDER BY sessionID DESC");
            ddlAssignSemester.DataSource = dtSem;
            ddlAssignSemester.DataTextField = "label";
            ddlAssignSemester.DataValueField = "sessionID";
            ddlAssignSemester.DataBind();
            ddlAssignSemester.Items.Insert(0, new ListItem("-- Select Semester --", ""));

            // Programme dropdown
            DataTable dtProg = DbHelper.ExecuteQuery(
                "SELECT programmeID, programmeName FROM PROGRAMME WHERE status = 'Active' ORDER BY programmeName");
            ddlAssignProgramme.DataSource = dtProg;
            ddlAssignProgramme.DataTextField = "programmeName";
            ddlAssignProgramme.DataValueField = "programmeID";
            ddlAssignProgramme.DataBind();
            ddlAssignProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));
        }

        protected void ddlAssignProgramme_Changed(object sender, EventArgs e)
        {
            // Just keep state — courses load when button clicked
        }

        protected void btnLoadCourses_Click(object sender, EventArgs e)
        {
            if (ddlAssignProgramme.SelectedValue == "")
            {
                ShowMessage("Please select a programme first.", false);
                return;
            }

            int programmeId = Convert.ToInt32(ddlAssignProgramme.SelectedValue);

            DataTable dt = DbHelper.ExecuteQuery(
                $"SELECT courseID, courseCode + ' — ' + courseName AS label " +
                $"FROM   COURSE " +
                $"WHERE  programmeID = {programmeId} AND status = 'Active' " +
                $"ORDER  BY courseCode");

            cblCourses.DataSource = dt;
            cblCourses.DataTextField = "label";
            cblCourses.DataValueField = "courseID";
            cblCourses.DataBind();

            lblAssignProgrammeName.Text = ddlAssignProgramme.SelectedItem.Text;
            pnlCourseAssign.Visible = true;
        }

        protected void btnAssignCourses_Click(object sender, EventArgs e)
        {
            if (ddlAssignSemester.SelectedValue == "" || ddlAssignProgramme.SelectedValue == "")
            {
                ShowMessage("Please select both a semester and a programme.", false);
                return;
            }

            // Collect checked course IDs
            System.Collections.Generic.List<int> selectedCourses = new System.Collections.Generic.List<int>();
            foreach (ListItem item in cblCourses.Items)
                if (item.Selected) selectedCourses.Add(Convert.ToInt32(item.Value));

            if (selectedCourses.Count == 0)
            {
                ShowMessage("Please tick at least one course.", false);
                return;
            }

            int programmeId = Convert.ToInt32(ddlAssignProgramme.SelectedValue);
            int sessionId = Convert.ToInt32(ddlAssignSemester.SelectedValue);

            // Get semester details
            DataTable dtSem = DbHelper.ExecuteQuery(
                $"SELECT semesterName, academicYear FROM SEMESTER_SESSION WHERE sessionID = {sessionId}");
            if (dtSem.Rows.Count == 0) { ShowMessage("Semester not found.", false); return; }

            string semesterName = dtSem.Rows[0]["semesterName"].ToString();
            string academicYear = dtSem.Rows[0]["academicYear"].ToString();

            // Get all students in this programme
            DataTable dtStudents = DbHelper.ExecuteQuery(
                $"SELECT studentID FROM STUDENT WHERE programmeID = {programmeId}");

            if (dtStudents.Rows.Count == 0)
            {
                ShowMessage("No students found under this programme.", false);
                return;
            }

            int inserted = 0;
            int skipped = 0;

            using (SqlConnection conn = DbHelper.GetConnection())
            {
                conn.Open();
                using (SqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        foreach (DataRow student in dtStudents.Rows)
                        {
                            int studentId = Convert.ToInt32(student["studentID"]);

                            foreach (int courseId in selectedCourses)
                            {
                                // Skip if record already exists for this student+course+semester
                                using (SqlCommand chk = new SqlCommand(
                                    @"SELECT COUNT(*) FROM ENROLMENT
                                      WHERE studentID = @sid AND courseID = @cid AND semester = @sem",
                                    conn, tx))
                                {
                                    chk.Parameters.AddWithValue("@sid", studentId);
                                    chk.Parameters.AddWithValue("@cid", courseId);
                                    chk.Parameters.AddWithValue("@sem", semesterName);
                                    int exists = Convert.ToInt32(chk.ExecuteScalar());
                                    if (exists > 0) { skipped++; continue; }
                                }

                                // Insert pending enrolment
                                using (SqlCommand ins = new SqlCommand(
                                    @"INSERT INTO ENROLMENT
                                        (studentID, courseID, semester, academicYear, enrolDate, status)
                                      VALUES
                                        (@sid, @cid, @sem, @yr, GETDATE(), 'pending')",
                                    conn, tx))
                                {
                                    ins.Parameters.AddWithValue("@sid", studentId);
                                    ins.Parameters.AddWithValue("@cid", courseId);
                                    ins.Parameters.AddWithValue("@sem", semesterName);
                                    ins.Parameters.AddWithValue("@yr", academicYear);
                                    ins.ExecuteNonQuery();
                                    inserted++;
                                }
                            }
                        }

                        tx.Commit();
                        lblAssignResult.Text = $"Done. {inserted} enrolment record(s) created as PENDING. {skipped} already existed and were skipped.";
                        lblAssignResult.ForeColor = System.Drawing.Color.Green;
                        ShowMessage($"Courses assigned successfully. {inserted} records created.", true);
                    }
                    catch (Exception ex)
                    {
                        tx.Rollback();
                        ShowMessage("Error: " + ex.Message, false);
                    }
                }
            }
        }

        // ══════════════════════════════════════════════════════
        // TAB 3 — DROP REQUESTS
        // ══════════════════════════════════════════════════════
        private void LoadDropRequests()
        {
            string sql = @"
                SELECT e.enrolmentID,
                       s.name       AS studentName,
                       ISNULL(s.studentCode, CAST(s.studentID AS VARCHAR)) AS studentCode,
                       c.courseName,
                       c.courseCode,
                       e.semester,
                       e.academicYear
                FROM   ENROLMENT e
                JOIN   STUDENT   s ON e.studentID = s.studentID
                JOIN   COURSE    c ON e.courseID  = c.courseID
                WHERE  e.status = 'drop_requested'
                ORDER  BY e.enrolmentID DESC";

            DataTable dt = DbHelper.ExecuteQuery(sql);
            gvDropRequests.DataSource = dt;
            gvDropRequests.DataBind();

            // Show count badge on tab
            lblDropBadge.Text = dt.Rows.Count > 0 ? dt.Rows.Count.ToString() : "";
            lblDropBadge.Visible = dt.Rows.Count > 0;
        }

        protected void gvDropRequests_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "ApproveRow" && e.CommandName != "RejectRow")
                return; // ignore the GridView's built-in commands (paging/sorting)

            int enrolmentId = Convert.ToInt32(e.CommandArgument);
            string newStatus = e.CommandName == "ApproveRow" ? "dropped" : "rejected";
            string notifType = e.CommandName == "ApproveRow" ? "drop_approved" : "drop_rejected";
            string notifTitle = e.CommandName == "ApproveRow"
                ? "Drop request approved"
                : "Drop request rejected";

            using (SqlConnection conn = DbHelper.GetConnection())
            {
                conn.Open();
                using (SqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        // 1. Update ENROLMENT status
                        using (SqlCommand cmd = new SqlCommand(
                            "UPDATE ENROLMENT SET status = @s WHERE enrolmentID = @id", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@s", newStatus);
                            cmd.Parameters.AddWithValue("@id", enrolmentId);
                            cmd.ExecuteNonQuery();
                        }

                        // 2. Get studentID and course info for notification
                        int studentId = 0;
                        string courseName = "";
                        using (SqlCommand cmd = new SqlCommand(
                            @"SELECT e.studentID, c.courseName
                              FROM   ENROLMENT e
                              JOIN   COURSE    c ON e.courseID = c.courseID
                              WHERE  e.enrolmentID = @id", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@id", enrolmentId);
                            using (SqlDataReader r = cmd.ExecuteReader())
                            {
                                if (r.Read())
                                {
                                    studentId = Convert.ToInt32(r["studentID"]);
                                    courseName = r["courseName"].ToString();
                                }
                            }
                        }

                        // 3. Insert notification for student
                        if (studentId > 0)
                        {
                            string message = e.CommandName == "ApproveRow"
                                ? $"Your drop request for {courseName} has been approved by HOP."
                                : $"Your drop request for {courseName} has been rejected by HOP.";

                            using (SqlCommand cmd = new SqlCommand(
                                @"INSERT INTO NOTIFICATION
                                    (recipientID, recipientRole, title, message, isRead, createdAt, notifType)
                                  VALUES
                                    (@rid, 'student', @title, @msg, 0, GETDATE(), @ntype)",
                                conn, tx))
                            {
                                cmd.Parameters.AddWithValue("@rid", studentId);
                                cmd.Parameters.AddWithValue("@title", notifTitle);
                                cmd.Parameters.AddWithValue("@msg", message);
                                cmd.Parameters.AddWithValue("@ntype", notifType);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        tx.Commit();
                        ShowMessage(
                            e.CommandName == "ApproveRow"
                                ? "Drop request approved. Student has been notified."
                                : "Drop request rejected. Student has been notified.",
                            true);
                    }
                    catch (Exception ex)
                    {
                        tx.Rollback();
                        ShowMessage("Error: " + ex.Message, false);
                    }
                }
            }

            LoadDropRequests(); // refresh grid
        }

        // ══════════════════════════════════════════════════════
        // TAB 4 — ENROLMENT RECORDS
        // ══════════════════════════════════════════════════════
        private void LoadFilterDropDowns()
        {
            // Semester filter
            DataTable dtSem = DbHelper.ExecuteQuery(
                "SELECT DISTINCT semester, semester AS label FROM ENROLMENT ORDER BY semester");
            ddlFilterSemester.DataSource = dtSem;
            ddlFilterSemester.DataTextField = "label";
            ddlFilterSemester.DataValueField = "semester";
            ddlFilterSemester.DataBind();
            ddlFilterSemester.Items.Insert(0, new ListItem("All Semesters", ""));

            // Programme filter
            DataTable dtProg = DbHelper.ExecuteQuery(
                "SELECT programmeID, programmeName FROM PROGRAMME ORDER BY programmeName");
            ddlFilterProgramme.DataSource = dtProg;
            ddlFilterProgramme.DataTextField = "programmeName";
            ddlFilterProgramme.DataValueField = "programmeID";
            ddlFilterProgramme.DataBind();
            ddlFilterProgramme.Items.Insert(0, new ListItem("All Programmes", ""));
        }

        private void LoadEnrolmentRecords(string semester = "", string programmeId = "", string status = "")
        {
            // Build WHERE clauses safely
            string where = "WHERE 1=1";
            if (!string.IsNullOrEmpty(semester)) where += $" AND e.semester = '{semester.Replace("'", "''")}'";
            if (!string.IsNullOrEmpty(status)) where += $" AND e.status   = '{status.Replace("'", "''")}'";
            if (!string.IsNullOrEmpty(programmeId)) where += $" AND s.programmeID = {programmeId}";

            string sql = $@"
                SELECT TOP 200
                       e.enrolmentID,
                       s.name        AS studentName,
                       ISNULL(s.studentCode, CAST(s.studentID AS VARCHAR)) AS studentCode,
                       c.courseName,
                       e.semester,
                       e.academicYear,
                       e.status,
                       e.enrolDate
                FROM   ENROLMENT e
                JOIN   STUDENT   s ON e.studentID = s.studentID
                JOIN   COURSE    c ON e.courseID  = c.courseID
                {where}
                ORDER  BY e.enrolmentID DESC";

            DataTable dt = DbHelper.ExecuteQuery(sql);
            gvEnrolmentRecords.DataSource = dt;
            gvEnrolmentRecords.DataBind();
        }

        protected void btnFilterRecords_Click(object sender, EventArgs e)
        {
            LoadEnrolmentRecords(
                ddlFilterSemester.SelectedValue,
                ddlFilterProgramme.SelectedValue,
                ddlFilterStatus.SelectedValue);
        }

        // ══════════════════════════════════════════════════════
        // TAB 5 — RESULTS & RETAKE  (TASK 1)
        //   • Lists every PUBLISHED result with derived Fail/Pass.
        //   • "Mark Retake" toggles RESULT.retakeRequired.
        //   • "Notify Student" emails the student's personal email AND
        //     drops an in-app NOTIFICATION row (both reuse existing code).
        // ══════════════════════════════════════════════════════
        private void LoadResultCourses()
        {
            DataTable dt = DbHelper.ExecuteQuery(
                "SELECT courseID, courseCode + ' - ' + courseName AS label " +
                "FROM COURSE ORDER BY courseCode");
            ddlResultCourse.DataSource = dt;
            ddlResultCourse.DataTextField = "label";
            ddlResultCourse.DataValueField = "courseID";
            ddlResultCourse.DataBind();
            ddlResultCourse.Items.Insert(0, new ListItem("All Courses", ""));
        }

        private void LoadResults(string courseId = "")
        {
            bool hasCourse = !string.IsNullOrEmpty(courseId);

            string sql = @"
                SELECT r.resultID,
                       s.studentID,
                       s.name        AS studentName,
                       ISNULL(s.studentCode, CAST(s.studentID AS VARCHAR)) AS studentCode,
                       ISNULL(s.personalEmail, '') AS personalEmail,
                       c.courseCode,
                       c.courseName,
                       r.marks,
                       r.grade,
                       ISNULL(r.retakeRequired, 0) AS retakeRequired,
                       r.failNotifiedAt
                FROM   RESULT  r
                JOIN   STUDENT s ON r.studentID = s.studentID
                JOIN   COURSE  c ON r.courseID  = c.courseID
                WHERE  r.publishedStatus = 'Published'";

            if (hasCourse) sql += " AND r.courseID = @cid";

            // Fails first, then by course/name
            sql += " ORDER BY (CASE WHEN r.marks < 50 THEN 0 ELSE 1 END), c.courseCode, s.name";

            DataTable dt = hasCourse
                ? DbHelper.ExecuteQuery(sql, new SqlParameter("@cid", Convert.ToInt32(courseId)))
                : DbHelper.ExecuteQuery(sql);

            gvResults.DataSource = dt;
            gvResults.DataBind();
        }

        protected void btnFilterResults_Click(object sender, EventArgs e)
        {
            LoadResults(ddlResultCourse.SelectedValue);
        }

        protected void gvResults_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ToggleRetake")
            {
                int resultId = Convert.ToInt32(e.CommandArgument);

                // Look up the current marks + flag so we can guard against marking
                // a PASSING student for retake.
                DataTable dt = DbHelper.ExecuteQuery(
                    "SELECT marks, ISNULL(retakeRequired,0) AS retakeRequired FROM RESULT WHERE resultID = @id",
                    new SqlParameter("@id", resultId));

                if (dt.Rows.Count == 0)
                {
                    ShowMessage("Result not found.", false);
                    return;
                }

                decimal marks = dt.Rows[0]["marks"] == DBNull.Value ? 0m : Convert.ToDecimal(dt.Rows[0]["marks"]);
                bool currentlyRetake = Convert.ToBoolean(dt.Rows[0]["retakeRequired"]);
                bool fail = marks < 50m;

                // Block turning retake ON for a student who has not failed.
                if (!currentlyRetake && !fail)
                {
                    ShowMessage("Cannot mark retake — this student has not failed (marks are 50 or above).", false);
                    LoadResults(ddlResultCourse.SelectedValue);
                    return;
                }

                DbHelper.ExecuteNonQuery(
                    "UPDATE RESULT SET retakeRequired = @v WHERE resultID = @id",
                    new SqlParameter("@v", currentlyRetake ? 0 : 1),
                    new SqlParameter("@id", resultId));

                ShowMessage(currentlyRetake ? "Retake flag removed." : "Student marked for retake.", true);
                LoadResults(ddlResultCourse.SelectedValue);
            }
            else if (e.CommandName == "NotifyStudent")
            {
                NotifyStudent(Convert.ToInt32(e.CommandArgument));
                LoadResults(ddlResultCourse.SelectedValue);
            }
        }

        private void NotifyStudent(int resultId)
        {
            // 1. Fetch everything we need for this one result row
            DataTable dt = DbHelper.ExecuteQuery(
                @"SELECT r.studentID, s.name AS studentName,
                         ISNULL(s.personalEmail,'') AS personalEmail,
                         c.courseCode, c.courseName,
                         r.marks, r.grade, ISNULL(r.retakeRequired,0) AS retakeRequired
                  FROM   RESULT  r
                  JOIN   STUDENT s ON r.studentID = s.studentID
                  JOIN   COURSE  c ON r.courseID  = c.courseID
                  WHERE  r.resultID = @id",
                new SqlParameter("@id", resultId));

            if (dt.Rows.Count == 0)
            {
                ShowMessage("Result not found.", false);
                return;
            }

            DataRow row = dt.Rows[0];
            int studentId = Convert.ToInt32(row["studentID"]);
            string studentName = row["studentName"].ToString();
            string email = row["personalEmail"].ToString();
            string courseCode = row["courseCode"].ToString();
            string courseName = row["courseName"].ToString();
            decimal marks = row["marks"] == DBNull.Value ? 0m : Convert.ToDecimal(row["marks"]);
            string grade = row["grade"] == DBNull.Value ? "" : row["grade"].ToString();
            bool retake = Convert.ToBoolean(row["retakeRequired"]);
            bool fail = marks < 50m;

            // 2. Guard rails
            if (string.IsNullOrWhiteSpace(email))
            {
                ShowMessage("This student has no personal email on file. Add one under Manage Users first.", false);
                return;
            }
            if (!fail && !retake)
            {
                ShowMessage("This student passed and is not flagged for retake — nothing to notify.", false);
                return;
            }

            // 3. Compose status + instruction
            string statusLabel = retake ? "Must Retake" : "Failed";
            string marksGrade = $"{marks:0.00}" + (string.IsNullOrEmpty(grade) ? "" : $" ({grade})");
            string instruction = retake
                ? "You are required to RETAKE this course in the next available semester. " +
                  "Please contact the Head of Programme to register for the retake before the enrolment deadline."
                : "You did not meet the minimum passing mark (50) for this course. " +
                  "Please contact the Head of Programme to discuss your options, including a possible retake.";

            // 4. Send the email (reuses EmailHelper -> private Send -> Web.config SMTP).
            //    Same resilience pattern as the OTP flow: only mark as notified if
            //    delivery actually succeeded.
            try
            {
                EmailHelper.SendResultNotification(
                    email, studentName, courseCode, courseName, statusLabel, marksGrade, instruction);

                // 4a. Audit timestamp on the result
                DbHelper.ExecuteNonQuery(
                    "UPDATE RESULT SET failNotifiedAt = GETDATE() WHERE resultID = @id",
                    new SqlParameter("@id", resultId));

                // 4b. Also drop an in-app NOTIFICATION (existing bell system)
                DbHelper.ExecuteNonQuery(
                    @"INSERT INTO NOTIFICATION
                        (recipientID, recipientRole, title, message, isRead, createdAt, notifType)
                      VALUES
                        (@rid, 'student', @title, @msg, 0, GETDATE(), 'result')",
                    new SqlParameter("@rid", studentId),
                    new SqlParameter("@title", $"Action required — {courseCode} ({statusLabel})"),
                    new SqlParameter("@msg", $"{statusLabel}: {courseName}. {instruction}"));

                ShowMessage($"Notification emailed to {email} and posted to the student's notifications.", true);
            }
            catch (Exception ex)
            {
                // Delivery failed — do NOT set failNotifiedAt, surface the real reason.
                ShowMessage("Could not send email: " + ex.Message, false);
            }
        }

        // ── Helpers used by the Results & Retake grid bindings ──
        private bool MarksIsFail(object marks)
        {
            if (marks == null || marks == DBNull.Value) return false;
            return Convert.ToDecimal(marks) < 50m;
        }

        public string OutcomeText(object marks)
        {
            return MarksIsFail(marks) ? "Fail" : "Pass";
        }

        public string OutcomeBadge(object marks)
        {
            return MarksIsFail(marks) ? "badge-dropped" : "badge-enrolled";
        }

        public bool CanNotify(object marks, object retake)
        {
            bool r = retake != null && retake != DBNull.Value && Convert.ToBoolean(retake);
            return MarksIsFail(marks) || r;
        }

        // Retake button only makes sense for a failed result (or to UN-mark one
        // that is already flagged). Passing students never get the option.
        public bool CanRetake(object marks, object retake)
        {
            bool r = retake != null && retake != DBNull.Value && Convert.ToBoolean(retake);
            return MarksIsFail(marks) || r;
        }

        public string RetakeBtnText(object retake)
        {
            bool r = retake != null && retake != DBNull.Value && Convert.ToBoolean(retake);
            return r ? "Unmark Retake" : "Mark Retake";
        }

        public string NotifiedText(object dt)
        {
            if (dt == null || dt == DBNull.Value) return "—";
            return "Sent " + Convert.ToDateTime(dt).ToString("d MMM, HH:mm");
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
