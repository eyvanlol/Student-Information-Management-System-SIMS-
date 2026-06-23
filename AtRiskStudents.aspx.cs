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
                LoadAtRiskStudents();
            }
        }

        private void LoadAtRiskStudents()
        {
            int lecturerID = Convert.ToInt32(Session["UserID"]);

            // Calculate real attendance rate from ATTENDANCE table
            string sql = @"
                SELECT
                    s.studentID,
                    s.studentCode,
                    s.name,
                    c.courseCode,
                    c.courseName,
                    CAST(
                        COUNT(CASE WHEN a.status = 'Present' THEN 1 END) * 100.0
                        / NULLIF(COUNT(a.attendanceID), 0)
                    AS DECIMAL(5,1)) AS attendanceRate,
                    ISNULL(
                        STUFF((
                            SELECT ', ' + CONVERT(VARCHAR, a2.attendanceDate, 106)
                            FROM ATTENDANCE a2
                            WHERE a2.studentID = s.studentID
                              AND a2.courseID  = c.courseID
                              AND a2.status    = 'Absent'
                            ORDER BY a2.attendanceDate
                            FOR XML PATH(''), TYPE).value('.','NVARCHAR(MAX)')
                        , 1, 2, '')
                    , 'None recorded') AS absentDates
                FROM ENROLMENT e
                INNER JOIN STUDENT s  ON e.studentID  = s.studentID
                INNER JOIN COURSE  c  ON e.courseID   = c.courseID
                INNER JOIN ATTENDANCE a ON a.studentID = s.studentID
                                       AND a.courseID  = c.courseID
                WHERE c.lecturerID = @lecturerID
                  AND e.status IN ('enrolled', 'confirmed')
                GROUP BY s.studentID, s.studentCode, s.name, c.courseID, c.courseCode, c.courseName
                HAVING CAST(
                    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) * 100.0
                    / NULLIF(COUNT(a.attendanceID), 0)
                AS DECIMAL(5,1)) < 85
                ORDER BY attendanceRate ASC";

            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    cmd.Parameters.AddWithValue("@lecturerID", lecturerID);
                    da.Fill(dt);
                }
            }
            catch (SqlException ex)
            {
                lblSystemMessage.Text = "Error loading data: " + ex.Message;
                pnlMessage.Visible = true;
                pnlMessage.CssClass = "alert alert-danger fw-bold shadow-sm";
            }

            gvLowAttendance.DataSource = dt;
            gvLowAttendance.DataBind();
        }

        protected void gvLowAttendance_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "SendWarning")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                GridViewRow row = gvLowAttendance.Rows[index];

                // Get studentID safely from DataKeys
                int studentID = Convert.ToInt32(gvLowAttendance.DataKeys[index].Value);
                int lecturerID = Convert.ToInt32(Session["UserID"]);

                string studentName = row.Cells[1].Text;
                string courseCode = row.Cells[2].Text;

                // Send real notification to the student via NotificationHelper
                NotificationHelper.Insert(
                    recipientID: studentID,
                    recipientRole: NotificationHelper.Role.Student,
                    notifType: NotificationHelper.Type.Attendance,
                    title: "Attendance Warning — " + courseCode,
                    message: "Dear " + studentName + ", your attendance for " + courseCode +
                                   " has dropped below 85%. Please attend all remaining classes " +
                                   "and contact your lecturer if you have any concerns.",
                    senderID: lecturerID
                );

                lblSystemMessage.Text = "<i class='fas fa-check-circle me-2'></i>Warning notification sent to <strong>"
                                      + studentName + "</strong> for <strong>" + courseCode + "</strong>.";
                pnlMessage.Visible = true;
                pnlMessage.CssClass = "alert alert-success alert-dismissible fade show fw-bold shadow-sm";

                // Reload so the grid stays fresh
                LoadAtRiskStudents();
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