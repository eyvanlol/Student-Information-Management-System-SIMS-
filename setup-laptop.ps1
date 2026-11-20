# One-click setup for SIMS on a new Windows PC.
# Right-click this file -> "Run with PowerShell"
#   (or: powershell -ExecutionPolicy Bypass -File .\setup-laptop.ps1)
#
# What it does:
#   1. Copies the project to Documents\SIMS (out of OneDrive, so NuGet packages don't sync)
#   2. Installs Visual Studio 2022 Community + ASP.NET workload + LocalDB if missing
#      -> click YES on the Windows admin prompt, then wait 20-40 minutes
#   3. Builds the SIMS_DB database
#   4. Opens SIMS.sln -> press F5 in Visual Studio

$ErrorActionPreference = 'Stop'
$src  = $PSScriptRoot
$dest = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'SIMS'

function Step($t) { Write-Host "`n=== $t" -ForegroundColor Cyan }

# 1. Copy project
if ($src -ne $dest) {
  Step "Copying project to $dest"
  New-Item -ItemType Directory -Force $dest | Out-Null
  robocopy $src $dest /E /NFL /NDL /NJH /NJS /NP | Out-Null
}

# 2. Visual Studio (provides MSBuild, IIS Express and SQL Server LocalDB)
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$haveVS = (Test-Path $vswhere) -and (& $vswhere -latest -requires Microsoft.VisualStudio.Workload.NetWeb -property installationPath)
if (-not $haveVS) {
  Step "Installing Visual Studio 2022 Community (click YES on the admin prompt; takes 20-40 min)"
  winget install --id Microsoft.VisualStudio.2022.Community --exact --source winget `
    --accept-package-agreements --accept-source-agreements `
    --override "--passive --wait --norestart --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.Net.Component.4.7.2.TargetingPack --add Microsoft.VisualStudio.Component.SQL.LocalDB.Runtime --includeRecommended"
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Visual Studio install did not finish (code $LASTEXITCODE). If you clicked No on the admin prompt, run this script again." -ForegroundColor Red
    Read-Host "Press Enter to close"; exit 1
  }
  # make sqllocaldb visible in this window
  $env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
} else {
  Step "Visual Studio with ASP.NET is already installed"
}

# 3. Database
Step "Building the SIMS_DB database"
& (Join-Path $dest 'setup-database.ps1')
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { Read-Host "Database setup failed - see above. Press Enter to close"; exit 1 }

# 4. Open the solution
Step "Opening SIMS.sln - press F5 in Visual Studio to run the site"
Start-Process (Join-Path $dest 'SIMS.sln')
Write-Host "Log in with admin@sims.edu / Test@123" -ForegroundColor Green
Read-Host "Press Enter to close"
