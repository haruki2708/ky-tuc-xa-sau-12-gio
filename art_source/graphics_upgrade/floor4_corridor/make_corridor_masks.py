"""T-235: paint the whole corridor's mask atlases (walls, floor, ceiling), like the T-233 pilot and room 407
(../room407_shell/make_shell_masks.py, whose noise and Field helpers this reuses). Channels, read by
game/rendering/room407_shell.gdshader:
  walls, ceiling   R paint loss   G grime   B water stain   A mould
  floor, skirting  R grout dirt   G grime   B wet           A wear (polished lane)
Every pixel comes from the corridor point it covers and the noise runs on each surface's own coordinates, so the
pieces of one surface (cut per bay and per atlas rectangle) join without a seam, and no stain repeats: each door
gets its own hand marks, the washroom entrance is damp, the leaks and cracks sit at a few places only.
Option A (D-142): grime at the foot of the wall and round the places hands touch; nothing that tells a story
(no blood, writing, signs or posters).
Run: python -B make_corridor_masks.py [walls floor ceiling]   (numpy, Pillow; a few minutes)
"""
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "room407_shell"))
import make_shell_masks as M  # noqa: E402
import corridor_layout as L  # noqa: E402

OUT = HERE.parents[2] / "game/assets/textures/graphics_pilot/floor4_corridor"
NEUTRAL_VALUE = {"walls": (0, 30, 0, 0), "ceiling": (0, 30, 0, 0), "floor": (90, 20, 0, 0)}
smooth, fbm = M.smooth, M.fbm
ROOM_DOORS = [d for d in L.DOORS if d.swing != "sealed"]
SEALED = next(d for d in L.DOORS if d.swing == "sealed")


class FaceField(M.Field):
    """Pixels of one atlas rectangle: the piece a0..a1, b0..b1 of its surface, with bleed."""

    def __init__(self, face, scale):
        x0, y0, w, h = face.rect
        cols = np.arange(-L.PAD, w + L.PAD) + 0.5
        rows = np.arange(-L.PAD, h + L.PAD) + 0.5
        self.a, self.b = np.meshgrid(face.a0 + cols / scale, face.b0 + rows / scale)
        o, u, v = face.origin, face.u, face.v
        self.X = o[0] + u[0] * self.a + v[0] * self.b
        self.Y = o[1] + u[1] * self.a + v[1] * self.b
        self.Z = o[2] + u[2] * self.a + v[2] * self.b
        self.s, self.scale = face, scale
        seed = face.seed
        self.n1 = fbm(self.a, self.b, seed, 1.2)
        self.n2 = fbm(self.a, self.b, seed + 7, 5.0)
        self.n3 = fbm(self.a, self.b, seed + 13, 22.0, 3)
        self.R, self.G, self.B, self.A = (np.zeros(self.a.shape) for _ in range(4))
        self.xmin, self.xmax = float(self.X.min()), float(self.X.max())

    def near(self, x, reach):
        return self.xmin - reach <= x <= self.xmax + reach


# ---------------------------------------------------------------- features placed once for the whole corridor

def _features():
    rng = np.random.default_rng(235)
    f = {}
    # Per door: how much the latch side is handled (407 is the room we know; the old 408 doorway long unused).
    f["latch"] = {}
    for d in L.DOORS:
        amount = {"407": 1.25, "408Old": 0.3}.get(d.room, rng.uniform(0.6, 1.15))
        f["latch"][d.room] = (amount, rng.normal(0, 0.025), rng.normal(0, 0.06))
    # Shoe scuffs at the foot of the hall wall, level and soft; a few through the paint.
    stops = [(L.WASHROOM[0] - 0.02, L.WASHROOM[1] + 0.02)] + [
        (d.hole[0] - L.ARCH_W - 0.02, d.hole[1] + L.ARCH_W + 0.02) for d in L.DOORS]
    scuffs = []
    for _ in range(int((L.X1 - L.X0) * 2.5)):
        x = rng.uniform(L.X0 + 0.05, L.X1 - 0.05)
        if any(a < x < b for a, b in stops):
            continue
        y, ang = rng.uniform(0.04, 0.3), rng.normal(0, 0.12)
        pts = [(x, y)]
        for _k in range(4):
            pts.append((pts[-1][0] + 0.03 * math.cos(ang), pts[-1][1] + 0.03 * math.sin(ang)))
        scuffs.append((pts, rng.random() < 0.1))
    f["wall_scuffs"] = scuffs
    # End walls (z along the wall): fewer, the stairs traffic passes them.
    f["end_scuffs"] = []
    for _ in range(14):
        z, y, ang = rng.uniform(0.3, 3.7), rng.uniform(0.04, 0.25), rng.normal(0, 0.12)
        pts = [(z, y)]
        for _k in range(4):
            pts.append((pts[-1][0] + 0.03 * math.cos(ang), pts[-1][1] + 0.03 * math.sin(ang)))
        f["end_scuffs"].append(pts)
    # Black shoe scuffs in the walking lane.
    floor_scuffs = []
    for _ in range(int((L.X1 - L.X0) / 8 * 45)):
        cx, cz = rng.uniform(L.X0 + 0.2, L.X1 - 0.2), rng.normal(2.0, 0.55)
        ang = rng.uniform(0, math.tau)
        floor_scuffs.append([(cx + 0.012 * k * math.cos(ang + 0.15 * k), cz + 0.012 * k * math.sin(ang + 0.15 * k))
                             for k in range(6)])
    f["floor_scuffs"] = floor_scuffs
    # Ceiling: a few cracks (x, z) and three old leaks, nowhere near repeating per door.
    cracks = []
    for start, heading, steps in (((4.6, 0.1), 1.5, 70), ((11.3, 2.5), 0.15, 55), ((19.7, 0.1), 1.45, 75),
                                  ((25.2, 4.0), -1.75, 45), ((30.0, 0.1), 1.57, 90), ((36.8, 1.2), 2.9, 50),
                                  ((42.6, 4.0), -1.4, 40)):
        cracks += M.walk(rng, start, heading, steps, 0.04, 0.12, 0.1)
    f["ceiling_cracks"] = cracks
    f["leaks"] = [((13.4, 1.7), 0.4, 134), ((29.4, 1.3), 0.45, 294), ((41.1, 2.9), 0.55, 411)]
    # Lamps: soot builds up differently over each batten.
    f["soot"] = {x: rng.uniform(0.3, 0.6) for _, x in L.LIGHTS}
    # Infill of the old 408 doorway: a settling crack from its top corner.
    f["infill_crack"] = M.walk(rng, (SEALED.x1 - 0.05, SEALED.top - 0.05), -2.2, 22, 0.03, 0.25, 0.15)
    return f


F = _features()


# ---------------------------------------------------------------- walls

def damp_foot(f, level, strength=1.0):
    """Damp wicking up from the mopped floor: a low tide line in patches, flaking paint and a little mould."""
    patches = smooth(0.45, 0.65, fbm(f.a, f.b, 4400, 0.6))
    body, line = M.tide(f, level)
    f.B = np.maximum(f.B, (0.3 * body + 0.75 * line) * patches * strength)
    f.R = np.maximum(f.R, smooth(0.66, 0.8, f.n2) * smooth(0.3, 0.06, f.Y) * patches * strength)
    f.A = np.maximum(f.A, 0.45 * np.exp(-f.Y / 0.1) * smooth(0.55, 0.8, f.n2) * patches * strength)


def hall_wall(f):
    X, Y, n1, n2, n3 = f.X, f.Y, f.n1, f.n2, f.n3
    # Old yellowed paint, a faint shoulder-height rub where people pass close, dust under the ceiling.
    blotch = fbm(f.a, f.b, 4300, 0.5)
    f.G = 0.12 + 0.2 * smooth(0.35, 0.75, blotch) + 0.05 * (n2 - 0.5)
    rub = 0.6 + 0.6 * fbm(f.a, f.b, 4500, 0.15)  # stronger in some stretches than others
    f.G += 0.1 * rub * smooth(0.75, 1.0, Y) * smooth(1.6, 1.3, Y) * smooth(0.45, 0.75, n2)
    f.G += 0.12 * np.exp(-(L.CEILING - Y) / 0.08) * (0.5 + n2)
    # The foot of the wall: mop water, shoe dirt and dust, darkest in the first 10 cm.
    f.G += 0.55 * np.exp(-Y / 0.12) * (0.55 + 0.9 * n2) + 0.22 * np.exp(-Y / 0.45) * n1
    # Hand marks beside each door, kept faint: the shell's grime colour is a warm brown, and a saturated
    # patch reads as rust or dried blood under the torch, which option A rules out.
    for d in L.DOORS:
        hx0, hx1, _ = d.hole
        if not f.near(d.centre, 1.2):
            continue
        amount, dx, dy = F["latch"][d.room]
        for c, r, amp in (((hx0 - L.ARCH_W - 0.06 + dx, 1.05 + dy, L.WALL_FACE), (0.08, 0.22, 0.05), 0.2),
                          ((hx0 - L.ARCH_W - 0.03 + dx, 1.45 + dy, L.WALL_FACE), (0.05, 0.12, 0.05), 0.1),
                          ((hx1 + L.ARCH_W + 0.05 - dx, 1.2 - dy, L.WALL_FACE), (0.05, 0.18, 0.05), 0.08)):
            f.G += amount * amp * f.blob(c, r) * (0.55 + 0.9 * n3)
        # Chips knocked off next to the architraves at hand and bag height.
        if d.swing != "sealed":
            for x in (hx0 - L.ARCH_W, hx1 + L.ARCH_W):
                near = np.exp(-np.abs(X - x) / 0.025) * smooth(0.5, 0.8, Y) * smooth(1.5, 1.1, Y)
                f.R = np.maximum(f.R, smooth(0.6, 0.9, near * (0.5 + n3)))
    # People steady themselves on the washroom's jambs and on the corners where the corridor turns to the stairs.
    for c in ((L.WASHROOM[0] - 0.05, 1.15, L.WALL_FACE), (L.WASHROOM[1] + 0.05, 1.1, L.WALL_FACE),
              (L.X0 + 0.12, 1.15, L.WALL_FACE), (L.X1 - 0.12, 1.15, L.WALL_FACE)):
        if f.near(c[0], 0.5):
            f.G += 0.16 * f.blob(c, (0.07, 0.25, 0.05)) * (0.55 + 0.9 * n3)
    # Above the duty desk: hands and elbows where people lean to sign the book.
    if f.near(40.0, 1.0):
        f.G += 0.1 * f.box((39.3, 0.8, -1), (40.7, 1.15, 1), 0.12) * (0.4 + n2)
    for pts, through in F["wall_scuffs"]:
        if not f.near(pts[0][0], 0.2):
            continue
        line = f.segments(pts, 0.006, (0, 1))
        f.G += 0.22 * line
        if through:
            f.R = np.maximum(f.R, 0.7 * line)
    damp_foot(f, 0.07 + 0.09 * n1)
    # Splashes and damp round the washroom entrance: a higher tide, more mould at the foot.
    if f.near(3.0, 3.0):
        wet = np.exp(-np.abs(X - 3.0) / 1.6)
        damp_foot(f, 0.12 + 0.2 * n1 * wet, 0.8 * wet + 0.2)
        f.A = np.maximum(f.A, 0.5 * wet * np.exp(-Y / 0.18) * smooth(0.45, 0.75, n2))


def washroom_reveal(f):
    """The plastered jambs and head of the washroom entrance: handled at the edges, damp at the foot."""
    edge = np.exp(-np.abs(f.Z - L.WALL_FACE) / 0.05)
    f.G = 0.16 + 0.18 * smooth(0.35, 0.75, f.n1) + 0.55 * np.exp(-f.Y / 0.12) * (0.55 + 0.9 * f.n2)
    if f.s.surface != "WashroomHead":
        f.G += 0.2 * edge * smooth(0.8, 1.0, f.Y) * smooth(1.6, 1.3, f.Y) * (0.5 + f.n3)
        damp_foot(f, 0.2 + 0.15 * f.n1, 1.0)
        f.A = np.maximum(f.A, 0.55 * np.exp(-f.Y / 0.2) * smooth(0.4, 0.7, f.n2))
        f.R = np.maximum(f.R, smooth(0.6, 0.85, edge * f.n3) * smooth(0.5, 0.9, f.Y))
    else:
        f.G += 0.15 * edge * (0.5 + f.n2)


def infill(f):
    """The old 408 doorway, bricked up and plastered later: cleaner paint, a crack round its outline."""
    d = SEALED
    f.G = 0.05 + 0.07 * smooth(0.35, 0.75, f.n1) + 0.3 * np.exp(-(f.Y - L.SILL) / 0.1) * (0.5 + f.n2)
    inset = 0.012
    outline = [(d.x0 + inset, L.SILL + 0.02), (d.x0 + inset, d.top - inset), (d.x1 - inset, d.top - inset),
               (d.x1 - inset, L.SILL + 0.02)]
    wobble = 0.002 * (f.n3 - 0.5)
    crack = f.segments([(x, y) for x, y in outline], 0.0035 + 0.0015 * float(np.mean(f.n2)), (0, 1))
    crack = crack * smooth(0.42, 0.58, f.n2 + wobble)  # broken, not a drawn outline
    f.R = np.maximum(f.R, crack)
    f.G += 0.12 * crack
    for poly in F["infill_crack"]:
        line = f.segments(poly, 0.003, (0, 1))
        f.R = np.maximum(f.R, line)
        f.G += 0.1 * f.segments(poly, 0.012, (0, 1))
    body, line = M.tide(f, L.SILL + 0.05 + 0.04 * f.n1)
    f.B = np.maximum(f.B, 0.25 * body + 0.5 * line * smooth(0.4, 0.6, f.n2))


def end_wall(f):
    """The end walls on the caps: dust and damp at the foot, hand marks at the corner, weather at the open edge."""
    Z, Y, n1, n2, n3 = f.Z, f.Y, f.n1, f.n2, f.n3
    f.G = 0.13 + 0.2 * smooth(0.35, 0.75, fbm(f.a, f.b, 4600, 0.5)) + 0.05 * (n2 - 0.5)
    f.G += 0.55 * np.exp(-Y / 0.12) * (0.55 + 0.9 * n2) + 0.2 * np.exp(-Y / 0.45) * n1
    f.G += 0.12 * np.exp(-(L.CEILING - Y) / 0.08) * (0.5 + n2)
    f.G += 0.3 * np.exp(-(L.EDGE_Z - Z) / 0.35) * (0.4 + n2)  # rain and dust from the open side
    f.G += 0.14 * f.blob((f.X.mean(), 1.15, L.WALL_FACE + 0.15), (1.0, 0.25, 0.08)) * (0.55 + 0.9 * n3)
    for pts in F["end_scuffs"]:
        f.G += 0.2 * f.segments(pts, 0.006, (2, 1))
    damp_foot(f, 0.08 + 0.1 * n1)
    f.B = np.maximum(f.B, 0.35 * smooth(3.5, 3.95, Z) * smooth(0.45, 0.7, n2) * smooth(2.0, 0.5, Y))


WALL_PAINT = {"HallWall": hall_wall, "WashroomJambW": washroom_reveal, "WashroomJambE": washroom_reveal,
              "WashroomHead": washroom_reveal, "Infill408": infill, "EndWest": end_wall, "EndEast": end_wall}


def paint_walls(f):
    WALL_PAINT[f.s.surface](f)


# ---------------------------------------------------------------- floor and skirting

def paint_skirting(f):
    Y, n1, n2 = f.Y, f.n1, f.n2
    f.R = 0.6 + 0.2 * (n2 - 0.4)
    f.G = 0.25 + 0.2 * n1 + 0.35 * np.exp(-Y / 0.025) * (0.5 + n2)
    for d in ROOM_DOORS:
        if f.near(d.centre, 1.0):
            f.G += 0.2 * f.blob((d.centre, 0.05, L.WALL_FACE), (0.8, 0.2, 0.2)) * (0.4 + n2)
    if f.near(3.0, 2.0):  # mop water and splashes by the washroom
        f.B = np.maximum(f.B, 0.5 * f.blob((3.0, 0.0, L.WALL_FACE), (1.2, 0.2, 1.0)) * (0.4 + n2))


def floor_edges(f):
    """Distance to the wall face and to the slab edge under the railing."""
    return np.minimum(np.abs(f.Z - L.WALL_FACE), np.abs(L.EDGE_Z - f.Z))


def hall_floor(f):
    X, Z, n1, n2, n3 = f.X, f.Z, f.n1, f.n2, f.n3
    dw = floor_edges(f)
    f.R = 0.5 + 0.3 * np.exp(-dw / 0.4) + 0.2 * (n2 - 0.4)
    blotch = fbm(f.a, f.b, 5300, 0.6)
    f.G = 0.1 + 0.18 * smooth(0.35, 0.75, blotch) + 0.45 * np.exp(-dw / 0.06) * (0.5 + n2) + 0.18 * np.exp(-dw / 0.3) * n1
    # Dust and grit blown in from the open side gather along the slab edge, and in the corners at the ends.
    f.G += 0.25 * np.exp(-(L.EDGE_Z - Z) / 0.3) * (0.4 + n2)
    ends = np.minimum(X - L.X0, L.X1 - X)
    f.G += 0.3 * np.exp(-ends / 0.08) * (0.4 + n2)
    for d in ROOM_DOORS:  # where people stop in front of a door
        if f.near(d.centre, 1.0):
            f.G += 0.22 * f.box((d.x0 - 0.15, -1, L.WALL_FACE), (d.x1 + 0.15, 1, 0.8), 0.12) * (0.3 + n2)
    # The walking lane down the corridor, the turns into the doors and the washroom, the stairs at both ends.
    lane_shift = 0.25 * (fbm(f.a, f.b, 5400, 0.08) - 0.5)
    wear = 0.6 * np.exp(-((Z - 2.0 - lane_shift) / 0.6) ** 2)
    turns = [(d.centre, 0.55 * (1.2 if d.room == "407" else 0.85)) for d in ROOM_DOORS] + [(3.0, 0.75)]
    for cx, amp in turns:
        if f.near(cx, 1.0):
            lane = np.exp(-((X - cx) / 0.35) ** 2) * smooth(2.2, 1.6, Z)
            wear = np.maximum(wear, amp * lane)
    wear = np.maximum(wear, 0.5 * np.exp(-ends / 1.2) * np.exp(-((Z - 2.0) / 1.1) ** 2))
    if f.near(40.0, 1.5):  # the duty desk: people stand at it
        wear = np.maximum(wear, 0.45 * f.box((39.2, -1, 0.8), (40.8, 1, 1.6), 0.25))
        f.G += 0.2 * f.box((39.25, -1, L.WALL_FACE), (40.75, 1, 0.75), 0.05) * (0.5 + n2)  # dust under it
    f.A = wear * (0.6 + 0.6 * n1)
    f.G -= 0.05 * wear
    for pts in F["floor_scuffs"]:
        if f.near(pts[0][0], 0.1):
            f.G += 0.4 * f.segments(pts, 0.003)
    # Rain that blew in under the railing: damp patches drying from the edge; wet feet out of the washroom.
    f.B = 0.55 * smooth(3.3, 3.95, Z) * smooth(0.45, 0.7, n2 + 0.2 * n3)
    if f.near(3.0, 3.0):
        wet = np.exp(-(((X - 3.0) / 1.4) ** 2 + ((Z - L.WALL_FACE) / 1.1) ** 2))
        f.B = np.maximum(f.B, 0.7 * wet * smooth(0.3, 0.6, n2 + 0.15 * n3))


def paint_floor(f):
    if f.s.material == "skirting":
        paint_skirting(f)
    else:
        hall_floor(f)


# ---------------------------------------------------------------- ceiling

def paint_ceiling(f):
    X, Z, n1, n2 = f.X, f.Z, f.n1, f.n2
    edge = L.EDGE_Z - Z
    f.G = 0.1 + 0.22 * smooth(0.35, 0.75, n1) + 0.05 * (n2 - 0.5)
    f.G += 0.3 * np.exp(-np.abs(Z - L.WALL_FACE) / 0.06) * (0.5 + n2)
    f.G += 0.4 * np.exp(-edge / 0.3) * (0.4 + n2)  # weathered open edge
    for _, cx in L.LIGHTS:  # soot and dead insects over the tube battens
        if f.near(cx, 1.5):
            f.G += F["soot"][cx] * f.blob((cx, L.CEILING, L.LIGHT_Z), (0.8, 1.0, 0.3)) * (0.6 + 0.6 * n2)
    # Rain soaking in from the open edge: a damp band with a tide line, mould in the wettest spots.
    px = 1.0 / f.scale
    reach = 0.3 + 0.25 * n1 + 0.2 * fbm(f.a, f.b, 6100, 0.12)
    d = edge - reach
    body = 1 - smooth(-px, px, d)
    line = np.clip(1 - np.abs(d) / (1.4 * px), 0, 1)
    f.B = (0.3 * body + 0.8 * line) * smooth(0.3, 0.55, n2 + 0.1)
    f.A = 0.6 * np.exp(-edge / 0.15) * smooth(0.45, 0.7, n2)
    for (cx, cz), radius, seed in F["leaks"]:
        if f.near(cx, radius * 1.6):
            f.B = np.maximum(f.B, M.leak_rings(f, (cx, cz), radius, seed))
    for poly in F["ceiling_cracks"]:
        if not any(f.near(p[0], 0.05) for p in poly[::8] + [poly[-1]]):
            continue
        f.R = np.maximum(f.R, f.segments(poly, 0.0042))
        f.G += 0.12 * f.segments(poly, 0.02)


PAINT = {"walls": paint_walls, "floor": paint_floor, "ceiling": paint_ceiling}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    shells, scales = L.layout()
    wanted = set(sys.argv[1:]) or set(scales)
    for group, scale in scales.items():
        if group not in wanted:
            continue
        size = L.ATLAS[group]
        atlas = np.zeros((size[1], size[0], 4), np.uint8)
        atlas[:, :] = NEUTRAL_VALUE[group]
        for face in (f for f in shells if f.group == group and f.painted):
            f = FaceField(face, scale)
            PAINT[group](f)
            x0, y0, w, h = face.rect
            atlas[y0 - L.PAD:y0 + h + L.PAD, x0 - L.PAD:x0 + w + L.PAD] = f.rgba()
        n = L.NEUTRAL
        atlas[n[1]:n[1] + n[3], n[0]:n[0] + n[2]] = NEUTRAL_VALUE[group]
        Image.fromarray(atlas, "RGBA").save(OUT / f"mask_{group}.png", optimize=True)
        print("MASK", group, scale, "px/m", size, flush=True)
    print("RESULT: corridor masks PASS")


if __name__ == "__main__":
    main()
