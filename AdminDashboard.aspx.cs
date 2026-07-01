using System;
using System.Data.SqlClient;

namespace StudentManagementSystem
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
            }
            else
            {
                lblUserName.Text = Session["UserName"].ToString();
                lblTopUserName.Text = Session["UserName"].ToString();
                LoadIdentity();

                if (!IsPostBack)
                {
                    LoadStats();
                    LoadRecentEnrolments();
                    LoadPerformanceStats();
                }
            }
        }

        private void LoadIdentity()
        {
            // Admin identity is fixed to "Admin" — no Head-of-Programme title.
            lblRoleIdentity.Text = "Admin";
            Session["RoleIdentity"] = "Admin";
        }

        private void LoadStats()
        {
            // PROGRAMME is built; STUDENT / LECTURER / COURSE belong to other
            // modules and may not exist yet, so SafeCount returns 0 if missing.
            lblProgCount.Text = SafeCount("SELECT COUNT(*) FROM PROGRAMME").ToString();
            lblStudents.Text = SafeCount("SELECT COUNT(*) FROM STUDENT").ToString();
            lblLecturers.Text = SafeCount("SELECT COUNT(*) FROM LECTURER").ToString();
            lblCourses.Text = SafeCount("SELECT COUNT(*) FROM COURSE WHERE status = 'Active'").ToString();
        }

        private int SafeCount(string sql)
        {
            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    return (result == null || result == DBNull.Value) ? 0 : Convert.ToInt32(result);
                }
            }
            catch (SqlException)
            {
                return 0; // table not created yet
            }
        }

        private void LoadRecentEnrolments()
        {
            try
            {
                string sql = @"
                    SELECT TOP 5
                        e.studentID,
                        s.name AS studentName,
                        p.programmeName,
                        e.enrolDate,
                        e.status
                    FROM ENROLMENT e
                    JOIN STUDENT s ON e.studentID = s.studentID
                    JOIN PROGRAMME p ON s.programmeID = p.programmeID
                    ORDER BY e.enrolDate DESC";

                System.Data.DataTable dt = DbHelper.ExecuteQuery(sql);
                gvRecentEnrolments.DataSource = dt;
                gvRecentEnrolments.DataBind();
            }
            catch
            {
                // Fails silently if tables are not fully set up yet
            }
        }

        private void LoadPerformanceStats()
        {
            try
            {
                // Attendance Rate from 'Present' status; Pass Rate from marks >= 50
                string sql = @"
                    SELECT 
                        c.courseCode + ' - ' + c.courseName AS CourseTitle,
                        ISNULL(att.AttRate, 0) AS AttendanceRate,
                        ISNULL(res.PassRate, 0) AS PassRate
                    FROM COURSE c
                    LEFT JOIN (
                        SELECT courseID, 
                               CAST(SUM(CASE WHEN status = 'Present' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(5,1)) AS AttRate
                        FROM ATTENDANCE
                        GROUP BY courseID
                    ) att ON c.courseID = att.courseID
                    LEFT JOIN (
                        SELECT courseID, 
                               CAST(SUM(CASE WHEN marks >= 50 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) AS DECIMAL(5,1)) AS PassRate
                        FROM RESULT
                        GROUP BY courseID
                    ) res ON c.courseID = res.courseID
                    WHERE c.status = 'Active'";

                System.Data.DataTable dt = DbHelper.ExecuteQuery(sql);
                gvPerformance.DataSource = dt;
                gvPerformance.DataBind();
            }
            catch
            {
                // Fails silently if ATTENDANCE or RESULT tables are not fully set up yet
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}