"""Reopen the deliverable, check external textures and record mesh evidence."""
import json
from pathlib import Path

import bpy
from mathutils import Vector

HERE = Path(__file__).resolve().parent
bpy.ops.wm.open_mainfile(filepath=str(HERE / "room407_corner.blend"))
missing = []
images = []
for image in bpy.data.images:
    if image.source != "FILE":
        continue
    path = Path(bpy.path.abspath(image.filepath))
    if not path.is_file():
        missing.append(str(path))
    images.append({"name": image.name, "relative_path": image.filepath,
                   "size": list(image.size), "packed": bool(image.packed_file)})
report = {"blender": bpy.app.version_string, "missing_textures": missing,
          "blend_bytes": (HERE / "room407_corner.blend").stat().st_size,
          "images": images, "mesh_objects": sum(o.type == "MESH" for o in bpy.data.objects)}
report["props_room_local_bounds"] = {}
for row in json.loads((HERE / "placements.json").read_text()):
    root = bpy.data.objects[row["name"]]
    points = []
    for obj in root.children_recursive:
        if obj.type == "MESH":
            for corner in obj.bound_box:
                p = obj.matrix_world @ Vector(corner)
                points.append((p.x, p.z, -p.y))
    report["props_room_local_bounds"][row["name"]] = {
        "min": [min(p[i] for p in points) for i in range(3)],
        "max": [max(p[i] for p in points) for i in range(3)]}
(HERE / "blend_audit.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
assert not missing, missing
assert report["blend_bytes"] <= 10 * 1024 * 1024
assert all(not i["packed"] and i["relative_path"].startswith("//") for i in images)
print("RESULT: corner Blender reopen/external textures PASS", flush=True)
