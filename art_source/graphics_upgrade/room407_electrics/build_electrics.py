"""T-226 (D-136): room 407's small electrics, modelled in Blender instead of the PS1 boxes (owner: "vẫn là
dạng hình khối"). Run with Blender 5.2.2: blender -b --factory-startup -P <this file>.
Writes game/assets/models/graphics_pilot/room407_electrics/:
  power_strip_ch1.glb  chapter 1's strip (N2): Case (two-part shell with a seam, three rocker recesses,
                       lamp windows, round two-pin sockets, cord relief at -X), Rocker1..3 (origin on the
                       hinge, rocking about X like power_strip.gd's Rocker), LED1..3 (the lit lamp domes).
  mains_plug.glb       two round-pin plug: Body (colour set by the game), Pins. Origin on the face it plugs
                       into, pins along -Y; the cord leaves the relief at (0, 0.022, 0.0325).
  router_adapter.glb   the router's wall-wart: Body, Pins, RedTape (the owner's red-taped plug, N2); the
                       cord leaves its relief at (0, 0.030, 0.029).
  rj45_plug.glb        network plug: Body (clear), Contacts, Boot (cable colour set by the game). Origin in
                       the body, contacts towards +Z; the cable enters the boot at (0, 0, -0.028).
  lan_wall_port.glb    two-port faceplate: Plate, Jacks; origin on the wall behind its centre, front -Z,
                       jack centres at (+-0.022, -0.006, -0.008).
Every size is in Godot space (+Y up, +Z towards the viewer of a -Z front); g() turns it into Blender's.
Plain PBR colours: the pieces are a few centimetres across and read by their shape under the torch.
"""
import math
import sys
from pathlib import Path

import bpy
from mathutils import Matrix, Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OUT = ROOT / "game/assets/models/graphics_pilot/room407_electrics"
SWITCH_X = (-0.135, 0.0, 0.135)   # power_strip.tscn's Switch1..3 (lane A's switch areas sit on them)
CASE = (0.40, 0.040, 0.105)       # strip length, height, width
ROCKER_Z = -0.030                 # rockers and lamps on the -Z half, sockets on the +Z half
SOCKET_Z = 0.024
HINGE_Y = 0.034


def g(x, y, z):
    """Godot point to Blender point."""
    return Vector((x, -z, y))


def gs(x, y, z):
    """Godot size to Blender size."""
    return Vector((x, z, y))


def material(name, colour, roughness, metallic=0.0, emission=None, alpha=1.0):
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*colour, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Alpha"].default_value = alpha
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission[0], 1.0)
        bsdf.inputs["Emission Strength"].default_value = emission[1]
    return mat


def active(obj):
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)


def finish(obj, mat, bevel=0.0, segments=3):
    obj.data.materials.clear()
    obj.data.materials.append(mat)
    if bevel > 0.0:
        mod = obj.modifiers.new("Bevel", "BEVEL")
        mod.width = bevel
        mod.segments = segments
        mod.limit_method = "ANGLE"
        active(obj)
        bpy.ops.object.modifier_apply(modifier=mod.name)
    return obj


def box(name, size, at, mat, bevel=0.0, segments=3):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=g(*at))
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = gs(*size)
    active(obj)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    return finish(obj, mat, bevel, segments)


def cylinder(name, radius, length, at, axis, mat, vertices=24, bevel=0.0, taper=1.0):
    """A cylinder along Godot axis "x", "y" or "z"; taper scales its +axis end."""
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=length, location=(0, 0, 0))
    obj = bpy.context.active_object
    obj.name = name
    if taper != 1.0:
        for v in obj.data.vertices:
            if v.co.z > 0:
                v.co.x *= taper
                v.co.y *= taper
    # Blender's cylinder runs along its Z = Godot Y; turn it onto the requested Godot axis.
    obj.rotation_euler = {"y": (0, 0, 0), "x": (0, math.pi / 2, 0), "z": (math.pi / 2, 0, 0)}[axis]
    obj.location = g(*at)
    active(obj)
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=True)
    return finish(obj, mat, bevel, 2)


def cut(target, *cutters):
    for cutter in cutters:
        mod = target.modifiers.new("Cut", "BOOLEAN")
        mod.operation = "DIFFERENCE"
        mod.object = cutter
        mod.solver = "EXACT"
        active(target)
        bpy.ops.object.modifier_apply(modifier=mod.name)
        bpy.data.objects.remove(cutter, do_unlink=True)
    return target


def join(name, *objs):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objs:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    bpy.ops.object.join()
    obj = bpy.context.active_object
    obj.name = obj.data.name = name
    return obj


def smooth(obj, degrees=35.0):
    active(obj)
    bpy.ops.object.shade_smooth_by_angle(angle=math.radians(degrees))


def set_origin(obj, godot_point):
    """Moves obj's origin to godot_point without moving its mesh."""
    offset = g(*godot_point) - obj.location
    obj.data.transform(Matrix.Translation(-offset))
    obj.location += offset


def export(name, objs):
    for obj in objs:
        if obj.type == "MESH":
            smooth(obj)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objs:
        obj.select_set(True)
    path = OUT / (name + ".glb")
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True, export_yup=True)
    tris = 0
    for obj in objs:
        if obj.type == "MESH":
            obj.data.calc_loop_triangles()
            tris += len(obj.data.loop_triangles)
    print("ELECTRICS", name, [o.name for o in objs], tris, "tris", path.stat().st_size, "bytes")


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def strip():
    reset()
    white = material("StripPlastic", (0.76, 0.73, 0.64), 0.55)
    red = material("RockerRed", (0.62, 0.05, 0.035), 0.28)
    mark = material("RockerMark", (0.9, 0.88, 0.82), 0.5)
    lens = material("LampOff", (0.12, 0.03, 0.02), 0.15)
    lit = material("LampOn", (1.0, 0.42, 0.08), 0.3, emission=((1.0, 0.42, 0.08), 6.0))
    metal = material("Screw", (0.45, 0.45, 0.43), 0.35, metallic=0.9)
    length, height, width = CASE
    # Two shells meeting at y 0.016: their bevels leave the seam line round the strip.
    lower = box("Lower", (length, 0.016, width), (0, 0.008, 0), white, bevel=0.005)
    upper = box("Upper", (length - 0.002, height - 0.0165, width - 0.002), (0, 0.0165 + (height - 0.0165) / 2, 0),
                white, bevel=0.009, segments=4)
    cutters = []
    for x in SWITCH_X:
        cutters.append(box("RockerWell", (0.0205, 0.012, 0.030), (x, height, ROCKER_Z), white))
        cutters.append(cylinder("LampHole", 0.0036, 0.012, (x + 0.021, height, ROCKER_Z), "y", white, 16))
        cutters.append(cylinder("SocketDish", 0.0175, 0.008, (x, height + 0.001, SOCKET_Z), "y", white, 40))
        for side in (-0.0095, 0.0095):
            cutters.append(cylinder("PinHole", 0.0026, 0.04, (x + side, height, SOCKET_Z), "y", white, 16))
    cut(upper, *cutters)
    parts = [lower, upper]
    for x in SWITCH_X:
        parts.append(cylinder("Lens", 0.0034, 0.003, (x + 0.021, height - 0.0035, ROCKER_Z), "y", lens, 16))
        parts.append(box("WellFloor", (0.0195, 0.002, 0.029), (x, height - 0.0055, ROCKER_Z), lens))
    for x in (-0.185, 0.185):
        parts.append(cylinder("Screw", 0.003, 0.0012, (x, height + 0.0002, 0), "y", metal, 16))
    # Cord relief at -X, tapering to the 4 mm lead (cables.gd starts StripPower at its tip).
    parts.append(cylinder("Relief", 0.0055, 0.024, (-length / 2 - 0.010, 0.016, 0), "x", white, 20, taper=1.0))
    case = join("Case", *parts)
    rockers, lamps = [], []
    for i, x in enumerate(SWITCH_X):
        body = box("RockerBody", (0.0175, 0.0135, 0.027), (x, HINGE_Y + 0.0055, ROCKER_Z), red, bevel=0.002)
        line = box("RockerMark", (0.007, 0.0006, 0.0018), (x, HINGE_Y + 0.0124, ROCKER_Z - 0.0075), mark)
        rocker = join("Rocker%d" % (i + 1), body, line)
        set_origin(rocker, (x, HINGE_Y, ROCKER_Z))
        rockers.append(rocker)
        lamp = cylinder("LED%d" % (i + 1), 0.0033, 0.0026, (x + 0.021, height - 0.0008, ROCKER_Z), "y", lit, 16, bevel=0.0008)
        set_origin(lamp, (x + 0.021, height - 0.0008, ROCKER_Z))
        lamps.append(lamp)
    export("power_strip_ch1", [case] + rockers + lamps)


def mains_plug():
    reset()
    body_mat = material("PlugBody", (0.05, 0.05, 0.05), 0.5)
    brass = material("Brass", (0.78, 0.62, 0.32), 0.3, metallic=1.0)
    flange = box("Flange", (0.034, 0.003, 0.027), (0, 0.0015, 0), body_mat, bevel=0.0012)
    shell = box("Shell", (0.029, 0.029, 0.023), (0, 0.0175, 0), body_mat, bevel=0.0065, segments=4)
    grips = [box("Grip", (0.0025, 0.0012, 0.017), (side, y, 0), body_mat)
             for y in (0.020, 0.0235, 0.027) for side in (-0.0145, 0.0145)]
    cut(shell, *grips)
    relief = cylinder("Relief", 0.0045, 0.022, (0, 0.022, 0.0215), "z", body_mat, 20, taper=0.72)
    body = join("Body", flange, shell, relief)
    pins = [cylinder("Pin", 0.0024, 0.019, (x, -0.0095, 0), "y", brass, 16, bevel=0.0006) for x in (-0.0095, 0.0095)]
    export("mains_plug", [body, join("Pins", *pins)])


def router_adapter():
    reset()
    black = material("AdapterBody", (0.035, 0.035, 0.037), 0.55)
    brass = material("Brass", (0.78, 0.62, 0.32), 0.3, metallic=1.0)
    tape = material("RedTape", (0.70, 0.05, 0.04), 0.75)
    flange = box("Flange", (0.048, 0.003, 0.035), (0, 0.0015, 0), black, bevel=0.0012)
    shell = box("Shell", (0.045, 0.038, 0.032), (0, 0.022, 0), black, bevel=0.004, segments=3)
    vents = [box("Vent", (0.030, 0.0016, 0.004), (0, y, -0.016), black) for y in (0.020, 0.025, 0.030, 0.035)]
    cut(shell, *vents)
    relief = cylinder("Relief", 0.004, 0.013, (0, 0.030, 0.0225), "z", black, 20, taper=0.75)
    body = join("Body", flange, shell, relief)
    pins = [cylinder("Pin", 0.0024, 0.019, (x, -0.0095, 0), "y", brass, 16, bevel=0.0006) for x in (-0.0095, 0.0095)]
    band = box("RedTape", (0.0466, 0.013, 0.0336), (0, 0.029, 0), tape, bevel=0.0015)
    export("router_adapter", [body, join("Pins", *pins), band])


def rj45():
    reset()
    clear = material("ClearPlastic", (0.82, 0.88, 0.90), 0.08, alpha=0.55)
    gold = material("Gold", (0.95, 0.75, 0.35), 0.25, metallic=1.0)
    boot_mat = material("BootRubber", (0.5, 0.5, 0.5), 0.6)
    body = box("Body", (0.0117, 0.0080, 0.0210), (0, 0, 0.0005), clear, bevel=0.0008)
    latch = box("Latch", (0.0060, 0.0012, 0.0120), (0, -0.0048, 0.0010), clear, bevel=0.0003)
    latch.rotation_euler.x = math.radians(-10)
    active(latch)
    bpy.ops.object.transform_apply(rotation=True)
    body = join("Body", body, latch)
    contacts = [box("Contact", (0.0006, 0.0008, 0.0045), ((k - 3.5) * 0.00102, 0.0038, 0.0085), gold) for k in range(8)]
    boot = box("Boot", (0.0125, 0.0105, 0.018), (0, 0, -0.019), boot_mat, bevel=0.0018)
    for v in boot.data.vertices:  # the boot narrows towards the cable
        if v.co.y > 0.005:  # Blender +Y = Godot -Z (the cable end)
            v.co.x *= 0.62
            v.co.z *= 0.62
    export("rj45_plug", [body, join("Contacts", *contacts), boot])


def lan_port():
    reset()
    white = material("PlatePlastic", (0.80, 0.78, 0.70), 0.5)
    black = material("JackBlack", (0.03, 0.03, 0.03), 0.6)
    gold = material("Gold", (0.95, 0.75, 0.35), 0.25, metallic=1.0)
    label = material("LabelBlue", (0.55, 0.68, 0.80), 0.6)
    plate = box("Plate", (0.086, 0.086, 0.008), (0, 0, -0.004), white, bevel=0.0022, segments=3)
    openings = [box("Opening", (0.0150, 0.0195, 0.03), (x, -0.006, -0.004), white) for x in (-0.022, 0.022)]
    cut(plate, *openings)
    caps = [box("Cap", (0.013, 0.004, 0.0012), (0, y, -0.0084), white, bevel=0.0005) for y in (-0.036, 0.036)]
    labels = [box("Label", (0.011, 0.0045, 0.0006), (x, 0.012, -0.0082), label) for x in (-0.022, 0.022)]
    plate = join("Plate", plate, *caps, *labels)
    jacks = []
    for x in (-0.022, 0.022):
        frame = box("Keystone", (0.0150, 0.0195, 0.007), (x, -0.006, -0.0055), black, bevel=0.0006)
        cut(frame, box("Mouth", (0.0118, 0.0105, 0.02), (x, -0.0065, -0.006), black))
        back = box("Back", (0.0140, 0.0180, 0.002), (x, -0.006, -0.0015), black)
        pins = [box("Contact", (0.0006, 0.0006, 0.004), (x + (k - 3.5) * 0.00102, -0.0018, -0.0045), gold) for k in range(8)]
        jacks += [frame, back] + pins
    export("lan_wall_port", [plate, join("Jacks", *jacks)])


OUT.mkdir(parents=True, exist_ok=True)
strip()
mains_plug()
router_adapter()
rj45()
lan_port()
print("RESULT: room 407 electrics PASS")
