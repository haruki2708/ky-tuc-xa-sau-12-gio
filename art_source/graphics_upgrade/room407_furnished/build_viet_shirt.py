"""T-245 (D-163): Viet's shirt in his locker, a real folded T-shirt in place of the PS1 blocks.
Run with Blender 5.2.2: blender -b --factory-startup -P <this file>.

A striped cotton T-shirt folded the shop way (sleeves and sides tucked under, the chest up, the
collar at the front edge), 0.27 x 0.30 m, lying on a shelf: origin at the middle of its underside,
the collar towards Blender -Y (glTF +Z). The cloth is the recorded CC0 Rough Linen scan (normal and
roughness as scanned); its colour is that scan woven into navy and off-white stripes here (numpy).
  viet_shirt.glb  node VietShirt, one material
"""
import math
import sys
from pathlib import Path

import bmesh
import bpy
import numpy as np
from mathutils import Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
TEXTURES = HERE.parent / "room407_corner" / "textures"
OUT = ROOT / "game/assets/models/graphics_pilot/room407_furnished"
WIDTH, DEPTH, THICK = 0.27, 0.30, 0.036
NX, NY = 26, 30
CORNER = 0.022           # the folded corners are round
PERIOD = 0.30            # metres of cloth per repeat of the texture
BANDS = 7                # navy and white pairs per repeat
NAVY = np.array([0.10, 0.14, 0.26])
WHITE = np.array([0.80, 0.78, 0.72])
COLLAR_AT = Vector((0.0, -0.098))
COLLAR = (0.052, 0.030)  # the neck opening's half sizes


def stripes():
    """The linen scan's weave, dyed in bands across the chest. Saved beside this script."""
    source = bpy.data.images.load(str(TEXTURES / "rough_linen_color.jpg"))
    width, height = source.size
    scan = np.array(source.pixels[:], dtype=np.float32).reshape(height, width, 4)
    weave = scan[:, :, :3].mean(axis=2, keepdims=True)
    weave = weave / weave.mean()
    rows = (np.arange(height) + 0.5) / height * BANDS
    edge = np.abs((rows % 1.0) - 0.5) * 2.0          # 0 mid band, 1 at its edges
    navy = np.clip((0.5 - np.abs((rows % 1.0) - 0.25) * 2.0) * 40.0 + 0.5, 0.0, 1.0)
    _ = edge
    colour = WHITE[None, None, :] * (1.0 - navy[:, None, None]) + NAVY[None, None, :] * navy[:, None, None]
    pixels = np.ones((height, width, 4), dtype=np.float32)
    pixels[:, :, :3] = np.clip(colour * (0.55 + 0.45 * weave), 0.0, 1.0)
    image = bpy.data.images.new("viet_shirt_color", width, height, alpha=False)
    image.pixels = pixels.ravel()
    image.filepath_raw = str(HERE / "viet_shirt_color.jpg")
    image.file_format = "JPEG"
    image.save()
    image.pack()
    return image


def material():
    mat = bpy.data.materials.new("Viet shirt | CC0 Rough Linen, striped")
    mat.use_nodes = True
    nodes, links = mat.node_tree.nodes, mat.node_tree.links
    bsdf = nodes.get("Principled BSDF")
    colour = nodes.new("ShaderNodeTexImage")
    colour.image = stripes()
    links.new(colour.outputs["Color"], bsdf.inputs["Base Color"])
    bump = nodes.new("ShaderNodeTexImage")
    bump.image = bpy.data.images.load(str(TEXTURES / "rough_linen_normal.jpg"), check_existing=True)
    bump.image.colorspace_settings.name = "Non-Color"
    normal = nodes.new("ShaderNodeNormalMap")
    normal.inputs["Strength"].default_value = 0.7
    links.new(bump.outputs["Color"], normal.inputs["Color"])
    links.new(normal.outputs["Normal"], bsdf.inputs["Normal"])
    arm = nodes.new("ShaderNodeTexImage")
    arm.image = bpy.data.images.load(str(TEXTURES / "rough_linen_arm.jpg"), check_existing=True)
    arm.image.colorspace_settings.name = "Non-Color"
    split = nodes.new("ShaderNodeSeparateColor")
    links.new(arm.outputs["Color"], split.inputs["Color"])
    links.new(split.outputs["Green"], bsdf.inputs["Roughness"])
    bsdf.inputs["Metallic"].default_value = 0.0
    return mat


def outline(u, v):
    """The folded shirt's plan: a rectangle with round corners. (x, y) for u, v in -1..1."""
    x, y = u * WIDTH / 2.0, v * DEPTH / 2.0
    cx, cy = WIDTH / 2.0 - CORNER, DEPTH / 2.0 - CORNER
    dx, dy = abs(x) - cx, abs(y) - cy
    if dx > 0.0 and dy > 0.0:
        scale = CORNER / max(math.hypot(dx, dy), CORNER) if math.hypot(dx, dy) > CORNER else 1.0
        x = math.copysign(cx + dx * scale, x)
        y = math.copysign(cy + dy * scale, y)
    return x, y


def height(x, y):
    """The top of the folded cloth over the shelf."""
    edge = min(WIDTH / 2.0 - abs(x), DEPTH / 2.0 - abs(y))
    # Full height a finger's width in from the edge; the edge itself rolls over.
    roll = math.sqrt(max(0.0, 1.0 - (1.0 - min(edge / 0.016, 1.0)) ** 2))
    z = THICK * (0.62 + 0.38 * roll)
    # The sleeves and sides tucked under lift two soft ridges; the middle sags between them.
    z += 0.0045 * math.exp(-((abs(x) - 0.085) / 0.028) ** 2)
    z -= 0.0025 * math.exp(-(x / 0.04) ** 2) * (0.5 + 0.5 * math.cos(y * 9.0))
    # The hem folded up underneath makes the back third a little thicker.
    z += 0.003 / (1.0 + math.exp(-(y - 0.04) / 0.012))
    # Creases of worn cotton.
    z += 0.0012 * math.sin(x * 61.0 + y * 17.0) * math.sin(y * 43.0 - x * 9.0)
    z += 0.0009 * math.sin(x * 23.0 - y * 71.0)
    # Inside the neck the back of the collar lies lower.
    neck = ((x - COLLAR_AT.x) / COLLAR[0]) ** 2 + ((y - COLLAR_AT.y) / COLLAR[1]) ** 2
    if neck < 1.0:
        z -= 0.004 * (1.0 - neck) ** 0.5
    return z


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    mat = material()
    bm = bmesh.new()
    layer = bm.loops.layers.uv.new("UVMap")

    def cloth_uv(co):
        return (co.x / PERIOD + 0.5, co.y / PERIOD + 0.5)

    # The top.
    grid = []
    for j in range(NY + 1):
        row = []
        for i in range(NX + 1):
            x, y = outline(i / NX * 2.0 - 1.0, j / NY * 2.0 - 1.0)
            row.append(bm.verts.new((x, y, height(x, y))))
        grid.append(row)
    for j in range(NY):
        for i in range(NX):
            bm.faces.new((grid[j][i], grid[j][i + 1], grid[j + 1][i + 1], grid[j + 1][i]))
    # The sides: three folded layers showing as two shallow grooves, tucked in at the shelf.
    border = [grid[0][i] for i in range(NX)] + [grid[j][NX] for j in range(NY)] \
        + [grid[NY][i] for i in range(NX, 0, -1)] + [grid[j][0] for j in range(NY, 0, -1)]
    rings = [border]
    for level, inset in ((0.72, 0.0022), (0.5, -0.0006), (0.3, 0.002), (0.0, 0.004)):
        ring = []
        for v in border:
            out = Vector((v.co.x, v.co.y, 0.0))
            out = out.normalized() * inset if out.length > 0.0 else out
            ring.append(bm.verts.new((v.co.x - out.x, v.co.y - out.y, v.co.z * level)))
        rings.append(ring)
    count = len(border)
    for a, b in zip(rings, rings[1:]):
        for k in range(count):
            bm.faces.new((a[k], b[k], b[(k + 1) % count], a[(k + 1) % count]))
    bm.faces.new(rings[-1])
    for face in bm.faces:
        for loop in face.loops:
            loop[layer].uv = cloth_uv(loop.vert.co)
    # The side walls take the cloth along the edge, a band of it per layer.
    # (The top's metric UV would smear straight down them.)
    for a, b in zip(rings, rings[1:]):
        pass
    for face in bm.faces:
        if abs(face.normal.z) < 0.5 if face.normal.length else False:
            for loop in face.loops:
                co = loop.vert.co
                loop[layer].uv = ((co.x + co.y) / PERIOD + 0.5, co.z / PERIOD * 4.0 + 0.11)

    # The collar: a ribbed navy band round the neck, lying on the chest.
    before = set(bm.faces)
    around, sides = 28, 8
    navy_v = (0.25 + 0.5) / BANDS  # the middle of a navy band
    loops = []
    for a in range(around):
        angle = 2.0 * math.pi * a / around
        centre = Vector((COLLAR_AT.x + COLLAR[0] * math.cos(angle), COLLAR_AT.y + COLLAR[1] * math.sin(angle)))
        outward = Vector((math.cos(angle) / COLLAR[0], math.sin(angle) / COLLAR[1])).normalized()
        base = height(centre.x, centre.y)
        ring = []
        for s in range(sides):
            turn = 2.0 * math.pi * s / sides
            offset = outward * (0.0075 * math.cos(turn))
            ring.append(bm.verts.new((centre.x + offset.x, centre.y + offset.y,
                                      base + 0.0012 + 0.0034 * math.sin(turn))))
        loops.append(ring)
    for a in range(around):
        b = (a + 1) % around
        for s in range(sides):
            t = (s + 1) % sides
            face = bm.faces.new((loops[a][s], loops[b][s], loops[b][t], loops[a][t]))
            for loop in face.loops:
                index = a if loop.vert in loops[a] else a + 1
                loop[layer].uv = (index / around * 2.0, navy_v + 0.004 * math.sin(index * 2.1))
    _ = before
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    for face in bm.faces:
        face.smooth = True

    mesh = bpy.data.meshes.new("VietShirt")
    bm.to_mesh(mesh)
    bm.free()
    obj = bpy.data.objects.new("VietShirt", mesh)
    bpy.context.collection.objects.link(obj)
    mesh.materials.append(mat)
    bpy.ops.object.select_all(action="DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.shade_auto_smooth(angle=math.radians(50.0))
    bpy.ops.object.modifier_apply(modifier=obj.modifiers[-1].name)
    path = OUT / "viet_shirt.glb"
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True,
                              export_yup=True, export_image_format="JPEG")
    mesh.calc_loop_triangles()
    assert len(mesh.loop_triangles) <= 5000, len(mesh.loop_triangles)
    assert path.stat().st_size <= 10 * 1024 * 1024
    print("SHIRT", len(mesh.loop_triangles), "triangles", path.stat().st_size, "bytes")


main()
