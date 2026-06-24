<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="StudentManagementSystem.AdminDashboard" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin Dashboard - Head of Programme</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; --primary: #2c3e50; --secondary: #3498db; --accent: #e74c3c; --success: #27ae60; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        /* Sidebar */
        .sidebar {
            width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0; display: flex; flex-direction: column;
            background: linear-gradient(180deg, #2c3e50 0%, #34495e 100%);
            color: white; z-index: 1000; transition: all 0.3s; overflow: hidden;
        }
        .sidebar-header {
            padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        .sidebar-header img { width: 70px; height: 70px; border-radius: 50%; margin-bottom: 10px; border: 3px solid rgba(255,255,255,0.3); }
        .sidebar-header h4 { font-size: 1rem; margin-bottom: 3px; }
        .sidebar-header small { color: rgba(255,255,255,0.6); font-size: 0.75rem; }
        .nav-item { padding: 0; }
        .nav-link {
            color: rgba(255,255,255,0.8); padding: 14px 25px; display: flex; align-items: center;
            text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent;
        }
        .nav-link:hover, .nav-link.active {
            background: rgba(255,255,255,0.1); color: white; border-left-color: #3498db;
        }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .nav-link span { font-size: 0.9rem; }
        .sidebar nav { flex: 1 1 auto; overflow-y: auto; }
        .sidebar-footer {
            margin-top: auto; flex-shrink: 0; width: 100%; padding: 15px 25px;
            border-top: 1px solid rgba(255,255,255,0.1);
        }

        /* Main Content */
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
        .user-dropdown img { width: 35px; height: 35px; border-radius: 50%; }
        .user-dropdown span { font-size: 0.9rem; font-weight: 600; color: #2c3e50; }

        /* Dashboard Content */
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
        .stat-icon.blue { background: linear-gradient(135deg, #3498db, #2980b9); }
        .stat-icon.green { background: linear-gradient(135deg, #27ae60, #229954); }
        .stat-icon.orange { background: linear-gradient(135deg, #f39c12, #e67e22); }
        .stat-icon.red { background: linear-gradient(135deg, #e74c3c, #c0392b); }
        .stat-info h3 { font-size: 1.8rem; font-weight: 700; margin: 0; color: #2c3e50; }
        .stat-info p { color: #7f8c8d; margin: 0; font-size: 0.9rem; }
        .stat-trend { font-size: 0.8rem; margin-top: 5px; }
        .stat-trend.up { color: #27ae60; }
        .stat-trend.down { color: #e74c3c; }

        /* Cards */
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

        /* Tables */
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

        /* Progress Bars */
        .progress { height: 8px; border-radius: 10px; background: #e9ecef; }
        .progress-bar { border-radius: 10px; }

        /* Quick Actions */
        .quick-action {
            display: flex; align-items: center; gap: 15px; padding: 15px;
            border-radius: 12px; background: #f8f9fa; margin-bottom: 10px;
            cursor: pointer; transition: all 0.3s; text-decoration: none; color: inherit;
        }
        .quick-action:hover { background: #e9ecef; transform: translateX(5px); }
        .quick-action i { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; font-size: 1rem; }
        .quick-action div h6 { margin: 0; font-size: 0.9rem; font-weight: 600; }
        .quick-action div small { color: #7f8c8d; font-size: 0.75rem; }

        .chart-placeholder {
            height: 300px; background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
            color: #adb5bd; font-size: 1rem;
        }

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
                <div style="width:60px;height:60px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;margin:0 auto 10px;display:flex;align-items:center;justify-content:center;font-size:1.3rem;color:white;">
                    <i class="fas fa-user-shield"></i>
                </div>
                <h4><asp:Label ID="lblUserName" runat="server" Text="Head of Programme"></asp:Label></h4>
                <small><asp:Label ID="lblRoleIdentity" runat="server" Text="Head of Programme"></asp:Label></small>
            </div>

            <nav class="mt-3">
                <div class="nav-item"><a href="AdminDashboard.aspx" class="nav-link active"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
                <div class="nav-item"><a href="ManageProgrammes.aspx" class="nav-link"><i class="fas fa-book"></i><span>Academic Programmes</span></a></div>
                <div class="nav-item"><a href="ManageCourses.aspx" class="nav-link"><i class="fas fa-graduation-cap"></i><span>Courses</span></a></div>
                <div class="nav-item"><a href="ManageUsers.aspx" class="nav-link"><i class="fas fa-users"></i><span>Manage Users</span></a></div>
                <div class="nav-item"><a href="ManageEnrolment.aspx" class="nav-link"><i class="fas fa-clipboard-check"></i><span>Enrolment</span></a></div>
                <div class="nav-item"><a href="StudentStatistics.aspx" class="nav-link"><i class="fas fa-chart-pie"></i><span>Statistics</span></a></div>
                <div class="nav-item"><a href="Announcements.aspx" class="nav-link"><i class="fas fa-bullhorn"></i><span>Announcements</span></a></div>
                <div class="nav-item"><a href="AcademicCalendar.aspx" class="nav-link"><i class="fas fa-calendar-alt"></i><span>Academic Calendar</span></a></div>
            </nav>

            <div class="sidebar-footer">
                <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-link" OnClick="btnLogout_Click" style="padding:10px 0;">
                    <i class="fas fa-sign-out-alt"></i><span>Logout</span>
                </asp:LinkButton>
            </div>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <!-- Topbar -->
            <div class="topbar">
                <h2><i class="fas fa-home me-2 text-primary"></i>Admin Dashboard</h2>
                <div class="topbar-actions">
                    <div class="notification-bell" style="cursor:pointer;" onclick="location.href='Announcements.aspx'" title="View notifications">
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

            <!-- Dashboard Content -->
            <div class="dashboard-content">
                <!-- Head of Programme identity editor -->
                <div class="content-card" style="margin-bottom:25px;">
                    <div class="card-body" style="display:flex;flex-wrap:wrap;align-items:center;gap:12px;">
                        <i class="fas fa-user-shield" style="color:#3498db;font-size:1.2rem;"></i>
                        <label class="form-label" style="margin:0;">Programme:</label>
                        <asp:TextBox ID="txtHeadOf" runat="server" CssClass="form-control" style="max-width:280px;" placeholder="e.g. Computer Science" />
                        <asp:Button ID="btnSaveHeadOf" runat="server" Text="Save" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnSaveHeadOf_Click" />
                        <asp:Label ID="lblHeadOfMsg" runat="server" CssClass="small" />
                    </div>
                </div>

                <!-- Stats Row -->
                <div class="row stats-row">
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon blue"><i class="fas fa-users"></i></div>
                            <div class="stat-info">
                                <h3><asp:Label ID="lblStudents" runat="server" Text="0"></asp:Label></h3>
                                <p>Total Students</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon green"><i class="fas fa-user-tie"></i></div>
                            <div class="stat-info">
                                <h3><asp:Label ID="lblLecturers" runat="server" Text="0"></asp:Label></h3>
                                <p>Total Lecturers</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon orange"><i class="fas fa-book"></i></div>
                            <div class="stat-info">
                                <h3><asp:Label ID="lblCourses" runat="server" Text="0"></asp:Label></h3>
                                <p>Active Courses</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-card">
                            <div class="stat-icon red"><i class="fas fa-clipboard-list"></i></div>
                            <div class="stat-info">
                                <h3><asp:Label ID="lblProgCount" runat="server" Text="0"></asp:Label></h3>
                                <p>Programmes</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Charts & Recent Activity -->
                <div class="row">
                    <div class="col-md-8">
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-chart-line me-2 text-primary"></i>Student Enrolment Statistics</h5>
                                <asp:DropDownList ID="ddlYear" runat="server" CssClass="form-select form-select-sm" style="width:120px;">
                                    <asp:ListItem Text="2024" Value="2024"></asp:ListItem>
                                    <asp:ListItem Text="2023" Value="2023"></asp:ListItem>
                                    <asp:ListItem Text="2022" Value="2022"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="card-body">
                                <div class="chart-placeholder">
                                    <i class="fas fa-chart-bar me-2"></i>Enrolment Chart Placeholder
                                </div>
                            </div>
                        </div>

                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-users me-2 text-primary"></i>Recent Student Enrolments</h5>
                                <asp:Button ID="btnViewAll" runat="server" Text="View All" CssClass="btn btn-outline-primary btn-sm" />
                            </div>
                            <div class="card-body p-0">
                                <table class="table-custom">
                                    <thead>
                                        <tr>
                                            <th>Student ID</th>
                                            <th>Name</th>
                                            <th>Programme</th>
                                            <th>Enrolment Date</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                </table>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-bolt me-2 text-warning"></i>Quick Actions</h5>
                            </div>
                            <div class="card-body">
                                <a href="ManageProgrammes.aspx" class="quick-action">
                                    <i class="fas fa-plus" style="background:#d4edda;color:#155724;"></i>
                                    <div><h6>Add New Programme</h6><small>Create a new academic programme</small></div>
                                </a>
                                <a href="ManageEnrolment.aspx" class="quick-action">
                                    <i class="fas fa-clipboard-check" style="background:#f8d7da;color:#721c24;"></i>
                                    <div><h6>Manage Enrolment</h6><small>Review and approve enrolments</small></div>
                                </a>
                                <a href="AcademicCalendar.aspx" class="quick-action">
                                    <i class="fas fa-calendar-plus" style="background:#e2e3e5;color:#383d41;"></i>
                                    <div><h6>Update Calendar</h6><small>Manage academic calendar</small></div>
                                </a>
                            </div>
                        </div>

                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-bell me-2 text-danger"></i>Recent Announcements</h5>
                            </div>
                            <div class="card-body">
                                <div style="border-left:3px solid #3498db;padding-left:15px;margin-bottom:20px;">
                                    <small style="color:#7f8c8d;">Today, 9:00 AM</small>
                                    <h6 style="margin:5px 0;font-weight:600;">Semester 2 Registration Open</h6>
                                    <p style="font-size:0.85rem;color:#6c757d;margin:0;">Registration for Semester 2 courses is now open until March 15.</p>
                                </div>
                                <div style="border-left:3px solid #e74c3c;padding-left:15px;margin-bottom:20px;">
                                    <small style="color:#7f8c8d;">Yesterday, 2:30 PM</small>
                                    <h6 style="margin:5px 0;font-weight:600;">System Maintenance Notice</h6>
                                    <p style="font-size:0.85rem;color:#6c757d;margin:0;">Scheduled maintenance on Feb 28, 10PM - 2AM.</p>
                                </div>
                                <div style="border-left:3px solid #27ae60;padding-left:15px;">
                                    <small style="color:#7f8c8d;">Feb 20, 2024</small>
                                    <h6 style="margin:5px 0;font-weight:600;">New Faculty Hired</h6>
                                    <p style="font-size:0.85rem;color:#6c757d;margin:0;">Dr. Amanda Lee joins the Computer Science department.</p>
                                </div>
                            </div>
                        </div>

                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-chart-pie me-2 text-success"></i>Performance Summary</h5>
                            </div>
                            <div class="card-body">
                                <div class="mb-3">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span style="font-size:0.85rem;">Pass Rate</span>
                                        <span style="font-size:0.85rem;font-weight:600;">87%</span>
                                    </div>
                                    <div class="progress"><div class="progress-bar bg-success" style="width:87%"></div></div>
                                </div>
                                <div class="mb-3">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span style="font-size:0.85rem;">Attendance Rate</span>
                                        <span style="font-size:0.85rem;font-weight:600;">92%</span>
                                    </div>
                                    <div class="progress"><div class="progress-bar bg-info" style="width:92%"></div></div>
                                </div>
                                <div class="mb-3">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span style="font-size:0.85rem;">Course Completion</span>
                                        <span style="font-size:0.85rem;font-weight:600;">78%</span>
                                    </div>
                                    <div class="progress"><div class="progress-bar bg-warning" style="width:78%"></div></div>
                                </div>
                                <div>
                                    <div class="d-flex justify-content-between mb-1">
                                        <span style="font-size:0.85rem;">Student Satisfaction</span>
                                        <span style="font-size:0.85rem;font-weight:600;">94%</span>
                                    </div>
                                    <div class="progress"><div class="progress-bar bg-success" style="width:94%"></div></div>
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
