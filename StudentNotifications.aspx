<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentNotifications.aspx.cs" Inherits="StudentManagementSystem.StudentNotifications" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Notifications - Student</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; --primary: #2c3e50; --secondary: #1abc9c; --accent: #e74c3c; --success: #27ae60; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        .sidebar { width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0;
            background: linear-gradient(180deg, #114f46 0%, #0c2e2a 100%); color: white; z-index: 1000; overflow-y: auto; }
        .sidebar-header { padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-header h4 { font-size: 1rem; margin-bottom: 3px; }
        .sidebar-header small { color: rgba(255,255,255,0.6); font-size: 0.75rem; }
        .nav-item { padding: 0; }
        .nav-link { color: rgba(255,255,255,0.8); padding: 14px 25px; display: flex; align-items: center;
            text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent; }
        .nav-link:hover, .nav-link.active { background: rgba(255,255,255,0.1); color: white; border-left-color: var(--secondary); }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .nav-link span { font-size: 0.9rem; }
        .sidebar-footer { position: absolute; bottom: 0; width: 100%; padding: 15px 25px; border-top: 1px solid rgba(255,255,255,0.1); }

        .main-content { margin-left: var(--sidebar-width); padding: 0; min-height: 100vh; }
        .topbar { background: white; padding: 15px 30px; display: flex; justify-content: space-between;
            align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 100; }
        .topbar h2 { font-size: 1.4rem; color: #2c3e50; margin: 0; }
        .topbar-actions { display: flex; align-items: center; gap: 15px; }
        .notification-bell { position: relative; width: 40px; height: 40px; border-radius: 50%;
            background: #f8f9fa; display: flex; align-items: center; justify-content: center; }
        .notification-bell .badge { position: absolute; top: -2px; right: -2px; background: #e74c3c; color: white;
            font-size: 0.65rem; padding: 3px 6px; border-radius: 10px; }
        .user-dropdown { display: flex; align-items: center; gap: 10px; padding: 8px 15px; border-radius: 10px; }
        .user-dropdown span { font-size: 0.9rem; font-weight: 600; color: #2c3e50; }

        .dashboard-content { padding: 30px; }
        .content-card { background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); margin-bottom: 25px; overflow: hidden; }
        .card-header { padding: 20px 25px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
        .card-header h5 { margin: 0; font-weight: 700; color: #2c3e50; }

        /* Notification rows */
        .notif-list { list-style: none; margin: 0; padding: 0; }
        .notif-row { display: block; text-decoration: none; color: inherit; padding: 18px 25px;
            border-bottom: 1px solid #f0f0f0; transition: background 0.2s; }
        .notif-row:hover { background: #f8f9fa; color: inherit; }
        .notif-unread { background: #eef6ff; }
        .notif-unread:hover { background: #e3f0fd; }
        .notif-dot { width: 12px; height: 12px; border-radius: 50%; display: inline-block; flex: 0 0 12px; margin-top: 5px; }
        .notif-title { font-weight: 700; font-size: 0.95rem; color: #2c3e50; }
        .notif-msg { font-size: 0.85rem; color: #6c757d; margin: 2px 0 0;
            display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
        .notif-time { font-size: 0.72rem; color: #95a5a6; white-space: nowrap; }
        .unread-pill { background: var(--secondary); color: white; font-size: 0.6rem; padding: 2px 7px; border-radius: 10px; margin-left: 8px; vertical-align: middle; }
        .empty-state { text-align: center; padding: 60px 20px; color: #b0b8c1; }
        .empty-state i { font-size: 3rem; margin-bottom: 15px; }

        @media (max-width: 768px) { .sidebar { transform: translateX(-100%); } .main-content { margin-left: 0; } }
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
                <div class="nav-item"><a href="StudentNotifications.aspx" class="nav-link active"><i class="fas fa-bell"></i><span>Notifications</span></a></div>
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
                <h2><i class="fas fa-bell me-2" style="color:#1abc9c;"></i>Notifications</h2>
                <div class="topbar-actions">
                    <div class="notification-bell">
                        <i class="fas fa-bell text-muted"></i>
                        <asp:Label ID="lblBellBadge" runat="server" CssClass="badge" Text="0" />
                    </div>
                    <div style="display:flex;align-items:center;gap:10px;">
                        <div style="width:35px;height:35px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                            <i class="fas fa-user"></i>
                        </div>
                        <span style="font-size:0.9rem;font-weight:600;color:#2c3e50;"><asp:Label ID="lblTopUserName" runat="server" Text=""></asp:Label></span>
                    </div>
                </div>
            </div>

            <div class="dashboard-content">
                <div class="content-card">
                    <div class="card-header">
                        <h5><i class="fas fa-inbox me-2 text-primary"></i>All Notifications
                            <asp:Label ID="lblUnreadCount" runat="server" CssClass="unread-pill" Text="0 unread" /></h5>
                        <asp:LinkButton ID="btnMarkAll" runat="server" CssClass="btn btn-sm btn-outline-secondary"
                            OnClick="btnMarkAll_Click"><i class="fas fa-check-double me-1"></i>Mark all as read</asp:LinkButton>
                    </div>

                    <asp:Repeater ID="rptNotifs" runat="server" OnItemCommand="rptNotifs_ItemCommand">
                        <HeaderTemplate><ul class="notif-list"></HeaderTemplate>
                        <ItemTemplate>
                            <li>
                                <asp:LinkButton runat="server" CssClass='<%# "notif-row " + (Convert.ToBoolean(Eval("isRead")) ? "" : "notif-unread") %>'
                                    CommandName="Read" CommandArgument='<%# Eval("notificationID") %>'>
                                    <div class="d-flex align-items-start gap-3">
                                        <span class="notif-dot" style='<%# "background:" + NotificationHelper.DotColor(Eval("notifType").ToString()) + ";" %>'></span>
                                        <div class="flex-grow-1">
                                            <div class="d-flex justify-content-between align-items-start">
                                                <span class="notif-title">
                                                    <%# Server.HtmlEncode(Eval("title").ToString()) %>
                                                    <%# Convert.ToBoolean(Eval("isRead")) ? "" : "<span class='unread-pill'>NEW</span>" %>
                                                </span>
                                                <span class="notif-time"><%# NotificationHelper.TimeAgo((System.DateTime)Eval("createdAt")) %></span>
                                            </div>
                                            <p class="notif-msg"><%# Server.HtmlEncode(Eval("message").ToString()) %></p>
                                        </div>
                                    </div>
                                </asp:LinkButton>
                            </li>
                        </ItemTemplate>
                        <FooterTemplate></ul></FooterTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
                        <div class="empty-state">
                            <i class="fas fa-bell-slash d-block"></i>
                            You have no notifications yet.
                        </div>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
