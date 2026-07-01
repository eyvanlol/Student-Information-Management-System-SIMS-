using System;
using System.Data;
using System.Data.SqlClient;

namespace StudentManagementSystem
{
    /// <summary>
    /// FIX 3 — background worker for the student personal calendar.
    /// Called once a minute by the Global.asax timer. Finds personal reminders
    /// that start within the next hour and have not been emailed yet, emails the
    /// student (reusing EmailHelper -> the same Web.config SMTP), posts an in-app
    /// notification, and marks the row as sent.
    /// </summary>
    public static class ReminderService
    {
        public static void SendDueReminders()
        {
            // Unsent reminders starting within the next 60 minutes.
            DataTable due = DbHelper.ExecuteQuery(@"
                SELECT r.reminderID, r.title, r.description, r.startTime, r.studentID,
                       s.name AS studentName, ISNULL(s.personalEmail,'') AS personalEmail
                FROM   PERSONAL_REMINDER r
                JOIN   STUDENT s ON r.studentID = s.studentID
                WHERE  r.reminderSent = 0
                AND    r.startTime > GETDATE()
                AND    r.startTime <= DATEADD(MINUTE, 60, GETDATE())");

            foreach (DataRow row in due.Rows)
            {
                int reminderId = Convert.ToInt32(row["reminderID"]);
                int studentId = Convert.ToInt32(row["studentID"]);
                string email = row["personalEmail"].ToString();
                string name = row["studentName"].ToString();
                string title = row["title"].ToString();
                string desc = row["description"] == DBNull.Value ? "" : row["description"].ToString();
                DateTime start = Convert.ToDateTime(row["startTime"]);

                try
                {
                    if (!string.IsNullOrWhiteSpace(email))
                        EmailHelper.SendReminderDueSoon(email, name, title, desc, start);

                    DbHelper.ExecuteNonQuery(@"
                        INSERT INTO NOTIFICATION
                            (recipientID, recipientRole, title, message, isRead, createdAt, notifType)
                        VALUES (@rid, 'student', @t, @m, 0, GETDATE(), 'reminder')",
                        new SqlParameter("@rid", studentId),
                        new SqlParameter("@t", "Reminder: " + title),
                        new SqlParameter("@m", title + " starts at " + start.ToString("h:mm tt") +
                                              (string.IsNullOrEmpty(desc) ? "" : ". " + desc)));
                }
                catch
                {
                    // One bad address must not stop the rest of the batch.
                }

                // Mark sent regardless, so a permanently bad address is not retried forever.
                DbHelper.ExecuteNonQuery(
                    "UPDATE PERSONAL_REMINDER SET reminderSent = 1 WHERE reminderID = @id",
                    new SqlParameter("@id", reminderId));
            }
        }
    }
}
