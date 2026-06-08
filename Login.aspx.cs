using System;

namespace StudentManagementSystem
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                alertBox.Style["display"] = "none";
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            if (email == "admin@college.edu" && password == "admin123")
            {
                Session["UserName"] = "Head of Programme";
                Session["UserRole"] = "Admin";
                Session["UserEmail"] = email;
                Response.Redirect("AdminDashboard.aspx");
            }
            else if (email == "lecturer@college.edu" && password == "lecturer123")
            {
                Session["UserName"] = "Lecturer";
                Session["UserRole"] = "Lecturer";
                Session["UserEmail"] = email;
                Response.Redirect("LecturerDashboard.aspx");
            }
            else if (email == "student@college.edu" && password == "student123")
            {
                Session["UserName"] = "Eyvan";
                Session["UserRole"] = "Student";
                Session["UserEmail"] = email;
                Response.Redirect("StudentDashboard.aspx");
            }
            else
            {
                alertBox.Style["display"] = "block";
                alertBox.Attributes["class"] = "alert-box alert-error";
                alertBox.InnerHtml = "<i class='fas fa-exclamation-circle me-2'></i>Invalid email or password. Please check your credentials and try again.";
            }
        }
    }
}
