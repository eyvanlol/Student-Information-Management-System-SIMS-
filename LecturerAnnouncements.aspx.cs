using System;
using System.Data;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class LecturerAnnouncements : System.Web.UI.Page
    {
        private int LecturerID
        {
            get { return Convert.ToInt32(Session["UserID"]); }
        }

        private string GetProfilePictureUrl(int lecturerID)
        {
            string uploadPath = Server.MapPath("~/Uploads/ProfilePictures/");
            string[] extensions = { ".jpg", ".jpeg", ".png", ".gif" };
            string imageUrl = "~/Uploads/ProfilePictures/default.png";

            foreach (string ext in extensions)
            {
                string filePath = System.IO.Path.Combine(uploadPath, "lecturer_" + lecturerID + ext);
                if (System.IO.File.Exists(filePath))
                {
                    imageUrl = "~/Uploads/ProfilePictures/lecturer_" + lecturerID + ext + "?v=" + DateTime.Now.Ticks;
                    break;
                }
            }
            return imageUrl;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Lecturer")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            lblUserName.Text = Session["UserName"].ToString();
            lblTopUserName.Text = Session["UserName"].ToString();

            if (!IsPostBack)
            {
                LoadCourses();
                LoadHistory();
            }

            imgSidebarAvatar.ImageUrl = GetProfilePictureUrl(LecturerID);
        }

        private void LoadCourses()
        {
            string sql = "SELECT courseID, courseName, courseCode FROM COURSE WHERE lecturerID = @lid ORDER BY courseName";
            DataTable dt = DbHelper.ExecuteQuery(sql, new System.Data.SqlClient.SqlParameter("@lid", LecturerID));

            ddlCourse.Items.Clear();
            ddlCourse.Items.Add(new ListItem("All my courses", "ALL"));
            foreach (DataRow row in dt.Rows)
            {
                ddlCourse.Items.Add(new ListItem(
                    row["courseCode"] + " - " + row["courseName"],
                    row["courseID"].ToString()));
            }
        }

        private void LoadHistory()
        {
            DataTable dt = NotificationHelper.GetAnnouncementsByLecturer(LecturerID);
            gvHistory.DataSource = dt;
            gvHistory.DataBind();
            lblHistoryCount.Text = dt.Rows.Count.ToString();
        }

        protected void btnPost_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string title = txtTitle.Text.Trim();
            string message = txtMessage.Text.Trim();
            string courseSel = ddlCourse.SelectedValue;

            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(message))
            {
                ShowMessage("Please fill in both title and message.", false);
                return;
            }

            try
            {
                int recipients;
                if (courseSel == "ALL")
                    recipients = NotificationHelper.PostAnnouncementToAllCourses(LecturerID, title, message);
                else
                    recipients = NotificationHelper.PostAnnouncementToCourse(LecturerID, Convert.ToInt32(courseSel), title, message);

                if (recipients == 0)
                    ShowMessage("Announcement saved, but no actively-enrolled students matched, so nobody was notified.", false);
                else
                    ShowMessage($"Announcement sent to {recipients} student" + (recipients == 1 ? "." : "s."), true);

                txtTitle.Text = "";
                txtMessage.Text = "";
                LoadHistory();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtTitle.Text = "";
            txtMessage.Text = "";
            ddlCourse.SelectedIndex = 0;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        // ---- markup helpers ----
        protected string FmtCourse(object courseName)
        {
            string s = (courseName == null || courseName == DBNull.Value) ? "" : courseName.ToString();
            return string.IsNullOrEmpty(s) ? "All my courses" : Server.HtmlEncode(s);
        }

        protected string Trim(object message)
        {
            string s = (message == null || message == DBNull.Value) ? "" : message.ToString();
            if (s.Length > 70) s = s.Substring(0, 70) + "...";
            return Server.HtmlEncode(s);
        }

        private void ShowMessage(string text, bool ok)
        {
            pnlMsg.Visible = true;
            divMsg.Attributes["class"] = ok ? "alert alert-success" : "alert alert-danger";
            litMsg.Text = $"<i class='fas {(ok ? "fa-check-circle" : "fa-exclamation-circle")} me-2'></i>{text}";
        }
    }
}