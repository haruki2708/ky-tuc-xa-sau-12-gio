"""Build the door lever handle (T-220, D-124): a round rose, a short neck and a lever bar.

    blender -b --factory-startup -P build_door_lever.py -- --out <door_lever.glb>

Godot axes after glTF export: the rose sits on the door face at the origin, the handle stands
out along +Z, the bar runs along +X (it turns about Z when pressed). Brushed steel, no texture.
"""
import argparse
import math
import sys

import bpy

ROSE_RADIUS = 0.027
ROSE_DEPTH = 0.008
NECK_RADIUS = 0.0085
NECK_LENGTH = 0.03
BAR_RADIUS = 0.0095
BAR_LENGTH = 0.115
# Blender -Y is glTF/Godot +Z (out of the door face).
OUT = -1.0


def main():
    argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", required=True)
    args = parser.parse_args(argv)

    bpy.ops.wm.read_factory_settings(use_empty=True)
    parts = []
    bpy.ops.mesh.primitive_cylinder_add(vertices=48, radius=ROSE_RADIUS, depth=ROSE_DEPTH,
                                        location=(0.0, OUT * ROSE_DEPTH * 0.5, 0.0), rotation=(math.radians(90), 0.0, 0.0))
    rose = bpy.context.active_object
    bevel = rose.modifiers.new("Bevel", "BEVEL")
    bevel.width = 0.0025
    bevel.segments = 3
    parts.append(rose)
    neck_centre = ROSE_DEPTH + NECK_LENGTH * 0.5
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=NECK_RADIUS, depth=NECK_LENGTH,
                                        location=(0.0, OUT * neck_centre, 0.0), rotation=(math.radians(90), 0.0, 0.0))
    parts.append(bpy.context.active_object)
    bar_out = ROSE_DEPTH + NECK_LENGTH - BAR_RADIUS * 0.4
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=BAR_RADIUS, depth=BAR_LENGTH,
                                        location=(BAR_LENGTH * 0.5, OUT * bar_out, 0.0), rotation=(0.0, math.radians(90), 0.0))
    parts.append(bpy.context.active_object)
    for x in (0.0, BAR_LENGTH):
        bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, radius=BAR_RADIUS * 1.02,
                                             location=(x, OUT * bar_out, 0.0))
        parts.append(bpy.context.active_object)
    for part in parts:
        bpy.context.view_layer.objects.active = part
        for modifier in list(part.modifiers):
            bpy.ops.object.modifier_apply(modifier=modifier.name)
    bpy.ops.object.select_all(action="DESELECT")
    for part in parts:
        part.select_set(True)
    bpy.context.view_layer.objects.active = parts[0]
    bpy.ops.object.join()
    lever = bpy.context.active_object
    lever.name = "DoorLever"
    bpy.ops.object.shade_auto_smooth(angle=math.radians(40))

    steel = bpy.data.materials.new("BrushedSteel")
    steel.use_nodes = True
    shader = steel.node_tree.nodes["Principled BSDF"]
    shader.inputs["Base Color"].default_value = (0.62, 0.61, 0.58, 1.0)
    shader.inputs["Metallic"].default_value = 1.0
    shader.inputs["Roughness"].default_value = 0.36
    lever.data.materials.append(steel)

    bpy.ops.export_scene.gltf(filepath=args.out, export_format="GLB", export_apply=True)
    tris = sum(len(poly.vertices) - 2 for poly in lever.data.polygons)
    print(f"wrote {args.out}: {tris} triangles")


if __name__ == "__main__":
    main()
