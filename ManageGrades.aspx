<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageGrades.aspx.cs" Inherits="StudentManagementSystem.ManageGrades" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Manage Grades & Assessments</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; --primary: #2c3e50; --secondary: #9b59b6; --accent: #e74c3c; --success: #27ae60; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        /* MATCHING PURPLE SIDEBAR */
        .sidebar { width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0; background: linear-gradient(180deg, #1a1a2e 0%, #16213e 100%); color: white; z-index: 1000; overflow-y: auto; }
        .sidebar-header { padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-avatar {
            width: 70px; height: 70px; border-radius: 50%; margin: 0 auto 10px;
            overflow: hidden; display: flex; align-items: center; justify-content: center;
            background: linear-gradient(135deg, #9b59b6, #8e44ad);
        }
        .sidebar-avatar img {
            width: 70px; height: 70px; object-fit: cover; border-radius: 50%;
            display: block;
        }
        .sidebar-header h4 { font-size: 1rem; margin-bottom: 3px; }
        .sidebar-header small { color: rgba(255,255,255,0.6); font-size: 0.75rem; }
        .nav-item { padding: 0; }
        .nav-link { color: rgba(255,255,255,0.8); padding: 14px 25px; display: flex; align-items: center; text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent; }
        .nav-link:hover, .nav-link.active { background: rgba(155, 89, 182, 0.15); color: white; border-left-color: #9b59b6; }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .nav-link span { font-size: 0.9rem; }
        .sidebar-footer { position: absolute; bottom: 0; width: 100%; padding: 15px 25px; border-top: 1px solid rgba(255,255,255,0.1); }

        .main-content { margin-left: var(--sidebar-width); min-height: 100vh; }
        .topbar { background: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
        .topbar h2 { font-size: 1.4rem; color: #2c3e50; margin: 0; }
        .topbar-actions { display: flex; align-items: center; gap: 15px; }
        .notification-bell { position: relative; width: 40px; height: 40px; border-radius: 50%; background: #f8f9fa; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.3s; }
        .notification-bell:hover { background: #e9ecef; }
        .notification-bell .badge { position: absolute; top: -2px; right: -2px; background: #e74c3c; color: white; font-size: 0.65rem; padding: 3px 6px; border-radius: 10px; }
        .user-dropdown { display: flex; align-items: center; gap: 10px; cursor: pointer; padding: 8px 15px; border-radius: 10px; transition: all 0.3s; }
        .user-dropdown:hover { background: #f8f9fa; }
        .user-dropdown span { font-size: 0.9rem; font-weight: 600; color: #2c3e50; }

        /* Card & Table Styles */
        .dashboard-content { padding: 30px; }
        .content-card { background: white; border-radius: 15px; box-shadow: 0 5px 20px rgba(0,0,0,0.05); padding: 25px; }
        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0; }
        .table-custom th { background: #f8f9fa; padding: 15px; font-size: 0.8rem; font-weight: 700; color: #7f8c8d; text-transform: uppercase; border: none; letter-spacing: 0.5px; }
        .table-custom td { padding: 15px; border-bottom: 1px solid #f0f0f0; vertical-align: middle; font-size: 0.9rem; color: #2c3e50; }
        .table-custom tr:hover td { background: #f8f9fa; }

        /* Inputs */
        .mark-input { width: 80px; text-align: center; border: 1px solid #ced4da; border-radius: 6px; padding: 5px; }
        .mark-input:focus { border-color: #9b59b6; outline: none; box-shadow: 0 0 0 0.2rem rgba(155,89,182,.25); }
        .total-box { font-weight: 700; font-size: 1.1rem; color: #2c3e50; }
        .grade-box { padding: 5px 12px; border-radius: 6px; font-weight: 700; font-size: 0.9rem; background: #e9ecef; color: #495057; display: inline-block; min-width: 40px; text-align: center; }

        .btn-purple { background: #9b59b6; color: white; border: none; }
        .btn-purple:hover { background: #8e44ad; color: white; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="sidebar">
            <div class="sidebar-header">
                <div class="sidebar-avatar">
                    <asp:Image ID="imgSidebarAvatar" runat="server" 
                        Width="70" Height="70"
                        ImageUrl="~/Uploads/ProfilePictures/default.png" 
                        AlternateText="Avatar" />
                </div>
                <h4><asp:Label ID="lblUserName" runat="server"></asp:Label></h4>
                <small>Senior Lecturer</small>
            </div>
            <nav class="mt-3">
                <div class="nav-item"><a href="LecturerDashboard.aspx"    class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
                <div class="nav-item"><a href="LecturerProfile.aspx"      class="nav-link"><i class="fas fa-user-circle"></i><span>My Profile</span></a></div>
                <div class="nav-item"><a href="LecturerCourses.aspx"      class="nav-link"><i class="fas fa-book"></i><span>My Courses</span></a></div>
                <div class="nav-item"><a href="LecturerAttendance.aspx"   class="nav-link"><i class="fas fa-clipboard-check"></i><span>Attendance</span></a></div>
                <div class="nav-item"><a href="ManageGrades.aspx"         class="nav-link active"><i class="fas fa-clipboard-list"></i><span>Grades & Assessments</span></a></div>
                <div class="nav-item"><a href="AtRiskStudents.aspx"       class="nav-link"><i class="fas fa-exclamation-triangle"></i><span>At Risk Students</span></a></div>
                <div class="nav-item"><a href="LecturerStudentProgress.aspx"       class="nav-link"><i class="fas fa-chart-bar"></i><span>Student Progress</span></a></div>
                <div class="nav-item"><a href="LecturerAnnouncements.aspx" class="nav-link"><i class="fas fa-bullhorn"></i><span>Announcements</span></a></div>
            </nav>
        </div>

        <div class="main-content">
            <div class="topbar">
                <h2><i class="fas fa-edit me-2" style="color:#9b59b6;"></i>Grades & Assessments</h2>

                <div class="topbar-actions">
                    <div class="notification-bell"><i class="fas fa-bell text-muted"></i><span class="badge">3</span></div>
                    <div style="display:flex;align-items:center;gap:10px;">
                        <div style="width:35px;height:35px;background:linear-gradient(135deg,#3498db,#2980b9);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                            <i class="fas fa-user"></i>
                        </div>
                        <span style="font-size:0.9rem;font-weight:600;color:#2c3e50;"><asp:Label ID="lblTopUserName" runat="server" Text=""></asp:Label></span>
                    </div>
                </div>
            </div>

            <div class="dashboard-content">
                <div class="content-card">

                    <div class="d-flex justify-content-between align-items-center mb-4 pb-3" style="border-bottom: 2px solid #f0f0f0;">
                        <div>
                            <h4 class="mb-1" style="color:#2c3e50; font-weight:700;">
                                <asp:DropDownList ID="ddlCourses" runat="server" CssClass="form-select border-0 shadow-sm fw-bold" 
                                    style="font-size:1.2rem; color:#9b59b6; background:#f8f9fa;" AutoPostBack="true" OnSelectedIndexChanged="ddlCourses_SelectedIndexChanged">
                                </asp:DropDownList>
                            </h4>
                            <small class="text-muted"><i class="fas fa-info-circle me-1"></i>Select a course to manage student assessments.</small>
                        </div>

                        <asp:Label ID="lblStatus" runat="server" Visible="false" CssClass="badge bg-success p-2 fs-6"></asp:Label>
                    </div>

                    <div class="table-responsive mb-4">
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th>Student ID</th>
                                    <th>Name</th>
                                    <th class="text-center">Assignment (30)</th>
                                    <th class="text-center">Mid-Term (30)</th>
                                    <th class="text-center">Final (40)</th>
                                    <th class="text-center">Total (100)</th>
                                    <th class="text-center">Grade</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptStudents" runat="server">
                                    <ItemTemplate>
                                        <tr class="student-row">
                                            <td>
                                                <strong><%# Eval("studentCode") %></strong>
                                                <asp:HiddenField ID="hfStudentID" runat="server" Value='<%# Eval("studentID") %>' />
                                            </td>
                                            <td><%# Eval("studentName") %></td>
                                            <td class="text-center">
                                                <asp:TextBox ID="txtAssignment" runat="server" CssClass="mark-input assign-input" Text='<%# Eval("assignmentMarks") %>' onkeyup="calculateRow(this)"></asp:TextBox>
                                            </td>
                                            <td class="text-center">
                                                <asp:TextBox ID="txtMidterm" runat="server" CssClass="mark-input mid-input" Text='<%# Eval("midtermMarks") %>' onkeyup="calculateRow(this)"></asp:TextBox>
                                            </td>
                                            <td class="text-center">
                                                <asp:TextBox ID="txtFinal" runat="server" CssClass="mark-input final-input" Text='<%# Eval("finalMarks") %>' onkeyup="calculateRow(this)"></asp:TextBox>
                                            </td>
                                            <td class="text-center">
                                                <span class="total-box">0</span>
                                                <asp:HiddenField ID="hfTotal" runat="server" />
                                            </td>
                                            <td class="text-center">
                                                <span class="grade-box">-</span>
                                                <asp:HiddenField ID="hfGrade" runat="server" />
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>

                    <div class="d-flex justify-content-end gap-3 mt-4 pt-3" style="border-top: 1px solid #f0f0f0;">
                        <asp:Button ID="btnSaveDraft" runat="server" Text="Save as Draft" CssClass="btn btn-outline-secondary px-4 py-2 fw-bold" OnClick="btnSaveDraft_Click" />
                        <asp:Button ID="btnPublish" runat="server" Text="Publish Marks" CssClass="btn btn-purple px-4 py-2 fw-bold shadow-sm" OnClientClick="return confirm('Publishing will make these marks visible to students. Continue?');" OnClick="btnPublish_Click" />
                    </div>

                </div>
            </div>
        </div>
    </form>

    <script>
        function calculateRow(inputElement) {
            var row = inputElement.closest('tr');

            var assign = parseFloat(row.querySelector('.assign-input').value) || 0;
            var mid = parseFloat(row.querySelector('.mid-input').value) || 0;
            var final = parseFloat(row.querySelector('.final-input').value) || 0;

            if (assign > 30) { assign = 30; row.querySelector('.assign-input').value = 30; }
            if (mid > 30) { mid = 30; row.querySelector('.mid-input').value = 30; }
            if (final > 40) { final = 40; row.querySelector('.final-input').value = 40; }

            var total = assign + mid + final;
            row.querySelector('.total-box').innerText = total.toFixed(1);
            row.querySelector('input[id*="hfTotal"]').value = total.toFixed(1);

            var grade = "F";
            var bg = "#f8d7da"; var color = "#721c24";

            if (total >= 80) { grade = "A"; bg = "#d4edda"; color = "#155724"; }
            else if (total >= 75) { grade = "A-"; bg = "#d4edda"; color = "#155724"; }
            else if (total >= 70) { grade = "B+"; bg = "#d1ecf1"; color = "#0c5460"; }
            else if (total >= 65) { grade = "B"; bg = "#d1ecf1"; color = "#0c5460"; }
            else if (total >= 60) { grade = "B-"; bg = "#d1ecf1"; color = "#0c5460"; }
            else if (total >= 55) { grade = "C+"; bg = "#fff3cd"; color = "#856404"; }
            else if (total >= 50) { grade = "C"; bg = "#fff3cd"; color = "#856404"; }

            var gradeBox = row.querySelector('.grade-box');
            gradeBox.innerText = grade;
            gradeBox.style.backgroundColor = bg;
            gradeBox.style.color = color;
            row.querySelector('input[id*="hfGrade"]').value = grade;
        }

        window.onload = function () {
            var inputs = document.querySelectorAll('.assign-input');
            inputs.forEach(input => calculateRow(input));
        }
    </script>
</body>
</html>