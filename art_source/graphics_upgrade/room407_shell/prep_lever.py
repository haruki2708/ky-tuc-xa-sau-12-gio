"""Turn the Tripo lever (door_lever.glb, T-222) into the lever space of DoorHandles (T-220, D-124):
the rose's back on the door face at the origin, the handle standing out along Godot +Z, the bar
running along +X, up +Y; rose 54 mm across like build_door_lever.py.
Blender 5.2.2:  blender -b --factory-startup -P prep_lever.py -- <src.glb> <out.glb>
Tripo modelled it tilted, with a long neck: the rose's normal and the bar come from a principal-axis
fit of the two ends; the depth (out of the door) is pressed to 60 % so the bar sits about 45 mm out.
Prints the glTF bounds for bake_prop.py --fit box.
"""
import sys

import bpy
import numpy as np
from mathutils import Matrix, Vector

ROSE_DIAMETER = 0.054
DEPTH = 0.6


def main():
    src, out = sys.argv[sys.argv.index("--") + 1:][:2]
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=src)
    obj = [o for o in bpy.data.objects if o.type == "MESH"][0]
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    co = np.empty(len(obj.data.vertices) * 3)
    obj.data.vertices.foreach_get("co", co)
    co = co.reshape(-1, 3)
    rose = co[co[:, 0] < co[:, 0].min() + 0.16]
    centre = rose.mean(axis=0)
    _, _, axes = np.linalg.svd(rose - centre, full_matrices=False)
    normal = axes[2] * (1 if axes[2][0] > 0 else -1)  # out of the door: toward the handle (+x side)
    up = np.array([0.0, 0.0, 1.0])
    normal = normal - up * normal.dot(up)
    normal /= np.linalg.norm(normal)
    bar = np.cross(up, normal)  # in the door plane; the grip's free end lies on its + side
    tip = co[np.argmax(co[:, 0])]
    if (tip - centre).dot(bar) < 0:
        bar = -bar
    depth = (rose - centre) @ normal
    origin = centre + normal * depth.min()
    diameter = np.ptp((rose - centre) @ up)
    s = ROSE_DIAMETER / diameter
    # Rows: lever axes in Blender space (Godot X=bar -> Blender x, Godot Z=out -> Blender -y, Y=up -> z).
    rot = np.array([bar, -normal, up])
    scale = np.diag([s, s * DEPTH, s])
    m = np.eye(4)
    m[:3, :3] = scale @ rot
    m[:3, 3] = -(scale @ rot) @ origin
    obj.data.transform(Matrix(m.tolist()))
    obj.data.update()
    co = np.array([tuple(v.co) for v in obj.data.vertices])
    lo, hi = co.min(axis=0), co.max(axis=0)
    # glTF bounds: (x, z, -y) of Blender.
    g_lo = (lo[0], lo[2], -hi[1])
    g_size = (hi[0] - lo[0], hi[2] - lo[2], hi[1] - lo[1])
    print("LEVER scale", round(s, 4), "rose diameter", round(diameter, 3))
    print("LEVER gltf_min", " ".join(f"{v:.5f}" for v in g_lo), "gltf_size", " ".join(f"{v:.5f}" for v in g_size))
    for image in bpy.data.images:
        if image.has_data:
            image.pack()
    bpy.ops.export_scene.gltf(filepath=out, export_format="GLB", use_selection=True, export_image_format="JPEG",
                              export_jpeg_quality=95, export_yup=True)


main()
