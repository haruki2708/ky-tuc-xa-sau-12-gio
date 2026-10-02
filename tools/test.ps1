# Runs all headless tests. Usage: pwsh tools/test.ps1 [-Filter player]
param([string]$Filter = "")
. "$PSScriptRoot\godot-path.ps1"

# Import pass so new assets/scripts (class_name) are registered before running.
& $Godot --headless --path $GameDir --import 2>&1 | Out-Null

$userArgs = @()
if ($Filter) { $userArgs = @("--", "--filter=$Filter") }
$output = & $Godot --headless --path $GameDir res://tests/run_tests.tscn @userArgs 2>&1
$code = $LASTEXITCODE
$output | Write-Host
if ($output -match 'SCRIPT ERROR:|ERROR:' -or -not ($output -match '^RESULT: [0-9]+ passed, 0 failed$')) {
    Write-Host 'RESULT: test FAIL (engine error or missing successful runner result)'
    exit 1
}
exit $code
