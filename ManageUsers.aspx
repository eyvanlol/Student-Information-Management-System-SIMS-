<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageUsers.aspx.cs" Inherits="StudentManagementSystem.ManageUsers" %>
<%@ Register Src="~/NotificationBell.ascx" TagPrefix="uc" TagName="NotificationBell" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Manage Users - Head of Programme</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; --primary: #2c3e50; --secondary: #3498db; --accent: #e74c3c; --success: #27ae60; }
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
        .notification-bell { position: relative; width: 40px; height: 40px; border-radius: 50%; background:#f8f9fa; display:flex; align-items:center; justify-content:center; cursor:pointer; }
        .notification-bell:hover { background: #e9ecef; }
        .user-dropdown { display: flex; align-items: center; gap: 10px; padding: 8px 15px; border-radius: 10px; }
        .user-dropdown span { font-size: 0.9rem; font-weight: 600; color: #2c3e50; }

        .dashboard-content { padding: 30px; }
        .content-card { background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); margin-bottom: 25px; overflow: hidden; }
        .card-header { padding: 20px 25px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px; }
        .card-header h5 { margin: 0; font-weight: 700; color: #2c3e50; }
        .card-body { padding: 25px; }

        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th { background: #f8f9fa; padding: 15px; font-size: 0.8rem; font-weight: 700;
            color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; border: none; }
        .table-custom td { padding: 13px 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.9rem; color: #2c3e50; vertical-align: middle; }
        .table-custom tr:hover td { background: #f8f9fa; }
        .badge-custom { padding: 6px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-blue { background: #d6eaf8; color: #2471a3; }
        .badge-purple { background: #ede1f6; color: #6f42c1; }
        .badge-green { background: #d4efdf; color: #1e8449; }

        .form-label { font-weight: 600; font-size: 0.85rem; color: #2c3e50; }
        .req { color: #e74c3c; }
        .btn-save { background: linear-gradient(135deg, #2980b9 0%, #2471a3 100%); border: none; border-radius: 10px;
            padding: 12px 30px; font-weight: 600; color: white; }

        .cred-card { background: linear-gradient(135deg, #eafaf1, #d4efdf); border: 1px solid #a9dfbf; border-radius: 12px; padding: 20px 25px; }
        .cred-card .lbl { font-size: 0.75rem; color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; }
        .cred-card .val { font-size: 1rem; font-weight: 700; color: #2c3e50; font-family: 'Consolas', monospace; }

        @media (max-width: 768px) { .sidebar { transform: translateX(-100%); } .main-content { margin-left: 0; } }
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
                <small><%= StudentManagementSystem.DbHelper.GetRoleIdentity(Session) %></small>
            </div>
            <nav class="mt-3">
                <div class="nav-item"><a href="AdminDashboard.aspx" class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
                <div class="nav-item"><a href="ManageProgrammes.aspx" class="nav-link"><i class="fas fa-book"></i><span>Academic Programmes</span></a></div>
                <div class="nav-item"><a href="ManageCourses.aspx" class="nav-link"><i class="fas fa-graduation-cap"></i><span>Courses</span></a></div>
                <div class="nav-item"><a href="ManageUsers.aspx" class="nav-link active"><i class="fas fa-users"></i><span>Manage Users</span></a></div>
                <div class="nav-item"><a href="ManageEnrolment.aspx" class="nav-link"><i class="fas fa-clipboard-check"></i><span>Enrolment</span></a></div>
                <div class="nav-item"><a href="StudentStatistics.aspx" class="nav-link"><i class="fas fa-chart-pie"></i><span>Statistics</span></a></div>
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
                <h2><i class="fas fa-users-cog me-2" style="color:#3498db;"></i>Manage Users</h2>
                <div class="topbar-actions">
                    <uc:NotificationBell runat="server" ID="ucNotificationBell" />
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
                    <div id="divMsg" runat="server" class="alert" role="alert"><asp:Literal ID="litMsg" runat="server" /></div>
                </asp:Panel>

                <!-- Credential confirmation card (after create) -->
                <asp:Panel ID="pnlCred" runat="server" Visible="false" CssClass="mb-4">
                    <div class="cred-card">
                        <h5 class="mb-3"><i class="fas fa-check-circle text-success me-2"></i>Account created &mdash; share these credentials</h5>
                        <div class="row g-3">
                            <div class="col-md-3"><div class="lbl">Role</div><div class="val"><asp:Label ID="lblCredRole" runat="server" /></div></div>
                            <div class="col-md-3"><div class="lbl">Login ID</div><div class="val"><asp:Label ID="lblCredId" runat="server" /></div></div>
                            <div class="col-md-3"><div class="lbl">Login Email</div><div class="val"><asp:Label ID="lblCredEmail" runat="server" /></div></div>
                            <div class="col-md-3"><div class="lbl">Temp Password</div><div class="val"><asp:Label ID="lblCredPass" runat="server" /></div></div>
                        </div>
                        <small class="text-muted d-block mt-2">The user must change this password on first login. (Email delivery is stubbed until SMTP is configured.)</small>
                    </div>
                </asp:Panel>

                <!-- Add New User -->
                <div class="content-card">
                    <div class="card-header"><h5><i class="fas fa-user-plus me-2 text-primary"></i>Add New User</h5></div>
                    <div class="card-body">
                        <div class="row g-3">
                            <div class="col-md-4">
                                <label class="form-label">Role <span class="req">*</span></label>
                                <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="Student">Student</asp:ListItem>
                                    <asp:ListItem Value="Lecturer">Lecturer</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Full Name <span class="req">*</span></label>
                                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Full name" />
                                <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName"
                                    ValidationGroup="usr" CssClass="text-danger small" Display="Dynamic" ErrorMessage="Name is required." />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Personal Email <span class="req">*</span></label>
                                <asp:TextBox ID="txtPersonalEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="name@gmail.com" />
                                <asp:RequiredFieldValidator ID="rfvPEmail" runat="server" ControlToValidate="txtPersonalEmail"
                                    ValidationGroup="usr" CssClass="text-danger small" Display="Dynamic" ErrorMessage="Personal email is required." />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">IC Number</label>
                                <asp:TextBox ID="txtIc" runat="server" CssClass="form-control" placeholder="e.g. 040101-07-1234" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Phone</label>
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="e.g. 012-3456789" />
                            </div>
                        </div>

                        <!-- Student-only -->
                        <div id="studentFields" class="row g-3 mt-1">
                            <div class="col-12"><hr /><h6 class="text-muted"><i class="fas fa-user-graduate me-2"></i>Student details</h6></div>
                            <div class="col-md-4">
                                <label class="form-label">Programme <span class="req">*</span></label>
                                <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-select" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Intake Semester</label>
                                <asp:TextBox ID="txtIntake" runat="server" CssClass="form-control" placeholder="e.g. AUGUST 2026" />
                            </div>
                            <div class="col-md-4"></div>
                            <div class="col-md-4">
                                <label class="form-label">Emergency Contact Name</label>
                                <asp:TextBox ID="txtEmgName" runat="server" CssClass="form-control" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Emergency Contact Phone</label>
                                <asp:TextBox ID="txtEmgPhone" runat="server" CssClass="form-control" />
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Emergency Contact Relationship</label>
                                <asp:TextBox ID="txtEmgRel" runat="server" CssClass="form-control" placeholder="e.g. Parent" />
                            </div>
                        </div>

                        <!-- Lecturer-only -->
                        <div id="lecturerFields" class="row g-3 mt-1" style="display:none;">
                            <div class="col-12"><hr /><h6 class="text-muted"><i class="fas fa-user-tie me-2"></i>Lecturer details</h6></div>
                            <div class="col-md-4">
                                <label class="form-label">Department</label>
                                <asp:DropDownList ID="ddlDept" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="School of Computing">School of Computing</asp:ListItem>
                                    <asp:ListItem Value="School of Business">School of Business</asp:ListItem>
                                    <asp:ListItem Value="School of Engineering">School of Engineering</asp:ListItem>
                                    <asp:ListItem Value="School of Design">School of Design</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Staff Type</label>
                                <asp:DropDownList ID="ddlStaffType" runat="server" CssClass="form-select">
                                    <asp:ListItem Value="Full-time">Full-time</asp:ListItem>
                                    <asp:ListItem Value="Part-time">Part-time</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>

                        <div class="mt-4 d-flex gap-2">
                            <asp:Button ID="btnCreate" runat="server" Text="Create User" CssClass="btn btn-save" ValidationGroup="usr" OnClick="btnCreate_Click" />
                            <asp:Button ID="btnClearForm" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnClearForm_Click" />
                        </div>
                    </div>
                </div>

                <!-- User list -->
                <div class="content-card">
                    <div class="card-header">
                        <h5><i class="fas fa-list me-2 text-primary"></i>All Users
                            <span class="badge-custom badge-blue ms-2"><asp:Label ID="lblUserCount" runat="server" Text="0" /></span></h5>
                        <div class="d-flex gap-2">
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control form-control-sm" placeholder="Search name or ID..." style="width:200px;" />
                            <asp:DropDownList ID="ddlFilterRole" runat="server" CssClass="form-select form-select-sm" style="width:140px;">
                                <asp:ListItem Value="">All roles</asp:ListItem>
                                <asp:ListItem Value="Student">Students</asp:ListItem>
                                <asp:ListItem Value="Lecturer">Lecturers</asp:ListItem>
                            </asp:DropDownList>
                            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-sm btn-primary" CausesValidation="false" OnClick="btnSearch_Click" />
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="false" CssClass="table-custom"
                                GridLines="None" Width="100%" OnRowCommand="gvUsers_RowCommand"
                                EmptyDataText="No users found.">
                                <Columns>
                                    <asp:BoundField DataField="code" HeaderText="Code" />
                                    <asp:TemplateField HeaderText="Name">
                                        <ItemTemplate>
                                            <div style="font-weight:600;"><%# Server.HtmlEncode(Eval("name").ToString()) %></div>
                                            <small style="color:#6c757d;"><%# Server.HtmlEncode(Eval("email").ToString()) %></small>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="id" HeaderText="ID" ItemStyle-Width="70px" />
                                    <asp:TemplateField HeaderText="Role">
                                        <ItemTemplate>
                                            <span class='<%# "badge-custom " + (Eval("role").ToString() == "Lecturer" ? "badge-purple" : "badge-blue") %>'><%# Eval("role") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate><span class="badge-custom badge-green"><%# Eval("status") %></span></ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Actions" ItemStyle-Width="190px">
                                        <ItemTemplate>
                                            <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-danger"
                                                CommandName="DeleteUser" CommandArgument='<%# Eval("role") + "|" + Eval("id") %>'
                                                OnClientClick="return confirm('Delete this user?');">
                                                <i class="fas fa-trash"></i>
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function toggleRole() {
            var sel = document.getElementById('<%= ddlRole.ClientID %>');
            var isStudent = sel.value === 'Student';
            document.getElementById('studentFields').style.display = isStudent ? '' : 'none';
            document.getElementById('lecturerFields').style.display = isStudent ? 'none' : '';
        }
        window.addEventListener('load', toggleRole);
    </script>
</body>
</html>

                <div class="nav-item"><a href="Reports.aspx" class="nav-link"><i class="fas fa-file-export"></i><span>Reports</span></a></div>