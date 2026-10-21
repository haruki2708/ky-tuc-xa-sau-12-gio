"""T-222: the upgraded shell of room 407 (walls, floor, ceiling, frames, fixtures, balcony).
Run after make_shell_textures.py and make_shell_masks.py, with Blender 5.2.2:
  blender -b --factory-startup -P art_source/graphics_upgrade/room407_shell/build_shell.py
Exports to game/assets/models/graphics_pilot/room407_shell/ (room-local, place at the room origin):
  architecture.glb  walls and reveals; node names of the corner shell kept (FrontWallWest, BathroomSide...)
  floor.glb         room and bathroom floors, tile skirting
  ceiling.glb       ceiling slab and corner cobwebs
  frames.glb        door linings, architraves, hinges, stone sills, the balcony door's aluminium frame
  fixtures.glb      door leaves (until the Tripo leaves replace them) and the tube lamp
  balcony.glb       exterior of the back wall, balcony floor, dividers, parapet, soffit, drain, tap
Wall, floor, ceiling and balcony surfaces carry two UV sets: UV1 metric (the tiled CC0 scans), UV2 the
group's mask atlas (make_shell_masks.py). Their materials are placeholders named Shell*; Godot gives
them game/rendering/room407_shell.gdshader (Room407Furnish).
"""
import json
import math
import sys
from pathlib import Path

import bpy
from mathutils import Matrix, Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "room407_corner"))
import build_corner as bc  # noqa: E402
import shell_layout as L  # noqa: E402

OUT = bc.ROOT / "game/assets/models/graphics_pilot/room407_shell"
TEX = bc.ROOT / "game/assets/textures/graphics_pilot/room407_shell"
SCANS = HERE / "textures"
# Metres per texture repeat of each shell material (UV1), and a rotation for the diagonal floor scan.
PERIOD = {"wall": 2.0, "floor": 1.9, "bathfloor": 1.8, "skirting": 1.9, "ceiling": 2.0, "exterior": 2.0,
          "balconyfloor": 1.5}
ROTATE = {"floor": 45.0, "skirting": 45.0}
SHELL_COLOURS = {"wall": (0.72, 0.66, 0.52), "floor": (0.75, 0.62, 0.5), "bathfloor": (0.55, 0.42, 0.33),
                 "skirting": (0.75, 0.62, 0.5), "ceiling": (0.8, 0.78, 0.7), "exterior": (0.78, 0.72, 0.55),
                 "balconyfloor": (0.6, 0.48, 0.38)}
SOLID = 0.04  # back faces behind every shell surface: light-tight and solid for shadows
DOORS = OUT / "doors"
BALCONY_OPEN_DEGREES = 172.0  # D-127: open when a chapter starts, against the outside wall


def pbr(name, color, normal=None, arm=None, strength=0.6, alpha=False):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes, links = mat.node_tree.nodes, mat.node_tree.links
    bsdf = nodes["Principled BSDF"]
    tex = nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(str(color), check_existing=True)
    links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    if alpha:
        links.new(tex.outputs["Alpha"], bsdf.inputs["Alpha"])
        mat.surface_render_method = "BLENDED"
    if normal:
        n = nodes.new("ShaderNodeTexImage")
        n.image = bpy.data.images.load(str(normal), check_existing=True)
        n.image.colorspace_settings.name = "Non-Color"
        nm = nodes.new("ShaderNodeNormalMap")
        nm.inputs["Strength"].default_value = strength
        links.new(n.outputs["Color"], nm.inputs["Color"])
        links.new(nm.outputs["Normal"], bsdf.inputs["Normal"])
    if arm:
        a = nodes.new("ShaderNodeTexImage")
        a.image = bpy.data.images.load(str(arm), check_existing=True)
        a.image.colorspace_settings.name = "Non-Color"
        split = nodes.new("ShaderNodeSeparateColor")
        links.new(a.outputs["Color"], split.inputs["Color"])
        links.new(split.outputs["Green"], bsdf.inputs["Roughness"])
        links.new(split.outputs["Blue"], bsdf.inputs["Metallic"])
    return mat


def plain(name, color, roughness, metallic=0.0, emission=None):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1)
        bsdf.inputs["Emission Strength"].default_value = 1.0
    mat.diffuse_color = (*color, 1)
    return mat


SHELL_MATS = {}


def shell_material(kind):
    if kind not in SHELL_MATS:
        SHELL_MATS[kind] = plain("Shell" + kind.capitalize(), SHELL_COLOURS[kind], 0.85)
    return SHELL_MATS[kind]


def surface_piece(s, scale, obj_name, a0, b0, a1, b1, group):
    """One rectangle of a shell surface with UV1 (metric) and UV2 (atlas), and solid back faces."""
    corners = [(a0, b0), (a1, b0), (a1, b1), (a0, b1)]
    verts = [bc.point(s.point(a, b)) for a, b in corners]
    mesh = bpy.data.meshes.new(obj_name)
    mesh.from_pydata(verts, [], [(0, 1, 2, 3)])
    mesh.update()
    # Godot room-local normal of the face must equal the surface normal (Blender (x, -z, y)).
    n = s.normal
    want = Vector((n[0], -n[2], n[1]))
    if mesh.polygons[0].normal.dot(want) < 0:
        mesh.flip_normals()
    uv1 = mesh.uv_layers.new(name="UVMap")
    uv2 = mesh.uv_layers.new(name="Atlas")
    period = PERIOD[s.material]
    rot = math.radians(ROTATE.get(s.material, 0.0))
    seed = sum(ord(c) for c in s.name)
    off = ((seed * 0.37) % 1.0, (seed * 0.61) % 1.0)
    x0, y0 = s.rect[0], s.rect[1]
    for poly in mesh.polygons:
        for li in poly.loop_indices:
            vi = mesh.loops[li].vertex_index
            a, b = corners[vi]
            ra, rb = a * math.cos(rot) - b * math.sin(rot), a * math.sin(rot) + b * math.cos(rot)
            uv1.data[li].uv = (ra / period + off[0], rb / period + off[1])
            uv2.data[li].uv = ((x0 + a * scale) / L.ATLAS, 1.0 - (y0 + b * scale) / L.ATLAS)
    obj = bpy.data.objects.new(obj_name, mesh)
    bpy.context.collection.objects.link(obj)
    thickness = SKIRTING_DEPTH if s.material == "skirting" else SOLID
    solid = obj.modifiers.new("Back faces", "SOLIDIFY")
    solid.thickness, solid.offset, solid.use_rim = thickness, -1.0, True
    solid.use_rim_only = False
    bc.GROUP = group
    return bc.finish(obj, obj_name, shell_material(s.material))


SKIRTING_DEPTH = L.SKIRTING[1]


def build_surfaces(shells, scales):
    group_of = {"walls": "architecture", "floor": "floor", "ceiling": "ceiling", "balcony": "balcony"}
    for s in shells:
        for obj_name, a0, b0, a1, b1 in s.pieces:
            surface_piece(s, scales[s.group], obj_name, a0, b0, a1, b1, group_of[s.group])


def frame_materials():
    green = pbr("Painted door frame | CC0 planks repainted", TEX / "frame_green_color.jpg",
                SCANS / "distressed_painted_planks_normal.jpg", SCANS / "distressed_painted_planks_arm.jpg", 0.6)
    cream = pbr("Cream door frame | CC0 planks repainted", TEX / "frame_cream_color.jpg",
                SCANS / "distressed_painted_planks_normal.jpg", SCANS / "distressed_painted_planks_arm.jpg", 0.5)
    alu = pbr("Oxidised aluminium | drawn", TEX / "aluminium_color.jpg", None, TEX / "aluminium_arm.jpg")
    stone = pbr("Threshold granite | drawn", TEX / "granite_color.jpg", None, TEX / "granite_arm.jpg")
    steel = plain("Hinge steel", (0.32, 0.31, 0.29), 0.45, 1.0)
    return green, cream, alu, stone, steel


def hinge(name, pos, height, mat, axis="z"):
    """A butt hinge knuckle (two leaves meet at a round barrel) standing at pos."""
    x, y, z = pos
    bc.tube(name, (x, y - height / 2, z), (x, y + height / 2, z), 0.007, mat, 12, 0.1)
    bc.tube(name + "Pin", (x, y + height / 2, z), (x, y + height / 2 + 0.008, z), 0.004, mat, 8, 0.1)


def door_frames():
    green, cream, alu, stone, steel = frame_materials()
    bc.GROUP = "frames"
    # Room door: opening x 1.5..2.45, y 0..2.1, wall z 0 (room) .. 0.15 (corridor). The lining stops
    # 0.10 deep: the corridor wall of floor 4 takes over (the game moves this wall 0.105 into the room).
    x0, x1, top = L.ROOM_DOOR
    lin, depth, arch_w, arch_t = 0.02, 0.10, 0.07, 0.018
    parts = [
        ("RoomDoorLiningW", (x0 + lin / 2, top / 2, depth / 2), (lin, top, depth)),
        ("RoomDoorLiningE", (x1 - lin / 2, top / 2, depth / 2), (lin, top, depth)),
        ("RoomDoorLiningTop", ((x0 + x1) / 2, top - lin / 2, depth / 2), (x1 - x0, lin, depth)),
        ("RoomDoorStopW", (x0 + lin + 0.006, top / 2, 0.052), (0.012, top - lin, 0.025)),
        ("RoomDoorStopE", (x1 - lin - 0.006, top / 2, 0.052), (0.012, top - lin, 0.025)),
        ("RoomDoorStopTop", ((x0 + x1) / 2, top - lin - 0.006, 0.052), (x1 - x0 - 2 * lin, 0.012, 0.025)),
        ("RoomArchitraveW", (x0 - arch_w / 2, (top + arch_w) / 2, -arch_t / 2), (arch_w, top + arch_w, arch_t)),
        ("RoomArchitraveE", (x1 + arch_w / 2, (top + arch_w) / 2, -arch_t / 2), (arch_w, top + arch_w, arch_t)),
        ("RoomArchitraveTop", ((x0 + x1) / 2, top + arch_w / 2, -arch_t / 2), (x1 - x0, arch_w, arch_t)),
    ]
    room_frame = [bc.box(n, p, s, green, 0.004, 0.6) for n, p, s in parts]
    for y in (0.25, 1.05, 1.85):  # the leaf hangs on the east jamb (x 2.44)
        hinge("RoomHinge", (x1 - lin - 0.004, y, 0.004), 0.1, steel)
    sill = bc.box("RoomDoorSill", ((x0 + x1) / 2, 0.006, 0.05), (x1 - x0, 0.012, 0.1), stone, 0.003, 0.5)
    # The game moves everything on the door wall 0.105 m into the room: join it under one node.
    join_into("RoomDoorFrame", room_frame + [o for o in bc.GROUPS["frames"] if o.name.startswith("RoomHinge")] + [sill])
    # Bathroom door: opening x 5.35..6.35, y 0..2.2, wall z -3.925 (room) .. -4.075 (bathroom).
    x0, x1, top = L.BATH_DOOR
    zr, zb = L.BATH["wall_room_z"], L.BATH["z0"]
    zc, depth, arch_w = (zr + zb) / 2, zr - zb, L.ARCHITRAVE["bath"]
    parts = [
        ("BathDoorLiningW", (x0 + lin / 2, top / 2, zc), (lin, top, depth)),
        ("BathDoorLiningE", (x1 - lin / 2, top / 2, zc), (lin, top, depth)),
        ("BathDoorLiningTop", ((x0 + x1) / 2, top - lin / 2, zc), (x1 - x0, lin, depth)),
        # The leaf (z -4.02..-3.98) swings into the bathroom: it closes against stops on the room side.
        ("BathDoorStopE", (x1 - lin - 0.006, top / 2, zr - 0.042), (0.012, top - lin, 0.025)),
        ("BathDoorStopTop", ((x0 + x1) / 2, top - lin - 0.006, zr - 0.042), (x1 - x0 - 2 * lin, 0.012, 0.025)),
        ("BathArchitraveW", (x0 - 0.06 / 2, (top + arch_w) / 2, zr + arch_t / 2), (0.06, top + arch_w, arch_t)),
        ("BathArchitraveE", (x1 + arch_w / 2, (top + arch_w) / 2, zr + arch_t / 2), (arch_w, top + arch_w, arch_t)),
        ("BathArchitraveTop", ((x0 + x1 - 0.06 + arch_w) / 2, top + arch_w / 2, zr + arch_t / 2), (x1 - x0 + 0.06 + arch_w, arch_w, arch_t)),
        ("BathArchitraveInE", (x1 + arch_w / 2, (top + arch_w) / 2, zb - 0.008 - arch_t / 2), (arch_w, top + arch_w, arch_t)),
        ("BathArchitraveInTop", ((x0 + x1 + arch_w) / 2, top + arch_w / 2, zb - 0.008 - arch_t / 2), (x1 - x0 + arch_w, arch_w, arch_t)),
    ]
    for n, p, s in parts:
        bc.box(n, p, s, cream, 0.004, 0.6)
    for y in (0.25, 1.95):  # hinges on the west jamb (bathroom_door.tscn pivot x 5.35)
        hinge("BathHinge", (x0 + lin + 0.004, y, zb + 0.004), 0.1, steel)
    bc.box("BathDoorSill", ((x0 + x1) / 2, 0.008, zc), (x1 - x0, 0.016, depth), stone, 0.003, 0.5)
    # Balcony door: aluminium frame flush with the outside face of the wall, so the leaf (out onto the
    # balcony, hinged on the east jamb) can swing right round and stand open against the wall (D-127).
    x0, x1, top = L.BALCONY_DOOR
    face, prof = 0.04, 0.06
    zc = L.WALL_BACK_OUT + prof / 2
    for n, p, s in (("BalconyFrameW", (x0 + face / 2, top / 2, zc), (face, top, prof)),
                    ("BalconyFrameE", (x1 - face / 2, top / 2, zc), (face, top, prof)),
                    ("BalconyFrameTop", ((x0 + x1) / 2, top - face / 2, zc), (x1 - x0, face, prof)),
                    ("BalconyFrameSill", ((x0 + x1) / 2, 0.01, zc), (x1 - x0, 0.02, prof))):
        bc.box(n, p, s, alu, 0.003, 0.5)
    for y in (0.3, 1.15, 2.0):
        hinge("BalconyHinge", (x1 - face + 0.004, y, L.WALL_BACK_OUT - 0.006), 0.08, steel)
    inner = zc + prof / 2  # room face of the frame
    bc.box("BalconySillIn", ((x0 + x1) / 2, 0.008, (L.Z_BACK + inner) / 2), (x1 - x0, 0.016, L.Z_BACK - inner), stone, 0.003, 0.5)
    bc.box("BalconySillOut", ((x0 + x1) / 2, 0.012, L.WALL_BACK_OUT - 0.03), (x1 - x0 + 0.04, 0.024, 0.06), stone, 0.003, 0.5)


def join_into(name, objects):
    group = bc.GROUPS["frames"]
    for obj in objects[1:]:  # they stop existing once joined into objects[0]
        group.remove(obj)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    for obj in objects:
        for mod in list(obj.modifiers):
            bpy.context.view_layer.objects.active = obj
            bpy.ops.object.modifier_apply(modifier=mod.name)
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.join()
    joined = bpy.context.object
    joined.name = name
    return joined


def import_glb(path, name):
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=str(path))
    added = [o for o in bpy.data.objects if o not in before]
    meshes = [o for o in added if o.type == "MESH"]
    for o in added:
        if o.type != "MESH":
            bpy.data.objects.remove(o, do_unlink=True)
    obj = meshes[0]
    obj.parent = None
    obj.name = name
    obj.location = (0, 0, 0)
    obj.rotation_euler = (0, 0, 0)
    bc.GROUPS.setdefault(bc.GROUP, []).append(obj)
    return obj


def place_lever(lever, centre, out, bar, parent):
    """A copy of the lever on a leaf face: rose at centre, standing out along out, bar toward the hinges
    (lever space X bar, Y = out x bar, Z out: DoorHandles.fit)."""
    x, z = Vector(bar), Vector(out)
    y = z.cross(x)
    godot = Matrix((x, y, z)).transposed()  # columns: the lever's axes in room space
    swap = Matrix(((1, 0, 0), (0, 0, -1), (0, 1, 0)))  # Godot -> Blender axes
    copy = lever.copy()
    bpy.context.collection.objects.link(copy)
    copy.matrix_world = Matrix.Translation(Vector(bc.point(centre))) @ (swap @ godot @ swap.inverted()).to_4x4()
    bpy.context.view_layer.update()
    keep = copy.matrix_world.copy()
    copy.parent = parent
    copy.matrix_world = keep
    copy.name = "Lever"
    bc.GROUPS[bc.GROUP].append(copy)
    return copy


def fixtures():
    bc.GROUP = "fixtures"
    # Leaves where the corner shell had them: floor4.gd hangs RoomDoor on Door407, room407.gd carries
    # BathroomDoor onto the bathroom door's pivot.
    # Tripo leaves (prep_doors.py + ../tripo/bake_prop.py), each with a Tripo lever on both faces at the
    # latch side, the bar toward the hinges (DoorHandles' layout; static until T-220 reaches the game).
    # floor4.gd moves the room door's levers onto Door407's HandlePivot (the corridor rattle).
    lever = import_glb(DOORS / "door_lever.glb", "DoorLever")
    room = import_glb(DOORS / "door_room.glb", "RoomDoor")
    room.location = bc.point((1.995, 0.0, 0.02))
    for side in (-1, 1):  # room face z 0 (out -z), corridor face z 0.04
        place_lever(lever, (1.615, 1.05, 0.02 + side * 0.02), (0, 0, side), (1, 0, 0), room)
    bath = import_glb(DOORS / "door_bathroom.glb", "BathroomDoor")
    bath.location = bc.point((5.85, 0.0, -4.0))
    for side in (1, -1):
        place_lever(lever, (6.275, 1.0, -4.0 + side * 0.02), (0, 0, side), (-1, 0, 0), bath)
    # Balcony leaf: closed it fills the frame (x 2.34..3.26, z -7.025..-7.075); the pivot sits on the
    # hinge line (east jamb, outside face) and turns it 172 degrees out against the wall.
    pivot = bpy.data.objects.new("BalconyDoorPivot", None)
    bpy.context.collection.objects.link(pivot)
    pivot.location = bc.point((3.262, 0.0, L.WALL_BACK_OUT))
    bc.GROUPS["fixtures"].append(pivot)
    leaf = import_glb(DOORS / "door_balcony.glb", "BalconyDoor")
    leaf.location = bc.point((2.8, 0.02, L.WALL_BACK_OUT + 0.025))
    leaf.rotation_euler.z = math.pi  # Tripo's hinge knuckles to the east edge
    for side in (1, -1):
        place_lever(lever, (2.405, 1.0, L.WALL_BACK_OUT + 0.025 + side * 0.025), (0, 0, side), (1, 0, 0), leaf)
    bpy.context.view_layer.update()
    keep = leaf.matrix_world.copy()
    leaf.parent = pivot
    leaf.matrix_world = keep
    pivot.rotation_euler.z = math.radians(-BALCONY_OPEN_DEGREES)
    bc.GROUPS["fixtures"].remove(lever)  # the template; its copies share its mesh
    bpy.data.objects.remove(lever, do_unlink=True)
    # Tube lamp: a white enamelled batten (the old one yellowed, specks of dead insects) with two tubes.
    enamel = plain("Yellowed enamel batten", (0.78, 0.75, 0.64), 0.42)
    glass = plain("Tube glass", (0.92, 0.94, 0.9), 0.25)
    cap = plain("Tube cap", (0.55, 0.55, 0.52), 0.4, 1.0)
    cx, cy, cz, length = 2.0, 2.9, -1.2, 1.24
    bc.box("TubeHousing", (cx, cy + 0.07, cz), (length, 0.06, 0.14), enamel, 0.012, 0.5)
    for side in (-1, 1):
        bc.box("TubeReflector", (cx, cy + 0.035, cz + side * 0.075), (length - 0.02, 0.07, 0.006), enamel, 0.002, 0.5)
        bc.box("TubeEndCap", (cx + side * (length / 2 - 0.02), cy + 0.03, cz), (0.035, 0.08, 0.15), enamel, 0.008, 0.3)
    for z in (cz - 0.035, cz + 0.035):
        bc.tube("FluorescentTube", (cx - 0.54, 2.84, z), (cx + 0.54, 2.84, z), 0.016, glass, 16, 0.5)
        for x in (cx - 0.555, cx + 0.555):
            bc.tube("TubePin", (x - 0.015, 2.84, z), (x + 0.015, 2.84, z), 0.017, cap, 12, 0.1)
    for x in (cx - 0.58, cx + 0.58):
        bc.box("TubeSocket", (x, 2.865, cz), (0.04, 0.06, 0.12), enamel, 0.008, 0.3)


def cobwebs():
    bc.GROUP = "ceiling"
    web = pbr("Cobweb | drawn", TEX / "cobweb.png", alpha=True)
    # Not on the door wall: the game moves it 0.105 m into the room.
    corners = [((0.1, -6.925), (1, 0), (0, 1), 0.42), ((5.225, -6.925), (-1, 0), (0, 1), 0.35),
               ((7.9, -6.925), (-1, 0), (0, 1), 0.45), ((5.375, -4.075), (1, 0), (0, -1), 0.3)]
    for k, ((cx, cz), d1, d2, size) in enumerate(corners):
        c = Vector((cx, L.CEILING - 0.002, cz))
        e1, e2 = Vector((d1[0], 0, d1[1])), Vector((d2[0], 0, d2[1]))
        pts = [c + e1 * 0.004 + e2 * 0.004, c + e1 * size, c + (e1 + e2) * size * 0.62 + Vector((0, -size * 0.45, 0)),
               c + e2 * size]
        mesh = bpy.data.meshes.new("Cobweb")
        mesh.from_pydata([bc.point(tuple(p)) for p in pts], [], [(0, 1, 2, 3)])
        uv = mesh.uv_layers.new(name="UVMap")
        for li, coord in zip(range(4), ((0, 1), (1, 1), (1, 0), (0, 0))):
            uv.data[li].uv = coord
        obj = bpy.data.objects.new(f"Cobweb{k}", mesh)
        bpy.context.collection.objects.link(obj)
        bc.finish(obj, f"Cobweb{k}", web)


def balcony_extras():
    bc.GROUP = "balcony"
    ext = shell_material("exterior")
    tile = plain("Parapet coping", (0.36, 0.35, 0.32), 0.85)
    steel = plain("Galvanised pipe", (0.5, 0.5, 0.48), 0.5, 1.0)
    brass = plain("Old brass tap", (0.55, 0.43, 0.22), 0.35, 1.0)
    dark = plain("Drain hole", (0.02, 0.02, 0.02), 0.9)
    b = L.BALCONY
    # Solid parts the surfaces do not cover: divider ends and tops, parapet back and coping.
    # 1 mm behind the mask-painted faces so the two never share a plane.
    for x in (0.0, 5.2):
        bc.box("DividerBody", (x, b["divider_top"] / 2, (b["z0"] + b["z1"] - 0.1) / 2),
               (0.118, b["divider_top"], b["z0"] - b["z1"] + 0.1), ext, 0.004, 2.0)
    bc.box("ParapetBody", (2.6, (b["parapet_top"] - 0.05) / 2, -8.5), (5.2, b["parapet_top"] - 0.05, 0.098), ext, 0.004, 2.0)
    bc.box("ParapetCoping", (2.6, b["parapet_top"] - 0.025, -8.5), (5.32, 0.05, 0.16), tile, 0.006, 0.6)
    # Slab edge under the balcony and above it (floor 5's balcony floor).
    bc.box("SlabEdge", (2.6, -0.1, -8.56), (5.32, 0.2, 0.04), ext, 0.004, 2.0)
    bc.box("SlabAbove", (2.6, L.CEILING + 0.101, -7.82), (5.32, 0.2, 1.56), ext, 0.004, 2.0)
    # Floor drain in the west corner, tap on the east divider for washing.
    bc.box("BalconyDrain", (0.25, 0.002, -8.33), (0.1, 0.004, 0.1), steel, 0.002, 0.3)
    for i in range(4):
        bc.box("BalconyDrainSlot", (0.22 + i * 0.02, 0.0042, -8.33), (0.008, 0.001, 0.07), dark, 0, 0.3)
    bc.tube("TapPipe", (5.13, 0.0, -7.25), (5.13, 0.62, -7.25), 0.011, steel, 10, 0.3)
    bc.tube("TapBody", (5.13, 0.62, -7.25), (5.06, 0.62, -7.25), 0.013, brass, 10, 0.2)
    bc.tube("TapSpout", (5.06, 0.62, -7.25), (5.04, 0.57, -7.25), 0.008, brass, 8, 0.2)
    bc.box("TapHandle", (5.07, 0.66, -7.25), (0.012, 0.03, 0.05), brass, 0.003, 0.2)


def export(name):
    objects = bc.GROUPS[name]
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objects[0]
    path = OUT / (name + ".glb")
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True, export_apply=True,
                              export_image_format="JPEG", export_jpeg_quality=90, export_yup=True)
    tris = 0
    for obj in objects:
        if obj.type != "MESH":
            continue
        evaluated = obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
        mesh = evaluated.to_mesh()
        mesh.calc_loop_triangles()
        tris += len(mesh.loop_triangles)
        evaluated.to_mesh_clear()
    assert path.stat().st_size <= 10 * 1024 * 1024, path
    print("SHELL", name, tris, "tris", path.stat().st_size, "bytes", flush=True)
    return {"triangles": tris, "objects": len(objects), "bytes": path.stat().st_size}


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    OUT.mkdir(parents=True, exist_ok=True)
    shells, scales = L.layout()
    build_surfaces(shells, scales)
    door_frames()
    fixtures()
    cobwebs()
    balcony_extras()
    report = {"basis": "Godot room-local metres; place at the room origin", "px_per_metre": scales, "groups": {}}
    for name in ("architecture", "floor", "ceiling", "frames", "fixtures", "balcony"):
        report["groups"][name] = export(name)
    report["triangles"] = sum(g["triangles"] for g in report["groups"].values())
    (HERE / "geometry_report.json").write_bytes((json.dumps(report, indent=2) + "\n").encode("utf-8"))
    print("RESULT: room407 shell export PASS", report["triangles"], "tris")


if __name__ == "__main__":
    main()
