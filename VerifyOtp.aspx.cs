using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;

namespace StudentManagementSystem
{
    public partial class VerifyOtp : System.Web.UI.Page
    {
        private static readonly Random _rng = new Random();

        protected void Page_Load(object sender, EventArgs e)
        {
            // Must arrive here from a first-time login attempt.
            if (Session["PendingOtpStudentID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                alertBox.Style["display"] = "none";
                lblMaskedEmail.Text = MaskEmail(Convert.ToString(Session["PendingOtpPersonal"]));
            }
        }

        protected void btnVerify_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int studentID = Convert.ToInt32(Session["PendingOtpStudentID"]);
            string input = txtOtp.Text.Trim();

            DataTable dt = DbHelper.ExecuteQuery(
                "SELECT otpCode, otpExpiry, isActivated FROM STUDENT WHERE studentID = @id",
                new SqlParameter("@id", studentID));

            if (dt.Rows.Count == 0)
            {
                ShowError("Account not found. Please log in again.");
                return;
            }

            DataRow row = dt.Rows[0];
            string dbOtp = Convert.ToString(row["otpCode"]);
            bool hasExpiry = row["otpExpiry"] != DBNull.Value;
            DateTime expiry = hasExpiry ? Convert.ToDateTime(row["otpExpiry"]) : DateTime.MinValue;

            if (string.IsNullOrEmpty(dbOtp) || input != dbOtp)
            {
                ShowError("Incorrect code. Please check and try again.");
                return;
            }

            if (hasExpiry && DateTime.Now > expiry)
            {
                ShowError("This code has expired. Tap \"Resend code\" to get a new one.");
                return;
            }

            // Success: activate, clear the code, sign in (keep the temp password).
            DbHelper.ExecuteNonQuery(
                "UPDATE STUDENT SET isActivated = 1, otpCode = NULL, otpExpiry = NULL WHERE studentID = @id",
                new SqlParameter("@id", studentID));

            string email = Convert.ToString(Session["PendingOtpEmail"]);

            Session["UserID"] = studentID;
            Session["UserName"] = Session["PendingOtpName"];
            Session["UserEmail"] = email;
            Session["UserRole"] = "Student";

            Session.Remove("PendingOtpStudentID");
            Session.Remove("PendingOtpName");
            Session.Remove("PendingOtpEmail");
            Session.Remove("PendingOtpPersonal");

            FormsAuthentication.SetAuthCookie(email, true);
            Response.Redirect("StudentDashboard.aspx");
        }

        protected void btnResend_Click(object sender, EventArgs e)
        {
            int studentID = Convert.ToInt32(Session["PendingOtpStudentID"]);
            string personal = Convert.ToString(Session["PendingOtpPersonal"]);
            string name = Convert.ToString(Session["PendingOtpName"]);
            string collegeEmail = Convert.ToString(Session["PendingOtpEmail"]);

            string otp = _rng.Next(0, 1000000).ToString("D6");
            DateTime expiry = DateTime.Now.AddHours(24);

            DbHelper.ExecuteNonQuery(
                "UPDATE STUDENT SET otpCode = @o, otpExpiry = @e WHERE studentID = @id",
                new SqlParameter("@o", otp),
                new SqlParameter("@e", expiry),
                new SqlParameter("@id", studentID));

            try
            {
                EmailHelper.SendOtp(personal, name, collegeEmail, otp);
                ShowSuccess("A new code has been sent to " + MaskEmail(personal) + ".");
            }
            catch (Exception ex)
            {
                ShowError("Could not send the email: " + ex.Message);
            }
        }

        private static string MaskEmail(string email)
        {
            if (string.IsNullOrEmpty(email) || !email.Contains("@")) return "your email";
            int at = email.IndexOf('@');
            string user = email.Substring(0, at);
            string domain = email.Substring(at);
            string shown = user.Length <= 2 ? user.Substring(0, 1) : user.Substring(0, 2);
            return shown + new string('*', Math.Max(3, user.Length - shown.Length)) + domain;
        }

        private void ShowError(string msg)
        {
            alertBox.Style["display"] = "block";
            alertBox.Attributes["class"] = "alert-box mb-3 alert alert-danger";
            alertBox.InnerHtml = "<i class='fas fa-exclamation-circle me-2'></i>" + msg;
        }

        private void ShowSuccess(string msg)
        {
            alertBox.Style["display"] = "block";
            alertBox.Attributes["class"] = "alert-box mb-3 alert alert-success";
            alertBox.InnerHtml = "<i class='fas fa-check-circle me-2'></i>" + msg;
        }
    }
}
