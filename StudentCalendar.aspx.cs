using System;
using System.Data;
using System.Data.SqlClient;

namespace StudentManagementSystem
{
    public partial class StudentCalendar : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Student")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            string name = Session["UserName"]?.ToString() ?? "Student";
            lblUserName.Text = name;
            lblTopUserName.Text = name;

            if (!IsPostBack)
                LoadReminders();
        }

        private int StudentId => Convert.ToInt32(Session["UserID"]);

        private void LoadReminders()
        {
            DataTable dt = DbHelper.ExecuteQuery(
                @"SELECT reminderID, title, description, startTime, reminderSent
                  FROM   PERSONAL_REMINDER
                  WHERE  studentID = @sid
                  ORDER  BY startTime DESC",
                new SqlParameter("@sid", StudentId));

            gvReminders.DataSource = dt;
            gvReminders.DataBind();
        }

        private void ShowMessage(string text, bool success)
        {
            lblMsg.Text = "<div class='alert-msg " +
                (success ? "alert-success" : "alert-danger") + "'>" + text + "</div>";
            lblMsg.Visible = true;
        }

        protected void btnAddAlert_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string title = txtTitle.Text.Trim();
            string desc = txtDescription.Text.Trim();

            DateTime start;
            if (!DateTime.TryParse(txtStart.Text.Trim(), out start))
            {
                ShowMessage("Please enter a valid date and time.", false);
                return;
            }
            if (start <= DateTime.Now)
            {
                ShowMessage("The alert time must be in the future.", false);
                return;
            }

            // 1. Save the reminder
            DbHelper.ExecuteNonQuery(
                @"INSERT INTO PERSONAL_REMINDER (studentID, title, description, startTime, reminderSent, createdAt)
                  VALUES (@sid, @t, @d, @start, 0, GETDATE())",
                new SqlParameter("@sid", StudentId),
                new SqlParameter("@t", title),
                new SqlParameter("@d", string.IsNullOrEmpty(desc) ? (object)DBNull.Value : desc),
                new SqlParameter("@start", start));

            // 2. Email an immediate confirmation (reuses EmailHelper -> Web.config SMTP).
            //    Resilient: if email fails, the alert is still saved.
            string emailNote;
            try
            {
                DataTable s = DbHelper.ExecuteQuery(
                    "SELECT name, ISNULL(personalEmail,'') AS personalEmail FROM STUDENT WHERE studentID = @sid",
                    new SqlParameter("@sid", StudentId));

                string pmail = s.Rows.Count > 0 ? s.Rows[0]["personalEmail"].ToString() : "";
                string sname = s.Rows.Count > 0 ? s.Rows[0]["name"].ToString() : "Student";

                if (string.IsNullOrWhiteSpace(pmail))
                    emailNote = " (no personal email on file, so no confirmation email was sent)";
                else
                {
                    EmailHelper.SendReminderConfirmation(pmail, sname, title, desc, start);
                    emailNote = " A confirmation email has been sent to " + pmail + ".";
                }
            }
            catch (Exception ex)
            {
                emailNote = " (alert saved, but the confirmation email failed: " + ex.Message + ")";
            }

            ShowMessage("Alert saved." + emailNote, true);

            // reset the form
            txtTitle.Text = "";
            txtDescription.Text = "";
            txtStart.Text = "";

            LoadReminders();
        }

        protected void gvReminders_RowCommand(object sender, System.Web.UI.WebControls.GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteRow")
            {
                int reminderId = Convert.ToInt32(e.CommandArgument);
                // scope delete to THIS student so nobody can delete another's row
                DbHelper.ExecuteNonQuery(
                    "DELETE FROM PERSONAL_REMINDER WHERE reminderID = @id AND studentID = @sid",
                    new SqlParameter("@id", reminderId),
                    new SqlParameter("@sid", StudentId));
                ShowMessage("Alert deleted.", true);
                LoadReminders();
            }
        }

        // ── Helpers used by the grid bindings ──
        public string DateText(object start)
        {
            if (start == null || start == DBNull.Value) return "-";
            return Convert.ToDateTime(start).ToString("ddd, d MMM yyyy h:mm tt");
        }

        public string Trunc(object desc)
        {
            if (desc == null || desc == DBNull.Value) return "";
            string d = desc.ToString();
            return d.Length > 60 ? System.Web.HttpUtility.HtmlEncode(d.Substring(0, 60)) + "..."
                                 : System.Web.HttpUtility.HtmlEncode(d);
        }

        public string StatusText(object start, object sent)
        {
            bool isSent = sent != null && sent != DBNull.Value && Convert.ToBoolean(sent);
            DateTime when = (start == null || start == DBNull.Value) ? DateTime.MinValue : Convert.ToDateTime(start);
            if (isSent) return "Reminder sent";
            if (when < DateTime.Now) return "Past";
            return "Scheduled";
        }

        public string StatusBadge(object start, object sent)
        {
            bool isSent = sent != null && sent != DBNull.Value && Convert.ToBoolean(sent);
            DateTime when = (start == null || start == DBNull.Value) ? DateTime.MinValue : Convert.ToDateTime(start);
            if (isSent) return "badge-sent";
            if (when < DateTime.Now) return "badge-past";
            return "badge-wait";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
