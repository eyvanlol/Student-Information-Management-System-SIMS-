# Student-Information-Management-System-SIMS-

project namespace; StudentManagementSystem 
database name; SIMS_DB

PDF Excel Exportation packages
ClosedXML
iTextSharp
(Manage NuGet Packages for solution -> Search -> install)


## Database setup (run in this order, in SQL Server Management Studio against SIMS_DB)
1. `SQL CODE  UPDATED`
2. `SIMS_DB_PATCH10_otp.sql`
3. `SIMS_DB_PATCH11_identity.sql`
4. `SIMS_DB_PATCH12_enrolment_autoid.sql`
5. `SIMS_DB_PATCH13_missing_schema.sql` (adds the columns/tables for retakes, progression, attendance warnings and calendar reminders)

All patches can be re-run safely.

## Opening the project
Open `INTISESESE.csproj` (not `RecentSE.csproj`, which is an old copy). The NuGet hint paths expect a `packages` folder one level up, so keep this folder inside your solution folder, then restore NuGet packages.
