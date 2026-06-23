<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Reports.aspx.cs" Inherits="StudentManagementSystem.Reports" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Generate Reports - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; --primary: #2c3e50; --secondary: #3498db; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }
        .sidebar { width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0; background: linear-gradient(180deg, #2c3e50 0%, #34495e 100%); color: white; z-index: 1000; overflow-y: auto; }
        .sidebar-header { padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-header h4 { font-size: 1rem; margin-bottom: 3px; margin-top: 10px;}
        .sidebar-header small { color: rgba(255,255,255,0.6); font-size: 0.75rem; }
        .nav-item { padding: 0; }
        .nav-link { color: rgba(255,255,255,0.8); padding: 14px 25px; display: flex; align-items: center; text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent; }
        .nav-link:hover, .nav-link.active { background: rgba(255,255,255,0.1); color: white; border-left-color: #3498db; }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .sidebar-footer { position: absolute; bottom: 0; width: 100%; padding: 15px 25px; border-top: 1px solid rgba(255,255,255,0.1); }
        .main-content { margin-left: var(--sidebar-width); padding: 0; min-height: 100vh; }
        .topbar { background: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 100; }
        .topbar h2 { font-size: 1.4rem; color: #2c3e50; margin: 0; }
        .dashboard-content { padding: 30px; }
        .content-card { background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); overflow: hidden; margin-bottom: 25px; }
        .card-header { padding: 20px 25px; border-bottom: 1px solid #f0f0f0; display: flex; justify-content: space-between; align-items: center; background: white;}
        .card-header h5 { margin: 0; font-weight: 700; color: #2c3e50; }
        .table-custom { width: 100%; margin-bottom: 0; }
        .table-custom th { background: #f8f9fa; padding: 15px 25px; font-size: 0.8rem; font-weight: 700; color: #7f8c8d; text-transform: uppercase; border: none; letter-spacing: 0.5px; }
        .table-custom td { padding: 15px 25px; border-bottom: 1px solid #f0f0f0; font-size: 0.95rem; color: #2c3e50; vertical-align: middle;}
        .filter-panel { background: #f8f9fa; padding: 25px; border-radius: 12px; border: 1px solid #e9ecef; }
        .form-label { font-weight: 600; color: #2c3e50; font-size: 0.85rem; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="sidebar">
            <div class="sidebar-header">
                <div style="width:60px;height:60px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;margin:0 auto;display:flex;align-items:center;justify-content:center;font-size:1.3rem;color:white;">
                    <i class="fas fa-user-shield"></i>
                </div>
                <h4><asp:Label ID="lblUserName" runat="server" Text="Admin"></asp:Label></h4>
                <small>Administrator</small>
            </div>
            <nav class="mt-3">
                <div class="nav-item"><a href="AdminDashboard.aspx" class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
                <div class="nav-item"><a href="Reports.aspx" class="nav-link active"><i class="fas fa-file-export"></i><span>Reports</span></a></div>
                <div class="nav-item"><a href="AtRiskStudents.aspx" class="nav-link"><i class="fas fa-exclamation-triangle"></i><span>At-Risk Students</span></a></div>
            </nav>
            <div class="sidebar-footer">
                <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-link" OnClick="btnLogout_Click" style="padding:10px 0;">
                    <i class="fas fa-sign-out-alt"></i><span>Logout</span>
                </asp:LinkButton>
            </div>
        </div>

        <div class="main-content">
            <div class="topbar">
                <h2><i class="fas fa-file-export me-2 text-primary"></i>System Reports</h2>
            </div>
            <div class="dashboard-content">
                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-success fw-bold shadow-sm" style="border-radius: 12px;">
                    <i class="fas fa-check-circle me-2"></i><asp:Label ID="lblMessage" runat="server"></asp:Label>
                </asp:Panel>

                <div class="content-card">
                    <div class="card-header"><h5><i class="fas fa-filter me-2 text-primary"></i>Report Configuration</h5></div>
                    <div class="card-body">
                        <div class="filter-panel">
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label class="form-label">Report Type</label>
                                    <asp:DropDownList ID="ddlReportType" runat="server" CssClass="form-select shadow-sm">
                                        <asp:ListItem Text="Enrolment Report" Value="Enrolment"></asp:ListItem>
                                        <asp:ListItem Text="Performance Report" Value="Performance"></asp:ListItem>
                                        <asp:ListItem Text="Attendance Report" Value="Attendance"></asp:ListItem>
                                    </asp:DropDownList>  
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Programme</label>
                                    <asp:DropDownList ID="ddlProgramme" runat="server" CssClass="form-select shadow-sm">
                                        <asp:ListItem Text="-- All Programmes --" Value="ALL"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Semester</label>
                                    <asp:DropDownList ID="ddlSemester" runat="server" CssClass="form-select shadow-sm">
                                        <asp:ListItem Text="-- All Semesters --" Value="ALL"></asp:ListItem>
                                        <asp:ListItem Text="Jan 2026" Value="Jan2026"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Course / Class</label>
                                    <asp:DropDownList ID="ddlCourse" runat="server" CssClass="form-select shadow-sm">
                                        <asp:ListItem Text="-- All Courses --" Value="ALL"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                
                                <div class="col-md-4 mt-4">
                                    <label class="form-label">Sort Order (Main Metric)</label>
                                    <asp:DropDownList ID="ddlSortOrder" runat="server" CssClass="form-select shadow-sm">
                                        <asp:ListItem Text="-- Default --" Value="DEFAULT"></asp:ListItem>
                                        <asp:ListItem Text="Highest to Lowest" Value="DESC"></asp:ListItem>
                                        <asp:ListItem Text="Lowest to Highest" Value="ASC"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4 mt-4">
                                    <label class="form-label">Date Range (Start)</label>
                                    <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date" CssClass="form-control shadow-sm"></asp:TextBox>
                                </div>
                                <div class="col-md-4 mt-4">
                                    <label class="form-label">Date Range (End)</label>
                                    <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date" CssClass="form-control shadow-sm"></asp:TextBox>
                                </div>
                            </div>
                            <div class="mt-4 pt-3 border-top text-end">
                                <asp:Button ID="btnGenerate" runat="server" Text="Generate Preview" CssClass="btn btn-primary px-4 fw-bold shadow-sm" OnClick="btnGenerate_Click" />
                            </div>
                        </div>
                    </div>
                </div>
                  
                <div class="content-card"> 
                    <div class="card-header"><h5><i class="fas fa-table me-2 text-primary"></i>Report Preview & Export</h5></div>
                    <div class="bg-light p-3 border-bottom d-flex justify-content-end gap-2">
                        <asp:Button ID="btnExportCSV" runat="server" Text="Export to CSV" CssClass="btn btn-outline-secondary fw-bold shadow-sm" OnClick="btnExportCSV_Click" />
                        <asp:Button ID="btnExportExcel" runat="server" Text="Export to Excel" CssClass="btn btn-success fw-bold shadow-sm" OnClick="btnExportExcel_Click" />
                        <asp:Button ID="btnExportPDF" runat="server" Text="Export to PDF" CssClass="btn btn-danger fw-bold shadow-sm" OnClick="btnExportPDF_Click" />
                    </div>
                    <div class="table-responsive p-3">
                        <asp:GridView ID="gvReportPreview" runat="server" CssClass="table-custom" GridLines="None" EmptyDataText="<div class='p-4 text-center text-muted'><i class='fas fa-file-alt fs-3 mb-2 d-block'></i>Select your filters and click Generate to view data.</div>"></asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>