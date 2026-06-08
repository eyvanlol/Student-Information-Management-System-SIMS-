using System;
using System.Data.SqlClient;

namespace StudentManagementSystem
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
            }
            else
            {
                lblUserName.Text = Session["UserName"].ToString();
                lblTopUserName.Text = Session["UserName"].ToString();

                if (!IsPostBack)
                {
                    LoadStats();
                }
            }
        }

        private void LoadStats()
        {
            // PROGRAMME is built; STUDENT / LECTURER / COURSE belong to other
            // modules and may not exist yet, so SafeCount returns 0 if missing.
            lblProgCount.Text = SafeCount("SELECT COUNT(*) FROM PROGRAMME").ToString();
            lblStudents.Text = SafeCount("SELECT COUNT(*) FROM STUDENT").ToString();
            lblLecturers.Text = SafeCount("SELECT COUNT(*) FROM LECTURER").ToString();
            lblCourses.Text = SafeCount("SELECT COUNT(*) FROM COURSE WHERE status = 'Active'").ToString();
        }

        private int SafeCount(string sql)
        {
            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return (result == null || result == DBNull.Value) ? 0 : Convert.ToInt32(result);
                }
            }
            catch (SqlException)
            {
                return 0; // table not created yet
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
