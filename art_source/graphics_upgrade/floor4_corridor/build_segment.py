"""T-233: the floor-4 corridor pilot segment around doors 406 and 407 in room 407's style (D-142, option A).
Run after make_segment_masks.py, with Blender 5.2.2 (from the repository root):
  blender -b --factory-startup -P art_source/graphics_upgrade/floor4_corridor/build_segment.py
Exports to game/assets/models/graphics_pilot/floor4_corridor/, in Floor4 metres (place at the Floor4 origin):
  segment_shell.glb            corridor face of the room wall, floor, tile skirting, ceiling
  segment_frames.glb           door linings, architraves, granite sills; 406's stops and hinges
  segment_railing_dense.glb    painted steel railing, balusters every 12.5 cm (pilot default)
  segment_railing_classic.glb  the same railing with the PS1 rhythm (a baluster every 0.5 m)
  segment_lamps.glb            two enamel tube battens like room 407's, under the corridor lights
Every material is a placeholder named Corr*: corridor_g5_pilot.gd gives the surfaces room 407's shell
shader with this segment's mask atlases (make_segment_masks.py) and the rest the CC0 scans already in
the game, so no texture is copied into these files. Shell surfaces carry UV1 in world metres (tiles line
up across segments) and UV2 on their group's mask atlas.
"""
import json
import math
import sys
from pathlib import Path

import bpy
from mathutils import Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "room407_corner"))
import build_corner as bc  # noqa: E402
import segment_layout as L  # noqa: E402

OUT = bc.ROOT / "game/assets/models/graphics_pilot/floor4_corridor"
# Metres per repeat of each shell scan (UV1): 40 cm floor tiles, the plaster of room 407.
PERIOD = {"wall": 2.0, "floor": 2.0, "skirting": 2.0, "ceiling": 2.0}
# The skirting is a 10 cm strip cut from a floor tile: keep its UV1 inside one tile row (no grout line).
SKIRTING_V = 0.075
PLACEHOLDER = {  # name: (colour, roughness, metallic)
    "CorrWall": ((0.70, 0.67, 0.58), 0.85, 0.0), "CorrFloor": ((0.55, 0.47, 0.40), 0.6, 0.0),
    "CorrSkirting": ((0.55, 0.47, 0.40), 0.6, 0.0), "CorrCeiling": ((0.78, 0.76, 0.69), 0.9, 0.0),
    "CorrFrameGreen": ((0.08, 0.22, 0.15), 0.6, 0.0), "CorrGranite": ((0.25, 0.25, 0.25), 0.5, 0.0),
    "CorrHinge": ((0.32, 0.31, 0.29), 0.45, 1.0), "CorrRailSteel": ((0.12, 0.2, 0.13), 0.55, 0.3),
    "CorrEnamel": ((0.78, 0.75, 0.64), 0.42, 0.0), "CorrTubeGlass": ((0.92, 0.94, 0.9), 0.25, 0.0),
    "CorrTubeCap": ((0.55, 0.55, 0.52), 0.4, 1.0),
}
SOLID = 0.04  # back faces behind every shell surface: light-tight and solid for the corridor lights' shadows
MATS = {}


def mat(name):
    if name not in MATS:
        colour, roughness, metallic = PLACEHOLDER[name]
        m = bpy.data.materials.new(name)
        m.use_nodes = True
        bsdf = m.node_tree.nodes["Principled BSDF"]
        bsdf.inputs["Base Color"].default_value = (*colour, 1)
        bsdf.inputs["Roughness"].default_value = roughness
        bsdf.inputs["Metallic"].default_value = metallic
        m.diffuse_color = (*colour, 1)
        MATS[name] = m
    return MATS[name]


def surface_piece(s, scale, obj_name, a0, b0, a1, b1):
    """One rectangle of a shell surface: UV1 in world metres, UV2 on the atlas, solid back faces."""
    corners = [(a0, b0), (a1, b0), (a1, b1), (a0, b1)]
    points = [s.point(a, b) for a, b in corners]
    mesh = bpy.data.meshes.new(obj_name)
    mesh.from_pydata([bc.point(p) for p in points], [], [(0, 1, 2, 3)])
    mesh.update()
    n = s.normal
    if mesh.polygons[0].normal.dot(Vector((n[0], -n[2], n[1]))) < 0:
        mesh.flip_normals()
    uv1 = mesh.uv_layers.new(name="UVMap")
    uv2 = mesh.uv_layers.new(name="Atlas")
    period = PERIOD[s.material]
    x0, y0 = s.rect[0], s.rect[1]
    for poly in mesh.polygons:
        for li in poly.loop_indices:
            vi = mesh.loops[li].vertex_index
            a, b = corners[vi]
            p = points[vi]
            ua = sum(p[i] * s.u[i] for i in range(3)) / period
            vb = sum(p[i] * s.v[i] for i in range(3)) / period
            if s.material == "skirting":
                vb = SKIRTING_V + b / period
            uv1.data[li].uv = (ua, vb)
            uv2.data[li].uv = ((x0 + a * scale) / L.ATLAS[0], 1.0 - (y0 + b * scale) / L.ATLAS[1])
    obj = bpy.data.objects.new(obj_name, mesh)
    bpy.context.collection.objects.link(obj)
    solid = obj.modifiers.new("Back faces", "SOLIDIFY")
    solid.thickness = L.SKIRTING[1] if s.material == "skirting" else SOLID
    solid.offset, solid.use_rim = -1.0, True
    bc.GROUP = "shell"
    return bc.finish(obj, obj_name, mat("Corr" + s.material.capitalize()))


def box(name, lo, hi, material, bevel=0.003, period=0.6):
    """Axis-aligned box between two Floor4 corners."""
    centre = tuple((lo[i] + hi[i]) / 2 for i in range(3))
    size = tuple(hi[i] - lo[i] for i in range(3))
    return bc.box(name, centre, size, mat(material), bevel, period)


def hinge(name, x, y, z):
    steel = mat("CorrHinge")
    bc.tube(name, (x, y - 0.05, z), (x, y + 0.05, z), 0.007, steel, 12, 0.1)
    bc.tube(name + "Pin", (x, y + 0.05, z), (x, y + 0.058, z), 0.004, steel, 8, 0.1)


def door_frames():
    bc.GROUP = "frames"
    face, lin = L.WALL_FACE, L.LIN
    for d in L.DOORS:
        hx0, hx1, htop = d.hole
        n = d.name
        # Linings fill the reveal from the room's frame (407) or the room face (406) to the corridor face.
        box(n + "LiningW", (hx0, 0.0, d.z0), (d.x0, d.top, face), "CorrFrameGreen")
        box(n + "LiningE", (d.x1, 0.0, d.z0), (hx1, d.top, face), "CorrFrameGreen")
        box(n + "LiningTop", (hx0, d.top, d.z0), (hx1, htop, face), "CorrFrameGreen")
        # Architraves on the corridor face: legs to the top of the head, the head between them.
        box(n + "ArchitraveW", (hx0 - L.ARCH_W, 0.0, face), (hx0, htop + L.ARCH_W, face + L.ARCH_T), "CorrFrameGreen", 0.004)
        box(n + "ArchitraveE", (hx1, 0.0, face), (hx1 + L.ARCH_W, htop + L.ARCH_W, face + L.ARCH_T), "CorrFrameGreen", 0.004)
        box(n + "ArchitraveTop", (hx0, htop, face), (hx1, htop + L.ARCH_W, face + L.ARCH_T), "CorrFrameGreen", 0.004)
        box(n + "Sill", (d.x0, 0.0, d.z0), (d.x1, L.SILL, face + 0.006), "CorrGranite", 0.003, 0.5)
        if d.swing == "out":
            # The leaf closes from the corridor side against stops on its room side (z -0.045).
            box(n + "StopW", (d.x0, L.SILL, -0.07), (d.x0 + 0.012, d.top, -0.045), "CorrFrameGreen", 0.002)
            box(n + "StopTop", (d.x0, d.top - 0.012, -0.07), (d.x1, d.top, -0.045), "CorrFrameGreen", 0.002)
            for y in (0.25, 1.05, 1.85):  # knuckles on the hinge line, seen from the corridor
                hinge(n + "Hinge", d.x1 - 0.004, y, d.hinge[2] - 0.002)


def railing(variant):
    group = "railing_" + variant
    bc.GROUP = group
    z = L.RAIL_Z
    steel = mat("CorrRailSteel")
    for k, x in enumerate(L.POSTS):
        box(f"Post{k}", (x - 0.025, 0.0, z - 0.025), (x + 0.025, 1.05, z + 0.025), "CorrRailSteel", 0.003, 0.5)
        box(f"PostPlate{k}", (x - 0.06, 0.0, z - 0.06), (x + 0.06, 0.006, z + 0.06), "CorrRailSteel", 0.001, 0.5)
    # Handrail pipe inside the old top rail's collider (y 1.04..1.10), flat bottom rail inside the low one.
    bc.tube("Handrail", (L.X0, 1.07, z), (L.X1, 1.07, z), 0.025, steel, 16, 0.5)
    box("BottomRail", (L.X0, 0.16, z - 0.015), (L.X1, 0.20, z + 0.015), "CorrRailSteel", 0.002, 0.5)
    step = L.BAR_SPACING[variant]
    count = int(round((L.X1 - L.X0) / step))
    k = 0
    for i in range(count + 1):
        x = L.X0 + i * step if variant == "classic" else L.X0 + (i + 0.5) * step
        if x >= L.X1 or any(abs(x - p) < 0.04 for p in L.POSTS):
            continue
        box(f"Baluster{k}", (x - 0.008, 0.20, z - 0.008), (x + 0.008, 1.046, z + 0.008), "CorrRailSteel", 0.0, 0.5)
        k += 1
    return group


def lamps():
    """Room 407's tube batten (build_shell.py fixtures) under each corridor light; the lights do not move."""
    bc.GROUP = "lamps"
    enamel, glass, cap = mat("CorrEnamel"), mat("CorrTubeGlass"), mat("CorrTubeCap")
    for k, (cx, cz) in enumerate(L.LIGHTS):
        cy, length = 2.9, 1.24
        tag = f"Lamp{k}"
        bc.box(tag + "Housing", (cx, cy + 0.07, cz), (length, 0.06, 0.14), enamel, 0.012, 0.5)
        for side in (-1, 1):
            bc.box(tag + "Reflector", (cx, cy + 0.035, cz + side * 0.075), (length - 0.02, 0.07, 0.006), enamel, 0.002, 0.5)
            bc.box(tag + "EndCap", (cx + side * (length / 2 - 0.02), cy + 0.03, cz), (0.035, 0.08, 0.15), enamel, 0.008, 0.3)
        for tz in (cz - 0.035, cz + 0.035):
            bc.tube("FluorescentTube", (cx - 0.54, 2.84, tz), (cx + 0.54, 2.84, tz), 0.016, glass, 16, 0.5)
            for x in (cx - 0.555, cx + 0.555):
                bc.tube(tag + "TubePin", (x - 0.015, 2.84, tz), (x + 0.015, 2.84, tz), 0.017, cap, 12, 0.1)
        for x in (cx - 0.58, cx + 0.58):
            bc.box(tag + "Socket", (x, 2.865, cz), (0.04, 0.06, 0.12), enamel, 0.008, 0.3)


def triangles(objects):
    total = 0
    depsgraph = bpy.context.evaluated_depsgraph_get()
    for obj in objects:
        if obj.type != "MESH":
            continue
        evaluated = obj.evaluated_get(depsgraph)
        mesh = evaluated.to_mesh()
        mesh.calc_loop_triangles()
        total += len(mesh.loop_triangles)
        evaluated.to_mesh_clear()
    return total


def export(group, filename):
    objects = bc.GROUPS[group]
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    path = OUT / filename
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True, export_apply=True,
                              export_yup=True, export_materials="EXPORT")
    size = path.stat().st_size
    assert size <= 10 * 1024 * 1024, path
    report = {"file": filename, "triangles": triangles(objects), "objects": len(objects), "bytes": size,
              "materials": sorted({s.material.name for o in objects if o.type == "MESH" for s in o.material_slots})}
    print("SEGMENT", filename, report["triangles"], "tris", size, "bytes", flush=True)
    return report


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    OUT.mkdir(parents=True, exist_ok=True)
    shells, scales = L.layout()
    for s in shells:
        for obj_name, a0, b0, a1, b1 in s.pieces:
            surface_piece(s, scales[s.group], obj_name, a0, b0, a1, b1)
    door_frames()
    lamps()
    groups = {"shell": "segment_shell.glb", "frames": "segment_frames.glb", "lamps": "segment_lamps.glb"}
    for variant in L.BAR_SPACING:
        groups[railing(variant)] = f"segment_railing_{variant}.glb"
    report = {"basis": "Floor4 metres (Godot axes); place every file at the Floor4 origin",
              "segment_x": [L.X0, L.X1], "atlas": list(L.ATLAS), "px_per_metre": scales, "files": {}}
    for group, filename in groups.items():
        report["files"][group] = export(group, filename)
    shown = ["shell", "frames", "lamps", "railing_dense"]
    report["pilot_triangles"] = sum(report["files"][g]["triangles"] for g in shown)
    (HERE / "geometry_report.json").write_bytes((json.dumps(report, indent=2) + "\n").encode("utf-8"))
    print("RESULT: floor4 corridor segment export PASS", report["pilot_triangles"], "tris")


if __name__ == "__main__":
    main()
