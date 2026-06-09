using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Security;

namespace StudentManagementSystem
{
    public partial class Login : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["SIMSConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                alertBox.Style["display"] = "none";
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;

            LoginUser user = CheckAllTables(email, password);

            if (user == null)
            {
                alertBox.Style["display"] = "block";
                alertBox.Attributes["class"] = "alert-box alert-error";
                alertBox.InnerHtml = "Invalid email or password.";
                return;
            }

            Session["UserID"] = user.UserID;
            Session["UserName"] = user.Name;
            Session["UserEmail"] = email;
            Session["UserRole"] = user.Role;

            FormsAuthentication.SetAuthCookie(email, true);

            if (user.Role == "Admin")
                Response.Redirect("AdminDashboard.aspx");
            else if (user.Role == "Lecturer")
                Response.Redirect("LecturerDashboard.aspx");
            else if (user.Role == "Student")
                Response.Redirect("StudentDashboard.aspx");
        }

        private LoginUser CheckAllTables(string email, string password)
        {
            LoginUser user;

            user = FindUser("HOP_ADMIN", "adminID", "name", "email", "password", "Admin", email, password);
            if (user != null) return user;

            user = FindUser("LECTURER", "lecturerID", "name", "email", "password", "Lecturer", email, password);
            if (user != null) return user;

            user = FindUser("STUDENT", "studentID", "name", "email", "password", "Student", email, password);
            if (user != null) return user;

            return null;
        }

        private LoginUser FindUser(
            string table,
            string idColumn,
            string nameColumn,
            string emailColumn,
            string passwordColumn,
            string role,
            string email,
            string password)
        {
            string sql = $@"
                SELECT {idColumn}, {nameColumn}, {passwordColumn}
                FROM {table}
                WHERE {emailColumn} = @Email";

            using (SqlConnection conn = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@Email", email);

                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    string dbPassword = dr[passwordColumn].ToString();

                    if (VerifyPassword(password, dbPassword))
                    {
                        return new LoginUser
                        {
                            UserID = Convert.ToInt32(dr[idColumn]),
                            Name = dr[nameColumn].ToString(),
                            Role = role
                        };
                    }
                }
            }

            return null;
        }

        private bool VerifyPassword(string inputPassword, string dbPassword)
        {
            // allows old plain passwords
            if (inputPassword == dbPassword)
                return true;

            // checks hashed passwords
            string hashedInput = HashPassword(inputPassword);
            return hashedInput == dbPassword;
        }

        public static string HashPassword(string password)
        {
            using (SHA256 sha = SHA256.Create())
            {
                byte[] bytes = sha.ComputeHash(Encoding.UTF8.GetBytes(password));
                return Convert.ToBase64String(bytes);
            }
        }

        private class LoginUser
        {
            public int UserID { get; set; }
            public string Name { get; set; }
            public string Role { get; set; }
        }
    }
}
