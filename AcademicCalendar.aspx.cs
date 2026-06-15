using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class AcademicCalendar : System.Web.UI.Page
    {
        // ══════════════════════════════════════════════════════
        // PAGE LOAD
        // ══════════════════════════════════════════════════════
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
                EnsureCalendarTable();
                LoadCalendarEvents();
                LoadUpcomingEvents();
            }
        }

        // ══════════════════════════════════════════════════════
        // ENSURE CALENDAR TABLE EXISTS
        // Creates ACADEMIC_CALENDAR if not yet in the DB.
        // ══════════════════════════════════════════════════════
        private void EnsureCalendarTable()
        {
            string sql = @"
                IF NOT EXISTS (
                    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
                    WHERE  TABLE_NAME = 'ACADEMIC_CALENDAR'
                )
                CREATE TABLE ACADEMIC_CALENDAR (
                    calendarID   INT IDENTITY(1,1) PRIMARY KEY,
                    eventName    NVARCHAR(150) NOT NULL,
                    eventType    VARCHAR(20)   NOT NULL,
                    startDate    DATE          NOT NULL,
                    endDate      DATE          NULL,
                    academicYear VARCHAR(10)   NULL,
                    affects      VARCHAR(20)   NOT NULL DEFAULT 'All',
                    createdBy    INT           NULL
                );";

            using (SqlConnection conn = DbHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ══════════════════════════════════════════════════════
        // HELPER — feedback message
        // ══════════════════════════════════════════════════════
        private void ShowMessage(string text, bool success)
        {
            lblMessage.Text = "<i class='fas fa-" + (success ? "check" : "exclamation") + "-circle me-2'></i>" + text;
            lblMessage.CssClass = "alert-msg " + (success ? "alert-success-custom" : "alert-danger-custom");
        }

        // ══════════════════════════════════════════════════════
        // HELPERS used in .aspx bindings
        // ══════════════════════════════════════════════════════
        public string GetTypeBadge(string type)
        {
            switch (type)
            {
                case "Semester": return "badge-semester";
                case "Enrolment": return "badge-enrolment";
                case "Exam": return "badge-exam";
                case "Holiday": return "badge-holiday";
                default: return "badge-other";
            }
        }

        public string FormatDateRange(object start, object end)
        {
            if (start == null || start == DBNull.Value) return "-";
            string s = Convert.ToDateTime(start).ToString("d MMM yyyy");
            if (end == null || end == DBNull.Value) return s;
            string e2 = Convert.ToDateTime(end).ToString("d MMM yyyy");
            return s == e2 ? s : s + " – " + e2;
        }

        // ══════════════════════════════════════════════════════
        // LOAD EVENTS (with optional type filter)
        // ══════════════════════════════════════════════════════
        private void LoadCalendarEvents(string typeFilter = "")
        {
            string where = string.IsNullOrEmpty(typeFilter)
                ? ""
                : $" WHERE eventType = '{typeFilter.Replace("'", "''")}'";

            string sql = $@"
                SELECT calendarID, eventName, eventType,
                       startDate, endDate, academicYear, affects
                FROM   ACADEMIC_CALENDAR
                {where}
                ORDER  BY startDate ASC";

            DataTable dt = DbHelper.ExecuteQuery(sql);
            gvCalendar.DataSource = dt;
            gvCalendar.DataBind();
        }

        private void LoadUpcomingEvents()
        {
            string sql = @"
                SELECT eventName, eventType, startDate, endDate, affects
                FROM   ACADEMIC_CALENDAR
                WHERE  startDate BETWEEN GETDATE() AND DATEADD(DAY, 60, GETDATE())
                ORDER  BY startDate ASC";

            DataTable dt = DbHelper.ExecuteQuery(sql);
            gvUpcoming.DataSource = dt;
            gvUpcoming.DataBind();
        }

        // ══════════════════════════════════════════════════════
        // FILTER BY TYPE
        // ══════════════════════════════════════════════════════
        protected void ddlFilterType_Changed(object sender, EventArgs e)
        {
            LoadCalendarEvents(ddlFilterType.SelectedValue);
        }

        // ══════════════════════════════════════════════════════
        // SAVE EVENT (Add or Update)
        // ══════════════════════════════════════════════════════
        protected void btnSaveEvent_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string eventName = txtEventName.Text.Trim();
            string eventType = ddlEventType.SelectedValue;
            string startDateStr = txtStartDate.Text.Trim();
            string endDateStr = txtEndDate.Text.Trim();
            string academicYear = txtAcademicYear.Text.Trim();
            string affects = ddlAffects.SelectedValue;
            int editId = Convert.ToInt32(hdnEditSessionID.Value);

            DateTime startDate;
            if (!DateTime.TryParse(startDateStr, out startDate))
            {
                ShowMessage("Invalid start date.", false);
                return;
            }

            DateTime? endDate = null;
            if (!string.IsNullOrEmpty(endDateStr))
            {
                DateTime parsedEnd;
                if (!DateTime.TryParse(endDateStr, out parsedEnd))
                {
                    ShowMessage("Invalid end date.", false);
                    return;
                }
                if (parsedEnd < startDate)
                {
                    ShowMessage("End date cannot be before start date.", false);
                    return;
                }
                endDate = parsedEnd;
            }

            int adminId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;

            using (SqlConnection conn = DbHelper.GetConnection())
            {
                conn.Open();

                if (editId == 0)
                {
                    // INSERT new event
                    string sql = @"
                        INSERT INTO ACADEMIC_CALENDAR
                            (eventName, eventType, startDate, endDate, academicYear, affects, createdBy)
                        VALUES
                            (@name, @type, @start, @end, @year, @affects, @by)";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@name", eventName);
                        cmd.Parameters.AddWithValue("@type", eventType);
                        cmd.Parameters.AddWithValue("@start", startDate);
                        cmd.Parameters.AddWithValue("@end", endDate.HasValue ? (object)endDate.Value : DBNull.Value);
                        cmd.Parameters.AddWithValue("@year", string.IsNullOrEmpty(academicYear) ? (object)DBNull.Value : academicYear);
                        cmd.Parameters.AddWithValue("@affects", affects);
                        cmd.Parameters.AddWithValue("@by", adminId);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMessage("Event added successfully.", true);
                }
                else
                {
                    // UPDATE existing event
                    string sql = @"
                        UPDATE ACADEMIC_CALENDAR
                        SET    eventName    = @name,
                               eventType   = @type,
                               startDate   = @start,
                               endDate     = @end,
                               academicYear = @year,
                               affects     = @affects
                        WHERE  calendarID  = @id";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@name", eventName);
                        cmd.Parameters.AddWithValue("@type", eventType);
                        cmd.Parameters.AddWithValue("@start", startDate);
                        cmd.Parameters.AddWithValue("@end", endDate.HasValue ? (object)endDate.Value : DBNull.Value);
                        cmd.Parameters.AddWithValue("@year", string.IsNullOrEmpty(academicYear) ? (object)DBNull.Value : academicYear);
                        cmd.Parameters.AddWithValue("@affects", affects);
                        cmd.Parameters.AddWithValue("@id", editId);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMessage("Event updated successfully.", true);
                }
            }

            // Reset form to Add mode
            ResetForm();
            LoadCalendarEvents(ddlFilterType.SelectedValue);
            LoadUpcomingEvents();
        }

        // ══════════════════════════════════════════════════════
        // GRID ROW COMMANDS — Edit and Delete
        // ══════════════════════════════════════════════════════
        protected void gvCalendar_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int calendarId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteRow")
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "DELETE FROM ACADEMIC_CALENDAR WHERE calendarID = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", calendarId);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowMessage("Event deleted.", true);
                LoadCalendarEvents(ddlFilterType.SelectedValue);
                LoadUpcomingEvents();
            }
            else if (e.CommandName == "EditRow")
            {
                // Load the row into the form for editing
                DataTable dt = DbHelper.ExecuteQuery(
                    $"SELECT * FROM ACADEMIC_CALENDAR WHERE calendarID = {calendarId}");

                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    hdnEditSessionID.Value = calendarId.ToString();
                    txtEventName.Text = row["eventName"].ToString();
                    ddlEventType.SelectedValue = row["eventType"].ToString();
                    txtStartDate.Text = Convert.ToDateTime(row["startDate"]).ToString("yyyy-MM-dd");
                    txtEndDate.Text = row["endDate"] == DBNull.Value
                        ? ""
                        : Convert.ToDateTime(row["endDate"]).ToString("yyyy-MM-dd");
                    txtAcademicYear.Text = row["academicYear"].ToString();
                    ddlAffects.SelectedValue = row["affects"].ToString();

                    // Switch button to Update mode
                    btnSaveEvent.Text = "Update Event";
                    btnCancelEdit.Visible = true;

                    ShowMessage("Editing event — make your changes and click Update Event.", true);
                }
            }
        }

        // ══════════════════════════════════════════════════════
        // CANCEL EDIT
        // ══════════════════════════════════════════════════════
        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        private void ResetForm()
        {
            hdnEditSessionID.Value = "0";
            txtEventName.Text = "";
            ddlEventType.SelectedIndex = 0;
            txtStartDate.Text = "";
            txtEndDate.Text = "";
            txtAcademicYear.Text = "";
            ddlAffects.SelectedIndex = 0;
            btnSaveEvent.Text = "Save Event";
            btnCancelEdit.Visible = false;
        }

        // ══════════════════════════════════════════════════════
        // LOGOUT
        // ══════════════════════════════════════════════════════
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}
