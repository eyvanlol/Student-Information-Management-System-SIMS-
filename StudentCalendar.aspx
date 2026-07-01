<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentCalendar.aspx.cs" Inherits="StudentManagementSystem.StudentCalendar" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Calendar - Student</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }
        .sidebar { width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0; display: flex; flex-direction: column;
            background: linear-gradient(180deg, #114f46 0%, #0c2e2a 100%); color: white; z-index: 1000; overflow-y: auto; }
        .sidebar-header { padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.08); }
        .sidebar-header h4 { font-size: 0.95rem; margin-bottom: 2px; }
        .sidebar-header small { color: rgba(255,255,255,0.5); font-size: 0.75rem; }
        .nav-item { padding: 0; }
        .nav-link { color: rgba(255,255,255,0.7); padding: 14px 25px; display: flex; align-items: center;
            text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent; font-size: 0.9rem; }
        .nav-link:hover, .nav-link.active { background: rgba(26,188,156,0.15); color: white; border-left-color: #1abc9c; }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .sidebar nav { flex: 1 1 auto; overflow-y: auto; }
        .sidebar-footer { margin-top: auto; flex-shrink: 0; width: 100%; padding: 15px 25px; border-top: 1px solid rgba(255,255,255,0.08); }
        .main-content { margin-left: var(--sidebar-width); min-height: 100vh; }
        .topbar { background: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 100; }
        .topbar h2 { font-size: 1.4rem; color: #2c3e50; margin: 0; }
        .page-content { padding: 30px; }
        .content-card { background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); margin-bottom: 25px; overflow: hidden; }
        .card-header-custom { padding: 20px 25px; border-bottom: 1px solid #f0f0f0; }
        .card-header-custom h5 { margin: 0; font-weight: 700; color: #2c3e50; }
        .card-body-custom { padding: 25px; }
        .form-label-custom { font-size: 0.85rem; font-weight: 600; color: #495057; margin-bottom: 5px; }
        .form-control, .form-select { border-radius: 8px; border: 1px solid #dee2e6; font-size: 0.9rem; }
        .form-control:focus { border-color: #1abc9c; box-shadow: 0 0 0 0.2rem rgba(26,188,156,0.25); }
        .btn-teal { background: #1abc9c; border: none; color: #fff; padding: 9px 22px; border-radius: 8px; font-weight: 600; }
        .btn-teal:hover { background: #16a085; color:#fff; }
        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th { background: #f8f9fa; padding: 12px 15px; font-size: 0.78rem; font-weight: 700; color: #7f8c8d; text-transform: uppercase; }
        .table-custom td { padding: 12px 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.88rem; color: #2c3e50; vertical-align: middle; }
        .badge-sent { background:#d4edda; color:#155724; padding:5px 10px; border-radius:20px; font-size:0.74rem; font-weight:600; }
        .badge-wait { background:#fff3cd; color:#856404; padding:5px 10px; border-radius:20px; font-size:0.74rem; font-weight:600; }
        .badge-past { background:#e2e3e5; color:#383d41; padding:5px 10px; border-radius:20px; font-size:0.74rem; font-weight:600; }
        .alert-msg { padding: 12px 18px; border-radius: 10px; font-size: 0.9rem; margin-bottom: 20px; }
        .btn-del { background:#e74c3c; border:none; color:#fff; padding:6px 12px; border-radius:6px; font-size:0.8rem; font-weight:600; }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <div class="sidebar">
        <div class="sidebar-header">
            <div style="width:60px;height:60px;background:linear-gradient(135deg,#1abc9c,#16a085);border-radius:50%;margin:0 auto 10px;display:flex;align-items:center;justify-content:center;font-size:1.3rem;color:white;">
                <i class="fas fa-user-graduate"></i>
            </div>
            <h4><asp:Label ID="lblUserName" runat="server" Text="Student"></asp:Label></h4>
            <small>Student</small>
        </div>
        <nav class="mt-3">
            <div class="nav-item"><a href="StudentDashboard.aspx" class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
            <div class="nav-item"><a href="StudentEnrolment.aspx" class="nav-link"><i class="fas fa-clipboard-check"></i><span>Enrolment</span></a></div>
            <div class="nav-item"><a href="StudentAttendance.aspx" class="nav-link"><i class="fas fa-calendar-check"></i><span>Attendance</span></a></div>
            <div class="nav-item"><a href="StudentResult.aspx" class="nav-link"><i class="fas fa-chart-line"></i><span>Results</span></a></div>
            <div class="nav-item"><a href="StudentTranscript.aspx" class="nav-link"><i class="fas fa-file-alt"></i><span>Transcript</span></a></div>
            <div class="nav-item"><a href="StudentCalendar.aspx" class="nav-link active"><i class="fas fa-calendar-alt"></i><span>My Calendar</span></a></div>
            <div class="nav-item"><a href="StudentNotifications.aspx" class="nav-link"><i class="fas fa-bell"></i><span>Notifications</span></a></div>
            <div class="nav-item"><a href="StudentProfile.aspx" class="nav-link"><i class="fas fa-user-circle"></i><span>Profile</span></a></div>
        </nav>
        <div class="sidebar-footer">
            <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-link" OnClick="btnLogout_Click" style="padding:10px 0;">
                <i class="fas fa-sign-out-alt"></i><span>Logout</span>
            </asp:LinkButton>
        </div>
    </div>

    <div class="main-content">
        <div class="topbar">
            <h2><i class="fas fa-calendar-alt me-2" style="color:#1abc9c;"></i>My Calendar</h2>
            <div style="display:flex;align-items:center;gap:10px;">
                <div style="width:35px;height:35px;background:linear-gradient(135deg,#1abc9c,#16a085);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                    <i class="fas fa-user"></i>
                </div>
                <span style="font-size:0.9rem;font-weight:600;color:#2c3e50;"><asp:Label ID="lblTopUserName" runat="server" Text=""></asp:Label></span>
            </div>
        </div>

        <div class="page-content">

            <asp:Label ID="lblMsg" runat="server" Visible="false"></asp:Label>

            <!-- Create alert -->
            <div class="content-card">
                <div class="card-header-custom">
                    <h5><i class="fas fa-plus-circle me-2" style="color:#1abc9c;"></i>Add a Personal Alert</h5>
                </div>
                <div class="card-body-custom">
                    <p style="font-size:0.85rem;color:#6c757d;">
                        Set a personal reminder. We will email your registered personal address an
                        <strong>hour before</strong> it starts, and email you a confirmation now (with your note) when you save it.
                    </p>
                    <div class="row g-3">
                        <div class="col-md-5">
                            <label class="form-label-custom">Title <span style="color:#e74c3c;">*</span></label>
                            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" MaxLength="150" placeholder="e.g. Assignment 2 submission"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtTitle"
                                ErrorMessage="Title is required." CssClass="text-danger" Display="Dynamic"
                                ValidationGroup="addAlert" style="font-size:0.8rem;"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label-custom">Date &amp; time <span style="color:#e74c3c;">*</span></label>
                            <asp:TextBox ID="txtStart" runat="server" CssClass="form-control" TextMode="DateTimeLocal"></asp:TextBox>
                            <asp:RequiredFieldValidator runat="server" ControlToValidate="txtStart"
                                ErrorMessage="Start date/time is required." CssClass="text-danger" Display="Dynamic"
                                ValidationGroup="addAlert" style="font-size:0.8rem;"></asp:RequiredFieldValidator>
                        </div>
                        <div class="col-md-3 d-flex align-items-end">
                            <asp:Button ID="btnAddAlert" runat="server" Text="Save Alert" CssClass="btn-teal w-100"
                                OnClick="btnAddAlert_Click" ValidationGroup="addAlert" />
                        </div>
                        <div class="col-12">
                            <label class="form-label-custom">Description / note</label>
                            <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"
                                placeholder="Optional details — this text is included in the reminder email."></asp:TextBox>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Upcoming + past alerts -->
            <div class="content-card">
                <div class="card-header-custom">
                    <h5><i class="fas fa-list me-2" style="color:#1abc9c;"></i>My Alerts</h5>
                </div>
                <div class="card-body-custom p-0">
                    <asp:GridView ID="gvReminders" runat="server" AutoGenerateColumns="false" CssClass="table-custom"
                        GridLines="None" OnRowCommand="gvReminders_RowCommand"
                        EmptyDataText="You have no alerts yet."
                        EmptyDataRowStyle-CssClass="text-center p-4 text-muted">
                        <Columns>
                            <asp:BoundField DataField="title" HeaderText="Title" />
                            <asp:TemplateField HeaderText="When">
                                <ItemTemplate><%# DateText(Eval("startTime")) %></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Note">
                                <ItemTemplate><%# Trunc(Eval("description")) %></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Reminder">
                                <ItemTemplate>
                                    <span class='<%# StatusBadge(Eval("startTime"), Eval("reminderSent")) %>'>
                                        <%# StatusText(Eval("startTime"), Eval("reminderSent")) %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Action">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn-del"
                                        CommandName="DeleteRow" CommandArgument='<%# Eval("reminderID") %>'
                                        OnClientClick="return confirm('Delete this alert?');">
                                        <i class="fas fa-trash"></i>
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

        </div>
    </div>
</form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
