<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LecturerProfile.aspx.cs" Inherits="StudentManagementSystem.LecturerProfile" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Profile - Lecturer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; --primary: #2c3e50; --secondary: #9b59b6; --accent: #e74c3c; --success: #27ae60; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        .sidebar {
            width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0; display: flex; flex-direction: column;
            background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%);
            color: white; z-index: 1000; transition: all 0.3s; overflow: hidden;
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
        .sidebar nav { flex: 1 1 auto; overflow-y: auto; }
        .sidebar-footer {
            margin-top: auto; flex-shrink: 0; width: 100%; padding: 15px 25px;
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
        .card-body { padding: 30px; }

        .profile-avatar {
            width: 120px; height: 120px; background: linear-gradient(135deg, #9b59b6, #8e44ad);
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
            color: white; font-size: 3rem; margin: 0 auto 20px;
        }
        .form-group { margin-bottom: 20px; }
        .form-group label {
            font-size: 0.8rem; font-weight: 700; color: #7f8c8d; text-transform: uppercase;
            letter-spacing: 0.5px; margin-bottom: 8px; display: block;
        }
        .form-control {
            border-radius: 10px; border: 2px solid #e0e0e0; padding: 12px 15px;
            font-size: 0.95rem; transition: all 0.3s;
        }
        .form-control:focus {
            border-color: #9b59b6; box-shadow: 0 0 0 0.2rem rgba(155, 89, 182, 0.15);
        }
        .form-control:read-only {
            background: #f8f9fa; color: #6c757d; cursor: not-allowed;
        }
        .btn-save {
            background: linear-gradient(135deg, #9b59b6, #8e44ad); border: none;
            border-radius: 10px; padding: 12px 30px; font-weight: 600; color: white;
            transition: all 0.3s;
        }
        .btn-save:hover {
            transform: translateY(-2px); box-shadow: 0 8px 25px rgba(155, 89, 182, 0.4);
        }
        .alert-box {
            padding: 12px 15px; border-radius: 10px; margin-bottom: 20px;
            font-size: 0.9rem;
        }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background: #fde8e8; color: #c0392b; border: 1px solid #f5c6cb; }

        .info-badge {
            display: inline-block; background: #f8f9fa; border-radius: 8px;
            padding: 8px 15px; font-size: 0.85rem; color: #6c757d; margin-top: 5px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <div class="sidebar">
            <div class="sidebar-header">
                <div class="logo"><i class="fas fa-chalkboard-teacher"></i></div>
                <h4><asp:Label ID="lblUserName" runat="server" Text="Lecturer"></asp:Label></h4>
                <small>Senior Lecturer</small>
            </div>

            <nav class="mt-3">
                <div class="nav-item"><a href="LecturerDashboard.aspx" class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
                <div class="nav-item"><a href="LecturerProfile.aspx" class="nav-link active"><i class="fas fa-user-circle"></i><span>My Profile</span></a></div>
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
                <h2><i class="fas fa-user-circle me-2" style="color:#9b59b6;"></i>My Profile</h2>
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
                <div class="row">
                    <div class="col-lg-8 mx-auto">
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-id-card me-2" style="color:#9b59b6;"></i>Personal Information</h5>
                                <asp:Label ID="lblLastUpdated" runat="server" CssClass="text-muted" style="font-size:0.8rem;"></asp:Label>
                            </div>
                            <div class="card-body">
                                <div id="alertBox" runat="server" class="alert-box" style="display:none;"></div>

                                <div class="text-center mb-4">
                                    <div class="profile-avatar">
                                        <i class="fas fa-user"></i>
                                    </div>
                                    <h4 class="mb-1"><asp:Label ID="lblProfileName" runat="server"></asp:Label></h4>
                                    <span class="badge bg-secondary"><asp:Label ID="lblStaffType" runat="server"></asp:Label></span>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label><i class="fas fa-hashtag me-1"></i>Lecturer ID</label>
                                            <asp:TextBox ID="txtLecturerID" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                            <div class="info-badge"><i class="fas fa-lock me-1"></i>Read-only</div>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label><i class="fas fa-envelope me-1"></i>Institutional Email</label>
                                            <asp:TextBox ID="txtInstEmail" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                                            <div class="info-badge"><i class="fas fa-lock me-1"></i>Read-only</div>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label><i class="fas fa-user me-1"></i>Full Name</label>
                                            <asp:TextBox ID="txtName" runat="server" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label><i class="fas fa-envelope-open me-1"></i>Personal Email</label>
                                            <asp:TextBox ID="txtPersonalEmail" runat="server" CssClass="form-control" TextMode="Email"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label><i class="fas fa-building me-1"></i>Department</label>
                                            <asp:TextBox ID="txtDepartment" runat="server" CssClass="form-control"></asp:TextBox>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label><i class="fas fa-briefcase me-1"></i>Staff Type</label>
                                            <asp:DropDownList ID="ddlStaffType" runat="server" CssClass="form-control">
                                                <asp:ListItem Text="Full-time" Value="Full-time"></asp:ListItem>
                                                <asp:ListItem Text="Part-time" Value="Part-time"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>

                                <div class="text-end mt-4">
                                    <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="btn btn-save" OnClick="btnSave_Click" />
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