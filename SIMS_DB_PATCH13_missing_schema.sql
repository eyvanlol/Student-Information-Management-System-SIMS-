-- =====================================================================
-- PATCH 13: columns and tables the C# code uses but no earlier script creates.
-- Safe to run more than once. Run AFTER "SQL CODE  UPDATED" and patches 10-12.
--   RESULT.retakeRequired / failNotifiedAt   -> ManageEnrolment, ProgressionService
--   STUDENT.currentSemester / studentStatus  -> ProgressionService, FinalResultProcessing
--   ENROLMENT.warningLevel / warningSentAt   -> LecturerAttendance
--   ATTENDANCE_WARNING_LOG                   -> AtRiskStudents
--   PERSONAL_REMINDER                        -> StudentCalendar, ReminderService
-- =====================================================================
USE SIMS_DB;
GO

IF COL_LENGTH('RESULT', 'retakeRequired') IS NULL
    ALTER TABLE RESULT ADD retakeRequired BIT NOT NULL CONSTRAINT df_result_retake DEFAULT 0;
IF COL_LENGTH('RESULT', 'failNotifiedAt') IS NULL
    ALTER TABLE RESULT ADD failNotifiedAt DATETIME NULL;
GO

IF COL_LENGTH('STUDENT', 'currentSemester') IS NULL
    ALTER TABLE STUDENT ADD currentSemester INT NULL;
IF COL_LENGTH('STUDENT', 'studentStatus') IS NULL
    ALTER TABLE STUDENT ADD studentStatus VARCHAR(20) NULL;   -- 'Advancing' / 'Retake' / 'Resit'
GO

IF COL_LENGTH('ENROLMENT', 'warningLevel') IS NULL
    ALTER TABLE ENROLMENT ADD warningLevel INT NULL;
IF COL_LENGTH('ENROLMENT', 'warningSentAt') IS NULL
    ALTER TABLE ENROLMENT ADD warningSentAt DATETIME NULL;
GO

IF OBJECT_ID('ATTENDANCE_WARNING_LOG', 'U') IS NULL
    CREATE TABLE ATTENDANCE_WARNING_LOG (
        logID     INT IDENTITY(1,1) PRIMARY KEY,
        studentID INT      NOT NULL,
        courseID  INT      NOT NULL,
        sentDate  DATETIME NOT NULL DEFAULT GETDATE()
    );
GO

IF OBJECT_ID('PERSONAL_REMINDER', 'U') IS NULL
    CREATE TABLE PERSONAL_REMINDER (
        reminderID   INT IDENTITY(1,1) PRIMARY KEY,
        studentID    INT            NOT NULL,
        title        NVARCHAR(150)  NOT NULL,
        description  NVARCHAR(MAX)  NULL,
        startTime    DATETIME       NOT NULL,
        reminderSent BIT            NOT NULL DEFAULT 0,
        createdAt    DATETIME       NOT NULL DEFAULT GETDATE()
    );
GO

PRINT 'PATCH 13 applied.';
GO
