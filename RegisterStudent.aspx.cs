using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class RegisterStudent : System.Web.UI.Page
    {
        // College email domain for auto-generated student logins.
        private const string COLLEGE_DOMAIN = "student.newinti.edu.my";

        // One shared RNG for codes/passwords (sufficient for this project).
        private static readonly Random _rng = new Random();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            lblUserName.Text = Session["UserName"].ToString();
            lblTopUserName.Text = Session["UserName"].ToString();

            if (!IsPostBack)
            {
                LoadProgrammes();
                LoadIntakes();
                LoadStudents();
            }
        }

        private void LoadProgrammes()
        {
            string sql = "SELECT programmeID, programmeName FROM PROGRAMME WHERE status = 'Active' ORDER BY programmeName";
            DataTable dt = DbHelper.ExecuteQuery(sql);

            ddlProgramme.Items.Clear();
            ddlProgramme.Items.Add(new ListItem("-- Select Programme --", ""));
            foreach (DataRow row in dt.Rows)
                ddlProgramme.Items.Add(new ListItem(row["programmeName"].ToString(), row["programmeID"].ToString()));
        }

        // Populate the intake dropdown from SEMESTER_SESSION (optional field).
        private void LoadIntakes()
        {
            ddlIntake.Items.Clear();
            ddlIntake.Items.Add(new ListItem("-- Not set --", ""));
            try
            {
                DataTable dt = DbHelper.ExecuteQuery(
                    "SELECT semesterName FROM SEMESTER_SESSION ORDER BY sessionID DESC");
                foreach (DataRow row in dt.Rows)
                    ddlIntake.Items.Add(new ListItem(row["semesterName"].ToString(), row["semesterName"].ToString()));
            }
            catch
            {
                // SEMESTER_SESSION missing -> just leave the default option.
            }
        }

        private void LoadStudents()
        {
            string sql = @"
                SELECT s.studentID, s.name, s.email, s.studentCode, s.isActivated, p.programmeName
                FROM STUDENT s
                LEFT JOIN PROGRAMME p ON s.programmeID = p.programmeID
                ORDER BY s.studentID DESC";

            try
            {
                DataTable dt = DbHelper.ExecuteQuery(sql);
                gvStudents.DataSource = dt;
                gvStudents.DataBind();
                lblStudentCount.Text = dt.Rows.Count.ToString();
            }
            catch
            {
                gvStudents.DataSource = null;
                gvStudents.DataBind();
                lblStudentCount.Text = "0";
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string name = txtName.Text.Trim();
            string ic = txtIc.Text.Trim();
            string personalEmail = txtPersonalEmail.Text.Trim().ToLower();
            string phone = txtPhone.Text.Trim();
            string programmeID = ddlProgramme.SelectedValue;
            string intake = ddlIntake.SelectedValue;   // may be ""

            if (string.IsNullOrEmpty(programmeID))
            {
                ShowMessage("Please select a programme.", false);
                return;
            }

            // ----- auto-generate credentials + OTP -----
            string studentCode = GenerateStudentCode();
            string collegeEmail = studentCode.ToLower() + "@" + COLLEGE_DOMAIN;
            string tempPassword = GenerateTempPassword();
            string otp = GenerateOtp();
            DateTime otpExpiry = DateTime.Now.AddHours(24);

            string sql = @"
                INSERT INTO STUDENT
                    (name, email, password, programmeID, personalEmail, icNumber, phone,
                     intakeSemester, studentCode, otpCode, otpExpiry, isActivated)
                VALUES
                    (@name, @email, @pwd, @prog, @pmail, @ic, @phone,
                     @intake, @code, @otp, @exp, 0)";

            // 1) create the record (so the OTP exists even if email later fails)
            try
            {
                DbHelper.ExecuteNonQuery(sql,
                    new SqlParameter("@name", name),
                    new SqlParameter("@email", collegeEmail),
                    new SqlParameter("@pwd", Login.HashPassword(tempPassword)),
                    new SqlParameter("@prog", Convert.ToInt32(programmeID)),
                    new SqlParameter("@pmail", personalEmail),
                    new SqlParameter("@ic", ic),
                    new SqlParameter("@phone", phone),
                    new SqlParameter("@intake", string.IsNullOrEmpty(intake) ? (object)DBNull.Value : intake),
                    new SqlParameter("@code", studentCode),
                    new SqlParameter("@otp", otp),
                    new SqlParameter("@exp", otpExpiry));
            }
            catch (SqlException ex)
            {
                string friendly = (ex.Number == 2627 || ex.Number == 2601)
                    ? "A generated ID or email clashed with an existing record. Please try again."
                    : "Database error: " + ex.Message;
                ShowMessage(friendly, false);
                return;
            }

            // 2) email the welcome + OTP
            try
            {
                EmailHelper.SendStudentWelcome(personalEmail, name, studentCode, collegeEmail, tempPassword, otp);

                ShowMessage(
                    $"Student <strong>{name}</strong> registered. ID <strong>{studentCode}</strong>, " +
                    $"login <strong>{collegeEmail}</strong>. A 6-digit activation code was emailed to {personalEmail}.",
                    true);
                ClearForm();
            }
            catch (Exception ex)
            {
                // Account is created and the OTP is stored; only delivery failed.
                ShowMessage(
                    $"Student <strong>{name}</strong> was created (ID {studentCode}, login {collegeEmail}), " +
                    $"but the activation email could NOT be sent: {ex.Message} " +
                    "Check the SMTP settings in Web.config, then use \"Resend code\" on the verify screen.",
                    false);
            }

            LoadStudents();
        }

        // Next sequential student code, e.g. STU2606005.
        private string GenerateStudentCode()
        {
            object o = DbHelper.ExecuteScalar(
                @"SELECT ISNULL(MAX(CAST(RIGHT(studentCode,3) AS INT)),0)+1
                  FROM STUDENT
                  WHERE studentCode LIKE 'STU%' AND ISNUMERIC(RIGHT(studentCode,3)) = 1");
            int next = (o == null || o == DBNull.Value) ? 1 : Convert.ToInt32(o);
            return "STU" + DateTime.Now.ToString("yyMM") + next.ToString("D3");
        }

        // Readable temporary password, >= 6 chars, e.g. INTI4827.
        private string GenerateTempPassword()
        {
            return "INTI" + _rng.Next(1000, 10000).ToString();
        }

        // 6-digit one-time code, zero-padded.
        private string GenerateOtp()
        {
            return _rng.Next(0, 1000000).ToString("D6");
        }

        protected void gvStudents_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRow")
                DeleteStudent(Convert.ToInt32(e.CommandArgument));
        }

        private void DeleteStudent(int id)
        {
            try
            {
                DbHelper.ExecuteNonQuery("DELETE FROM STUDENT WHERE studentID=@id",
                    new SqlParameter("@id", id));
                ShowMessage("Student deleted.", true);
                LoadStudents();
            }
            catch (SqlException ex)
            {
                string friendly = (ex.Number == 547)
                    ? "Cannot delete: this student has enrolment or attendance records."
                    : "Database error: " + ex.Message;
                ShowMessage(friendly, false);
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void ClearForm()
        {
            txtName.Text = "";
            txtIc.Text = "";
            txtPersonalEmail.Text = "";
            txtPhone.Text = "";
            ddlProgramme.SelectedIndex = 0;
            ddlIntake.SelectedIndex = 0;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        private void ShowMessage(string text, bool ok)
        {
            pnlMsg.Visible = true;
            divMsg.Attributes["class"] = ok ? "alert alert-success" : "alert alert-danger";
            litMsg.Text = $"<i class='fas {(ok ? "fa-check-circle" : "fa-exclamation-circle")} me-2'></i>{text}";
        }
    }
}
