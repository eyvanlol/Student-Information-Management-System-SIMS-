using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class ManageProgrammes : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Same role guard used by AdminDashboard
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            lblUserName.Text = Session["UserName"].ToString();
            lblTopUserName.Text = Session["UserName"].ToString();

            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        // Current search term, kept across postbacks (paging, save, delete)
        private string CurrentSearch
        {
            get { return ViewState["search"] as string ?? ""; }
            set { ViewState["search"] = value; }
        }

        // =================================================================
        //  READ  (with optional search filter + paging-safe rebind)
        // =================================================================
        private void BindGrid()
        {
            string search = CurrentSearch;

            string sql =
                "SELECT programmeID, programmeName, programmeCode, faculty, " +
                "       totalCredits, durationYears, status FROM PROGRAMME";

            if (!string.IsNullOrEmpty(search))
                sql += " WHERE programmeName LIKE @q OR programmeCode LIKE @q OR faculty LIKE @q";

            sql += " ORDER BY programmeID";

            DataTable dt = new DataTable();
            using (SqlConnection conn = DbHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (!string.IsNullOrEmpty(search))
                    cmd.Parameters.AddWithValue("@q", "%" + search + "%");

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            gvProgrammes.DataSource = dt;
            gvProgrammes.DataBind();

            // If a delete emptied the last page, drop back to a valid page.
            if (gvProgrammes.PageCount > 0 && gvProgrammes.PageIndex >= gvProgrammes.PageCount)
            {
                gvProgrammes.PageIndex = gvProgrammes.PageCount - 1;
                gvProgrammes.DataSource = dt;
                gvProgrammes.DataBind();
            }
        }

        // ----- Search -------------------------------------------------------
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            CurrentSearch = txtSearch.Text.Trim();
            gvProgrammes.PageIndex = 0;
            BindGrid();
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            CurrentSearch = "";
            txtSearch.Text = "";
            gvProgrammes.PageIndex = 0;
            BindGrid();
        }

        // ----- Paging -------------------------------------------------------
        protected void gvProgrammes_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvProgrammes.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        // =================================================================
        //  CREATE / UPDATE  (one button, decided by the hidden ID)
        // =================================================================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            bool isUpdate = !string.IsNullOrEmpty(hfProgrammeID.Value);

            string sql = isUpdate
                ? "UPDATE PROGRAMME SET programmeName=@name, programmeCode=@code, " +
                  "faculty=@fac, totalCredits=@cr, durationYears=@dur, status=@st " +
                  "WHERE programmeID=@id"
                : "INSERT INTO PROGRAMME " +
                  "(programmeName, programmeCode, faculty, totalCredits, durationYears, status) " +
                  "VALUES (@name, @code, @fac, @cr, @dur, @st)";

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@name", txtName.Text.Trim());
                    cmd.Parameters.AddWithValue("@code", txtCode.Text.Trim());
                    cmd.Parameters.AddWithValue("@fac", ddlFaculty.SelectedValue);
                    cmd.Parameters.AddWithValue("@cr", Convert.ToInt32(txtCredits.Text));
                    cmd.Parameters.AddWithValue("@dur", Convert.ToInt32(txtDuration.Text));
                    cmd.Parameters.AddWithValue("@st", ddlStatus.SelectedValue);
                    if (isUpdate)
                        cmd.Parameters.AddWithValue("@id", Convert.ToInt32(hfProgrammeID.Value));

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage(isUpdate ? "Programme updated successfully." : "Programme added successfully.", true);
                ClearForm();
                BindGrid();
            }
            catch (SqlException ex)
            {
                // 2627 / 2601 = duplicate value in a UNIQUE column (programmeCode)
                string friendly = (ex.Number == 2627 || ex.Number == 2601)
                    ? "That programme code already exists. Please use a unique code."
                    : "Database error: " + ex.Message;
                ShowMessage(friendly, false);
            }
        }

        // =================================================================
        //  Grid row actions: Edit (load into form) / Delete
        // =================================================================
        protected void gvProgrammes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditRow")
                LoadIntoForm(id);
            else if (e.CommandName == "DeleteRow")
                DeleteProgramme(id);
        }

        private void LoadIntoForm(int id)
        {
            const string sql = "SELECT * FROM PROGRAMME WHERE programmeID=@id";

            using (SqlConnection conn = DbHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        hfProgrammeID.Value = id.ToString();
                        txtName.Text = r["programmeName"].ToString();
                        txtCode.Text = r["programmeCode"].ToString();
                        txtCredits.Text = r["totalCredits"].ToString();
                        txtDuration.Text = r["durationYears"].ToString();
                        SetListValue(ddlFaculty, r["faculty"].ToString());
                        SetListValue(ddlStatus, r["status"].ToString());
                    }
                }
            }

            lblFormTitle.Text = "Edit Programme";
            btnSave.Text = "Update Programme";
        }

        private void DeleteProgramme(int id)
        {
            const string sql = "DELETE FROM PROGRAMME WHERE programmeID=@id";

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowMessage("Programme deleted.", true);
                ClearForm();
                BindGrid();
            }
            catch (SqlException ex)
            {
                // 547 = row is still referenced by STUDENT or COURSE (FK)
                string friendly = (ex.Number == 547)
                    ? "Cannot delete: students or courses are still linked to this programme."
                    : "Database error: " + ex.Message;
                ShowMessage(friendly, false);
            }
        }

        // =================================================================
        //  Helpers
        // =================================================================
        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void ClearForm()
        {
            hfProgrammeID.Value = "";
            txtName.Text = "";
            txtCode.Text = "";
            txtCredits.Text = "";
            txtDuration.Text = "";
            ddlFaculty.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            lblFormTitle.Text = "Add New Programme";
            btnSave.Text = "Save Programme";
        }

        private void SetListValue(DropDownList ddl, string value)
        {
            ListItem item = ddl.Items.FindByValue(value);
            if (item != null)
            {
                ddl.ClearSelection();
                item.Selected = true;
            }
        }

        private void ShowMessage(string text, bool ok)
        {
            pnlMsg.Visible = true;
            divMsg.Attributes["class"] = ok ? "alert alert-success" : "alert alert-danger";
            litMsg.Text = text;
        }
    }
}
