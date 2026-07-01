using System;
using System.Data;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class FinalResultProcessing : System.Web.UI.Page
    {
        // ══════════════════════════════════════════════════════
        // PAGE LOAD
        // ══════════════════════════════════════════════════════
        protected void Page_Load(object sender, EventArgs e)
        {
            // Auth guard — same pattern as the other admin pages.
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (Session["UserName"] != null)
            {
                lblUserName.Text = Session["UserName"].ToString();
                lblTopUserName.Text = Session["UserName"].ToString();
            }

            if (!IsPostBack)
            {
                LoadSemesters();
            }
        }

        // ══════════════════════════════════════════════════════
        // Populate the semester dropdown with semesters that
        // actually have published results to process.
        // ══════════════════════════════════════════════════════
        private void LoadSemesters()
        {
            DataTable dt = DbHelper.ExecuteQuery(
                "SELECT DISTINCT semester FROM RESULT WHERE publishedStatus = 'Published' ORDER BY semester");

            ddlSemester.DataSource = dt;
            ddlSemester.DataTextField = "semester";
            ddlSemester.DataValueField = "semester";
            ddlSemester.DataBind();

            if (dt.Rows.Count == 0)
            {
                ddlSemester.Items.Insert(0, new ListItem("(no published results yet)", ""));
            }
        }

        // ══════════════════════════════════════════════════════
        // STEP 1 — Preview (reads only, saves nothing).
        // ══════════════════════════════════════════════════════
        protected void btnPreview_Click(object sender, EventArgs e)
        {
            BindPreview();
        }

        private void BindPreview()
        {
            string sem = ddlSemester.SelectedValue;
            if (string.IsNullOrEmpty(sem))
            {
                ShowMessage("Please select a semester that has published results.", false);
                return;
            }

            var outcomes = ProgressionService.Preview(sem);
            rptOutcomes.DataSource = outcomes;
            rptOutcomes.DataBind();
            pnlResults.Visible = true;

            if (outcomes.Count == 0)
                ShowMessage("No students have published results for " + sem + ".", false);
        }

        // ══════════════════════════════════════════════════════
        // STEP 2 — Commit (updates STUDENT.currentSemester / status
        // and flags failed subjects for retake).
        // ══════════════════════════════════════════════════════
        protected void btnCommit_Click(object sender, EventArgs e)
        {
            string sem = ddlSemester.SelectedValue;
            if (string.IsNullOrEmpty(sem))
            {
                ShowMessage("Please select a semester first.", false);
                return;
            }

            var applied = ProgressionService.Commit(sem);
            rptOutcomes.DataSource = applied;   // show exactly what was applied (pre-commit snapshot)
            rptOutcomes.DataBind();
            pnlResults.Visible = true;
            ShowMessage(applied.Count + " student record(s) processed and updated for " + sem + ".", true);
        }

        // ══════════════════════════════════════════════════════
        // HELPERS
        // ══════════════════════════════════════════════════════
        public string GetStatusBadge(string status)
        {
            switch (status)
            {
                case "Advancing": return "badge-advancing";
                case "Retake": return "badge-retake";
                case "Resit": return "badge-resit";
                default: return "badge-new";
            }
        }

        private void ShowMessage(string text, bool success)
        {
            lblMessage.Text = "<i class='fas fa-" + (success ? "check" : "exclamation") + "-circle me-2'></i>" + text;
            lblMessage.CssClass = "alert-msg show " + (success ? "alert-success-custom" : "alert-danger-custom");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
