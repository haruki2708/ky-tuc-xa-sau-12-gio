param()
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/godot-path.ps1"
& pwsh -NoProfile -File "$PSScriptRoot/export.ps1"
if ($LASTEXITCODE -ne 0) { throw 'Release export failed.' }
$project = Get-Content -LiteralPath (Join-Path $GameDir 'project.godot') -Raw
if ($project -notmatch '(?m)^config/version="([^"]+)"') { throw 'Missing config/version.' }
$version = $Matches[1]
if ($version -notmatch '^[a-zA-Z0-9._-]+$') { throw 'Version is not safe for a filename.' }
$hash = & git -C $RepoRoot rev-parse --short HEAD
if ($LASTEXITCODE -ne 0) { throw 'Cannot read Git revision.' }
$dist = Join-Path $RepoRoot 'build/dist'
$stage = Join-Path $dist ('stage-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stage -Force | Out-Null
# The current export preset embeds the PCK. Copy only release runtime files.
Copy-Item -LiteralPath (Join-Path $RepoRoot 'build/windows/KyTucXa.exe') -Destination $stage
@'
KÝ TÚC XÁ SAU 12 GIỜ / THE DORM AFTER MIDNIGHT

VI: Giải nén toàn bộ ZIP, chạy KyTucXa.exe trên Windows 64-bit.
Phím đã đăng ký: WASD di chuyển; Shift chạy; E/chuột trái tương tác;
Tab sổ tay; Esc tạm dừng; chuột nhìn quanh khi có bộ điều khiển người chơi.
Bản P0 chỉ có hành lang và camera đứng yên; các chức năng chơi chưa hoàn thiện.

EN: Extract the entire ZIP and run KyTucXa.exe on 64-bit Windows.
Registered controls: WASD move; Shift sprint; E/left mouse interact;
Tab notebook; Esc pause; mouse look when a player controller is available.
The P0 build contains a corridor and a fixed camera; gameplay is incomplete.
'@ | Set-Content -LiteralPath (Join-Path $stage 'README.txt') -Encoding utf8
$zip = Join-Path $dist "KyTucXa-$version-$hash-win64.zip"
Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip -Force
Write-Host 'RESULT: package PASS'
Write-Output $zip
