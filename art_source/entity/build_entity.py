"""T-135 original low-poly figures; Blender background, metres, no addons."""
import json
import math
from pathlib import Path

import bpy
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "game/assets/models/entity"


def material(name, color):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1)
    shader.inputs["Roughness"].default_value = 1
    return mat


def ellipsoid(name, center, radius, mat, parent=None):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=4, location=center)
    obj = bpy.context.object
    obj.name = name
    obj.scale = radius
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    if parent:
        world = obj.matrix_world.copy()
        obj.parent = parent
        obj.matrix_world = world
    return obj


def limb(name, a, b, radius, mat):
    middle = (Vector(a) + Vector(b)) / 2
    obj = ellipsoid(name, middle, (radius, radius, (Vector(b) - Vector(a)).length / 2 + radius), mat)
    obj.rotation_euler = (Vector(b) - Vector(a)).to_track_quat("Z", "Y").to_euler()
    return obj


def box(name, center, scale, mat):
    bpy.ops.mesh.primitive_cube_add(size=1, location=center)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    return obj


def build(silhouette):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    skin = material("shadow" if silhouette else "skin", (.006, .009, .011) if silhouette else (.43, .29, .20))
    shirt = skin if silhouette else material("cotton_shirt", (.39, .46, .39))
    shorts = skin if silhouette else material("shorts", (.075, .10, .14))
    sandals = skin if silhouette else material("rubber_sandals", (.025, .037, .034))
    hair = skin if silhouette else material("hair", (.025, .021, .018))
    # Blender -Y becomes Godot +Z; front +Y becomes Godot -Z.
    ellipsoid("Torso", (0, .0, 1.28), (.22 if silhouette else .25, .12, .34), shirt)
    ellipsoid("Shoulders", (0, -.01, 1.48), (.26, .15, .17), shirt)
    ellipsoid("Hips", (0, 0, .91), (.17, .12, .18), shorts)
    for side in (-1, 1):
        x = side * .115
        limb("Leg", (x, 0, .86), (x + side * .015, .012, .12), .065 if silhouette else .078, skin)
        box("Slipper", (x + side * .015, .055, .035), (.13, .28, .07), sandals)
        if not silhouette:
            box("ShortsLeg", (x, 0, .79), (.205, .235, .29), shorts)
            box("SlipperStrap", (x + side * .015, .03, .085), (.14, .075, .035), shorts)
        shoulder = (side * .235, .01, 1.47)
        hand = (side * .31, .07, .64 if silhouette else .84)
        limb("Arm", shoulder, hand, .048 if silhouette else .06, skin)
        if not silhouette:
            limb("Sleeve", shoulder, (side * .29, .015, 1.30), .087, shirt)
    head = bpy.data.objects.new("HeadPivot", None)
    bpy.context.collection.objects.link(head)
    head.location = (.035 if silhouette else 0, .05, 1.62)
    ellipsoid("Head", (head.location.x, .065, 1.70 if silhouette else 1.61),
              (.105, .11, .15 if silhouette else .14), skin, head)
    if silhouette:
        head.rotation_euler.y = math.radians(-12)
    else:
        ellipsoid("Hair", (0, .047, 1.72), (.11, .111, .06), hair, head)
        # A small nose makes head direction legible without detailed facial art.
        nose = box("Nose", (0, .177, 1.62), (.042, .04, .045), skin)
        world = nose.matrix_world.copy()
        nose.parent = head
        nose.matrix_world = world
    triangles = 0
    for obj in bpy.context.scene.objects:
        if obj.type == "MESH":
            obj.data.calc_loop_triangles()
            triangles += len(obj.data.loop_triangles)
    if silhouette:
        assert triangles < 800, triangles
    name = "silhouette" if silhouette else "reflection_body"
    bpy.ops.export_scene.gltf(filepath=str(OUT / f"{name}.glb"), export_format="GLB",
                             export_yup=True, export_cameras=False, export_lights=False)
    return {"triangles": triangles, "origin": "feet", "front": "Godot -Z"}


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    report = {"blender": bpy.app.version_string, "models": {}}
    for shadow in (True, False):
        report["models"]["silhouette" if shadow else "reflection_body"] = build(shadow)
    (ROOT / "art_source/entity/manifest.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print("ENTITY_BUILD_RESULT:", json.dumps(report))
