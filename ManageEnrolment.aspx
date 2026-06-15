<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageEnrolment.aspx.cs" Inherits="StudentManagementSystem.ManageEnrolment" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Manage Enrolment - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        /* ── SIDEBAR (same as AdminDashboard) ── */
        .sidebar {
            width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0;
            background: linear-gradient(180deg, #2c3e50 0%, #34495e 100%);
            color: white; z-index: 1000; overflow-y: auto;
        }
        .sidebar-header { padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-header h4 { font-size: 1rem; margin-bottom: 3px; }
        .sidebar-header small { color: rgba(255,255,255,0.6); font-size: 0.75rem; }
        .nav-link {
        color: rgba(255,255,255,0.8); padding: 14px 25px; display: flex; align-items: center;
        text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent;
        font-size: 0.9rem;
        }
        .nav-link:hover, .nav-link.active {
        background: rgba(255,255,255,0.1); color: white; border-left-color: #3498db;
        }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .nav-link span { font-size: 0.9rem; }
        .sidebar-footer { position: absolute; bottom: 0; width: 100%; padding: 15px 25px; border-top: 1px solid rgba(255,255,255,0.1); }

        /* ── MAIN ── */
        .main-content { margin-left: var(--sidebar-width); padding: 0; min-height: 100vh; }
        .topbar {
            background: white; padding: 15px 30px; display: flex; justify-content: space-between;
            align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 100;
        }
        .topbar h2 { font-size: 1.4rem; color: #2c3e50; margin: 0; }
        .page-content { padding: 30px; }

        /* ── TABS ── */
        .tab-nav { display: flex; gap: 4px; background: white; border-radius: 12px; padding: 6px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 25px; }
        .tab-btn {
            flex: 1; padding: 10px 16px; border: none; border-radius: 8px; background: transparent;
            font-size: 0.88rem; font-weight: 600; color: #7f8c8d; cursor: pointer; transition: all 0.2s;
        }
        .tab-btn.active { background: #3498db; color: white; }
        .tab-btn i { margin-right: 6px; }
        .tab-panel { display: none; }
        .tab-panel.active { display: block; }

        /* ── CARDS ── */
        .content-card { background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); margin-bottom: 25px; overflow: hidden; }
        .card-header-custom { padding: 20px 25px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
        .card-header-custom h5 { margin: 0; font-weight: 700; color: #2c3e50; }
        .card-body-custom { padding: 25px; }

        /* ── SEMESTER CARD ── */
        .semester-status-card {
            border-radius: 12px; padding: 20px 25px; display: flex; align-items: center;
            justify-content: space-between; margin-bottom: 15px; border: 2px solid;
        }
        .semester-status-card.open { background: #d4edda; border-color: #c3e6cb; }
        .semester-status-card.closed { background: #f8f9fa; border-color: #e9ecef; }
        .semester-status-card h6 { margin: 0 0 4px; font-weight: 700; font-size: 1rem; }
        .semester-status-card small { color: #6c757d; }

        /* ── TABLES ── */
        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th { background: #f8f9fa; padding: 12px 15px; font-size: 0.78rem; font-weight: 700; color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; }
        .table-custom td { padding: 12px 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.88rem; color: #2c3e50; vertical-align: middle; }
        .table-custom tr:last-child td { border-bottom: none; }
        .table-custom tr:hover td { background: #f8f9fa; }

        /* ── BADGES ── */
        .badge-enrolled  { background: #d4edda; color: #155724; padding: 5px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-pending   { background: #fff3cd; color: #856404; padding: 5px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-dropped   { background: #f8d7da; color: #721c24; padding: 5px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-confirmed { background: #d1ecf1; color: #0c5460; padding: 5px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-rejected  { background: #e2e3e5; color: #383d41; padding: 5px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-open      { background: #d4edda; color: #155724; padding: 5px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: 700; }
        .badge-closed    { background: #e2e3e5; color: #383d41; padding: 5px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: 700; }

        /* ── ALERT ── */
        .alert-msg { padding: 12px 18px; border-radius: 10px; font-size: 0.88rem; margin-bottom: 20px; display: none; }
        .alert-success-custom { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-danger-custom  { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        /* ── FORM ── */
        .form-label-custom { font-size: 0.85rem; font-weight: 600; color: #495057; margin-bottom: 5px; }
        .form-control, .form-select { border-radius: 8px; border: 1px solid #dee2e6; font-size: 0.88rem; }
        .form-control:focus, .form-select:focus { border-color: #3498db; box-shadow: 0 0 0 0.2rem rgba(52,152,219,0.25); }

        /* ── BUTTONS ── */
        .btn-primary-custom { background: #3498db; border: none; color: white; padding: 8px 20px; border-radius: 8px; font-size: 0.88rem; font-weight: 600; cursor: pointer; transition: all 0.2s; }
        .btn-primary-custom:hover { background: #2980b9; }
        .btn-success-custom { background: #27ae60; border: none; color: white; padding: 6px 14px; border-radius: 6px; font-size: 0.82rem; font-weight: 600; cursor: pointer; }
        .btn-danger-custom  { background: #e74c3c; border: none; color: white; padding: 6px 14px; border-radius: 6px; font-size: 0.82rem; font-weight: 600; cursor: pointer; }
        .btn-open-enrol  { background: #27ae60; border: none; color: white; padding: 8px 18px; border-radius: 8px; font-size: 0.85rem; font-weight: 600; cursor: pointer; }
        .btn-close-enrol { background: #e74c3c; border: none; color: white; padding: 8px 18px; border-radius: 8px; font-size: 0.85rem; font-weight: 600; cursor: pointer; }
        
        .topbar-actions { display: flex; align-items: center; gap: 15px; }
        .notification-bell {
            position: relative; width: 40px; height: 40px; border-radius: 50%;
            background: #f8f9fa; display: flex; align-items: center; justify-content: center;
            cursor: pointer; transition: all 0.3s;
        }
        .notification-bell:hover { background: #e9ecef; }
        .notification-bell .badge {
            position: absolute; top: -2px; right: -2px; background: #e74c3c; color: white;
            font-size: 0.65rem; padding: 3px 6px; border-radius: 10px;
        }
        .user-dropdown {
            display: flex; align-items: center; gap: 10px; cursor: pointer; padding: 8px 15px;
            border-radius: 10px; transition: all 0.3s;
        }
        .user-dropdown:hover { background: #f8f9fa; }
        .user-dropdown span { font-size: 0.9rem; font-weight: 600; color: #2c3e50; }
        </style>
</head>
<body>
<form id="form1" runat="server">

    <!-- ── SIDEBAR ── -->
    <div class="sidebar">
        <div class="sidebar-header">
            <div style="width:60px;height:60px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;margin:0 auto 10px;display:flex;align-items:center;justify-content:center;font-size:1.3rem;color:white;">
                <i class="fas fa-user-shield"></i>
            </div>
            <h4><asp:Label ID="lblUserName" runat="server" Text="Head of Programme"></asp:Label></h4>
            <small>Administrator</small>
        </div>
        <nav class="mt-3">
            <div class="nav-item"><a href="AdminDashboard.aspx"   class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
            <div class="nav-item"><a href="RegisterStudent.aspx"  class="nav-link"><i class="fas fa-users"></i><span>Manage Users</span></a></div>
            <div class="nav-item"><a href="ManageProgrammes.aspx" class="nav-link"><i class="fas fa-book"></i><span>Manage Programmes</span></a></div>
            <div class="nav-item"><a href="ManageCourses.aspx"    class="nav-link"><i class="fas fa-graduation-cap"></i><span>Manage Courses</span></a></div>
            <div class="nav-item"><a href="ManageEnrolment.aspx"  class="nav-link"><i class="fas fa-clipboard-check"></i><span>Manage Enrolment</span></a></div>
            <div class="nav-item"><a href="#"                     class="nav-link"><i class="fas fa-chart-bar"></i><span>Student Statistics</span></a></div>
            <div class="nav-item"><a href="#"                     class="nav-link"><i class="fas fa-file-export"></i><span>Reports</span></a></div>
            <div class="nav-item"><a href="AcademicCalendar.aspx" class="nav-link"><i class="fas fa-calendar-alt"></i><span>Academic Calendar</span></a></div>
            <div class="nav-item"><a href="Announcements.aspx"    class="nav-link"><i class="fas fa-bullhorn"></i><span>Announcements</span></a></div>
        </nav>
        <div class="sidebar-footer">
            <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-link" OnClick="btnLogout_Click" style="padding:10px 0;">
                <i class="fas fa-sign-out-alt"></i><span>Logout</span>
            </asp:LinkButton>
        </div>
    </div>

    <!-- ── MAIN CONTENT ── -->
    <div class="main-content">
            <div class="topbar">
                <h2><i class="fas fa-clipboard-check me-2 text-primary"></i>Manage Enrolment</h2>
                <div class="topbar-actions">
                    <div class="notification-bell">
                        <i class="fas fa-bell text-muted"></i>
                        <span class="badge">5</span>
                    </div>
                    <div class="user-dropdown">
                        <div style="width:35px;height:35px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                            <i class="fas fa-user-shield"></i>
                        </div>
                        <span><asp:Label ID="lblTopUserName" runat="server" Text="Head of Programme"></asp:Label></span>
                        <i class="fas fa-chevron-down text-muted" style="font-size:0.7rem;"></i>
                    </div>
                </div>
            </div>
        <div class="page-content">

            <!-- Alert message -->
            <asp:Label ID="lblMessage" runat="server" CssClass="alert-msg" EnableViewState="false"></asp:Label>

            <!-- ── TAB NAVIGATION ── -->
            <div class="tab-nav">
                <button type="button" class="tab-btn active" onclick="showTab('tab-semester', this)">
                    <i class="fas fa-toggle-on"></i>Semester Control
                </button>
                <button type="button" class="tab-btn" onclick="showTab('tab-assign', this)">
                    <i class="fas fa-tasks"></i>Assign Courses
                </button>
                <button type="button" class="tab-btn" onclick="showTab('tab-drops', this)">
                    <i class="fas fa-minus-circle"></i>Drop Requests
                    <asp:Label ID="lblDropBadge" runat="server" Text="" style="background:#e74c3c;color:white;border-radius:10px;padding:2px 7px;font-size:0.72rem;margin-left:5px;"></asp:Label>
                </button>
                <button type="button" class="tab-btn" onclick="showTab('tab-records', this)">
                    <i class="fas fa-list"></i>Enrolment Records
                </button>
            </div>

            <!-- ══════════════════════════════════════════════
                 TAB 1 — SEMESTER CONTROL
            ══════════════════════════════════════════════ -->
            <div id="tab-semester" class="tab-panel active">
                <div class="content-card">
                    <div class="card-header-custom">
                        <h5><i class="fas fa-toggle-on me-2 text-primary"></i>Semester Sessions</h5>
                        <small class="text-muted">Open or close enrolment windows. Closing auto-confirms all pending enrolments.</small>
                    </div>
                    <div class="card-body-custom">
                        <asp:Repeater ID="rptSemesters" runat="server">
                            <ItemTemplate>
                                <div class='semester-status-card <%# Eval("status").ToString() == "Open" ? "open" : "closed" %>'>
                                    <div>
                                        <h6><%# Eval("semesterName") %> &nbsp;
                                            <span class='<%# Eval("status").ToString() == "Open" ? "badge-open" : "badge-closed" %>'>
                                                <%# Eval("status") %>
                                            </span>
                                        </h6>
                                        <small>
                                            Enrolment: <%# Convert.ToDateTime(Eval("enrolStartDate")).ToString("d MMM yyyy") %>
                                            – <%# Convert.ToDateTime(Eval("enrolEndDate")).ToString("d MMM yyyy") %>
                                            &nbsp;·&nbsp; Type: <%# Eval("semesterType") %>
                                        </small>
                                    </div>
                                    <asp:LinkButton
                                        ID="btnToggleSemester"
                                        runat="server"
                                        CommandName="ToggleSemester"
                                        CommandArgument='<%# Eval("sessionID") + "|" + Eval("status") %>'
                                        OnCommand="btnToggleSemester_Command"
                                        CssClass='<%# Eval("status").ToString() == "Open" ? "btn-close-enrol" : "btn-open-enrol" %>'
                                        OnClientClick="return confirm('Are you sure you want to change this semester status?');">
                                        <%# Eval("status").ToString() == "Open" ? "<i class='fas fa-lock me-1'></i>Close Enrolment" : "<i class='fas fa-lock-open me-1'></i>Open Enrolment" %>
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>

            <!-- ══════════════════════════════════════════════
                 TAB 2 — ASSIGN COURSES TO PROGRAMME
            ══════════════════════════════════════════════ -->
            <div id="tab-assign" class="tab-panel">
                <div class="content-card">
                    <div class="card-header-custom">
                        <h5><i class="fas fa-tasks me-2 text-success"></i>Assign Courses to Programme</h5>
                        <small class="text-muted">Creates pending enrolment records for all students in the selected programme.</small>
                    </div>
                    <div class="card-body-custom">
                        <div class="row g-3 mb-4">
                            <div class="col-md-4">
                                <label class="form-label-custom">Semester Session</label>
                                <asp:DropDownList ID="ddlAssignSemester" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label-custom">Programme</label>
                                <asp:DropDownList ID="ddlAssignProgramme" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAssignProgramme_Changed"></asp:DropDownList>
                            </div>
                            <div class="col-md-4 d-flex align-items-end">
                                <asp:Button ID="btnLoadCourses" runat="server" Text="Load Courses" CssClass="btn-primary-custom w-100" OnClick="btnLoadCourses_Click" />
                            </div>
                        </div>

                        <!-- Course checklist -->
                        <asp:Panel ID="pnlCourseAssign" runat="server" Visible="false">
                            <div style="background:#f8f9fa;border-radius:10px;padding:20px;margin-bottom:20px;">
                                <h6 style="font-weight:700;margin-bottom:15px;color:#2c3e50;">
                                    <i class="fas fa-book me-2 text-primary"></i>
                                    Courses for <asp:Label ID="lblAssignProgrammeName" runat="server"></asp:Label>
                                </h6>
                                <p style="font-size:0.82rem;color:#6c757d;margin-bottom:15px;">
                                    Tick the courses to assign. The system will create PENDING enrolment records
                                    for every student under this programme.
                                </p>
                                <asp:CheckBoxList ID="cblCourses" runat="server" CssClass="course-checklist" RepeatLayout="Flow">
                                </asp:CheckBoxList>
                            </div>
                            <div style="display:flex;justify-content:flex-end;">
                                <asp:Button ID="btnAssignCourses" runat="server" Text="Assign Selected Courses" CssClass="btn-primary-custom" OnClick="btnAssignCourses_Click"
                                    OnClientClick="return confirm('This will create PENDING enrolment records for all students in this programme. Continue?');" />
                            </div>
                            <asp:Label ID="lblAssignResult" runat="server" style="display:block;margin-top:12px;font-size:0.85rem;font-weight:600;"></asp:Label>
                        </asp:Panel>
                    </div>
                </div>
            </div>

            <!-- ══════════════════════════════════════════════
                 TAB 3 — DROP REQUESTS
            ══════════════════════════════════════════════ -->
            <div id="tab-drops" class="tab-panel">
                <div class="content-card">
                    <div class="card-header-custom">
                        <h5><i class="fas fa-minus-circle me-2 text-danger"></i>Pending Drop Requests</h5>
                        <small class="text-muted">Approve or reject student course drop requests. Student is notified either way.</small>
                    </div>
                    <div class="card-body-custom p-0">
                        <asp:GridView
                            ID="gvDropRequests"
                            runat="server"
                            AutoGenerateColumns="false"
                            CssClass="table-custom"
                            OnRowCommand="gvDropRequests_RowCommand"
                            EmptyDataText="No pending drop requests."
                            EmptyDataRowStyle-CssClass="text-center p-4 text-muted">
                            <Columns>
                                <asp:BoundField  DataField="studentName"  HeaderText="Student"      />
                                <asp:BoundField  DataField="studentCode"  HeaderText="Student ID"   ItemStyle-CssClass="font-monospace" />
                                <asp:BoundField  DataField="courseName"   HeaderText="Course"       />
                                <asp:BoundField  DataField="courseCode"   HeaderText="Code"         ItemStyle-CssClass="font-monospace" />
                                <asp:BoundField  DataField="semester"     HeaderText="Semester"     />
                                <asp:BoundField  DataField="academicYear" HeaderText="Year"         />
                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <asp:LinkButton
                                            ID="btnApprove"
                                            runat="server"
                                            CommandName="ApproveRow"
                                            CommandArgument='<%# Eval("enrolmentID") %>'
                                            CssClass="btn-success-custom me-1"
                                            OnClientClick="return confirm('Approve this drop request?');">
                                            <i class="fas fa-check me-1"></i>Approve
                                        </asp:LinkButton>
                                        <asp:LinkButton
                                            ID="btnReject"
                                            runat="server"
                                            CommandName="RejectRow"
                                            CommandArgument='<%# Eval("enrolmentID") %>'
                                            CssClass="btn-danger-custom"
                                            OnClientClick="return confirm('Reject this drop request?');">
                                            <i class="fas fa-times me-1"></i>Reject
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <!-- ══════════════════════════════════════════════
                 TAB 4 — ENROLMENT RECORDS
            ══════════════════════════════════════════════ -->
            <div id="tab-records" class="tab-panel">
                <div class="content-card">
                    <div class="card-header-custom">
                        <h5><i class="fas fa-list me-2 text-info"></i>Enrolment Records</h5>
                    </div>
                    <div class="card-body-custom">
                        <!-- Filters -->
                        <div class="row g-3 mb-4">
                            <div class="col-md-3">
                                <label class="form-label-custom">Filter by Semester</label>
                                <asp:DropDownList ID="ddlFilterSemester" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label-custom">Filter by Programme</label>
                                <asp:DropDownList ID="ddlFilterProgramme" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label-custom">Filter by Status</label>
                                <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="All Statuses" Value=""></asp:ListItem>
                                    <asp:ListItem Text="Pending"        Value="pending"></asp:ListItem>
                                    <asp:ListItem Text="Enrolled"       Value="enrolled"></asp:ListItem>
                                    <asp:ListItem Text="Drop Requested" Value="drop_requested"></asp:ListItem>
                                    <asp:ListItem Text="Dropped"        Value="dropped"></asp:ListItem>
                                    <asp:ListItem Text="Rejected"       Value="rejected"></asp:ListItem>
                                    <asp:ListItem Text="Confirmed"      Value="confirmed"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-3 d-flex align-items-end">
                                <asp:Button ID="btnFilterRecords" runat="server" Text="Apply Filter" CssClass="btn-primary-custom w-100" OnClick="btnFilterRecords_Click" />
                            </div>
                        </div>

                        <!-- Records table -->
                        <asp:GridView
                            ID="gvEnrolmentRecords"
                            runat="server"
                            AutoGenerateColumns="false"
                            CssClass="table-custom"
                            EmptyDataText="No records found."
                            EmptyDataRowStyle-CssClass="text-center p-4 text-muted">
                            <Columns>
                                <asp:BoundField DataField="enrolmentID"  HeaderText="ID"         ItemStyle-CssClass="font-monospace" />
                                <asp:BoundField DataField="studentName"  HeaderText="Student"    />
                                <asp:BoundField DataField="studentCode"  HeaderText="Student ID" ItemStyle-CssClass="font-monospace" />
                                <asp:BoundField DataField="courseName"   HeaderText="Course"     />
                                <asp:BoundField DataField="semester"     HeaderText="Semester"   />
                                <asp:BoundField DataField="academicYear" HeaderText="Year"       />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='<%# GetStatusBadge(Eval("status").ToString()) %>'>
                                            <%# Eval("status") %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="enrolDate" HeaderText="Date" DataFormatString="{0:d MMM yyyy}" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

        </div><!-- /page-content -->
    </div><!-- /main-content -->

</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function showTab(tabId, btn) {
        // Hide all panels
        document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        // Show selected
        document.getElementById(tabId).classList.add('active');
        btn.classList.add('active');
    }

    // Auto-show alert message if present
    window.onload = function () {
    var msg = document.getElementById('<%= lblMessage.ClientID %>');
    if (msg && msg.innerText.trim() !== '') {
        msg.style.display = 'block';
        setTimeout(function () { msg.style.display = 'none'; }, 5000);
    }
};
</script>
</body>
</html>
