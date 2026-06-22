<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VerifyOtp.aspx.cs" Inherits="StudentManagementSystem.VerifyOtp" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Verify Account - SIMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" />
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #2c3e50, #34495e); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .verify-card { background: #fff; border-radius: 16px; box-shadow: 0 15px 40px rgba(0,0,0,0.25); width: 100%; max-width: 420px; overflow: hidden; }
        .verify-head { background: linear-gradient(135deg, #1abc9c, #16a085); color: #fff; padding: 28px; text-align: center; }
        .verify-head .icon { width: 64px; height: 64px; background: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.6rem; margin: 0 auto 12px; }
        .verify-head h4 { margin: 0; font-weight: 700; }
        .verify-head p { margin: 6px 0 0; opacity: .9; font-size: .85rem; }
        .verify-body { padding: 28px; }
        .otp-input { font-size: 1.6rem; letter-spacing: 10px; text-align: center; font-weight: 700; }
        .btn-verify { background: linear-gradient(135deg, #1abc9c, #16a085); border: none; color: #fff; font-weight: 600; border-radius: 10px; padding: 12px; }
        .alert-box { display: none; border-radius: 10px; font-size: .85rem; padding: 10px 14px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="verify-card">
            <div class="verify-head">
                <div class="icon"><i class="fas fa-shield-halved"></i></div>
                <h4>Verify Your Account</h4>
                <p>Enter the 6-digit code sent to <asp:Label ID="lblMaskedEmail" runat="server" Text="your email" /></p>
            </div>
            <div class="verify-body">
                <div id="alertBox" runat="server" class="alert-box mb-3"></div>

                <div class="mb-3">
                    <label class="form-label fw-semibold">Activation Code</label>
                    <asp:TextBox ID="txtOtp" runat="server" CssClass="form-control otp-input" MaxLength="6"
                        placeholder="######" TextMode="SingleLine" />
                    <asp:RequiredFieldValidator ID="rfvOtp" runat="server" ControlToValidate="txtOtp"
                        ValidationGroup="otp" CssClass="text-danger small" Display="Dynamic"
                        ErrorMessage="Please enter the 6-digit code." />
                    <asp:RegularExpressionValidator ID="revOtp" runat="server" ControlToValidate="txtOtp"
                        ValidationGroup="otp" CssClass="text-danger small d-block" Display="Dynamic"
                        ValidationExpression="^\d{6}$" ErrorMessage="The code is 6 digits." />
                </div>

                <div class="d-grid mb-3">
                    <asp:Button ID="btnVerify" runat="server" Text="Verify &amp; Continue"
                        CssClass="btn btn-verify" ValidationGroup="otp" OnClick="btnVerify_Click" />
                </div>

                <div class="text-center">
                    <asp:LinkButton ID="btnResend" runat="server" CssClass="small text-decoration-none"
                        CausesValidation="false" OnClick="btnResend_Click">
                        <i class="fas fa-paper-plane me-1"></i>Resend code
                    </asp:LinkButton>
                    <span class="text-muted small"> &middot; </span>
                    <a href="Login.aspx" class="small text-decoration-none">Back to login</a>
                </div>
            </div>
        </div>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
