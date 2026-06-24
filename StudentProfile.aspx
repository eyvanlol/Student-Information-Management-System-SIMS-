<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentProfile.aspx.cs" Inherits="StudentManagementSystem.StudentProfile" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Student Profile</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        :root { --sidebar-width: 260px; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; }

        /* ── SIDEBAR ── */
        .sidebar {
            width: var(--sidebar-width); height: 100vh; position: fixed; left: 0; top: 0;
            background: linear-gradient(180deg, #114f46 0%, #0c2e2a 100%);
            color: white; z-index: 1000; overflow-y: auto;
        }
        .sidebar-header { padding: 25px 20px; text-align: center; border-bottom: 1px solid rgba(255,255,255,0.08); }
        .sidebar-header h4 { font-size: 0.95rem; margin-bottom: 2px; }
        .sidebar-header small { color: rgba(255,255,255,0.5); font-size: 0.75rem; }
        .nav-item { padding: 0; }
        .nav-link {
            color: rgba(255,255,255,0.7); padding: 14px 25px; display: flex; align-items: center;
            text-decoration: none; transition: all 0.3s; border-left: 4px solid transparent; font-size: 0.9rem;
        }
        .nav-link:hover, .nav-link.active {
            background: rgba(26,188,156,0.15); color: white; border-left-color: #1abc9c;
        }
        .nav-link i { width: 25px; font-size: 1rem; margin-right: 12px; }
        .nav-link span { font-size: 0.9rem; }
        .sidebar-footer { position: absolute; bottom: 0; width: 100%; padding: 15px 25px; border-top: 1px solid rgba(255,255,255,0.08); }

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

        /* ── PROFILE CARD ── */
        .profile-card {
            background: white; border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.05);
            overflow: hidden; margin-bottom: 24px;
        }
        .profile-header {
            background: linear-gradient(135deg, #0f3460, #16213e);
            padding: 40px 30px; color: white; text-align: center;
        }
        .profile-avatar {
            width: 100px; height: 100px; border-radius: 50%;
            background: linear-gradient(135deg, #1abc9c, #16a085);
            display: flex; align-items: center; justify-content: center;
            font-size: 2.5rem; color: white; margin: 0 auto 15px;
            border: 4px solid rgba(255,255,255,0.2);
        }
        .profile-header h3 { margin: 0; font-size: 1.4rem; font-weight: 700; }
        .profile-header p { margin: 5px 0 0; opacity: 0.7; font-size: 0.9rem; }

        /* ── INFO SECTIONS ── */
        .info-section { padding: 28px 30px; border-bottom: 1px solid #f0f0f0; }
        .info-section:last-child { border-bottom: none; }
        .section-title {
            font-size: 0.85rem; font-weight: 700; color: #7f8c8d;
            text-transform: uppercase; letter-spacing: 1px; margin-bottom: 20px;
            display: flex; align-items: center; gap: 8px;
        }
        .info-row { margin-bottom: 18px; }
        .info-row:last-child { margin-bottom: 0; }
        .info-label {
            font-size: 0.78rem; font-weight: 600; color: #95a5a6;
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 4px;
        }
        .info-value {
            font-size: 0.95rem; color: #2c3e50; font-weight: 500;
            padding: 10px 14px; background: #f8f9fa; border-radius: 8px;
            border: 1px solid #e9ecef; display: block;
        }

        /* ── EMERGENCY SECTION ── */
        .emergency-section {
            background: #fff8e1; border: 1px solid #ffe082; border-radius: 12px;
            padding: 24px; margin-top: 10px;
        }
        .emergency-header {
            display: flex; align-items: center; gap: 10px; margin-bottom: 18px;
        }
        .emergency-header i { color: #f39c12; font-size: 1.1rem; }
        .emergency-header h5 { margin: 0; font-size: 1rem; font-weight: 700; color: #856404; }
        .emergency-note {
            font-size: 0.82rem; color: #b7791f; background: rgba(255,255,255,0.6);
            padding: 10px 14px; border-radius: 8px; margin-bottom: 18px;
            border-left: 3px solid #f39c12;
        }

        /* ── STATUS BADGE ── */
        .status-badge {
            display: inline-block; padding: 4px 12px; border-radius: 20px;
            font-size: 0.78rem; font-weight: 600;
        }
        .status-active { background: #d4edda; color: #155724; }
        .status-inactive { background: #f8d7da; color: #721c24; }
        .status-pending { background: #fff3cd; color: #856404; }

        /* ── READ-ONLY NOTICE ── */
        .readonly-notice {
            background: #e3f2fd; border: 1px solid #90caf9; border-radius: 10px;
            padding: 14px 18px; margin-bottom: 24px; display: flex;
            align-items: center; gap: 12px; color: #1565c0;
        }
        .readonly-notice i { font-size: 1.2rem; }
        .readonly-notice span { font-size: 0.88rem; }

        /* ── TWO COLUMN LAYOUT ── */
        .two-col { display: flex; gap: 24px; }
        .two-col .col-main { flex: 2; }
        .two-col .col-side { flex: 1; }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <!-- ── SIDEBAR ── -->
    <div class="sidebar">
        <div class="sidebar-header">
            <div style="width:60px;height:60px;background:linear-gradient(135deg,#1abc9c,#16a085);border-radius:50%;margin:0 auto 10px;display:flex;align-items:center;justify-content:center;font-size:1.3rem;color:white;">
                <i class="fas fa-user-graduate"></i>
            </div>
            <h4><asp:Label ID="lblUserName" runat="server" Text="Student"></asp:Label></h4>
            <small><asp:Label ID="lblProgramme" runat="server" Text=""></asp:Label></small>
        </div>
        <nav class="mt-3">
            <div class="nav-item"><a href="StudentDashboard.aspx" class="nav-link"><i class="fas fa-home"></i><span>Dashboard</span></a></div>
            <div class="nav-item"><a href="StudentEnrolment.aspx" class="nav-link"><i class="fas fa-clipboard-check"></i><span>Enrolment</span></a></div>
            <div class="nav-item"><a href="StudentAttendance.aspx" class="nav-link"><i class="fas fa-calendar-check"></i><span>Attendance</span></a></div>
            <div class="nav-item"><a href="StudentResult.aspx" class="nav-link"><i class="fas fa-chart-line"></i><span>Results</span></a></div>
            <div class="nav-item"><a href="StudentTranscript.aspx" class="nav-link"><i class="fas fa-file-alt"></i><span>Transcript</span></a></div>
            <div class="nav-item"><a href="StudentNotifications.aspx" class="nav-link"><i class="fas fa-bell"></i><span>Notifications</span></a></div>
            <div class="nav-item"><a href="StudentProfile.aspx" class="nav-link active"><i class="fas fa-user-circle"></i><span>Profile</span></a></div>
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
            <h2><i class="fas fa-user-circle me-2" style="color:#1abc9c;"></i>Student Profile</h2>
            <div class="topbar-actions">
                <div class="notification-bell">
                    <i class="fas fa-bell text-muted"></i>
                    <span class="badge"><asp:Label ID="lblBellCount" runat="server" Text="0"></asp:Label></span>
                </div>
                <div style="display:flex;align-items:center;gap:10px;">
                    <div style="width:35px;height:35px;background:linear-gradient(135deg,#1abc9c,#16a085);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:0.8rem;">
                        <i class="fas fa-user"></i>
                    </div>
                    <div style="display:flex;flex-direction:column;line-height:1.2;">
                        <span style="font-size:0.9rem;font-weight:600;color:#2c3e50;"><asp:Label ID="lblTopUserName" runat="server" Text=""></asp:Label></span>
                        <span style="font-size:0.72rem;color:#7f8c8d;"><asp:Label ID="lblTopStudentId" runat="server" Text=""></asp:Label></span>
                    </div>
                </div>
            </div>
        </div>

        <div class="page-content">

            <!-- Read-only notice -->
            <div class="readonly-notice">
                <i class="fas fa-lock"></i>
                <span><strong>Read-only profile.</strong> Your profile details are maintained by the administration. To update any information, please contact the admin office.</span>
            </div>

            <div class="two-col">
                <div class="col-main">
                    <!-- Profile Card -->
                    <div class="profile-card">
                        <div class="profile-header">
                            <div class="profile-avatar">
                                <i class="fas fa-user-graduate"></i>
                            </div>
                            <h3><asp:Label ID="lblProfileName" runat="server" Text="Student Name"></asp:Label></h3>
                            <p><asp:Label ID="lblProfileProgramme" runat="server" Text="Programme"></asp:Label></p>
                        </div>

                        <!-- Academic Information -->
                        <div class="info-section">
                            <div class="section-title"><i class="fas fa-graduation-cap"></i> Academic Information</div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="info-row">
                                        <div class="info-label">Student ID</div>
                                        <asp:Label ID="lblStudentCode" runat="server" CssClass="info-value" Text="—"></asp:Label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="info-row">
                                        <div class="info-label">Programme</div>
                                        <asp:Label ID="lblProgrammeName" runat="server" CssClass="info-value" Text="—"></asp:Label>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="info-row">
                                        <div class="info-label">Intake Semester</div>
                                        <asp:Label ID="lblIntakeSemester" runat="server" CssClass="info-value" Text="—"></asp:Label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="info-row">
                                        <div class="info-label">Current CGPA</div>
                                        <asp:Label ID="lblCGPA" runat="server" CssClass="info-value" Text="—"></asp:Label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Contact Information -->
                        <div class="info-section">
                            <div class="section-title"><i class="fas fa-address-card"></i> Contact Information</div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="info-row">
                                        <div class="info-label">Institutional Email</div>
                                        <asp:Label ID="lblInstEmail" runat="server" CssClass="info-value" Text="—"></asp:Label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="info-row">
                                        <div class="info-label">Personal Email</div>
                                        <asp:Label ID="lblPersonalEmail" runat="server" CssClass="info-value" Text="—"></asp:Label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Account Status -->
                        <div class="info-section">
                            <div class="section-title"><i class="fas fa-shield-alt"></i> Account Status</div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="info-row">
                                        <div class="info-label">Account Status</div>
                                        <asp:Label ID="lblAccountStatus" runat="server" CssClass="status-badge status-active" Text="Active"></asp:Label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-side">
                    <!-- Emergency Contact Card -->
                    <div class="profile-card">
                        <div class="emergency-section">
                            <div class="emergency-header">
                                <i class="fas fa-exclamation-circle"></i>
                                <h5>Emergency Contact</h5>
                            </div>
                            <div class="emergency-note">
                                <i class="fas fa-info-circle me-1"></i>
                                This contact is used <strong>exclusively</strong> for attendance warning notifications. It is not used for any other system function.
                            </div>
                            <div class="info-row">
                                <div class="info-label">Contact Name</div>
                                <asp:Label ID="lblEmergencyName" runat="server" CssClass="info-value" Text="—" style="background:white;border:1px solid #ffe082;"></asp:Label>
                            </div>
                            <div class="info-row">
                                <div class="info-label">Relationship</div>
                                <asp:Label ID="lblEmergencyRel" runat="server" CssClass="info-value" Text="—" style="background:white;border:1px solid #ffe082;"></asp:Label>
       