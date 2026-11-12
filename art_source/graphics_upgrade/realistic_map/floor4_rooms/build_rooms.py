"""T-252: reusable, measured Blender furniture; Godot assigns shared CC0 scans.
Run with Blender 5.2.2 -b --factory-startup -P this_file.
All helper coordinates are Godot metres. No network or Tripo operations.
"""
import json
import math
import sys
from pathlib import Path

import bpy

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
sys.path.insert(0, str(HERE.parents[1] / "room407_corner"))
import build_corner as bc

OUT = ROOT / "game/assets/models/graphics_pilot/realistic_map/floor4_rooms"
MATS = {}
REPORT = {}
COLORS = {
    "Plaster": (.63, .60, .46), "Tile": (.57, .49, .40),
    "Steel": (.12, .23, .15), "Wood": (.40, .25, .12),
    "Linen": (.64, .61, .51), "Check": (.36, .42, .39),
    "Blanket": (.30, .26, .22), "Dark": (.045, .06, .065),
}


def mat(name):
    if name not in MATS:
        m = bpy.data.materials.new(name)
        m.diffuse_color = (*COLORS[name], 1)
        m.use_nodes = True
        m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = m.diffuse_color
        MATS[name] = m
    return MATS[name]


def box(name, pos, size, material, bevel=.003, period=1):
    return bc.box(name, pos, size, mat(material), bevel, period)


def tube(name, a, b, radius=.015, material="Steel", sides=8):
    return bc.tube(name, a, b, radius, mat(material), sides, 1)


def export(name, build):
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    build()
    objects = list(bpy.context.scene.objects)
    for obj in objects:
        bpy.context.view_layer.objects.active = obj
        for modifier in list(obj.modifiers):
            bpy.ops.object.modifier_apply(modifier=modifier.name)
    bpy.ops.object.select_all(action='SELECT')
    bpy.context.view_layer.objects.active = objects[0]
    bpy.ops.object.join()
    obj = bpy.context.object
    obj.name = name
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    if not name.startswith('shell') and name != 'curtains':
        reduction = obj.modifiers.new('Doorway detail budget', 'DECIMATE')
        reduction.ratio = .65
        reduction.use_collapse_triangulate = True
        bpy.ops.object.modifier_apply(modifier=reduction.name)
    obj.data.calc_loop_triangles()
    path = OUT / f"{name}.glb"
    bpy.ops.export_scene.gltf(filepath=str(path), export_format='GLB', use_selection=True,
                              export_yup=True, export_materials='EXPORT', export_cameras=False,
                              export_lights=False)
    REPORT[name] = {'triangles': len(obj.data.loop_triangles),
                    'materials': sorted({m.name for m in obj.data.materials if m}),
                    'bytes': path.stat().st_size}


def shell(width):
    half = width / 2
    # Backing remains solid behind the inset window: existing collision is unchanged.
    box('Floor', (0, -.1, -2.5), (width, .2, 5), 'Tile', 0, 1.9)
    box('Ceiling', (0, 3.075, -2.5), (width, .15, 5), 'Plaster', 0, 2)
    box('Back', (0, 1.5, -5), (width, 3, .2), 'Plaster', 0, 2)
    # Half thickness at shared bay edges avoids duplicate coplanar walls.
    for side in [-1, 1]:
        box('Side', (side*(half-.05), 1.5, -2.5), (.1, 3, 5), 'Plaster', 0, 2)
        box('Skirting', (side*(half-.112), .065, -2.5), (.024, .13, 4.8), 'Tile', .002, 1.9)
    box('BackSkirting', (0, .065, -4.887), (width-.2, .13, .026), 'Tile', .002, 1.9)
    # A closed, opaque night window, recessed behind its painted steel frame.
    box('WindowPane', (0, 1.96, -4.884), (1.45, 1.16, .018), 'Dark', 0)
    for x in [-.75, 0, .75]:
        box('WindowMullion', (x, 1.96, -4.844), (.035, 1.24, .055), 'Steel', .002)
    for y in [1.34, 1.96, 2.58]:
        box('WindowRail', (0, y, -4.844), (1.53, .035, .055), 'Steel', .002)
    box('WindowSill', (0, 1.31, -4.79), (1.65, .06, .22), 'Tile', .006, 1.9)


def curtains():
    tube('CurtainRod', (-1, 2.69, -4.65), (1, 2.69, -4.65), .012)
    # Gathered curtains with a readable silhouette, no alpha overdraw.
    for side in [-1, 1]:
        verts, faces = [], []
        nx, ny = 14, 8
        for j in range(ny+1):
            for i in range(nx+1):
                u, v = i/nx, j/ny
                x = side*(.74 + (u-.5)*(.40-.09*math.sin(v*math.pi)))
                z = -4.64 + .04*math.sin(u*math.pi*10) + .015*math.sin(v*7+u)
                verts.append(bc.point((x, 1.24+v*1.4+.018*math.sin(u*9)*(1-v), z)))
        for j in range(ny):
            for i in range(nx):
                k = j*(nx+1)+i
                faces.append((k, k+1, k+nx+2, k+nx+1))
        mesh = bpy.data.meshes.new('Curtain')
        mesh.from_pydata(verts, [], faces)
        obj = bpy.data.objects.new('Curtain', mesh)
        bpy.context.collection.objects.link(obj)
        bc.metric_uv(obj, .27)
        for p in mesh.polygons:
            p.use_smooth = True
        bc.finish(obj, 'Curtain', mat('Linen'))


def bunk():
    # A 0.9 x 2 m bed; decks match the original 0.4/1.45 m colliders.
    for x in [-.43, .43]:
        for z in [-.96, .96]:
            tube('Post', (x, .025, z), (x, 1.94, z), .023)
            box('Foot', (x, .023, z), (.054, .046, .054), 'Dark', .005)
    for y in [.4, 1.45]:
        box('Deck', (0, y-.02, 0), (.86, .04, 1.94), 'Wood', .003, .55)
        for x in [-.43, .43]:
            tube('Rail', (x, y, -.96), (x, y, .96), .021)
        for z in [-.96, .96]:
            tube('EndRail', (-.43, y, z), (.43, y, z), .02)
            tube('HeadRail', (-.43, y+.40, z), (.43, y+.40, z), .016)
            for x in [-.25, 0, .25]:
                tube('Spindle', (x, y+.03, z), (x, y+.40, z), .008, sides=6)
        box('Mattress', (0, y+.045, 0), (.80, .085, 1.88), 'Linen', .024, .27)
        pillow = bc.soft_block('Pillow', (0, y+.14, -.65), (.55, .16, .34),
                               mat('Check'), 3, bc.pillow_shape, .5)
        pillow.rotation_euler.z = .09 if y < 1 else -.12
        # Folded fabric surface and a sewn edge, rounded folds visible from a doorway.
        cloth = bc.grid('Blanket', (-.4, .4), (-.25, .89), y+.105, 10, 16,
                        mat('Blanket'), .27,
                        lambda u, v: .025*math.sin(v*14+u*5)+.013*math.sin(u*19-v*4))
        solid = cloth.modifiers.new('Fabric thickness', 'SOLIDIFY')
        solid.thickness = .007
    tube('Guard', (-.43, 1.78, -.96), (-.43, 1.78, .96), .014)
    for z in [.43, .82]:
        tube('Ladder', (.46, .06, z), (.46, 1.65, z), .017)
    for y in [.24, .53, .82, 1.11, 1.40]:
        tube('Rung', (.46, y, .43), (.46, y, .82), .014)


def desk():
    box('Top', (0, .76, 0), (1.18, .045, .55), 'Wood', .009, .55)
    for x in [-.52, .52]:
        for z in [-.21, .21]:
            tube('Leg', (x, .025, z), (x, .735, z), .016)
        tube('Brace', (x, .28, -.21), (x, .28, .21), .012)
    box('Drawer', (.27, .655, 0), (.49, .16, .48), 'Wood', .004, .55)
    tube('Pull', (.17, .66, .255), (.36, .66, .255), .009)
    # Books with separate covers/page blocks, cup and an unlit desk lamp.
    for i in range(3):
        for y in [.795+i*.043, .831+i*.043]:
            obj = box('BookCover', (-.27, y, -.03), (.28, .005, .20), 'Check', .001, .5)
            obj.rotation_euler.z = .08*i
        box('Pages', (-.27, .813+i*.043, -.03), (.264, .032, .19), 'Linen', .001, .27)
    tube('Cup', (.1, .79, .12), (.1, .89, .12), .038, 'Linen', 12)
    tube('LampBase', (.42, .785, -.12), (.42, .80, -.12), .075, 'Dark', 12)
    tube('LampStem', (.42, .80, -.12), (.42, 1.06, -.12), .009, 'Dark')
    tube('LampArm', (.42, 1.06, -.12), (.29, 1.12, -.12), .012, 'Dark')
    tube('LampShade', (.29, 1.12, -.12), (.25, 1.07, -.12), .055, 'Steel', 12)


def locker():
    box('Body', (0, .94, 0), (.74, 1.76, .51), 'Steel', .007)
    for x in [-.18, .18]:
        box('Door', (x, .96, .268), (.35, 1.65, .027), 'Steel', .004)
        for y in [1.50, 1.55, 1.60, .29, .34]:
            box('VentRecess', (x, y, .286), (.23, .012, .003), 'Dark', 0)
            box('VentLip', (x, y+.009, .289), (.24, .008, .012), 'Steel', .001)
        tube('Handle', (x+.10, .9, .30), (x+.10, 1.01, .30), .009)
    for x in [-.3, .3]:
        for z in [-.18, .18]:
            box('Foot', (x, .055, z), (.05, .11, .05), 'Steel', .002)
    box('StorageBox', (0, 1.94, -.01), (.58, .20, .40), 'Wood', .005, .55)


def stool():
    box('Seat', (0, .43, 0), (.32, .04, .30), 'Wood', .009, .55)
    for x in [-.12, .12]:
        for z in [-.11, .11]:
            tube('Leg', (x*1.2, .025, z*1.2), (x, .41, z), .012)


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    OUT.mkdir(parents=True, exist_ok=True)
    for width in [4, 6]:
        export(f'shell_{width}', lambda: shell(width))
    for name, build in [('bunk', bunk), ('desk', desk), ('locker', locker), ('stool', stool), ('curtains', curtains)]:
        export(name, build)
    REPORT['room_4_triangles'] = REPORT['shell_4']['triangles'] + sum(REPORT[n]['triangles']*c for n,c in [('bunk',2),('desk',1),('locker',1),('stool',1),('curtains',1)])
    REPORT['room_6_triangles'] = REPORT['room_4_triangles'] - REPORT['shell_4']['triangles'] + REPORT['shell_6']['triangles']
    REPORT['total_seven_rooms'] = REPORT['room_4_triangles']*6 + REPORT['room_6_triangles']
    (HERE/'geometry_report.json').write_text(json.dumps(REPORT, indent=2)+'\n')
    print('RESULT: T-252 Blender', json.dumps(REPORT))


if __name__ == '__main__':
    main()
