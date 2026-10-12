"""Normalize the Tripo Studio backpack for the G2 prototype (D-084, D-085).

Run with Blender 5.2.2 (background):
    blender -b --factory-startup -P normalize_backpack.py -- <source.glb> <output.glb>

Steps (TRIPO_BACKPACK.md, "Các bước khi đủ điều kiện" 5-6):
1. Import the untouched Tripo GLB.
2. Rotate 180 degrees about glTF +Y so the pocket faces glTF -Z (D-085 basis).
3. Fit the visual geometry to the measured envelope of the current backpack
   (root-local min (-0.145, 0.01, -0.1325), size (0.29, 0.45636, 0.30274)).
   Pivot stays at the origin; no world placement is baked in.
4. Resize every texture to at most 1024 x 1024.
5. Export a single static GLB (one material, Y-up).
"""
import sys

import bpy
import mathutils

TARGET_MIN_GLTF = mathutils.Vector((-0.145, 0.01, -0.1325))
TARGET_SIZE_GLTF = mathutils.Vector((0.29, 0.45636, 0.30274))
TEXTURE_EDGE = 1024


def gltf_to_blender(v: mathutils.Vector) -> mathutils.Vector:
    # glTF (x, y, z) Y-up -> Blender (x, -z, y) Z-up.
    return mathutils.Vector((v.x, -v.z, v.y))


def world_bounds(objects):
    lo = mathutils.Vector((1e9, 1e9, 1e9))
    hi = mathutils.Vector((-1e9, -1e9, -1e9))
    for obj in objects:
        for vert in obj.data.vertices:
            w = obj.matrix_world @ vert.co
            lo = mathutils.Vector(map(min, lo, w))
            hi = mathutils.Vector(map(max, hi, w))
    return lo, hi


def main() -> None:
    argv = sys.argv[sys.argv.index("--") + 1:]
    source, output = argv[0], argv[1]
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=source)
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    assert len(meshes) == 1, f"expected one mesh, got {len(meshes)}"
    obj = meshes[0]
    # Drop any imported parent empties so the mesh is the only node.
    world = obj.matrix_world.copy()
    obj.parent = None
    obj.matrix_world = world
    for other in list(bpy.context.scene.objects):
        if other is not obj:
            bpy.data.objects.remove(other, do_unlink=True)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    # 2. Pocket from glTF +Z to glTF -Z: 180 degrees about glTF Y (= Blender Z).
    obj.data.transform(mathutils.Matrix.Rotation(3.141592653589793, 4, "Z"))

    # 3. Fit to the measured envelope (Blender axes).
    lo, hi = world_bounds([obj])
    size = hi - lo
    target_min = gltf_to_blender(TARGET_MIN_GLTF)
    target_max = gltf_to_blender(TARGET_MIN_GLTF + TARGET_SIZE_GLTF)
    t_lo = mathutils.Vector(map(min, target_min, target_max))
    t_hi = mathutils.Vector(map(max, target_min, target_max))
    t_size = t_hi - t_lo
    scale = mathutils.Vector((t_size.x / size.x, t_size.y / size.y, t_size.z / size.z))
    print("NORMALIZE source size (blender)", tuple(round(v, 5) for v in size), "scale", tuple(round(v, 5) for v in scale))
    fit = mathutils.Matrix.Translation(t_lo) @ mathutils.Matrix.Diagonal((*scale, 1.0)) @ mathutils.Matrix.Translation(-lo)
    obj.data.transform(fit)
    obj.data.update()
    lo, hi = world_bounds([obj])
    print("NORMALIZE result bounds (blender)", tuple(round(v, 5) for v in lo), tuple(round(v, 5) for v in hi))

    # 4. Textures at most TEXTURE_EDGE.
    for image in bpy.data.images:
        if image.size[0] > TEXTURE_EDGE or image.size[1] > TEXTURE_EDGE:
            before = tuple(image.size)
            image.scale(min(image.size[0], TEXTURE_EDGE), min(image.size[1], TEXTURE_EDGE))
            image.pack()
            print("NORMALIZE texture", image.name, before, "->", tuple(image.size))

    # Stable texture names (Godot extracts embedded images by name).
    for image in bpy.data.images:
        for suffix in ("basecolor", "normal", "rm"):
            if image.name.rsplit(".", 1)[0].endswith("_" + suffix):
                image.name = "backpack_tripo_" + suffix
    obj.name = "backpack_tripo"
    obj.data.name = "backpack_tripo_mesh"
    tris = sum(len(p.vertices) - 2 for p in obj.data.polygons)
    print("NORMALIZE triangles", tris, "materials", len(obj.data.materials))
    bpy.ops.export_scene.gltf(filepath=output, export_format="GLB", use_selection=False,
        export_image_format="AUTO", export_yup=True, export_apply=True,
        export_animations=False, export_extras=False)
    print("NORMALIZE wrote", output)


main()
