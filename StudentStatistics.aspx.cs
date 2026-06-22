using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;

namespace StudentManagementSystem
{
    public partial class StudentStatistics : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            lblUserName.Text = Session["UserName"].ToString();
            lblTopUserName.Text = Session["UserName"].ToString();

            if (!IsPostBack)
            {
                LoadCharts();
            }
        }

        private void LoadCharts()
        {
            DataTable gpa = GetData(@"
                SELECT grade, COUNT(*) AS total
                FROM RESULT
                WHERE publishedStatus = 'Published'
                GROUP BY grade
                ORDER BY grade");

            DataTable attendance = GetData(@"
                SELECT 
                    c.courseCode,
                    CAST(ROUND(
                        SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0
                    ) AS INT) AS attendancePercent
                FROM ATTENDANCE a
                INNER JOIN COURSE c ON a.courseID = c.courseID
                GROUP BY c.courseCode
                ORDER BY c.courseCode");

            JavaScriptSerializer js = new JavaScriptSerializer();

            hiddenGpaLabels.Value = js.Serialize(GetColumn(gpa, "grade"));
            hiddenGpaData.Value = js.Serialize(GetColumn(gpa, "total"));

            hiddenAttendanceLabels.Value = js.Serialize(GetColumn(attendance, "courseCode"));
            hiddenAttendanceData.Value = js.Serialize(GetColumn(attendance, "attendancePercent"));
        }

        private string[] GetColumn(DataTable dt, string col)
        {
            string[] arr = new string[dt.Rows.Count];

            for (int i = 0; i < dt.Rows.Count; i++)
            {
                arr[i] = dt.Rows[i][col].ToString();
            }

            return arr;
        }

        private DataTable GetData(string sql)
        {
            DataTable dt = new DataTable();

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
            catch
            {
            }

            return dt;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}