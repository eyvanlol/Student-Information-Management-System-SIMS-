using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace StudentManagementSystem
{
    /// <summary>
    /// Student Progression logic — the "Final Exam Result Processing" engine.
    ///
    /// RULES (from the coursework brief):
    ///   * All subjects passed   -> status "Advancing", semester + 1
    ///   * Any Grade F (fail)     -> status "Retake",    semester + 1, failed subjects carried for retake
    ///   * Any Grade C- (no F)    -> status "Resit",     semester unchanged (held until resit passed)
    ///
    /// WHERE the data lives:
    ///   * Each student's standing is stored on STUDENT.currentSemester / STUDENT.studentStatus (PATCH 15).
    ///   * Failed subjects are flagged on RESULT.retakeRequired (PATCH 13).
    ///   * Resit subjects are identified by grade = 'C-' (no extra column needed).
    ///   * History is preserved: published RESULT rows are never changed by processing.
    ///
    /// AUTO-ENROLMENT (added):
    ///   * On Commit, the engine creates 'pending' ENROLMENT rows for the next semester's
    ///     courses (looked up via COURSE.programmeID + COURSE.semester).
    ///   * Retake students additionally get a 'pending' row for each failed course.
    ///   * Resit students are NOT auto-enrolled (they are held at the same semester).
    ///   * Target session = the currently 'Open' SEMESTER_SESSION.
    /// </summary>
    public static class ProgressionService
    {
        public class Outcome
        {
            public int StudentID { get; set; }
            public string StudentCode { get; set; }
            public string StudentName { get; set; }
            public int ProgrammeID { get; set; }
            public int CurrentSemester { get; set; }
            public int NextSemester { get; set; }
            public string Status { get; set; }
            public string ResultsSummary { get; set; }
            public string SubjectsDisplay { get; set; }
            public string NextSemDisplay { get; set; }
            public List<int> FailedCourseIDs { get; set; } = new List<int>();
        }

        private static Outcome BuildOutcome(int studentID, string code, string name,
                                            int programmeID, int currentSem, DataTable results)
        {
            var failed = new List<string>();
            var failedIDs = new List<int>();
            var resit = new List<string>();

            foreach (DataRow r in results.Rows)
            {
                string grade = (r["grade"] ?? "").ToString().Trim().ToUpper();
                string courseCode = (r["courseCode"] ?? "").ToString();
                int courseID = Convert.ToInt32(r["courseID"]);

                if (grade == "F") { failed.Add(courseCode); failedIDs.Add(courseID); }
                else if (grade == "C-") resit.Add(courseCode);
            }

            var o = new Outcome
            {
                StudentID = studentID,
                StudentCode = code,
                StudentName = name,
                ProgrammeID = programmeID,
                CurrentSemester = currentSem,
                FailedCourseIDs = failedIDs
            };

            if (failed.Count > 0)
            {
                o.Status = "Retake";
                o.NextSemester = currentSem + 1;
                o.ResultsSummary = failed.Count + " failed";
                o.SubjectsDisplay = string.Join(", ", failed);
                o.NextSemDisplay = o.NextSemester.ToString();
            }
            else if (resit.Count > 0)
            {
                o.Status = "Resit";
                o.NextSemester = currentSem;
                o.ResultsSummary = resit.Count + " resit";
                o.SubjectsDisplay = string.Join(", ", resit);
                o.NextSemDisplay = currentSem + " (until resit completed)";
            }
            else
            {
                o.Status = "Advancing";
                o.NextSemester = currentSem + 1;
                o.ResultsSummary = "All passed";
                o.SubjectsDisplay = "\u2014";
                o.NextSemDisplay = o.NextSemester.ToString();
            }

            return o;
        }

        /// <summary>
        /// PREVIEW — work out every student's outcome for a semester. Reads only.
        /// </summary>
        public static List<Outcome> Preview(string semester)
        {
            var list = new List<Outcome>();

            string studentSql = @"
                SELECT DISTINCT s.studentID, s.studentCode, s.name, s.programmeID, s.currentSemester
                FROM   STUDENT s
                JOIN   RESULT  r ON r.studentID = s.studentID
                WHERE  r.semester = @sem
                AND    r.publishedStatus = 'Published'
                ORDER  BY s.name";

            DataTable students = DbHelper.ExecuteQuery(studentSql, new SqlParameter("@sem", semester));

            foreach (DataRow s in students.Rows)
            {
                int sid = Convert.ToInt32(s["studentID"]);
                int prog = s["programmeID"] == DBNull.Value ? 0 : Convert.ToInt32(s["programmeID"]);
                int cur = s["currentSemester"] == DBNull.Value ? 1 : Convert.ToInt32(s["currentSemester"]);

                string resultSql = @"
                    SELECT r.courseID, c.courseCode, r.grade
                    FROM   RESULT r
                    JOIN   COURSE c ON c.courseID = r.courseID
                    WHERE  r.studentID = @sid
                    AND    r.semester  = @sem
                    AND    r.publishedStatus = 'Published'";

                DataTable results = DbHelper.ExecuteQuery(resultSql,
                    new SqlParameter("@sid", sid),
                    new SqlParameter("@sem", semester));

                list.Add(BuildOutcome(sid, s["studentCode"].ToString(), s["name"].ToString(),
                                       prog, cur, results));
            }

            return list;
        }

        /// <summary>
        /// COMMIT — apply outcomes AND auto-enrol Advancing/Retake students into
        /// next-semester courses. Returns the applied snapshot.
        /// </summary>
        public static List<Outcome> Commit(string semester)
        {
            var outcomes = Preview(semester);

            // The target session for new enrolments = the currently-Open session.
            string targetSession = null;
            string targetYear = null;
            DataTable open = DbHelper.ExecuteQuery(@"
                SELECT TOP 1 semesterName, academicYear
                FROM   SEMESTER_SESSION
                WHERE  status = 'Open'
                ORDER  BY sessionID DESC");
            if (open.Rows.Count > 0)
            {
                targetSession = open.Rows[0]["semesterName"].ToString();
                targetYear = open.Rows[0]["academicYear"].ToString();
            }

            foreach (var o in outcomes)
            {
                // 1) Advance / hold the student.
                DbHelper.ExecuteNonQuery(
                    "UPDATE STUDENT SET currentSemester = @next, studentStatus = @status WHERE studentID = @sid",
                    new SqlParameter("@next", o.NextSemester),
                    new SqlParameter("@status", o.Status),
                    new SqlParameter("@sid", o.StudentID));

                // 2) Flag failed subjects for retake.
                DbHelper.ExecuteNonQuery(
                    @"UPDATE RESULT
                      SET    retakeRequired = 1
                      WHERE  studentID = @sid
                      AND    semester  = @sem
                      AND    publishedStatus = 'Published'
                      AND    UPPER(LTRIM(RTRIM(grade))) = 'F'",
                    new SqlParameter("@sid", o.StudentID),
                    new SqlParameter("@sem", semester));

                // 3) AUTO-ENROL into next semester's courses (Advancing + Retake only).
                if (targetSession != null
                    && (o.Status == "Advancing" || o.Status == "Retake")
                    && o.ProgrammeID > 0)
                {
                    // 3a) Next semester's standard courses.
                    DbHelper.ExecuteNonQuery(@"
                        INSERT INTO ENROLMENT (studentID, courseID, semester, academicYear, enrolDate, status)
                        SELECT  @sid, c.courseID, @sem, @yr, GETDATE(), 'pending'
                        FROM    COURSE c
                        WHERE   c.programmeID = @pid
                        AND     c.semester    = @nextSem
                        AND     c.status      = 'Active'
                        AND     NOT EXISTS (
                            SELECT 1 FROM ENROLMENT e
                            WHERE  e.studentID = @sid
                            AND    e.courseID  = c.courseID
                            AND    e.semester  = @sem
                        )",
                        new SqlParameter("@sid", o.StudentID),
                        new SqlParameter("@sem", targetSession),
                        new SqlParameter("@yr", targetYear),
                        new SqlParameter("@pid", o.ProgrammeID),
                        new SqlParameter("@nextSem", o.NextSemester));

                    // 3b) Re-enrol failed courses (Retake only).
                    if (o.Status == "Retake")
                    {
                        foreach (int failedCourseID in o.FailedCourseIDs)
                        {
                            DbHelper.ExecuteNonQuery(@"
                                INSERT INTO ENROLMENT (studentID, courseID, semester, academicYear, enrolDate, status)
                                SELECT @sid, @cid, @sem, @yr, GETDATE(), 'pending'
                                WHERE NOT EXISTS (
                                    SELECT 1 FROM ENROLMENT
                                    WHERE  studentID = @sid AND courseID = @cid AND semester = @sem
                                )",
                                new SqlParameter("@sid", o.StudentID),
                                new SqlParameter("@cid", failedCourseID),
                                new SqlParameter("@sem", targetSession),
                                new SqlParameter("@yr", targetYear));
                        }
                    }
                }
            }

            return outcomes;
        }
    }
}
