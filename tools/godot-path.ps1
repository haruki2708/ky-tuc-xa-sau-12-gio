# Resolves the pinned Godot console executable. Dot-source this file.
# Override with $env:GODOT if Godot lives elsewhere.
$GodotVersion = "4.7.2-stable"
$Godot = if ($env:GODOT) { $env:GODOT } else { "D:\Tools\Godot\Godot_v$GodotVersion`_win64_console.exe" }
if (-not (Test-Path $Godot)) {
    Write-Error "Godot not found at '$Godot'. Install Godot $GodotVersion or set `$env:GODOT."
    exit 2
}
$RepoRoot = Split-Path -Parent $PSScriptRoot
$GameDir = Join-Path $RepoRoot "game"
