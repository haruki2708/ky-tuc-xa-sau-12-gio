"""Extract the six pilot clips from the CC0 Quaternius Standard library.

Godot's SkeletonProfileHumanoid performs the actual shared-rig retargeting.
Only deform-bone rotation and pelvis position survive the import settings.
"""
import json
import math
from pathlib import Path
import bpy
from mathutils import Vector, Matrix, Quaternion

ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / "build/t219/downloads/gltf-universal-animation-library-main/glTF/AnimationLibrary_Godot_Standard.gltf"
OUT = ROOT / "game/assets/models/characters/manager/manager_motion_source.glb"
CLIPS = {"stand": "Idle_Loop", "walk": "Walk_Formal_Loop", "ask": "Idle_Talking_Loop",
         "slash": "Sword_Attack", "lunge": "Sprint_Loop", "kill": "Sword_Attack"}


def orient(bone, direction):
    bpy.context.view_layer.update()
    rotation = bone.vector.normalized().rotation_difference(Vector(direction).normalized())
    bone.matrix = Matrix.Translation(bone.head) @ rotation.to_matrix().to_4x4() @ bone.matrix.to_3x3().to_4x4()
    bpy.context.view_layer.update()


def arm_ik(rig, side, target, pole, blade_direction):
    upper, lower, hand = [rig.pose.bones['DEF-'+name+'.'+side] for name in ('upper_arm', 'forearm', 'hand')]
    shoulder = upper.head.copy()
    ray = target-shoulder
    distance = min(ray.length, upper.length+lower.length-0.005)
    axis = ray.normalized()
    along = (upper.length**2-lower.length**2+distance**2)/(2*distance)
    away = (Vector(pole)-shoulder)
    away = (away-axis*away.dot(axis)).normalized()
    elbow = shoulder+axis*along+away*math.sqrt(max(0, upper.length**2-along**2))
    orient(upper, elbow-shoulder)
    orient(lower, target-lower.head)
    orient(hand, blade_direction)


def author_stand(rig, action):
    # Approved review change: a CC0 upright idle authored once on the SOURCE rig.
    # The original Idle_Loop has 21/14 degree knees even without retargeting.
    rig.animation_data.action = action
    rig.animation_data.action_slot = action.slots[0]
    bpy.context.scene.frame_set(0)
    grip = {b.name: b.rotation_quaternion.copy() for b in rig.pose.bones
            if b.name.endswith('.R') and (b.name.startswith('DEF-f_') or b.name.startswith('DEF-thumb'))}
    for layer in action.layers:
        for strip in layer.strips:
            for bag in strip.channelbags:
                for curve in list(bag.fcurves):
                    bag.fcurves.remove(curve)
    rig.animation_data.action = action
    rig.animation_data.action_slot = action.slots[0]
    for frame in range(0, 61, 5):
        bpy.context.scene.frame_set(frame)
        for bone in rig.pose.bones:
            bone.matrix_basis = Matrix.Identity(4)
            bone.rotation_mode = 'QUATERNION'
        bpy.context.view_layer.update()
        for side, sign in [('L', 1), ('R', -1)]:
            orient(rig.pose.bones['DEF-upper_arm.'+side], (sign*0.12, -0.025, -1))
            orient(rig.pose.bones['DEF-forearm.'+side], (-sign*0.04, -0.075, -1))
        for name, rotation in grip.items():
            rig.pose.bones[name].rotation_quaternion = rotation
        breath = math.sin(frame/60*2*math.pi)
        rig.pose.bones['DEF-spine.002'].rotation_quaternion = Quaternion((1, 0, 0), 0.008*breath)
        for bone in rig.pose.bones:
            bone.keyframe_insert('location', frame=frame)
            bone.keyframe_insert('rotation_quaternion', frame=frame)
            bone.keyframe_insert('scale', frame=frame)
    rig.animation_data.action = None


def author_slash(rig, action):
    # Preserve CC0 Sword_Attack body motion; replace both arm chains with an
    # overhead diagonal cut. Contact at 0.25 s, windup at 0.10 s after retiming.
    rig.animation_data.action = action
    rig.animation_data.action_slot = action.slots[0]
    start, end = action.frame_range
    keys = [
        (0.0, (0.02, -0.20, -0.23), (0.05, -0.6, -0.8)),
        (0.2222, (-0.06, -0.035, 0.18), (0.05, 0.1, 1.0)),
        (0.5556, (0.18, -0.42, -0.27), (0.08, -0.7, -0.72)),
        (0.8444, (0.10, -0.25, -0.30), (0.05, -0.7, -0.72)),
        (1.0, (0.02, -0.20, -0.23), (0.05, -0.6, -0.8)),
    ]
    for frame in range(int(start), int(end)+1):
        bpy.context.scene.frame_set(frame)
        t = (frame-start)/(end-start)
        a, b = next((a, b) for a, b in zip(keys, keys[1:]) if a[0] <= t <= b[0])
        f = (t-a[0])/(b[0]-a[0])
        f = f*f*(3-2*f)
        shoulder = rig.pose.bones['DEF-upper_arm.R'].head.copy()
        target = shoulder+Vector(a[1]).lerp(Vector(b[1]), f)
        direction = Vector(a[2]).lerp(Vector(b[2]), f)
        arm_ik(rig, 'R', target, shoulder+Vector((-0.30, -0.15, 0.04)), direction)
        left = rig.pose.bones['DEF-upper_arm.L'].head.copy()
        arm_ik(rig, 'L', left+Vector((-0.13, -0.16, -0.30)), left+Vector((0.08, 0.0, -0.3)), (-0.3, -0.2, -1))
        for side in ('L', 'R'):
            for name in ('upper_arm', 'forearm', 'hand'):
                bone = rig.pose.bones['DEF-'+name+'.'+side]
                bone.rotation_mode = 'QUATERNION'
                bone.keyframe_insert('rotation_quaternion', frame=frame)
    rig.animation_data.action = None

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
    if name == 'stand':
        author_stand(rig, action)
    elif name == 'slash':
        author_slash(rig, action)
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
bpy.context.preferences.filepaths.save_version = 0
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT / 'art_source/graphics_upgrade/manager/manager_motion.blend'), compress=True)
