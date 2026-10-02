param(
    [string]$Scene = 'res://scenes/main/main.tscn',
    [ValidateRange(1, 1000000)][int]$Frames = 60,
    [ValidateRange(1, 240)][int]$Fps = 30,
    [ValidatePattern('^[1-9][0-9]*x[1-9][0-9]*$')][string]$Resolution = '1280x720',
    [string]$Out = 'build/captures/main',
    [string]$Autoplay = '',
    [ValidateRange(1, 1000000)][int]$KeepEvery = 10,
    [switch]$KeepSnapshot
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/godot-path.ps1"
$outputRoot = [IO.Path]::GetFullPath((Join-Path $RepoRoot $Out))
if ($outputRoot.Equals($GameDir, [StringComparison]::OrdinalIgnoreCase) -or $outputRoot.StartsWith($GameDir + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Capture output must be outside game/ to avoid recursive snapshots.' }
# Each run owns an isolated directory: never delete a previous capture.
$runDir = Join-Path $outputRoot ([guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $runDir -Force | Out-Null
$movie = Join-Path $runDir 'frame.png'
$userArgs = @()
if ($Autoplay) {
    if (-not $Autoplay.StartsWith('res://')) { $Autoplay = [IO.Path]::GetFullPath((Join-Path $RepoRoot $Autoplay)) }
    $userArgs = @('--', "--autoplay=$Autoplay")
}
& $Godot --headless --path $GameDir --import
if ($LASTEXITCODE -ne 0) { throw 'Import failed.' }
# Movie Maker uses the project viewport, not --resolution. Use an isolated
# snapshot with a viewport override; never modify the source project settings.
$captureGame = Join-Path $runDir 'project'
try {
    Copy-Item -LiteralPath $GameDir -Destination $captureGame -Recurse
    $dimensions = $Resolution.Split('x')
    @"

[display]
window/size/viewport_width=$($dimensions[0])
window/size/viewport_height=$($dimensions[1])
"@ | Add-Content -LiteralPath (Join-Path $captureGame 'override.cfg')
    $log = & $Godot --path $captureGame $Scene --windowed --write-movie $movie --fixed-fps $Fps --quit-after $Frames --resolution $Resolution @userArgs 2>&1
    $code = $LASTEXITCODE
    $log | Write-Host
    if ($code -ne 0 -or ($log -match 'SCRIPT ERROR:|ERROR:')) { throw 'Capture failed; inspect Godot output.' }
    if ($Autoplay -and -not ($log -match 'AUTOPLAY: loaded')) { throw 'Autoplay was not loaded. Add the Autoplay autoload or use the test scene; see tools/README.md.' }
    $images = @(Get-ChildItem -LiteralPath $runDir -Filter 'frame*.png' -File | Sort-Object Name)
    if ($images.Count -eq 0) { throw 'Godot did not produce PNG frames.' }
    for ($i = 0; $i -lt $images.Count - 1; $i++) {
        if (($i + 1) % $KeepEvery -ne 0) {
            $target = [IO.Path]::GetFullPath($images[$i].FullName)
            if (-not $target.StartsWith($runDir + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe capture cleanup path.' }
            Remove-Item -LiteralPath $target
        }
    }
    Write-Host "RESULT: capture PASS ($($images.Count) frames rendered)"
    Write-Output $images[-1].FullName

} finally {
    if (-not $KeepSnapshot -and (Test-Path -LiteralPath $captureGame)) {
        $resolvedRun = (Resolve-Path -LiteralPath $runDir).Path
        $resolvedSnapshot = (Resolve-Path -LiteralPath $captureGame).Path
        if ($resolvedSnapshot -ne (Join-Path $resolvedRun 'project') -or $resolvedSnapshot -eq $GameDir) {
            throw 'Unsafe snapshot cleanup path.'
        }
        Remove-Item -LiteralPath $resolvedSnapshot -Recurse -Force
    }
}
