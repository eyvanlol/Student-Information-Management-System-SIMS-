# Builds SIMS_DB on SQL Server LocalDB from the scripts in this folder.
# Usage (PowerShell, in this folder):   .\setup-database.ps1
# If scripts are blocked:               powershell -ExecutionPolicy Bypass -File .\setup-database.ps1
param([string]$Server = '(localdb)\MSSQLLocalDB')

$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

# Run order matters. The base schema runs twice: the second pass only fills
# columns that the patches added (everything else is skipped).
$files = @(
  'SIMS_DB_00_base_schema.sql',
  'SQL CODE  UPDATED',
  'SIMS_DB_PATCH10_otp.sql',
  'SIMS_DB_PATCH11_identity.sql',
  'SIMS_DB_PATCH12_enrolment_autoid.sql',
  'SIMS_DB_PATCH13_missing_schema.sql',
  'SIMS_DB_00_base_schema.sql'
)

# Make sure LocalDB is running (it ships with Visual Studio's ASP.NET workload)
if (Get-Command sqllocaldb -ErrorAction SilentlyContinue) { sqllocaldb start MSSQLLocalDB | Out-Null }

Add-Type -AssemblyName System.Data
$conn = New-Object System.Data.SqlClient.SqlConnection("Server=$Server;Database=master;Integrated Security=true;")
$conn.add_InfoMessage({ param($s, $e) Write-Host "    $($e.Message)" -ForegroundColor DarkGray })
$conn.Open()
try {
  $first = $true
  foreach ($f in $files) {
    Write-Host "== $f" -ForegroundColor Cyan
    if (-not $first) { $conn.ChangeDatabase('SIMS_DB') }   # patches have no USE statement
    $first = $false
    $text = Get-Content -LiteralPath $f -Raw -Encoding UTF8
    $batches = [regex]::Split($text, '(?im)^\s*GO\s*;?\s*$')
    $i = 0
    foreach ($b in $batches) {
      $i++
      if ($b.Trim().Length -eq 0) { continue }
      $cmd = $conn.CreateCommand(); $cmd.CommandText = $b; $cmd.CommandTimeout = 120
      try { [void]$cmd.ExecuteNonQuery() }
      catch {
        $msg = if ($_.Exception.InnerException) { $_.Exception.InnerException.Message } else { $_.Exception.Message }
        Write-Host "!! '$f' batch $i failed: $msg" -ForegroundColor Red
        Write-Host ($b.Trim().Substring(0, [Math]::Min(500, $b.Trim().Length)))
        exit 1
      }
    }
  }
  Write-Host "`nSIMS_DB is ready. Test logins (password Test@123):" -ForegroundColor Green
  Write-Host "  admin@sims.edu, lecturer@sims.edu, student1@sims.edu, student2@sims.edu"
} finally { $conn.Close() }
