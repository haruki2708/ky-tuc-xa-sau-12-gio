"""T-263 round 2 (D-181): the rest of the canteen (A15) and the A16 strip round it. Blender 5.2.2, bmesh only, no add-on,
no Tripo. The owner picked round 1's T1 F1 Q1 (wood boards) C2 K1 M2 and the TV's news frame: those glbs are
build_canteen_pilot.py's (hall_shell, windows, ceiling_panels, lights_fans, tables_inox, tableware_mess, counter_inox,
price_boards, tv, tv_screen, kitchen_room, kitchen_k1, clock, facade). This script adds:

  hall_east.glb       the hand basins on SinkBlock (tiled trough, four enamel basins, wall taps, mirrors), the tray
                      return rack on TrayReturn with its trays, ReturnSign's "TRẢ KHAY" board, two slop bins, the four
                      posters (the one PS1 hung in the west exit's opening moved beside it), three split AC heads, the
                      door thresholds (main door, kitchen opening, store door)
  store.glb           the store's floor, walls, ceiling, the store door's jambs, the back door's frame with its rolled-up
                      shutter, both racks with the boxes, oil jugs, the sacks (and the kitchen's rice sacks)
  outside.glb         the outside faces of the west, east and back walls (lime yellow, white plinth, bands, corner
                      pilasters), both roofs (slab tops, fascias, parapets with coping, gutter, a water tank), the
                      chimney, downpipes, AC outdoor units with pipes, gas cylinders and their cage, wheelie bins, the
                      kitchen's exhaust, an electrical box, the west exit's steel door leaf folded back on the wall
  bikes.glb           the six parked bicycles (Bike0..5: frames in their PS1 colours, two leaning 12 degrees)
  strip_canteen.glb   the A16 strip (canteen_layout.A16_BOX less wave 8's corner and the building): the forecourt's
                      pavers from T-262's walk (z 13) to the facade, concrete aprons with covered drains along the
                      other walls, the service yard behind the kitchen and the store, worn lawn, edging
  strip_canteen_props.glb  where the 18 replaced PS1 pieces lay (w6_ps1_props.json, main's data): papers (wave 3's
                      litter cards), sandals and a backpack (wave 4's palette), trays
Nothing new stands where the player walks that the PS1 did not have (see test_t263_canteen.gd): fixtures sit on their
PS1 colliders or on walls, the back door's shutter box and rails stay above 2.5 m or beside the opening.
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave6/build_canteen.py [-- name ...]
(after patch_canteen.py data, which writes w6_ps1_props.json from main's props.tscn)
"""
import json
import math
from pathlib import Path
import random
import sys

import bpy  # noqa: F401
from mathutils import Matrix, Vector

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE))
import build_canteen_pilot as P  # noqa: E402  (its main is guarded; it puts wave1/wave5 on the path)
import canteen_layout as L  # noqa: E402

w1kit = P.w1kit
GP = P.GP
GPart, B, G = P.GPart, P.B, P.G
lbox, lcyl, yaw_matrix, gl = P.lbox, P.lcyl, P.yaw_matrix, P.gl
INSET = P.INSET
T = L.T
PS1_PROPS = HERE / "w6_ps1_props.json"
PALETTE4 = json.loads((HERE.parent / "wave4" / "palette.json").read_text(encoding="utf-8"))
GP.PREVIEW.update({"W6Posters": ((0.8, 0.78, 0.7), 0.85), "W6Mirror": ((0.5, 0.52, 0.53), 0.06), "W6StripGround": ((0.2, 0.25, 0.12), 0.95),
	"W6Pavers": ((0.45, 0.45, 0.43), 0.8), "W6YardConcrete": ((0.48, 0.47, 0.44), 0.85), "W4Palette": ((0.6, 0.6, 0.6), 0.6),
	"W3Litter": ((0.85, 0.85, 0.8), 0.9), "W3GutterDark": ((0.05, 0.045, 0.04), 0.9), "W5DoorPaint": ((0.25, 0.35, 0.3), 0.6)})


def export(name, objs):
	P.export(name, objs)


def keep(part, faces):
	"""Faces with their own UVs (palette cells, board atlases): bevelled boxes made later in the same part clear every
	face's tag (bmesh.ops.bevel), so build() tags these again or w1kit would box-project over their UVs."""
	if not hasattr(part, "painted"):
		part.painted = []
	part.painted += list(faces)
	return faces


def cell_uv(part, faces, key, rnd=None):
	P.cell_uv(part, faces, key, rnd)
	return keep(part, faces)


def build(part, extra=None):
	for f in getattr(part, "painted", []):
		if f.is_valid:
			f.tag = True
	return P.build(part, extra)


def out_uv2(part, faces, run, a, along="x"):
	"""Mask row 3 (outside faces but the front): metres along the run from its start `a`, height above the floor."""
	s0 = L.OUT_RUNS[run]

	def fn(q):
		s = abs((q[0] if along == "x" else q[2]) - a)
		return L.wall_uv2(L.OUT_ROW, s0 + s, q[1], L.OUT_LENGTH)
	part.map_uv2(faces, fn)
	return faces


def wall_uv(row, s0, length, along, a):
	def fn(q):
		s = abs((q[0] if along == "x" else q[2]) - a)
		return L.wall_uv2(row, s0 + s, q[1], length)
	return fn


# ------------------------------------------------------------------------------------------------ hall, east side

def _basin(part, x, y, z, rnd):
	"""A wall-hung enamel basin (55 x 42 cm) sitting on the trough's top, its bowl a lathe squashed along z."""
	m = Matrix.Translation(B((x, y, z))) @ Matrix.Diagonal((0.42 / 0.5, 0.55 / 0.5, 1.0, 1.0))
	prof = [(0.0, 0.04), (0.06, 0.04), (0.18, 0.07), (0.235, 0.115), (0.25, 0.12), (0.25, 0.14), (0.235, 0.14), (0.21, 0.125),
		(0.16, 0.08), (0.05, 0.055), (0.0, 0.055)]
	part.lathe("W1Enamel", prof, segments=16, matrix=m, smooth=True, close_ends=False)
	part.cylinder("W6Stainless", tuple(B((x, y + 0.057, z))), 0.022, 0.004, segments=8)


def build_hall_east():
	w1kit.reset()
	fix = GPart("EastFixtures")
	mirrors = GPart("Mirrors")
	small = GPart("EastSmall")
	posters = GPart("Posters")
	ac = GPart("ACIndoor")
	sills = GPart("Thresholds")
	rnd = random.Random(26310)
	# Hand basins: SinkBlock's collider (x 209.3..209.9, top -9.1) as a tiled trough against the east wall (the wall's
	# new inside face is x 209.871), a terrazzo top, four basins on it, taps out of the wall, a mirror over each.
	sb = L.SINK_BLOCK
	xw = L.HALL["x"][1] - T - INSET
	s_e = 39.75
	faces = fix.gbox("W6Wainscot", (sb["x"][0], G, sb["z"][0]), (xw, sb["top"] - 0.04, sb["z"][1]), skip=("+x",))
	fix.map_uv2(faces, lambda q: L.wall_uv2(0, s_e + (q[2] - 20.125), q[1], L.HALL_PERIMETER))
	faces = fix.gbox("W1Terrazzo", (sb["x"][0] - 0.02, sb["top"] - 0.04, sb["z"][0] - 0.02), (xw, sb["top"], sb["z"][1] + 0.02), skip=("+x",))
	fix.gbox("W1Black", (sb["x"][0] + 0.02, G, sb["z"][0] + 0.02), (xw, G + 0.08, sb["z"][1] - 0.02), skip=("+x", "-y"))
	for z in L.BASINS_Z:
		_basin(fix, 209.6, sb["top"], z, rnd)
		fix.pipe("W6Stainless", [(xw, -8.82, z), (209.74, -8.82, z), (209.7, -8.86, z), (209.7, -8.92, z)], 0.011, sides=8)
		fix.cylinder("W6Stainless", tuple(B((209.8, -8.79, z))), 0.016, 0.03, segments=8)
		fix.gbox("W6Stainless", (209.79, -8.77, z - 0.005), (209.81, -8.76, z + 0.06))
		# Mirror 0.8 x 0.7 in an aluminium frame, a little proud of the wall; one cracked across (two panes).
		ya, yb, za, zb = -8.55, -7.85, z - 0.4, z + 0.4
		xf = xw - 0.012
		if z == L.BASINS_Z[2]:
			mirrors.face("W6Mirror", [(xf, ya, za), (xf, ya, zb), (xf, -8.05, zb), (xf, -8.3, za)], (-1, 0, 0))
			mirrors.face("W6Mirror", [(xf - 0.002, -8.3, za), (xf - 0.002, -8.05, zb), (xf - 0.002, yb, zb), (xf - 0.002, yb, za)], (-1, 0, 0))
		else:
			mirrors.face("W6Mirror", [(xf, ya, za), (xf, ya, zb), (xf, yb, zb), (xf, yb, za)], (-1, 0, 0))
		for lo, hi in (((xf - 0.01, ya - 0.02, za - 0.02), (xw, ya, zb + 0.02)), ((xf - 0.01, yb, za - 0.02), (xw, yb + 0.02, zb + 0.02)),
				((xf - 0.01, ya, za - 0.02), (xw, yb, za)), ((xf - 0.01, ya, zb), (xw, yb, zb + 0.02))):
			fix.gbox("W1Alu", lo, hi, skip=("+x",))
	# A soap bottle and a bar of soap on the top, a drain pipe under the trough's lip.
	f = small.gbox("W6Palette", (209.45, sb["top"], 22.72), (209.53, sb["top"] + 0.18, 22.8))
	cell_uv(small, f, "green_plastic", rnd)
	f = small.gbox("W6Palette", (209.4, sb["top"], 24.92), (209.48, sb["top"] + 0.025, 24.98))
	cell_uv(small, f, "cream_paint", rnd)
	# Tray return (TrayReturn: x 208.9..209.9, z 37.5..40.5, top -8.1): an open stainless rack, four shelves.
	tr = L.TRAY_RETURN
	x0, z0, z1 = tr["x"][0] + 0.01, tr["z"][0] + 0.01, tr["z"][1] - 0.01
	fix.gbox("W6Stainless", (x0, G, z0), (xw, tr["top"], z0 + 0.025))
	fix.gbox("W6Stainless", (x0, G, z1 - 0.025), (xw, tr["top"], z1))
	fix.gbox("W6Stainless", (x0, tr["top"] - 0.03, z0), (xw, tr["top"], z1))
	fix.face("W6Stainless", [(xw - 0.002, G + 0.1, z0), (xw - 0.002, G + 0.1, z1), (xw - 0.002, tr["top"], z1), (xw - 0.002, tr["top"], z0)], (-1, 0, 0))
	for y in L.RETURN_SHELVES:
		fix.gbox("W6Stainless", (x0, y - 0.015, z0 + 0.025), (xw - 0.002, y + 0.005, z1 - 0.025))
		fix.gbox("W6Stainless", (x0, y + 0.005, z0 + 0.025), (x0 + 0.02, y + 0.04, z1 - 0.025))
	fix.gbox("W1Black", (x0 + 0.02, G, z0 + 0.025), (xw, G + 0.1, z1 - 0.025), skip=("+x",))
	for k, (x, y, z) in enumerate(L.DIRTY_TRAYS):
		level = min(L.RETURN_SHELVES, key=lambda s: abs(s - y)) + 0.005
		for n in range(rnd.randrange(1, 4)):
			# The PS1 trays (x 208.79..209.21) stuck out of TrayReturn's collider: these lie on the shelves, inside it.
			m = P._tray(small, 209.3 + rnd.uniform(-0.03, 0.03), level + n * 0.024, z + rnd.uniform(-0.3, 0.3), 90 + rnd.uniform(-8, 8), rnd)
			if n == 0:
				P._food(small, m, rnd, rnd.uniform(0.4, 0.9))
	# ReturnSign "TRẢ KHAY" (Label3D at 209.75, -7.7, 39 facing -x): an enamel board 1.0 x 0.3 on the wall over the rack.
	u1, v0, v1 = 486 / 1024, 366 / 512, 512 / 512
	xs = xw - 0.014
	f = posters.face("W6Posters", [(xs, -7.85, 38.5), (xs, -7.85, 39.5), (xs, -7.55, 39.5), (xs, -7.55, 38.5)], (-1, 0, 0),
		uv=[(0.0, 1 - v1), (u1, 1 - v1), (u1, 1 - v0), (0.0, 1 - v0)])   # seen from the hall (looking +x) +z is on the right
	keep(posters, [f])
	fix.gbox("W1Iron", (xw - 0.012, -7.86, 38.48), (xw, -7.54, 39.52), skip=("+x",))
	# Slop bins: blue plastic, open, full of leftovers; one lid dropped against the second.
	for k, (x, z) in enumerate(L.SLOP_BINS):
		m = Matrix.Translation(B((x, G, z)))
		prof = [(0.0, 0.0), (0.22, 0.0), (0.24, 0.02), (0.27, 0.7), (0.285, 0.72), (0.285, 0.75), (0.265, 0.75), (0.25, 0.71)]
		f = small.lathe("W6Palette", prof, segments=14, matrix=m, smooth=True, close_ends=False)
		cell_uv(small, f, "blue_plastic", rnd)
		f = small.cylinder("W6Palette", tuple(B((x, G + 0.66, z))), 0.245, 0.002, segments=12)
		cell_uv(small, f, "slop", rnd)
		for side in (-1, 1):
			f = small.gbox("W6Palette", (x - 0.05, G + 0.62, z + side * 0.27), (x + 0.05, G + 0.66, z + side * 0.3))
			cell_uv(small, f, "blue_plastic", rnd)
	lid = Matrix.Translation(B((207.9, G + 0.3, 41.55))) @ Matrix.Rotation(math.radians(70), 4, "Y")
	f = small.cylinder("W6Palette", (0, 0, 0), 0.29, 0.03, segments=14, matrix=lid)
	cell_uv(small, f, "blue_plastic", rnd)
	P._spill(small, 208.0, 41.55, 0.35, 0.25, rnd, "slop")
	# Posters on the west wall's inside face (x 170.125 + INSET), 0.7 x 1.0, the fourth beside the exit.
	xp = L.HALL["x"][0] + T + INSET + 0.003
	for k, zc in enumerate(L.POSTERS_Z):
		u0, u1 = k * 256 / 1024, (k + 1) * 256 / 1024
		va = 366 / 512
		tilt = rnd.uniform(-0.03, 0.03)
		pts = [(xp, -8.4 + tilt, zc + 0.35), (xp, -8.4 - tilt, zc - 0.35), (xp, -7.4 - tilt, zc - 0.35), (xp, -7.4 + tilt, zc + 0.35)]
		keep(posters, [posters.face("W6Posters", pts, (1, 0, 0), uv=[(u0, 1 - va), (u1, 1 - va), (u1, 1.0), (u0, 1.0)])])  # looking -x, +z is left
	# Split AC heads inside, over the outdoor units (z 24, 30, 36), pipes into the wall behind them.
	for z in L.AC_Z:
		x0a = L.HALL["x"][0] + T + INSET
		f = ac.gbox("W6Palette", (x0a, -6.6, z - 0.45), (x0a + 0.21, -6.3, z + 0.45), skip=("-x",))
		cell_uv(ac, f, "ac_white", rnd)
		f = ac.gbox("W6Palette", (x0a + 0.1, -6.61, z - 0.4), (x0a + 0.2, -6.6, z + 0.4))
		cell_uv(ac, f, "black", rnd)
		f = ac.gbox("W6Palette", (x0a + 0.211, -6.42, z - 0.4), (x0a + 0.212, -6.36, z + 0.4))
		cell_uv(ac, f, "pvc_grey", rnd)
		f = ac.gbox("W6Palette", (x0a + 0.211, -6.55, z + 0.3), (x0a + 0.212, -6.53, z + 0.33))
		cell_uv(ac, f, "led_green", rnd)
	# Thresholds: the main door (x 186..194 through the wall), the kitchen opening and the store door.
	sills.gbox("W1Terrazzo", (L.DOOR[0], G - 0.02, L.HALL["z"][0] - T), (L.DOOR[1], G + 0.008, L.HALL["z"][0] + T + 0.002))
	sills.gbox("W6Stainless", (186.0, G - 0.02, L.HALL["z"][1] - T - 0.002), (198.0, G + 0.006, L.HALL["z"][1] + T))
	sills.gbox("W1Terrazzo", (L.STORE_DOOR[0], G - 0.02, L.HALL["z"][1] - T - 0.002), (L.STORE_DOOR[1], G + 0.008, L.HALL["z"][1] + T + 0.002))
	for p in (fix, mirrors, small, posters, ac, sills):
		p.bm.normal_update()
	export("hall_east.glb", [build(fix, {"W6Stainless": 1.0, "W1Terrazzo": 1.0, "W1Enamel": 1.0, "W1Alu": 1.0, "W1Black": 1.0, "W1Iron": 1.0}),
		build(mirrors), build(small, {"W6Palette": 1.0, "W6Stainless": 1.0}), build(posters), build(ac, {"W6Palette": 1.0}),
		build(sills, {"W1Terrazzo": 1.0, "W6Stainless": 1.0})])


# ------------------------------------------------------------------------------------------------ store

def _sack(part, x, y0, z, size, rnd, key="sack", band="sack_print"):
	"""A woven rice sack lying on its side: a soft bevelled block, slumped, its print band round the middle."""
	sx, sy, sz = size
	m = Matrix.Translation(B((x, y0 + sy / 2, z))) @ Matrix.Rotation(math.radians(rnd.uniform(-6, 6)), 4, "Z")
	f = part.box("W6Palette", (-sx / 2, -sz / 2, -sy / 2), (sx / 2, sz / 2, sy / 2), bevel=min(0.12, sy * 0.35), segments=2, matrix=m)
	cell_uv(part, f, key, rnd)
	f = part.box("W6Palette", (-0.08, -sz / 2 - 0.004, -sy / 2 + 0.04), (0.08, sz / 2 + 0.004, sy / 2 - 0.04), matrix=m)
	cell_uv(part, f, band, rnd)
	# The sewn ends (ears).
	for e in (-1, 1):
		f = part.box("W6Palette", (e * sx / 2 - 0.03, -0.12, -0.04), (e * sx / 2 + 0.03, 0.12, 0.04), matrix=m)
		cell_uv(part, f, key, rnd)


def _jug(part, x, y0, z, rnd):
	"""A 5-litre cooking-oil jug: amber plastic, handle, red cap."""
	m = Matrix.Translation(B((x, y0 + 0.135, z)))   # B(): glbs sit at (0, G, 0), so heights go through it
	f = part.box("W6Palette", (-0.1, -0.065, -0.135), (0.1, 0.065, 0.135), bevel=0.02, segments=1, matrix=m)
	cell_uv(part, f, "oil_yellow", rnd)
	f = part.cylinder("W6Palette", tuple(B((x + 0.05, y0 + 0.29, z))), 0.024, 0.04, segments=8)
	cell_uv(part, f, "red_plastic", rnd)
	f = part.pipe("W6Palette", [(x - 0.07, y0 + 0.24, z), (x - 0.07, y0 + 0.31, z), (x + 0.0, y0 + 0.31, z), (x + 0.02, y0 + 0.27, z)], 0.012, sides=4)
	cell_uv(part, f, "oil_yellow", rnd)


def build_store():
	w1kit.reset()
	room = GPart("StoreRoom")
	things = GPart("StoreThings")
	door = GPart("BackDoor")
	rnd = random.Random(26311)
	x0, x1 = L.STORE["x"][0] + T, L.STORE["x"][1] - T
	z0, z1 = L.STORE["z"][0] + T, L.STORE["z"][1] - T
	fl = room.face("W6KitchenFloor", [(x0, G + 0.002, z0), (x1, G + 0.002, z0), (x1, G + 0.002, z1), (x0, G + 0.002, z1)], (0, 1, 0))
	room.map_uv2([fl], lambda q: L.floor_uv2(q[0], q[2]))
	top = L.ROOF_UNDER
	s = L.STORE_S
	# Inside faces: west (the kitchen's side wall), north with the back door, east, south with the store door (the
	# pilot's hall_shell has the face over that door).
	P.wall_face(room, (x0 + INSET, z0), (x0 + INSET, z1), G, top, (1, 0, 0), [], 1, s, 80.0, lower="W6WallYellow", upper="W6WallYellow")
	s += z1 - z0
	back = (L.BACK_DOOR[0] - x0, L.BACK_DOOR[1] - x0, G - 1, L.BACK_DOOR_HEAD)
	P.wall_face(room, (x0, z1 - INSET), (x1, z1 - INSET), G, top, (0, 0, -1), [back], 1, s, 80.0, lower="W6WallYellow", upper="W6WallYellow")
	s += x1 - x0
	P.wall_face(room, (x1 - INSET, z1), (x1 - INSET, z0), G, top, (-1, 0, 0), [], 1, s, 80.0, lower="W6WallYellow", upper="W6WallYellow")
	s += z1 - z0
	front = (x1 - L.STORE_DOOR[1], x1 - L.STORE_DOOR[0], G - 1, top + 1)
	P.wall_face(room, (x1, z0 + INSET), (x0, z0 + INSET), G, top, (0, 0, 1), [front], 1, s, 80.0, lower="W6WallYellow", upper="W6WallYellow")
	ceil = room.face("W6WallYellow", [(x0, top - 0.003, z0), (x1, top - 0.003, z0), (x1, top - 0.003, z1), (x0, top - 0.003, z1)], (0, -1, 0))
	room.map_uv2([ceil], lambda q: L.wall_uv2(1, 70.0 + (q[0] - 198.0) * 0.5, -5.6, 80.0))
	# The store door's jambs (x 201, 203) through the back wall, up to its lintel (-7.5).
	zb0, zb1 = L.HALL["z"][1] - T - INSET, L.HALL["z"][1] + T + INSET
	for xd, n in ((L.STORE_DOOR[0], (1, 0, 0)), (L.STORE_DOOR[1], (-1, 0, 0))):
		f = room.face("W6WallYellow", [(xd, G, zb0), (xd, G, zb1), (xd, L.STORE_DOOR_HEAD, zb1), (xd, L.STORE_DOOR_HEAD, zb0)], n)
		room.map_uv2([f], lambda q: L.wall_uv2(1, 76.0, q[1], 80.0))
	# The back door (x 200..204): jambs and lintel through the wall, a concrete sill; the shutter rolled up into its
	# box inside over the opening (box from 2.5 m), guide rails beside the opening, the bottom bar just under the box.
	zd0, zd1 = L.STORE["z"][1] - T - INSET, L.STORE["z"][1] + T + INSET
	bx0, bx1 = L.BACK_DOOR
	for xd, n in ((bx0, (1, 0, 0)), (bx1, (-1, 0, 0))):
		f = door.face("W6WallYellow", [(xd, G, zd0), (xd, G, zd1), (xd, L.BACK_DOOR_HEAD, zd1), (xd, L.BACK_DOOR_HEAD, zd0)], n)
		door.map_uv2([f], lambda q: L.wall_uv2(1, 78.0, q[1], 80.0))
	f = door.face("W6WallYellow", [(bx0, L.BACK_DOOR_HEAD, zd0), (bx1, L.BACK_DOOR_HEAD, zd0), (bx1, L.BACK_DOOR_HEAD, zd1), (bx0, L.BACK_DOOR_HEAD, zd1)], (0, -1, 0))
	door.map_uv2([f], lambda q: L.wall_uv2(1, 78.0, 2.4 + G, 80.0))
	door.gbox("W1Concrete", (bx0, G - 0.02, zd0), (bx1, G + 0.015, zd1))
	door.gbox("W6Shutter", (bx0 - 0.12, L.BACK_DOOR_HEAD, z1 - 0.3), (bx1 + 0.12, L.BACK_DOOR_HEAD + 0.45, z1 - INSET))
	door.gbox("W6Shutter", (bx0 - 0.02, L.BACK_DOOR_HEAD - 0.06, z1 - 0.2), (bx1 + 0.02, L.BACK_DOOR_HEAD, z1 - 0.15))
	for xr in (bx0 - 0.07, bx1 + 0.01):
		door.gbox("W6Shutter", (xr, G, z1 - 0.09), (xr + 0.06, L.BACK_DOOR_HEAD, z1 - INSET))
	# A wall switch by the door.
	f = door.gbox("W6Palette", (bx0 - 0.3, -8.6, z1 - INSET - 0.02), (bx0 - 0.22, -8.48, z1 - INSET))
	cell_uv(door, f, "white_plastic", rnd)
	# Racks: slotted steel angle, three timber boards (RACK_LEVELS), two on each long side.
	for rx in L.RACKS_X:
		za, zb = L.RACK_Z
		for ux in (rx - 0.34, rx + 0.31):
			for uz in (za + 0.01, (za + zb) / 2 - 0.015, zb - 0.04):
				things.gbox("W4PoleSteel", (ux, G, uz), (ux + 0.03, -7.3, uz + 0.003))
				things.gbox("W4PoleSteel", (ux, G, uz), (ux + 0.003, -7.3, uz + 0.03))
		for y in L.RACK_LEVELS:
			things.gbox("W1Wood", (rx - 0.34, y - 0.005, za + 0.01), (rx + 0.34, y + 0.02, zb - 0.01))
			for ez in (za + 0.01, zb - 0.04):
				things.gbox("W4PoleSteel", (rx - 0.34, y + 0.02, ez), (rx + 0.34, y + 0.05, ez + 0.003))
	for x, y, z in L.STORE_BOXES:
		base = min(L.RACK_LEVELS, key=lambda lv: abs(lv - (y - 0.2))) + 0.02
		yaw = math.radians(rnd.uniform(-5, 5))
		m = Matrix.Translation(B((x, base + 0.2, z))) @ Matrix.Rotation(yaw, 4, "Z")
		f = things.box("W6Palette", (-0.25, -0.225, -0.2), (0.25, 0.225, 0.2), bevel=0.008, segments=1, matrix=m)
		cell_uv(things, f, "cardboard", rnd)
		f = things.box("W6Palette", (-0.255, -0.03, 0.195), (0.255, 0.03, 0.203), matrix=m)
		cell_uv(things, f, "tape", rnd)
	for x, y, z in L.OIL_CANS:
		base = min(L.RACK_LEVELS, key=lambda lv: abs(lv - (y - 0.2))) + 0.02
		for dz in (-0.08, 0.08):
			_jug(things, x + rnd.uniform(-0.05, 0.05), base, z + dz, rnd)
	for x, y, z in L.STORE_SACKS:
		_sack(things, x, G + 0.002, z, (0.7, 0.42, 0.6), rnd)
	for k, (x, y, z) in enumerate(L.RICE_SACKS):
		_sack(things, x, G + 0.002 + (0.44 if y > -9.4 else 0.0), z, (0.7, 0.42, 0.6), rnd, band="sack_green" if k % 2 else "sack_print")
	# An unlit fluorescent batten on the store's ceiling (no light added).
	things.gbox("W1Enamel", (203.4, top - 0.06, 47.95), (204.6, top - 0.003, 48.05))
	for p in (room, things, door):
		p.bm.normal_update()
	export("store.glb", [build(room), build(things, {"W6Palette": 1.0, "W1Wood": 1.0, "W4PoleSteel": 1.0, "W1Enamel": 1.0}),
		build(door, {"W6Shutter": 1.0, "W1Concrete": 0.8, "W1Iron": 1.0, "W6Palette": 1.0})])


# ------------------------------------------------------------------------------------------------ outside

def _plinth_and_band(part, a, b, normal, run, holes=()):
	"""White plinth (40 cm, 4 cm proud) along an outside face from a to b (x, z), broken at `holes` (from, to along)."""
	ax, az = a
	bx, bz = b
	along = "x" if az == bz else "z"
	lo_s, hi_s = (min(ax, bx), max(ax, bx)) if along == "x" else (min(az, bz), max(az, bz))
	cuts = sorted(holes)
	spans, s = [], lo_s
	for h0, h1 in cuts:
		if h0 > s:
			spans.append((s, h0))
		s = max(s, h1)
	if s < hi_s:
		spans.append((s, hi_s))
	nx, nz = normal[0], normal[2]
	for s0, s1 in spans:
		for y0, y1, proud in ((G - 0.05, G + 0.4, 0.04),):
			if along == "x":
				zf = az
				lo = (s0, y0, min(zf, zf + nz * proud))
				hi = (s1, y1, max(zf, zf + nz * proud))
			else:
				xf = ax
				lo = (min(xf, xf + nx * proud), y0, s0)
				hi = (max(xf, xf + nx * proud), y1, s1)
			faces = part.gbox("W6FacadeWhite", lo, hi)
			out_uv2(part, faces, run, ax if along == "x" else az, along)


def _pilaster(part, x, z, nx, nz, run, a, along):
	w = 0.22
	if nx:
		lo, hi = (min(x, x + nx * 0.15), G - 0.05, z - w), (max(x, x + nx * 0.15), L.WALL_TOP, z + w)
	else:
		lo, hi = (x - w, G - 0.05, min(z, z + nz * 0.15)), (x + w, L.WALL_TOP, max(z, z + nz * 0.15))
	faces = part.gbox("W6FacadeWhite", lo, hi)
	out_uv2(part, faces, run, a, along)


def _ac_outdoor(part, small, z, rnd):
	"""A split AC's outdoor unit on L brackets off the west wall (PS1 ACUnit: x 169.43..169.78, y -7.6..-7.0)."""
	xw = L.HALL["x"][0] - T
	xa, xb = 169.45, xw - 0.07
	f = small.gbox("W6Palette", (xa, -7.6, z - 0.4), (xb, -7.02, z + 0.4))
	cell_uv(small, f, "ac_white", rnd)
	f = small.gbox("W6Palette", (xa - 0.004, -7.56, z - 0.36), (xa, -7.06, z + 0.06))
	cell_uv(small, f, "black", rnd)
	ring_c = (xa - 0.006, -7.31, z - 0.15)
	for r in (0.08, 0.15, 0.22):
		pts = [(ring_c[0], ring_c[1] + math.sin(k / 16 * math.tau) * r, ring_c[2] + math.cos(k / 16 * math.tau) * r) for k in range(17)]
		f = small.pipe("W6Palette", pts, 0.004, sides=4, cap=False)
		cell_uv(small, f, "steel_grey", rnd)
	for k in range(3):
		a = k / 3 * math.pi
		f = small.pipe("W6Palette", [(ring_c[0], ring_c[1] + math.sin(a) * 0.22, ring_c[2] + math.cos(a) * 0.22),
			(ring_c[0], ring_c[1] - math.sin(a) * 0.22, ring_c[2] - math.cos(a) * 0.22)], 0.004, sides=4, cap=False)
		cell_uv(small, f, "steel_grey", rnd)
	f = small.gbox("W6Palette", (xa - 0.003, -7.54, z + 0.1), (xa, -7.08, z + 0.36))
	cell_uv(small, f, "steel_grey", rnd)
	for dz in (-0.33, 0.33):
		part.gbox("W1Iron", (169.42, -7.64, z + dz - 0.02), (xw, -7.6, z + dz + 0.02))
		part.beam("W1Iron", (169.47, -7.62, z + dz), (xw - 0.01, -8.0, z + dz), 0.03, 0.03)
	# Copper pipes in grey insulation up the wall and into it at the indoor head's height, a drain hose down.
	f = small.pipe("W6Palette", [(xb + 0.02, -7.2, z + 0.32), (xw - 0.03, -7.2, z + 0.32), (xw - 0.03, -6.45, z + 0.32), (xw, -6.45, z + 0.32)], 0.025, sides=6)
	cell_uv(small, f, "foam", rnd)
	f = small.pipe("W6Palette", [(xb, -7.6, z + 0.2), (xb - 0.02, -7.8, z + 0.22), (xb - 0.02, G + 0.3, z + 0.25), (xb - 0.15, G + 0.02, z + 0.25)], 0.008, sides=4)
	cell_uv(small, f, "black", rnd)


def _gas_cylinder(small, x, z, rnd):
	m = Matrix.Translation(B((x, G, z)))
	prof = [(0.0, 0.0), (0.16, 0.0), (0.17, 0.06), (0.15, 0.065), (0.18, 0.09), (0.19, 0.12), (0.19, 0.88), (0.17, 0.96), (0.12, 1.0),
		(0.06, 1.02), (0.0, 1.02)]
	f = small.lathe("W6Palette", prof, segments=16, matrix=m, smooth=True, close_ends=False)
	cell_uv(small, f, "gas_red", rnd)
	f = small.lathe("W6Palette", [(0.13, 0.98), (0.14, 1.0), (0.14, 1.1), (0.12, 1.1), (0.12, 1.0)], segments=12, matrix=m, smooth=False, close_ends=False)
	cell_uv(small, f, "steel_grey", rnd)
	f = small.cylinder("W6Palette", tuple(B((x, G + 1.06, z))), 0.022, 0.06, segments=8)
	cell_uv(small, f, "gas_valve", rnd)
	f = small.gbox("W6Palette", (x - 0.04, G + 1.08, z - 0.03), (x + 0.04, G + 1.13, z + 0.03))
	cell_uv(small, f, "black", rnd)


def _wheelie_bin(small, x, z, key, rnd, yaw=0.0):
	"""A 240-litre wheelie bin (PS1 Bin: r 0.3, h 0.9), lid ajar, two wheels at the back."""
	m = Matrix.Translation(B((x, G, z))) @ Matrix.Rotation(math.radians(yaw), 4, "Z")
	verts = [(-0.26, -0.3, 0.05), (0.26, -0.3, 0.05), (0.26, 0.3, 0.05), (-0.26, 0.3, 0.05),
		(-0.29, -0.36, 0.95), (0.29, -0.36, 0.95), (0.29, 0.36, 0.95), (-0.29, 0.36, 0.95)]
	faces = [(0, 3, 2, 1), (0, 1, 5, 4), (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7), (4, 5, 6, 7)]
	f = small.poly("W6Palette", [tuple(m @ Vector(v)) for v in verts], faces, recalc=True)
	cell_uv(small, f, key, rnd)
	lid = m @ Matrix.Translation(Vector((0, -0.37, 0.96))) @ Matrix.Rotation(math.radians(-12), 4, "X")
	f = small.box("W6Palette", (-0.31, 0.0, 0.0), (0.31, 0.76, 0.03), matrix=lid)
	cell_uv(small, f, key, rnd)
	for sx in (-0.22, 0.22):
		f = small.cylinder("W6Palette", (sx, -0.33, 0.1), 0.1, 0.05, axis="X", segments=10, matrix=m)
		cell_uv(small, f, "rubber", rnd)
	f = small.tube("W6Palette", [m @ Vector((-0.25, -0.4, 0.92)), m @ Vector((0.25, -0.4, 0.92))], 0.018, segments=6)
	cell_uv(small, f, key, rnd)
	# A black bin bag bulging out under the lid.
	f = small.box("W6Palette", (-0.22, -0.2, 0.86), (0.18, 0.25, 1.02), bevel=0.06, segments=2, matrix=m)
	cell_uv(small, f, "black", rnd)


def _downpipe(part, x, z, nx, nz, rnd):
	"""A grey PVC downpipe 7 cm off the wall from the roof edge to a shoe at the foot, two wall clips."""
	xo, zo = x + nx * 0.07, z + nz * 0.07
	f = part.pipe("W6Palette", [(xo, L.WALL_TOP - 0.05, zo), (xo, G + 0.18, zo), (xo + nx * 0.12, G + 0.04, zo + nz * 0.12)], 0.045, sides=10)
	cell_uv(part, f, "pvc_grey", rnd)
	for y in (-6.0, -8.5):
		if nx:
			part.gbox("W1Iron", (min(x, xo + nx * 0.05), y - 0.02, zo - 0.05), (max(x, xo + nx * 0.05), y + 0.02, zo + 0.05))
		else:
			part.gbox("W1Iron", (xo - 0.05, y - 0.02, min(z, zo + nz * 0.05)), (xo + 0.05, y + 0.02, max(z, zo + nz * 0.05)))


def build_outside():
	w1kit.reset()
	walls = GPart("OutsideWalls")
	roof = GPart("Roof")
	fix = GPart("OutsideFixtures")
	small = GPart("OutsideSmall")
	rnd = random.Random(26312)
	t = T
	y0 = G - 0.06
	top = L.WALL_TOP
	hx0, hx1 = L.HALL["x"][0] - t, L.HALL["x"][1] + t     # 169.875, 210.125
	zb = L.STORE["z"][1] + t                               # 52.125
	kx = L.KITCHEN["x"][0] - t                             # 185.875
	# Faces (row 3 runs; the back wall's west part is hall_shell's).
	P.wall_face(walls, (kx, L.HALL["z"][1] + t), (kx, zb), y0, top, (-1, 0, 0), [], L.OUT_ROW, L.OUT_RUNS["kitchen_west"], L.OUT_LENGTH,
		lower=None, upper="W6FacadeYellow")
	P.wall_face(walls, (kx, zb), (L.KITCHEN["x"][1], zb), y0, top, (0, 0, 1), [], L.OUT_ROW, L.OUT_RUNS["kitchen_back"], L.OUT_LENGTH,
		lower=None, upper="W6FacadeYellow")
	back = (L.BACK_DOOR[0] - 198.0, L.BACK_DOOR[1] - 198.0, G - 1, L.BACK_DOOR_HEAD)
	P.wall_face(walls, (198.0, zb), (hx1, zb), y0, top, (0, 0, 1), [back], L.OUT_ROW, L.OUT_RUNS["store_back"], L.OUT_LENGTH,
		lower=None, upper="W6FacadeYellow")
	P.wall_face(walls, (hx1, zb), (hx1, L.HALL["z"][0] - t), y0, top, (1, 0, 0), [], L.OUT_ROW, L.OUT_RUNS["east"], L.OUT_LENGTH,
		lower=None, upper="W6FacadeYellow")
	west_door = (L.WEST_DOOR[0] - (L.HALL["z"][0] - t), L.WEST_DOOR[1] - (L.HALL["z"][0] - t), G - 1, L.WEST_DOOR_HEAD)
	P.wall_face(walls, (hx0, L.HALL["z"][0] - t), (hx0, L.HALL["z"][1] + t), y0, top, (-1, 0, 0), [west_door], L.OUT_ROW, L.OUT_RUNS["west"],
		L.OUT_LENGTH, lower=None, upper="W6FacadeYellow")
	# Plinth all round (broken at the doors and the west exit's casings), a white band at the window heads on the
	# side walls (as the front), corner and side pilasters every 8 m.
	_plinth_and_band(walls, (hx0, L.HALL["z"][1] + t), (kx, L.HALL["z"][1] + t), (0, 0, 1), "back_west")
	_plinth_and_band(walls, (kx, L.HALL["z"][1] + t), (kx, zb), (-1, 0, 0), "kitchen_west")
	_plinth_and_band(walls, (kx, zb), (L.KITCHEN["x"][1], zb), (0, 0, 1), "kitchen_back")
	_plinth_and_band(walls, (198.0, zb), (hx1, zb), (0, 0, 1), "store_back", holes=[(L.BACK_DOOR[0], L.BACK_DOOR[1])])
	_plinth_and_band(walls, (hx1, zb), (hx1, L.HALL["z"][0] - t), (1, 0, 0), "east")
	_plinth_and_band(walls, (hx0, L.HALL["z"][0] - t), (hx0, L.HALL["z"][1] + t), (-1, 0, 0), "west", holes=[(L.WEST_DOOR[0] - 0.1, L.WEST_DOOR[1] + 0.1)])
	for xf, n, run, a in ((hx0, -1, "west", L.HALL["z"][0] - t), (hx1, 1, "east", zb)):
		faces = walls.gbox("W6FacadeWhite", (min(xf, xf + n * 0.03), -6.9, L.HALL["z"][0] - t), (max(xf, xf + n * 0.03), -6.75, L.HALL["z"][1] + t))
		out_uv2(walls, faces, run, a, "z")
	for z in (27.0, 33.0, 38.6, 44.0):   # between the AC units (z 24, 30, 36) and clear of the west exit's casings
		_pilaster(walls, hx0, z, -1, 0, "west", L.HALL["z"][0] - t, "z")
	for z in (28.0, 36.0, 44.0, 52.125 - 0.22):
		_pilaster(walls, hx1, z, 1, 0, "east", zb, "z")
	_pilaster(walls, hx0 + 0.22, L.HALL["z"][1] + t, 0, 1, "back_west", hx0, "x")
	_pilaster(walls, kx + 0.22, zb, 0, 1, "kitchen_back", kx, "x")
	_pilaster(walls, hx1 - 0.22, zb, 0, 1, "store_back", 198.0, "x")
	# Roofs: the hall's slab and the kitchen and store's, tops (seen from the dorm), fascias, parapets with coping,
	# a box gutter on the kitchen roof's north edge, a stainless water tank on its stand over the hall.
	rt, ru = L.ROOF_TOP, L.WALL_TOP
	rx0, rx1 = L.ROOF["x"]
	rz0, rz1 = L.ROOF["z"]
	roof.face("W1Concrete", [(rx0, rt, rz0), (rx1, rt, rz0), (rx1, rt, rz1), (rx0, rt, rz1)], (0, 1, 0))
	kr = L.KITCHEN_ROOF
	roof.face("W1Concrete", [(kr["x"][0], rt, rz1), (kr["x"][1], rt, rz1), (kr["x"][1], rt, kr["z"][1]), (kr["x"][0], rt, kr["z"][1])], (0, 1, 0))
	for lo, hi in (((rx0, ru, rz0 + 0.375), (hx0, rt, rz1)), ((hx1, ru, rz0 + 0.375), (rx1, rt, rz1)), ((rx0, ru, L.HALL["z"][1] + t), (kx, rt, rz1)),
			((kr["x"][0], ru, zb), (kr["x"][1], rt, kr["z"][1]))):
		faces = roof.gbox("W6FacadeWhite", lo, hi)
		roof.map_uv2(faces, lambda q: L.wall_uv2(L.OUT_ROW, 120.0, 4.4 + G, L.OUT_LENGTH))
	for xf, n in ((kr["x"][0], (-1, 0, 0)), (kr["x"][1], (1, 0, 0))):
		f = roof.face("W6FacadeWhite", [(xf, ru, rz1), (xf, ru, kr["z"][1]), (xf, rt, kr["z"][1]), (xf, rt, rz1)], n)
		roof.map_uv2([f], lambda q: L.wall_uv2(L.OUT_ROW, 120.0, 4.4 + G, L.OUT_LENGTH))
	ptop = -4.65
	for lo, hi in (((169.35, rt, 20.5), (169.65, ptop, 44.65)), ((210.35, rt, 20.5), (210.65, ptop, 44.65)), ((169.35, rt, 44.35), (210.65, ptop, 44.65))):
		faces = roof.gbox("W6FacadeWhite", lo, hi)
		roof.map_uv2(faces, lambda q: L.wall_uv2(L.OUT_ROW, 124.0, q[1] - 0.6, L.OUT_LENGTH))
		roof.gbox("W1Concrete", (lo[0] - 0.03, ptop, lo[2] - (0.03 if lo[2] > 21 else 0.0)), (hi[0] + 0.03, ptop + 0.05, hi[2] + 0.03))
	fix.gbox("W4PoleSteel", (kr["x"][0], ru, kr["z"][1]), (kr["x"][1], ru + 0.1, kr["z"][1] + 0.13), skip=("+y",))
	tank_c = (176.0, rt + 0.95, 40.0)
	fix.cylinder("W6Stainless", tuple(B(tank_c)), 0.5, 1.8, axis="X", segments=16)
	for dx in (-0.6, 0.6):
		fix.cylinder("W6Stainless", tuple(B((tank_c[0] + dx, tank_c[1], tank_c[2]))), 0.51, 0.04, axis="X", segments=16)
		for dz in (-0.4, 0.4):
			fix.gbox("W1Iron", (tank_c[0] + dx - 0.02, rt, tank_c[2] + dz - 0.02), (tank_c[0] + dx + 0.02, tank_c[1] - 0.3, tank_c[2] + dz + 0.02))
		fix.gbox("W1Iron", (tank_c[0] + dx - 0.02, tank_c[1] - 0.45, tank_c[2] - 0.45), (tank_c[0] + dx + 0.02, tank_c[1] - 0.41, tank_c[2] + 0.45))
	f = fix.pipe("W6Palette", [(tank_c[0] + 0.9, tank_c[1] - 0.3, tank_c[2]), (tank_c[0] + 1.3, tank_c[1] - 0.3, tank_c[2]), (tank_c[0] + 1.3, rt + 0.02, tank_c[2])], 0.02, sides=6)
	cell_uv(fix, f, "pvc_grey", rnd)
	# Chimney (PS1 0.6 m box at (192, 51) up to -3.3): a galvanised round duct, flashing, a rain cap on three struts.
	cx, cz = L.CHIMNEY
	fix.gbox("W4PoleSteel", (cx - 0.4, rt, cz - 0.4), (cx + 0.4, rt + 0.04, cz + 0.4))
	fix.cylinder("W4PoleSteel", tuple(B((cx, (rt + -3.55) / 2, cz))), 0.25, -3.55 - rt, segments=14, cap=False)
	for k in range(3):
		a = k / 3 * math.tau
		fix.pipe("W1Iron", [(cx + math.cos(a) * 0.24, -3.56, cz + math.sin(a) * 0.24), (cx + math.cos(a) * 0.3, -3.32, cz + math.sin(a) * 0.3)], 0.008, sides=4)
	fix.cylinder("W1Black", tuple(B((cx, -3.24, cz))), 0.42, 0.16, segments=14, radius2=0.06)
	# Downpipes, AC outdoor units, the kitchen's exhaust, an electrical box with its sticker, the west exit's leaf.
	for x, z, nx, nz in ((hx0, 20.6, -1, 0), (hx1, 21.0, 1, 0), (hx1, 51.4, 1, 0), (186.6, zb, 0, 1), (209.4, zb, 0, 1)):
		_downpipe(small, x, z, nx, nz, rnd)
	for z in L.AC_Z:
		_ac_outdoor(fix, small, z, rnd)
	ex, ey = 194.0, -6.9
	fix.gbox("W1Iron", (ex - 0.32, ey - 0.32, zb), (ex + 0.32, ey + 0.32, zb + 0.22))
	for k in range(7):
		y = ey - 0.27 + k * 0.09
		fix.beam("W6Shutter", (ex - 0.28, y, zb + 0.23), (ex + 0.28, y, zb + 0.23), 0.075, 0.008, up=(0, 0.6, 0.8))
	fix.gbox("W1Iron", (hx1, -8.45, 29.7), (hx1 + 0.16, -7.85, 30.2))
	u0, u1, va, vb = 500 / 1024, 646 / 1024, 366 / 512, 512 / 512
	f = small.face("W6Posters", [(hx1 + 0.162, -8.3, 30.05), (hx1 + 0.162, -8.3, 29.85), (hx1 + 0.162, -8.1, 29.85), (hx1 + 0.162, -8.1, 30.05)],
		(1, 0, 0), uv=[(u0, 1 - vb), (u1, 1 - vb), (u1, 1 - va), (u0, 1 - va)])   # looking -x, +z is on the left
	keep(small, [f])
	f = fix.pipe("W6Palette", [(hx1 + 0.05, -7.85, 30.0), (hx1 + 0.05, top - 0.05, 30.0)], 0.018, sides=6)
	cell_uv(fix, f, "pvc_grey", rnd)
	# The west exit's steel leaf, swung out 180 degrees flat against the outside wall north of the opening.
	lz0, lz1 = L.WEST_DOOR[1] + 0.12, L.WEST_DOOR[1] + 2.02
	lx = hx0 - 0.03
	fix.gbox("W5DoorPaint", (lx - 0.045, G + 0.02, lz0), (lx, L.WEST_DOOR_HEAD - 0.05, lz1))
	for zz in (lz0 + 0.1, lz1 - 0.1):
		fix.gbox("W5DoorPaint", (lx - 0.06, G + 0.08, zz - 0.04), (lx - 0.045, L.WEST_DOOR_HEAD - 0.11, zz + 0.04))
	fix.gbox("W1Iron", (lx - 0.09, -8.95, lz1 - 0.12), (lx - 0.045, -8.9, lz1 - 0.04))
	for y in (G + 0.3, -8.1):
		fix.gbox("W1Iron", (lx - 0.02, y, L.WEST_DOOR[1] + 0.02), (hx0, y + 0.1, lz0 + 0.02))
	# Gas cylinders behind the kitchen in a steel cage, their hoses into the wall; the wheelie bins by the store.
	for x, z in L.GAS_CYLINDERS:
		_gas_cylinder(small, x, z, rnd)
		f = small.pipe("W6Palette", [(x, G + 1.13, z), (x, G + 1.25, z - 0.3), (x, -8.4, zb + 0.02)], 0.01, sides=5)
		cell_uv(small, f, "black", rnd)
	cage = (188.62, 52.15, 189.98, 53.4)
	for k in range(9):
		x = cage[0] + k * (cage[2] - cage[0]) / 8
		fix.gbox("W1Iron", (x - 0.008, G, cage[3] - 0.008), (x + 0.008, G + 1.3, cage[3] + 0.008))
	for zz in (cage[1] + 0.4, cage[1] + 0.8):
		for xx in (cage[0], cage[2]):
			fix.gbox("W1Iron", (xx - 0.008, G, zz - 0.008), (xx + 0.008, G + 1.3, zz + 0.008))
	for y in (G + 0.05, G + 0.65, G + 1.28):
		fix.gbox("W1Iron", (cage[0], y, cage[3] - 0.012), (cage[2], y + 0.025, cage[3] + 0.012))
		for xx in (cage[0], cage[2]):
			fix.gbox("W1Iron", (xx - 0.012, y, cage[1]), (xx + 0.012, y + 0.025, cage[3]))
	fix.gbox("W1Iron", (cage[0], G + 1.3, cage[1]), (cage[2], G + 1.33, cage[3]))
	for x, z, key in L.BINS:
		_wheelie_bin(small, x, z, key, rnd, yaw=rnd.uniform(-10, 10))
	for p in (walls, roof, fix, small):
		p.bm.normal_update()
	export("outside.glb", [build(walls), build(roof, {"W1Concrete": 0.8}), build(fix, {"W1Iron": 1.0, "W4PoleSteel": 1.0, "W6Stainless": 1.0,
		"W1Black": 1.0, "W6Palette": 1.0, "W6Shutter": 1.0, "W5DoorPaint": 1.0}), build(small, {"W6Palette": 1.0, "W1Iron": 1.0})])


# ------------------------------------------------------------------------------------------------ bicycles

BIKE_PAINT = ["bike_blue", "bike_red", "bike_blue", "bike_red", "bike_blue", "bike_red"]   # the PS1 frames' tints


def _wheel(part, xf, cx, rnd):
	"""A 26-inch wheel in the bike's plane (local x along, y up, z across) centred at (cx, 0.33)."""
	r = 0.33
	n = 14
	ring = [xf((cx + math.cos(k / n * math.tau) * r, 0.33 + math.sin(k / n * math.tau) * r, 0.0)) for k in range(n + 1)]
	f = part.pipe("W6Palette", ring, 0.02, sides=6, cap=False)
	cell_uv(part, f, "rubber", rnd)
	rim = [xf((cx + math.cos(k / n * math.tau) * (r - 0.03), 0.33 + math.sin(k / n * math.tau) * (r - 0.03), 0.0)) for k in range(n + 1)]
	f = part.pipe("W6Palette", rim, 0.008, sides=4, cap=False)
	cell_uv(part, f, "chrome", rnd)
	for k in range(12):
		a = k / 12 * math.tau + 0.13
		side = 0.018 if k % 2 else -0.018
		f = part.pipe("W6Palette", [xf((cx, 0.33, side)), xf((cx + math.cos(a) * (r - 0.03), 0.33 + math.sin(a) * (r - 0.03), 0.0))], 0.0015, sides=3, cap=False)
		cell_uv(part, f, "chrome", rnd)
	f = part.pipe("W6Palette", [xf((cx, 0.33, -0.05)), xf((cx, 0.33, 0.05))], 0.02, sides=6)
	cell_uv(part, f, "steel_grey", rnd)


def build_bikes():
	w1kit.reset()
	part = GPart("Bikes")
	rnd = random.Random(26313)
	for k, (x, z, lean) in enumerate(L.BIKES):
		yaw = rnd.uniform(-4, 4) + (180.0 if k % 2 else 0.0)
		lean_r = math.radians(lean)
		a = math.radians(yaw)

		def xf(p, x=x, z=z, a=a, lean_r=lean_r):
			lx, ly, lz = p
			# Lean about the line the tyres touch the ground (local x), then turn about y, then place.
			ly2 = ly * math.cos(lean_r) - lz * math.sin(lean_r)
			lz2 = ly * math.sin(lean_r) + lz * math.cos(lean_r)
			wx = x + lx * math.cos(a) + lz2 * math.sin(a)
			wz = z - lx * math.sin(a) + lz2 * math.cos(a)
			return (wx, G + ly2, wz)
		paint = BIKE_PAINT[k]
		for cx in (-0.55, 0.55):
			_wheel(part, xf, cx, rnd)
		# Step-through frame: head tube, a bent down tube, seat tube, chain and seat stays, fork, rack, basket.
		head = [(0.36, 0.62, 0.0), (0.42, 0.86, 0.0)]
		tubes = [[(0.4, 0.78, 0.0), (0.18, 0.5, 0.0), (-0.02, 0.32, 0.0), (-0.08, 0.3, 0.0)], [(-0.08, 0.3, 0.0), (-0.2, 0.86, 0.0)],
			[(-0.08, 0.3, 0.03), (-0.55, 0.33, 0.04)], [(-0.08, 0.3, -0.03), (-0.55, 0.33, -0.04)],
			[(-0.19, 0.8, 0.03), (-0.55, 0.33, 0.04)], [(-0.19, 0.8, -0.03), (-0.55, 0.33, -0.04)], head]
		for pts in tubes:
			f = part.pipe("W6Palette", [xf(p) for p in pts], 0.016, sides=6)
			cell_uv(part, f, paint, rnd)
		for s in (0.04, -0.04):
			f = part.pipe("W6Palette", [xf((0.38, 0.66, s)), xf((0.5, 0.45, s)), xf((0.55, 0.33, s))], 0.011, sides=5)
			cell_uv(part, f, "chrome", rnd)
		f = part.pipe("W6Palette", [xf((0.42, 0.86, 0.0)), xf((0.44, 0.98, 0.0)), xf((0.36, 1.0, 0.0))], 0.012, sides=5)
		cell_uv(part, f, "chrome", rnd)
		f = part.pipe("W6Palette", [xf((0.3, 0.99, -0.28)), xf((0.36, 1.0, -0.1)), xf((0.36, 1.0, 0.1)), xf((0.3, 0.99, 0.28))], 0.011, sides=5)
		cell_uv(part, f, "chrome", rnd)
		for s in (-0.28, 0.28):
			f = part.pipe("W6Palette", [xf((0.3, 0.99, s)), xf((0.24, 0.985, s * 1.05))], 0.015, sides=5)
			cell_uv(part, f, "black", rnd)
		f = part.pipe("W6Palette", [xf((-0.2, 0.86, 0.0)), xf((-0.22, 0.95, 0.0))], 0.012, sides=5)
		cell_uv(part, f, "chrome", rnd)
		f = part.pipe("W6Palette", [xf((-0.36, 0.975, 0.0)), xf((-0.24, 0.985, 0.0)), xf((-0.13, 0.975, 0.0))], 0.05, sides=6)
		cell_uv(part, f, "saddle", rnd)
		# Chainring, cranks, pedals; mudguards; the rear rack; a wire basket on the front.
		ring = [xf((-0.08 + math.cos(j / 10 * math.tau) * 0.09, 0.3 + math.sin(j / 10 * math.tau) * 0.09, 0.05)) for j in range(11)]
		f = part.pipe("W6Palette", ring, 0.01, sides=4, cap=False)
		cell_uv(part, f, "steel_grey", rnd)
		for s, d in ((0.06, 1), (-0.06, -1)):
			f = part.pipe("W6Palette", [xf((-0.08, 0.3, s)), xf((-0.08 + 0.12 * d, 0.3 - 0.11 * d, s * 1.6))], 0.009, sides=4)
			cell_uv(part, f, "steel_grey", rnd)
			f = part.pipe("W6Palette", [xf((-0.08 + 0.12 * d, 0.3 - 0.11 * d, s * 1.6)), xf((-0.08 + 0.12 * d, 0.3 - 0.11 * d, s * 2.6))], 0.014, sides=4)
			cell_uv(part, f, "black", rnd)
		for cx in (-0.55, 0.55):
			arc = [xf((cx + math.cos(math.radians(d)) * 0.37, 0.33 + math.sin(math.radians(d)) * 0.37, 0.0))
				for d in (range(15, 170, 22) if cx > 0 else range(20, 175, 22))]
			f = part.pipe("W6Palette", arc, 0.022, sides=4, cap=False)
			cell_uv(part, f, paint, rnd)
		for s in (-0.07, 0.07):
			f = part.pipe("W6Palette", [xf((-0.2, 0.74, s)), xf((-0.72, 0.74, s)), xf((-0.6, 0.36, s * 0.6))], 0.006, sides=4)
			cell_uv(part, f, "black", rnd)
		f = part.pipe("W6Palette", [xf((-0.72, 0.74, -0.07)), xf((-0.72, 0.74, 0.07))], 0.006, sides=4)
		cell_uv(part, f, "black", rnd)
		bkx0, bkx1, bky0, bky1, bkz = 0.5, 0.82, 0.86, 1.08, 0.16
		for pts in ([(bkx0, bky0, -bkz), (bkx1, bky0, -bkz), (bkx1, bky0, bkz), (bkx0, bky0, bkz), (bkx0, bky0, -bkz)],
				[(bkx0, bky1, -bkz), (bkx1, bky1, -bkz), (bkx1, bky1, bkz), (bkx0, bky1, bkz), (bkx0, bky1, -bkz)]):
			f = part.pipe("W6Palette", [xf(p) for p in pts], 0.005, sides=3, cap=False)
			cell_uv(part, f, "black", rnd)
		for j in range(5):
			zz = -bkz + j * bkz / 2
			for xx in (bkx0, bkx1):
				f = part.pipe("W6Palette", [xf((xx, bky0, zz)), xf((xx, bky1, zz))], 0.003, sides=3, cap=False)
				cell_uv(part, f, "black", rnd)
		if lean:
			# The kickstand on the side it leans to, its foot on the ground once leant (0.22 m out x tan 12 deg up).
			f = part.pipe("W6Palette", [xf((-0.12, 0.28, 0.05)), xf((-0.2, 0.22 * math.tan(lean_r), 0.22))], 0.008, sides=4)
			cell_uv(part, f, "chrome", rnd)
	part.bm.normal_update()
	export("bikes.glb", [build(part, {"W6Palette": 1.0})])


# ------------------------------------------------------------------------------------------------ the A16 strip

def _grid(part, mat, x0, z0, x1, z1, y, cell=4.0):
	faces = []
	nx = max(1, int(round((x1 - x0) / cell)))
	nz = max(1, int(round((z1 - z0) / cell)))
	for i in range(nx):
		for j in range(nz):
			xa, xb = x0 + (x1 - x0) * i / nx, x0 + (x1 - x0) * (i + 1) / nx
			za, zbb = z0 + (z1 - z0) * j / nz, z0 + (z1 - z0) * (j + 1) / nz
			faces.append(part.face(mat, [(xa, y, za), (xb, y, za), (xb, y, zbb), (xa, y, zbb)], (0, 1, 0)))
	return faces


EDGE = 0.12      # concrete edging round the forecourt (as T-262's walk)


def strip_regions():
	"""Rectangles (x0, z0, x1, z1) of the strip, the box less wave 8's corner (x < 170 north of z 37) and the building:
	lawn, pavers (the forecourt; west of T-262's walk an edging along z 13 first), concrete (aprons along the west,
	back and east walls, the kitchen's west wall, the service yard) and the covered drains on the aprons' outer edges
	(axis, across from, across to, along from, along to, the side the lawn is on)."""
	f = L.FOOTPRINT
	fp, yard, ap, dr = L.FRONT_PAVED, L.YARD, L.APRON, L.DRAIN
	kx = L.KITCHEN["x"][0] - T            # 185.875
	bz = L.HALL["z"][1] + T               # 44.125
	paved = [(fp["x"][0], fp["z"][0] + EDGE, 185.88, fp["z"][1]), (185.88, fp["z"][0], fp["x"][1], fp["z"][1])]
	concrete = [(f["x"][0] - ap, f["z"][0], f["x"][0], 37.0), (170.0, bz, kx, bz + ap), (kx - ap, bz + ap, kx, yard["z"][0]),
		(f["x"][1], f["z"][0], f["x"][1] + ap, yard["z"][0]), (yard["x"][0], yard["z"][0], yard["x"][1], yard["z"][1])]
	drains = [("z", f["x"][0] - ap - dr, f["x"][0] - ap, f["z"][0], 37.0, -1), ("x", bz + ap, bz + ap + dr, 170.0, kx - ap - dr, 1),
		("z", kx - ap - dr, kx - ap, bz + ap, yard["z"][0], -1), ("z", f["x"][1] + ap, f["x"][1] + ap + dr, f["z"][0], yard["z"][0], 1)]
	lawn = [(166.0, 13.0, fp["x"][0] - EDGE, fp["z"][1]), (166.0, fp["z"][1], f["x"][0] - ap - dr, 37.0),
		(fp["x"][1] + EDGE, 13.0, 218.0, fp["z"][1]), (f["x"][1] + ap + dr, fp["z"][1], 218.0, yard["z"][0]),
		(170.0, bz + ap + dr, kx - ap - dr, yard["z"][0]), (170.0, yard["z"][0], yard["x"][0], 60.0),
		(yard["x"][0], yard["z"][1], yard["x"][1], 60.0), (yard["x"][1], yard["z"][0], 218.0, 60.0)]
	return lawn, paved, concrete, drains


def build_strip():
	w1kit.reset()
	lawn_p = GPart("Lawn")
	pav = GPart("Pavers")
	yard = GPart("Yard")
	kerb = GPart("Kerbs")
	gut = GPart("Gutters")
	lawn, paved, concrete, drains = strip_regions()
	faces = []
	for x0, z0, x1, z1 in lawn:
		faces += _grid(lawn_p, "W6StripGround", x0, z0, x1, z1, L.GROUND_TOP)
	lawn_p.map_uv2(faces, lambda q: L.strip_uv2(q[0], q[2]))
	faces = []
	for x0, z0, x1, z1 in paved:
		faces += _grid(pav, "W6Pavers", x0, z0, x1, z1, L.PAVED_TOP, 3.0)
	pav.map_uv2(faces, lambda q: L.strip_uv2(q[0], q[2]))
	faces = []
	for x0, z0, x1, z1 in concrete:
		faces += _grid(yard, "W6YardConcrete", x0, z0, x1, z1, L.PAVED_TOP, 3.0)
	yard.map_uv2(faces, lambda q: L.strip_uv2(q[0], q[2]))
	# Concrete edging round the forecourt (south along z 13 west of T-262's walk, west and east ends), top 1 cm up.
	fp = L.FRONT_PAVED
	lo_y, top = G - 0.08, G + 0.01
	for lo, hi in (((fp["x"][0] - EDGE, lo_y, fp["z"][0]), (185.88, top, fp["z"][0] + EDGE)), ((fp["x"][0] - EDGE, lo_y, fp["z"][0] + EDGE), (fp["x"][0], top, fp["z"][1])),
			((fp["x"][1], lo_y, fp["z"][0]), (fp["x"][1] + EDGE, top, fp["z"][1]))):
		kerb.gbox("W1Concrete", lo, hi)
	# Covered drains on the aprons' outer edges: a dark channel under precast slabs 0.5 m long with 1.5 cm gaps; the
	# channel's outer lip shows 3 cm over the lawn.
	for axis, c0, c1, s0, s1, lawn_side in drains:
		def P3(c, y, s, axis=axis):
			return (c, y, s) if axis == "z" else (s, y, c)
		gut.face("W3GutterDark", [P3(c0, G - 0.12, s0), P3(c1, G - 0.12, s0), P3(c1, G - 0.12, s1), P3(c0, G - 0.12, s1)], (0, 1, 0))
		for cc, sign in ((c0, 1), (c1, -1)):
			n = (sign, 0, 0) if axis == "z" else (0, 0, sign)
			kerb.face("W1Concrete", [P3(cc, G - 0.12, s0), P3(cc, G - 0.12, s1), P3(cc, G, s1), P3(cc, G, s0)], n)
		lip = c0 if lawn_side < 0 else c1
		n = (lawn_side, 0, 0) if axis == "z" else (0, 0, lawn_side)
		kerb.face("W1Concrete", [P3(lip, L.GROUND_TOP - 0.01, s0), P3(lip, L.GROUND_TOP - 0.01, s1), P3(lip, G, s1), P3(lip, G, s0)], n)
		s = s0
		while s < s1 - 0.05:
			e = min(s1, s + 0.5)
			lo, hi = P3(c0, G - 0.05, s + 0.0075), P3(c1, G - 0.002, e - 0.0075)
			kerb.gbox("W1Concrete", (min(lo[0], hi[0]), lo[1], min(lo[2], hi[2])), (max(lo[0], hi[0]), hi[1], max(lo[2], hi[2])))
			s = e
	# The yard's slab edge where it meets the lawn (west, north, east), 3 cm over it.
	yd = L.YARD
	for pts, n in (([(yd["x"][0], L.GROUND_TOP - 0.01, yd["z"][0]), (yd["x"][0], L.GROUND_TOP - 0.01, yd["z"][1]), (yd["x"][0], G, yd["z"][1]), (yd["x"][0], G, yd["z"][0])], (-1, 0, 0)),
			([(yd["x"][0], L.GROUND_TOP - 0.01, yd["z"][1]), (yd["x"][1], L.GROUND_TOP - 0.01, yd["z"][1]), (yd["x"][1], G, yd["z"][1]), (yd["x"][0], G, yd["z"][1])], (0, 0, 1)),
			([(yd["x"][1], L.GROUND_TOP - 0.01, yd["z"][0]), (yd["x"][1], L.GROUND_TOP - 0.01, yd["z"][1]), (yd["x"][1], G, yd["z"][1]), (yd["x"][1], G, yd["z"][0])], (1, 0, 0))):
		kerb.face("W1Concrete", pts, n)
	# A floor drain grate in the yard by the back door, an expansion joint grid in the yard's slab (thin dark lines).
	gut.gbox("W1Iron", (201.6, G - 0.002, 53.4), (202.4, G + 0.004, 53.7))
	for zz in (55.3, 58.5 - 0.01):
		gut.gbox("W3GutterDark", (L.YARD["x"][0], G - 0.001, zz - 0.006), (L.YARD["x"][1], G + 0.002, zz + 0.006))
	for xx in (190.0, 196.0, 202.0 + 3.0, 208.0):
		gut.gbox("W3GutterDark", (xx - 0.006, G - 0.001, L.YARD["z"][0]), (xx + 0.006, G + 0.002, L.YARD["z"][1]))
	for p in (lawn_p, pav, yard, kerb, gut):
		p.bm.normal_update()
	export("strip_canteen.glb", [build(lawn_p, {"W6StripGround": 1.0}), build(pav, {"W6Pavers": L.SIZES["W6Pavers"]}),
		build(yard, {"W6YardConcrete": L.SIZES["W6YardConcrete"]}), build(kerb, {"W1Concrete": 0.8}), build(gut, {"W1Iron": 1.0})])


def surface_y(x, z):
	if L.in_footprint(x, z):
		return G + 0.002     # two of the PS1 papers lay inside the store (x 209.0..209.1): on its floor
	fp = L.FRONT_PAVED
	if fp["x"][0] <= x <= fp["x"][1] and fp["z"][0] <= z <= fp["z"][1]:
		return L.PAVED_TOP
	y = L.YARD
	if y["x"][0] <= x <= y["x"][1] and y["z"][0] <= z <= y["z"][1]:
		return L.PAVED_TOP
	return L.GROUND_TOP


def _pal4(part, faces, rgba, rnd):
	"""Faces into the wave-4 palette cell nearest this PS1 tint (the earlier strips' dropped things)."""
	best, key = 9.0, "black"
	for k in PALETTE4:
		try:
			c = [float(t) for t in k.split(",")]
		except ValueError:
			continue
		d = sum((a - b) ** 2 for a, b in zip(c, rgba[:3]))
		if d < best:
			best, key = d, k
	cx, cy = PALETTE4[key]
	for f in faces:
		ju, jv = rnd.uniform(0.3, 0.7), rnd.uniform(0.3, 0.7)
		for loop in f.loops:
			loop[part.uv].uv = ((cx + ju) / 8.0, 1.0 - (cy + jv) / 8.0)
		f.tag = True
	return keep(part, faces)


def _named4(part, faces, key, rnd):
	cx, cy = PALETTE4[key]
	for f in faces:
		for loop in f.loops:
			loop[part.uv].uv = ((cx + 0.5) / 8.0, 1.0 - (cy + 0.5) / 8.0)
		f.tag = True
	return keep(part, faces)


def build_strip_props():
	w1kit.reset()
	rnd = random.Random(26314)
	litter = GPart("Litter")
	dropped = GPart("Dropped")
	trays = GPart("StripTrays")
	data = json.loads(PS1_PROPS.read_text(encoding="utf-8"))
	cells = [(0.0, 0.5, 0.5, 1.0), (0.5, 0.5, 1.0, 1.0), (0.0, 0.0, 0.5, 0.5), (0.5, 0.0, 1.0, 0.5)]
	counts = {}
	for name, entry in data.items():
		v = entry["data"]
		for k in range(0, len(v), 16):
			c = v[k:k + 16]
			kind = L.replaced_kind(name, c)
			if kind is None:
				continue
			counts[kind] = counts.get(kind, 0) + 1
			basis = [Vector(c[0:3]), Vector(c[3:6]), Vector(c[6:9])]
			s = [b.length for b in basis]
			x, y, z = c[9:12]
			yaw = math.atan2(-basis[0].z, basis[0].x) if s[0] > 0 else 0.0
			gy = surface_y(x, z)
			if kind == "paper":
				size = max(0.18, min(0.42, s[0] * 1.3))
				a = rnd.uniform(0, math.tau)
				at = B((x, gy + 0.006, z))
				d = Vector((math.cos(a), math.sin(a), 0.0)) * size * 0.5
				n = Vector((-math.sin(a), math.cos(a), 0.0)) * size * 0.5
				u0, v0, u1, v1 = cells[rnd.randrange(4)]
				verts = [litter.bm.verts.new(p) for p in (at - d - n, at + d - n, at + d + n, at - d + n)]
				f = litter.bm.faces.new(verts)
				f.material_index = litter.slot("W3Litter")
				for loop, uv in zip(f.loops, [(u0, v0), (u1, v0), (u1, v1), (u0, v1)]):
					loop[litter.uv].uv = uv
				f.tag = True
			elif kind == "dropped: sandal":
				m = Matrix.Translation(B((x, gy + 0.008, z))) @ Matrix.Rotation(yaw, 4, "Z")
				f = dropped.box("W4Palette", (-s[0] * 0.48, -s[2] * 0.48, -0.008), (s[0] * 0.48, s[2] * 0.48, 0.008), bevel=0.006, segments=1, matrix=m)
				_pal4(dropped, f, c[12:16], rnd)
				strap = []
				for sx in (-1, 1):
					pts = [(0.0, s[2] * 0.22, 0.006), (sx * s[0] * 0.38, -s[2] * 0.02, 0.022), (sx * s[0] * 0.46, -s[2] * 0.08, 0.006)]
					strap += dropped.tube("W4Palette", [m @ Vector(p) for p in pts], 0.004, segments=4, cap=False)
				_named4(dropped, strap, "black", rnd)
			elif kind == "dropped: backpack":
				if abs(s[1] - 0.42) < 0.02:
					# Lying on its back (its 0.2 m depth upright), the shoulder straps on top.
					m = Matrix.Translation(B((x, gy + 0.105, z))) @ Matrix.Rotation(yaw, 4, "Z") @ Matrix.Rotation(math.radians(4), 4, "X")
					f = dropped.box("W4Palette", (-s[0] * 0.47, -s[1] * 0.48, -0.1), (s[0] * 0.47, s[1] * 0.48, 0.1), bevel=0.05, segments=2, matrix=m)
					_pal4(dropped, f, c[12:16], rnd)
					straps = []
					for sx in (-0.08, 0.08):
						pts = [(sx, s[1] * 0.42, 0.1), (sx, s[1] * 0.1, 0.16), (sx, -s[1] * 0.38, 0.11)]
						straps += dropped.tube("W4Palette", [m @ Vector(p) for p in pts], 0.012, segments=4, cap=False)
					_named4(dropped, straps, "black", rnd)
				else:
					m = Matrix.Translation(B((x, gy + 0.03, z))) @ Matrix.Rotation(yaw + 0.4, 4, "Z")
					f = dropped.box("W4Palette", (-s[0] * 0.45, -s[1] * 0.45, -0.03), (s[0] * 0.45, s[1] * 0.45, 0.03), bevel=0.02, segments=1, matrix=m)
					_pal4(dropped, f, c[12:16], rnd)
			elif kind == "dropped: tray":
				if name.startswith("P_white_box"):
					mt = P._tray(trays, x, gy + 0.003, z, math.degrees(yaw) + rnd.uniform(-20, 20), rnd, flip=True)
				else:
					a = rnd.uniform(0, math.tau)
					at = B((x + 0.25, gy + 0.006, z + 0.1))
					d = Vector((math.cos(a), math.sin(a), 0.0)) * 0.12
					n = Vector((-math.sin(a), math.cos(a), 0.0)) * 0.12
					u0, v0, u1, v1 = cells[0]
					verts = [litter.bm.verts.new(p) for p in (at - d - n, at + d - n, at + d + n, at - d + n)]
					f = litter.bm.faces.new(verts)
					f.material_index = litter.slot("W3Litter")
					for loop, uv in zip(f.loops, [(u0, v0), (u1, v0), (u1, v1), (u0, v1)]):
						loop[litter.uv].uv = uv
					f.tag = True
	print("T263_STRIP_PROPS", dict(sorted(counts.items())))
	for p in (litter, dropped, trays):
		p.bm.normal_update()
	export("strip_canteen_props.glb", [build(litter), build(dropped, {"W4Palette": 1.0}), build(trays, {"W6Stainless": 1.0, "W6Palette": 1.0})])


# ------------------------------------------------------------------------------------------------ targets

BUILDS = {"hall_east": build_hall_east, "store": build_store, "outside": build_outside, "bikes": build_bikes, "strip": build_strip,
	"strip_props": build_strip_props}


if __name__ == "__main__":
	random.seed(2632)
	args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for key in (args or list(BUILDS)):
		BUILDS[key]()
