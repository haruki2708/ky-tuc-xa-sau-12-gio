param([ValidateSet('filter', 'smoke', 'capture', 'g5', 'g5test', 'test', 'check', 'full')][string]$Stage)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
Set-Location -LiteralPath $repo
$lockPath = 'D:\GAME_WORK\GODOT_DANG_CHAY.txt'
# CreateNew prevents two lanes from acquiring the same turn.
$lockStream = $null
$attempt = 0
while ($null -eq $lockStream) {
    try {
        $lockStream = [IO.File]::Open($lockPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::Read)
    } catch [IO.IOException] {
        if (-not (Test-Path -LiteralPath $lockPath)) { throw }
        if ($attempt % 12 -eq 0) {
            Write-Host ('WAIT Godot: ' + (Get-Content -LiteralPath $lockPath -Raw))
        }
        $attempt++
        Start-Sleep -Seconds 5
    }
}
$writer = [IO.StreamWriter]::new($lockStream)
$writer.WriteLine("lane B, floor4 corridor $Stage, $(Get-Date -Format o)")
$writer.Dispose()
$stageCode = 1
try {
    # Logs stay out of Git (T-229 review): build/ is ignored.
    $logDir = Join-Path $repo 'build/floor4_corridor'
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    $logPath = Join-Path $logDir "$Stage.log"
    $godot = 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
    if ($Stage -eq 'capture') {
        & $godot --path "$repo/game" --rendering-method forward_plus --resolution 1920x1080 res://scenes/levels/floor4/corridor_capture.tscn 2>&1 | Tee-Object -FilePath $logPath
    } elseif ($Stage -eq 'g5') {
        # Reimport first so freshly painted masks and rebuilt GLBs are the ones captured.
        & $godot --headless --path "$repo/game" --import 2>&1 | Out-File -FilePath (Join-Path $logDir 'g5_import.log')
        & $godot --path "$repo/game" --rendering-method forward_plus --resolution 1920x1080 res://scenes/levels/floor4/corridor_capture.tscn -- --g5 2>&1 | Tee-Object -FilePath $logPath
    } elseif ($Stage -eq 'g5test') {
        & pwsh tools/test.ps1 -Filter test_corridor_g5 2>&1 | Tee-Object -FilePath $logPath
    } elseif ($Stage -eq 'filter') {
        & pwsh tools/test.ps1 -Filter test_floor4 2>&1 | Tee-Object -FilePath $logPath
    } elseif ($Stage -eq 'smoke') {
        & pwsh tools/test.ps1 -Filter test_smoke_scenes 2>&1 | Tee-Object -FilePath $logPath
    } elseif ($Stage -eq 'test') {
        & pwsh tools/test.ps1 2>&1 | Tee-Object -FilePath $logPath
    } elseif ($Stage -eq 'full') {
        # Pre-commit gate in one Godot turn: full test, then check only if the test passed.
        & pwsh tools/test.ps1 2>&1 | Tee-Object -FilePath (Join-Path $logDir 'test.log')
        if ($LASTEXITCODE -eq 0) {
            & pwsh tools/check.ps1 2>&1 | Tee-Object -FilePath (Join-Path $logDir 'check.log')
        }
    } else {
        & pwsh tools/check.ps1 2>&1 | Tee-Object -FilePath $logPath
    }
    $stageCode = $LASTEXITCODE
    if ($Stage -in @('capture', 'g5')) {
        $captureLog = Get-Content -LiteralPath $logPath -Raw
        $expected = if ($Stage -eq 'g5') { 'RESULT: corridor g5 capture \d+ images PASS' } else { 'RESULT: corridor capture 12 images PASS' }
        if ($captureLog -match 'SCRIPT ERROR:|ERROR:' -or $captureLog -notmatch $expected) {
            Write-Host 'RESULT: capture FAIL (engine error or missing successful result)'
            $stageCode = 1
        }
    }
} finally {
    Remove-Item -LiteralPath $lockPath -Force
}
exit $stageCode
