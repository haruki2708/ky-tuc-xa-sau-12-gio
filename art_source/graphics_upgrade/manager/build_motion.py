"""Extract the six pilot clips from the CC0 Quaternius Standard library.

Godot's SkeletonProfileHumanoid performs the actual shared-rig retargeting.
Only deform-bone rotation and pelvis position survive the import settings.
"""
import json
from pathlib import Path
import bpy

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / "build/t219/downloads/gltf-universal-animation-library-main/glTF/AnimationLibrary_Godot_Standard.gltf"
OUT = ROOT / "game/assets/models/characters/manager/manager_motion_source.glb"
CLIPS = {"stand": "Idle_Loop", "walk": "Walk_Formal_Loop", "ask": "Idle_Talking_Loop",
         "slash": "Sword_Attack", "lunge": "Sprint_Loop", "kill": "Sword_Attack"}

bpy.ops.object.select_all(action="SELECT")
bpy.ops.object.delete(use_global=False)
bpy.ops.import_scene.gltf(filepath=str(SOURCE))
rig = next(obj for obj in bpy.context.scene.objects if obj.type == "ARMATURE")
rig.name = "Rig"
actions = {action.name: action for action in bpy.data.actions}
print("T219_ACTIONS", [(a.name, list(a.frame_range)) for a in actions.values()])
rig.animation_data_clear()
rig.animation_data_create()
for name, source_name in CLIPS.items():
    source = next(a for key, a in actions.items() if key == source_name or key.endswith("|" + source_name))
    action = source.copy()
    action.name = name
    action.use_fake_user = True
    track = rig.animation_data.nla_tracks.new()
    track.name = name
    strip = track.strips.new(name, int(action.frame_range[0]), action)
    strip.name = name
    if action.slots:
        strip.action_slot = action.slots[0]
# Original imported tracks and actions are intentionally excluded.
bpy.ops.object.select_all(action="DESELECT")
rig.select_set(True)
for child in rig.children_recursive:
    child.select_set(True)
bpy.context.view_layer.objects.active = rig
bpy.ops.export_scene.gltf(filepath=str(OUT), export_format="GLB", use_selection=True,
    export_animation_mode="NLA_TRACKS", export_nla_strips=True, export_force_sampling=True)
print("T219_MOTION", OUT, OUT.stat().st_size)
