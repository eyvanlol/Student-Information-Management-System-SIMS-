<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentEnrolment.aspx.cs" Inherits="StudentManagementSystem.StudentEnrolment" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Enrolment - Student</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        /* ── SIDEBAR ── */
        .sidebar {
            width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0;
            background: linear-gradient(180deg, #1a5fa8 0%, #2980b9 100%);
            color: white; z-index: 1000; overflow-y: auto;
        }
        .sidebar-header { padding: 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.15); }
        .sidebar-header h4 { font-size: 0.95rem; margin-bottom: 2px; }
        .sidebar-header small { color: rgba(255,255,255,0.65); font-size: 0.75rem; }
        .nav-item { padding: 0; }
        .nav-link {
            color: rgba(255,255,255,0.8); padding: 13px 25px; display: flex; align-items: center;
            text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent; font-size: 0.9rem;
        }
        .nav-link:hover, .nav-link.active { background: rgba(255,255,255,0.15); color: white; border-left-color: #fff; }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .nav-link span { font-size: 0.9rem; }
        .sidebar-footer { position: absolute; bottom: 0; width: 100%; padding: 15px 25px; border-top: 1px solid rgba(255,255,255,0.15); }

        /* ── MAIN ── */
        .main-content { margin-left: var(--sidebar-width); padding: 0; min-height: 100vh; }
        .topbar {
            background: white; padding: 15px 30px; display: flex; justify-content: space-between;
            align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 100;
        }
        .topbar h2 { font-size: 1.4rem; color: #2c3e50; margin: 0; }
        .topbar-actions { display: flex; align-items: center; gap: 15px; }
        .notification-bell {
            position: relative; width: 40px; height: 40px; border-radius: 50%;
            background: #f8f9fa; display: flex; align-items: center; justify-content: center; cursor: pointer;
        }
        .notification-bell:hover { background: #e9ecef; }
        .notification-bell .badge {
            position: absolute; top: -2px; right: -2px; background: #e74c3c; color: white;
            font-size: 0.65rem; padding: 3px 6px; border-radius: 10px;
        }
        .user-dropdown {
            display: flex; align-items: center; gap: 10px; cursor: pointer;
            padding: 8px 15px; border-radius: 10px; transition: all 0.3s;
        }
        .user-dropdown:hover { background: #f8f9fa; }
        .user-dropdown span { font-size: 0.9rem; font-weight: 600; color: #2c3e50; }

        /* ── CONTENT ── */
        .page-content { padding: 30px; }

        /* ── STATUS BANNER ── */
        .status-banner {
            border-radius: 12px; padding: 16px 22px; margin-bottom: 24px;
            display: flex; align-items: center; gap: 14px;
        }
        .banner-open   { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
        .banner-closed { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
        .banner-icon   { font-size: 1.4rem; }
        .banner-title  { font-weight: 700; font-size: 1rem; margin-bottom: 2px; }
        .banner-sub    { font-size: 0.83rem; opacity: 0.85; }

        /* ── CARDS ── */
        .content-card { background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); margin-bottom: 24px; overflow: hidden; }
        .card-header-custom { padding: 18px 24px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; }
        .card-header-custom h5 { margin: 0; font-weight: 700; color: #2c3e50; font-size: 1rem; }
        .card-body-custom { padding: 24px; }

        /* ── TABLE ── */
        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th { background: #f8f9fa; padding: 12px 15px; font-size: 0.78rem; font-weight: 700; color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; }
        .table-custom td { padding: 13px 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.88rem; color: #2c3e50; vertical-align: middle; }
        .table-custom tr:last-child td { border-bottom: none; }
        .table-custom tr:hover td { background: #f8f9fa; }

        /* ── BADGES ── */
        .badge-enrolled    { background: #d4edda; color: #155724; padding: 5px 11px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-pending     { background: #fff3cd; color: #856404; padding: 5px 11px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-confirmed   { background: #d1ecf1; color: #0c5460; padding: 5px 11px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-dropped     { background: #f8d7da; color: #721c24; padding: 5px 11px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-rejected    { background: #e2e3e5; color: #383d41; padding: 5px 11px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-drop-req    { background: #fdebd0; color: #7e5109; padding: 5px 11px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }

        /* ── BUTTONS ── */
        .btn-confirm-all { background: #27ae60; border: none; color: white; padding: 9px 22px; border-radius: 8px; font-size: 0.88rem; font-weight: 700; cursor: pointer; }
        .btn-confirm-all:hover { background: #229954; }
        .btn-drop { background: transparent; border: 1px solid #e74c3c; color: #e74c3c; padding: 5px 13px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; cursor: pointer; transition: all 0.2s; }
        .btn-drop:hover { background: #e74c3c; color: white; }
        .btn-disabled { background: transparent; border: 1px solid #dee2e6; color: #adb5bd; padding: 5px 13px; border-radius: 6px; font-size: 0.8rem; cursor: not-allowed; }

        /* ── ALERT ── */
        .alert-msg { padding: 12px 18px; border-radius: 10px; font-size: 0.88rem; margin-bottom: 20px; display: none; }
        .alert-success-custom { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-danger-custom  { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        /* ── EMPTY STATE ── */
        .empty-state { text-align: center; padding: 50px 20px; color: #adb5bd; }
        .empty-state i { font-size: 3rem; display: block; margin-bottom: 12px; }
        .empty-state p { font-size: 0.9rem; }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <!-- ── SIDEBAR ── -->
    <div class="sidebar">
        <div class="sidebar-header">
            <div style="width:50px;height:50px;background:rgba(255,255,255,0.2);border-radius:50%;margin:0 auto 10px;display:flex;align-items:center;justify-content:center;font-size:1.2rem;color:white;">
                <i class="fas fa-user-graduate"></i>
            </div>
            <h4><asp:Label ID="lblUserName" runat="server" Text="Student"></asp:Label></h4>
            <small><asp:Label ID="lblProgramme" runat="server" Text=""></asp:Label></small>
        </div>
        <nav class="mt-3">
                <div class="nav-item"><a href="StudentDashboard.aspx" class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
                <div class="nav-item"><a href="StudentEnrolment.aspx" class="nav-link active"><i class="fas fa-clipboard-check"></i><span>Enrolment</span></a></div>
                <div class="nav-item"><a href="StudentAttendance.aspx" class="nav-link"><i class="fas fa-calendar-check"></i><span>Attendance</span></a></div>
                <div class="nav-item"><a href="StudentResult.aspx" class="nav-link"><i class="fas fa-chart-line"></i><span>Results</span></a></div>
                <div class="nav-item"><a href="StudentTranscript.aspx" class="nav-link"><i class="fas fa-file-alt"></i><span>Transcript</span></a></div>
                <div class="nav-item"><a href="StudentNotifications.aspx" class="nav-link"><i class="fas fa-bell"></i><span>Notifications</span></a></div>
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
            <h2><i class="fas fa-clipboard-list me-2 text-primary"></i>My Enrolment</h2>
            <div class="topbar-actions">
                <div class="notification-bell">
                    <i class="fas fa-bell text-muted"></i>
                    <span class="badge"><asp:Label ID="lblBellCount" runat="server" Text="0"></asp:Label></span>
                </div>
                <div style="display:flex;align-items:center;gap:10px;">
                        <div style="width:35px;height:35px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                            <i class="fas fa-user"></i>
                        </div>
                        <span style="font-size:0.9rem;font-weight:600;color:#2c3e50;"><asp:Label ID="lblTopUserName" runat="server" Text=""></asp:Label></span>
                    </div>
            </div>
        </div>

        <div class="page-content">

            <!-- Alert message -->
            <asp:Label ID="lblMessage" runat="server" CssClass="alert-msg" EnableViewState="false"></asp:Label>

            <!-- Enrolment window status banner -->
            <asp:Panel ID="pnlWindowOpen" runat="server" Visible="false">
                <div class="status-banner banner-open">
                    <div class="banner-icon"><i class="fas fa-lock-open"></i></div>
                    <div>
                        <div class="banner-title">Enrolment window is OPEN</div>
                        <div class="banner-sub">
                            <asp:Label ID="lblWindowDetails" runat="server"></asp:Label>
                            &mdash; You can confirm your courses or submit drop requests.
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlWindowClosed" runat="server" Visible="false">
                <div class="status-banner banner-closed">
                    <div class="banner-icon"><i class="fas fa-lock"></i></div>
                    <div>
                        <div class="banner-title">Enrolment window is CLOSED</div>
                        <div class="banner-sub">Your courses are confirmed for this semester. No changes can be made.</div>
                    </div>
                </div>
            </asp:Panel>

            <!-- ══ UPCOMING SEMESTER COURSES (pending/enrolled — action available) ══ -->
            <asp:Panel ID="pnlUpcoming" runat="server" Visible="false">
                <div class="content-card">
                    <div class="card-header-custom">
                        <h5>
                            <i class="fas fa-clock me-2 text-warning"></i>
                            Upcoming semester —
                            <asp:Label ID="lblUpcomingSemester" runat="server" style="color:#f39c12"></asp:Label>
                        </h5>
                        <asp:Button
                            ID="btnConfirmAll"
                            runat="server"
                            Text="Confirm all courses"
                            CssClass="btn-confirm-all"
                            OnClick="btnConfirmAll_Click"
                            OnClientClick="return confirm('Confirm enrolment for all pending courses?');" />
                    </div>
                    <div class="card-body-custom p-0">
                        <asp:GridView
                            ID="gvUpcoming"
                            runat="server"
                            AutoGenerateColumns="false"
                            CssClass="table-custom"
                            OnRowCommand="gvUpcoming_RowCommand"
                            EmptyDataText="No courses assigned for upcoming semester yet."
                            EmptyDataRowStyle-CssClass="text-center p-4 text-muted">
                            <Columns>
                                <asp:BoundField DataField="courseCode" HeaderText="Code"        ItemStyle-CssClass="font-monospace" />
                                <asp:BoundField DataField="courseName" HeaderText="Course name" />
                                <asp:BoundField DataField="creditHour" HeaderText="Credit hrs"  ItemStyle-HorizontalAlign="Center" />
                                <asp:BoundField DataField="semester"   HeaderText="Semester"    />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='<%# GetStatusBadge(Eval("status").ToString()) %>'>
                                            <%# GetStatusLabel(Eval("status").ToString()) %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Action">
                                    <ItemTemplate>
                                        <%# GetActionButton(Eval("enrolmentID"), Eval("status").ToString()) %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                    <div style="padding:14px 20px;background:#f8f9fa;font-size:0.82rem;color:#7f8c8d;border-top:1px solid #f0f0f0;">
                        <i class="fas fa-info-circle me-1"></i>
                        Click <strong>Confirm all courses</strong> to enrol. Use <strong>Drop</strong> on individual courses to request a drop before confirming.
                        Drop requests require HOP approval.
                    </div>
                </div>
            </asp:Panel>

            <!-- ══ CURRENT SEMESTER CONFIRMED COURSES ══ -->
            <div class="content-card">
                <div class="card-header-custom">
                    <h5>
                        <i class="fas fa-check-circle me-2 text-success"></i>
                        Current semester &mdash;
                        <asp:Label ID="lblCurrentSemester" runat="server" style="color:#27ae60"></asp:Label>
                    </h5>
                </div>
                <div class="card-body-custom p-0">
                    <asp:GridView
                        ID="gvCurrent"
                        runat="server"
                        AutoGenerateColumns="false"
                        CssClass="table-custom"
                        EmptyDataText="No enrolled courses for current semester."
                        EmptyDataRowStyle-CssClass="text-center p-4 text-muted">
                        <Columns>
                            <asp:BoundField DataField="courseCode"  HeaderText="Code"        ItemStyle-CssClass="font-monospace" />
                            <asp:BoundField DataField="courseName"  HeaderText="Course name" />
                            <asp:BoundField DataField="creditHour"  HeaderText="Credit hrs"  ItemStyle-HorizontalAlign="Center" />
                            <asp:BoundField DataField="lecturerName" HeaderText="Lecturer"   />
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <span class='<%# GetStatusBadge(Eval("status").ToString()) %>'>
                                        <%# GetStatusLabel(Eval("status").ToString()) %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <!-- ══ DROP REQUESTS STATUS ══ -->
            <asp:Panel ID="pnlDropRequests" runat="server" Visible="false">
                <div class="content-card">
                    <div class="card-header-custom">
                        <h5><i class="fas fa-minus-circle me-2 text-danger"></i>My drop requests</h5>
                    </div>
                    <div class="card-body-custom p-0">
                        <asp:GridView
                            ID="gvDropRequests"
                            runat="server"
                            AutoGenerateColumns="false"
                            CssClass="table-custom"
                            EmptyDataText="No drop requests."
                            EmptyDataRowStyle-CssClass="text-center p-4 text-muted">
                            <Columns>
                                <asp:BoundField DataField="courseCode" HeaderText="Code"        ItemStyle-CssClass="font-monospace" />
                                <asp:BoundField DataField="courseName" HeaderText="Course name" />
                                <asp:BoundField DataField="semester"   HeaderText="Semester"    />
                                <asp:TemplateField HeaderText="Drop status">
                                    <ItemTemplate>
                                        <span class='<%# GetStatusBadge(Eval("status").ToString()) %>'>
                                            <%# GetStatusLabel(Eval("status").ToString()) %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Result">
                                    <ItemTemplate>
                                        <%# GetDropResult(Eval("status").ToString()) %>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </asp:Panel>

        </div>
    </div>

</form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    window.onload = function () {
        var msg = document.getElementById('<%= lblMessage.ClientID %>');
        if (msg !== null && msg.innerText.trim() !== '') {
            msg.style.display = 'block';
            setTimeout(function () { msg.style.display = 'none'; }, 5000);
        }
    };
</script>
</body>
</html>
