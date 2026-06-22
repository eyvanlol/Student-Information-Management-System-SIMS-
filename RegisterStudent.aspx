<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RegisterStudent.aspx.cs" Inherits="StudentManagementSystem.RegisterStudent" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Register Student - Head of Programme</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; --primary: #2c3e50; --secondary: #3498db; --accent: #e74c3c; --success: #27ae60; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

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

        .main-content { margin-left: var(--sidebar-width); padding: 0; min-height: 100vh; }
        .topbar {
            background: white; padding: 15px 30px; display: flex; justify-content: space-between;
            align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 100;
        }
        .topbar h2 { font-size: 1.4rem; color: #2c3e50; margin: 0; }
        .topbar-actions { display: flex; align-items: center; gap: 15px; }
        .notification-bell {
            position: relative; width: 40px; height: 40px; border-radius: 50%;
            background: #f8f9fa; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.3s;
        }
        .notification-bell:hover { background: #e9ecef; }
        .notification-bell .badge { position: absolute; top: -2px; right: -2px; background: #e74c3c; color: white; font-size: 0.65rem; padding: 3px 6px; border-radius: 10px; }
        .user-dropdown { display: flex; align-items: center; gap: 10px; cursor: pointer; padding: 8px 15px; border-radius: 10px; transition: all 0.3s; }
        .user-dropdown:hover { background: #f8f9fa; }
        .user-dropdown span { font-size: 0.9rem; font-weight: 600; color: #2c3e50; }

        .dashboard-content { padding: 30px; }
        .content-card { background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); margin-bottom: 25px; overflow: hidden; }
        .card-header { padding: 20px 25px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
        .card-header h5 { margin: 0; font-weight: 700; color: #2c3e50; }
        .card-body { padding: 25px; }

        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th { background: #f8f9fa; padding: 15px; font-size: 0.8rem; font-weight: 700; color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; border: none; }
        .table-custom td { padding: 13px 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.9rem; color: #2c3e50; vertical-align: middle; }
        .table-custom tr:hover td { background: #f8f9fa; }
        .badge-custom { padding: 6px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-teal { background: #d1f2eb; color: #117a65; }
        .badge-pending { background: #fdebd0; color: #b9770e; }

        .form-label { font-weight: 600; font-size: 0.85rem; color: #2c3e50; }
        .req { color: #e74c3c; }
        .btn-save { background: linear-gradient(135deg, #1abc9c 0%, #16a085 100%); border: none; border-radius: 10px; padding: 12px 30px; font-weight: 600; color: white; }
        .student-icon { width: 80px; height: 80px; background: linear-gradient(135deg, #1abc9c, #16a085); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 2rem; margin: 0 auto 20px; }
        .gen-note { background: #eafaf1; border: 1px solid #abebc6; border-radius: 10px; padding: 12px 14px; font-size: 0.8rem; color: #117a65; }

        @media (max-width: 768px) { .sidebar { transform: translateX(-100%); } .main-content { margin-left: 0; } }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-header">
                <div style="width:70px;height:70px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;margin:0 auto 10px;display:flex;align-items:center;justify-content:center;font-size:1.5rem;color:white;">
                    <i class="fas fa-user-shield"></i>
                </div>
                <h4><asp:Label ID="lblUserName" runat="server" Text="Head of Programme"></asp:Label></h4>
                <small>Administrator</small>
            </div>

            <nav class="mt-3">
                <div class="nav-item"><a href="AdminDashboard.aspx" class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
                <div class="nav-item"><a href="ManageProgrammes.aspx" class="nav-link"><i class="fas fa-book"></i><span>Academic Programmes</span></a></div>
                <div class="nav-item"><a href="ManageCourses.aspx" class="nav-link"><i class="fas fa-graduation-cap"></i><span>Courses</span></a></div>
                <div class="nav-item"><a href="RegisterLecturer.aspx" class="nav-link"><i class="fas fa-user-tie"></i><span>Register Lecturer</span></a></div>
                <div class="nav-item"><a href="RegisterStudent.aspx" class="nav-link active"><i class="fas fa-user-graduate"></i><span>Register Student</span></a></div>
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
            <div class="topbar">
                <h2><i class="fas fa-user-graduate me-2" style="color:#1abc9c;"></i>Register New Student</h2>
                <div class="topbar-actions">
                    <div class="notification-bell"><i class="fas fa-bell text-muted"></i><span class="badge">4</span></div>
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
                    <div id="divMsg" runat="server" class="alert" role="alert">
                        <asp:Literal ID="litMsg" runat="server" />
                    </div>
                </asp:Panel>

                <div class="row">
                    <!-- Registered Students List -->
                    <div class="col-lg-8">
                        <div class="content-card">
                            <div class="card-header">
                                <h5><i class="fas fa-list me-2 text-primary"></i>Registered Students</h5>
                                <span class="badge-custom badge-teal">
                                    <asp:Label ID="lblStudentCount" runat="server" Text="0"></asp:Label> Total
                                </span>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <asp:GridView ID="gvStudents" runat="server"
                                        AutoGenerateColumns="false"
                                        DataKeyNames="studentID"
                                        CssClass="table-custom"
                                        GridLines="None"
                                        Width="100%"
                                        OnRowCommand="gvStudents_RowCommand"
                                        EmptyDataText="No students registered yet.">
                                        <Columns>
                                            <asp:TemplateField HeaderText="Student">
                                                <ItemTemplate>
                                                    <div class="d-flex align-items-center gap-2">
                                                        <div style="width:32px;height:32px;background:linear-gradient(135deg,#1abc9c,#16a085);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.7rem;">
                                                            <i class="fas fa-user-graduate"></i>
                                                        </div>
                                                        <div>
                                                            <div style="font-weight:600;font-size:0.9rem;"><%# Eval("name") %></div>
                                                            <small style="color:#6c757d;"><%# Eval("email") %></small>
                                                        </div>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Student ID">
                                                <ItemTemplate>
                                                    <span style="font-weight:600;"><%# Eval("studentCode") %></span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Programme">
                                                <ItemTemplate>
                                                    <span class="badge-custom badge-teal"><%# Eval("programmeName") %></span>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Status">
                                                <ItemTemplate>
                                                    <%# Convert.ToBoolean(Eval("isActivated"))
                                                        ? "<span class='badge-custom badge-teal'><i class='fas fa-check-circle me-1'></i>Active</span>"
                                                        : "<span class='badge-custom badge-pending'><i class='fas fa-clock me-1'></i>Pending OTP</span>" %>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Actions" ItemStyle-Width="80px">
                                                <ItemTemplate>
                                                    <asp:LinkButton runat="server" CssClass="btn btn-sm btn-outline-danger"
                                                        CommandName="DeleteRow" CommandArgument='<%# Eval("studentID") %>'
                                                        OnClientClick="return confirm('Delete this student?');">
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

                    <!-- Registration Form -->
                    <div class="col-lg-4">
                        <div class="content-card">
                            <div class="card-body text-center">
                                <div class="student-icon"><i class="fas fa-user-graduate"></i></div>
                                <h5 class="mb-2">Register New Student</h5>
                                <p class="gen-note text-start mb-4">
                                    <i class="fas fa-magic me-1"></i>
                                    Student ID, college email &amp; a temporary password are generated automatically.
                                    A 6-digit activation code is emailed to the student's personal email.
                                </p>

                                <div class="text-start">
                                    <div class="mb-3">
                                        <label class="form-label">Full Name <span class="req">*</span></label>
                                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Enter student's full name" />
                                        <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName"
                                            ValidationGroup="stud" CssClass="text-danger small" Display="Dynamic"
                                            ErrorMessage="Name is required." />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">IC / Passport No. <span class="req">*</span></label>
                                        <asp:TextBox ID="txtIc" runat="server" CssClass="form-control" placeholder="e.g. 040101-07-1234" />
                                        <asp:RequiredFieldValidator ID="rfvIc" runat="server" ControlToValidate="txtIc"
                                            ValidationGroup="stud" CssClass="text-danger small" Display="Dynamic"
                                            ErrorMessage="IC / Passport number is required." />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Personal Email <span class="req">*</span></label>
                                        <asp:TextBox ID="txtPersonalEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="student@gmail.com" />
                                        <small class="text-muted">The activation code is sent here.</small>
                                        <asp:RequiredFieldValidator ID="rfvPersonalEmail" runat="server" ControlToValidate="txtPersonalEmail"
                                            ValidationGroup="stud" CssClass="text-danger small d-block" Display="Dynamic"
                                            ErrorMessage="Personal email is required." />
                                        <asp:RegularExpressionValidator ID="revPersonalEmail" runat="server" ControlToValidate="txtPersonalEmail"
                                            ValidationGroup="stud" CssClass="text-danger small d-block" Display="Dynamic"
                                            ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                            ErrorMessage="Invalid email format." />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Phone Number <span class="req">*</span></label>
                                        <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="e.g. 012-3456789" />
                                        <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone"
                                            ValidationGroup="stud" CssClass="text-danger small" Display="Dynamic"
                                            ErrorMessage="Phone number is required." />
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label">Programme <span class="req">*</span></label>
                                        <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-select" />
                                        <asp:RequiredFieldValidator ID="rfvProgramme" runat="server" ControlToValidate="ddlProgramme"
                                            ValidationGroup="stud" CssClass="text-danger small" Display="Dynamic"
                                            InitialValue="" ErrorMessage="Please select a programme." />
                                    </div>

                                    <div class="mb-4">
                                        <label class="form-label">Intake Semester</label>
                                        <asp:DropDownList ID="ddlIntake" runat="server" CssClass="form-select" />
                                    </div>

                                    <div class="d-grid gap-2">
                                        <asp:Button ID="btnRegister" runat="server" Text="Register &amp; Send Code"
                                            CssClass="btn btn-save" ValidationGroup="stud" OnClick="btnRegister_Click" />
                                        <asp:Button ID="btnClear" runat="server" Text="Clear Form"
                                            CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnClear_Click" />
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
