# Student-Information-Management-System-SIMS-

project namespace; StudentManagementSystem 
database name; SIMS_DB

PDF Excel Exportation packages
ClosedXML
iTextSharp
(Manage NuGet Packages for solution -> Search -> install)


## How to run it (Windows)

**1. Install** Visual Studio 2022 Community with the **ASP.NET and web development** workload
(this includes IIS Express and SQL Server LocalDB).

**2. Build the database.** Open PowerShell in this folder and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-database.ps1
```

This creates `SIMS_DB` on `(localdb)\MSSQLLocalDB` and runs every script in order:
`SIMS_DB_00_base_schema.sql` → `SQL CODE  UPDATED` → PATCH 10 → 11 → 12 → 13 → `SIMS_DB_00_base_schema.sql` again
(the second pass only fills columns the patches added). Everything is safe to re-run.

**3. Open `SIMS.sln`** in Visual Studio, then press **F5**. NuGet packages restore automatically
(into a `packages` folder one level up, set by `nuget.config`). The site opens on `Login.aspx`.

**Test logins** (all use password `Test@123`):

| Role | Email |
|---|---|
| Admin | admin@sims.edu |
| Lecturer | lecturer@sims.edu |
| Student | student1@sims.edu, student2@sims.edu |

Notes:
- `SIMS_DB_00_base_schema.sql` was rebuilt from the C# queries because the original CREATE TABLE script wasn't in the repo.
- New students registered in the app must enter an emailed OTP. Without working email, read the code with
  `SELECT email, otpCode FROM STUDENT WHERE isActivated = 0;`
- `RecentSE.csproj` is an old copy of the project; use `SIMS.sln` / `INTISESESE.csproj`.
