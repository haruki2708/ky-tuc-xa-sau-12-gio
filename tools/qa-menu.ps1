param(
    [string]$Stage,
    [ValidateSet(1, 2, 3)][int]$Chapter = 1,
    [string]$Profile,
    [switch]$Smoke
)
$ErrorActionPreference = 'Stop'
if (-not $Stage) { $Stage = if ($Chapter -eq 3) { 'b' } elseif ($Chapter -eq 2) { 'r3' } else { 'prologue' } }
if (-not $Profile) { $Profile = Join-Path $PSScriptRoot $(if ($Chapter -eq 3) { 'ch3-profile.json' } elseif ($Chapter -eq 2) { 'ch2-profile.json' } else { 'ch1v2-profile.json' }) }
. "$PSScriptRoot/godot-path.ps1"
$root = Join-Path $RepoRoot ('build/qa-menu/' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $root -Force | Out-Null
$Profile = (Resolve-Path -LiteralPath $Profile).Path
$config = Get-Content -Raw -LiteralPath $Profile | ConvertFrom-Json -AsHashtable
if (-not $Smoke -and (-not $config.jumps.ContainsKey($Stage) -or [string]::IsNullOrWhiteSpace($config.jumps[$Stage]))) {
    Write-Host "RESULT: qa-menu SKIP stage=$Stage (T-160 jump binding unavailable)"
    exit 2
}
$import = & $Godot --headless --path $GameDir --import 2>&1
$import | Set-Content (Join-Path $root 'import.log')
if ($LASTEXITCODE -ne 0 -or $import -match 'SCRIPT ERROR:|ERROR:') { $import | Write-Host; exit 1 }
$previousData = $env:APPDATA
$previousRoot = $env:QA_PLAYTHROUGH_ROOT
try {
    $env:APPDATA = Join-Path $root 'userdata'
    New-Item -ItemType Directory -Path $env:APPDATA -Force | Out-Null
    $env:QA_PLAYTHROUGH_ROOT = $env:APPDATA.Replace('\', '/')
    $scene = if ($Smoke -and $Chapter -eq 3) { 'ch3_menu_smoke' } elseif ($Smoke -and $Chapter -eq 2) { 'ch2_menu_smoke' } elseif ($Smoke) { 'qa_menu_smoke' } else { 'qa_preview' }
    $arguments = @('--path', ('"' + $GameDir + '"'), "res://scripts/debug/$scene.tscn", '--windowed', '--resolution', '1280x720', '--max-fps', '60', '--', '--qa-menu', ('"--chapter-profile=' + $Profile.Replace('\', '/') + '"'))
    if ($Chapter -ge 2) { $arguments += "--qa-chapter=$Chapter" }; if (-not $Smoke) { $arguments += "--qa-stage=$Stage" }
    $process = Start-Process -FilePath $Godot -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $root 'stdout.log') -RedirectStandardError (Join-Path $root 'stderr.log')
} finally {
    $env:APPDATA = $previousData
    $env:QA_PLAYTHROUGH_ROOT = $previousRoot
}
Write-Host "QA_MENU_ARTIFACTS: $root"
if (-not $Smoke) { Write-Host "QA_MENU_PID: $($process.Id)"; exit 0 }
if (-not $process.WaitForExit(120000)) { $process.Kill($true); Write-Host 'RESULT: qa-menu FAIL timeout'; exit 1 }
$process.WaitForExit()
$process.Refresh()
$output = @(Get-Content (Join-Path $root 'stdout.log'), (Join-Path $root 'stderr.log'))
$output | Write-Host
if ($process.ExitCode -ne 0 -or $output -match '\bERROR\b' -or -not ($output -match '^RESULT: qa-menu (PASS|SKIP)')) { Write-Host 'RESULT: qa-menu FAIL launcher'; exit 1 }

if ($output -match '^RESULT: qa-menu SKIP') { exit 2 }
