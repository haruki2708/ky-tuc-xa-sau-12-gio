# Runs all headless tests. Usage: pwsh tools/test.ps1 [-Filter player]
param([string]$Filter = "")
. "$PSScriptRoot\godot-path.ps1"

# Import pass so new assets/scripts (class_name) are registered before running.
& $Godot --headless --path $GameDir --import 2>&1 | Out-Null

$userArgs = @()
if ($Filter) { $userArgs = @("--", "--filter=$Filter") }
& $Godot --headless --path $GameDir res://tests/run_tests.tscn @userArgs
exit $LASTEXITCODE
