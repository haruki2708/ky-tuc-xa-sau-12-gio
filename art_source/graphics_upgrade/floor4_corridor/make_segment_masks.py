"""T-233: paint the corridor segment's own mask atlases (walls, floor, ceiling), like room 407's
(../room407_shell/make_shell_masks.py, whose noise and Field helpers this reuses). Channels, read by
game/rendering/room407_shell.gdshader:
  walls, ceiling   R paint loss   G grime   B water stain   A mould
  floor, skirting  R grout dirt   G grime   B wet           A wear (polished lane)
Option A (D-142): grime at the foot of the wall and round the places hands touch (the latch side of each
door); nothing that tells a story (no blood, writing, signs or posters).
Run: python -B make_segment_masks.py [walls floor ceiling]   (numpy, Pillow; under a minute)
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
import segment_layout as L  # noqa: E402

OUT = HERE.parents[2] / "game/assets/textures/graphics_pilot/floor4_corridor"
NEUTRAL_VALUE = {"walls": (0, 30, 0, 0), "ceiling": (0, 30, 0, 0), "floor": (90, 20, 0, 0)}
smooth, fbm = M.smooth, M.fbm


def latch_points():
    """Where hands land beside each door: the wall on the latch (west) side, the architrave edges."""
    for d in L.DOORS:
        hx0, hx1, htop = d.hole
        yield (hx0 - L.ARCH_W - 0.06, 1.05, L.WALL_FACE), (0.08, 0.22, 0.05), 0.2
        yield (hx0 - L.ARCH_W - 0.03, 1.45, L.WALL_FACE), (0.05, 0.12, 0.05), 0.1
        yield (hx1 + L.ARCH_W + 0.05, 1.2, L.WALL_FACE), (0.05, 0.18, 0.05), 0.08


def paint_wall(f, rng):
    s, X, Y = f.s, f.X, f.Y
    n1, n2, n3 = f.n1, f.n2, f.n3
    if s.material == "skirting":
        paint_skirting(f)
        return
    # Old yellowed paint, a faint shoulder-height rub where people pass close, dust under the ceiling.
    blotch = fbm(f.a, f.b, 4300, 0.5)
    f.G = 0.12 + 0.2 * smooth(0.35, 0.75, blotch) + 0.05 * (n2 - 0.5)
    f.G += 0.1 * smooth(0.75, 1.0, Y) * smooth(1.6, 1.3, Y) * smooth(0.45, 0.75, n2)
    f.G += 0.12 * np.exp(-(L.CEILING - Y) / 0.08) * (0.5 + n2)
    # The foot of the wall: mop water, shoe dirt and dust, darkest in the first 10 cm.
    f.G += 0.55 * np.exp(-Y / 0.12) * (0.55 + 0.9 * n2) + 0.22 * np.exp(-Y / 0.45) * n1
    # Kept faint: the shell's grime colour is a warm brown, and a saturated patch beside a door reads
    # as rust or dried blood under the torch, which option A rules out.
    for c, r, amp in latch_points():
        f.G += amp * f.blob(c, r) * (0.55 + 0.9 * n3)
    # Shoe scuffs at the foot of the wall only, near level, soft; a few through the paint.
    for _ in range(int(s.w * 2.5)):
        x = L.X0 + rng.uniform(0, s.w)
        if any(d.hole[0] - L.ARCH_W - 0.02 < x < d.hole[1] + L.ARCH_W + 0.02 for d in L.DOORS):
            continue
        y = rng.uniform(0.04, 0.3)
        ang = rng.normal(0, 0.12)
        pts = [(x, y)]
        for _k in range(4):
            pts.append((pts[-1][0] + 0.03 * math.cos(ang), pts[-1][1] + 0.03 * math.sin(ang)))
        line = f.segments(pts, 0.006, (0, 1))
        f.G += 0.22 * line
        if rng.random() < 0.1:
            f.R = np.maximum(f.R, 0.7 * line)
    # Damp wicking up from the mopped floor: a low tide line in patches, flaking paint and a little mould.
    patches = smooth(0.45, 0.65, fbm(f.a, f.b, 4400, 0.6))
    level = 0.07 + 0.09 * n1
    body, line = M.tide(f, level)
    f.B = np.maximum(f.B, (0.3 * body + 0.75 * line) * patches)
    f.R = np.maximum(f.R, smooth(0.66, 0.8, n2) * smooth(0.3, 0.06, Y) * patches)
    f.A = np.maximum(f.A, 0.45 * np.exp(-Y / 0.1) * smooth(0.55, 0.8, n2) * patches)
    # Chips knocked off next to the architraves at hand and bag height.
    for d in L.DOORS:
        for x in (d.hole[0] - L.ARCH_W, d.hole[1] + L.ARCH_W):
            near = np.exp(-np.abs(X - x) / 0.025) * smooth(0.5, 0.8, Y) * smooth(1.5, 1.1, Y)
            f.R = np.maximum(f.R, smooth(0.6, 0.9, near * (0.5 + n3)))


def paint_skirting(f):
    Y, n1, n2 = f.Y, f.n1, f.n2
    f.R = 0.6 + 0.2 * (n2 - 0.4)
    f.G = 0.25 + 0.2 * n1 + 0.35 * np.exp(-Y / 0.025) * (0.5 + n2)
    for d in L.DOORS:
        f.G += 0.2 * f.blob(((d.x0 + d.x1) / 2, 0.05, L.WALL_FACE), (0.8, 0.2, 0.2)) * (0.4 + n2)


def floor_edges(f):
    """Distance to the wall face and to the slab edge under the railing."""
    return np.minimum(np.abs(f.Z - L.WALL_FACE), np.abs(L.EDGE_Z - f.Z))


def paint_floor(f, rng):
    if f.s.material == "skirting":
        paint_skirting(f)
        return
    X, Z, n1, n2, n3 = f.X, f.Z, f.n1, f.n2, f.n3
    dw = floor_edges(f)
    f.R = 0.5 + 0.3 * np.exp(-dw / 0.4) + 0.2 * (n2 - 0.4)
    blotch = fbm(f.a, f.b, 5300, 0.6)
    f.G = 0.1 + 0.18 * smooth(0.35, 0.75, blotch) + 0.45 * np.exp(-dw / 0.06) * (0.5 + n2) + 0.18 * np.exp(-dw / 0.3) * n1
    # Dust and grit blown in from the open side gather along the slab edge.
    f.G += 0.25 * np.exp(-(L.EDGE_Z - Z) / 0.3) * (0.4 + n2)
    for d in L.DOORS:  # where people stop in front of a door
        f.G += 0.22 * f.box((d.x0 - 0.15, -1, L.WALL_FACE), (d.x1 + 0.15, 1, 0.8), 0.12) * (0.3 + n2)
    # The walking lane down the corridor and the turn into each door, polished.
    wear = 0.6 * np.exp(-((Z - 2.0) / 0.6) ** 2)
    for d in L.DOORS:
        cx = (d.x0 + d.x1) / 2
        lane = np.exp(-((X - cx) / 0.35) ** 2) * smooth(2.2, 1.6, Z)
        wear = np.maximum(wear, 0.55 * lane)
    f.A = wear * (0.6 + 0.6 * n1)
    f.G -= 0.05 * wear
    for _ in range(45):  # black shoe scuffs in the lane
        cx, cz = rng.uniform(L.X0 + 0.2, L.X1 - 0.2), rng.normal(2.0, 0.55)
        ang = rng.uniform(0, math.tau)
        arc = [(cx + 0.012 * k * math.cos(ang + 0.15 * k), cz + 0.012 * k * math.sin(ang + 0.15 * k)) for k in range(6)]
        f.G += 0.4 * f.segments(arc, 0.003)
    # Rain that blew in under the railing: damp patches drying from the edge.
    f.B = 0.55 * smooth(3.3, 3.95, Z) * smooth(0.45, 0.7, n2 + 0.2 * n3)


def paint_ceiling(f, rng):
    X, Z, n1, n2 = f.X, f.Z, f.n1, f.n2
    edge = L.EDGE_Z - Z
    f.G = 0.1 + 0.22 * smooth(0.35, 0.75, n1) + 0.05 * (n2 - 0.5)
    f.G += 0.3 * np.exp(-np.abs(Z - L.WALL_FACE) / 0.06) * (0.5 + n2)
    f.G += 0.4 * np.exp(-edge / 0.3) * (0.4 + n2)  # weathered open edge
    for cx, cz in L.LIGHTS:  # soot and dead insects over the tube battens
        f.G += 0.45 * f.blob((cx, L.CEILING, cz), (0.8, 1.0, 0.3)) * (0.6 + 0.6 * n2)
    # Rain soaking in from the open edge: a damp band with a tide line, mould in the wettest spots.
    px = 1.0 / f.scale
    d = edge - (0.3 + 0.25 * n1)
    body = 1 - smooth(-px, px, d)
    line = np.clip(1 - np.abs(d) / (1.4 * px), 0, 1)
    f.B = (0.3 * body + 0.8 * line) * smooth(0.3, 0.55, n2 + 0.1)
    f.A = 0.6 * np.exp(-edge / 0.15) * smooth(0.45, 0.7, n2)
    f.B = np.maximum(f.B, M.leak_rings(f, (29.4, 1.3), 0.45, 294))
    lines = []
    for start, heading, steps in (((30.0, 0.1), 1.57, 90), ((L.X0 + 0.5, 2.6), 0.1, 60), ((33.2, 4.0), -1.9, 40)):
        lines += M.walk(rng, start, heading, steps, 0.04, 0.12, 0.1)
    for poly in lines:
        f.R = np.maximum(f.R, f.segments(poly, 0.0042))
        f.G += 0.12 * f.segments(poly, 0.02)


PAINT = {"walls": paint_wall, "floor": paint_floor, "ceiling": paint_ceiling}


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    shells, scales = L.layout()
    wanted = set(sys.argv[1:]) or set(scales)
    for group, scale in scales.items():
        if group not in wanted:
            continue
        rng = np.random.default_rng(406)
        atlas = np.zeros((L.ATLAS[1], L.ATLAS[0], 4), np.uint8)
        atlas[:, :] = NEUTRAL_VALUE[group]
        for k, s in enumerate([s for s in shells if s.group == group]):
            f = M.Field(s, scale, 2000 + k * 37)
            PAINT[group](f, rng)
            x0, y0, w, h = s.rect
            atlas[y0 - L.PAD:y0 + h + L.PAD, x0 - L.PAD:x0 + w + L.PAD] = f.rgba()
        n = L.NEUTRAL
        atlas[n[1]:n[1] + n[3], n[0]:n[0] + n[2]] = NEUTRAL_VALUE[group]
        Image.fromarray(atlas, "RGBA").save(OUT / f"mask_{group}.png", optimize=True)
        print("MASK", group, scale, "px/m", flush=True)
    print("RESULT: corridor segment masks PASS")


if __name__ == "__main__":
    main()
