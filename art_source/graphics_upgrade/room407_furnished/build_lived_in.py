"""Blender pieces of the lived-in pass of room 407 (D-100); Tripo batch 3 brings the loose props.
Run after make_lived_in_textures.py, with Blender 5.2.2: blender -b --factory-startup -P <this file>.
Exports to game/assets/models/graphics_pilot/room407_furnished/:
  floor_mat.glb        sedge sleeping mat (chieu) on the floor, 1.4 x 1.8 m, cloth binding, curled corner;
                       object-local, centred, bottom at y=0
  bath_tiles.glb       old white wall tiles (CC0) to 1.8 m on the four bathroom walls + stainless
                       floor drain; room-local (place at the room origin)
  conduits.glb         white PVC conduits with saddles from the light switch and two wall sockets to
                       the ceiling; room-local
  calendar.glb, timetable.glb, sticky_notes.glb
                       wall paper items; object-local, back on the wall plane z=0, facing -Z
  curtain_balcony.glb  curtain on a rod over the balcony doorway, drawn back to the west jamb so the
                       doorway stays clear (ch1/ch2 walk onto the balcony); room-local
Coordinates are room-local Godot metres (shell of room407_corner/build_corner.py).
"""
import math
import sys
from pathlib import Path

import bmesh
import bpy
from mathutils import Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "room407_corner"))
import build_corner as bc  # noqa: E402  (helpers and CC0 materials of the corner pilot)

OUT = bc.ROOT / "game/assets/models/graphics_pilot/room407_furnished"
PAPER = HERE / "paper"
CEILING = 3.0
BATH = {"x0": 5.375, "x1": 7.9, "z0": -4.075, "z1": -6.925, "door": (5.35, 6.35)}
TILE_TOP = 1.8


def plain(name, color, roughness, metallic=0.0):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    return mat


def printed(name, image_path, roughness=0.85):
    """Paper or cloth whose colour is one image; flat shading detail comes from the print."""
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    nodes, links = mat.node_tree.nodes, mat.node_tree.links
    tex = nodes.new("ShaderNodeTexImage")
    tex.image = bpy.data.images.load(str(image_path), check_existing=True)
    links.new(tex.outputs["Color"], nodes["Principled BSDF"].inputs["Base Color"])
    nodes["Principled BSDF"].inputs["Roughness"].default_value = roughness
    return mat


def sheet(name, width, height, mat, cuts=(1, 1), bend=None):
    """Upright sheet on the z=0 wall plane, facing -Z, UV 0..1; bend(u, v) -> offset towards -Z."""
    bc.GROUP = name
    bpy.ops.mesh.primitive_grid_add(x_subdivisions=cuts[0], y_subdivisions=cuts[1], size=1)
    obj = bpy.context.object
    mesh = obj.data
    uv = mesh.uv_layers.active.data
    for vertex in mesh.vertices:
        u, v = vertex.co.x + .5, vertex.co.y + .5
        out = bend(u, v) if bend else 0.0
        vertex.co = bc.point((width * (u - .5), height * v, -0.0015 - out))
    for face in mesh.polygons:
        for li in face.loop_indices:
            co = mesh.vertices[mesh.loops[li].vertex_index].co
            uv[li].uv = (co.x / width + .5, co.z / height)
    # Godot room-local: facing -Z means the visible side points to Blender +Y.
    mesh.update()
    if mesh.polygons[0].normal.y < 0:
        mesh.flip_normals()
    return bc.finish(obj, name, mat)


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
        evaluated = obj.evaluated_get(bpy.context.evaluated_depsgraph_get())
        mesh = evaluated.to_mesh()
        mesh.calc_loop_triangles()
        tris += len(mesh.loop_triangles)
        evaluated.to_mesh_clear()
    assert path.stat().st_size <= 10 * 1024 * 1024, path
    print("LIVED", name, tris, "tris", path.stat().st_size, "bytes")
    return tris


def floor_mat():
    bc.GROUP = "floor_mat"
    rush = bc.material("Sleeping mat (chieu) | scanned CC0", "tatami_mat", strength=0.9)
    binding = printed("Mat binding | dyed CC0 linen", PAPER / "binding_navy.jpg", 0.9)
    w, d = 1.4, 1.8

    def lift(x, z):
        # A soft wave from being rolled up, and the south-east corner curling up.
        wave = .004 * math.sin(z * 3.1 + .6) * math.cos(x * 2.2)
        corner = max(0.0, 1 - math.hypot(x - w / 2, z - d / 2) / .32) ** 2 * .035
        return .004 + wave * .5 + corner

    mat = bc.grid("SleepingMat", (-w / 2 + .025, w / 2 - .025), (-d / 2 + .025, d / 2 - .025), 0, 28, 36, rush, 1.8,
                  lambda u, v: 0)
    for vertex in mat.data.vertices:
        x, z = vertex.co.x, -vertex.co.y
        vertex.co.z = lift(x, z) + max(0.0, .0005 * math.sin(x * 40))
    for edge in ((-w / 2, -d / 2, w / 2, -d / 2), (w / 2, -d / 2, w / 2, d / 2),
                 (w / 2, d / 2, -w / 2, d / 2), (-w / 2, d / 2, -w / 2, -d / 2)):
        x0, z0, x1, z1 = edge
        steps = 18
        coords = [(x0 + (x1 - x0) * t / steps, 0, z0 + (z1 - z0) * t / steps) for t in range(steps + 1)]
        strip = bc.seam("Binding", [(x, lift(x * .97, z * .97) + .003, z) for x, _, z in coords], binding, radius=.014)
        strip.scale.z = .3
        bpy.context.view_layer.objects.active = strip
        bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return export("floor_mat")


def bath_tiles():
    bc.GROUP = "bath_tiles"
    tiles = bc.material("Old white wall tiles | scanned CC0", "long_white_tiles", strength=0.7)
    steel = plain("Stainless drain", (.55, .56, .57), .35, 1.0)
    dark = plain("Drain slot", (.03, .03, .03), .9)
    period, t, half = 1.27, .008, TILE_TOP / 2
    x0, x1, z0, z1 = BATH["x0"], BATH["x1"], BATH["z0"], BATH["z1"]
    bc.box("TilesWest", (x0 + t / 2, half, (z0 + z1) / 2), (t, TILE_TOP, z0 - z1), tiles, .002, period)
    bc.box("TilesEast", (x1 - t / 2, half, (z0 + z1) / 2), (t, TILE_TOP, z0 - z1), tiles, .002, period)
    bc.box("TilesBack", ((x0 + x1) / 2, half, z1 + t / 2), (x1 - x0 - 2 * t, TILE_TOP, t), tiles, .002, period)
    door_east = BATH["door"][1]
    bc.box("TilesFront", ((door_east + x1) / 2, half, z0 - t / 2), (x1 - door_east - t, TILE_TOP, t), tiles, .002, period)
    # Bull-nose capping strip on top of the tiling.
    for name, pos, size in (("CapWest", (x0 + .007, TILE_TOP + .006, (z0 + z1) / 2), (.014, .012, z0 - z1)),
                            ("CapEast", (x1 - .007, TILE_TOP + .006, (z0 + z1) / 2), (.014, .012, z0 - z1)),
                            ("CapBack", ((x0 + x1) / 2, TILE_TOP + .006, z1 + .007), (x1 - x0, .012, .014)),
                            ("CapFront", ((door_east + x1) / 2, TILE_TOP + .006, z0 - .007), (x1 - door_east, .012, .014))):
        bc.box(name, pos, size, tiles, .005, period)
    drain = (6.45, -6.25)
    bc.box("DrainGrate", (drain[0], .002, drain[1]), (.12, .004, .12), steel, .002, .3)
    for i in range(5):
        bc.box("DrainSlot", (drain[0] - .04 + i * .02, .0042, drain[1]), (.008, .001, .08), dark, 0, .3)
    return export("bath_tiles")


def conduits():
    bc.GROUP = "conduits"
    pvc = bc.material("PVC conduit | CC0 plaster tone", "plastered_wall_04_small")
    # Inner wall faces of the corner shell: front (door) wall z=0, west wall x=0.1, ceiling y=3.0.
    r, front, west, top = .009, -.009, .1 + .009, CEILING - .009
    runs = [  # light switch (Room407LightSwitch 2.72, 1.35) up and along the ceiling to the tube lamp
        [(2.72, 1.43, front), (2.72, top, front), (2.72, top, -1.2), (2.6, top, -1.2)],
        # decorative socket by Viet's desk, joining the same ceiling run
        [(3.95, .41, front), (3.95, top, front), (2.72, top, front)],
        # decorative socket by Phuc's desk on the west wall
        [(west, .41, -5.3), (west, top, -5.3), (west, top, -4.42)],
    ]
    for run in runs:
        for a, b in zip(run, run[1:]):
            bc.tube("Conduit", a, b, r, pvc, 10, .3)
            length = (Vector(b) - Vector(a)).length
            for k in range(1, int(length / .6) + 1):  # saddle clips every 0.6 m
                p = Vector(a) + (Vector(b) - Vector(a)) * (k * .6 / length)
                along = (Vector(b) - Vector(a)).normalized()
                size = [.022, .022, .022]
                size[max(range(3), key=lambda i: abs(along[i]))] = .012
                bc.box("Saddle", tuple(p), tuple(size), pvc, .002, .3)
        for corner in run[1:-1]:
            bc.box("Elbow", corner, (.03, .03, .03), pvc, .006, .3)
    return export("conduits")


def paper_items():
    paper = lambda name: printed(name + " | drawn (OFL font)", PAPER / (name + ".png"))
    tape = plain("Clear tape", (.86, .84, .76), .35)
    nail = plain("Nail", (.2, .2, .2), .5, 1.0)
    curl = lambda u, v: .012 * max(0.0, (.25 - v) / .25) ** 2
    sheet("calendar", .30, .425, paper("calendar"), (6, 10), curl)
    bc.tube("Nail", (0, .418, 0), (0, .418, -.012), .0015, nail, 6, .1)
    export("calendar")
    sheet("timetable", .297, .21, paper("timetable"), (8, 6), lambda u, v: .004 * math.sin(u * math.pi))
    for x in (-.135, .135):
        for y in (.012, .198):
            bc.box("Tape", (x, y, -.0022), (.045, .018, .0006), tape, 0, .1)
    export("timetable")
    notes = paper("sticky_notes")
    bc.GROUP = "sticky_notes"
    for i, (dx, dy, tilt) in enumerate(((-.09, .02, -4), (0, .0, 3), (.09, .03, -2))):
        note = sheet("sticky_notes", .076, .076, notes, (4, 4), lambda u, v: .006 * max(0.0, (.4 - v) / .4) ** 2)
        note.name = f"Note{i}"
        uv = note.data.uv_layers.active.data
        for loop in uv:
            loop.uv = ((i + loop.uv[0]) / 3, loop.uv[1])
        note.rotation_euler.y = math.radians(tilt)
        note.location = bc.point((dx, dy, 0))
    export("sticky_notes")


def curtain():
    bc.GROUP = "curtain_balcony"
    cloth_mat = printed("Curtain | dyed CC0 linen", PAPER / "curtain_green.jpg", 0.95)
    steel = plain("Curtain rod", (.75, .74, .7), .3, 1.0)
    rod_y, rod_z = 2.42, -6.84
    bc.tube("CurtainRod", (1.85, rod_y, rod_z), (3.55, rod_y, rod_z), .011, steel, 12, .3)
    for x in (1.9, 3.5):
        bc.box("RodBracket", (x, rod_y, rod_z - .04), (.02, .03, .1), steel, .003, .3)
    # 1.6 m of fabric drawn back into 0.42 m beside the west jamb (x 1.9 .. 2.32): deep pleats.
    cols, rows, height = 48, 36, 2.36
    bpy.ops.mesh.primitive_grid_add(x_subdivisions=cols, y_subdivisions=rows, size=1)
    obj = bpy.context.object
    obj.name = "Curtain"
    pins = obj.vertex_groups.new(name="pin")
    mesh = obj.data
    fabric_uv = {}
    for vertex in mesh.vertices:
        u, v = vertex.co.x + .5, vertex.co.y + .5
        fabric_uv[vertex.index] = (u * 1.6 / .8, v * height / .8)
        pleat = .055 * math.sin(u * cols * math.pi / 2)
        x = 1.9 + u * .42
        y = rod_y - .03 - (1 - v) * height
        vertex.co = bc.point((x, y, rod_z + pleat * (.3 + .7 * v)))
    uv = mesh.uv_layers.active.data
    for face in mesh.polygons:
        face.use_smooth = True
        for li in face.loop_indices:
            uv[li].uv = fabric_uv[mesh.loops[li].vertex_index]
    top = max(v.co.z for v in mesh.vertices)
    pins.add([v.index for v in mesh.vertices if v.co.z > top - .01], 1.0, "REPLACE")
    sim = obj.modifiers.new("Cloth", "CLOTH")
    st = sim.settings
    st.quality, st.mass, st.air_damping = 6, .15, 2
    st.tension_stiffness = st.compression_stiffness = 15
    st.bending_stiffness = .5
    st.vertex_group_mass = "pin"
    sim.collision_settings.use_self_collision = False
    scene = bpy.context.scene
    scene.frame_start, scene.frame_end = 1, 50
    sim.point_cache.frame_start, sim.point_cache.frame_end = 1, 50
    for frame in range(1, 51):
        scene.frame_set(frame)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=sim.name)
    scene.frame_set(1)
    solid = obj.modifiers.new("Thickness", "SOLIDIFY")
    solid.thickness = .002
    bpy.ops.object.modifier_apply(modifier=solid.name)
    low = min(v.co.z for v in mesh.vertices)
    assert low > .01, "curtain must hang clear of the floor"
    bc.finish(obj, "Curtain", cloth_mat)
    return export("curtain_balcony")


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    OUT.mkdir(parents=True, exist_ok=True)
    total = floor_mat() + bath_tiles() + conduits()
    paper_items()
    total += curtain()
    print("RESULT: lived-in Blender pieces PASS", total, "tris")


main()
