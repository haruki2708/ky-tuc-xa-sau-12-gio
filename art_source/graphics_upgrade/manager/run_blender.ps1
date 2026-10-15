param([Parameter(Mandatory)][string]$Script, [string[]]$ScriptArgs = @())
$ErrorActionPreference = 'Stop'
$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
$tempRoot = Join-Path $repo 'build/t219/tmp'
New-Item -ItemType Directory -Force $tempRoot | Out-Null
$env:TEMP = $tempRoot
$env:TMP = $tempRoot
$env:PYTHONDONTWRITEBYTECODE = '1'
& 'D:\Tools\Blender\5.2.2\blender.exe' -b --python-exit-code 1 --python $Script -- @ScriptArgs
exit $LASTEXITCODE
