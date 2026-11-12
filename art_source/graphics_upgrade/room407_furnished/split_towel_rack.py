"""T-245 (D-163): the bathroom towel rack and the cloth on it become two models.
Run with Blender 5.2.2: blender -b --factory-startup -P <this file>.

The baked Tripo rack (room407_batch3/towel_rack.glb) is one mesh: the rack, a pair of shorts on a
hook, and a green cloth hung over the bar (joined to the rack where it touches). Chapter 2's rag is
taken from this rack; the owner took "the rag" and the green cloth stayed. The green cloth is cut
out as the rag:
  rack_rag.glb         the green cloth alone, as Tripo made it (node RackRag)
  towel_rack_bare.glb  the rack and the shorts (nodes TowelRack, Shorts)
Both keep the rack's origin, so they are placed with one transform and line up as before. Behind the
cloth the Tripo plate was torn and pulled into it, so the rack itself is built again here, plain
chromed steel on the same measures (plate, bar under the cloth, hooks); the shorts are Tripo's.
"""
import math
import sys
from pathlib import Path

import bmesh
import bpy
from mathutils import Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SRC = ROOT / "game/assets/models/graphics_pilot/room407_batch3/towel_rack.glb"
OUT = ROOT / "game/assets/models/graphics_pilot/room407_furnished"
WELD = 0.0004      # the bake splits the surface along UV seams: verts this close are one point
GREEN_OVER = 1.12  # a face is the cloth when green leads red and blue by this much
STRETCH = 0.045    # a face of the rack by the cloth with an edge this long is a join
CLOTH_TOP = 0.318  # the cloth lies over the bar no higher than this (Blender z, the rack's own space)
GROW_RINGS = 6
# The rebuilt rack (Blender metres, the Tripo rack's own space: +Y into the room, the wall at -Y).
PLATE_X = 0.225
PLATE_Y = (-0.059, -0.049)
PLATE_Z = (0.25, 0.361)
BAR_X = 0.2
BAR_RADIUS = 0.007
HOOKS_X = (-0.185, -0.13, 0.13, 0.185)
HOOK_RADIUS = 0.0038
HOOK_REACH = 0.034
HOOK_FOOT = 0.2
MATERIAL = None


def largest_patch(faces):
    """The largest edge-connected set of `faces`."""
    best = set()
    left = set(faces)
    while left:
        patch = set()
        stack = [left.pop()]
        while stack:
            face = stack.pop()
            patch.add(face)
            for edge in face.edges:
                for other in edge.link_faces:
                    if other in left:
                        left.discard(other)
                        stack.append(other)
        if len(patch) > len(best):
            best = patch
    return best


def to_object(bm, name, material):
    mesh = bpy.data.meshes.new(name)
    bm.to_mesh(mesh)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    mesh.materials.append(material)
    for poly in mesh.polygons:
        poly.use_smooth = True
    return obj


def export(name, objects):
    bpy.ops.object.select_all(action="DESELECT")
    for obj in objects:
        obj.select_set(True)
    path = OUT / (name + ".glb")
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True,
                              export_yup=True, export_image_format="JPEG")
    triangles = 0
    points = []
    for obj in objects:
        obj.data.calc_loop_triangles()
        triangles += len(obj.data.loop_triangles)
        points += [obj.matrix_world @ v.co for v in obj.data.vertices]
    lo = Vector([min(p[i] for p in points) for i in range(3)])
    hi = Vector([max(p[i] for p in points) for i in range(3)])
    assert triangles <= 5000, name
    print("SPLIT", name, [o.name for o in objects], triangles, "triangles", path.stat().st_size, "bytes",
          "blender bounds", tuple(round(c, 3) for c in lo), tuple(round(c, 3) for c in hi))


def box(bm, lo, hi, bevel=0.0):
    made = bmesh.ops.create_cube(bm, size=1.0)["verts"]
    lo, hi = Vector(lo), Vector(hi)
    for v in made:
        v.co = Vector(((v.co.x + 0.5) * (hi.x - lo.x) + lo.x, (v.co.y + 0.5) * (hi.y - lo.y) + lo.y,
                       (v.co.z + 0.5) * (hi.z - lo.z) + lo.z))
    if bevel > 0.0:
        edges = {e for v in made for e in v.link_edges}
        bmesh.ops.bevel(bm, geom=list(edges), offset=bevel, segments=2, affect="EDGES", profile=0.5)


def tube(bm, points, radius, sides=10):
    """A round rod through `points`, capped."""
    rings = []
    for i, point in enumerate(points):
        ahead = (points[min(i + 1, len(points) - 1)] - points[max(i - 1, 0)]).normalized()
        side = ahead.cross(Vector((1.0, 0.0, 0.0)))
        if side.length < 0.01:
            side = ahead.cross(Vector((0.0, 0.0, 1.0)))
        side.normalize()
        up = side.cross(ahead)
        ring = []
        for k in range(sides):
            angle = 2.0 * math.pi * k / sides
            ring.append(bm.verts.new(point + (side * math.cos(angle) + up * math.sin(angle)) * radius))
        rings.append(ring)
    for a, b in zip(rings, rings[1:]):
        for k in range(sides):
            bm.faces.new((a[k], a[(k + 1) % sides], b[(k + 1) % sides], b[k]))
    bm.faces.new(list(reversed(rings[0])))
    bm.faces.new(rings[-1])


def build_rack(bar, hanger):
    """A chromed wall rack in the Tripo rack's place: back plate on the wall (-Y), a bar before it
    under the cloth, four hooks under the plate (one of them in the hanger of the shorts)."""
    bm = bmesh.new()
    box(bm, (-PLATE_X, PLATE_Y[0], PLATE_Z[0]), (PLATE_X, PLATE_Y[1], PLATE_Z[1]), 0.003)
    # The bar and the two arms that carry it.
    tube(bm, [Vector((-BAR_X, bar.y, bar.z)), Vector((BAR_X, bar.y, bar.z))], BAR_RADIUS, 12)
    for x in (-BAR_X, BAR_X):
        tube(bm, [Vector((x, PLATE_Y[1] - 0.002, bar.z)), Vector((x, bar.y + BAR_RADIUS + 0.004, bar.z))],
             BAR_RADIUS + 0.002, 10)
    # Screw heads at the corners.
    for x in (-PLATE_X + 0.018, PLATE_X - 0.018):
        for z in (PLATE_Z[0] + 0.016, PLATE_Z[1] - 0.016):
            tube(bm, [Vector((x, PLATE_Y[1] - 0.001, z)), Vector((x, PLATE_Y[1] + 0.003, z))], 0.0055, 10)
    # Hooks: down from the foot of the plate, round under, up at the front.
    hooks = [x for x in HOOKS_X if abs(x - hanger.x) > 0.04] + [hanger.x]
    for x in hooks:
        foot = hanger.z - HOOK_RADIUS - 0.022 if x == hanger.x else HOOK_FOOT
        back = PLATE_Y[1] + HOOK_RADIUS
        path = [Vector((x, back, PLATE_Z[0] + 0.012)), Vector((x, back, foot + 0.02))]
        for step in range(1, 8):
            angle = math.pi * step / 8
            path.append(Vector((x, back + HOOK_REACH * 0.5 * (1.0 - math.cos(angle)),
                                foot + 0.02 - 0.02 * math.sin(angle))))
        path.append(Vector((x, back + HOOK_REACH, foot + 0.034)))
        tube(bm, path, HOOK_RADIUS, 8)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    chrome = bpy.data.materials.new("Rack chrome")
    chrome.use_nodes = True
    shader = chrome.node_tree.nodes["Principled BSDF"]
    shader.inputs["Base Color"].default_value = (0.72, 0.74, 0.76, 1.0)
    shader.inputs["Metallic"].default_value = 1.0
    shader.inputs["Roughness"].default_value = 0.3
    rack = to_object(bm, "TowelRack", chrome)
    bm.free()
    bpy.ops.object.select_all(action="DESELECT")
    rack.select_set(True)
    bpy.context.view_layer.objects.active = rack
    bpy.ops.object.shade_auto_smooth(angle=math.radians(40.0))
    bpy.ops.object.modifier_apply(modifier=rack.modifiers[-1].name)
    return rack


def main():
    global MATERIAL
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=str(SRC))
    obj = next(o for o in bpy.data.objects if o.type == "MESH")
    for other in list(bpy.data.objects):
        if other is not obj:
            bpy.data.objects.remove(other, do_unlink=True)
    obj.parent = None
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    mesh = obj.data
    MATERIAL = mesh.materials[0]

    image = next(node.image for node in MATERIAL.node_tree.nodes
                 if node.type == "TEX_IMAGE" and node.image and "basecolor" in node.image.name.lower())
    width, height = image.size
    pixels = image.pixels[:]

    def colour_at(u, v):
        x = int(u % 1.0 * (width - 1))
        y = int(v % 1.0 * (height - 1))
        at = (y * width + x) * 4
        return Vector(pixels[at:at + 3])

    bm = bmesh.new()
    bm.from_mesh(mesh)
    # UVs are per face corner: welding the points keeps the seams and gives the mesh its real edges.
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=WELD)
    uv_layer = bm.loops.layers.uv.active

    # The cloth is the green of the baked base colour; the rack is chrome, the shorts are black.
    green = set()
    for face in bm.faces:
        points = [loop[uv_layer].uv for loop in face.loops]
        centre = sum(points, Vector((0.0, 0.0))) / len(points)
        # Inside the face (the corners sit on the UV island's edge, where the bake bleeds).
        total = colour_at(*centre)
        for point in points:
            total += colour_at(*(centre.lerp(point, 0.5)))
        r, g, b = total / (len(points) + 1)
        if g > r * GREEN_OVER and g > b * GREEN_OVER:
            green.add(face)
    # Behind the cloth (the wall side) the bake pulled the plate down to it: faces that reach above
    # the bar are the plate's, and a long edge next to the cloth is a join, whatever their colour.
    spikes = {face for face in bm.faces if max(v.co.z for v in face.verts) > CLOTH_TOP}
    stretched = spikes | {face for face in bm.faces if max(e.calc_length() for e in face.edges) > STRETCH}
    spikes |= {face for face in stretched if max(v.co.z for v in face.verts) > CLOTH_TOP - 0.03}
    cloth = largest_patch(green - spikes)
    # A few rings of the faces all but walled in by it: dark folds, and the bleed along seams.
    for _ring in range(GROW_RINGS):
        added = set()
        for face in cloth:
            for edge in face.edges:
                for other in edge.link_faces:
                    if other in cloth or other in added or other in spikes:
                        continue
                    # Up by the bar what is not green is the rack.
                    if max(v.co.z for v in other.verts) > CLOTH_TOP - 0.05:
                        continue
                    near = {f for e in other.edges for f in e.link_faces if f is not other}
                    if len(near & cloth) * 3 >= len(near) * 2:
                        added.add(other)
        if not added:
            break
        cloth |= added
    # What joined the two: stray green bits, and the stretched faces touching the cloth.
    cloth_verts = {v for face in cloth for v in face.verts}
    drop = (green - cloth) | {face for face in stretched - cloth if any(v in cloth_verts for v in face.verts)}
    print("SPLIT green", len(green), "cloth", len(cloth), "dropped", len(drop), "of", len(bm.faces))
    assert 300 < len(cloth) < len(bm.faces) // 2, "the green cloth was not found as one piece"

    # The shorts hang loose from their hook: the piece of what is left that reaches lowest.
    rest = set(bm.faces) - cloth - drop
    lowest = min(rest, key=lambda face: min(v.co.z for v in face.verts))
    shorts = set()
    stack = [lowest]
    while stack:
        face = stack.pop()
        if face in shorts:
            continue
        shorts.add(face)
        for edge in face.edges:
            for other in edge.link_faces:
                if other in rest and other not in shorts:
                    stack.append(other)
    highest = max(rest, key=lambda face: max(v.co.z for v in face.verts))
    assert highest not in shorts, "the shorts are not a loose piece"
    for face in bm.faces:
        face.tag = face in cloth
        face.select = face in shorts

    # The rag: the cloth as Tripo made it.
    part = bm.copy()
    bmesh.ops.delete(part, geom=[face for face in part.faces if not face.tag], context="FACES")
    top = max(v.co.z for v in part.verts)
    over = [v.co for v in part.verts if v.co.z > top - 0.02]
    bar = Vector((0.0, sum(co.y for co in over) / len(over), top - BAR_RADIUS - 0.004))
    rag = to_object(part, "RackRag", MATERIAL)
    part.free()
    export("rack_rag", [rag])

    # The rack: built clean, with the shorts Tripo made on their hook.
    part = bm.copy()
    bmesh.ops.delete(part, geom=[face for face in part.faces if not face.select], context="FACES")
    hanger = max(part.verts, key=lambda v: v.co.z).co.copy()
    worn = to_object(part, "Shorts", MATERIAL)
    part.free()
    rack = build_rack(bar, hanger)
    export("towel_rack_bare", [rack, worn])
    print("SPLIT bar", tuple(round(c, 3) for c in bar), "hanger", tuple(round(c, 3) for c in hanger))


main()
