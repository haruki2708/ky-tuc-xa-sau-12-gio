param(
    [ValidateSet('import', 'capture', 'test', 'full')][string]$Stage = 'import',
    [string]$Filter = 'test_t252_floor4_rooms',
    [ValidateSet('before', 'after')][string]$State = 'before'
)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../../..')).Path
Set-Location -LiteralPath $repo
$lockPath = 'D:\GAME_WORK\GODOT_DANG_CHAY.txt'
$stream = $null
$waitStarted = Get-Date
while ($null -eq $stream) {
    try {
        $stream = [IO.File]::Open($lockPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::Read)
    } catch [IO.IOException] {
        if (-not (Test-Path -LiteralPath $lockPath)) { throw }
        $lockAge = (Get-Date) - (Get-Item -LiteralPath $lockPath).LastWriteTime
        if ($lockAge.TotalMinutes -ge 10 -or ((Get-Date) - $waitStarted).TotalMinutes -ge 10) {
            Write-Output 'RESULT: T-252 blocked: Godot lock wait exceeded 10 minutes; leave owner lock untouched'
            exit 75
        }
        Write-Output ('WAIT Godot: ' + (Get-Content -LiteralPath $lockPath -Raw))
        Start-Sleep -Seconds 30
    }
}
$token = "lane C, T-252, $(Get-Date -Format o)"
$writer = [IO.StreamWriter]::new($stream)
$writer.WriteLine($token)
$writer.Dispose()
$result = 1
try {
    New-Item -ItemType Directory -Force -Path build/t252 | Out-Null
    $godot = 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe'
    if ($Stage -eq 'import') {
        & $godot --headless --path game --import *> build/t252/import.log
    } elseif ($Stage -eq 'capture') {
        New-Item -ItemType Directory -Force -Path game/_probe_tmp | Out-Null
        Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'capture.gd') -Destination game/_probe_tmp/t252_capture.gd
        @'
[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://_probe_tmp/t252_capture.gd" id="1"]
[node name="T252Capture" type="Node3D"]
script = ExtResource("1")
'@ | Set-Content -LiteralPath game/_probe_tmp/t252_capture.tscn
        foreach ($chapter in @(1, 3)) {
            & $godot --path game --resolution 1920x1080 res://_probe_tmp/t252_capture.tscn -- "--chapter=$chapter" "--state=$State" *> "build/t252/capture_${State}_${chapter}.log"
            if ($LASTEXITCODE -ne 0) { throw "Capture chapter $chapter failed" }
            $captureLog = Get-Content -LiteralPath "build/t252/capture_${State}_${chapter}.log" -Raw
            if ($captureLog -match 'SCRIPT ERROR:|ERROR:' -or $captureLog -notmatch 'RESULT: T-252 chapter .* PASS') {
                throw "Capture chapter $chapter has engine errors or no successful RESULT"
            }
        }
    } elseif ($Stage -eq 'test') {
        & pwsh tools/test.ps1 -Filter $Filter *> "build/t252/$Filter.log"
    } else {
        & pwsh tools/test.ps1 *> build/t252/full_test.log
        if ($LASTEXITCODE -ne 0) { throw 'Full test failed; see build/t252/full_test.log' }
        & pwsh tools/check.ps1 *> build/t252/check.log
    }
    $result = $LASTEXITCODE
    Write-Output "RESULT: T-252 $Stage exit=$result (logs: build/t252)"
} finally {
    if ($Stage -eq 'capture') {
        foreach ($file in @('t252_capture.gd', 't252_capture.gd.uid', 't252_capture.tscn')) {
            $temporary = Join-Path $repo "game/_probe_tmp/$file"
            if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary }
        }
        if ((Test-Path -LiteralPath game/_probe_tmp) -and -not (Get-ChildItem -LiteralPath game/_probe_tmp -Force)) {
            Remove-Item -LiteralPath game/_probe_tmp
        }
    }
    if ((Get-Content -LiteralPath $lockPath -Raw).Trim() -eq $token) {
        Remove-Item -LiteralPath $lockPath
    }
}
exit $result
