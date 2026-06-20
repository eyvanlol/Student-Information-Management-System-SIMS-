using System;
using System.Data;

namespace StudentManagementSystem
{
    public partial class StudentNotifications : System.Web.UI.Page
    {
        private int StudentID
        {
            get { return Convert.ToInt32(Session["UserID"]); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Student")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            lblUserName.Text = Session["UserName"].ToString();
            lblTopUserName.Text = Session["UserName"].ToString();

            if (!IsPostBack)
                LoadNotifications();
        }

        private void LoadNotifications()
        {
            DataTable dt = NotificationHelper.GetForStudent(StudentID);

            rptNotifs.DataSource = dt;
            rptNotifs.DataBind();

            pnlEmpty.Visible = (dt.Rows.Count == 0);

            int unread = NotificationHelper.GetUnreadCount(StudentID);
            lblUnreadCount.Text = unread + " unread";
            lblBellBadge.Text = unread.ToString();
            lblBellBadge.Visible = unread > 0;
            btnMarkAll.Visible = unread > 0;
        }

        // Clicking a notification marks it read.
        protected void rptNotifs_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Read")
            {
                int id = Convert.ToInt32(e.CommandArgument);
                NotificationHelper.MarkAsRead(id);
                LoadNotifications();
            }
        }

        protected void btnMarkAll_Click(object sender, EventArgs e)
        {
            // Mark every unread row for this student as read.
            DbHelper.ExecuteNonQuery(
                "UPDATE NOTIFICATION SET isRead = 1 WHERE recipientID = @sid AND recipientRole IN ('student','all') AND isRead = 0;",
                new System.Data.SqlClient.SqlParameter("@sid", StudentID));
            LoadNotifications();
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
