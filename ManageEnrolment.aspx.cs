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
