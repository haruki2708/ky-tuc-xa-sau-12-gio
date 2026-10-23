"""T-226 (D-136): the baked Tripo standing fan (room407_batch2/standing_fan.glb) split so its blades spin.
Run with Blender 5.2.2: blender -b --factory-startup -P <this file>.
  standing_fan_split.glb  nodes FanBody (stand, motor, both grilles, rim) + Rotor/Blades (five blades and
                          the hub). Rotor sits on the motor axis at the rim's centre; its local Z (Godot's
                          local Y) is the axis, pointing out of the front grille, so the game spins it with
                          rotate_y like the ceiling fan's fan_rotor (split_animated.py).
The Tripo mesh is one piece (blades fused to the grilles), so the blades are cut out by where they lie:
between the rear grille's cone and the front grille's dome, inside the rim. Same baked texture set.
The bake also painted the blades' blue onto the grille wires in front of and behind them (~570 faces);
those would stand still while the blades turn, so each takes the texels of the nearest wire that kept
the grille's own colour.
"""
import sys
from pathlib import Path

import bpy
import numpy as np
from mathutils import Matrix, Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SRC = ROOT / "game/assets/models/graphics_pilot/room407_batch2/standing_fan.glb"
OUT = ROOT / "game/assets/models/graphics_pilot/room407_furnished/standing_fan_split.glb"
HEAD_Z = 0.68    # everything above this is the fan head (the stand ends at ~0.65 m)
RIM = 0.265      # the rim ring and the rear grille's outer arc start at this radius
# Grilles in the rim frame (depth d along the axis, front +; radius r), measured from the vertices:
# rear cone (r 0.07, d -0.025) to (r 0.26, d -0.105); front dome (r 0.26, d 0.045) to (r 0.12, d 0.075).
REAR_D0, REAR_SLOPE = -0.025, 0.421
FRONT_D0, FRONT_SLOPE = 0.045, 0.214
MARGIN = 0.010   # kept off each grille so its wires stay on the body
HUB_R = 0.085    # the blade hub is a 0.08 m cylinder from d -0.05 to 0.03
BLADE_BLUE = 0.06  # a texel this much bluer than red is the blades' plastic (wires and rim are grey/cream)


def load():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(SRC))
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


def centres(obj):
    c = np.empty(len(obj.data.polygons) * 3)
    obj.data.polygons.foreach_get("center", c)
    return c.reshape(-1, 3)


def separate(obj, face_mask, name):
    """Moves the faces where face_mask is True into a new object called name."""
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_mode(type="FACE")
    bpy.ops.mesh.select_all(action="DESELECT")
    bpy.ops.object.mode_set(mode="OBJECT")
    obj.data.polygons.foreach_set("select", face_mask)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.separate(type="SELECTED")
    bpy.ops.object.mode_set(mode="OBJECT")
    part = next(o for o in bpy.context.selected_objects if o is not obj)
    part.name = part.data.name = name
    return part


def frame(head):
    """Centre and axis of the rim: a circle fitted to the outermost head vertex of each 4 degrees,
    refitted a few times from the head's flattest direction."""
    centre = head.mean(0)
    axis = np.linalg.svd(head - centre, full_matrices=False)[2][2]
    axis = axis if axis[1] > 0 else -axis  # Tripo's front faces +Y
    for _ in range(4):
        e1 = np.cross(axis, (0, 0, 1))
        e1 /= np.linalg.norm(e1)
        e2 = np.cross(axis, e1)
        p = head - centre
        x, y, d = p @ e1, p @ e2, p @ axis
        angle, radius = np.arctan2(y, x), np.hypot(x, y)
        rim = []
        for k in range(90):
            band = (angle >= -np.pi + k * np.pi / 45) & (angle < -np.pi + (k + 1) * np.pi / 45)
            if band.any():
                i = np.argmax(np.where(band, radius, -1))
                rim.append((x[i], y[i], d[i]))
        rim = np.array(rim)
        fit = np.c_[2 * rim[:, :2], np.ones(len(rim))]
        cx, cy, _ = np.linalg.lstsq(fit, (rim[:, :2] ** 2).sum(1), rcond=None)[0]
        points = centre + np.outer(rim[:, 0], e1) + np.outer(rim[:, 1], e2) + np.outer(rim[:, 2], axis)
        normal = np.linalg.svd(points - points.mean(0), full_matrices=False)[2][2]
        centre = centre + cx * e1 + cy * e2 + rim[:, 2].mean() * axis
        axis = normal if normal @ axis > 0 else -normal
    return centre, axis


def rotor_mask(obj, centre, axis):
    c = centres(obj)
    d = (c - centre) @ axis
    r = np.linalg.norm(c - centre - np.outer(d, axis), axis=1)
    rear = REAR_D0 - REAR_SLOPE * (r - 0.07)
    front = FRONT_D0 + FRONT_SLOPE * (0.26 - r)
    blades = (r >= HUB_R) & (r < RIM) & (d > rear + MARGIN) & (d < front - MARGIN)
    # The rear grille's spokes bend out to the rim behind the blade tips.
    blades &= ~((r > 0.235) & (d < -0.075))
    hub = (r < HUB_R) & (d > -0.055) & (d < 0.045)
    return (blades | hub) & (c[:, 2] > HEAD_Z)


def face_colours(obj):
    """Base colour texel under each face's mean UV."""
    bsdf = next(n for n in obj.data.materials[0].node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    image = bsdf.inputs["Base Color"].links[0].from_node.image
    w, h = image.size
    pixels = np.empty(w * h * 4, np.float32)
    image.pixels.foreach_get(pixels)
    pixels = pixels.reshape(h, w, 4)
    uv = np.empty(len(obj.data.loops) * 2)
    obj.data.uv_layers.active.data.foreach_get("uv", uv)
    uv = uv.reshape(-1, 2)
    starts = np.empty(len(obj.data.polygons), int)
    obj.data.polygons.foreach_get("loop_start", starts)
    totals = np.empty(len(obj.data.polygons), int)
    obj.data.polygons.foreach_get("loop_total", totals)
    mean = np.add.reduceat(uv, starts) / totals[:, None]
    x = np.clip((mean[:, 0] % 1.0) * w, 0, w - 1).astype(int)
    y = np.clip((mean[:, 1] % 1.0) * h, 0, h - 1).astype(int)  # Blender pixels run bottom-up like UV v
    return pixels[y, x, :3], mean, starts, totals


def repaint_grille(body):
    """Grille faces carrying the blades' baked blue take the UV of the nearest grey/cream head face."""
    colour, mean, starts, totals = face_colours(body)
    c = centres(body)
    head = c[:, 2] > HEAD_Z
    blue = head & (colour[:, 2] - colour[:, 0] > BLADE_BLUE)
    donors = np.flatnonzero(head & ~blue)
    uv = np.empty(len(body.data.loops) * 2)
    body.data.uv_layers.active.data.foreach_get("uv", uv)
    uv = uv.reshape(-1, 2)
    for face in np.flatnonzero(blue):
        nearest = donors[np.argmin(np.linalg.norm(c[donors] - c[face], axis=1))]
        uv[starts[face]:starts[face] + totals[face]] = mean[nearest]
    body.data.uv_layers.active.data.foreach_set("uv", uv.ravel())
    print("GRILLE repainted", int(blue.sum()), "faces")


def main():
    obj = load()
    co = coords(obj)
    centre, axis = frame(co[co[:, 2] > HEAD_Z])
    print("FAN rim centre", centre.round(4), "axis", axis.round(4))
    blades = separate(obj, rotor_mask(obj, centre, axis), "Blades")
    obj.name = obj.data.name = "FanBody"
    repaint_grille(obj)
    # Rotor: local Z along the axis (Godot's local Y after the Y-up export), origin on the rim's centre.
    z = Vector(axis)
    x = z.cross(Vector((0, 0, 1))).normalized()
    y = z.cross(x)
    pose = Matrix.Translation(Vector(centre)) @ Matrix((x, y, z)).transposed().to_4x4()
    rotor = bpy.data.objects.new("Rotor", None)
    bpy.context.scene.collection.objects.link(rotor)
    rotor.matrix_world = pose
    blades.data.transform(pose.inverted())
    blades.parent = rotor
    b = coords(blades)
    print("ROTOR faces", len(blades.data.polygons), "body faces", len(obj.data.polygons),
          "radius", np.hypot(b[:, 0], b[:, 1]).max().round(3), "depth", b[:, 2].min().round(3), b[:, 2].max().round(3))
    bpy.ops.object.select_all(action="DESELECT")
    for part in (obj, rotor, blades):
        part.select_set(True)
    bpy.ops.export_scene.gltf(filepath=str(OUT), export_format="GLB", use_selection=True,
                              export_yup=True, export_image_format="JPEG")
    assert OUT.stat().st_size <= 10 * 1024 * 1024, OUT
    print("SPLIT", OUT.name, OUT.stat().st_size, "bytes")


main()
print("RESULT: split standing fan PASS")
