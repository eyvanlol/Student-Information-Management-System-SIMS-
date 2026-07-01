<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FinalResultProcessing.aspx.cs" Inherits="StudentManagementSystem.FinalResultProcessing" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Final Result Processing - Head of Programme</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        /* ── SIDEBAR (same as the other admin pages) ── */
        .sidebar {
            width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0; display: flex; flex-direction: column;
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
        .nav-link:hover, .nav-link.active { background: rgba(255,255,255,0.1); color: white; border-left-color: #3498db; }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .sidebar nav { flex: 1 1 auto; overflow-y: auto; }
        .sidebar-footer { margin-top: auto; flex-shrink: 0; width: 100%; padding: 15px 25px; border-top: 1px solid rgba(255,255,255,0.1); }

        /* ── MAIN ── */
        .main-content { margin-left: var(--sidebar-width); padding: 0; min-height: 100vh; }
        .topbar {
            background: white; padding: 15px 30px; display: flex; justify-content: space-between;
            align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 100;
        }
        .topbar h2 { font-size: 1.4rem; color: #2c3e50; margin: 0; }
        .page-content { padding: 30px; }

        /* ── CARDS ── */
        .content-card { background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); margin-bottom: 25px; overflow: hidden; }
        .card-header-custom { padding: 20px 25px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
        .card-header-custom h5 { margin: 0; font-weight: 700; color: #2c3e50; }
        .card-body-custom { padding: 25px; }

        /* ── TABLE ── */
        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th { background: #f8f9fa; padding: 12px 15px; font-size: 0.78rem; font-weight: 700; color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; text-align: left; }
        .table-custom td { padding: 12px 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.88rem; color: #2c3e50; vertical-align: middle; }
        .table-custom tr:last-child td { border-bottom: none; }
        .table-custom tr:hover td { background: #f8f9fa; }

        /* ── STATUS BADGES ── */
        .badge-advancing { background: #d4edda; color: #155724; padding: 5px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; }
        .badge-retake    { background: #fff3cd; color: #856404; padding: 5px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; }
        .badge-resit     { background: #d1ecf1; color: #0c5460; padding: 5px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; }
        .badge-new       { background: #e2e3e5; color: #383d41; padding: 5px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 700; }

        /* ── ALERT ── */
        .alert-msg { padding: 12px 18px; border-radius: 10px; font-size: 0.88rem; margin-bottom: 20px; display: none; }
        .alert-msg.show { display: block; }
        .alert-success-custom { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-danger-custom  { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- ── SIDEBAR ── -->
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
                <div class="nav-item"><a href="ManageUsers.aspx" class="nav-link"><i class="fas fa-users"></i><span>Manage Users</span></a></div>
                <div class="nav-item"><a href="ManageEnrolment.aspx" class="nav-link"><i class="fas fa-clipboard-check"></i><span>Enrolment</span></a></div>
                <div class="nav-item"><a href="FinalResultProcessing.aspx" class="nav-link active"><i class="fas fa-arrow-trend-up"></i><span>Result Processing</span></a></div>
                <div class="nav-item"><a href="StudentStatistics.aspx" class="nav-link"><i class="fas fa-chart-pie"></i><span>Statistics</span></a></div>
                <div class="nav-item"><a href="Announcements.aspx" class="nav-link"><i class="fas fa-bullhorn"></i><span>Announcements</span></a></div>
            </nav>
            <div class="sidebar-footer">
                <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-link" OnClick="btnLogout_Click" style="padding:10px 0;">
                    <i class="fas fa-sign-out-alt"></i><span>Logout</span>
                </asp:LinkButton>
            </div>
        </div>

        <!-- ── MAIN CONTENT ── -->
        <div class="main-content">
            <div class="topbar">
                <h2><i class="fas fa-arrow-trend-up me-2 text-primary"></i>Final Exam Result Processing</h2>
                <div style="display:flex;align-items:center;gap:10px;">
                    <div style="width:35px;height:35px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                        <i class="fas fa-user"></i>
                    </div>
                    <span style="font-size:0.9rem;font-weight:600;color:#2c3e50;"><asp:Label ID="lblTopUserName" runat="server" Text=""></asp:Label></span>
                </div>
            </div>

            <div class="page-content">

                <asp:Label ID="lblMessage" runat="server" CssClass="alert-msg" EnableViewState="false"></asp:Label>

                <!-- ── STEP 1: choose a semester ── -->
                <div class="content-card">
                    <div class="card-header-custom">
                        <h5><i class="fas fa-gears me-2 text-primary"></i>Process a Semester's Results</h5>
                    </div>
                    <div class="card-body-custom">
                        <p class="text-muted" style="font-size:0.88rem;">
                            After exam results are published, choose the semester below and preview each student's outcome.
                            The system reads their grades and decides <strong>Advancing</strong>, <strong>Retake</strong>, or <strong>Resit</strong>
                            automatically. Nothing is saved until you click <em>Apply Progression</em>.
                        </p>
                        <div style="display:flex;align-items:center;gap:12px;flex-wrap:wrap;">
                            <label style="font-weight:600;color:#2c3e50;margin:0;">Semester:</label>
                            <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select" style="max-width:320px;"></asp:DropDownList>
                            <asp:Button ID="btnPreview" runat="server" Text="Preview Outcomes" CssClass="btn btn-primary" OnClick="btnPreview_Click" />
                        </div>
                    </div>
                </div>

                <!-- ── STEP 2: preview + commit ── -->
                <asp:Panel ID="pnlResults" runat="server" Visible="false" CssClass="content-card">
                    <div class="card-header-custom">
                        <h5><i class="fas fa-list-check me-2 text-primary"></i>Progression Preview</h5>
                        <asp:Button ID="btnCommit" runat="server" Text="Apply Progression" CssClass="btn btn-success" OnClick="btnCommit_Click" />
                    </div>
                    <div class="card-body-custom">
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th>Student</th>
                                    <th>Current Sem</th>
                                    <th>Results</th>
                                    <th>Outcome</th>
                                    <th>Next Sem</th>
                                    <th>Subjects to Retake / Resit</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptOutcomes" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td>
                                                <strong><%# Eval("StudentName") %></strong><br />
                                                <small class="text-muted"><%# Eval("StudentCode") %></small>
                                            </td>
                                            <td><%# Eval("CurrentSemester") %></td>
                                            <td><%# Eval("ResultsSummary") %></td>
                                            <td><span class="<%# GetStatusBadge(Eval("Status").ToString()) %>"><%# Eval("Status") %></span></td>
                                            <td><%# Eval("NextSemDisplay") %></td>
                                            <td><%# Eval("SubjectsDisplay") %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </asp:Panel>

            </div>
        </div>

        <script>
            // Reveal the server-rendered alert (matches the other admin pages).
            (function () {
                var m = document.getElementById('<%= lblMessage.ClientID %>');
                if (m && m.innerHTML.trim() !== '') m.classList.add('show');
            })();
        </script>
    </form>
</body>
</html>
