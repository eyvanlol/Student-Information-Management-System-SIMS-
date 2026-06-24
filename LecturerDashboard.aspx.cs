using System;
using System.Data;
using System.Data.SqlClient;
using DocumentFormat.OpenXml.Drawing;

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

            // Stat 3: Avg attendance
            object avgAtt = DbHelper.ExecuteScalar(
                @"SELECT ISNULL(CAST(
                    COUNT(CASE WHEN a.status='Present' THEN 1 END)*100.0/NULLIF(COUNT(*),0)
                  AS INT),0) FROM ATTENDANCE a WHERE a.lecturerID = @id",
                new SqlParameter("@id", lecturerID));
            lblAvgAttendance.Text = (avgAtt?.ToString() ?? "0") + "%";

            // Stat 4: At-risk count
            object atRiskCount = DbHelper.ExecuteScalar(
                @"SELECT COUNT(*) FROM (
                    SELECT a.studentID, a.courseID FROM ATTENDANCE a WHERE a.lecturerID = @id
                    GROUP BY a.studentID, a.courseID
                    HAVING COUNT(CASE WHEN a.status='Present' THEN 1 END)*100.0/NULLIF(COUNT(*),0) < 85
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

            // At-Risk Students
            DataTable dtAtRisk = DbHelper.ExecuteQuery(
                @"SELECT s.name, c.courseCode,
                         CAST(COUNT(CASE WHEN a.status='Present' THEN 1 END)*100.0/NULLIF(COUNT(*),0) AS DECIMAL(5,1)) AS attendanceRate
                  FROM ATTENDANCE a
                  INNER JOIN STUDENT s ON a.studentID=s.studentID
                  INNER JOIN COURSE  c ON a.courseID =c.courseID
                  WHERE a.lecturerID=@id
                  GROUP BY s.name, c.courseCode
                  HAVING CAST(COUNT(CASE WHEN a.status='Present' THEN 1 END)*100.0/NULLIF(COUNT(*),0) AS DECIMAL(5,1)) < 85
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

            // Weekly Attendance — % per day of week from last 30 days
            DataTable dtWeekly = DbHelper.ExecuteQuery(
                @"SELECT
                    DATEPART(WEEKDAY, attendanceDate) AS dayNum,
                    DATENAME(WEEKDAY, attendanceDate) AS dayName,
                    CAST(COUNT(CASE WHEN status='Present' THEN 1 END)*100.0/NULLIF(COUNT(*),0) AS INT) AS pct
                  FROM ATTENDANCE
                  WHERE lecturerID = @id
                    AND attendanceDate >= DATEADD(DAY,-30,GETDATE())
                  GROUP BY DATEPART(WEEKDAY,attendanceDate), DATENAME(WEEKDAY,attendanceDate)
                  ORDER BY dayNum",
                new SqlParameter("@id", lecturerID));

            // Map day name -> pct for the 5 bars
            int monPct = 0, tuePct = 0, wedPct = 0, thuPct = 0, friPct = 0;
            foreach (DataRow row in dtWeekly.Rows)
            {
                string day = row["dayName"].ToString().Substring(0, 3);
                int pct = Convert.ToInt32(row["pct"]);
                switch (day)
                {
                    case "Mon": monPct = pct; break;
                    case "Tue": tuePct = pct; break;
                    case "Wed": wedPct = pct; break;
                    case "Thu": thuPct = pct; break;
                    case "Fri": friPct = pct; break;
                }
            }

            hfMon.Value = monPct.ToString();
            hfTue.Value = tuePct.ToString();
            hfWed.Value = wedPct.ToString();
            hfThu.Value = thuPct.ToString();
            hfFri.Value = friPct.ToString();
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