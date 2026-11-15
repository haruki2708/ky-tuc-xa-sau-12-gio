"""T-263 round 1: the canteen pilot (card section 2, step 2) with the options the owner picks from. Blender 5.2.2, bmesh
only, no add-on, no Tripo. Every glb is in Godot world space with its origin at Godot (0, G, 0) (canteen_layout.py has
the measured layout). Nothing new stands where the player walks that the PS1 did not have: tables, stools, the counter,
the stove, the prep table and the sink stay inside their PS1 colliders; the queue rail, tray slide, tray stand, card
reader and the canopy posts stand where their PS1 meshes stood (they never had colliders); lintels and the transom over
the doors start 2.4 m (west exit, store) and 3.3 m (main door) above the floor.

  hall_shell.glb      floor, the inside faces of the hall's walls (paint over a 1.4 m wainscot), the front wall whole
                      (both faces, ten window openings, the transom over the door), the back wall west of the kitchen
                      whole (five serving hatches with half-closed roller shutters), lintels over the kitchen and store
                      openings, the west exit's frame. F1 materials (W6FloorCeramic, W6WallYellow, W6Wainscot); F2 swaps
                      them at run time for W6FloorTerrazzo, W6WallGreen, W6DadoGreen
  windows.glb         the ten front windows: aluminium sliding sashes, glass, burglar bars outside, sills
  ceiling_panels.glb  C2: 60 x 60 mineral-fibre panels at the PS1 ceiling's height (-5.9), six missing, two sagging
  ceiling_roof.glb    C1: the roof's underside as corrugated sheet on galvanised purlins and painted steel rafters
  lights_fans.glb     20 fluorescent battens where the PS1 tubes were, 3 ceiling fans (stopped, blades as PS1)
  tables_inox.glb     T1: the 21 stainless tables with their six attached round stools (red/blue seats as PS1)
  tables_stone.glb    T2: stone-top tables on painted steel frames, loose plastic stools (upright); tables_stone_mess.glb
                      the same with a third of the stools knocked over (all inside the tables' colliders)
  tableware.glb       M1: trays, bowls and chopsticks where the PS1 had them, the six fallen trays and spills
  tableware_mess.glb  M2: M1 plus tipped bowls, more trays and chopsticks on the floor, more spills
  counter_inox.glb    Q1: stainless bain-marie counter, sneeze glass, pans with food, tray slide, rice warmers, tray stand,
                      card reader, queue rail; counter_tiled.glb Q2: the counter built and faced with white tiles
  price_boards.glb    the five boards (PriceText0..4, words unchanged): W6PriceWood, swapped for W6PricePrint
  tv.glb, tv_screen.glb  an old flat TV on a wall bracket; its lit screen (hung under TV/Screen, which campus.gd toggles)
  kitchen_room.glb    kitchen floor, walls (tiles to 1.8 m), prep table, sink, steamers, rice cookers, shelf, utensils
  kitchen_k1.glb      K1: brick stove faced with cream tiles, cast-iron woks and big aluminium pots, split hood (the
                      clock under its duct stays in view); kitchen_k2.glb K2: an industrial stainless range and hood
  clock.glb           the kitchen clock, stopped at 4:00 as KitchenClock's meta stopped_hour
  facade.glb          front: pilasters, plinth, parapet, roof edge, canopy and posts, step, the sign (W6Sign), the slogan
                      board inside over the door (W6Slogan)
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave6/build_canteen_pilot.py [-- name ...]
"""
import json
import math
from pathlib import Path
import random
import sys

import bmesh  # noqa: F401
import bpy  # noqa: F401
from mathutils import Matrix, Vector

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE.parent / "wave1"))
sys.path.insert(0, str(HERE.parent / "wave5"))
sys.path.insert(0, str(HERE))
import w1kit  # noqa: E402
import build_gate_pilot as GP  # noqa: E402  (GPart, B, build, export, set_uv; its main is guarded)
import canteen_layout as L  # noqa: E402

ROOT = HERE.parents[3]
OUT = ROOT / "game/assets/models/graphics_pilot/realistic_map/wave6"
G = L.G
B = GP.B
GPart = GP.GPart
PALETTE = json.loads((HERE / "palette.json").read_text(encoding="utf-8"))
SIZES = dict(L.SIZES)
DADO = 1.4           # wainscot / dado height above the floor
INSET = 0.004        # new inside faces stand this far in front of the PS1 walls they cover


def export(name, objs):
	GP.export(OUT / name, objs)


def build(part, extra=None):
	sizes = dict(SIZES)
	sizes.update(extra or {})
	return GP.build(part, sizes)


def cell_uv(part, faces, key, rnd=None):
	"""Faces into one palette cell (8 x 8 cells, a jitter inside the cell keeps the weave from repeating)."""
	cx, cy = PALETTE[key]
	rnd = rnd or random
	for f in faces:
		ju, jv = rnd.uniform(0.3, 0.7), rnd.uniform(0.3, 0.7)
		for loop in f.loops:
			loop[part.uv].uv = ((cx + ju) / 8.0, 1.0 - (cy + jv) / 8.0)
		f.tag = True
	return faces


def retag(part, faces):
	for f in faces:
		if f.is_valid:
			f.tag = True


def yaw_matrix(x, y, z, yaw_deg=0.0, roll=None):
	"""Godot point + yaw (about +y, degrees) -> Blender matrix for local Blender-frame geometry (local Godot (lx, ly,
	lz) is Blender (lx, -lz, ly))."""
	m = Matrix.Translation(B((x, y, z))) @ Matrix.Rotation(math.radians(yaw_deg), 4, "Z")
	if roll is not None:
		m = m @ roll
	return m


def gl(lx, ly, lz):
	"""Local Godot offset -> local Blender vector."""
	return Vector((lx, -lz, ly))


def lbox(part, m, mat, lo, hi, bevel=0.0):
	"""A box given in local Godot coordinates (lo, hi), placed by the Blender matrix m."""
	a, b = gl(*lo), gl(*hi)
	return part.box(mat, (min(a.x, b.x), min(a.y, b.y), min(a.z, b.z)), (max(a.x, b.x), max(a.y, b.y), max(a.z, b.z)), bevel=bevel,
		segments=1, matrix=m)


def lcyl(part, m, mat, c, r, h, segs=12, axis="Y", r2=None, cap=True):
	"""A cylinder centred at local Godot c, its axis along local Godot Y (up), X or Z."""
	baxis = {"Y": "Z", "X": "X", "Z": "Y"}[axis]
	return part.cylinder(mat, tuple(gl(*c)), r, h, axis=baxis, segments=segs, radius2=r2, cap=cap, matrix=m)


# ------------------------------------------------------------------------------------------------ hall shell

def wall_face(part, a, b, y0, y1, normal, holes, row, s0, length, lower="W6Wainscot", upper="W6WallYellow", dado=DADO):
	"""A vertical face from a to b (Godot x, z), y0..y1, holes [(s_from, s_to, y_lo, y_hi)] in metres along a->b,
	split at the dado; UV2 in mask row `row` at s0 + s along an unrolled length."""
	ax, az = a
	bx, bz = b
	full = math.hypot(bx - ax, bz - az)
	ss = {0.0, full}
	ys = {y0, y1}
	if lower and G + dado > y0 and G + dado < y1:
		ys.add(G + dado)
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
			p = lambda s, y: (ax + (bx - ax) * s / full, y, az + (bz - az) * s / full)  # noqa: E731
			mat = lower if (lower and ym < G + dado) else upper
			f = part.face(mat, [p(ss[i], ys[j]), p(ss[i + 1], ys[j]), p(ss[i + 1], ys[j + 1]), p(ss[i], ys[j + 1])], normal)
			faces.append(f)
	part.map_uv2(faces, lambda q: _wall_uv(q, a, b, full, row, s0, length))
	return faces


def _wall_uv(q, a, b, full, row, s0, length):
	s = math.hypot(q[0] - a[0], q[2] - a[1])
	u, v = L.wall_uv2(row, s0 + s, q[1], length)
	return (u, v)


def reveal(part, mat, x0, x1, y0, y1, z0, z1, axis="z", row=0, s=0.0, length=128.0):
	"""The four faces lining a rectangular hole through a wall (axis: the wall's normal direction)."""
	faces = []
	if axis == "z":
		faces.append(part.face(mat, [(x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1)], (0, 1, 0)))
		faces.append(part.face(mat, [(x0, y1, z0), (x1, y1, z0), (x1, y1, z1), (x0, y1, z1)], (0, -1, 0)))
		faces.append(part.face(mat, [(x0, y0, z0), (x0, y1, z0), (x0, y1, z1), (x0, y0, z1)], (1, 0, 0)))
		faces.append(part.face(mat, [(x1, y0, z0), (x1, y1, z0), (x1, y1, z1), (x1, y0, z1)], (-1, 0, 0)))
	else:
		# x0/x1 are the wall's two faces, z0/z1 the hole's sides.
		faces.append(part.face(mat, [(x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1)], (0, 1, 0)))
		faces.append(part.face(mat, [(x0, y1, z0), (x1, y1, z0), (x1, y1, z1), (x0, y1, z1)], (0, -1, 0)))
		faces.append(part.face(mat, [(x0, y0, z0), (x0, y1, z0), (x1, y1, z0), (x1, y0, z0)], (0, 0, 1)))
		faces.append(part.face(mat, [(x0, y0, z1), (x0, y1, z1), (x1, y1, z1), (x1, y0, z1)], (0, 0, -1)))
	part.map_uv2(faces, lambda q: L.wall_uv2(row, s, q[1], length))
	return faces


def build_hall_shell():
	w1kit.reset()
	part = GPart("HallShell")
	top = L.ROOF_UNDER
	t = L.T
	x0, x1 = L.HALL["x"]
	z0, z1 = L.HALL["z"]
	win_lo, win_hi = L.WINDOW["y"] - L.WINDOW["h"] / 2, L.WINDOW["y"] + L.WINDOW["h"] / 2
	# Floor (F1/F2), a hair over the PS1 floor's top.
	fl = part.face("W6FloorCeramic", [(x0 + t, G + 0.002, z0 + t), (x1 - t, G + 0.002, z0 + t), (x1 - t, G + 0.002, z1 - t),
		(x0 + t, G + 0.002, z1 - t)], (0, 1, 0))
	part.map_uv2([fl], lambda q: L.floor_uv2(q[0], q[2]))
	# Front wall, inside face (z 20.125, facing +z) and outside face (z 19.875, facing -z): windows cut through, the
	# door gap x 186..194 with a transom from y -6.6 up.
	transom = -6.6
	inner_z, outer_z = z0 + t, z0 - t
	holes = [(wx - 1.2 - (x0 + t), wx + 1.2 - (x0 + t), win_lo, win_hi) for wx in L.WINDOWS_X]
	holes.append((L.DOOR[0] - (x0 + t), L.DOOR[1] - (x0 + t), G - 1, transom))
	wall_face(part, (x0 + t, inner_z), (x1 - t, inner_z), G, top, (0, 0, 1), holes, 0, 0.0, L.HALL_PERIMETER)
	out_holes = [(wx - 1.2 - (x0 - t), wx + 1.2 - (x0 - t), win_lo, win_hi) for wx in L.WINDOWS_X]
	out_holes.append((L.DOOR[0] - (x0 - t), L.DOOR[1] - (x0 - t), G - 1, transom))
	wall_face(part, (x0 - t, outer_z), (x1 + t, outer_z), G, L.WALL_TOP, (0, 0, -1), out_holes, 2, 0.5 - t, 41.0,
		lower=None, upper="W6FacadeYellow")
	for wx in L.WINDOWS_X:
		reveal(part, "W6FacadeWhite", wx - 1.2, wx + 1.2, win_lo, win_hi, outer_z, inner_z, "z", 2, wx - 169.5, 41.0)
	# Door gap: the two jamb faces and the transom's underside.
	for xd, n in ((L.DOOR[0], (1, 0, 0)), (L.DOOR[1], (-1, 0, 0))):
		f = part.face("W6FacadeWhite", [(xd, G, outer_z), (xd, G, inner_z), (xd, transom, inner_z), (xd, transom, outer_z)], n)
		part.map_uv2([f], lambda q, xd=xd: L.wall_uv2(2, xd - 169.5, q[1], 41.0))
	f = part.face("W6FacadeWhite", [(L.DOOR[0], transom, outer_z), (L.DOOR[1], transom, outer_z), (L.DOOR[1], transom, inner_z),
		(L.DOOR[0], transom, inner_z)], (0, -1, 0))
	part.map_uv2([f], lambda q: L.wall_uv2(2, q[0] - 169.5, transom, 41.0))
	# East wall (Side210 kept; this face covers its inside), back wall east of the kitchen (Back199.5, Back206.5 kept).
	s_e = 39.75
	wall_face(part, (x1 - t - INSET, z0 + t), (x1 - t - INSET, z1 - t), G, top, (-1, 0, 0), [], 0, s_e, L.HALL_PERIMETER)
	s_b = s_e + 23.75
	bz = z1 - t - INSET
	back_holes = [(x1 - t - L.STORE_DOOR[1], x1 - t - L.STORE_DOOR[0], G - 1, -7.5), (x1 - t - 198.0, x1 - t - 186.0, G - 1, -6.6)]
	wall_face(part, (x1 - t, bz), (186.0, bz), G, top, (0, 0, -1), back_holes, 0, s_b, L.HALL_PERIMETER)
	# Back wall west of the kitchen (Back178 hidden): both faces, five serving hatches.
	hatch_lo, hatch_hi = -8.6, -7.6
	inner_b, outer_b = z1 - t, z1 + t
	hatches = [(186.0 - (sx + 1.0), 186.0 - (sx - 1.0), hatch_lo, hatch_hi) for sx in L.SERVE_X]
	wall_face(part, (186.0, inner_b), (x0 + t, inner_b), G, top, (0, 0, -1), hatches, 0, s_b + (x1 - t - 186.0), L.HALL_PERIMETER)
	wall_face(part, (x0 - t, outer_b), (186.0, outer_b), G, L.WALL_TOP, (0, 0, 1), [], 3, 0.0, 128.0, lower=None, upper="W6FacadeYellow")
	recess = 0.2
	for sx in L.SERVE_X:
		reveal(part, "W6Stainless", sx - 1.0, sx + 1.0, hatch_lo, hatch_hi, inner_b, inner_b + recess, "z", 0, 0.0)
		back = part.face("W6Plenum", [(sx - 1.0, hatch_lo, inner_b + recess), (sx + 1.0, hatch_lo, inner_b + recess),
			(sx + 1.0, hatch_hi, inner_b + recess), (sx - 1.0, hatch_hi, inner_b + recess)], (0, 0, -1))
		# Stainless trim round the hatch and a half-closed roller shutter (slats down to 0.3 m over the sill).
		for lo, hi in (((sx - 1.06, hatch_lo - 0.06, inner_b - 0.012), (sx + 1.06, hatch_lo, inner_b)),
				((sx - 1.06, hatch_hi, inner_b - 0.012), (sx + 1.06, hatch_hi + 0.06, inner_b)),
				((sx - 1.06, hatch_lo, inner_b - 0.012), (sx - 1.0, hatch_hi, inner_b)),
				((sx + 1.0, hatch_lo, inner_b - 0.012), (sx + 1.06, hatch_hi, inner_b))):
			part.gbox("W6Stainless", lo, hi)
		part.gbox("W6Shutter", (sx - 1.0, hatch_hi - 0.12, inner_b + 0.02), (sx + 1.0, hatch_hi, inner_b + recess - 0.01))
		y = hatch_hi - 0.12
		while y > hatch_lo + 0.3:
			part.gbox("W6Shutter", (sx - 0.97, y - 0.075, inner_b + 0.09), (sx + 0.97, y, inner_b + 0.11))
			part.gbox("W6Shutter", (sx - 0.97, y - 0.081, inner_b + 0.1), (sx + 0.97, y - 0.074, inner_b + 0.115))
			y -= 0.08
	# Lintels over the kitchen opening (x 186..198, from y -6.6) and the store door (x 201..203, from y -7.5): both
	# faces and the underside; the opening's jamb faces.
	for (a, b2), low in (((186.0, 198.0), -6.6), (L.STORE_DOOR, -7.5)):
		f = part.face("W6WallYellow", [(a, low, z1 - t - INSET), (b2, low, z1 - t - INSET), (b2, low, z1 + t), (a, low, z1 + t)], (0, -1, 0))
		part.map_uv2([f], lambda q: L.wall_uv2(0, 70.0, q[1], 128.0))
		f2 = part.face("W6WallYellow", [(a, low, z1 + t), (b2, low, z1 + t), (b2, top, z1 + t), (a, top, z1 + t)], (0, 0, 1))
		part.map_uv2([f2], lambda q: L.wall_uv2(1, 30.0, q[1], 80.0))
	# West wall: the WestExit walls kept (their outside faces), this inside face with the exit's opening and frame.
	wx = x0 + t + INSET
	s_w = s_b + 39.75
	door = (z1 - t - L.WEST_DOOR[1], z1 - t - L.WEST_DOOR[0], G - 1, L.WEST_DOOR_HEAD)
	wall_face(part, (wx, z1 - t), (wx, z0 + t), G, top, (1, 0, 0), [door], 0, s_w, L.HALL_PERIMETER)
	za, zb = L.WEST_DOOR
	for zz, n in ((za, (0, 0, 1)), (zb, (0, 0, -1))):
		part.face("W1Wood", [(x0 - t, G, zz), (x0 + t, G, zz), (x0 + t, L.WEST_DOOR_HEAD, zz), (x0 - t, L.WEST_DOOR_HEAD, zz)], n)
	part.face("W1Wood", [(x0 - t, L.WEST_DOOR_HEAD, za), (x0 + t, L.WEST_DOOR_HEAD, za), (x0 + t, L.WEST_DOOR_HEAD, zb), (x0 - t, L.WEST_DOOR_HEAD, zb)],
		(0, -1, 0))
	# Casings 8 cm wide on both faces, outside the opening (it stays 2 m wide).
	for xa, xb in ((x0 + t + INSET, x0 + t + INSET + 0.02), (x0 - t - 0.024, x0 - t - 0.004)):
		part.gbox("W1Wood", (xa, G, za - 0.08), (xb, L.WEST_DOOR_HEAD + 0.08, za))
		part.gbox("W1Wood", (xa, G, zb), (xb, L.WEST_DOOR_HEAD + 0.08, zb + 0.08))
		part.gbox("W1Wood", (xa, L.WEST_DOOR_HEAD, za), (xb, L.WEST_DOOR_HEAD + 0.08, zb))
	part.gbox("W1Terrazzo", (x0 - t, G, za), (x0 + t, G + 0.01, zb))
	# Wainscot cap (a bullnose strip 1 cm proud) along the inside faces, broken at the doors.
	cap = G + DADO
	for a, b2 in (((x0 + t, z0 + t), (L.DOOR[0], z0 + t)), ((L.DOOR[1], z0 + t), (x1 - t, z0 + t)),
			((x1 - t - INSET, z0 + t), (x1 - t - INSET, z1 - t)), ((x1 - t, z1 - t - INSET), (L.STORE_DOOR[1], z1 - t - INSET)),
			((L.STORE_DOOR[0], z1 - t - INSET), (198.0, z1 - t - INSET)), ((186.0, z1 - t), (x0 + t, z1 - t)),
			((x0 + t + INSET, z1 - t), (x0 + t + INSET, L.WEST_DOOR[1] + 0.08)), ((x0 + t + INSET, L.WEST_DOOR[0] - 0.08), (x0 + t + INSET, z0 + t))):
		(ax, az), (bx2, bz2) = a, b2
		lo = (min(ax, bx2) - (0.012 if ax == bx2 else 0), cap - 0.012, min(az, bz2) - (0.012 if az == bz2 else 0))
		hi = (max(ax, bx2) + (0.012 if ax == bx2 else 0), cap + 0.012, max(az, bz2) + (0.012 if az == bz2 else 0))
		faces = part.gbox("W6Wainscot", lo, hi)
		part.map_uv2(faces, lambda q: (0.995, 0.25))
	# Inside window sills (tiles) over the wainscot cap.
	for wxx in L.WINDOWS_X:
		faces = part.gbox("W6Wainscot", (wxx - 1.25, win_lo - 0.02, inner_z - 0.01), (wxx + 1.25, win_lo, inner_z + 0.06))
		part.map_uv2(faces, lambda q: (0.995, 0.25))
	part.bm.normal_update()
	export("hall_shell.glb", [build(part, {"W6Stainless": 1.0, "W6Shutter": 1.0, "W6Plenum": 1.0, "W1Wood": 1.0, "W1Terrazzo": 1.0})])


# ------------------------------------------------------------------------------------------------ windows

def build_windows():
	w1kit.reset()
	part = GPart("Windows")
	glass = GPart("Glass")
	z_in, z_out = L.HALL["z"][0] + L.T, L.HALL["z"][0] - L.T
	lo, hi = L.WINDOW["y"] - L.WINDOW["h"] / 2, L.WINDOW["y"] + L.WINDOW["h"] / 2
	rnd = random.Random(26301)
	for i, wx in enumerate(L.WINDOWS_X):
		a, b = wx - 1.2, wx + 1.2
		zf = 19.99   # frame plane in the wall's middle
		# Outer frame.
		part.gbox("W1Alu", (a, lo, zf - 0.04), (b, lo + 0.045, zf + 0.04))
		part.gbox("W1Alu", (a, hi - 0.045, zf - 0.04), (b, hi, zf + 0.04))
		part.gbox("W1Alu", (a, lo, zf - 0.04), (a + 0.045, hi, zf + 0.04))
		part.gbox("W1Alu", (b - 0.045, lo, zf - 0.04), (b, hi, zf + 0.04))
		# Four sashes on two tracks; window 3 has one sash slid open, window 7 a cracked pane (missing a shard).
		w = (b - a - 0.09) / 4
		for k in range(4):
			track = -0.018 if k % 2 == 0 else 0.018
			sa = a + 0.045 + k * w - (0.01 if k % 2 else 0)
			if i == 3 and k == 1:
				sa -= w * 0.8
			sb = sa + w + 0.02
			for lo2, hi2 in (((sa, lo + 0.045, zf + track - 0.012), (sb, lo + 0.08, zf + track + 0.012)),
					((sa, hi - 0.08, zf + track - 0.012), (sb, hi - 0.045, zf + track + 0.012)),
					((sa, lo + 0.08, zf + track - 0.012), (sa + 0.035, hi - 0.08, zf + track + 0.012)),
					((sb - 0.035, lo + 0.08, zf + track - 0.012), (sb, hi - 0.08, zf + track + 0.012))):
				part.gbox("W1Alu", lo2, hi2)
			ga, gb = sa + 0.035, sb - 0.035
			if i == 7 and k == 2:
				# A shard gone from the lower corner.
				glass.face("W2Glass", [(ga, lo + 0.35, zf + track), (gb - 0.2, lo + 0.08, zf + track), (gb, lo + 0.08, zf + track),
					(gb, hi - 0.08, zf + track), (ga, hi - 0.08, zf + track)], (0, 0, -1))
			else:
				glass.face("W2Glass", [(ga, lo + 0.08, zf + track), (gb, lo + 0.08, zf + track), (gb, hi - 0.08, zf + track),
					(ga, hi - 0.08, zf + track)], (0, 0, -1))
		# Burglar bars outside: a flat-bar frame and round bars every 12 cm, two flat cross bars.
		zb = z_out - 0.04
		part.gbox("W1Iron", (a + 0.02, lo + 0.02, zb - 0.012), (b - 0.02, lo + 0.06, zb + 0.012))
		part.gbox("W1Iron", (a + 0.02, hi - 0.06, zb - 0.012), (b - 0.02, hi - 0.02, zb + 0.012))
		for y in (lo + 0.55, hi - 0.55):
			part.gbox("W1Iron", (a + 0.02, y - 0.02, zb - 0.006), (b - 0.02, y + 0.02, zb + 0.006))
		n = int((b - a - 0.1) / 0.12)
		for k in range(n + 1):
			x = a + 0.05 + k * (b - a - 0.1) / n
			part.pipe("W1Iron", [(x, lo + 0.02, zb), (x, hi - 0.02, zb)], 0.007, sides=6, cap=False)
		for x in (a + 0.02, b - 0.02):
			part.gbox("W1Iron", (x - 0.012, lo + 0.02, zb - 0.012), (x + 0.012, hi - 0.02, z_out))
		# Outside concrete sill (5 cm proud, drip edge).
		part.gbox("W1Concrete", (a - 0.06, lo - 0.05, z_out - 0.07), (b + 0.06, lo, z_out + 0.002))
	part.bm.normal_update()
	glass.bm.normal_update()
	export("windows.glb", [build(part, {"W1Alu": 1.0, "W1Iron": 1.0, "W1Concrete": 0.8}), build(glass, {"W2Glass": 1.0})])


# ------------------------------------------------------------------------------------------------ ceilings

MISSING = [(176.75, 22.25), (186.95, 33.65), (199.55, 40.85), (199.55, 40.25), (205.15, 25.85), (172.55, 38.45)]
SAGGING = [(181.55, 34.25, 6.0), (200.75, 41.45, -7.0)]


def build_ceiling_panels():
	w1kit.reset()
	part = GPart("CeilingPanels")
	x0, x1 = L.HALL["x"][0] + L.T, L.HALL["x"][1] - L.T
	z0, z1 = L.HALL["z"][0] + L.T, L.HALL["z"][1] - L.T
	y = L.CEIL
	p = 0.6
	cells = set()
	for cx, cz in MISSING + [(s[0], s[1]) for s in SAGGING]:
		cells.add((math.floor((cx - 170.0) / p), math.floor((cz - 20.0) / p)))
	# The ceiling as quads of whole panels (row by row), leaving out the missing and sagging cells.
	nx, nz = int(round((x1 - x0) / p)) + 1, int(round((z1 - z0) / p)) + 1
	faces = []
	for j in range(nz):
		za, zb = max(z0, 20.0 + j * p), min(z1, 20.0 + (j + 1) * p)
		if zb <= za:
			continue
		i = 0
		while i < nx:
			if (i, j) in cells:
				i += 1
				continue
			k = i
			while k < nx and (k, j) not in cells:
				k += 1
			xa, xb = max(x0, 170.0 + i * p), min(x1, 170.0 + k * p)
			if xb > xa:
				faces.append(part.face("W6CeilingPanel", [(xa, y, za), (xb, y, za), (xb, y, zb), (xa, y, zb)], (0, -1, 0)))
			i = k
	# The kitchen opening's bulkhead is in hall_shell; the grid's T-bars round each hole (white).
	for (i, j) in cells:
		xa, za = 170.0 + i * p, 20.0 + j * p
		for lo, hi in (((xa - 0.012, y - 0.03, za), (xa + 0.012, y, za + p)), ((xa + p - 0.012, y - 0.03, za), (xa + p + 0.012, y, za + p)),
				((xa, y - 0.03, za - 0.012), (xa + p, y, za + 0.012)), ((xa, y - 0.03, za + p - 0.012), (xa + p, y, za + p + 0.012))):
			part.gbox("W1Enamel", lo, hi)
		part.face("W6Plenum", [(xa, L.ROOF_UNDER - 0.01, za), (xa + p, L.ROOF_UNDER - 0.01, za), (xa + p, L.ROOF_UNDER - 0.01, za + p),
			(xa, L.ROOF_UNDER - 0.01, za + p)], (0, -1, 0))
	part.map_uv2(faces, lambda q: L.floor_uv2(q[0], q[2]))
	# Sagging panels: hinged on one edge, dropped 20..30 degrees; a fallen one on the floor under a hole.
	sag_faces = []
	for cx, cz, ang in SAGGING:
		i, j = math.floor((cx - 170.0) / p), math.floor((cz - 20.0) / p)
		xa, za = 170.0 + i * p, 20.0 + j * p
		drop = math.radians(abs(ang) * 4)
		dz = p * math.cos(drop)
		dy = p * math.sin(drop)
		sag_faces.append(part.face("W6CeilingPanel", [(xa + 0.01, y, za), (xa + p - 0.01, y, za), (xa + p - 0.01, y - dy, za + dz), (xa + 0.01, y - dy, za + dz)],
			(0, -1, -0.3)))
		sag_faces.append(part.face("W6CeilingPanel", [(xa + 0.01, y + 0.012, za), (xa + 0.01, y + 0.012 - dy, za + dz), (xa + p - 0.01, y + 0.012 - dy, za + dz),
			(xa + p - 0.01, y + 0.012, za)], (0, 1, 0.3)))
	part.map_uv2(sag_faces, lambda q: L.floor_uv2(q[0], q[2]))
	fallen = part.gbox("W6CeilingPanel", (176.5, G + 0.004, 22.0), (177.1, G + 0.016, 22.6))
	part.map_uv2(fallen, lambda q: L.floor_uv2(q[0], q[2]))
	part.bm.normal_update()
	export("ceiling_panels.glb", [build(part, {"W1Enamel": 1.0, "W6Plenum": 1.0})])


def build_ceiling_roof():
	"""C1: the hall's roof seen from below: corrugated sheet sloping gently from a ridge over z 32 to the eaves, on
	galvanised C purlins every 1.2 m, carried by painted steel I rafters every 5 m (x 175, 180, ... 205)."""
	w1kit.reset()
	sheet = GPart("RoofSheet")
	steel = GPart("RoofSteel")
	x0, x1 = L.HALL["x"][0] + L.T, L.HALL["x"][1] - L.T
	z0, z1 = L.HALL["z"][0] + L.T, L.HALL["z"][1] - L.T
	ridge, eave = -5.5, -5.78
	def sy(z):  # noqa: E306
		return ridge + (eave - ridge) * abs(z - 32.0) / (z1 - 32.0)
	# Corrugation by geometry across x (76 mm pitch, 18 mm deep) would be heavy: the sheet texture carries it; the
	# sheet is built in 1.2 m strips with a 1 cm step at each lap.
	z = z0
	faces = []
	while z < z1 - 1e-6:
		zb = min(z1, z + 1.2)
		faces.append(sheet.face("W4RoofSheet", [(x0, sy(z), z), (x1, sy(z), z), (x1, sy(zb), zb), (x0, sy(zb), zb)], (0, -1, 0)))
		z = zb
	for rx in range(175, 210, 5):
		zz = z0
		pts = [(rx, sy(z0) - 0.02, z0), (rx, ridge - 0.02, 32.0), (rx, sy(z1) - 0.02, z1)]
		for (pa, pb) in zip(pts, pts[1:]):
			steel.beam("W4SteelFrame", (pa[0], pa[1] - 0.17, pa[2]), (pb[0], pb[1] - 0.17, pb[2]), 0.012, 0.3)
			steel.beam("W4SteelFrame", (pa[0], pa[1] - 0.012, pa[2]), (pb[0], pb[1] - 0.012, pb[2]), 0.15, 0.012)
			steel.beam("W4SteelFrame", (pa[0], pa[1] - 0.318, pa[2]), (pb[0], pb[1] - 0.318, pb[2]), 0.15, 0.012)
		del zz
	for k in range(21):
		pz = z0 + 0.3 + k * 1.15
		if pz > z1 - 0.2:
			break
		y = sy(pz) - 0.01
		steel.beam("W4PoleSteel", (x0, y - 0.075, pz), (x1, y - 0.075, pz), 0.05, 0.15)
	# Tie rods, a gutter-side wall plate.
	for pz in (z0 + 0.1, z1 - 0.1):
		steel.beam("W4PoleSteel", (x0, sy(pz) - 0.06, pz), (x1, sy(pz) - 0.06, pz), 0.12, 0.08)
	sheet.bm.normal_update()
	steel.bm.normal_update()
	export("ceiling_roof.glb", [build(sheet, {"W4RoofSheet": 1.0}), build(steel, {"W4SteelFrame": 1.0, "W4PoleSteel": 1.0})])


def build_lights_fans():
	w1kit.reset()
	body = GPart("Battens")
	tube = GPart("Tubes")
	fans = GPart("Fans")
	y = L.CEIL
	for (x, z) in L.TUBES:
		# A 1.25 m batten under the ceiling, a bare tube under it (one batten's tube gone dark: the PS1 had none lit).
		body.gbox("W1Enamel", (x - 0.62, y - 0.05, z - 0.045), (x + 0.62, y, z + 0.045))
		for zz in (z - 0.045, z + 0.045):
			body.gbox("W1Enamel", (x - 0.62, y - 0.065, zz - 0.004), (x + 0.62, y - 0.05, zz + 0.004))
		for xx in (x - 0.6, x + 0.6):
			body.gbox("W1Enamel", (xx - 0.02, y - 0.09, z - 0.02), (xx + 0.02, y - 0.05, z + 0.02))
		tube.pipe("W2Tube", [(x - 0.58, y - 0.075, z), (x + 0.58, y - 0.075, z)], 0.013, sides=8)
		# Hangers up to the roof (hidden above C2, seen under C1).
		for xx in (x - 0.4, x + 0.4):
			body.pipe("W4PoleSteel", [(xx, y, z), (xx, -5.5, z)], 0.003, sides=4, cap=False)
	rnd = random.Random(26302)
	for fx, fz, yaw in L.FANS:
		hub_y = -6.2
		fans.pipe("W6FanPaint", [(fx, hub_y + 0.1, fz), (fx, -5.45, fz)], 0.013, sides=8)
		fans.cylinder("W6FanPaint", tuple(B((fx, y - 0.04, fz))), 0.07, 0.08, segments=12)
		fans.cylinder("W6FanPaint", tuple(B((fx, hub_y, fz))), 0.11, 0.16, segments=16, radius2=0.09)
		fans.cylinder("W6FanPaint", tuple(B((fx, hub_y - 0.1, fz))), 0.06, 0.06, segments=12, radius2=0.03)
		for k in range(3):
			a = math.radians(yaw + k * 120)
			d = Vector((math.cos(a), math.sin(a), 0))
			side = Vector((-d.y, d.x, 0))
			c = B((fx, hub_y - 0.06, fz))
			droop = rnd.uniform(0.0, 0.03)
			p0, p1 = c + d * 0.12, c + d * 0.7 + Vector((0, 0, -droop))
			ww0, ww1 = 0.05, 0.075
			v = [p0 - side * ww0, p0 + side * ww0, p1 + side * ww1, p1 - side * ww1]
			made = [fans.bm.verts.new(t) for t in v]
			f1 = fans.bm.faces.new(made)
			f2 = fans.bm.faces.new(list(reversed([fans.bm.verts.new(t + Vector((0, 0, -0.006))) for t in v])))
			for f in (f1, f2):
				f.material_index = fans.slot("W6FanPaint")
	body.bm.normal_update()
	tube.bm.normal_update()
	fans.bm.normal_update()
	export("lights_fans.glb", [build(body, {"W1Enamel": 1.0, "W4PoleSteel": 1.0}), build(tube, {"W2Tube": 1.0}),
		build(fans, {"W6FanPaint": 1.0})])


# ------------------------------------------------------------------------------------------------ tables

def stool_colour(k):
	return "W1RedPlastic" if L.STOOL_COLOURS[k] == "red" else "W6PlasticBlue"


def build_tables_inox():
	w1kit.reset()
	steel = w1kit.Part("TablesSteel")
	seats = w1kit.Part("TablesSeats")
	tl, td, top = L.TABLE["len"] / 2, L.TABLE["depth"] / 2, L.TABLE["top"]
	for name, (x, z), yaw in L.tables():
		m = yaw_matrix(x, G, z, yaw)
		lbox(steel, m, "W6Stainless", (-tl, top - 0.025, -td), (tl, top, td), bevel=0.01)
		lbox(steel, m, "W6Stainless", (-tl + 0.02, top - 0.06, -td + 0.02), (tl - 0.02, top - 0.025, -td + 0.035))
		lbox(steel, m, "W6Stainless", (-tl + 0.02, top - 0.06, td - 0.035), (tl - 0.02, top - 0.025, td - 0.02))
		for sx in (-1.05, 1.05):
			lbox(steel, m, "W6Stainless", (sx - 0.015, top - 0.06, -td + 0.02), (sx + 0.015, top - 0.025, td - 0.02))
			for sz in (-0.28, 0.28):
				lbox(steel, m, "W6Stainless", (sx - 0.017, 0.0, sz - 0.017), (sx + 0.017, top - 0.025, sz + 0.017))
				lbox(steel, m, "W6Stainless", (sx - 0.022, 0.0, sz - 0.022), (sx + 0.022, 0.012, sz + 0.022))
			# The base: a foot rail across, out to the stool bars.
			lbox(steel, m, "W6Stainless", (sx - 0.015, 0.17, -0.5), (sx + 0.015, 0.2, 0.5))
		for sz in (-0.5, 0.5):
			lbox(steel, m, "W6Stainless", (-1.07, 0.17, sz - 0.016), (1.07, 0.2, sz + 0.016))
		for k, (lx, lz) in enumerate(L.STOOLS):
			arm_z = 0.5 if lz > 0 else -0.5
			lbox(steel, m, "W6Stainless", (lx - 0.015, 0.17, min(arm_z, lz)), (lx + 0.015, 0.2, max(arm_z, lz)))
			lcyl(steel, m, "W6Stainless", (lx, 0.31, lz), 0.02, 0.26, segs=8)
			lcyl(steel, m, "W6Stainless", (lx, 0.43, lz), 0.12, 0.012, segs=12)
			lcyl(seats, m, stool_colour(k), (lx, 0.452, lz), 0.17, 0.032, segs=16)
	export("tables_inox.glb", [steel.build(uv_size={"W6Stainless": 1.0}), seats.build()])


def _plastic_stool(part, colour, m):
	"""A tall round plastic stool (45 cm), local origin on the floor under its centre."""
	part.cylinder(colour, tuple(gl(0, 0.435, 0)), 0.15, 0.03, segments=16, matrix=m)
	part.cylinder(colour, tuple(gl(0, 0.395, 0)), 0.14, 0.05, segments=16, radius2=0.15, cap=False, matrix=m)
	for k in range(4):
		a = math.radians(45 + 90 * k)
		top = (math.cos(a) * 0.1, 0.38, math.sin(a) * 0.1)
		foot = (math.cos(a) * 0.17, 0.0, math.sin(a) * 0.17)
		d = Vector(foot) - Vector(top)
		mid = (Vector(top) + Vector(foot)) / 2
		axis = Vector((d.x, -d.z, d.y)).normalized()
		rot = Vector((0, 0, 1)).rotation_difference(axis).to_matrix().to_4x4()
		part.box(colour, (-0.018, -0.024, -d.length / 2), (0.018, 0.024, d.length / 2), segments=1,
			matrix=m @ Matrix.Translation(gl(*mid)) @ rot)
	part.cylinder(colour, tuple(gl(0, 0.15, 0)), 0.14, 0.02, segments=12, cap=False, matrix=m)


def build_tables_stone(mess=False):
	w1kit.reset()
	frame = w1kit.Part("StoneFrames")
	tops = w1kit.Part("StoneTops")
	stools = w1kit.Part("Stools")
	tl, td, top = L.TABLE["len"] / 2, L.TABLE["depth"] / 2, L.TABLE["top"]
	rnd = random.Random(26303)
	for name, (x, z), yaw in L.tables():
		m = yaw_matrix(x, G, z, yaw)
		lbox(tops, m, "W1Granite", (-tl, top - 0.03, -td), (tl, top, td), bevel=0.006)
		lbox(frame, m, "W1Iron", (-tl + 0.08, top - 0.08, -td + 0.06), (tl - 0.08, top - 0.03, -td + 0.09))
		lbox(frame, m, "W1Iron", (-tl + 0.08, top - 0.08, td - 0.09), (tl - 0.08, top - 0.03, td - 0.06))
		for sx in (-1.0, 1.0):
			lbox(frame, m, "W1Iron", (sx - 0.02, top - 0.08, -td + 0.06), (sx + 0.02, top - 0.03, td - 0.06))
			for sz in (-0.28, 0.28):
				lbox(frame, m, "W1Iron", (sx - 0.02, 0.0, sz - 0.02), (sx + 0.02, top - 0.03, sz + 0.02))
			lbox(frame, m, "W1Iron", (sx - 0.015, 0.12, -0.28), (sx + 0.015, 0.15, 0.28))
		lbox(frame, m, "W1Iron", (-1.0, 0.12, -0.015), (1.0, 0.15, 0.015))
		for k, (lx, lz) in enumerate(L.STOOLS):
			colour = stool_colour(k)
			jx, jz, jyaw = rnd.uniform(-0.08, 0.08), rnd.uniform(-0.05, 0.03) * (1 if lz > 0 else -1), rnd.uniform(0, 90)
			knocked = mess and rnd.random() < 0.34
			if not knocked:
				wx, wz = L.local_to_world((x, z), yaw, lx + jx, lz + jz)
				_plastic_stool(stools, colour, yaw_matrix(wx, G, wz, jyaw))
			else:
				# On its side, seat outward, inside the table's collider (|z| <= 1.0 locally).
				side = 1 if lz > 0 else -1
				wx, wz = L.local_to_world((x, z), yaw, lx + jx, side * 0.72)
				lie = Matrix.Rotation(math.radians(90 * side), 4, "X") @ Matrix.Translation(Vector((0, 0, -0.15)))
				_plastic_stool(stools, colour, yaw_matrix(wx, G + 0.15, wz, yaw + rnd.uniform(-35, 35)) @ lie)
	export("tables_stone_mess.glb" if mess else "tables_stone.glb",
		[tops.build(uv_size={"W1Granite": 1.0}), frame.build(), stools.build()])


# ------------------------------------------------------------------------------------------------ tableware

def _tray(part, x, y, z, yaw, rnd, flip=False, tilt=None):
	"""A stainless 5-compartment tray (42 x 32 cm), local origin at its bottom centre."""
	m = yaw_matrix(x, y, z, yaw, tilt)
	if flip:
		m = m @ Matrix.Rotation(math.pi, 4, "X") @ Matrix.Translation(Vector((0, 0, -0.022)))
	lbox(part, m, "W6Stainless", (-0.21, 0.0, -0.16), (0.21, 0.004, 0.16))
	for lo, hi in (((-0.21, 0.0, -0.16), (0.21, 0.022, -0.15)), ((-0.21, 0.0, 0.15), (0.21, 0.022, 0.16)),
			((-0.21, 0.0, -0.15), (-0.2, 0.022, 0.15)), ((0.2, 0.0, -0.15), (0.21, 0.022, 0.15))):
		lbox(part, m, "W6Stainless", lo, hi)
	lbox(part, m, "W6Stainless", (-0.2, 0.004, 0.0), (0.2, 0.016, 0.008))
	for sx in (-0.07, 0.07):
		lbox(part, m, "W6Stainless", (sx - 0.004, 0.004, -0.15), (sx + 0.004, 0.016, 0.0))
	return m


def _food(ware, m, rnd, eaten):
	"""Leftovers in a tray's compartments (palette cells); `eaten` 0..1 how much is gone."""
	if rnd.random() < 0.85:
		h = 0.03 * (1 - eaten) + 0.006
		f = ware.cylinder("W6Palette", tuple(gl(0.0, 0.004 + h / 2, 0.08)), 0.11 * (1 - 0.4 * eaten) + 0.03, h, segments=8,
			radius2=0.05, matrix=m)
		cell_uv(ware, f, "rice", rnd)
	for sx, key in ((-0.14, rnd.choice(["greens", "pork", "tofu"])), (0.0, rnd.choice(["pork", "egg", "greens"])),
			(0.14, rnd.choice(["tofu", "greens", "fish_sauce"]))):
		if rnd.random() < 0.7 - 0.4 * eaten:
			f = lbox(ware, m, "W6Palette", (sx - 0.05, 0.004, -0.13), (sx + 0.05, 0.004 + rnd.uniform(0.006, 0.016), -0.03))
			cell_uv(ware, f, key, rnd)


def _bowl(ware, x, y, z, rnd, tipped=False, yaw=0.0):
	m = yaw_matrix(x, y, z, yaw)
	if tipped:
		m = m @ Matrix.Translation(Vector((0, 0, 0.045))) @ Matrix.Rotation(math.radians(80), 4, "X") @ Matrix.Translation(Vector((0, 0, -0.035)))
	prof = [(0.033, 0.0), (0.036, 0.004), (0.05, 0.02), (0.062, 0.045), (0.066, 0.062), (0.06, 0.062), (0.054, 0.045), (0.036, 0.012), (0.0, 0.012)]
	f = ware.lathe("W6Palette", prof, segments=12, matrix=m, smooth=True, close_ends=False)
	cell_uv(ware, f, "porcelain", rnd)
	band = ware.lathe("W6Palette", [(0.0662, 0.054), (0.0668, 0.06)], segments=12, matrix=m, smooth=True, close_ends=False)
	cell_uv(ware, band, "bowl_blue", rnd)
	if not tipped and rnd.random() < 0.6:
		s = ware.cylinder("W6Palette", (0, 0, 0.032), 0.05, 0.002, segments=10, matrix=m)
		cell_uv(ware, s, rnd.choice(["broth", "noodle", "broth"]), rnd)


def _chopsticks(ware, x, y, z, yaw, rnd, key="chopstick"):
	m = yaw_matrix(x, y, z, yaw)
	for dz in (-0.006, 0.006):
		f = lbox(ware, m, "W6Palette", (-0.115, 0.0, dz - 0.0035), (0.115, 0.007, dz + 0.0035))
		cell_uv(ware, f, key, rnd)


def _spill(ware, x, z, rx, rz, rnd, key="spill"):
	n = 11
	pts = []
	for k in range(n):
		a = k / n * math.tau
		r = rnd.uniform(0.6, 1.0)
		pts.append((x + math.cos(a) * rx * r, G + 0.004, z + math.sin(a) * rz * r))
	f = ware.face("W6Palette", pts, (0, 1, 0))
	cell_uv(ware, [f], key, rnd)


def build_tableware(mess=False):
	w1kit.reset()
	trays = GPart("Trays")
	ware = GPart("Ware")
	rnd = random.Random(26304)
	tables = {n: (c, y) for n, c, y in L.tables()}
	top = G + L.TABLE["top"]
	bowls = L.table_items("Bowl")
	sticks = L.table_items("Chopsticks")
	for i, (table, pos, yaw) in enumerate(L.table_items("Tray")):
		m = _tray(trays, pos[0], top, pos[2], yaw, rnd)   # survey yaws are global
		_food(ware, m, rnd, rnd.uniform(0.2, 0.9))
	for i, (table, pos, yaw) in enumerate(bowls):
		tipped = mess and rnd.random() < 0.55
		_bowl(ware, pos[0], top + 0.022, pos[2], rnd, tipped=tipped, yaw=rnd.uniform(0, 360))
	for i, (table, pos, yaw) in enumerate(sticks):
		_chopsticks(ware, pos[0], top + 0.022, pos[2], yaw + rnd.uniform(-12, 12), rnd)
	# The six fallen trays (PS1 FloorTray*): face down or on edge against nothing, food and soup spilled round them.
	for name, pos, yaw in L.floor_items("FloorTray"):
		_tray(trays, pos[0], G + 0.003, pos[2], yaw, rnd, flip=rnd.random() < 0.6)
	for name, pos, yaw in L.floor_items("Spill"):
		_spill(ware, pos[0], pos[2], 0.38, 0.27, rnd)
		_spill(ware, pos[0] - 0.15, pos[2] + 0.1, 0.12, 0.09, rnd, "rice")
	if mess:
		# More trays, bowls and chopsticks in the aisles (none on the walk lines' centres is needed: no colliders).
		extra = [(176.0, 25.0), (181.2, 29.6), (186.5, 31.0), (188.8, 26.4), (192.6, 30.2), (194.4, 34.8), (199.2, 29.8),
			(204.1, 30.1), (183.0, 34.9), (178.2, 39.6), (196.0, 39.8), (207.8, 35.2), (189.4, 41.6), (172.4, 30.0),
			(174.6, 35.4), (175.6, 38.7), (176.9, 34.4), (174.3, 29.9), (177.6, 30.4), (180.4, 25.2), (183.4, 25.5),
			(185.4, 29.3), (181.0, 34.6), (186.2, 37.6), (179.8, 39.9), (184.0, 40.0), (176.0, 40.3), (172.0, 39.6),
			(188.0, 33.0), (190.5, 28.0), (193.5, 38.5), (171.6, 26.0), (178.0, 21.8), (184.8, 22.4)]
		for x, z in extra:
			k = rnd.random() * 0.9
			if k < 0.45:
				_tray(trays, x, G + 0.003, z, rnd.uniform(0, 360), rnd, flip=rnd.random() < 0.5)
				_spill(ware, x + 0.2, z + 0.15, 0.3, 0.22, rnd)
			elif k < 0.75:
				_bowl(ware, x, G + 0.002, z, rnd, tipped=True, yaw=rnd.uniform(0, 360))
				_spill(ware, x + 0.1, z, 0.18, 0.12, rnd, "broth")
			else:
				_chopsticks(ware, x, G + 0.002, z, rnd.uniform(0, 180), rnd)
				_chopsticks(ware, x + 0.3, G + 0.002, z - 0.2, rnd.uniform(0, 180), rnd, "chopstick_red")
			# Broken bowl shards.
			for s in range(rnd.randrange(0, 3)):
				sx, sz = x + rnd.uniform(-0.5, 0.5), z + rnd.uniform(-0.5, 0.5)
				f = ware.face("W6Palette", [(sx, G + 0.006, sz), (sx + 0.05, G + 0.006, sz + 0.02), (sx + 0.02, G + 0.006, sz + 0.06)], (0, 1, 0))
				cell_uv(ware, [f], "porcelain", rnd)
	trays.bm.normal_update()
	ware.bm.normal_update()
	export("tableware_mess.glb" if mess else "tableware.glb", [build(trays, {"W6Stainless": 1.0}), build(ware, {"W6Palette": 1.0})])


# ------------------------------------------------------------------------------------------------ counter

PANS = [171.6 + 1.2 * k for k in range(12)]
PAN_FOOD = ["pork", "greens", "tofu", "egg", "fish_sauce", "greens", "pork", "noodle", "broth", "greens", "tofu", "egg"]


def _counter_top_and_pans(part, ware, rnd):
	x0, x1 = L.COUNTER["x"]
	z0, z1 = L.COUNTER["z"]
	ty = -8.99
	wz0, wz1 = 42.3, 42.72
	wx0, wx1 = PANS[0] - 0.3, PANS[-1] + 0.3
	for lo, hi in (((x0, ty - 0.03, z0), (x1, ty, wz0)), ((x0, ty - 0.03, wz1), (x1, ty, z1)), ((x0, ty - 0.03, wz0), (wx0, ty, wz1)),
			((wx1, ty - 0.03, wz0), (x1, ty, wz1))):
		part.gbox("W6Stainless", lo, hi)
	part.gbox("W6Stainless", (wx0, ty - 0.17, wz0), (wx1, ty - 0.16, wz1))
	for x, key in zip(PANS, PAN_FOOD):
		a, b = x - 0.25, x + 0.25
		part.gbox("W6Stainless", (a, ty - 0.003, wz0 - 0.01), (b, ty + 0.004, wz0 + 0.012))
		part.gbox("W6Stainless", (a, ty - 0.003, wz1 - 0.012), (b, ty + 0.004, wz1 + 0.01))
		part.gbox("W6Stainless", (a, ty - 0.003, wz0), (a + 0.012, ty + 0.004, wz1))
		part.gbox("W6Stainless", (b - 0.012, ty - 0.003, wz0), (b, ty + 0.004, wz1))
		level = ty - rnd.uniform(0.04, 0.09)
		f = ware.face("W6Palette", [(a + 0.012, level, wz0 + 0.012), (b - 0.012, level, wz0 + 0.012), (b - 0.012, level, wz1 - 0.012),
			(a + 0.012, level, wz1 - 0.012)], (0, 1, 0))
		cell_uv(ware, [f], key, rnd)
		for _ in range(rnd.randrange(2, 6)):
			px, pz = rnd.uniform(a + 0.05, b - 0.05), rnd.uniform(wz0 + 0.05, wz1 - 0.05)
			s = rnd.uniform(0.025, 0.05)
			g = ware.gbox("W6Palette", (px - s, level, pz - s * 0.7), (px + s, level + rnd.uniform(0.01, 0.025), pz + s * 0.7))
			cell_uv(ware, g, key, rnd)
		# A ladle in every other pan, its handle on the rim.
		if rnd.random() < 0.6:
			ware.pipe("W6Stainless", [(x + 0.05, level + 0.02, 42.5), (x + 0.12, ty + 0.06, 42.42), (x + 0.15, ty + 0.12, 42.3)], 0.006, sides=6)


def _sneeze_and_rails(part, glass):
	x0, x1 = L.COUNTER["x"]
	ty = -8.99
	posts = [x0 + 0.05 + k * (x1 - x0 - 0.1) / 10 for k in range(11)]
	lean = math.radians(20)
	gz = 41.98
	gy0, gh = ty + 0.12, 0.5
	for x in posts:
		part.pipe("W6Stainless", [(x, ty, gz + 0.02), (x, gy0 + gh * math.cos(lean), gz + 0.02 - gh * math.sin(lean))], 0.012, sides=8)
	part.pipe("W6Stainless", [(x0 + 0.05, gy0 + gh * math.cos(lean), gz + 0.02 - gh * math.sin(lean)),
		(x1 - 0.05, gy0 + gh * math.cos(lean), gz + 0.02 - gh * math.sin(lean))], 0.014, sides=8)
	for a, b in zip(posts, posts[1:]):
		glass.face("W2Glass", [(a + 0.02, gy0, gz), (b - 0.02, gy0, gz), (b - 0.02, gy0 + gh * math.cos(lean), gz - gh * math.sin(lean)),
			(a + 0.02, gy0 + gh * math.cos(lean), gz - gh * math.sin(lean))], (0, 0.3, -1))
	# Tray slide on the customer side (where the PS1 TrayRail lay), on brackets.
	for rz in (41.66, 41.76, 41.86):
		part.pipe("W6Stainless", [(x0, -9.05, rz), (x1, -9.05, rz)], 0.011, sides=8)
	for x in posts[::2]:
		part.gbox("W6Stainless", (x - 0.01, -9.08, 41.62), (x + 0.01, -9.05, 41.92))


def _counter_extras(part, ware, rnd):
	# Rice warmers (RiceBucket0..2), the tray stand and card reader by the counter's west end, the queue rail.
	for k, x in enumerate((182.6, 183.3, 184.0)):
		part.cylinder("W6Stainless", tuple(B((x, -8.73, 42.5))), 0.24, 0.48, segments=16)
		part.cylinder("W6Stainless", tuple(B((x, -8.48, 42.5))), 0.245, 0.03, segments=16)
		part.cylinder("W1Black", tuple(B((x, -8.45, 42.5))), 0.04, 0.03, segments=8)
		for s in (-1, 1):
			part.gbox("W1Black", (x + s * 0.24, -8.6, 42.47), (x + s * 0.27, -8.57, 42.53))
	sx, sz = 170.9, 41.0
	for dx in (-0.18, 0.18):
		for dz in (-0.13, 0.13):
			part.pipe("W6Stainless", [(sx + dx, G, sz + dz), (sx + dx, -8.97, sz + dz)], 0.012, sides=6)
	part.gbox("W6Stainless", (sx - 0.22, -8.98, sz - 0.17), (sx + 0.22, -8.96, sz + 0.17))
	part.gbox("W6Stainless", (sx - 0.22, -9.6, sz - 0.17), (sx + 0.22, -9.58, sz + 0.17))
	for k in range(8):
		_tray(part, sx, -8.96 + k * 0.024, sz, 90 + rnd.uniform(-4, 4), rnd)
	cx, cz = 171.0, 41.5
	part.pipe("W6Stainless", [(cx, G, cz), (cx, -8.9, cz)], 0.02, sides=8)
	part.cylinder("W6Stainless", tuple(B((cx, G + 0.005, cz))), 0.12, 0.01, segments=12)
	f = part.gbox("W6Palette", (cx - 0.06, -8.9, cz - 0.05), (cx + 0.06, -8.6, cz + 0.05))
	cell_uv(part, f, "blue_plastic", rnd)
	f = part.gbox("W6Palette", (cx - 0.045, -8.72, cz - 0.052), (cx + 0.045, -8.64, cz - 0.05))
	cell_uv(part, f, "led_green", rnd)
	for k in range(5):
		x = 171.5 + k * 3.25
		part.pipe("W6Stainless", [(x, G + 0.02, 40.8), (x, -9.0, 40.8)], 0.025, sides=10)
		part.cylinder("W6Stainless", tuple(B((x, G + 0.01, 40.8))), 0.15, 0.02, segments=14)
	part.pipe("W6Stainless", [(171.5, -9.0, 40.8), (184.5, -9.0, 40.8)], 0.02, sides=8)
	part.pipe("W6Stainless", [(171.5, -9.45, 40.8), (184.5, -9.45, 40.8)], 0.012, sides=6)


def build_counter(kind):
	w1kit.reset()
	part = GPart("Counter")
	glass = GPart("SneezeGlass")
	ware = GPart("PanFood")
	rnd = random.Random(26305)
	x0, x1 = L.COUNTER["x"]
	z0, z1 = L.COUNTER["z"]
	if kind == "inox":
		part.gbox("W6Stainless", (x0 + 0.05, G + 0.12, z0 + 0.04), (x1 - 0.05, -9.02, z1 - 0.02))
		part.gbox("W1Black", (x0 + 0.1, G, z0 + 0.1), (x1 - 0.1, G + 0.12, z1 - 0.05))
		for k in range(11):   # panel seams on the customer face
			x = x0 + 0.05 + k * (x1 - x0 - 0.1) / 10
			part.gbox("W1Black", (x - 0.003, G + 0.13, z0 + 0.037), (x + 0.003, -9.04, z0 + 0.04))
	else:
		faces = part.gbox("W6CounterTile", (x0 + 0.03, G, z0 + 0.03), (x1 - 0.03, -9.02, z1 - 0.02))
		part.map_uv2(faces, lambda q: L.wall_uv2(0, q[0] - 170.0 + 88.0, q[1], 128.0))
		part.gbox("W1Concrete", (x0 + 0.02, G, z0 + 0.02), (x1 - 0.02, G + 0.1, z1 - 0.01))
		part.gbox("W6Stainless", (x0, -9.03, z0 - 0.01), (x1, -9.0, z0 + 0.04))
	_counter_top_and_pans(part, ware, rnd)
	_sneeze_and_rails(part, glass)
	_counter_extras(part, ware, rnd)
	for p in (part, glass, ware):
		p.bm.normal_update()
	export("counter_%s.glb" % kind, [build(part, {"W6Stainless": 1.0, "W1Black": 1.0, "W1Concrete": 0.8, "W6Palette": 1.0}),
		build(glass, {"W2Glass": 1.0}), build(ware, {"W6Palette": 1.0, "W6Stainless": 1.0})])


def build_price_boards():
	"""Five boards (2.6 x 0.7 x 0.035) where PriceBoard0..4 hang, on two short chains each; front face mapped to its
	cell of price_*.png (make_wave6_textures.price_uv), edges to the cell's frame."""
	w1kit.reset()
	part = GPart("PriceBoards")
	wire = GPart("PriceChains")
	zb = L.HALL["z"][1] - L.T - 0.02
	for i, x in enumerate(L.SERVE_X):
		u0, v0, u1, v1 = L.price_uv(i)
		a, b, y0, y1 = x - 1.3, x + 1.3, -7.05, -6.35
		zf = zb - 0.035
		part.face("W6PriceWood", [(a, y0, zf), (b, y0, zf), (b, y1, zf), (a, y1, zf)], (0, 0, -1),
			uv=[(u1, 1 - v1), (u0, 1 - v1), (u0, 1 - v0), (u1, 1 - v0)])  # seen from the hall +x is on the left
		edge = [(u0 + 0.002, 1 - v0 - 0.002)] * 4
		for pts, n in (([(a, y0, zf), (b, y0, zf), (b, y0, zb), (a, y0, zb)], (0, -1, 0)), ([(a, y1, zf), (b, y1, zf), (b, y1, zb), (a, y1, zb)], (0, 1, 0)),
				([(a, y0, zf), (a, y1, zf), (a, y1, zb), (a, y0, zb)], (-1, 0, 0)), ([(b, y0, zf), (b, y1, zf), (b, y1, zb), (b, y0, zb)], (1, 0, 0))):
			part.face("W6PriceWood", pts, n, uv=edge)
		for cx in (a + 0.35, b - 0.35):
			wire.pipe("W1Iron", [(cx, y1, zb - 0.018), (cx, -5.95, zb - 0.01)], 0.003, sides=4, cap=False)
	part.bm.normal_update()
	export("price_boards.glb", [build(part, {"W6PriceWood": 1.0}), build(wire, {"W1Iron": 1.0})])


# ------------------------------------------------------------------------------------------------ TV

def build_tv():
	"""An old 42-inch flat TV (1.2 x 0.75) on an arm bracket, in the PS1 case's box (x 170.12..170.28, y -7.9..-7.1,
	z 31.4..32.6), screen facing +x; the lit screen is a separate glb hung under TV/Screen."""
	w1kit.reset()
	part = GPart("TV")
	cz, cy = L.TV["case"][2], L.TV["case"][1]
	xb, xf = 170.17, 170.27
	part.gbox("W1Black", (xb, cy - 0.39, cz - 0.6), (xf, cy + 0.39, cz + 0.6))
	part.gbox("W1Black", (170.13, cy - 0.2, cz - 0.3), (xb, cy + 0.2, cz + 0.3))
	part.face("W6ScreenOff", [(xf + 0.002, cy - 0.34, cz + 0.555), (xf + 0.002, cy - 0.34, cz - 0.555), (xf + 0.002, cy + 0.34, cz - 0.555),
		(xf + 0.002, cy + 0.34, cz + 0.555)], (1, 0, 0))
	# Bracket plate on the wall and two arms; the power and aerial cables down the wall to the wainscot.
	part.gbox("W1Iron", (170.125 + 0.004, cy - 0.22, cz - 0.12), (170.14, cy + 0.22, cz + 0.12))
	for dy in (-0.12, 0.12):
		part.gbox("W1Iron", (170.14, cy + dy - 0.02, cz - 0.03), (170.13 + 0.05, cy + dy + 0.02, cz + 0.03))
	part.pipe("W1Black", [(170.135, cy - 0.3, cz + 0.4), (170.135, cy - 0.5, cz + 0.45), (170.135, G + 1.42, cz + 0.45)], 0.005, sides=4)
	part.pipe("W1Black", [(170.135, cy - 0.3, cz + 0.35), (170.135, -5.95, cz + 0.6)], 0.004, sides=4)
	f = part.gbox("W6Palette", (170.27, cy - 0.37, cz + 0.45), (170.275, cy - 0.36, cz + 0.47))
	cell_uv(part, f, "led_green")
	part.bm.normal_update()
	export("tv.glb", [build(part, {"W1Black": 1.0, "W1Iron": 1.0, "W6Palette": 1.0})])
	w1kit.reset()
	screen = GPart("Screen")
	screen.face("W6ScreenOn", [(xf + 0.006, cy - 0.34, cz + 0.555), (xf + 0.006, cy - 0.34, cz - 0.555), (xf + 0.006, cy + 0.34, cz - 0.555),
		(xf + 0.006, cy + 0.34, cz + 0.555)], (1, 0, 0), uv=[(0, 0), (1, 0), (1, 1), (0, 1)])
	screen.bm.normal_update()
	export("tv_screen.glb", [build(screen, {"W6ScreenOn": 1.0})])


# ------------------------------------------------------------------------------------------------ kitchen

def build_kitchen_room():
	w1kit.reset()
	part = GPart("KitchenRoom")
	kit = GPart("KitchenThings")
	rnd = random.Random(26306)
	x0, x1 = L.KITCHEN["x"]
	z0, z1 = L.KITCHEN["z"]
	t = L.T
	fl = part.face("W6KitchenFloor", [(x0 + t, G + 0.002, z0), (x1 - t, G + 0.002, z0), (x1 - t, G + 0.002, z1 - t), (x0 + t, G + 0.002, z1 - t)], (0, 1, 0))
	part.map_uv2([fl], lambda q: L.floor_uv2(q[0], q[2]))
	# Tiles to 1.8 m, paint above; soot over the stoves (mask row 1).
	s = 0.0
	for (a, b), n in zip(L.KITCHEN_FACES, ((1, 0, 0), (0, 0, -1), (-1, 0, 0))):
		ax, az = a
		bx, bz = b
		ax += n[0] * INSET
		bx += n[0] * INSET
		az += n[2] * INSET
		bz += n[2] * INSET
		wall_face(part, (ax, az), (bx, bz), G, L.ROOF_UNDER, n, [], 1, s, 80.0, lower="W6Wainscot", upper="W6WallYellow", dado=1.8)
		s += math.hypot(b[0] - a[0], b[1] - a[1])
	cy = L.ROOF_UNDER - 0.003   # just under the PS1 KitchenRoof slab's underside
	ceil = part.face("W6WallYellow", [(x0 + t, cy, z0), (x1 - t, cy, z0), (x1 - t, cy, z1 - t), (x0 + t, cy, z1 - t)], (0, -1, 0))
	part.map_uv2([ceil], lambda q: L.wall_uv2(1, 40.0 + (q[0] - 186.0), -5.6, 80.0))
	# A floor drain channel along the stoves.
	kit.gbox("W6Stainless", (188.0, G + 0.001, 50.2), (196.0, G + 0.006, 50.45))
	for k in range(40):
		x = 188.05 + k * 0.2
		kit.gbox("W1Black", (x, G + 0.006, 50.22), (x + 0.12, G + 0.007, 50.43))
	# Prep table (PrepTable collider x 188.4..189.4, z 44.4..48.8, top -9.0): stainless with an undershelf.
	px0, px1 = L.PREP["x"]
	pz0, pz1 = L.PREP["z"]
	kit.gbox("W6Stainless", (px0 + 0.02, -9.04, pz0 + 0.02), (px1 - 0.02, -9.0, pz1 - 0.02))
	kit.gbox("W6Stainless", (px0 + 0.06, G + 0.15, pz0 + 0.06), (px1 - 0.06, G + 0.17, pz1 - 0.06))
	for lx in (px0 + 0.06, px1 - 0.06):
		for lz in (pz0 + 0.06, (pz0 + pz1) / 2, pz1 - 0.06):
			kit.pipe("W6Stainless", [(lx, G, lz), (lx, -9.04, lz)], 0.02, sides=8)
	f = kit.gbox("W1Wood", (188.66, -9.0, 47.06), (189.14, -8.96, 47.74))
	kit.gbox("W6Stainless", (188.75, -8.96, 46.88), (188.85, -8.955, 47.12))
	f = kit.gbox("W1Wood", (188.78, -8.96, 47.1), (188.82, -8.94, 47.2))
	for k, z in enumerate((45.5, 45.9, 46.3)):
		basket = kit.gbox("W6Palette", (188.86, -9.0, z - 0.13), (189.14, -8.92, z + 0.13))
		cell_uv(kit, basket, "bamboo", rnd)
		for _ in range(5):
			vx, vz = rnd.uniform(188.9, 189.1), rnd.uniform(z - 0.1, z + 0.1)
			g = kit.gbox("W6Palette", (vx - 0.03, -8.92, vz - 0.02), (vx + 0.03, -8.89, vz + 0.02))
			cell_uv(kit, g, ["veg_green", "onion", "chili"][rnd.randrange(3)], rnd)
	# Two industrial rice cookers on the table (RiceCooker0/1).
	for z in (45.0, 46.1):
		f = kit.cylinder("W6Palette", tuple(B((188.9, -8.77, z))), 0.29, 0.46, segments=16)
		cell_uv(kit, f, "white_plastic", rnd)
		f = kit.cylinder("W6Stainless", tuple(B((188.9, -8.52, z))), 0.27, 0.04, segments=16, radius2=0.22)
		kit.gbox("W1Black", (188.85, -8.5, z - 0.08), (188.95, -8.47, z + 0.08))
	# Bamboo steamers stacked 4 high where the PS1 Steamer stacks stand (x 187, z 45.2/46.2/47.2).
	for z in (45.2, 46.2, 47.2):
		for k in range(4):
			y = G + 0.15 + k * 0.32
			f = kit.cylinder("W6Palette", tuple(B((187.0, y, z))), 0.38, 0.28, segments=16, cap=(k == 3))
			cell_uv(kit, f, "bamboo", rnd)
			f = kit.cylinder("W6Palette", tuple(B((187.0, y - 0.13, z))), 0.385, 0.03, segments=16, cap=False)
			cell_uv(kit, f, "wood", rnd)
	# Sink (KitchenSink collider x 186.6..187.8, z 48.85..49.75): a stainless double bowl on legs, tap, splashback.
	sx0, sx1 = L.SINK["x"]
	sz0, sz1 = L.SINK["z"]
	kit.gbox("W6Stainless", (sx0, -9.03, sz0), (sx1, -9.0, sz0 + 0.06))
	kit.gbox("W6Stainless", (sx0, -9.03, sz1 - 0.06), (sx1, -9.0, sz1))
	kit.gbox("W6Stainless", (sx0, -9.03, sz0), (sx0 + 0.04, -9.0, sz1))
	kit.gbox("W6Stainless", (sx1 - 0.04, -9.03, sz0), (sx1, -9.0, sz1))
	kit.gbox("W6Stainless", ((sx0 + sx1) / 2 - 0.02, -9.03, sz0), ((sx0 + sx1) / 2 + 0.02, -9.0, sz1))
	kit.gbox("W6Stainless", (sx0 + 0.04, -9.3, sz0 + 0.06), (sx1 - 0.04, -9.29, sz1 - 0.06))
	for a, b in ((sx0 + 0.04, (sx0 + sx1) / 2 - 0.02), ((sx0 + sx1) / 2 + 0.02, sx1 - 0.04)):
		for lo, hi in (((a, -9.3, sz0 + 0.06), (b, -9.03, sz0 + 0.065)), ((a, -9.3, sz1 - 0.065), (b, -9.03, sz1 - 0.06))):
			kit.gbox("W6Stainless", lo, hi)
	for lx in (sx0 + 0.05, sx1 - 0.05):
		for lz in (sz0 + 0.05, sz1 - 0.05):
			kit.pipe("W6Stainless", [(lx, G, lz), (lx, -9.3, lz)], 0.02, sides=8)
	kit.pipe("W6Stainless", [(187.2, -9.0, 49.7), (187.2, -8.65, 49.7), (187.2, -8.62, 49.55), (187.2, -8.7, 49.45)], 0.012, sides=8)
	# Wall shelf with pots and a ladle rail over the prep table (HangingLadle*), a wall-mounted gas pipe.
	kit.gbox("W6Stainless", (186.15, -8.0, 44.6), (186.45, -7.97, 48.2))
	for z in (45.0, 45.8, 46.8, 47.6):
		f = kit.cylinder("W6PotAlu", tuple(B((186.3, -7.85, z))), 0.13, 0.24, segments=12)
	kit.pipe("W6Stainless", [(186.2, -7.4, 44.6), (186.2, -7.4, 48.2)], 0.008, sides=6)
	for k in range(6):
		z = 44.9 + k * 0.55
		kit.pipe("W6Stainless", [(186.21, -7.4, z), (186.22, -7.85, z)], 0.005, sides=4)
		kit.cylinder("W6Stainless", tuple(B((186.23, -7.9, z))), 0.05, 0.05, segments=8, radius2=0.03)
	kit.pipe("W1Iron", [(188.0, -8.0, 51.84), (196.0, -8.0, 51.84)], 0.012, sides=6)
	for p in (part, kit):
		p.bm.normal_update()
	export("kitchen_room.glb", [build(part), build(kit, {"W6Stainless": 1.0, "W6PotAlu": 1.0, "W1Wood": 1.0, "W1Black": 1.0,
		"W6Palette": 1.0, "W1Iron": 1.0})])


def _hood(part, mat):
	"""A hood in two halves either side of the clock (x 191.45..192.55 left open), joined under a common duct."""
	x0, x1 = 187.8, 196.2
	y0, y1 = -7.62, -6.95
	z0, z1 = 50.6, L.KITCHEN["z"][1] - L.T - 0.01
	for a, b in ((x0, 191.4), (192.6, x1)):
		part.gbox(mat, (a, y1 - 0.05, z0), (b, y1, z1))
		part.face(mat, [(a, y0, z0), (b, y0, z0), (b, y1 - 0.05, z0 + 0.25), (a, y1 - 0.05, z0 + 0.25)], (0, -0.4, -1))
		for xx in (a, b):
			part.face(mat, [(xx, y0, z0), (xx, y1 - 0.05, z0 + 0.25), (xx, y1 - 0.05, z1), (xx, y0, z1)], (-1 if xx == a else 1, 0, 0))
		part.gbox(mat, (a, y0 - 0.02, z0 - 0.01), (b, y0 + 0.02, z0 + 0.03))
		part.gbox("W1Iron", (a + 0.05, y0 + 0.02, z0 + 0.06), (b - 0.05, y0 + 0.03, z1 - 0.06))
	part.gbox(mat, (190.4, y1, 51.2), (193.6, -6.75, z1))
	part.gbox(mat, (191.5, -6.75, 51.2), (192.5, L.ROOF_UNDER, z1))


def build_kitchen(kind):
	w1kit.reset()
	part = GPart("Stove")
	pots = GPart("Pots")
	rnd = random.Random(26307)
	x0, x1 = L.COOKTOP["x"]
	z0, z1 = L.COOKTOP["z"]
	ty = L.COOKTOP["top"]
	burners = [189.0, 191.0, 193.0, 195.0]
	if kind == "k1":
		faces = part.gbox("W6StoveTile", (x0 + 0.02, G, z0 + 0.02), (x1 - 0.02, ty - 0.04, z1))
		part.map_uv2(faces, lambda q: L.wall_uv2(1, q[0] - 186.0 + 8.0, q[1], 80.0))
		faces = part.gbox("W6StoveTile", (x0, ty - 0.04, z0), (x1, ty, z1))
		part.map_uv2(faces, lambda q: L.wall_uv2(1, q[0] - 186.0 + 8.0, 1.0 + G, 80.0))
		for bx in burners:
			# Fire mouths on the front under each burner, the burner ring on top.
			part.gbox("W6Plenum", (bx - 0.18, G + 0.25, z0 + 0.015), (bx + 0.18, G + 0.5, z0 + 0.02))
			part.cylinder("W6CastIron", tuple(B((bx, ty + 0.01, 51.1))), 0.3, 0.02, segments=16, cap=False)
			part.cylinder("W6CastIron", tuple(B((bx, ty + 0.03, 51.1))), 0.22, 0.04, segments=16, radius2=0.26, cap=False)
		for bx in burners[:2]:
			prof = [(0.0, -0.13), (0.1, -0.125), (0.22, -0.09), (0.33, -0.02), (0.37, 0.04), (0.36, 0.04), (0.32, -0.015), (0.21, -0.08),
				(0.1, -0.115), (0.0, -0.12)]
			pots.lathe("W6CastIron", prof, segments=20, matrix=Matrix.Translation(B((bx, ty + 0.17, 51.1))), close_ends=False)
			pots.tube("W1Wood", [B((bx + 0.36, ty + 0.2, 51.05)), B((bx + 0.68, ty + 0.27, 50.98))], 0.016, segments=6)
		for bx in burners[2:]:
			pots.cylinder("W6PotAlu", tuple(B((bx, ty + 0.27, 51.1))), 0.34, 0.46, segments=20, cap=False)
			pots.cylinder("W6PotAlu", tuple(B((bx, ty + 0.045, 51.1))), 0.34, 0.01, segments=20)
			pots.cylinder("W6PotAlu", tuple(B((bx, ty + 0.5, 51.1))), 0.355, 0.02, segments=20, radius2=0.33)
			pots.cylinder("W6PotAlu", tuple(B((bx, ty + 0.53, 51.1))), 0.05, 0.04, segments=8)
			for s in (-1, 1):
				pots.gbox("W6PotAlu", (bx + s * 0.34, ty + 0.4, 51.05), (bx + s * 0.4, ty + 0.43, 51.15))
		# Gas pipes and valves along the back.
		part.pipe("W1Iron", [(x0 + 0.1, ty + 0.06, z1 - 0.08), (x1 - 0.1, ty + 0.06, z1 - 0.08)], 0.015, sides=6)
		for bx in burners:
			part.pipe("W1Black", [(bx, ty + 0.06, z1 - 0.08), (bx, ty + 0.02, 51.4)], 0.008, sides=4)
		_hood(part, "W6Stainless")
	else:
		part.gbox("W6Stainless", (x0 + 0.02, G + 0.12, z0 + 0.03), (x1 - 0.02, ty - 0.02, z1))
		part.gbox("W1Black", (x0 + 0.05, G, z0 + 0.08), (x1 - 0.05, G + 0.12, z1 - 0.05))
		part.gbox("W6Stainless", (x0, ty - 0.02, z0), (x1, ty, z1))
		part.gbox("W6Stainless", (x0, ty, z1 - 0.06), (x1, ty + 0.35, z1))
		for bx in burners:
			part.gbox("W1Black", (bx - 0.36, ty - 0.001, 50.75), (bx + 0.36, ty + 0.002, 51.45))
			part.cylinder("W6CastIron", tuple(B((bx, ty + 0.05, 51.1))), 0.3, 0.1, segments=16, cap=False, radius2=0.25)
			part.cylinder("W6CastIron", tuple(B((bx, ty + 0.01, 51.1))), 0.08, 0.02, segments=10)
			for k in range(3):
				part.cylinder("W1Black", tuple(B((bx - 0.2 + k * 0.2, ty - 0.18, z0 - 0.02))), 0.025, 0.04, axis="Y", segments=8)
			part.gbox("W6Stainless", (bx - 0.38, G + 0.15, z0 + 0.02), (bx - 0.36, ty - 0.08, z0 + 0.025))
		for bx in burners[::3]:
			prof = [(0.0, -0.13), (0.1, -0.125), (0.22, -0.09), (0.33, -0.02), (0.37, 0.04), (0.36, 0.04), (0.32, -0.015), (0.21, -0.08),
				(0.1, -0.115), (0.0, -0.12)]
			pots.lathe("W6CastIron", prof, segments=20, matrix=Matrix.Translation(B((bx, ty + 0.2, 51.1))), close_ends=False)
		for bx in burners[1:3]:
			pots.cylinder("W6Stainless", tuple(B((bx, ty + 0.33, 51.1))), 0.32, 0.46, segments=20, cap=False)
			pots.cylinder("W6Stainless", tuple(B((bx, ty + 0.11, 51.1))), 0.32, 0.01, segments=20)
			pots.cylinder("W6Stainless", tuple(B((bx, ty + 0.57, 51.1))), 0.33, 0.02, segments=20)
		_hood(part, "W6Stainless")
	part.bm.normal_update()
	pots.bm.normal_update()
	export("kitchen_%s.glb" % kind, [build(part, {"W6Stainless": 1.0, "W6CastIron": 1.0, "W1Iron": 1.0, "W6Plenum": 1.0, "W1Black": 1.0,
		"W6Palette": 1.0}), build(pots, {"W6CastIron": 1.0, "W6PotAlu": 1.0, "W1Wood": 1.0, "W6Stainless": 1.0})])


def build_clock():
	"""A plastic wall clock (31 cm) at KitchenClock, dial facing -z (into the kitchen), hands at 4:00 (stopped_hour)."""
	w1kit.reset()
	part = GPart("Clock")
	cx, cy, cz = L.CLOCK
	zw = L.KITCHEN["z"][1] - L.T - INSET
	r = 0.28
	segs = 32
	back = zw - 0.005
	front = zw - 0.055
	ring = [(cx + math.cos(k / segs * math.tau) * r, cy + math.sin(k / segs * math.tau) * r) for k in range(segs)]
	for k in range(segs):
		(ax, ay), (bx, by) = ring[k], ring[(k + 1) % segs]
		part.face("W1ClockCase", [(ax, ay, back), (bx, by, back), (bx, by, front), (ax, ay, front)],
			((ax + bx) / 2 - cx, (ay + by) / 2 - cy, 0))
	inner = [(cx + math.cos(k / segs * math.tau) * (r - 0.03), cy + math.sin(k / segs * math.tau) * (r - 0.03)) for k in range(segs)]
	for k in range(segs):
		(ax, ay), (bx, by) = ring[k], ring[(k + 1) % segs]
		(cx2, cy2), (dx, dy) = inner[(k + 1) % segs], inner[k]
		part.face("W1ClockCase", [(ax, ay, front), (bx, by, front), (cx2, cy2, front), (dx, dy, front)], (0, 0, -1))
	# Dial: the wave-1 clock face texture, mapped so 12 is up as seen from the kitchen (-z looking +z: +x is to the left).
	dial_z = front + 0.012
	pts = [(cx + math.cos(k / segs * math.tau) * (r - 0.03), cy + math.sin(k / segs * math.tau) * (r - 0.03), dial_z) for k in range(segs)]
	uv = [(0.5 - math.cos(k / segs * math.tau) * 0.5, 0.5 + math.sin(k / segs * math.tau) * 0.5) for k in range(segs)]
	part.face("W1ClockDial", pts, (0, 0, -1), uv=uv)
	# Hands at 4:00: the hour hand 120 degrees clockwise from 12 as seen from the kitchen, the minute hand at 12.
	hz = dial_z - 0.006
	for length, width, ang, depth in ((0.14, 0.018, 120.0, 0.0), (0.21, 0.012, 0.0, -0.004)):
		a = math.radians(ang)
		d = Vector((-math.sin(a), math.cos(a)))   # seen from -z, clockwise turns towards -x
		side = Vector((d.y, -d.x))
		p0 = Vector((cx, cy)) - d * 0.03
		p1 = Vector((cx, cy)) + d * length
		quad = [p0 - side * width / 2, p0 + side * width / 2, p1 + side * width / 4, p1 - side * width / 4]
		part.face("W1ClockHand", [(q.x, q.y, hz + depth) for q in quad], (0, 0, -1))
	part.cylinder("W1ClockHand", tuple(B((cx, cy, hz - 0.006))), 0.012, 0.01, axis="Y", segments=8)
	part.bm.normal_update()
	export("clock.glb", [build(part, {"W1ClockCase": 1.0, "W1ClockDial": 1.0, "W1ClockHand": 1.0})])


# ------------------------------------------------------------------------------------------------ facade

def build_facade():
	w1kit.reset()
	part = GPart("Facade")
	sign = GPart("Sign")
	t = L.T
	zo = L.HALL["z"][0] - t
	x0, x1 = 169.5, 210.5
	# Pilasters on the piers between windows and at the corners and the door, 15 cm proud, whitewashed.
	piers = [170.0, 173.5, 176.5, 179.5, 182.5, 185.6, 194.4, 197.5, 200.5, 203.5, 206.5, 210.0]
	for px in piers:
		w = 0.22 if 170.5 < px < 209.5 else 0.3
		faces = part.gbox("W6FacadeWhite", (px - w, G, zo - 0.15), (px + w, L.WALL_TOP, zo))
		part.map_uv2(faces, lambda q: L.wall_uv2(2, q[0] - x0, q[1], 41.0))
	# Plinth band (40 cm, splashed), a white band at the window heads, the roof edge and the parapet with coping.
	for a, b in ((x0, L.DOOR[0]), (L.DOOR[1], x1)):
		faces = part.gbox("W6FacadeWhite", (a, G - 0.05, zo - 0.04), (b, G + 0.4, zo))
		part.map_uv2(faces, lambda q: L.wall_uv2(2, q[0] - x0, q[1], 41.0))
		faces = part.gbox("W6FacadeWhite", (a, -6.9, zo - 0.03), (b, -6.75, zo))
		part.map_uv2(faces, lambda q: L.wall_uv2(2, q[0] - x0, q[1], 41.0))
	faces = part.gbox("W6FacadeWhite", (x0, L.WALL_TOP, 19.5), (x1, L.ROOF_TOP, zo))
	part.map_uv2(faces, lambda q: L.wall_uv2(2, q[0] - x0, 4.4 + G, 41.0))
	faces = part.gbox("W6FacadeWhite", (x0, L.ROOF_TOP, 19.5), (x1, -4.65, 19.8))
	part.map_uv2(faces, lambda q: L.wall_uv2(2, q[0] - x0, q[1] - 0.6, 41.0))
	part.gbox("W1Concrete", (x0 - 0.03, -4.65, 19.47), (x1 + 0.03, -4.6, 19.83))
	for xx in (x0, x1):   # parapet returns along the sides (to the PS1 ParapetSide)
		part.gbox("W6FacadeWhite", (xx - 0.15 if xx == x0 else xx - 0.15, L.ROOF_TOP, 19.5), (xx + 0.15, -4.65, 20.5))
	# Canopy over the door (PS1 Canopy x 184.5..195.5, z 16.4..20, y -6.6..-6.4) on its two posts.
	part.gbox("W1Concrete", (184.5, -6.6, 16.4), (195.5, -6.42, zo))
	part.gbox("W1Concrete", (184.5, -6.42, 16.4), (195.5, -6.32, 16.5))
	for px in (185.2, 194.8):
		part.pipe("W5GateGreen", [(px, G + 0.02, 16.6), (px, -6.6, 16.6)], 0.05, sides=10)
		part.gbox("W1Concrete", (px - 0.15, G, 16.45), (px + 0.15, G + 0.06, 16.75))
	# The step (PS1 Step x 185.5..194.5, z 17.9..19.9, 12 cm): worn concrete with a terrazzo nosing.
	part.gbox("W1Concrete", (185.5, G - 0.02, 17.9), (194.5, G + 0.11, 19.9))
	part.gbox("W1Terrazzo", (185.5, G + 0.11, 17.9), (194.5, G + 0.12, 18.05))
	# The sign (SignBoard: 10 x 1 m, y -5.65..-4.65, z 19.12..19.24) on brackets off the parapet, its east end dropped
	# 6 cm on a sheared bolt.
	sx0, sx1, sy0, sy1, sz = 185.0, 195.0, -5.65, -4.65, 19.13
	drop = 0.06
	sign.face("W6Sign", [(sx0, sy0, sz), (sx1, sy0 - drop, sz), (sx1, sy1 - drop, sz), (sx0, sy1, sz)], (0, 0, -1),
		uv=[(1, 0), (0, 0), (0, 1), (1, 1)])  # seen from the yard +x is on the left
	sign.face("W6Sign", [(sx0, sy0, sz + 0.03), (sx0, sy1, sz + 0.03), (sx1, sy1 - drop, sz + 0.03), (sx1, sy0 - drop, sz + 0.03)], (0, 0, 1),
		uv=[(0.01, 0.98)] * 4)
	for k in range(6):
		bx = sx0 + 0.6 + k * (sx1 - sx0 - 1.2) / 5
		part.gbox("W1Iron", (bx - 0.02, -5.2 - drop * (bx - sx0) / 10, sz + 0.03), (bx + 0.02, -5.16 - drop * (bx - sx0) / 10, 19.5))
	part.gbox("W1Iron", (sx0, sy1 - 0.02, sz + 0.03), (sx1, sy1, sz + 0.06))
	# Slogan board inside over the door, on the transom (SloganBoard 14 x 0.7, y -6.95..-6.25, z 20.13..20.17).
	gx0, gx1 = 183.0, 197.0
	sign.face("W6Slogan", [(gx0, -6.95, 20.17), (gx1, -6.95, 20.17), (gx1, -6.25, 20.17), (gx0, -6.25, 20.17)], (0, 0, 1),
		uv=[(0, 0), (1, 0), (1, 1), (0, 1)])
	for gx in (gx0 + 0.5, (gx0 + gx1) / 2, gx1 - 0.5):
		part.gbox("W1Iron", (gx - 0.02, -6.6, 20.125), (gx + 0.02, -6.56, 20.17))
	part.bm.normal_update()
	sign.bm.normal_update()
	export("facade.glb", [build(part, {"W1Concrete": 0.8, "W5GateGreen": 1.0, "W1Iron": 1.0, "W1Terrazzo": 1.0}), build(sign, {"W6Sign": 1.0, "W6Slogan": 1.0})])


BUILDS = {"hall_shell": build_hall_shell, "windows": build_windows, "ceiling_panels": build_ceiling_panels,
	"ceiling_roof": build_ceiling_roof, "lights_fans": build_lights_fans, "tables_inox": build_tables_inox,
	"tables_stone": build_tables_stone, "tables_stone_mess": lambda: build_tables_stone(True), "tableware": build_tableware,
	"tableware_mess": lambda: build_tableware(True), "counter_inox": lambda: build_counter("inox"),
	"counter_tiled": lambda: build_counter("tiled"), "price_boards": build_price_boards, "tv": build_tv,
	"kitchen_room": build_kitchen_room, "kitchen_k1": lambda: build_kitchen("k1"), "kitchen_k2": lambda: build_kitchen("k2"),
	"clock": build_clock, "facade": build_facade}


if __name__ == "__main__":
	random.seed(263)
	args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for key in (args or list(BUILDS)):
		BUILDS[key]()
