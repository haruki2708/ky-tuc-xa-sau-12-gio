"""Canteen v2 (Claude làm thay lane B, owner playtest 2026-10-06): a Chinese
school canteen ("食堂") instead of a bare box. Writes only
game/scenes/levels/campus/canteen.tscn and replaces the Dining_* navigation
cells in campus.tscn to match the new furniture. Keeps every contract of
T-183: the room footprint (x 170–210, z 20–44, kitchen and store behind),
door openings and nav links, TV/Screen, the kitchen clock, anchors.

Run from the repo root:  py -3 art_source/campus/canteen_cn.py
"""
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
sys.argv.append('--detail')
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import build_campus as c  # noqa: E402
import detail  # noqa: E402

G = c.G
part = detail.part
ROOT = c.ROOT
FONT = 'res://assets/fonts/be_vietnam_pro_regular.ttf'

# Long tables with fixed stools, 3 a side: centres and footprint (half sizes).
TABLE_X = [173.5, 178.5, 183.5, 196.5, 201.5, 206.5]
TABLE_Z = [27.0, 32.5, 37.0]
# The zombies' spawn points fill the front left (x 178–186, z 24–30); the
# front right gets one more row.
TABLES = [(x, z) for x in TABLE_X for z in TABLE_Z] + [(196.5, 22.6), (201.5, 22.6), (205.6, 22.6)]
HALF_X, HALF_Z = 1.3, 1.0
# Earthquake: a few tables knocked askew or over (still inside their footprint).
TOPPLED = {(178.5, 32.5), (201.5, 27.0), (206.5, 37.0)}
ASKEW = {(173.5, 37.0): 9, (196.5, 32.5): -7, (183.5, 27.0): 5}


def label(s, name, pos, text, size=64, color='Color(0.9,0.85,0.75,1)', yaw=0, parent='.'):
    font = s.resource(FONT, 'FontFile')
    return s.node(name, 'Label3D', parent, 'position = ' + s.vec(pos) + '\nrotation_degrees = Vector3(0,%s,0)\n' % yaw
                  + 'text = "%s"\nfont = %s\nfont_size = %d\npixel_size = 0.01\nmodulate = %s\noutline_size = 0\n'
                  'double_sided = false\ntexture_filter = 0' % (text, font, size, color))


def shell(s):
    # Floor, roof, walls (same footprint and openings as T-183).
    s.box('Floor', (190, G - .1, 32), (40, .2, 24), 'tile', floor=True)
    s.box('Roof', (190, G + 4.6, 32), (41, .3, 25), 'concrete')
    s.box('Ceiling', (190, G + 4.05, 32), (40, .1, 24), 'white', solid=False)
    for x in [170, 210]:
        s.box('Side' + str(x), (x, G + 2.3, 32), (.25, 4.6, 24), 'wall')
    # Front wall with an 8 m entrance (x 186–194) and long window bands.
    for x in [178, 202]:
        s.box('Front' + str(x), (x, G + 2.3, 20), (16, 4.6, .25), 'wall')
        for i in range(5):
            wx = x - 6 + i * 3
            part(s, 'Window%d_%d' % (x, i), (wx, G + 2.2, 19.86), (2.4, 1.6, .04), 'glass')
            part(s, 'WindowFrame%d_%d' % (x, i), (wx, G + 2.2, 19.84), (2.5, .08, .06), 'iron')
            part(s, 'WindowSill%d_%d' % (x, i), (wx, G + 1.38, 19.8), (2.5, .08, .2), 'concrete')
    for x, w in [(178, 16), (199.5, 3), (206.5, 7)]:
        s.box('Back' + str(x), (x, G + 2.3, 44), (w, 4.6, .25), 'wall')
    # Parapet, pilasters, canopy and sign outside.
    for z in [19.4, 44.6]:
        part(s, 'Parapet%s' % z, (190, G + 5.0, z), (41, .6, .3), 'concrete')
    for x in [169.6, 210.4]:
        part(s, 'ParapetSide%s' % x, (x, G + 5.0, 32), (.3, .6, 25), 'concrete')
    for x in [171, 176, 181, 186, 194, 199, 204, 209]:
        part(s, 'Pilaster%d' % x, (x, G + 2.3, 19.78), (.5, 4.6, .3), 'concrete')
    part(s, 'Canopy', (190, G + 3.4, 18.2), (11, .2, 3.6), 'concrete')
    for x in [185.2, 194.8]:
        part(s, 'CanopyPost%s' % x, (x, G + 1.7, 16.6), (.2, 3.4, .2), 'iron')
    part(s, 'Step', (190, G + .06, 18.9), (9, .12, 2.0), 'concrete')
    # On the parapet face, above the canopy, so nothing hides the letters.
    part(s, 'SignBoard', (190, G + 4.75, 19.18), (10, 1.0, .12), 'red')
    label(s, 'SignText', (190, G + 4.72, 19.11), 'NHÀ ĂN SINH VIÊN', 80, 'Color(0.95,0.85,0.55,1)', 180)
    # Outdoor units, bikes, bins (visual only; outdoor navigation unchanged).
    for z in [24, 30, 36]:
        part(s, 'ACUnit%d' % z, (169.6, G + 2.6, z), (.35, .6, .8), 'white')
        part(s, 'ACGrill%d' % z, (169.42, G + 2.6, z), (.02, .45, .45), 'iron')
    for i in range(6):
        bx = 172 + i * 1.6
        p = s.node('Bike%d' % i, properties='position = ' + s.vec((bx, G, 17.2)) + '\nrotation_degrees = Vector3(0,90,%d)' % (12 if i % 3 == 0 else 0))
        for dz in [-.55, .55]:
            part(s, 'Wheel' + str(dz), (0, .33, dz), (.66, .04, .66), 'iron', p, shape='cyl', angles=(90, 0, 0))
        part(s, 'Frame', (0, .55, 0), (.04, .06, 1.0), 'red' if i % 2 else 'blue', p)
        part(s, 'Seat', (0, .85, -.2), (.12, .05, .25), 'iron', p)
    for x in [205, 206.2]:
        part(s, 'Bin%s' % x, (x, G + .45, 54.2), (.6, .9, .6), 'blue' if x < 206 else 'concrete', shape='cyl')
    for i in range(2):
        part(s, 'GasCylinder%d' % i, (189 + i * .6, G + .55, 53.0), (.4, 1.1, .4), 'red', shape='cyl')
    part(s, 'Chimney', (192, G + 5.6, 51), (.6, 2.0, .6), 'iron')


def dining(s):
    for tx, tz in TABLES:
        name = 'Table_%d_%d' % (tx * 10, tz * 10)
        props = 'position = ' + s.vec((tx, G, tz))
        if (tx, tz) in ASKEW:
            props += '\nrotation_degrees = Vector3(0,%d,0)' % ASKEW[(tx, tz)]
        p = s.node(name, properties=props)
        toppled = (tx, tz) in TOPPLED
        top_angles = (0, 0, 70) if toppled else None
        part(s, 'Top', (0, .76 if not toppled else .45, 0), (2.4, .05, .75), 'white', p, angles=top_angles)
        part(s, 'Edge', (0, .73 if not toppled else .42, 0), (2.42, .03, .77), 'iron', p, angles=top_angles)
        # Fixed steel frame and round stools (3 a side).
        for dx in [-1.05, 1.05]:
            for dz in [-.28, .28]:
                part(s, 'Leg%s_%s' % (dx, dz), (dx, .37, dz), (.04, .74, .04), 'iron', p, angles=top_angles)
        for side in [-1, 1]:
            part(s, 'StoolBar%d' % side, (0, .2, side * .5), (2.1, .035, .035), 'iron', p, angles=top_angles)
        for side in [-1, 1]:
            for i in range(3):
                sx = -.8 + i * .8
                stool_tilt = (25 * side, 0, 0) if toppled else None
                part(s, 'Stool%d_%d' % (side, i), (sx, .45, side * .75), (.36, .05, .36), 'red' if (i + side) % 2 else 'blue',
                     p, shape='cyl', angles=stool_tilt)
                part(s, 'StoolArm%d_%d' % (side, i), (sx, .23, side * .6), (.04, .45, .3), 'iron', p, angles=stool_tilt)
        # Trays, bowls and chopsticks left behind.
        if not toppled:
            for i in range(2 + int(tx + tz) % 3):
                ox = -.9 + i * .6
                part(s, 'Tray%d' % i, (ox, .8, .18 * (1 if i % 2 else -1)), (.42, .02, .32), 'iron', p,
                     angles=(0, (i * 23) % 40 - 20, 0))
                part(s, 'Bowl%d' % i, (ox + .08, .84, .18 * (1 if i % 2 else -1)), (.14, .07, .1), 'white', p, shape='cyl')
                part(s, 'Chopsticks%d' % i, (ox - .1, .815, .18 * (1 if i % 2 else -1)), (.22, .01, .015), 'wood', p)
        s.box('Collision', (0, .45, 0), (HALF_X * 2, .9, HALF_Z * 2), parent=p, visible=False)
    # Spilled trays and an overturned stool on the floor.
    for i, (x, z) in enumerate([(188, 29), (191.5, 35.5), (176, 30.2), (204, 34.8), (186.5, 39.5), (193, 24)]):
        part(s, 'FloorTray%d' % i, (x, G + .012, z), (.42, .02, .32), 'iron', angles=(0, i * 37, 0))
        part(s, 'Spill%d' % i, (x + .3, G + .006, z + .2), (.7, .01, .5), 'red' if i % 2 else 'wood', angles=(0, i * 21, 0))


def serving_line(s):
    # Serving counter along the back wall (left half): stainless, sneeze glass,
    # food pans, windows to the kitchen, price boards.
    s.box('Counter', (178, G + .45, 42.4), (15, .9, 1.0), 'iron')
    part(s, 'CounterTop', (178, G + .92, 42.4), (15.1, .05, 1.1), 'white')
    part(s, 'TrayRail', (178, G + .85, 41.75), (15, .04, .3), 'iron')
    for i in range(15):
        part(s, 'SneezeGlass%d' % i, (171.1 + i, G + 1.3, 42.1), (.95, .5, .02), 'glass', angles=(-20, 0, 0))
    for i in range(12):
        x = 171.6 + i * 1.2
        part(s, 'FoodPan%d' % i, (x, G + .97, 42.5), (.5, .08, .35), 'iron')
        part(s, 'Food%d' % i, (x, G + 1.0, 42.5), (.44, .03, .3), ['red', 'wood', 'grass', 'paper'][i % 4])
        part(s, 'Ladle%d' % i, (x + .2, G + 1.05, 42.4), (.03, .02, .3), 'iron', angles=(15, 0, 0))
    for i in range(5):
        x = 172.5 + i * 3
        part(s, 'ServeWindow%d' % i, (x, G + 1.8, 43.86), (2.2, 1.2, .02), 'concrete')
        part(s, 'ServeWindowDark%d' % i, (x, G + 1.8, 43.84), (2.0, 1.0, .02), 'iron')
        part(s, 'PriceBoard%d' % i, (x, G + 3.2, 43.84), (2.6, .7, .04), 'wood')
        label(s, 'PriceText%d' % i, (x, G + 3.2, 43.8), ['CƠM 5', 'RAU 3', 'THỊT 8', 'CANH 2', 'MÌ 6'][i], 48, yaw=180)
    for i in range(3):
        part(s, 'RiceBucket%d' % i, (182.6 + i * .7, G + 1.18, 42.5), (.5, .5, .5), 'white', shape='cyl')
    for i in range(8):
        part(s, 'TrayStack%d' % i, (170.9 + 0.0, G + .95 + i * .025, 41.0), (.42, .02, .32), 'iron')
    part(s, 'CardReader', (171.0, G + 1.15, 41.5), (.12, .3, .1), 'blue')
    # Queue rail in front of the counter.
    part(s, 'QueueRail', (178, G + .9, 40.8), (13, .05, .05), 'iron')
    for i in range(5):
        part(s, 'QueuePost%d' % i, (171.5 + i * 3.25, G + .45, 40.8), (.06, .9, .06), 'iron')


def walls_inside(s):
    # White tiles to waist height, slogans, posters, TV, sinks, tray return.
    for name, pos, size in [('TileW', (170.15, G + .7, 32), (.02, 1.4, 24)), ('TileE', (209.85, G + .7, 32), (.02, 1.4, 24)),
                            ('TileB', (190, G + .7, 43.85), (40, 1.4, .02))]:
        part(s, name, pos, size, 'white')
    s.node('TV', properties='position = Vector3(170.2,%s,32)' % (G + 2.4))
    s.box('Case', (0, 0, 0), (.16, .8, 1.2), 'iron', 'TV', solid=False)
    s.box('Screen', (.09, 0, 0), (.015, .66, 1.04), 'white', 'TV', solid=False)
    part(s, 'TVBracket', (170.25, G + 2.0, 32), (.1, .3, .1), 'iron')
    part(s, 'SloganBoard', (190, G + 3.3, 20.15), (14, .7, .04), 'red')
    label(s, 'SloganText', (190, G + 3.3, 20.2), 'TIẾT KIỆM LƯƠNG THỰC, KHÔNG BỎ PHÍ CƠM', 52, 'Color(0.95,0.88,0.6,1)')
    for i, z in enumerate([24, 28, 36, 40]):
        part(s, 'Poster%d' % i, (170.2, G + 2.0, z), (.02, 1.0, .7), 'paper')
        part(s, 'PosterInk%d' % i, (170.22, G + 2.1, z), (.01, .5, .5), ['red', 'blue'][i % 2])
    # Hand-wash sinks along the east wall near the entrance.
    for i in range(4):
        z = 22.2 + i * 1.1
        part(s, 'Sink%d' % i, (209.6, G + .82, z), (.5, .2, .9), 'white')
        part(s, 'Tap%d' % i, (209.8, G + 1.05, z), (.06, .2, .06), 'iron')
        part(s, 'Mirror%d' % i, (209.84, G + 1.7, z), (.02, .7, .8), 'glass')
    s.box('SinkBlock', (209.6, G + .4, 23.85), (.6, .8, 4.6), 'concrete')
    # Tray return: shelves with dirty trays and slop bins, east wall.
    s.box('TrayReturn', (209.4, G + .9, 39.0), (1.0, 1.8, 3.0), 'iron')
    for i in range(4):
        part(s, 'ReturnShelf%d' % i, (209.0, G + .4 + i * .45, 39.0), (.15, .03, 3.0), 'white')
        part(s, 'DirtyTray%d' % i, (209.0, G + .45 + i * .45, 38.2 + i * .5), (.42, .02, .32), 'iron')
    for i in range(2):
        part(s, 'SlopBin%d' % i, (208.4, G + .4, 41.2 + i * .7), (.55, .8, .55), 'blue', shape='cyl')
    label(s, 'ReturnSign', (209.75, G + 2.2, 39.0), 'TRẢ KHAY', 48, yaw=-90)
    # Ceiling: fluorescent tubes and fans.
    for x in [175, 183, 191, 199, 207]:
        for z in [24, 30, 36, 41]:
            part(s, 'Tube_%d_%d' % (x, z), (x, G + 3.98, z), (1.2, .05, .12), 'white')
    for x, z in [(179, 30), (201, 30), (190, 37)]:
        part(s, 'FanHub_%d_%d' % (x, z), (x, G + 3.7, z), (.2, .3, .2), 'iron')
        part(s, 'FanBlades_%d_%d' % (x, z), (x, G + 3.55, z), (1.4, .02, .12), 'white', angles=(0, x % 60, 0))
    for z in [25, 33, 40]:
        s.node('CeilingLight' + str(z), 'OmniLight3D', properties='position = ' + s.vec((190, G + 3.6, z))
               + '\nlight_energy = 1.1\nomni_range = 19.0\nshadow_enabled = false\nlight_color = Color(.64,.69,.54,1)')


def kitchen(s):
    s.box('KitchenFloor', (192, G - .1, 48), (12, .2, 8), 'wet_tile', floor=True)
    for x in [186, 198]:
        s.box('KitchenSide' + str(x), (x, G + 2.3, 48), (.25, 4.6, 8), 'wall')
    s.box('KitchenBack', (192, G + 2.3, 52), (12, 4.6, .25), 'wall')
    part(s, 'KitchenRoof', (198, G + 4.6, 48), (24, .3, 8.4), 'concrete')
    # Gas range with woks, under an exhaust hood (back wall).
    s.box('Cooktop', (192, G + .45, 51.2), (8, .9, 1.1), 'iron')
    for i in range(4):
        x = 189 + i * 2
        part(s, 'Wok%d' % i, (x, G + 1.0, 51.1), (.8, .18, .5), 'iron', shape='cyl')
        part(s, 'WokHandle%d' % i, (x + .5, G + 1.05, 51.0), (.45, .03, .04), 'wood')
    part(s, 'Hood', (192, G + 2.6, 51.3), (8.4, .7, 1.4), 'iron')
    part(s, 'HoodDuct', (192, G + 3.5, 51.6), (1.0, 1.2, .8), 'iron')
    clock_pos = (192, G + 2.5, 51.85)
    detail.clock(s, 'KitchenClock', clock_pos, 180)
    # Steamer stacks, rice cookers, prep table, sink (west side, off the nav strip).
    for i in range(3):
        for k in range(4):
            part(s, 'Steamer%d_%d' % (i, k), (187.0, G + .25 + k * .32, 45.2 + i * 1.0), (.8, .3, .8), 'wood', shape='cyl')
    for i in range(2):
        part(s, 'RiceCooker%d' % i, (188.9, G + 1.15, 45.0 + i * 1.1), (.6, .5, .6), 'white', shape='cyl')
    s.box('PrepTable', (188.9, G + .45, 46.6), (1.0, .9, 4.4), 'iron')
    part(s, 'ChoppingBoard', (188.9, G + .93, 47.4), (.5, .04, .7), 'wood')
    part(s, 'Cleaver', (188.8, G + .97, 47.0), (.1, .02, .3), 'iron')
    for i in range(3):
        part(s, 'Vegetables%d' % i, (189.0, G + .98, 45.5 + i * .4), (.3, .1, .25), 'grass')
    s.box('KitchenSink', (187.2, G + .45, 49.3), (1.2, .9, .9), 'iron')
    part(s, 'SinkTap', (187.2, G + 1.15, 49.7), (.06, .3, .06), 'iron')
    for i in range(5):
        part(s, 'HangingLadle%d' % i, (186.2, G + 1.9, 45.3 + i * .5), (.03, .6, .1), 'iron')
    for i in range(4):
        part(s, 'RiceSack%d' % i, (196.9, G + .3 + (i // 2) * .5, 45.0 + (i % 2) * .8), (.7, .45, .6), 'cloth')


def store(s):
    s.box('StoreFloor', (204, G - .1, 48), (12, .2, 8), 'tile', floor=True)
    s.box('StoreSide', (210, G + 2.3, 48), (.25, 4.6, 8), 'wall')
    for x, w in [(199, 2), (207, 6)]:
        s.box('StoreBack' + str(x), (x, G + 2.3, 52), (w, 4.6, .25), 'wall')
    for x in [199.2, 209.2]:
        for y in [.5, 1.4, 2.3]:
            part(s, 'Shelf%s_%s' % (x, y), (x, G + y, 48), (.7, .09, 5), 'wood')
    for i in range(8):
        part(s, 'StoreBox%d' % i, (199.2, G + .7 + (i % 3) * .9, 46 + i * .5), (.5, .4, .45), 'paper')
        part(s, 'OilCan%d' % i, (209.2, G + .7 + (i % 3) * .9, 46 + i * .5), (.25, .4, .25), 'red' if i % 2 else 'white', shape='cyl')
    for i in range(3):
        part(s, 'StoreSack%d' % i, (200.4, G + .3, 50.8 - i * .8), (.7, .45, .6), 'cloth')


def write_canteen():
    c.base.OUT = c.OUT  # the base writer saves under floor4/ otherwise
    s = c.Scene('Canteen')
    shell(s)
    dining(s)
    serving_line(s)
    walls_inside(s)
    kitchen(s)
    store(s)
    s.save('canteen.tscn')


def blocked(x, z):
    """A 1 m navigation cell (x..x+1, z..z+1) touched by furniture."""
    margin = .2
    for tx, tz in TABLES:
        if x < tx + HALF_X + margin and x + 1 > tx - HALF_X - margin and z < tz + HALF_Z + margin and z + 1 > tz - HALF_Z - margin:
            return True
    if x < 186 and z >= 40.5:  # serving counter, queue rail
        return True
    if x >= 208 and (z <= 26.5 or 37 <= z):  # sinks, tray return
        return True
    return False


def write_navigation():
    path = ROOT / 'game/scenes/levels/campus/campus.tscn'
    text = path.read_text(encoding='utf-8')
    # Drop the old Dining_* regions and the NavigationMesh sub-resources they use.
    node_re = re.compile(r'\[node name="Dining_\d+_\d+" type="NavigationRegion3D" parent="Navigation"[^\]]*\]\nnavigation_mesh = SubResource\("([^"]+)"\)\n\n')
    old_ids = node_re.findall(text)
    text = node_re.sub('', text)
    for sid in old_ids:
        text = re.sub(r'\[sub_resource type="NavigationMesh" id="%s"\]\n(?:[^\[\n][^\n]*\n)*\n' % re.escape(sid), '', text)
    subs, nodes = [], []
    for x in range(171, 209):
        for z in range(21, 43):
            if blocked(x, z):
                continue
            sid = 'cn_%d_%d' % (x, z)
            subs.append('[sub_resource type="NavigationMesh" id="%s"]\nvertices = PackedVector3Array(%d, %s, %d, %d, %s, %d, %d, %s, %d, %d, %s, %d)\n'
                        'polygons = [PackedInt32Array(0, 1, 2, 3)]\nagent_height = 1.75\nagent_radius = 0.3\n\n'
                        % (sid, x, G, z, x, G, z + 1, x + 1, G, z + 1, x + 1, G, z))
            nodes.append('[node name="Dining_%d_%d" type="NavigationRegion3D" parent="Navigation"]\nnavigation_mesh = SubResource("%s")\n\n' % (x, z, sid))
    # Sub-resources go before the first node; regions right after the Navigation node.
    first_node = text.index('[node ')
    text = text[:first_node] + ''.join(subs) + text[first_node:]
    nav = text.index('[node name="Navigation" type="Node3D" parent="."')
    nav_end = text.index('\n\n', nav) + 2
    text = text[:nav_end] + ''.join(nodes) + text[nav_end:]
    path.write_text(text, encoding='utf-8', newline='\n')
    return len(old_ids), len(nodes)


if __name__ == '__main__':
    write_canteen()
    removed, added = write_navigation()
    print('canteen.tscn written; navigation cells: removed %d, added %d' % (removed, added))
