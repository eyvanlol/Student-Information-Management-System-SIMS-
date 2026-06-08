<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentDashboard.aspx.cs" Inherits="StudentManagementSystem.StudentDashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Student Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; --primary: #2c3e50; --secondary: #1abc9c; --accent: #e74c3c; --success: #27ae60; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        .sidebar {
            width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0;
            background: linear-gradient(180deg, #0f3460 0%, #16213e 100%);
            color: white; z-index: 1000; transition: all 0.3s; overflow-y: auto;
        }
        .sidebar-header {
            padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        .sidebar-header .logo {
            width: 70px; height: 70px; background: linear-gradient(135deg, #1abc9c, #16a085);
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
            background: rgba(26, 188, 156, 0.15); color: white; border-left-color: #1abc9c;
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
        .stat-icon.teal { background: linear-gradient(135deg, #1abc9c, #16a085); }
        .stat-icon.blue { background: linear-gradient(135deg, #3498db, #2980b9); }
        .stat-icon.orange { background: linear-gradient(135deg, #f39c12, #e67e22); }
        .stat-icon.purple { background: linear-gradient(135deg, #9b59b6, #8e44ad); }
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
        .course-card:hover { border-color: #1abc9c; box-shadow: 0 5px 15px rgba(0,0,0,0.08); }
        .course-card .course-code { font-size: 0.75rem; color: #1abc9c; font-weight: 700; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 5px; }
        .course-card .course-title { font-weight: 700; color: #2c3e50; margin-bottom: 8px; font-size: 1rem; }
        .course-card .course-meta { display: flex; justify-content: space-between; font-size: 0.8rem; color: #7f8c8d; }
        .course-card .course-grade { margin-top: 10px; padding-top: 10px; border-top: 1px solid #f0f0f0; }

        .notification-item {
            padding: 15px; border-radius: 10px; margin-bottom: 10px; transition: all 0.3s;
        }
        .notification-item:hover { background: #f8f9fa; }
        .notification-item .notif-icon {
            width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; margin-right: 15px;
        }
        .notification-item .notif-title { font-weight: 600; font-size: 0.9rem; margin-bottom: 3px; }
        .notification-item .notif-text { font-size: 0.8rem; color: #6c757d; }
        .notification-item .notif-time { font-size: 0.75rem; color: #adb5bd; }

        .gpa-circle {
            width: 120px; height: 120px; border-radius: 50%;
            background: conic-gradient(#1abc9c 0% 85%, #e9ecef 85% 100%);
            display: flex; align-items: center; justify-content: center; margin: 0 auto 15px;
        }
        .gpa-circle-inner {
            width: 100px; height: 100px; border-radius: 50%; background: white;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
        }
        .gpa-circle-inner h3 { margin: 0; font-size: 1.8rem; font-weight: 700; color: #1abc9c; }
        .gpa-circle-inner small { font-size: 0.7rem; color: #6c757d; }

        .progress { height: 8px; border-radius: 10px; background: #e9ecef; }
        .progress-bar { border-radius: 10px; }

        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .main-content { margin-left: 0; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-header">
                <div class="logo"><i class="fas fa-user-graduate"></i></div>
                <h4><asp:Label ID="lblUserName" runat="server" Text="John Smith"></asp:Label></h4>
                <small>Student ID: STU2024001</small>
            </div>

            <nav class="mt-3">
                <div class="nav-item"><a href="StudentDashboard.aspx" class="nav-link active"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
                <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-user-circle"></i><span>My Profile</span></a></div>
                <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-book"></i><span>My Courses</span></a></div>
                <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-plus-circle"></i><span>Course Registration</span></a></div>
                <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-clipboard-check"></i><span>Attendance</span></a></div>
                <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-chart-line"></i><span>Academic Results</span></a></div>
                <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-history"></i><span>Academic History</span></a></div>
                <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-bell"></i><span>Notifications</span></a></div>
                <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-cog"></i><span>Settings</span></a></div>
            </nav>

            <div class="sidebar-footer">
                <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-link" OnClick="btnLogout_Click" style="padding:10px 0;">
                    <i class="fas fa-sign-out-alt"></i><span>Logout</span>
                </asp:LinkButton>
            </div>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <div class="topbar">
                <h2><i class="fas fa-home me-2" style="color:#1abc9c;"></i>Student Dashboard</h2>
                <div class="topbar-actions">
                    <div class="notification-bell"><i class="fas fa-bell text-muted"></i><span class="badge">4</span></div>
                    <div class="user-dropdown">
                        <div style="width:35px;height:35px;background:linear-gradient(135deg,#1abc9c,#16a085);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                            <i class="fas fa-user-graduate"></i>
                        </div>
                        <span><asp:Label ID="lblTopUserName" runat="server" Text="Eyvan"></asp:Label></span>
                        <i class="fas fa-chevron-down text-muted" style="font-size:0.7rem;"></i>
                    </div>
                </div>
            </div>

            <div class="dashboard-content">
                
                <div class="row stats-row">
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon teal"><i class="fas fa-book"></i></div>
                            <div class="stat-info">
                                <h3>5</h3>
                                <p>Enrolled Courses</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon blue"><i class="fas fa-award"></i></div>
                            <div class="stat-info">
                                <h3>3.85</h3>
                                <p>Current GPA</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon orange"><i class="fas fa-clipboard-check"></i></div>
                            <div class="stat-info">
                                <h3>94%</h3>
                                <p>Attendance Rate</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon purple"><i class="fas fa-coins"></i></div>
                            <div class="stat-info">
                                <h3>18</h3>
                                <p>Credits Earned</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-8">
                        
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-book me-2" style="color:#1abc9c;"></i>My Courses</h5>
                                <asp:Button ID="btnRegisterCourse" runat="server" Text="Register/Drop" CssClass="btn btn-outline-primary btn-sm" />
                            </div>
                            <div class="card-body">
                                <div class="course-card">
                                    <div class="course-code">CS101 - Introduction to AI</div>
                                    <div class="course-title">Introduction to AI</div>
                                    <div class="course-meta">
                                        <span><i class="fas fa-chalkboard-teacher me-1"></i>Ms. Vasuky</span>
                                        <span><i class="fas fa-clock me-1"></i>Mon & Wed, 9:00 AM</span>
                                    </div>
                                    <div class="course-grade">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span style="font-size:0.85rem;color:#6c757d;">Current Grade</span>
                                            <span class="grade-a">A</span>
                                        </div>
                                    </div>
                                </div>
                                <div class="course-card">
                                    <div class="course-code">MAT201 - Calculus II</div>
                                    <div class="course-title">Calculus II</div>
                                    <div class="course-meta">
                                        <span><i class="fas fa-chalkboard-teacher me-1"></i>Dr. Ace</span>
                                        <span><i class="fas fa-clock me-1"></i>Tue & Thu, 10:00 AM</span>
                                    </div>
                                    <div class="course-grade">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <span style="font-size:0.85rem;color:#6c757d;">Current Grade</span>
                                            <span class="grade-b">B+</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-chart-line me-2" style="color:#1abc9c;"></i>Recent Results</h5>
                                <asp:Button ID="btnViewAllResults" runat="server" Text="View All" CssClass="btn btn-outline-primary btn-sm" />
                            </div>
                            <div class="card-body p-0">
                                <table class="table-custom">
                                    <thead>
                                        <tr><th>Course</th><th>Assessment</th><th>Score</th><th>Grade</th><th>Date</th></tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td><strong>DCS101</strong></td>
                                            <td>Mid-Term Exam</td>
                                            <td>88/100</td>
                                            <td><span class="grade-a">A</span></td>
                                            <td>June 15, 2024</td>
                                        </tr>
                                        <tr>
                                            <td><strong>MAT201</strong></td>
                                            <td>Quiz 3</td>
                                            <td>75/100</td>
                                            <td><span class="grade-b">B</span></td>
                                            <td>June 14, 2024</td>
                                        </tr>
                                        <tr>
                                            <td><strong>DCS101</strong></td>
                                            <td>Assignment 2</td>
                                            <td>95/100</td>
                                            <td><span class="grade-a">A+</span></td>
                                            <td>June 08, 2026</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4">
                        
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-award me-2" style="color:#1abc9c;"></i>GPA Overview</h5>
                            </div>
                            <div class="card-body text-center">
                                <div class="gpa-circle">
                                    <div class="gpa-circle-inner">
                                        <h3>3.85</h3>
                                        <small>CUMULATIVE GPA</small>
                                    </div>
                                </div>
                                <div class="row text-center mt-3">
                                    <div class="col-4">
                                        <h5 style="color:#1abc9c;font-weight:700;">18</h5>
                                        <small style="color:#6c757d;">Credits</small>
                                    </div>
                                    <div class="col-4">
                                        <h5 style="color:#3498db;font-weight:700;">5</h5>
                                        <small style="color:#6c757d;">Courses</small>
                                    </div>
                                    <div class="col-4">
                                        <h5 style="color:#f39c12;font-weight:700;">2nd</h5>
                                        <small style="color:#6c757d;">Year</small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-clipboard-check me-2" style="color:#1abc9c;"></i>Attendance Summary</h5>
                            </div>
                            <div class="card-body">
                                <div class="mb-3">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span style="font-size:0.85rem;">DCS101</span>
                                        <span style="font-size:0.85rem;font-weight:600;">96%</span>
                                    </div>
                                    <div class="progress"><div class="progress-bar bg-success" style="width:96%"></div></div>
                                </div>
                                <div class="mb-3">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span style="font-size:0.85rem;">MAT201</span>
                                        <span style="font-size:0.85rem;font-weight:600;">88%</span>
                                    </div>
                                    <div class="progress"><div class="progress-bar bg-info" style="width:88%"></div></div>
                                </div>
                                <div>
                                    <div class="d-flex justify-content-between mb-1">
                                        <span style="font-size:0.85rem;">DCS205</span>
                                        <span style="font-size:0.85rem;font-weight:600;">94%</span>
                                    </div>
                                    <div class="progress"><div class="progress-bar bg-success" style="width:94%"></div></div>
                                </div>
                            </div>
                        </div>

                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-bell me-2 text-danger"></i>Notifications</h5>
                            </div>
                            <div class="card-body">
                                <div class="notification-item">
                                    <div class="d-flex">
                                        <div class="notif-icon" style="background:#d4edda;color:#155724;"><i class="fas fa-graduation-cap"></i></div>
                                        <div style="flex:1;">
                                            <div class="notif-title">Grade Published</div>
                                            <div class="notif-text">DCS101 Mid-Term results are now available.</div>
                                            <div class="notif-time"><i class="far fa-clock me-1"></i>2 hours ago</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="notification-item">
                                    <div class="d-flex">
                                        <div class="notif-icon" style="background:#fff3cd;color:#856404;"><i class="fas fa-calendar"></i></div>
                                        <div style="flex:1;">
                                            <div class="notif-title">Exam Schedule Updated</div>
                                            <div class="notif-text">Final exam dates have been announced.</div>
                                            <div class="notif-time"><i class="far fa-clock me-1"></i>5 hours ago</div>
                                        </div>
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
