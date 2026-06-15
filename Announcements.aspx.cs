using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class Announcements : System.Web.UI.Page
    {
        // ══════════════════════════════════════════════════════
        // PAGE LOAD
        // ══════════════════════════════════════════════════════
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
                LoadStats();
                LoadProgrammes();
                LoadHistory();
                UpdateRecipientCount();
            }
        }

        // ══════════════════════════════════════════════════════
        // HELPER — feedback message
        // ══════════════════════════════════════════════════════
        private void ShowMessage(string text, bool success)
        {
            lblMessage.Text = "<i class='fas fa-" + (success ? "check" : "exclamation") + "-circle me-2'></i>" + text;
            lblMessage.CssClass = "alert-msg " + (success ? "alert-success-custom" : "alert-danger-custom");
        }

        // ══════════════════════════════════════════════════════
        // HELPERS used in .aspx bindings
        // ══════════════════════════════════════════════════════
        public string GetAudienceBadge(string role)
        {
            switch (role)
            {
                case "all": return "badge-all";
                case "student": return "badge-student";
                case "lecturer": return "badge-lecturer";
                default: return "badge-prog";
            }
        }

        public string GetAudienceLabel(string role)
        {
            switch (role)
            {
                case "all": return "All";
                case "student": return "Students";
                case "lecturer": return "Lecturers";
                default: return "Programme";
            }
        }

        // ══════════════════════════════════════════════════════
        // LOAD STATS CARDS
        // ══════════════════════════════════════════════════════
        private void LoadStats()
        {
            lblTotalSent.Text = SafeCount(
                "SELECT COUNT(DISTINCT groupKey) FROM NOTIFICATION WHERE notifType = 'announcement'");

            lblSentToday.Text = SafeCount(
                "SELECT COUNT(DISTINCT groupKey) FROM NOTIFICATION " +
                "WHERE notifType = 'announcement' AND CAST(createdAt AS DATE) = CAST(GETDATE() AS DATE)");

            lblTotalStudents.Text = SafeCount("SELECT COUNT(*) FROM STUDENT");
            lblTotalLecturers.Text = SafeCount("SELECT COUNT(*) FROM LECTURER");
        }

        private string SafeCount(string sql)
        {
            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return (result == null || result == DBNull.Value) ? "0" : result.ToString();
                }
            }
            catch { return "0"; }
        }

        // ══════════════════════════════════════════════════════
        // LOAD PROGRAMMES DROPDOWN
        // ══════════════════════════════════════════════════════
        private void LoadProgrammes()
        {
            DataTable dt = DbHelper.ExecuteQuery(
                "SELECT programmeID, programmeName FROM PROGRAMME WHERE status = 'Active' ORDER BY programmeName");
            ddlProgramme.DataSource = dt;
            ddlProgramme.DataTextField = "programmeName";
            ddlProgramme.DataValueField = "programmeID";
            ddlProgramme.DataBind();
            ddlProgramme.Items.Insert(0, new ListItem("-- Select Programme --", ""));
        }

        // ══════════════════════════════════════════════════════
        // AUDIENCE DROPDOWN CHANGED — show/hide programme panel
        // and update recipient count
        // ══════════════════════════════════════════════════════
        protected void ddlAudience_Changed(object sender, EventArgs e)
        {
            pnlProgramme.Visible = (ddlAudience.SelectedValue == "programme");
            UpdateRecipientCount();
        }

        private void UpdateRecipientCount()
        {
            string audience = ddlAudience.SelectedValue;
            int count = 0;

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                {
                    conn.Open();
                    string sql = "";

                    switch (audience)
                    {
                        case "all":
                            sql = "SELECT (SELECT COUNT(*) FROM STUDENT) + (SELECT COUNT(*) FROM LECTURER)";
                            break;
                        case "student":
                            sql = "SELECT COUNT(*) FROM STUDENT";
                            break;
                        case "lecturer":
                            sql = "SELECT COUNT(*) FROM LECTURER";
                            break;
                        case "programme":
                            string progId = ddlProgramme.SelectedValue;
                            if (string.IsNullOrEmpty(progId)) { lblRecipientCount.Text = "—"; return; }
                            sql = $"SELECT COUNT(*) FROM STUDENT WHERE programmeID = {progId}";
                            break;
                        default:
                            lblRecipientCount.Text = "—";
                            return;
                    }

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        object result = cmd.ExecuteScalar();
                        count = (result == null || result == DBNull.Value) ? 0 : Convert.ToInt32(result);
                    }
                }
            }
            catch { count = 0; }

            lblRecipientCount.Text = count + " recipient" + (count == 1 ? "" : "s");
        }

        // ══════════════════════════════════════════════════════
        // BROADCAST ANNOUNCEMENT
        // Inserts one NOTIFICATION row per recipient.
        // Uses a groupKey (GUID) so history can group them.
        // ══════════════════════════════════════════════════════
        protected void btnBroadcast_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string title = txtTitle.Text.Trim();
            string message = txtMessage.Text.Trim();
            string audience = ddlAudience.SelectedValue;

            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(message))
            {
                ShowMessage("Please fill in both title and message.", false);
                return;
            }

            // Build recipient list
            DataTable recipients = new DataTable();
            recipients.Columns.Add("recipientID", typeof(int));
            recipients.Columns.Add("recipientRole", typeof(string));

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                {
                    conn.Open();

                    // Students
                    if (audience == "all" || audience == "student")
                    {
                        string sql = "SELECT studentID FROM STUDENT";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                                recipients.Rows.Add(Convert.ToInt32(r["studentID"]), "student");
                        }
                    }

                    // Lecturers
                    if (audience == "all" || audience == "lecturer")
                    {
                        string sql = "SELECT lecturerID FROM LECTURER";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                                recipients.Rows.Add(Convert.ToInt32(r["lecturerID"]), "lecturer");
                        }
                    }

                    // Specific programme — students only
                    if (audience == "programme")
                    {
                        string progId = ddlProgramme.SelectedValue;
                        if (string.IsNullOrEmpty(progId))
                        {
                            ShowMessage("Please select a programme.", false);
                            return;
                        }

                        string sql = $"SELECT studentID FROM STUDENT WHERE programmeID = {progId}";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                                recipients.Rows.Add(Convert.ToInt32(r["studentID"]), "student");
                        }
                    }
                }

                if (recipients.Rows.Count == 0)
                {
                    ShowMessage("No recipients found for the selected audience.", false);
                    return;
                }

                // Insert one NOTIFICATION row per recipient
                // groupKey links all rows from one broadcast together for history view
                string groupKey = Guid.NewGuid().ToString();

                using (SqlConnection conn = DbHelper.GetConnection())
                {
                    conn.Open();
                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            // Check if groupKey column exists; add if not
                            EnsureGroupKeyColumn(conn, tx);

                            string insertSql = @"
                                INSERT INTO NOTIFICATION
                                    (recipientID, recipientRole, title, message, isRead, createdAt, notifType, groupKey)
                                VALUES
                                    (@rid, @role, @title, @msg, 0, GETDATE(), 'announcement', @gk)";

                            foreach (DataRow row in recipients.Rows)
                            {
                                using (SqlCommand cmd = new SqlCommand(insertSql, conn, tx))
                                {
                                    cmd.Parameters.AddWithValue("@rid", row["recipientID"]);
                                    cmd.Parameters.AddWithValue("@role", row["recipientRole"]);
                                    cmd.Parameters.AddWithValue("@title", title);
                                    cmd.Parameters.AddWithValue("@msg", message);
                                    cmd.Parameters.AddWithValue("@gk", groupKey);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            tx.Commit();
                            ShowMessage($"Announcement broadcast to {recipients.Rows.Count} recipient(s) successfully.", true);

                            // Reset form
                            txtTitle.Text = "";
                            txtMessage.Text = "";
                        }
                        catch (Exception ex)
                        {
                            tx.Rollback();
                            ShowMessage("Error: " + ex.Message, false);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }

            LoadStats();
            LoadHistory(ddlFilterAudience.SelectedValue);
            UpdateRecipientCount();
        }

        // ══════════════════════════════════════════════════════
        // ENSURE groupKey COLUMN EXISTS IN NOTIFICATION
        // groupKey was added to support announcement history.
        // ══════════════════════════════════════════════════════
        private void EnsureGroupKeyColumn(SqlConnection conn, SqlTransaction tx)
        {
            string sql = @"
                IF NOT EXISTS (
                    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
                    WHERE  TABLE_NAME  = 'NOTIFICATION'
                    AND    COLUMN_NAME = 'groupKey'
                )
                ALTER TABLE NOTIFICATION ADD groupKey VARCHAR(50) NULL;";

            using (SqlCommand cmd = new SqlCommand(sql, conn, tx))
            {
                cmd.ExecuteNonQuery();
            }
        }

        // ══════════════════════════════════════════════════════
        // LOAD ANNOUNCEMENT HISTORY
        // Groups by groupKey so each broadcast shows as one row.
        // ══════════════════════════════════════════════════════
        private void LoadHistory(string audienceFilter = "")
        {
            string where = string.IsNullOrEmpty(audienceFilter)
                ? ""
                : $" AND recipientRole = '{audienceFilter.Replace("'", "''")}'";

            // Ensure groupKey column exists before querying it
            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='NOTIFICATION' AND COLUMN_NAME='groupKey') " +
                    "ALTER TABLE NOTIFICATION ADD groupKey VARCHAR(50) NULL;", conn))
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }

            string sql = $@"
                SELECT   MIN(notificationID) AS notificationID,
                         MAX(title)          AS title,
                         MAX(message)        AS message,
                         MAX(recipientRole)  AS recipientRole,
                         MAX(createdAt)      AS createdAt,
                         COUNT(*)            AS recipientCount,
                         ISNULL(groupKey, CAST(MIN(notificationID) AS VARCHAR)) AS groupKey
                FROM     NOTIFICATION
                WHERE    notifType = 'announcement'
                {where}
                GROUP BY ISNULL(groupKey, CAST(notificationID AS VARCHAR))
                ORDER BY MAX(createdAt) DESC";

            try
            {
                DataTable dt = DbHelper.ExecuteQuery(sql);
                gvHistory.DataSource = dt;
                gvHistory.DataBind();
            }
            catch
            {
                gvHistory.DataSource = new DataTable();
                gvHistory.DataBind();
            }
        }

        protected void ddlFilterAudience_Changed(object sender, EventArgs e)
        {
            LoadHistory(ddlFilterAudience.SelectedValue);
        }

        // ══════════════════════════════════════════════════════
        // DELETE ANNOUNCEMENT (by groupKey — removes all rows)
        // ══════════════════════════════════════════════════════
        protected void gvHistory_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteAnn")
            {
                string groupKey = e.CommandArgument.ToString();

                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "DELETE FROM NOTIFICATION WHERE notifType = 'announcement' AND ISNULL(groupKey, CAST(notificationID AS VARCHAR)) = @gk",
                    conn))
                {
                    cmd.Parameters.AddWithValue("@gk", groupKey);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Announcement removed from history.", true);
                LoadStats();
                LoadHistory(ddlFilterAudience.SelectedValue);
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
    }
}
