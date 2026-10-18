"""Stand a tilted Tripo prop upright along its principal axes (T-219, D-118).

Blender 5.2.2, background:
    blender -b --factory-startup -P align_prop.py -- --src knife.glb --out knife_upright.glb

Tripo returns hand props at an arbitrary tilt; bake_prop.py only turns about the
vertical axis. This rotates the detailed model so its longest axis is vertical
(Blender +Z, glTF +Y), the middle axis is X and the thinnest axis is the depth.
The wider end (the cleaver blade) goes up, so the handle end sits at the origin.
"""
import argparse
import sys

import bpy
import mathutils
import numpy


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--src", required=True)
    parser.add_argument("--out", required=True)
    args = parser.parse_args(sys.argv[sys.argv.index("--") + 1:])

    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=args.src)
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]
    for obj in meshes:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = meshes[0]
    if len(meshes) > 1:
        bpy.ops.object.join()
    obj = bpy.context.view_layer.objects.active
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

    count = len(obj.data.vertices)
    co = numpy.empty(count * 3)
    obj.data.vertices.foreach_get("co", co)
    co = co.reshape(count, 3)
    centre = co.mean(axis=0)
    values, vectors = numpy.linalg.eigh(numpy.cov((co - centre).T))
    order = numpy.argsort(values)[::-1]
    length, middle = vectors[:, order[0]], vectors[:, order[1]]
    along = (co - centre) @ length
    across = numpy.abs((co - centre) @ middle)
    low, high = numpy.quantile(along, [0.3, 0.7])
    if across[along > high].max() < across[along < low].max():
        length = -length
    depth = numpy.cross(middle, length)
    basis = mathutils.Matrix((middle, depth, length))  # rows: new X, Y, Z
    obj.data.transform(basis.to_4x4() @ mathutils.Matrix.Translation(-mathutils.Vector(centre)))
    obj.data.update()
    zmin = min(v.co.z for v in obj.data.vertices)
    obj.data.transform(mathutils.Matrix.Translation((0.0, 0.0, -zmin)))
    print("axes (length, middle, depth):", [round(float(numpy.sqrt(v)), 4) for v in values[order]])
    bpy.ops.export_scene.gltf(filepath=args.out, export_format="GLB", use_selection=False)


main()
