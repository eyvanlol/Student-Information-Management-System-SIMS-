using System;
using System.Configuration;
using System.Net;
using System.Net.Mail;

namespace StudentManagementSystem
{
    /// <summary>
    /// Sends transactional email via SMTP (Gmail by default).
    ///
    /// SMTP settings live in Web.config &lt;appSettings&gt;:
    ///   Smtp:Host      e.g. smtp.gmail.com
    ///   Smtp:Port      e.g. 587
    ///   Smtp:User      the Gmail address that sends the mail
    ///   Smtp:Password  a 16-char Gmail APP PASSWORD (NOT the account password)
    ///   Smtp:From      shown as the sender (usually same as Smtp:User)
    ///   Smtp:EnableSsl true / false
    ///
    /// Gmail app password: enable 2-Step Verification, then create one at
    /// https://myaccount.google.com/apppasswords  -> paste it into Smtp:Password.
    ///
    /// Every method throws on failure so the caller can show the real reason.
    /// </summary>
    public static class EmailHelper
    {
        private static string Cfg(string key, string fallback = "")
        {
            string v = ConfigurationManager.AppSettings[key];
            return string.IsNullOrEmpty(v) ? fallback : v;
        }

        // Builds and sends one HTML message using the Web.config SMTP settings.
        private static void Send(string toEmail, string subject, string htmlBody)
        {
            string host = Cfg("Smtp:Host", "smtp.gmail.com");
            int port = int.TryParse(Cfg("Smtp:Port", "587"), out int p) ? p : 587;
            string user = Cfg("Smtp:User");
            string pass = Cfg("Smtp:Password");
            string from = Cfg("Smtp:From", user);
            bool ssl = !string.Equals(Cfg("Smtp:EnableSsl", "true"), "false",
                                       StringComparison.OrdinalIgnoreCase);

            if (string.IsNullOrEmpty(user) || string.IsNullOrEmpty(pass))
                throw new InvalidOperationException(
                    "SMTP is not configured. Set Smtp:User and Smtp:Password in Web.config <appSettings>.");

            using (MailMessage msg = new MailMessage())
            {
                msg.From = new MailAddress(from, "SIMS Registry");
                msg.To.Add(new MailAddress(toEmail));
                msg.Subject = subject;
                msg.Body = htmlBody;
                msg.IsBodyHtml = true;

                using (SmtpClient client = new SmtpClient(host, port))
                {
                    client.EnableSsl = ssl;
                    client.DeliveryMethod = SmtpDeliveryMethod.Network;
                    client.UseDefaultCredentials = false;
                    client.Credentials = new NetworkCredential(user, pass);
                    client.Send(msg);
                }
            }
        }

        /// <summary>
        /// First-time email a new student receives: their Student ID, login email,
        /// temporary password, and the one-time activation code.
        /// </summary>
        public static void SendStudentWelcome(
            string toPersonalEmail,
            string studentName,
            string studentCode,
            string collegeEmail,
            string tempPassword,
            string otp)
        {
            string subject = "Your SIMS student account & activation code";
            string body = $@"
<div style='font-family:Segoe UI,Arial,sans-serif;max-width:560px;margin:auto;color:#2c3e50;'>
  <div style='background:linear-gradient(135deg,#1abc9c,#16a085);padding:22px 28px;border-radius:12px 12px 0 0;color:#fff;'>
    <h2 style='margin:0;font-size:1.3rem;'>Welcome to SIMS</h2>
    <p style='margin:4px 0 0;opacity:.9;'>Student Information Management System</p>
  </div>
  <div style='border:1px solid #eee;border-top:none;padding:28px;border-radius:0 0 12px 12px;'>
    <p>Hi {studentName},</p>
    <p>Your student account has been created. Use the details below to sign in for the first time.</p>
    <table style='width:100%;border-collapse:collapse;margin:18px 0;font-size:.95rem;'>
      <tr><td style='padding:8px 0;color:#7f8c8d;'>Student ID</td><td style='padding:8px 0;font-weight:600;'>{studentCode}</td></tr>
      <tr><td style='padding:8px 0;color:#7f8c8d;'>Login email</td><td style='padding:8px 0;font-weight:600;'>{collegeEmail}</td></tr>
      <tr><td style='padding:8px 0;color:#7f8c8d;'>Temporary password</td><td style='padding:8px 0;font-weight:600;'>{tempPassword}</td></tr>
    </table>
    <p style='margin-bottom:6px;'>Your one-time activation code is:</p>
    <div style='font-size:2rem;font-weight:700;letter-spacing:8px;background:#f4f6f9;border:1px dashed #1abc9c;border-radius:10px;padding:16px;text-align:center;color:#16a085;'>{otp}</div>
    <p style='font-size:.85rem;color:#7f8c8d;margin-top:18px;'>
      Sign in with your login email and temporary password, then enter this code when prompted.
      The code expires in 24 hours. If it expires, choose &ldquo;Resend code&rdquo; on the verification screen.
    </p>
    <p style='font-size:.8rem;color:#b0b7bd;'>If you did not expect this email, please ignore it.</p>
  </div>
</div>";
            Send(toPersonalEmail, subject, body);
        }

        /// <summary>
        /// Re-sends ONLY a fresh activation code (used by the Resend button).
        /// Does not repeat the password for safety.
        /// </summary>
        public static void SendOtp(string toPersonalEmail, string studentName, string collegeEmail, string otp)
        {
            string subject = "Your SIMS activation code";
            string body = $@"
<div style='font-family:Segoe UI,Arial,sans-serif;max-width:560px;margin:auto;color:#2c3e50;'>
  <div style='background:linear-gradient(135deg,#1abc9c,#16a085);padding:22px 28px;border-radius:12px 12px 0 0;color:#fff;'>
    <h2 style='margin:0;font-size:1.3rem;'>New activation code</h2>
  </div>
  <div style='border:1px solid #eee;border-top:none;padding:28px;border-radius:0 0 12px 12px;'>
    <p>Hi {studentName},</p>
    <p>Here is a fresh one-time code for <strong>{collegeEmail}</strong>:</p>
    <div style='font-size:2rem;font-weight:700;letter-spacing:8px;background:#f4f6f9;border:1px dashed #1abc9c;border-radius:10px;padding:16px;text-align:center;color:#16a085;'>{otp}</div>
    <p style='font-size:.85rem;color:#7f8c8d;margin-top:18px;'>This code expires in 24 hours.</p>
  </div>
</div>";
            Send(toPersonalEmail, subject, body);
        }
    }
}
