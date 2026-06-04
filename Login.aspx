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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .login-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
            width: 100%;
            max-width: 1000px;
            min-height: 600px;
        }
        .login-left {
            background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%);
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
        }
        .login-right h2 { color: #2c3e50; font-weight: 700; margin-bottom: 10px; }
        .login-right .subtitle { color: #7f8c8d; margin-bottom: 35px; }
        .form-floating { margin-bottom: 20px; }
        .form-floating .form-control {
            border-radius: 12px; border: 2px solid #e0e0e0; padding-left: 45px;
        }
        .form-floating .form-control:focus {
            border-color: #3498db; box-shadow: 0 0 0 0.2rem rgba(52, 152, 219, 0.25);
        }
        .input-icon {
            position: absolute; left: 15px; top: 50%; transform: translateY(-50%);
            color: #95a5a6; z-index: 10;
        }
        .btn-login {
            background: linear-gradient(135deg, #3498db 0%, #2980b9 100%); border: none;
            border-radius: 12px; padding: 15px; font-weight: 600; font-size: 1rem;
            color: white; width: 100%; margin-top: 10px;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .btn-login:hover {
            transform: translateY(-2px); box-shadow: 0 8px 25px rgba(52, 152, 219, 0.4);
        }
        .forgot-password { text-align: center; margin-top: 20px; color: #7f8c8d; }
        .forgot-password a { color: #3498db; text-decoration: none; font-weight: 600; }
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
            background: #f8f9fa; border-radius: 10px; padding: 15px; margin-top: 20px;
            font-size: 0.8rem; color: #6c757d;
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

                    <div class="position-relative">
                        <i class="fas fa-envelope input-icon"></i>
                        <div class="form-floating">
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Email Address"></asp:TextBox>
                            <label for="txtEmail">Email Address</label>
                        </div>
                    </div>

                    <div class="position-relative">
                        <i class="fas fa-lock input-icon"></i>
                        <div class="form-floating">
                            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" placeholder="Password" TextMode="Password"></asp:TextBox>
                            <label for="txtPassword">Password</label>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div class="form-check">
                            <asp:CheckBox ID="chkRemember" runat="server" CssClass="form-check-input" />
                            <label class="form-check-label" for="chkRemember">Remember me</label>
                        </div>
                    </div>

                    <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="btn btn-login" OnClick="btnLogin_Click" />

                    <div class="forgot-password">
                        <a href="#"><i class="fas fa-key me-1"></i>Forgot your password?</a>
                    </div>

                    <div class="demo-creds">
                        <strong><i class="fas fa-info-circle me-1"></i>Demo Credentials:</strong><br/>
                        <b>Admin:</b> admin@college.edu / admin123<br/>
                        <b>Lecturer:</b> lecturer@college.edu / lecturer123<br/>
                        <b>Student:</b> student@college.edu / student123
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>