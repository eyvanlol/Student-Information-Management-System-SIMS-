using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class RegisterStudent : System.Web.UI.Page
    {
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
            {
                ddlProgramme.Items.Add(new ListItem(
                    row["programmeName"].ToString(),
                    row["programmeID"].ToString()
                ));
            }
        }

        // Load all enrolled students with programme name
        private void LoadStudents()
        {
            string sql = @"
                SELECT s.studentID, s.name, s.email, p.programmeName 
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

        protected void btnEnrol_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string password = txtPassword.Text;
            string programmeID = ddlProgramme.SelectedValue;

            if (string.IsNullOrEmpty(programmeID))
            {
                ShowMessage("Please select a programme.", false);
                return;
            }

            string sql = "INSERT INTO STUDENT (name, email, password, programmeID) VALUES (@name, @email, @password, @progID)";

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@password", password);
                    cmd.Parameters.AddWithValue("@progID", Convert.ToInt32(programmeID));
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage($"Student '{name}' enrolled successfully!", true);
                ClearForm();
                LoadStudents(); // Refresh the list
            }
            catch (SqlException ex)
            {
                string friendly = (ex.Number == 2627 || ex.Number == 2601)
                    ? "This email is already registered. Please use a different email."
                    : "Database error: " + ex.Message;
                ShowMessage(friendly, false);
            }
        }

        // Handle delete from grid
        protected void gvStudents_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRow")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                DeleteStudent(id);
            }
        }

        private void DeleteStudent(int id)
        {
            string sql = "DELETE FROM STUDENT WHERE studentID=@id";

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowMessage("Student deleted.", true);
                LoadStudents(); // Refresh the list
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
            txtEmail.Text = "";
            txtPassword.Text = "";
            txtConfirmPassword.Text = "";
            ddlProgramme.SelectedIndex = 0;
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