using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using ClosedXML.Excel;
using iTextSharp.text;
using iTextSharp.text.pdf;

namespace StudentManagementSystem
{
    public partial class Reports : System.Web.UI.Page
    {
        // MANUAL CONTROL DECLARATIONS (Fixes CS0103 errors)
        protected global::System.Web.UI.WebControls.DropDownList ddlReportType;
        protected global::System.Web.UI.WebControls.DropDownList ddlProgramme;
        protected global::System.Web.UI.WebControls.DropDownList ddlSemester;
        protected global::System.Web.UI.WebControls.DropDownList ddlCourse;
        protected global::System.Web.UI.WebControls.DropDownList ddlSortOrder;
        protected global::System.Web.UI.WebControls.TextBox txtStartDate;
        protected global::System.Web.UI.WebControls.TextBox txtEndDate;
        protected global::System.Web.UI.WebControls.GridView gvReportPreview;
        protected global::System.Web.UI.WebControls.Label lblMessage;
        protected global::System.Web.UI.WebControls.Label lblUserName;
        protected global::System.Web.UI.WebControls.Panel pnlMessage;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }
            if (!IsPostBack)
            {
                if (lblUserName != null && Session["UserName"] != null)
                    lblUserName.Text = Session["UserName"].ToString();

                // Load the dynamic dropdown data on first load
                LoadDropdowns();
            }
        }

        // --- DYNAMIC DROPDOWN LOADER ---
        private void LoadDropdowns()
        {
            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                {
                    conn.Open();

                    // 1. Load real Programmes (Using 'programmeName')
                    string progSql = "SELECT programmeID, programmeName FROM PROGRAMME";
                    using (SqlCommand cmd = new SqlCommand(progSql, conn))
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dtProg = new DataTable();
                        sda.Fill(dtProg);
                        if (ddlProgramme != null)
                        {
                            foreach (DataRow row in dtProg.Rows)
                            {
                                ddlProgramme.Items.Add(new System.Web.UI.WebControls.ListItem(row["programmeName"].ToString(), row["programmeID"].ToString()));
                            }
                        }
                    }

                    // 2. Load real Courses (Using 'courseName' and explicitly selecting 'courseCode' twice)
                    string courseSql = "SELECT courseCode, courseCode + ' - ' + courseName AS DisplayName FROM COURSE";
                    using (SqlCommand cmd = new SqlCommand(courseSql, conn))
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dtCourse = new DataTable();
                        sda.Fill(dtCourse);
                        if (ddlCourse != null)
                        {
                            foreach (DataRow row in dtCourse.Rows)
                            {
                                ddlCourse.Items.Add(new System.Web.UI.WebControls.ListItem(row["DisplayName"].ToString(), row["courseCode"].ToString()));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                if (lblMessage != null && pnlMessage != null)
                {
                    lblMessage.Text = "Failed to load filters: " + ex.Message;
                    pnlMessage.Visible = true;
                    pnlMessage.CssClass = "alert alert-danger fw-bold shadow-sm";
                }
            }
        }

        protected void btnGenerate_Click(object sender, EventArgs e)
        {
            // Reset message panel
            if (pnlMessage != null) pnlMessage.CssClass = "alert alert-success fw-bold shadow-sm";

            DataTable dt = GetReportData();
            if (gvReportPreview != null)
            {
                gvReportPreview.DataSource = dt;
                gvReportPreview.DataBind();
            }

            if (pnlMessage != null && lblMessage != null && !lblMessage.Text.StartsWith("SQL Error") && !lblMessage.Text.StartsWith("Failed"))
            {
                pnlMessage.Visible = true;
                lblMessage.Text = "Report preview generated successfully. You can now export this data.";
            }
        }

        // --- EXPORT TO CSV ---
        protected void btnExportCSV_Click(object sender, EventArgs e)
        {
            DataTable dt = GetReportData();
            LogExportAction("CSV Export");

            StringBuilder sb = new StringBuilder();
            string[] columnNames = new string[dt.Columns.Count];
            for (int i = 0; i < dt.Columns.Count; i++) columnNames[i] = dt.Columns[i].ColumnName;
            sb.AppendLine(string.Join(",", columnNames));

            foreach (DataRow row in dt.Rows)
            {
                string[] fields = new string[dt.Columns.Count];
                for (int i = 0; i < dt.Columns.Count; i++) fields[i] = row[i].ToString().Replace(",", " ");
                sb.AppendLine(string.Join(",", fields));
            }

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", $"attachment;filename={ddlReportType.SelectedValue}_Report.csv");
            Response.ContentType = "application/text";
            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        // --- EXPORT TO EXCEL ---
        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            DataTable dt = GetReportData();
            LogExportAction("Excel Export");

            using (XLWorkbook wb = new XLWorkbook())
            {
                wb.Worksheets.Add(dt, "SystemReport");
                Response.Clear();
                Response.Buffer = true;
                Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                Response.AddHeader("content-disposition", $"attachment;filename={ddlReportType.SelectedValue}_Report.xlsx");

                using (MemoryStream MyMemoryStream = new MemoryStream())
                {
                    wb.SaveAs(MyMemoryStream);
                    MyMemoryStream.WriteTo(Response.OutputStream);
                    Response.Flush();
                    Response.End();
                }
            }
        }

        // --- EXPORT TO PDF ---
        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
            DataTable dt = GetReportData();
            LogExportAction("PDF Export");

            using (MemoryStream stream = new MemoryStream())
            {
                Document pdfDoc = new Document(PageSize.A4.Rotate(), 10f, 10f, 10f, 0f);
                PdfWriter.GetInstance(pdfDoc, stream);
                pdfDoc.Open();

                pdfDoc.Add(new Paragraph($"{ddlReportType.SelectedValue} Report (Generated: {DateTime.Now.ToString("dd-MMM-yyyy")})\n\n"));

                PdfPTable pdfTable = new PdfPTable(dt.Columns.Count) { WidthPercentage = 100 };
                foreach (DataColumn column in dt.Columns)
                {
                    PdfPCell cell = new PdfPCell(new Phrase(column.ColumnName)) { BackgroundColor = new BaseColor(240, 240, 240) };
                    pdfTable.AddCell(cell);
                }
                foreach (DataRow row in dt.Rows)
                {
                    foreach (object item in row.ItemArray) pdfTable.AddCell(item.ToString());
                }

                pdfDoc.Add(pdfTable);
                pdfDoc.Close();

                Response.ContentType = "application/pdf";
                Response.AddHeader("content-disposition", $"attachment;filename={ddlReportType.SelectedValue}_Report.pdf");
                Response.Cache.SetCacheability(HttpCacheability.NoCache);
                Response.BinaryWrite(stream.ToArray());
                Response.End();
            }
        }

        // --- CORE SQL DATA GENERATOR ---
        private DataTable GetReportData()
        {
            string reportType = ddlReportType != null ? ddlReportType.SelectedValue : "";
            string courseFilter = ddlCourse != null ? ddlCourse.SelectedValue : "ALL";
            string sortOrder = ddlSortOrder != null ? ddlSortOrder.SelectedValue : "DEFAULT";

            string sql = "";

            if (reportType == "Enrolment")
            {
                // Fixed: using enrolDate
                sql = @"SELECT e.enrolmentID, s.studentCode, s.name, c.courseCode, e.enrolDate, e.status 
                        FROM ENROLMENT e INNER JOIN STUDENT s ON e.studentID = s.studentID INNER JOIN COURSE c ON e.courseID = c.courseID WHERE 1=1";
            }
            else if (reportType == "Performance")
            {
                sql = @"SELECT r.resultID, s.studentCode, s.name, c.courseCode, r.grade, r.GPA, r.publishedStatus 
                        FROM RESULT r INNER JOIN STUDENT s ON r.studentID = s.studentID INNER JOIN COURSE c ON r.courseID = c.courseID WHERE 1=1";
            }
            else if (reportType == "Attendance")
            {
                // Fixed: dynamically calculating attendance rate from the ATTENDANCE table
                sql = @"SELECT e.enrolmentID, s.studentCode, s.name, c.courseCode, 
                        ISNULL((SELECT CAST(COUNT(CASE WHEN status = 'Present' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) AS INT) 
                                FROM ATTENDANCE a WHERE a.studentID = e.studentID AND a.courseID = e.courseID), 0) AS [Attendance Rate],
                        CASE 
                            WHEN ISNULL((SELECT CAST(COUNT(CASE WHEN status = 'Present' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) AS INT) 
                                         FROM ATTENDANCE a WHERE a.studentID = e.studentID AND a.courseID = e.courseID), 0) >= 85 THEN 'Good' 
                            WHEN ISNULL((SELECT CAST(COUNT(CASE WHEN status = 'Present' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0) AS INT) 
                                         FROM ATTENDANCE a WHERE a.studentID = e.studentID AND a.courseID = e.courseID), 0) >= 70 THEN 'At Risk' 
                            ELSE 'Critical' 
                        END AS [Attendance Rating]
                        FROM ENROLMENT e INNER JOIN STUDENT s ON e.studentID = s.studentID INNER JOIN COURSE c ON e.courseID = c.courseID WHERE 1=1";
            }

            // --- APPLY COURSE FILTER ---
            if (courseFilter != "ALL")
            {
                sql += $" AND c.courseCode = '{courseFilter}'";
            }

            // --- APPLY SORTING ---
            if (sortOrder != "DEFAULT")
            {
                string sortColumn = "s.name";

                if (reportType == "Performance") sortColumn = "r.GPA";
                else if (reportType == "Attendance") sortColumn = "[Attendance Rate]"; // Sort by dynamic column

                sql += $" ORDER BY {sortColumn} {sortOrder}";
            }

            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                {
                    sda.Fill(dt);
                }
            }
            catch (Exception ex)
            {
                if (lblMessage != null && pnlMessage != null)
                {
                    lblMessage.Text = "SQL Error: " + ex.Message;
                    pnlMessage.Visible = true;
                    pnlMessage.CssClass = "alert alert-danger fw-bold shadow-sm";
                }
            }
            return dt;
        }
          
        // --- AUDIT TRAIL LOGGING --- 
        private void LogExportAction(string actionType)
        {
            string type = $"{(ddlReportType != null ? ddlReportType.SelectedValue : "Unknown")} ({actionType})";
            string dateRangeStr = (txtStartDate != null && txtEndDate != null && string.IsNullOrEmpty(txtStartDate.Text) && string.IsNullOrEmpty(txtEndDate.Text)) ? "No Date Range Set" : $"{txtStartDate.Text} to {txtEndDate.Text}";

            string advancedFilters = $"Prog: {(ddlProgramme != null ? ddlProgramme.SelectedValue : "")} | Course: {(ddlCourse != null ? ddlCourse.SelectedValue : "")}";

            string sql = "INSERT INTO REPORT (reportType, programmeFilter, semesterFilter, dateRange, generatedBy, generatedDate) VALUES (@type, @prog, @sem, @dates, @admin, GETDATE())";

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@type", type);
                    cmd.Parameters.AddWithValue("@prog", advancedFilters);
                    cmd.Parameters.AddWithValue("@sem", ddlSemester != null ? ddlSemester.SelectedValue : "");
                    cmd.Parameters.AddWithValue("@dates", dateRangeStr);
                    cmd.Parameters.AddWithValue("@admin", Session["UserName"] != null ? Session["UserName"].ToString() : "Unknown");
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException) { }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}