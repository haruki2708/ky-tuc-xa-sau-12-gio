"""T-235: the whole floor-4 corridor in room 407's style (T-233 pilot, D-142 option A; approved D-144).
Run after make_corridor_masks.py, with Blender 5.2.2 (from the repository root):
  blender -b --factory-startup -P art_source/graphics_upgrade/floor4_corridor/build_corridor.py
Exports to game/assets/models/graphics_pilot/floor4_corridor/, in Floor4 metres (place at the Floor4 origin):
  corridor_shell.glb          one mesh per bay: corridor face of the room wall, floor, skirting, ceiling, slab edges
  corridor_ends.glb           plaster end walls on the WestEnd / EastEnd caps (hung under the caps at runtime)
  corridor_frames.glb         linings, architraves and granite sills of doors 401..408 and the old 408 doorway;
                              stops and hinges where the RoomDoor leaves swing out; the washroom's sill
  corridor_railing.glb        A1 painted steel railing (balusters every 12.5 cm), one mesh per bay
  corridor_lamps.glb          room 407's enamel tube batten under each of the nine corridor lights
  corridor_plates_alu.glb     room plates, default: anodised aluminium, raised black digits
  corridor_plates_enamel.glb  room plates, option: blue enamel, white printed digits
  corridor_seal_board.glb     option for the old 408 doorway: boarded over with planks
Every material is a placeholder named Corr*: corridor_g5_pilot.gd gives the shell room 407's shell shader with
this corridor's mask atlases (make_corridor_masks.py) and the rest the CC0 scans already in the game, so no
texture is copied into these files. Shell faces carry UV1 in world metres (tiles line up across bays) and UV2 on
their group's mask atlas. The digits are drawn here from strokes (no font file).
"""
import json
import math
import sys
from pathlib import Path

import bpy
import bmesh

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "room407_corner"))
import build_corner as bc  # noqa: E402
import corridor_layout as L  # noqa: E402

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
    "CorrPlateAlu": ((0.62, 0.63, 0.62), 0.4, 1.0), "CorrPlateInk": ((0.03, 0.03, 0.03), 0.55, 0.0),
    "CorrPlateEnamel": ((0.06, 0.16, 0.38), 0.22, 0.0), "CorrPlatePrint": ((0.86, 0.86, 0.82), 0.3, 0.0),
    "CorrScrew": ((0.5, 0.5, 0.48), 0.4, 1.0), "CorrBoard": ((0.45, 0.36, 0.27), 0.8, 0.0),
}
MATS = {}
PARTS = {}  # GLB part -> joined objects


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


# ---------------------------------------------------------------- helpers

def created(build):
    """Run build() and return the objects it added to the scene."""
    before = set(bpy.context.scene.objects)
    build()
    return [o for o in bpy.context.scene.objects if o not in before]


def bake(obj):
    """Apply every modifier (bevels, weighted normals) so objects can be joined without losing them."""
    if obj.type != "MESH" or not obj.modifiers:
        return
    depsgraph = bpy.context.evaluated_depsgraph_get()
    mesh = bpy.data.meshes.new_from_object(obj.evaluated_get(depsgraph), preserve_all_data_layers=True,
                                           depsgraph=depsgraph)
    obj.modifiers.clear()
    obj.data = mesh


def join(objects, name, part):
    """One mesh per bay, door, lamp or plate: fewer draw calls over 44 m."""
    for obj in objects:
        bake(obj)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    if len(objects) > 1:
        bpy.ops.object.join()
    obj = bpy.context.view_layer.objects.active
    obj.name = name
    obj.data.name = name
    PARTS.setdefault(part, []).append(obj)
    return obj


def box(name, lo, hi, material, bevel=0.003, period=0.6):
    """Axis-aligned box between two Floor4 corners."""
    centre = tuple((lo[i] + hi[i]) / 2 for i in range(3))
    size = tuple(hi[i] - lo[i] for i in range(3))
    return bc.box(name, centre, size, mat(material), bevel, period)


def mesh_object(name, verts, faces, face_mats, materials, uv_layers=None):
    """Mesh from Floor4-space vertices; uv_layers: {layer: per-loop uvs in face order}."""
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata([bc.point(v) for v in verts], [], faces)
    mesh.update()
    for m in materials:
        mesh.materials.append(mat(m))
    for poly, index in zip(mesh.polygons, face_mats):
        poly.material_index = index
        poly.use_smooth = False
    for layer, uvs in (uv_layers or {}).items():
        data = mesh.uv_layers.new(name=layer).data
        for li, uv in enumerate(uvs):
            data[li].uv = uv
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    return obj


# ---------------------------------------------------------------- shell

def shell(shells, scales):
    """Every face of a bay (wall, floor, skirting, ceiling, slab edges) in one mesh with UV1 and UV2."""
    by_obj = {}
    for f in shells:
        by_obj.setdefault(f.obj, []).append(f)
    for obj_name, faces in by_obj.items():
        verts, polys, mats, uv1, uv2 = [], [], [], [], []
        materials = sorted({"Corr" + f.material.capitalize() for f in faces})
        for f in faces:
            corners = [(f.a0, f.b0), (f.a1, f.b0), (f.a1, f.b1), (f.a0, f.b1)]
            points = [f.point(a, b) for a, b in corners]
            base = len(verts)
            verts += points
            polys.append((base, base + 1, base + 2, base + 3))
            mats.append(materials.index("Corr" + f.material.capitalize()))
            period = PERIOD[f.material]
            size = L.ATLAS[f.group]
            for (a, b), p in zip(corners, points):
                ua = sum(p[i] * f.u[i] for i in range(3)) / period
                vb = sum(p[i] * f.v[i] for i in range(3)) / period
                if f.material == "skirting" and f.surface.endswith("Skirting"):
                    vb = SKIRTING_V + (b - f.b0) / period
                uv1.append((ua, vb))
                if f.painted:
                    x0, y0 = f.rect[0], f.rect[1]
                    s = scales[f.group]
                    uv2.append(((x0 + (a - f.a0) * s) / size[0], 1.0 - (y0 + (b - f.b0) * s) / size[1]))
                else:
                    n = L.NEUTRAL
                    uv2.append(((n[0] + n[2] / 2) / size[0], 1.0 - (n[1] + n[3] / 2) / size[1]))
        obj = mesh_object(obj_name, verts, polys, mats, materials, {"UVMap": uv1, "Atlas": uv2})
        # Check the winding: every face must look the way its surface says (u x v).
        for poly, f in zip(obj.data.polygons, faces):
            n = f.normal
            want = bc.point(n)
            assert poly.normal.dot(want) > 0.99, (obj_name, f.surface, tuple(poly.normal), want)
        PARTS.setdefault(faces[0].part, []).append(obj)


# ---------------------------------------------------------------- frames

def hinge(name, x, y, z):
    steel = mat("CorrHinge")
    bc.tube(name, (x, y - 0.05, z), (x, y + 0.05, z), 0.007, steel, 12, 0.1)
    bc.tube(name + "Pin", (x, y + 0.05, z), (x, y + 0.058, z), 0.004, steel, 8, 0.1)


def door_frame(d):
    face, lin = L.WALL_FACE, L.LIN
    hx0, hx1, htop = d.hole
    n = d.name
    # Linings fill the reveal from the room's frame (407), the room face or the infill to the corridor face.
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


def frames():
    for d in L.DOORS:
        join(created(lambda d=d: door_frame(d)), "Frame" + d.room, "frames")
    w0, w1, _ = L.WASHROOM
    join(created(lambda: box("WashroomSill", (w0, 0.0, L.WALL_BACK), (w1, L.SILL, L.WALL_FACE + 0.006),
                             "CorrGranite", 0.003, 0.5)), "SillWashroom", "frames")


# ---------------------------------------------------------------- railing

def railing():
    """A1 (D-144): square posts every 2 m, a 50 mm handrail pipe inside the old top rail's collider, a flat
    bottom rail inside the low one, balusters every 12.5 cm."""
    z = L.RAIL_Z
    steel = mat("CorrRailSteel")
    count = int(round((L.X1 - L.X0) / L.BAR_SPACING))
    bars = [L.X0 + (i + 0.5) * L.BAR_SPACING for i in range(count)]
    bars = [x for x in bars if all(abs(x - p) >= 0.04 for p in L.POSTS)]
    for b0, b1, bay in L.BAYS:
        def build(b0=b0, b1=b1):
            for k, x in enumerate(p for p in L.POSTS if b0 <= p < b1 or (b1 == L.X1 and p == L.POSTS[-1])):
                box(f"Post{k}", (x - 0.025, 0.0, z - 0.025), (x + 0.025, 1.05, z + 0.025), "CorrRailSteel", 0.003, 0.5)
                box(f"PostPlate{k}", (x - 0.06, 0.0, z - 0.06), (x + 0.06, 0.006, z + 0.06), "CorrRailSteel", 0.001, 0.5)
            bc.tube("Handrail", (b0, 1.07, z), (b1, 1.07, z), 0.025, steel, 16, 0.5)
            box("BottomRail", (b0, 0.16, z - 0.015), (b1, 0.20, z + 0.015), "CorrRailSteel", 0.002, 0.5)
            for k, x in enumerate(x for x in bars if b0 <= x < b1):
                box(f"Baluster{k}", (x - 0.008, 0.20, z - 0.008), (x + 0.008, 1.046, z + 0.008), "CorrRailSteel", 0.0, 0.5)
        join(created(build), "Rail" + bay, "railing")


# ---------------------------------------------------------------- lamps

def lamp(cx, cz):
    """Room 407's tube batten (build_shell.py fixtures) under a corridor light; the light does not move."""
    enamel, glass, cap = mat("CorrEnamel"), mat("CorrTubeGlass"), mat("CorrTubeCap")
    cy, length = 2.9, 1.24
    bc.box("Housing", (cx, cy + 0.07, cz), (length, 0.06, 0.14), enamel, 0.012, 0.5)
    for side in (-1, 1):
        bc.box("Reflector", (cx, cy + 0.035, cz + side * 0.075), (length - 0.02, 0.07, 0.006), enamel, 0.002, 0.5)
        bc.box("EndCap", (cx + side * (length / 2 - 0.02), cy + 0.03, cz), (0.035, 0.08, 0.15), enamel, 0.008, 0.3)
    for tz in (cz - 0.035, cz + 0.035):
        bc.tube("FluorescentTube", (cx - 0.54, 2.84, tz), (cx + 0.54, 2.84, tz), 0.016, glass, 16, 0.5)
        for x in (cx - 0.555, cx + 0.555):
            bc.tube("TubePin", (x - 0.015, 2.84, tz), (x + 0.015, 2.84, tz), 0.017, cap, 12, 0.1)
    for x in (cx - 0.58, cx + 0.58):
        bc.box("Socket", (x, 2.865, cz), (0.04, 0.06, 0.12), enamel, 0.008, 0.3)


def lamps():
    for light, x in L.LIGHTS:
        join(created(lambda x=x: lamp(x, L.LIGHT_Z)), "Lamp_" + light, "lamps")


# ---------------------------------------------------------------- room plates

def _arc(cx, cy, rx, ry, a0, a1, n):
    return [(cx + rx * math.cos(math.radians(a0 + (a1 - a0) * k / (n - 1))),
             cy + ry * math.sin(math.radians(a0 + (a1 - a0) * k / (n - 1)))) for k in range(n)]


def _bezier(p0, p1, p2, n):
    return [((1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0],
             (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]) for t in (k / (n - 1) for k in range(n))]


def _six():
    return [_arc(0.28, 0.29, 0.27, 0.29, 0, 360, 21), _bezier((0.01, 0.31), (0.03, 0.9), (0.46, 0.99), 8)]


# Plain sans-serif digits drawn as centre-line strokes in a 0.56 x 1 cell (y up); our own, no font file.
GLYPHS = {
    "0": [_arc(0.28, 0.5, 0.27, 0.5, 90, 450, 25)],
    "1": [[(0.08, 0.78), (0.32, 1.0), (0.32, 0.0)]],
    "2": [_arc(0.28, 0.72, 0.26, 0.27, 165, -35, 10) + [(0.02, 0.0), (0.56, 0.0)]],
    "3": [_arc(0.27, 0.76, 0.24, 0.24, 150, -90, 10) + _arc(0.27, 0.27, 0.28, 0.27, 90, -150, 12)[1:]],
    "4": [[(0.42, 0.0), (0.42, 1.0), (0.0, 0.32), (0.58, 0.32)]],
    "5": [[(0.52, 1.0), (0.12, 1.0), (0.09, 0.56)] + _arc(0.28, 0.32, 0.29, 0.29, 128, -150, 14)[1:]],
    "6": _six(),
    "7": [[(0.0, 1.0), (0.56, 1.0), (0.18, 0.0)]],
    "8": [_arc(0.28, 0.76, 0.22, 0.23, -90, 270, 19), _arc(0.28, 0.27, 0.27, 0.27, 90, 450, 21)],
    "9": [[(0.56 - x, 1.0 - y) for x, y in stroke] for stroke in _six()],
}
GLYPH_W = 0.56


def strokes_for(text, cx, cy, height, gap):
    advance = (GLYPH_W + gap) * height
    left = cx - (advance * len(text) - gap * height) / 2
    out = []
    for k, ch in enumerate(text):
        for stroke in GLYPHS[ch]:
            out.append([(left + k * advance + x * height, cy + (y - 0.5) * height) for x, y in stroke])
    return out


def ribbon(name, strokes, width, z, depth, material):
    """Strokes in the plane z (facing the corridor) as ribbons; raised into prisms when depth > 0."""
    bm = bmesh.new()
    for pts in strokes:
        closed = math.dist(pts[0], pts[-1]) < 1e-6
        if closed:
            pts = pts[:-1]
        n = len(pts)
        edges = []
        for i in range(n):
            if closed:
                prev, nxt = pts[i - 1], pts[(i + 1) % n]
            else:
                prev, nxt = pts[max(i - 1, 0)], pts[min(i + 1, n - 1)]
            p = pts[i]
            d_in = (p[0] - prev[0], p[1] - prev[1]) if prev != p else (nxt[0] - p[0], nxt[1] - p[1])
            d_out = (nxt[0] - p[0], nxt[1] - p[1]) if nxt != p else d_in
            li, lo = math.hypot(*d_in) or 1, math.hypot(*d_out) or 1
            t = (d_in[0] / li + d_out[0] / lo, d_in[1] / li + d_out[1] / lo)
            lt = math.hypot(*t) or 1
            t = (t[0] / lt, t[1] / lt)
            normal = (-t[1], t[0])
            seg_normal = (-d_out[1] / lo, d_out[0] / lo)
            miter = width / 2 / max(normal[0] * seg_normal[0] + normal[1] * seg_normal[1], 0.4)
            edges.append(((p[0] + normal[0] * miter, p[1] + normal[1] * miter),
                          (p[0] - normal[0] * miter, p[1] - normal[1] * miter)))
        top = [(bm.verts.new(bc.point((l[0], l[1], z + depth))), bm.verts.new(bc.point((r[0], r[1], z + depth))))
               for l, r in edges]
        bottom = [(bm.verts.new(bc.point((l[0], l[1], z))), bm.verts.new(bc.point((r[0], r[1], z))))
                  for l, r in edges] if depth > 0 else None
        segments = range(n) if closed else range(n - 1)
        for i in segments:
            j = (i + 1) % n
            bm.faces.new((top[i][1], top[j][1], top[j][0], top[i][0]))
            if bottom:
                bm.faces.new((bottom[i][0], bottom[j][0], bottom[j][1], bottom[i][1]))
                bm.faces.new((top[i][0], top[j][0], bottom[j][0], bottom[i][0]))
                bm.faces.new((bottom[i][1], bottom[j][1], top[j][1], top[i][1]))
        if bottom and not closed:
            bm.faces.new((top[0][0], bottom[0][0], bottom[0][1], top[0][1]))
            bm.faces.new((top[-1][1], bottom[-1][1], bottom[-1][0], top[-1][0]))
    if depth > 0:
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh)
    bm.free()
    mesh.materials.append(mat(material))
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    return obj


def screw(name, x, y, z, radius=0.0035, material="CorrScrew"):
    bc.tube(name, (x, y, z), (x, y, z + 0.0018), radius, mat(material), 8, 0.05)


def plate_alu(room, x):
    """Anodised aluminium, a stamped rim and raised digits painted black, two screws (default)."""
    y, face = L.PLATE_Y, L.WALL_FACE
    w, h, t = 0.30, 0.12, 0.0025
    box("Plate", (x - w / 2, y - h / 2, face), (x + w / 2, y + h / 2, face + t), "CorrPlateAlu", 0.0015, 0.25)
    rim = [(x - w / 2 + 0.008, y - h / 2 + 0.008), (x + w / 2 - 0.008, y - h / 2 + 0.008),
           (x + w / 2 - 0.008, y + h / 2 - 0.008), (x - w / 2 + 0.008, y + h / 2 - 0.008), (x - w / 2 + 0.008, y - h / 2 + 0.008)]
    ribbon("Rim", [rim], 0.0025, face + t, 0.0007, "CorrPlateAlu")
    ribbon("Digits", strokes_for(room, x, y, 0.07, 0.3), 0.0095, face + t, 0.0012, "CorrPlateInk")
    for sx in (-1, 1):
        screw("Screw", x + sx * (w / 2 - 0.022), y, face + t)


def plate_enamel(room, x):
    """Blue enamel with a white border and white printed digits, two screws (option)."""
    y, face = L.PLATE_Y, L.WALL_FACE
    w, h, t = 0.30, 0.14, 0.003
    box("Plate", (x - w / 2, y - h / 2, face), (x + w / 2, y + h / 2, face + t), "CorrPlateEnamel", 0.004, 0.3)
    lift = face + t + 0.0008
    border = [(x - w / 2 + 0.011, y - h / 2 + 0.011), (x + w / 2 - 0.011, y - h / 2 + 0.011),
              (x + w / 2 - 0.011, y + h / 2 - 0.011), (x - w / 2 + 0.011, y + h / 2 - 0.011), (x - w / 2 + 0.011, y - h / 2 + 0.011)]
    ribbon("Border", [border], 0.004, lift, 0.0, "CorrPlatePrint")
    ribbon("Digits", strokes_for(room, x, y, 0.08, 0.3), 0.012, lift, 0.0, "CorrPlatePrint")
    for sx in (-1, 1):
        screw("Screw", x + sx * (w / 2 - 0.02), y, face + t, 0.004, "CorrPlatePrint")


def plates():
    for room, x in L.PLATES.items():
        join(created(lambda room=room, x=x: plate_alu(room, x)), "PlateAlu_" + room, "plates_alu")
        join(created(lambda room=room, x=x: plate_enamel(room, x)), "PlateEnamel_" + room, "plates_enamel")


# ---------------------------------------------------------------- the old 408 doorway, option

def seal_board():
    """Option: old planks screwed across the walled-up doorway, inside its frame."""
    d = next(d for d in L.DOORS if d.swing == "sealed")
    z0 = L.SEAL_Z
    heights = [0.41, 0.43, 0.40, 0.42, 0.37]  # five planks, not quite even
    gap = (d.top - L.SILL - sum(heights)) / (len(heights) + 1)

    def build():
        y = L.SILL + gap
        for k, ph in enumerate(heights):
            inset = 0.004 + 0.006 * (k % 2)
            depth = 0.013 + 0.002 * ((k * 7) % 3)  # screw heads stay inside the corridor face
            box(f"Plank{k}", (d.x0 + inset, y, z0), (d.x1 - inset, y + ph, z0 + depth), "CorrBoard", 0.003, 0.55)
            for sx in (d.x0 + 0.045, d.x1 - 0.045):
                for sy in (y + 0.09, y + ph - 0.09):
                    screw("Screw", sx, sy, z0 + depth)
            y += ph + gap
    join(created(build), "SealBoard", "seal_board")


# ---------------------------------------------------------------- export

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


def export(part, filename):
    objects = PARTS[part]
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
    print("CORRIDOR", filename, report["triangles"], "tris", len(objects), "objects", size, "bytes", flush=True)
    return report


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    OUT.mkdir(parents=True, exist_ok=True)
    shells, scales = L.layout()
    shell(shells, scales)
    frames()
    lamps()
    railing()
    plates()
    seal_board()
    report = {"basis": "Floor4 metres (Godot axes); place every file at the Floor4 origin",
              "corridor_x": [L.X0, L.X1], "atlas": {g: list(s) for g, s in L.ATLAS.items()},
              "px_per_metre": scales, "files": {}}
    for part in ("shell", "ends", "frames", "railing", "lamps", "plates_alu", "plates_enamel", "seal_board"):
        report["files"][part] = export(part, f"corridor_{part}.glb")
    # What the pilot shows by default (plates: aluminium; old 408 doorway: walled up, no planks).
    shown = ["shell", "ends", "frames", "railing", "lamps", "plates_alu"]
    report["default_triangles"] = sum(report["files"][g]["triangles"] for g in shown)
    report["materials"] = sorted({m for f in report["files"].values() for m in f["materials"]})
    (HERE / "geometry_report.json").write_bytes((json.dumps(report, indent=2) + "\n").encode("utf-8"))
    print("RESULT: floor4 corridor export PASS", report["default_triangles"], "tris")


if __name__ == "__main__":
    main()
