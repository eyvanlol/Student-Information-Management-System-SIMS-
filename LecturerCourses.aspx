<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerCourses.aspx.cs" Inherits="StudentManagementSystem.LecturerCourses" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Courses - Lecturer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; --primary: #2c3e50; --secondary: #9b59b6; --accent: #e74c3c; --success: #27ae60; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        .sidebar {
            width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0;
            background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%);
            color: white; z-index: 1000; transition: all 0.3s; overflow-y: auto;
        }
        .sidebar-header {
            padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        .sidebar-avatar {
            width: 70px; height: 70px; border-radius: 50%; margin: 0 auto 10px;
            overflow: hidden; display: flex; align-items: center; justify-content: center;
            background: linear-gradient(135deg, #9b59b6, #8e44ad);
        }
        .sidebar-avatar img {
            width: 70px; height: 70px; object-fit: cover; border-radius: 50%;
            display: block;
        }
        .sidebar-header h4 { font-size: 1rem; margin-bottom: 3px; }
        .sidebar-header small { color: rgba(255,255,255,0.6); font-size: 0.75rem; }
        .nav-item { padding: 0; }
        .nav-link {
            color: rgba(255,255,255,0.8); padding: 14px 25px; display: flex; align-items: center;
            text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent;
        }
        .nav-link:hover, .nav-link.active {
            background: rgba(155, 89, 182, 0.15); color: white; border-left-color: #9b59b6;
        }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .nav-link span { font-size: 0.9rem; }
        .sidebar-footer {
            position: absolute; bottom: 0; width: 100%; padding: 15px 25px;
            border-top: 1px solid rgba(255,255,255,0.1);
        }

        .main-content { margin-left: var(--sidebar-width); padding: 0; min-height: 100vh; }
        .topbar {
            background: white; padding: 15px 30px; display: flex; justify-content: space-between;
            align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 100;
        }
        .topbar h2 { font-size: 1.4rem; color: #2c3e50; margin: 0; }
        .topbar-actions { display: flex; align-items: center; gap: 15px; }
        .user-dropdown {
            display: flex; align-items: center; gap: 10px; cursor: pointer; padding: 8px 15px;
            border-radius: 10px; transition: all 0.3s;
        }
        .user-dropdown:hover { background: #f8f9fa; }
        .user-dropdown span { font-size: 0.9rem; font-weight: 600; color: #2c3e50; }

        .dashboard-content { padding: 30px; }
        .content-card {
            background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05);
            margin-bottom: 25px; overflow: hidden;
        }
        .card-header {
            padding: 20px 25px; border-bottom: 1px solid #f0f0f0;
            display: flex; justify-content: space-between; align-items: center;
        }
        .card-header h5 { margin: 0; font-weight: 700; color: #2c3e50; }
        .card-body { padding: 25px; }

        .course-card {
            background: white; border-radius: 12px; padding: 25px;
            border: 2px solid #f0f0f0; transition: all 0.3s; cursor: pointer;
            margin-bottom: 20px; position: relative; overflow: hidden;
        }
        .course-card:hover {
            border-color: #9b59b6;
            box-shadow: 0 8px 25px rgba(0,0,0,0.08);
            transform: translateY(-3px);
        }
        .course-card::before {
            content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%;
            background: linear-gradient(180deg, #9b59b6, #8e44ad);
        }
        .course-code {
            font-size: 0.75rem; color: #9b59b6; font-weight: 700;
            text-transform: uppercase; letter-spacing: 1px; margin-bottom: 5px;
        }
        .course-title {
            font-weight: 700; color: #2c3e50; margin-bottom: 12px; font-size: 1.1rem;
        }
        .course-meta {
            display: flex; gap: 20px; flex-wrap: wrap;
        }
        .course-meta-item {
            display: flex; align-items: center; gap: 8px;
            font-size: 0.85rem; color: #7f8c8d;
        }
        .course-meta-item i { color: #9b59b6; font-size: 0.9rem; }
        .course-stats {
            display: flex; gap: 15px; margin-top: 15px; padding-top: 15px;
            border-top: 1px solid #f0f0f0;
        }
        .course-stat {
            text-align: center; padding: 8px 15px; background: #f8f9fa;
            border-radius: 8px; min-width: 80px;
        }
        .course-stat .stat-value {
            font-size: 1.2rem; font-weight: 700; color: #2c3e50; display: block;
        }
        .course-stat .stat-label {
            font-size: 0.7rem; color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px;
        }
        .badge-status {
            position: absolute; top: 20px; right: 20px;
            padding: 5px 12px; border-radius: 20px; font-size: 0.7rem; font-weight: 600;
        }
        .badge-active { background: #d4edda; color: #155724; }
        .badge-inactive { background: #f8d7da; color: #721c24; }
        .badge-full { background: #fff3cd; color: #856404; }

        .empty-state {
            text-align: center; padding: 60px 20px;
        }
        .empty-state i {
            font-size: 4rem; color: #dee2e6; margin-bottom: 20px;
        }
        .empty-state h4 { color: #6c757d; margin-bottom: 10px; }
        .empty-state p { color: #adb5bd; }

        .search-box {
            position: relative; max-width: 300px;
        }
        .search-box input {
            border-radius: 10px; border: 2px solid #e0e0e0; padding: 10px 15px 10px 40px;
            font-size: 0.9rem; width: 100%;
        }
        .search-box i {
            position: absolute; left: 15px; top: 50%; transform: translateY(-50%);
            color: #95a5a6;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="sidebar">
            <div class="sidebar-header">
                <div class="sidebar-avatar">
                    <asp:Image ID="imgSidebarAvatar" runat="server" 
                        Width="70" Height="70"
                        ImageUrl="~/Uploads/ProfilePictures/default.png" 
                        AlternateText="Avatar" />
                </div>
                <h4><asp:Label ID="lblUserName" runat="server" Text="Lecturer"></asp:Label></h4>
                <small>Senior Lecturer</small>
            </div>

                <nav class="mt-3">
                    <div class="nav-item"><a href="LecturerDashboard.aspx"    class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
                    <div class="nav-item"><a href="LecturerProfile.aspx"      class="nav-link"><i class="fas fa-user-circle"></i><span>My Profile</span></a></div>
                    <div class="nav-item"><a href="LecturerCourses.aspx"      class="nav-link active"><i class="fas fa-book"></i><span>My Courses</span></a></div>
                    <div class="nav-item"><a href="LecturerAttendance.aspx"   class="nav-link"><i class="fas fa-clipboard-check"></i><span>Attendance</span></a></div>
                    <div class="nav-item"><a href="ManageGrades.aspx"         class="nav-link"><i class="fas fa-clipboard-list"></i><span>Grades & Assessments</span></a></div>
                    <div class="nav-item"><a href="AtRiskStudents.aspx"       class="nav-link"><i class="fas fa-exclamation-triangle"></i><span>At Risk Students</span></a></div>
                    <div class="nav-item"><a href="LecturerStudentProgress.aspx"       class="nav-link"><i class="fas fa-chart-bar"></i><span>Student Progress</span></a></div>
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
                <h2><i class="fas fa-book me-2" style="color:#9b59b6;"></i>My Courses</h2>
                <div class="topbar-actions">
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
                        <h5><i class="fas fa-list me-2" style="color:#9b59b6;"></i>Assigned Courses</h5>
                        <div class="search-box">
                            <i class="fas fa-search"></i>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search courses..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                        </div>
                    </div>
                    <div class="card-body">
                        <asp:Panel ID="pnlCourseList" runat="server">
                            <asp:Repeater ID="rptCourses" runat="server">
                                <ItemTemplate>
                                    <div class="course-card" onclick="window.location='LecturerAttendance.aspx?courseID=<%# Eval("courseID") %>'">
                                        <span class="badge-status badge-<%# Eval("status").ToString().ToLower() %>"><%# Eval("status") %></span>
                                        <div class="course-code"><%# Eval("courseCode") %></div>
                                        <div class="course-title"><%# Eval("courseName") %></div>
                                        <div class="course-meta">
                                            <div class="course-meta-item"><i class="fas fa-graduation-cap"></i><span><%# Eval("programmeName") %></span></div>
                                            <div class="course-meta-item"><i class="fas fa-clock"></i><span><%# Eval("creditHour") %> Credits</span></div>
                                            <div class="course-meta-item"><i class="fas fa-calendar"></i><span>Semester <%# Eval("semester") %></span></div>
                                            <div class="course-meta-item"><i class="fas fa-users"></i><span><%# Eval("enrolledCount") %> / <%# Eval("maxCapacity") %> Students</span></div>
                                        </div>
                                        <div class="course-stats">
                                            <div class="course-stat">
                                                <span class="stat-value"><%# Eval("enrolledCount") %></span>
                                                <span class="stat-label">Enrolled</span>
                                            </div>
                                            <div class="course-stat">
                                                <span class="stat-value"><%# Eval("creditHour") %></span>
                                                <span class="stat-label">Credits</span>
                                            </div>
                                            <div class="course-stat">
                                                <span class="stat-value"><%# Eval("semester") %></span>
                                                <span class="stat-label">Semester</span>
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:Panel>
                        <asp:Panel ID="pnlEmptyCourses" runat="server" CssClass="empty-state" Visible="false">
                            <i class="fas fa-book-open"></i>
                            <h4>No Courses Assigned</h4>
                            <p>You currently have no courses assigned to you.</p>
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>