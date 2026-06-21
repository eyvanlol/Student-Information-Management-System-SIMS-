<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageProgrammes.aspx.cs" Inherits="StudentManagementSystem.ManageProgrammes" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Manage Programmes - Head of Programme</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; --primary: #2c3e50; --secondary: #3498db; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        /* Sidebar (matches AdminDashboard) */
        .sidebar {
            width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0;
            background: linear-gradient(180deg, #2c3e50 0%, #34495e 100%);
            color: white; z-index: 1000; transition: all 0.3s; overflow-y: auto;
        }
        .sidebar-header { padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-header h4 { font-size: 1rem; margin-bottom: 3px; }
        .sidebar-header small { color: rgba(255,255,255,0.6); font-size: 0.75rem; }
        .nav-item { padding: 0; }
        .nav-link {
            color: rgba(255,255,255,0.8); padding: 14px 25px; display: flex; align-items: center;
            text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent;
        }
        .nav-link:hover, .nav-link.active { background: rgba(255,255,255,0.1); color: white; border-left-color: #3498db; }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .nav-link span { font-size: 0.9rem; }
        .sidebar-footer { position: absolute; bottom: 0; width: 100%; padding: 15px 25px; border-top: 1px solid rgba(255,255,255,0.1); }

        /* Main */
        .main-content { margin-left: var(--sidebar-width); min-height: 100vh; }
        .topbar {
            background: white; padding: 15px 30px; display: flex; justify-content: space-between;
            align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 100;
        }
        .topbar h2 { font-size: 1.4rem; color: #2c3e50; margin: 0; }
        .topbar-actions { display: flex; align-items: center; gap: 15px; }
        .user-dropdown { display: flex; align-items: center; gap: 10px; padding: 8px 15px; border-radius: 10px; }
        .user-dropdown span { font-size: 0.9rem; font-weight: 600; color: #2c3e50; }
        .dashboard-content { padding: 30px; }

        /* Cards */
        .content-card { background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); margin-bottom: 25px; overflow: hidden; }
        .card-header { padding: 20px 25px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
        .card-header h5 { margin: 0; font-weight: 700; color: #2c3e50; }
        .card-body { padding: 25px; }

        /* Table */
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

        /* GridView pager */
        .gv-pager td { padding: 14px 15px !important; background: #fff; border-top: 1px solid #f0f0f0; }
        .gv-pager a, .gv-pager span { padding: 5px 11px; margin: 0 2px; border-radius: 6px; text-decoration: none; font-size: 0.85rem; display: inline-block; }
        .gv-pager a { color: #2c3e50; background: #f1f3f7; }
        .gv-pager a:hover { background: #e2e7f1; }
        .gv-pager span { background: #3498db; color: #fff; font-weight: 700; }

        .form-label { font-weight: 600; font-size: 0.85rem; color: #2c3e50; }
        .req { color: #e74c3c; }

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
            <small>Administrator</small>
        </div>
            <nav class="mt-3">
                <div class="nav-item">
                    <a href="AdminDashboard.aspx" class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a>
                </div>
                <div class="nav-item">
                    <ahref="ManageUsers.aspx" class="nav-link"><i class="fas fa-users"></i><span>Manage Users</span></a>
                </div>
                <div class="nav-item">
                    <a href="ManageProgrammes.aspx" class="nav-link"><i class="fas fa-book"></i><span>Manage Programmes</span></a>
                </div>
                <div class="nav-item">
                    <a href="ManageCourses.aspx" class="nav-link"><i class="fas fa-graduation-cap"></i><span>Manage Courses</span></a>
                </div>
                <div class="nav-item">
                    <a href="ManageEnrolment.aspx" class="nav-link"><i class="fas fa-clipboard-check"></i><span>Manage Enrolment</span></a>
                </div>
                <div class="nav-item">
                    <a href="#" class="nav-link"><i class="fas fa-chart-bar"></i><span>Student Statistics</span></a>
                </div>
                <div class="nav-item">
                    <a href="#" class="nav-link"><i class="fas fa-file-export"></i><span>Reports</span></a>
                </div>
                <div class="nav-item">
                    <a href="AcademicCalendar.aspx" class="nav-link"><i class="fas fa-calendar-alt"></i><span>Academic Calendar</span></a>
                </div>
                <div class="nav-item">
                    <a href="Announcements.aspx" class="nav-link"><i class="fas fa-bullhorn"></i><span>Announcements</span></a>
                </div>
        </nav>
            <div class="sidebar-footer">
                <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-link" OnClick="btnLogout_Click" style="padding:10px 0;">
                    <i class="fas fa-sign-out-alt"></i><span>Logout</span>
                </asp:LinkButton>
            </div>
        </div>

        <!-- Main -->
        <div class="main-content">
            <div class="topbar">
                <h2><i class="fas fa-book me-2 text-primary"></i>Manage Programmes</h2>
                <div class="topbar-actions">
                    <div class="user-dropdown">
                        <div style="width:35px;height:35px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                            <i class="fas fa-user-shield"></i>
                        </div>
                        <span><asp:Label ID="lblTopUserName" runat="server" Text="Head of Programme"></asp:Label></span>
                    </div>
                </div>
            </div>

            <div class="dashboard-content">

                <!-- status message -->
                <asp:Panel ID="pnlMsg" runat="server" Visible="false">
                    <div id="divMsg" runat="server" class="alert" role="alert"><asp:Literal ID="litMsg" runat="server" /></div>
                </asp:Panel>

                <div class="row">

                    <!-- Programme list -->
                    <div class="col-lg-8">
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-list me-2 text-primary"></i>All Programmes</h5>
                                <div class="d-flex gap-2">
                                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control form-control-sm"
                                        placeholder="Search name / code / faculty" style="width:230px;" />
                                    <asp:Button ID="btnSearch" runat="server" Text="Search" CausesValidation="false"
                                        CssClass="btn btn-sm btn-primary" OnClick="btnSearch_Click" />
                                    <asp:Button ID="btnClearSearch" runat="server" Text="Reset" CausesValidation="false"
                                        CssClass="btn btn-sm btn-outline-secondary" OnClick="btnClearSearch_Click" />
                                </div>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <asp:GridView ID="gvProgrammes" runat="server"
                                        AutoGenerateColumns="false"
                                        DataKeyNames="programmeID"
                                        CssClass="table-custom"
                                        GridLines="None"
                                        Width="100%"
                                        AllowPaging="true"
                                        PageSize="8"
                                        OnPageIndexChanging="gvProgrammes_PageIndexChanging"
                                        PagerSettings-Mode="NumericFirstLast"
                                        OnRowCommand="gvProgrammes_RowCommand"
                                        EmptyDataText="No programmes found.">
                                        <PagerStyle CssClass="gv-pager" HorizontalAlign="Center" />
                                        <Columns>
                                            <asp:BoundField DataField="programmeName" HeaderText="Programme" />
                                            <asp:TemplateField HeaderText="Code">
                                                <ItemTemplate><span class="code-chip"><%# Eval("programmeCode") %></span></ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:BoundField DataField="faculty" HeaderText="Faculty" />
                                            <asp:BoundField DataField="totalCredits" HeaderText="Credits" />
                                            <asp:BoundField DataField="durationYears" HeaderText="Yrs" />
                                            <asp:TemplateField HeaderText="Status">
                                                <ItemTemplate>
                                                    <span class='badge-custom <%# Eval("status").ToString() == "Active" ? "badge-success" : "badge-danger" %>'><%# Eval("status") %></span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Actions">
                                                <ItemTemplate>
                                                    <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-primary me-1"
                                                        CommandName="EditRow" CommandArgument='<%# Eval("programmeID") %>'>
                                                        <i class="fas fa-edit"></i>
                                                    </asp:LinkButton>
                                                    <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-danger"
                                                        CommandName="DeleteRow" CommandArgument='<%# Eval("programmeID") %>'
                                                        OnClientClick="return confirm('Delete this programme?');">
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

                    <!-- Add / edit form -->
                    <div class="col-lg-4">
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-plus-circle me-2 text-success"></i><asp:Label ID="lblFormTitle" runat="server" Text="Add New Programme" /></h5>
                            </div>
                            <div class="card-body">
                                <asp:HiddenField ID="hfProgrammeID" runat="server" />

                                <div class="mb-3">
                                    <label class="form-label">Programme Name <span class="req">*</span></label>
                                    <asp:TextBox ID="txtName" runat="server" CssClass="form-control" MaxLength="150" />
                                    <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName"
                                        ValidationGroup="prog" CssClass="text-danger small" Display="Dynamic"
                                        ErrorMessage="Programme name is required." />
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Programme Code <span class="req">*</span></label>
                                    <asp:TextBox ID="txtCode" runat="server" CssClass="form-control" MaxLength="20" />
                                    <asp:RequiredFieldValidator ID="rfvCode" runat="server" ControlToValidate="txtCode"
                                        ValidationGroup="prog" CssClass="text-danger small" Display="Dynamic"
                                        ErrorMessage="Code is required." />
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Faculty <span class="req">*</span></label>
                                    <asp:DropDownList ID="ddlFaculty" runat="server" CssClass="form-select">
                                        <asp:ListItem Text="Faculty of Computing" />
                                        <asp:ListItem Text="Faculty of Business" />
                                        <asp:ListItem Text="Faculty of Engineering" />
                                        <asp:ListItem Text="Faculty of Creative Arts" />
                                        <asp:ListItem Text="Faculty of Science" />
                                    </asp:DropDownList>
                                </div>

                                <div class="row">
                                    <div class="col-6 mb-3">
                                        <label class="form-label">Credits <span class="req">*</span></label>
                                        <asp:TextBox ID="txtCredits" runat="server" CssClass="form-control" TextMode="Number" />
                                        <asp:RequiredFieldValidator ID="rfvCredits" runat="server" ControlToValidate="txtCredits"
                                            ValidationGroup="prog" CssClass="text-danger small" Display="Dynamic"
                                            ErrorMessage="Required." />
                                        <asp:RangeValidator ID="rngCredits" runat="server" ControlToValidate="txtCredits"
                                            ValidationGroup="prog" CssClass="text-danger small" Display="Dynamic"
                                            Type="Integer" MinimumValue="0" MaximumValue="500" ErrorMessage="0-500 only." />
                                    </div>
                                    <div class="col-6 mb-3">
                                        <label class="form-label">Duration (Yrs) <span class="req">*</span></label>
                                        <asp:TextBox ID="txtDuration" runat="server" CssClass="form-control" TextMode="Number" />
                                        <asp:RangeValidator ID="rngDuration" runat="server" ControlToValidate="txtDuration"
                                            ValidationGroup="prog" CssClass="text-danger small" Display="Dynamic"
                                            Type="Integer" MinimumValue="1" MaximumValue="10" ErrorMessage="1-10 only." />
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Status</label>
                                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                                        <asp:ListItem Text="Active" />
                                        <asp:ListItem Text="Inactive" />
                                    </asp:DropDownList>
                                </div>

                                <div class="d-grid gap-2">
                                    <asp:Button ID="btnSave" runat="server" Text="Save Programme"
                                        CssClass="btn btn-primary" ValidationGroup="prog" OnClick="btnSave_Click" />
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
