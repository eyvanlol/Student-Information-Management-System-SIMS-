# One-step setup for SIMS on a Windows PC.
#
# Run it from this folder (type this in File Explorer's address bar, or in PowerShell):
#   powershell -ExecutionPolicy Bypass -File .\setup.ps1
#
# What it does:
#   1. Installs Visual Studio 2022 Community + "ASP.NET and web development" + LocalDB,
#      only if they're missing  -> click YES on the Windows admin prompt, then wait 20-40 min
#   2. Builds the SIMS_DB database and lists the accounts you can log in with
#   3. Opens SIMS.sln  -> press F5 in Visual Studio to run the site
#
# Options:
#   -ResetPasswords   also set every account's password to Test@123

param([switch]$ResetPasswords)

$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

function Step($t) { Write-Host "`n=== $t" -ForegroundColor Cyan }
function Done-Fail($msg) { Write-Host $msg -ForegroundColor Red; Read-Host "Press Enter to close"; exit 1 }

if ($PSScriptRoot -like "*OneDrive*") {
  Write-Host "Note: this folder is inside OneDrive. It works, but NuGet packages will sync too." -ForegroundColor Yellow
}

# 1. Visual Studio (provides MSBuild, IIS Express and SQL Server LocalDB)
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$haveVS = (Test-Path $vswhere) -and (& $vswhere -latest -requires Microsoft.VisualStudio.Workload.NetWeb -property installationPath)
if ($haveVS) {
  Step "Visual Studio with ASP.NET is already installed"
} else {
  Step "Installing Visual Studio 2022 Community (click YES on the admin prompt; takes 20-40 min)"
  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Done-Fail "winget isn't available. Install Visual Studio 2022 Community yourself with the 'ASP.NET and web development' workload, then run this again."
  }
  winget install --id Microsoft.VisualStudio.2022.Community --exact --source winget `
    --accept-package-agreements --accept-source-agreements `
    --override "--passive --wait --norestart --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.Net.Component.4.7.2.TargetingPack --add Microsoft.VisualStudio.Component.SQL.LocalDB.Runtime --includeRecommended"
  if ($LASTEXITCODE -ne 0) {
    Done-Fail "Visual Studio install did not finish (code $LASTEXITCODE). If you clicked No on the admin prompt, run this script again."
  }
  # pick up sqllocaldb on PATH in this window
  $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
}

# 2. Database
Step "Building the SIMS_DB database"
& (Join-Path $PSScriptRoot 'setup-database.ps1') -ResetPasswords:$ResetPasswords
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { Done-Fail "Database setup failed - see the red text above." }

# 3. Open the solution
Step "Opening SIMS.sln - press F5 in Visual Studio to run the site"
Start-Process (Join-Path $PSScriptRoot 'SIMS.sln')
Read-Host "Press Enter to close"
