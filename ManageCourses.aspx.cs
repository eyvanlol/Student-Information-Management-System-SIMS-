using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class ManageCourses : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Admin role guard
            if (Session["UserRole"] == null || Session["UserRole"].ToString() != "Admin")
            {
                Response.Redirect("Login.aspx");
                return;
            }

            lblUserName.Text = Session["UserName"].ToString();
            lblTopUserName.Text = Session["UserName"].ToString();

            if (!IsPostBack)
            {
                LoadDropdowns();
                BindGrid();
            }
        }

        // =================================================================
        //  LOAD DROPDOWNS (Programme & Lecturer from ERD)
        // =================================================================
        private void LoadDropdowns()
        {
            // Load Programmes (from PROGRAMME table per ERD)
            string progSql = "SELECT programmeID, programmeName FROM PROGRAMME WHERE status = 'Active' ORDER BY programmeName";
            DataTable progDt = DbHelper.ExecuteQuery(progSql);

            ddlProgramme.Items.Clear();
            ddlProgramme.Items.Add(new ListItem("-- Select Programme --", ""));
            foreach (DataRow row in progDt.Rows)
            {
                ddlProgramme.Items.Add(new ListItem(row["programmeName"].ToString(), row["programmeID"].ToString()));
            }

            // Load Lecturers (from LECTURER table per ERD)
            string lectSql = "SELECT lecturerID, name FROM LECTURER ORDER BY name";
            DataTable lectDt = DbHelper.ExecuteQuery(lectSql);

            ddlLecturer.Items.Clear();
            ddlLecturer.Items.Add(new ListItem("-- Select Lecturer --", ""));
            foreach (DataRow row in lectDt.Rows)
            {
                ddlLecturer.Items.Add(new ListItem(row["name"].ToString(), row["lecturerID"].ToString()));
            }
        }

        // =================================================================
        //  READ  (with search + paging)
        // =================================================================
        private string CurrentSearch
        {
            get { return ViewState["search"] as string ?? ""; }
            set { ViewState["search"] = value; }
        }

        private void BindGrid()
        {
            string search = CurrentSearch;

            // Join with PROGRAMME and LECTURER to show names instead of IDs
            string sql = @"
                SELECT c.courseID, c.courseName, c.courseCode, c.creditHour, c.semester, 
                       c.maxCapacity, c.status, c.description,
                       p.programmeName, l.name as lecturerName
                FROM COURSE c
                LEFT JOIN PROGRAMME p ON c.programmeID = p.programmeID
                LEFT JOIN LECTURER l ON c.lecturerID = l.lecturerID";

            if (!string.IsNullOrEmpty(search))
                sql += " WHERE c.courseName LIKE @q OR c.courseCode LIKE @q";

            sql += " ORDER BY c.courseID";

            DataTable dt = new DataTable();
            using (SqlConnection conn = DbHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (!string.IsNullOrEmpty(search))
                    cmd.Parameters.AddWithValue("@q", "%" + search + "%");

                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }

            gvCourses.DataSource = dt;
            gvCourses.DataBind();

            // Fix page index if out of range after delete
            if (gvCourses.PageCount > 0 && gvCourses.PageIndex >= gvCourses.PageCount)
            {
                gvCourses.PageIndex = gvCourses.PageCount - 1;
                gvCourses.DataSource = dt;
                gvCourses.DataBind();
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            CurrentSearch = txtSearch.Text.Trim();
            gvCourses.PageIndex = 0;
            BindGrid();
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            CurrentSearch = "";
            txtSearch.Text = "";
            gvCourses.PageIndex = 0;
            BindGrid();
        }

        protected void gvCourses_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvCourses.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        // =================================================================
        //  CREATE / UPDATE
        // =================================================================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            bool isUpdate = !string.IsNullOrEmpty(hfCourseID.Value);

            // Using ERD columns: courseID, programmeID, lecturerID, courseName, courseCode, creditHour, description, semester, maxCapacity, status
            string sql = isUpdate
                ? @"UPDATE COURSE SET 
                    courseName=@name, courseCode=@code, programmeID=@progID, lecturerID=@lectID,
                    creditHour=@cr, description=@desc, semester=@sem, maxCapacity=@cap, status=@st
                    WHERE courseID=@id"
                : @"INSERT INTO COURSE 
                    (courseName, courseCode, programmeID, lecturerID, creditHour, description, semester, maxCapacity, status)
                    VALUES (@name, @code, @progID, @lectID, @cr, @desc, @sem, @cap, @st)";

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@name", txtCourseName.Text.Trim());
                    cmd.Parameters.AddWithValue("@code", txtCourseCode.Text.Trim().ToUpper());
                    cmd.Parameters.AddWithValue("@progID", Convert.ToInt32(ddlProgramme.SelectedValue));
                    cmd.Parameters.AddWithValue("@lectID", Convert.ToInt32(ddlLecturer.SelectedValue));
                    cmd.Parameters.AddWithValue("@cr", Convert.ToInt32(txtCreditHour.Text));
                    cmd.Parameters.AddWithValue("@desc", txtDescription.Text.Trim());
                    cmd.Parameters.AddWithValue("@sem", ddlSemester.SelectedValue);
                    cmd.Parameters.AddWithValue("@cap", Convert.ToInt32(txtMaxCapacity.Text));
                    cmd.Parameters.AddWithValue("@st", ddlStatus.SelectedValue);

                    if (isUpdate)
                        cmd.Parameters.AddWithValue("@id", Convert.ToInt32(hfCourseID.Value));

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                ShowMessage(isUpdate ? "Course updated successfully." : "Course added successfully.", true);
                ClearForm();
                BindGrid();
            }
            catch (SqlException ex)
            {
                string friendly = (ex.Number == 2627 || ex.Number == 2601)
                    ? "That course code already exists. Please use a unique code."
                    : "Database error: " + ex.Message;
                ShowMessage(friendly, false);
            }
        }

        // =================================================================
        //  GRID ACTIONS: Edit / Delete
        // =================================================================
        protected void gvCourses_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditRow")
                LoadIntoForm(id);
            else if (e.CommandName == "DeleteRow")
                DeleteCourse(id);
        }

        private void LoadIntoForm(int id)
        {
            // Fetch course data with ERD columns
            string sql = @"
                SELECT courseID, courseName, courseCode, programmeID, lecturerID, 
                       creditHour, description, semester, maxCapacity, status
                FROM COURSE WHERE courseID=@id";

            using (SqlConnection conn = DbHelper.GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        hfCourseID.Value = id.ToString();
                        txtCourseName.Text = r["courseName"].ToString();
                        txtCourseCode.Text = r["courseCode"].ToString();
                        txtCreditHour.Text = r["creditHour"].ToString();
                        txtDescription.Text = r["description"].ToString();
                        txtMaxCapacity.Text = r["maxCapacity"].ToString();

                        SetListValue(ddlProgramme, r["programmeID"].ToString());
                        SetListValue(ddlLecturer, r["lecturerID"].ToString());
                        SetListValue(ddlSemester, r["semester"].ToString());
                        SetListValue(ddlStatus, r["status"].ToString());
                    }
                }
            }

            lblFormTitle.Text = "Edit Course";
            btnSave.Text = "Update Course";
        }

        private void DeleteCourse(int id)
        {
            string sql = "DELETE FROM COURSE WHERE courseID=@id";

            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowMessage("Course deleted.", true);
                ClearForm();
                BindGrid();
            }
            catch (SqlException ex)
            {
                // 547 = FK constraint (enrolled students, attendance, results, etc.)
                string friendly = (ex.Number == 547)
                    ? "Cannot delete: students are enrolled or records exist for this course."
                    : "Database error: " + ex.Message;
                ShowMessage(friendly, false);
            }
        }

        // =================================================================
        //  HELPERS
        // =================================================================
        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void ClearForm()
        {
            hfCourseID.Value = "";
            txtCourseName.Text = "";
            txtCourseCode.Text = "";
            txtCreditHour.Text = "";
            txtMaxCapacity.Text = "";
            txtDescription.Text = "";
            ddlProgramme.SelectedIndex = 0;
            ddlLecturer.SelectedIndex = 0;
            ddlSemester.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            lblFormTitle.Text = "Add New Course";
            btnSave.Text = "Save Course";
        }

        private void SetListValue(DropDownList ddl, string value)
        {
            ListItem item = ddl.Items.FindByValue(value);
            if (item != null)
            {
                ddl.ClearSelection();
                item.Selected = true;
            }
        }

        private void ShowMessage(string text, bool ok)
        {
            pnlMsg.Visible = true;
            divMsg.Attributes["class"] = ok ? "alert alert-success" : "alert alert-danger";
            litMsg.Text = $"<i class='fas {(ok ? "fa-check-circle" : "fa-exclamation-circle")} me-2'></i>{text}";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }
    }
}