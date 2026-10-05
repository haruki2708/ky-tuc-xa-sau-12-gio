param(
    [ValidateSet('correct', 'deviant', 'mirror', 'ch1_good', 'ch1_stay_in_bed', 'ch1_leave_room', 'ch1_own_bed', 'ch1v2_good', 'ch1v2_wrong_switch', 'ch1v2_door_late', 'ch1v2_lamp_on', 'ch1v2_wrong_advice', 'ch2_good', 'ch2_chain_timeout', 'ch2_chain_wrong', 'ch2_scald', 'ch2_leave_shower', 'ch2_wrong_prediction', 'ch3_good', 'ch3_grabbed', 'ch3_guard', 'all')][string]$Scenario = 'all',
    [ValidateSet(0, 1, 2, 3)][int]$Chapter = 0,
    [string]$ChapterProfile,
    [switch]$RequireComplete,
    [switch]$Performance,
    [switch]$V2,
    [ValidateRange(20, 10000)][int]$PerfFrames = 240,
    [ValidateRange(1, 10000)][int]$WarmupFrames = 90,
    [switch]$Capture,
    [ValidateRange(0.005, 1.0)][double]$TimeScale = 0.05,
    [ValidateRange(5, 3600)][int]$SegmentTimeout = 45
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/godot-path.ps1"
if ($Chapter -eq 1 -and -not $PSBoundParameters.ContainsKey('SegmentTimeout')) { $SegmentTimeout = 120 }
$allowed = if ($Chapter -eq 1) { @('ch1_good', 'ch1_stay_in_bed', 'ch1_leave_room', 'ch1_own_bed') } else { @('correct', 'deviant', 'mirror') }
if ($V2) {
    if ($Chapter -ge 2) { throw '-V2 selects chapter 1; use -Chapter 2 alone.' }
    $Chapter = 1
    $allowed = @('ch1v2_good', 'ch1v2_wrong_switch', 'ch1v2_door_late', 'ch1v2_lamp_on', 'ch1v2_wrong_advice')
    if (-not $ChapterProfile) { $ChapterProfile = Join-Path $PSScriptRoot 'ch1v2-profile.json' }
    if (-not $PSBoundParameters.ContainsKey('TimeScale')) { $TimeScale = 1.0 }
    if (-not $PSBoundParameters.ContainsKey('SegmentTimeout')) { $SegmentTimeout = 1800 }
}
if ($Chapter -eq 2) {
    $allowed = @('ch2_good', 'ch2_chain_timeout', 'ch2_chain_wrong', 'ch2_scald', 'ch2_leave_shower', 'ch2_wrong_prediction')
    if (-not $ChapterProfile) { $ChapterProfile = Join-Path $PSScriptRoot 'ch2-profile.json' }
    if (-not $PSBoundParameters.ContainsKey('TimeScale')) { $TimeScale = 1.0 }
    if (-not $PSBoundParameters.ContainsKey('SegmentTimeout')) { $SegmentTimeout = 120 }
}
if ($Chapter -eq 3) {
    $allowed = @('ch3_good', 'ch3_grabbed', 'ch3_guard')
    if (-not $ChapterProfile) { $ChapterProfile = Join-Path $PSScriptRoot 'ch3-profile.json' }
    if (-not $PSBoundParameters.ContainsKey('TimeScale')) { $TimeScale = 1.0 }
    if (-not $PSBoundParameters.ContainsKey('SegmentTimeout')) { $SegmentTimeout = 300 }
}
if (-not $Performance -and $Scenario -ne 'all' -and $Scenario -notin $allowed) { throw 'Scenario does not belong to selected Chapter (0 = legacy demo, 1 = chapter 1, 2 = chapter 2, 3 = chapter 3).' }
if ($ChapterProfile) { $ChapterProfile = (Resolve-Path -LiteralPath $ChapterProfile).Path }
$runRoot = Join-Path $RepoRoot ('build/playthrough/' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $runRoot -Force | Out-Null
$importLog = & $Godot --headless --path $GameDir --import 2>&1
$importLog | Set-Content -LiteralPath (Join-Path $runRoot 'import.log')
if ($LASTEXITCODE -ne 0 -or $importLog -match 'SCRIPT ERROR:|ERROR:') {
    $importLog | Write-Host
    Write-Host 'PLAYTHROUGH_RESULT: FAIL import'
    exit 1
}
$scenarios = if ($Performance) { @('performance') } elseif ($Scenario -eq 'all') { $allowed } else { @($Scenario) }
$skipped = 0
$failures = 0
foreach ($case in $scenarios) {
    $caseDir = Join-Path $runRoot $case
    $dataDir = Join-Path $caseDir 'userdata'
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
    $previousAppData = $env:APPDATA
    $previousQaRoot = $env:QA_PLAYTHROUGH_ROOT
    $process = $null
    try {
        $env:APPDATA = $dataDir
        $env:QA_PLAYTHROUGH_ROOT = $dataDir.Replace('\', '/')
        $scene = if ($Chapter -eq 3) { if ($Performance) { 'ch3_performance' } else { 'ch3_bot' } } elseif ($Chapter -eq 2) { if ($Performance) { 'ch2_performance' } else { 'ch2_bot' } } elseif ($Performance) { 'performance_bot' } elseif ($V2) { 'ch1v2_bot' } elseif ($Chapter -eq 1) { 'chapter_bot' } else { 'playthrough_bot' }
        $arguments = @('--path', ('"' + $GameDir + '"'), "res://scripts/debug/$scene.tscn", '--max-fps', $(if ($Performance) { '0' } else { '60' }))
        $arguments += if ($Capture -or $Performance) { @('--windowed', '--resolution', '1280x720') } else { @('--headless') }
        $scale = $TimeScale.ToString([Globalization.CultureInfo]::InvariantCulture)
        $arguments += @('--', "--scenario=$case", "--story-scale=$scale", "--segment-timeout=$SegmentTimeout")
        $arguments += '"--report=' + (Join-Path $caseDir 'report.json').Replace('\', '/') + '"'
        if ($ChapterProfile) { $arguments += '"--chapter-profile=' + $ChapterProfile.Replace('\', '/') + '"' }
        if ($Performance) { $arguments += @("--perf-frames=$PerfFrames", "--warmup-frames=$WarmupFrames") }
        if ($V2) { $arguments += '--ch1v2' }
        if ($Capture) {
            $images = Join-Path $caseDir 'captures'
            New-Item -ItemType Directory -Path $images -Force | Out-Null
            $arguments += '"--capture-dir=' + $images.Replace('\', '/') + '"'
        }
        $watch = [Diagnostics.Stopwatch]::StartNew()
        $process = Start-Process -FilePath $Godot -ArgumentList $arguments -WorkingDirectory $RepoRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $caseDir 'stdout.log') -RedirectStandardError (Join-Path $caseDir 'stderr.log')
        $timeout = $false
        $reportedPerfAlerts = @{}
        while (-not $process.WaitForExit(1000)) {
            if ($Chapter -eq 3 -and $Performance) {
                foreach ($alert in @(Select-String -LiteralPath (Join-Path $caseDir 'stdout.log') -Pattern '^CH3_PERF_ALERT:')) {
                    if (-not $reportedPerfAlerts.ContainsKey($alert.Line)) {
                        Write-Host $alert.Line
                        $reportedPerfAlerts[$alert.Line] = $true
                    }
                }
            }
            if (Select-String -LiteralPath (Join-Path $caseDir 'stderr.log') -Pattern '\bERROR\b' -Quiet) {
                $process.Kill($true)
                break
            }
            if ($watch.Elapsed.TotalSeconds -gt $(if ($Chapter -eq 3) { if ($Performance) { 600 } else { 4515 } } elseif ($Chapter -eq 2 -and -not $Performance) { 3615 } elseif ($V2 -and -not $Performance) { 4515 } else { 6 * $SegmentTimeout + 15 })) {
                $process.Kill($true)
                $timeout = $true
                break
            }
        }
        $process.WaitForExit()
        $process.Refresh()
        $watch.Stop()
        $output = @(Get-Content -LiteralPath (Join-Path $caseDir 'stdout.log'), (Join-Path $caseDir 'stderr.log'))
        $output | Write-Host
        $caseSkipped = ($output -match "^PLAYTHROUGH_RESULT: SKIP scenario=$case ")
        if ($timeout -or $process.ExitCode -ne 0 -or ($output -match '\bERROR\b') -or (-not $caseSkipped -and -not ($output -match "^PLAYTHROUGH_RESULT: PASS scenario=$case "))) {
            $failures++
            Write-Host "PLAYTHROUGH_RESULT: FAIL scenario=$case launcher exit=$($process.ExitCode) timeout=$timeout; inspect $caseDir"
        } elseif ($caseSkipped) {
            $skipped++
        }
        Write-Host ('PLAYTHROUGH_TIME: {0} {1:F2}s; logs={2}' -f $case, $watch.Elapsed.TotalSeconds, $caseDir)
    } catch {
        $failures++
        Write-Host "PLAYTHROUGH_RESULT: FAIL scenario=$case $($_.Exception.Message)"
    } finally {
        if ($null -ne $process -and -not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
        $env:APPDATA = $previousAppData
        $env:QA_PLAYTHROUGH_ROOT = $previousQaRoot
        $resolved = (Resolve-Path -LiteralPath $dataDir).Path
        if ($resolved -ne [IO.Path]::GetFullPath((Join-Path $caseDir 'userdata')) -or -not $resolved.StartsWith([IO.Path]::GetFullPath($runRoot) + [IO.Path]::DirectorySeparatorChar)) { throw 'Unsafe playthrough cleanup path.' }
        for ($attempt = 0; $attempt -lt 5; $attempt++) {
            try { Remove-Item -LiteralPath $resolved -Recurse -Force; break }
            catch {
                if ($attempt -eq 4) { Write-Warning "Temporary userdata retained (file still locked): $resolved" }
                else { Start-Sleep -Milliseconds 300 }
            }
        }
    }
}
Write-Host "PLAYTHROUGH_ARTIFACTS: $runRoot"
if ($skipped -gt 0) {
    Write-Host "RESULT: playthrough $($scenarios.Count - $failures - $skipped) passed, $failures failed, $skipped skipped"
} else {
    Write-Host "RESULT: playthrough $($scenarios.Count - $failures) passed, $failures failed"
}
if ($RequireComplete -and $skipped -gt 0 -and $failures -eq 0) { exit 2 }
exit ([int]($failures -gt 0))
