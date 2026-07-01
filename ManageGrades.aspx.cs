using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class ManageGrades : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Lecturer")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // UI Fix: Added assignment for both username labels present in your HTML
                string userName = Session["UserName"]?.ToString() ?? "Lecturer";
                lblUserName.Text = userName;
                lblTopUserName.Text = userName;

                LoadLecturerCourses();
            }
        }

        private void LoadLecturerCourses()
        {
            int lecturerId = Convert.ToInt32(Session["UserID"]);
            string sql = "SELECT courseID, courseCode + ' - ' + courseName AS FullName FROM COURSE WHERE lecturerID = @lecturerID";

            DataTable dt = new DataTable();

            using (SqlConnection conn = DbHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@lecturerID", lecturerId);
                using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                {
                    sda.Fill(dt);
                }
            }

            ddlCourses.DataSource = dt;
            ddlCourses.DataValueField = "courseID";
            ddlCourses.DataTextField = "FullName";
            ddlCourses.DataBind();

            if (ddlCourses.Items.Count > 0)
            {
                LoadStudentsForCourse(Convert.ToInt32(ddlCourses.SelectedValue));
            }
        }

        protected void ddlCourses_SelectedIndexChanged(object sender, EventArgs e)
        {
            lblStatus.Visible = false;
            LoadStudentsForCourse(Convert.ToInt32(ddlCourses.SelectedValue));
        }

        private void LoadStudentsForCourse(int courseId)
        {
            // Added r.publishedStatus to the SELECT statement
            string sql = @"
        SELECT s.studentID, s.studentCode, s.name AS studentName,
               ISNULL(r.marks * 0.3, 0) AS assignmentMarks, 
               ISNULL(r.marks * 0.3, 0) AS midtermMarks,
               ISNULL(r.marks * 0.4, 0) AS finalMarks,
               ISNULL(r.publishedStatus, 'Draft') AS publishedStatus
        FROM ENROLMENT e
        INNER JOIN STUDENT s ON e.studentID = s.studentID
        LEFT JOIN RESULT r ON e.studentID = r.studentID AND e.courseID = r.courseID
        WHERE e.courseID = @courseID AND e.status = 'enrolled'";

            DataTable dt = new DataTable();

            using (SqlConnection conn = DbHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@courseID", courseId);
                using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                {
                    sda.Fill(dt);
                }
            }

            rptStudents.DataSource = dt;
            rptStudents.DataBind();
        }
        // ==========================================
        // ACTION 1: SAVE DRAFT
        // ==========================================
        protected void btnSaveDraft_Click(object sender, EventArgs e)
        {
            SaveMarksToDatabase("Draft");
            ShowStatus("Marks saved as Draft successfully. Students cannot see these yet.", "bg-secondary");
        }

        // ==========================================
        // ACTION 2: PUBLISH MARKS
        // ==========================================
        protected void btnPublish_Click(object sender, EventArgs e)
        {
            SaveMarksToDatabase("Published");
            ShowStatus("Marks Published successfully! Notifications sent to students.", "bg-success");
        }

        // ==========================================
        // ACTION 3: LOGOUT (FIXES COMPILATION ERROR)
        // ==========================================
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        private void SaveMarksToDatabase(string status)
        {
            int courseId = Convert.ToInt32(ddlCourses.SelectedValue);
            int lecturerId = Convert.ToInt32(Session["UserID"]);

            foreach (RepeaterItem item in rptStudents.Items)
            {
                HiddenField hfStudentID = (HiddenField)item.FindControl("hfStudentID");
                HiddenField hfTotal = (HiddenField)item.FindControl("hfTotal");
                HiddenField hfGrade = (HiddenField)item.FindControl("hfGrade");

                int studentId = Convert.ToInt32(hfStudentID.Value);
                decimal totalMarks = string.IsNullOrEmpty(hfTotal.Value) ? 0 : Convert.ToDecimal(hfTotal.Value);
                string grade = string.IsNullOrEmpty(hfGrade.Value) ? "F" : hfGrade.Value;

                decimal gpaPoint = CalculateGPAValue(totalMarks);

                string sqlResult = @"
                    IF EXISTS (SELECT 1 FROM RESULT WHERE studentID = @sID AND courseID = @cID)
                    BEGIN
                        UPDATE RESULT SET marks = @marks, grade = @grade, GPA = @gpa, 
                               publishedStatus = @status, publishedDate = @pubDate 
                        WHERE studentID = @sID AND courseID = @cID
                    END
                    ELSE
                    BEGIN
                        INSERT INTO RESULT (studentID, courseID, lecturerID, semester, marks, grade, GPA, publishedStatus, publishedDate)
                        VALUES (@sID, @cID, @lID, '1', @marks, @grade, @gpa, @status, @pubDate)
                    END";

                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sqlResult, conn))
                {
                    cmd.Parameters.AddWithValue("@sID", studentId);
                    cmd.Parameters.AddWithValue("@cID", courseId);
                    cmd.Parameters.AddWithValue("@lID", lecturerId);
                    cmd.Parameters.AddWithValue("@marks", totalMarks);
                    cmd.Parameters.AddWithValue("@grade", grade);
                    cmd.Parameters.AddWithValue("@gpa", gpaPoint);
                    cmd.Parameters.AddWithValue("@status", status);
                    cmd.Parameters.AddWithValue("@pubDate", status == "Published" ? (object)DateTime.Now : DBNull.Value);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                if (status == "Published")
                {
                    CreateNotification(studentId, ddlCourses.SelectedItem.Text, grade);
                }
            }
        }

        private void CreateNotification(int studentId, string courseName, string grade)
        {
            string title = $"Grades published - {courseName.Split('-')[0].Trim()}";
            string msg = $"Your results for {courseName} are now available. Grade: {grade}";

            string sql = "INSERT INTO NOTIFICATION (recipientID, recipientRole, title, message, notifType) VALUES (@rID, 'student', @title, @msg, 'grade')";

            using (SqlConnection conn = DbHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@rID", studentId);
                cmd.Parameters.AddWithValue("@title", title);
                cmd.Parameters.AddWithValue("@msg", msg);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private decimal CalculateGPAValue(decimal marks)
        {
            if (marks >= 80) return 4.00m;
            if (marks >= 75) return 3.67m;
            if (marks >= 70) return 3.33m;
            if (marks >= 65) return 3.00m;
            if (marks >= 60) return 2.67m;
            if (marks >= 55) return 2.33m;
            if (marks >= 50) return 2.00m;
            return 0.00m;
        }

        private void ShowStatus(string message, string cssClass)
        {
            lblStatus.Text = $"<i class='fas fa-check-circle me-1'></i>{message}";
            lblStatus.CssClass = $"badge {cssClass} p-2 fs-6 shadow-sm";
            lblStatus.Visible = true;
        }
    }
}