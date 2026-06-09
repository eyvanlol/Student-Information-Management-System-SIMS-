using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;

namespace StudentManagementSystem
{
    public partial class StudentResult : System.Web.UI.Page
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
                LoadResults(studentID);
            }
        }

        private void LoadResults(int studentID)
        {
            string sql = @"
                SELECT
                    c.courseCode,
                    c.courseName,
                    r.semester,
                    r.marks,
                    r.grade,
                    r.GPA,
                    r.remarks,
                    r.publishedDate
                FROM RESULT r
                INNER JOIN COURSE c ON r.courseID = c.courseID
                WHERE r.studentID = @studentID
                ORDER BY r.publishedDate DESC";

            using (SqlConnection conn = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.Parameters.AddWithValue("@studentID", studentID);

                DataTable dt = new DataTable();
                da.Fill(dt);

                gvResults.DataSource = dt;
                gvResults.DataBind();
            }
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
