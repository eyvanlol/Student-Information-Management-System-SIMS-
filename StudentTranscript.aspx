<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentTranscript.aspx.cs" Inherits="StudentManagementSystem.StudentTranscript" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Attendance & Transcript</title>

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
            padding: 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.9rem; color: #2c3e50;
        }

        .table-custom tr:hover td { background: #f8f9fa; }

        .empty-box {
            padding: 25px;
            text-align: center;
            color: #7f8c8d;
        }

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
            <div class="logo"><i class="fas fa-user-graduate"></i></div>
            <h4><asp:Label ID="lblUserName" runat="server" Text="Student"></asp:Label></h4>
            <small>Student Portal</small>
        </div>

        <nav class="mt-3">
            <div class="nav-item"><a href="StudentDashboard.aspx" class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
            <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-user-circle"></i><span>My Profile</span></a></div>
            <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-book"></i><span>My Courses</span></a></div>
            <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-plus-circle"></i><span>Course Registration</span></a></div>
            <div class="nav-item"><a href="StudentTranscript.aspx" class="nav-link active"><i class="fas fa-clipboard-check"></i><span>Attendance</span></a></div>
            <div class="nav-item"><a href="StudentTranscript.aspx" class="nav-link"><i class="fas fa-chart-line"></i><span>Academic Results</span></a></div>
            <div class="nav-item"><a href="StudentTranscript.aspx" class="nav-link"><i class="fas fa-history"></i><span>Academic History</span></a></div>
            <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-bell"></i><span>Notifications</span></a></div>
            <div class="nav-item"><a href="#" class="nav-link"><i class="fas fa-cog"></i><span>Settings</span></a></div>
        </nav>

        <div class="sidebar-footer">
            <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-link" OnClick="btnLogout_Click" style="padding:10px 0;">
                <i class="fas fa-sign-out-alt"></i><span>Logout</span>
            </asp:LinkButton>
        </div>
    </div>

    <div class="main-content">
        <div class="topbar">
            <h2><i class="fas fa-file-alt me-2" style="color:#1abc9c;"></i>Attendance & Transcript</h2>

            <div class="topbar-actions">
                <div class="notification-bell">
                    <i class="fas fa-bell text-muted"></i>
                    <span class="badge">4</span>
                </div>

                <div class="user-dropdown">
                    <div style="width:35px;height:35px;background:linear-gradient(135deg,#1abc9c,#16a085);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                        <i class="fas fa-user-graduate"></i>
                    </div>
                    <span><asp:Label ID="lblTopUserName" runat="server" Text="Student"></asp:Label></span>
                    <i class="fas fa-chevron-down text-muted" style="font-size:0.7rem;"></i>
                </div>
            </div>
        </div>

        <div class="dashboard-content">

            <div class="content-card">
                <div class="card-header">
                    <h5><i class="fas fa-clipboard-check me-2" style="color:#1abc9c;"></i>My Attendance</h5>
                </div>

                <div class="card-body p-0">
                    <asp:GridView ID="gvAttendance" runat="server"
                        AutoGenerateColumns="False"
                        CssClass="table-custom"
                        GridLines="None">

                        <Columns>
                            <asp:BoundField DataField="courseCode" HeaderText="Course Code" />
                            <asp:BoundField DataField="courseName" HeaderText="Course Name" />
                            <asp:BoundField DataField="attendanceDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:BoundField DataField="sessionType" HeaderText="Session Type" />
                            <asp:BoundField DataField="status" HeaderText="Status" />
                        </Columns>

                        <EmptyDataTemplate>
                            <div class="empty-box">
                                <i class="fas fa-info-circle me-2"></i>No attendance records found.
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>

            <div class="content-card">
                <div class="card-header">
                    <h5><i class="fas fa-chart-line me-2" style="color:#1abc9c;"></i>My Results / Transcript</h5>
                </div>

                <div class="card-body p-0">
                    <asp:GridView ID="gvResults" runat="server"
                        AutoGenerateColumns="False"
                        CssClass="table-custom"
                        GridLines="None">

                        <Columns>
                            <asp:BoundField DataField="courseCode" HeaderText="Course Code" />
                            <asp:BoundField DataField="courseName" HeaderText="Course Name" />
                            <asp:BoundField DataField="semester" HeaderText="Semester" />
                            <asp:BoundField DataField="marks" HeaderText="Marks" />
                            <asp:BoundField DataField="grade" HeaderText="Grade" />
                        </Columns>

                        <EmptyDataTemplate>
                            <div class="empty-box">
                                <i class="fas fa-info-circle me-2"></i>No result records found.
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
