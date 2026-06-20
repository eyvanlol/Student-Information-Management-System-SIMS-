using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace StudentManagementSystem
{
    public partial class ManageUsers : System.Web.UI.Page
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
            ddlRole.Attributes["onchange"] = "toggleRole();";

            if (!IsPostBack)
            {
                LoadProgrammes();
                LoadUsers("", "");
            }
        }

        // ──────────────────────────────────────────────
        // fn 7 — USER LIST (search by name/ID/code, filter by role)
        // ──────────────────────────────────────────────
        private void LoadUsers(string search, string roleFilter)
        {
            string sql = @"
                SELECT * FROM (
                    SELECT ISNULL(studentCode,'-') AS code, studentID AS id, name, email, 'Student' AS role, 'Active' AS status FROM STUDENT
                    UNION ALL
                    SELECT ISNULL(lecturerCode,'-') AS code, lecturerID AS id, name, email, 'Lecturer' AS role, 'Active' AS status FROM LECTURER
                ) u
                WHERE (@role = '' OR u.role = @role)
                  AND (@q = '' OR u.name LIKE @q OR CAST(u.id AS VARCHAR(20)) LIKE @q OR u.code LIKE @q)
                ORDER BY u.role, u.name;";

            string q = string.IsNullOrEmpty(search) ? "" : "%" + search.Trim() + "%";

            DataTable dt = DbHelper.ExecuteQuery(sql,
                P("@role", roleFilter ?? ""),
                P("@q", q));

            gvUsers.DataSource = dt;
            gvUsers.DataBind();
            lblUserCount.Text = dt.Rows.Count.ToString();
        }

        private void LoadProgrammes()
        {
            string sql = "SELECT programmeID, programmeName FROM PROGRAMME WHERE status = 'Active' ORDER BY programmeName";
            DataTable dt = DbHelper.ExecuteQuery(sql);
            ddlProgramme.Items.Clear();
            ddlProgramme.Items.Add(new ListItem("-- Select Programme --", ""));
            foreach (DataRow row in dt.Rows)
                ddlProgramme.Items.Add(new ListItem(row["programmeName"].ToString(), row["programmeID"].ToString()));
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadUsers(txtSearch.Text, ddlFilterRole.SelectedValue);
        }

        // ──────────────────────────────────────────────
        // fn 6 — CREATE USER (role-adaptive, auto-gen ID/email/password)
        // ──────────────────────────────────────────────
        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string role = ddlRole.SelectedValue;
            string name = txtName.Text.Trim();
            string personalEmail = txtPersonalEmail.Text.Trim().ToLower();

            try
            {
                if (role == "Student")
                {
                    if (string.IsNullOrEmpty(ddlProgramme.SelectedValue))
                    {
                        ShowMessage("Please select a programme for the student.", false);
                        return;
                    }
                    CreateStudent(name, personalEmail);
                }
                else
                {
                    CreateLecturer(name, personalEmail);
                }
                ClearForm();
                LoadUsers("", "");
            }
            catch (SqlException ex)
            {
                string friendly = (ex.Number == 2627 || ex.Number == 2601)
                    ? "A generated email/code collided with an existing one. Please try again."
                    : "Database error: " + ex.Message;
                ShowMessage(friendly, false);
            }
        }

        private void CreateStudent(string name, string personalEmail)
        {
            string tempPwd = GenTempPassword();
            string hashed = Login.HashPassword(tempPwd);
            string tmpEmail = "pending_" + Guid.NewGuid().ToString("N") + "@temp.local";

            int newId;
            string email, code;

            using (SqlConnection conn = DbHelper.GetConnection())
            {
                conn.Open();
                using (SqlTransaction tx = conn.BeginTransaction())
                {
                    string insert = @"
                        INSERT INTO STUDENT
                            (name, email, password, programmeID, personalEmail, phone, icNumber,
                             intakeSemester, emergencyContactName, emergencyContactPhone, emergencyContactRel)
                        VALUES
                            (@name, @tmp, @pwd, @prog, @pe, @ph, @ic, @intake, @en, @ep, @er);
                        SELECT CAST(SCOPE_IDENTITY() AS INT);";

                    using (SqlCommand cmd = new SqlCommand(insert, conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@name", name);
                        cmd.Parameters.AddWithValue("@tmp", tmpEmail);
                        cmd.Parameters.AddWithValue("@pwd", hashed);
                        cmd.Parameters.AddWithValue("@prog", Convert.ToInt32(ddlProgramme.SelectedValue));
                        cmd.Parameters.AddWithValue("@pe", personalEmail);
                        cmd.Parameters.AddWithValue("@ph", NullIfBlank(txtPhone.Text));
                        cmd.Parameters.AddWithValue("@ic", NullIfBlank(txtIc.Text));
                        cmd.Parameters.AddWithValue("@intake", NullIfBlank(txtIntake.Text));
                        cmd.Parameters.AddWithValue("@en", NullIfBlank(txtEmgName.Text));
                        cmd.Parameters.AddWithValue("@ep", NullIfBlank(txtEmgPhone.Text));
                        cmd.Parameters.AddWithValue("@er", NullIfBlank(txtEmgRel.Text));
                        newId = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    email = "s" + newId + "@student.sims.edu";
                    code = "STU" + DateTime.Now.ToString("yyMM") + newId.ToString("D3");

                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE STUDENT SET email=@email, studentCode=@code WHERE studentID=@id", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@email", email);
                        cmd.Parameters.AddWithValue("@code", code);
                        cmd.Parameters.AddWithValue("@id", newId);
                        cmd.ExecuteNonQuery();
                    }
                    tx.Commit();
                }
            }

            NotificationHelper.Insert(newId, NotificationHelper.Role.Student, NotificationHelper.Type.Welcome,
                "Welcome to SIMS",
                "Your student account has been created. Log in with " + email + " and change your password on first login.");

            TrySendWelcomeEmail(personalEmail, email, code, GenTempPasswordEcho());
            ShowCredential("Student", code, email, GenTempPasswordEcho());
        }

        private void CreateLecturer(string name, string personalEmail)
        {
            string tempPwd = GenTempPassword();
            string hashed = Login.HashPassword(tempPwd);
            string tmpEmail = "pending_" + Guid.NewGuid().ToString("N") + "@temp.local";

            int newId;
            string email, code;

            using (SqlConnection conn = DbHelper.GetConnection())
            {
                conn.Open();
                using (SqlTransaction tx = conn.BeginTransaction())
                {
                    string insert = @"
                        INSERT INTO LECTURER
                            (name, email, password, personalEmail, phone, icNumber, department, staffType)
                        VALUES
                            (@name, @tmp, @pwd, @pe, @ph, @ic, @dept, @stype);
                        SELECT CAST(SCOPE_IDENTITY() AS INT);";

                    using (SqlCommand cmd = new SqlCommand(insert, conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@name", name);
                        cmd.Parameters.AddWithValue("@tmp", tmpEmail);
                        cmd.Parameters.AddWithValue("@pwd", hashed);
                        cmd.Parameters.AddWithValue("@pe", personalEmail);
                        cmd.Parameters.AddWithValue("@ph", NullIfBlank(txtPhone.Text));
                        cmd.Parameters.AddWithValue("@ic", NullIfBlank(txtIc.Text));
                        cmd.Parameters.AddWithValue("@dept", ddlDept.SelectedValue);
                        cmd.Parameters.AddWithValue("@stype", ddlStaffType.SelectedValue);
                        newId = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    email = "l" + newId + "@staff.sims.edu";
                    code = "LEC" + DateTime.Now.ToString("yyMM") + newId.ToString("D3");

                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE LECTURER SET email=@email, lecturerCode=@code WHERE lecturerID=@id", conn, tx))
                    {
                        cmd.Parameters.AddWithValue("@email", email);
                        cmd.Parameters.AddWithValue("@code", code);
                        cmd.Parameters.AddWithValue("@id", newId);
                        cmd.ExecuteNonQuery();
                    }
                    tx.Commit();
                }
            }

            NotificationHelper.Insert(newId, NotificationHelper.Role.Lecturer, NotificationHelper.Type.Welcome,
                "Welcome to SIMS",
                "Your lecturer account has been created. Log in with " + email + " and change your password on first login.");

            ShowCredential("Lecturer", code, email, GenTempPasswordEcho());
        }

        // ──────────────────────────────────────────────
        // fn 8 — ASSIGN / CHANGE ROLE  +  DELETE
        // Role = which table the account lives in, so changing it moves the
        // account across tables. Blocked if the user has dependent records.
        // ──────────────────────────────────────────────
        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "ChangeRole" && e.CommandName != "DeleteUser") return;

            string[] parts = e.CommandArgument.ToString().Split('|');
            string role = parts[0];
            int id = Convert.ToInt32(parts[1]);

            if (e.CommandName == "ChangeRole") ChangeUserRole(role, id);
            else DeleteUser(role, id);
        }

        private void ChangeUserRole(string fromRole, int id)
        {
            try
            {
                if (fromRole == "Student")
                {
                    if (HasDependents("ENROLMENT", "studentID", id) ||
                        HasDependents("ATTENDANCE", "studentID", id) ||
                        HasDependents("RESULT", "studentID", id))
                    {
                        ShowMessage("Cannot change role: this student has enrolment, attendance or result records.", false);
                        return;
                    }
                    MoveAccount("STUDENT", "studentID", id, "Lecturer");
                }
                else
                {
                    if (HasDependents("COURSE", "lecturerID", id) ||
                        HasDependents("ATTENDANCE", "lecturerID", id) ||
                        HasDependents("RESULT", "lecturerID", id))
                    {
                        ShowMessage("Cannot change role: this lecturer is assigned to courses or has attendance/result records.", false);
                        return;
                    }
                    MoveAccount("LECTURER", "lecturerID", id, "Student");
                }
                LoadUsers("", "");
            }
            catch (SqlException ex)
            {
                string friendly = (ex.Number == 547)
                    ? "Cannot change role: this user still has linked records."
                    : "Database error: " + ex.Message;
                ShowMessage(friendly, false);
            }
        }

        // Moves an account from its current table to the target-role table, carrying
        // over name/password/personalEmail/phone/icNumber and generating a new ID+email+code.
        private void MoveAccount(string fromTable, string fromIdCol, int id, string toRole)
        {
            using (SqlConnection conn = DbHelper.GetConnection())
            {
                conn.Open();
                using (SqlTransaction tx = conn.BeginTransaction())
                {
                    string name = "", pwd = "", pe = "", ph = "", ic = "";
                    using (SqlCommand read = new SqlCommand(
                        $"SELECT name, password, personalEmail, phone, icNumber FROM {fromTable} WHERE {fromIdCol}=@id", conn, tx))
                    {
                        read.Parameters.AddWithValue("@id", id);
                        using (SqlDataReader dr = read.ExecuteReader())
                        {
                            if (!dr.Read()) { tx.Rollback(); ShowMessage("User not found.", false); return; }
                            name = dr["name"].ToString();
                            pwd = dr["password"].ToString();
                            pe = dr["personalEmail"] == DBNull.Value ? null : dr["personalEmail"].ToString();
                            ph = dr["phone"] == DBNull.Value ? null : dr["phone"].ToString();
                            ic = dr["icNumber"] == DBNull.Value ? null : dr["icNumber"].ToString();
                        }
                    }

                    string tmp = "pending_" + Guid.NewGuid().ToString("N") + "@temp.local";
                    int newId;
                    string email, code;

                    if (toRole == "Lecturer")
                    {
                        using (SqlCommand ins = new SqlCommand(@"
                            INSERT INTO LECTURER (name, email, password, personalEmail, phone, icNumber, department, staffType)
                            VALUES (@n,@tmp,@p,@pe,@ph,@ic,'School of Computing','Full-time');
                            SELECT CAST(SCOPE_IDENTITY() AS INT);", conn, tx))
                        {
                            AddPersonParams(ins, name, tmp, pwd, pe, ph, ic);
                            newId = Convert.ToInt32(ins.ExecuteScalar());
                        }
                        email = "l" + newId + "@staff.sims.edu";
                        code = "LEC" + DateTime.Now.ToString("yyMM") + newId.ToString("D3");
                        using (SqlCommand up = new SqlCommand("UPDATE LECTURER SET email=@e, lecturerCode=@c WHERE lecturerID=@i", conn, tx))
                        { up.Parameters.AddWithValue("@e", email); up.Parameters.AddWithValue("@c", code); up.Parameters.AddWithValue("@i", newId); up.ExecuteNonQuery(); }
                    }
                    else
                    {
                        using (SqlCommand ins = new SqlCommand(@"
                            INSERT INTO STUDENT (name, email, password, programmeID, personalEmail, phone, icNumber)
                            VALUES (@n,@tmp,@p,NULL,@pe,@ph,@ic);
                            SELECT CAST(SCOPE_IDENTITY() AS INT);", conn, tx))
                        {
                            AddPersonParams(ins, name, tmp, pwd, pe, ph, ic);
                            newId = Convert.ToInt32(ins.ExecuteScalar());
                        }
                        email = "s" + newId + "@student.sims.edu";
                        code = "STU" + DateTime.Now.ToString("yyMM") + newId.ToString("D3");
                        using (SqlCommand up = new SqlCommand("UPDATE STUDENT SET email=@e, studentCode=@c WHERE studentID=@i", conn, tx))
                        { up.Parameters.AddWithValue("@e", email); up.Parameters.AddWithValue("@c", code); up.Parameters.AddWithValue("@i", newId); up.ExecuteNonQuery(); }
                    }

                    using (SqlCommand del = new SqlCommand($"DELETE FROM {fromTable} WHERE {fromIdCol}=@id", conn, tx))
                    { del.Parameters.AddWithValue("@id", id); del.ExecuteNonQuery(); }

                    tx.Commit();
                    ShowMessage($"Role changed to {toRole}. New login email: {email} (code {code}).", true);
                }
            }
        }

        private void DeleteUser(string role, int id)
        {
            string table = role == "Lecturer" ? "LECTURER" : "STUDENT";
            string idCol = role == "Lecturer" ? "lecturerID" : "studentID";
            try
            {
                using (SqlConnection conn = DbHelper.GetConnection())
                using (SqlCommand cmd = new SqlCommand($"DELETE FROM {table} WHERE {idCol}=@id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                ShowMessage($"{role} deleted.", true);
                LoadUsers("", "");
            }
            catch (SqlException ex)
            {
                string friendly = (ex.Number == 547)
                    ? (role == "Lecturer" ? "Cannot delete: this lecturer is assigned to courses." : "Cannot delete: this student has enrolment/attendance records.")
                    : "Database error: " + ex.Message;
                ShowMessage(friendly, false);
            }
        }

        // ──────────────────────────────────────────────
        // Helpers
        // ──────────────────────────────────────────────
        private bool HasDependents(string table, string col, int id)
        {
            object o = DbHelper.ExecuteScalar($"SELECT COUNT(*) FROM {table} WHERE {col}=@id", P("@id", id));
            return Convert.ToInt32(o) > 0;
        }

        private void AddPersonParams(SqlCommand cmd, string name, string tmp, string pwd, string pe, string ph, string ic)
        {
            cmd.Parameters.AddWithValue("@n", name);
            cmd.Parameters.AddWithValue("@tmp", tmp);
            cmd.Parameters.AddWithValue("@p", pwd);
            cmd.Parameters.AddWithValue("@pe", (object)pe ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ph", (object)ph ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ic", (object)ic ?? DBNull.Value);
        }

        // Email delivery is stubbed until SMTP settings exist in Web.config.
        // Wrapped so a future real implementation can't crash account creation.
        private void TrySendWelcomeEmail(string toPersonal, string loginEmail, string code, string tempPwd)
        {
            try { /* TODO: configure System.Net.Mail.SmtpClient and send here */ }
            catch { /* swallow — account is already created; credentials shown on screen */ }
        }

        // We show the password once, on screen. To keep the plaintext available for
        // the credential card without storing it, it is generated once per click and
        // cached in a field for this request.
        private string _tempPwdEcho;
        private string GenTempPassword()
        {
            if (_tempPwdEcho == null)
                _tempPwdEcho = "Sims@" + new Random().Next(1000, 9999);
            return _tempPwdEcho;
        }
        private string GenTempPasswordEcho() { return _tempPwdEcho ?? GenTempPassword(); }

        private void ShowCredential(string role, string code, string email, string tempPwd)
        {
            pnlCred.Visible = true;
            lblCredRole.Text = role;
            lblCredId.Text = code;
            lblCredEmail.Text = email;
            lblCredPass.Text = tempPwd;
            ShowMessage($"{role} account created successfully.", true);
        }

        protected void btnClearForm_Click(object sender, EventArgs e) { ClearForm(); }

        private void ClearForm()
        {
            txtName.Text = ""; txtPersonalEmail.Text = ""; txtIc.Text = ""; txtPhone.Text = "";
            txtIntake.Text = ""; txtEmgName.Text = ""; txtEmgPhone.Text = ""; txtEmgRel.Text = "";
            ddlProgramme.SelectedIndex = 0;
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear(); Session.Abandon(); Response.Redirect("Login.aspx");
        }

        private static object NullIfBlank(string s)
        {
            return string.IsNullOrWhiteSpace(s) ? (object)DBNull.Value : s.Trim();
        }

        private void ShowMessage(string text, bool ok)
        {
            pnlMsg.Visible = true;
            divMsg.Attributes["class"] = ok ? "alert alert-success" : "alert alert-danger";
            litMsg.Text = $"<i class='fas {(ok ? "fa-check-circle" : "fa-exclamation-circle")} me-2'></i>{text}";
        }

        private static SqlParameter P(string name, object value)
        {
            return new SqlParameter(name, value ?? DBNull.Value);
        }
    }
}
