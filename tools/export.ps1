# Exports a Windows build to build/windows/. Usage: pwsh tools/export.ps1 [-Debug]
param([switch]$Debug)
. "$PSScriptRoot\godot-path.ps1"

$outDir = Join-Path $RepoRoot "build\windows"
New-Item -ItemType Directory -Force $outDir | Out-Null
$mode = if ($Debug) { "--export-debug" } else { "--export-release" }

& $Godot --headless --path $GameDir --import 2>&1 | Out-Null
& $Godot --headless --path $GameDir $mode "Windows Desktop" (Join-Path $outDir "KyTucXa.exe")
if ($LASTEXITCODE -ne 0) { Write-Error "Export failed"; exit $LASTEXITCODE }
Write-Host "Exported to $outDir"
