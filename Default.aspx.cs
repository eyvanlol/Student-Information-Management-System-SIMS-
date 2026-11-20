using System;

namespace StudentManagementSystem
{
    // Site root: send everyone to the login page.
    public partial class _Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Redirect("~/Login.aspx");
        }
    }
}
