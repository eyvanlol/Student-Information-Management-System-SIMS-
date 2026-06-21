using System;
using System.Data;
using System.Data.SqlClient;

namespace StudentManagementSystem
{
    /// <summary>
    /// Shared notification layer for SIMS. This is the ONE place the team
    /// should read/write the NOTIFICATION table, so column names and
    /// notifType values stay identical across every module.
    ///
    /// Schema assumed (after PATCH 8 in the master script):
    ///   notificationID INT IDENTITY PK | recipientID INT | recipientRole VARCHAR
    ///   title | message | isRead BIT | createdAt DATETIME | notifType VARCHAR
    ///   groupKey VARCHAR | senderID INT NULL | courseID INT NULL
    ///
    /// IDs are INT throughout and match Session["UserID"] (set at login as int).
    /// ENROLMENT stores studentID/courseID as VARCHAR; SQL Server converts them
    /// implicitly on the joins below — the same thing ManageGrades already does.
    /// Enrolled students are filtered by status = 'enrolled'.
    /// </summary>
    public static class NotificationHelper
    {
        // ---- Locked enums: single source of truth for the whole team ----
        public static class Type
        {
            public const string Grade = "grade";
            public const string Attendance = "attendance";
            public const string Enrolment = "enrolment";
            public const string Announcement = "announcement";
            public const string DropApproved = "drop_approved";
            public const string DropRejected = "drop_rejected";
            public const string Welcome = "welcome";
        }

        public static class Role
        {
            public const string Student = "student";
            public const string Lecturer = "lecturer";
            public const string All = "all";
        }

        // =====================================================================
        // WRITE SIDE
        // =====================================================================

        /// <summary>
        /// Insert a single notification (welcome, grade, drop decision, etc.).
        /// senderID / courseID / groupKey are optional.
        /// </summary>
        public static void Insert(int recipientID, string recipientRole, string notifType,
                                  string title, string message,
                                  int? senderID = null, int? courseID = null, string groupKey = null)
        {
            const string sql = @"
                INSERT INTO NOTIFICATION
                    (senderID, recipientID, recipientRole, title, message,
                     isRead, createdAt, notifType, courseID, groupKey)
                VALUES
                    (@senderID, @recipientID, @recipientRole, @title, @msg,
                     0, GETDATE(), @notifType, @courseID, @groupKey);";

            DbHelper.ExecuteNonQuery(sql,
                P("@senderID", (object)senderID),
                P("@recipientID", recipientID),
                P("@recipientRole", recipientRole),
                P("@title", title),
                P("@msg", message),
                P("@notifType", notifType),
                P("@courseID", (object)courseID),
                P("@groupKey", groupKey));
        }

        /// <summary>
        /// Post an announcement to ONE course: one NOTIFICATION row per
        /// actively-enrolled student. Returns the number of students notified.
        /// </summary>
        public static int PostAnnouncementToCourse(int senderLecturerID, int courseID,
                                                   string title, string message)
        {
            string groupKey = Guid.NewGuid().ToString();
            const string sql = @"
                INSERT INTO NOTIFICATION
                    (senderID, recipientID, recipientRole, title, message,
                     isRead, createdAt, notifType, courseID, groupKey)
                SELECT @sender, e.studentID, 'student', @title, @msg,
                       0, GETDATE(), 'announcement', @courseID, @gk
                FROM ENROLMENT e
                INNER JOIN STUDENT s ON e.studentID = s.studentID
                WHERE e.courseID = @courseID AND e.status = 'enrolled';";

            return DbHelper.ExecuteNonQuery(sql,
                P("@sender", senderLecturerID),
                P("@title", title),
                P("@msg", message),
                P("@courseID", courseID),
                P("@gk", groupKey));
        }

        /// <summary>
        /// Post an announcement to EVERY course this lecturer teaches: one row
        /// per DISTINCT student. courseID is left NULL (it's a broadcast).
        /// Returns the number of students notified.
        /// </summary>
        public static int PostAnnouncementToAllCourses(int lecturerID, string title, string message)
        {
            string groupKey = Guid.NewGuid().ToString();
            const string sql = @"
                INSERT INTO NOTIFICATION
                    (senderID, recipientID, recipientRole, title, message,
                     isRead, createdAt, notifType, courseID, groupKey)
                SELECT DISTINCT @sender, e.studentID, 'student', @title, @msg,
                       0, GETDATE(), 'announcement', NULL, @gk
                FROM ENROLMENT e
                INNER JOIN COURSE c ON e.courseID = c.courseID
                WHERE c.lecturerID = @sender AND e.status = 'enrolled';";

            return DbHelper.ExecuteNonQuery(sql,
                P("@sender", lecturerID),
                P("@title", title),
                P("@msg", message),
                P("@gk", groupKey));
        }

        // =====================================================================
        // READ SIDE — student notifications panel
        // =====================================================================

        /// <summary>Full list for a student, newest first.</summary>
        public static DataTable GetForStudent(int studentID)
        {
            const string sql = @"
                SELECT notificationID, notifType, title, message, courseID, isRead, createdAt
                FROM   NOTIFICATION
                WHERE  recipientID = @sid AND recipientRole IN ('student','all')
                ORDER  BY createdAt DESC, notificationID DESC;";
            return DbHelper.ExecuteQuery(sql, P("@sid", studentID));
        }

        /// <summary>Dashboard preview: the N most recent UNREAD notifications.</summary>
        public static DataTable GetRecentUnread(int studentID, int top = 3)
        {
            const string sql = @"
                SELECT TOP (@top) notificationID, notifType, title, message, courseID, isRead, createdAt
                FROM   NOTIFICATION
                WHERE  recipientID = @sid AND recipientRole IN ('student','all') AND isRead = 0
                ORDER  BY createdAt DESC, notificationID DESC;";
            return DbHelper.ExecuteQuery(sql, P("@top", top), P("@sid", studentID));
        }

        /// <summary>Unread count for the red bell badge.</summary>
        public static int GetUnreadCount(int studentID)
        {
            const string sql = @"
                SELECT COUNT(*) FROM NOTIFICATION
                WHERE recipientID = @sid AND recipientRole IN ('student','all') AND isRead = 0;";
            object o = DbHelper.ExecuteScalar(sql, P("@sid", studentID));
            return (o == null || o == DBNull.Value) ? 0 : Convert.ToInt32(o);
        }

        /// <summary>Mark one notification row as read.</summary>
        public static void MarkAsRead(int notificationID)
        {
            DbHelper.ExecuteNonQuery(
                "UPDATE NOTIFICATION SET isRead = 1 WHERE notificationID = @id;",
                P("@id", notificationID));
        }

        // =====================================================================
        // READ SIDE — lecturer "my past announcements"
        // =====================================================================

        /// <summary>
        /// One row per announcement this lecturer posted (grouped by groupKey):
        /// title, course name, date, recipient count.
        /// </summary>
        public static DataTable GetAnnouncementsByLecturer(int lecturerID)
        {
            const string sql = @"
                SELECT  n.groupKey,
                        MAX(n.title)      AS title,
                        MAX(n.message)    AS message,
                        MAX(n.courseID)   AS courseID,
                        MAX(c.courseName) AS courseName,
                        MAX(n.createdAt)  AS createdAt,
                        COUNT(*)          AS recipientCount
                FROM    NOTIFICATION n
                LEFT JOIN COURSE c ON n.courseID = c.courseID
                WHERE   n.senderID = @lid AND n.notifType = 'announcement'
                GROUP BY n.groupKey
                ORDER BY MAX(n.createdAt) DESC;";
            return DbHelper.ExecuteQuery(sql, P("@lid", lecturerID));
        }

        // =====================================================================
        // UI HELPERS — shared by the panel AND the dashboard preview
        // =====================================================================

        /// <summary>Hex colour for the notifType dot.</summary>
        public static string DotColor(string notifType)
        {
            switch (notifType)
            {
                case Type.Grade: return "#198754"; // green
                case Type.Attendance: return "#fd7e14"; // orange
                case Type.Enrolment: return "#0d6efd"; // blue
                case Type.Announcement: return "#6f42c1"; // purple
                case Type.DropApproved: return "#20c997"; // teal
                case Type.DropRejected: return "#dc3545"; // red
                case Type.Welcome: return "#0dcaf0"; // cyan
                default: return "#6c757d"; // grey
            }
        }

        /// <summary>"Just now" / "2 hours ago" / "Yesterday" / "3 days ago".</summary>
        public static string TimeAgo(DateTime when)
        {
            TimeSpan span = DateTime.Now - when;

            if (span.TotalSeconds < 60) return "Just now";
            if (span.TotalMinutes < 60) { int m = (int)span.TotalMinutes; return m + (m == 1 ? " minute ago" : " minutes ago"); }
            if (span.TotalHours < 24) { int h = (int)span.TotalHours; return h + (h == 1 ? " hour ago" : " hours ago"); }
            if (span.TotalDays < 2) return "Yesterday";
            if (span.TotalDays < 7) { int d = (int)span.TotalDays; return d + " days ago"; }
            if (span.TotalDays < 30) { int w = (int)(span.TotalDays / 7); return w + (w == 1 ? " week ago" : " weeks ago"); }
            return when.ToString("dd MMM yyyy");
        }

        // ---- small param helper: coerces null -> DBNull, and the (string,object)
        // ---- overload avoids the SqlParameter(string, SqlDbType) int ambiguity ----
        private static SqlParameter P(string name, object value)
        {
            return new SqlParameter(name, value ?? DBNull.Value);
        }
    }
}