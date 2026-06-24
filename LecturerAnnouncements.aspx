<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerAnnouncements.aspx.cs" Inherits="StudentManagementSystem.LecturerAnnouncements" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Announcements - Lecturer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; --primary: #2c3e50; --secondary: #9b59b6; --accent: #e74c3c; --success: #27ae60; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        .sidebar { width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0; display: flex; flex-direction: column;
            background: linear-gradient(180deg, #2c3e50 0%, #34495e 100%); color: white; z-index: 1000; overflow-y: auto; }
        .sidebar-header { padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-header h4 { font-size: 1rem; margin-bottom: 3px; }
        .sidebar-header small { color: rgba(255,255,255,0.6); font-size: 0.75rem; }
        .nav-item { padding: 0; }
        .nav-link { color: rgba(255,255,255,0.8); padding: 14px 25px; display: flex; align-items: center;
            text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent; }
        .nav-link:hover, .nav-link.active { background: rgba(255,255,255,0.1); color: white; border-left-color: var(--secondary); }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .nav-link span { font-size: 0.9rem; }
        .sidebar nav { flex: 1 1 auto; overflow-y: auto; }
        .sidebar-footer { margin-top: auto; flex-shrink: 0; width: 100%; padding: 15px 25px; border-top: 1px solid rgba(255,255,255,0.1); }

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
        .card-body { padding: 25px; }

        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th { background: #f8f9fa; padding: 15px; font-size: 0.8rem; font-weight: 700;
            color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; border: none; }
        .table-custom td { padding: 13px 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.9rem; color: #2c3e50; vertical-align: middle; }
        .table-custom tr:hover td { background: #f8f9fa; }
        .badge-custom { padding: 6px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-purple { background: #ede1f6; color: #6f42c1; }
        .badge-grey { background: #eceff1; color: #607d8b; }

        .form-label { font-weight: 600; font-size: 0.85rem; color: #2c3e50; }
        .req { color: #e74c3c; }
        .btn-post { background: linear-gradient(135deg, #9b59b6 0%, #8e44ad 100%); border: none; border-radius: 10px;
            padding: 12px 30px; font-weight: 600; color: white; }
        .post-icon { width: 80px; height: 80px; background: linear-gradient(135deg, #9b59b6, #8e44ad); border-radius: 50%;
            display: flex; align-items: center; justify-content: center; color: white; font-size: 2rem; margin: 0 auto 20px; }

        @media (max-width: 768px) { .sidebar { transform: translateX(-100%); } .main-content { margin-left: 0; } }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="sidebar">
            <div class="sidebar-header">
                <div style="width:70px;height:70px;background:linear-gradient(135deg,#9b59b6,#8e44ad);border-radius:50%;margin:0 auto 10px;display:flex;align-items:center;justify-content:center;font-size:1.5rem;color:white;">
                    <i class="fas fa-chalkboard-teacher"></i>
                </div>
                <h4><asp:Label ID="lblUserName" runat="server" Text="Lecturer"></asp:Label></h4>
                <small>Lecturer</small>
            </div>
            <nav class="mt-3">
                <div class="nav-item"><a href="LecturerDashboard.aspx" class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
                <div class="nav-item"><a href="LecturerProfile.aspx" class="nav-link"><i class="fas fa-user-circle"></i><span>My Profile</span></a></div>
                <div class="nav-item"><a href="LecturerCourses.aspx" class="nav-link"><i class="fas fa-book"></i><span>My Courses</span></a></div>
                <div class="nav-item"><a href="LecturerAttendance.aspx" class="nav-link"><i class="fas fa-clipboard-check"></i><span>Attendance</span></a></div>
                <div class="nav-item"><a href="ManageGrades.aspx" class="nav-link"><i class="fas fa-clipboard-list"></i><span>Grades & Assessments</span></a></div>
                <div class="nav-item"><a href="LecturerAnnouncements.aspx" class="nav-link active"><i class="fas fa-bullhorn"></i><span>Announcements</span></a></div>
            </nav>
            <div class="sidebar-footer">
                <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-link" OnClick="btnLogout_Click" style="padding:10px 0;">
                    <i class="fas fa-sign-out-alt"></i><span>Logout</span>
                </asp:LinkButton>
            </div>
        </div>

        <div class="main-content">
            <div class="topbar">
                <h2><i class="fas fa-bullhorn me-2" style="color:#9b59b6;"></i>Announcements</h2>
                <div class="topbar-actions">
                    <div class="notification-bell" style="cursor:pointer;" onclick="location.href='LecturerAnnouncements.aspx'" title="View notifications"><i class="fas fa-bell text-muted"></i></div>
                    <div style="display:flex;align-items:center;gap:10px;">
                        <div style="width:35px;height:35px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                            <i class="fas fa-user"></i>
                        </div>
                        <span style="font-size:0.9rem;font-weight:600;color:#2c3e50;"><asp:Label ID="lblTopUserName" runat="server" Text=""></asp:Label></span>
                    </div>
                </div>
            </div>

            <div class="dashboard-content">
                <asp:Panel ID="pnlMsg" runat="server" Visible="false" CssClass="mb-4">
                    <div id="divMsg" runat="server" class="alert" role="alert">
                        <asp:Literal ID="litMsg" runat="server" />
                    </div>
                </asp:Panel>

                <div class="row">
                    <!-- Past announcements -->
                    <div class="col-lg-8">
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-history me-2 text-primary"></i>My Past Announcements</h5>
                                <span class="badge-custom badge-purple"><asp:Label ID="lblHistoryCount" runat="server" Text="0" /> posted</span>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="false" CssClass="table-custom"
                                        GridLines="None" Width="100%" EmptyDataText="You haven't posted any announcements yet.">
                                        <Columns>
                                            <asp:TemplateField HeaderText="Announcement">
                                                <ItemTemplate>
                                                    <div style="font-weight:600;"><%# Server.HtmlEncode(Eval("title").ToString()) %></div>
                                                    <small style="color:#6c757d;"><%# Trim(Eval("message")) %></small>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Course">
                                                <ItemTemplate><span class="badge-custom badge-grey"><%# FmtCourse(Eval("courseName")) %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Date Posted">
                                                <ItemTemplate><%# Convert.ToDateTime(Eval("createdAt")).ToString("dd MMM yyyy, h:mm tt") %></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Recipients" ItemStyle-Width="110px">
                                                <ItemTemplate>
                                                    <span class="badge-custom badge-purple"><i class="fas fa-users me-1"></i><%# Eval("recipientCount") %></span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Post form -->
                    <div class="col-lg-4">
                        <div class="content-card">
                            <div class="card-body text-center">
                                <div class="post-icon"><i class="fas fa-bullhorn"></i></div>
                                <h5 class="mb-4">Post Announcement</h5>
                                <div class="text-start">
                                    <div class="mb-3">
                                        <label class="form-label">Course <span class="req">*</span></label>
                                        <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-select" />
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Title <span class="req">*</span></label>
                                        <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="e.g. Assignment 1 posted" />
                                        <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle"
                                            ValidationGroup="ann" CssClass="text-danger small" Display="Dynamic" ErrorMessage="Title is required." />
                                    </div>
                                    <div class="mb-4">
                                        <label class="form-label">Message <span class="req">*</span></label>
                                        <asp:TextBox ID="txtMessage" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="5" placeholder="Write your announcement..." />
                                        <asp:RequiredFieldValidator ID="rfvMessage" runat="server" ControlToValidate="txtMessage"
                                            ValidationGroup="ann" CssClass="text-danger small" Display="Dynamic" ErrorMessage="Message is required." />
                                    </div>
                                    <div class="d-grid gap-2">
                                        <asp:Button ID="btnPost" runat="server" Text="Post Announcement" CssClass="btn btn-post"
                                            ValidationGroup="ann" OnClick="btnPost_Click" />
                                        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-outline-secondary"
                                            CausesValidation="false" OnClick="btnClear_Click" />
                                    </div>
                                </div>
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
