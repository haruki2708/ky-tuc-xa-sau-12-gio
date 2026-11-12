"""T-249 (D-165): chapter 3's iron bar, a real one in place of the grey PS1 boxes.
Run with Blender 5.2.2: blender -b --factory-startup -P <this file>.

A length of old 27 mm water pipe, 0.85 m, rusted, one end still threaded.
  iron_bar.glb  Armature > Bar   the whole bar on seven bones along it (Bar0 the grip end ... Bar6
                                 the far end): IronBarWeapon bends it at the six joints between
                                 them as it wears (0.26 to 0.46 m from the grip end)
                HalfGrip, HalfTip  the two pieces of a bar that broke where it had bent, each about
                                 its own middle, placed as they sit in the fully bent bar
Frame (as Godot sees it): the bar runs along +Z, its middle at the origin, the grip end at
-0.425 and the far end at +0.425; it bends toward +Y.
Rust, bare steel and scratches are drawn here (numpy), no downloaded texture.
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
ROOT = HERE.parents[3]
OUT = ROOT / "game/assets/models/graphics_pilot/protagonist"
LENGTH = 0.85
RADIUS = 0.0135
WALL = 0.0026
SIDES = 16
# Where the bar bends (metres from the grip end) and how far when it is worn out (radians): as the
# PS1 bar did (IronBarWeapon: 0.8 rad at no hits left).
BEND_FROM = 0.26
BEND_TO = 0.50
BEND_MAX = 0.8
JOINTS = 6
BREAK_AT = 0.38
TEX_AROUND = 128
TEX_ALONG = 1024
THREAD = 0.028  # the threaded length at the far end


def smooth_noise(rng, shape, scale):
    """Tileable noise: white noise low-passed at `scale` pixels, to unit variance."""
    white = rng.normal(0.0, 1.0, shape)
    fy = np.fft.fftfreq(shape[0])[:, None]
    fx = np.fft.rfftfreq(shape[1])[None, :]
    lowpass = np.exp(-((fy * scale[0]) ** 2 + (fx * scale[1]) ** 2) * 18.0)
    out = np.fft.irfft2(np.fft.rfft2(white) * lowpass, s=shape)
    return out / max(out.std(), 1e-9)


def smoothstep(a, b, x):
    t = np.clip((x - a) / (b - a), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)


def textures():
    """Base colour, occlusion-roughness-metal and normal (rows run along the bar from the grip end,
    columns go round it)."""
    rng = np.random.default_rng(249)
    shape = (TEX_ALONG, TEX_AROUND)
    along = (np.arange(TEX_ALONG) + 0.5)[:, None] / TEX_ALONG * LENGTH
    blobs = smooth_noise(rng, shape, (90.0, 40.0))
    patches = smooth_noise(rng, shape, (28.0, 16.0))
    fine = smooth_noise(rng, shape, (5.0, 4.0))
    grain = smooth_noise(rng, shape, (1.6, 1.6))
    # More rust toward both ends (they lay in the wet), less where hands would have held it.
    ends = 0.55 * np.exp(-along / 0.09) + 0.75 * np.exp(-(LENGTH - along) / 0.12)
    rust = smoothstep(-0.15, 0.55, blobs * 0.7 + patches * 0.45 + ends * 1.6 - 0.25 + fine * 0.12)
    pits = smoothstep(1.35, 1.9, fine + patches * 0.3) * rust
    # Scratches down to bright steel: long ones along the bar, short ones across.
    scratch = np.zeros(shape)
    for _ in range(46):
        row = int(rng.integers(0, TEX_ALONG - 130))
        column = int(rng.integers(0, TEX_AROUND))
        length = int(rng.integers(30, 130))
        drift = rng.normal(0.0, 0.25, length).cumsum()
        for step in range(length):
            scratch[row + step, int(column + drift[step]) % TEX_AROUND] = float(rng.uniform(0.5, 1.0))
    for _ in range(30):
        row = int(rng.integers(0, TEX_ALONG))
        column = int(rng.integers(0, TEX_AROUND))
        for step in range(int(rng.integers(6, 22))):
            scratch[row, (column + step) % TEX_AROUND] = float(rng.uniform(0.4, 0.9))
    scratch *= 1.0 - 0.6 * rust
    # The thread at the far end: ridges every 3.3 mm.
    threaded = (along > LENGTH - THREAD).astype(float) * np.ones(shape)
    ridge = 0.5 + 0.5 * np.sin(along / 0.0033 * 2.0 * math.pi) * np.ones(shape)

    steel = np.array([0.27, 0.265, 0.26])[None, None, :] * (1.0 + 0.07 * grain + 0.05 * patches)[:, :, None]
    scale = np.array([0.17, 0.18, 0.2])[None, None, :] * np.ones(shape)[:, :, None]
    steel = steel * (1.0 - 0.45 * smoothstep(0.2, 1.0, blobs)[:, :, None]) + scale * 0.45 * smoothstep(0.2, 1.0, blobs)[:, :, None]
    orange = np.array([0.44, 0.215, 0.085])
    brown = np.array([0.23, 0.105, 0.05])
    tone = smoothstep(-1.0, 1.0, fine * 0.8 + patches * 0.5)[:, :, None]
    rusty = (brown[None, None, :] * (1.0 - tone) + orange[None, None, :] * tone) * (1.0 + 0.1 * grain)[:, :, None]
    colour = steel * (1.0 - rust[:, :, None]) + rusty * rust[:, :, None]
    colour *= (1.0 - 0.3 * pits)[:, :, None]
    colour = colour * (1.0 - scratch[:, :, None]) + np.array([0.62, 0.62, 0.63])[None, None, :] * scratch[:, :, None]
    colour *= (1.0 - 0.35 * threaded * (1.0 - ridge))[:, :, None]

    roughness = 0.44 + 0.08 * grain
    roughness = roughness * (1.0 - rust) + (0.9 + 0.05 * grain) * rust
    roughness = roughness * (1.0 - scratch) + 0.3 * scratch
    metal = 0.9 * (1.0 - rust) + 0.12 * rust
    metal = metal * (1.0 - scratch) + 1.0 * scratch
    occlusion = 1.0 - 0.5 * pits - 0.3 * threaded * (1.0 - ridge)

    # Height in metres: rust stands a little proud and is bumpy, pits and scratches go in, the thread.
    height = rust * (0.00035 + 0.00025 * fine) - pits * 0.0005 - scratch * 0.00018 + grain * 0.00003
    height += threaded * ridge * 0.0007
    texel_along = LENGTH / TEX_ALONG
    texel_around = 2.0 * math.pi * RADIUS / TEX_AROUND
    d_around = (np.roll(height, -1, axis=1) - np.roll(height, 1, axis=1)) / (2.0 * texel_around)
    d_along = np.gradient(height, texel_along, axis=0)
    normal = np.stack([-d_around, -d_along, np.ones(shape)], axis=2)
    normal /= np.linalg.norm(normal, axis=2, keepdims=True)

    def image(name, rgb, colour_space):
        pixels = np.ones((TEX_ALONG, TEX_AROUND, 4), dtype=np.float32)
        pixels[:, :, :3] = np.clip(rgb, 0.0, 1.0)
        made = bpy.data.images.new(name, TEX_AROUND, TEX_ALONG, alpha=False)
        made.colorspace_settings.name = colour_space
        made.pixels = pixels.ravel()
        made.filepath_raw = str(HERE / (name + ".png"))
        made.file_format = "PNG"
        made.save()
        made.pack()
        return made

    # Blender's pixel rows start at the bottom: row 0 is v = 0, the grip end.
    return (image("iron_bar_colour", colour, "sRGB"),
            image("iron_bar_orm", np.stack([occlusion, roughness, metal], axis=2), "Non-Color"),
            image("iron_bar_normal", normal * 0.5 + 0.5, "Non-Color"))


def materials():
    colour, orm, normal = textures()
    steel = bpy.data.materials.new("Iron bar | drawn rusted steel pipe")
    steel.use_nodes = True
    tree = steel.node_tree
    shader = tree.nodes["Principled BSDF"]
    base = tree.nodes.new("ShaderNodeTexImage")
    base.image = colour
    tree.links.new(base.outputs["Color"], shader.inputs["Base Color"])
    packed = tree.nodes.new("ShaderNodeTexImage")
    packed.image = orm
    split = tree.nodes.new("ShaderNodeSeparateColor")
    tree.links.new(packed.outputs["Color"], split.inputs["Color"])
    tree.links.new(split.outputs["Green"], shader.inputs["Roughness"])
    tree.links.new(split.outputs["Blue"], shader.inputs["Metallic"])
    bump = tree.nodes.new("ShaderNodeTexImage")
    bump.image = normal
    to_normal = tree.nodes.new("ShaderNodeNormalMap")
    tree.links.new(bump.outputs["Color"], to_normal.inputs["Color"])
    tree.links.new(to_normal.outputs["Normal"], shader.inputs["Normal"])
    bore = bpy.data.materials.new("Iron bar bore")
    bore.use_nodes = True
    shader = bore.node_tree.nodes["Principled BSDF"]
    shader.inputs["Base Color"].default_value = (0.012, 0.01, 0.008, 1.0)
    shader.inputs["Metallic"].default_value = 0.0
    shader.inputs["Roughness"].default_value = 0.95
    return steel, bore


def centre_line(s, bend):
    """The bar's middle at `s` metres from the grip end and the way it runs there, bent `bend`
    radians in all (Blender: the bar runs along -Y, bends toward +Z)."""
    kappa = bend / (BEND_TO - BEND_FROM)
    if s <= BEND_FROM or bend == 0.0:
        return Vector((0.0, LENGTH / 2.0 - s, 0.0)), Vector((0.0, -1.0, 0.0))
    at_start = Vector((0.0, LENGTH / 2.0 - BEND_FROM, 0.0))
    angle = kappa * (min(s, BEND_TO) - BEND_FROM)
    point = at_start + Vector((0.0, -math.sin(angle), 1.0 - math.cos(angle))) / kappa
    ahead = Vector((0.0, -math.cos(angle), math.sin(angle)))
    if s > BEND_TO:
        point += ahead * (s - BEND_TO)
    return point, ahead


def ring(bm, centre, ahead, radius, squash=1.0, widen=1.0, jag=None):
    """Sixteen points round `centre`, square to `ahead`; `squash` flattens the ring in the plane the
    bar bends in, `widen` spreads it across; `jag` moves each point along the bar (a torn edge)."""
    across = Vector((1.0, 0.0, 0.0))
    up = across.cross(ahead).normalized()
    made = []
    for k in range(SIDES):
        angle = 2.0 * math.pi * k / SIDES
        point = centre + (across * math.cos(angle) * widen + up * math.sin(angle) * squash) * radius
        if jag is not None:
            point += ahead * jag[k]
        made.append(bm.verts.new(point))
    return made


def bridge(bm, a, b, layer, v_a, v_b, material=0, flip=False, smooth=True):
    for k in range(SIDES):
        n = (k + 1) % SIDES
        corners = [a[k], a[n], b[n], b[k]]
        uvs = [(k / SIDES, v_a), ((k + 1) / SIDES, v_a), ((k + 1) / SIDES, v_b), (k / SIDES, v_b)]
        if flip:
            corners.reverse()
            uvs.reverse()
        face = bm.faces.new(corners)
        face.material_index = material
        face.smooth = smooth
        for loop, uv in zip(face.loops, uvs):
            loop[layer].uv = uv


def end(bm, layer, s, bend, outward, squash=1.0, widen=1.0, jag=None):
    """The open end at `s`: the wall's rim, a little of the bore and a dark plug in it. `outward`
    +1 for the far end of a piece, -1 for its near end."""
    centre, ahead = centre_line(s, bend)
    v = s / LENGTH
    outer = ring(bm, centre, ahead, RADIUS, squash, widen, jag)
    inner = ring(bm, centre, ahead, RADIUS - WALL, squash, widen, jag)
    deep_centre, deep_ahead = centre_line(s - outward * 0.03, bend)
    deep = ring(bm, deep_centre, deep_ahead, RADIUS - WALL, 1.0, 1.0)
    # Windings: the rim faces out of the piece, the bore faces the bar's middle line, the plug the opening.
    far = outward > 0
    bridge(bm, outer, inner, layer, v, v, 0, far, False)
    bridge(bm, inner, deep, layer, v, v - outward * 0.03 / LENGTH, 1, far, True)
    plug = bm.faces.new(list(reversed(deep)) if far else deep)
    plug.material_index = 1
    for loop in plug.loops:
        loop[layer].uv = (0.5, v)


def piece(bm, layer, stations, bend, near_torn=False, far_torn=False, seed=0):
    """A length of pipe through `stations` (metres from the grip end) of the bar bent `bend`."""
    rng = np.random.default_rng(249 + seed)
    rings = []
    shapes = []
    for index, s in enumerate(stations):
        centre, ahead = centre_line(s, bend)
        squash, widen, jag = 1.0, 1.0, None
        # A pipe that breaks where it bent is flattened there and tears unevenly.
        for torn, edge, sign in ((near_torn, stations[0], 1.0), (far_torn, stations[-1], -1.0)):
            if not torn:
                continue
            near = 1.0 - min(abs(s - edge) / 0.035, 1.0)
            squash = min(squash, 1.0 - 0.42 * near * near)
            widen = max(widen, 1.0 + 0.2 * near * near)
            if s == edge:
                jag = [float(sign * rng.uniform(-0.005, 0.004)) for _ in range(SIDES)]
        rings.append(ring(bm, centre, ahead, RADIUS, squash, widen, jag))
        shapes.append((squash, widen, jag))
    for index in range(len(stations) - 1):
        bridge(bm, rings[index], rings[index + 1], layer, stations[index] / LENGTH, stations[index + 1] / LENGTH, 0, True)
    end(bm, layer, stations[0], bend, -1.0, *shapes[0])
    end(bm, layer, stations[-1], bend, 1.0, *shapes[-1])


def stations(start, stop):
    """Ring positions: every centimetre where the bar bends, coarser elsewhere."""
    marks = {round(start, 4), round(stop, 4)}
    s = 0.0
    while s < LENGTH + 1e-6:
        fine = BEND_FROM - 0.02 <= s <= BEND_TO + 0.02
        if start < s < stop:
            marks.add(round(s, 4))
        s += 0.01 if fine else 0.04
    return sorted(marks)


def to_object(bm, name, mats, origin=None, turn=0.0):
    """`origin`, `turn`: the object's own place and its turn about X (so a piece's own axis runs along
    it); the mesh is put back by the same, so it sits where it was made."""
    mesh = bpy.data.meshes.new(name)
    if origin is not None:
        bmesh.ops.translate(bm, verts=bm.verts, vec=-origin)
        bmesh.ops.rotate(bm, verts=bm.verts, cent=(0.0, 0.0, 0.0), matrix=Matrix.Rotation(-turn, 3, "X"))
    bm.normal_update()
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    for mat in mats:
        mesh.materials.append(mat)
    if origin is not None:
        obj.location = origin
        obj.rotation_euler = (turn, 0.0, 0.0)
    return obj


def rig(bar):
    """Seven bones along the bar; each ring of the mesh follows the bone it lies on, blended over
    2 cm either side of a joint."""
    data = bpy.data.armatures.new("Armature")
    armature = bpy.data.objects.new("Armature", data)
    bpy.context.collection.objects.link(armature)
    bpy.context.view_layer.objects.active = armature
    bpy.ops.object.mode_set(mode="EDIT")
    step = (BEND_TO - BEND_FROM) / JOINTS
    starts = [0.0] + [BEND_FROM + step * k for k in range(JOINTS)]
    stops = starts[1:] + [LENGTH]
    parent = None
    for index, (a, b) in enumerate(zip(starts, stops)):
        bone = data.edit_bones.new("Bar%d" % index)
        bone.head = (0.0, LENGTH / 2.0 - a, 0.0)
        bone.tail = (0.0, LENGTH / 2.0 - b, 0.0)
        bone.roll = 0.0
        bone.parent = parent
        bone.use_connect = parent is not None
        parent = bone
    bpy.ops.object.mode_set(mode="OBJECT")
    groups = [bar.vertex_groups.new(name="Bar%d" % index) for index in range(len(starts))]
    for vertex in bar.data.vertices:
        s = LENGTH / 2.0 - vertex.co.y
        weights = [0.0] * len(starts)
        # The joint this point is nearest to shares it between the bones either side.
        index = 0
        for k in range(1, len(starts)):
            if s >= starts[k]:
                index = k
        weights[index] = 1.0
        for k in range(1, len(starts)):
            near = (s - (starts[k] - step / 2.0)) / step
            if 0.0 < near < 1.0:
                weights = [0.0] * len(starts)
                weights[k - 1] = 1.0 - near
                weights[k] = near
        for k, weight in enumerate(weights):
            if weight > 0.0:
                groups[k].add([vertex.index], weight, "REPLACE")
    modifier = bar.modifiers.new("Armature", "ARMATURE")
    modifier.object = armature
    bar.parent = armature
    return armature


def triangles(obj):
    obj.data.calc_loop_triangles()
    return len(obj.data.loop_triangles)


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    mats = list(materials())

    bm = bmesh.new()
    layer = bm.loops.layers.uv.new("UVMap")
    piece(bm, layer, stations(0.0, LENGTH), 0.0)
    bar = to_object(bm, "Bar", mats)
    armature = rig(bar)

    halves = []
    for name, start, stop, seed in (("HalfGrip", 0.0, BREAK_AT, 1), ("HalfTip", BREAK_AT, LENGTH, 2)):
        bm = bmesh.new()
        layer = bm.loops.layers.uv.new("UVMap")
        piece(bm, layer, stations(start, stop), BEND_MAX, near_torn=start > 0.0, far_torn=stop < LENGTH, seed=seed)
        # About the middle of its chord, its own axis along the chord (the bar's own runs along -Y).
        a, _ = centre_line(start, BEND_MAX)
        b, _ = centre_line(stop, BEND_MAX)
        chord = b - a
        halves.append(to_object(bm, name, mats, (a + b) / 2.0, -math.atan2(chord.z, -chord.y)))

    OUT.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in [armature, bar] + halves:
        obj.select_set(True)
    path = OUT / "iron_bar.glb"
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True, export_yup=True,
                              export_image_format="AUTO", export_animations=False, export_skins=True)
    count = triangles(bar)
    pieces = sum(triangles(half) for half in halves)
    assert count <= 5000 and pieces <= 5000, (count, pieces)
    print("IRON_BAR bar %d triangles, the two halves %d, %d bytes" % (count, pieces, path.stat().st_size))
    for half in halves:
        print("IRON_BAR %s at %s turned %.3f" % (half.name, tuple(round(c, 4) for c in half.location), half.rotation_euler.x))


main()
