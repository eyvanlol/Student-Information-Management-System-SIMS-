using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class AtRiskStudents : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Lecturer")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblUserName.Text = Session["UserName"] != null ? Session["UserName"].ToString() : "Lecturer";
            }

            LoadAtRiskStudents(); // run every load so system always checks risk
        }

        private void LoadAtRiskStudents()
        {
            int lecturerID = Convert.ToInt32(Session["UserID"]);

            string sql = @"
                SELECT
                    s.studentID,
                    s.studentCode,
                    s.name,
                    c.courseID,
                    c.courseCode,
                    c.courseName,
                    CAST(
                        COUNT(CASE WHEN a.status = 'Present' THEN 1 END) * 100.0 /
                        NULLIF(COUNT(a.attendanceID), 0)
                    AS DECIMAL(5,1)) AS attendanceRate,
                    ISNULL(
                        STUFF((
                            SELECT ', ' + CONVERT(VARCHAR, a2.attendanceDate, 106)
                            FROM ATTENDANCE a2
                            WHERE a2.studentID = s.studentID
                              AND a2.courseID  = c.courseID
                              AND a2.status    = 'Absent'
                            FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
                        , 1, 2, '')
                    , 'None') AS absentDates
                FROM ENROLMENT e
                INNER JOIN STUDENT s ON e.studentID = s.studentID
                INNER JOIN COURSE c ON e.courseID = c.courseID
                INNER JOIN ATTENDANCE a ON a.studentID = s.studentID AND a.courseID = c.courseID
                WHERE c.lecturerID = @lecturerID
                  AND e.status IN ('enrolled','confirmed')
                GROUP BY s.studentID, s.studentCode, s.name, c.courseID, c.courseCode, c.courseName
                HAVING CAST(
                    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) * 100.0 /
                    NULLIF(COUNT(a.attendanceID), 0)
                AS DECIMAL(5,1)) < 80
                ORDER BY attendanceRate ASC";

            DataTable dt = new DataTable();

            using (SqlConnection conn = DbHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.Parameters.AddWithValue("@lecturerID", lecturerID);
                da.Fill(dt);
            }

            // Bind grid
            gvLowAttendance.DataSource = dt;
            gvLowAttendance.DataBind();

            // ===========================
            // AUTO NOTIFICATION ENGINE
            // ===========================
            foreach (DataRow row in dt.Rows)
            {
                int studentID = Convert.ToInt32(row["studentID"]);
                int courseID = Convert.ToInt32(row["courseID"]);
                string studentName = row["name"].ToString();
                string courseCode = row["courseCode"].ToString();

                // prevent duplicate spam (IMPORTANT)
                if (!HasAlreadySentWarning(studentID, courseID))
                {
                    NotificationHelper.Insert(
                        recipientID: studentID,
                        recipientRole: NotificationHelper.Role.Student,
                        notifType: NotificationHelper.Type.Attendance,
                        title: "Attendance Alert — " + courseCode,
                        message: "Your attendance for " + courseCode +
                                 " has dropped below 80%. Please improve attendance immediately.",
                        senderID: lecturerID
                    );

                    SaveWarningLog(studentID, courseID);
                }
            }
        }

        // ===========================
        // PREVENT DUPLICATE ALERTS
        // ===========================
        private bool HasAlreadySentWarning(int studentID, int courseID)
        {
            using (SqlConnection conn = DbHelper.GetConnection())
            {
                string sql = @"
                    SELECT COUNT(*)
                    FROM ATTENDANCE_WARNING_LOG
                    WHERE studentID = @studentID
                      AND courseID = @courseID";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@studentID", studentID);
                cmd.Parameters.AddWithValue("@courseID", courseID);

                conn.Open();
                int count = (int)cmd.ExecuteScalar();
                return count > 0;
            }
        }

        private void SaveWarningLog(int studentID, int courseID)
        {
            using (SqlConnection conn = DbHelper.GetConnection())
            {
                string sql = @"
                    INSERT INTO ATTENDANCE_WARNING_LOG(studentID, courseID, sentDate)
                    VALUES(@studentID, @courseID, GETDATE())";

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@studentID", studentID);
                cmd.Parameters.AddWithValue("@courseID", courseID);

                conn.Open();
                cmd.ExecuteNonQuery();
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