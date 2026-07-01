<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentDashboard.aspx.cs" Inherits="StudentManagementSystem.StudentDashboard" %>
<%@ Register Src="~/NotificationBell.ascx" TagPrefix="uc" TagName="NotificationBell" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Student Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        /* ── SIDEBAR ── */
        .sidebar {
            width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0; display: flex; flex-direction: column;
            background: linear-gradient(180deg, #114f46 0%, #0c2e2a 100%);
            color: white; z-index: 1000; overflow-y: auto;
        }
        .sidebar-header { padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.08); }
        .sidebar-header h4 { font-size: 0.95rem; margin-bottom: 2px; }
        .sidebar-header small { color: rgba(255,255,255,0.5); font-size: 0.75rem; }
        .nav-item { padding: 0; }
        .nav-link {
            color: rgba(255,255,255,0.7); padding: 14px 25px; display: flex; align-items: center;
            text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent; font-size: 0.9rem;
        }
        .nav-link:hover, .nav-link.active {
            background: rgba(26,188,156,0.15); color: white; border-left-color: #1abc9c;
        }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .nav-link span { font-size: 0.9rem; }
        .sidebar nav { flex: 1 1 auto; overflow-y: auto; }
        .sidebar-footer { margin-top: auto; flex-shrink: 0; width: 100%; padding: 15px 25px; border-top: 1px solid rgba(255,255,255,0.08); }

        /* ── MAIN ── */
        .main-content { margin-left: var(--sidebar-width); padding: 0; min-height: 100vh; }
        .topbar {
            background: white; padding: 15px 30px; display: flex; justify-content: space-between;
            align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 100;
        }
        .topbar h2 { font-size: 1.4rem; color: #2c3e50; margin: 0; }
        .topbar-actions { display: flex; align-items: center; gap: 15px; }
        .notification-bell {
            position: relative; width: 40px; height: 40px; border-radius: 50%;
            background: #f8f9fa; display: flex; align-items: center; justify-content: center; cursor: pointer;
        }
        .notification-bell:hover { background: #e9ecef; }
        .notification-bell .badge {
            position: absolute; top: -2px; right: -2px; background: #e74c3c; color: white;
            font-size: 0.65rem; padding: 3px 6px; border-radius: 10px;
        }
        .user-dropdown {
            display: flex; align-items: center; gap: 10px; cursor: pointer;
            padding: 8px 15px; border-radius: 10px; transition: all 0.3s;
        }
        .user-dropdown:hover { background: #f8f9fa; }
        .user-dropdown span { font-size: 0.9rem; font-weight: 600; color: #2c3e50; }

        /* ── CONTENT ── */
        .page-content { padding: 30px; }

        /* ── STAT CARDS ── */
        .stat-card {
            background: white; border-radius: 15px; padding: 22px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.05);
            display: flex; align-items: center; gap: 18px; transition: transform 0.3s;
        }
        .stat-card:hover { transform: translateY(-4px); }
        .stat-icon {
            width: 56px; height: 56px; border-radius: 14px; display: flex;
            align-items: center; justify-content: center; font-size: 1.4rem; color: white; flex-shrink: 0;
        }
        .icon-blue   { background: linear-gradient(135deg, #16a085, #1abc9c); }
        .icon-green  { background: linear-gradient(135deg, #27ae60, #229954); }
        .icon-orange { background: linear-gradient(135deg, #f39c12, #e67e22); }
        .icon-purple { background: linear-gradient(135deg, #8e44ad, #9b59b6); }
        .icon-teal   { background: linear-gradient(135deg, #16a085, #1abc9c); }
        .stat-info h3 { font-size: 1.6rem; font-weight: 700; margin: 0; color: #2c3e50; }
        .stat-info p  { color: #7f8c8d; margin: 0; font-size: 0.85rem; }

        /* ── CONTENT CARDS ── */
        .content-card { background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); margin-bottom: 24px; overflow: hidden; }
        .card-header-custom { padding: 18px 24px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
        .card-header-custom h5 { margin: 0; font-weight: 700; color: #2c3e50; font-size: 1rem; }
        .card-body-custom { padding: 24px; }

        /* ── TABLE ── */
        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th { background: #f8f9fa; padding: 12px 15px; font-size: 0.78rem; font-weight: 700; color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; }
        .table-custom td { padding: 12px 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.88rem; color: #2c3e50; vertical-align: middle; }
        .table-custom tr:last-child td { border-bottom: none; }
        .table-custom tr:hover td { background: #f8f9fa; }

        /* ── BADGES ── */
        .badge-good    { background: #d4edda; color: #155724; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-warn    { background: #fff3cd; color: #856404; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-danger  { background: #f8d7da; color: #721c24; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-info    { background: #d1ecf1; color: #0c5460; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }

        /* ── NOTIFICATION ITEMS ── */
        .notif-item { display: flex; gap: 12px; align-items: flex-start; padding: 12px 0; border-bottom: 1px solid #f0f0f0; }
        .notif-item:last-child { border-bottom: none; }
        .notif-dot { width: 10px; height: 10px; border-radius: 50%; margin-top: 5px; flex-shrink: 0; }
        .dot-blue   { background: #3498db; }
        .dot-green  { background: #27ae60; }
        .dot-amber  { background: #f39c12; }
        .dot-red    { background: #e74c3c; }
        .dot-gray   { background: #95a5a6; }
        .notif-title { font-size: 0.88rem; font-weight: 600; color: #2c3e50; margin-bottom: 2px; }
        .notif-msg   { font-size: 0.8rem; color: #7f8c8d; margin-bottom: 3px; }
        .notif-time  { font-size: 0.75rem; color: #bdc3c7; }

        /* ── WELCOME BANNER ── */
        .welcome-banner {
            background: linear-gradient(135deg, #16a085, #1abc9c);
            border-radius: 15px; padding: 24px 28px; color: white;
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 24px;
        }
        .welcome-banner h3 { font-size: 1.3rem; font-weight: 700; margin: 0 0 4px; }
        .welcome-banner p  { font-size: 0.88rem; opacity: 0.85; margin: 0; }
        .welcome-icon { font-size: 3rem; opacity: 0.3; }

        /* ── ALERT ── */
        .alert-attendance {
            background: #fff3cd; border: 1px solid #ffc107; border-radius: 10px;
            padding: 12px 18px; font-size: 0.88rem; color: #856404;
            display: flex; align-items: center; gap: 10px; margin-bottom: 20px;
        }

        /* ── VIEW ALL LINK ── */
        .view-all { font-size: 0.82rem; color: #3498db; text-decoration: none; font-weight: 600; }
        .view-all:hover { text-decoration: underline; }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <!-- ── SIDEBAR ── -->
    <div class="sidebar">
        <div class="sidebar-header">
            <div style="width:60px;height:60px;background:linear-gradient(135deg,#1abc9c,#16a085);border-radius:50%;margin:0 auto 10px;display:flex;align-items:center;justify-content:center;font-size:1.3rem;color:white;">
                <i class="fas fa-user-graduate"></i>
            </div>
            <h4><asp:Label ID="lblUserName" runat="server" Text="Student"></asp:Label></h4>
            <small><asp:Label ID="lblProgramme" runat="server" Text=""></asp:Label></small>
        </div>
        <nav class="mt-3">
                <div class="nav-item"><a href="StudentDashboard.aspx" class="nav-link active"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
                <div class="nav-item"><a href="StudentEnrolment.aspx" class="nav-link"><i class="fas fa-clipboard-check"></i><span>Enrolment</span></a></div>
                <div class="nav-item"><a href="StudentAttendance.aspx" class="nav-link"><i class="fas fa-calendar-check"></i><span>Attendance</span></a></div>
                <div class="nav-item"><a href="StudentResult.aspx" class="nav-link"><i class="fas fa-chart-line"></i><span>Results</span></a></div>
                <div class="nav-item"><a href="StudentTranscript.aspx" class="nav-link"><i class="fas fa-file-alt"></i><span>Transcript</span></a></div>
                <div class="nav-item"><a href="StudentCalendar.aspx" class="nav-link"><i class="fas fa-calendar-alt"></i><span>My Calendar</span></a></div>
                <div class="nav-item"><a href="StudentNotifications.aspx" class="nav-link"><i class="fas fa-bell"></i><span>Notifications</span></a></div>
                <div class="nav-item"><a href="StudentProfile.aspx" class="nav-link"><i class="fas fa-user-circle"></i><span>Profile</span></a></div>
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
            <h2><i class="fas fa-home me-2" style="color:#1abc9c;"></i>Student Dashboard</h2>
            <div class="topbar-actions">
                <uc:NotificationBell runat="server" ID="ucNotificationBell" />
                <div style="display:flex;align-items:center;gap:10px;">
                        <div style="width:35px;height:35px;background:linear-gradient(135deg,#1abc9c,#16a085);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                            <i class="fas fa-user"></i>
                        </div>
                        <div style="display:flex;flex-direction:column;line-height:1.2;">
                            <span style="font-size:0.9rem;font-weight:600;color:#2c3e50;"><asp:Label ID="lblTopUserName" runat="server" Text=""></asp:Label></span>
                            <span style="font-size:0.72rem;color:#7f8c8d;"><asp:Label ID="lblTopStudentId" runat="server" Text=""></asp:Label></span>
                        </div>
                        </div>
            </div>
        </div>

        <div class="page-content">

            <!-- Welcome Banner -->
            <div class="welcome-banner">
                <div>
                    <h3>Welcome back, <asp:Label ID="lblWelcomeName" runat="server" Text="Student"></asp:Label>!</h3>
                    <p><asp:Label ID="lblWelcomeSemester" runat="server" Text="Current semester loading..."></asp:Label></p>
                </div>
                <i class="fas fa-graduation-cap welcome-icon"></i>
            </div>

            <!-- Low attendance warning — shown only if any course below 80% -->
            <asp:Panel ID="pnlAttendanceWarning" runat="server" Visible="false">
                <div class="alert-attendance">
                    <i class="fas fa-exclamation-triangle"></i>
                    <span><asp:Label ID="lblAttendanceWarning" runat="server"></asp:Label></span>
                </div>
            </asp:Panel>

            <!-- Stats Row -->
            <div class="row g-3 mb-4">
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-icon icon-blue"><i class="fas fa-book"></i></div>
                        <div class="stat-info">
                            <h3><asp:Label ID="lblEnrolledCount" runat="server" Text="0"></asp:Label></h3>
                            <p>Courses enrolled</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-icon icon-green"><i class="fas fa-calendar-check"></i></div>
                        <div class="stat-info">
                            <h3><asp:Label ID="lblAttendancePct" runat="server" Text="—"></asp:Label></h3>
                            <p>Overall attendance</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-icon icon-purple"><i class="fas fa-star"></i></div>
                        <div class="stat-info">
                            <h3><asp:Label ID="lblGPA" runat="server" Text="—"></asp:Label></h3>
                            <p>Current GPA</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="stat-card">
                        <div class="stat-icon icon-orange"><i class="fas fa-bell"></i></div>
                        <div class="stat-info">
                            <h3><asp:Label ID="lblUnreadNotif" runat="server" Text="0"></asp:Label></h3>
                            <p>Unread notifications</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Current Courses + Notifications -->
            <div class="row">
                <div class="col-md-8">
                    <div class="content-card">
                        <div class="card-header-custom">
                            <h5><i class="fas fa-book-open me-2 text-primary"></i>Current semester courses</h5>
                            <a href="StudentEnrolment.aspx" class="view-all">View enrolment →</a>
                        </div>
                        <div class="card-body-custom p-0">
                            <asp:GridView
                                ID="gvCourses"
                                runat="server"
                                AutoGenerateColumns="false"
                                CssClass="table-custom"
                                EmptyDataText="No courses enrolled for current semester."
                                EmptyDataRowStyle-CssClass="text-center p-4 text-muted">
                                <Columns>
                                    <asp:BoundField DataField="courseCode" HeaderText="Code" ItemStyle-CssClass="font-monospace" />
                                    <asp:BoundField DataField="courseName" HeaderText="Course name" />
                                    <asp:BoundField DataField="creditHour" HeaderText="Credit hrs" ItemStyle-HorizontalAlign="Center" />
                                    <asp:TemplateField HeaderText="Attendance">
                                        <ItemTemplate>
                                            <span class='<%# GetAttendanceBadge(Eval("attendancePct")) %>'>
                                                <%# Eval("attendancePct") != DBNull.Value ? Eval("attendancePct").ToString() + "%" : "—" %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <span class='<%# GetEnrolmentBadge(Eval("status").ToString()) %>'>
                                                <%# Eval("status") %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

                <!-- Recent Notifications -->
                <div class="col-md-4">
                    <div class="content-card">
                        <div class="card-header-custom">
                            <h5><i class="fas fa-bell me-2 text-warning"></i>Recent notifications</h5>
                            <a href="StudentNotifications.aspx" class="view-all">View all →</a>
                        </div>
                        <div class="card-body-custom">
                            <asp:Repeater ID="rptNotifications" runat="server">
                                <ItemTemplate>
                                    <div class="notif-item">
                                        <div class='notif-dot <%# GetNotifDot(Eval("notifType").ToString()) %>'></div>
                                        <div>
                                            <div class="notif-title"><%# Eval("title") %></div>
                                            <div class="notif-msg"><%# TruncateMsg(Eval("message").ToString()) %></div>
                                            <div class="notif-time"><%# TimeAgo(Eval("createdAt")) %></div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:Panel ID="pnlNoNotif" runat="server" Visible="false">
                                <div style="text-align:center;padding:20px;color:#bdc3c7;font-size:0.88rem;">
                                    <i class="fas fa-bell-slash" style="font-size:1.5rem;display:block;margin-bottom:8px;"></i>
                                    No new notifications
                                </div>
                            </asp:Panel>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

</form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

