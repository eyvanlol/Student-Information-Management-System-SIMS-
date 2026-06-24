<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageCourses.aspx.cs" Inherits="StudentManagementSystem.ManageCourses" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Courses - Head of Programme</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; --primary: #2c3e50; --secondary: #3498db; --accent: #e74c3c; --success: #27ae60; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        /* Sidebar - EXACT MATCH to AdminDashboard */
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

        /* Main Content - EXACT MATCH to AdminDashboard */
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
        .table-custom td { padding: 13px 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.9rem; color: #2c3e50; vertical-align: middle; }
        .table-custom tr:hover td { background: #f8f9fa; }
        .code-chip { background: #eef3ff; color: #2563eb; font-weight: 700; font-size: 0.78rem; padding: 4px 10px; border-radius: 6px; }
        
        .badge-custom { padding: 6px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-success { background: #d4edda; color: #155724; }
        .badge-danger { background: #f8d7da; color: #721c24; }
        .badge-warning { background: #fff3cd; color: #856404; }

        /* GridView pager */
        .gv-pager td { padding: 14px 15px !important; background: #fff; border-top: 1px solid #f0f0f0; }
        .gv-pager a, .gv-pager span { padding: 5px 11px; margin: 0 2px; border-radius: 6px; text-decoration: none; font-size: 0.85rem; display: inline-block; }
        .gv-pager a { color: #2c3e50; background: #f1f3f7; }
        .gv-pager a:hover { background: #e2e7f1; }
        .gv-pager span { background: #3498db; color: #fff; font-weight: 700; }

        .form-label { font-weight: 600; font-size: 0.85rem; color: #2c3e50; }
        .req { color: #e74c3c; }

        .btn-save {
            background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
            border: none; border-radius: 10px; padding: 12px;
            font-weight: 600; color: white; width: 100%;
        }

        @media (max-width: 768px) {
            .sidebar { transform: translateX(-100%); }
            .main-content { margin-left: 0; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Sidebar - EXACT SAME as AdminDashboard -->
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
                <div class="nav-item"><a href="ManageCourses.aspx" class="nav-link active"><i class="fas fa-graduation-cap"></i><span>Courses</span></a></div>
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

        <!-- Main Content - EXACT SAME structure as AdminDashboard -->
        <div class="main-content">
            <!-- Topbar - EXACT SAME as AdminDashboard -->
            <div class="topbar">
                <h2><i class="fas fa-graduation-cap me-2 text-primary"></i>Manage Courses</h2>
                <div class="topbar-actions">
                    <div class="notification-bell" style="cursor:pointer;" onclick="location.href='Announcements.aspx'" title="View notifications">
                        <i class="fas fa-bell text-muted"></i>
                        <span class="badge">2</span>
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
                
                <!-- Message Panel -->
                <asp:Panel ID="pnlMsg" runat="server" Visible="false" CssClass="mb-4">
                    <div id="divMsg" runat="server" class="alert" role="alert">
                        <asp:Literal ID="litMsg" runat="server" />
                    </div>
                </asp:Panel>

                <div class="row">
                    <!-- Course List -->
                    <div class="col-lg-8">
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-list me-2 text-primary"></i>All Courses</h5>
                                <div class="d-flex gap-2">
                                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control form-control-sm" 
                                        placeholder="Search course name / code" style="width:200px;" />
                                    <asp:Button ID="btnSearch" runat="server" Text="Search" CausesValidation="false"
                                        CssClass="btn btn-sm btn-primary" OnClick="btnSearch_Click" />
                                    <asp:Button ID="btnClearSearch" runat="server" Text="Reset" CausesValidation="false"
                                        CssClass="btn btn-sm btn-outline-secondary" OnClick="btnClearSearch_Click" />
                                </div>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <asp:GridView ID="gvCourses" runat="server"
                                        AutoGenerateColumns="false"
                                        DataKeyNames="courseID"
                                        CssClass="table-custom"
                                        GridLines="None"
                                        Width="100%"
                                        AllowPaging="true"
                                        PageSize="8"
                                        OnPageIndexChanging="gvCourses_PageIndexChanging"
                                        PagerSettings-Mode="NumericFirstLast"
                                        OnRowCommand="gvCourses_RowCommand"
                                        EmptyDataText="No courses found.">
                                        <PagerStyle CssClass="gv-pager" HorizontalAlign="Center" />
                                        <Columns>
                                            <asp:BoundField DataField="courseName" HeaderText="Course Name" />
                                            <asp:TemplateField HeaderText="Code">
                                                <ItemTemplate><span class="code-chip"><%# Eval("courseCode") %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Programme">
                                                <ItemTemplate><%# Eval("programmeName") %></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Lecturer">
                                                <ItemTemplate><%# Eval("lecturerName") %></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField DataField="creditHour" HeaderText="Credits" />
                                            <asp:BoundField DataField="semester" HeaderText="Semester" />
                                            <asp:BoundField DataField="maxCapacity" HeaderText="Capacity" />
                                            <asp:TemplateField HeaderText="Status">
                                                <ItemTemplate>
                                                    <span class='badge-custom <%# Eval("status").ToString() == "Active" ? "badge-success" : (Eval("status").ToString() == "Full" ? "badge-warning" : "badge-danger") %>'>
                                                        <%# Eval("status") %>
                                                    </span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Actions" ItemStyle-Width="120px">
                                                <ItemTemplate>
                                                    <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-primary me-1"
                                                        CommandName="EditRow" CommandArgument='<%# Eval("courseID") %>'>
                                                        <i class="fas fa-edit"></i>
                                                    </asp:LinkButton>
                                                    <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-danger"
                                                        CommandName="DeleteRow" CommandArgument='<%# Eval("courseID") %>'
                                                        OnClientClick="return confirm('Delete this course?');">
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

                    <!-- Add / Edit Form -->
                    <div class="col-lg-4">
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-plus-circle me-2 text-success"></i>
                                    <asp:Label ID="lblFormTitle" runat="server" Text="Add New Course" /></h5>
                            </div>
                            <div class="card-body">
                                <asp:HiddenField ID="hfCourseID" runat="server" />

                                <div class="mb-3">
                                    <label class="form-label">Course Name <span class="req">*</span></label>
                                    <asp:TextBox ID="txtCourseName" runat="server" CssClass="form-control" MaxLength="150" />
                                    <asp:RequiredFieldValidator ID="rfvCourseName" runat="server" ControlToValidate="txtCourseName"
                                        ValidationGroup="course" CssClass="text-danger small" Display="Dynamic"
                                        ErrorMessage="Course name is required." />
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Course Code <span class="req">*</span></label>
                                    <asp:TextBox ID="txtCourseCode" runat="server" CssClass="form-control" MaxLength="20" />
                                    <asp:RequiredFieldValidator ID="rfvCourseCode" runat="server" ControlToValidate="txtCourseCode"
                                        ValidationGroup="course" CssClass="text-danger small" Display="Dynamic"
                                        ErrorMessage="Course code is required." />
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Programme <span class="req">*</span></label>
                                    <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-select" />
                                    <asp:RequiredFieldValidator ID="rfvProgramme" runat="server" ControlToValidate="ddlProgramme"
                                        ValidationGroup="course" CssClass="text-danger small" Display="Dynamic"
                                        InitialValue="" ErrorMessage="Programme is required." />
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Assigned Lecturer <span class="req">*</span></label>
                                    <asp:DropDownList ID="ddlLecturer" runat="server" CssClass="form-select" />
                                    <asp:RequiredFieldValidator ID="rfvLecturer" runat="server" ControlToValidate="ddlLecturer"
                                        ValidationGroup="course" CssClass="text-danger small" Display="Dynamic"
                                        InitialValue="" ErrorMessage="Lecturer is required." />
                                </div>

                                <div class="row">
                                    <div class="col-6 mb-3">
                                        <label class="form-label">Credit Hours <span class="req">*</span></label>
                                        <asp:TextBox ID="txtCreditHour" runat="server" CssClass="form-control" TextMode="Number" />
                                        <asp:RequiredFieldValidator ID="rfvCreditHour" runat="server" ControlToValidate="txtCreditHour"
                                            ValidationGroup="course" CssClass="text-danger small" Display="Dynamic"
                                            ErrorMessage="Required." />
                                        <asp:RangeValidator ID="rngCreditHour" runat="server" ControlToValidate="txtCreditHour"
                                            ValidationGroup="course" CssClass="text-danger small" Display="Dynamic"
                                            Type="Integer" MinimumValue="1" MaximumValue="30" ErrorMessage="1-30 only." />
                                    </div>
                                    <div class="col-6 mb-3">
                                        <label class="form-label">Max Capacity <span class="req">*</span></label>
                                        <asp:TextBox ID="txtMaxCapacity" runat="server" CssClass="form-control" TextMode="Number" />
                                        <asp:RequiredFieldValidator ID="rfvMaxCapacity" runat="server" ControlToValidate="txtMaxCapacity"
                                            ValidationGroup="course" CssClass="text-danger small" Display="Dynamic"
                                            ErrorMessage="Required." />
                                        <asp:RangeValidator ID="rngMaxCapacity" runat="server" ControlToValidate="txtMaxCapacity"
                                            ValidationGroup="course" CssClass="text-danger small" Display="Dynamic"
                                            Type="Integer" MinimumValue="1" MaximumValue="500" ErrorMessage="1-500 only." />
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-6 mb-3">
                                        <label class="form-label">Semester <span class="req">*</span></label>
                                        <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select">
                                            <asp:ListItem Text="Semester 1" Value="1" />
                                            <asp:ListItem Text="Semester 2" Value="2" />
                                            <asp:ListItem Text="Semester 3" Value="3" />
                                        </asp:DropDownList>
                                    </div>
                                    <div class="col-6 mb-3">
                                        <label class="form-label">Status</label>
                                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                                            <asp:ListItem Text="Active" />
                                            <asp:ListItem Text="Inactive" />
                                            <asp:ListItem Text="Full" />
                                        </asp:DropDownList>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Description</label>
                                    <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="500" />
                                </div>

                                <div class="d-grid gap-2">
                                    <asp:Button ID="btnSave" runat="server" Text="Save Course"
                                        CssClass="btn btn-save" ValidationGroup="course" OnClick="btnSave_Click" />
                                    <asp:Button ID="btnClear" runat="server" Text="Clear"
                                        CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnClear_Click" />
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
