using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
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

            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                LoadCourses();
            }
        }

        private void LoadCourses()
        {
            int lecturerID = Convert.ToInt32(Session["UserID"]);

            string sql = @"
                SELECT courseID, courseCode + ' - ' + courseName AS courseDisplay
                FROM COURSE
                WHERE lecturerID = @lecturerID
                AND status = 'Active'
                ORDER BY courseName";

            using (SqlConnection con = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@lecturerID", lecturerID);

                con.Open();
                ddlCourse.DataSource = cmd.ExecuteReader();
                ddlCourse.DataTextField = "courseDisplay";
                ddlCourse.DataValueField = "courseID";
                ddlCourse.DataBind();
            }

            ddlCourse.Items.Insert(0, new ListItem("-- Select Course --", ""));
        }

        protected void btnLoadStudents_Click(object sender, EventArgs e)
        {
            if (ddlCourse.SelectedValue == "")
            {
                ShowMessage("Please select a course.", false);
                return;
            }

            LoadStudents();
        }

        private void LoadStudents()
        {
            string sql = @"
                SELECT s.studentID, s.name, s.email
                FROM ENROLMENT e
                INNER JOIN STUDENT s ON e.studentID = s.studentID
                WHERE e.courseID = @courseID
                AND e.status IN ('enrolled', 'confirmed')
                ORDER BY s.name";

            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.Parameters.AddWithValue("@courseID", ddlCourse.SelectedValue);
                da.Fill(dt);
            }

            gvStudents.DataSource = dt;
            gvStudents.DataBind();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (ddlCourse.SelectedValue == "")
            {
                ShowMessage("Please select a course.", false);
                return;
            }

            if (gvStudents.Rows.Count == 0)
            {
                ShowMessage("Please load students first.", false);
                return;
            }

            int courseID = Convert.ToInt32(ddlCourse.SelectedValue);
            int lecturerID = Convert.ToInt32(Session["UserID"]);
            DateTime attendanceDate = Convert.ToDateTime(txtDate.Text);
            string sessionType = ddlSessionType.SelectedValue;

            using (SqlConnection con = new SqlConnection(cs))
            {
                con.Open();

                foreach (GridViewRow row in gvStudents.Rows)
                {
                    int studentID = Convert.ToInt32(gvStudents.DataKeys[row.RowIndex].Value);
                    DropDownList ddlStatus = (DropDownList)row.FindControl("ddlStatus");
                    string status = ddlStatus.SelectedValue;

                    string sql = @"
                        INSERT INTO ATTENDANCE
                        (studentID, courseID, lecturerID, attendanceDate, sessionType, status)
                        VALUES
                        (@studentID, @courseID, @lecturerID, @attendanceDate, @sessionType, @status)";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@studentID", studentID);
                        cmd.Parameters.AddWithValue("@courseID", courseID);
                        cmd.Parameters.AddWithValue("@lecturerID", lecturerID);
                        cmd.Parameters.AddWithValue("@attendanceDate", attendanceDate);
                        cmd.Parameters.AddWithValue("@sessionType", sessionType);
                        cmd.Parameters.AddWithValue("@status", status);

                        cmd.ExecuteNonQuery();
                    }

                    CheckAttendanceWarning(studentID, courseID, con);
                }
            }

            ShowMessage("Attendance saved successfully.", true);
            LoadStudents();
        }

        private void CheckAttendanceWarning(int studentID, int courseID, SqlConnection con)
        {
            int present = 0;
            int total = 0;
            string courseName = "";
            string studentEmail = "";

            string sql = @"
                SELECT
                    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS PresentCount,
                    COUNT(*) AS TotalSessions,
                    c.courseName,
                    s.personalEmail
                FROM ATTENDANCE a
                INNER JOIN COURSE c ON a.courseID = c.courseID
                INNER JOIN STUDENT s ON a.studentID = s.studentID
                WHERE a.studentID = @studentID
                AND a.courseID = @courseID
                GROUP BY c.courseName, s.personalEmail";

            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@studentID", studentID);
                cmd.Parameters.AddWithValue("@courseID", courseID);

                using (SqlDataReader dr = cmd.ExecuteReader())
                {
                    if (dr.Read())
                    {
                        present = Convert.ToInt32(dr["PresentCount"]);
                        total = Convert.ToInt32(dr["TotalSessions"]);
                        courseName = dr["courseName"].ToString();
                        studentEmail = dr["personalEmail"].ToString();
                    }
                }
            }

            if (total == 0) return;

            int percent = (int)Math.Round((present / (double)total) * 100);

            if (percent < 80)
            {
                InsertNotification(studentID, courseName, percent, con);

                // Turn this on later when Gmail SMTP is ready
                // SendWarningEmail(studentEmail, courseName, percent);
            }
        }

        private void InsertNotification(int studentID, string courseName, int percent, SqlConnection con)
        {
            string sql = @"
                INSERT INTO NOTIFICATION
                (recipientID, recipientRole, title, message, isRead, notifType)
                VALUES
                (@studentID, 'student', @title, @message, 0, 'attendance')";

            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@studentID", studentID);
                cmd.Parameters.AddWithValue("@title", "Attendance warning - " + courseName);
                cmd.Parameters.AddWithValue("@message",
                    "Your attendance for " + courseName +
                    " is below 80%. Current attendance: " + percent + "%.");

                cmd.ExecuteNonQuery();
            }
        }

        private void SendWarningEmail(string toEmail, string courseName, int percent)
        {
            if (string.IsNullOrEmpty(toEmail)) return;

            MailMessage mail = new MailMessage();
            mail.From = new MailAddress("YOUR_GMAIL@gmail.com");
            mail.To.Add(toEmail);
            mail.Subject = "Attendance Warning - " + courseName;
            mail.Body =
                "Dear Student,\n\n" +
                "Your attendance for " + courseName + " is below the required 80% threshold.\n" +
                "Current attendance: " + percent + "%\n\n" +
                "Please attend future classes to improve your attendance.\n\n" +
                "SIMS";

            SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587);
            smtp.Credentials = new NetworkCredential("YOUR_GMAIL@gmail.com", "YOUR_APP_PASSWORD");
            smtp.EnableSsl = true;
            smtp.Send(mail);
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
            lblMsg.Text = "<div class='alert " +
                          (success ? "alert-success" : "alert-danger") +
                          "'>" + msg + "</div>";
        }
    }
}
