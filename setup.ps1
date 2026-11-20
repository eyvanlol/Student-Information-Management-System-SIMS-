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
$vsDir     = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer"
$vswhere   = Join-Path $vsDir 'vswhere.exe'
$vsSetup   = Join-Path $vsDir 'setup.exe'
$parts     = '--add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.Net.Component.4.7.2.TargetingPack --add Microsoft.VisualStudio.Component.SQL.LocalDB.Runtime --includeRecommended'

function Explain-InstallCode($code) {
  switch ($code) {
    { $_ -in 0, 3010 } { return $null }   # success (3010 = restart later)
    8006    { "Visual Studio or the Visual Studio Installer is still open. Close them (check the taskbar and the icons near the clock), or restart the PC, then run this script again." }
    1001    { "Another Visual Studio install or update is already running. Wait for it to finish, then run this script again." }
    { $_ -in 1602, 5004 } { "The install was cancelled (the admin prompt was declined or closed). Run this script again and click Yes." }
    740     { "The installer needs admin rights. Run this script again and click Yes on the admin prompt." }
    { $_ -in -1978335189, -1978335135 } { "Windows says Visual Studio 2022 is already installed, but it isn't working properly (probably an install that didn't finish). Open 'Visual Studio Installer' from the Start menu: click Resume or Repair if you see it, then click Modify, tick 'ASP.NET and web development' and click Modify. Then run this script again." }
    default { "The Visual Studio installer stopped with code $code. Restart the PC and run this script again. If it keeps failing, install 'ASP.NET and web development' from the Visual Studio Installer yourself." }
  }
}

$haveWeb = (Test-Path $vswhere) -and (& $vswhere -latest -prerelease -requires Microsoft.VisualStudio.Workload.NetWeb -property installationPath)
# -all also finds installs that didn't finish (those need "resume" before they can be changed)
$vsInfo  = if (Test-Path $vswhere) { & $vswhere -all -latest -prerelease -format json | Out-String | ConvertFrom-Json | Select-Object -First 1 } else { $null }
$anyVS   = if ($vsInfo) { $vsInfo.installationPath } else { $null }

if ($haveWeb) {
  Step "Visual Studio with ASP.NET is already installed"
} else {
  # The installer refuses to run while Visual Studio is open (error 8006)
  while (Get-Process devenv, vs_installer, vs_installershell -ErrorAction SilentlyContinue) {
    Write-Host "Please close Visual Studio and the Visual Studio Installer first." -ForegroundColor Yellow
    Read-Host "Press Enter when they're closed"
  }

  if ($anyVS -and (Test-Path $vsSetup)) {
    $code = 0
    if ($vsInfo.isComplete -eq $false) {
      # A previous install stopped halfway: finish it first
      Step "Finishing an earlier Visual Studio install that didn't complete (click YES on the admin prompt)"
      $p = Start-Process $vsSetup -ArgumentList "resume --installPath `"$anyVS`" --passive --norestart" -Verb RunAs -Wait -PassThru
      $code = $p.ExitCode
    }
    if ((Explain-InstallCode $code) -eq $null) {
      # Visual Studio exists but is missing the ASP.NET part: add it instead of reinstalling
      Step "Adding 'ASP.NET and web development' to your Visual Studio (click YES on the admin prompt; takes 10-30 min)"
      $p = Start-Process $vsSetup -ArgumentList "modify --installPath `"$anyVS`" $parts --passive --norestart" -Verb RunAs -Wait -PassThru
      $code = $p.ExitCode
      # Newer/preview Visual Studio versions may not know one of the extra parts:
      # retry with just the ASP.NET workload (it brings IIS Express and LocalDB)
      if ((Explain-InstallCode $code) -and $code -notin 8006, 1001, 1602, 5004, 740) {
        Step "Retrying with just 'ASP.NET and web development'"
        $p = Start-Process $vsSetup -ArgumentList "modify --installPath `"$anyVS`" --add Microsoft.VisualStudio.Workload.NetWeb --includeRecommended --passive --norestart" -Verb RunAs -Wait -PassThru
        $code = $p.ExitCode
      }
    }
  } else {
    Step "Installing Visual Studio 2022 Community (click YES on the admin prompt; takes 20-40 min)"
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
      Done-Fail "winget isn't available. Install Visual Studio 2022 Community yourself with the 'ASP.NET and web development' workload, then run this again."
    }
    winget install --id Microsoft.VisualStudio.2022.Community --exact --source winget `
      --accept-package-agreements --accept-source-agreements `
      --override "--passive --wait --norestart $parts" 2>&1 | Tee-Object -Variable wingetOut
    $code = $LASTEXITCODE
    # winget reports its own code; the installer's real code is in its output
    $m = [regex]::Match(($wingetOut | Out-String), 'exit code:\s*(\d+)')
    if ($m.Success) { $code = [int]$m.Groups[1].Value }
  }

  $why = Explain-InstallCode $code
  if ($why) { Done-Fail $why }

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
