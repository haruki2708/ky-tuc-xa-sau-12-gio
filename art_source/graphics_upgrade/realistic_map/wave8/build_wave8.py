"""T-265 round 2 (D-185): the library's realistic layer, the owner's picks (card section 1). Blender 5.2.2, bmesh only, no
add-on, no Tripo; it reuses the pilot's kit (build_wave8_pilot.py) and wave8_layout.FINAL. World pieces in Godot world
space with the glb origin at Godot (0, G, 0); the back door's leaf is local to BackDoor/Hinge.

  shell_f1|f2|f3.glb   one floor's inside (F1: cream ceramic, pale yellow walls over a ceramic skirting; floor 3 bare
                       cement), sills, the windows seen from inside (dark glass, bars, faded curtains: wave8_layout curtains
                       per window, the same ones the facade shows from outside), C2 ceiling (60 x 60 stained panels, a few
                       missing), the battens (lit where the six lights are), the well's slab edges
  stairs.glb           both flights and their balustrades (inside RailCollision*), and the new railings on the well's slab
                       edges (WellRail; colliders Real/Added/WellRail_*): the west edge on floors 2 and 3, and round 3's
                       (card 1.14, D-186) east-slot ends on floors 2 and 3 and floor 3's south edge
  counter_q1.glb, librarian_chair.glb, rule_book.glb (local), back_frame.glb, back_leaf.glb (local), front_door.glb,
  barricade.glb        as the pilot (Q1; the chair upright, its seat 0.46 m)
  map_print.glb        the printed map in its aluminium frame under a matt glass (less glare under the torch)
  tables.glb           the three T1 reading tables and their six chairs, the rule book where ReadingTable13/Book lay
  shelves_f1|f2.glb, shelves_f3n|f3s.glb   every stack of a floor (the nine PS1 shelves' new stacks and FINAL's wall shelves,
                       low shelves and double-faced rows): frames merged (Frames: steel enamel, its backs painted sheet with
                       stiffeners and folds; FramesWood on floor 3), books per cluster as near meshes (Books_<cluster>: one
                       quad per spine from the 48-spine atlas, page tops) and far ones (BooksFar_<cluster>: one block per
                       board); library_real.gd sets their draw ranges
  fill_f1|f2|f3.glb    FINAL's loose pieces (catalogues, trolleys, newspaper desks, boxes, dead plants, a sheeted cabinet)
                       and the mess (Mess: books lying in front of the stacks, papers, fallen ceiling panels under the
                       missing ones; nothing within 2 m of floor 3's scare points and their shelves)
  facade.glb           E1: lime yellow walls, whitewashed bands, bare concrete fins over the long faces, the door hood; every
                       window dark glass with the curtains behind it (CurtainGlass), the east and west faces' windows outside
                       only (the walls inside stay plain), ground-floor grilles, parapet, roof, tanks, downpipes
  strip.glb            the ring round the library as the pilot (aprons, covered drains, forecourt, porch, verge)
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave8/build_wave8.py [-- name ...]
"""
import math
from pathlib import Path
import random
import sys

import bpy  # noqa: F401

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE))
import build_wave8_pilot as P  # noqa: E402  (the pilot's kit; its main is guarded)

L, GP, w1kit = P.L, P.GP, P.w1kit
Frame, Part, WORLD, LOCAL = P.Frame, P.Part, P.WORLD, P.LOCAL
G = L.G
INSET = P.INSET
GP.PREVIEW.update({"W8ShelfBack": ((0.36, 0.37, 0.36), 0.5)})
CURTAIN_MATS = {"curtain_beige": "W8CurtainBeige", "curtain_green": "W8CurtainGreen", "curtain_blue": "W8CurtainBlue"}
NEAR_SPLIT = {2: ("f3n", lambda p: p["box"][2] >= 209.0), 3: ("f3s", lambda p: p["box"][2] < 209.0)}


def export(name, parts):
	return P.export(name, parts)


# ------------------------------------------------------------------------------------------------ shared choices

def curtain(level, wall, wx):
	"""One window's curtains (colour, how far each side is drawn), the same seen from inside and outside. wall: "S", "N"
	(front, back), "E", "W" (outside only: drawn shut)."""
	rnd = random.Random("%d%s%d" % (level, wall, int(wx * 10)))
	col = rnd.choice(["curtain_beige", "curtain_green", "curtain_blue", "curtain_beige"])
	if wall in ("E", "W"):
		return col, 1.0
	return col, rnd.uniform(0.25, 0.6)


def missing_panels(level):
	"""Ceiling panels missing on a floor (x, z of the panel's corner on the 0.6 m grid), clear of the well and the battens."""
	rnd = random.Random(26540 + level)
	out = []
	while len(out) < 6:
		x = 47.5 + rnd.randrange(0, 60) * 0.6
		z = 196.5 + rnd.randrange(0, 45) * 0.6
		if x + 0.6 > L.IN_E - 0.3 or z + 0.6 > L.IN_N - 0.3:
			continue
		if L.WELL[0] - 0.8 < x < L.WELL[1] and L.WELL[2] - 0.8 < z < L.WELL[3]:
			continue
		if any(abs(x + 0.3 - bx) < 1.0 and abs(z + 0.3 - bz) < 0.6 for bx in L.LIGHTS_X for bz in (201.0, 211.0, 221.0)):
			continue
		if any(abs(x - ox) < 1.5 and abs(z - oz) < 1.5 for ox, oz in out):
			continue
		out.append((round(x, 2), round(z, 2)))
	return out


# ------------------------------------------------------------------------------------------------ shells

def curtain_folds(part, x0, x1, y0, y1, z, inward, col, rnd, folds_per_m=7):
	"""A curtain hanging x0..x1 at plane z (folds stepping toward the room by `inward`), both faces (seen from in and out)."""
	n = max(2, int((x1 - x0) * folds_per_m))
	pts = [(x0 + (x1 - x0) * k / n, z + inward * (0.025 if k % 2 else 0.0)) for k in range(n + 1)]
	faces = []
	for pa, pb in zip(pts, pts[1:]):
		faces.append(part.quad("W8Palette", [(pa[0], y0, pa[1]), (pb[0], y0, pb[1]), (pb[0], y1, pb[1]), (pa[0], y1, pa[1])], (0, 0, inward)))
		faces.append(part.quad("W8Palette", [(pb[0], y0, pb[1]), (pa[0], y0, pa[1]), (pa[0], y1, pa[1]), (pb[0], y1, pb[1])], (0, 0, -inward)))
	part.pal(faces, col, rnd)


def window_inside(win, sills, x, level, wall_z, inward, rnd):
	"""The pilot's option 1 (dark glass in an aluminium frame, bars in the reveal, faded curtains drawn part way), the
	curtains from curtain()."""
	y_floor = L.LEVELS[level]
	x0, x1 = x - L.WINDOW["w"] / 2, x + L.WINDOW["w"] / 2
	y0, y1 = y_floor + L.WINDOW["foot"], y_floor + L.WINDOW["head"]
	mid = wall_z - inward * 0.11
	n = (0, 0, inward)
	lo_z, hi_z = sorted((mid, wall_z + inward * 0.05))
	sills.box("W1Terrazzo", (x0 - 0.04, y0 - 0.04, lo_z), (x1 + 0.04, y0, hi_z))
	win.quad("W7GlassDark", [(x0, y0, mid + inward * 0.002), (x1, y0, mid + inward * 0.002), (x1, y1, mid + inward * 0.002),
		(x0, y1, mid + inward * 0.002)], n)
	za, zb = sorted((mid + inward * 0.002, mid + inward * 0.04))
	for k in range(4):
		xm = x0 + (x1 - x0) * k / 3
		win.box("W1Alu", (xm - 0.025, y0, za), (xm + 0.025, y1, zb))
	for yy in (y0, y1 - 0.05):
		win.box("W1Alu", (x0, yy, za), (x1, yy + 0.05, zb))
	zb_ = mid + inward * 0.07
	for k in range(1, 24):
		xb = x0 + (x1 - x0) * k / 24
		win.rod("W1Iron", [(xb, y0 + 0.01, zb_), (xb, y1 - 0.01, zb_)], 0.007, sides=4, cap=False)
	for yy in (y0 + 0.05, (y0 + y1) / 2, y1 - 0.05):
		za2, zb2 = sorted((zb_ - 0.01, zb_ + 0.01))
		win.box("W1Iron", (x0, yy - 0.015, za2), (x1, yy + 0.015, zb2))
	col, cover = curtain(level, "S" if inward > 0 else "N", x)
	zc = wall_z + inward * 0.03
	rod_lo, rod_hi = sorted((wall_z + inward * 0.01, wall_z + inward * 0.05))
	win.pbox("chrome", (x0 - 0.15, y1 + 0.08, rod_lo), (x1 + 0.15, y1 + 0.1, rod_hi), rnd)
	w = (x1 - x0 + 0.3) * cover * 0.5
	for xa in (x0 - 0.15, x1 + 0.15 - w):
		curtain_folds(win, xa, xa + w, y0 - 0.15, y1 + 0.08, zc, inward, col, rnd)


def build_shell(level):
	w1kit.reset()
	rnd = random.Random(26500 + level)
	y = L.LEVELS[level]
	ceil = L.CEILING[level]
	parts = {k: Part(k) for k in ("Floor", "Walls", "Sills", "Windows", "Ceiling", "Battens", "WellEdge")}
	rects = [(L.IN_W, L.IN_E, L.IN_S, L.IN_N)] if level == 0 else [(L.IN_W, L.WELL[0], L.IN_S, L.IN_N),
		(L.WELL[0], L.IN_E, L.IN_S, L.WELL[2]), (L.WELL[0], L.IN_E, L.WELL[3], L.IN_N)]
	m = "W8FloorCement" if level == 2 else "W8FloorCeramic"
	faces = [parts["Floor"].quad(m, [(x0, y + 0.002, z0), (x1, y + 0.002, z0), (x1, y + 0.002, z1), (x0, y + 0.002, z1)], (0, 1, 0))
		for x0, x1, z0, z1 in rects]
	parts["Floor"].map_uv2(faces, lambda q: L.floor_uv2(level, q[0], q[2]))
	win_holes = [(wx - 1.5, wx + 1.5, y + L.WINDOW["foot"], y + L.WINDOW["head"]) for wx in L.WINDOWS_X]
	door = (L.DOOR_X[0], L.DOOR_X[1], y - 1.0, y + L.DOOR_H)
	front_holes = [(h[0] - L.IN_W, h[1] - L.IN_W, h[2], h[3]) for h in win_holes]
	back_holes = [(L.IN_E - h[1], L.IN_E - h[0], h[2], h[3]) for h in win_holes]
	if level == 0:
		front_holes.append((door[0] - L.IN_W, door[1] - L.IN_W, door[2], door[3]))
		back_holes.append((L.IN_E - door[1], L.IN_E - door[0], door[2], door[3]))
	p = parts["Walls"]
	lo, hi, split = "W8Skirting", "W8WallYellow", P.SKIRT
	zf, zb = L.IN_S + INSET, L.IN_N - INSET
	xw, xe = L.IN_W + INSET, L.IN_E - INSET
	P.wall_run(p, lo, hi, (L.IN_W, zf), (L.IN_E, zf), y, ceil, (0, 0, 1), front_holes, level, split)
	P.wall_run(p, lo, hi, (xe, L.IN_S), (xe, L.IN_N), y, ceil, (-1, 0, 0), [], level, split)
	P.wall_run(p, lo, hi, (L.IN_E, zb), (L.IN_W, zb), y, ceil, (0, 0, -1), back_holes, level, split)
	P.wall_run(p, lo, hi, (xw, L.IN_N), (xw, L.IN_S), y, ceil, (1, 0, 0), [], level, split)
	for wx in L.WINDOWS_X:
		for wall_z, inward in ((L.IN_S, 1), (L.IN_N, -1)):
			mid = wall_z - inward * 0.11
			x0, x1 = wx - 1.5, wx + 1.5
			y0, y1 = y + L.WINDOW["foot"], y + L.WINDOW["head"]
			za, zb_ = wall_z + inward * INSET, mid
			p.quad(hi, [(x0, y1, za), (x1, y1, za), (x1, y1, zb_), (x0, y1, zb_)], (0, -1, 0))
			p.quad(hi, [(x0, y0, za), (x0, y1, za), (x0, y1, zb_), (x0, y0, zb_)], (1, 0, 0))
			p.quad(hi, [(x1, y0, za), (x1, y1, za), (x1, y1, zb_), (x1, y0, zb_)], (-1, 0, 0))
	yc = y + split
	for (a, b, axis, plane, inward) in ((L.IN_W, L.IN_E, "x", L.IN_S, 1), (L.IN_W, L.IN_E, "x", L.IN_N, -1), (L.IN_S, L.IN_N, "z", L.IN_W, 1),
			(L.IN_S, L.IN_N, "z", L.IN_E, -1)):
		segs = [(a, door[0]), (door[1], b)] if level == 0 and axis == "x" else [(a, b)]
		for s0, s1 in segs:
			if axis == "x":
				za, zb_ = sorted((plane, plane + inward * (INSET + 0.015)))
				p.box(lo, (s0, yc - 0.02, za), (s1, yc + 0.015, zb_))
			else:
				xa, xb = sorted((plane, plane + inward * (INSET + 0.015)))
				p.box(lo, (xa, yc - 0.02, s0), (xb, yc + 0.015, s1))
	for wx in L.WINDOWS_X:
		for wall_z, inward in ((L.IN_S, 1), (L.IN_N, -1)):
			window_inside(parts["Windows"], parts["Sills"], wx, level, wall_z, inward, rnd)
	# C2: panels at 2.95 m (floor 3: 6 cm under the roof's underside), the missing ones dark (the plenum behind).
	ph = min(y + 2.95, ceil - 0.05)
	cp = parts["Ceiling"]
	crects = [(L.IN_W, L.IN_E, L.IN_S, L.IN_N)] if level == 2 else [(L.IN_W, L.WELL[0], L.IN_S, L.IN_N), (L.WELL[0], L.IN_E, L.IN_S, L.WELL[2]),
		(L.WELL[0], L.IN_E, L.WELL[3], L.IN_N)]
	for x0, x1, z0, z1 in crects:
		f = cp.quad("W8CeilingPanel", [(x0, ph, z0), (x1, ph, z0), (x1, ph, z1), (x0, ph, z1)], (0, -1, 0))
		cp.map_uv2([f], lambda q: L.floor_uv2(level, q[0], q[2]))
	for mx, mz in missing_panels(level):
		cp.quad("W6Plenum", [(mx, ph - 0.002, mz), (mx + 0.6, ph - 0.002, mz), (mx + 0.6, ph - 0.002, mz + 0.6), (mx, ph - 0.002, mz + 0.6)], (0, -1, 0))
	if level < 2:
		for (a, b), plane, axis, inward in (((L.WELL[0], L.WELL[1]), L.WELL[2], "x", 1), ((L.WELL[0], L.WELL[1]), L.WELL[3], "x", -1),
				((L.WELL[2], L.WELL[3]), L.WELL[0], "z", 1)):
			if axis == "x":
				cp.quad("W8CeilingConcrete", [(a, ph, plane), (b, ph, plane), (b, ceil, plane), (a, ceil, plane)], (0, 0, inward))
			else:
				cp.quad("W8CeilingConcrete", [(plane, ph, a), (plane, ph, b), (plane, ceil, b), (plane, ceil, a)], (inward, 0, 0))
	by = min(y + L.LIGHT_H + 0.04, ph - 0.12)
	for bx in L.LIGHTS_X:
		for bz in (201.0, 211.0, 221.0):
			P.batten(parts["Battens"], bx, by, bz, lit=(bz == L.LIGHT_Z))
			for dx in (-0.4, 0.4):
				parts["Battens"].rod("W1Steel", [(bx + dx, by + 0.12, bz), (bx + dx, ph, bz)], 0.004, sides=4, cap=False)
	if level > 0:
		we = parts["WellEdge"]
		for (a, b), plane, axis, inward in (((L.WELL[0], L.WELL[1]), L.WELL[2], "x", 1), ((L.WELL[0], L.WELL[1]), L.WELL[3], "x", -1),
				((L.WELL[2], L.WELL[3]), L.WELL[0], "z", 1)):
			if axis == "x":
				we.quad("W8CeilingConcrete", [(a, y - L.SLAB, plane), (b, y - L.SLAB, plane), (b, y, plane), (a, y, plane)], (0, 0, inward))
				za, zb_ = sorted((plane, plane - inward * 0.05))
				we.box("W1Terrazzo", (a, y - 0.03, za), (b, y + 0.004, zb_))
			else:
				we.quad("W8CeilingConcrete", [(plane, y - L.SLAB, a), (plane, y - L.SLAB, b), (plane, y, b), (plane, y, a)], (inward, 0, 0))
				xa, xb = sorted((plane, plane - inward * 0.05))
				we.box("W1Terrazzo", (xa, y - 0.03, a), (xb, y + 0.004, b))
	return export("shell_f%d.glb" % (level + 1), list(parts.values()))


# ------------------------------------------------------------------------------------------------ stairs and the railing

def build_stairs():
	w1kit.reset()
	treads, sides, rails, well = Part("Treads"), Part("Stringers"), Part("Balustrades"), Part("WellRail")
	n = L.STAIRS["steps"]
	run = (L.STAIRS["z"][1] - L.STAIRS["z"][0]) / n
	x0, x1 = L.STAIRS["x"]
	for level in range(2):
		y = L.LEVELS[level]
		for i in range(n):
			za, zb = L.STAIRS["z"][0] + i * run, L.STAIRS["z"][0] + (i + 1) * run
			top = y + (i + 0.5) * L.STAIRS["rise"]
			low = top - L.STAIRS["rise"]
			treads.box("W1Terrazzo", (x0 + 0.06, top - 0.04, za - 0.02), (x1 - 0.06, top, zb))
			treads.box("W1Terrazzo", (x0 + 0.06, max(low, y - 0.001), za), (x1 - 0.06, top - 0.04, za + 0.02))
		za, zb = L.STAIRS["z"]
		for xs in (x0, x1 - 0.06):
			pts = [(xs, y - 0.25, za), (xs, y + 0.12, za - 0.1), (xs, y + 3.3 + 0.12, zb - 0.1), (xs, y + 3.3 - 0.25, zb)]
			for xx, nn in ((xs, (-1, 0, 0)), (xs + 0.06, (1, 0, 0))):
				sides.quad("W8WallYellow", [(xx, q[1], q[2]) for q in pts], nn)
			sides.quad("W8WallYellow", [(xs, y + 0.12, za - 0.1), (xs + 0.06, y + 0.12, za - 0.1), (xs + 0.06, y + 3.42, zb - 0.1),
				(xs, y + 3.42, zb - 0.1)], (0, 1, -0.3))
		sides.quad("W8CeilingConcrete", [(x0, y - 0.25 + 0.001, za), (x1, y - 0.25 + 0.001, za), (x1, y + 3.05, zb), (x0, y + 3.05, zb)], (0, -1, 0.3))
		for xr in L.RAILS_X:
			for k in range(0, 41):
				z = za + 0.12 + k * (zb - za - 0.24) / 40
				s = y + (z - za) * 0.33
				rails.box("W1Iron", (xr - 0.006, s + 0.02, z - 0.012), (xr + 0.006, s + 0.92, z + 0.012))
			for h, mat, w, t in ((0.92, "W1Wood", 0.05, 0.06), (0.1, "W1Iron", 0.012, 0.03)):
				rails.beam2(mat, (xr, y + h, za), (xr, y + 3.3 + h, zb), w, t)
			rails.box("W1Iron", (xr - 0.025, y, za - 0.025), (xr + 0.025, y + 1.0, za + 0.025))
			rails.box("W1Iron", (xr - 0.025, y + 3.3, zb - 0.025), (xr + 0.025, y + 4.3, zb + 0.025))
	# The railings on the slab's edges (L.RAILS: the west edge on floors 2 and 3, round 3's east-slot ends and floor 3's south
	# edge): flat-bar posts every 12 cm, a timber handrail at 1.1 m, a bottom bar, newels at both ends (one at a shared
	# corner); everything inside its collider.
	newels = []
	for r in L.RAILS:
		y = L.LEVELS[r["level"]]
		x0, x1, z0, z1 = r["box"]
		along_z = z1 - z0 > x1 - x0
		run = (z0, z1) if along_z else (x0, x1)
		mid = (x0 + x1) / 2 if along_z else (z0 + z1) / 2

		def bar(mat, a0, a1, half, y0, y1):
			if along_z:
				well.box(mat, (mid - half, y0, a0), (mid + half, y1, a1))
			else:
				well.box(mat, (a0, y0, mid - half), (a1, y1, mid + half))
		a = run[0] + 0.06
		while a < run[1] - 0.05:
			bar("W1Iron", a - 0.012, a + 0.012, 0.006, y + 0.05, y + 1.02)
			a += 0.12
		bar("W1Wood", run[0], run[1], 0.03, y + 1.04, y + r["height"])
		bar("W1Iron", run[0], run[1], 0.012, y + 1.02, y + 1.04)
		bar("W1Iron", run[0], run[1], 0.015, y + 0.05, y + 0.08)
		for aa in (run[0], run[1] - 0.05):
			at = (mid, y, aa + 0.025) if along_z else (aa + 0.025, y, mid)
			if any(abs(at[1] - n[1]) < 0.01 and math.hypot(at[0] - n[0], at[2] - n[2]) < 0.1 for n in newels):
				continue
			newels.append(at)
			bar("W1Iron", aa, aa + 0.05, 0.025, y, y + 1.08)
	return export("stairs.glb", [treads, sides, rails, well])


# ------------------------------------------------------------------------------------------------ map, tables

def build_map():
	"""The printed map (the pilot's print option) under a matt glass (W8MapGlass: rough, faint)."""
	w1kit.reset()
	b = L.MAP_BOARD
	x_wall = L.IN_W + INSET
	_, yc, zc = b["at"]
	hw, hh = b["w"] / 2, b["h"] / 2
	p = Part("MapPrint")
	glass = Part("MapGlass")
	pw, ph = b["paper"][0] / 2, b["paper"][1] / 2
	xf = x_wall + 0.04
	for lo, hi in (((x_wall, yc + hh - 0.05, zc - hw), (xf, yc + hh, zc + hw)), ((x_wall, yc - hh, zc - hw), (xf, yc - hh + 0.05, zc + hw)),
			((x_wall, yc - hh, zc - hw), (xf, yc + hh, zc - hw + 0.05)), ((x_wall, yc - hh, zc + hw - 0.05), (xf, yc + hh, zc + hw))):
		p.box("W1Alu", lo, hi)
	p.box("W1WoodPale", (x_wall, yc - hh + 0.05, zc - hw + 0.05), (x_wall + 0.02, yc + hh - 0.05, zc + hw - 0.05))
	face_x = x_wall + 0.03
	glass.quad("W8MapGlass", [(x_wall + 0.035, yc - hh + 0.05, zc + hw - 0.05), (x_wall + 0.035, yc - hh + 0.05, zc - hw + 0.05),
		(x_wall + 0.035, yc + hh - 0.05, zc - hw + 0.05), (x_wall + 0.035, yc + hh - 0.05, zc + hw - 0.05)], (1, 0, 0))
	p.quad("W8MapPrint", [(face_x, yc - ph, zc + pw), (face_x, yc - ph, zc - pw), (face_x, yc + ph, zc - pw), (face_x, yc + ph, zc + pw)], (1, 0, 0),
		uv=[P.uv_img(0, 1), P.uv_img(1, 1), P.uv_img(1, 0), P.uv_img(0, 0)])
	return export("map_print.glb", [p, glass])


def build_tables():
	w1kit.reset()
	rnd = random.Random(26515)
	table, chairs, book = Part("Tables"), Part("Chairs"), Part("RuleBook")
	for tx in L.TABLES_X:
		t = Part("T", Frame((tx, L.LEVELS[1], L.TABLE_Z), 0.0))
		P.table_parts(t, rnd, divider=False)
		P._merge_into(table, t)
		for side in (-1, 1):
			cf = Frame((tx + rnd.uniform(-0.6, 0.6), L.LEVELS[1], L.TABLE_Z + side * L.CHAIR_DZ + rnd.uniform(-0.1, 0.1)), (0.0 if side > 0 else 180.0) + rnd.uniform(-12, 12))
			c = Part("C", cf)
			P.chair_parts(c, rnd)
			P._merge_into(chairs, c)
	# The rule book where ReadingTable13/Book lay (anchor ReadingDesk (58, -5.71, 216)): a closed hardcover, 0.89 over the floor.
	b = Part("B", Frame((58.0, L.LEVELS[1], L.TABLE_Z), 0.0))
	top = L.TABLE["top"]
	b.box("W1Ledger", (-0.17, top, -0.12), (0.17, top + 0.045, 0.12))
	b.box("W1PageEdge", (-0.165, top + 0.004, -0.115), (0.165, top + 0.041, 0.118))
	b.box("W1LedgerSpine", (-0.172, top - 0.001, -0.125), (0.172, top + 0.046, -0.112))
	P._merge_into(book, b)
	return export("tables.glb", [table, chairs, book])


# ------------------------------------------------------------------------------------------------ stacks and books

def book2(p, x, y, z_front, wdt, hgt, dep, cell, lean=0.0, lie=False, sides=False):
	"""The pilot's book() with the covers drawn only where they show (a leaning or lying book, the ends of a run, by a gap)."""
	col, row = cell % 16, cell // 16
	cu0, cu1 = col * 64 / 1024, (col + 1) * 64 / 1024
	cv0, cv1 = row * 256 / 1024, (row + 1) * 256 / 1024
	mu0, mu1 = cu0 + 0.4 * (cu1 - cu0), cu0 + 0.6 * (cu1 - cu0)
	ex, ey = (hgt, wdt) if lie else (wdt, hgt)
	a = math.radians(lean)
	ca, sa = math.cos(a), math.sin(a)
	pivot = (-ex / 2) if lean > 0 else (ex / 2)

	def Q(lx, ly, lz):
		rx, ry = lx - pivot, ly
		return (x + pivot + rx * ca - ry * sa, y + rx * sa + ry * ca, lz)
	z0, z1 = z_front, z_front + dep
	hx = ex / 2
	uv = ([P.uv_img(cu0, cv1), P.uv_img(cu0, cv0), P.uv_img(cu1, cv0), P.uv_img(cu1, cv1)] if lie else
		[P.uv_img(cu1, cv1), P.uv_img(cu0, cv1), P.uv_img(cu0, cv0), P.uv_img(cu1, cv0)])
	p.quad("W8Books", [Q(-hx, 0, z0), Q(hx, 0, z0), Q(hx, ey, z0), Q(-hx, ey, z0)], (0, 0, -1), uv=uv)
	p.quad("W8Books", [Q(-hx, ey, z0), Q(hx, ey, z0), Q(hx, ey, z1), Q(-hx, ey, z1)], (0, 1, 0),
		uv=[P.uv_img(0.02, 0.76), P.uv_img(0.48, 0.76), P.uv_img(0.48, 0.99), P.uv_img(0.02, 0.99)])
	if sides or lean or lie:
		for sx, nx in ((-hx, -1), (hx, 1)):
			p.quad("W8Books", [Q(sx, 0, z0), Q(sx, 0, z1), Q(sx, ey, z1), Q(sx, ey, z0)], (nx, 0, 0),
				uv=[P.uv_img(mu0, cv1), P.uv_img(mu1, cv1), P.uv_img(mu1, cv0), P.uv_img(mu0, cv0)])


def fill_board2(p, rnd, y, x0, x1, clear, mode, z_front, depth_max):
	"""The pilot's fill_board with book2 (covers only by gaps and ends). mode: full / sparse / tipped."""
	x = x0 + rnd.uniform(0.0, 0.02)
	fill = {"full": 0.97, "sparse": 0.86, "tipped": 0.88}[mode]
	gap_before = True
	while x < x1 - 0.02:
		if rnd.random() > fill and mode != "full":
			x += rnd.uniform(0.05, 0.3)
			gap_before = True
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
			ang = -rnd.uniform(35, 62)
			for k in range(rnd.randint(4, 9)):
				if x + hgt * math.sin(math.radians(-ang)) + wdt > x1 - 0.03:
					break
				book2(p, x, y, zf, wdt, hgt, dep, rnd.randrange(48), lean=ang)
				x += wdt / math.cos(math.radians(ang)) * 1.02
			x += hgt * math.sin(math.radians(-ang)) + 0.02
			gap_before = True
			continue
		if mode != "full" and rnd.random() < 0.07 and x + hgt < x1 - 0.02:
			yy = y
			for k in range(rnd.randint(1, 4)):
				t = rnd.choice([0.025, 0.03, 0.04])
				book2(p, x + hgt / 2, yy, zf, t, hgt, dep, rnd.randrange(48), lie=True)
				yy += t
			x += hgt + 0.02
			gap_before = True
			continue
		if abs(lean) > 0 and x + hgt * math.sin(math.radians(abs(lean))) + wdt > x1 - 0.02:
			lean = 0.0
		last = x + wdt + 0.05 > x1 - 0.02
		book2(p, x + wdt / 2, y, zf, wdt, hgt, dep, cell, lean=lean, sides=gap_before or last)
		gap_before = bool(lean)
		x += wdt + (abs(math.sin(math.radians(lean))) * hgt if lean else 0.0) + rnd.uniform(0.0, 0.004)


def shelf_unit(frames, near, far, fr, kind, w, d, h, boards, mode, rnd, double=False):
	"""One stack in frame fr (centre of its foot; the open face toward local -z; double: both faces, a divider between).
	frames gets the carcass, near the books (atlas, per spine), far one block per board and face."""
	steel = kind == "steel"
	mat = "W8ShelfSteel" if steel else "W8ShelfWood"
	t = 0.025 if steel else 0.04
	hw = w / 2
	z0, z1 = -d / 2, d / 2
	q = Part("U", fr)
	for sx in (-hw, hw - t):
		q.box(mat, (sx, 0.0, z0), (sx + t, h, z1))
		if steel:
			q.box(mat, (sx - 0.005 if sx < 0 else sx + t, 0.0, z0), (sx if sx < 0 else sx + t + 0.005, h, z0 + 0.03))
			if double:
				q.box(mat, (sx - 0.005 if sx < 0 else sx + t, 0.0, z1 - 0.03), (sx if sx < 0 else sx + t + 0.005, h, z1))
	# The back (single) or the divider (double): painted sheet steel in three panels with folded joints, stiffeners on the
	# outside, a lip at the top (steel); boards (wood).
	if steel:
		bz0, bz1 = (-0.008, 0.008) if double else (z1 - 0.02, z1 - 0.012)
		panels = 3
		for k in range(panels):
			xa = -hw + t + k * (w - 2 * t) / panels
			xb = xa + (w - 2 * t) / panels
			q.box("W8ShelfBack", (xa + 0.003, 0.08, bz0), (xb - 0.003, h - 0.04, bz1))
			# The folded joint: a 2 cm return either side of each panel's edge, toward the outside.
			for xe in (xa + 0.003, xb - 0.023):
				q.box("W8ShelfBack", (xe, 0.08, bz1 if not double else bz0 - 0.012), (xe + 0.02, h - 0.04, bz1 + 0.012 if not double else bz0))
		if not double:
			for k in range(1, 6):
				xs = -hw + t + k * (w - 2 * t) / 6
				q.box("W8ShelfBack", (xs - 0.015, 0.1, bz1 + 0.012), (xs + 0.015, h - 0.06, bz1 + 0.027))
			q.box("W8ShelfBack", (-hw + t, h - 0.06, bz1), (hw - t, h - 0.03, bz1 + 0.03))
	else:
		bz0, bz1 = (-0.01, 0.01) if double else (z1 - 0.04, z1 - 0.02)
		for k in range(int(w / 0.14)):
			xa = -hw + t + k * 0.14
			if xa + 0.135 > hw - t:
				break
			q.box("W1WoodPale", (xa, 0.06, bz0), (xa + 0.135, h - 0.03, bz1))
	faces = [(-1, z0, (0.0 if double else z1 - 0.02))] + ([(1, 0.0, z1)] if double else [])
	q.box("W1Black" if steel else mat, (-hw + t, 0.0, z0 + 0.03), (hw - t, boards[0] - L.SHELF["board_t"] / 2, z1 - (0.03 if double else 0.02)))
	for by in boards:
		yb1 = by + L.SHELF["board_t"] / 2
		q.box(mat, (-hw + t, yb1 - (0.02 if steel else 0.03), z0), (hw - t, yb1, z1))
		for side, fa, fb in faces:
			edge = z0 if side < 0 else z1
			if steel:
				q.box(mat, (-hw + t, yb1 - 0.045, min(edge, edge - side * 0.015)), (hw - t, yb1, max(edge, edge - side * 0.015)))
				q.pbox("label_white", (-0.1, yb1 - 0.04, min(edge + side * 0.003, edge)), (0.1, yb1 - 0.01, max(edge + side * 0.003, edge)), rnd)
			else:
				q.box("W1Wood", (-hw + t, yb1 - 0.05, min(edge - side * 0.005, edge + side * 0.015)), (hw - t, yb1, max(edge - side * 0.005, edge + side * 0.015)))
	q.box(mat, (-hw, h - 0.03, z0 - (0.0 if steel else 0.02)), (hw, h, z1 + (0.0 if steel or not double else 0.02)))
	P._merge_into(frames, q)
	# Books on each face (a double row's +z face: the frame turned half round).
	for side, fa, fb in faces:
		face_fr = fr if side < 0 else Frame(fr.p((0, 0, 0)), _yaw(fr) + 180.0)
		zf, depth = (-d / 2 + 0.015, d / 2 - 0.05) if double else (z0 + 0.015, d - 0.1)
		bn, bf = Part("N", face_fr), Part("F", face_fr)
		hw_b = w / 2 - t - 0.02
		for k, by in enumerate(boards):
			yy = by + L.SHELF["board_t"] / 2
			nxt = boards[k + 1] - L.SHELF["board_t"] / 2 if k + 1 < len(boards) else h - 0.03
			fill_board2(bn, rnd, yy, -hw_b, hw_b, nxt - yy, mode, zf, min(depth, 0.27))
			P.book_block(bf, rnd, -hw_b, hw_b, yy, min(nxt - yy - 0.04, rnd.uniform(0.22, 0.3)), zf + 0.01, min(depth, 0.27))
		P._merge_into(near, bn)
		P._merge_into(far, bf)


def _yaw(fr):
	return math.degrees(math.atan2(fr.s, fr.c))


def _stack_frame(piece):
	"""A FINAL shelf piece's frame: centre of its box; the open face away from its wall (single), along x for rows."""
	x0, x1, z0, z1 = piece["box"]
	cx, cz = (x0 + x1) / 2, (z0 + z1) / 2
	y = L.LEVELS[piece["level"]]
	along_x = (x1 - x0) >= (z1 - z0)
	if piece["kind"].startswith("row"):
		return Frame((cx, y, cz), 0.0), x1 - x0, z1 - z0
	if along_x:
		yaw = 0.0 if cz > (L.IN_S + L.IN_N) / 2 else 180.0
		return Frame((cx, y, cz), yaw), x1 - x0, z1 - z0
	yaw = 90.0 if cx > (L.IN_W + L.IN_E) / 2 else -90.0
	return Frame((cx, y, cz), yaw), z1 - z0, x1 - x0


def build_shelves():
	"""Per floor: the nine PS1 shelves' new stacks (inside their colliders, as the pilot) and FINAL's stacks."""
	for level in range(3):
		groups = {}
		w1kit.reset()
		rnd = random.Random(26560 + level)
		wood = level == 2
		frames = Part("FramesWood" if wood else "Frames")
		clusters = {}

		def cluster(name):
			if name not in clusters:
				clusters[name] = (Part("Books_" + name), Part("BooksFar_" + name))
			return clusters[name]
		for sx in L.SHELF_X:
			sz = L.SHELF_Z[level]
			name = "F%d_Shelf%d" % (level + 1, int(sx - 45))
			mode = "full" if level < 2 else ("sparse" if sx in (57.0, 73.0) else "tipped")
			near, far = cluster(name)
			shelf_unit(frames, near, far, Frame((sx, L.LEVELS[level], sz), 0.0), "wood" if wood else "steel", L.SHELF["w"] + 0.04,
				L.SHELF["d"], L.SHELF["h"], L.SHELF["boards_y"], mode, rnd)
		for piece in L.FINAL:
			if piece["level"] != level or "cluster" not in piece:
				continue
			fr, length, depth = _stack_frame(piece)
			kind = piece["kind"]
			steel = not kind.endswith("_wood")
			if kind.startswith("row"):
				boards = L.ROW_BOARDS
			elif kind.startswith("low"):
				boards = L.LOW_BOARDS
			else:
				boards = [0.1, 0.55, 1.0, 1.45, 1.9]
			mode = ("full" if rnd.random() < 0.6 else "sparse") if steel else ("tipped" if rnd.random() < 0.35 else "sparse")
			near, far = cluster(piece["cluster"])
			shelf_unit(frames, near, far, fr, "steel" if steel else "wood", length, depth, piece["height"], boards, mode, rnd,
				double=kind.startswith("row"))
			groups.setdefault(piece["cluster"], piece["box"][2])
		parts = [frames]
		for name in sorted(clusters):
			parts += list(clusters[name])
		if level < 2:
			export("shelves_f%d.glb" % (level + 1), parts)
		else:
			# Floor 3 in two files (north and south of the cross aisle: each under the 10 MB a binary may weigh).
			north = [p for p in parts[1:] if _cluster_north(p.name, groups)]
			south = [p for p in parts[1:] if not _cluster_north(p.name, groups)]
			export("shelves_f3n.glb", [frames] + north)
			export("shelves_f3s.glb", south)


def _cluster_north(part_name, groups):
	name = part_name.split("_", 1)[1]
	if name.startswith("F3_Shelf"):
		return True
	return groups.get(name, 0.0) >= 209.0


# ------------------------------------------------------------------------------------------------ loose pieces, mess

def build_fill():
	for level in range(3):
		w1kit.reset()
		rnd = random.Random(26570 + level)
		fill = Part("Fill")
		for piece in L.FINAL:
			if piece["level"] != level or "cluster" in piece:
				continue
			if piece["kind"] == "catalogue":
				x0, x1, z0, z1 = piece["box"]
				zm = (z0 + z1) / 2
				for box, yaw in (((x0, x1, z0, zm), 180.0), ((x0, x1, zm, z1), 0.0)):
					half = dict(piece, box=box, yaw=yaw)
					P.fill_piece(fill, half, rnd)
			else:
				P.fill_piece(fill, piece, rnd)
		mess = build_mess(level)
		export("fill_f%d.glb" % (level + 1), [fill, mess])


def _clear_of(x, z, level, pad=0.08):
	"""Whether a mess piece at (x, z) stays off every stack, piece and PS1 collider (grown by pad) and, on floor 3, out of
	the scare points' and their shelves' 2 m."""
	for piece in L.FINAL:
		if piece["level"] == level:
			x0, x1, z0, z1 = piece["box"]
			if x0 - pad < x < x1 + pad and z0 - pad < z < z1 + pad:
				return False
	for x0, x1, z0, z1 in L.ps1_solids(level):
		if x0 - pad < x < x1 + pad and z0 - pad < z < z1 + pad:
			return False
	if not (L.IN_W + 0.3 < x < L.IN_E - 0.3 and L.IN_S + 0.3 < z < L.IN_N - 0.3):
		return False
	if level > 0 and L.WELL[0] - 0.4 < x < L.WELL[1] and L.WELL[2] - 0.4 < z < L.WELL[3]:
		return False
	if level == 2:
		if any(math.hypot(x - sx, z - sz) < L.SCARE_CLEAR + 0.3 for sx, sz in L.SCARE_POINTS):
			return False
		for x0, x1, z0, z1 in L.SCARE_SHELVES:
			if x0 - L.SCARE_CLEAR - 0.3 < x < x1 + L.SCARE_CLEAR + 0.3 and z0 - L.SCARE_CLEAR - 0.3 < z < z1 + L.SCARE_CLEAR + 0.3:
				return False
	if level == 0 and math.hypot(x - L.LIBRARIAN_CHAIR[0], z - L.LIBRARIAN_CHAIR[2]) < L.LIBRARIAN_CLEAR:
		return False
	return True


def _on_nav(x, z):
	"""Inside the cross of aisles (the navigation and its 0.6 m band): only flat paper there."""
	return (45.4 < x < 78.6 and 208.4 < z < 213.6) or (61.4 < x < 68.6) or (76.4 < x < 84.4 and (z < 199.1 or z > 208.9))


def build_mess(level):
	"""Medium mess, flat (a lying book is 2.5-4 cm; nothing over 3 cm on the aisles): books fallen in front of the stacks,
	papers, the fallen ceiling panels under the missing ones."""
	rnd = random.Random(26580 + level)
	y = L.LEVELS[level]
	p = Part("Mess")
	stacks = [(sx - 1.5, sx + 1.5, L.SHELF_Z[level] - 0.3, L.SHELF_Z[level] + 0.3) for sx in L.SHELF_X]
	stacks += [q["box"] for q in L.FINAL if q["level"] == level and "cluster" in q]
	placed = 0
	for x0, x1, z0, z1 in stacks:
		if rnd.random() < 0.45:
			continue
		for k in range(rnd.randint(2, 6)):
			along_x = (x1 - x0) >= (z1 - z0)
			side = rnd.choice((-1, 1))
			if along_x:
				bx = rnd.uniform(x0 + 0.2, x1 - 0.2)
				bz = (z0 if side < 0 else z1) + side * rnd.uniform(0.2, 0.7)
			else:
				bz = rnd.uniform(z0 + 0.2, z1 - 0.2)
				bx = (x0 if side < 0 else x1) + side * rnd.uniform(0.2, 0.7)
			if not _clear_of(bx, bz, level, 0.12) or _on_nav(bx, bz):
				continue
			q = Part("B", Frame((bx, y, bz), rnd.uniform(0, 360)))
			book2(q, 0.0, 0.0, -0.1, rnd.choice([0.025, 0.03, 0.04]), rnd.uniform(0.2, 0.28), rnd.uniform(0.15, 0.22), rnd.randrange(48),
				lie=True, sides=True)
			P._merge_into(p, q)
			placed += 1
	papers = 0
	while papers < 16:
		px, pz = rnd.uniform(46, 84), rnd.uniform(196, 224)
		if not _clear_of(px, pz, level, 0.2):
			continue
		a = rnd.uniform(0, math.tau)
		c, s = math.cos(a), math.sin(a)
		pts = [(px + c * dx - s * dz, y + 0.004, pz + s * dx + c * dz) for dx, dz in ((-0.105, -0.15), (0.105, -0.15), (0.105, 0.15), (-0.105, 0.15))]
		p.pal([p.quad("W8Palette", pts, (0, 1, 0))], rnd.choice(["paper", "newspaper", "label_white"]), rnd)
		papers += 1
	# Fallen ceiling panels (1.5 cm) under two of the missing ones, where they are clear of the stacks.
	fallen = 0
	for mx, mz in missing_panels(level):
		cx, cz = mx + 0.3 + rnd.uniform(-0.3, 0.3), mz + 0.3 + rnd.uniform(-0.3, 0.3)
		if fallen >= 2 or not _clear_of(cx, cz, level, 0.5) or _on_nav(cx, cz):
			continue
		a = rnd.uniform(0, math.tau)
		c, s = math.cos(a), math.sin(a)
		corners = [(cx + c * dx - s * dz, cz + s * dx + c * dz) for dx, dz in ((-0.3, -0.3), (0.3, -0.3), (0.3, 0.3), (-0.3, 0.3))]
		top = [(u, y + 0.017, v) for u, v in corners]
		p.pal([p.quad("W8Palette", top, (0, 1, 0))], "chalk", rnd)
		fallen += 1
	print("MESS floor %d: %d books, %d papers, %d panels" % (level + 1, placed, papers, fallen))
	return p


# ------------------------------------------------------------------------------------------------ facade

def _curtain_glass(part, x0, x1, y0, y1, z, out, col, cover):
	"""A window seen from outside: dark glass, the curtains behind it (their cover from curtain(); seen from outside the
	inside's left is the right). One quad per section: curtain, glass, curtain."""
	w = min((x1 - x0 + 0.3) * cover * 0.5 - 0.15, (x1 - x0) / 2)
	secs = [(x0, x0 + w, CURTAIN_MATS[col]), (x0 + w, x1 - w, "W7GlassDark"), (x1 - w, x1, CURTAIN_MATS[col])] if cover < 0.999 else [(x0, x1, CURTAIN_MATS[col])]
	made = []
	for a, b, mat in secs:
		if b - a < 0.01:
			continue
		u0, u1 = (a - x0) / 0.6, (b - x0) / 0.6
		if out < 0:
			pts = [(b, y0, z), (a, y0, z), (a, y1, z), (b, y1, z)]
			uv = [(u1, 1), (u0, 1), (u0, 0), (u1, 0)]
		else:
			pts = [(a, y0, z), (b, y0, z), (b, y1, z), (a, y1, z)]
			uv = [(u0, 1), (u1, 1), (u1, 0), (u0, 0)]
		made.append(part.quad(mat, pts, (0, 0, out), [P.uv_img(u, v) for u, v in uv]))
	return made


def _curtain_glass_z(part, z0, z1, y0, y1, x, out, col):
	"""East/west faces (outside only): the curtains drawn shut behind dark glass."""
	u = (z1 - z0) / 0.6
	if out > 0:
		pts, uv = [(x, y0, z0), (x, y0, z1), (x, y1, z1), (x, y1, z0)], [(0, 1), (u, 1), (u, 0), (0, 0)]
	else:
		pts, uv = [(x, y0, z1), (x, y0, z0), (x, y1, z0), (x, y1, z1)], [(0, 1), (u, 1), (u, 0), (0, 0)]
	return part.quad(CURTAIN_MATS[col], pts, (out, 0, 0), [P.uv_img(a, b) for a, b in uv])


SIDE_WINDOWS_Z = [202.0, 210.0, 218.0]    # east and west faces: three a floor, 8 m apart as the long faces' pairs


def build_facade():
	w1kit.reset()
	rnd = random.Random(26519)
	wall_mat, band_mat = "W8FacadeYellow", "W8FacadeWhite"
	parts = {k: Part(k) for k in ("Walls", "Bands", "Fins", "Frames", "Grilles", "CurtainGlass", "Roof", "Extras")}
	walls = parts["Walls"]
	top = L.PARAPET_TOP
	faces = [("front", (L.OUT_W, L.OUT_S), (L.OUT_E, L.OUT_S), (0, 0, -1)), ("east", (L.OUT_E, L.OUT_S), (L.OUT_E, L.OUT_N), (1, 0, 0)),
		("back", (L.OUT_E, L.OUT_N), (L.OUT_W, L.OUT_N), (0, 0, 1)), ("west", (L.OUT_W, L.OUT_N), (L.OUT_W, L.OUT_S), (-1, 0, 0))]
	plinth = 0.45
	for name, a, b, n in faces:
		holes = []
		long_face = name in ("front", "back")
		for k in range(3):
			for c in (L.WINDOWS_X if long_face else SIDE_WINDOWS_Z):
				s0 = abs(c - (a[0] if long_face else a[1]))
				holes.append((s0 - 1.5, s0 + 1.5, L.LEVELS[k] + L.WINDOW["foot"], L.LEVELS[k] + L.WINDOW["head"]))
		if long_face:
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
				Q = lambda s, yy: (a[0] + (b[0] - a[0]) * s / full, yy, a[1] + (b[1] - a[1]) * s / full)  # noqa: E731
				m = "W8Concrete" if ym < G + plinth else wall_mat
				made.append(walls.quad(m, [Q(ss[i], ys[j]), Q(ss[i + 1], ys[j]), Q(ss[i + 1], ys[j + 1]), Q(ss[i], ys[j + 1])], n))
		walls.map_uv2(made, lambda q: L.wall_uv2(3, L.outer_s(P._snap_ox(q[0]), P._snap_oz(q[2])), q[1] - G))
		# Window reveals (to the wall's middle), sills, frames, the dark glass with the curtains behind it, grilles on floor 1.
		for k in range(3):
			y0, y1 = L.LEVELS[k] + L.WINDOW["foot"], L.LEVELS[k] + L.WINDOW["head"]
			for c in (L.WINDOWS_X if long_face else SIDE_WINDOWS_Z):
				lo_, hi_ = c - 1.5, c + 1.5
				if long_face:
					out = -1 if name == "front" else 1
					zf = a[1]
					mid = zf - out * 0.11
					rv = [walls.quad(band_mat, [(lo_, y1, zf), (hi_, y1, zf), (hi_, y1, mid), (lo_, y1, mid)], (0, -1, 0)),
						walls.quad(band_mat, [(lo_, y0, zf), (lo_, y1, zf), (lo_, y1, mid), (lo_, y0, mid)], (1, 0, 0)),
						walls.quad(band_mat, [(hi_, y0, zf), (hi_, y1, zf), (hi_, y1, mid), (hi_, y0, mid)], (-1, 0, 0))]
					za, zb = sorted((zf + out * 0.06, mid))
					parts["Bands"].box(band_mat, (lo_ - 0.06, y0 - 0.06, za), (hi_ + 0.06, y0, zb))
					za, zb = sorted((mid, mid + out * 0.04))
					for kk in range(4):
						xm = lo_ + (hi_ - lo_) * kk / 3
						parts["Frames"].box("W1Alu", (xm - 0.025, y0, za), (xm + 0.025, y1, zb))
					for yy in (y0, y1 - 0.05):
						parts["Frames"].box("W1Alu", (lo_, yy, za), (hi_, yy + 0.05, zb))
					col, cover = curtain(k, "S" if name == "front" else "N", c)
					_curtain_glass(parts["CurtainGlass"], lo_, hi_, y0, y1, mid + out * 0.015, out, col, cover)
					if k == 0:
						gl = parts["Grilles"]
						for kk in range(1, 25):
							xb = lo_ + (hi_ - lo_) * kk / 25
							gl.rod("W1Iron", [(xb, y0, zf - out * 0.03), (xb, y1, zf - out * 0.03)], 0.008, sides=4, cap=False)
						for yy in (y0 + 0.03, (y0 + y1) / 2, y1 - 0.03):
							za2, zb2 = sorted((zf - out * 0.045, zf - out * 0.015))
							gl.box("W1Iron", (lo_, yy - 0.015, za2), (hi_, yy + 0.015, zb2))
				else:
					out = 1 if name == "east" else -1
					xf = a[0]
					mid = xf - out * 0.11
					rv = [walls.quad(band_mat, [(xf, y1, lo_), (xf, y1, hi_), (mid, y1, hi_), (mid, y1, lo_)], (0, -1, 0)),
						walls.quad(band_mat, [(xf, y0, lo_), (mid, y0, lo_), (mid, y1, lo_), (xf, y1, lo_)], (0, 0, 1)),
						walls.quad(band_mat, [(xf, y0, hi_), (xf, y1, hi_), (mid, y1, hi_), (mid, y0, hi_)], (0, 0, -1))]
					xa, xb = sorted((xf + out * 0.06, mid))
					parts["Bands"].box(band_mat, (xa, y0 - 0.06, lo_ - 0.06), (xb, y0, hi_ + 0.06))
					xa, xb = sorted((mid, mid + out * 0.04))
					for kk in range(4):
						zm = lo_ + (hi_ - lo_) * kk / 3
						parts["Frames"].box("W1Alu", (xa, y0, zm - 0.025), (xb, y1, zm + 0.025))
					for yy in (y0, y1 - 0.05):
						parts["Frames"].box("W1Alu", (xa, yy, lo_), (xb, yy + 0.05, hi_))
					col, _ = curtain(k, "E" if name == "east" else "W", c)
					_curtain_glass_z(parts["CurtainGlass"], lo_, hi_, y0, y1, mid + out * 0.015, out, col)
					if k == 0:
						gl = parts["Grilles"]
						for kk in range(1, 25):
							zb_ = lo_ + (hi_ - lo_) * kk / 25
							gl.rod("W1Iron", [(xf - out * 0.03, y0, zb_), (xf - out * 0.03, y1, zb_)], 0.008, sides=4, cap=False)
						for yy in (y0 + 0.03, (y0 + y1) / 2, y1 - 0.03):
							xa2, xb2 = sorted((xf - out * 0.045, xf - out * 0.015))
							gl.box("W1Iron", (xa2, yy - 0.015, lo_), (xb2, yy + 0.015, hi_))
				walls.map_uv2(rv, lambda q: (0.995, 0.995))
	bands = parts["Bands"]
	ring = [(L.OUT_W, L.OUT_E, L.OUT_S, "x", -1), (L.OUT_W, L.OUT_E, L.OUT_N, "x", 1), (L.OUT_S, L.OUT_N, L.OUT_W, "z", -1),
		(L.OUT_S, L.OUT_N, L.OUT_E, "z", 1)]
	for yb in [L.LEVELS[1] - 0.24, L.LEVELS[2] - 0.24, top - 0.12]:
		for a0, a1, plane, axis, out in ring:
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
	ex = parts["Extras"]
	for tx in (78.0, 80.4):
		ex.rod("W6Stainless", [(tx, rt + 1.0, 220.0), (tx, rt + 2.4, 220.0)], 0.6, sides=16)
		for dx in (-0.45, 0.45):
			for dz in (-0.45, 0.45):
				ex.box("W1Iron", (tx + dx - 0.03, rt, 220 + dz - 0.03), (tx + dx + 0.03, rt + 1.0, 220 + dz + 0.03))
		ex.box("W1Iron", (tx - 0.55, rt + 0.95, 219.45), (tx + 0.55, rt + 1.0, 220.55))
	ex.box("W8Concrete", (80.0, rt, 202.0), (82.0, rt + 1.2, 204.0))
	for x, z in ((L.OUT_W - 0.07, 195.6), (L.OUT_W - 0.07, 224.4), (L.OUT_E + 0.07, 195.6), (L.OUT_E + 0.07, 224.4)):
		ex.rod("W8Palette", [(x, G + 0.05, z), (x, top - 0.1, z)], 0.05, sides=8)
	ex.pal([f for f in ex.bm.faces if ex.slots[f.material_index] == "W8Palette"], "trolley_grey", rnd)
	fins = parts["Fins"]
	for zf, out in ((L.OUT_S, -1), (L.OUT_N, 1)):
		x = L.OUT_W + 0.5
		while x < L.OUT_E - 0.3:
			if not (63.6 < x < 66.4):
				za, zb = sorted((zf, zf + out * 0.45))
				fins.box("W8Concrete", (x - 0.06, G + plinth, za), (x + 0.06, top - 0.12, zb))
			x += 1.0
	za, zb = sorted((L.OUT_S, L.OUT_S - 0.45))
	bands.box("W8Concrete", (63.4, G + 2.55, za), (66.6, G + 2.7, zb))
	return export("facade.glb", list(parts.values()))


# ------------------------------------------------------------------------------------------------ main

def main():
	argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	jobs = {"shell": lambda: [build_shell(k) for k in range(3)], "stairs": build_stairs, "counter": lambda: P.build_counter("q1"),
		"chair": P.build_librarian_chair, "map": build_map, "tables": build_tables, "shelves": build_shelves, "fill": build_fill,
		"back": lambda: [P.build_back_frame(), P.build_back_leaf()], "front": lambda: [P.build_front_door(), P.build_barricade()],
		"facade": build_facade, "strip": P.build_strip}
	for name in (argv or list(jobs)):
		jobs[name]()


if __name__ == "__main__":
	main()
