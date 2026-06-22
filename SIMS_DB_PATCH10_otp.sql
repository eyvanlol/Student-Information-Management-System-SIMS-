-- =====================================================================
-- SIMS_DB PATCH 10 — STUDENT first-time OTP / account activation
-- Safe to run multiple times. No tables dropped.
-- Adds:
--   otpCode      VARCHAR(6)  - the 6-digit one-time code (NULL once used)
--   otpExpiry    DATETIME    - when the code stops being valid
--   isActivated  BIT         - 0 = must verify OTP on first login, 1 = active
-- Existing students are marked activated so they are NOT locked out.
-- =====================================================================

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME = 'STUDENT' AND COLUMN_NAME = 'otpCode')
    ALTER TABLE STUDENT ADD otpCode VARCHAR(6) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME = 'STUDENT' AND COLUMN_NAME = 'otpExpiry')
    ALTER TABLE STUDENT ADD otpExpiry DATETIME NULL;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME = 'STUDENT' AND COLUMN_NAME = 'isActivated')
    ALTER TABLE STUDENT ADD isActivated BIT NOT NULL DEFAULT 0;
GO

-- Mark all pre-OTP students as activated (they have no pending code).
-- Re-running this later is safe: students still waiting on a code keep
-- a non-NULL otpCode, so they are skipped.
UPDATE STUDENT SET isActivated = 1 WHERE isActivated = 0 AND otpCode IS NULL;
GO

PRINT 'PATCH 10 applied: otpCode / otpExpiry / isActivated ready.';
GO

-- Verify
SELECT studentID, name, studentCode, email, personalEmail, isActivated, otpCode, otpExpiry
FROM STUDENT
ORDER BY studentID;
GO
