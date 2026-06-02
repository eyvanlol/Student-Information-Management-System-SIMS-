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
            string role = hdnRole.Value;

            // Hardcoded credentials
            bool isValid = false;
            string redirectPage = "";

            if (role == "admin" && email == "admin@college.edu" && password == "admin123")
            {
                isValid = true;
                redirectPage = "AdminDashboard.aspx";
                Session["UserName"] = "Head of Programme";
                Session["UserRole"] = "Admin";
                Session["UserEmail"] = email;
            }
            else if (role == "lecturer" && email == "lecturer@college.edu" && password == "lecturer123")
            {
                isValid = true;
                redirectPage = "LecturerDashboard.aspx";
                Session["UserName"] = "Lecturer";
                Session["UserRole"] = "Lecturer";
                Session["UserEmail"] = email;
            }
            else if (role == "student" && email == "student@college.edu" && password == "student123")
            {
                isValid = true;
                redirectPage = "StudentDashboard.aspx";
                Session["UserName"] = "Eyvan";
                Session["UserRole"] = "Student";
                Session["UserEmail"] = email;
            }

            if (isValid)
            {
                Response.Redirect(redirectPage);
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