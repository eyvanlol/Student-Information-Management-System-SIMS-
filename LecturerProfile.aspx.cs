using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace StudentManagementSystem
{
    public partial class LecturerProfile : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Auth check
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Lecturer")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblUserName.Text = Session["UserName"].ToString();
                lblTopUserName.Text = Session["UserName"].ToString();
                LoadProfile();
            }
        }

        private void LoadProfile()
        {
            int lecturerID = Convert.ToInt32(Session["UserID"]);

            string sql = @"
                SELECT lecturerID, name, email, personalEmail, department, staffType
                FROM LECTURER
                WHERE lecturerID = @LecturerID";

            DataTable dt = DbHelper.ExecuteQuery(sql, new SqlParameter("@LecturerID", lecturerID));

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];

                txtLecturerID.Text = row["lecturerID"].ToString();
                txtInstEmail.Text = row["email"].ToString();
                txtName.Text = row["name"].ToString();
                txtPersonalEmail.Text = row["personalEmail"] != DBNull.Value ? row["personalEmail"].ToString() : "";
                txtDepartment.Text = row["department"] != DBNull.Value ? row["department"].ToString() : "";
                lblStaffType.Text = row["staffType"] != DBNull.Value ? row["staffType"].ToString() : "Not Set";
                lblProfileName.Text = row["name"].ToString();

                // Set dropdown
                string staffType = row["staffType"] != DBNull.Value ? row["staffType"].ToString() : "Full-time";
                ddlStaffType.SelectedValue = staffType;
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            int lecturerID = Convert.ToInt32(Session["UserID"]);

            string sql = @"
                UPDATE LECTURER
                SET name = @Name,
                    personalEmail = @PersonalEmail,
                    department = @Department,
                    staffType = @StaffType
                WHERE lecturerID = @LecturerID";

            int rowsAffected = DbHelper.ExecuteNonQuery(sql,
                new SqlParameter("@Name", txtName.Text.Trim()),
                new SqlParameter("@PersonalEmail", string.IsNullOrEmpty(txtPersonalEmail.Text) ? (object)DBNull.Value : txtPersonalEmail.Text.Trim()),
                new SqlParameter("@Department", string.IsNullOrEmpty(txtDepartment.Text) ? (object)DBNull.Value : txtDepartment.Text.Trim()),
                new SqlParameter("@StaffType", ddlStaffType.SelectedValue),
                new SqlParameter("@LecturerID", lecturerID));

            if (rowsAffected > 0)
            {
                ShowAlert("Profile updated successfully.", "success");
                lblLastUpdated.Text = "Last updated: " + DateTime.Now.ToString("MMM dd, yyyy HH:mm");
                // Refresh session name if changed
                Session["UserName"] = txtName.Text.Trim();
                lblUserName.Text = txtName.Text.Trim();
                lblTopUserName.Text = txtName.Text.Trim();
                lblProfileName.Text = txtName.Text.Trim();
            }
            else
            {
                ShowAlert("Failed to update profile. Please try again.", "error");
            }
        }

        private void ShowAlert(string message, string type)
        {
            alertBox.Style["display"] = "block";
            alertBox.Attributes["class"] = "alert-box alert-" + type;
            alertBox.InnerHtml = "<i class='fas fa-" + (type == "success" ? "check-circle" : "exclamation-circle") + " me-2'></i>" + message;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}