# Student Information Management System (SIMS)

ASP.NET Web Forms (.NET Framework 4.7.2) + SQL Server LocalDB.
Project namespace: `StudentManagementSystem` · Database: `SIMS_DB`

## Quick start (Windows)

1. **Download the project**: on GitHub click **Code → Download ZIP** and extract it, or run
   `git clone https://github.com/eyvanlol/Student-Information-Management-System-SIMS-.git`
2. **Run the setup**: open the project folder in File Explorer, click the address bar, type this and press Enter:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\setup.ps1
   ```

   It will:
   - install Visual Studio 2022 Community with **ASP.NET and web development** and LocalDB, if they're missing
     (click **Yes** on the Windows admin prompt; this takes 20-40 minutes)
   - create or update the `SIMS_DB` database and **list the accounts you can log in with**
   - open `SIMS.sln`
3. **Press F5** in Visual Studio. The site opens on the login page.

> Don't double-click `setup.ps1`. Windows opens it as a text file instead of running it.

## Logging in

On a new database, the setup creates these accounts, all with the password **`Test@123`**:

| Role | Email |
|---|---|
| Admin | admin@sims.edu |
| Lecturer | lecturer@sims.edu |
| Student | student1@sims.edu, student2@sims.edu |

If you already had a `SIMS_DB`, your existing accounts are kept and the setup lists them at the end.
**Forgot a password?** Run this to set every account to `Test@123` and skip the student email code:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -ResetPasswords
```

## What's in the database scripts

`setup-database.ps1` runs these in order on `(localdb)\MSSQLLocalDB`. Every script is safe to re-run:

1. `SIMS_DB_00_base_schema.sql`: creates the database, base tables and sample data
   (rebuilt from the C# queries, because the original CREATE TABLE script wasn't in the repo)
2. `SQL CODE  UPDATED`: patches 1-12
3. `SIMS_DB_PATCH10_otp.sql`, `SIMS_DB_PATCH11_identity.sql`, `SIMS_DB_PATCH12_enrolment_autoid.sql`
4. `SIMS_DB_PATCH13_missing_schema.sql`: retakes, progression, attendance warnings, calendar reminders
5. `SIMS_DB_00_base_schema.sql` again: fills columns the patches added

## Notes

- NuGet packages (ClosedXML, iTextSharp, …) restore automatically on the first build, into a `packages`
  folder next to the project folder (set in `nuget.config`).
- Students registered in the app get a one-time code by email. Without working email, read it with
  `SELECT email, otpCode FROM STUDENT WHERE isActivated = 0;`
- Email is sent through the Gmail account in `Web.config` (`Smtp:*` settings). Use your own Gmail App Password there.
