# Run five consecutive main-scene captures and report reproducibility.
param()
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$batch = 'build/captures/T-124-' + [guid]::NewGuid().ToString('N')
$failed = $false
for ($run = 1; $run -le 5; $run++) {
    $out = "$batch/run-$run"
    $lines = & pwsh -NoProfile -File "$PSScriptRoot/capture.ps1" -Scene res://scenes/main/main.tscn -Autoplay res://tests/tools/autoplay_main.json -Frames 200 -KeepEvery 1 -Out $out 2>&1
    $code = $LASTEXITCODE
    $log = Join-Path $repo "$batch/run-$run.log"
    $lines | Set-Content -LiteralPath $log
    $directory = Get-ChildItem -LiteralPath (Join-Path $repo $out) -Directory | Select-Object -First 1
    $count = @(Get-ChildItem -LiteralPath $directory.FullName -Filter 'frame*.png').Count
    $snapshot = Test-Path -LiteralPath (Join-Path $directory.FullName 'project')
    Write-Host "Run ${run}: $count PNG; snapshot=$snapshot; exit=$code; log=$log"
    if ($count -ne 136 -or $snapshot -or $code -ne 0) { $failed = $true }
}
if ($failed) { Write-Host 'RESULT: autoplay capture FAIL (inspect run logs)'; exit 1 }
Write-Host 'RESULT: autoplay capture 5/5 PASS (136 frames each, no snapshots)'
