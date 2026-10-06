"""T-192 stadium stands, low walls, fence and gates (stdlib only).

Main (north) stand: 18 tiers, 6.8 m tall, covered, directly on the track.
Secondary (south) stand: 7 tiers. Both are one continuous sloped collision
slab with visual treads, like the stairs of T-183, so a capsule walks up
without a step algorithm. The gates at x = 193..203 are gone (the stands
stand there); the north and south gates now sit at both stand ends.
"""
import math
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
import detail  # noqa: E402
from prims import Batch, euler  # noqa: E402

G = -9.9
AISLE = 6.0
SLAB = .4
ROOF_CLEARANCE = 3.5
STANDS = [
    dict(name='MainBleachers', short='Main', x0=158.0, x1=238.0, z0=212.7, dir=1, tiers=18, rise=.38, run=.85,
         aisles=[173.0, 198.0, 223.0], wall_z=212.4, roof=True),
    dict(name='SecondaryBleachers', short='South', x0=168.0, x1=228.0, z0=119.5, dir=-1, tiers=7, rise=.40, run=.90,
         aisles=[183.0, 213.0], wall_z=119.8, roof=False),
]
# Gate openings (10 m) at both ends of the north/south stands, and the old W/E gates.
SIDE_GATES = [148.0, 248.0]
END_GATES = [166.0]
FIELD = (110.0, 286.0, 119.8, 212.4)  # x0, x1, south fence z, north fence z
SPAWN_NORTH = (149.0, G, 210.0)
SPAWN_SOUTH = (249.0, G, 123.0)
# Zone box of the Bleachers Area3D: seats up to 6.8 m, the roof and the space under the stand.
BLEACHERS_ZONE = ((198.0, G + 4.25, 220.75), (86.0, 9.5, 18.5))
INFO = {}


def geometry(st):
    k = st['rise'] / st['run']
    depth = st['tiers'] * st['run']
    return k, depth, st['tiers'] * st['rise'], st['z0'] + st['dir'] * depth


def height_at(st, z):
    """Height of the walking surface above the ground at world z."""
    return st['rise'] / st['run'] * st['dir'] * (z - st['z0'])


def sections(st):
    edges = [st['x0']]
    for a in st['aisles']:
        edges += [a - AISLE / 2, a + AISLE / 2]
    edges.append(st['x1'])
    return [(edges[i], edges[i + 1]) for i in range(0, len(edges), 2)]


def rotate(s, path, angles):
    detail.rotate(s, path, angles)


def solid(s, name, pos, size, parent, yaw_pitch_roll=None, material=None):
    """Hidden-or-visible box collider with optional rotation about x (slope)."""
    path = s.box(name, pos, size, material or 'wall', parent, solid=True, visible=material is not None)
    if yaw_pitch_roll:
        rotate(s, path, yaw_pitch_roll)
    return path


def build_stand(s, c, batch, st, visuals):
    k, depth, height, z_end = geometry(st)
    d = st['dir']
    x0, x1, z0 = st['x0'], st['x1'], st['z0']
    name = st['name']
    body = s.node(name, 'StaticBody3D', '.', 'collision_layer = 1\ncollision_mask = 0\nmetadata/surface = &"concrete"')
    top = [(x0, G, z0), (x1, G, z0), (x1, G + height, z_end), (x0, G + height, z_end)]
    points = top + [(x, y - SLAB, z) for x, y, z in top]
    shape = s.subresource('ConvexPolygonShape3D', 'points = PackedVector3Array(' + ','.join(str(round(n, 6)) for p in points for n in p) + ')')
    s.node('Slab', 'CollisionShape3D', body, 'shape = ' + shape)
    # Low front wall with an aisle gap in front of every stairway.
    for i, (a, b) in enumerate(sections(st)):
        solid(s, 'FrontWall%d' % i, ((a + b) / 2, G + .55, st['wall_z']), (b - a, 1.1, .4), body, material='paper')
    # Rear parapet and the two sloping end parapets keep people on the stand.
    solid(s, 'RearParapet', ((x0 + x1) / 2, G + height + .6, z_end + d * .15), (x1 - x0, 1.2, .3), body, material='paper')
    slope = math.degrees(math.atan(k))
    length = math.hypot(depth, height)
    normal = (0.0, math.cos(math.radians(slope)), -d * math.sin(math.radians(slope)))
    mid = (z0 + d * depth / 2, height / 2)
    for label, x in (('EndWest', x0 - .15), ('EndEast', x1 + .15)):
        center = (x, G + mid[1] + .6 * normal[1], mid[0] + .6 * normal[2])
        solid(s, label, center, (.3, 1.2, length), body, (-d * slope, 0, 0), material='paper')
    c.obstacle((x0 + x1) / 2, z0 + d * depth / 2, x1 - x0, depth)
    for i, (a, b) in enumerate(sections(st)):
        c.obstacle((a + b) / 2, st['wall_z'], b - a, .4)

    # Navigation: the seating slope, a link at every stairway, and (main) the
    # open space under the stand, entered from behind.
    # The walkable quad keeps a capsule (r = .3) clear of the front wall (inner face z0 - .1 d),
    # the rear parapet (face at z_end) and the end parapets (face at x0 / x1).
    inset = .5
    za, zb = z0 + d * .5, z_end - d * .45
    c.quad(st['short'] + 'StandSeats', [(x0 + inset, G + height_at(st, za), za), (x0 + inset, G + height_at(st, zb), zb),
                                       (x1 - inset, G + height_at(st, zb), zb), (x1 - inset, G + height_at(st, za), za)])
    for i, a in enumerate(st['aisles']):
        start = (a, G, z0 - d * 1.2)
        end_z = z0 + d * .6
        c.link('%sStandAisle%d' % (st['short'], i), start, (a, G + height_at(st, end_z), end_z))
    # Top row of the walking surface, centre of the last tread.
    top_z = z_end - d * st['run'] / 2
    INFO[name] = dict(height=height, top_y=G + height_at(st, top_z), top_z=top_z, z_end=z_end, tiers=st['tiers'],
                      slope_deg=slope, depth=depth)
    if st['roof']:
        under_front = z0 + d * (2.25 / k)  # first z where the slab leaves 1.9 m of headroom
        c.quad(st['short'] + 'StandUnder', [(x0 + 1.0, G, under_front + d * .2), (x0 + 1.0, G, z_end - d * .2),
                                           (x1 - 1.0, G, z_end - d * .2), (x1 - 1.0, G, under_front + d * .2)])
        for i, x in enumerate([x0 + 13, (x0 + x1) / 2 + 1, x1 - 13]):
            c.link('%sStandUnderEntry%d' % (st['short'], i), (x, G, z_end + d * 3.0), (x, G, z_end - d * .5))
        INFO[name]['under_front'] = under_front

    if not visuals:
        return
    # Treads: overlapping slabs make a closed sawtooth with no light gaps.
    for i in range(st['tiers']):
        zc = z0 + d * (i + .5) * st['run']
        top_y = G + st['rise'] * (i + .5)
        batch.add('concrete', 'box', ((x0 + x1) / 2, top_y - .2, zc), (x1 - x0, .4, st['run'] + .02))
        for a in st['aisles']:
            batch.add('paper', 'box', (a, top_y + .012, zc - d * (st['run'] / 2 - .07)), (AISLE - .6, .03, .12))
        for lo, hi in sections(st):
            width = hi - lo - .6
            batch.add('blue', 'box', ((lo + hi) / 2, top_y + .06, zc - d * .08), (width, .08, .5))
            batch.add('white', 'box', ((lo + hi) / 2, top_y + .25, zc + d * .3), (width, .38, .07))


def build_roof(s, c, batch, st):
    x0, x1, z0, d = st['x0'], st['x1'], st['z0'], st['dir']
    k, depth, height, z_end = geometry(st)
    roof_y = G + height - st['rise'] * .5 + ROOF_CLEARANCE + .15
    front = z0 + d * 1.6
    rear = z_end + d * 3.4
    width = x1 - x0 + 1.4
    batch.add('white', 'box', ((x0 + x1) / 2, roof_y, (front + rear) / 2), (width, .3, abs(rear - front)), tint=(.6, .62, .6))
    batch.add('white', 'box', ((x0 + x1) / 2, roof_y - .35, front), (width, .85, .3))
    batch.add('iron', 'box', ((x0 + x1) / 2, roof_y - .35, rear), (width, .6, .3))
    for frac in (.18, .5, .82):
        batch.add('iron', 'box', ((x0 + x1) / 2, roof_y - .28, front + (rear - front) * frac), (width - .4, .22, .22))
    col_z = z_end + d * .9
    columns = []
    x = x0
    while x <= x1 + .01:
        columns.append(x)
        batch.add('concrete', 'cylinder', (x, G + (roof_y - G) / 2, col_z), (.55, roof_y - G - .15, .55))
        batch.add('iron', 'box', (x, roof_y - .28, (front + rear) / 2), (.22, .22, abs(rear - front)))
        # Raking strut from the column up to the roof, 5 m toward the pitch.
        batch.add('iron', 'box', (x, roof_y - 2.4, col_z - d * 2.5), (.2, .2, 6.5), euler(0, d * 40, 0))
        x += 10.0
    for i, x in enumerate(columns):
        solid(s, 'RoofColumn%d' % i, (x, G + 3.0, col_z), (.55, 6.0, .55), '.')
        c.obstacle(x, col_z, .55, .55)
    INFO[st['name']]['roof_y'] = roof_y
    INFO[st['name']]['columns'] = len(columns)


def build_fence(s, c, batch, visuals):
    fx0, fx1, fzs, fzn = FIELD
    segments = []
    for z, stand in ((fzn, STANDS[0]), (fzs, STANDS[1])):
        cuts = sorted(SIDE_GATES)
        pieces = [(fx0, cuts[0] - 5), (cuts[0] + 5, stand['x0']), (stand['x1'], cuts[1] - 5), (cuts[1] + 5, fx1)]
        for a, b in pieces:
            segments.append(('x', z, a, b))
    for x in (fx0, fx1):
        segments.append(('z', x, fzs, END_GATES[0] - 5))
        segments.append(('z', x, END_GATES[0] + 5, fzn))
    for index, (axis, fixed, a, b) in enumerate(segments):
        length = b - a
        mid = (a + b) / 2
        pos = (mid, G + .65, fixed) if axis == 'x' else (fixed, G + .65, mid)
        size = (length, 1.3, .08) if axis == 'x' else (.08, 1.3, length)
        s.box('Fence%d' % index, pos, size, 'iron', '.', visible=False)
        c.obstacle(pos[0], pos[2], size[0], size[2])
        if not visuals:
            continue
        along = (1, 0, 0) if axis == 'x' else (0, 0, 1)
        batch.add('iron', 'box', (pos[0], G + 1.3, pos[2]), (length if axis == 'x' else .07, .07, .07 if axis == 'x' else length))
        batch.add('iron', 'box', (pos[0], G + .4, pos[2]), (length if axis == 'x' else .05, .05, .05 if axis == 'x' else length))
        count = max(2, int(length // 2.0))
        for i in range(count + 1):
            t = a + length * i / count
            batch.add('iron', 'box', (t if axis == 'x' else fixed, G + .65, fixed if axis == 'x' else t), (.04, 1.3, .04))
    INFO['fence_segments'] = len(segments)
    # Gate posts (3.6 m) at every opening.
    for z in (fzn, fzs):
        for x in SIDE_GATES:
            for offset in (-5, 5):
                s.box('GatePost%d_%d_%d' % (round(x), round(z), offset), (x + offset, G + 1.8, z), (.35, 3.6, .35), 'iron')
    for x in (fx0, fx1):
        for offset in (-5, 5):
            s.box('GatePost%d_166_%d' % (round(x), offset), (x, G + 1.8, 166 + offset), (.35, 3.6, .35), 'iron')


def build(s, c, visuals):
    batch = Batch()
    s.nodes[0] += 'metadata/tiers = Vector2i(%d, %d)\n' % (STANDS[0]['tiers'], STANDS[1]['tiers'])
    for st in STANDS:
        build_stand(s, c, batch, st, visuals)
    build_roof(s, c, batch, STANDS[0])
    build_fence(s, c, batch, visuals)
    if visuals:
        # Loose pipes lying under the main stand next to the bar spawn B03.
        for i in range(4):
            batch.add('iron', 'box', (163 + i * .25, G + .07, 225.5), (.045, .045, 1.7), euler(15 + i * 9, 0, 0))
    INFO['triangles'] = batch.triangles
    return batch
