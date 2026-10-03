# Extract offline build tools only under D:\Tools; do not run Windows Installer.
$ErrorActionPreference = 'Stop'
$espeakRoot = 'D:\Tools\espeak-ng\1.52.0'
$lessmsiRoot = 'D:\Tools\lessmsi\2.12.9'
$executable = Join-Path $espeakRoot 'portable\SourceDir\eSpeak NG\espeak-ng.exe'
if (Test-Path -LiteralPath $executable) {
    if ((Get-FileHash -LiteralPath $executable).Hash -ne '3080EC3822C1B266EF557C710BC79A97D20A7AB133A34BAC308B81AB0AFC733E') {
        throw 'Existing eSpeak executable differs from the pinned 1.52.0 release.'
    }
    Write-Output "TTS tool already available: $executable"
    exit 0
}
New-Item -ItemType Directory -Path $espeakRoot, $lessmsiRoot -Force | Out-Null
$msi = Join-Path $espeakRoot 'espeak-ng.msi'
$zip = Join-Path $lessmsiRoot 'lessmsi.zip'
Invoke-WebRequest 'https://github.com/espeak-ng/espeak-ng/releases/download/1.52.0/espeak-ng.msi' -OutFile $msi
Invoke-WebRequest 'https://github.com/activescott/lessmsi/releases/download/v2.12.9/lessmsi-v2.12.9.zip' -OutFile $zip
if ((Get-FileHash -LiteralPath $msi).Hash -ne '7F673C709EA5DD579D3B5EBB98688CC575328A6AB7438D2BC405B88CEDAEAFB9') { throw 'eSpeak archive hash mismatch.' }
if ((Get-FileHash -LiteralPath $zip).Hash -ne '5B4E187E74B184AD3A63CCF06C3D17DAE2B8C4B6C298A996DBD51A9F6DB29D21') { throw 'lessmsi archive hash mismatch.' }
Expand-Archive -LiteralPath $zip -DestinationPath $lessmsiRoot -Force
& (Join-Path $lessmsiRoot 'lessmsi.exe') x $msi (Join-Path $espeakRoot 'portable\')
if ($LASTEXITCODE -ne 0) { throw 'Archive extraction failed.' }
Write-Output "TTS tool extracted: $executable"
