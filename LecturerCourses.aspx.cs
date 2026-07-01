using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class LecturerCourses : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Auth check
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Lecturer")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblUserName.Text = Session["UserName"].ToString();
                lblTopUserName.Text = Session["UserName"].ToString();
                LoadCourses();
            }
        }

        private void LoadCourses(string searchTerm = "")
        {
            int lecturerID = Convert.ToInt32(Session["UserID"]);

            string sql = @"
                SELECT 
                    c.courseID,
                    c.courseCode,
                    c.courseName,
                    c.creditHour,
                    c.semester,
                    c.maxCapacity,
                    c.status,
                    p.programmeName,
                    COUNT(e.enrolmentID) AS enrolledCount
                FROM COURSE c
                INNER JOIN PROGRAMME p ON c.programmeID = p.programmeID
                LEFT JOIN ENROLMENT e ON c.courseID = e.courseID AND e.status = 'enrolled'
                WHERE c.lecturerID = @LecturerID
                ";

            if (!string.IsNullOrEmpty(searchTerm))
            {
                sql += " AND (c.courseName LIKE @Search OR c.courseCode LIKE @Search) ";
            }

            sql += @"
                GROUP BY c.courseID, c.courseCode, c.courseName, c.creditHour, c.semester, c.maxCapacity, c.status, p.programmeName
                ORDER BY c.semester, c.courseCode";

            SqlParameter[] parameters;
            if (!string.IsNullOrEmpty(searchTerm))
            {
                parameters = new SqlParameter[]
                {
                    new SqlParameter("@LecturerID", lecturerID),
                    new SqlParameter("@Search", "%" + searchTerm + "%")
                };
            }
            else
            {
                parameters = new SqlParameter[]
                {
                    new SqlParameter("@LecturerID", lecturerID)
                };
            }

            DataTable dt = DbHelper.ExecuteQuery(sql, parameters);

            if (dt.Rows.Count > 0)
            {
                pnlCourseList.Visible = true;
                pnlEmptyCourses.Visible = false;
                rptCourses.DataSource = dt;
                rptCourses.DataBind();
            }
            else
            {
                pnlCourseList.Visible = false;
                pnlEmptyCourses.Visible = true;
                rptCourses.DataSource = null;
                rptCourses.DataBind();
            }
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            LoadCourses(txtSearch.Text.Trim());
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}