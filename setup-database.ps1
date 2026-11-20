# Builds SIMS_DB on SQL Server LocalDB from the scripts in this folder.
# Usage (PowerShell, in this folder):   .\setup-database.ps1
# If scripts are blocked:               powershell -ExecutionPolicy Bypass -File .\setup-database.ps1
#   -ResetPasswords   set every account's password to Test@123 and activate all students
param([string]$Server = '(localdb)\MSSQLLocalDB', [switch]$ResetPasswords)

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
  Write-Host "`nSIMS_DB is ready." -ForegroundColor Green

  # Optional: make every account usable locally (password Test@123, students activated)
  if ($ResetPasswords) {
    foreach ($t in 'HOP_ADMIN','LECTURER','STUDENT') {
      $cmd = $conn.CreateCommand(); $cmd.CommandText = "UPDATE $t SET password = 'Test@123'"
      Write-Host ("Reset {0} {1} password(s) to Test@123" -f $cmd.ExecuteNonQuery(), $t)
    }
    $cmd = $conn.CreateCommand(); $cmd.CommandText = "UPDATE STUDENT SET isActivated = 1, otpCode = NULL WHERE isActivated = 0"
    Write-Host ("Activated {0} student account(s) (no email code needed)" -f $cmd.ExecuteNonQuery())
  }

  # List who can log in. The login form takes the email + password.
  # Passwords stored as a hash can't be shown: run with -ResetPasswords to set them all to Test@123.
  $hashed = $false
  foreach ($t in @(@('HOP_ADMIN','Admin'), @('LECTURER','Lecturer'), @('STUDENT','Student'))) {
    $extra = if ($t[0] -eq 'STUDENT') { ", isActivated" } else { ", CAST(1 AS BIT) AS isActivated" }
    $cmd = $conn.CreateCommand(); $cmd.CommandText = "SELECT email, password $extra FROM $($t[0]) ORDER BY email"
    $r = $cmd.ExecuteReader()
    Write-Host "`n  $($t[1]) logins:" -ForegroundColor Green
    while ($r.Read()) {
      $p = "$($r['password'])"
      if ($p.Length -ge 40) { $p = '(hidden - stored as a hash)'; $hashed = $true }
      $note = if ($r['isActivated'] -eq $false) { '  [first login asks for an emailed code]' } else { '' }
      Write-Host ("    {0,-32} password: {1}{2}" -f $r['email'], $p, $note)
    }
    $r.Close()
  }
  Write-Host ""
  Write-Host "  Accounts this setup created use the password Test@123." -ForegroundColor Green
  if ($hashed) { Write-Host "  Forgot a hidden password? Run:  powershell -ExecutionPolicy Bypass -File .\setup.ps1 -ResetPasswords" -ForegroundColor Yellow }
} finally { $conn.Close() }
