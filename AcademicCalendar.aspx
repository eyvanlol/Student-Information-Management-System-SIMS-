<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AcademicCalendar.aspx.cs" Inherits="StudentManagementSystem.AcademicCalendar" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Academic Calendar - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        /* ── SIDEBAR ── */
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

        /* ── CARDS ── */
        .content-card { background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); margin-bottom: 25px; overflow: hidden; }
        .card-header-custom { padding: 20px 25px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
        .card-header-custom h5 { margin: 0; font-weight: 700; color: #2c3e50; }
        .card-body-custom { padding: 25px; }

        /* ── FORM ── */
        .form-label-custom { font-size: 0.85rem; font-weight: 600; color: #495057; margin-bottom: 5px; }
        .form-control, .form-select { border-radius: 8px; border: 1px solid #dee2e6; font-size: 0.88rem; padding: 8px 12px; }
        .form-control:focus, .form-select:focus { border-color: #3498db; box-shadow: 0 0 0 0.2rem rgba(52,152,219,0.25); }

        /* ── TABLE ── */
        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th { background: #f8f9fa; padding: 12px 15px; font-size: 0.78rem; font-weight: 700; color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; }
        .table-custom td { padding: 12px 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.88rem; color: #2c3e50; vertical-align: middle; }
        .table-custom tr:last-child td { border-bottom: none; }
        .table-custom tr:hover td { background: #f8f9fa; }

        /* ── EVENT TYPE BADGES ── */
        .badge-semester    { background: #d1ecf1; color: #0c5460; padding: 5px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-enrolment   { background: #fff3cd; color: #856404; padding: 5px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-exam        { background: #f8d7da; color: #721c24; padding: 5px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-holiday     { background: #d4edda; color: #155724; padding: 5px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-other       { background: #e2e3e5; color: #383d41; padding: 5px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }

        /* ── ALERT ── */
        .alert-msg { padding: 12px 18px; border-radius: 10px; font-size: 0.88rem; margin-bottom: 20px; display: none; }
        .alert-success-custom { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-danger-custom  { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        /* ── BUTTONS ── */
        .btn-primary-custom { background: #3498db; border: none; color: white; padding: 8px 20px; border-radius: 8px; font-size: 0.88rem; font-weight: 600; cursor: pointer; }
        .btn-primary-custom:hover { background: #2980b9; }
        .btn-danger-custom  { background: #e74c3c; border: none; color: white; padding: 5px 12px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; cursor: pointer; }
        .btn-warning-custom { background: #f39c12; border: none; color: white; padding: 5px 12px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; cursor: pointer; }

        /* ── EDIT PANEL ── */
        .edit-panel { background: #f8f9fa; border-radius: 12px; padding: 20px; margin-bottom: 20px; border: 1px solid #e9ecef; display: none; }
        .edit-panel.visible { display: block; }
        .edit-panel h6 { font-weight: 700; margin-bottom: 15px; color: #2c3e50; }

        /* ── UPCOMING HIGHLIGHT ── */
        .upcoming-row td { background: #fffbf0 !important; }

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
                <div class="nav-item"><a href="AdminDashboard.aspx" class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
                <div class="nav-item"><a href="ManageProgrammes.aspx" class="nav-link"><i class="fas fa-book"></i><span>Academic Programmes</span></a></div>
                <div class="nav-item"><a href="ManageCourses.aspx" class="nav-link"><i class="fas fa-graduation-cap"></i><span>Courses</span></a></div>
                <div class="nav-item"><a href="RegisterLecturer.aspx" class="nav-link"><i class="fas fa-user-tie"></i><span>Register Lecturer</span></a></div>
                <div class="nav-item"><a href="RegisterStudent.aspx" class="nav-link"><i class="fas fa-user-graduate"></i><span>Register Student</span></a></div>
                <div class="nav-item"><a href="ManageUsers.aspx" class="nav-link"><i class="fas fa-users"></i><span>Manage Users</span></a></div>
                <div class="nav-item"><a href="ManageEnrolment.aspx" class="nav-link"><i class="fas fa-clipboard-check"></i><span>Enrolment</span></a></div>
                <div class="nav-item"><a href="StudentStatistics.aspx" class="nav-link"><i class="fas fa-chart-pie"></i><span>Statistics</span></a></div>
                <div class="nav-item"><a href="Announcements.aspx" class="nav-link"><i class="fas fa-bullhorn"></i><span>Announcements</span></a></div>
                <div class="nav-item"><a href="AcademicCalendar.aspx" class="nav-link active"><i class="fas fa-calendar-alt"></i><span>Academic Calendar</span></a></div>
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
                        <h2><i class="fas fa-calendar-alt me-2 text-primary"></i>Academic Calendar</h2>
                        <div class="topbar-actions">
                    <div class="notification-bell">
                        <i class="fas fa-bell text-muted"></i>
                        <span class="badge">5</span>
                    </div>
                    <div style="display:flex;align-items:center;gap:10px;">
                        <div style="width:35px;height:35px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                            <i class="fas fa-user"></i>
                        </div>
                        <span style="font-size:0.9rem;font-weight:600;color:#2c3e50;"><asp:Label ID="lblTopUserName" runat="server" Text=""></asp:Label></span>
                    </div>
                </div>
            </div>

        <div class="page-content">

            <!-- Alert -->
            <asp:Label ID="lblMessage" runat="server" CssClass="alert-msg" EnableViewState="false"></asp:Label>

            <div class="row">

                <!-- ── LEFT: ADD / EDIT FORM ── -->
                <div class="col-md-4">
                    <div class="content-card">
                        <div class="card-header-custom">
                            <h5><i class="fas fa-plus-circle me-2 text-success"></i>Add New Event</h5>
                        </div>
                        <div class="card-body-custom">

                            <!-- Hidden field to track edit mode -->
                            <asp:HiddenField ID="hdnEditSessionID" runat="server" Value="0" />

                            <div class="mb-3">
                                <label class="form-label-custom">Event Name</label>
                                <asp:TextBox ID="txtEventName" runat="server" CssClass="form-control" placeholder="e.g. APRIL 2026 Semester Begins" MaxLength="150"></asp:TextBox>
                                <asp:RequiredFieldValidator
                                    ID="rfvEventName" runat="server"
                                    ControlToValidate="txtEventName"
                                    ErrorMessage="Event name is required."
                                    CssClass="text-danger" Display="Dynamic"
                                    ValidationGroup="CalendarForm"
                                    style="font-size:0.8rem;">
                                </asp:RequiredFieldValidator>
                            </div>

                            <div class="mb-3">
                                <label class="form-label-custom">Event Type</label>
                                <asp:DropDownList ID="ddlEventType" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="-- Select Type --" Value=""></asp:ListItem>
                                    <asp:ListItem Text="Semester"   Value="Semester"></asp:ListItem>
                                    <asp:ListItem Text="Enrolment" Value="Enrolment"></asp:ListItem>
                                    <asp:ListItem Text="Exam"      Value="Exam"></asp:ListItem>
                                    <asp:ListItem Text="Holiday"   Value="Holiday"></asp:ListItem>
                                    <asp:ListItem Text="Other"     Value="Other"></asp:ListItem>
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator
                                    ID="rfvEventType" runat="server"
                                    ControlToValidate="ddlEventType"
                                    InitialValue=""
                                    ErrorMessage="Please select an event type."
                                    CssClass="text-danger" Display="Dynamic"
                                    ValidationGroup="CalendarForm"
                                    style="font-size:0.8rem;">
                                </asp:RequiredFieldValidator>
                            </div>

                            <div class="mb-3">
                                <label class="form-label-custom">Start Date</label>
                                <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                                <asp:RequiredFieldValidator
                                    ID="rfvStartDate" runat="server"
                                    ControlToValidate="txtStartDate"
                                    ErrorMessage="Start date is required."
                                    CssClass="text-danger" Display="Dynamic"
                                    ValidationGroup="CalendarForm"
                                    style="font-size:0.8rem;">
                                </asp:RequiredFieldValidator>
                            </div>

                            <div class="mb-3">
                                <label class="form-label-custom">End Date <small class="text-muted">(optional for single-day events)</small></label>
                                <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label-custom">Academic Year</label>
                                <asp:TextBox ID="txtAcademicYear" runat="server" CssClass="form-control" placeholder="e.g. 2025/2026" MaxLength="10"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label-custom">Affects</label>
                                <asp:DropDownList ID="ddlAffects" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="All"       Value="All"></asp:ListItem>
                                    <asp:ListItem Text="Students"  Value="Students"></asp:ListItem>
                                    <asp:ListItem Text="Lecturers" Value="Lecturers"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div style="display:flex;gap:10px;">
                                <asp:Button
                                    ID="btnSaveEvent"
                                    runat="server"
                                    Text="Save Event"
                                    CssClass="btn-primary-custom flex-grow-1"
                                    OnClick="btnSaveEvent_Click"
                                    ValidationGroup="CalendarForm" />
                                <asp:Button
                                    ID="btnCancelEdit"
                                    runat="server"
                                    Text="Cancel"
                                    CssClass="btn btn-outline-secondary"
                                    OnClick="btnCancelEdit_Click"
                                    CausesValidation="false"
                                    Visible="false" />
                            </div>

                        </div>
                    </div>
                </div>

                <!-- ── RIGHT: EVENTS LIST ── -->
                <div class="col-md-8">
                    <div class="content-card">
                        <div class="card-header-custom">
                            <h5><i class="fas fa-calendar-alt me-2 text-primary"></i>All Calendar Events</h5>
                            <!-- Filter by type -->
                            <div style="display:flex;gap:8px;align-items:center;">
                                <asp:DropDownList ID="ddlFilterType" runat="server" CssClass="form-select form-select-sm" style="width:160px;" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterType_Changed">
                                    <asp:ListItem Text="All Types"  Value=""></asp:ListItem>
                                    <asp:ListItem Text="Semester"   Value="Semester"></asp:ListItem>
                                    <asp:ListItem Text="Enrolment"  Value="Enrolment"></asp:ListItem>
                                    <asp:ListItem Text="Exam"       Value="Exam"></asp:ListItem>
                                    <asp:ListItem Text="Holiday"    Value="Holiday"></asp:ListItem>
                                    <asp:ListItem Text="Other"      Value="Other"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="card-body-custom p-0">
                            <asp:GridView
                                ID="gvCalendar"
                                runat="server"
                                AutoGenerateColumns="false"
                                CssClass="table-custom"
                                OnRowCommand="gvCalendar_RowCommand"
                                EmptyDataText="No calendar events found."
                                EmptyDataRowStyle-CssClass="text-center p-4 text-muted">
                                <Columns>
                                    <asp:BoundField DataField="eventName"    HeaderText="Event"        />
                                    <asp:TemplateField HeaderText="Type">
                                        <ItemTemplate>
                                            <span class='<%# GetTypeBadge(Eval("eventType").ToString()) %>'>
                                                <%# Eval("eventType") %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Date(s)">
                                        <ItemTemplate>
                                            <%# FormatDateRange(Eval("startDate"), Eval("endDate")) %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="academicYear" HeaderText="Year"         />
                                    <asp:BoundField DataField="affects"      HeaderText="Affects"      />
                                    <asp:TemplateField HeaderText="Actions">
                                        <ItemTemplate>
                                            <asp:LinkButton
                                                ID="btnEdit"
                                                runat="server"
                                                CommandName="EditRow"
                                                CommandArgument='<%# Eval("calendarID") %>'
                                                CssClass="btn-warning-custom me-1">
                                                <i class="fas fa-edit"></i>
                                            </asp:LinkButton>
                                            <asp:LinkButton
                                                ID="btnDelete"
                                                runat="server"
                                                CommandName="DeleteRow"
                                                CommandArgument='<%# Eval("calendarID") %>'
                                                CssClass="btn-danger-custom"
                                                OnClientClick="return confirm('Delete this event?');">
                                                <i class="fas fa-trash"></i>
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>

                    <!-- Upcoming events summary -->
                    <div class="content-card">
                        <div class="card-header-custom">
                            <h5><i class="fas fa-clock me-2 text-warning"></i>Upcoming Events <small class="text-muted" style="font-size:0.75rem;">(next 60 days)</small></h5>
                        </div>
                        <div class="card-body-custom p-0">
                            <asp:GridView
                                ID="gvUpcoming"
                                runat="server"
                                AutoGenerateColumns="false"
                                CssClass="table-custom"
                                RowStyle-CssClass="upcoming-row"
                                EmptyDataText="No upcoming events in the next 60 days."
                                EmptyDataRowStyle-CssClass="text-center p-4 text-muted">
                                <Columns>
                                    <asp:BoundField DataField="eventName"  HeaderText="Event"  />
                                    <asp:TemplateField HeaderText="Type">
                                        <ItemTemplate>
                                            <span class='<%# GetTypeBadge(Eval("eventType").ToString()) %>'>
                                                <%# Eval("eventType") %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Date(s)">
                                        <ItemTemplate>
                                            <%# FormatDateRange(Eval("startDate"), Eval("endDate")) %>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="affects" HeaderText="Affects" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

            </div><!-- /row -->
        </div><!-- /page-content -->
    </div><!-- /main-content -->

</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
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
