<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Announcements.aspx.cs" Inherits="StudentManagementSystem.Announcements" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Announcements - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        /* ── SIDEBAR ── */
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
        text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent;
        font-size: 0.9rem;
        }
        .nav-link:hover, .nav-link.active {
            background: rgba(255,255,255,0.1); color: white; border-left-color: #3498db;
        }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .nav-link span { font-size: 0.9rem; }
        .sidebar-footer { position: absolute; bottom: 0; width: 100%; padding: 15px 25px; border-top: 1px solid rgba(255,255,255,0.1); }

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

        /* ── FORM ── */
        .form-label-custom { font-size: 0.85rem; font-weight: 600; color: #495057; margin-bottom: 5px; display: block; }
        .form-control, .form-select { border-radius: 8px; border: 1px solid #dee2e6; font-size: 0.88rem; padding: 8px 12px; width: 100%; }
        .form-control:focus, .form-select:focus { border-color: #3498db; box-shadow: 0 0 0 0.2rem rgba(52,152,219,0.25); outline: none; }
        textarea.form-control { resize: vertical; min-height: 120px; }

        /* ── AUDIENCE PILLS ── */
        .audience-row { display: flex; gap: 10px; flex-wrap: wrap; margin-bottom: 5px; }
        .audience-pill {
            display: flex; align-items: center; gap: 8px; padding: 10px 16px;
            border: 2px solid #dee2e6; border-radius: 10px; cursor: pointer;
            transition: all 0.2s; font-size: 0.85rem; font-weight: 600; color: #6c757d;
            background: white;
        }
        .audience-pill:hover { border-color: #3498db; color: #3498db; }
        .audience-pill.selected { border-color: #3498db; background: #ddeeff; color: #1a5fa8; }
        .audience-pill i { font-size: 1rem; }

        /* ── PREVIEW BOX ── */
        .preview-box {
            background: #f8f9fa; border-radius: 10px; padding: 16px 20px;
            border-left: 4px solid #3498db; margin-bottom: 20px; display: none;
        }
        .preview-box.visible { display: block; }
        .preview-title { font-weight: 700; font-size: 0.95rem; color: #2c3e50; margin-bottom: 4px; }
        .preview-meta  { font-size: 0.78rem; color: #6c757d; margin-bottom: 8px; }
        .preview-body  { font-size: 0.88rem; color: #495057; line-height: 1.6; }

        /* ── HISTORY TABLE ── */
        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th { background: #f8f9fa; padding: 12px 15px; font-size: 0.78rem; font-weight: 700; color: #7f8c8d; text-transform: uppercase; letter-spacing: 0.5px; }
        .table-custom td { padding: 12px 15px; border-bottom: 1px solid #f0f0f0; font-size: 0.88rem; color: #2c3e50; vertical-align: middle; }
        .table-custom tr:last-child td { border-bottom: none; }
        .table-custom tr:hover td { background: #f8f9fa; }

        /* ── AUDIENCE BADGES ── */
        .badge-all      { background: #d1ecf1; color: #0c5460;  padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-student  { background: #d4edda; color: #155724;  padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-lecturer { background: #fff3cd; color: #856404;  padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .badge-prog     { background: #eeeeff; color: #3C3489;  padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }

        /* ── ALERT ── */
        .alert-msg { padding: 12px 18px; border-radius: 10px; font-size: 0.88rem; margin-bottom: 20px; display: none; }
        .alert-success-custom { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-danger-custom  { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        /* ── BUTTONS ── */
        .btn-broadcast { background: #3498db; border: none; color: white; padding: 10px 28px; border-radius: 8px; font-size: 0.95rem; font-weight: 700; cursor: pointer; display: flex; align-items: center; gap: 8px; }
        .btn-broadcast:hover { background: #2980b9; }
        .btn-preview   { background: white; border: 1px solid #dee2e6; color: #495057; padding: 10px 20px; border-radius: 8px; font-size: 0.88rem; font-weight: 600; cursor: pointer; }
        .btn-preview:hover { background: #f8f9fa; }

        /* ── STATS ROW ── */
        .stats-mini { display: flex; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
        .stat-mini { background: #f8f9fa; border-radius: 10px; padding: 12px 18px; flex: 1; min-width: 120px; }
        .stat-mini .val { font-size: 1.5rem; font-weight: 700; color: #2c3e50; }
        .stat-mini .lbl { font-size: 0.75rem; color: #7f8c8d; margin-top: 2px; }

        /* ── CHAR COUNT ── */
        .char-count { font-size: 0.75rem; color: #aaa; text-align: right; margin-top: 3px; }
        .char-count.near-limit { color: #c47a00; }
        .char-count.over-limit { color: #a02020; }

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

        .stats-row { margin-bottom: 25px; }
        .stat-card {
            background: white; border-radius: 15px; padding: 25px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.05);
            display: flex; align-items: center; gap: 20px; transition: transform 0.3s;
        }
        .stat-card:hover { transform: translateY(-5px); }
        .stat-icon {
            width: 60px; height: 60px; border-radius: 15px; display: flex;
            align-items: center; justify-content: center; font-size: 1.5rem; color: white;
            flex-shrink: 0;
        }
        .stat-info h3 { font-size: 1.8rem; font-weight: 700; margin: 0; color: #2c3e50; }
        .stat-info p  { color: #7f8c8d; margin: 0; font-size: 0.9rem; }
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
            <small>Administrator</small>
        </div>
       <nav class="mt-3">
        <div class="nav-item"><a href="AdminDashboard.aspx"   class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
        <div class="nav-item"><a href="RegisterStudent.aspx"  class="nav-link"><i class="fas fa-users"></i><span>Manage Users</span></a></div>
        <div class="nav-item"><a href="ManageProgrammes.aspx" class="nav-link"><i class="fas fa-book"></i><span>Manage Programmes</span></a></div>
        <div class="nav-item"><a href="ManageCourses.aspx"    class="nav-link"><i class="fas fa-graduation-cap"></i><span>Manage Courses</span></a></div>
        <div class="nav-item"><a href="ManageEnrolment.aspx"  class="nav-link"><i class="fas fa-clipboard-check"></i><span>Manage Enrolment</span></a></div>
        <div class="nav-item"><a href="#"                     class="nav-link"><i class="fas fa-chart-bar"></i><span>Student Statistics</span></a></div>
        <div class="nav-item"><a href="#"                     class="nav-link"><i class="fas fa-file-export"></i><span>Reports</span></a></div>
        <div class="nav-item"><a href="AcademicCalendar.aspx" class="nav-link"><i class="fas fa-calendar-alt"></i><span>Academic Calendar</span></a></div>
        <div class="nav-item"><a href="Announcements.aspx"    class="nav-link"><i class="fas fa-bullhorn"></i><span>Announcements</span></a></div>
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
                <h2><i class="fas fa-bullhorn me-2 text-primary"></i>Announcements</h2>
                <div class="topbar-actions">
                    <div class="notification-bell">
                        <i class="fas fa-bell text-muted"></i>
                        <span class="badge">5</span>
                    </div>
                    <div class="user-dropdown">
                        <div style="width:35px;height:35px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                            <i class="fas fa-user-shield"></i>
                        </div>
                        <span><asp:Label ID="lblTopUserName" runat="server" Text="Head of Programme"></asp:Label></span>
                        <i class="fas fa-chevron-down text-muted" style="font-size:0.7rem;"></i>
                    </div>
                </div>
            </div>
        <div class="page-content">

            <!-- Alert -->
            <asp:Label ID="lblMessage" runat="server" CssClass="alert-msg" EnableViewState="false"></asp:Label>

            <!-- Stats mini row -->
            <div class="row stats-row mb-4">
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background:linear-gradient(135deg,#667eea,#764ba2)">
                        <i class="fas fa-bullhorn"></i>
                    </div>
                    <div class="stat-info">
                        <h3><asp:Label ID="lblTotalSent" runat="server" Text="0"></asp:Label></h3>
                        <p>Total Announcements</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background:linear-gradient(135deg,#f093fb,#f5576c)">
                        <i class="fas fa-paper-plane"></i>
                    </div>
                    <div class="stat-info">
                        <h3><asp:Label ID="lblSentToday" runat="server" Text="0"></asp:Label></h3>
                        <p>Sent Today</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background:linear-gradient(135deg,#4facfe,#00f2fe)">
                        <i class="fas fa-user-graduate"></i>
                    </div>
                    <div class="stat-info">
                        <h3><asp:Label ID="lblTotalStudents" runat="server" Text="0"></asp:Label></h3>
                        <p>Active Students</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stat-card">
                    <div class="stat-icon" style="background:linear-gradient(135deg,#43e97b,#38f9d7)">
                        <i class="fas fa-user-tie"></i>
                    </div>
                    <div class="stat-info">
                        <h3><asp:Label ID="lblTotalLecturers" runat="server" Text="0"></asp:Label></h3>
                        <p>Active Lecturers</p>
                    </div>
                </div>
            </div>
        </div>

            <div class="row">

                <!-- ── LEFT: COMPOSE ── -->
                <div class="col-md-5">
                    <div class="content-card">
                        <div class="card-header-custom">
                            <h5><i class="fas fa-pen me-2 text-primary"></i>Compose Announcement</h5>
                        </div>
                        <div class="card-body-custom">

                            <!-- Title -->
                            <div class="mb-3">
                                <label class="form-label-custom">Title</label>
                                <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="Announcement title" MaxLength="200"></asp:TextBox>
                                <asp:RequiredFieldValidator
                                    ID="rfvTitle" runat="server"
                                    ControlToValidate="txtTitle"
                                    ErrorMessage="Title is required."
                                    CssClass="text-danger" Display="Dynamic"
                                    ValidationGroup="AnnForm"
                                    style="font-size:0.8rem;">
                                </asp:RequiredFieldValidator>
                            </div>

                            <!-- Message body -->
                            <div class="mb-3">
                                <label class="form-label-custom">Message</label>
                                <asp:TextBox
                                    ID="txtMessage"
                                    runat="server"
                                    CssClass="form-control"
                                    TextMode="MultiLine"
                                    Rows="5"
                                    placeholder="Write your announcement here..."
                                    MaxLength="1000"
                                    onkeyup="updateCharCount(this)">
                                </asp:TextBox>
                                <div class="char-count" id="charCount">0 / 1000 characters</div>
                                <asp:RequiredFieldValidator
                                    ID="rfvMessage" runat="server"
                                    ControlToValidate="txtMessage"
                                    ErrorMessage="Message is required."
                                    CssClass="text-danger" Display="Dynamic"
                                    ValidationGroup="AnnForm"
                                    style="font-size:0.8rem;">
                                </asp:RequiredFieldValidator>
                            </div>

                            <!-- Send to audience -->
                            <div class="mb-3">
                                <label class="form-label-custom">Send to</label>
                                <asp:DropDownList ID="ddlAudience" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAudience_Changed">
                                    <asp:ListItem Text="All students and lecturers" Value="all"></asp:ListItem>
                                    <asp:ListItem Text="Students only"             Value="student"></asp:ListItem>
                                    <asp:ListItem Text="Lecturers only"            Value="lecturer"></asp:ListItem>
                                    <asp:ListItem Text="Specific programme (students)" Value="programme"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <!-- Programme selector — shown only when "Specific programme" selected -->
                            <asp:Panel ID="pnlProgramme" runat="server" Visible="false" CssClass="mb-3">
                                <label class="form-label-custom">Select Programme</label>
                                <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-select">
                                </asp:DropDownList>
                            </asp:Panel>

                            <!-- Recipient count estimate -->
                            <div style="background:#f0f7ff;border-radius:8px;padding:10px 14px;margin-bottom:16px;font-size:0.83rem;color:#1a5fa8;">
                                <i class="fas fa-users me-1"></i>
                                Estimated recipients: <strong><asp:Label ID="lblRecipientCount" runat="server" Text="—"></asp:Label></strong>
                            </div>

                            <!-- Action buttons -->
                            <div style="display:flex;gap:10px;align-items:center;flex-wrap:wrap;">
                                <asp:Button
                                    ID="btnBroadcast"
                                    runat="server"
                                    Text="Broadcast"
                                    CssClass="btn-broadcast"
                                    OnClick="btnBroadcast_Click"
                                    ValidationGroup="AnnForm"
                                    OnClientClick="return confirm('Broadcast this announcement now?');" />
                                <button type="button" class="btn-preview" onclick="showPreview()">
                                    <i class="fas fa-eye me-1"></i>Preview
                                </button>
                            </div>

                            <!-- Preview box -->
                            <div class="preview-box mt-3" id="previewBox">
                                <div class="preview-title" id="previewTitle"></div>
                                <div class="preview-meta" id="previewMeta"></div>
                                <div class="preview-body"  id="previewBody"></div>
                            </div>

                        </div>
                    </div>
                </div>

                <!-- ── RIGHT: HISTORY ── -->
                <div class="col-md-7">
                    <div class="content-card">
                        <div class="card-header-custom">
                            <h5><i class="fas fa-history me-2 text-info"></i>Announcement History</h5>
                            <!-- Filter -->
                            <asp:DropDownList ID="ddlFilterAudience" runat="server" CssClass="form-select form-select-sm" style="width:170px;" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterAudience_Changed">
                                <asp:ListItem Text="All audiences"  Value=""></asp:ListItem>
                                <asp:ListItem Text="All (students + lecturers)" Value="all"></asp:ListItem>
                                <asp:ListItem Text="Students only"  Value="student"></asp:ListItem>
                                <asp:ListItem Text="Lecturers only" Value="lecturer"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="card-body-custom p-0">
                            <asp:GridView
                                ID="gvHistory"
                                runat="server"
                                AutoGenerateColumns="false"
                                CssClass="table-custom"
                                OnRowCommand="gvHistory_RowCommand"
                                EmptyDataText="No announcements sent yet."
                                EmptyDataRowStyle-CssClass="text-center p-4 text-muted">
                                <Columns>
                                    <asp:TemplateField HeaderText="Announcement">
                                        <ItemTemplate>
                                            <div style="font-weight:600;font-size:0.88rem;color:#2c3e50;"><%# Eval("title") %></div>
                                            <div style="font-size:0.78rem;color:#7f8c8d;margin-top:2px;max-width:280px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"><%# Eval("message") %></div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Sent to">
                                        <ItemTemplate>
                                            <span class='<%# GetAudienceBadge(Eval("recipientRole").ToString()) %>'>
                                                <%# GetAudienceLabel(Eval("recipientRole").ToString()) %>
                                            </span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Date sent">
                                        <ItemTemplate>
                                            <div style="font-size:0.83rem;"><%# Convert.ToDateTime(Eval("createdAt")).ToString("d MMM yyyy") %></div>
                                            <div style="font-size:0.75rem;color:#aaa;"><%# Convert.ToDateTime(Eval("createdAt")).ToString("h:mm tt") %></div>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Recipients">
                                        <ItemTemplate>
                                            <span style="font-weight:600;color:#2c3e50;"><%# Eval("recipientCount") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="">
                                        <ItemTemplate>
                                            <asp:LinkButton
                                                ID="btnDelete"
                                                runat="server"
                                                CommandName="DeleteAnn"
                                                CommandArgument='<%# Eval("groupKey") %>'
                                                style="font-size:0.78rem;color:#e74c3c;text-decoration:none;"
                                                OnClientClick="return confirm('Delete this announcement from history?');">
                                                <i class="fas fa-trash"></i>
                                            </asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

            </div><!-- /row -->
        </div><!-- /page-content -->
    </div><!-- /main-content -->

</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Character counter for message textarea
    function updateCharCount(el) {
        var len = el.value.length;
        var div = document.getElementById('charCount');
        div.textContent = len + ' / 1000 characters';
        div.className = 'char-count' + (len > 900 ? ' over-limit' : len > 750 ? ' near-limit' : '');
    }

    // Preview the announcement before sending
    function showPreview() {
        var title   = document.getElementById('<%= txtTitle.ClientID %>').value.trim();
        var message = document.getElementById('<%= txtMessage.ClientID %>').value.trim();
        var audience = document.getElementById('<%= ddlAudience.ClientID %>');
        var audienceText = audience.options[audience.selectedIndex].text;

        if (!title || !message) {
            alert('Please fill in both Title and Message to preview.');
            return;
        }

        var box = document.getElementById('previewBox');
        document.getElementById('previewTitle').textContent = title;
        document.getElementById('previewMeta').textContent  = 'To: ' + audienceText + '  ·  From: HOP  ·  ' + new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' });
        document.getElementById('previewBody').textContent  = message;
        box.classList.add('visible');
    }

    // Auto-show alert if present
    window.onload = function () {
        var msg = document.getElementById('<%= lblMessage.ClientID %>');
        if (msg && msg.innerText.trim() !== '') {
            msg.style.display = 'block';
            setTimeout(function () { msg.style.display = 'none'; }, 6000);
        }
        // Init char count if message has content
    var ta = document.getElementById('<%= txtMessage.ClientID %>');
    if (ta && ta.value.length > 0) updateCharCount(ta);
};
</script>
</body>
</html>
