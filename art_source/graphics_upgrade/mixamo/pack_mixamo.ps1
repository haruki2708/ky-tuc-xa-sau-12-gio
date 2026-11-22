# T-268: pack Mixamo motion clips (FBX, "Without Skin", X Bot) into Godot animation libraries for
# Tran Trung and the manager. The raw FBX never enters game/ (D-189): a throwaway Godot project in
# build/mixamo_pack/ imports them with Godot's own humanoid retarget, then pack_mixamo.gd writes
# one AnimationLibrary .res per character, and only those .res files are copied into the game.
#
#   pwsh -NoProfile -File art_source/graphics_upgrade/mixamo/pack_mixamo.ps1            # setup, import, pack, copy
#   ... -Stage setup|import|pack|probe -Who trung -Probe walk_fwd                           # one stage
#
# Godot runs go through build/integrator/godot_steps_locked.ps1 (the shared Godot lock).
param(
    [ValidateSet('all', 'setup', 'import', 'pack', 'probe')][string]$Stage = 'all',
    [string[]]$Who = @('trung', 'manager'),
    [string]$Probe = '',
    [switch]$NoCopy
)
$ErrorActionPreference = 'Stop'
$repo = 'D:\GAME_DEMO'
$here = Join-Path $repo 'art_source\graphics_upgrade\mixamo'
$staging = Join-Path $repo 'build\graphics\staging\mixamo'
$proj = Join-Path $repo 'build\mixamo_pack'
$out = Join-Path $repo 'game\assets\models\characters\mixamo'
$manifest = Get-Content -LiteralPath (Join-Path $here 'clips.json') -Raw | ConvertFrom-Json

# Tran Trung's own import (trung_tripo.glb.import) forces his A-pose arms and his feet onto the
# humanoid profile (fix_silhouette). The X Bot is a T-pose, but its feet point 39 degrees off the
# profile and its collarbones 12: the same fix at 11 degrees puts both rigs on one silhouette.
$skeletonRetarget = @'
"retarget/bone_map": Resource("res://mixamo_bone_map.tres"),
"retarget/bone_renamer/rename_bones": true,
"retarget/bone_renamer/unique_node/make_unique": true,
"retarget/bone_renamer/unique_node/skeleton_name": "GeneralSkeleton",
"retarget/remove_tracks/except_bone_transform": false,
"retarget/remove_tracks/unimportant_positions": true,
"retarget/remove_tracks/unmapped_bones": UNMAPPED,
"retarget/rest_fixer/apply_node_transforms": true,
"retarget/rest_fixer/normalize_position_tracks": true,
"retarget/rest_fixer/reset_all_bone_poses_after_import": true,
"retarget/rest_fixer/retarget_method": 1,
"retarget/rest_fixer/keep_global_rest_on_leftovers": true,
"retarget/rest_fixer/fix_silhouette/enable": true,
"retarget/rest_fixer/fix_silhouette/threshold": THRESHOLD
'@

function Write-FbxImport([string]$resPath, [string]$file) {
    $retarget = $skeletonRetarget.Replace('UNMAPPED', '1').Replace('THRESHOLD', '11.0')
    $text = @"
[remap]

importer="scene"
importer_version=1
type="PackedScene"

[deps]

source_file="$resPath"

[params]

nodes/root_type=""
nodes/root_name=""
nodes/root_script=null
nodes/apply_root_scale=true
nodes/root_scale=1.0
nodes/import_as_skeleton_bones=false
nodes/use_name_suffixes=true
nodes/use_node_type_suffixes=true
meshes/ensure_tangents=false
meshes/generate_lods=false
meshes/create_shadow_meshes=false
meshes/light_baking=0
skins/use_named_skins=true
animation/import=true
animation/fps=30
animation/trimming=false
animation/remove_immutable_tracks=true
animation/import_rest_as_RESET=false
import_script/path=""
materials/extract=0
_subresources={
"nodes": {
"PATH:Skeleton3D": {
$retarget
},
"PATH:AnimationPlayer": {
"optimizer/enabled": false,
"compression/enabled": false
}
}
}
fbx/importer=0
fbx/allow_geometry_helper_nodes=false
fbx/embedded_image_handling=0
fbx/naming_version=2
"@
    Set-Content -LiteralPath ($file + '.import') -Value $text -Encoding utf8NoBOM
}

# The manager's skeleton is not retargeted in the game (manager_tripo.glb.import has no bone map),
# so his clips are baked onto it: the same GLB imported twice, once as the game imports it and once
# retargeted the way Tran Trung is (pack_mixamo.gd copies the retargeted copy's skinning).
function Write-ManagerImport([string]$resPath, [string]$file, [bool]$retargeted) {
    $sub = '{}'
    if ($retargeted) {
        $retarget = $skeletonRetarget.Replace('UNMAPPED', '0').Replace('THRESHOLD', '15.0')
        $sub = "{`n`"nodes`": {`n`"PATH:Armature/Skeleton3D`": {`n$retarget`n}`n}`n}"
    }
    $text = @"
[remap]

importer="scene"
importer_version=1
type="PackedScene"

[deps]

source_file="$resPath"

[params]

nodes/root_type=""
nodes/root_name=""
nodes/root_script=null
nodes/apply_root_scale=true
nodes/root_scale=1.73
nodes/import_as_skeleton_bones=false
nodes/use_name_suffixes=true
nodes/use_node_type_suffixes=true
meshes/ensure_tangents=false
meshes/generate_lods=false
meshes/create_shadow_meshes=false
meshes/light_baking=0
skins/use_named_skins=true
animation/import=true
animation/fps=30
animation/trimming=false
animation/remove_immutable_tracks=true
animation/import_rest_as_RESET=false
import_script/path=""
materials/extract=0
_subresources=$sub
gltf/naming_version=2
gltf/embedded_image_handling=0
gltf/texture_map_mode=1
"@
    Set-Content -LiteralPath ($file + '.import') -Value $text -Encoding utf8NoBOM
}

function Invoke-Setup {
    New-Item -ItemType Directory -Force $proj, (Join-Path $proj 'out') | Out-Null
    @"
config_version=5

[application]

config/name="mixamo_pack"
config/features=PackedStringArray("4.7")

[filesystem]

import/fbx2gltf/enabled=false
import/blender/enabled=false
"@ | Set-Content -LiteralPath (Join-Path $proj 'project.godot') -Encoding utf8NoBOM
    foreach ($f in 'mixamo_bone_map.tres', 'pack_mixamo.gd', 'clips.json') {
        Copy-Item -LiteralPath (Join-Path $here $f) -Destination (Join-Path $proj $f) -Force
    }
    foreach ($w in $Who) {
        $dir = Join-Path $proj "src\$w"
        New-Item -ItemType Directory -Force $dir | Out-Null
        foreach ($clip in $manifest.$w) {
            $from = Join-Path $staging "$w\$($clip.file).fbx"
            if (-not (Test-Path -LiteralPath $from)) { throw "missing $from" }
            $to = Join-Path $dir "$($clip.file).fbx"
            if (-not (Test-Path -LiteralPath $to) -or (Get-Item $to).Length -ne (Get-Item $from).Length) { Copy-Item -LiteralPath $from -Destination $to -Force }
            if (-not (Test-Path -LiteralPath ($to + '.import'))) { Write-FbxImport "res://src/$w/$($clip.file).fbx" $to }
        }
    }
    if ($Who -contains 'manager') {
        $dir = Join-Path $proj 'manager'
        New-Item -ItemType Directory -Force $dir | Out-Null
        $glb = Join-Path $repo 'game\assets\models\characters\manager\manager_tripo.glb'
        foreach ($twin in @(@('manager_plain', $false), @('manager_ret', $true))) {
            $to = Join-Path $dir "$($twin[0]).glb"
            Copy-Item -LiteralPath $glb -Destination $to -Force
            if (-not (Test-Path -LiteralPath ($to + '.import'))) { Write-ManagerImport "res://manager/$($twin[0]).glb" $to $twin[1] }
        }
    }
    "setup: $proj"
}

function Invoke-Godot([string]$label, [string]$godotArgs) {
    & (Join-Path $repo 'build\integrator\godot_steps_locked.ps1') -Label $label -ProjectDir $proj -Steps @("run|900|$godotArgs")
    $log = Join-Path $repo "build\integrator\${label}_run.out.log"
    Get-Content -LiteralPath $log | Select-String -Pattern 'ERROR|WARNING|PACK|PROBE|CHECK|FAIL' | Select-Object -First 200 | ForEach-Object { $_.Line }
}

if ($Stage -in 'all', 'setup') { Invoke-Setup }
if ($Stage -in 'all', 'import') { Invoke-Godot 't268pack_import' '--headless --import' }
if ($Stage -eq 'probe') { Invoke-Godot 't268pack_probe' "--headless --script res://pack_mixamo.gd -- --probe=$($Who[0])/$Probe" }
if ($Stage -in 'all', 'pack') {
    Invoke-Godot 't268pack_pack' ("--headless --script res://pack_mixamo.gd -- --pack=" + ($Who -join ','))
    if (-not $NoCopy) {
        New-Item -ItemType Directory -Force $out | Out-Null
        foreach ($w in $Who) {
            $res = Join-Path $proj "out\${w}_mixamo.res"
            if (Test-Path -LiteralPath $res) { Copy-Item -LiteralPath $res -Destination (Join-Path $out "${w}_mixamo.res") -Force; "copied ${w}_mixamo.res ($((Get-Item $res).Length) bytes)" }
            else { "MISSING $res" }
        }
    }
}
