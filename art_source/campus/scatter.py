"""T-192 street props for the campus (D-064): the map keeps its real size
(D-054) and gets things worth looking at along every route.

Everything is stdlib geometry, deterministic (fixed seed) and batched into
`boxes.gd` MultiMesh nodes by 40 m chunk; solid props share one StaticBody3D
per chunk. Solid props register `obstacle()` so the outdoor lattice routes
around them, and every route keeps at least 5 m of free lane.
"""
import math
import random
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
import detail  # noqa: E402
from prims import Batch, IDENTITY, euler, rot_x, rot_y, rot_z, mvec  # noqa: E402

G = -9.9
LANE = 3.0            # a solid prop keeps this far from a route centre line (+ its radius)
BOUNDS = (-74.0, 414.0, -54.0, 284.0)
SAMPLE_STEP = 5.0     # density check along the route
NEED_WITHIN_30M = 4
TREE_ROWS = []
INFO = {}

WHITE = (1.0, 1.0, 1.0)
# Instance colours stay within 0..1: a light base texture ('white', 'paper') times the tint.
CAR_TINTS = [(.95, .95, .98), (.28, .30, .36), (.85, .16, .12), (.20, .36, .85), (.95, .82, .22), (.50, .60, .50), (.62, .64, .70)]
BAG_TINTS = [(.8, .2, .15), (.2, .4, .8), (.75, .65, .15), (.2, .65, .3), (.75, .25, .6), (.15, .15, .18)]
SHIRTS = [(.9, .85, .75), (.2, .4, .8), (.8, .2, .15), (.2, .6, .3), (.5, .5, .6), (.12, .12, .15)]
JEANS = [(.2, .3, .55), (.12, .14, .2), (.3, .3, .3), (.4, .4, .3)]
SKIN = (.9, .7, .6)


def route_segments(route):
    seen, segs = set(), []
    for a, b in zip(route, route[1:]):
        key = tuple(sorted(((round(a[0]), round(a[2])), (round(b[0]), round(b[2])))))
        if key in seen or a[1] > G + .5 or b[1] > G + .5 or (a[0] == b[0] and a[2] == b[2]):
            continue
        seen.add(key)
        segs.append(((a[0], a[2]), (b[0], b[2])))
    return segs


def seg_distance(px, pz, a, b):
    dx, dz = b[0] - a[0], b[1] - a[1]
    length2 = dx * dx + dz * dz
    t = 0.0 if length2 == 0 else max(0.0, min(1.0, ((px - a[0]) * dx + (pz - a[1]) * dz) / length2))
    return math.hypot(px - (a[0] + t * dx), pz - (a[1] + t * dz))


class Props:
    def __init__(self, c, seed='T192'):
        self.c = c
        self.rng = random.Random(seed)
        self.batch = Batch()
        self.decals = Batch(80.0)  # flat decals are tiny: coarser chunks, fewer nodes
        self.segs = route_segments(c.ROUTE)
        self.circles = []        # (x, z, r) of everything already placed
        self.solids = []         # (cx, cz, w, d, h, yaw)
        self.points = []         # notable props, for the density rule and the test
        self.lights = []
        self.blinkers = []
        self.counts = {}
        self.where = {}
        self.tri = {}
        self.ground = G
        self.keep_clear = self._anchor_discs()
        self.keep_rects = [(0, 44, 8, 48.5),     # garden: beds, benches and lamps are placed by hand
                           (-6, 50, -8, 4.5),     # building B and its stairs
                           (-1, 49, 54, 64),      # building A
                           (108, 288, 118, 214),  # the pitch and track hold only non-solid things
                           (154, 242, 209, 233),  # main stand and the space under it
                           (164, 232, 109, 123)]  # south stand
        self.keep_rects += [(a - .4, b + .4, c0 - .4, d + .4) for a, b, c0, d in c.BLOCKS if (b - a) * (d - c0) > 600]

    # ----------------------------------------------------------------- queries
    def _anchor_discs(self):
        discs = []
        for name, p in self.c.ANCHORS.items():
            if name.startswith(('ZombieSpawns/', 'ZombieIdle/', 'BarSpawns/', 'Start_', 'GuardLine/', 'Paths/')) or name in ('GuardBooth', 'NguBench', 'CanteenExit', 'ManagerWindow'):
                discs.append((p[0], p[2], 2.6))
        return discs

    def lane_distance(self, x, z):
        return min((seg_distance(x, z, a, b) for a, b in self.segs), default=999.0)

    def free(self, x, z, r, solid=True, margin=.3):
        if not (BOUNDS[0] < x < BOUNDS[1] and BOUNDS[2] < z < BOUNDS[3]):
            return False
        for a, b, c0, d in self.keep_rects:
            if a - r < x < b + r and c0 - r < z < d + r:
                return False
        if solid:
            if self.lane_distance(x, z) < LANE + r:
                return False
            for ax, az, ar in self.keep_clear:
                if math.hypot(x - ax, z - az) < ar + r:
                    return False
            for a, b, c0, d in self.c.BLOCKS:
                nx, nz = max(a, min(x, b)), max(c0, min(z, d))
                if math.hypot(x - nx, z - nz) < r + .2:
                    return False
        for ox, oz, orr in self.circles:
            if math.hypot(x - ox, z - oz) < r + orr + margin:
                return False
        return True

    def reserve(self, x, z, r):
        self.circles.append((x, z, r))

    def count_near(self, x, z, radius=30.0):
        return sum(1 for p in self.points if math.hypot(p[0] - x, p[2] - z) <= radius)

    # ----------------------------------------------------------------- output
    def solid(self, x, z, w, d, h, yaw=0.0, local=(0.0, 0.0)):
        off = mvec(rot_y(yaw), (local[0], 0, local[1]))
        cx, cz = x + off[0], z + off[2]
        self.solids.append((cx, cz, w, d, h, yaw))
        a = math.radians(yaw)
        bw = abs(w * math.cos(a)) + abs(d * math.sin(a))
        bd = abs(w * math.sin(a)) + abs(d * math.cos(a))
        self.c.obstacle(cx, cz, bw, bd)

    def note(self, kind, x, z):
        self.counts[kind] = self.counts.get(kind, 0) + 1
        self.where.setdefault(kind, []).append((round(x, 1), round(z, 1)))
        self.points.append((x, G, z))

    def frame(self, x, z, yaw=0.0, pitch=0.0, roll=0.0, lift=0.0, batch=None):
        return (batch or self.batch).frame((x, self.ground + lift, z), euler(yaw, pitch, roll))


# ------------------------------------------------------------------ builders
# Each takes the Props object, a position and a yaw and returns the radius it
# occupies (or None if it could not be placed). Solid ones also register
# their collision boxes.

def moped(p, x, z, yaw, fallen=True):
    r = p.rng
    f = p.frame(x, z, yaw, 76 * r.choice((-1, 1)) if fallen else 0, 0, lift=.22 if fallen else 0)
    tint = r.choice(CAR_TINTS)
    for wx in (-.55, .6):
        f.cyl('iron', (wx, .28, 0), (.56, .13, .56), rot_x(90))
    f.box('white', (0, .5, 0), (1.15, .3, .3), tint=tint)
    f.box('white', (-.25, .74, 0), (.6, .1, .32), tint=(.2, .2, .22))
    f.box('iron', (.58, .97, 0), (.08, .06, .62))
    f.box('iron', (.6, .62, 0), (.06, .62, .08))
    f.box('paper', (.7, .88, 0), (.1, .12, .16))
    if fallen:
        p.solid(x, z, 1.9, 1.0, .9, yaw)
        r_ = 1.1
    else:
        p.solid(x, z, 1.7, .5, .9, yaw)
        r_ = .95
    p.note('moped', x, z)
    return r_


def bicycle(p, x, z, yaw, fallen=True, lane_offset=0.0):
    f = p.frame(x, z, yaw, 80 * p.rng.choice((-1, 1)) if fallen else 0, 0, lift=.12 if fallen else 0)
    for wx in (-.5, .5):
        f.cyl('iron', (wx, .33, 0), (.66, .035, .66), rot_x(90))
    f.box('iron', (0, .55, 0), (.9, .035, .035), rot_z(8))
    f.box('iron', (-.15, .5, 0), (.035, .4, .035), rot_z(-20))
    f.box('iron', (.38, .65, 0), (.035, .55, .035), rot_z(15))
    f.box('iron', (.42, .93, 0), (.04, .04, .5))
    f.box('wood', (-.22, .78, 0), (.22, .05, .1))
    if fallen:
        p.solid(x, z, 1.5, .6, .6, yaw)
    p.note('bicycle', x, z)
    return .85


def car(p, x, z, yaw, tint=None):
    f = p.frame(x, z, yaw)
    tint = tint or p.rng.choice(CAR_TINTS)
    f.box('white', (0, .6, 0), (4.2, .62, 1.8), tint=tint)
    f.box('white', (-.2, 1.2, 0), (2.3, .62, 1.62), tint=tint)
    f.box('white', (-.2, 1.22, 0), (2.34, .42, 1.66), tint=(.3, .45, .5))
    f.box('white', (-.2, 1.54, 0), (2.4, .08, 1.7), tint=tint)
    for wx in (-1.3, 1.3):
        for wz in (-.82, .82):
            f.cyl('iron', (wx, .34, wz), (.68, .24, .68), rot_x(90))
    f.box('iron', (2.12, .42, 0), (.18, .22, 1.7))
    f.box('iron', (-2.12, .42, 0), (.18, .22, 1.7))
    for wz in (-.6, .6):
        f.box('paper', (2.12, .7, wz), (.08, .16, .3))
        f.box('white', (-2.12, .7, wz), (.08, .14, .3), tint=(.8, .08, .08))
    p.solid(x, z, 4.4, 1.9, 1.5, yaw)
    p.note('car', x, z)
    return 2.5


def shelter(p, x, z, yaw, length=6.0):
    f = p.frame(x, z, yaw)
    f.box('white', (0, 2.55, 0), (length + .4, .12, 2.8), tint=(.35, .37, .4))
    for px in (-length / 2 + .1, length / 2 - .1):
        for pz in (-1.25, 1.25):
            f.box('iron', (px, 1.25, pz), (.14, 2.5, .14))
    f.box('concrete', (0, 1.0, -1.3), (length, 2.0, .1))
    count = max(3, int(length // 1.4))
    for i in range(count):
        bx = -length / 2 + .7 + i * ((length - 1.2) / max(1, count - 1))
        for wz in (-.4, .4):
            f.cyl('iron', (bx, .33, wz), (.66, .035, .66), rot_z(90))
        f.box('iron', (bx, .55, 0), (.035, .035, .8))
        f.box('iron', (bx, .93, .38), (.5, .04, .04))
    p.solid(x, z, length, 2.8, 1.3, yaw)
    p.note('shelter', x, z)
    return length / 2 + .8


def kiosk(p, x, z, yaw):
    f = p.frame(x, z, yaw)
    tint = p.rng.choice([(.9, .75, .4), (.4, .7, .8), (.85, .35, .3)])
    f.box('white', (0, 1.15, 0), (3.0, 2.3, 2.0), tint=tint)
    f.box('white', (0, 1.0, 1.02), (2.6, 1.5, .06), tint=(.4, .42, .45))
    f.box('red', (0, 2.45, .9), (3.6, .1, 1.5), rot_x(-10))
    f.box('white', (0, 2.0, 1.04), (2.2, .38, .05), tint=(.2, .4, .6))
    f.box('concrete', (0, 1.1, 1.2), (3.0, .12, .5))
    p.solid(x, z, 3.2, 2.3, 2.4, yaw)
    p.note('kiosk', x, z)
    return 2.3


def vending(p, x, z, yaw):
    f = p.frame(x, z, yaw)
    f.box('white', (0, .95, 0), (.9, 1.9, .8), tint=(.2, .4, .7))
    f.box('white', (0, 1.25, .41), (.62, .95, .03), tint=(.5, .7, .8))
    f.box('iron', (0, .25, .41), (.62, .2, .03))
    p.solid(x, z, .9, .8, 1.9, yaw)
    p.note('vending', x, z)
    return .75


def bench(p, x, z, yaw, overturned=False):
    f = p.frame(x, z, yaw, 0, 90 if overturned else 0, lift=.45 if overturned else 0)
    f.box('concrete', (0, .45, 0), (2.0, .1, .5))
    f.box('concrete', (0, .78, .22), (2.0, .45, .08))
    for lx in (-.8, .8):
        f.box('concrete', (lx, .22, 0), (.1, .45, .45))
    p.solid(x, z, 2.0, .6, .9, yaw)
    p.note('bench', x, z)
    return 1.2


def planter(p, x, z, yaw):
    f = p.frame(x, z, yaw)
    f.box('concrete', (0, .3, 0), (2.4, .6, .9))
    f.box('grass', (0, .62, 0), (2.2, .06, .7))
    for bx in (-.8, 0, .8):
        f.cone('white', (bx, 1.0 + p.rng.random() * .2, 0), (.95, .85, .95), tint=(.3, .55, .3))
    p.solid(x, z, 2.4, .9, 1.4, yaw)
    p.note('planter', x, z)
    return 1.45


def bin_(p, x, z, yaw, fallen=False):
    r = p.rng
    f = p.frame(x, z, yaw, 0, 88 if fallen else 0, lift=.26 if fallen else 0)
    f.cyl('white', (0, .42, 0), (.52, .84, .52), tint=r.choice([(.25, .5, .3), (.2, .3, .6), (.5, .5, .5)]))
    if fallen:
        spill = p.frame(x, z, yaw, batch=p.decals)
        for i in range(5):
            spill.quad('paper', (.7 + r.random() * .9, .055 + i * .002, (r.random() - .5) * .9), (.25, 1, .3), rot_y(r.random() * 180))
    p.solid(x, z, .6, .6, .9, yaw)
    p.note('bin', x, z)
    return .55


def signpost(p, x, z, yaw, lean=0.0):
    f = p.frame(x, z, yaw, 0, lean)
    f.cyl('iron', (0, 1.4, 0), (.11, 2.8, .11))
    f.box('white', (0, 2.5, .07), (1.4, .55, .05), tint=(.15, .35, .65))
    f.box('white', (0, 2.5, .1), (.7, .1, .02))
    f.box('white', (.28, 2.5, .1), (.28, .09, .02), rot_z(40))
    f.box('white', (.28, 2.5, .1), (.28, .09, .02), rot_z(-40))
    p.solid(x, z, .3, .3, 1.0, yaw)
    p.note('signpost', x, z)
    return .8


def notice_board(p, x, z, yaw):
    r = p.rng
    f = p.frame(x, z, yaw)
    for px in (-1.0, 1.0):
        f.box('iron', (px, 1.0, 0), (.1, 2.0, .1))
    f.box('wood', (0, 1.55, .03), (2.3, 1.25, .08))
    f.box('iron', (0, 2.2, .15), (2.6, .08, .6))
    for i in range(6):
        f.box('paper', (-.85 + (i % 3) * .85, 1.35 + (i // 3) * .55, .09), (.34, .42, .01), rot_z(r.uniform(-12, 12)))
    p.solid(x, z, 2.4, .5, 2.2, yaw)
    p.note('board', x, z)
    return 1.4


def lamp_fallen(p, x, z, yaw):
    f = p.frame(x, z, yaw, 88, 0, lift=.12)
    f.cyl('iron', (0, 3.2, 0), (.2, 6.4, .2))
    f.box('iron', (.5, 6.3, 0), (1.0, .08, .08))
    f.box('paper', (1.0, 6.25, 0), (.5, .1, .3), tint=(1, 1, .8))
    p.solid(x, z, .35, 6.4, .5, yaw, local=(0.0, 3.2))
    p.note('lamp_fallen', x, z)
    return 3.4


def lamp_leaning(p, x, z, yaw):
    f = p.frame(x, z, yaw, 0, 15)
    f.cyl('iron', (0, 3.4, 0), (.2, 6.8, .2))
    f.box('iron', (.5, 6.7, 0), (1.0, .08, .08))
    f.box('paper', (1.0, 6.65, 0), (.5, .1, .3), tint=(1, 1, .8))
    p.solid(x, z, .5, .5, 1.5, yaw)
    p.note('lamp_leaning', x, z)
    return 1.3


def tree_fallen(p, x, z, yaw):
    f = p.frame(x, z, yaw, 88, 0, lift=.3)
    f.cyl('wood', (0, 2.9, 0), (.55, 5.8, .55))
    f.cone('white', (0, 6.6, 0), (3.8, 3.6, 3.8), tint=(.15, .35, .15))
    for i in range(3):
        f.cone('wood', (math.sin(i * 2.1) * .5, -.1, math.cos(i * 2.1) * .5), (.5, 1.2, .5), rot_x(70 + i * 12))
    p.solid(x, z, .8, 6.0, .8, yaw, local=(0.0, 2.9))
    p.solid(x, z, 3.2, 3.4, 1.6, yaw, local=(0.0, 6.6))
    p.note('tree_fallen', x, z)
    return 4.6


def rubble(p, x, z, yaw, size=1.0):
    r = p.rng
    f = p.frame(x, z, yaw)
    for i in range(int(7 + 4 * size)):
        ang, rad = r.uniform(0, 6.28), r.uniform(0, .9 * size)
        s = r.uniform(.25, .75) * size
        f.box('concrete', (math.cos(ang) * rad, s * .35, math.sin(ang) * rad), (s, s * .7, s * r.uniform(.6, 1.2)),
              euler(r.uniform(0, 180), r.uniform(-25, 25), r.uniform(-25, 25)), tint=r.choice([(1, 1, 1), (.8, .8, .8), (.9, .9, .85)]))
    for i in range(3):
        f.cyl('iron', (r.uniform(-.5, .5) * size, .5, r.uniform(-.5, .5) * size), (.04, 1.1, .04), euler(0, r.uniform(20, 50), r.uniform(0, 360)), tint=(1, .8, .6))
    p.solid(x, z, 1.7 * size, 1.5 * size, .8, yaw)
    p.note('rubble', x, z)
    return 1.25 * size


def cones(p, x, z, yaw, count=3):
    for i in range(count):
        cx = (i - (count - 1) / 2) * 1.0
        tip = p.rng.random() < .25
        g = p.frame(x + math.cos(math.radians(yaw)) * cx, z - math.sin(math.radians(yaw)) * cx, yaw, 0, 85 if tip else 0, lift=.3 if tip else 0)
        g.cone('white', (0, .35, 0), (.36, .7, .36), tint=(.95, .4, .1))
        g.box('white', (0, .02, 0), (.46, .04, .46), tint=(.6, .6, .6))
    p.note('cones', x, z)
    return count * .5 + .2


def barrier(p, x, z, yaw):
    f = p.frame(x, z, yaw)
    for i, tint in enumerate([(.9, .9, .9), (.9, .12, .12)] * 2):
        f.box('white', (-.9 + i * .6, .75, 0), (.6, .28, .06), tint=tint)
    for lx in (-1.0, 1.0):
        f.box('iron', (lx, .4, 0), (.07, .8, .5))
    p.solid(x, z, 2.2, .5, 1.0, yaw)
    p.note('barrier', x, z)
    return 1.3


def crates(p, x, z, yaw):
    r = p.rng
    f = p.frame(x, z, yaw)
    for i in range(r.randint(3, 5)):
        f.box('white', (r.uniform(-.7, .7), .3 + (i % 2) * .6, r.uniform(-.5, .5)), (.8, .6, .8), rot_y(r.uniform(0, 90)), tint=(.45, .3, .15))
    p.solid(x, z, 2.0, 1.6, 1.2, yaw)
    p.note('crates', x, z)
    return 1.3


def lit_lamp(p, x, z, yaw=0):
    f = p.frame(x, z, yaw)
    f.cyl('iron', (0, 2.6, 0), (.14, 5.2, .14))
    f.box('iron', (.4, 5.15, 0), (.8, .07, .07))
    f.box('paper', (.8, 5.1, 0), (.45, .1, .28), tint=(1, 1, .8))
    p.lights.append((x + .8, G + 4.9, z, yaw))
    p.solid(x, z, .3, .3, 1.5, yaw)
    p.note('lit_lamp', x, z)
    return .9


# --------------------------------------------------------- small, non-solid
def backpack(p, x, z):
    r = p.rng
    f = p.frame(x, z, r.uniform(0, 360), 78, 0, lift=.12)
    tint = r.choice(BAG_TINTS)
    f.box('white', (0, .2, 0), (.32, .42, .2), tint=tint)
    f.box('white', (0, .12, .12), (.26, .2, .06), tint=tuple(v * .7 for v in tint))


def shoes(p, x, z):
    r = p.rng
    yaw = r.uniform(0, 360)
    tint = r.choice([(.15, .15, .18), (.85, .85, .85), (.7, .15, .1), (.2, .35, .7)])
    for i, dx in enumerate((-.12, .12)):
        yy = yaw + r.uniform(-25, 25)
        g = p.frame(x + dx, z + r.uniform(-.1, .1), yy, 0, 70 if i and r.random() < .4 else 0, lift=.06)
        g.box('white', (0, .05, 0), (.26, .1, .1), tint=tint)


def sandals(p, x, z):
    r = p.rng
    tint = r.choice([(.8, .1, .1), (.15, .3, .8), (.1, .1, .1)])
    for dx in (-.14, .14):
        p.decals.add('white', 'quad', (x + dx + r.uniform(-.1, .1), p.ground + .062, z + r.uniform(-.2, .2)), (.11, 1, .27), rot_y(r.uniform(0, 360)), tint)


def tray(p, x, z):
    r = p.rng
    f = p.frame(x, z, r.uniform(0, 360), 0, 0, lift=.02)
    f.box('white', (0, .015, 0), (.42, .03, .3), tint=(.7, .7, .72))
    f.box('paper', (0, .035, .06), (.34, .012, .16), tint=(.9, .8, .6))


def papers(p, x, z, n=6, spread=1.0):
    r = p.rng
    for i in range(n):
        p.decals.add('paper', 'quad', (x + r.uniform(-spread, spread), p.ground + .058 + i * .0008, z + r.uniform(-spread, spread)),
                     (.18, 1, .26), rot_y(r.uniform(0, 360)), (1, 1, .95))


def phone(p, x, z):
    r = p.rng
    yaw = r.uniform(0, 360)
    p.decals.add('white', 'quad', (x, p.ground + .066, z), (.07, 1, .15), rot_y(yaw), (.4, .55, .65))
    p.decals.add('iron', 'quad', (x, p.ground + .068, z), (.012, 1, .17), rot_y(yaw + 30), (.4, .4, .4))


def glass_shards(p, x, z, n=9, spread=1.2):
    r = p.rng
    for i in range(n):
        s = r.uniform(.05, .2)
        p.decals.add('white', 'quad', (x + r.uniform(-spread, spread), p.ground + .06 + i * .0006, z + r.uniform(-spread, spread)),
                     (s, 1, s * r.uniform(.4, 1.0)), rot_y(r.uniform(0, 360)), (.55, .75, .85))


def blood(p, x, z, size=1.0):
    r = p.rng
    for i in range(3):
        s = size * r.uniform(.5, 1.0)
        p.decals.add('red', 'quad', (x + r.uniform(-.25, .25) * size, p.ground + .054 + i * .0007, z + r.uniform(-.25, .25) * size), (s, 1, s * r.uniform(.5, 1.0)),
                     rot_y(r.uniform(0, 360)), (.9, .6, .6))


def crack(p, x, z, yaw, length=7.0, width=.1):
    r = p.rng
    a = math.radians(yaw)
    cx, cz = x, z
    done = 0.0
    while done < length:
        seg = r.uniform(.8, 1.6)
        a += math.radians(r.uniform(-28, 28))
        ex, ez = cx + math.cos(a) * seg, cz - math.sin(a) * seg
        p.decals.add('iron', 'quad', ((cx + ex) / 2, p.ground + .056, (cz + ez) / 2), (seg + .05, 1, width * r.uniform(.6, 1.2)),
                     rot_y(math.degrees(a)), (.3, .3, .3))
        cx, cz = ex, ez
        done += seg
        if r.random() < .18:
            crack(p, cx, cz, math.degrees(a) + r.choice((-50, 50)), length * .35, width * .7)


def body(p, x, z, yaw, face_down=None):
    """A person lying on the ground: a still model, not a zombie."""
    r = p.rng
    shirt = r.choice(SHIRTS)
    jeans = r.choice(JEANS)
    f = p.frame(x, z, yaw, 0, 0, lift=0)
    f.box('white', (0, .13, 0), (.34, .24, .55), tint=shirt)
    f.box('paper', (0, .12, .42), (.22, .22, .22), tint=SKIN)
    sx = r.uniform(.12, .5)
    f.box('white', (.3, .1, .05 - sx * .3), (.12, .12, .55), euler(r.uniform(-50, 10), 0, 0), tint=shirt)
    f.box('white', (-.3, .1, .05 + sx * .3), (.12, .12, .55), euler(r.uniform(-10, 70), 0, 0), tint=shirt)
    spread = r.uniform(4, 20)
    f.box('white', (.13, .09, -.62), (.15, .15, .78), euler(spread, 0, 0), tint=jeans)
    f.box('white', (-.13, .09, -.62), (.15, .15, .78), euler(-spread, 0, 0), tint=jeans)
    if r.random() < .7:
        blood(p, x + math.sin(math.radians(yaw)) * .1, z + math.cos(math.radians(yaw)) * .1, r.uniform(.8, 1.4))
    p.note('body', x, z)
    return .9


def hurdle(p, x, z, yaw, down=False):
    f = p.frame(x, z, yaw, 0, 82 if down else 0, lift=.5 if down else 0)
    for hx in (-.55, .55):
        f.box('white', (hx, .42, 0), (.04, .84, .04))
    f.box('white', (0, .84, 0), (1.2, .07, .05), tint=(1.0, .5, .5))
    p.note('hurdle', x, z)
    return .8


def gym_bag(p, x, z):
    r = p.rng
    f = p.frame(x, z, r.uniform(0, 360))
    f.box('white', (0, .17, 0), (.75, .32, .3), tint=r.choice(BAG_TINTS))
    p.note('bag', x, z)


def litter(p, x, z):
    """A small spill of what people dropped while running."""
    r = p.rng
    for i in range(r.randint(1, 3)):
        px, pz = x + r.uniform(-1.4, 1.4), z + r.uniform(-1.4, 1.4)
        r.choice((backpack, shoes, shoes, sandals, tray, phone, phone))(p, px, pz)
    papers(p, x, z, r.randint(3, 6), 1.6)
    p.note('litter', x, z)


# ------------------------------------------------------------------ placement
# name -> (builder, footprint radius, local z offset of the footprint centre)
KINDS = {
    'moped': (moped, 1.15, 0.0), 'bicycle': (bicycle, .9, 0.0), 'car': (car, 2.55, 0.0),
    'kiosk': (kiosk, 2.35, 0.0), 'vending': (vending, .8, 0.0), 'bench': (bench, 1.25, 0.0),
    'planter': (planter, 1.5, 0.0), 'bin': (bin_, .6, 0.0), 'signpost': (signpost, .85, 0.0),
    'board': (notice_board, 1.45, 0.0), 'lamp_fallen': (lamp_fallen, 1.4, 3.2),
    'lamp_leaning': (lamp_leaning, 1.4, 0.0), 'tree_fallen': (tree_fallen, 4.2, 3.6),
    'rubble': (rubble, 1.3, 0.0), 'cones': (cones, 1.9, 0.0), 'barrier': (barrier, 1.4, 0.0),
    'crates': (crates, 1.4, 0.0), 'shelter': (shelter, 4.2, 0.0),
}
ZONE_TABLES = {
    'road': {'moped': 6, 'bicycle': 3, 'bin': 3, 'bench': 3, 'car': 4, 'signpost': 2, 'board': 1, 'lamp_fallen': 1,
             'lamp_leaning': 1, 'tree_fallen': 1, 'rubble': 2, 'planter': 3, 'kiosk': .6, 'shelter': .4,
             'cones': 1, 'barrier': .5, 'crates': .3, 'vending': .4},
    'gate': {'car': 6, 'barrier': 3, 'cones': 4, 'rubble': 2, 'moped': 2, 'bin': 1, 'signpost': 1, 'bench': .5},
    'canteen': {'moped': 3, 'bicycle': 4, 'bench': 2, 'bin': 2, 'planter': 2, 'board': 1.5, 'vending': 1,
                'shelter': .8, 'kiosk': 1, 'rubble': 1},
    'stadium': {'moped': 3, 'bicycle': 3, 'bin': 2, 'bench': 2, 'signpost': 1.5, 'rubble': 2, 'cones': 2,
                'barrier': 1.5, 'planter': 1},
    'building': {'shelter': 2, 'bicycle': 3, 'moped': 3, 'bin': 3, 'rubble': 3, 'tree_fallen': 1, 'planter': 1,
                 'bench': 1, 'crates': 1},
}
ZONE_DENSITY = {'road': .62, 'gate': .8, 'canteen': .8, 'stadium': .7, 'building': .75}
LARGE = {'car', 'shelter', 'kiosk', 'tree_fallen', 'lamp_fallen'}


def profile(x, z):
    if 186 <= x <= 254 and -62 <= z <= -18:
        return 'gate'
    if 160 <= x <= 228 and -12 <= z <= 22:
        return 'canteen'
    if 78 <= x <= 118 and 140 <= z <= 195:
        return 'stadium'
    if -30 <= x <= 56 and -45 <= z <= -8:
        return 'building'
    return 'road'


def place(p, kind, x, z, yaw, **kw):
    func, r, off = KINDS[kind]
    s_, c_ = math.sin(math.radians(yaw)), math.cos(math.radians(yaw))
    cx, cz = x + s_ * off, z + c_ * off
    if not p.free(cx, cz, r):
        return False
    before = p.batch.triangles + p.decals.triangles
    func(p, x, z, yaw, **kw)
    p.tri[kind] = p.tri.get(kind, 0) + p.batch.triangles + p.decals.triangles - before
    p.reserve(cx, cz, r)
    return True


def place_any(p, kind, candidates, **kw):
    for x, z, yaw in candidates:
        if place(p, kind, x, z, yaw, **kw):
            return True
    return False


def free_small(p, x, z):
    if not (BOUNDS[0] < x < BOUNDS[1] and BOUNDS[2] < z < BOUNDS[3]):
        return False
    for a, b, c0, d in p.c.BLOCKS:
        if a < x < b and c0 < z < d:
            return False
    return True


def small(p, kind, x, z, **kw):
    if not free_small(p, x, z):
        return False
    before = p.batch.triangles + p.decals.triangles
    {'litter': litter, 'body': lambda pp, xx, zz: body(pp, xx, zz, pp.rng.uniform(0, 360)), 'bag': gym_bag,
     'glass': glass_shards, 'blood': blood, 'papers': papers}[kind](p, x, z, **kw)
    p.tri[kind] = p.tri.get(kind, 0) + p.batch.triangles + p.decals.triangles - before
    return True


def pick(rng, table):
    names = list(table)
    return rng.choices(names, [table[n] for n in names])[0]


def route_pass(p):
    rng = p.rng
    for a, b in p.segs:
        length = math.hypot(b[0] - a[0], b[1] - a[1])
        ux, uz = (b[0] - a[0]) / length, (b[1] - a[1]) / length
        nx, nz = -uz, ux
        heading = math.degrees(math.atan2(ux, uz))
        count = max(1, int(length // 10))
        for i in range(count):
            t = (i + .5 + rng.uniform(-.3, .3)) / count
            px, pz = a[0] + ux * length * t, a[1] + uz * length * t
            zone = profile(px, pz)
            for side in (-1, 1):
                if rng.random() > ZONE_DENSITY[zone]:
                    continue
                for attempt in range(4):
                    kind = pick(rng, ZONE_TABLES[zone])
                    lateral = rng.uniform(4.2 if kind in LARGE else 3.6, 9.5 if kind in LARGE else 8.0) * side
                    x, z = px + nx * lateral, pz + nz * lateral
                    # Vehicles, benches and shelters line up with the road; the rest lie anywhere.
                    aligned = kind in ('car', 'bench', 'shelter', 'barrier', 'kiosk')
                    yaw = heading + (90 if kind in ('bench', 'kiosk') else 0) + (0 if kind != 'car' else rng.choice((0, 180)))
                    yaw += rng.uniform(-14, 14) if aligned else rng.uniform(0, 360)
                    if kind == 'bench' or kind == 'kiosk':
                        yaw = heading + (90 if side == -1 else -90) + rng.uniform(-8, 8)
                    extra = {}
                    if kind == 'moped':
                        extra['fallen'] = rng.random() < .75
                    if kind == 'bicycle':
                        extra['fallen'] = rng.random() < .8
                    if kind == 'bin':
                        extra['fallen'] = rng.random() < .35
                    if kind == 'bench':
                        extra['overturned'] = rng.random() < .15
                    if kind == 'signpost':
                        extra['lean'] = rng.choice((0, 0, 9, -11, 16))
                    if kind == 'cones':
                        extra['count'] = rng.randint(2, 4)
                    if kind == 'rubble':
                        extra['size'] = rng.uniform(.8, 1.5)
                    if place(p, kind, x, z, yaw, **extra):
                        break
            # Things dropped by people running past; bodies stay clear of the lane.
            if rng.random() < .45:
                lat = rng.choice((-1, 1)) * rng.uniform(1.5, 7.0)
                small(p, 'litter', px + nx * lat, pz + nz * lat)
            if rng.random() < .16:
                lat = rng.choice((-1, 1)) * rng.uniform(2.6, 6.5)
                small(p, 'body', px + nx * lat, pz + nz * lat)
            if rng.random() < .25:
                lat = rng.uniform(-3, 3)
                crack(p, px + nx * lat - ux * 3.5, pz + nz * lat - uz * 3.5, math.degrees(math.atan2(-nz, nx)) + rng.uniform(-35, 35), 6.5 + rng.random() * 3)
                p.note('crack', px, pz)


def density_fill(p):
    """Every route sample keeps at least NEED_WITHIN_30M notable things in view."""
    rng = p.rng
    added = 0
    for a, b in p.segs:
        length = math.hypot(b[0] - a[0], b[1] - a[1])
        ux, uz = (b[0] - a[0]) / length, (b[1] - a[1]) / length
        nx, nz = -uz, ux
        steps = max(1, int(length // SAMPLE_STEP))
        for i in range(steps + 1):
            px, pz = a[0] + ux * length * i / steps, a[1] + uz * length * i / steps
            for attempt in range(40):
                if p.count_near(px, pz) >= NEED_WITHIN_30M:
                    break
                lat = rng.choice((-1, 1)) * rng.uniform(2.4, 9.0)
                x, z = px + nx * lat + ux * rng.uniform(-8, 8), pz + nz * lat + uz * rng.uniform(-8, 8)
                if rng.random() < .5:
                    added += small(p, 'litter', x, z)
                else:
                    added += place(p, pick(rng, {'bin': 2, 'bench': 1, 'signpost': 1, 'planter': 1, 'bicycle': 2, 'moped': 2, 'rubble': 1}),
                                   x, z, rng.uniform(0, 360))
    return added


def stand_surface_items(p):
    """Bodies and bags left on the stands; they sit on the sloped walking surface."""
    import stands
    main, south = stands.STANDS
    rng = p.rng
    for (st, spots) in ((main, [(186.5, 218.4), (209.0, 221.8), (231.5, 225.2), (166.0, 216.3), (214.0, 226.4)]),
                        (south, [(176.0, 117.0), (205.0, 115.2)])):
        for i, (x, z) in enumerate(spots):
            p.ground = G + stands.height_at(st, z) - .02
            if i % 2 == 0:
                body(p, x, z, rng.uniform(0, 360))
            else:
                gym_bag(p, x, z)
                backpack(p, x + .8, z + .2)
            p.note('stand_item', x, z)
    p.ground = G


def set_pieces(p):
    rng = p.rng
    # Garden: lanes between the beds hold what people dropped (beds and benches stay clear).
    for x, z in [(13, 17), (31, 18.5), (15, 27), (30, 37), (12, 45.5), (36, 45.5), (30, 27), (14, 37.5)]:
        small(p, 'litter', x, z)
    for x, z in [(11.5, 17.2), (29.0, 27.2), (14.5, 36.6)]:
        small(p, 'body', x, z)
    for x, z, yaw in [(14, 25.5, 20), (32, 17, -35), (24, 38, 70)]:
        crack(p, x, z, yaw, 6.5, .11)
    notice_board(p, 30.5, 11.2, 180)
    p.reserve(30.5, 11.2, 1.5)
    # Behind building B: rubble and glass under the broken windows, a bike park.
    for x, z in [(12.5, -10.6), (27, -10.2), (40, -10.6)]:
        rubble(p, x, z, rng.uniform(0, 360), 1.6)
        p.reserve(x, z, 1.9)
    for x in (2.2, 7.8, 17, 33):
        glass_shards(p, x, -9.4, 8, 1.4)
    for x, z in [(1.8, -9.7), (7.5, -10.2), (-4, -10.5)]:
        small(p, 'litter', x, z)
    place_any(p, 'shelter', [(30, -27, 0), (24, -30, 0), (36, -30, 0)])
    # Building A front: rubble and glass under the silhouette windows.
    for x in (8, 22, 36):
        rubble(p, x, 51.0, rng.uniform(0, 360), 1.8)
        p.reserve(x, 51.0, 2.1)
        glass_shards(p, x + 2.5, 52.4, 10, 1.6)
    # Direction signs and notice boards at the junctions (no text: the school name stays open, T-183).
    for spots in ([(86.5, -9.5, 10), (74, -21, -8)], [(88, 24, 0)], [(93, 160, 90)], [(214, -8, 180)], [(88, 96, -5)], [(70, 38, 8)]):
        place_any(p, 'signpost', [(x, z, yaw, ) for x, z, yaw in spots])
    for spots in ([(70, 150, 90), (92, 150, 270)], [(226, 8, 180), (236, 6, 180)], [(96, -9, 180), (104, -21, 0)], [(60, -8, 0), (60, -22, 180)]):
        place_any(p, 'board', spots)
    # A tree down beside the roads.
    place_any(p, 'tree_fallen', [(68, 60, 8), (100, 96, 172), (118, -27, 92), (40, -36, 30), (160, -31, 95), (66, 122, 4)])
    place_any(p, 'tree_fallen', [(100, 36, 170), (140, -30, 85), (60, 150, 10)])
    # Earthquake debris at the foot of the far buildings (lecture hall, library, gym).
    for x, z in [(-30, 177), (-8, 177), (14, 177), (58, 192), (78, 192), (-40, 87), (-15, 87)]:
        rubble(p, x, z, rng.uniform(0, 360), 2.0)
        p.reserve(x, z, 2.4)
        glass_shards(p, x + 2.6, z + .5, 8, 1.5)
    # Gate court.
    place(p, 'car', 208, -37, 62)
    place(p, 'car', 211.5, -41.5, -35)
    place(p, 'car', 238.5, -33.5, 100)
    for x, z, yaw in [(232, -28, 15), (236, -26, 10), (228, -24, 20), (240, -30, 5)]:
        if place(p, 'car', x, z, yaw, tint=(.95, .95, .98)):
            p.blinkers.append((x, G + 1.9, z))
            break
    for x in (203, 207, 235):
        place(p, 'cones', x, -47.5, 0, count=3)
    place(p, 'barrier', 213, -49.5, 8)
    place(p, 'barrier', 227, -49.5, -6)
    for x, z in [(205, -43.5), (236, -40.2), (214.5, -34.4)]:
        small(p, 'body', x, z)
    for x, z in [(200, -36), (241, -44), (219, -46)]:
        small(p, 'litter', x, z)
    # Canteen front yard.
    place_any(p, 'shelter', [(166, 8, 0), (170, 4, 0)])
    place_any(p, 'vending', [(182.2, 16.2, 180), (198.5, 15.0, 180)])
    place_any(p, 'kiosk', [(214, 18, 180), (214, 24, 180)])
    place_any(p, 'board', [(181, 14.0, 180), (200.5, 17.5, 180)])
    for x, z in [(179, 13.5), (204, 12.5), (196, 6)]:
        small(p, 'litter', x, z)
    # Stadium: knocked-over hurdles, cones and bags on the track, litter on the grass, cracks.
    for x in range(168, 233, 8):
        hurdle(p, x + rng.uniform(-1.5, 1.5), 127.0 + rng.choice((0, 1.22)), rng.uniform(75, 105), down=rng.random() < .55)
    for i in range(6):
        hurdle(p, 120 + i * 3.3, 160 + rng.uniform(-3, 3), rng.uniform(0, 360), down=True)
    for x, z in [(142, 128), (254, 206), (263, 147), (150, 205), (176, 133), (222, 202)]:
        gym_bag(p, x, z)
        backpack(p, x + 1.1, z + .6)
    for x, z in [(131, 147), (170, 154), (226, 130), (262, 181), (238, 196), (146, 192), (124, 134)]:
        small(p, 'litter', x, z)
    for x, z in [(141, 143), (203, 199.5), (260, 160), (192, 125), (244, 128), (156, 207)]:
        small(p, 'body', x, z)
    for x, z, yaw in [(130, 168, 80), (210, 150, 10), (174, 196, 150), (262, 140, 120), (198, 128, 30)]:
        crack(p, x, z, yaw, 8.0, .12)
    stand_surface_items(p)
    # Under the main stand: crates and rubbish beside the pickable pipes at x = 163..164.
    for x, z in [(186, 222.5), (214, 225.5)]:
        crates(p, x, z, rng.uniform(0, 90))
        p.reserve(x, z, 1.4)
    for x, z in [(176, 224), (196, 226.5), (232, 223)]:
        small(p, 'litter', x, z)
    small(p, 'body', 205, 224.2)
    # Earthquake: cracked roads at junctions and in front of every building.
    for x, z, yaw in [(80, -15, 90), (80, 28, 0), (80, 166, 90), (220, -15, 90), (100, -15, 100), (150, -15, 80),
                      (180, -15, 95), (80, 80, 10), (80, 120, 75), (-8, -2, 20), (-8, 4, 100), (44, 1, 90), (60, -15, 80)]:
        crack(p, x - 3, z, yaw, 9.0, .13)


# ---------------------------------------------------------- trees and lights
def extra_trees(p):
    rng = p.rng
    pts = []

    def add(x, z):
        x += rng.uniform(-1.2, 1.2)
        z += rng.uniform(-1.2, 1.2)
        if p.free(x, z, .6) and not any(math.hypot(x - a, z - b) < 3 for a, b in pts):
            pts.append((x, z))
            p.reserve(x, z, .6)

    for x in range(6, 186, 14):
        add(x, -27)
    for x in range(256, 400, 14):
        add(x, -27)
    for x in range(60, 214, 18):
        add(x, -3.5)
    for z in range(10, 164, 14):
        add(91, z)
    for z in range(8, 164, 20):
        add(64, z)
    for x in range(52, 78, 9):
        add(x, 19)
        add(x, 37)
    for z in range(-12, 8, 11):
        add(211, z)
        add(229, z)
    for z in range(-30, 6, 10):
        add(-14, z)
    trees = [(x, G, z) for x, z in pts]
    for x, z in pts:
        p.solid(x, z, .5, .5, 3.0, 0)
    INFO['extra_trees'] = len(trees)
    return trees


LIT_LAMPS = [(130, -21.5), (62, -21.5), (96, 130), (205, -6), (240, -22), (176, 11)]
EXISTING_LAMP_LIGHTS = [(20, -20), (100, -20), (160, -20), (86, 45), (86, 105), (86, 165)]


# --------------------------------------------------------------------- output
def chunk_key(x, z):
    return (math.floor(x / 40.0), math.floor(z / 40.0))


def build(c):
    p = Props(c)
    detail_trees = []
    set_pieces(p)
    route_pass(p)
    for x, z in LIT_LAMPS:
        if p.free(x, z, 1.0):
            lit_lamp(p, x, z)
            p.reserve(x, z, 1.0)
    # One lamp per skipped standing lamp lies or leans where it stood.
    for i, (x, z) in enumerate(detail.SKIP_LAMPS):
        lamp = 'lamp_fallen' if i % 2 == 0 else 'lamp_leaning'
        # A fallen pole lies along its road, never across the lane.
        yaw = p.rng.uniform(0, 360) if lamp == 'lamp_leaning' else (90 if z == -20 else 0) + p.rng.uniform(-18, 18)
        if not place(p, lamp, x, z, yaw):
            place(p, 'lamp_leaning', x, z, p.rng.uniform(0, 360))
    detail_trees = extra_trees(p)
    added = density_fill(p)
    INFO.update(tri_by_kind=dict(sorted(p.tri.items(), key=lambda kv: -kv[1])), density_added=added, notable=len(p.points), counts=dict(sorted(p.counts.items())),
                triangles=p.batch.triangles + p.decals.triangles, solids=len(p.solids), lights=len(p.lights))
    return p, detail_trees


def emit(c, p, trees, filename='props.tscn'):
    s = c.Scene('Props')
    points = p.points
    s.nodes[0] += 'metadata/points = PackedVector3Array(' + ','.join('%.2f,%.2f,%.2f' % pt for pt in points) + ')\n'
    script = s.resource('res://scenes/levels/campus/boxes.gd', 'Script')
    s.node('Parts')
    p.batch.emit(s, 'Parts', script, 'P', cull=125.0)
    s.node('Decals')
    p.decals.emit(s, 'Decals', script, 'D', cull=80.0)
    s.node('Solids')
    chunks = {}
    for item in p.solids:
        chunks.setdefault(chunk_key(item[0], item[1]), []).append(item)
    shapes = {}
    for (cx, cz), items in sorted(chunks.items()):
        body = s.node('Body_%s%d_%s%d' % ('m' if cx < 0 else 'p', abs(cx), 'm' if cz < 0 else 'p', abs(cz)), 'StaticBody3D', 'Solids',
                      'collision_layer = 1\ncollision_mask = 0\nmetadata/surface = &"concrete"')
        for i, (x, z, w, d, h, yaw) in enumerate(items):
            key = (round(w, 2), round(h, 2), round(d, 2))
            if key not in shapes:
                shapes[key] = s.subresource('BoxShape3D', 'size = ' + c.V((key[0], key[1], key[2])))
            props = 'position = %s\nshape = %s' % (c.V((x, G + h / 2, z)), shapes[key])
            if abs(yaw) > .01:
                props += '\nrotation_degrees = Vector3(0,%s,0)' % round(yaw, 2)
            s.node('S%d' % i, 'CollisionShape3D', body, props)
    s.node('Lights')
    flicker = s.resource('res://scenes/levels/campus/flicker.gd', 'Script')
    for i, (x, y, z, _) in enumerate(p.lights):
        s.node('Lamp%d' % i, 'OmniLight3D', 'Lights',
               'position = %s\nlight_energy = 0.8\nlight_color = Color(1,0.84,0.52,1)\nomni_range = 15.0\nshadow_enabled = false\n'
               'distance_fade_enabled = true\ndistance_fade_begin = 90.0\ndistance_fade_length = 30.0' % c.V((x, y, z)))
    for i, (x, y, z) in enumerate(p.blinkers):
        s.node('Hazard%d' % i, 'OmniLight3D', 'Lights',
               'position = %s\nscript = %s\nphase = %s\nlight_energy = 0.8\nlight_color = Color(1,0.55,0.1,1)\nomni_range = 7.0\nshadow_enabled = false\n'
               'distance_fade_enabled = true\ndistance_fade_begin = 70.0\ndistance_fade_length = 20.0' % (c.V((x, y, z)), flicker, i * 2.3))
    for i, (x, z) in enumerate(EXISTING_LAMP_LIGHTS):
        extra = 'script = %s\nphase = %s\n' % (flicker, i * 1.7) if i % 3 == 1 else ''
        s.node('StreetLamp%d' % i, 'OmniLight3D', 'Lights',
               'position = %s\n%slight_energy = 0.8\nlight_color = Color(1,0.84,0.52,1)\nomni_range = 15.0\nshadow_enabled = false\n'
               'distance_fade_enabled = true\ndistance_fade_begin = 90.0\ndistance_fade_length = 30.0' % (c.V((x, G + 6.9, z)), extra))
    if trees:
        s.node('Trees')
        detail.cluster(s, 'ExtraTrees', trees, 'tree', 'Trees')
    s.save(filename)
