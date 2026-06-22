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
                LoadIdentity();

                if (!IsPostBack)
                {
                    LoadStats();
                }
            }
        }

        private void LoadIdentity()
        {
            try
            {
                object o = DbHelper.ExecuteScalar(
                    "SELECT headOf FROM HOP_ADMIN WHERE adminID = @id",
                    new SqlParameter("@id", Convert.ToInt32(Session["UserID"])));
                string h = (o == null || o == DBNull.Value) ? "" : o.ToString();
                if (!string.IsNullOrEmpty(h))
                    lblRoleIdentity.Text = "Head of Programme, " + h;
                if (!IsPostBack)
                    txtHeadOf.Text = h;
            }
            catch
            {
                // headOf column not present yet (PATCH 11) -> keep default label.
            }
        }

        protected void btnSaveHeadOf_Click(object sender, EventArgs e)
        {
            string h = txtHeadOf.Text.Trim();
            try
            {
                DbHelper.ExecuteNonQuery(
                    "UPDATE HOP_ADMIN SET headOf = @h WHERE adminID = @id",
                    new SqlParameter("@h", string.IsNullOrEmpty(h) ? (object)DBNull.Value : h),
                    new SqlParameter("@id", Convert.ToInt32(Session["UserID"])));

                lblRoleIdentity.Text = string.IsNullOrEmpty(h) ? "Head of Programme" : "Head of Programme, " + h;
                lblHeadOfMsg.Text = "<span class='text-success'><i class='fas fa-check-circle me-1'></i>Saved.</span>";
            }
            catch (Exception ex)
            {
                lblHeadOfMsg.Text = "<span class='text-danger'>Could not save: " + ex.Message + "</span>";
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
