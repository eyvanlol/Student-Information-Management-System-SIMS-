using System;
using System.Threading;
using System.Web;

namespace StudentManagementSystem
{
    public class Global : HttpApplication
    {
        // FIX 3 — fires once a minute to deliver due calendar reminders.
        private static Timer _reminderTimer;

        void Application_Start(object sender, EventArgs e)
        {
            // Start the personal-reminder sweeper. First run after 20s, then every minute.
            _reminderTimer = new Timer(_ => SafeSweep(), null,
                TimeSpan.FromSeconds(20), TimeSpan.FromMinutes(1));
        }

        private static void SafeSweep()
        {
            // Never let a background error bubble up and recycle the app.
            try { StudentManagementSystem.ReminderService.SendDueReminders(); }
            catch { /* swallow */ }
        }
    }
}
