param([string]$Blender = "D:\Tools\Blender\5.2.2\blender.exe")
$ErrorActionPreference = "Stop"
& "$PSScriptRoot/build_kit.ps1" -Blender $Blender
$before = Get-Content -LiteralPath "$PSScriptRoot/build_hashes.json" -Raw | ConvertFrom-Json -AsHashtable
& "$PSScriptRoot/build_kit.ps1" -Blender $Blender
$after = Get-Content -LiteralPath "$PSScriptRoot/build_hashes.json" -Raw | ConvertFrom-Json -AsHashtable
$changed = @($before.Keys | Where-Object { $before[$_] -ne $after[$_] })
if ($changed.Count -gt 0 -or $before.Count -ne 24 -or $after.Count -ne 24) {
    throw "REBUILD_RESULT: FAIL changed files: $($changed -join ', ')"
}
Write-Output "REBUILD_RESULT: PASS 24/24 generated GLB, texture and preview hashes match"
