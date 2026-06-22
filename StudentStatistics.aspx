<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentStatistics.aspx.cs" Inherits="StudentManagementSystem.StudentStatistics" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Student Statistics - Admin</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />

    <style>
        :root { --sidebar-width: 260px; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

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
            text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent; font-size: 0.9rem;
        }

        .nav-link:hover, .nav-link.active {
            background: rgba(255,255,255,0.1); color: white; border-left-color: #3498db;
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

        .user-dropdown span {
            font-size: 0.9rem; font-weight: 600; color: #2c3e50;
        }

        .page-content { padding: 30px; }

        .content-card {
            background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05);
            margin-bottom: 25px; overflow: hidden;
        }

        .card-header-custom {
            padding: 20px 25px; border-bottom: 1px solid #f0f0f0;
            display: flex; justify-content: space-between; align-items: center;
        }

        .card-header-custom h5 {
            margin: 0; font-weight: 700; color: #2c3e50;
        }

        .card-body-custom { padding: 25px; }

        canvas { max-height: 320px; }

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
            <div style="width:60px;height:60px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;margin:0 auto 10px;display:flex;align-items:center;justify-content:center;font-size:1.3rem;color:white;">
                <i class="fas fa-user-shield"></i>
            </div>
            <h4><asp:Label ID="lblUserName" runat="server" Text="Head of Programme"></asp:Label></h4>
            <small>Administrator</small>
        </div>

        <nav class="mt-3">
            <div class="nav-item"><a href="AdminDashboard.aspx" class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
            <div class="nav-item"><a href="ManageUsers.aspx" class="nav-link"><i class="fas fa-users"></i><span>Manage Users</span></a></div>
            <div class="nav-item"><a href="ManageProgrammes.aspx" class="nav-link"><i class="fas fa-book"></i><span>Manage Programmes</span></a></div>
            <div class="nav-item"><a href="ManageCourses.aspx" class="nav-link"><i class="fas fa-graduation-cap"></i><span>Manage Courses</span></a></div>
            <div class="nav-item"><a href="ManageEnrolment.aspx" class="nav-link"><i class="fas fa-clipboard-check"></i><span>Manage Enrolment</span></a></div>
            <div class="nav-item"><a href="StudentStatistics.aspx" class="nav-link active"><i class="fas fa-chart-bar"></i><span>Student Statistics</span></a></div>
            <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-file-export"></i><span>Reports</span></a></div>
            <div class="nav-item"><a href="AcademicCalendar.aspx" class="nav-link"><i class="fas fa-calendar-alt"></i><span>Academic Calendar</span></a></div>
            <div class="nav-item"><a href="Announcements.aspx" class="nav-link"><i class="fas fa-bullhorn"></i><span>Announcements</span></a></div>
        </nav>

        <div class="sidebar-footer">
            <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-link" OnClick="btnLogout_Click" style="padding:10px 0;">
                <i class="fas fa-sign-out-alt"></i><span>Logout</span>
            </asp:LinkButton>
        </div>
    </div>

    <div class="main-content">
        <div class="topbar">
            <h2>
                <i class="fas fa-chart-bar me-2 text-primary"></i>
                Student Statistics
            </h2>

            <div class="topbar-actions">
                <div class="notification-bell">
                    <i class="fas fa-bell text-muted"></i>
                    <span class="badge">5</span>
                </div>

                <div class="user-dropdown">
                    <div style="width:35px;height:35px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                        <i class="fas fa-user-shield"></i>
                    </div>

                    <span>
                        <asp:Label ID="lblTopUserName" runat="server" Text="Head of Programme"></asp:Label>
                    </span>

                    <i class="fas fa-chevron-down text-muted" style="font-size:0.7rem;"></i>
                </div>
            </div>
        </div>

        <div class="page-content">
            <div class="row">

                <div class="col-md-6">
                    <div class="content-card">
                        <div class="card-header-custom">
                            <h5>
                                <i class="fas fa-chart-bar me-2 text-primary"></i>
                                GPA / Grade Distribution
                            </h5>
                        </div>

                        <div class="card-body-custom">
                            <canvas id="gpaChart"></canvas>
                        </div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="content-card">
                        <div class="card-header-custom">
                            <h5>
                                <i class="fas fa-calendar-check me-2 text-success"></i>
                                Attendance Overview
                            </h5>
                        </div>

                        <div class="card-body-custom">
                            <canvas id="attendanceChart"></canvas>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <asp:HiddenField ID="hiddenGpaLabels" runat="server" />
    <asp:HiddenField ID="hiddenGpaData" runat="server" />
    <asp:HiddenField ID="hiddenAttendanceLabels" runat="server" />
    <asp:HiddenField ID="hiddenAttendanceData" runat="server" />

</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<script>
    const gpaLabels = JSON.parse(document.getElementById('<%= hiddenGpaLabels.ClientID %>').value || "[]");
    const gpaData = JSON.parse(document.getElementById('<%= hiddenGpaData.ClientID %>').value || "[]");

    new Chart(document.getElementById('gpaChart'), {
        type: 'bar',
        data: {
            labels: gpaLabels,
            datasets: [{
                label: 'Number of Students',
                data: gpaData
            }]
        }
    });

    const attLabels = JSON.parse(document.getElementById('<%= hiddenAttendanceLabels.ClientID %>').value || "[]");
    const attData = JSON.parse(document.getElementById('<%= hiddenAttendanceData.ClientID %>').value || "[]");

    new Chart(document.getElementById('attendanceChart'), {
        type: 'bar',
        data: {
            labels: attLabels,
            datasets: [{
                label: 'Attendance %',
                data: attData
            }]
        }
    });
</script>

</body>
</html>
