param([string]$Blender = "D:\Tools\Blender\5.2.2\blender.exe")
$ErrorActionPreference = "Stop"
if (-not (Test-Path -LiteralPath $Blender)) {
    throw "Blender missing: $Blender. Run art_source/kit/install_blender.ps1 first."
}
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$scratch = Join-Path $repoRoot "art_source/kit/.scratch.tmp"
New-Item -ItemType Directory -Path $scratch -Force | Out-Null
$oldTemp = $env:TEMP
$oldTmp = $env:TMP
$oldResources = $env:BLENDER_USER_RESOURCES
try {
    $env:TEMP = $scratch
    $env:TMP = $scratch
    $env:BLENDER_USER_RESOURCES = $scratch
    & $Blender --background --factory-startup --python-exit-code 1 --python "$PSScriptRoot/build_kit.py"
    if ($LASTEXITCODE -ne 0) { throw "Blender build failed with exit code $LASTEXITCODE." }
} finally {
    $env:TEMP = $oldTemp
    $env:TMP = $oldTmp
    $env:BLENDER_USER_RESOURCES = $oldResources
}
