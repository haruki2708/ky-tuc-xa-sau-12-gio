"""T-265 round 1: the library pilot (card section 2, step 2) with the options the owner picks from (step 3). Blender 5.2.2,
bmesh only, no add-on, no Tripo. World pieces are in Godot world space with the glb origin at Godot (0, G, 0) (as the
earlier waves); "local" pieces have their origin where the capture hangs them (a shelf's, a table's or the back door's
Hinge node). Nothing new stands where the player walks that the PS1 did not have, except M2/M3's pieces (fill_m2.glb,
fill_m3.glb: the options; round 2 gives M2's pieces colliders under Real/Added). wave8_layout.py has the measurements.

  shell_f1|f2|f3.glb    one floor's inside: floor (Floor_F1 ceramic, Floor_F2 terrazzo, Floor_F3 cement on the top floor),
                        walls 4 mm inside the PS1 walls with the windows' reveals (Walls_F1 pale yellow over a ceramic
                        skirting, Walls_F2 ivory limewash over a green dado), sills, windows seen from inside (WinGlass:
                        dark glass, bars, faded curtains; WinShutter: closed louvred shutters), the ceiling (CeilPanels C2:
                        60 x 60 stained panels at 2.95 m with a few missing; CeilConcrete C1: the bare slab and its beams,
                        Fans), the light fittings (Battens: the two lit where the PS1 lights are, the rest dead), the well's
                        slab edges
  stairs.glb            both flights: terrazzo treads and risers on the PS1 ramp (tread tops on the ramp's middle line, as
                        the PS1 steps), stringers, soffits, balustrades inside RailCollision* (x 79, 84)
  counter_q1.glb        Q1: plywood counter with a glass top, top face at 0.868 m (the iron bar's foot is at 0.8865), a CRT
                        monitor (off), keyboard, card file box, stamp, ledger; counter_q2.glb Q2: built and tiled, terrazzo top
  librarian_chair.glb   an old swivel chair whose seat is LibrarianSeat (57, -9.44, 207.5)
  map_print.glb / map_drawn.glb   M-board options: print in an aluminium frame under glass / drawn on squared paper taped
                        to a plywood board; the two red rings in the image where the PS1 FadedCircle* run
  shelf_steel.glb / shelf_wood.glb   (local: a Shelf node) the stack inside the PS1 shelf's colliders (boards at the PS1's
                        heights); books_full.glb / books_sparse.glb / books_tipped.glb (local) the books (atlas, one mesh)
  table_t1.glb / table_t2.glb   (local: a ReadingTable node) T1 a long wooden table and two loose chairs; T2 the same with a
                        felt divider and two banker's lamps (off); rule_book.glb (local) the rule book on ReadingTable13
  back_frame.glb        the back doorway's lining and casings (world); back_leaf.glb (local: BackDoor/Hinge) the new leaf:
                        painted boards, two wired-glass vision panes, a lever where Hinge/Handle is
  front_door.glb        the shut front doors (double, glazed) in their frame; barricade.glb the barricade (the PS1 table's
                        place: a heavy table, three chairs upside down on it)
  facade_e1.glb         E1: lime yellow walls, whitewashed bands, bare concrete fins 0.45 m deep over the long faces, a hood
                        over the front door; facade_e2.glb E2: washed pebble render, the "THƯ VIỆN" sign over the door. Both:
                        windows (FakeRooms / DarkGlass), parapet, roof, tanks, downpipes
  strip.glb             the ring round the library (x 39..91, z 189..231 less the floor): concrete aprons and covered
                        drains, paved forecourt and porch at the front door, worn verge on wave 7's campus mask
  fill_m2.glb           M2's added pieces (wave8_layout.FILL["m2"]); fill_m3.glb M3's mid-room stacks
  mess.glb              the messy level: fallen books by the shelves, scattered papers, a fallen panel, an overturned chair
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave8/build_wave8_pilot.py [-- name ...]
"""
import json
import math
from pathlib import Path
import random
import sys

import bpy  # noqa: F401

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE.parent / "wave1"))
sys.path.insert(0, str(HERE.parent / "wave5"))
sys.path.insert(0, str(HERE))
import w1kit  # noqa: E402
import build_gate_pilot as GP  # noqa: E402  (GPart, B, build, export; its main is guarded)
import wave8_layout as L  # noqa: E402

ROOT = HERE.parents[3]
OUT = ROOT / "game/assets/models/graphics_pilot/realistic_map/wave8"
G = L.G
PALETTE = json.loads((HERE / "palette8.json").read_text(encoding="utf-8"))
GP.PREVIEW.update({"W8WallYellow": ((0.86, 0.79, 0.55), 0.85), "W8Books": ((0.4, 0.3, 0.25), 0.8), "W8ShelfSteel": ((0.46, 0.5, 0.48), 0.5)})
INSET = 0.004
SKIRT = 0.1
DADO = 1.2


# ------------------------------------------------------------------------------------------------ kit

class Frame:
	"""Local Godot point -> world Godot point: origin + yaw about +y (Godot's rotation_degrees.y)."""

	def __init__(self, origin=(0.0, 0.0, 0.0), yaw=0.0):
		self.o = origin
		self.c, self.s = math.cos(math.radians(yaw)), math.sin(math.radians(yaw))

	def p(self, q):
		x, y, z = q
		return (self.o[0] + x * self.c + z * self.s, self.o[1] + y, self.o[2] - x * self.s + z * self.c)

	def n(self, q):
		x, y, z = q
		return (x * self.c + z * self.s, y, -x * self.s + z * self.c)


WORLD = Frame()
LOCAL = Frame((0.0, G, 0.0))      # a local glb: Godot local (x, y, z) -> B() puts it at Blender (x, -z, y)


class Part(GP.GPart):
	def __init__(self, name, frame=WORLD):
		super().__init__(name)
		self.f = frame
		self.painted = []

	def box(self, m, lo, hi, skip=()):
		return list(self.xbox(m, lo, hi, self.f.p, skip).values())

	def quad(self, m, pts, normal, uv=None):
		f = self.face(m, [self.f.p(q) for q in pts], self.f.n(normal), uv)
		if uv is not None:
			self.painted.append(f)
		return f

	def rod(self, m, pts, r, sides=8, cap=True):
		return self.pipe(m, [self.f.p(q) for q in pts], r, sides=sides, cap=cap)

	def beam2(self, m, a, b, w, h, up=(0, 1, 0)):
		return self.beam(m, self.f.p(a), self.f.p(b), w, h, up=self.f.n(up))

	def pal(self, faces, key, rnd=None):
		cx, cy = PALETTE[key]
		rnd = rnd or random
		for f in faces:
			ju, jv = rnd.uniform(0.3, 0.7), rnd.uniform(0.3, 0.7)
			for loop in f.loops:
				loop[self.uv].uv = ((cx + ju) / 8.0, 1.0 - (cy + jv) / 8.0)
			f.tag = True
		self.painted += list(faces)
		return faces

	def pbox(self, key, lo, hi, rnd=None, skip=()):
		return self.pal(self.box("W8Palette", lo, hi, skip), key, rnd)


def build(part, extra=None):
	for f in part.painted:
		if f.is_valid:
			f.tag = True
	sizes = dict(L.SIZES)
	sizes.update(extra or {})
	GP.ensure_uv2(part)
	return GP.build(part, sizes)


def export(name, parts):
	objs = [build(p) for p in parts if p.bm.faces]
	GP.export(OUT / name, objs)
	return objs


def uv_img(u, v):
	"""Image coordinates (v down) -> the Blender UV glTF flips back."""
	return (u, 1.0 - v)


# ------------------------------------------------------------------------------------------------ shells

def wall_run(part, mat_lo, mat_hi, a, b, y0, y1, normal, holes, row, split):
	"""An inside wall face from a to b ((x, z) points on the face plane), y0..y1 (world), holes [(s0, s1, ya, yb)] in metres
	along a->b, split into the lower material below y0 + split. UV2: wave8_layout.wall_uv2(row, inner_s, y - floor)."""
	ax, az = a
	bx, bz = b
	full = math.hypot(bx - ax, bz - az)
	ss = {0.0, full}
	ys = {y0, y1, y0 + split} if split > 0 else {y0, y1}
	for h in holes:
		ss |= {max(0.0, min(full, h[0])), max(0.0, min(full, h[1]))}
		ys |= {max(y0, min(y1, h[2])), max(y0, min(y1, h[3]))}
	ss, ys = sorted(ss), sorted(ys)
	faces = []
	for i in range(len(ss) - 1):
		for j in range(len(ys) - 1):
			sm, ym = (ss[i] + ss[i + 1]) / 2, (ys[j] + ys[j + 1]) / 2
			if any(h[0] < sm < h[1] and h[2] < ym < h[3] for h in holes):
				continue
			P = lambda s, y: (ax + (bx - ax) * s / full, y, az + (bz - az) * s / full)  # noqa: E731
			m = mat_lo if ym < y0 + split else mat_hi
			faces.append(part.quad(m, [P(ss[i], ys[j]), P(ss[i + 1], ys[j]), P(ss[i + 1], ys[j + 1]), P(ss[i], ys[j + 1])], normal))
	part.map_uv2(faces, lambda q: L.wall_uv2(row, L.inner_s(_snap_x(q[0]), _snap_z(q[2])), q[1] - y0))
	return faces


def _snap_x(x):
	for v in (L.IN_W, L.IN_E):
		if abs(x - v) < 0.02:
			return v
	return x


def _snap_z(z):
	for v in (L.IN_S, L.IN_N):
		if abs(z - v) < 0.02:
			return v
	return z


def window_inside(win, shut, sills, x, y_floor, wall_z, inward, rnd):
	"""One window seen from inside on a long wall (wall_z: its inside face, inward: +1 for the front wall (the room is +z)).
	The reveal is lined in the wall part; here the sill, and per option the dark glass with bars and curtains or the shutters."""
	x0, x1 = x - L.WINDOW["w"] / 2, x + L.WINDOW["w"] / 2
	y0, y1 = y_floor + L.WINDOW["foot"], y_floor + L.WINDOW["head"]
	mid = wall_z - inward * 0.11       # the wall's middle plane
	n = (0, 0, inward)
	# Sill: a cream terrazzo board in the reveal, 5 cm proud of the wall.
	lo_z, hi_z = sorted((mid, wall_z + inward * 0.05))
	sills.box("W1Terrazzo", (x0 - 0.04, y0 - 0.04, lo_z), (x1 + 0.04, y0, hi_z))
	# Option 1: dark glass in an aluminium frame, bars inside the reveal, curtains drawn part way.
	win.quad("W7GlassDark", [(x0, y0, mid + inward * 0.002), (x1, y0, mid + inward * 0.002), (x1, y1, mid + inward * 0.002),
		(x0, y1, mid + inward * 0.002)], n)
	for k in range(4):
		xm = x0 + (x1 - x0) * k / 3
		za, zb = sorted((mid + inward * 0.002, mid + inward * 0.04))
		win.box("W1Alu", (xm - 0.025, y0, za), (xm + 0.025, y1, zb))
	for yy in (y0, y1 - 0.05):
		za, zb = sorted((mid + inward * 0.002, mid + inward * 0.04))
		win.box("W1Alu", (x0, yy, za), (x1, yy + 0.05, zb))
	zb_ = mid + inward * 0.07
	for k in range(1, 24):
		xb = x0 + (x1 - x0) * k / 24
		win.rod("W1Iron", [(xb, y0 + 0.01, zb_), (xb, y1 - 0.01, zb_)], 0.007, sides=4, cap=False)
	for yy in (y0 + 0.05, (y0 + y1) / 2, y1 - 0.05):
		za, zb = sorted((zb_ - 0.01, zb_ + 0.01))
		win.box("W1Iron", (x0, yy - 0.015, za), (x1, yy + 0.015, zb))
	col = rnd.choice(["curtain_beige", "curtain_green", "curtain_blue", "curtain_beige"])
	zc = wall_z + inward * 0.03
	cover = rnd.uniform(0.25, 0.6)
	rod_lo, rod_hi = sorted((wall_z + inward * 0.01, wall_z + inward * 0.05))
	win.pbox("chrome", (x0 - 0.15, y1 + 0.08, rod_lo), (x1 + 0.15, y1 + 0.1, rod_hi), rnd)
	for side in (0, 1):
		w = (x1 - x0 + 0.3) * cover * (0.5 if side else 0.5)
		xa = x0 - 0.15 if side == 0 else x1 + 0.15 - w
		folds = 7
		pts = []
		for k in range(folds + 1):
			pts.append((xa + w * k / folds, zc + inward * (0.025 if k % 2 else 0.0)))
		faces = []
		for (pa, pb) in zip(pts, pts[1:]):
			faces.append(win.quad("W8Palette", [(pa[0], y0 - 0.15, pa[1]), (pb[0], y0 - 0.15, pb[1]), (pb[0], y1 + 0.08, pb[1]),
				(pa[0], y1 + 0.08, pa[1])], n))
		win.pal(faces, col, rnd)
	# Option 2: louvred wooden shutters, two leaves shut in the reveal.
	za, zb = sorted((mid + inward * 0.02, mid + inward * 0.09))
	for leaf in range(2):
		lx0 = x0 + leaf * (x1 - x0) / 2
		lx1 = lx0 + (x1 - x0) / 2
		shut.box("W1Wood", (lx0, y0, za), (lx0 + 0.07, y1, zb))
		shut.box("W1Wood", (lx1 - 0.07, y0, za), (lx1, y1, zb))
		shut.box("W1Wood", (lx0, y0, za), (lx1, y0 + 0.09, zb))
		shut.box("W1Wood", (lx0, y1 - 0.09, za), (lx1, y1, zb))
		shut.box("W1Wood", (lx0, (y0 + y1) / 2 - 0.04, za), (lx1, (y0 + y1) / 2 + 0.04, zb))
		yy = y0 + 0.12
		while yy < y1 - 0.12:
			shut.beam2("W1Wood", (lx0 + 0.07, yy, (za + zb) / 2), (lx1 - 0.07, yy, (za + zb) / 2), 0.012, 0.06,
				up=(0, math.cos(math.radians(40)), inward * math.sin(math.radians(40))))
			yy += 0.055
		shut.pbox("brass", (lx1 - 0.12 if leaf == 0 else lx0 + 0.06, (y0 + y1) / 2 - 0.05, za - 0.01),
			(lx1 - 0.06 if leaf == 0 else lx0 + 0.12, (y0 + y1) / 2 + 0.05, zb + 0.01), rnd)


def batten(part, x, y, z, lit, dead_mat="W8TubeDead"):
	"""A twin-tube fluorescent batten along x, its underside at y (hanging under the ceiling)."""
	part.box("W1Steel", (x - 0.62, y + 0.06, z - 0.08), (x + 0.62, y + 0.12, z + 0.08))
	part.box("W1Steel", (x - 0.63, y + 0.02, z - 0.1), (x + 0.63, y + 0.06, z + 0.1))
	for dz in (-0.045, 0.045):
		part.rod("W2Tube" if lit else dead_mat, [(x - 0.6, y + 0.0, z + dz), (x + 0.6, y + 0.0, z + dz)], 0.013, sides=6, cap=True)


def build_shell(level, rnd):
	w1kit.reset()
	y = L.LEVELS[level]
	ceil = L.CEILING[level]
	parts = {k: Part(k) for k in ("Floor_F1", "Floor_F2", "Floor_F3", "Walls_F1", "Walls_F2", "Sills", "WinGlass", "WinShutter",
		"CeilPanels", "CeilConcrete", "Fans", "Battens", "WellEdge")}
	# Floor: the plates less the well on the upper floors (x 79..85, z 199..209).
	rects = [(L.IN_W, L.IN_E, L.IN_S, L.IN_N)] if level == 0 else [(L.IN_W, L.WELL[0], L.IN_S, L.IN_N),
		(L.WELL[0], L.IN_E, L.IN_S, L.WELL[2]), (L.WELL[0], L.IN_E, L.WELL[3], L.IN_N)]
	for key, m in (("Floor_F1", "W8FloorCeramic"), ("Floor_F2", "W8FloorTerrazzo"), ("Floor_F3", "W8FloorCement")):
		if key == "Floor_F3" and level != 2:
			continue
		faces = [parts[key].quad(m, [(x0, y + 0.002, z0), (x1, y + 0.002, z0), (x1, y + 0.002, z1), (x0, y + 0.002, z1)], (0, 1, 0))
			for x0, x1, z0, z1 in rects]
		parts[key].map_uv2(faces, lambda q: L.floor_uv2(level, q[0], q[2]))
	# Walls (inside faces 4 mm in front of the PS1's), the windows and (floor 1) the two doorways cut through.
	win_holes = [(wx - 1.5, wx + 1.5, y + L.WINDOW["foot"], y + L.WINDOW["head"]) for wx in L.WINDOWS_X]
	door = (L.DOOR_X[0], L.DOOR_X[1], y - 1.0, y + L.DOOR_H)
	front_holes = [(h[0] - L.IN_W, h[1] - L.IN_W, h[2], h[3]) for h in win_holes]
	back_holes = [(L.IN_E - h[1], L.IN_E - h[0], h[2], h[3]) for h in win_holes]
	if level == 0:
		front_holes.append((door[0] - L.IN_W, door[1] - L.IN_W, door[2], door[3]))
		back_holes.append((L.IN_E - door[1], L.IN_E - door[0], door[2], door[3]))
	for key, lo, hi, split in (("Walls_F1", "W8Skirting", "W8WallYellow", SKIRT), ("Walls_F2", "W8DadoGreen", "W8WallIvory", DADO)):
		p = parts[key]
		zf, zb = L.IN_S + INSET, L.IN_N - INSET
		xw, xe = L.IN_W + INSET, L.IN_E - INSET
		wall_run(p, lo, hi, (L.IN_W, zf), (L.IN_E, zf), y, ceil, (0, 0, 1), front_holes, level, split)
		wall_run(p, lo, hi, (xe, L.IN_S), (xe, L.IN_N), y, ceil, (-1, 0, 0), [], level, split)
		wall_run(p, lo, hi, (L.IN_E, zb), (L.IN_W, zb), y, ceil, (0, 0, -1), back_holes, level, split)
		wall_run(p, lo, hi, (xw, L.IN_N), (xw, L.IN_S), y, ceil, (1, 0, 0), [], level, split)
		# Window reveals to the wall's middle; doorways right through (the frames line them).
		for wx in L.WINDOWS_X:
			for wall_z, inward in ((L.IN_S, 1), (L.IN_N, -1)):
				mid = wall_z - inward * 0.11
				x0, x1 = wx - 1.5, wx + 1.5
				y0, y1 = y + L.WINDOW["foot"], y + L.WINDOW["head"]
				za, zb = wall_z + inward * INSET, mid
				p.quad(hi, [(x0, y1, za), (x1, y1, za), (x1, y1, zb), (x0, y1, zb)], (0, -1, 0))
				p.quad(hi, [(x0, y0, za), (x0, y1, za), (x0, y1, zb), (x0, y0, zb)], (1, 0, 0))
				p.quad(hi, [(x1, y0, za), (x1, y1, za), (x1, y1, zb), (x1, y0, zb)], (-1, 0, 0))
		# Dado / skirting cap: a 2 cm strip proud of the wall at the split, broken at the doorways.
		cap_mat = "W1Wood" if key == "Walls_F2" else "W8Skirting"
		yc = y + split
		for (a, b, axis, plane, inward) in ((L.IN_W, L.IN_E, "x", L.IN_S, 1), (L.IN_W, L.IN_E, "x", L.IN_N, -1), (L.IN_S, L.IN_N, "z", L.IN_W, 1),
				(L.IN_S, L.IN_N, "z", L.IN_E, -1)):
			segs = [(a, b)]
			if level == 0 and axis == "x":
				segs = [(a, door[0]), (door[1], b)]
			for s0, s1 in segs:
				if axis == "x":
					za, zb = sorted((plane, plane + inward * (INSET + 0.015)))
					p.box(cap_mat, (s0, yc - 0.02, za), (s1, yc + 0.015, zb))
				else:
					xa, xb = sorted((plane, plane + inward * (INSET + 0.015)))
					p.box(cap_mat, (xa, yc - 0.02, s0), (xb, yc + 0.015, s1))
	for wx in L.WINDOWS_X:
		for wall_z, inward in ((L.IN_S, 1), (L.IN_N, -1)):
			window_inside(parts["WinGlass"], parts["WinShutter"], parts["Sills"], wx, y, wall_z, inward, rnd)
	# Ceiling C2: panels at 2.95 m (floor 3: 0.06 under the roof's underside), a perimeter angle; holes where 7 panels are
	# missing (the dark plenum behind), the well left open on floors 1-2.
	ph = min(y + 2.95, ceil - 0.05)
	cp = parts["CeilPanels"]
	crects = [(L.IN_W, L.IN_E, L.IN_S, L.IN_N)] if level == 2 else [(L.IN_W, L.WELL[0], L.IN_S, L.IN_N), (L.WELL[0], L.IN_E, L.IN_S, L.WELL[2]),
		(L.WELL[0], L.IN_E, L.WELL[3], L.IN_N)]
	missing = [(47.5 + rnd.randrange(0, 50) * 0.6, 196.5 + rnd.randrange(0, 45) * 0.6) for _ in range(7)]
	for x0, x1, z0, z1 in crects:
		f = cp.quad("W8CeilingPanel", [(x0, ph, z0), (x1, ph, z0), (x1, ph, z1), (x0, ph, z1)], (0, -1, 0))
		cp.map_uv2([f], lambda q: L.floor_uv2(level, q[0], q[2]))
	for mx, mz in missing:
		if L.WELL[0] - 0.6 < mx < L.WELL[1] and L.WELL[2] - 0.6 < mz < L.WELL[3]:
			continue
		cp.quad("W6Plenum", [(mx, ph - 0.002, mz), (mx + 0.6, ph - 0.002, mz), (mx + 0.6, ph - 0.002, mz + 0.6), (mx, ph - 0.002, mz + 0.6)], (0, -1, 0))
	if level < 2:
		# The well's sides between the panels and the slab (seen from the stairs).
		for (a, b), plane, axis, inward in ((((L.WELL[0], L.WELL[1])), L.WELL[2], "x", 1), (((L.WELL[0], L.WELL[1])), L.WELL[3], "x", -1),
				(((L.WELL[2], L.WELL[3])), L.WELL[0], "z", 1)):
			if axis == "x":
				cp.quad("W8CeilingConcrete", [(a, ph, plane), (b, ph, plane), (b, ceil, plane), (a, ceil, plane)], (0, 0, inward))
			else:
				cp.quad("W8CeilingConcrete", [(plane, ph, a), (plane, ph, b), (plane, ceil, b), (plane, ceil, a)], (inward, 0, 0))
	# Ceiling C1: the bare slab underside, beams across every 5 m (0.3 x 0.4), fans (stopped) in C1 only.
	cc = parts["CeilConcrete"]
	for x0, x1, z0, z1 in crects:
		f = cc.quad("W8CeilingConcrete", [(x0, ceil - INSET, z0), (x1, ceil - INSET, z0), (x1, ceil - INSET, z1), (x0, ceil - INSET, z1)], (0, -1, 0))
		cc.map_uv2([f], lambda q: L.floor_uv2(level, q[0], q[2]))
	for bz in (200.0, 205.0, 210.0, 215.0, 220.0):
		spans = [(L.IN_W, L.IN_E)] if level == 2 or not (L.WELL[2] < bz < L.WELL[3]) else [(L.IN_W, L.WELL[0])]
		for x0, x1 in spans:
			cc.box("W8CeilingConcrete", (x0, ceil - 0.4, bz - 0.15), (x1, ceil - INSET, bz + 0.15))
	for fx in (50.0, 62.0, 74.0):
		for fz in (202.5, 217.5):
			if level < 2 and L.WELL[0] - 1 < fx < L.WELL[1] and L.WELL[2] - 1 < fz < L.WELL[3]:
				continue
			fan = parts["Fans"]
			fan.rod("W1Steel", [(fx, ceil - 0.4, fz), (fx, ceil - 0.02, fz)], 0.012, sides=6)
			fan.pal(fan.cylinder("W8Palette", tuple(GP.B((fx, ceil - 0.5, fz))), 0.1, 0.12, axis="Z", segments=12), "fan_cream", rnd)
			for k in range(3):
				a = math.radians(k * 120 + rnd.uniform(0, 120))
				ex, ez = fx + math.cos(a) * 0.65, fz + math.sin(a) * 0.65
				fan.pal(fan.beam2("W8Palette", (fx + math.cos(a) * 0.08, ceil - 0.5, fz + math.sin(a) * 0.08), (ex, ceil - 0.53, ez), 0.12, 0.008),
					"fan_cream", rnd)
	# Battens: lit where the PS1 lights are (x 54, 70; z 211), dead elsewhere.
	by = min(y + L.LIGHT_H + 0.04, ph - 0.12)
	for bx in L.LIGHTS_X:
		for bz in (201.0, 211.0, 221.0):
			batten(parts["Battens"], bx, by, bz, lit=(bz == L.LIGHT_Z))
			for dx in (-0.4, 0.4):
				parts["Battens"].rod("W1Steel", [(bx + dx, by + 0.12, bz), (bx + dx, ph, bz)], 0.004, sides=4, cap=False)
	# The well's slab edge on the upper floors (0.24 thick) and its underside's lip.
	if level > 0:
		we = parts["WellEdge"]
		for (a, b), plane, axis, inward in (((L.WELL[0], L.WELL[1]), L.WELL[2], "x", 1), ((L.WELL[0], L.WELL[1]), L.WELL[3], "x", -1),
				((L.WELL[2], L.WELL[3]), L.WELL[0], "z", 1)):
			if axis == "x":
				we.quad("W8CeilingConcrete", [(a, y - L.SLAB, plane), (b, y - L.SLAB, plane), (b, y, plane), (a, y, plane)], (0, 0, inward))
			else:
				we.quad("W8CeilingConcrete", [(plane, y - L.SLAB, a), (plane, y - L.SLAB, b), (plane, y, b), (plane, y, a)], (inward, 0, 0))
			# A terrazzo nosing strip on the slab's edge.
			if axis == "x":
				za, zb = sorted((plane, plane - inward * 0.05))
				we.box("W1Terrazzo", (a, y - 0.03, za), (b, y + 0.004, zb))
			else:
				xa, xb = sorted((plane, plane - inward * 0.05))
				we.box("W1Terrazzo", (xa, y - 0.03, a), (xb, y + 0.004, b))
	return export("shell_f%d.glb" % (level + 1), list(parts.values()))


# ------------------------------------------------------------------------------------------------ stairs

def build_stairs():
	w1kit.reset()
	treads, sides, rails = Part("Treads"), Part("Stringers"), Part("Balustrades")
	n = L.STAIRS["steps"]
	run = (L.STAIRS["z"][1] - L.STAIRS["z"][0]) / n
	x0, x1 = L.STAIRS["x"]
	for level in range(2):
		y = L.LEVELS[level]
		for i in range(n):
			za, zb = L.STAIRS["z"][0] + i * run, L.STAIRS["z"][0] + (i + 1) * run
			top = y + (i + 0.5) * L.STAIRS["rise"]
			low = top - L.STAIRS["rise"]
			# Tread (4 cm terrazzo slab with a nosing 2 cm over the riser) and the riser under it.
			treads.box("W1Terrazzo", (x0 + 0.06, top - 0.04, za - 0.02), (x1 - 0.06, top, zb))
			treads.box("W1Terrazzo", (x0 + 0.06, max(low, y - 0.001), za), (x1 - 0.06, top - 0.04, za + 0.02))
		# Stringers along both sides (0.06 wide), from the floor to the landing; the soffit under the flight.
		za, zb = L.STAIRS["z"]
		for xs in (x0, x1 - 0.06):
			pts = [(xs, y - 0.25, za), (xs, y + 0.12, za - 0.1), (xs, y + 3.3 + 0.12, zb - 0.1), (xs, y + 3.3 - 0.25, zb)]
			for xx, nn in ((xs, (-1, 0, 0)), (xs + 0.06, (1, 0, 0))):
				sides.quad("W8WallIvory", [(xx, p[1], p[2]) for p in pts], nn)
			sides.quad("W8WallIvory", [(xs, y + 0.12, za - 0.1), (xs + 0.06, y + 0.12, za - 0.1), (xs + 0.06, y + 3.42, zb - 0.1),
				(xs, y + 3.42, zb - 0.1)], (0, 1, -0.3))
		sides.quad("W8CeilingConcrete", [(x0, y - 0.25 + 0.001, za), (x1, y - 0.25 + 0.001, za), (x1, y + 3.05, zb), (x0, y + 3.05, zb)], (0, -1, 0.3))
		# Balustrades inside RailCollision* (x 79 +- 0.05, 1.1 m over the slope): flat-bar posts, a timber handrail.
		for xr in L.RAILS_X:
			for k in range(0, 41):
				z = za + 0.12 + k * (zb - za - 0.24) / 40
				s = y + (z - za) * 0.33
				rails.box("W1Iron", (xr - 0.006, s + 0.02, z - 0.012), (xr + 0.006, s + 0.92, z + 0.012))
			for h, mat, w, t in ((0.92, "W1Wood", 0.05, 0.06), (0.1, "W1Iron", 0.012, 0.03)):
				rails.beam2(mat, (xr, y + h, za), (xr, y + 3.3 + h, zb), w, t)
			rails.box("W1Iron", (xr - 0.025, y, za - 0.025), (xr + 0.025, y + 1.0, za + 0.025))
			rails.box("W1Iron", (xr - 0.025, y + 3.3, zb - 0.025), (xr + 0.025, y + 4.3, zb + 0.025))
	return export("stairs.glb", [treads, sides, rails])


# ------------------------------------------------------------------------------------------------ counter, chair

TOP = 0.868     # the counter's new top face over the floor (collider top 0.84, iron bar's foot 0.8865)


def counter_items(p, cx, cz, top, rnd):
	y = G + top
	# CRT monitor (off) and keyboard at the west end, facing +z (the staff side), a card file box, the stamp and pad, a ledger.
	mx, mz = cx - 1.7, cz - 0.15
	p.pbox("crt_beige", (mx - 0.2, y, mz - 0.22), (mx + 0.2, y + 0.04, mz + 0.18), rnd)
	p.pbox("crt_beige", (mx - 0.06, y + 0.04, mz - 0.06), (mx + 0.06, y + 0.1, mz + 0.06), rnd)
	p.pbox("crt_beige", (mx - 0.2, y + 0.1, mz - 0.25), (mx + 0.2, y + 0.42, mz + 0.12), rnd)
	p.pbox("crt_beige", (mx - 0.14, y + 0.14, mz - 0.4), (mx + 0.14, y + 0.38, mz - 0.25), rnd)
	p.pbox("screen_dark", (mx - 0.16, y + 0.13, mz + 0.12), (mx + 0.16, y + 0.39, mz + 0.125), rnd)
	p.pbox("keyboard", (mx - 0.22, y, mz + 0.22), (mx + 0.22, y + 0.03, mz + 0.38), rnd)
	p.rod("W1Cord", [(mx, y + 0.12, mz - 0.4), (mx + 0.1, y + 0.005, mz - 0.55), (mx + 0.3, y + 0.005, mz - 0.6)], 0.004, sides=4)
	fx, fz = cx - 0.85, cz - 0.25
	p.box("W1Wood", (fx - 0.17, y, fz - 0.22), (fx + 0.17, y + 0.16, fz + 0.22))
	p.pal(p.box("W8Palette", (fx - 0.15, y + 0.16, fz - 0.2), (fx + 0.15, y + 0.2, fz + 0.2)), "paper", rnd)
	p.pbox("brass", (fx - 0.04, y + 0.08, fz + 0.22), (fx + 0.04, y + 0.11, fz + 0.225), rnd)
	sx, sz = cx + 0.3, cz + 0.35
	p.pbox("ink_pad", (sx - 0.06, y, sz - 0.04), (sx + 0.06, y + 0.02, sz + 0.04), rnd)
	p.pbox("black", (sx + 0.1, y, sz - 0.02), (sx + 0.14, y + 0.03, sz + 0.02), rnd)
	p.pbox("stamp_red", (sx + 0.11, y + 0.03, sz - 0.01), (sx + 0.13, y + 0.1, sz + 0.01), rnd)
	lx, lz = cx + 1.6, cz + 0.2
	p.box("W1Ledger", (lx - 0.22, y, lz - 0.16), (lx + 0.22, y + 0.035, lz + 0.16))
	p.box("W1PageEdge", (lx - 0.215, y + 0.003, lz - 0.155), (lx + 0.215, y + 0.032, lz + 0.155))
	p.pal(p.box("W8Palette", (lx + 0.3, y, lz - 0.04), (lx + 0.38, y + 0.11, lz + 0.04)), "plastic_blue", rnd)


def build_counter(kind):
	w1kit.reset()
	rnd = random.Random(26510)
	p = Part("Counter" + kind.upper())
	cx, _, cz = L.COUNTER["at"]
	hw, hd = L.COUNTER["w"] / 2, L.COUNTER["d"] / 2
	x0, x1, z0, z1 = cx - hw, cx + hw, cz - hd, cz + hd
	top = G + TOP
	if kind == "q1":
		# Plywood carcass: the public front (z0, toward the front door) closed, the staff side closed by drawers along the PS1
		# Panel (z 206.54..206.66), a plinth; a wood top with a glass sheet over the west half (papers under it).
		p.box("W1WoodPale", (x0, G + 0.08, z0 + 0.02), (x1, top - 0.04, z0 + 0.04))
		p.box("W1Black", (x0 + 0.04, G, z0 + 0.06), (x1 - 0.04, G + 0.08, z1 - 0.1))
		p.box("W1WoodPale", (x0, G + 0.05, z1 - 0.12), (x1, top - 0.04, z1 - 0.08))
		for xe in (x0, x1 - 0.03):
			p.box("W1WoodPale", (xe, G, z0 + 0.02), (xe + 0.03, top - 0.04, z1 - 0.08))
		for k in range(10):
			dx0 = x0 + 0.06 + k * (L.COUNTER["w"] - 0.12) / 10
			dx1 = dx0 + (L.COUNTER["w"] - 0.12) / 10 - 0.02
			for row, (ya, yb) in enumerate(((0.12, 0.42), (0.45, 0.76))):
				p.box("W1Wood", (dx0, G + ya, z1 - 0.08), (dx1, G + yb, z1 - 0.06))
				p.pbox("brass", ((dx0 + dx1) / 2 - 0.05, G + yb - 0.08, z1 - 0.06), ((dx0 + dx1) / 2 + 0.05, G + yb - 0.06, z1 - 0.045), rnd)
		p.box("W1Wood", (x0 - 0.03, top - 0.04, z0 - 0.03), (x1 + 0.03, top, z1 + 0.02))
		p.quad("W2Glass", [(x0 + 0.05, top + 0.0005, z0 + 0.05), (cx - 0.3, top + 0.0005, z0 + 0.05), (cx - 0.3, top + 0.0005, z1 - 0.05),
			(x0 + 0.05, top + 0.0005, z1 - 0.05)], (0, 1, 0))
		for k in range(5):
			ax, az = x0 + 0.2 + k * 0.4 + rnd.uniform(-0.05, 0.05), z0 + 0.2 + rnd.uniform(0, 0.6)
			p.pal([p.quad("W8Palette", [(ax, top - 0.0005, az), (ax + 0.21, top - 0.0005, az), (ax + 0.21, top - 0.0005, az + 0.3),
				(ax, top - 0.0005, az + 0.3)], (0, 1, 0))], rnd.choice(["paper", "newspaper", "label_white"]), rnd)
		# A modesty strip of laminate on the public face, a book drop slot.
		p.box("W1Wood", (x0, G + 0.5, z0), (x1, G + 0.56, z0 + 0.02))
		p.pbox("black", (cx + 1.2, G + 0.62, z0 - 0.002), (cx + 1.6, G + 0.66, z0 + 0.02), rnd)
	else:
		# Built: brick faced with white tiles on the public front and both ends, a terrazzo top; the staff side as Q1.
		p.box("W8Skirting", (x0, G, z0), (x1, top - 0.04, z1 - 0.12))
		p.box("W1WoodPale", (x0, G + 0.05, z1 - 0.12), (x1, top - 0.04, z1 - 0.08))
		for k in range(10):
			dx0 = x0 + 0.06 + k * (L.COUNTER["w"] - 0.12) / 10
			dx1 = dx0 + (L.COUNTER["w"] - 0.12) / 10 - 0.02
			p.box("W1Wood", (dx0, G + 0.45, z1 - 0.08), (dx1, G + 0.76, z1 - 0.06))
		p.box("W1Terrazzo", (x0 - 0.04, top - 0.04, z0 - 0.04), (x1 + 0.04, top, z1 + 0.02))
		p.box("W1Iron", (x0, G, z0 - 0.002), (x1, G + 0.1, z0 + 0.01))
	counter_items(p, cx, cz, TOP, rnd)
	return export("counter_%s.glb" % kind, [p])


def chair_parts(p, rnd, seat_y=0.46, wood="W1Wood", back_z=0.21, legs="W1Iron"):
	"""A school wooden chair in its local frame (seat centre at (0, seat_y, 0), back toward +z)."""
	p.box(wood, (-0.22, seat_y - 0.03, -0.21), (0.22, seat_y, 0.21))
	for x in (-0.19, 0.19):
		for z in (-0.18, 0.18):
			p.box(legs, (x - 0.018, 0.0, z - 0.018), (x + 0.018, seat_y - 0.03, z + 0.018))
		p.box(legs, (x - 0.018, seat_y, back_z - 0.035), (x + 0.018, seat_y + 0.42, back_z - 0.005))
	p.box(wood, (-0.21, seat_y + 0.22, back_z - 0.04), (0.21, seat_y + 0.4, back_z - 0.015))
	p.box(legs, (-0.19, 0.12, -0.17), (0.19, 0.14, -0.15))


def build_librarian_chair():
	w1kit.reset()
	rnd = random.Random(26511)
	ax, ay, az = L.LIBRARIAN_CHAIR
	p = Part("LibrarianChair", Frame((ax, G, az), 0.0))
	seat = 0.46
	# Five-star base with castors, a gas column, a vinyl seat split at the front edge, a back (toward +z: she faced the counter).
	for k in range(5):
		a = math.radians(k * 72 + 10)
		p.beam2("W1Iron", (0, 0.07, 0), (math.cos(a) * 0.3, 0.05, math.sin(a) * 0.3), 0.04, 0.03)
		p.pal(p.cylinder("W8Palette", GP.B(p.f.p((math.cos(a) * 0.3, 0.025, math.sin(a) * 0.3))), 0.025, 0.03, axis="X", segments=8), "rubber", rnd)
	p.rod("W1Steel", [(0, 0.07, 0), (0, seat - 0.06, 0)], 0.025, sides=8)
	p.pbox("seat_vinyl", (-0.24, seat - 0.07, -0.23), (0.24, seat, 0.22), rnd)
	p.pbox("foam", (-0.1, seat - 0.005, -0.23), (0.05, seat + 0.002, -0.12), rnd)
	p.box("W1Steel", (-0.03, seat - 0.05, 0.18), (0.03, seat + 0.2, 0.22))
	p.pbox("seat_vinyl", (-0.22, seat + 0.15, 0.2), (0.22, seat + 0.62, 0.27), rnd)
	return export("librarian_chair.glb", [p])


# ------------------------------------------------------------------------------------------------ map board

def build_map(kind):
	w1kit.reset()
	rnd = random.Random(26512)
	b = L.MAP_BOARD
	x_wall = L.IN_W + INSET
	_, yc, zc = b["at"]
	hw, hh = b["w"] / 2, b["h"] / 2
	p = Part("Map" + kind.capitalize())
	pw, ph = b["paper"][0] / 2, b["paper"][1] / 2
	if kind == "print":
		# Aluminium frame 3.1 x 2.1, 4 cm deep; the print at 3 cm, glass at 3.5 cm.
		xf = x_wall + 0.04
		for lo, hi in (((x_wall, yc + hh - 0.05, zc - hw), (xf, yc + hh, zc + hw)), ((x_wall, yc - hh, zc - hw), (xf, yc - hh + 0.05, zc + hw)),
				((x_wall, yc - hh, zc - hw), (xf, yc + hh, zc - hw + 0.05)), ((x_wall, yc - hh, zc + hw - 0.05), (xf, yc + hh, zc + hw))):
			p.box("W1Alu", lo, hi)
		p.box("W1WoodPale", (x_wall, yc - hh + 0.05, zc - hw + 0.05), (x_wall + 0.02, yc + hh - 0.05, zc + hw - 0.05))
		face_x, mat = x_wall + 0.03, "W8MapPrint"
		p.quad("W2Glass", [(x_wall + 0.035, yc - hh + 0.05, zc + hw - 0.05), (x_wall + 0.035, yc - hh + 0.05, zc - hw + 0.05),
			(x_wall + 0.035, yc + hh - 0.05, zc - hw + 0.05), (x_wall + 0.035, yc + hh - 0.05, zc + hw - 0.05)], (1, 0, 0))
	else:
		# A plywood board 3.1 x 2.1 (2 cm) on two battens, the paper taped over it, red pins at the corners.
		p.box("W1WoodPale", (x_wall + 0.015, yc - hh, zc - hw), (x_wall + 0.035, yc + hh, zc + hw))
		for dz in (-1.2, 1.2):
			p.box("W1Wood", (x_wall, yc - hh + 0.1, zc + dz - 0.03), (x_wall + 0.015, yc + hh - 0.1, zc + dz + 0.03))
		face_x, mat = x_wall + 0.0365, "W8MapDrawn"
		for cz_, cy_ in ((zc - pw + 0.04, yc + ph - 0.04), (zc + pw - 0.04, yc + ph - 0.04), (zc - pw + 0.04, yc - ph + 0.04), (zc + pw - 0.04, yc - ph + 0.04)):
			p.pal(p.box("W8Palette", (face_x, cy_ - 0.01, cz_ - 0.01), (face_x + 0.012, cy_ + 0.01, cz_ + 0.01)), "stamp_red", rnd)
	# The paper: u from the viewer's left (+z) to right (-z), v from the top.
	p.quad(mat, [(face_x, yc - ph, zc + pw), (face_x, yc - ph, zc - pw), (face_x, yc + ph, zc - pw), (face_x, yc + ph, zc + pw)], (1, 0, 0),
		uv=[uv_img(0, 1), uv_img(1, 1), uv_img(1, 0), uv_img(0, 0)])
	return export("map_%s.glb" % kind, [p])


# ------------------------------------------------------------------------------------------------ shelves and books

def shelf_frame(p, kind, rnd, w=None, d=None, h=None, boards=None, double=False):
	"""A stack in its local frame (centre of the foot at the origin, open face toward -z, back at +z). Defaults: the PS1
	shelf (inside its colliders: sides x +-1.52, depth z -0.3..0.3, back 0.22..0.30, boards at 0.1 + 0.56 k, top 2.2)."""
	w = w or L.SHELF["w"] + 0.04
	d = d or L.SHELF["d"]
	h = h or L.SHELF["h"]
	boards = boards if boards is not None else L.SHELF["boards_y"]
	hw = w / 2
	z0, z1 = -d / 2, d / 2
	mat = "W8ShelfSteel" if kind == "steel" else "W8ShelfWood"
	t = 0.025 if kind == "steel" else 0.04
	for sx in (-hw, hw - t):
		p.box(mat, (sx, 0.0, z0), (sx + t, h, z1))
		if kind == "steel":
			# End panel's folded edge and a card holder with a call-number card on the aisle end.
			p.box(mat, (sx - 0.005 if sx < 0 else sx + t, 0.0, z0), (sx if sx < 0 else sx + t + 0.005, h, z0 + 0.03))
	if not double:
		p.box(mat if kind == "steel" else "W1WoodPale", (-hw + t, 0.0, z1 - 0.08), (hw - t, h, z1 - 0.06))
	else:
		p.box(mat, (-hw + t, 0.1, -0.01), (hw - t, h - 0.05, 0.01))
	p.box("W1Black" if kind == "steel" else mat, (-hw + t, 0.0, z0 + 0.03), (hw - t, boards[0] - L.SHELF["board_t"] / 2, z1 - 0.08))
	for by in boards:
		yb0, yb1 = by - L.SHELF["board_t"] / 2 + (0.02 if kind == "steel" else 0.0), by + L.SHELF["board_t"] / 2
		p.box(mat, (-hw + t, yb1 - (0.02 if kind == "steel" else 0.03), z0), (hw - t, yb1, z1 - 0.08))
		if kind == "steel":
			p.box(mat, (-hw + t, yb1 - 0.045, z0), (hw - t, yb1, z0 + 0.015))
			p.pbox("label_white", (-0.1, yb1 - 0.04, z0 - 0.003), (0.1, yb1 - 0.01, z0), rnd)
		else:
			p.box("W1Wood", (-hw + t, yb1 - 0.05, z0 - 0.015), (hw - t, yb1, z0 + 0.005))
	p.box(mat, (-hw, h - 0.03, z0 - (0.0 if kind == "steel" else 0.02)), (hw, h, z1))
	if kind == "wood":
		p.box("W1Wood", (-hw - 0.02, h - 0.08, z0 - 0.03), (hw + 0.02, h - 0.03, z0))


def book(p, x, y, z_front, wdt, hgt, dep, cell, rnd, lean=0.0, lie=False):
	"""One book standing on (x, y) with its spine at z_front facing -z; lean: degrees about z (toward -x/+x); lie: flat on
	its side (spine still to the aisle). UVs: spine -> its atlas cell, top -> page edges, sides -> the cell's middle."""
	col, row = cell % 16, cell // 16
	cu0, cu1 = col * 64 / 1024, (col + 1) * 64 / 1024
	cv0, cv1 = row * 256 / 1024, (row + 1) * 256 / 1024
	mu0, mu1 = cu0 + 0.4 * (cu1 - cu0), cu0 + 0.6 * (cu1 - cu0)
	if lie:
		# Flat: width along y (thickness), height along x.
		ex, ey = hgt, wdt
	else:
		ex, ey = wdt, hgt
	a = math.radians(lean)
	ca, sa = math.cos(a), math.sin(a)

	def P(lx, ly, lz):
		# Lean about the foot edge on the side it leans toward.
		pivot = (-ex / 2) if lean > 0 else (ex / 2)
		rx, ry = lx - pivot, ly
		return (x + pivot + rx * ca - ry * sa, y + rx * sa + ry * ca, lz)

	z0, z1 = z_front, z_front + dep
	hx = ex / 2
	# Spine (-z).
	if lie:
		uv = [uv_img(cu1, cv0), uv_img(cu1, cv1), uv_img(cu0, cv1), uv_img(cu0, cv0)]
		p.quad("W8Books", [P(-hx, 0, z0), P(hx, 0, z0), P(hx, ey, z0), P(-hx, ey, z0)], (0, 0, -1),
			uv=[uv_img(cu0, cv1), uv_img(cu0, cv0), uv_img(cu1, cv0), uv_img(cu1, cv1)])
	else:
		p.quad("W8Books", [P(-hx, 0, z0), P(hx, 0, z0), P(hx, ey, z0), P(-hx, ey, z0)], (0, 0, -1),
			uv=[uv_img(cu1, cv1), uv_img(cu0, cv1), uv_img(cu0, cv0), uv_img(cu1, cv0)])
	# Top: page edges (the leaning book's top shows them too).
	p.quad("W8Books", [P(-hx, ey, z0), P(hx, ey, z0), P(hx, ey, z1), P(-hx, ey, z1)], (0, 1, 0),
		uv=[uv_img(0.02, 0.76), uv_img(0.48, 0.76), uv_img(0.48, 0.99), uv_img(0.02, 0.99)])
	# Sides (covers).
	for sx, nx in ((-hx, -1), (hx, 1)):
		p.quad("W8Books", [P(sx, 0, z0), P(sx, 0, z1), P(sx, ey, z1), P(sx, ey, z0)], (nx, 0, 0),
			uv=[uv_img(mu0, cv1), uv_img(mu1, cv1), uv_img(mu1, cv0), uv_img(mu0, cv0)])


def fill_board(p, rnd, y, x0, x1, clear, mode, z_front=-0.285, depth_max=0.27):
	"""Books along one board from x0 to x1 (local x), standing on y, under `clear` of headroom."""
	x = x0 + rnd.uniform(0.0, 0.02)
	fill = {"full": 0.97, "sparse": 0.86, "tipped": 0.88}[mode]
	while x < x1 - 0.02:
		if rnd.random() > fill and mode != "full":
			x += rnd.uniform(0.05, 0.3)           # a gap
			# The books by the gap lean into it.
			continue
		wdt = rnd.choice([0.018, 0.022, 0.025, 0.03, 0.035, 0.04, 0.05, 0.06])
		hgt = min(rnd.uniform(0.19, 0.31), clear - 0.03)
		dep = min(rnd.uniform(0.14, 0.24), depth_max)
		cell = rnd.randrange(48)
		zf = z_front + rnd.uniform(0.0, 0.025) + (0.0 if mode == "full" else rnd.uniform(0, 0.03))
		lean = 0.0
		if mode != "full" and rnd.random() < 0.18:
			lean = -rnd.uniform(8, 22)
		if mode == "tipped" and rnd.random() < 0.25:
			# A run tipped over like dominoes (stays inside the stack).
			run = rnd.randint(4, 9)
			ang = -rnd.uniform(35, 62)
			for k in range(run):
				if x + hgt * math.sin(math.radians(-ang)) + wdt > x1 - 0.03:
					break
				book(p, x, y, zf, wdt, hgt, dep, rnd.randrange(48), rnd, lean=ang)
				x += wdt / math.cos(math.radians(ang)) * 1.02
			x += hgt * math.sin(math.radians(-ang)) + 0.02
			continue
		if mode != "full" and rnd.random() < 0.07 and x + hgt < x1 - 0.02:
			stack = rnd.randint(1, 4)
			yy = y
			for k in range(stack):
				t = rnd.choice([0.025, 0.03, 0.04])
				book(p, x + hgt / 2, yy, zf, t, hgt, dep, rnd.randrange(48), rnd, lie=True)
				yy += t
			x += hgt + 0.02
			continue
		if abs(lean) > 0:
			if x + hgt * math.sin(math.radians(abs(lean))) + wdt > x1 - 0.02:
				lean = 0.0
		book(p, x + wdt / 2, y, zf, wdt, hgt, dep, cell, rnd, lean=lean)
		x += wdt + (abs(math.sin(math.radians(lean))) * hgt if lean else 0.0) + rnd.uniform(0.0, 0.004)


def book_block(p, rnd, x0, x1, y, h, z_front, depth):
	"""A row of books as one block (the far look, and M3's mock stacks): its front repeats one atlas row of 16 spines every
	0.6 m (u wraps), its top shows the page edges."""
	row = rnd.randrange(3)
	v0, v1 = row * 0.25, (row + 1) * 0.25
	u = (x1 - x0) / 0.6
	p.quad("W8Books", [(x1, y, z_front), (x0, y, z_front), (x0, y + h, z_front), (x1, y + h, z_front)], (0, 0, -1),
		uv=[uv_img(0, v1), uv_img(u, v1), uv_img(u, v0), uv_img(0, v0)])
	p.quad("W8Books", [(x0, y + h, z_front), (x1, y + h, z_front), (x1, y + h, z_front + depth), (x0, y + h, z_front + depth)], (0, 1, 0),
		uv=[uv_img(0.02, 0.76), uv_img(0.48, 0.76), uv_img(0.48, 0.99), uv_img(0.02, 0.99)])


def books_for_shelf(p, rnd, mode, w=None, boards=None, top=None, z_front=-0.285, depth_max=0.27):
	w = w or L.SHELF["w"]
	boards = boards or L.SHELF["boards_y"]
	top = top or L.SHELF["h"]
	hw = w / 2 - 0.06
	for k, by in enumerate(boards):
		y = by + L.SHELF["board_t"] / 2
		nxt = boards[k + 1] - L.SHELF["board_t"] / 2 if k + 1 < len(boards) else top - 0.03
		if mode == "block":
			book_block(p, rnd, -hw, hw, y, min(nxt - y - 0.04, rnd.uniform(0.22, 0.3)), z_front + 0.01, depth_max)
		else:
			fill_board(p, rnd, y, -hw, hw, nxt - y, mode, z_front, depth_max)


def build_shelf(kind):
	w1kit.reset()
	p = Part("Shelf" + kind.capitalize(), LOCAL)
	shelf_frame(p, kind, random.Random(26513))
	return export("shelf_%s.glb" % kind, [p])


def build_books(mode):
	w1kit.reset()
	p = Part("Books" + mode.capitalize(), LOCAL)
	books_for_shelf(p, random.Random(26514 + len(mode)), mode)
	objs = export("books_%s.glb" % mode, [p])
	return objs


# ------------------------------------------------------------------------------------------------ reading tables

def table_parts(p, rnd, divider):
	w, d = L.TABLE["w"], L.TABLE["d"]
	top = L.TABLE["top"]
	p.box("W1Wood", (-w / 2, top - 0.04, -d / 2), (w / 2, top, d / 2))
	p.box("W1Wood", (-w / 2 + 0.06, top - 0.14, -d / 2 + 0.06), (w / 2 - 0.06, top - 0.04, -d / 2 + 0.09))
	p.box("W1Wood", (-w / 2 + 0.06, top - 0.14, d / 2 - 0.09), (w / 2 - 0.06, top - 0.04, d / 2 - 0.06))
	for x in (-w / 2 + 0.06, w / 2 - 0.12):
		for z in (-d / 2 + 0.06, d / 2 - 0.12):
			p.box("W1Wood", (x, 0.0, z), (x + 0.06, top - 0.04, z + 0.06))
		p.box("W1Wood", (x, 0.12, -d / 2 + 0.08), (x + 0.05, 0.16, d / 2 - 0.08))
	if divider:
		# A felt-covered divider along the table's middle and two banker's lamps (off) on it.
		p.box("W1Wood", (-w / 2 + 0.1, top, -0.015), (w / 2 - 0.1, top + 0.38, 0.015))
		p.pbox("felt_green", (-w / 2 + 0.13, top + 0.03, -0.017), (w / 2 - 0.13, top + 0.35, 0.017), rnd)
		for lx in (-0.75, 0.75):
			for side in (-1, 1):
				bz = side * 0.2
				p.pbox("brass", (lx - 0.07, top, bz - 0.05), (lx + 0.07, top + 0.02, bz + 0.05), rnd)
				p.rod("W1Brass", [(lx, top + 0.02, bz), (lx, top + 0.3, bz)], 0.008, sides=6)
				p.pbox("lamp_green", (lx - 0.17, top + 0.3, bz - 0.06), (lx + 0.17, top + 0.36, bz + 0.06), rnd)


def build_table(kind):
	w1kit.reset()
	rnd = random.Random(26515)
	p = Part("Table" + kind.upper(), LOCAL)
	table_parts(p, rnd, divider=(kind == "t2"))
	ch = Part("Chairs" + kind.upper(), LOCAL)
	for side in (-1, 1):
		cf = Frame((rnd.uniform(-0.25, 0.25), G, side * L.CHAIR_DZ + rnd.uniform(-0.1, 0.1)), (0.0 if side > 0 else 180.0) + rnd.uniform(-12, 12))
		cp = Part("Chair%d" % side, cf)
		chair_parts(cp, rnd)
		_merge_into(ch, cp)
	return export("table_%s.glb" % kind, [p, ch])


def _merge_into(dst, src):
	"""Copies src's bmesh faces into dst (materials by name)."""
	vmap = {}
	for v in src.bm.verts:
		vmap[v] = dst.bm.verts.new(v.co)
	for f in src.bm.faces:
		nf = dst.bm.faces.new([vmap[v] for v in f.verts])
		nf.material_index = dst.slot(src.slots[f.material_index])
		nf.smooth = f.smooth
		for la, lb in zip(f.loops, nf.loops):
			lb[dst.uv].uv = la[src.uv].uv
		if f.tag:
			nf.tag = True
			dst.painted.append(nf)
	src.bm.free()


def build_rule_book():
	w1kit.reset()
	p = Part("RuleBook", LOCAL)
	top = L.TABLE["top"]
	# The rule book (lane D's notebook in the HUD) as a closed hardcover lying where ReadingTable13/Book lay, 0.89 over the floor.
	p.box("W1Ledger", (-0.17, top, -0.12), (0.17, top + 0.045, 0.12))
	p.box("W1PageEdge", (-0.165, top + 0.004, -0.115), (0.165, top + 0.041, 0.118))
	p.box("W1LedgerSpine", (-0.172, top - 0.001, -0.125), (0.172, top + 0.046, -0.112))
	return export("rule_book.glb", [p])


# ------------------------------------------------------------------------------------------------ doors

def build_back_frame():
	w1kit.reset()
	p = Part("BackFrame")
	x0, x1 = L.DOOR_X
	zi, zo = L.IN_N, L.OUT_N
	head = G + L.DOOR_H
	# Lining of the opening (jambs, head) and casings 8 cm wide on both faces, a steel threshold.
	p.quad("W1Wood", [(x0, G, zi), (x0, head, zi), (x0, head, zo), (x0, G, zo)], (1, 0, 0))
	p.quad("W1Wood", [(x1, G, zi), (x1, G, zo), (x1, head, zo), (x1, head, zi)], (-1, 0, 0))
	p.quad("W1Wood", [(x0, head, zi), (x1, head, zi), (x1, head, zo), (x0, head, zo)], (0, -1, 0))
	for z_face, out in ((zi - INSET, -1), (zo + INSET, 1)):
		za, zb = sorted((z_face, z_face + out * 0.02))
		p.box("W1Wood", (x0 - 0.08, G, za), (x0, head + 0.08, zb))
		p.box("W1Wood", (x1, G, za), (x1 + 0.08, head + 0.08, zb))
		p.box("W1Wood", (x0 - 0.08, head, za), (x1 + 0.08, head + 0.08, zb))
	p.box("W1Steel", (x0, G, zi), (x1, G + 0.008, zo))
	# A stop bead against which the leaf closes (outside half of the lining).
	p.box("W1Wood", (x0, head - 0.03, 225.05), (x1, head, zo))
	return export("back_frame.glb", [p])


def build_back_leaf():
	"""In BackDoor/Hinge's frame: the leaf from x 0.01 to 1.93, 5 cm thick (z -0.025..0.025: open, it stands 2 cm clear of the
	jamb), y 0..2.4. Inside the library is -z. The lever where Hinge/Handle is (1.72, 1.1, -0.09)."""
	w1kit.reset()
	rnd = random.Random(26516)
	p = Part("BackLeaf", LOCAL)
	glass = Part("BackLeafGlass", LOCAL)
	x0, x1, t = 0.01, 1.93, 0.025
	h = 2.39
	# Two leaves' worth of boards in one (the opening is 2 m): stiles, rails, panels of boards, two vision panes.
	m = "W5DoorPaint"
	for lo, hi in (((x0, 0, -t), (x0 + 0.1, h, t)), ((x1 - 0.1, 0, -t), (x1, h, t)), ((x0 + 0.1, h - 0.12, -t), (x1 - 0.1, h, t)),
			((x0 + 0.1, 0, -t), (x1 - 0.1, 0.22, t)), ((x0 + 0.1, 1.0, -t), (x1 - 0.1, 1.12, t)), ((0.92, 0.22, -t), (1.02, h - 0.12, t))):
		p.box(m, lo, hi)
	for px0, px1 in ((x0 + 0.1, 0.92), (1.02, x1 - 0.1)):
		p.box(m, (px0, 0.22, -0.012), (px1, 1.0, 0.012))
		# Upper panel: boards with a wired-glass pane at eye height.
		gx0, gx1 = px0 + 0.22, px1 - 0.22
		gy0, gy1 = 1.35, 1.95
		for lo, hi in (((px0, 1.12, -0.012), (px1, gy0, 0.012)), ((px0, gy1, -0.012), (px1, h - 0.12, 0.012)), ((px0, gy0, -0.012), (gx0, gy1, 0.012)),
				((gx1, gy0, -0.012), (px1, gy1, 0.012))):
			p.box(m, lo, hi)
		for z, n in ((0.0, (0, 0, -1)), (0.001, (0, 0, 1))):
			glass.quad("W2Glass", [(gx0, gy0, z), (gx1, gy0, z), (gx1, gy1, z), (gx0, gy1, z)], n)
		for k in range(1, 6):
			xx = gx0 + (gx1 - gx0) * k / 6
			p.box("W1Iron", (xx - 0.001, gy0, -0.002), (xx + 0.001, gy1, 0.002))
		for k in range(1, 8):
			yy = gy0 + (gy1 - gy0) * k / 8
			p.box("W1Iron", (gx0, yy - 0.001, -0.002), (gx1, yy + 0.001, 0.002))
		for lo, hi in (((gx0 - 0.02, gy0 - 0.02, -0.02), (gx1 + 0.02, gy0, 0.02)), ((gx0 - 0.02, gy1, -0.02), (gx1 + 0.02, gy1 + 0.02, 0.02)),
				((gx0 - 0.02, gy0, -0.02), (gx0, gy1, 0.02)), ((gx1, gy0, -0.02), (gx1 + 0.02, gy1, 0.02))):
			p.box("W1Wood", lo, hi)
	# Hinges (three), the lever handle on both faces where Hinge/Handle is, a kick plate inside, a barrel bolt.
	for hy in (0.25, 1.2, 2.15):
		p.box("W1Steel", (-0.01, hy - 0.06, -0.03), (0.04, hy + 0.06, 0.03))
	for side in (-1, 1):
		zf = side * (t + 0.005)
		p.box("W1Steel", (1.68, 1.02, min(zf, zf + side * 0.008)), (1.76, 1.2, max(zf, zf + side * 0.008)))
		p.rod("W1Steel", [(1.72, 1.1, zf + side * 0.05), (1.6, 1.1, zf + side * 0.06)], 0.01, sides=6)
		p.rod("W1Steel", [(1.72, 1.1, zf), (1.72, 1.1, zf + side * 0.05)], 0.01, sides=6)
	p.box("W1Alu", (x0 + 0.1, 0.02, -t - 0.002), (x1 - 0.1, 0.25, -t))
	p.box("W1Iron", (1.5, 1.85, -t - 0.03), (1.75, 1.88, -t))
	# Old paper notice taped inside, scuffs low down outside from the zombies (mask-free: palette strips).
	p.pal([p.quad("W8Palette", [(0.3, 1.25, -t - 0.001), (0.6, 1.25, -t - 0.001), (0.6, 1.6, -t - 0.001), (0.3, 1.6, -t - 0.001)], (0, 0, -1))],
		"paper", rnd)
	return export("back_leaf.glb", [p, glass])


def build_front_door():
	w1kit.reset()
	rnd = random.Random(26517)
	p = Part("FrontDoor")
	glass = Part("FrontDoorGlass")
	x0, x1 = L.DOOR_X
	zi, zo = L.IN_S, L.OUT_S
	head = G + L.DOOR_H
	p.quad("W1Wood", [(x0, G, zo), (x0, head, zo), (x0, head, zi), (x0, G, zi)], (1, 0, 0))
	p.quad("W1Wood", [(x1, G, zi), (x1, head, zi), (x1, head, zo), (x1, G, zo)], (-1, 0, 0))
	p.quad("W1Wood", [(x0, head, zo), (x1, head, zo), (x1, head, zi), (x0, head, zi)], (0, -1, 0))
	for z_face, out in ((zi + INSET, 1), (zo - INSET, -1)):
		za, zb = sorted((z_face, z_face + out * 0.02))
		p.box("W1Wood", (x0 - 0.08, G, za), (x0, head + 0.08, zb))
		p.box("W1Wood", (x1, G, za), (x1 + 0.08, head + 0.08, zb))
		p.box("W1Wood", (x0 - 0.08, head, za), (x1 + 0.08, head + 0.08, zb))
	# Two glazed leaves shut (inside the FrontDoor collider z 194.94..195.06), a chain and padlock through the pulls inside.
	za, zb = 194.975, 195.025
	for lx0, lx1 in ((x0 + 0.02, 65.0), (65.0, x1 - 0.02)):
		for lo, hi in (((lx0, G, za), (lx0 + 0.1, head - 0.01, zb)), ((lx1 - 0.1, G, za), (lx1, head - 0.01, zb)),
				((lx0, G, za), (lx1, G + 0.3, zb)), ((lx0, head - 0.13, za), (lx1, head - 0.01, zb)), ((lx0, 1.05 + G, za), (lx1, 1.15 + G, zb))):
			p.box("W1Wood", lo, hi)
		for gy0, gy1 in ((G + 0.3, G + 1.05), (G + 1.15, head - 0.13)):
			for z, n in ((195.0, (0, 0, -1)), (195.001, (0, 0, 1))):
				glass.quad("W2Glass", [(lx0 + 0.1, gy0, z), (lx1 - 0.1, gy0, z), (lx1 - 0.1, gy1, z), (lx0 + 0.1, gy1, z)], n)
		for side in (-1, 1):
			xp = lx1 - 0.16 if lx0 < 65 else lx0 + 0.16
			p.rod("W1Steel", [(xp, G + 0.85, 195.0 + side * 0.03), (xp, G + 1.35, 195.0 + side * 0.03)], 0.012, sides=6)
	for k in range(9):
		p.rod("W1Iron", [(64.84 + k * 0.04, G + 1.12 + 0.02 * math.sin(k), 195.06), (64.86 + k * 0.04, G + 1.14 + 0.02 * math.cos(k), 195.065)], 0.008, sides=4)
	p.pbox("brass", (64.97, G + 1.0, 195.06), (65.05, G + 1.1, 195.09), rnd)
	return export("front_door.glb", [p, glass])


def build_barricade():
	w1kit.reset()
	rnd = random.Random(26518)
	bx, _, bz = L.BARRICADE["at"]
	t = Part("BarricadeTable", Frame((bx, G, bz), 0.0))
	# A heavy reading table the size of the PS1's (2.6 x 1.3, top 0.72..0.84) shoved against the doors.
	w, d, top = L.BARRICADE["w"], L.BARRICADE["d"], L.BARRICADE["top"]
	t.box("W1Wood", (-w / 2, top - 0.05, -d / 2), (w / 2, top, d / 2))
	for x in (-w / 2 + 0.05, w / 2 - 0.12):
		for z in (-d / 2 + 0.05, d / 2 - 0.12):
			t.box("W1Wood", (x, 0.0, z), (x + 0.07, top - 0.05, z + 0.07))
	t.box("W1Wood", (-w / 2 + 0.05, top - 0.16, -d / 2 + 0.05), (w / 2 - 0.05, top - 0.05, -d / 2 + 0.08))
	ch = Part("BarricadeChairs")
	# The three PS1 chairs (on the top at x 64.2, 65, 65.8) upside down on it, legs up, one tipped against the door.
	for i, cx in enumerate(L.BARRICADE["chairs_x"]):
		roll = math.radians(180.0 + rnd.uniform(-8, 8))
		cf = Frame((cx, G + top + 0.88, bz + rnd.uniform(-0.15, 0.15)), rnd.uniform(-20, 20) + 90 * (i % 2))
		cp = Part("BChair%d" % i, _RollFrame(cf, roll))
		chair_parts(cp, rnd, legs="W1Iron")
		_merge_into(ch, cp)
	return export("barricade.glb", [t, ch])


class _RollFrame(Frame):
	"""A frame turned upside down (roll about local x) before its own yaw and origin."""

	def __init__(self, inner, roll):
		self.inner = inner
		self.cr, self.sr = math.cos(roll), math.sin(roll)

	def _r(self, q):
		x, y, z = q
		return (x, y * self.cr - z * self.sr, y * self.sr + z * self.cr)

	def p(self, q):
		return self.inner.p(self._r(q))

	def n(self, q):
		return self.inner.n(self._r(q))


# ------------------------------------------------------------------------------------------------ facades

def build_facade(kind):
	w1kit.reset()
	rnd = random.Random(26519)
	wall_mat = "W8FacadeYellow" if kind == "e1" else "W8WashedStone"
	band_mat = "W8FacadeWhite" if kind == "e1" else "W8Concrete"
	parts = {k: Part(k) for k in ("Walls", "Bands", "Fins", "Frames", "Grilles", "FakeRooms", "DarkGlass", "Glass", "Roof", "Extras")}
	walls = parts["Walls"]
	top = L.PARAPET_TOP
	faces = [("front", (L.OUT_W, L.OUT_S), (L.OUT_E, L.OUT_S), (0, 0, -1)), ("east", (L.OUT_E, L.OUT_S), (L.OUT_E, L.OUT_N), (1, 0, 0)),
		("back", (L.OUT_E, L.OUT_N), (L.OUT_W, L.OUT_N), (0, 0, 1)), ("west", (L.OUT_W, L.OUT_N), (L.OUT_W, L.OUT_S), (-1, 0, 0))]
	plinth = 0.45
	for name, a, b, n in faces:
		holes = []
		if name in ("front", "back"):
			for k in range(3):
				for wx in L.WINDOWS_X:
					s0 = abs(wx - a[0])
					holes.append((s0 - 1.5, s0 + 1.5, L.LEVELS[k] + L.WINDOW["foot"], L.LEVELS[k] + L.WINDOW["head"]))
			s0 = abs(65.0 - a[0])
			holes.append((s0 - 1.0, s0 + 1.0, G - 1, G + L.DOOR_H))
		full = math.hypot(b[0] - a[0], b[1] - a[1])
		ss = sorted({0.0, full} | {max(0, min(full, h[0])) for h in holes} | {max(0, min(full, h[1])) for h in holes})
		ys = sorted({G, top, G + plinth} | {h[2] for h in holes if h[2] > G} | {h[3] for h in holes})
		made = []
		for i in range(len(ss) - 1):
			for j in range(len(ys) - 1):
				sm, ym = (ss[i] + ss[i + 1]) / 2, (ys[j] + ys[j + 1]) / 2
				if any(h[0] < sm < h[1] and h[2] < ym < h[3] for h in holes):
					continue
				P = lambda s, y: (a[0] + (b[0] - a[0]) * s / full, y, a[1] + (b[1] - a[1]) * s / full)  # noqa: E731
				m = "W8Concrete" if ym < G + plinth else wall_mat
				made.append(walls.quad(m, [P(ss[i], ys[j]), P(ss[i + 1], ys[j]), P(ss[i + 1], ys[j + 1]), P(ss[i], ys[j + 1])], n))
		walls.map_uv2(made, lambda q: L.wall_uv2(3, L.outer_s(_snap_ox(q[0]), _snap_oz(q[2])), q[1] - G))
		# Reveals of the windows and doors (to the wall's middle; the doors' are the frames').
		if name in ("front", "back"):
			out = -1 if name == "front" else 1
			zf = a[1]
			mid = zf - out * 0.11
			for k in range(3):
				for wx in L.WINDOWS_X:
					x0, x1 = wx - 1.5, wx + 1.5
					y0, y1 = L.LEVELS[k] + L.WINDOW["foot"], L.LEVELS[k] + L.WINDOW["head"]
					rv = [walls.quad(band_mat, [(x0, y1, zf), (x1, y1, zf), (x1, y1, mid), (x0, y1, mid)], (0, -1, 0)),
						walls.quad(band_mat, [(x0, y0, zf), (x0, y1, zf), (x0, y1, mid), (x0, y0, mid)], (1, 0, 0)),
						walls.quad(band_mat, [(x1, y0, zf), (x1, y1, zf), (x1, y1, mid), (x1, y0, mid)], (-1, 0, 0))]
					walls.map_uv2(rv, lambda q: (0.995, 0.995))
					# Sill (precast, 4 cm proud with a drip).
					za, zb = sorted((zf + out * 0.06, mid))
					parts["Bands"].box(band_mat, (x0 - 0.06, y0 - 0.06, za), (x1 + 0.06, y0, zb))
					# Aluminium frame, 3 sashes, glass; behind it the fake room or dark glass.
					za, zb = sorted((mid, mid + out * 0.04))
					for kk in range(4):
						xm = x0 + (x1 - x0) * kk / 3
						parts["Frames"].box("W1Alu", (xm - 0.025, y0, za), (xm + 0.025, y1, zb))
					for yy in (y0, y1 - 0.05):
						parts["Frames"].box("W1Alu", (x0, yy, za), (x1, yy + 0.05, zb))
					zg = mid + out * 0.015
					GP_quad_x(parts["Glass"], "W2Glass", x0, x1, y0, y1, zg, out)
					GP_quad_x(parts["DarkGlass"], "W7GlassDark", x0, x1, y0, y1, zg - out * 0.002, out)
					f = GP_quad_x(parts["FakeRooms"], "W7RoomClass", x0, x1, y0, y1, mid + out * 0.005, out)
					parts["FakeRooms"].map_uv2(f, lambda q, w=x1 - x0, h=y1 - y0: (w, h))
					if k == 0:
						# Ground floor grilles outside, in the reveal's mouth.
						zg2 = zf + out * 0.0
						gl = parts["Grilles"]
						for kk in range(1, 25):
							xb = x0 + (x1 - x0) * kk / 25
							gl.rod("W1Iron", [(xb, y0, zg2 - out * 0.03), (xb, y1, zg2 - out * 0.03)], 0.008, sides=4, cap=False)
						for yy in (y0 + 0.03, (y0 + y1) / 2, y1 - 0.03):
							za2, zb2 = sorted((zg2 - out * 0.045, zg2 - out * 0.015))
							gl.box("W1Iron", (x0, yy - 0.015, za2), (x1, yy + 0.015, zb2))
	# Bands at each floor's slab (0.3 high, 5 cm proud), the coping, the parapet's inside, the roof.
	bands = parts["Bands"]
	ring = [(L.OUT_W, L.OUT_E, L.OUT_S, L.OUT_S, "x", -1), (L.OUT_W, L.OUT_E, L.OUT_N, L.OUT_N, "x", 1),
		(L.OUT_S, L.OUT_N, L.OUT_W, L.OUT_W, "z", -1), (L.OUT_S, L.OUT_N, L.OUT_E, L.OUT_E, "z", 1)]
	for yb in [L.LEVELS[1] - 0.24, L.LEVELS[2] - 0.24, top - 0.12]:
		for a0, a1, plane, _, axis, out in ring:
			h0, h1 = (yb, yb + 0.3) if yb < top - 0.2 else (top - 0.12, top + 0.04)
			proud = 0.05 if yb < top - 0.2 else 0.06
			if axis == "x":
				za, zb = sorted((plane, plane + out * proud))
				bands.box(band_mat, (a0 - proud, h0, za), (a1 + proud, h1, zb))
			else:
				xa, xb = sorted((plane, plane + out * proud))
				bands.box(band_mat, (xa, h0, a0), (xb, h1, a1))
	roof = parts["Roof"]
	rt = L.ROOF_TOP + 0.002
	roof.quad("W8Concrete", [(L.IN_W, rt, L.IN_S), (L.IN_E, rt, L.IN_S), (L.IN_E, rt, L.IN_N), (L.IN_W, rt, L.IN_N)], (0, 1, 0))
	for (a, b, n) in (((L.IN_W, L.IN_S), (L.IN_E, L.IN_S), (0, 0, 1)), ((L.IN_E, L.IN_S), (L.IN_E, L.IN_N), (-1, 0, 0)),
			((L.IN_E, L.IN_N), (L.IN_W, L.IN_N), (0, 0, -1)), ((L.IN_W, L.IN_N), (L.IN_W, L.IN_S), (1, 0, 0))):
		roof.quad("W8Concrete", [(a[0], rt, a[1]), (b[0], rt, b[1]), (b[0], top, b[1]), (a[0], top, a[1])], n)
	roof.quad("W8Concrete", [(L.OUT_W, top, L.OUT_S), (L.OUT_W, top, L.OUT_N), (L.OUT_E, top, L.OUT_N), (L.OUT_E, top, L.OUT_S)], (0, 1, 0))
	# Two water tanks on a steel stand and a roof hatch box.
	ex = parts["Extras"]
	for tx in (78.0, 80.4):
		ex.rod("W6Stainless", [(tx, rt + 1.0, 220.0), (tx, rt + 2.4, 220.0)], 0.6, sides=16)
		for dx in (-0.45, 0.45):
			for dz in (-0.45, 0.45):
				ex.box("W1Iron", (tx + dx - 0.03, rt, 220 + dz - 0.03), (tx + dx + 0.03, rt + 1.0, 220 + dz + 0.03))
		ex.box("W1Iron", (tx - 0.55, rt + 0.95, 219.45), (tx + 0.55, rt + 1.0, 220.55))
	ex.box("W8Concrete", (80.0, rt, 202.0), (82.0, rt + 1.2, 204.0))
	# Downpipes (grey PVC) at the four corners on the east and west faces, inside 0.15 m.
	for x, z in ((L.OUT_W - 0.07, 195.6), (L.OUT_W - 0.07, 224.4), (L.OUT_E + 0.07, 195.6), (L.OUT_E + 0.07, 224.4)):
		ex.rod("W8Palette", [(x, G + 0.05, z), (x, top - 0.1, z)], 0.05, sides=8)
	ex.pal([f for f in ex.bm.faces if ex.slots[f.material_index] == "W8Palette"], "trolley_grey", rnd)
	# E1: concrete fins every metre over the long faces from the plinth to the coping, 0.12 x 0.45; a hood over the front door.
	# E2: no fins; the sign over the front door; the hood as E1.
	fins = parts["Fins"]
	if kind == "e1":
		for zf, out in ((L.OUT_S, -1), (L.OUT_N, 1)):
			x = L.OUT_W + 0.5
			while x < L.OUT_E - 0.3:
				if not (63.6 < x < 66.4):
					za, zb = sorted((zf, zf + out * 0.45))
					fins.box("W8Concrete", (x - 0.06, G + plinth, za), (x + 0.06, top - 0.12, zb))
				x += 1.0
	for zf, out in ((L.OUT_S, -1),):
		za, zb = sorted((zf, zf + out * 0.45))
		bands.box("W8Concrete", (63.4, G + 2.55, za), (66.6, G + 2.7, zb))
	if kind == "e2":
		sg = parts["Extras"]
		z = L.OUT_S - 0.03
		sg.box("W8Concrete", (62.9, G + 2.78, z - 0.02), (67.1, G + 3.48, L.OUT_S))
		sg.quad("W8Sign", [(67.0, G + 2.83, z - 0.021), (63.0, G + 2.83, z - 0.021), (63.0, G + 3.455, z - 0.021), (67.0, G + 3.455, z - 0.021)],
			(0, 0, -1), uv=[uv_img(0, 1), uv_img(1, 1), uv_img(1, 0), uv_img(0, 0)])
	return export("facade_%s.glb" % kind, list(parts.values()))


def GP_quad_x(part, mat, x0, x1, y0, y1, z, normal_z):
	if normal_z < 0:
		pts, uvs = [(x1, y0, z), (x0, y0, z), (x0, y1, z), (x1, y1, z)], [(0, 1), (1, 1), (1, 0), (0, 0)]
	else:
		pts, uvs = [(x0, y0, z), (x1, y0, z), (x1, y1, z), (x0, y1, z)], [(0, 1), (1, 1), (1, 0), (0, 0)]
	return [part.quad(mat, pts, (0, 0, normal_z), [uv_img(u, v) for u, v in uvs])]


def _snap_ox(x):
	for v in (L.OUT_W, L.OUT_E):
		if abs(x - v) < 0.02:
			return v
	return x


def _snap_oz(z):
	for v in (L.OUT_S, L.OUT_N):
		if abs(z - v) < 0.02:
			return v
	return z


# ------------------------------------------------------------------------------------------------ the ring of ground

def build_strip():
	w1kit.reset()
	ground, apron, paved, drains = Part("Verge"), Part("Apron"), Part("Paved"), Part("Drains")
	zx0, zx1, zz0, zz1 = L.ZONE
	a0x, a1x, a0z, a1z = L.OUT_W - L.APRON, L.OUT_E + L.APRON, L.OUT_S - L.APRON, L.OUT_N + L.APRON
	d0x, d1x, d0z, d1z = a0x - L.DRAIN, a1x + L.DRAIN, a0z - L.DRAIN, a1z + L.DRAIN
	# The forecourt in front of the main door (north): x 55..75 from the zone's edge to the drain.
	fx0, fx1 = 55.0, 75.0
	cells = []
	xs = sorted({zx0, zx1, d0x, d1x, fx0, fx1})
	zs = sorted({zz0, zz1, d0z, d1z})
	for xa, xb in zip(xs, xs[1:]):
		for za, zb in zip(zs, zs[1:]):
			mx, mz = (xa + xb) / 2, (za + zb) / 2
			if d0x < mx < d1x and d0z < mz < d1z:
				continue
			kind = "paved" if (fx0 < mx < fx1 and mz < d0z) else "verge"
			cells.append((kind, xa, xb, za, zb))
	for kind, xa, xb, za, zb in cells:
		part = paved if kind == "paved" else ground
		y = L.APRON_Y if kind == "paved" else L.GROUND_Y
		m = "W7Pavers" if kind == "paved" else "W7Verge"
		f = part.quad(m, [(xa, y, za), (xb, y, za), (xb, y, zb), (xa, y, zb)], (0, 1, 0))
		part.map_uv2([f], lambda q: L.campus_uv2(q[0], q[2]))
	# Apron ring (0.8 m) and the drain covers (0.3 m concrete slabs with slots) round it; the porch at the front door.
	for xa, xb, za, zb in ((a0x, a1x, a0z, L.OUT_S), (a0x, a1x, L.OUT_N, a1z), (a0x, L.OUT_W, L.OUT_S, L.OUT_N), (L.OUT_E, a1x, L.OUT_S, L.OUT_N)):
		f = apron.quad("W8Apron", [(xa, L.APRON_Y, za), (xb, L.APRON_Y, za), (xb, L.APRON_Y, zb), (xa, L.APRON_Y, zb)], (0, 1, 0))
		apron.map_uv2([f], lambda q: L.campus_uv2(q[0], q[2]))
	apron.box("W1Terrazzo", (62.6, L.APRON_Y, L.OUT_S - 1.6), (67.4, G + 0.0, L.OUT_S))
	for xa, xb, za, zb, along in ((d0x, d1x, d0z, a0z, "x"), (d0x, d1x, a1z, d1z, "x"), (d0x, a0x, a0z, a1z, "z"), (a1x, d1x, a0z, a1z, "z")):
		length = (xb - xa) if along == "x" else (zb - za)
		k = 0
		s = 0.0
		while s < length - 0.01:
			e = min(s + 0.6, length)
			if along == "x":
				lo, hi = (xa + s + 0.005, L.APRON_Y - 0.01, za), (xa + e - 0.005, L.APRON_Y + 0.002, zb)
			else:
				lo, hi = (xa, L.APRON_Y - 0.01, za + s + 0.005), (xb, L.APRON_Y + 0.002, za + e - 0.005)
			drains.box("W1Concrete", lo, hi)
			s = e
			k += 1
		if along == "x":
			drains.quad("W6Plenum", [(xa, L.APRON_Y - 0.012, za), (xb, L.APRON_Y - 0.012, za), (xb, L.APRON_Y - 0.012, zb), (xa, L.APRON_Y - 0.012, zb)], (0, 1, 0))
		else:
			drains.quad("W6Plenum", [(xa, L.APRON_Y - 0.012, za), (xb, L.APRON_Y - 0.012, za), (xb, L.APRON_Y - 0.012, zb), (xa, L.APRON_Y - 0.012, zb)], (0, 1, 0))
	return export("strip.glb", [ground, apron, paved, drains])


# ------------------------------------------------------------------------------------------------ fill options, mess

def fill_piece(dst, piece, rnd):
	"""One FILL piece's geometry in world space (its box on the floor, the long side along the wall)."""
	x0, x1, z0, z1 = piece["box"]
	y = L.LEVELS[piece["level"]]
	h = piece["height"]
	kind = piece["kind"]
	cx, cz = (x0 + x1) / 2, (z0 + z1) / 2
	wx, wz = x1 - x0, z1 - z0
	along_x = wx >= wz
	length, depth = (wx, wz) if along_x else (wz, wx)
	# Which way the open face looks: away from the nearest wall.
	if along_x:
		yaw = 0.0 if cz > (L.IN_S + L.IN_N) / 2 else 180.0
	else:
		yaw = 90.0 if cx > (L.IN_W + L.IN_E) / 2 else -90.0
	yaw = piece.get("yaw", yaw) if kind == "catalogue" else yaw
	fr = Frame((cx, y, cz), yaw)
	p = Part("Piece", fr)
	if kind in ("wall_shelf", "wall_shelf_wood", "low_shelf"):
		boards = [0.1, 0.5] if kind == "low_shelf" else [0.1, 0.55, 1.0, 1.45, 1.9]
		top = h
		shelf_frame(p, "wood" if kind == "wall_shelf_wood" else "steel", rnd, w=length, d=depth, h=h, boards=boards)
		books_for_shelf(p, rnd, rnd.choice(["full", "sparse"]) if kind != "wall_shelf_wood" else "sparse", w=length, boards=boards, top=top,
			z_front=-depth / 2 + 0.015, depth_max=depth - 0.1)
	elif kind == "stack":
		for side in (-1, 1):
			q = Part("Side", Frame(fr.p((0, 0, side * depth / 4)), yaw + (0 if side < 0 else 180)))
			shelf_frame(q, "steel", rnd, w=length, d=depth / 2, h=h, boards=[0.1, 0.55, 1.0, 1.45, 1.9])
			books_for_shelf(q, rnd, "block", w=length, boards=[0.1, 0.55, 1.0, 1.45, 1.9], top=h, z_front=-depth / 4 + 0.01, depth_max=depth / 2 - 0.06)
			_merge_into(p, q)
	elif kind == "catalogue":
		# A card catalogue: a wooden cabinet of 6 x 6 small drawers with brass label frames, on a plinth.
		p.box("W1Wood", (-length / 2, 0.0, -depth / 2), (length / 2, h, depth / 2))
		for r in range(6):
			for c in range(6):
				dx0 = -length / 2 + 0.05 + c * (length - 0.1) / 6
				dy0 = 0.25 + r * (h - 0.3) / 6
				p.box("W1WoodPale", (dx0 + 0.008, dy0 + 0.008, -depth / 2 - 0.012), (dx0 + (length - 0.1) / 6 - 0.008, dy0 + (h - 0.3) / 6 - 0.008, -depth / 2))
				p.pbox("brass", (dx0 + 0.05, dy0 + 0.1, -depth / 2 - 0.016), (dx0 + 0.13, dy0 + 0.13, -depth / 2 - 0.012), rnd)
	elif kind == "trolley":
		p.pbox("trolley_grey", (-length / 2, 0.15, -depth / 2), (length / 2, 0.17, depth / 2), rnd)
		p.pbox("trolley_grey", (-length / 2, 0.55, -depth / 2), (length / 2, 0.57, depth / 2), rnd)
		for x in (-length / 2, length / 2 - 0.03):
			p.pbox("trolley_grey", (x, 0.1, -depth / 2), (x + 0.03, h, depth / 2), rnd)
		for x in (-length / 2 + 0.05, length / 2 - 0.05):
			for z in (-depth / 2 + 0.05, depth / 2 - 0.05):
				p.pal(p.cylinder("W8Palette", GP.B(fr.p((x, 0.05, z))), 0.05, 0.03, axis="X", segments=8), "rubber", rnd)
		fill_board(p, rnd, 0.17, -length / 2 + 0.04, length / 2 - 0.04, 0.36, "sparse", z_front=-depth / 2 + 0.02, depth_max=depth - 0.04)
		fill_board(p, rnd, 0.57, -length / 2 + 0.04, length / 2 - 0.04, h - 0.6, "tipped", z_front=-depth / 2 + 0.02, depth_max=depth - 0.04)
	elif kind == "news_table":
		# A sloping newspaper desk: two lecterns back to back, papers on wooden rods.
		p.box("W1Wood", (-length / 2, 0.0, -0.05), (length / 2, 0.8, 0.05))
		for side in (-1, 1):
			p.beam2("W1Wood", (-length / 2, 0.8, side * 0.05), (length / 2, 0.8, side * 0.05), 0.04, 0.04)
			for k in range(3):
				x = -length / 2 + 0.35 + k * (length - 0.7) / 2
				a = (x - 0.3, 0.98, side * 0.02)
				b = (x + 0.3, 0.98, side * 0.02)
				p.rod("W1Wood", [a, b], 0.01, sides=6)
				pf = [p.quad("W8Palette", [(x - 0.3, 0.98, side * 0.03), (x + 0.3, 0.98, side * 0.03), (x + 0.3, 0.55, side * (depth / 2 - 0.05)),
					(x - 0.3, 0.55, side * (depth / 2 - 0.05))], (0, 0.6, side))]
				p.pal(pf, "newspaper", rnd)
			p.box("W1Wood", (-length / 2, 0.5, side * depth / 2 - 0.03 if side > 0 else -depth / 2), (length / 2, 0.55, side * depth / 2 if side > 0 else -depth / 2 + 0.03))
	elif kind == "boxes":
		yy = 0.0
		layers = max(1, int(h / 0.32))
		for k in range(layers):
			for bx0 in (-length / 2, 0.02):
				w_ = length / 2 - 0.03
				jitter = rnd.uniform(-0.04, 0.04)
				p.pbox("cardboard", (bx0 + jitter, yy, -depth / 2 + 0.03), (bx0 + jitter + w_, yy + 0.3, depth / 2 - 0.03), rnd)
				p.pbox("tape", (bx0 + jitter + w_ / 2 - 0.03, yy + 0.3, -depth / 2 + 0.03), (bx0 + jitter + w_ / 2 + 0.03, yy + 0.302, depth / 2 - 0.03), rnd)
			yy += 0.31
	elif kind == "plant":
		p.pal(p.cylinder("W8Palette", GP.B(fr.p((0, 0.2, 0))), 0.22, 0.4, axis="Z", segments=12, radius2=0.26), "pot_terracotta", rnd)
		p.pal(p.cylinder("W8Palette", GP.B(fr.p((0, 0.39, 0))), 0.24, 0.02, axis="Z", segments=12), "soil", rnd)
		for k in range(7):
			a = rnd.uniform(0, math.tau)
			ln = rnd.uniform(0.5, 1.0)
			end = (math.cos(a) * 0.25 * ln, 0.4 + ln, math.sin(a) * 0.25 * ln)
			p.rod("W8Palette", [(0, 0.4, 0), end], 0.012, sides=4)
			for j in range(3):
				t = rnd.uniform(0.4, 1.0)
				q = (end[0] * t, 0.4 + (end[1] - 0.4) * t, end[2] * t)
				p.pal([p.quad("W8Palette", [q, (q[0] + 0.08, q[1] - 0.12, q[2] + 0.02), (q[0] + 0.03, q[1] - 0.2, q[2] - 0.03)], (0.3, 0.2, 1))],
					"leaf_dry", rnd)
		p.pal([f for f in p.bm.faces if not f.tag], "plant_dead", rnd)
	elif kind == "sheeted":
		p.box("W1Wood", (-length / 2, 0.0, -depth / 2), (length / 2, h - 0.05, depth / 2))
		p.pbox("dust_sheet", (-length / 2 - 0.04, h - 0.05, -depth / 2 - 0.04), (length / 2 + 0.04, h, depth / 2 + 0.04), rnd)
		for side in (-1, 1):
			p.pal([p.quad("W8Palette", [(-length / 2 - 0.04, h, side * (depth / 2 + 0.04)), (length / 2 + 0.04, h, side * (depth / 2 + 0.04)),
				(length / 2 + 0.06, 0.3, side * (depth / 2 + 0.07)), (-length / 2 - 0.06, 0.4, side * (depth / 2 + 0.07))], (0, 0, side))], "dust_sheet", rnd)
	_merge_into(dst, p)


def build_fill(key):
	w1kit.reset()
	rnd = random.Random(26520 + len(key))
	dsts = {}
	for piece in L.FILL[key]:
		name = "Fill%s_F%d" % (key.upper(), piece["level"] + 1)
		dst = dsts.setdefault(name, Part(name))
		fill_piece(dst, piece, rnd)
	return export("fill_%s.glb" % key, list(dsts.values()))


def build_mess():
	"""Mess (visual only, no piece over 3 cm on a walkway): fallen books in front of some shelves (not under Shelf2_12,
	ScareShelf3F: the scare's result is not laid out), papers on the floors, a fallen ceiling panel, a chair on its side
	off the walkways (floors 2 and 3)."""
	w1kit.reset()
	rnd = random.Random(26521)
	parts = {}
	for level in range(3):
		y = L.LEVELS[level]
		p = parts.setdefault(level, Part("Mess_F%d" % (level + 1)))
		for sx in L.SHELF_X:
			if level == 2 and sx == 57.0:
				continue
			sz = L.SHELF_Z[level]
			for k in range(rnd.randint(3, 9)):
				bx = sx + rnd.uniform(-1.3, 1.3)
				bz = sz - 0.45 - rnd.uniform(0.0, 0.7)
				fr = Frame((bx, y, bz), rnd.uniform(0, 360))
				q = Part("B", fr)
				book(q, 0.0, 0.0, -0.1, rnd.choice([0.025, 0.03, 0.04]), rnd.uniform(0.2, 0.28), rnd.uniform(0.15, 0.22), rnd.randrange(48), rnd, lie=True)
				_merge_into(p, q)
		for k in range(14):
			px, pz = rnd.uniform(46, 84), rnd.uniform(196, 224)
			if level > 0 and L.WELL[0] - 0.3 < px < L.WELL[1] and L.WELL[2] - 0.3 < pz < L.WELL[3]:
				continue
			a = rnd.uniform(0, math.tau)
			c, s = math.cos(a), math.sin(a)
			pts = [(px + c * dx - s * dz, y + 0.004, pz + s * dx + c * dz) for dx, dz in ((-0.105, -0.15), (0.105, -0.15), (0.105, 0.15), (-0.105, 0.15))]
			p.pal([p.quad("W8Palette", pts, (0, 1, 0))], rnd.choice(["paper", "newspaper", "label_white"]), rnd)
		if level > 0:
			cf = Frame((48.5 + level * 2, y + 0.24, 199.0 + level), 30.0 * level)
			cp = Part("C", _RollFrame(cf, math.radians(90)))
			chair_parts(cp, rnd)
			_merge_into(p, cp)
		# A fallen ceiling panel (C2) by the stairs' side.
		p.pal(p.box("W8Palette", (70.4, y + 0.002, 205.2), (71.0, y + 0.017, 205.8)), "paper", rnd)
	return export("mess.glb", list(parts.values()))


# ------------------------------------------------------------------------------------------------ main

def main():
	argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	jobs = {"shell": lambda: [build_shell(k, random.Random(26500 + k)) for k in range(3)], "stairs": build_stairs,
		"counter": lambda: [build_counter("q1"), build_counter("q2")], "chair": build_librarian_chair,
		"map": lambda: [build_map("print"), build_map("drawn")], "shelf": lambda: [build_shelf("steel"), build_shelf("wood")],
		"books": lambda: [build_books(m) for m in ("full", "sparse", "tipped")], "table": lambda: [build_table("t1"), build_table("t2")],
		"rule_book": build_rule_book, "back": lambda: [build_back_frame(), build_back_leaf()],
		"front": lambda: [build_front_door(), build_barricade()], "facade": lambda: [build_facade("e1"), build_facade("e2")],
		"strip": build_strip, "fill": lambda: [build_fill("m2"), build_fill("m3")], "mess": build_mess}
	for name in (argv or list(jobs)):
		jobs[name]()


if __name__ == "__main__":
	main()
