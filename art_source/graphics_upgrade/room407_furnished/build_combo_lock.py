"""T-245 (D-163): the combination padlock on Dat's locker, a real one in place of the PS1 blocks.
Run with Blender 5.2.2: blender -b --factory-startup -P <this file>.

A brass four-wheel combination padlock (the puzzle's code has four digits) hanging through a steel
hasp across the two doors of the closed locker. Its origin is the old lock's (Anchors/DatLocker):
front towards the room (Blender -Y, glTF +Z), the door surface HASP_Y behind it.
  combo_lock.glb  LockBody (body, wheels, digits, hasp and staple)
                  ShacklePivot (on the long leg, where it enters the body) > Shackle
dat_locker.gd lifts the pivot and turns it about the long leg when the puzzle is solved.
The wheels show 4 7 3 6: never the code. Brushed brass and steel are drawn here (numpy), no
downloaded texture; one textured metal material and one black for the engraved digits.
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
OUT = ROOT / "game/assets/models/graphics_pilot/room407_furnished"
SHOWN = "4736"
HASP_Y = 0.034            # the door surface (its raised panels), behind the anchor
BODY = (0.062, 0.020, 0.062)
BODY_AT = Vector((0.0, HASP_Y - 0.0095, -0.009))  # the shackle runs through the staple
LEG_X = 0.016
SHACKLE_RADIUS = 0.0038
ARCH_Z = 0.042            # where the legs become the arch
WHEEL_RADIUS = 0.0098
WHEEL_WIDTH = 0.0105
WHEEL_Z = -0.019
WHEEL_STEP = 0.0132
BRASS, STEEL = 0, 1       # halves of the metal texture


def metal_texture():
    """Brushed brass (left half) and steel (right half): fine streaks along u, a few scratches."""
    size = 256
    rng = np.random.default_rng(245)
    rows = rng.normal(0.0, 1.0, (size, 1))
    streak = np.repeat(rows, size, axis=1)
    grain = rng.normal(0.0, 1.0, (size, size))
    shade = 1.0 + 0.022 * streak + 0.012 * grain
    for _ in range(26):
        y = int(rng.integers(0, size))
        x0 = int(rng.integers(0, size - 40))
        shade[y, x0:x0 + int(rng.integers(12, 40))] += float(rng.choice([-0.07, 0.06]))
    pixels = np.ones((size, size, 4), dtype=np.float32)
    brass = np.array([0.78, 0.60, 0.26])
    steel = np.array([0.74, 0.75, 0.77])
    half = size // 2
    pixels[:, :half, :3] = brass * shade[:, :half, None]
    pixels[:, half:, :3] = steel * shade[:, half:, None]
    image = bpy.data.images.new("combo_lock_metal", size, size, alpha=False)
    image.pixels = np.clip(pixels, 0.0, 1.0).ravel()
    image.filepath_raw = str(HERE / "combo_lock_metal.png")
    image.file_format = "PNG"
    image.save()
    image.pack()
    return image


def materials():
    image = metal_texture()
    metal = bpy.data.materials.new("Lock metal | drawn brushed brass and steel")
    metal.use_nodes = True
    shader = metal.node_tree.nodes["Principled BSDF"]
    texture = metal.node_tree.nodes.new("ShaderNodeTexImage")
    texture.image = image
    metal.node_tree.links.new(texture.outputs["Color"], shader.inputs["Base Color"])
    shader.inputs["Metallic"].default_value = 1.0
    shader.inputs["Roughness"].default_value = 0.34
    ink = bpy.data.materials.new("Lock ink")
    ink.use_nodes = True
    shader = ink.node_tree.nodes["Principled BSDF"]
    shader.inputs["Base Color"].default_value = (0.02, 0.02, 0.02, 1.0)
    shader.inputs["Metallic"].default_value = 0.0
    shader.inputs["Roughness"].default_value = 0.6
    return metal, ink


def paint(bm, faces, half, material=0):
    """UVs for `faces`: their front projection laid into one half of the metal texture."""
    # The first layer is the one exported (a digit's own mesh brings a layer of its own name).
    layer = bm.loops.layers.uv[0] if len(bm.loops.layers.uv) else bm.loops.layers.uv.new("UVMap")
    points = [v.co for face in faces for v in face.verts]
    lo = Vector([min(p[i] for p in points) for i in range(3)])
    hi = Vector([max(p[i] for p in points) for i in range(3)])
    span = Vector([max(hi[i] - lo[i], 1e-5) for i in range(3)])
    for face in faces:
        face.material_index = material
        face.smooth = True
        for loop in face.loops:
            co = loop.vert.co
            # Along the brushing: across the part (and a little with its depth, so sides are not one line).
            u = ((co.x - lo.x) / span.x * 0.8 + (co.y - lo.y) / span.y * 0.2)
            v = (co.z - lo.z) / span.z * 0.8 + (co.y - lo.y) / span.y * 0.2
            loop[layer].uv = (0.5 * half + 0.03 + 0.44 * u, 0.03 + 0.94 * v)


def new_faces(bm, before):
    return [face for face in bm.faces if face not in before]


def rounded_box(bm, centre, size, bevel, half):
    before = set(bm.faces)
    made = bmesh.ops.create_cube(bm, size=1.0)["verts"]
    for v in made:
        v.co = Vector((v.co.x * size[0], v.co.y * size[1], v.co.z * size[2])) + Vector(centre)
    edges = {e for v in made for e in v.link_edges}
    bmesh.ops.bevel(bm, geom=list(edges), offset=bevel, segments=3, affect="EDGES", profile=0.5)
    paint(bm, new_faces(bm, before), half)


def rod(bm, points, radius, half, sides=10):
    """A round rod through `points`, capped."""
    before = set(bm.faces)
    rings = []
    for i, point in enumerate(points):
        ahead = (points[min(i + 1, len(points) - 1)] - points[max(i - 1, 0)]).normalized()
        side = ahead.cross(Vector((0.0, 1.0, 0.0)))
        if side.length < 0.01:
            side = ahead.cross(Vector((1.0, 0.0, 0.0)))
        side.normalize()
        up = side.cross(ahead)
        rings.append([bm.verts.new(point + (side * math.cos(2.0 * math.pi * k / sides)
                                            + up * math.sin(2.0 * math.pi * k / sides)) * radius)
                      for k in range(sides)])
    for a, b in zip(rings, rings[1:]):
        for k in range(sides):
            bm.faces.new((a[k], a[(k + 1) % sides], b[(k + 1) % sides], b[k]))
    bm.faces.new(list(reversed(rings[0])))
    bm.faces.new(rings[-1])
    paint(bm, new_faces(bm, before), half)


def wheel(bm, centre):
    """A knurled number wheel on an axis along x."""
    before = set(bm.faces)
    sides = 20
    rings = []
    for x, radius in ((-0.5, 0.86), (-0.42, 1.0), (0.42, 1.0), (0.5, 0.86)):
        ring = []
        for k in range(sides):
            angle = 2.0 * math.pi * k / sides
            # Ten flats for ten digits, a shallow groove between them.
            r = WHEEL_RADIUS * radius * (1.0 - 0.035 * (k % 2))
            ring.append(bm.verts.new(centre + Vector((x * WHEEL_WIDTH, -math.cos(angle) * r, math.sin(angle) * r))))
        rings.append(ring)
    for a, b in zip(rings, rings[1:]):
        for k in range(sides):
            bm.faces.new((a[k], b[k], b[(k + 1) % sides], a[(k + 1) % sides]))
    bm.faces.new(rings[0])
    bm.faces.new(list(reversed(rings[-1])))
    paint(bm, new_faces(bm, before), BRASS)


def digit(bm, character, centre, turn):
    """An engraved digit on a wheel's rim, `turn` radians round the wheel from its front."""
    bpy.ops.object.text_add()
    text = bpy.context.object
    text.data.body = character
    text.data.size = 0.0056
    text.data.align_x = "CENTER"
    text.data.align_y = "CENTER"
    text.data.resolution_u = 2
    bpy.ops.object.convert(target="MESH")
    mesh = text.data
    # The text lies in XY facing +Z: stand it up facing -Y on the rim, then go round the axle.
    place = (Matrix.Translation(centre) @ Matrix.Rotation(turn, 4, "X")
             @ Matrix.Translation(Vector((0.0, -WHEEL_RADIUS * 0.985, 0.0))) @ Matrix.Rotation(math.pi / 2.0, 4, "X"))
    mesh.transform(place)
    before = set(bm.faces)
    bm.from_mesh(mesh)
    for face in new_faces(bm, before):
        face.material_index = 1
        face.smooth = False
    bpy.data.objects.remove(text, do_unlink=True)


def to_object(bm, name, mats):
    bmesh.ops.recalc_face_normals(bm, faces=[f for f in bm.faces if f.material_index == 0])
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    for mat in mats:
        mesh.materials.append(mat)
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.shade_auto_smooth(angle=math.radians(35.0))
    bpy.ops.object.modifier_apply(modifier=obj.modifiers[-1].name)
    return obj


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    metal, ink = materials()

    bm = bmesh.new()
    rounded_box(bm, BODY_AT, BODY, 0.004, BRASS)
    front = BODY_AT.y - BODY[1] / 2.0
    # The wheels stand out of a steel bezel on the front.
    first = -WHEEL_STEP * (len(SHOWN) - 1) / 2.0
    rounded_box(bm, (0.0, front - 0.0005, WHEEL_Z), (WHEEL_STEP * len(SHOWN) + 0.006, 0.003, 0.026), 0.0012, STEEL)
    for index, character in enumerate(SHOWN):
        centre = Vector((first + WHEEL_STEP * index, front + 0.0035, WHEEL_Z))
        wheel(bm, centre)
        value = int(character)
        for offset in (-1, 0, 1):
            digit(bm, str((value + offset) % 10), centre, math.radians(36.0) * offset)
    # A mark under the wheels where the code is read, and the maker's plate.
    rounded_box(bm, (0.0, front - 0.0004, WHEEL_Z + 0.019), (0.02, 0.0016, 0.0022), 0.0006, STEEL)
    # Collars where the shackle enters.
    top = BODY_AT.z + BODY[2] / 2.0
    for x in (-LEG_X, LEG_X):
        rod(bm, [Vector((x, BODY_AT.y, top - 0.001)), Vector((x, BODY_AT.y, top + 0.0025))], SHACKLE_RADIUS + 0.0018, STEEL, 12)
    # The hasp: a flap from the left door over a staple on the right, both on the door surface.
    rounded_box(bm, (-0.022, HASP_Y - 0.001, 0.052), (0.07, 0.002, 0.03), 0.0008, STEEL)
    rounded_box(bm, (-0.062, HASP_Y - 0.0015, 0.052), (0.012, 0.004, 0.034), 0.001, STEEL)
    for x, z in ((-0.045, 0.062), (-0.045, 0.042), (-0.062, 0.052)):
        rod(bm, [Vector((x, HASP_Y - 0.002, z)), Vector((x, HASP_Y - 0.0042, z))], 0.0028, STEEL, 8)
    staple = [Vector((0.0, HASP_Y - 0.002 - 0.016 * math.sin(math.pi * k / 10), 0.052 - 0.016 * math.cos(math.pi * k / 10)))
              for k in range(11)]
    rod(bm, staple, 0.003, STEEL, 8)
    body = to_object(bm, "LockBody", [metal, ink])

    # The shackle about its pivot: the long leg, where it enters the body.
    pivot_at = Vector((-LEG_X, BODY_AT.y, top))
    bm = bmesh.new()
    path = [Vector((-LEG_X, BODY_AT.y, top - 0.018)), Vector((-LEG_X, BODY_AT.y, ARCH_Z))]
    for k in range(1, 12):
        angle = math.pi * k / 12
        path.append(Vector((-LEG_X * math.cos(angle), BODY_AT.y, ARCH_Z + LEG_X * math.sin(angle))))
    path += [Vector((LEG_X, BODY_AT.y, ARCH_Z)), Vector((LEG_X, BODY_AT.y, top - 0.006))]
    rod(bm, [point - pivot_at for point in path], SHACKLE_RADIUS, STEEL, 12)
    shackle = to_object(bm, "Shackle", [metal])
    pivot = bpy.data.objects.new("ShacklePivot", None)
    bpy.context.collection.objects.link(pivot)
    pivot.location = pivot_at
    shackle.parent = pivot

    bpy.ops.object.select_all(action="DESELECT")
    for obj in (body, pivot, shackle):
        obj.select_set(True)
    path = OUT / "combo_lock.glb"
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True,
                              export_yup=True, export_image_format="AUTO")
    triangles = 0
    for obj in (body, shackle):
        obj.data.calc_loop_triangles()
        triangles += len(obj.data.loop_triangles)
    assert triangles <= 5000, triangles
    print("LOCK", triangles, "triangles", path.stat().st_size, "bytes")


main()
