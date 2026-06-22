-- =====================================================================
-- SIMS_DB PATCH 11 — role identity fields
-- Safe to run multiple times. No tables dropped.
-- Adds:
--   HOP_ADMIN.headOf       VARCHAR(100) - programme the HOP is Head of
--   LECTURER.lecturerTitle VARCHAR(80)  - e.g. "Senior Lecturer of IT"
-- Students need no new column: identity = their PROGRAMME.programmeName.
-- =====================================================================

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME = 'HOP_ADMIN' AND COLUMN_NAME = 'headOf')
    ALTER TABLE HOP_ADMIN ADD headOf VARCHAR(100) NULL;
GO

UPDATE HOP_ADMIN SET headOf = 'Computer Science' WHERE adminID = 1 AND headOf IS NULL;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
               WHERE TABLE_NAME = 'LECTURER' AND COLUMN_NAME = 'lecturerTitle')
    ALTER TABLE LECTURER ADD lecturerTitle VARCHAR(80) NULL;
GO

UPDATE LECTURER SET lecturerTitle = 'Senior Lecturer of IT'            WHERE lecturerID = 1 AND lecturerTitle IS NULL;
UPDATE LECTURER SET lecturerTitle = 'Lecturer of Software Engineering' WHERE lecturerID = 2 AND lecturerTitle IS NULL;
UPDATE LECTURER SET lecturerTitle = 'Lecturer of Computer Science'     WHERE lecturerID = 3 AND lecturerTitle IS NULL;
UPDATE LECTURER SET lecturerTitle = 'Senior Lecturer of Business'      WHERE lecturerID = 4 AND lecturerTitle IS NULL;
GO

PRINT 'PATCH 11 applied: HOP_ADMIN.headOf / LECTURER.lecturerTitle ready.';
GO

SELECT adminID, name, headOf FROM HOP_ADMIN;
SELECT lecturerID, name, department, lecturerTitle FROM LECTURER;
GO
