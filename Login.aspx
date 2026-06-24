<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="StudentManagementSystem.Login" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Student Information Management System - Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        body {
            background: linear-gradient(135deg, #f8c8b0 0%, #e8e4f0 50%, #d4d0e8 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .login-container {
            background: rgba(255, 255, 255, 0.15); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
            width: 100%;
            max-width: 1000px;
            min-height: 600px;
        }
        .login-left {
            background: linear-gradient(135deg, #e8a88a 0%, #d4a5d4 100%);
            color: white;
            padding: 60px 40px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .login-left h1 { font-size: 2.5rem; font-weight: 700; margin-bottom: 20px; }
        .login-left p { font-size: 1.1rem; opacity: 0.9; line-height: 1.6; }
        .login-left .features { margin-top: 30px; }
        .login-left .feature-item {
            display: flex; align-items: center; margin-bottom: 15px; font-size: 0.95rem;
        }
        .login-left .feature-item i {
            width: 30px; height: 30px; background: rgba(255,255,255,0.2);
            border-radius: 50%; display: flex; align-items: center; justify-content: center;
            margin-right: 12px; font-size: 0.8rem;
        }
        .login-right {
            padding: 60px 50px;
            display: flex; flex-direction: column; justify-content: center;
            background: rgba(255, 255, 255, 0.1); backdrop-filter: blur(10px);
        }
        .login-right h2 { color: #2c3e50; font-weight: 700; margin-bottom: 10px; text-shadow: 0 1px 2px rgba(255,255,255,0.5); }
        .login-right .subtitle { color: #5a6c7d; margin-bottom: 35px; font-weight: 500; }
        .form-floating { margin-bottom: 20px; }
        .form-floating .form-control {
            border-radius: 12px; border: 2px solid rgba(255, 255, 255, 0.4); padding-left: 45px;
            background: rgba(255, 255, 255, 0.2); color: #2c3e50;
        }
        .form-floating .form-control::placeholder { color: rgba(44, 62, 80, 0.6); }
        .form-floating .form-control:focus {
            border-color: #e07a5f; box-shadow: 0 0 0 0.2rem rgba(224, 122, 95, 0.25);
        }
        .input-icon {
            position: absolute; left: 15px; top: 50%; transform: translateY(-50%);
            color: #95a5a6; z-index: 10;
        }
        .btn-login {
            background: linear-gradient(135deg, #e07a5f 0%, #d4a5d4 100%); border: none;
            border-radius: 12px; padding: 15px; font-weight: 600; font-size: 1rem;
            color: white; width: 100%; margin-top: 10px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn-login:hover {
            transform: translateY(-2px); box-shadow: 0 8px 25px rgba(224, 122, 95, 0.4);
        }
        .forgot-password { text-align: center; margin-top: 20px; color: #7f8c8d; }
        .forgot-password a { color: #e07a5f; text-decoration: none; font-weight: 600; }
        .system-badge {
            display: inline-block; background: rgba(255,255,255,0.2);
            padding: 8px 20px; border-radius: 20px; font-size: 0.85rem; margin-bottom: 20px;
        }
        .alert-box {
            padding: 12px 15px; border-radius: 10px; margin-bottom: 20px;
            font-size: 0.9rem; display: none;
        }
        .alert-error { background: #fde8e8; color: #c0392b; border: 1px solid #f5c6cb; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .demo-creds {
            background: rgba(255, 255, 255, 0.3); border-radius: 10px; padding: 15px; margin-top: 20px;
            font-size: 0.8rem; color: #5a6c7d; border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .demo-creds strong { color: #2c3e50; }
        @media (max-width: 768px) {
            .login-left { display: none; }
            .login-right { padding: 40px 30px; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="login-container row g-0">
                <div class="col-md-5 login-left">
                    <div class="system-badge">
                        <i class="fas fa-graduation-cap me-2"></i>Student Information Management System (SIMS)
                    </div>
                    <h1>Welcome Back!</h1>
                    <p>Access your personalized dashboard to manage academic programs, courses, student records, and more.</p>
                </div>
                <div class="col-md-7 login-right">
                    <h2>Sign In</h2>
                    <p class="subtitle">Enter your email and password</p>

                    <div id="alertBox" class="alert-box" runat="server"></div>

                    <div class="position-relative mb-3">
                        <i class="fas fa-envelope input-icon"></i>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Email Address" style="padding-left: 45px; border-radius: 12px; border: 2px solid rgba(255, 255, 255, 0.4); background: rgba(255, 255, 255, 0.2); color: #2c3e50; height: 56px;"></asp:TextBox>
                    </div>

                    <div class="position-relative mb-3">
                        <i class="fas fa-lock input-icon"></i>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" placeholder="Password" TextMode="Password" style="padding-left: 45px; border-radius: 12px; border: 2px solid rgba(255, 255, 255, 0.4); background: rgba(255, 255, 255, 0.2); color: #2c3e50; height: 56px;"></asp:TextBox>
                    </div>



                    <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="btn btn-login" OnClick="btnLogin_Click" />

                    <div class="forgot-password">
                        <a href="javascript:void(0);" onclick="showContactAdminModal();" style="color: #e07a5f; text-decoration: none; font-weight: 600;">
                            <i class="fas fa-key me-1"></i>Forgot your password?
                        </a>
                    </div>

                    <!-- Contact Admin Modal -->
                    <div id="contactAdminModal" style="display: none; position: fixed; z-index: 9999; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); backdrop-filter: blur(5px); align-items: center; justify-content: center;">
                        <div style="background: rgba(255, 255, 255, 0.95); border-radius: 20px; padding: 40px; max-width: 400px; width: 90%; text-align: center; box-shadow: 0 20px 60px rgba(0,0,0,0.3); animation: modalSlideIn 0.3s ease;">
                            <div style="width: 70px; height: 70px; background: linear-gradient(135deg, #e07a5f, #d4a5d4); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px; color: white; font-size: 1.8rem;">
                                <i class="fas fa-user-shield"></i>
                            </div>
                            <h4 style="color: #2c3e50; font-weight: 700; margin-bottom: 15px;">Contact Administrator</h4>
                            <p style="color: #7f8c8d; margin-bottom: 25px; line-height: 1.6;">Please contact the admin to reset your password.</p>
                            <button onclick="hideContactAdminModal();" style="background: linear-gradient(135deg, #e07a5f 0%, #d4a5d4 100%); border: none; border-radius: 12px; padding: 12px 40px; font-weight: 600; color: white; cursor: pointer; font-size: 1rem; transition: transform 0.2s, box-shadow 0.2s;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 8px 25px rgba(224, 122, 95, 0.4)';" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='none';">
                                I Understand
                            </button>
                        </div>
                    </div>

                    <style>
                        @keyframes modalSlideIn {
                            from { transform: translateY(-50px); opacity: 0; }
                            to { transform: translateY(0); opacity: 1; }
                        }
                    </style>

                    <script>
                        function showContactAdminModal() {
                            document.getElementById('contactAdminModal').style.display = 'flex';
                        }
                        function hideContactAdminModal() {
                            document.getElementById('contactAdminModal').style.display = 'none';
                        }
                        // Close modal when clicking outside
                        document.getElementById('contactAdminModal').addEventListener('click', function (e) {
                            if (e.target === this) hideContactAdminModal();
                        });
                    </script>


                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
