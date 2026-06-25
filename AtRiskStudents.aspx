<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AtRiskStudents.aspx.cs" Inherits="StudentManagementSystem.AtRiskStudents" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>At-Risk Students</title>

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

        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th {
            background: #f8f9fa; padding: 15px; font-size: 0.8rem; font-weight: 700;
            color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; border: none;
        }
        .table-custom td {
            padding: 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.9rem; color: #2c3e50; vertical-align: middle;
        }
        .table-custom tr:hover td { background: #f8f9fa; }

        .attendance-badge {
            padding: 6px 12px; border-radius: 20px; font-weight: bold; font-size: 0.85rem;
            background: #f8d7da; color: #721c24; /* Red for at-risk */
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
                <small>Lecturer</small>
            </div>

         <nav class="mt-3">
            <div class="nav-item"><a href="LecturerDashboard.aspx"    class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
            <div class="nav-item"><a href="LecturerProfile.aspx"      class="nav-link"><i class="fas fa-user-circle"></i><span>My Profile</span></a></div>
            <div class="nav-item"><a href="LecturerCourses.aspx"      class="nav-link"><i class="fas fa-book"></i><span>My Courses</span></a></div>
            <div class="nav-item"><a href="LecturerAttendance.aspx"   class="nav-link"><i class="fas fa-clipboard-check"></i><span>Attendance</span></a></div>
            <div class="nav-item"><a href="ManageGrades.aspx"         class="nav-link"><i class="fas fa-clipboard-list"></i><span>Grades & Assessments</span></a></div>
            <div class="nav-item"><a href="AtRiskStudents.aspx"       class="nav-link active"><i class="fas fa-exclamation-triangle"></i><span>At Risk Students</span></a></div>
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
                <h2><i class="fas fa-exclamation-triangle me-2 text-danger"></i>At-Risk Students</h2>
            </div>

            <div class="dashboard-content">
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-info">
                    <asp:Label ID="lblSystemMessage" runat="server"></asp:Label>
                </asp:Panel>

                <div class="content-card">
                    <div class="card-header">
                        <h5><i class="fas fa-users me-2 text-danger"></i>Students with Low Attendance (&lt; 80%)</h5>
                    </div>
                    <div class="card-body p-0">
                        <asp:GridView ID="gvLowAttendance" runat="server" AutoGenerateColumns="False" 
                            CssClass="table-custom" GridLines="None" DataKeyNames="studentID">
                            <Columns>
                                <asp:BoundField DataField="studentCode" HeaderText="Student ID" />
                                <asp:BoundField DataField="name" HeaderText="Student Name" />
                                <asp:BoundField DataField="courseCode" HeaderText="Course" />
                                <asp:TemplateField HeaderText="Attendance Rate">
                                    <ItemTemplate>
                                        <span class="attendance-badge"><%# Eval("attendanceRate") %>%</span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="absentDates" HeaderText="Dates Missed" />
                            </Columns>
                            <EmptyDataTemplate>
                                <div class="text-center p-4 text-muted">
                                    <i class="fas fa-check-circle fa-2x mb-3 text-success"></i><br />
                                    All students are currently meeting attendance requirements!
                                </div>
                            </EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>