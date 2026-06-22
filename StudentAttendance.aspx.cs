using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;

namespace StudentManagementSystem
{
    public partial class StudentAttendance : System.Web.UI.Page
    {
        string cs = ConfigurationManager.ConnectionStrings["SIMSConnection"].ConnectionString;

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
            {
                LoadAttendance();
            }
        }

        private void LoadAttendance()
        {
            int studentID = Convert.ToInt32(Session["UserID"]);

            string sql = @"
                SELECT 
                    c.courseID,
                    c.courseName AS CourseName,
                    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS PresentCount,
                    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS AbsentCount,
                    COUNT(*) AS TotalSessions
                FROM ATTENDANCE a
                INNER JOIN COURSE c ON a.courseID = c.courseID
                WHERE a.studentID = @studentID
                GROUP BY c.courseID, c.courseName
                ORDER BY c.courseName";

            DataTable rawDt = new DataTable();

            using (SqlConnection con = new SqlConnection(cs))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@studentID", studentID);

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(rawDt);
                }
            }

            DataTable finalDt = new DataTable();

            finalDt.Columns.Add("CourseName");
            finalDt.Columns.Add("PresentCount", typeof(int));
            finalDt.Columns.Add("AbsentCount", typeof(int));
            finalDt.Columns.Add("TotalSessions", typeof(int));
            finalDt.Columns.Add("AttendancePercent", typeof(int));

            string warningText = "";

            foreach (DataRow row in rawDt.Rows)
            {
                string courseName = row["CourseName"].ToString();

                int present = Convert.ToInt32(row["PresentCount"]);
                int absent = Convert.ToInt32(row["AbsentCount"]);
                int total = Convert.ToInt32(row["TotalSessions"]);

                int percent = 0;

                if (total > 0)
                {
                    percent = (int)Math.Round((present / (double)total) * 100);
                }

                finalDt.Rows.Add(
                    courseName,
                    present,
                    absent,
                    total,
                    percent
                );

                if (percent < 80)
                {
                    warningText +=
                        courseName +
                        " attendance is below 80% (" +
                        percent +
                        "%)<br/>";
                }
            }

            gvAttendance.DataSource = finalDt;
            gvAttendance.DataBind();

            if (!string.IsNullOrEmpty(warningText))
            {
                pnlWarning.Visible = true;
                litWarning.Text = warningText;
            }
            else
            {
                pnlWarning.Visible = false;
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            FormsAuthentication.SignOut();

            Response.Redirect("Login.aspx");
        }
    }
}