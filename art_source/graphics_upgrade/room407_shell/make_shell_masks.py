"""Paint the T-222 shell mask atlases (one RGBA PNG per group of shell_layout.py).

Every pixel is computed from the room-local point it covers, so each stain sits at a real place of
room 407: hair grease above the pillows, hands round the light switch, soot behind the fridge, damp
rising out of the bathroom wall, leak rings on the ceiling, wet feet from the shower to Trung's bed.
Channels (read by game/rendering/room407_shell.gdshader):
  walls, ceiling, balcony walls  R paint loss   G grime   B water stain (rings drawn in)   A mould
  floors, skirting               R grout dirt   G grime   B wet         A wear (polished paths)
Run: python -B make_shell_masks.py [walls floor ceiling balcony]   (numpy, Pillow; about four minutes for all)
"""
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import shell_layout as L  # noqa: E402

OUT = HERE.parents[2] / "game/assets/textures/graphics_pilot/room407_shell"
NEUTRAL_VALUE = {"walls": (0, 30, 0, 0), "ceiling": (0, 30, 0, 0), "balcony": (0, 40, 0, 0), "floor": (90, 20, 0, 0)}


# ---------------------------------------------------------------- noise

def _hash(ix, iy, seed):
    h = (ix.astype(np.int64) * 374761393 + iy.astype(np.int64) * 668265263 + seed * 2147483647) & 0xFFFFFFFF
    h = h.astype(np.uint64)
    h = ((h ^ (h >> np.uint64(13))) * np.uint64(1274126177)) & np.uint64(0xFFFFFFFF)
    h = h ^ (h >> np.uint64(16))
    return (h & np.uint64(0xFFFFFF)).astype(np.float64) / float(0x1000000)


def vnoise(x, y, seed):
    ix, iy = np.floor(x), np.floor(y)
    fx, fy = x - ix, y - iy
    sx, sy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
    a, b = _hash(ix, iy, seed), _hash(ix + 1, iy, seed)
    c, d = _hash(ix, iy + 1, seed), _hash(ix + 1, iy + 1, seed)
    return (a + (b - a) * sx) + ((c + (d - c) * sx) - (a + (b - a) * sx)) * sy


def fbm(x, y, seed, freq, octaves=4, gain=0.5):
    total, amp, norm = 0.0, 1.0, 0.0
    for o in range(octaves):
        total = total + amp * vnoise(x * freq * 2 ** o, y * freq * 2 ** o, seed + o * 101)
        norm += amp
        amp *= gain
    return total / norm


def smooth(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0.0, 1.0)
    return t * t * (3 - 2 * t)


# ---------------------------------------------------------------- per-surface field

class Field:
    """Pixels of one surface rectangle (with bleed) and the room points they cover."""

    def __init__(self, s, scale, seed):
        x0, y0, w, h = s.rect
        cols = np.arange(-L.PAD, w + L.PAD) + 0.5
        rows = np.arange(-L.PAD, h + L.PAD) + 0.5
        self.a, self.b = np.meshgrid(cols / scale, rows / scale)
        o, u, v = s.origin, s.u, s.v
        self.X = o[0] + u[0] * self.a + v[0] * self.b
        self.Y = o[1] + u[1] * self.a + v[1] * self.b
        self.Z = o[2] + u[2] * self.a + v[2] * self.b
        self.s, self.scale = s, scale
        self.n1 = fbm(self.a, self.b, seed, 1.2)
        self.n2 = fbm(self.a, self.b, seed + 7, 5.0)
        self.n3 = fbm(self.a, self.b, seed + 13, 22.0, 3)
        shape = self.a.shape
        self.R, self.G, self.B, self.A = (np.zeros(shape) for _ in range(4))

    def blob(self, c, r):
        """Gaussian around room point c with radii r (x, y, z); use a large radius for the normal axis."""
        return np.exp(-(((self.X - c[0]) / r[0]) ** 2 + ((self.Y - c[1]) / r[1]) ** 2 + ((self.Z - c[2]) / r[2]) ** 2))

    def box(self, lo, hi, soft=0.01):
        """1 inside the room-space box lo..hi, soft edges."""
        m = np.ones(self.a.shape)
        for P, a, b in ((self.X, lo[0], hi[0]), (self.Y, lo[1], hi[1]), (self.Z, lo[2], hi[2])):
            m = m * smooth(a - soft, a + soft, P) * (1 - smooth(b - soft, b + soft, P))
        return m

    def segments(self, pts, width, axes=(0, 2)):
        """Distance-based line strength along a room-space polyline (2 axes of the surface plane)."""
        P = (self.X, self.Y, self.Z)
        pa, pb = P[axes[0]], P[axes[1]]
        out = np.zeros(self.a.shape)
        for (a0, b0), (a1, b1) in zip(pts, pts[1:]):
            lo_a, hi_a = min(a0, a1) - width * 4, max(a0, a1) + width * 4
            lo_b, hi_b = min(b0, b1) - width * 4, max(b0, b1) + width * 4
            sel = (pa >= lo_a) & (pa <= hi_a) & (pb >= lo_b) & (pb <= hi_b)
            if not sel.any():
                continue
            da, db = a1 - a0, b1 - b0
            ll = da * da + db * db or 1e-9
            t = np.clip(((pa[sel] - a0) * da + (pb[sel] - b0) * db) / ll, 0, 1)
            d = np.hypot(pa[sel] - (a0 + t * da), pb[sel] - (b0 + t * db))
            out[sel] = np.maximum(out[sel], np.clip(1 - d / width, 0, 1))
        return out

    def rgba(self):
        stack = np.stack([self.R, self.G, self.B, self.A], axis=-1)
        return (np.clip(stack, 0, 1) * 255 + 0.5).astype(np.uint8)


def walk(rng, start, heading, steps, step, wobble, branch=0.0, depth=0):
    """Random-walk polylines (cracks, scratches) in a 2D plane."""
    lines, pts = [], [start]
    p, h = np.array(start, float), heading
    for _ in range(steps):
        h += rng.normal(0, wobble)
        p = p + step * np.array([math.cos(h), math.sin(h)])
        pts.append(tuple(p))
        if depth < 2 and rng.random() < branch:
            lines += walk(rng, tuple(p), h + rng.choice([-1, 1]) * rng.uniform(0.5, 1.1),
                          int(steps * rng.uniform(0.2, 0.5)), step * 0.8, wobble, branch * 0.5, depth + 1)
    return [pts] + lines


# ---------------------------------------------------------------- room facts

CONCAVE = [(0.1, 0.0), (0.1, -6.925), (5.225, -6.925), (7.9, -3.925), (7.9, 0.0),
           (5.375, -4.075), (5.375, -6.925), (7.9, -6.925), (7.9, -4.075),
           (0.06, -7.075), (5.14, -7.075), (0.06, -8.45), (5.14, -8.45)]
CONVEX = (5.225, -3.925)
# Walls of the floor pieces (door gaps left out: no dust heaps in a doorway).
ROOM_EDGES = [[(1.5, 0.0), (0.1, 0.0), (0.1, -6.925), (2.3, -6.925)], [(3.3, -6.925), (5.225, -6.925), (5.225, -3.925), (5.35, -3.925)],
              [(6.35, -3.925), (7.9, -3.925), (7.9, 0.0), (2.45, 0.0)]]
BATH_EDGES = [[(5.375, -4.075), (5.375, -6.925), (7.9, -6.925), (7.9, -4.075), (6.35, -4.075)]]
BALCONY_EDGES = [[(0.06, -7.075), (0.06, -8.45), (5.14, -8.45), (5.14, -7.075), (3.3, -7.075)], [(2.3, -7.075), (0.06, -7.075)]]
# Where people walk (the room was laid out with 1 m walkways, D-100).
PATHS = [[(1.97, -0.25), (2.35, -1.1), (2.6, -3.6), (3.05, -4.1), (3.1, -6.6)],  # door to balcony
         [(1.97, -0.25), (3.6, -1.2), (5.0, -2.9), (5.85, -3.75)],  # door to the bathroom
         [(1.97, -0.25), (1.45, -1.6), (1.35, -3.4)],  # door to bunk A's ladder
         [(3.6, -1.2), (5.6, -1.5), (6.6, -2.3)],  # to bunk B
         [(2.6, -3.6), (3.6, -3.7), (5.0, -2.9)]]
LEAKS = [((2.95, -6.55), 0.5), ((5.55, -2.15), 0.65), ((6.7, -5.35), 0.55), ((0.55, -6.45), 0.32)]
SHOWER, DRAIN = (6.18, -6.69), (6.45, -6.25)
# Patches of newer paint (a lighter, cleaner rectangle with brushed edges), room points and size (w, h).
REPAINTS = [("x", (0.1, 1.25, -1.0), (0.95, 0.75)), ("z", (6.45, 1.05, 0.0), (1.15, 0.85)),
            ("z", (4.55, 1.7, -6.925), (0.6, 0.5)), ("x", (7.9, 0.85, -3.55), (0.65, 0.6))]
# Pen scribbles near the bunk heads and desks (tallies, a phone number, doodles).
SCRIBBLES = [("x", (0.1, 0.78, -2.12)), ("x", (0.1, 1.55, -2.2)), ("x", (7.9, 0.8, -1.95)), ("x", (0.1, 1.05, -5.6))]
POSTER_GHOSTS = [("x", (7.9, 1.78, -3.15), (0.50, 0.70)), ("z", (5.05, 1.62, 0.0), (0.30, 0.42)),
                 ("x", (0.1, 2.05, -4.75), (0.58, 0.42)), ("z", (0.75, 2.2, -6.925), (0.42, 0.30))]


def edge_distance(f, edges):
    d = np.full(f.a.shape, 9.0)
    for line in edges:
        for (x0, z0), (x1, z1) in zip(line, line[1:]):
            dx, dz = x1 - x0, z1 - z0
            t = np.clip(((f.X - x0) * dx + (f.Z - z0) * dz) / (dx * dx + dz * dz), 0, 1)
            d = np.minimum(d, np.hypot(f.X - (x0 + t * dx), f.Z - (z0 + t * dz)))
    return d


def corner_distance(f, corners):
    d = np.full(f.a.shape, 9.0)
    for cx, cz in corners:
        d = np.minimum(d, np.hypot(f.X - cx, f.Z - cz))
    return d


def tide(f, level, width_px=1.4):
    """Water-stain body below `level` (a height field) with a darker tide line on its edge."""
    px = 1.0 / f.scale
    body = 1 - smooth(-px, px, f.Y - level)
    line = np.clip(1 - np.abs(f.Y - level) / (width_px * px), 0, 1)
    return body, line


def leak_rings(f, centre, radius, seed, plane=(0, 2)):
    """Ceiling/wall leak: an irregular stain with two older tide rings."""
    P = (f.X, f.Y, f.Z)
    pa, pb = P[plane[0]] - centre[0], P[plane[1]] - centre[1]
    ang = np.arctan2(pb, pa)
    warp = 1 + 0.28 * (fbm(np.cos(ang) * 1.3 + seed, np.sin(ang) * 1.3, seed, 1.0, 3) - 0.5) * 2
    warp = warp + 0.10 * (f.n2 - 0.5)
    rr = np.hypot(pa, pb) / (radius * warp)
    px = 1.0 / (f.scale * radius)
    body = (1 - smooth(1 - px, 1 + px, rr)) * (0.35 + 0.25 * smooth(0.9, 0.2, rr))
    rings = np.zeros(f.a.shape)
    for k, (level, strength) in enumerate(((1.0, 1.0), (0.78, 0.75), (0.52, 0.55))):
        rings = np.maximum(rings, strength * np.clip(1 - np.abs(rr - level) / (1.6 * px), 0, 1))
    return np.maximum(body, rings)


def _on_wall(f, axis, c):
    along = f.Z if axis == "x" else f.X
    ca = c[2] if axis == "x" else c[0]
    on_plane = np.abs((f.X if axis == "x" else f.Z) - (c[0] if axis == "x" else c[2])) < 0.02
    return along, ca, on_plane


def repaints(f, normal_axis):
    for axis, c, (w, h) in REPAINTS:
        if axis != normal_axis:
            continue
        along, ca, on_plane = _on_wall(f, axis, c)
        # Brushed, uneven edges: the roller stopped short in places.
        edge = 0.04 * (f.n2 - 0.5) + 0.015 * (f.n3 - 0.5)
        inside = (smooth(-w / 2 - 0.02, -w / 2 + 0.02, along - ca + edge) * (1 - smooth(w / 2 - 0.02, w / 2 + 0.02, along - ca + edge))
                  * smooth(-h / 2 - 0.02, -h / 2 + 0.02, f.Y - c[1] + edge) * (1 - smooth(h / 2 - 0.02, h / 2 + 0.02, f.Y - c[1] + edge)))
        inside = np.where(on_plane, inside, 0.0)
        f.G = f.G * (1 - inside) + inside * (0.03 + 0.03 * f.n3)
        f.R = f.R * (1 - inside)


def scribbles(f, normal_axis, rng):
    for axis, c in SCRIBBLES:
        if axis != normal_axis:
            continue
        along, ca, on_plane = _on_wall(f, axis, c)
        if not on_plane.any():
            continue
        plane = (2, 1) if axis == "x" else (0, 1)
        for _ in range(9):
            start = (ca + rng.uniform(-0.12, 0.12), c[1] + rng.uniform(-0.08, 0.08))
            if rng.random() < 0.4:  # a tally: four strokes and a slash
                pts = [[(start[0] + k * 0.008, start[1]), (start[0] + k * 0.008 + 0.002, start[1] + 0.03)] for k in range(4)]
                pts.append([(start[0] - 0.004, start[1] + 0.006), (start[0] + 0.03, start[1] + 0.024)])
            else:  # a loose doodle or a written line
                walk_pts = [start]
                for _ in range(rng.integers(5, 12)):
                    walk_pts.append((walk_pts[-1][0] + rng.uniform(0.004, 0.012), walk_pts[-1][1] + rng.uniform(-0.008, 0.008)))
                pts = [walk_pts]
            for line in pts:
                stroke = f.segments(line, 0.004, plane)  # marker pen; the wall atlas is 6 mm a texel
                f.G = np.where(on_plane, np.maximum(f.G, 0.85 * stroke), f.G)


def ghosts(f, normal_axis):
    """Removed posters: a cleaner patch, yellow tape residue at the corners, nail holes."""
    for axis, c, (w, h) in POSTER_GHOSTS:
        if axis != normal_axis:
            continue
        along = (f.Z if axis == "x" else f.X)
        ca = c[2] if axis == "x" else c[0]
        on_plane = np.abs((f.X if axis == "x" else f.Z) - (c[0] if axis == "x" else c[2])) < 0.02
        inside = (smooth(-w / 2 - 0.01, -w / 2 + 0.01, along - ca) * (1 - smooth(w / 2 - 0.01, w / 2 + 0.01, along - ca))
                  * smooth(-h / 2 - 0.01, -h / 2 + 0.01, f.Y - c[1]) * (1 - smooth(h / 2 - 0.01, h / 2 + 0.01, f.Y - c[1])))
        f.G = np.where(on_plane, f.G - 0.11 * inside, f.G)
        for sa in (-1, 1):
            for sb in (-1, 1):
                tape = (np.abs(along - (ca + sa * (w / 2 - 0.012))) < 0.022) & (np.abs(f.Y - (c[1] + sb * (h / 2 - 0.008))) < 0.012)
                f.B = np.where(on_plane & tape, np.maximum(f.B, 0.42 + 0.2 * f.n3), f.B)
        for nail in ((ca, c[1] + h / 2 + 0.02), (ca - w / 2 + 0.03, c[1] + h / 2 - 0.03)):
            hole = np.hypot(along - nail[0], f.Y - nail[1]) < 0.004
            f.R = np.where(on_plane & hole, 1.0, f.R)
            f.G = np.where(on_plane & hole, 0.9, f.G)


# ---------------------------------------------------------------- groups

def paint_wall(f, rng):
    s, X, Y, Z = f.s, f.X, f.Y, f.Z
    n1, n2, n3 = f.n1, f.n2, f.n3
    nx, _, nz = s.normal
    bath = s.name.startswith("Bath") and s.name not in ("BathroomSide", "BathFront")
    dc = corner_distance(f, CONCAVE)
    # Grime: blotchy yellowed paint, a dirty lower wall where people and furniture rub, dirt rising
    # from the floor, dust under the ceiling and in corners.
    blotch = fbm(f.a, f.b, 4100 + int(abs(nx) * 7 + nz * 3), 0.55)
    f.G = 0.14 + 0.24 * smooth(0.35, 0.75, blotch) + 0.06 * (n2 - 0.5)
    f.G += 0.16 * smooth(1.3, 0.3, Y) * (0.45 + 0.9 * n2)
    f.G += 0.6 * np.exp(-Y / 0.11) * (0.55 + 0.9 * n2) + 0.2 * np.exp(-Y / 0.4) * n1
    f.G += 0.16 * np.exp(-(L.CEILING - Y) / 0.07) * (0.5 + n2)
    f.G += 0.28 * np.exp(-dc / 0.13) * (0.4 + n2) * smooth(2.9, 0.0, Y * 0.3)
    for c, r, amp in (
            ((0.1, 0.58, -2.28), (0.06, 0.09, 0.2), 0.55), ((0.1, 1.36, -2.28), (0.06, 0.09, 0.2), 0.45),  # hair, bunk A
            ((7.9, 0.58, -2.02), (0.06, 0.09, 0.2), 0.55), ((7.9, 1.36, -2.02), (0.06, 0.09, 0.2), 0.45),  # bunk B
            ((2.72, 1.35, 0.0), (0.12, 0.14, 0.06), 0.6),  # light switch
            ((1.37, 1.05, 0.0), (0.05, 0.26, 0.06), 0.45),  # room door, latch side
            ((6.47, 1.0, -3.925), (0.07, 0.25, 0.05), 0.5), ((6.43, 1.0, -4.075), (0.07, 0.25, 0.05), 0.45),  # bathroom door
            ((2.2, 1.0, -6.925), (0.07, 0.25, 0.05), 0.3),  # balcony latch, behind the curtain
            ((5.225, 1.2, -3.3), (0.06, 0.38, 0.27), 0.5), ((5.225, 0.45, -3.3), (0.06, 0.3, 0.3), 0.3),  # fridge heat
            ((5.9, 0.25, 0.0), (0.4, 0.18, 0.06), 0.4),  # behind the shoe rack
            ((1.1, 0.68, 0.0), (0.16, 0.28, 0.06), 0.22),  # jacket rubbing under its hook
            ((3.95, 0.3, 0.0), (0.06, 0.06, 0.05), 0.35), ((0.1, 0.3, -5.3), (0.05, 0.06, 0.06), 0.35),  # sockets
            ((1.0, 0.13, 0.0), (0.5, 0.06, 0.06), 0.25), ((3.15, 0.13, 0.0), (0.4, 0.06, 0.06), 0.25)):  # slippers
        f.G += amp * f.blob(c, r) * (0.55 + 0.9 * n3)
    f.G += 0.28 * f.box((0.09, 0.71, -6.55), (0.12, 0.77, -5.05), 0.012) * (0.4 + n2)  # Phuc's desk edge
    ghosts(f, "x" if abs(nx) > 0.5 else "z")
    repaints(f, "x" if abs(nx) > 0.5 else "z")
    scribbles(f, "x" if abs(nx) > 0.5 else "z", rng)
    # Scuffs: short dark strokes at chair, bag and shoulder height; some go through the paint.
    plane = (2, 1) if abs(nx) > 0.5 else (0, 1)
    for _ in range(int(s.w * 3)):
        start_a = rng.uniform(0, s.w)
        p = s.point(start_a, rng.uniform(0.35, 1.3))
        pts = [(p[plane[0]], p[1])]
        ang = rng.normal(0, 0.35) + (0 if rng.random() < 0.6 else math.pi / 2 * rng.choice([-1, 1]) * 0.3)
        for k in range(4):
            pts.append((pts[-1][0] + 0.03 * math.cos(ang), pts[-1][1] + 0.03 * math.sin(ang)))
        line = f.segments(pts, 0.0035, plane)
        f.G += 0.35 * line
        if rng.random() < 0.25:
            f.R = np.maximum(f.R, 0.9 * line)
    # Water: damp rising out of the bathroom into the room side of its walls; leak streaks; splashes.
    if s.name in ("BathroomSide", "BathFront", "SkirtingBathSide"):
        near_bath = smooth(-3.6, -4.3, Z) if s.name == "BathroomSide" else smooth(7.3, 6.1, X)
        level = (0.22 + 0.2 * n1 + 0.04 * n2) * near_bath
        body, line = tide(f, level)
        old_body, old_line = tide(f, level * 1.35 + 0.03)
        f.B = np.maximum(f.B, np.maximum(0.38 * body + 0.9 * line, 0.55 * old_line * near_bath))
        f.R = np.maximum(f.R, smooth(0.62, 0.78, n2) * smooth(level - 0.05, level + 0.02, Y) * smooth(level + 0.28, level + 0.1, Y) * near_bath)
        f.A = np.maximum(f.A, 0.55 * body * smooth(0.45, 0.7, n2))
    for x_or_z, top, width, plane_x in ((3.55, 0.9, 0.11, False), (2.05, 0.6, 0.08, False), (-6.7, 0.7, 0.1, True),
                                         (6.85, 1.1, 0.13, False), (7.5, 0.8, 0.1, False)):
        along = Z if plane_x else X
        streak = np.exp(-((along - x_or_z) / (width * (0.7 + 0.6 * n1))) ** 2) * smooth(L.CEILING - top - 0.3, L.CEILING, Y)
        on = (np.abs(X - L.X0) < 0.02) if plane_x else (np.abs(Z - L.Z_BACK) < 0.02)
        f.B = np.where(on, np.maximum(f.B, 0.45 * streak * (0.6 + 0.6 * n2)), f.B)
        f.G = np.where(on, f.G + 0.12 * streak, f.G)
    if s.name.startswith("BalconyReveal") or s.name in ("BackWall",):
        f.B = np.maximum(f.B, 0.45 * f.blob((2.8, 0.05, -7.0), (0.75, 0.22, 0.2)) * (0.5 + n2))
    # Paint loss: round the balcony opening (rain), on the bathroom's knocked corner, in the bathroom.
    near_opening = f.blob((2.3, 2.3, -6.95), (0.35, 0.35, 0.3)) + f.blob((3.3, 2.3, -6.95), (0.35, 0.4, 0.3)) \
        + 0.8 * f.blob((2.8, 0.1, -6.95), (0.7, 0.25, 0.3))
    f.R = np.maximum(f.R, smooth(0.95, 1.25, near_opening * 0.8 + n2 * 0.75))
    corner_edge = np.hypot(X - CONVEX[0], Z - CONVEX[1]) < 0.035
    f.R = np.where(corner_edge & (n3 > 0.62) & (Y > 0.15) & (Y < 1.6), 1.0, f.R)
    f.G += 0.3 * np.exp(-np.hypot(X - CONVEX[0], Z - CONVEX[1]) / 0.05) * smooth(0.2, 0.6, Y) * smooth(1.7, 1.2, Y)
    # Mould: bathroom ceiling line, corners and round the shower; room corners near the balcony.
    if bath or s.name == "BathroomSide":
        f.A = np.maximum(f.A, (0.85 * np.exp(-(L.CEILING - Y) / 0.3) + 0.6 * np.exp(-dc / 0.25) * smooth(1.6, 2.4, Y)) * smooth(0.35, 0.75, n2))
        f.A = np.maximum(f.A, 0.9 * f.blob((SHOWER[0], 2.3, -6.925), (0.6, 0.55, 0.3)) * smooth(0.3, 0.6, n2))
        f.R = np.maximum(f.R, smooth(0.66, 0.8, n2) * smooth(2.0, 2.6, Y))
        f.G += 0.1
    f.A = np.maximum(f.A, 0.7 * (f.blob((0.1, 3.0, -6.925), (0.5, 0.6, 0.5)) + f.blob((2.8, 3.0, -6.925), (0.6, 0.5, 0.4))
                                 + 0.6 * f.blob((5.225, 3.0, -6.925), (0.4, 0.5, 0.4))) * smooth(0.35, 0.7, n2))
    f.A = np.maximum(f.A, 0.35 * f.box((0.09, 0.0, -3.9), (0.12, 0.45, -2.1), 0.05) * smooth(0.5, 0.75, n2))


def paint_floor(f, rng):
    s, X, Z = f.s, f.X, f.Z
    n1, n2, n3 = f.n1, f.n2, f.n3
    bath = s.material == "bathfloor"
    skirting = s.material == "skirting"
    dw = edge_distance(f, BATH_EDGES if bath else ROOM_EDGES)
    if skirting:
        dw = np.minimum(dw, f.Y + 0.02)
    dc = corner_distance(f, CONCAVE)
    f.R = 0.5 + 0.35 * np.exp(-dw / 0.4) + 0.22 * (n2 - 0.4) + (0.25 if bath else 0)
    blotch = fbm(f.a, f.b, 5100, 0.7)
    f.G = 0.1 + 0.2 * smooth(0.35, 0.75, blotch) + 0.5 * np.exp(-dw / 0.06) * (0.5 + n2) + 0.2 * np.exp(-dw / 0.3) * n1 \
        + 0.3 * np.exp(-dc / 0.15) * (0.4 + n2)
    for lo, hi, amp in (((0.22, -1, -3.98), (1.08, 1, -2.02), 0.32), ((6.92, -1, -3.68), (7.78, 1, -1.72), 0.32),  # under bunks
                        ((0.175, -1, -6.55), (0.825, 1, -5.05), 0.18), ((3.85, -1, -6.25), (4.55, 1, -5.55), 0.15),  # desks
                        ((1.5, -1, -0.75), (2.45, 1, 0.0), 0.35), ((2.3, -1, -6.925), (3.3, 1, -6.35), 0.3)):  # doorways
        f.G += amp * f.box(lo, hi, 0.08) * (0.3 + n2)
    for (cx, cz), r in (((0.5, -4.6), 0.17), ((0.5, -4.6), 0.15), ((2.9, -5.4), 0.16), ((5.65, -6.45), 0.17)):
        ring = np.clip(1 - np.abs(np.hypot(X - cx, Z - cz) - r * (1 + 0.04 * (n2 - 0.5))) / 0.006, 0, 1)
        f.G += 0.4 * ring
    for _ in range(0 if bath or skirting else 70):  # black shoe scuffs
        cx, cz = rng.uniform(0.4, 7.6), rng.uniform(-6.7, -0.2)
        if 5.2 < cx and cz < -3.9:
            continue
        ang = rng.uniform(0, math.tau)
        arc = [(cx + 0.012 * k * math.cos(ang + 0.15 * k), cz + 0.012 * k * math.sin(ang + 0.15 * k)) for k in range(6)]
        f.G += 0.45 * f.segments(arc, 0.003)
    if not bath and not skirting:
        wear = np.zeros(f.a.shape)
        for path in PATHS:
            for (x0, z0), (x1, z1) in zip(path, path[1:]):
                dx, dz = x1 - x0, z1 - z0
                t = np.clip(((X - x0) * dx + (Z - z0) * dz) / (dx * dx + dz * dz), 0, 1)
                d = np.hypot(X - (x0 + t * dx), Z - (z0 + t * dz))
                wear = np.maximum(wear, np.exp(-(d / 0.32) ** 2))
        f.A = 0.65 * wear * (0.6 + 0.6 * n1)
        f.G -= 0.05 * wear
        # Wet feet from the shower to Trung's bed, drying out; a puddle under the water dispenser.
        feet = footprints([(5.85, -3.95), (6.25, -3.45), (6.6, -2.95), (6.75, -2.55)], 0.27)
        for k, (pos, heading, side) in enumerate(feet):
            f.B = np.maximum(f.B, (0.85 - 0.14 * k) * foot(f, pos, heading, side))
        f.B = np.maximum(f.B, 0.8 * smooth(1.0, 0.85, np.hypot(X - 5.08, Z + 3.82) / (0.13 * (0.8 + 0.5 * n2))))
        drips = (n3 > 0.82) & (f.segments([(5.85, -3.95), (6.6, -2.95), (6.75, -2.55)], 0.06) > 0)
        f.B = np.where(drips, np.maximum(f.B, 0.6), f.B)
    if bath:
        shower = np.hypot(X - SHOWER[0], Z - SHOWER[1])
        f.B = np.clip(0.25 + 0.75 * smooth(1.6, 0.3, shower) * (0.5 + n1) + 0.9 * smooth(0.35, 0.1, np.hypot(X - DRAIN[0], Z - DRAIN[1])), 0, 1)
        f.B = f.B * smooth(0.25, 0.45, n2 + 0.3 * smooth(1.2, 0.2, shower))
        f.G += 0.1 + 0.2 * smooth(0.55, 0.75, n2)


def foot(f, pos, heading, side):
    ca, sa = math.cos(heading), math.sin(heading)
    ds, dt = (f.X - pos[0]) * ca + (f.Z - pos[1]) * sa, -(f.X - pos[0]) * sa + (f.Z - pos[1]) * ca
    dt = dt * side
    heel = ((ds + 0.085) / 0.038) ** 2 + (dt / 0.032) ** 2
    ball = ((ds - 0.045) / 0.05) ** 2 + ((dt + 0.006) / 0.043) ** 2
    arch = ((ds + 0.02) / 0.06) ** 2 + ((dt - 0.022) / 0.014) ** 2
    shape = np.maximum.reduce([smooth(1.15, 0.85, heel), smooth(1.15, 0.85, ball), 0.8 * smooth(1.2, 0.8, arch)])
    for k, (s_off, t_off, r) in enumerate(((0.112, -0.022, 0.016), (0.118, 0.0, 0.012), (0.114, 0.017, 0.011),
                                           (0.107, 0.031, 0.01), (0.096, 0.042, 0.009))):
        toe = np.hypot(ds - s_off, dt - t_off) / r
        shape = np.maximum(shape, smooth(1.1, 0.8, toe))
    return shape * (0.65 + 0.5 * f.n3)


def footprints(path, stride):
    """Alternating left/right feet along a polyline."""
    out, side, carry = [], 1, 0.0
    for (x0, z0), (x1, z1) in zip(path, path[1:]):
        length, heading = math.hypot(x1 - x0, z1 - z0), math.atan2(z1 - z0, x1 - x0)
        d = carry
        while d < length:
            t = d / length
            px, pz = x0 + (x1 - x0) * t, z0 + (z1 - z0) * t
            off = 0.065 * side
            out.append(((px - off * math.sin(heading), pz + off * math.cos(heading)), heading, side))
            side, d = -side, d + stride
        carry = d - length
    return out


def paint_ceiling(f, rng):
    X, Z, n1, n2, n3 = f.X, f.Z, f.n1, f.n2, f.n3
    dw = edge_distance(f, [[(0.1, 0.0), (0.1, -6.925), (7.9, -6.925), (7.9, 0.0), (0.1, 0.0)],
                           [(5.225, -6.925), (5.225, -3.925), (7.9, -3.925)], [(5.375, -6.925), (5.375, -4.075), (7.9, -4.075)]])
    f.G = 0.1 + 0.26 * smooth(0.35, 0.75, n1) + 0.05 * (n2 - 0.5) + 0.32 * np.exp(-dw / 0.06) * (0.5 + n2)
    f.G += 0.5 * f.blob((2.0, 3.0, -1.2), (0.75, 1.0, 0.28)) * (0.6 + 0.6 * n2)  # soot over the tube lamp
    fan = np.hypot(X - 2.0, Z + 2.5)
    f.G += 0.3 * np.exp(-((fan - 0.16) / 0.07) ** 2) * (0.5 + n2)
    for (cx, cz), r in LEAKS:
        f.B = np.maximum(f.B, leak_rings(f, (cx, cz), r, int(cx * 10)))
    lines = []
    for start, heading, steps in (((0.1, -3.5), 0.0, 120), ((7.9, -1.0), math.pi + 0.3, 40), ((2.8, -6.92), 1.6, 50),
                                  ((4.6, -0.02), -1.4, 45), ((0.1, -1.2), 0.4, 30)):
        lines += walk(rng, start, heading, steps, 0.04, 0.12, 0.12)
    for line in lines:
        crack = f.segments(line, 0.0042)
        f.R = np.maximum(f.R, crack)
        f.G += 0.15 * f.segments(line, 0.02)
    bath = (X > 5.3) & (Z < -4.0)
    f.A = np.where(bath, np.maximum(f.A, (0.8 * np.exp(-dw / 0.35) + 0.9 * smooth(1.3, 0.3, np.hypot(X - SHOWER[0], Z - SHOWER[1])))
                                    * smooth(0.35, 0.7, n2)), f.A)
    f.A = np.maximum(f.A, 0.6 * f.blob((2.8, 3.0, -6.925), (0.6, 1, 0.45)) * smooth(0.35, 0.7, n2))
    f.R = np.where(bath, np.maximum(f.R, smooth(0.7, 0.85, n2)), f.R)


def paint_balcony(f, rng):
    s, X, Y, Z, n1, n2, n3 = f.s, f.X, f.Y, f.Z, f.n1, f.n2, f.n3
    if s.material == "balconyfloor":
        dw = edge_distance(f, BALCONY_EDGES)
        dc = corner_distance(f, CONCAVE)
        f.R = 0.55 + 0.3 * np.exp(-dw / 0.3)
        f.G = 0.15 + 0.15 * n1 + 0.5 * np.exp(-dw / 0.06) * (0.5 + n2) + 0.4 * np.exp(-dc / 0.2) * (0.4 + n2)
        f.B = 0.9 * smooth(0.3, 0.12, np.hypot(X - 0.25, Z + 8.33) / (0.8 + 0.4 * n2))
        f.G += 0.4 * np.clip(1 - np.abs(np.hypot(X - 0.25, Z + 8.33) - 0.38) / 0.01, 0, 1)
        path = [(2.8, -7.1), (2.8, -7.9), (1.6, -7.8)]
        wear = np.zeros(f.a.shape)
        for (x0, z0), (x1, z1) in zip(path, path[1:]):
            dx, dz = x1 - x0, z1 - z0
            t = np.clip(((X - x0) * dx + (Z - z0) * dz) / (dx * dx + dz * dz), 0, 1)
            wear = np.maximum(wear, np.exp(-(np.hypot(X - (x0 + t * dx), Z - (z0 + t * dz)) / 0.3) ** 2))
        f.A = 0.5 * wear
        return
    top = L.CEILING if s.name.startswith("Ext") else (2.0 if "Divider" in s.name else 1.05)
    if s.name == "BalconySoffit":
        edge = smooth(-8.3, -8.6, Z)
        f.G = 0.15 + 0.2 * n1 + 0.45 * edge * (0.4 + n2)
        f.B = 0.7 * edge * smooth(0.45, 0.65, n2)
        f.A = 0.6 * edge * smooth(0.5, 0.75, n2)
        return
    along = f.a
    streaks = fbm(along * 9.0, Y * 0.25, 77, 1.0, 3)
    f.G = 0.12 + 0.12 * n1 + 0.45 * smooth(0.45, 0.8, streaks) * smooth(top - 1.6, top, Y) + 0.5 * np.exp(-Y / 0.25) * (0.5 + n2)
    level = 0.18 + 0.12 * n1
    body, line = tide(f, level)
    f.B = 0.35 * body + 0.8 * line
    f.A = 0.8 * np.exp(-Y / 0.35) * smooth(0.4, 0.7, n2) + 0.5 * np.exp(-(top - Y) / 0.2) * smooth(0.5, 0.75, n2)
    f.R = smooth(0.7, 0.85, n2) * smooth(0.6, 0.0, Y) + smooth(0.78, 0.9, n2 * 0.6 + n3 * 0.5)
    if s.name.startswith("Ext"):
        for x in (2.3, 3.3):
            streak = np.exp(-((X - x) / 0.07) ** 2) * smooth(2.4, 1.0, Y) * (Y < 2.35)
            f.G += 0.35 * streak * (0.5 + n2)
            f.B = np.maximum(f.B, 0.5 * streak)


PAINT = {"walls": paint_wall, "floor": paint_floor, "ceiling": paint_ceiling, "balcony": paint_balcony}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    shells, scales = L.layout()
    wanted = set(sys.argv[1:]) or set(scales)
    for group, scale in scales.items():
        if group not in wanted:
            continue
        rng = np.random.default_rng(407)
        atlas = np.zeros((L.ATLAS, L.ATLAS, 4), np.uint8)
        atlas[:, :] = NEUTRAL_VALUE[group]
        for k, s in enumerate([s for s in shells if s.group == group]):
            f = Field(s, scale, 1000 + k * 37)
            PAINT[group](f, rng)
            x0, y0, w, h = s.rect
            atlas[y0 - L.PAD:y0 + h + L.PAD, x0 - L.PAD:x0 + w + L.PAD] = f.rgba()
        n = L.NEUTRAL
        atlas[n[1]:n[1] + n[3], n[0]:n[0] + n[2]] = NEUTRAL_VALUE[group]
        Image.fromarray(atlas, "RGBA").save(OUT / f"mask_{group}.png", optimize=True)
        print("MASK", group, scale, "px/m", flush=True)
    print("RESULT: shell masks PASS")


if __name__ == "__main__":
    main()
