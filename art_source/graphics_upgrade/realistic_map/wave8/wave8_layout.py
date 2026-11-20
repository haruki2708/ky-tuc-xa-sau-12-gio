"""T-265 wave 8: the library's measurements, taken from main's library.tscn (art_source/ch4_environment/build.py made it,
survey/library_nodes.tsv and plan_geometry.json confirm it). Godot world coordinates: the scene's root sits at
(45, -9.9, 195), so world = local + (45, -9.9, 195). Shared by the plan, the Blender pilot, the texture and capture
scripts. Pure Python (Blender's interpreter imports it).
"""
ORIGIN = (45.0, -9.9, 195.0)
G = -9.9
FLOOR_H = 3.3
LEVELS = [-9.9, -6.6, -3.3]          # floor tops (Floor<t>_Main/_South/_North tops; slabs 0.24 thick under them)
SLAB = 0.24
ROOF_UNDER = -0.05                   # Roof: 40 x 0.2 x 30 at y 0.05
ROOF_TOP = 0.15
CEILING = [y + FLOOR_H - SLAB for y in LEVELS[:2]] + [ROOF_UNDER]   # -6.84, -3.54, -0.05

# Walls (0.22 thick, centred on the scene's x 0 / 40, z 0 / 30): inner and outer faces.
WALL_T = 0.22
IN_W, IN_E, IN_S, IN_N = 45.11, 84.89, 195.11, 224.89
OUT_W, OUT_E, OUT_S, OUT_N = 44.89, 85.11, 194.89, 225.11
# The doorways through the ground floor's front (z 195) and back (z 225) walls: x 64..66, 2.4 m high (lintel above).
DOOR_X = (64.0, 66.0)
DOOR_H = 2.4
FRONT_DOOR = {"x": (64.025, 65.975), "z": (194.94, 195.06), "y": (G, G + 2.4)}      # FrontDoor: solid leaf, never opens
BACK_DOOR = {"at": (65.0, G, 225.0), "hinge_x": 64.03, "leaf": 1.94, "height": 2.4, "leaf_t": 0.1, "blocker_t": 0.16}
# Windows: 3 x 1.35 m dark panels (Window<t>_<x>_<z>) on the inside faces, x 50 / 58 / 72 / 80, both long walls; their foot
# 1.125 m and head 2.475 m over each floor; Sill<t>_* 3.15 x 0.07 x 0.25 at 1.1 m. The walls are solid behind them.
WINDOWS_X = [50.0, 58.0, 72.0, 80.0]
WINDOW = {"w": 3.0, "foot": 1.125, "head": 2.475, "sill": 1.1}
LIGHTS_X = [54.0, 70.0]               # Light<t>_9, _25: (x, floor + 2.8, 211), energy 0.65, range 16, kept as they are
LIGHT_Z = 211.0
LIGHT_H = 2.8
# Stairs on the east: two flights (Stairs0 floor 1 -> 2, Stairs1 floor 2 -> 3), x 79..84, rising north from z 199 to 209,
# 22 steps (0.15 rise, 10/22 tread); rails (RailCollision<t>_34 / _39) at x 79 and 84, 1.1 m over the slope. Upper
# floors are open over x 79..85, z 199..209 (the well). StairBase (floor 1) x 79..85, z 199..209.
STAIRS = {"x": (79.0, 84.0), "z": (199.0, 209.0), "steps": 22, "rise": 0.15}
RAILS_X = [79.0, 84.0]
WELL = (79.0, 85.0, 199.0, 209.0)
STAIR_FOOT = (81.0, 198.0)            # StairBottom<t> link (81, y, 198) -> (81, y, 199.1)
STAIR_TOP = (81.0, 210.0)             # StairTop<t> link (81, y + 3.3, 208.9) -> (81, y + 3.3, 210)
# Furniture (world), with the colliders kept.
SHELF_X = [51.0, 57.0, 73.0]          # Shelf<t>_6, _12, _28
SHELF_Z = {0: 218.0, 1: 202.0, 2: 218.0}
SHELF = {"w": 3.0, "d": 0.6, "h": 2.2, "back_z": 0.26, "boards_y": [0.1 + 0.56 * k for k in range(4)], "board_t": 0.07,
	"side_x": 1.48, "side_t": 0.08, "back_t": 0.08}      # open face toward -z (the front of the building)
TABLES_X = [53.0, 58.0, 72.0]         # ReadingTable8, 13, 27 on floor 2, z 216, 3 x 1.4, top 0.72..0.84 (only Top is solid)
TABLE_Z = 216.0
TABLE = {"w": 3.0, "d": 1.4, "top": 0.84, "top_t": 0.12}
CHAIR_DZ = 1.2                        # Chair<x>_-1 / _1 at z 216 -/+ 1.2 (no collider)
COUNTER = {"at": (57.0, G, 206.0), "w": 5.0, "d": 1.4, "top": 0.84, "top_t": 0.12, "panel_z": 0.6, "panel_t": 0.12, "panel_y": (0.05, 0.75)}
IRON_BAR = (58.0, -9.0, 206.0)        # Counter/IronBar: the pipe's middle line 0.9 over the floor, r 0.0135 -> its foot 0.886
LIBRARIAN_CHAIR = (57.0, G, 207.5)    # the anchor LibrarianSeat (57, -9.44, 207.5) is its seat
MAP_BOARD = {"at": (45.15, -8.1, 211.0), "w": 3.1, "h": 2.1, "paper": (2.9, 1.9)}   # on the west wall, facing +x
BARRICADE = {"at": (65.0, G, 196.0), "w": 2.6, "d": 1.3, "top": 0.84, "chairs_x": [64.2, 65.0, 65.8], "chairs_y": -9.05}
# Chapter 4's anchors (ch4_anchors.tscn, world; never moved).
ANCHORS = {"Start_library": (65.0, G, 223.0), "Counter": (58.0, -9.0, 206.0), "MapBoard": (45.25, -8.1, 211.0),
	"LibrarianSeat": (57.0, -9.44, 207.5), "ReadingDesk": (58.0, -5.71, 216.0), "ScareShelf3F": (57.0, -3.3, 218.0),
	"ThrownBook3F": (73.0, -1.1, 218.0)}
SPAWNS = [(62.0 + 3.0 * (i % 3), G, 228.0 + 3.0 * (i // 3)) for i in range(6)]
ZONE = (39.0, 91.0, 189.0, 231.0)     # wave 8's box: the library and 6 m round it
RUBBLE = [(58.0, 192.0, 25.91), (78.0, 192.0, 320.44)]   # Props/Solids/Body_p1_p4/S0, S1: 3.4 x 0.8 x 3.0 (kept)

# Masks (make_wave8_textures.py). Floors and ceilings: one row per floor of mask_floor8.png / mask_ceiling8.png over the
# inside x 45.11..84.89, z 195.11..224.89. Walls: mask_walls8.png rows 0..2 the inside faces of floors 1..3 (unrolled
# anticlockwise seen from above: front from the west, east, back from the east, west; 3.3 m high), row 3 the outside
# faces (the same order, from the ground to the parapet's top).
IN_RUNS = {"front": 0.0, "east": 39.78, "back": 69.56, "west": 109.34}
RUN_BACK = IN_RUNS["back"]
OUT_RUNS = {"front": 0.0, "east": 40.22, "back": 70.44, "west": 110.66}
OUT_RUN_BACK = OUT_RUNS["back"]
PARAPET_TOP = 0.6
WALL_ROWS = 4
WALL_ROW_SIZE = [(139.12, FLOOR_H)] * 3 + [(140.88, PARAPET_TOP - G)]


def floor_uv2(level, x, z):
	u = min(max((x - IN_W) / (IN_E - IN_W), 0.0), 1.0)
	v = min(max((z - IN_S) / (IN_N - IN_S), 0.0), 1.0)
	return (u, (level + 0.004 + v * 0.992) / 3.0)


def wall_uv2(row, s, y_rel):
	length, height = WALL_ROW_SIZE[row]
	u = min(max(s / length, 0.0), 1.0)
	v = min(max(y_rel / height, 0.0), 1.0)
	return (u, (row + 1.0 - (0.004 + v * 0.992)) / WALL_ROWS)


def inner_s(x, z):
	"""Metres along the inside perimeter (IN_RUNS) of a point on an inside wall face."""
	if abs(z - IN_S) < 0.05:
		return IN_RUNS["front"] + (x - IN_W)
	if abs(x - IN_E) < 0.05:
		return IN_RUNS["east"] + (z - IN_S)
	if abs(z - IN_N) < 0.05:
		return IN_RUNS["back"] + (IN_E - x)
	return IN_RUNS["west"] + (IN_N - z)


def outer_s(x, z):
	if abs(z - OUT_S) < 0.05:
		return OUT_RUNS["front"] + (x - OUT_W)
	if abs(x - OUT_E) < 0.05:
		return OUT_RUNS["east"] + (z - OUT_S)
	if abs(z - OUT_N) < 0.05:
		return OUT_RUNS["back"] + (OUT_E - x)
	return OUT_RUNS["west"] + (OUT_N - z)


SIZES = {"W8FloorCeramic": 1.6, "W8FloorTerrazzo": 1.0, "W8FloorCement": 2.0, "W8WallYellow": 2.0, "W8WallIvory": 2.0,
	"W8DadoGreen": 2.0, "W8Skirting": 1.6, "W8CeilingPanel": 2.4, "W8CeilingConcrete": 2.0, "W8FacadeYellow": 2.0,
	"W8FacadeWhite": 2.0, "W8Concrete": 2.0, "W8WashedStone": 1.0, "W8Apron": 2.0, "W7Pavers": 0.9, "W7Kerb": 1.0}
GROUND_Y = -9.925      # wave 7's verge top (VERGE_Y); the PS1 tiles' top is -9.94
APRON_Y = -9.915
APRON = 0.8            # concrete apron round the walls, a covered drain 0.3 m on its outer edge
DRAIN = 0.3


def campus_uv2(x, z):
	"""wave7_layout.campus_uv2: UV2 over the whole campus (mask_road7.png, mask_verge7.png), so the ring joins wave 7."""
	return ((x + 80.0) / 500.0, (z + 60.0) / 350.0)


# Fill options (card step 3). Each piece: level (0..2), box (x0, x1, z0, z1) on the floor, height, label, kind; blocks_nav
# for M3's rows (they would need new navigation). M1 adds nothing. M2 stands outside navigation + 0.6 m, outside the 1.5 m
# rings and off the sightlines from the back door to the counter and from floor 2's stair top to the reading desk
# (plan_wave8.py checks the first two; the sightlines run inside the nav bands), each with a lane of at least 1.2 m beside it.
def _wall_run(level, kind, label, axis, fixed, a0, a1, depth, height, unit=3.0, gap=0.1):
	out = []
	a = a0
	while a + unit <= a1 + 1e-6:
		if axis == "z":   # along a west/east wall at x = fixed (depth into the room by sign)
			x0, x1 = (fixed, fixed + depth) if depth > 0 else (fixed + depth, fixed)
			out.append({"level": level, "box": (round(x0, 3), round(x1, 3), round(a, 3), round(a + unit, 3)), "height": height, "label": label, "kind": kind})
		else:
			z0, z1 = (fixed, fixed + depth) if depth > 0 else (fixed + depth, fixed)
			out.append({"level": level, "box": (round(a, 3), round(a + unit, 3), round(z0, 3), round(z1, 3)), "height": height, "label": label, "kind": kind})
		a += unit + gap
	return out


def _under_windows(level, label, wall_z, depth, xs):
	"""Low shelves (1.0 m, under the sills at 1.1 m) along a long wall, one under each window (3 m)."""
	out = []
	for wx in xs:
		z0, z1 = (wall_z, wall_z + depth) if depth > 0 else (wall_z + depth, wall_z)
		out.append({"level": level, "box": (wx - 1.5, wx + 1.5, round(z0, 3), round(z1, 3)), "height": 1.0, "label": label, "kind": "low_shelf"})
	return out


def _fill_m2():
	p = []
	d = 0.42
	for level in range(3):
		wood = "wall_shelf_wood" if level == 2 else "wall_shelf"
		# West wall, north of the cross aisle's band (z 213.6..) and south of it (..208.4); the map board's wall stays bare
		# on floor 1 south of z 208.4 too (the counter's corner).
		p += _wall_run(level, wood, "kệ sát tường", "z", IN_W, 214.0, 224.6, d, 2.2)
		if level > 0:
			p += _wall_run(level, wood, "kệ sát tường", "z", IN_W, 195.6, 208.2, d, 2.2)
		# Back wall: low shelves under the windows west and east of the aisle.
		p += _under_windows(level, "kệ thấp dưới cửa sổ", IN_N, -0.36, [50.0, 58.0, 72.0, 80.0])
		# East wall north of the stairs' access band.
		p += _wall_run(level, wood, "kệ sát tường", "z", IN_E, 214.0, 224.6, -d, 2.2)
		# Front wall: low shelves under the windows (floor 1 keeps x 50 clear behind the counter's corner).
		p += _under_windows(level, "kệ thấp dưới cửa sổ", IN_S, 0.36, [50.0, 58.0, 72.0] if level else [50.0, 72.0])
	# Floor 1: the loan hall.
	p += [{"level": 0, "box": (47.0, 48.2, 203.0, 203.45), "height": 1.3, "label": "tủ phích", "kind": "catalogue"},
		{"level": 0, "box": (47.0, 48.2, 203.45, 203.9), "height": 1.3, "label": "tủ phích", "kind": "catalogue", "yaw": 180.0},
		{"level": 0, "box": (50.0, 51.2, 203.0, 203.45), "height": 1.3, "label": "tủ phích", "kind": "catalogue"},
		{"level": 0, "box": (50.0, 51.2, 203.45, 203.9), "height": 1.3, "label": "tủ phích", "kind": "catalogue", "yaw": 180.0},
		{"level": 0, "box": (52.4, 53.3, 207.3, 207.75), "height": 1.0, "label": "xe đẩy sách", "kind": "trolley"},
		{"level": 0, "box": (70.0, 72.4, 201.0, 202.2), "height": 1.05, "label": "bàn báo", "kind": "news_table"},
		{"level": 0, "box": (74.6, 75.9, 196.0, 197.0), "height": 0.9, "label": "thùng sách", "kind": "boxes"},
		{"level": 0, "box": (46.0, 46.6, 223.9, 224.5), "height": 1.4, "label": "cây chết khô", "kind": "plant"},
		{"level": 0, "box": (75.6, 76.2, 207.4, 208.0), "height": 1.4, "label": "cây chết khô", "kind": "plant"},
		# Floor 2: the reading room (a newspaper table, a trolley, a plant; the reading tables are the PS1's).
		{"level": 1, "box": (70.0, 72.4, 203.5, 204.7), "height": 1.05, "label": "bàn báo", "kind": "news_table"},
		{"level": 1, "box": (52.0, 52.9, 223.4, 223.85), "height": 1.0, "label": "xe đẩy sách", "kind": "trolley"},
		{"level": 1, "box": (75.6, 76.2, 196.0, 196.6), "height": 1.4, "label": "cây chết khô", "kind": "plant"},
		# Floor 3: the old store: boxes, a trolley, a cabinet under a dust sheet.
		{"level": 2, "box": (70.0, 71.3, 196.0, 197.0), "height": 1.0, "label": "thùng sách", "kind": "boxes"},
		{"level": 2, "box": (73.5, 74.8, 205.8, 206.8), "height": 0.7, "label": "thùng sách", "kind": "boxes"},
		{"level": 2, "box": (50.5, 51.8, 222.5, 223.5), "height": 0.9, "label": "thùng sách", "kind": "boxes"},
		{"level": 2, "box": (78.0, 79.3, 222.8, 223.8), "height": 1.0, "label": "thùng sách", "kind": "boxes"},
		{"level": 2, "box": (52.4, 53.3, 205.0, 205.45), "height": 1.0, "label": "xe đẩy sách", "kind": "trolley"},
		{"level": 2, "box": (55.0, 56.6, 199.0, 199.6), "height": 1.2, "label": "tủ phủ vải", "kind": "sheeted"}]
	return p


def _fill_m3():
	"""Mid-room rows of double-faced stacks (0.6 deep, 1.0 m aisles) in the four bays: they cut the bays the zombies and
	the player cross today, so navigation and the zombies' routes would change (integrator's card)."""
	p = []
	for level in (0, 2):
		rows_n = [215.2, 220.6, 223.0] if level == 2 else [215.2, 220.6]
		for z in rows_n:
			for x0, x1 in ((46.4, 49.4), (53.3, 56.3), (59.0, 61.0), (69.4, 72.4), (75.6, 78.6), (79.6, 82.6)):
				p.append({"level": level, "box": (x0, x1, z - 0.3, z + 0.3), "height": 2.2, "label": "dãy kệ", "kind": "stack", "blocks_nav": True})
		rows_s = [197.6, 200.4, 203.2, 206.0] if level == 2 else [197.6, 200.4]
		for z in rows_s:
			bays = ((46.4, 49.4), (50.4, 53.4), (54.4, 57.4), (58.0, 61.0), (69.4, 72.4), (73.0, 76.0))
			for x0, x1 in bays:
				if level == 0 and x0 < 61.0:
					continue
				p.append({"level": level, "box": (x0, x1, z - 0.3, z + 0.3), "height": 2.2, "label": "dãy kệ", "kind": "stack", "blocks_nav": True})
	return p


FILL = {"m1": [], "m2": _fill_m2(), "m3": _fill_m3()}


# ------------------------------------------------------------------------------------------------ round 2 (D-185)
# The owner's pick (card section 1): M2 with double-faced rows in the four bays where they keep M2's rules (card section 4:
# outside navigation + 0.6 m, out of the 1.5 m rings, off the sightlines, a lane of at least 1.2 m beside each piece, a
# collider each under Real/Added); floor 1 keeps the counter's corner as M2 had it; floor 2 adds rows only in the bays away
# from the reading tables (3 m clear round them); floor 3 (the old store, wood) takes the M3 sample's rows that keep the
# rules. Every piece: name (its collider's node under Real/Added), level, box (x0, x1, z0, z1), height, kind, cluster (the
# books' near/far mesh it belongs to, shelves only). Pieces touch (gap <= TOUCH) or stand LANE apart: no narrow slot.
LANE = 1.2
TOUCH = 0.05
SCARE_CLEAR = 2.0          # no books, papers or fallen pieces this close to the scare points and their shelves (card 1.10)
TABLE_CLEAR = 3.0          # floor 2: no added piece this close to a reading table's top
ROW_D = 0.6                # double-faced row depth (two 0.3 m faces back to back)
WALL_D = 0.42              # wall shelves
LOW_D = 0.36               # low shelves under the windows
ROW_BOARDS = [0.1, 0.55, 1.0, 1.45, 1.9]
LOW_BOARDS = [0.1, 0.5]


def _p(name, level, box, height, kind, cluster=None, **extra):
	d = {"name": name, "level": level, "box": tuple(round(v, 3) for v in box), "height": height, "kind": kind}
	if cluster:
		d["cluster"] = cluster
	d.update(extra)
	return d


def _final():
	out = []
	for level in range(3):
		f = "F%d" % (level + 1)
		wood = level == 2
		shelf = "wall_shelf_wood" if wood else "wall_shelf"
		row = "row_wood" if wood else "row_steel"
		low = "low_shelf_wood" if wood else "low_shelf"
		# Wall shelves: three 3 m units abutting along the west and east walls north of the cross aisle (z 214..223); on the
		# upper floors three more on the west wall south of it (z 195.15..204.15; floor 1 keeps the map's wall bare).
		for side, x0, x1 in (("W", IN_W, IN_W + WALL_D), ("E", IN_E - WALL_D, IN_E)):
			for k in range(3):
				out.append(_p("%s_Wall%sN%d" % (f, side, k), level, (x0, x1, 214.0 + 3 * k, 217.0 + 3 * k), 2.2, shelf, "%s_Wall%sN" % (f, side)))
		if level > 0:
			for k in range(3):
				out.append(_p("%s_WallWS%d" % (f, k), level, (IN_W, IN_W + WALL_D, 195.15 + 3 * k, 198.15 + 3 * k), 2.2, shelf, f + "_WallWS"))
		# Low shelves (1.0 m, under the sills at 1.1 m) under the back windows (not on floor 3: its third row of stacks stands
		# there) and the front ones (floor 1: not x 58, the counter's corner).
		if level < 2:
			for wx in WINDOWS_X:
				out.append(_p("%s_LowN%d" % (f, int(wx)), level, (wx - 1.5, wx + 1.5, IN_N - LOW_D, IN_N), 1.0, low, f + "_LowN"))
		for wx in ([50.0, 72.0] if level == 0 else [50.0, 58.0, 72.0]):
			out.append(_p("%s_LowS%d" % (f, int(wx)), level, (wx - 1.5, wx + 1.5, IN_S, IN_S + LOW_D), 1.0, low, f + "_LowS"))
		# Double-faced rows.
		rows = []
		if level == 0:
			rows += [("NW", 215.2, [(46.8, 49.8), (53.3, 56.3)]), ("NW", 220.6, [(46.8, 49.8), (53.3, 56.3), (59.0, 61.0)]),
				("NE", 215.2, [(69.4, 72.4), (73.8, 76.8), (78.2, 81.2)]), ("NE", 220.6, [(69.4, 72.4), (73.8, 76.8), (78.2, 81.2)]),
				("SE", 197.9, [(69.4, 75.6)]), ("SE", 200.7, [(69.4, 75.6)])]
		elif level == 1:
			rows += [("SW", 198.8, [(46.8, 52.8), (54.2, 60.2)]), ("SW", 205.2, [(46.8, 52.8), (54.2, 60.2)]), ("SE", 198.8, [(69.4, 75.6)])]
		else:
			for z in (215.1, 220.9, 223.3):
				rows += [("NW", z, [(46.8, 49.8), (53.3, 56.3), (59.0, 61.0)]), ("NE", z, [(69.4, 72.4), (73.8, 76.8), (78.2, 81.2)])]
			for z in (197.9, 200.7, 203.5, 206.3):
				rows += [("SW", z, [(46.8, 49.8), (51.2, 54.2), (55.6, 58.6)]), ("SE", z, [(69.4, 72.4), (73.8, 76.0)])]
		for bay, z, spans in rows:
			for k, (x0, x1) in enumerate(spans):
				out.append(_p("%s_Row%s%d_%d" % (f, bay, int(round(z * 10)), k), level, (x0, x1, z - ROW_D / 2, z + ROW_D / 2), 2.2, row,
					"%s_Row%s%d" % (f, bay, int(round(z * 10)))))
	# Loose pieces (M2's, moved where the rows left room).
	out += [
		_p("F1_Catalogue0", 0, (47.0, 48.2, 203.0, 203.9), 1.3, "catalogue"),
		_p("F1_Catalogue1", 0, (50.0, 51.2, 203.0, 203.9), 1.3, "catalogue"),
		_p("F1_Trolley", 0, (52.2, 53.1, 207.3, 207.75), 1.0, "trolley"),
		_p("F1_NewsTable", 0, (70.0, 72.4, 203.6, 204.8), 1.05, "news_table"),
		_p("F1_Boxes", 0, (74.0, 75.3, 203.6, 204.6), 0.9, "boxes"),
		_p("F1_PlantS", 0, (53.4, 54.0, 195.15, 195.75), 1.4, "plant"),
		_p("F1_PlantE", 0, (75.6, 76.2, 207.4, 208.0), 1.4, "plant"),
		_p("F2_NewsTable", 1, (70.0, 72.4, 203.6, 204.8), 1.05, "news_table"),
		_p("F2_Trolley", 1, (47.0, 47.9, 219.0, 219.45), 1.0, "trolley"),
		_p("F2_Plant", 1, (75.6, 76.2, 195.15, 195.75), 1.4, "plant"),
		_p("F3_Sheeted", 2, (75.0, 76.2, 195.15, 195.75), 1.2, "sheeted"),
		_p("F3_BoxesS", 2, (59.5, 60.8, 195.15, 196.15), 1.0, "boxes"),
		_p("F3_BoxesE", 2, (81.2, 82.4, 214.8, 215.4), 0.7, "boxes"),
	]
	return out


FINAL = _final()
# The railing along the stairwell's west edge on floors 2 and 3 (card section 1.11): on the slab's edge at x 78.9 (posts
# and rail inside its collider x 78.86..78.94), z 199..209, 1.1 m. Clear of navigation by more than the zombie's widest
# shape (zombie.tscn: capsule r 0.25, agent r 0.3, head sphere r 0.31): StairNav* starts at x 79.4 (0.46 m), StairSide*
# ends at x 78 (0.86 m), StairFoot* ends at z 198.5 and StairAccess* starts at z 209.5 (0.5 m).
RAIL = {"x": (78.86, 78.94), "z": (199.0, 209.0), "h": 1.1, "post_x": 78.9}
ZOMBIE_R = 0.31
RAILS = [{"name": "WellRail_F%d" % (level + 1), "level": level, "box": (RAIL["x"][0], RAIL["x"][1], RAIL["z"][0], RAIL["z"][1]),
	"height": RAIL["h"], "kind": "rail"} for level in (1, 2)]
# Round 3 (card 1.14, D-186): the well's last drops, closed by railings like the west one (same height, same 8 cm depth, on
# the slab's edge). The east slot between each flight's east rail (RailCollision*_39, x 83.95..84.05) and the east wall's
# inside face (East1|2, x 84.89), z 199..209, on floors 2 and 3, at its south and north ends; floor 3's south edge (z 199,
# no flight going up there), from the west railing to the east wall. Floor 2's way onto flight two (x 79..84 at z 199) and
# both flights' tops (x 79..84 at z 209) stay open. Clear of navigation: StairFoot1|2 and StairAccess1|2 end at x 83.8
# (0.49 m to the east pieces' corners), StairNav* at x 83.6 (0.45 m); StairFoot2 ends at z 198.5 (0.42 m to WellRail_F3S);
# flight two's StairNav1 under WellRail_F3S is 3.3 m lower there (out of a zombie's reach: it rises under the slab only
# north of z 199).
WELL_EAST = (84.05, 84.89)
RAILS += [{"name": name, "level": level, "box": box, "height": RAIL["h"], "kind": "rail"} for name, level, box in (
	("WellRail_F3S", 2, (RAIL["x"][0], WELL_EAST[1], 198.92, 199.0)),
	("WellRail_F2SE", 1, (WELL_EAST[0], WELL_EAST[1], 198.92, 199.0)),
	("WellRail_F2NE", 1, (WELL_EAST[0], WELL_EAST[1], 209.0, 209.08)),
	("WellRail_F3NE", 2, (WELL_EAST[0], WELL_EAST[1], 209.0, 209.08)))]
# Sightlines kept clear (card section 4): the back door to the counter's top, floor 2's stair top to reading table 13.
SIGHTLINES = [{"level": 0, "eye": (65.0, 225.0), "to": ((COUNTER["at"][0] - 2.5, 206.0), (COUNTER["at"][0] + 2.5, 206.0))},
	{"level": 1, "eye": STAIR_TOP, "to": ((56.5, TABLE_Z), (59.5, TABLE_Z))}]
# Scare points (floor 3) and their shelves: no mess within SCARE_CLEAR.
SCARE_POINTS = [(57.0, 218.0), (73.0, 218.0)]
SCARE_SHELVES = [(55.5, 58.5, 217.7, 218.3), (71.5, 74.5, 217.7, 218.3)]
# Floor 1: the librarian's corner (nothing corpse-like, the chair upright).
LIBRARIAN_CLEAR = 2.0


def ps1_solids(level):
	"""PS1 colliders that stand on a floor (x0, x1, z0, z1): the three shelves, floor 2's tables' tops, floor 1's counter and
	barricade, the stairs and their rails' footprint."""
	y = level
	out = []
	for sx in SHELF_X:
		z = SHELF_Z[level]
		out.append((sx - 1.52, sx + 1.52, z - 0.3, z + 0.3))
	if level == 1:
		for tx in TABLES_X:
			out.append((tx - 1.5, tx + 1.5, TABLE_Z - 0.7, TABLE_Z + 0.7))
	if level == 0:
		cx, _, cz = COUNTER["at"]
		out.append((cx - 2.5, cx + 2.5, cz - 0.7, cz + 0.7))
		out.append((65.0 - 1.3, 65.0 + 1.3, 196.0 - 0.65, 196.0 + 0.65))
	out.append((STAIRS["x"][0], STAIRS["x"][1], STAIRS["z"][0], STAIRS["z"][1]))
	del y
	return out
