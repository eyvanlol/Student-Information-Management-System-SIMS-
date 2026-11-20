-- =====================================================================
-- SIMS_DB_00_base_schema.sql
-- Base tables for a FRESH SQL Server / LocalDB install, i.e. the state
-- BEFORE "SQL CODE  UPDATED" and SIMS_DB_PATCH10..13 are run.
-- Safe to run more than once (every CREATE / seed is guarded).
--
-- RUN ORDER (all against the SIMS_DB database):
--   1. SIMS_DB_00_base_schema.sql            (this file - creates SIMS_DB)
--   2. "SQL CODE  UPDATED"                   (PATCH 1-9, plus inline copies of 10-12)
--   3. SIMS_DB_PATCH10_otp.sql               (idempotent re-run, harmless)
--   4. SIMS_DB_PATCH11_identity.sql          (idempotent re-run, harmless)
--   5. SIMS_DB_PATCH12_enrolment_autoid.sql  (drops + recreates the trigger, harmless)
--   6. SIMS_DB_PATCH13_missing_schema.sql
--   7. SIMS_DB_00_base_schema.sql AGAIN      (only to apply the final
--      "post-patch seed" section; everything else is skipped)
--
--   NOTE: "SQL CODE  UPDATED" and PATCH 10-12 contain no USE statement.
--   Run them with SIMS_DB as the current database, e.g.
--     sqlcmd -S "(localdb)\MSSQLLocalDB" -d SIMS_DB -i "SQL CODE  UPDATED"
--   (in SSMS: pick SIMS_DB in the database dropdown first).
--
-- KNOWN PATCH ISSUES (none should fail on top of this base):
--   * "SQL CODE  UPDATED" PATCH 1 / PATCH 2 UPDATE seed rows by ID 1-4
--     "WHERE personalEmail IS NULL". STUDENT.personalEmail and studentCode
--     are pre-created here (PATCH 1 guards both with IF NOT EXISTS) so that
--     (a) the student UPDATEs are no-ops and do NOT write real-looking
--     gmail.com addresses that the app would then email, and (b) the
--     UNIQUE uq_student_code constraint can be added (two NULL codes would
--     violate it). LECTURER is left to PATCH 2, which sets lecturer 1's
--     code/department/staffType and a gmail personalEmail (lecturers are
--     never emailed by the app).
--   * PATCH 12 relies on an INSTEAD OF INSERT trigger filling the NOT NULL
--     VARCHAR primary key ENROLMENT.enrolmentID when the app omits it. The
--     seed rows below supply enrolmentID explicitly (the trigger does not
--     exist yet when this file first runs).
--
-- TEST LOGINS (Login.aspx: "Email" + "Password"; the email is matched
-- against the `email` column of HOP_ADMIN, then LECTURER, then STUDENT):
--   Role      Email (login field)      Password   Code (display only)
--   Admin     admin@sims.edu           Test@123   ADM2604001 (set by PATCH 3)
--   Lecturer  lecturer@sims.edu        Test@123   LEC2604001 (set by PATCH 2)
--   Student   student1@sims.edu        Test@123   STU2604001
--   Student   student2@sims.edu        Test@123   STU2604002
--
-- Passwords are stored as Base64(SHA-256(UTF-8 password)), which is exactly
-- what Login.HashPassword() produces (NOT hex). Login also accepts an exact
-- plaintext match, so password = 'Test@123' would work too.
-- Seeded students are activated by PATCH 10 (isActivated = 1 where
-- otpCode IS NULL), so they skip the VerifyOtp screen.
-- =====================================================================

IF DB_ID('SIMS_DB') IS NULL
    CREATE DATABASE SIMS_DB;
GO
USE SIMS_DB;
GO

-- =====================================================================
-- TABLES
-- =====================================================================

IF OBJECT_ID('dbo.PROGRAMME', 'U') IS NULL
    CREATE TABLE dbo.PROGRAMME (
        programmeID    INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_programme PRIMARY KEY,
        programmeName  VARCHAR(150) NOT NULL,
        programmeCode  VARCHAR(20)  NOT NULL CONSTRAINT uq_programme_code UNIQUE,
        faculty        VARCHAR(100) NULL,
        totalCredits   INT          NULL,
        durationYears  INT          NULL,
        status         VARCHAR(20)  NOT NULL CONSTRAINT df_programme_status DEFAULT 'Active'
    );
GO

IF OBJECT_ID('dbo.HOP_ADMIN', 'U') IS NULL
    CREATE TABLE dbo.HOP_ADMIN (
        adminID   INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_hop_admin PRIMARY KEY,
        name      VARCHAR(100) NOT NULL,
        email     VARCHAR(100) NOT NULL CONSTRAINT uq_admin_email UNIQUE,
        password  VARCHAR(255) NOT NULL
        -- adminCode : PATCH 3      headOf : PATCH 11
    );
GO

IF OBJECT_ID('dbo.LECTURER', 'U') IS NULL
    CREATE TABLE dbo.LECTURER (
        lecturerID  INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_lecturer PRIMARY KEY,
        name        VARCHAR(100) NOT NULL,
        email       VARCHAR(100) NOT NULL CONSTRAINT uq_lecturer_email UNIQUE,
        password    VARCHAR(255) NOT NULL
        -- personalEmail, lecturerCode, department, staffType : PATCH 2
        -- icNumber, phone : PATCH 9          lecturerTitle : PATCH 11
    );
GO

IF OBJECT_ID('dbo.STUDENT', 'U') IS NULL
    CREATE TABLE dbo.STUDENT (
        studentID      INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_student PRIMARY KEY,
        name           VARCHAR(100) NOT NULL,
        email          VARCHAR(100) NOT NULL CONSTRAINT uq_student_email UNIQUE,
        password       VARCHAR(255) NOT NULL,
        programmeID    INT          NULL CONSTRAINT fk_student_programme REFERENCES dbo.PROGRAMME(programmeID),
        -- Pre-created on purpose (PATCH 1 adds them only IF NOT EXISTS) - see header.
        personalEmail  VARCHAR(100) NULL,
        studentCode    VARCHAR(20)  NULL     -- UNIQUE uq_student_code is added by PATCH 1
        -- emergencyContact* : PATCH 1   icNumber, phone, intakeSemester : PATCH 9
        -- otpCode, otpExpiry, isActivated : PATCH 10   currentSemester, studentStatus : PATCH 13
    );
GO

IF OBJECT_ID('dbo.COURSE', 'U') IS NULL
    CREATE TABLE dbo.COURSE (
        courseID     INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_course PRIMARY KEY,
        programmeID  INT           NOT NULL CONSTRAINT fk_course_programme REFERENCES dbo.PROGRAMME(programmeID),
        lecturerID   INT           NULL     CONSTRAINT fk_course_lecturer  REFERENCES dbo.LECTURER(lecturerID),
        courseName   VARCHAR(150)  NOT NULL,
        courseCode   VARCHAR(20)   NOT NULL CONSTRAINT uq_course_code UNIQUE,
        creditHour   INT           NOT NULL CONSTRAINT df_course_credit DEFAULT 4,
        description  NVARCHAR(500) NULL,
        semester     INT           NOT NULL CONSTRAINT df_course_semester DEFAULT 1,   -- 1 / 2 / 3 (programme semester)
        maxCapacity  INT           NOT NULL CONSTRAINT df_course_capacity DEFAULT 40,
        status       VARCHAR(20)   NOT NULL CONSTRAINT df_course_status DEFAULT 'Active' -- Active / Inactive / Full
    );
GO

-- enrolmentID is VARCHAR with no IDENTITY: PATCH 12 installs an INSTEAD OF
-- INSERT trigger that generates numeric string IDs. No index/constraint may
-- depend on `semester` ("SQL CODE  UPDATED" runs ALTER COLUMN semester).
-- Status default is dropped and replaced by PATCH 4.
IF OBJECT_ID('dbo.ENROLMENT', 'U') IS NULL
    CREATE TABLE dbo.ENROLMENT (
        enrolmentID   VARCHAR(20) NOT NULL CONSTRAINT pk_enrolment PRIMARY KEY,
        studentID     INT         NOT NULL CONSTRAINT fk_enrolment_student REFERENCES dbo.STUDENT(studentID),
        courseID      INT         NOT NULL CONSTRAINT fk_enrolment_course  REFERENCES dbo.COURSE(courseID),
        semester      VARCHAR(30) NULL,        -- matches SEMESTER_SESSION.semesterName, e.g. 'AUGUST 2026'
        academicYear  VARCHAR(10) NULL,        -- e.g. '2026/2027'
        enrolDate     DATETIME    NULL CONSTRAINT df_enrolment_date DEFAULT GETDATE(),
        status        VARCHAR(20) NOT NULL CONSTRAINT df_enrolment_status_base DEFAULT 'Active'
        -- warningLevel, warningSentAt : PATCH 13
    );
GO

IF OBJECT_ID('dbo.ATTENDANCE', 'U') IS NULL
    CREATE TABLE dbo.ATTENDANCE (
        attendanceID    INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_attendance PRIMARY KEY,
        studentID       INT         NOT NULL CONSTRAINT fk_attendance_student  REFERENCES dbo.STUDENT(studentID),
        courseID        INT         NOT NULL CONSTRAINT fk_attendance_course   REFERENCES dbo.COURSE(courseID),
        lecturerID      INT         NULL     CONSTRAINT fk_attendance_lecturer REFERENCES dbo.LECTURER(lecturerID),
        attendanceDate  DATE        NOT NULL,
        sessionType     VARCHAR(20) NULL,      -- Lecture / Tutorial / Lab
        status          VARCHAR(10) NOT NULL   -- Present / Absent / Late
    );
GO

-- publishedStatus is added by PATCH 7 (rows with publishedDate become 'Published').
IF OBJECT_ID('dbo.RESULT', 'U') IS NULL
    CREATE TABLE dbo.RESULT (
        resultID       INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_result PRIMARY KEY,
        studentID      INT          NOT NULL CONSTRAINT fk_result_student  REFERENCES dbo.STUDENT(studentID),
        courseID       INT          NOT NULL CONSTRAINT fk_result_course   REFERENCES dbo.COURSE(courseID),
        lecturerID     INT          NULL     CONSTRAINT fk_result_lecturer REFERENCES dbo.LECTURER(lecturerID),
        semester       VARCHAR(30)  NULL,      -- ManageGrades writes '1'
        marks          DECIMAL(5,2) NULL,
        grade          VARCHAR(5)   NULL,
        GPA            DECIMAL(3,2) NULL,
        remarks        VARCHAR(255) NULL,
        publishedDate  DATETIME     NULL
        -- publishedStatus : PATCH 7     retakeRequired, failNotifiedAt : PATCH 13
    );
GO

-- Reports.aspx.cs writes Session["UserName"] (a string) into generatedBy.
IF OBJECT_ID('dbo.REPORT', 'U') IS NULL
    CREATE TABLE dbo.REPORT (
        reportID         INT IDENTITY(1,1) NOT NULL CONSTRAINT pk_report PRIMARY KEY,
        reportType       VARCHAR(100) NOT NULL,
        programmeFilter  VARCHAR(255) NULL,
        semesterFilter   VARCHAR(50)  NULL,
        dateRange        VARCHAR(100) NULL,
        generatedBy      VARCHAR(100) NULL,
        generatedDate    DATETIME     NOT NULL CONSTRAINT df_report_date DEFAULT GETDATE()
    );
GO

-- AcademicCalendar.aspx.cs also creates this at runtime (identical
-- definition, IF NOT EXISTS), so creating it here is harmless.
IF OBJECT_ID('dbo.ACADEMIC_CALENDAR', 'U') IS NULL
    CREATE TABLE dbo.ACADEMIC_CALENDAR (
        calendarID   INT IDENTITY(1,1) PRIMARY KEY,
        eventName    NVARCHAR(150) NOT NULL,
        eventType    VARCHAR(20)   NOT NULL,
        startDate    DATE          NOT NULL,
        endDate      DATE          NULL,
        academicYear VARCHAR(10)   NULL,
        affects      VARCHAR(20)   NOT NULL DEFAULT 'All',
        createdBy    INT           NULL
    );
GO

-- Not created here (a patch creates and seeds them):
--   SEMESTER_SESSION (PATCH 5), NOTIFICATION (PATCH 6/8),
--   ATTENDANCE_WARNING_LOG and PERSONAL_REMINDER (PATCH 13).

-- =====================================================================
-- SEED DATA (base columns only). Password hash below = Base64(SHA-256("Test@123")).
-- =====================================================================

IF NOT EXISTS (SELECT 1 FROM dbo.PROGRAMME)
BEGIN
    SET IDENTITY_INSERT dbo.PROGRAMME ON;
    INSERT INTO dbo.PROGRAMME (programmeID, programmeName, programmeCode, faculty, totalCredits, durationYears, status)
    VALUES (1, 'Bachelor of Computer Science (Hons)', 'BCS', 'Faculty of Computing', 120, 3, 'Active');
    SET IDENTITY_INSERT dbo.PROGRAMME OFF;
END
GO

-- adminID 1 is required: PATCH 3 updates adminID 1, PATCH 5 seeds createdBy = 1.
IF NOT EXISTS (SELECT 1 FROM dbo.HOP_ADMIN)
BEGIN
    SET IDENTITY_INSERT dbo.HOP_ADMIN ON;
    INSERT INTO dbo.HOP_ADMIN (adminID, name, email, password)
    VALUES (1, 'Test Admin', 'admin@sims.edu', 'h3bxCOJHqx4rMjBCwEnCZkB8gfutQb3h6N/Bu2b9Jn4=');
    SET IDENTITY_INSERT dbo.HOP_ADMIN OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.LECTURER)
BEGIN
    SET IDENTITY_INSERT dbo.LECTURER ON;
    INSERT INTO dbo.LECTURER (lecturerID, name, email, password)
    VALUES (1, 'Test Lecturer', 'lecturer@sims.edu', 'h3bxCOJHqx4rMjBCwEnCZkB8gfutQb3h6N/Bu2b9Jn4=');
    SET IDENTITY_INSERT dbo.LECTURER OFF;
END
GO

-- personalEmail uses the reserved example.com domain so any app email goes nowhere real.
IF NOT EXISTS (SELECT 1 FROM dbo.STUDENT)
BEGIN
    SET IDENTITY_INSERT dbo.STUDENT ON;
    INSERT INTO dbo.STUDENT (studentID, name, email, password, programmeID, personalEmail, studentCode) VALUES
    (1, 'Test Student One', 'student1@sims.edu', 'h3bxCOJHqx4rMjBCwEnCZkB8gfutQb3h6N/Bu2b9Jn4=', 1, 'student1@example.com', 'STU2604001'),
    (2, 'Test Student Two', 'student2@sims.edu', 'h3bxCOJHqx4rMjBCwEnCZkB8gfutQb3h6N/Bu2b9Jn4=', 1, 'student2@example.com', 'STU2604002');
    SET IDENTITY_INSERT dbo.STUDENT OFF;
END
GO

-- Course codes/names match the NOTIFICATION rows PATCH 6 seeds for student 1.
IF NOT EXISTS (SELECT 1 FROM dbo.COURSE)
BEGIN
    SET IDENTITY_INSERT dbo.COURSE ON;
    INSERT INTO dbo.COURSE (courseID, programmeID, lecturerID, courseName, courseCode, creditHour, description, semester, maxCapacity, status) VALUES
    (1, 1, 1, 'Introduction to AI',     'DCS101', 4, 'Foundations of artificial intelligence.', 1, 40, 'Active'),
    (2, 1, 1, 'Software Engineering',   'DCS205', 4, 'Software process, requirements and design.', 1, 40, 'Active'),
    (3, 1, 1, 'Database Systems',       'DCS110', 4, 'Relational databases and SQL.', 1, 40, 'Active'),
    (4, 1, 1, 'Web Application Development', 'DCS210', 4, 'Server-side web development.', 2, 40, 'Active');
    SET IDENTITY_INSERT dbo.COURSE OFF;
END
GO

-- Semester 'AUGUST 2026' / '2026/2027' = the session PATCH 5 seeds as 'Open'.
-- enrolmentID supplied explicitly (PATCH 12 trigger does not exist yet).
IF NOT EXISTS (SELECT 1 FROM dbo.ENROLMENT)
    INSERT INTO dbo.ENROLMENT (enrolmentID, studentID, courseID, semester, academicYear, enrolDate, status) VALUES
    ('1', 1, 1, 'AUGUST 2026', '2026/2027', '2026-06-15', 'enrolled'),
    ('2', 1, 2, 'AUGUST 2026', '2026/2027', '2026-06-15', 'enrolled'),
    ('3', 1, 3, 'AUGUST 2026', '2026/2027', '2026-06-15', 'enrolled'),
    ('4', 2, 1, 'AUGUST 2026', '2026/2027', '2026-06-16', 'enrolled'),
    ('5', 2, 2, 'AUGUST 2026', '2026/2027', '2026-06-16', 'enrolled'),
    ('6', 2, 3, 'AUGUST 2026', '2026/2027', '2026-06-16', 'pending');
GO

-- Student 1 attends well; student 2 is below 80% in DCS101 (shows on At-Risk pages).
IF NOT EXISTS (SELECT 1 FROM dbo.ATTENDANCE)
    INSERT INTO dbo.ATTENDANCE (studentID, courseID, lecturerID, attendanceDate, sessionType, status) VALUES
    (1, 1, 1, '2026-08-03', 'Lecture', 'Present'),
    (1, 1, 1, '2026-08-06', 'Lecture', 'Present'),
    (1, 1, 1, '2026-08-10', 'Lecture', 'Present'),
    (1, 1, 1, '2026-08-13', 'Lecture', 'Present'),
    (1, 2, 1, '2026-08-04', 'Lecture', 'Present'),
    (1, 2, 1, '2026-08-07', 'Lecture', 'Absent'),
    (1, 2, 1, '2026-08-11', 'Lecture', 'Present'),
    (2, 1, 1, '2026-08-03', 'Lecture', 'Present'),
    (2, 1, 1, '2026-08-06', 'Lecture', 'Absent'),
    (2, 1, 1, '2026-08-10', 'Lecture', 'Absent'),
    (2, 1, 1, '2026-08-13', 'Lecture', 'Present'),
    (2, 2, 1, '2026-08-04', 'Lecture', 'Present'),
    (2, 2, 1, '2026-08-07', 'Lecture', 'Present');
GO

-- Rows with publishedDate become 'Published' in PATCH 7; NULL publishedDate -> 'Draft'.
IF NOT EXISTS (SELECT 1 FROM dbo.RESULT)
    INSERT INTO dbo.RESULT (studentID, courseID, lecturerID, semester, marks, grade, GPA, remarks, publishedDate) VALUES
    (1, 1, 1, '1', 78.50, 'B+', 3.33, NULL, '2026-10-30'),            -- published pass
    (2, 1, 1, '1', 45.00, 'F',  0.00, NULL, '2026-10-30'),            -- published fail (Results & Retake tab)
    (1, 2, 1, '1', 70.00, 'B+', 3.33, NULL, NULL);                    -- draft
GO

IF NOT EXISTS (SELECT 1 FROM dbo.ACADEMIC_CALENDAR)
    INSERT INTO dbo.ACADEMIC_CALENDAR (eventName, eventType, startDate, endDate, academicYear, affects, createdBy) VALUES
    (N'Final Examinations', 'Exam',    '2026-12-07', '2026-12-18', '2026/2027', 'All', 1),
    (N'Semester Break',     'Holiday', '2026-12-21', '2027-01-03', '2026/2027', 'All', 1);
GO

-- =====================================================================
-- POST-PATCH SEED  (only does something when this file is RE-RUN after
-- "SQL CODE  UPDATED" and PATCH 10-13). Each block is guarded by
-- COL_LENGTH and uses EXEC() so this batch still compiles on a fresh DB
-- where the columns do not exist yet.
-- =====================================================================

-- Seeded students: make sure they never hit the OTP screen (PATCH 10).
IF COL_LENGTH('dbo.STUDENT', 'isActivated') IS NOT NULL
    EXEC(N'UPDATE dbo.STUDENT SET isActivated = 1, otpCode = NULL, otpExpiry = NULL
           WHERE email IN (''student1@sims.edu'', ''student2@sims.edu'');');

-- Contact details (PATCH 1 / PATCH 9).
IF COL_LENGTH('dbo.STUDENT', 'emergencyContactName') IS NOT NULL
    EXEC(N'UPDATE dbo.STUDENT SET emergencyContactName = ''Parent of '' + name,
                                 emergencyContactRel  = ''Parent'',
                                 emergencyContactPhone = ''012-0000000''
           WHERE email IN (''student1@sims.edu'', ''student2@sims.edu'') AND emergencyContactName IS NULL;');

IF COL_LENGTH('dbo.STUDENT', 'intakeSemester') IS NOT NULL
    EXEC(N'UPDATE dbo.STUDENT SET intakeSemester = ''AUGUST 2026'', phone = ''011-0000000''
           WHERE email IN (''student1@sims.edu'', ''student2@sims.edu'') AND intakeSemester IS NULL;');

-- Progression standing (PATCH 13).
IF COL_LENGTH('dbo.STUDENT', 'currentSemester') IS NOT NULL
    EXEC(N'UPDATE dbo.STUDENT SET currentSemester = 1
           WHERE email IN (''student1@sims.edu'', ''student2@sims.edu'') AND currentSemester IS NULL;');

-- Lecturer: PATCH 2 / 11 already set code, department, staffType, title for lecturerID 1.
IF COL_LENGTH('dbo.LECTURER', 'phone') IS NOT NULL
    EXEC(N'UPDATE dbo.LECTURER SET phone = ''013-0000000''
           WHERE email = ''lecturer@sims.edu'' AND phone IS NULL;');
GO

PRINT 'SIMS_DB_00_base_schema.sql done. Now run "SQL CODE  UPDATED" and PATCH 10-13 against SIMS_DB, then re-run this file.';
GO
