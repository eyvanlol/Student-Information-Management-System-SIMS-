<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerDashboard.aspx.cs" Inherits="StudentManagementSystem.LecturerDashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Lecturer Dashboard</title>
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
        .sidebar-header .logo {
            width: 70px; height: 70px; background: linear-gradient(135deg, #9b59b6, #8e44ad);
            border-radius: 50%; margin: 0 auto 10px; display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem; color: white;
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

        .dashboard-content { padding: 30px; }
        .stats-row { margin-bottom: 30px; }
        .stat-card {
            background: white; border-radius: 15px; padding: 25px; box-shadow: 0 5px 20px rgba(0,0,0,0.05);
            display: flex; align-items: center; gap: 20px; transition: transform 0.3s;
        }
        .stat-card:hover { transform: translateY(-5px); }
        .stat-icon {
            width: 60px; height: 60px; border-radius: 15px; display: flex;
            align-items: center; justify-content: center; font-size: 1.5rem; color: white;
        }
        .stat-icon.purple { background: linear-gradient(135deg, #9b59b6, #8e44ad); }
        .stat-icon.blue { background: linear-gradient(135deg, #3498db, #2980b9); }
        .stat-icon.orange { background: linear-gradient(135deg, #f39c12, #e67e22); }
        .stat-icon.red { background: linear-gradient(135deg, #e74c3c, #c0392b); }
        .stat-info h3 { font-size: 1.8rem; font-weight: 700; margin: 0; color: #2c3e50; }
        .stat-info p { color: #7f8c8d; margin: 0; font-size: 0.9rem; }

        .content-card {
            background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05);
            margin-bottom: 25px; overflow: hidden;
        }
        .card-header {
            padding: 20px 25px; border-bottom: 1px solid #f0f0f0;
            display: flex; justify-content: space-between; align-items: center;
        }
        .card-header h5 { margin: 0; font-weight: 700; color: #2c3e50; }
        .card-header .btn-sm {
            padding: 6px 15px; border-radius: 8px; font-size: 0.8rem; font-weight: 600;
        }
        .card-body { padding: 25px; }

        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th {
            background: #f8f9fa; padding: 15px; font-size: 0.8rem; font-weight: 700;
            color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; border: none;
        }
        .table-custom td {
            padding: 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.9rem; color: #2c3e50;
        }
        .table-custom tr:hover td { background: #f8f9fa; }

        .badge-custom {
            padding: 6px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;
        }
        .badge-success { background: #d4edda; color: #155724; }
        .badge-warning { background: #fff3cd; color: #856404; }
        .badge-danger { background: #f8d7da; color: #721c24; }
        .badge-info { background: #d1ecf1; color: #0c5460; }

        .grade-a { background: #d4edda; color: #155724; padding: 5px 15px; border-radius: 8px; font-weight: 700; }
        .grade-b { background: #d1ecf1; color: #0c5460; padding: 5px 15px; border-radius: 8px; font-weight: 700; }
        .grade-c { background: #fff3cd; color: #856404; padding: 5px 15px; border-radius: 8px; font-weight: 700; }
        .grade-d { background: #f8d7da; color: #721c24; padding: 5px 15px; border-radius: 8px; font-weight: 700; }

        .course-card {
            background: white; border-radius: 12px; padding: 20px; border: 2px solid #f0f0f0;
            transition: all 0.3s; cursor: pointer; margin-bottom: 15px;
        }
        .course-card:hover { border-color: #9b59b6; box-shadow: 0 5px 15px rgba(0,0,0,0.08); }
        .course-card .course-code { font-size: 0.75rem; color: #9b59b6; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 5px; }
        .course-card .course-title { font-weight: 700; color: #2c3e50; margin-bottom: 8px; font-size: 1rem; }
        .course-card .course-meta { display: flex; justify-content: space-between; font-size: 0.8rem; color: #7f8c8d; }

        .alert-student {
            background: linear-gradient(135deg, rgba(231, 76, 60, 0.08), rgba(231, 76, 60, 0.03));
            border-left: 4px solid #e74c3c; border-radius: 0 12px 12px 0; padding: 15px; margin-bottom: 15px;
        }
        .alert-student .alert-title { font-weight: 700; color: #e74c3c; font-size: 0.9rem; margin-bottom: 5px; }
        .alert-student .alert-text { font-size: 0.85rem; color: #555; }

        .attendance-bar-container { display: flex; align-items: flex-end; gap: 8px; height: 150px; padding: 20px 0; }
        .attendance-bar {
            flex: 1; background: linear-gradient(to top, #9b59b6, #bb8fce);
            border-radius: 6px 6px 0 0; min-height: 20px; position: relative; transition: all 0.3s;
        }
        .attendance-bar:hover { opacity: 0.8; }
        .attendance-bar .bar-label { position: absolute; bottom: -25px; left: 50%; transform: translateX(-50%); font-size: 0.7rem; color: #7f8c8d; white-space: nowrap; }
        .attendance-bar .bar-value { position: absolute; top: -20px; left: 50%; transform: translateX(-50%); font-size: 0.75rem; font-weight: 700; color: #9b59b6; }

        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .main-content { margin-left: 0; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        
        <div class="sidebar">
            <div class="sidebar-header">
                <div class="logo"><i class="fas fa-chalkboard-teacher"></i></div>
                <h4><asp:Label ID="lblUserName" runat="server" Text="Lecturer"></asp:Label></h4>
                <small><asp:Label ID="lblRoleIdentity" runat="server" Text="Lecturer"></asp:Label></small>
            </div>

            <nav class="mt-3">
                <div class="nav-item"><a href="LecturerDashboard.aspx" class="nav-link active"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
                <div class="nav-item"><a href="LecturerProfile.aspx" class="nav-link"><i class="fas fa-user-circle"></i><span>My Profile</span></a></div>
                <div class="nav-item"><a href="LecturerCourses.aspx" class="nav-link"><i class="fas fa-book"></i><span>My Courses</span></a></div>
                <div class="nav-item"><a href="LecturerAttendance.aspx" class="nav-link"><i class="fas fa-clipboard-check"></i><span>Attendance</span></a></div>
                <div class="nav-item"><a href="ManageGrades.aspx" class="nav-link"><i class="fas fa-clipboard-list"></i><span>Grades & Assessments</span></a></div>
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
                <h2><i class="fas fa-home me-2" style="color:#9b59b6;"></i>Lecturer Dashboard</h2>
                <div class="topbar-actions">
                    <div class="notification-bell"><i class="fas fa-bell text-muted"></i><span class="badge">3</span></div>
                    <div style="display:flex;align-items:center;gap:10px;">
                        <div style="width:35px;height:35px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                            <i class="fas fa-user"></i>
                        </div>
                        <span style="font-size:0.9rem;font-weight:600;color:#2c3e50;"><asp:Label ID="lblTopUserName" runat="server" Text=""></asp:Label></span>
                    </div>
                </div>
            </div>

            <div class="dashboard-content">
                
                <div class="row stats-row">
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon purple"><i class="fas fa-book"></i></div>
                            <div class="stat-info">
                                <h3>4</h3>
                                <p>Assigned Courses</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon blue"><i class="fas fa-users"></i></div>
                            <div class="stat-info">
                                <h3>156</h3>
                                <p>Registered Students</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon orange"><i class="fas fa-clipboard-check"></i></div>
                            <div class="stat-info">
                                <h3>92%</h3>
                                <p>Avg. Attendance</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon red"><i class="fas fa-exclamation-triangle"></i></div>
                            <div class="stat-info">
                                <h3>8</h3>
                                <p>At-Risk Students</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-8">
                        
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-book me-2" style="color:#9b59b6;"></i>My Courses</h5>
                                <asp:Button ID="btnManageCourses" runat="server" Text="Manage Courses" CssClass="btn btn-outline-primary btn-sm" />
                            </div>
                            <div class="card-body">
                                <div class="course-card">
                                    <div class="course-code">DCS101 - Introduction to AI</div>
                                    <div class="course-title">Introduction to AI</div>
                                    <div class="course-meta">
                                        <span><i class="fas fa-users me-1"></i>45 Students</span>
                                        <span><i class="fas fa-clock me-1"></i>Mon & Wed, 9:00 AM</span>
                                        <span><i class="fas fa-map-marker-alt me-1"></i>Room 302</span>
                                    </div>
                                </div>
                                <div class="course-card">
                                    <div class="course-code">DCS205 - Software Engineering</div>
                                    <div class="course-title">Software Engineering Principles</div>
                                    <div class="course-meta">
                                        <span><i class="fas fa-users me-1"></i>31 Students</span>
                                        <span><i class="fas fa-clock me-1"></i>Fri, 9:00 AM - 12:00 PM</span>
                                        <span><i class="fas fa-map-marker-alt me-1"></i>Room 501</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-edit me-2" style="color:#9b59b6;"></i>Recent Grade Entries</h5>
                                <asp:Button ID="btnEnterGrades" runat="server" Text="Enter Grades" CssClass="btn btn-outline-primary btn-sm" />
                            </div>
                            <div class="card-body p-0">
                                <table class="table-custom">
                                    <thead>
                                        <tr><th>Student</th><th>Course</th><th>Assessment</th><th>Grade</th><th>Date</th></tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td><div style="display:flex;align-items:center;gap:10px;"><div style="width:32px;height:32px;background:#3498db;border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.7rem;">JW</div>Lorens</div></td>
                                            <td>DCS101</td>
                                            <td>Mid-Term Exam</td>
                                            <td><span class="grade-a">A</span></td>
                                            <td>June 15, 2026</td>
                                        </tr>
                                        <tr>
                                            <td><div style="display:flex;align-items:center;gap:10px;"><div style="width:32px;height:32px;background:#e74c3c;border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.7rem;">ET</div>Retcheal</div></td>
                                            <td>DCS205</td>
                                            <td>Assignment 2</td>
                                            <td><span class="grade-b">B+</span></td>
                                            <td>May 14, 2026</td>
                                        </tr>
                                        <tr>
                                            <td><div style="display:flex;align-items:center;gap:10px;"><div style="width:32px;height:32px;background:#27ae60;border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.7rem;">MC</div>Eyvan</div></td>
                                            <td>DCS101</td>
                                            <td>Quiz 3</td>
                                            <td><span class="grade-c">C</span></td>
                                            <td>June 13, 2026</td>
                                        </tr>
                                </table>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4">
                        
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-exclamation-triangle me-2 text-danger"></i>At-Risk Students</h5>
                            </div>
                            <div class="card-body">
                                <div class="alert-student">
                                    <div class="alert-title"><i class="fas fa-user me-1"></i> Lorens</div>
                                    <div class="alert-text">Attendance: 45% | Current Grade: D</div>
                                </div>
                                <div class="alert-student">
                                    <div class="alert-title"><i class="fas fa-user me-1"></i> Retcheal</div>
                                    <div class="alert-text">Attendance: 55% | Current Grade: C</div>
                                </div>
                                <div class="alert-student">
                                    <div class="alert-title"><i class="fas fa-user me-1"></i> Eyvan</div>
                                    <div class="alert-text">Attendance: 60% | Current Grade: D+</div>
                                </div>
                            </div>
                        </div>

                        
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-chart-bar me-2" style="color:#9b59b6;"></i>Weekly Attendance</h5>
                            </div>
                            <div class="card-body">
                                <div class="attendance-bar-container">
                                    <div class="attendance-bar" style="height:85%;"><span class="bar-value">85%</span><span class="bar-label">Mon</span></div>
                                    <div class="attendance-bar" style="height:92%;"><span class="bar-value">92%</span><span class="bar-label">Tue</span></div>
                                    <div class="attendance-bar" style="height:78%;"><span class="bar-value">78%</span><span class="bar-label">Wed</span></div>
                                    <div class="attendance-bar" style="height:88%;"><span class="bar-value">88%</span><span class="bar-label">Thu</span></div>
                                    <div class="attendance-bar" style="height:95%;"><span class="bar-value">95%</span><span class="bar-label">Fri</span></div>
                                </div>
                            </div>
                        </div>

                        
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-bolt me-2 text-warning"></i>Quick Actions</h5>
                            </div>
                            <div class="card-body">
                                <div style="display:flex;flex-direction:column;gap:10px;">
                                    <asp:Button ID="btnTakeAttendance" runat="server" Text="Take Attendance" CssClass="btn btn-primary w-100" style="background:#9b59b6;border:none;border-radius:10px;padding:12px;" />
                                    <asp:Button ID="btnPostMaterial" runat="server" Text="Post Course Material" CssClass="btn btn-outline-primary w-100" style="border-radius:10px;padding:12px;" />
                                    <asp:Button ID="btnSendAnnouncement" runat="server" Text="Send Announcement" CssClass="btn btn-outline-primary w-100" style="border-radius:10px;padding:12px;" />
                                    <asp:Button ID="btnViewProgress" runat="server" Text="View Student Progress" CssClass="btn btn-outline-primary w-100" style="border-radius:10px;padding:12px;" />
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
