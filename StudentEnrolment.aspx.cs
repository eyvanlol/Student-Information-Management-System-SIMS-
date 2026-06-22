using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class StudentEnrolment : System.Web.UI.Page
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
                lblUserName.Text    = Session["UserName"].ToString();
                lblTopUserName.Text = Session["UserName"].ToString();
            }

            if (!IsPostBack)
            {
                LoadEnrolmentPage();
            }
        }

        // ══════════════════════════════════════════════════════
        // LOAD ALL ENROLMENT DATA
        // ══════════════════════════════════════════════════════
        private void LoadEnrolmentPage()
        {
            int studentId = Convert.ToInt32(Session["UserID"]);

            LoadProgramme(studentId);
            LoadNotifCount(studentId);
            LoadWindowStatus();
            LoadUpcomingCourses(studentId);
            LoadCurrentCourses(studentId);
            LoadDropRequests(studentId);
        }

        // ══════════════════════════════════════════════════════
        // LOAD PROGRAMME FOR SIDEBAR
        // ══════════════════════════════════════════════════════
        private void LoadProgramme(int studentId)
        {
            try
            {
                string sql = @"
                    SELECT p.programmeName
                    FROM   STUDENT s JOIN PROGRAMME p ON s.programmeID = p.programmeID
                    WHERE  s.studentID = @sid";

                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    object r = cmd.ExecuteScalar();
                    lblProgramme.Text = r != null ? r.ToString() : "";
                }
            }
            catch { lblProgramme.Text = ""; }
        }

        // ══════════════════════════════════════════════════════
        // LOAD NOTIFICATION COUNT FOR BELL
        // ══════════════════════════════════════════════════════
        private void LoadNotifCount(int studentId)
        {
            try
            {
                string sql = @"
                    SELECT COUNT(*) FROM NOTIFICATION
                    WHERE recipientID = @sid AND recipientRole = 'student' AND isRead = 0";

                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    object r = cmd.ExecuteScalar();
                    lblBellCount.Text = (r != null && r != DBNull.Value) ? r.ToString() : "0";
                }
            }
            catch { lblBellCount.Text = "0"; }
        }

        // ══════════════════════════════════════════════════════
        // CHECK ENROLMENT WINDOW STATUS
        // ══════════════════════════════════════════════════════
        private void LoadWindowStatus()
        {
            try
            {
                string sql = @"
                    SELECT TOP 1 semesterName, academicYear, enrolStartDate, enrolEndDate, status
                    FROM   SEMESTER_SESSION
                    ORDER  BY sessionID DESC";

                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string status    = r["status"].ToString();
                            string semName   = r["semesterName"].ToString();
                            string acYear    = r["academicYear"].ToString();
                            string startDate = Convert.ToDateTime(r["enrolStartDate"]).ToString("d MMM yyyy");
                            string endDate   = Convert.ToDateTime(r["enrolEndDate"]).ToString("d MMM yyyy");

                            if (status == "Open")
                            {
                                pnlWindowOpen.Visible   = true;
                                pnlWindowClosed.Visible = false;
                                lblWindowDetails.Text   = semName + " " + acYear +
                                    " · Deadline: " + endDate;
                            }
                            else
                            {
                                pnlWindowOpen.Visible   = false;
                                pnlWindowClosed.Visible = true;

                                // Hide confirm button if window is closed
                                btnConfirmAll.Visible = false;
                            }
                        }
                    }
                }
            }
            catch
            {
                pnlWindowClosed.Visible = true;
            }
        }

        // ══════════════════════════════════════════════════════
        // LOAD UPCOMING SEMESTER — PENDING / ENROLLED COURSES
        // ══════════════════════════════════════════════════════
        private void LoadUpcomingCourses(int studentId)
        {
            try
            {
                // Get the most recent OPEN semester
                string semSql = @"
                    SELECT TOP 1 semesterName, academicYear
                    FROM   SEMESTER_SESSION WHERE status = 'Open'
                    ORDER  BY sessionID DESC";

                string semName = ""; string acYear = "";
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(semSql, conn))
                {
                    conn.Open();
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            semName = r["semesterName"].ToString();
                            acYear  = r["academicYear"].ToString();
                        }
                    }
                }

                if (string.IsNullOrEmpty(semName)) return;

                lblUpcomingSemester.Text = semName + " " + acYear;

                string sql = @"
                    SELECT e.enrolmentID,
                           c.courseCode,
                           c.courseName,
                           c.creditHour,
                           e.semester,
                           e.status
                    FROM   ENROLMENT e
                    JOIN   COURSE    c ON e.courseID = c.courseID
                    WHERE  e.studentID = @sid
                    AND    e.semester  = @sem
                    AND    e.status    IN ('pending','enrolled','drop_requested')
                    ORDER  BY c.courseCode";

                DataTable dt = new DataTable();
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    cmd.Parameters.AddWithValue("@sem", semName);
                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        da.Fill(dt);
                }

                if (dt.Rows.Count > 0)
                {
                    pnlUpcoming.Visible    = true;
                    gvUpcoming.DataSource  = dt;
                    gvUpcoming.DataBind();
                }
            }
            catch { }
        }

        // ══════════════════════════════════════════════════════
        // LOAD CURRENT SEMESTER — ENROLLED / CONFIRMED COURSES
        // ══════════════════════════════════════════════════════
        private void LoadCurrentCourses(int studentId)
        {
            try
            {
                string sql = @"
                    SELECT e.enrolmentID,
                           c.courseCode,
                           c.courseName,
                           c.creditHour,
                           ISNULL(l.name, 'TBA') AS lecturerName,
                           e.semester,
                           e.status
                    FROM   ENROLMENT e
                    JOIN   COURSE    c ON e.courseID   = c.courseID
                    LEFT JOIN LECTURER l ON c.lecturerID = l.lecturerID
                    WHERE  e.studentID = @sid
                    AND    e.status    IN ('enrolled','confirmed')
                    ORDER  BY e.enrolmentID DESC";

                DataTable dt = new DataTable();
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        da.Fill(dt);
                }

                // Set current semester label from first row
                if (dt.Rows.Count > 0)
                    lblCurrentSemester.Text = dt.Rows[0]["semester"].ToString();
                else
                    lblCurrentSemester.Text = "No active enrolment";

                gvCurrent.DataSource = dt;
                gvCurrent.DataBind();
            }
            catch { }
        }

        // ══════════════════════════════════════════════════════
        // LOAD DROP REQUESTS
        // ══════════════════════════════════════════════════════
        private void LoadDropRequests(int studentId)
        {
            try
            {
                string sql = @"
                    SELECT e.enrolmentID,
                           c.courseCode,
                           c.courseName,
                           e.semester,
                           e.status
                    FROM   ENROLMENT e
                    JOIN   COURSE    c ON e.courseID = c.courseID
                    WHERE  e.studentID = @sid
                    AND    e.status    IN ('drop_requested','dropped','rejected')
                    ORDER  BY e.enrolmentID DESC";

                DataTable dt = new DataTable();
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        da.Fill(dt);
                }

                if (dt.Rows.Count > 0)
                {
                    pnlDropRequests.Visible    = true;
                    gvDropRequests.DataSource  = dt;
                    gvDropRequests.DataBind();
                }
            }
            catch { }
        }

        // ══════════════════════════════════════════════════════
        // CONFIRM ALL PENDING COURSES
        // ══════════════════════════════════════════════════════
        protected void btnConfirmAll_Click(object sender, EventArgs e)
        {
            // Check window is still open
            if (!IsWindowOpen())
            {
                ShowMessage("Enrolment window is closed. You cannot confirm courses at this time.", false);
                return;
            }

            int studentId = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    @"UPDATE ENROLMENT SET status = 'enrolled'
                      WHERE  studentID = @sid AND status = 'pending'", conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    int rows = cmd.ExecuteNonQuery();
                    ShowMessage($"Successfully confirmed {rows} course(s). You are now enrolled.", true);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }

            LoadEnrolmentPage();
        }

        // ══════════════════════════════════════════════════════
        // DROP INDIVIDUAL COURSE
        // ══════════════════════════════════════════════════════
        protected void gvUpcoming_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "DropCourse") return;

            // Check window is open
            if (!IsWindowOpen())
            {
                ShowMessage("Enrolment window is closed. Drop requests cannot be submitted.", false);
                return;
            }

            int enrolmentId = Convert.ToInt32(e.CommandArgument);
            int studentId   = Convert.ToInt32(Session["UserID"]);

            using (SqlConnection conn = DbHelper.GetConnection())
            {
                conn.Open();
                using (SqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        // 1. Update ENROLMENT status to drop_requested
                        using (SqlCommand cmd = new SqlCommand(
                            @"UPDATE ENROLMENT SET status = 'drop_requested'
                              WHERE  enrolmentID = @eid AND studentID = @sid
                              AND    status IN ('pending','enrolled')", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@eid", enrolmentId);
                            cmd.Parameters.AddWithValue("@sid", studentId);
                            cmd.ExecuteNonQuery();
                        }

                        // 2. Get course name for notification
                        string courseName = "";
                        using (SqlCommand cmd = new SqlCommand(
                            @"SELECT c.courseName FROM ENROLMENT e
                              JOIN   COURSE c ON e.courseID = c.courseID
                              WHERE  e.enrolmentID = @eid", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@eid", enrolmentId);
                            object r = cmd.ExecuteScalar();
                            courseName = r != null ? r.ToString() : "course";
                        }

                        // 3. Insert notification for HOP (admin)
                        // Get adminID from HOP_ADMIN table
                        int adminId = 1;
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT TOP 1 adminID FROM HOP_ADMIN", conn, tx))
                        {
                            object r = cmd.ExecuteScalar();
                            if (r != null) adminId = Convert.ToInt32(r);
                        }

                        using (SqlCommand cmd = new SqlCommand(
                            @"INSERT INTO NOTIFICATION
                                (recipientID, recipientRole, title, message, isRead, createdAt, notifType)
                              VALUES
                                (@rid, 'admin', @title, @msg, 0, GETDATE(), 'drop_requested')", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@rid",   adminId);
                            cmd.Parameters.AddWithValue("@title", "Drop request — " + courseName);
                            cmd.Parameters.AddWithValue("@msg",
                                Session["UserName"] + " has submitted a drop request for " + courseName + ".");
                            cmd.ExecuteNonQuery();
                        }

                        tx.Commit();
                        ShowMessage("Drop request submitted for " + courseName + ". Awaiting HOP approval.", true);
                    }
                    catch (Exception ex)
                    {
                        tx.Rollback();
                        ShowMessage("Error: " + ex.Message, false);
                    }
                }
            }

            LoadEnrolmentPage();
        }

        // ══════════════════════════════════════════════════════
        // CHECK WINDOW IS OPEN
        // ══════════════════════════════════════════════════════
        private bool IsWindowOpen()
        {
            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT COUNT(*) FROM SEMESTER_SESSION WHERE status = 'Open'", conn))
                {
                    conn.Open();
                    return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                }
            }
            catch { return false; }
        }

        // ══════════════════════════════════════════════════════
        // HELPERS — used in .aspx bindings
        // ══════════════════════════════════════════════════════
        public string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "enrolled":       return "badge-enrolled";
                case "pending":        return "badge-pending";
                case "confirmed":      return "badge-confirmed";
                case "dropped":        return "badge-dropped";
                case "rejected":       return "badge-rejected";
                case "drop_requested": return "badge-drop-req";
                default:               return "badge-pending";
            }
        }

        public string GetStatusLabel(string status)
        {
            switch (status)
            {
                case "enrolled":       return "Enrolled";
                case "pending":        return "Pending confirmation";
                case "confirmed":      return "Confirmed";
                case "dropped":        return "Dropped";
                case "rejected":       return "Rejected";
                case "drop_requested": return "Drop requested";
                default:               return status;
            }
        }

        public string GetActionButton(object enrolmentId, string status)
        {
            if (status == "drop_requested")
                return "<span class=\"badge-drop-req\">Drop requested</span>";
            if (status == "dropped")
                return "<span class=\"badge-dropped\">Dropped</span>";

            // Only show drop button if window is open
            return $"<asp:LinkButton runat='server' CommandName='DropCourse' CommandArgument='{enrolmentId}' " +
                   $"CssClass='btn-drop' OnClientClick=\"return confirm('Submit drop request for this course?');\">Drop</asp:LinkButton>";
        }

        public string GetDropResult(string status)
        {
            switch (status)
            {
                case "drop_requested": return "<span style='color:#7e5109;font-size:0.82rem;'>⏳ Awaiting HOP decision</span>";
                case "dropped":        return "<span style='color:#155724;font-size:0.82rem;'>✅ Approved by HOP</span>";
                case "rejected":       return "<span style='color:#721c24;font-size:0.82rem;'>❌ Rejected by HOP</span>";
                default:               return "—";
            }
        }

        // ══════════════════════════════════════════════════════
        // SHOW MESSAGE
        // ══════════════════════════════════════════════════════
        private void ShowMessage(string text, bool success)
        {
            lblMessage.Text     = "<i class='fas fa-" + (success ? "check" : "exclamation") + "-circle me-2'></i>" + text;
            lblMessage.CssClass = "alert-msg " + (success ? "alert-success-custom" : "alert-danger-custom");
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
