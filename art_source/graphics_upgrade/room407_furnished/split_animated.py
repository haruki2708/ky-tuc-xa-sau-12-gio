"""Splits two baked Tripo props (D-096) into moving parts for G3.
Run with Blender 5.2.2: blender -b --factory-startup -P <this file>.
  locker_viet.glb        locker_open (it has an interior) with a clean closed door, 0.70 m wide like
                         locker_closed; nodes LockerBody + DoorPivot/Door.
                         DoorPivot sits on the hinge (-X side of the front); +90 deg about Y opens it
                         towards -Z, like hinged.gd of ch1v2/viet_locker.tscn.
  ceiling_fan_split.glb  ceiling_fan stood upright (the Tripo fan hangs ~20 deg off plumb);
                         nodes FanBody + fan_rotor (the name main.gd spins, T-102). Origin is the
                         canopy top on the rotation axis, so the fan is placed at ceiling height.
Both share the baked texture set; no new texture work.
"""
import math
import sys
from pathlib import Path

import bmesh
import bpy
import numpy as np
from mathutils import Matrix, Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SRC = ROOT / "game/assets/models/graphics_pilot/room407_batch2"
OUT = ROOT / "game/assets/models/graphics_pilot/room407_furnished"
DOOR_X = (0.02, 0.43)    # closed door: centre seam to the cabinet side frame
DOOR_Z = (0.045, 1.655)  # door bottom/top, inside the plinth and top frame
LOCKER_TRIS = 8000       # large-prop budget (D-093) for body + door
LOCKER_WIDTH = 0.70      # locker_closed width, so the Viet locker lines up with the others


def load(name):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(SRC / (name + ".glb")))
    obj = next(o for o in bpy.data.objects if o.type == "MESH")
    for other in list(bpy.data.objects):
        if other is not obj and other.type != "MESH":
            bpy.data.objects.remove(other, do_unlink=True)
    obj.parent = None
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    return obj


def coords(obj):
    co = np.empty(len(obj.data.vertices) * 3)
    obj.data.vertices.foreach_get("co", co)
    return co.reshape(-1, 3)


def separate(obj, face_mask, name):
    """Moves the faces where face_mask is True into a new object called name."""
    obj.data.polygons.foreach_set("select", face_mask)
    obj.data.vertices.foreach_set("select", np.zeros(len(obj.data.vertices), bool))
    obj.data.edges.foreach_set("select", np.zeros(len(obj.data.edges), bool))
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_mode(type="FACE")
    bpy.ops.object.mode_set(mode="OBJECT")
    obj.data.polygons.foreach_set("select", face_mask)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.separate(type="SELECTED")
    bpy.ops.object.mode_set(mode="OBJECT")
    part = next(o for o in bpy.context.selected_objects if o is not obj)
    part.name = part.data.name = name
    return part


def centres(obj):
    c = np.empty(len(obj.data.polygons) * 3)
    obj.data.polygons.foreach_get("center", c)
    return c.reshape(-1, 3)


def set_origin(obj, point):
    offset = Vector(point) - obj.location
    obj.data.transform(Matrix.Translation(-offset))
    obj.location += offset


def export(name, objects):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    path = OUT / (name + ".glb")
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True,
                              export_yup=True, export_image_format="JPEG")
    assert path.stat().st_size <= 10 * 1024 * 1024, path
    print("SPLIT", name, [(o.name, len(o.data.polygons) if o.type == "MESH" else 0) for o in objects],
          path.stat().st_size, "bytes")


def triangles(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


def close_door(door, xs, front, thickness=0.012):
    """Plain back sheet and edge strips behind the textured panel (seen only when it is open).
    They reuse the panel's centre UV, a flat stretch of painted metal."""
    bm = bmesh.new()
    bm.from_mesh(door.data)
    uv = bm.loops.layers.uv.active
    z = [v.co.z for v in bm.verts]
    z0, z1 = min(z), max(z)
    centre = Vector(((xs[0] + xs[1]) / 2, front, (z0 + z1) / 2))
    probe = min((f for f in bm.faces), key=lambda f: (f.calc_center_median() - centre).length)
    flat = probe.loops[0][uv].uv.copy()
    back = front - thickness
    sheets = [
        ([(xs[0], back, z0), (xs[1], back, z0), (xs[1], back, z1), (xs[0], back, z1)], (0, -1, 0)),
        ([(xs[0], front, z0), (xs[0], back, z0), (xs[0], back, z1), (xs[0], front, z1)], (-1, 0, 0)),
        ([(xs[1], front, z0), (xs[1], back, z0), (xs[1], back, z1), (xs[1], front, z1)], (1, 0, 0)),
        ([(xs[0], front, z0), (xs[1], front, z0), (xs[1], back, z0), (xs[0], back, z0)], (0, 0, -1)),
        ([(xs[0], front, z1), (xs[1], front, z1), (xs[1], back, z1), (xs[0], back, z1)], (0, 0, 1)),
    ]
    for corners, outward in sheets:
        face = bm.faces.new([bm.verts.new(c) for c in corners])
        face.normal_update()
        if face.normal.dot(Vector(outward)) < 0:
            face.normal_flip()
        for loop in face.loops:
            loop[uv].uv = flat
    bm.to_mesh(door.data)
    bm.free()


def locker():
    body = load("locker_open")
    body.name = body.data.name = "LockerBody"
    # Blender space: Godot -Z (the locker front) is Blender +Y. Tripo's open door (hinge side,
    # -X) stands edge-on in front of the cabinet and its surface is torn: it is dropped.
    c = centres(body)
    old = separate(body, (c[:, 1] > 0.135) & (c[:, 0] < -0.2), "OldDoor")
    bpy.data.objects.remove(old, do_unlink=True)
    # Outer plane of the closed door: the most common depth of its forward-facing faces.
    c = centres(body)
    n = np.empty(len(body.data.polygons) * 3)
    body.data.polygons.foreach_get("normal", n)
    n = n.reshape(-1, 3)
    facing = c[(n[:, 1] > 0.8) & (c[:, 0] > 0.05) & (c[:, 0] < 0.4) & (c[:, 2] > 0.2) & (c[:, 2] < 1.5), 1]
    hist, edges = np.histogram(facing, bins=60)
    front = float(edges[hist.argmax()] + edges[1] - edges[0])
    # New door: a flat panel over the intact closed door (+X half) takes that door's UVs (vents
    # come from its baked colour and normal maps) plus its real handle; it is then slid across
    # onto the open compartment. Tripo's handle sits at that door's +X edge, so it lands at the
    # centre seam, the free edge of a door hinged at -X.
    x0, x1 = DOOR_X
    bpy.ops.mesh.primitive_grid_add(x_subdivisions=16, y_subdivisions=64, size=1,
                                    location=((x0 + x1) / 2, front, (DOOR_Z[0] + DOOR_Z[1]) / 2),
                                    rotation=(-math.pi / 2, 0, 0))
    door = bpy.context.object
    door.name = door.data.name = "Door"
    door.dimensions = (x1 - x0, DOOR_Z[1] - DOOR_Z[0], 0)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    door.data.materials.append(body.data.materials[0])
    door.data.uv_layers.new(name="UVMap")
    transfer = door.modifiers.new("uv", "DATA_TRANSFER")
    transfer.object = body
    transfer.use_loop_data = True
    transfer.data_types_loops = {"UV"}
    transfer.loop_mapping = "POLYINTERP_NEAREST"
    bpy.ops.object.modifier_apply(modifier=transfer.name)
    n_panel = len(door.data.polygons)
    handle = body.copy()
    handle.data = body.data.copy()
    bpy.context.scene.collection.objects.link(handle)
    c = centres(handle)
    keep = (c[:, 1] > front + 0.012) & (c[:, 0] > x0) & (c[:, 0] < x1) & (c[:, 2] > DOOR_Z[0]) & (c[:, 2] < DOOR_Z[1])
    bpy.data.objects.remove(separate(handle, ~keep, "Junk"), do_unlink=True)
    print("HANDLE", len(handle.data.polygons), "faces")
    bpy.ops.object.select_all(action="DESELECT")
    handle.select_set(True)
    door.select_set(True)
    bpy.context.view_layer.objects.active = door
    bpy.ops.object.join()
    door.data.transform(Matrix.Translation((-(x0 + x1), 0, 0)))
    close_door(door, (-x1, -x0), front)
    # Body shed to keep the whole locker within the large-prop budget.
    body_target = LOCKER_TRIS - triangles(door)
    if triangles(body) > body_target:
        dec = body.modifiers.new("budget", "DECIMATE")
        dec.ratio = body_target / triangles(body) * 0.995
        bpy.ops.object.select_all(action="DESELECT")
        bpy.context.view_layer.objects.active = body
        body.select_set(True)
        bpy.ops.object.modifier_apply(modifier=dec.name)
    # Same footprint and origin convention as locker_closed (D-096): 0.70 m wide, origin at the
    # centre of the cabinet on the floor, so it drops into the Viet slot of placements.json.
    b = coords(body)
    centre_x, centre_y = (b[:, 0].max() + b[:, 0].min()) / 2, (b[:, 1].max() + b[:, 1].min()) / 2
    fit = Matrix.Diagonal((LOCKER_WIDTH / (b[:, 0].max() - b[:, 0].min()), 1, 1, 1)) @ Matrix.Translation((-centre_x, -centre_y, 0))
    body.data.transform(fit)
    door.data.transform(fit)
    front -= centre_y
    d = coords(door)
    print("DOOR", len(door.data.polygons), "faces (panel", n_panel, "), x", d[:, 0].min().round(3), d[:, 0].max().round(3),
          "y", d[:, 1].min().round(3), d[:, 1].max().round(3), "front", round(front, 3))
    hinge = Vector((float(d[:, 0].min()), front, 0.0))
    set_origin(door, hinge)
    pivot = bpy.data.objects.new("DoorPivot", None)
    bpy.context.scene.collection.objects.link(pivot)
    pivot.location = door.location.copy()
    door.parent = pivot
    door.location = (0, 0, 0)
    export("locker_viet", [body, pivot, door])


def straighten(obj, axis, pivot):
    """Rotates obj's mesh about pivot so axis becomes vertical."""
    to = Matrix.Translation(pivot) @ axis.rotation_difference(Vector((0, 0, 1))).to_matrix().to_4x4() @ Matrix.Translation(-pivot)
    obj.data.transform(to)


def principal(points, index):
    v = Vector(np.linalg.svd(points - points.mean(0), full_matrices=False)[2][index])
    return -v if v.z < 0 else v


def fan():
    obj = load("ceiling_fan")
    co = coords(obj)
    rod_axis = principal(co[(co[:, 2] > 0.44) & (co[:, 2] < 0.60)], 0)
    print("FAN rod tilt", round(math.degrees(rod_axis.angle(Vector((0, 0, 1)))), 1))
    # Body: the downrod becomes plumb and passes through the origin; origin = canopy top.
    straighten(obj, rod_axis, Vector((0, 0, 0)))
    co = coords(obj)
    top = co[:, 2].max()
    rod = co[(co[:, 2] < top - 0.22) & (co[:, 2] > top - 0.36)]
    centre = rod[:, :2].mean(0)
    obj.data.transform(Matrix.Translation((-centre[0], -centre[1], -top)))
    co = coords(obj)
    # Motor top: going down the rod, the first slice wider than the rod.
    cut = None
    for z in np.arange(-0.25, -0.8, -0.005):
        band = co[(co[:, 2] < z) & (co[:, 2] > z - 0.01)]
        if len(band) and np.hypot(band[:, 0], band[:, 1]).max() > 0.06:
            cut = float(z) - 0.012  # leave the static collar on the rod
            break
    print("FAN motor top", round(cut + 0.012, 3), "height", round(float(-co[:, 2].min()), 3))
    rotor = separate(obj, centres(obj)[:, 2] < cut, "Blades")
    obj.name = obj.data.name = "FanBody"
    # Rotor: the Tripo blades are a few degrees off the rod; they spin in their own plane.
    r = coords(rotor)
    normal = principal(r, 2)
    print("FAN blade plane vs rod", round(math.degrees(normal.angle(Vector((0, 0, 1)))), 1), "deg")
    straighten(rotor, normal, Vector((0, 0, cut)))
    r = coords(rotor)
    rotor.data.transform(Matrix.Translation((0, 0, cut - r[:, 2].max())))  # hub top meets the collar
    r = coords(rotor)
    # Hub centre: middle of the motor housing (everything within 0.14 m of the axis).
    hub_pts = r[np.hypot(r[:, 0], r[:, 1]) < 0.14]
    hub_c = (hub_pts[:, :2].min(0) + hub_pts[:, :2].max(0)) / 2
    rotor.data.transform(Matrix.Translation((-hub_c[0], -hub_c[1], -cut)))
    hub = bpy.data.objects.new("fan_rotor", None)
    bpy.context.scene.collection.objects.link(hub)
    hub.location = (0, 0, cut)
    rotor.parent = hub
    r = coords(rotor)
    print("ROTOR faces", len(rotor.data.polygons), "hub shift", hub_c.round(3), "extent",
          np.hypot(r[:, 0], r[:, 1]).max().round(3), "z", r[:, 2].min().round(3), r[:, 2].max().round(3))
    export("ceiling_fan_split", [obj, hub, rotor])


OUT.mkdir(parents=True, exist_ok=True)
locker()
fan()
print("RESULT: split animated props PASS")
