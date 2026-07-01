using System;
using System.Data;
using System.Data.SqlClient;

namespace StudentManagementSystem
{
    public partial class LecturerDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Lecturer")
            {
                Response.Redirect("Login.aspx");
            }
            else
            {
                lblUserName.Text = Session["UserName"].ToString();
                lblTopUserName.Text = Session["UserName"].ToString();

                try
                {
                    object o = DbHelper.ExecuteScalar(
                        "SELECT lecturerTitle FROM LECTURER WHERE lecturerID = @id",
                        new SqlParameter("@id", Convert.ToInt32(Session["UserID"])));
                    string t = (o == null || o == DBNull.Value) ? "" : o.ToString();
                    if (!string.IsNullOrEmpty(t)) lblRoleIdentity.Text = t;
                }
                catch { }

                if (!IsPostBack)
                    LoadDashboard();
            }
        }

        private void LoadDashboard()
        {
            int lecturerID = Convert.ToInt32(Session["UserID"]);

            // Stat 1: Course count
            object courseCount = DbHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM COURSE WHERE lecturerID = @id",
                new SqlParameter("@id", lecturerID));
            lblCourseCount.Text = courseCount?.ToString() ?? "0";

            // Stat 2: Distinct enrolled students
            object studentCount = DbHelper.ExecuteScalar(
                @"SELECT COUNT(DISTINCT e.studentID)
                  FROM ENROLMENT e INNER JOIN COURSE c ON e.courseID = c.courseID
                  WHERE c.lecturerID = @id AND e.status IN ('enrolled','confirmed')",
                new SqlParameter("@id", lecturerID));
            lblStudentCount.Text = studentCount?.ToString() ?? "0";

            // Stat 3: Avg attendance (Fixed to use c.lecturerID)
            object avgAtt = DbHelper.ExecuteScalar(
                @"SELECT ISNULL(CAST(
                    COUNT(CASE WHEN a.status='Present' THEN 1 END)*100.0/NULLIF(COUNT(*),0)
                  AS INT),0) 
                  FROM ATTENDANCE a 
                  INNER JOIN COURSE c ON a.courseID = c.courseID 
                  WHERE c.lecturerID = @id",
                new SqlParameter("@id", lecturerID));
            lblAvgAttendance.Text = (avgAtt?.ToString() ?? "0") + "%";

            // Stat 4: At-risk count (Fixed to < 80 and c.lecturerID)
            object atRiskCount = DbHelper.ExecuteScalar(
                @"SELECT COUNT(*) FROM (
                    SELECT a.studentID, a.courseID 
                    FROM ATTENDANCE a 
                    INNER JOIN COURSE c ON a.courseID = c.courseID 
                    WHERE c.lecturerID = @id
                    GROUP BY a.studentID, a.courseID
                    HAVING CAST(COUNT(CASE WHEN a.status='Present' THEN 1 END)*100.0/NULLIF(COUNT(*),0) AS DECIMAL(5,1)) < 80
                  ) x",
                new SqlParameter("@id", lecturerID));
            lblAtRiskCount.Text = atRiskCount?.ToString() ?? "0";

            // My Courses
            DataTable dtCourses = DbHelper.ExecuteQuery(
                @"SELECT c.courseCode, c.courseName, c.creditHour,
                         COUNT(DISTINCT e.studentID) AS studentCount
                  FROM COURSE c
                  LEFT JOIN ENROLMENT e ON e.courseID=c.courseID AND e.status IN ('enrolled','confirmed')
                  WHERE c.lecturerID=@id
                  GROUP BY c.courseCode, c.courseName, c.creditHour",
                new SqlParameter("@id", lecturerID));
            rptCourses.DataSource = dtCourses;
            rptCourses.DataBind();

            // At-Risk Students List (Fixed to < 80 and c.lecturerID)
            DataTable dtAtRisk = DbHelper.ExecuteQuery(
                @"SELECT s.name, c.courseCode,
                         CAST(COUNT(CASE WHEN a.status='Present' THEN 1 END)*100.0/NULLIF(COUNT(*),0) AS DECIMAL(5,1)) AS attendanceRate
                  FROM ATTENDANCE a
                  INNER JOIN STUDENT s ON a.studentID = s.studentID
                  INNER JOIN COURSE  c ON a.courseID = c.courseID
                  WHERE c.lecturerID = @id
                  GROUP BY s.name, c.courseCode
                  HAVING CAST(COUNT(CASE WHEN a.status='Present' THEN 1 END)*100.0/NULLIF(COUNT(*),0) AS DECIMAL(5,1)) < 80
                  ORDER BY attendanceRate ASC",
                new SqlParameter("@id", lecturerID));
            rptAtRisk.DataSource = dtAtRisk;
            rptAtRisk.DataBind();
            lblNoAtRisk.Visible = (dtAtRisk.Rows.Count == 0);

            // Recent Grade Entries
            DataTable dtGrades = DbHelper.ExecuteQuery(
                @"SELECT TOP 5 s.name, c.courseCode, 'Final Result' AS assessmentName, r.grade, r.publishedDate
                  FROM RESULT r
                  INNER JOIN STUDENT s ON r.studentID=s.studentID
                  INNER JOIN COURSE  c ON r.courseID =c.courseID
                  WHERE r.lecturerID=@id AND r.publishedStatus='Published'
                  ORDER BY r.publishedDate DESC",
                new SqlParameter("@id", lecturerID));
            rptGrades.DataSource = dtGrades;
            rptGrades.DataBind();

            // Weekly attendance (auto-refreshes to the current week)
            LoadWeeklyAttendance();
        }

        private void LoadWeeklyAttendance()
        {
            // Default all bars to 0 so the page never crashes if a day has no classes
            hfMon.Value = "0";
            hfTue.Value = "0";
            hfWed.Value = "0";
            hfThu.Value = "0";
            hfFri.Value = "0";

            try
            {
                int lecturerID = Convert.ToInt32(Session["UserID"]);

                // Current week: Monday 00:00 up to (but not including) the following Saturday → covers Mon–Fri
                DateTime today = DateTime.Today;
                int diff = (7 + (today.DayOfWeek - DayOfWeek.Monday)) % 7;
                DateTime monday = today.AddDays(-diff).Date;
                DateTime saturday = monday.AddDays(5).Date;

                DataTable dtWeekly = DbHelper.ExecuteQuery(
                    @"SELECT DATENAME(WEEKDAY, a.attendanceDate) AS dayName,
                             CAST(ROUND(100.0 * SUM(CASE WHEN a.status='Present' THEN 1 ELSE 0 END)
                                  / NULLIF(COUNT(*),0), 0) AS INT) AS pct
                      FROM ATTENDANCE a
                      INNER JOIN COURSE c ON a.courseID = c.courseID
                      WHERE c.lecturerID = @id
                        AND a.attendanceDate >= @monday
                        AND a.attendanceDate <  @saturday
                      GROUP BY DATENAME(WEEKDAY, a.attendanceDate)",
                    new SqlParameter("@id", lecturerID),
                    new SqlParameter("@monday", monday),
                    new SqlParameter("@saturday", saturday));

                foreach (DataRow row in dtWeekly.Rows)
                {
                    string day = row["dayName"].ToString();
                    string pct = row["pct"].ToString();
                    switch (day)
                    {
                        case "Monday": hfMon.Value = pct; break;
                        case "Tuesday": hfTue.Value = pct; break;
                        case "Wednesday": hfWed.Value = pct; break;
                        case "Thursday": hfThu.Value = pct; break;
                        case "Friday": hfFri.Value = pct; break;
                    }
                }
            }
            catch
            {
                hfMon.Value = "0"; hfTue.Value = "0"; hfWed.Value = "0"; hfThu.Value = "0"; hfFri.Value = "0";
            }
        }

        protected void btnViewProgress_Click(object sender, EventArgs e)
        {
            Response.Redirect("LecturerStudentProgress.aspx");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}