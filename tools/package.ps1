param()
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/godot-path.ps1"
$dist = Join-Path $RepoRoot 'build/dist'
$work = Join-Path $dist ('verify-' + [guid]::NewGuid().ToString('N'))
$failed = $false
try {
    $exportLog = & pwsh -NoProfile -File "$PSScriptRoot/export.ps1" 2>&1
    $exportCode = $LASTEXITCODE
    $exportLog | Write-Host
    if ($exportCode -ne 0 -or ($exportLog -match '\bERROR\b')) { throw 'Release export failed.' }
    $project = Get-Content -LiteralPath (Join-Path $GameDir 'project.godot') -Raw
    if ($project -notmatch '(?m)^config/version="([^"]+)"') { throw 'Missing config/version.' }
    $version = $Matches[1]
    if ($version -notmatch '^[a-zA-Z0-9._-]+$') { throw 'Version is not safe for a filename.' }
    $hash = & git -C $RepoRoot rev-parse --short HEAD
    if ($LASTEXITCODE -ne 0) { throw 'Cannot read Git revision.' }
    $stage = Join-Path $work 'stage'
    $unpacked = Join-Path $work 'unpacked'
    New-Item -ItemType Directory -Path $stage -Force | Out-Null
    # The Windows preset embeds its PCK in the executable.
    Copy-Item -LiteralPath (Join-Path $RepoRoot 'build/windows/KyTucXa.exe') -Destination $stage
    Copy-Item -LiteralPath "$PSScriptRoot/package_readme.txt" -Destination (Join-Path $stage 'README.txt')
    $zip = Join-Path $dist "KyTucXa-$version-$hash-win64.zip"
    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip -Force
    Write-Host ('ZIP: {0} bytes ({1:F2} MiB)' -f (Get-Item $zip).Length, ((Get-Item $zip).Length / 1MB))
    Expand-Archive -LiteralPath $zip -DestinationPath $unpacked
    # Keep logs outside the temporary extraction directory, including on failure.
    $logPath = "$zip.verify.log"
    $stdout = "$zip.stdout.log"
    $stderr = "$zip.stderr.log"
    $process = Start-Process -FilePath (Join-Path $unpacked 'KyTucXa.exe') -WorkingDirectory $unpacked -ArgumentList @('--windowed', '--log-file', ('"' + $logPath + '"'), '--', '--quit-after-frames=60') -WindowStyle Hidden -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    if (-not $process.WaitForExit(60000)) {
        $process.Kill()
        $process.WaitForExit()
        throw 'Extracted release timed out after 60 seconds.'
    }
    $process.WaitForExit()
    $process.Refresh()
    if ($process.ExitCode -ne 0) { throw "Extracted release exited with $($process.ExitCode)." }
    if (-not (Test-Path -LiteralPath $logPath)) { throw 'Extracted release did not create a Godot log.' }
    $logs = Get-Content -LiteralPath $logPath, $stdout, $stderr
    $logs | Write-Host
    if ($logs -match '\bERROR\b') { throw 'Extracted release logged ERROR.' }
    Write-Host 'Verified extracted release: 60-frame run, exit 0, no ERROR.'
} catch {
    $failed = $true
    Write-Host "Package error: $($_.Exception.Message)"
} finally {
    if (Test-Path -LiteralPath $work) {
        $resolvedDist = (Resolve-Path -LiteralPath $dist).Path
        $resolvedWork = (Resolve-Path -LiteralPath $work).Path
        if ((Split-Path -Parent $resolvedWork) -ne $resolvedDist -or (Split-Path -Leaf $resolvedWork) -notmatch '^verify-[0-9a-f]{32}$') {
            throw 'Unsafe package cleanup path.'
        }
        Remove-Item -LiteralPath $resolvedWork -Recurse -Force
    }
}
if ($failed) { Write-Host 'RESULT: package FAIL'; exit 1 }
Write-Host 'RESULT: package PASS'
Write-Output $zip
