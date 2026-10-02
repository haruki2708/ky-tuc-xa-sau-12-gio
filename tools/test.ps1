# Runs all headless tests. Usage: pwsh tools/test.ps1 [-Filter player]
param([string]$Filter = "")
. "$PSScriptRoot\godot-path.ps1"

# Import pass so new assets/scripts (class_name) are registered before running.
& $Godot --headless --path $GameDir --import 2>&1 | Out-Null

$userArgs = @()
if ($Filter) { $userArgs = @("--", "--filter=$Filter") }
# Isolate user:// fixtures across lanes and simultaneous test runs on Windows.
# APPDATA is inherited only by this child process; restore it after the run.
$testDataRoot = Join-Path $RepoRoot ('build/test-userdata/' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testDataRoot -Force | Out-Null
$previousAppData = $env:APPDATA
$previousQaRoot = $env:QA_EXPECTED_USER_ROOT
try {
    $env:APPDATA = $testDataRoot
    $env:QA_EXPECTED_USER_ROOT = $testDataRoot.Replace('\', '/')
    $output = & $Godot --headless --path $GameDir res://tests/run_tests.tscn @userArgs 2>&1
    $code = $LASTEXITCODE
    $output | Write-Host
    if ($output -match 'SCRIPT ERROR:|ERROR:' -or -not ($output -match '^RESULT: [0-9]+ passed, 0 failed$')) {
        Write-Host 'RESULT: test FAIL (engine error or missing successful runner result)'
        $code = 1
    }
} finally {
    $env:APPDATA = $previousAppData
    $env:QA_EXPECTED_USER_ROOT = $previousQaRoot
    $resolved = (Resolve-Path -LiteralPath $testDataRoot).Path
    $expectedParent = [IO.Path]::GetFullPath((Join-Path $RepoRoot 'build/test-userdata'))
    if ((Split-Path -Parent $resolved) -ne $expectedParent -or (Split-Path -Leaf $resolved) -notmatch '^[0-9a-f]{32}$') { throw 'Unsafe test data cleanup path.' }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
exit $code
