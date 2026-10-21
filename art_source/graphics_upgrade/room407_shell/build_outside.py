"""T-222: what room 407's balcony looks out on, at night (Blender 5.2.2):
  blender -b --factory-startup -P art_source/graphics_upgrade/room407_shell/build_outside.py
Exports game/assets/models/graphics_pilot/room407_shell/outside.glb (room-local metres):
  - our block: the neighbours' balconies on floors 1-6 either side (room pitch 8 m, floor pitch 3.2 m),
    each with a parapet, dividers, a balcony door (dark glass or lit curtain) and some washing;
  - the courtyard 9.6 m below with paving, grass, three trees and a sodium lamp;
  - the block opposite, 22 m away, facing us with the same balconies, a few windows lit;
  - a night sky dome (night_sky.png; the moon sits a little right of straight out, 32 degrees up).
Materials named Outside* are set up in Godot by Room407Furnish (lit windows and sky ignore the fog).
"""
import math
import random
import sys
from pathlib import Path

import bpy
from mathutils import Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "room407_corner"))
import build_corner as bc  # noqa: E402
from build_shell import OUT, TEX, pbr, plain  # noqa: E402

ROOM, FLOOR, FLOORS = 8.0, 3.2, range(1, 7)  # our room is on floor 4 at y = 0
FACADE_Z, GAP = -8.55, 22.0
RNG = random.Random(407)


def floor_y(k):
    return (k - 4) * FLOOR


def module(x0, y0, mirror, mats, ours=False):
    """One room's balcony bay. mirror=False faces -z (our block), True faces +z (the block opposite)."""
    wall, slab, glass_dark, glass_lit, cloth, steel = mats
    z_wall = -7.075 if not mirror else -7.075 - 2 * (-7.075 - FACADE_Z) - GAP  # mirror through the gap
    out = -1 if not mirror else 1

    def z(local):  # local 0 = back wall face, positive = outwards
        return z_wall + out * local

    depth = abs(FACADE_Z - (-7.075))
    if not ours:
        if not (not mirror and x0 == 0 and y0 == FLOOR):  # our balcony's soffit is the slab above it
            bc.box("OutSlab", (x0 + 2.6, y0 - 0.1, z(depth / 2)), (5.32, 0.2, depth + 0.05), slab, 0, 2.0)
        bc.box("OutParapet", (x0 + 2.6, y0 + 0.55, z(depth - 0.05)), (5.2, 1.1, 0.1), wall, 0, 2.0)
        bc.box("OutCoping", (x0 + 2.6, y0 + 1.125, z(depth - 0.05)), (5.32, 0.05, 0.16), slab, 0, 1.0)
        for dx in (0.0, 5.2):
            bc.box("OutDivider", (x0 + dx, y0 + 1.0, z(depth / 2)), (0.12, 2.0, depth), wall, 0, 2.0)
        # Back wall with the balcony door and the bathroom's small window.
        for (a, b), (c, d) in (((0, 2.3), (0, FLOOR)), ((3.3, ROOM), (0, FLOOR)), ((2.3, 3.3), (2.3, FLOOR))):
            bc.box("OutWall", (x0 + (a + b) / 2, y0 + (c + d) / 2, z(-0.05)), (b - a, d - c, 0.1), wall, 0, 2.0)
        lit = RNG.random() < (0.22 if mirror else 0.12)
        bc.box("OutDoorGlass", (x0 + 2.8, y0 + 1.15, z(-0.02)), (0.92, 2.24, 0.02), glass_lit if lit else glass_dark, 0, 1.0)
        if RNG.random() < 0.15:
            bc.box("OutBathWindow", (x0 + 6.8, y0 + 2.05, z(0.01)), (0.5, 0.4, 0.02), glass_lit, 0, 1.0)
        # Washing on about half the lines.
        if RNG.random() < 0.55:
            bc.tube("OutLine", (x0 + 0.3, y0 + 2.15, z(0.7)), (x0 + 4.9, y0 + 2.15, z(0.7)), 0.003, steel, 6, 0.3)
            for _ in range(RNG.randint(2, 6)):
                cx = x0 + RNG.uniform(0.6, 4.6)
                w, h = RNG.uniform(0.35, 0.6), RNG.uniform(0.45, 0.8)
                bc.box("OutCloth", (cx, y0 + 2.15 - h / 2, z(0.7)), (w, h, 0.01), RNG.choice(cloth), 0, 1.0)
    else:
        # Only the walls of our own bay beside the balcony (the shell has the rest): the bathroom part.
        bc.box("OutWall", (x0 + 6.6, y0 + 1.6, z(-0.05)), (2.8, FLOOR, 0.1), wall, 0, 2.0)


def block(mirror, mats):
    for k in FLOORS:
        for i in range(-4, 5):
            ours = (not mirror) and k == 4 and i == 0
            module(i * ROOM, floor_y(k), mirror, mats, ours)
    # Gable ends and the roof edge.
    zc = (-7.075 + FACADE_Z) / 2 if not mirror else (-7.075 - GAP - 2 * (-7.075 - FACADE_Z) + (FACADE_Z - GAP)) / 2
    wall = mats[0]
    bc.box("OutRoofEdge", (4.0, floor_y(7) + 0.3, zc), (9 * ROOM + 0.4, 0.6, 1.8), wall, 0.004, 2.0)


def courtyard(mats):
    wall, slab = mats[0], mats[1]
    ground = plain("OutsideGround", (0.16, 0.16, 0.15), 0.9)
    grass = plain("OutsideGrass", (0.05, 0.08, 0.04), 0.95)
    bark = plain("OutsideBark", (0.08, 0.06, 0.05), 0.9)
    leaves = plain("OutsideLeaves", (0.03, 0.06, 0.03), 0.9)
    pole = plain("OutsidePole", (0.2, 0.2, 0.2), 0.6, 1.0)
    lamp = plain("OutsideLampLit", (1.0, 0.62, 0.25), 0.5, emission=(1.0, 0.55, 0.2))
    y = floor_y(1) - 0.2
    zc = FACADE_Z - GAP / 2
    bc.box("OutGround", (4.0, y - 0.05, zc), (80, 0.1, GAP + 6), ground, 0.0, 4.0)
    for cx, cz, w, d in ((-6, zc + 2, 9, 4), (14, zc - 1, 10, 5)):
        bc.box("OutGrass", (cx, y + 0.01, cz), (w, 0.02, d), grass, 0.0, 4.0)
    for cx, cz, r in ((-5, zc + 2, 2.6), (9.5, zc - 1.5, 3.2), (17, zc + 0.5, 2.4)):
        bc.tube("OutTrunk", (cx, y, cz), (cx, y + 3.5, cz), 0.16, bark, 8, 1.0)
        for k in range(4):
            bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=r * RNG.uniform(0.6, 0.9),
                                                  location=bc.point((cx + RNG.uniform(-1, 1), y + 3.5 + k * 0.9 + RNG.uniform(0, 0.6),
                                                                     cz + RNG.uniform(-1, 1))))
            canopy = bpy.context.object
            for v in canopy.data.vertices:
                v.co *= 1 + RNG.uniform(-0.12, 0.12)
            bc.finish(canopy, "OutCanopy", leaves)
    bc.tube("OutLampPole", (2.0, y, zc + 3), (2.0, y + 4.5, zc + 3), 0.05, pole, 8, 1.0)
    bc.tube("OutLampArm", (2.0, y + 4.5, zc + 3), (2.0, y + 4.5, zc + 3.6), 0.03, pole, 8, 1.0)
    bc.box("OutLampHead", (2.0, y + 4.42, zc + 3.7), (0.22, 0.1, 0.4), lamp, 0.01, 0.5)


def sky():
    tex = pbr("OutsideSky", TEX / "night_sky.png")
    radius, rows, cols = 140.0, 24, 48
    verts, faces, uvs = [], [], []
    for r in range(rows + 1):
        el = math.pi / 2 - math.pi * r / rows
        for c in range(cols + 1):
            az = 2 * math.pi * c / cols
            # Godot room-local direction: azimuth 0 looks straight out of the balcony (-z), +x to the right.
            d = (math.sin(az) * math.cos(el), math.sin(el), -math.cos(az) * math.cos(el))
            verts.append(bc.point((3.0 + d[0] * radius, d[1] * radius, -4.0 + d[2] * radius)))
            uvs.append((c / cols, r / rows))
    for r in range(rows):
        for c in range(cols):
            k = r * (cols + 1) + c
            faces.append((k, k + 1, k + cols + 2, k + cols + 1))
    mesh = bpy.data.meshes.new("OutsideSkyDome")
    mesh.from_pydata(verts, [], faces)
    uv = mesh.uv_layers.new(name="UVMap")
    for poly in mesh.polygons:
        for li in poly.loop_indices:
            u, v = uvs[mesh.loops[li].vertex_index]
            uv.data[li].uv = (u, 1 - v)
    mesh.update()
    centre = Vector(bc.point((3.0, 0.0, -4.0)))
    # Faces must look inwards.
    poly = mesh.polygons[len(mesh.polygons) // 2]
    if poly.normal.dot(centre - poly.center) < 0:
        mesh.flip_normals()
    obj = bpy.data.objects.new("OutsideSkyDome", mesh)
    bpy.context.collection.objects.link(obj)
    bc.finish(obj, "OutsideSkyDome", tex)


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bc.GROUP = "outside"
    wall = pbr("OutsideFacade", TEX / "facade_color.jpg")
    slab = plain("OutsideConcrete", (0.36, 0.35, 0.32), 0.9)
    glass_dark = pbr("OutsideWindowDark", TEX / "window_dark.png")
    glass_lit = pbr("OutsideWindowLit", TEX / "window_lit.png")
    cloth = [plain(f"OutsideCloth{k}", c, 0.95) for k, c in enumerate(((0.35, 0.08, 0.06), (0.1, 0.15, 0.3), (0.6, 0.58, 0.5),
                                                                      (0.08, 0.2, 0.12), (0.45, 0.35, 0.1), (0.2, 0.2, 0.22)))]
    steel = plain("OutsideWire", (0.4, 0.4, 0.4), 0.5, 1.0)
    mats = (wall, slab, glass_dark, glass_lit, cloth, steel)
    block(False, mats)
    block(True, mats)
    courtyard(mats)
    sky()
    objects = bc.GROUPS["outside"]
    # One object per material keeps the draw calls few.
    by_mat = {}
    for obj in objects:
        by_mat.setdefault(obj.data.materials[0].name, []).append(obj)
    merged = []
    for name, objs in by_mat.items():
        bpy.ops.object.select_all(action="DESELECT")
        for obj in objs:
            obj.select_set(True)
            bpy.context.view_layer.objects.active = obj
            for mod in list(obj.modifiers):
                bpy.ops.object.modifier_apply(modifier=mod.name)
        bpy.context.view_layer.objects.active = objs[0]
        bpy.ops.object.join()
        bpy.context.object.name = name.replace(" ", "")
        merged.append(bpy.context.object)
    bpy.ops.object.select_all(action="DESELECT")
    for obj in merged:
        obj.select_set(True)
    path = OUT / "outside.glb"
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True, export_apply=True,
                              export_image_format="AUTO", export_yup=True)
    tris = 0
    for obj in merged:
        obj.data.calc_loop_triangles()
        tris += len(obj.data.loop_triangles)
    assert path.stat().st_size <= 10 * 1024 * 1024, path
    print("RESULT: room407 outside export PASS", tris, "tris", path.stat().st_size, "bytes")


main()
