param([string]$InstallRoot = "D:\Tools\Blender")
$ErrorActionPreference = "Stop"
$version = "5.2.2"
$archiveName = "blender-$version-windows-x64.zip"
$baseUrl = "https://download.blender.org/release/Blender5.2"
$destination = Join-Path $InstallRoot $version
$downloads = Join-Path $InstallRoot "downloads"
$archive = Join-Path $downloads $archiveName
New-Item -ItemType Directory -Force -Path $downloads, $destination | Out-Null
Invoke-WebRequest "$baseUrl/blender-$version.sha256" -OutFile "$archive.sha256"
$hashLine = Get-Content "$archive.sha256" | Where-Object { $_ -match ([regex]::Escape($archiveName) + '$') }
if (-not $hashLine) { throw "Archive missing from official SHA256 manifest." }
$expected = ($hashLine -split '\s+')[0]
if (-not (Test-Path -LiteralPath $archive)) {
    Invoke-WebRequest "$baseUrl/$archiveName" -OutFile $archive
}
if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $expected) {
    throw "Blender archive SHA256 mismatch."
}
if (-not (Test-Path -LiteralPath "$destination\blender.exe")) {
    Expand-Archive -LiteralPath $archive -DestinationPath $downloads -Force
    $resolvedRoot = [IO.Path]::GetFullPath($InstallRoot).TrimEnd('\') + '\'
    $source = (Resolve-Path -LiteralPath "$downloads\blender-$version-windows-x64").Path
    $target = (Resolve-Path -LiteralPath $destination).Path
    if (-not ($source.StartsWith($resolvedRoot, [StringComparison]::OrdinalIgnoreCase) -and
        $target.StartsWith($resolvedRoot, [StringComparison]::OrdinalIgnoreCase))) {
        throw "Extraction paths must stay inside InstallRoot."
    }
    Get-ChildItem -LiteralPath $source -Force | ForEach-Object {
        Move-Item -LiteralPath $_.FullName -Destination $target
    }
}
New-Item -ItemType Directory -Force -Path "$destination\portable" | Out-Null
& "$destination\blender.exe" --background --factory-startup --version
if ($LASTEXITCODE -ne 0) { throw "Blender version check failed." }
Write-Output "Blender ZIP SHA256: $expected"
