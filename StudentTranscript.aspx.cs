using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;

namespace StudentManagementSystem
{
    public partial class StudentTranscript : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["SIMSConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Student")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            lblUserName.Text = Session["UserName"].ToString();
            lblTopUserName.Text = Session["UserName"].ToString();

            if (!IsPostBack)
            {
                int studentID = Convert.ToInt32(Session["UserID"]);

                LoadAttendance(studentID);
                LoadResults(studentID);
            }
        }

        private void LoadAttendance(int studentID)
        {
            string sql = @"
                SELECT 
                    c.courseCode,
                    c.courseName,
                    a.attendanceDate,
                    a.status
                FROM ATTENDANCE a
                INNER JOIN COURSE c ON a.courseID = c.courseID
                WHERE a.studentID = @studentID
                ORDER BY a.attendanceDate DESC";

            gvAttendance.DataSource = GetData(sql, studentID);
            gvAttendance.DataBind();
        }

        private void LoadResults(int studentID)
        {
            string sql = @"
                SELECT 
                    c.courseCode,
                    c.courseName,
                    r.semester,
                    r.marks,
                    r.grade
                FROM RESULT r
                INNER JOIN COURSE c ON r.courseID = c.courseID
                WHERE r.studentID = @studentID
                ORDER BY r.semester ASC, c.courseCode ASC";

            gvResults.DataSource = GetData(sql, studentID);
            gvResults.DataBind();
        }

        private DataTable GetData(string sql, int studentID)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.Parameters.AddWithValue("@studentID", studentID);
                da.Fill(dt);
            }

            return dt;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();

            Response.Redirect("Login.aspx");
        }
    }
}
