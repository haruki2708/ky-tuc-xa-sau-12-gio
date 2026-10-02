param()
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/godot-path.ps1"
$errorsFound = 0
& $Godot --headless --path $GameDir --import
if ($LASTEXITCODE -ne 0) { $errorsFound++ }
foreach ($file in Get-ChildItem $GameDir -Recurse -Filter *.gd -File | Where-Object FullName -NotMatch '[\\/]\.godot[\\/]') {
    $relative = [IO.Path]::GetRelativePath($GameDir, $file.FullName).Replace('\', '/')
    $output = & $Godot --headless --path $GameDir --check-only --script "res://$relative" 2>&1
    # Standalone --script does not register project autoload identifiers.
    # Recheck in a normal scene context; genuine parse errors still fail.
    if ($output -match 'Identifier not found:') {
        $output = & $Godot --headless --path $GameDir res://tests/tools/parse_probe.tscn -- --qa-parse="res://$relative" 2>&1
    }
    if ($LASTEXITCODE -ne 0 -or ($output -match 'SCRIPT ERROR:|ERROR:')) {
        Write-Host "FAIL parse: $relative"
        $output | Write-Host
        $errorsFound++
    } else { Write-Host "PASS parse: $relative" }
}
# Include tracked and untracked source files, excluding ignored build/cache output.
$paths = & git -C $RepoRoot -c core.quotepath=false ls-files --cached --others --exclude-standard
if ($LASTEXITCODE -ne 0) { throw 'Cannot enumerate repository files.' }
foreach ($path in $paths | Sort-Object -Unique) {
    $full = Join-Path $RepoRoot $path
    if ((Test-Path -LiteralPath $full -PathType Leaf) -and (Get-Item -LiteralPath $full).Length -gt 10MB) {
        Write-Host "FAIL size (>10 MB): $path"
        $errorsFound++
    }
}
$rows = @(Import-Csv -LiteralPath (Join-Path $GameDir 'localization/strings.csv'))
if ($rows.Count -eq 0 -or 'vi' -notin $rows[0].PSObject.Properties.Name -or 'en' -notin $rows[0].PSObject.Properties.Name) {
    Write-Host 'FAIL translations: missing vi/en columns or no keys.'
    $errorsFound++
} else {
    foreach ($row in $rows) {
        foreach ($locale in @('vi', 'en')) {
            if ([string]::IsNullOrWhiteSpace($row.$locale)) {
                Write-Host "FAIL translation: $($row.keys) missing $locale"
                $errorsFound++
            }
        }
    }
}
Write-Host "RESULT: check $errorsFound error(s)"
exit ([int]($errorsFound -gt 0))
