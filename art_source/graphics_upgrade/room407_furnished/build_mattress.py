"""Bunk mattress with the woven sleeping mat (chieu), from the approved T-213 corner (D-095 option a).
Run with Blender 5.2.2: blender -b --factory-startup -P <this file>.
One mattress, centred on x/z, bottom at y=0, top at y=0.05 (room407_anchors View heights 0.43 / 1.20
sit on the Tripo bunk decks at 0.38 / 1.15).
"""
import math
import sys
from pathlib import Path

import bpy

sys.dont_write_bytecode = True

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "room407_corner"))
import build_corner as bc  # noqa: E402  (helpers and CC0 materials of the corner pilot)

OUT = bc.ROOT / "game/assets/models/graphics_pilot/room407_furnished"
TOP = 0.05


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    fabric = bc.material("Mattress cover | scanned CC0", "rough_linen_square", strength=0.8)
    mat_rush = bc.material("Sleeping mat (chieu) | scanned CC0", "tatami_mat", strength=0.9)
    bc.GROUP = "bunk_mattress"
    mattress = bc.box("Mattress", (0, TOP - .026, 0), (.8, .048, 1.9), fabric, .016, .27)
    for vertex in mattress.data.vertices:
        if vertex.co.z > .005:
            vertex.co.z -= .003 * math.exp(-((vertex.co.x / .26) ** 2 + (vertex.co.y / .65) ** 2))
    bc.seam("Piping", [(-.395, TOP - .004, -.94), (.395, TOP - .004, -.94), (.395, TOP - .004, .94),
                       (-.395, TOP - .004, .94), (-.395, TOP - .004, -.94)], fabric)
    sleeping_mat = bc.grid("SleepingMat", (-.38, .38), (-.93, .93), TOP - .001, 1, 1, mat_rush, 1.8, lambda u, v: 0)
    for li, _loop in enumerate(sleeping_mat.data.loops):
        u, v = sleeping_mat.data.uv_layers.active.data[li].uv
        sleeping_mat.data.uv_layers.active.data[li].uv = (v, .03 + u * .42 / (.76 / 1.8))
    objects = bc.GROUPS["bunk_mattress"]
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / "bunk_mattress.glb"
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True, export_apply=True,
                              export_image_format="JPEG", export_jpeg_quality=90, export_yup=True)
    tris = 0
    for obj in objects:
        evaluated = obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
        mesh = evaluated.to_mesh()
        mesh.calc_loop_triangles()
        tris += len(mesh.loop_triangles)
        evaluated.to_mesh_clear()
    assert path.stat().st_size <= 10 * 1024 * 1024, path
    print("RESULT: bunk mattress export PASS", tris, "tris", path.stat().st_size, "bytes")


main()
