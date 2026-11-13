"""T-253 (D-167) wave 2, A08-A10: building B's corridors on floors 1-3 and the rooms seen through their doors,
in wave 1's approved style (two-tone plaster with a green-grey dado, terrazzo floor and skirting, green paint, the
steel balustrade with a wooden rail, room 407's shell shader with masks drawn for these corridors).
Run with Blender 5.2.2 from the repository root (after make_wave2_textures.py):
  blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave2/build_hall.py [-- 1 2 3 kit]

Every glb is in Godot world metres unless it says otherwise; nothing here has a collider (building_b.tscn keeps
every PS1 collider; the new surfaces stand 3 mm in front of the PS1 faces they cover, whose outer faces stay).
  floor<N>_hall.glb   Hall0..3   the corridor two bays at a time: the room-side wall (dado, plaster, skirting), its
                                 returns at the stairwells, terrazzo floor with divider strips, plastered ceiling, the
                                 cross beams over the partitions and the edge beam; floors 2-3 the balustrade on a
                                 curb (in the rail collider), floor 1 the parapet walls of the lobby (their colliders)
                      Lamps      a tube batten under each KitDetail<N>/Light<x> (the lights stay where they are)
  floor<N>_rooms.glb  Rooms      the inside of every room one can see into: walls, floor, ceiling, skirting; on floors
                                 2-3 a light bunk and a locker inside the PS1 RoomInterior colliders (room 203 gets room
                                 407's furniture in the scene instead)
  kit (local frames, instanced in building_b.tscn):
    door_surround.glb        replaces the PS1 wall_door kit under KitDetail<N>/Frame<i> (origin: the doorway's
                             centre on the floor): linings, a transom bar over the 2.4 m leaves, stops, architraves
                             both sides, a granite threshold, hinge knuckles, the green backing of the room plate
    room_door_leaf_right.glb / room_door_leaf_left.glb   one leaf of a double door each, origin on its hinge line at
                             the leaf's foot; under Door<i>/Hinge/Leaf (RoomDoor) or a shut Door<i> body
    room_plate.glb           the aluminium plate (no digits: KitDetail<N>/Plate<i>/Number prints them)
"""
import math
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w2kit as K  # noqa: E402
from w2kit import G, L, gbox, quad  # noqa: E402

COVER = L.COVER
TOPH = L.CEILING - 0.002  # the plaster stops just under the ceiling's cover
DADO = 1.1
SKIRT = 0.12
SKIRT_OUT = 0.01
FLOOR_LIFT = 0.002
ROW = {3: 2.0 / 3.0, 2: 1.0 / 3.0, 1: 0.0}  # UV2 v base of each floor's row in the hall masks
CHUNKS = ((0, 1), (2, 3), (4, 5), (6, 7))
BEAM_W = 0.25
BEAM_D = 0.35
EDGE_BEAM = 3.75  # the edge beam's inner face (z); its outer face is the slab edge at 4.0


def row_v(floor, t):
	"""v inside a floor's row of a hall mask for t in 0..1 (kept off the row's edges)."""
	return ROW[floor] + (0.002 + 0.996 * min(max(t, 0.0), 1.0)) / 3.0


def chunk_span(chunk):
	a, b = chunk
	x0 = L.X0 if a == 0 else L.BAY * a
	x1 = L.X1 if b == L.BAYS - 1 else L.BAY * (b + 1)
	return x0, x1


# ---------------------------------------------------------------- walls

def wall(part, plane, c, s0, s1, base, holes, facing, mats, uv2, top=TOPH, dado=DADO, skirting=True, skirt_mat="W1Terrazzo"):
	"""A plastered wall on the plane z = c (plane "z": s runs along x) or x = c (plane "x": s runs along z), from
	s0 to s1, floor at y = base: the dado up to `dado`, plaster above, terrazzo skirting 1 cm proud. holes:
	[(s_a, s_b, h_top)] openings from the floor; [(s_a, s_b, h_top, h_bottom)] windows. uv2(s, h) -> (u, v)."""
	def P(s, h, off=0.0):
		if plane == "z":
			return (s, base + h, c + off * facing[2])
		return (c + off * facing[0], base + h, s)
	cuts = sorted({s0, s1} | {e for hole in holes for e in hole[:2] if s0 < e < s1})
	made = []
	for a, b in zip(cuts, cuts[1:]):
		mid = (a + b) / 2
		gap = [hole for hole in holes if hole[0] <= mid <= hole[1]]
		spans = [(0.0, top)]
		if gap:
			hole = gap[0]
			bottom = hole[3] if len(hole) > 3 else 0.0
			spans = [(hole[2], top)] + ([(0.0, bottom)] if bottom > 0.0 else [])
		for lo, hi in spans:
			if hi - lo < 1e-4:
				continue
			for blo, bhi, mat in ((lo, min(hi, dado), mats[0]), (max(lo, dado), hi, mats[1])):
				if bhi - blo < 1e-4:
					continue
				f = quad(part, mat, P(a, blo), P(b, blo), P(b, bhi), P(a, bhi), facing)
				part.set_uv2([f], lambda co, plane=plane: uv2(co.x if plane == "z" else -co.y, co.z - base))
				made.append(f)
		if skirting and not (gap and (gap[0][3] if len(gap[0]) > 3 else 0.0) == 0.0):
			lo_s = gbox(part, skirt_mat, P(a, 0.0), P(b, SKIRT, SKIRT_OUT))
			made += lo_s
	return made


def wall_return(part, x, z0, z1, base, facing, mats, uv2):
	"""The corridor wall's return into a stairwell (plane x), with its skirting."""
	return wall(part, "x", x, z0, z1, base, [], facing, mats, uv2)


# ---------------------------------------------------------------- corridor

def hall_chunk(floor, chunk):
	y = L.FLOORS[floor]
	x0, x1 = chunk_span(chunk)
	part = K.Part("Hall%d" % CHUNKS.index(chunk))
	face = L.FACE + COVER
	wall_uv2 = lambda s, h: (s / 44.0, row_v(floor, h / L.CEILING))  # noqa: E731
	holes = [(L.door_x(i) - L.DOOR_HALF, L.door_x(i) + L.DOOR_HALF, L.DOOR_TOP) for i in range(L.BAYS)]
	wx0 = x0 - (L.END_HALF + COVER) if x0 == L.X0 else x0
	wx1 = x1 + (L.END_HALF + COVER) if x1 == L.X1 else x1
	wall(part, "z", face, wx0, wx1, y, holes, (0, 0, 1), ("W2HallDado", "W2HallWall"), wall_uv2)
	if x0 == L.X0:
		wall_return(part, x0 - L.END_HALF - COVER, -0.2, face, y, (-1, 0, 0), ("W2HallDado", "W2HallWall"), wall_uv2)
	if x1 == L.X1:
		wall_return(part, x1 + L.END_HALF + COVER, -0.2, face, y, (1, 0, 0), ("W2HallDado", "W2HallWall"), wall_uv2)
	# The stair towers' front walls (MainStairs/FireStairs FrontRail, x -5.1..0.1 and 43.9..49.1, z 4.025..4.175)
	# end at the corridor: plaster on their end faces.
	for end, x, facing in ((x0 == L.X0, L.X0 + 0.1 + COVER, 1), (x1 == L.X1, L.X1 - 0.1 - COVER, -1)):
		if end:
			wall(part, "x", x, 4.025, 4.175, y, [], (facing, 0, 0), ("W2HallDado", "W2HallWall"),
				lambda s, h: (x / 44.0, row_v(floor, h / L.CEILING)), skirting=False)
	# Floor: terrazzo over the slab, to the rail's curb (floor 1: the parapet, and out to the main door).
	front = L.RAIL_FRONT if floor != 1 else L.RAIL_FRONT - COVER
	floor_uv2 = lambda co: (co.x / 44.0, row_v(floor, -co.y / 4.0))  # noqa: E731
	fl = quad(part, "W2HallFloor", (wx0, y + FLOOR_LIFT, face), (wx1, y + FLOOR_LIFT, face),
		(wx1, y + FLOOR_LIFT, front), (wx0, y + FLOOR_LIFT, front), (0, 1, 0))
	part.set_uv2([fl], floor_uv2)
	if floor == 1 and x0 <= L.MAIN_DOOR_X <= x1:
		a, b = L.LOBBY_RAILS[0][1], L.LOBBY_RAILS[1][0]
		f2 = quad(part, "W2HallFloor", (a, y + FLOOR_LIFT, front), (b, y + FLOOR_LIFT, front),
			(b, y + FLOOR_LIFT, 4.05), (a, y + FLOOR_LIFT, 4.05), (0, 1, 0))
		part.set_uv2([f2], floor_uv2)
	# Divider strips cast into the terrazzo: across every 1.1 m, along at z 1, 2 and 3.
	lift = y + FLOOR_LIFT + 0.0006
	k = math.ceil(wx0 / 1.1)
	while k * 1.1 < wx1 - 0.05:
		xs = k * 1.1
		if xs > wx0 + 0.05:
			quad(part, "W2Divider", (xs - 0.003, lift, face), (xs + 0.003, lift, face), (xs + 0.003, lift, front),
				(xs - 0.003, lift, front), (0, 1, 0))
		k += 1
	for zs in (1.0, 2.0, 3.0):
		quad(part, "W2Divider", (wx0, lift, zs - 0.003), (wx1, lift, zs - 0.003), (wx1, lift, zs + 0.003),
			(wx0, lift, zs + 0.003), (0, 1, 0))
	# Ceiling: plaster under the ceiling box, cross beams over the partitions, the edge beam along the open side.
	ceil = y + L.CEILING - COVER
	ceil_uv2 = lambda co: (co.x / 44.0, row_v(floor, -co.y / 4.0))  # noqa: E731
	cf = quad(part, "W2HallCeiling", (wx0, ceil, face), (wx1, ceil, face), (wx1, ceil, L.SLAB_EDGE),
		(wx0, ceil, L.SLAB_EDGE), (0, -1, 0))
	part.set_uv2([cf], ceil_uv2)
	beams = []
	for i in range(L.BAYS - 1):
		bx = L.partition_x(i)
		if x0 - 1e-6 <= bx <= x1 + 1e-6 and (bx < x1 - 1e-6 or x1 == L.X1):
			beams += gbox(part, "W2HallCeiling", (bx - BEAM_W / 2, ceil - BEAM_D, face), (bx + BEAM_W / 2, ceil, EDGE_BEAM))
	beams += gbox(part, "W2HallCeiling", (wx0, ceil - BEAM_D, EDGE_BEAM), (wx1, ceil, L.SLAB_EDGE))
	part.set_uv2(beams, ceil_uv2)
	if floor == 1:
		parapet(part, floor, x0, x1)
	else:
		balustrade(part, y, x0, x1)
	return K.build(part)


def balustrade(part, y, x0, x1):
	"""Floors 2-3: wave 1's well balustrade along the open side, inside the Rail collider (z 3.945..4.095,
	y 0..1.3): a concrete curb, square steel bars every 12.5 cm, flat steel rails, posts every 2.75 m and the
	wooden handrail on top (its top at 1.295)."""
	z = L.RAIL_Z
	gbox(part, "W1Concrete", (x0, y, 3.95), (x1, y + 0.1, 4.09), bevel=0.006)
	gbox(part, "W1RailSteel", (x0, y + 0.16, z - 0.012), (x1, y + 0.19, z + 0.012))
	gbox(part, "W1RailSteel", (x0, y + 1.215, z - 0.02), (x1, y + 1.235, z + 0.02))
	wood = gbox(part, "W1RailWood", (x0, y + 1.235, z - 0.032), (x1, y + 1.295, z + 0.032), bevel=0.012, segments=2)
	posts = [x0 + 0.03 if x0 == L.X0 else x0] + [x0 + k * 2.75 for k in range(1, int(round((x1 - x0) / 2.75)))]
	if x1 == L.X1:
		posts.append(x1 - 0.03)
	for px in posts:
		gbox(part, "W1RailSteel", (px - 0.025, y + 0.1, z - 0.025), (px + 0.025, y + 1.235, z + 0.025), bevel=0.003)
	count = int(round((x1 - x0) / 0.125))
	for k in range(count):
		bx = x0 + (k + 0.5) * (x1 - x0) / count
		if min(abs(bx - p) for p in posts) < 0.05:
			continue
		gbox(part, "W1RailSteel", (bx - 0.008, y + 0.19, z - 0.008), (bx + 0.008, y + 1.215, z + 0.008))


def parapet(part, floor, x0, x1):
	"""Floor 1: the lobby's low walls (LobbyRailWest/East, x 0..17.65 and 20.65..44, y 0..1.3,
	z 3.945..4.095), plastered both sides with a terrazzo coping; the gap for the main door."""
	y = L.FLOORS[floor]
	uv2 = lambda s, h: (s / 44.0, row_v(floor, h / L.CEILING))  # noqa: E731
	for a, b in L.LOBBY_RAILS:
		a, b = max(a, x0), min(b, x1)
		if b - a < 1e-4:
			continue
		top = 1.25
		wall(part, "z", L.RAIL_FRONT - COVER, a, b, y, [], (0, 0, -1), ("W2HallDado", "W2HallWall"), uv2, top=top)
		# The outside face: plaster to the coping (the campus side), no skirting.
		wall(part, "z", 4.095 + COVER, a, b, y, [], (0, 0, 1), ("W1StairDado", "W1StairWall"),
			lambda s, h: ((s % 5.0) / 5.0, h / 3.3), top=top, dado=0.45, skirting=False)
		gbox(part, "W1Terrazzo", (a - (0.02 if a == L.LOBBY_RAILS[1][0] else 0.0), y + top, 3.925),
			(b + (0.02 if b == L.LOBBY_RAILS[0][1] else 0.0), y + 1.3, 4.115), bevel=0.008)
		for end, facing in ((a, -1), (b, 1)):
			if end in (L.LOBBY_RAILS[0][1], L.LOBBY_RAILS[1][0]):
				x = end + facing * COVER
				wall(part, "x", x, L.RAIL_FRONT - COVER, 4.095 + COVER, y, [], (facing, 0, 0),
					("W1StairDado", "W1StairWall"), lambda s, h: ((s - 3.9) / 0.2, h / 3.3), top=top, skirting=False)


def lamps(floor):
	"""A batten under each KitDetail<N>/Light<x> (y + 2.65): enamel housing, two tubes (lit), end caps."""
	y = L.FLOORS[floor]
	part = K.Part("Lamps")
	ceil = y + L.CEILING - COVER
	for lx in L.LIGHTS_X:
		cz = L.LIGHT_Z
		gbox(part, "W1Enamel", (lx - 0.62, ceil - 0.065, cz - 0.07), (lx + 0.62, ceil, cz + 0.07), bevel=0.01, segments=2)
		for side in (-1, 1):
			gbox(part, "W1Enamel", (lx - 0.61, ceil - 0.09, cz + side * 0.075 - 0.003), (lx + 0.61, ceil - 0.06, cz + side * 0.075 + 0.003))
			gbox(part, "W1Enamel", (lx + side * 0.6 - 0.018, ceil - 0.11, cz - 0.07), (lx + side * 0.6 + 0.018, ceil - 0.06, cz + 0.07), bevel=0.006)
		for tz in (cz - 0.035, cz + 0.035):
			part.tube("W2Tube", [G(lx - 0.575, ceil - 0.1, tz), G(lx + 0.575, ceil - 0.1, tz)], 0.0135, 12)
			for ex in (-1, 1):
				part.tube("W1Steel", [G(lx + ex * 0.575, ceil - 0.1, tz), G(lx + ex * 0.588, ceil - 0.1, tz)], 0.0145, 10)
		# The conduit from the wall to the batten along the ceiling.
		gbox(part, "W1Enamel", (lx - 0.012, ceil - 0.016, L.FACE + COVER), (lx + 0.012, ceil, cz - 0.07))
		gbox(part, "W1Enamel", (lx - 0.035, ceil - 0.03, L.FACE + COVER), (lx + 0.035, ceil, L.FACE + COVER + 0.05), bevel=0.004)
	return K.build(part)


# ---------------------------------------------------------------- rooms

def room_shell(part, floor, i):
	"""Walls, floor, ceiling and skirting of bay i's room (all faces 3 mm in front of the PS1 boxes)."""
	y = L.FLOORS[floor]
	rx0, rx1 = L.bay_span(i)
	rx0, rx1 = rx0 + COVER, rx1 - COVER
	back = L.BACK_FACE + COVER
	front = -L.FACE - COVER
	dx = L.door_x(i)
	mats = ("W1StairDado", "W1StairWall")
	door = [(dx - L.DOOR_HALF, dx + L.DOOR_HALF, L.DOOR_TOP)]
	along = lambda a, b: (lambda s, h: ((s - a) / (b - a), h / 3.3))  # noqa: E731
	wall(part, "z", front, rx0, rx1, y, door, (0, 0, -1), mats, along(rx0, rx1))
	holes = []
	if floor == 1 and i == 0:
		w = L.WINDOW
		holes = [(w["x0"], w["x1"], w["head"], w["sill"])]
	wall(part, "z", back, rx0, rx1, y, holes, (0, 0, 1), mats, along(rx1, rx0))
	wall(part, "x", rx0, back, front, y, [], (1, 0, 0), mats, along(back, front))
	wall(part, "x", rx1, back, front, y, [], (-1, 0, 0), mats, along(front, back))
	fl = quad(part, "W1Terrazzo", (rx0, y + FLOOR_LIFT, back), (rx1, y + FLOOR_LIFT, back), (rx1, y + FLOOR_LIFT, front),
		(rx0, y + FLOOR_LIFT, front), (0, 1, 0))
	part.set_uv2([fl], lambda co: ((co.x - rx0) / (rx1 - rx0), (-co.y - front) / (back - front)))
	quad(part, "W1Soffit", (rx0, y + TOPH, back), (rx1, y + TOPH, back), (rx1, y + TOPH, front), (rx0, y + TOPH, front), (0, -1, 0))


def bunk(part, floor, i):
	"""A light steel bunk inside the PS1 bunk colliders (decks y 0.32..0.48 and 1.37..1.53, x -2.225..-1.375,
	z -4.425..-2.475 from the door centre), boards, a thin mattress below and a rolled mat above."""
	y = L.FLOORS[floor]
	b = L.ROOM_BUNK
	cx = L.door_x(i) + b["x"]
	hx, hz = 0.415, 0.965
	za, zb = b["z"] - hz, b["z"] + hz
	t = 0.018
	for px in (cx - hx + t, cx + hx - t):
		for pz in (za + t, zb - t):
			gbox(part, "W2BunkPaint", (px - t, y, pz - t), (px + t, y + 1.78, pz + t), bevel=0.004)
	for deck in b["decks"]:
		top = y + deck + 0.06
		for side in (-1, 1):
			gbox(part, "W2BunkPaint", (cx + side * (hx - t) - t, top - 0.07, za + t), (cx + side * (hx - t) + t, top - 0.02, zb - t))
		for pz in (za + t, zb - t):
			gbox(part, "W2BunkPaint", (cx - hx + t, top - 0.07, pz - t), (cx + hx - t, top - 0.02, pz + t))
		for k in range(7):
			pz = za + 0.08 + k * (zb - za - 0.16) / 6
			gbox(part, "W1WoodPale", (cx - hx + 0.03, top - 0.035, pz - 0.045), (cx + hx - 0.03, top - 0.02, pz + 0.045))
	# Head and foot boards of tube, the upper guard rail on the room side.
	for pz in (za + t, zb - t):
		for h in (0.75, 1.75):
			gbox(part, "W2BunkPaint", (cx - hx + t, y + h - 0.012, pz - 0.012), (cx + hx - t, y + h + 0.012, pz + 0.012))
	gbox(part, "W2BunkPaint", (cx + hx - 2 * t, y + 1.72, za + t), (cx + hx, y + 1.745, zb - t))
	gbox(part, "W2Mattress", (cx - hx + 0.04, y + 0.46, za + 0.06), (cx + hx - 0.04, y + 0.52, zb - 0.06), bevel=0.02, segments=2)
	part.tube("W2Chieu", [G(cx - hx + 0.06, y + 1.56, za + 0.25), G(cx + hx - 0.06, y + 1.56, za + 0.25)], 0.06, 10)
	gbox(part, "W2Pillow", (cx - 0.28, y + 0.52, za + 0.08), (cx + 0.28, y + 0.6, za + 0.38), bevel=0.03, segments=2)


def locker(part, floor, i):
	"""A two-door steel locker inside the PS1 locker collider (x 1.45..2.15, y 0..1.7, z -4.225..-3.575)."""
	y = L.FLOORS[floor]
	c = L.ROOM_LOCKER
	cx = L.door_x(i) + c["x"]
	sx, sy, sz = c["size"]
	x0, x1 = cx - sx / 2 + 0.01, cx + sx / 2 - 0.01
	z0, z1 = c["z"] - sz / 2 + 0.01, c["z"] + sz / 2 - 0.01
	gbox(part, "W2LockerPaint", (x0, y + 0.06, z0), (x1, y + 1.68, z1), bevel=0.006)
	gbox(part, "W1Black", (x0 + 0.02, y, z0 + 0.03), (x1 - 0.02, y + 0.06, z1 - 0.03))
	# Doors face the room's middle (+z): two leaves, louvres, handles.
	front = z1
	for k, (a, b) in enumerate(((x0 + 0.01, cx - 0.004), (cx + 0.004, x1 - 0.01))):
		gbox(part, "W2LockerPaint", (a, y + 0.09, front), (b, y + 1.65, front + 0.008), bevel=0.003)
		for v in range(5):
			h = y + 1.42 + v * 0.035
			gbox(part, "W1Black", (a + 0.05, h, front + 0.006), (b - 0.05, h + 0.012, front + 0.0095))
		hx = b - 0.035 if k == 0 else a + 0.035
		gbox(part, "W1Steel", (hx - 0.008, y + 0.9, front + 0.008), (hx + 0.008, y + 1.05, front + 0.025))


def rooms(floor):
	part = K.Part("Rooms")
	for i in range(L.BAYS):
		if not L.room_visible(floor, i):
			continue
		room_shell(part, floor, i)
		if floor in (2, 3) and not (floor == 2 and i == L.ROOM203_BAY):
			bunk(part, floor, i)
			locker(part, floor, i)
	return K.build(part)


# ---------------------------------------------------------------- kit (local frames)

def door_surround():
	"""Origin: the doorway's centre on the floor (KitDetail<N>/Frame<i> stands at (x, y, 0))."""
	part = K.Part("DoorSurround")
	h, face = L.DOOR_HALF, L.FACE + COVER
	paint = "W1DoorPaint"
	lin = 0.004
	for s in (-1, 1):
		gbox(part, paint, (s * (h - lin), 0.008, -face), (s * h, 2.392, face))
		# Stops behind the leaves (they close from the corridor side at z 0.03..0.07).
		gbox(part, paint, (s * (h - lin - 0.011), 0.008, 0.012), (s * (h - lin), 2.392, 0.03))
		for side in (-1, 1):
			z0, z1 = (face, face + 0.022) if side > 0 else (-face - 0.022, -face)
			gbox(part, paint, (s * h, 0.0, z0), (s * (h + 0.07), 2.57, z1), bevel=0.004)
		# Hinge knuckles on the jamb, one leaf each side.
		for ky in (0.26, 1.21, 2.14):
			part.cylinder("W1Steel", tuple(G(s * (h - 0.007), ky, 0.074)), 0.007, 0.1, axis="Z", segments=10)
			gbox(part, "W1Steel", (s * (h - 0.004), ky - 0.045, 0.06), (s * (h - 0.001), ky + 0.045, 0.074))
	# The transom bar over the 2.4 m leaves fills the opening's top (y 2.392..2.5), its lining, the stop.
	gbox(part, paint, (-h, 2.392, -face), (h, 2.5, face), bevel=0.002)
	gbox(part, paint, (-h + lin, 2.38, 0.012), (h - lin, 2.392, 0.03))
	for side in (-1, 1):
		z0, z1 = (face, face + 0.022) if side > 0 else (-face - 0.022, -face)
		gbox(part, paint, (-(h + 0.07), 2.5, z0), (h + 0.07, 2.57, z1), bevel=0.004)
	# Granite threshold (6 mm proud of the terrazzo).
	gbox(part, "W1Granite", (-h, 0.0, -face), (h, 0.008, face), bevel=0.002)
	# The plate's green backing on the wall over the head (its front at z 0.105: the plate stands proud of it).
	gbox(part, paint, (-0.19, 2.62, face), (0.19, 2.8, face + 0.022), bevel=0.004)
	return K.build(part)


def leaf(side):
	"""One leaf of the double door, 0.836 x 2.38 x 0.04 at z 0.03..0.07; origin on its hinge line at its foot.
	side 'right': the hinge on its +x edge (the leaf runs to -x), 'left' the mirror. Raised panels both faces,
	a lever handle and a lock on the right leaf (the active one), flush bolts on the left one."""
	s = -1 if side == "right" else 1  # direction from the hinge to the meeting edge
	part = K.Part("Leaf" + side.capitalize())
	paint = "W1DoorPaint"
	a, b = 0.0045, 0.8425  # from the hinge line
	xs = sorted((s * a, s * b))
	z0, z1 = 0.03, 0.07
	H = 2.38
	stile, top_rail, mid_rail, bottom_rail = 0.11, 0.12, 0.18, 0.22
	gbox(part, paint, (xs[0], 0.0, z0 + 0.008), (xs[1], H, z1 - 0.008))
	inner = (xs[0] + stile, xs[1] - stile)
	for lo, hi in ((xs[0], xs[0] + stile), (xs[1] - stile, xs[1])):
		gbox(part, paint, (lo, 0.0, z0), (hi, H, z1), bevel=0.003)
	mid = 1.0
	for lo, hi in ((0.0, bottom_rail), (mid - mid_rail / 2, mid + mid_rail / 2), (H - top_rail, H)):
		gbox(part, paint, (inner[0], lo, z0), (inner[1], hi, z1), bevel=0.003)
	# Raised fields in the two panels, both faces.
	for lo, hi in ((bottom_rail, mid - mid_rail / 2), (mid + mid_rail / 2, H - top_rail)):
		for zz in ((z1 - 0.012, z1 - 0.003), (z0 + 0.003, z0 + 0.012)):
			gbox(part, paint, (inner[0] + 0.035, lo + 0.035, zz[0]), (inner[1] - 0.035, hi - 0.035, zz[1]), bevel=0.012, segments=2)
	meet = s * b
	if side == "right":
		# Astragal over the meeting gap (corridor face), lever handles both faces, a key escutcheon.
		gbox(part, paint, (meet - 0.012, 0.01, z1), (meet + 0.006, H - 0.01, z1 + 0.008), bevel=0.002)
		hx = meet + 0.065
		for face_z, out in ((z1, 1), (z0, -1)):
			gbox(part, "W1Steel", (hx - 0.022, 0.86, face_z), (hx + 0.022, 1.13, face_z + out * 0.006), bevel=0.003)
			part.cylinder("W1Steel", tuple(G(hx, 1.05, face_z + out * 0.03)), 0.009, 0.05, axis="Y", segments=10)
			part.tube("W1Steel", [G(hx, 1.05, face_z + out * 0.055), G(hx - s * 0.12, 1.05, face_z + out * 0.06)], 0.009, 10)
			part.cylinder("W1Black", tuple(G(hx, 0.93, face_z + out * 0.0065)), 0.006, 0.002, axis="Y", segments=8)
	else:
		for by in (0.02, H - 0.25):
			gbox(part, "W1Steel", (meet - 0.03, by, z0 - 0.006), (meet - 0.012, by + 0.23, z0))
	return K.build(part)


def plate():
	"""Origin: KitDetail<N>/Plate<i> ((x, y + 2.6, 0.12)); the plate's back at z 0.1075 world, centred at y + 2.71
	on its backing; anodised aluminium with a stamped rim and two screws. The digits are the Label3D."""
	part = K.Part("Plate")
	w, h, t = 0.3, 0.12, 0.0025
	cy, back = 0.11, 0.1075 - 0.12
	gbox(part, "W1Alu", (-w / 2, cy - h / 2, back), (w / 2, cy + h / 2, back + t), bevel=0.0015)
	for lo, hi in (((-w / 2 + 0.008, cy + h / 2 - 0.011), (w / 2 - 0.008, cy + h / 2 - 0.008)),
			((-w / 2 + 0.008, cy - h / 2 + 0.008), (w / 2 - 0.008, cy - h / 2 + 0.011)),
			((-w / 2 + 0.008, cy - h / 2 + 0.008), (-w / 2 + 0.011, cy + h / 2 - 0.008)),
			((w / 2 - 0.011, cy - h / 2 + 0.008), (w / 2 - 0.008, cy + h / 2 - 0.008))):
		gbox(part, "W1Alu", (lo[0], lo[1], back + t), (hi[0], hi[1], back + t + 0.0007))
	for sx in (-1, 1):
		part.cylinder("W1Steel", tuple(G(sx * (w / 2 - 0.022), cy, back + t + 0.001)), 0.0035, 0.002, axis="Y", segments=8)
	return K.build(part)


def main():
	K.materials()
	which = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else ["1", "2", "3", "kit"]
	for job in which:
		if job == "kit":
			for name, fn in (("door_surround.glb", door_surround), ("room_plate.glb", plate)):
				K.export(name, [fn()])
				K.reset()
				K.materials()
			for side in ("right", "left"):
				K.export("room_door_leaf_%s.glb" % side, [leaf(side)])
				K.reset()
				K.materials()
			continue
		floor = int(job)
		objs = [hall_chunk(floor, c) for c in CHUNKS] + [lamps(floor)]
		K.export("floor%d_hall.glb" % floor, objs)
		K.reset()
		K.materials()
		K.export("floor%d_rooms.glb" % floor, [rooms(floor)])
		K.reset()
		K.materials()


main()
