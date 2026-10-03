param(
    [ValidateSet('correct', 'deviant', 'all')][string]$Scenario = 'all',
    [switch]$Capture,
    [ValidateRange(0.005, 1.0)][double]$TimeScale = 0.05,
    [ValidateRange(5, 120)][int]$SegmentTimeout = 45
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/godot-path.ps1"
$runRoot = Join-Path $RepoRoot ('build/playthrough/' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $runRoot -Force | Out-Null
$importLog = & $Godot --headless --path $GameDir --import 2>&1
$importLog | Set-Content -LiteralPath (Join-Path $runRoot 'import.log')
if ($LASTEXITCODE -ne 0 -or $importLog -match 'SCRIPT ERROR:|ERROR:') {
    $importLog | Write-Host
    Write-Host 'PLAYTHROUGH_RESULT: FAIL import'
    exit 1
}
$scenarios = if ($Scenario -eq 'all') { @('correct', 'deviant') } else { @($Scenario) }
$failures = 0
foreach ($case in $scenarios) {
    $caseDir = Join-Path $runRoot $case
    $dataDir = Join-Path $caseDir 'userdata'
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
    $previousAppData = $env:APPDATA
    $process = $null
    try {
        $env:APPDATA = $dataDir
        $arguments = @('--path', ('"' + $GameDir + '"'), 'res://scripts/debug/playthrough_bot.tscn', '--max-fps', '60')
        $arguments += if ($Capture) { @('--windowed', '--resolution', '1280x720') } else { @('--headless') }
        $scale = $TimeScale.ToString([Globalization.CultureInfo]::InvariantCulture)
        $arguments += @('--', "--scenario=$case", "--story-scale=$scale", "--segment-timeout=$SegmentTimeout")
        if ($Capture) {
            $images = Join-Path $caseDir 'captures'
            New-Item -ItemType Directory -Path $images -Force | Out-Null
            $arguments += '"--capture-dir=' + $images.Replace('\', '/') + '"'
        }
        $watch = [Diagnostics.Stopwatch]::StartNew()
        $process = Start-Process -FilePath $Godot -ArgumentList $arguments -WorkingDirectory $RepoRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $caseDir 'stdout.log') -RedirectStandardError (Join-Path $caseDir 'stderr.log')
        $timeout = $false
        while (-not $process.WaitForExit(1000)) {
            if ($watch.Elapsed.TotalSeconds -gt (6 * $SegmentTimeout + 15)) {
                $process.Kill()
                $timeout = $true
                break
            }
        }
        $process.WaitForExit()
        $process.Refresh()
        $watch.Stop()
        $output = @(Get-Content -LiteralPath (Join-Path $caseDir 'stdout.log'), (Join-Path $caseDir 'stderr.log'))
        $output | Write-Host
        if ($timeout -or $process.ExitCode -ne 0 -or ($output -match '\bERROR\b') -or -not ($output -match "^PLAYTHROUGH_RESULT: PASS scenario=$case ")) {
            $failures++
            Write-Host "PLAYTHROUGH_RESULT: FAIL scenario=$case launcher exit=$($process.ExitCode) timeout=$timeout; inspect $caseDir"
        }
        Write-Host ('PLAYTHROUGH_TIME: {0} {1:F2}s; logs={2}' -f $case, $watch.Elapsed.TotalSeconds, $caseDir)
    } catch {
        $failures++
        Write-Host "PLAYTHROUGH_RESULT: FAIL scenario=$case $($_.Exception.Message)"
    } finally {
        if ($null -ne $process -and -not $process.HasExited) { $process.Kill(); $process.WaitForExit() }
        $env:APPDATA = $previousAppData
        $resolved = (Resolve-Path -LiteralPath $dataDir).Path
        if ($resolved -ne [IO.Path]::GetFullPath((Join-Path $caseDir 'userdata')) -or -not $resolved.StartsWith([IO.Path]::GetFullPath($runRoot) + [IO.Path]::DirectorySeparatorChar)) { throw 'Unsafe playthrough cleanup path.' }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
Write-Host "RESULT: playthrough $($scenarios.Count - $failures) passed, $failures failed"
exit ([int]($failures -gt 0))
