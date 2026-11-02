param([ValidateSet('filter', 'smoke', 'capture', 'test', 'check')][string]$Stage)
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
$writer.WriteLine("lane B, T-229 $Stage, $(Get-Date -Format o)")
$writer.Dispose()
$stageCode = 1
try {
    $logPath = Join-Path $PSScriptRoot "previews/$Stage.log"
    if ($Stage -eq 'capture') {
        $godot = 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
        & $godot --path "$repo/game" --rendering-method forward_plus --resolution 1920x1080 res://scenes/levels/floor4/corridor_capture.tscn 2>&1 | Tee-Object -FilePath $logPath
    } elseif ($Stage -eq 'filter') {
        & pwsh tools/test.ps1 -Filter test_floor4 2>&1 | Tee-Object -FilePath $logPath
    } elseif ($Stage -eq 'smoke') {
        & pwsh tools/test.ps1 -Filter test_smoke_scenes 2>&1 | Tee-Object -FilePath $logPath
    } elseif ($Stage -eq 'test') {
        & pwsh tools/test.ps1 2>&1 | Tee-Object -FilePath $logPath
    } else {
        & pwsh tools/check.ps1 2>&1 | Tee-Object -FilePath $logPath
    }
    $stageCode = $LASTEXITCODE
    if ($Stage -eq 'capture') {
        $captureLog = Get-Content -LiteralPath $logPath -Raw
        if ($captureLog -match 'SCRIPT ERROR:|ERROR:' -or $captureLog -notmatch 'RESULT: corridor capture 12 images PASS') {
            Write-Host 'RESULT: capture FAIL (engine error or missing successful result)'
            $stageCode = 1
        }
    }
} finally {
    Remove-Item -LiteralPath $lockPath -Force
}
exit $stageCode
