using System;
using System.Data;
using System.Data.SqlClient;

namespace StudentManagementSystem
{
    public partial class LecturerStudentProgress : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Security Check
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Lecturer")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblUserName.Text = Session["UserName"].ToString();
                lblTopUserName.Text = Session["UserName"].ToString();

                int lecturerID = Convert.ToInt32(Session["UserID"]);
                LoadCourseTabs(lecturerID);

                // Check if a course was clicked (e.g., ?courseID=1)
                if (Request.QueryString["courseID"] != null)
                {
                    int selectedCourseID;
                    if (int.TryParse(Request.QueryString["courseID"], out selectedCourseID))
                    {
                        LoadStudentProgress(selectedCourseID);
                    }
                }
            }
        }

        private void LoadCourseTabs(int lecturerID)
        {
            // Get courses assigned to this lecturer for the buttons
            string sql = "SELECT courseID, courseCode, courseName FROM COURSE WHERE lecturerID = @id";
            DataTable dtCourses = DbHelper.ExecuteQuery(sql, new SqlParameter("@id", lecturerID));

            rptCourseTabs.DataSource = dtCourses;
            rptCourseTabs.DataBind();
        }

        private void LoadStudentProgress(int courseID)
        {
            // Set up the UI Panels
            pnlNoCourse.Visible = false;
            pnlProgress.Visible = true;

            // Get the course name for the header
            object courseNameObj = DbHelper.ExecuteScalar(
                "SELECT courseCode + ' — ' + courseName FROM COURSE WHERE courseID = @cID",
                new SqlParameter("@cID", courseID));

            lblSelectedCourse.Text = courseNameObj != null ? courseNameObj.ToString() : "Course Progress";

            // Complex Query to get Student Name, calculate Attendance %, and get GPA
            string sql = @"
                SELECT 
                        s.studentCode, 
                        s.name,
                        -- Subquery to calculate attendance percentage
                        ISNULL((
                            SELECT CAST(COUNT(CASE WHEN a.status='Present' THEN 1 END)*100.0/NULLIF(COUNT(*),0) AS DECIMAL(5,1))
                            FROM ATTENDANCE a
                            WHERE a.studentID = s.studentID AND a.courseID = @cID
                        ), 0) AS attendanceRate,
                        -- Subquery to get GPA
                        ISNULL((
                            SELECT TOP 1 r.GPA
                            FROM RESULT r
                            WHERE r.studentID = s.studentID AND r.courseID = @cID
                        ), 0.00) AS GPA,
                        -- Subquery to get Grade Badge Text
                        ISNULL((
                            SELECT TOP 1 r.grade
                            FROM RESULT r
                            WHERE r.studentID = s.studentID AND r.courseID = @cID
                        ), 'N/A') AS grade,
                        -- Subquery to get Grade Badge Color CSS
                        ISNULL((
                            SELECT TOP 1 
                                CASE 
                                    WHEN r.grade LIKE 'A%' THEN 'grade-a'
                                    WHEN r.grade LIKE 'B%' THEN 'grade-b'
                                    WHEN r.grade LIKE 'C%' THEN 'grade-c'
                                    WHEN r.grade = 'F' THEN 'grade-d'
                                    ELSE 'grade-na'
                                END
                            FROM RESULT r
                            WHERE r.studentID = s.studentID AND r.courseID = @cID
                        ), 'grade-na') AS gradeClass
                    FROM ENROLMENT e
                    INNER JOIN STUDENT s ON e.studentID = s.studentID
                    WHERE e.courseID = @cID AND e.status IN ('enrolled', 'confirmed')
                    ORDER BY s.studentCode ASC";

            DataTable dtProgress = DbHelper.ExecuteQuery(sql, new SqlParameter("@cID", courseID));

            gvProgress.DataSource = dtProgress;
            gvProgress.DataBind();
        }


        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}