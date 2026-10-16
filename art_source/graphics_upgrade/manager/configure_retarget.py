"""Write explicit Godot Humanoid BoneMaps and import options after initial import."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / "game/assets/models/characters/manager"


def mapping(source):
    if source == "mpfb":
        result = {"Root": "Root", "Hips": "pelvis", "Spine": "spine_01", "Chest": "spine_02",
                  "UpperChest": "spine_03", "Neck": "neck_01", "Head": "head"}
        parts = {"Shoulder": "clavicle", "UpperArm": "upperarm", "LowerArm": "lowerarm", "Hand": "hand",
                 "UpperLeg": "thigh", "LowerLeg": "calf", "Foot": "foot", "Toes": "ball"}
    else:
        result = {"Root": "root", "Hips": "DEF-hips", "Spine": "DEF-spine.001", "Chest": "DEF-spine.002",
                  "UpperChest": "DEF-spine.003", "Neck": "DEF-neck", "Head": "DEF-head"}
        parts = {"Shoulder": "shoulder", "UpperArm": "upper_arm", "LowerArm": "forearm", "Hand": "hand",
                 "UpperLeg": "thigh", "LowerLeg": "shin", "Foot": "foot", "Toes": "toe"}
    for side, suffix in [("Left", "l"), ("Right", "r")]:
        for profile, bone in parts.items():
            result[side+profile] = bone+"_"+suffix if source == "mpfb" else "DEF-"+bone+"."+suffix.upper()
        for finger in ["Thumb", "Index", "Middle", "Ring", "Little"]:
            origin = "pinky" if finger == "Little" else finger.lower()
            labels = ["Metacarpal", "Proximal", "Distal"] if finger == "Thumb" else ["Proximal", "Intermediate", "Distal"]
            for i, label in enumerate(labels, 1):
                result[side+finger+label] = (f"{origin}_{i:02d}_{suffix}" if source == "mpfb" else
                    f"DEF-{'f_' if finger != 'Thumb' else ''}{origin}.{i:02d}.{suffix.upper()}")
    return result


for file, source in [("manager_c", "mpfb"), ("manager_motion_source", "quaternius")]:
    bones = mapping(source)
    text = '[gd_resource type="BoneMap" load_steps=2 format=3]\n\n[sub_resource type="SkeletonProfileHumanoid" id="Profile"]\n\n[resource]\nprofile = SubResource("Profile")\n'
    text += "".join(f'bone_map/{key} = &"{value}"\n' for key, value in bones.items())
    (OUT / f"{source}_bone_map.tres").write_text(text, encoding="utf-8")
    path = OUT / f"{file}.glb.import"
    text = path.read_text(encoding="utf-8")
    options = f'''{{
"nodes": {{
"PATH:Rig/Skeleton3D": {{
"retarget/bone_map": Resource("res://assets/models/characters/manager/{source}_bone_map.tres"),
"retarget/bone_renamer/rename_bones": true,
"retarget/bone_renamer/unique_node/make_unique": true,
"retarget/bone_renamer/unique_node/skeleton_name": "GeneralSkeleton",
"retarget/rest_fixer/apply_node_transforms": true,
"retarget/rest_fixer/normalize_position_tracks": true,
"retarget/rest_fixer/retarget_method": 1,
"retarget/rest_fixer/fix_silhouette/enable": true,
"retarget/rest_fixer/fix_silhouette/threshold": 0.1,
"retarget/remove_tracks/except_bone_transform": false,
"retarget/remove_tracks/unimportant_positions": false,
"retarget/remove_tracks/unmapped_bones": false
}}
}}
}}'''
    text = re.sub(r"_subresources=\{.*?\}\ngltf/", lambda _: "_subresources="+options+"\ngltf/", text, flags=re.S)
    # Embedded textures remain in the GLB, keeping import deterministic and self-contained.
    text = text.replace("gltf/embedded_image_handling=1", "gltf/embedded_image_handling=2")
    path.write_text(text, encoding="utf-8")
    (OUT / f"{source}_bone_map.json").write_text(json.dumps(bones, indent=2)+"\n", encoding="utf-8")
