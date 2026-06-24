-- =====================================================================
-- SIMS_DB PATCH 12 — ENROLMENT auto-ID fix (numeric, not lexicographic)
-- Safe to run multiple times. No data dropped.
--
-- CAUSE: enrolmentID is VARCHAR with no IDENTITY/DEFAULT. The ID was
-- generated as MAX(enrolmentID)+1, but VARCHAR MAX sorts as text, so
-- MAX of "1".."10" is "9" (not "10"). Generator produced 10, which
-- already existed -> PK violation "duplicate key value is (10)".
--
-- FIX: replace the generator with an INSTEAD OF INSERT trigger that
-- computes the next ID using MAX(TRY_CAST(enrolmentID AS INT)) and
-- assigns sequential IDs even for multi-row inserts.
-- =====================================================================

-- 1) Drop ANY existing trigger on ENROLMENT (whatever it is named),
--    so we don't end up with a stale string-MAX trigger fighting ours.
DECLARE @drop NVARCHAR(MAX) = N'';
SELECT @drop += N'DROP TRIGGER ' + QUOTENAME(s.name) + N'.' + QUOTENAME(t.name) + N';' + CHAR(10)
FROM   sys.triggers t
JOIN   sys.tables   tb ON t.parent_id = tb.object_id
JOIN   sys.schemas  s  ON tb.schema_id = s.schema_id
WHERE  t.parent_id = OBJECT_ID('dbo.ENROLMENT');

IF @drop <> N''
BEGIN
    PRINT 'Dropping existing ENROLMENT trigger(s):';
    PRINT @drop;
    EXEC sp_executesql @drop;
END
ELSE
    PRINT 'No existing trigger on ENROLMENT (none to drop).';
GO

-- 2) Create the correct numeric auto-ID trigger.
--    CREATE TRIGGER must be the first statement in its batch, hence the GO above.
CREATE TRIGGER dbo.TR_ENROLMENT_AutoID
ON dbo.ENROLMENT
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Current highest numeric ID (text values cast safely; non-numeric -> ignored)
    DECLARE @base INT = (SELECT ISNULL(MAX(TRY_CAST(enrolmentID AS INT)), 0) FROM dbo.ENROLMENT);

    INSERT INTO dbo.ENROLMENT
        (enrolmentID, studentID, courseID, semester, academicYear, enrolDate, status)
    SELECT
        CAST(@base + ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS VARCHAR(20)),  -- sequential numeric IDs
        i.studentID,
        i.courseID,
        i.semester,
        i.academicYear,
        ISNULL(i.enrolDate, GETDATE()),     -- respects the column default if not supplied
        ISNULL(i.status,    'pending')      -- respects the column default if not supplied
    FROM inserted i;
END
GO

PRINT 'PATCH 12 applied: dbo.TR_ENROLMENT_AutoID now generates numeric enrolmentIDs.';
GO

-- 3) Verify
SELECT MAX(TRY_CAST(enrolmentID AS INT)) AS CurrentMaxId   -- should read 10; next insert -> 11
FROM   dbo.ENROLMENT;

SELECT name AS TriggerOnEnrolment
FROM   sys.triggers
WHERE  parent_id = OBJECT_ID('dbo.ENROLMENT');             -- should list TR_ENROLMENT_AutoID only
GO
