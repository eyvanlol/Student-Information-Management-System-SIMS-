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

        /// <summary>
        /// TASK 1 — Fail / Retake notification to a student's PERSONAL email.
        /// Reuses the same private Send() (and therefore the same Web.config SMTP
        /// settings) as the OTP/welcome mail, so no new email mechanism is added.
        ///
        ///   statusLabel        : "Failed" or "Must Retake"
        ///   marksGrade         : display string, e.g. "42.00 (F)"
        ///   retakeInstruction  : free-text guidance shown in the body
        /// Throws on delivery failure so the caller can show the real reason.
        /// </summary>
        public static void SendResultNotification(
            string toPersonalEmail,
            string studentName,
            string courseCode,
            string courseName,
            string statusLabel,
            string marksGrade,
            string retakeInstruction)
        {
            // Red header for "Failed", amber for "Must Retake".
            bool isRetake = string.Equals(statusLabel, "Must Retake", StringComparison.OrdinalIgnoreCase);
            string headerBg = isRetake
                ? "linear-gradient(135deg,#e67e22,#d35400)"
                : "linear-gradient(135deg,#e74c3c,#c0392b)";
            string accent = isRetake ? "#d35400" : "#c0392b";

            string subject = $"SIMS result notice — {courseCode} ({statusLabel})";
            string body = $@"
<div style='font-family:Segoe UI,Arial,sans-serif;max-width:560px;margin:auto;color:#2c3e50;'>
  <div style='background:{headerBg};padding:22px 28px;border-radius:12px 12px 0 0;color:#fff;'>
    <h2 style='margin:0;font-size:1.3rem;'>Result Notification</h2>
    <p style='margin:4px 0 0;opacity:.9;'>Student Information Management System</p>
  </div>
  <div style='border:1px solid #eee;border-top:none;padding:28px;border-radius:0 0 12px 12px;'>
    <p>Dear {studentName},</p>
    <p>This is an official notice from the Head of Programme regarding your result for the
       following course:</p>
    <table style='width:100%;border-collapse:collapse;margin:18px 0;font-size:.95rem;'>
      <tr><td style='padding:8px 0;color:#7f8c8d;'>Course</td><td style='padding:8px 0;font-weight:600;'>{courseCode} — {courseName}</td></tr>
      <tr><td style='padding:8px 0;color:#7f8c8d;'>Result</td><td style='padding:8px 0;font-weight:600;'>{marksGrade}</td></tr>
      <tr><td style='padding:8px 0;color:#7f8c8d;'>Status</td>
          <td style='padding:8px 0;font-weight:700;color:{accent};'>{statusLabel}</td></tr>
    </table>
    <div style='background:#f4f6f9;border-left:4px solid {accent};border-radius:6px;padding:14px 16px;margin:14px 0;'>
      <strong>What you need to do</strong>
      <p style='margin:8px 0 0;font-size:.9rem;'>{retakeInstruction}</p>
    </div>
    <p style='font-size:.85rem;color:#7f8c8d;margin-top:18px;'>
      If you believe this is an error, please contact the Head of Programme as soon as possible.
    </p>
    <p style='font-size:.8rem;color:#b0b7bd;'>This is an automated message from SIMS Registry.</p>
  </div>
</div>";
            Send(toPersonalEmail, subject, body);
        }

        /// <summary>
        /// FIX 3 — sent immediately when a student creates a personal calendar
        /// alert. Confirms the alert and echoes the description back.
        /// </summary>
        public static void SendReminderConfirmation(
            string toPersonalEmail, string studentName, string title,
            string description, DateTime startTime)
        {
            string subject = "Alert set: " + title;
            string desc = string.IsNullOrEmpty(description) ? "(no description)" : description;
            string body = $@"
<div style='font-family:Segoe UI,Arial,sans-serif;max-width:560px;margin:auto;color:#2c3e50;'>
  <div style='background:linear-gradient(135deg,#3498db,#2980b9);padding:22px 28px;border-radius:12px 12px 0 0;color:#fff;'>
    <h2 style='margin:0;font-size:1.3rem;'>Calendar alert created</h2>
  </div>
  <div style='border:1px solid #eee;border-top:none;padding:28px;border-radius:0 0 12px 12px;'>
    <p>Hi {studentName},</p>
    <p>You have created the following personal alert in SIMS:</p>
    <table style='width:100%;border-collapse:collapse;margin:18px 0;font-size:.95rem;'>
      <tr><td style='padding:8px 0;color:#7f8c8d;'>Title</td><td style='padding:8px 0;font-weight:600;'>{title}</td></tr>
      <tr><td style='padding:8px 0;color:#7f8c8d;'>When</td><td style='padding:8px 0;font-weight:600;'>{startTime:dddd, d MMM yyyy h:mm tt}</td></tr>
      <tr><td style='padding:8px 0;color:#7f8c8d;vertical-align:top;'>Details</td><td style='padding:8px 0;'>{desc}</td></tr>
    </table>
    <p style='font-size:.85rem;color:#7f8c8d;'>We will email you a reminder about one hour before it starts.</p>
  </div>
</div>";
            Send(toPersonalEmail, subject, body);
        }

        /// <summary>
        /// FIX 3 — sent by the background ReminderService about an hour before
        /// the alert's start time.
        /// </summary>
        public static void SendReminderDueSoon(
            string toPersonalEmail, string studentName, string title,
            string description, DateTime startTime)
        {
            string subject = "Reminder (starts soon): " + title;
            string desc = string.IsNullOrEmpty(description) ? "(no description)" : description;
            string body = $@"
<div style='font-family:Segoe UI,Arial,sans-serif;max-width:560px;margin:auto;color:#2c3e50;'>
  <div style='background:linear-gradient(135deg,#e67e22,#d35400);padding:22px 28px;border-radius:12px 12px 0 0;color:#fff;'>
    <h2 style='margin:0;font-size:1.3rem;'>Starting soon</h2>
  </div>
  <div style='border:1px solid #eee;border-top:none;padding:28px;border-radius:0 0 12px 12px;'>
    <p>Hi {studentName},</p>
    <p>This is a reminder that your alert <strong>{title}</strong> begins at
       <strong>{startTime:h:mm tt}</strong> ({startTime:dddd, d MMM yyyy}).</p>
    <div style='background:#f4f6f9;border-left:4px solid #d35400;border-radius:6px;padding:14px 16px;margin:14px 0;'>
      <strong>Your note</strong>
      <p style='margin:8px 0 0;font-size:.9rem;'>{desc}</p>
    </div>
  </div>
</div>";
            Send(toPersonalEmail, subject, body);
        }

        /// <summary>
        /// FIX 4 — attendance warning / barring / drop letter (INTI style).
        /// level: 1 = first warning (&lt;80%), 2 = second warning + barred from
        /// final (&lt;60%), 3 = dropped (&lt;40%).
        /// </summary>
        public static void SendAttendanceWarningLetter(
            string toPersonalEmail, string studentName, string programmeName,
            string courseCode, string courseName, int percent,
            int attended, int totalSessions, int level)
        {
            int absent = totalSessions - attended;
            string heading, levelLine, headerBg, accent;
            if (level >= 3)
            {
                heading = "ENROLMENT DROPPED DUE TO ABSENTEEISM";
                levelLine = "Your attendance has fallen below 40%. In line with the attendance policy, " +
                            "you have been AUTOMATICALLY DROPPED from this course.";
                headerBg = "linear-gradient(135deg,#c0392b,#7b241c)"; accent = "#7b241c";
            }
            else if (level == 2)
            {
                heading = "SECOND WARNING LETTER DUE TO ABSENTEEISM";
                levelLine = "This is your SECOND warning. Your attendance is below 60%. You will be " +
                            "BARRED from taking the final examination / submitting the final coursework " +
                            "for this module unless your attendance improves.";
                headerBg = "linear-gradient(135deg,#e74c3c,#c0392b)"; accent = "#c0392b";
            }
            else
            {
                heading = "FIRST WARNING LETTER DUE TO ABSENTEEISM";
                levelLine = "This is your FIRST warning. Your attendance is below the required 80%. " +
                            "Please attend all remaining classes to avoid being barred.";
                headerBg = "linear-gradient(135deg,#e67e22,#d35400)"; accent = "#d35400";
            }

            string subject = $"WARNING LETTER — {courseCode} ({percent}% attendance)";
            string body = $@"
<div style='font-family:Segoe UI,Arial,sans-serif;max-width:620px;margin:auto;color:#2c3e50;'>
  <div style='background:{headerBg};padding:22px 28px;border-radius:12px 12px 0 0;color:#fff;'>
    <h2 style='margin:0;font-size:1.25rem;'>{heading}</h2>
    <p style='margin:4px 0 0;opacity:.9;'>Student Information Management System</p>
  </div>
  <div style='border:1px solid #eee;border-top:none;padding:28px;border-radius:0 0 12px 12px;'>
    <p>Dear {studentName},</p>
    <p style='font-weight:600;'>{programmeName}</p>
    <p>According to the attendance records, your attendance for the following course is below
       the required threshold:</p>
    <table style='width:100%;border-collapse:collapse;margin:14px 0;font-size:.9rem;'>
      <tr style='background:#f8f9fa;'>
        <th style='border:1px solid #e0e0e0;padding:8px;text-align:left;'>Course</th>
        <th style='border:1px solid #e0e0e0;padding:8px;'>Sessions Held</th>
        <th style='border:1px solid #e0e0e0;padding:8px;'>Attended</th>
        <th style='border:1px solid #e0e0e0;padding:8px;'>Absent</th>
        <th style='border:1px solid #e0e0e0;padding:8px;'>Attendance %</th>
      </tr>
      <tr>
        <td style='border:1px solid #e0e0e0;padding:8px;'>{courseCode} — {courseName}</td>
        <td style='border:1px solid #e0e0e0;padding:8px;text-align:center;'>{totalSessions}</td>
        <td style='border:1px solid #e0e0e0;padding:8px;text-align:center;'>{attended}</td>
        <td style='border:1px solid #e0e0e0;padding:8px;text-align:center;'>{absent}</td>
        <td style='border:1px solid #e0e0e0;padding:8px;text-align:center;font-weight:700;color:{accent};'>{percent}%</td>
      </tr>
    </table>
    <div style='background:#f4f6f9;border-left:4px solid {accent};border-radius:6px;padding:14px 16px;margin:14px 0;'>
      <p style='margin:0;font-size:.92rem;'>{levelLine}</p>
    </div>
    <p style='font-size:.86rem;color:#555;'>
      Policy: a student must meet a minimum of 80% attendance. Failing which, you may be barred
      from the final examination or final coursework. Please see your Head of Programme as soon
      as possible if you are facing difficulties causing the absenteeism.
    </p>
    <p style='font-size:.8rem;color:#b0b7bd;'>This is an automated letter from SIMS Registry.</p>
  </div>
</div>";
            Send(toPersonalEmail, subject, body);
        }

    }
}
