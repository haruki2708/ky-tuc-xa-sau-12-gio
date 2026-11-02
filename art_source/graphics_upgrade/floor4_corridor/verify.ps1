$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '../../..')).Path
foreach ($stage in @('smoke', 'test', 'check')) {
    & pwsh art_source/graphics_upgrade/floor4_corridor/run_stage.ps1 -Stage $stage
    $code = $LASTEXITCODE
    Write-Output "T229_STAGE_EXIT $stage=$code"
    if ($code -ne 0) { exit $code }
}
Write-Output 'RESULT: T229 verification PASS'
