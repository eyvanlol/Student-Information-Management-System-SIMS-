using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;

namespace StudentManagementSystem
{
    public partial class StudentProfile : System.Web.UI.Page
    {
        // ══════════════════════════════════════════════════════
        // PAGE LOAD
        // ══════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            // ── Auth check ──
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Student")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // ── Set common UI labels from session ──
            if (Session["UserName"] != null)
            {
                string name = Session["UserName"].ToString();
                lblUserName.Text = name;
                lblTopUserName.Text = name;
                lblProfileName.Text = name;
            }

            // ── Load profile data on first load ──
            if (!IsPostBack)
            {
                LoadProfile();
                LoadProfilePicture();
            }
        }

        // ══════════════════════════════════════════════════════
        // LOAD ALL PROFILE DATA
        // ══════════════════════════════════════════════════════
        private void LoadProfile()
        {
            int studentId = Convert.ToInt32(Session["UserID"]);

            LoadStudentDetails(studentId);
            LoadProgrammeName(studentId);
            LoadIntakeSemester(studentId);
            LoadCGPA(studentId);
        }

        // ══════════════════════════════════════════════════════
        // 1. LOAD STUDENT DETAILS (from STUDENT table)
        // ══════════════════════════════════════════════════════
        private void LoadStudentDetails(int studentId)
        {
            try
            {
                string sql = @"
                    SELECT  s.studentCode,
                            s.email,
                            s.personalEmail,
                            s.emergencyContactName,
                            s.emergencyContactRel,
                            s.emergencyContactPhone,
                            s.isActivated
                    FROM    STUDENT s
                    WHERE   s.studentID = @sid";

                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblStudentCode.Text = reader["studentCode"] != DBNull.Value ? reader["studentCode"].ToString() : "—";
                            lblTopStudentId.Text = reader["studentCode"] != DBNull.Value ? reader["studentCode"].ToString() : "";
                            lblInstEmail.Text = reader["email"] != DBNull.Value ? reader["email"].ToString() : "—";
                            lblPersonalEmail.Text = reader["personalEmail"] != DBNull.Value ? reader["personalEmail"].ToString() : "—";
                            lblEmergencyName.Text = reader["emergencyContactName"] != DBNull.Value ? reader["emergencyContactName"].ToString() : "—";
                            lblEmergencyRel.Text = reader["emergencyContactRel"] != DBNull.Value ? reader["emergencyContactRel"].ToString() : "—";
                            lblEmergencyPhone.Text = reader["emergencyContactPhone"] != DBNull.Value ? reader["emergencyContactPhone"].ToString() : "—";

                            // Account status based on isActivated flag
                            bool isActivated = reader["isActivated"] != DBNull.Value && Convert.ToBoolean(reader["isActivated"]);
                            if (isActivated)
                            {
                                lblAccountStatus.Text = "Active";
                                lblAccountStatus.CssClass = "status-badge status-active";
                            }
                            else
                            {
                                lblAccountStatus.Text = "Pending Activation";
                                lblAccountStatus.CssClass = "status-badge status-pending";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Log error (in production, use proper logging)
                lblStudentCode.Text = "Error loading profile";
            }
        }

        // ══════════════════════════════════════════════════════
        // 2. LOAD PROGRAMME NAME (join to PROGRAMME)
        // ══════════════════════════════════════════════════════
        private void LoadProgrammeName(int studentId)
        {
            try
            {
                string sql = @"
                    SELECT  p.programmeName
                    FROM    STUDENT s
                    JOIN    PROGRAMME p ON s.programmeID = p.programmeID
                    WHERE   s.studentID = @sid";

                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();

                    string programmeName = result != null ? result.ToString() : "—";
                    lblProgramme.Text = programmeName;
                    lblProfileProgramme.Text = programmeName;
                    lblProgrammeName.Text = programmeName;
                }
            }
            catch
            {
                lblProgramme.Text = "";
                lblProfileProgramme.Text = "—";
                lblProgrammeName.Text = "—";
            }
        }

        // ══════════════════════════════════════════════════════
        // 3. LOAD INTAKE SEMESTER (earliest enrolment record)
        // ══════════════════════════════════════════════════════
        private void LoadIntakeSemester(int studentId)
        {
            try
            {
                string sql = @"
                    SELECT  TOP 1 semester + ' ' + academicYear AS intakeLabel
                    FROM    ENROLMENT
                    WHERE   studentID = @sid
                    ORDER   BY enrolDate ASC, enrolmentID ASC";

                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();

                    lblIntakeSemester.Text = result != null ? result.ToString() : "—";
                }
            }
            catch
            {
                lblIntakeSemester.Text = "—";
            }
        }

        // ══════════════════════════════════════════════════════
        // 4. LOAD CURRENT CGPA (from published RESULT records)
        // ══════════════════════════════════════════════════════
        private void LoadCGPA(int studentId)
        {
            try
            {
                string sql = @"
                    SELECT  CASE
                                WHEN COUNT(*) = 0 THEN NULL
                                ELSE CAST(ROUND(AVG(CAST(GPA AS FLOAT)), 2) AS DECIMAL(3,2))
                            END
                    FROM    RESULT
                    WHERE   studentID       = @sid
                    AND     publishedStatus = 'Published'";

                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@sid", studentId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();

                    lblCGPA.Text = (result != null && result != DBNull.Value)
                        ? result.ToString()
                        : "—";
                }
            }
            catch
            {
                lblCGPA.Text = "—";
            }
        }

        // ══════════════════════════════════════════════════════
        // LOGOUT
        // ══════════════════════════════════════════════════════
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        // ══════════════════════════════════════════════════════
        // PROFILE PICTURE  (file-based, no database column needed)
        // Files are stored as ~/Uploads/ProfilePictures/student_{id}.{ext}
        // ══════════════════════════════════════════════════════
        private string GetProfilePictureUrl()
        {
            int studentId = Convert.ToInt32(Session["UserID"]);
            string uploadPath = Server.MapPath("~/Uploads/ProfilePictures/");
            string[] extensions = { ".jpg", ".jpeg", ".png", ".gif" };

            string imageUrl = "~/Uploads/ProfilePictures/default.png";

            foreach (string ext in extensions)
            {
                string filePath = Path.Combine(uploadPath, "student_" + studentId + ext);
                if (File.Exists(filePath))
                {
                    // ?v= busts the browser cache so a freshly uploaded picture shows immediately
                    imageUrl = "~/Uploads/ProfilePictures/student_" + studentId + ext + "?v=" + DateTime.Now.Ticks;
                    break;
                }
            }

            return imageUrl;
        }

        private void LoadProfilePicture()
        {
            imgProfilePic.ImageUrl = GetProfilePictureUrl();
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            lblUploadMsg.CssClass = "text-warning d-block mt-2";

            if (!fuProfilePic.HasFile)
            {
                lblUploadMsg.Text = "Please select an image file.";
                return;
            }

            string ext = Path.GetExtension(fuProfilePic.FileName).ToLower();
            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".gif")
            {
                lblUploadMsg.Text = "Only JPG, PNG, or GIF files allowed.";
                return;
            }

            if (fuProfilePic.PostedFile.ContentLength > 2 * 1024 * 1024)
            {
                lblUploadMsg.Text = "File size must be less than 2MB.";
                return;
            }

            int studentId = Convert.ToInt32(Session["UserID"]);
            string uploadPath = Server.MapPath("~/Uploads/ProfilePictures/");

            if (!Directory.Exists(uploadPath))
                Directory.CreateDirectory(uploadPath);

            // Remove any previous picture (any extension) before saving the new one
            DeleteExistingProfilePictures(studentId, uploadPath);

            string fullPath = Path.Combine(uploadPath, "student_" + studentId + ext);

            try
            {
                fuProfilePic.SaveAs(fullPath);
                lblUploadMsg.CssClass = "text-success d-block mt-2";
                lblUploadMsg.Text = "Profile picture updated!";
                LoadProfilePicture();
            }
            catch (Exception ex)
            {
                lblUploadMsg.CssClass = "text-danger d-block mt-2";
                lblUploadMsg.Text = "Error: " + ex.Message;
            }
        }

        protected void btnRemovePic_Click(object sender, EventArgs e)
        {
            int studentId = Convert.ToInt32(Session["UserID"]);
            string uploadPath = Server.MapPath("~/Uploads/ProfilePictures/");

            DeleteExistingProfilePictures(studentId, uploadPath);

            lblUploadMsg.CssClass = "text-success d-block mt-2";
            lblUploadMsg.Text = "Profile picture removed.";
            LoadProfilePicture();
        }

        private void DeleteExistingProfilePictures(int studentId, string uploadPath)
        {
            string[] extensions = { ".jpg", ".jpeg", ".png", ".gif" };
            foreach (string ext in extensions)
            {
                string filePath = Path.Combine(uploadPath, "student_" + studentId + ext);
                if (File.Exists(filePath))
                    File.Delete(filePath);
            }
        }
    }
}