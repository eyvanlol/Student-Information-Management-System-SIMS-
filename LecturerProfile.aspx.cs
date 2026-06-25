using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
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
                LoadProfilePicture();
                LoadSidebarAvatar();
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

        // ============================================================
        // PROFILE PICTURE METHODS - NO DATABASE REQUIRED
        // ============================================================

        /// <summary>
        /// Gets the profile picture URL for the current lecturer
        /// </summary>
        private string GetProfilePictureUrl()
        {
            int lecturerID = Convert.ToInt32(Session["UserID"]);
            string uploadPath = Server.MapPath("~/Uploads/ProfilePictures/");
            string[] extensions = { ".jpg", ".jpeg", ".png", ".gif" };

            string imageUrl = "~/Uploads/ProfilePictures/default.png";

            foreach (string ext in extensions)
            {
                string filePath = Path.Combine(uploadPath, "lecturer_" + lecturerID + ext);
                if (File.Exists(filePath))
                {
                    imageUrl = "~/Uploads/ProfilePictures/lecturer_" + lecturerID + ext + "?v=" + DateTime.Now.Ticks;
                    break;
                }
            }

            return imageUrl;
        }

        /// <summary>
        /// Loads the main profile picture
        /// </summary>
        private void LoadProfilePicture()
        {
            imgProfilePic.ImageUrl = GetProfilePictureUrl();
        }

        /// <summary>
        /// Loads the sidebar avatar (same as profile picture)
        /// </summary>
        private void LoadSidebarAvatar()
        {
            imgSidebarAvatar.ImageUrl = GetProfilePictureUrl();
        }

        /// <summary>
        /// Upload a new profile picture
        /// </summary>
        protected void btnUpload_Click(object sender, EventArgs e)
        {
            lblUploadMsg.Text = "";
            lblUploadMsg.CssClass = "text-danger d-block mt-2";

            if (!fuProfilePic.HasFile)
            {
                lblUploadMsg.Text = "Please select an image file.";
                return;
            }

            // Validate extension manually (no System.Linq)
            string ext = Path.GetExtension(fuProfilePic.FileName).ToLower();
            bool isValidExtension = false;

            if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".gif")
            {
                isValidExtension = true;
            }

            if (!isValidExtension)
            {
                lblUploadMsg.Text = "Only JPG, PNG, or GIF files allowed.";
                return;
            }

            // Validate size (max 2MB)
            if (fuProfilePic.PostedFile.ContentLength > 2 * 1024 * 1024)
            {
                lblUploadMsg.Text = "File size must be less than 2MB.";
                return;
            }

            int lecturerID = Convert.ToInt32(Session["UserID"]);
            string uploadPath = Server.MapPath("~/Uploads/ProfilePictures/");

            // Create directory if missing
            if (!Directory.Exists(uploadPath))
                Directory.CreateDirectory(uploadPath);

            // Delete any existing pictures for this lecturer
            DeleteExistingProfilePictures(lecturerID, uploadPath);

            // Save new file
            string fileName = "lecturer_" + lecturerID + ext;
            string fullPath = Path.Combine(uploadPath, fileName);

            try
            {
                fuProfilePic.SaveAs(fullPath);
                lblUploadMsg.CssClass = "text-success d-block mt-2";
                lblUploadMsg.Text = "Profile picture updated!";

                // Refresh both profile pic and sidebar avatar
                LoadProfilePicture();
                LoadSidebarAvatar();
            }
            catch (Exception ex)
            {
                lblUploadMsg.Text = "Error: " + ex.Message;
            }
        }

        /// <summary>
        /// Remove profile picture and revert to default
        /// </summary>
        protected void btnRemovePic_Click(object sender, EventArgs e)
        {
            int lecturerID = Convert.ToInt32(Session["UserID"]);
            string uploadPath = Server.MapPath("~/Uploads/ProfilePictures/");

            DeleteExistingProfilePictures(lecturerID, uploadPath);

            lblUploadMsg.CssClass = "text-success d-block mt-2";
            lblUploadMsg.Text = "Profile picture removed.";

            // Refresh both profile pic and sidebar avatar
            LoadProfilePicture();
            LoadSidebarAvatar();
        }

        /// <summary>
        /// Helper: Delete all profile pictures for a lecturer
        /// </summary>
        private void DeleteExistingProfilePictures(int lecturerID, string uploadPath)
        {
            string[] extensions = { ".jpg", ".jpeg", ".png", ".gif" };

            foreach (string ext in extensions)
            {
                string filePath = Path.Combine(uploadPath, "lecturer_" + lecturerID + ext);
                if (File.Exists(filePath))
                    File.Delete(filePath);
            }
        }
    }
}