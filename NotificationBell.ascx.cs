using System;
using System.Data;
using System.Web;

namespace StudentManagementSystem
{
    public partial class NotificationBell : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Render the bell on every postback so the badge/list stay current.
            // Not logged in -> show an empty bell, never crash the host page.
            if (Session["UserID"] == null || Session["UserRole"] == null)
            {
                lblBadge.Visible = false;
                lblHeadCount.Visible = false;
                pnlEmpty.Visible = true;
                simsNotifSeeAll.HRef = "Login.aspx";
                return;
            }

            int userID = Convert.ToInt32(Session["UserID"]);
            string role = Session["UserRole"].ToString();

            simsNotifSeeAll.HRef = SeeAllUrl(role);

            int unread = 0;
            DataTable dt = null;
            try
            {
                unread = NotificationHelper.GetUnreadCountForUser(userID, role);
                dt = NotificationHelper.GetRecentUnreadForUser(userID, role, 6);
            }
            catch
            {
                // NOTIFICATION table not present yet (patch not run) -> degrade gracefully.
            }

            // ---- Badge (hidden entirely when there is nothing unread) ----
            if (unread > 0)
            {
                lblBadge.Text = unread > 99 ? "99+" : unread.ToString();
                lblBadge.Visible = true;
                lblHeadCount.Text = unread + " new";
                lblHeadCount.Visible = true;
            }
            else
            {
                lblBadge.Visible = false;
                lblHeadCount.Visible = false;
            }

            // ---- Dropdown list ----
            if (dt != null && dt.Rows.Count > 0)
            {
                rptNotif.DataSource = dt;
                rptNotif.DataBind();
                pnlEmpty.Visible = false;
            }
            else
            {
                pnlEmpty.Visible = true;
            }
        }

        /// <summary>Where the "See all" footer points, per role.</summary>
        private string SeeAllUrl(string role)
        {
            switch ((role ?? "").Trim().ToLowerInvariant())
            {
                case "student": return "StudentNotifications.aspx";
                case "lecturer": return "LecturerAnnouncements.aspx";
                default: return "Announcements.aspx";
            }
        }

        // ---- Null-safe binding helpers used by the Repeater markup ----

        protected string Dot(object notifType)
        {
            return NotificationHelper.DotColor(notifType == null ? "" : notifType.ToString());
        }

        protected string Ago(object createdAt)
        {
            if (createdAt == null || createdAt == DBNull.Value) return "";
            return NotificationHelper.TimeAgo(Convert.ToDateTime(createdAt));
        }

        protected string Enc(object value)
        {
            return HttpUtility.HtmlEncode(value == null ? "" : value.ToString());
        }

        /// <summary>Short, HTML-safe one-line preview of the message body.</summary>
        protected string Snippet(object message)
        {
            string s = (message == null) ? "" : message.ToString().Trim();
            if (s.Length > 90) s = s.Substring(0, 90).TrimEnd() + "\u2026";
            return HttpUtility.HtmlEncode(s);
        }
    }
}
