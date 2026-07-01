<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerAttendance.aspx.cs" Inherits="StudentManagementSystem.LecturerAttendance" %>
<%@ Register Src="~/NotificationBell.ascx" TagPrefix="uc" TagName="NotificationBell" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Attendance - Lecturer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }
        .sidebar { width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0; display: flex; flex-direction: column;
            background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%); color: white; z-index: 1000; overflow-y: auto; }
        .sidebar-header { padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-header .logo { width: 70px; height: 70px; background: linear-gradient(135deg, #9b59b6, #8e44ad); border-radius: 50%; margin: 0 auto 10px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; color: white; }
        .sidebar-header h4 { font-size: 1rem; margin-bottom: 3px; }
        .sidebar-header small { color: rgba(255,255,255,0.6); font-size: 0.75rem; }
        .nav-item { padding: 0; }
        .nav-link { color: rgba(255,255,255,0.8); padding: 14px 25px; display: flex; align-items: center;
            text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent; }
        .nav-link:hover, .nav-link.active { background: rgba(155, 89, 182, 0.15); color: white; border-left-color: #9b59b6; }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .nav-link span { font-size: 0.9rem; }
        .sidebar nav { flex: 1 1 auto; overflow-y: auto; }
        .sidebar-footer { margin-top: auto; flex-shrink: 0; width: 100%; padding: 15px 25px; border-top: 1px solid rgba(255,255,255,0.1); }
        .main-content { margin-left: var(--sidebar-width); min-height: 100vh; }
        .topbar { background: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 100; }
        .topbar h2 { font-size: 1.4rem; color: #2c3e50; margin: 0; }
        .topbar-actions { display: flex; align-items: center; gap: 15px; }
        .dashboard-content { padding: 30px; }
        .content-card { background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); margin-bottom: 25px; overflow: hidden; }
        .card-header { padding: 20px 25px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
        .card-header h5 { margin: 0; font-weight: 700; color: #2c3e50; }
        .card-body { padding: 25px; }
        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th { background: #f8f9fa; padding: 14px 15px; font-size: 0.78rem; font-weight: 700; color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; border: none; }
        .table-custom td { padding: 12px 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.9rem; color: #2c3e50; vertical-align: middle; }
        .table-custom tr:hover td { background: #faf7ff; }
        .form-label { font-weight: 600; font-size: 0.85rem; color: #2c3e50; }
        .btn-main { background: linear-gradient(135deg, #9b59b6 0%, #8e44ad 100%); border: none; border-radius: 10px; padding: 10px 22px; font-weight: 600; color: white; }
        .btn-main:hover { color: white; opacity: 0.95; }
        .btn-soft { border-radius: 8px; padding: 7px 14px; font-weight: 600; font-size: 0.82rem; border: 1px solid #dee2e6; background:#fff; color:#2c3e50; }
        .status-select { border-radius: 8px; border: 1px solid #dee2e6; font-weight: 600; padding: 6px 10px; }
        /* schedule + warning badges */
        .badge-pill { padding: 5px 11px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; }
        .lvl-ok    { background:#d4edda; color:#155724; }
        .lvl-1     { background:#fff3cd; color:#856404; }
        .lvl-2     { background:#f8d7da; color:#721c24; }
        .lvl-3     { background:#c0392b; color:#fff; }
        .pct-good  { color:#27ae60; font-weight:700; }
        .pct-warn  { color:#e67e22; font-weight:700; }
        .pct-bad   { color:#c0392b; font-weight:700; }
        .info-box { background:#f4f0fa; border-left:4px solid #9b59b6; border-radius:8px; padding:12px 16px; font-size:0.85rem; color:#4a3a5a; margin-bottom:15px; }
        @media (max-width: 768px) { .sidebar { transform: translateX(-100%); } .main-content { margin-left: 0; } }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <div class="sidebar">
        <div class="sidebar-header">
            <div class="logo"><i class="fas fa-chalkboard-teacher"></i></div>
            <h4><asp:Label ID="lblUserName" runat="server" Text="Lecturer"></asp:Label></h4>
            <small>Lecturer</small>
        </div>
        <nav class="mt-3">
            <div class="nav-item"><a href="LecturerDashboard.aspx" class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
            <div class="nav-item"><a href="LecturerProfile.aspx" class="nav-link"><i class="fas fa-user-circle"></i><span>My Profile</span></a></div>
            <div class="nav-item"><a href="LecturerCourses.aspx" class="nav-link"><i class="fas fa-book"></i><span>My Courses</span></a></div>
            <div class="nav-item"><a href="LecturerAttendance.aspx" class="nav-link active"><i class="fas fa-clipboard-check"></i><span>Attendance</span></a></div>
            <div class="nav-item"><a href="ManageGrades.aspx" class="nav-link"><i class="fas fa-clipboard-list"></i><span>Grades & Assessments</span></a></div>
            <div class="nav-item"><a href="AtRiskStudents.aspx" class="nav-link"><i class="fas fa-exclamation-triangle"></i><span>AtRisk Students</span></a></div>
            <div class="nav-item"><a href="LecturerAnnouncements.aspx" class="nav-link"><i class="fas fa-bullhorn"></i><span>Announcements</span></a></div>
        </nav>
        <div class="sidebar-footer">
            <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-link" OnClick="btnLogout_Click" style="padding:10px 0;">
                <i class="fas fa-sign-out-alt"></i><span>Logout</span>
            </asp:LinkButton>
        </div>
    </div>

    <div class="main-content">
        <div class="topbar">
            <h2><i class="fas fa-clipboard-check me-2" style="color:#9b59b6;"></i>Attendance</h2>
            <div class="topbar-actions">
                <uc:NotificationBell runat="server" ID="ucNotificationBell" />
                <div style="display:flex;align-items:center;gap:10px;">
                    <div style="width:35px;height:35px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                        <i class="fas fa-user"></i>
                    </div>
                    <span style="font-size:0.9rem;font-weight:600;color:#2c3e50;"><asp:Label ID="lblTopUserName" runat="server" Text=""></asp:Label></span>
                </div>
            </div>
        </div>

        <div class="dashboard-content">

            <asp:Label ID="lblMsg" runat="server"></asp:Label>

            <!-- ── Course selector (shared by all sections) ── -->
            <div class="content-card">
                <div class="card-header"><h5><i class="fas fa-book me-2" style="color:#9b59b6;"></i>Select Course</h5></div>
                <div class="card-body">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-6">
                            <label class="form-label">Course (4 credit hours · 2 classes per week)</label>
                            <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-select" AutoPostBack="true"
                                OnSelectedIndexChanged="ddlCourse_SelectedIndexChanged"></asp:DropDownList>
                        </div>
                        <div class="col-md-6">
                            <asp:Button ID="btnLoadStudents" runat="server" Text="Load Students for Marking"
                                CssClass="btn btn-main" OnClick="btnLoadStudents_Click" />
                            <asp:Button ID="btnRefreshWarnings" runat="server" Text="Refresh Warnings"
                                CssClass="btn btn-soft ms-2" OnClick="btnRefreshWarnings_Click" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- ══════════ CLASS SCHEDULE ══════════ -->
            <div class="content-card">
                <div class="card-header"><h5><i class="fas fa-calendar-week me-2" style="color:#9b59b6;"></i>Class Schedule</h5></div>
                <div class="card-body">
                    <div class="row g-3 align-items-end mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Semester session</label>
                            <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>
                        <div class="col-md-6">
                            <asp:Button ID="btnGenerateSchedule" runat="server" Text="Generate Schedule"
                                CssClass="btn btn-main" OnClick="btnGenerateSchedule_Click" />
                        </div>
                    </div>
                    <asp:Label ID="lblScheduleInfo" runat="server" CssClass="info-box d-block" Visible="false"></asp:Label>
                    <div class="table-responsive">
                        <asp:GridView ID="gvSchedule" runat="server" AutoGenerateColumns="false" CssClass="table-custom"
                            GridLines="None" OnRowCommand="gvSchedule_RowCommand"
                            EmptyDataText="Pick a semester and click Generate Schedule.">
                            <Columns>
                                <asp:BoundField DataField="Week"    HeaderText="Week" />
                                <asp:BoundField DataField="ClassNo" HeaderText="Class" />
                                <asp:BoundField DataField="Day"     HeaderText="Day" />
                                <asp:BoundField DataField="DateText" HeaderText="Date" />
                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnPick" runat="server" CssClass="btn-soft"
                                            CommandName="PickDate" CommandArgument='<%# Eval("DateIso") %>'>
                                            <i class="fas fa-pen me-1"></i>Mark this class
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <!-- ══════════ MARK ATTENDANCE ══════════ -->
            <div class="content-card">
                <div class="card-header"><h5><i class="fas fa-calendar-check me-2" style="color:#9b59b6;"></i>Mark Attendance</h5></div>
                <div class="card-body">
                    <div class="row g-3 align-items-end mb-3">
                        <div class="col-md-4">
                            <label class="form-label">Date</label>
                            <asp:TextBox ID="txtDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Session Type</label>
                            <asp:DropDownList ID="ddlSessionType" runat="server" CssClass="form-select">
                                <asp:ListItem>Lecture</asp:ListItem>
                                <asp:ListItem>Tutorial</asp:ListItem>
                                <asp:ListItem>Lab</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4">
                            <button type="button" class="btn-soft" onclick="markAll('Present');return false;"><i class="fas fa-check text-success me-1"></i>All Present</button>
                            <button type="button" class="btn-soft ms-1" onclick="markAll('Absent');return false;"><i class="fas fa-times text-danger me-1"></i>All Absent</button>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <asp:GridView ID="gvStudents" runat="server" AutoGenerateColumns="False" CssClass="table-custom"
                            GridLines="None" DataKeyNames="studentID" EmptyDataText="Select a course and click Load Students.">
                            <Columns>
                                <asp:TemplateField HeaderText="#"><ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate></asp:TemplateField>
                                <asp:BoundField DataField="studentCode" HeaderText="Student ID" />
                                <asp:BoundField DataField="name" HeaderText="Student Name" />
                                <asp:TemplateField HeaderText="Mark (Present / Absent / Late)">
                                    <ItemTemplate>
                                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="status-select">
                                            <asp:ListItem>Present</asp:ListItem>
                                            <asp:ListItem>Absent</asp:ListItem>
                                            <asp:ListItem>Late</asp:ListItem>
                                        </asp:DropDownList>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                    <div class="mt-3">
                        <asp:Button ID="btnSave" runat="server" Text="Save Attendance" CssClass="btn btn-main" OnClick="btnSave_Click" />
                        <a href="LecturerDashboard.aspx" class="btn btn-outline-secondary ms-2">Back</a>
                    </div>
                </div>
            </div>

            <!-- ══════════ ATTENDANCE WARNINGS ══════════ -->
            <div class="content-card">
                <div class="card-header">
                    <h5><i class="fas fa-triangle-exclamation me-2 text-danger"></i>Attendance Warnings</h5>
                    <asp:Button ID="btnSendAllWarnings" runat="server" Text="Send All Pending Letters"
                        CssClass="btn btn-main" OnClick="btnSendAllWarnings_Click"
                        OnClientClick="return confirm('Send warning letters to all flagged students? Students below 40% will be AUTO-DROPPED.');" />
                </div>
                <div class="card-body">
                    <div class="info-box">
                        Thresholds — <strong>&lt; 80%</strong>: First Warning &nbsp;·&nbsp;
                        <strong>&lt; 60%</strong>: Second Warning + barred from final exam &nbsp;·&nbsp;
                        <strong>&lt; 40%</strong>: Automatic drop from the course.
                    </div>
                    <div class="table-responsive">
                        <asp:GridView ID="gvWarnings" runat="server" AutoGenerateColumns="false" CssClass="table-custom"
                            GridLines="None" OnRowCommand="gvWarnings_RowCommand"
                            EmptyDataText="Select a course and click Refresh Warnings.">
                            <Columns>
                                <asp:BoundField DataField="name" HeaderText="Student" />
                                <asp:BoundField DataField="studentCode" HeaderText="Student ID" />
                                <asp:TemplateField HeaderText="Sessions">
                                    <ItemTemplate><%# Eval("attended") %> / <%# Eval("total") %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Attendance %">
                                    <ItemTemplate><span class='<%# PctClass(Eval("percent")) %>'><%# Eval("percent") %>%</span></ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate><span class='badge-pill <%# LevelBadge(Eval("level")) %>'><%# LevelText(Eval("level")) %></span></ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="btnSendOne" runat="server" CssClass="btn-soft"
                                            Visible='<%# Convert.ToInt32(Eval("level")) > 0 %>'
                                            CommandName="SendWarn" CommandArgument='<%# Eval("studentID") %>'
                                            OnClientClick="return confirm('Send the appropriate warning letter to this student? (Below 40% will be auto-dropped.)');">
                                            <i class="fas fa-envelope me-1"></i>Send Letter
                                        </asp:LinkButton>
                                        <asp:Label runat="server" Visible='<%# Convert.ToInt32(Eval("level")) == 0 %>' CssClass="text-muted" Text="OK"></asp:Label>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

        </div>
    </div>
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function markAll(status) {
        document.querySelectorAll('select[id$="ddlStatus"]').forEach(function (s) { s.value = status; });
    }
</script>
</body>
</html>
