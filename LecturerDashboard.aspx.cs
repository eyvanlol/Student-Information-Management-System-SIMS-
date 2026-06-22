using System;
using System.Data.SqlClient;

namespace StudentManagementSystem
{
    public partial class LecturerDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Lecturer")
            {
                Response.Redirect("Login.aspx");
            }
            else
            {
                lblUserName.Text = Session["UserName"].ToString();
                lblTopUserName.Text = Session["UserName"].ToString();

                try
                {
                    object o = DbHelper.ExecuteScalar(
                        "SELECT lecturerTitle FROM LECTURER WHERE lecturerID = @id",
                        new SqlParameter("@id", Convert.ToInt32(Session["UserID"])));
                    string t = (o == null || o == DBNull.Value) ? "" : o.ToString();
                    if (!string.IsNullOrEmpty(t))
                        lblRoleIdentity.Text = t;
                }
                catch
                {
                    // lecturerTitle column not present yet (PATCH 11) -> keep default.
                }
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
