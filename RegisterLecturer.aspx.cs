using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class RegisterLecturer : System.Web.UI.Page
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
                LoadLecturers();
            }
        }

        // Load all registered lecturers
        private void LoadLecturers()
        {
            string sql = "SELECT lecturerID, name, email FROM LECTURER ORDER BY lecturerID DESC";

            try
            {
                DataTable dt = DbHelper.ExecuteQuery(sql);
                gvLecturers.DataSource = dt;
                gvLecturers.DataBind();
                lblLecturerCount.Text = dt.Rows.Count.ToString();
            }
            catch
            {
                gvLecturers.DataSource = null;
                gvLecturers.DataBind();
                lblLecturerCount.Text = "0";
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim().ToLower();
            string password = Login.HashPassword(txtPassword.Text);

            string sql = "INSERT INTO LECTURER (name, email, password) VALUES (@name, @email, @password)";

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@name", name);
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@password", password);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage($"Lecturer '{name}' registered successfully!", true);
                ClearForm();
                LoadLecturers(); // Refresh the list
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
        protected void gvLecturers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRow")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                DeleteLecturer(id);
            }
        }

        private void DeleteLecturer(int id)
        {
            string sql = "DELETE FROM LECTURER WHERE lecturerID=@id";

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowMessage("Lecturer deleted.", true);
                LoadLecturers(); // Refresh the list
            }
            catch (SqlException ex)
            {
                string friendly = (ex.Number == 547)
                    ? "Cannot delete: this lecturer is assigned to courses."
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
