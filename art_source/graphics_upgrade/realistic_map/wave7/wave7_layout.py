"""T-264 wave 7: the background buildings, building B's outside and the rest of the campus ground, measured from main's
scenes (survey/*.tsv, survey_wave7.gd). Godot world coordinates (shells.tscn and campus.tscn sit at the origin).
Shared by the lister, the Blender pilot, the texture and sheet scripts. Pure Python (Blender's interpreter imports it).
"""
import math

G = -9.9            # campus ground and paving top
GROUND = -9.94      # the PS1 ground tiles' top (Ground/Tile_*: 50 x 0.3 x 50 at y -10.09)
ROAD_TOP = -9.87    # Road/* BoxMeshes (0.03 m at -9.885; no collider: the player walks on the tiles)
FLOOR_H = 3.3
SKIN = (0.9, 0.7, 0.6)

# shells.tscn: one solid collider per building (Shell 'StaticBody3D' + BoxShape), windows only on the front face.
BUILDING_A = {"x": (0.0, 44.0), "z": (54.0, 64.0), "y": (G, 9.9), "floors": 6, "front_z": 54.0,
	"windows_x": [2.5 + 5.0 * k for k in range(8)], "door_x": 22.0}
LECTURE = {"x": (-50.0, 30.0), "z": (180.0, 200.0), "y": (G, 6.6), "floors": 5, "front_z": 180.0,
	"windows_x": [-47.5 + 5.0 * k for k in range(16)], "door_x": -10.0}
GYM = {"x": (-60.0, 0.0), "z": (90.0, 130.0), "y": (G, 0.1), "floors": 1, "front_z": 90.0,
	"windows_x": [-57.5 + 5.0 * k for k in range(12)], "door_x": -30.0}
WINDOW = {"w": 2.0, "h": 1.5, "sill": 1.05}    # glass 2 x 1.5, its foot 1.05 m over each floor
SILHOUETTES = [(7.0, -1.9, 53.8), (18.0, -1.9, 53.8), (31.0, -1.9, 53.8)]   # WindowSilhouette0..2 (floor 3 of A)
# Occluders chapter 3 adds (game/scenes/main/occlusion/occluders_campus.tscn, core): solid 0.5 m inside each shell.
OCCLUDERS = {"BuildingA": ((0.5, -9.4, 54.5), (43.5, 9.4, 63.5)), "Lecture": ((-49.5, -9.4, 180.5), (29.5, 6.1, 199.5)),
	"Gym": ((-59.5, -9.4, 90.5), (-0.5, -0.4, 129.5))}

# building_b.tscn (campus origin): the block x 0..44, front z 4 (rails 4.0..4.2), back wall z -7.7..-7.5 (floors 1-3:
# Floor1/BackEast + WindowSill/Header, Floor2/Back, Floor3/Back), stair towers x -5.16..0.1 and 43.9..49.16 (PS1 walls to
# y 2.75), floors 5-6 blocked (UpperFloor5/6 colliders at y 4.8 / 8.1), 22 UpperWindow5_*/6_* at x 2..42 step 4, z 4.02.
BUILDING_B = {"x": (0.0, 44.0), "front_z": 4.0, "back_z": -7.7, "towers": [(-5.16, 0.1), (43.9, 49.16)], "top": 9.6,
	"upper_windows_x": [2.0 + 4.0 * k for k in range(11)], "upper_window_y": {5: 4.95, 6: 8.25}}

# mask_facades7.png rows: (name, length along in m, height in m, window centres along, window heads above the ground).
_A_HEADS = [1.05 + 1.5 + FLOOR_H * k for k in range(6)]
FACADE_ROWS = [("building A front", 44.0, 20.0, [x for x in BUILDING_A["windows_x"]], _A_HEADS),
	("gym front + east", 100.0, 10.2, [x + 60.0 for x in GYM["windows_x"]], [2.55]),
	("lecture front", 80.0, 16.6, [x + 50.0 for x in LECTURE["windows_x"]], [1.05 + 1.5 + FLOOR_H * k for k in range(5)]),
	("building B back + upper front", 88.0, 20.0, [x for x in BUILDING_B["upper_windows_x"]] + [44.0 + x for x in BUILDING_B["upper_windows_x"]],
		[FLOOR_H * k + 2.6 for k in range(6)])]


def facade_uv2(row, s, y, length=None):
	"""UV2 of a facade point: metres along its row (s), height above the ground (y in world)."""
	name, rl, height, _w, _h = FACADE_ROWS[row]
	u = min(max(s / rl, 0.0), 1.0)
	v = min(max((y - G) / height, 0.0), 1.0)
	return (u, (row + 1.0 - v) / len(FACADE_ROWS))


# The pilot's stretch of the Avenue (card step 2): x 112..176 of Road/Avenue (z -19..-11, its mesh's top -9.87), the
# verges to the trees on the north side (TreeTrunk100..103 at x 120, 136, 152, 168, z -7) and the lamps on the south side
# (StreetLights_3_-1 / _4_-1 at x 120, 140, 160, z -20), RoadBench2 (148, -22), FallenMoped1 (145, -18) on the road.
ROAD_PILOT = {"x": (112.0, 176.0), "z": (-26.0, 0.0)}
ROAD = {"x": (112.0, 176.0), "z": (-19.0, -11.0)}
PILOT_TREES = [(120.0, -7.0), (136.0, -7.0), (152.0, -7.0), (168.0, -7.0)]
PILOT_TREE_SPECIES = ["bang", "phuong", "xacu", "bang"]
PILOT_LAMPS = [(120.0, -20.0), (140.0, -20.0), (160.0, -20.0)]
BENCH = (148.0, -22.0)        # RoadBench2: seat 2.4 x 0.6 at -9.4, BenchBody2 collider
MOPED = (145.0, -18.0)        # FallenMoped1, MopedBody1 collider
TRUNK_BOX = 0.5               # TreeTrunk*: 0.5 x 3 x 0.5 at y -8.4 (G..G + 3)
FENCE_W_PILOT = {"x": -80.0, "z": (95.0, 125.0)}    # Fence/W: 0.3 x 3 x 350 at x -80 (z -60..290)

# Regions (x0, x1, z0, z1), checked in this order; what none holds is "rest", this wave's A16.
REGIONS = [
	("wave 8: library and 6 m round it", (39.0, 91.0, 189.0, 231.0), None),
	("building B", (-5.2, 49.2, -10.8, 4.3), None),
	("building A footprint", (0.0, 44.0, 54.0, 64.0), None),
	("lecture hall footprint", (-50.0, 30.0, 180.0, 200.0), None),
	("gym footprint", (-60.0, 0.0, 90.0, 130.0), None),
	("done: T-259 garden strip", (-6.0, 50.0, 4.0, 50.0), None),
	("done: T-261 stadium", (108.0, 290.0, 108.0, 236.0), None),
	("done: T-261 strip", (50.0, 110.0, -11.0, 176.0), None),
	("done: T-262 gate strip", (180.0, 262.0, -60.0, 13.0), None),
	("done: T-263 canteen strip", (166.0, 218.0, 13.0, 60.0), (166.0, 170.0, 37.0, 60.0)),
	("outside the campus", None, None),
]
CAMPUS = (-80.0, 420.0, -60.0, 290.0)
REGIONS_DOC = {name: {"box": box, "less": less} for name, box, less in REGIONS}


def region(x, z):
	for name, box, less in REGIONS:
		if box is None:
			continue
		if box[0] <= x <= box[1] and box[2] <= z <= box[3]:
			if less and less[0] <= x < less[1] and less[2] < z <= less[3]:
				continue
			return name
	if not (CAMPUS[0] <= x <= CAMPUS[1] and CAMPUS[2] <= z <= CAMPUS[3]):
		return "outside the campus"
	return "rest"


# ------------------------------------------------------------------------------------------------ round 3: the ground
# Heights: the tiles' collider top is -9.94; the new verge 1.5 cm over it, the roads and forecourts 2 cm over it (card
# section 4: the seen surface within 2 cm of the collider); the earlier strips lie at -9.93 (wave 4) to -9.9 (waves 5, 6).
VERGE_Y = -9.925
ROAD_Y = -9.92
PAVED_Y = -9.92
KERB_TOP = -9.84      # as waves 4 and 5's kerbs
KERB = 0.15
AVENUE_JOIN = (177.0, 180.0, -9.87)   # the Avenue rises to T-262's paved stretch (x 180.., top -9.87) over its last 3 m
# Roads of main's campus.tscn (Road/*/Mesh, top -9.87, no collider): (name, x0, x1, z0, z1, along). WestBranch and
# StadiumWestAccess are hidden (T-259, T-261: wave 4's paved road).
ROADS = [("Avenue", 0.0, 180.0, -19.0, -11.0, "x"), ("EastBranch", 306.0, 314.0, -30.0, 166.0, "z"),
	("StadiumEastAccess", 284.0, 312.0, 163.0, 169.0, "x")]
# Forecourts in "con sâu" block paving in front of the three far buildings (D-182 item 5), edged in concrete.
FORECOURTS = [("BuildingA", -1.0, 45.0, 50.0, 54.0), ("Lecture", -52.0, 32.0, 172.0, 180.0), ("Gym", -62.0, 2.0, 82.0, 90.0)]
EDGE = 0.12
# Where the new ground is not laid (the earlier strips, wave 8, the buildings and building B's own box; its tiles stay).
GROUND_SKIP = [box for name, box, less in REGIONS if box is not None and not name.startswith("outside")]
CANTEEN_CORNER = (166.0, 170.0, 37.0, 60.0)   # T-263 left it: this wave lays it (less the west exit, wave 8)


def ground_kind(x, z):
	"""What the new ground is at (x, z): None (not laid), 'road', 'kerb', 'paved', 'edge' or 'verge'."""
	if not (CAMPUS[0] <= x <= CAMPUS[1] and CAMPUS[2] <= z <= CAMPUS[3]):
		return None
	in_corner = CANTEEN_CORNER[0] <= x <= CANTEEN_CORNER[1] and CANTEEN_CORNER[2] <= z <= CANTEEN_CORNER[3]
	if not in_corner:
		for box in GROUND_SKIP:
			if box[0] <= x <= box[1] and box[2] <= z <= box[3]:
				return None
	for _name, x0, x1, z0, z1, along in ROADS:
		if x0 <= x <= x1 and z0 <= z <= z1:
			return "road"
	for _name, x0, x1, z0, z1, along in ROADS:
		if x0 - KERB <= x <= x1 + KERB and z0 - KERB <= z <= z1 + KERB:
			return "kerb"
	for _name, x0, x1, z0, z1 in FORECOURTS:
		if x0 <= x <= x1 and z0 <= z <= z1:
			return "paved"
	for _name, x0, x1, z0, z1 in FORECOURTS:
		if x0 - EDGE <= x <= x1 + EDGE and z0 - EDGE <= z <= z1:
			return "edge"
	return "verge"


def ground_lines():
	"""The x and z lines that cut the campus into rectangles of one ground kind each."""
	xs, zs = {CAMPUS[0], CAMPUS[1]}, {CAMPUS[2], CAMPUS[3]}
	for box in GROUND_SKIP + [CANTEEN_CORNER]:
		xs |= {box[0], box[1]}
		zs |= {box[2], box[3]}
	for _name, x0, x1, z0, z1, along in ROADS:
		xs |= {x0, x1, x0 - KERB, x1 + KERB}
		zs |= {z0, z1, z0 - KERB, z1 + KERB}
	for _name, x0, x1, z0, z1 in FORECOURTS:
		xs |= {x0, x1, x0 - EDGE, x1 + EDGE}
		zs |= {z0, z1, z0 - EDGE}
	xs = sorted(v for v in xs if CAMPUS[0] <= v <= CAMPUS[1])
	zs = sorted(v for v in zs if CAMPUS[2] <= v <= CAMPUS[3])
	return xs, zs


def ground_cells():
	"""[(kind, x0, x1, z0, z1)] covering the campus where the new ground is laid."""
	xs, zs = ground_lines()
	cells = []
	for xa, xb in zip(xs, xs[1:]):
		for za, zb in zip(zs, zs[1:]):
			kind = ground_kind((xa + xb) / 2, (za + zb) / 2)
			if kind is not None:
				cells.append((kind, xa, xb, za, zb))
	return cells


def campus_uv2(x, z):
	"""UV2 of the whole campus (mask_road7.png, mask_verge7.png: 500 x 350 m)."""
	return ((x - CAMPUS[0]) / (CAMPUS[1] - CAMPUS[0]), (z - CAMPUS[2]) / (CAMPUS[3] - CAMPUS[2]))


_SCENES = __import__("pathlib").Path(__file__).resolve().parents[4] / "game/scenes/levels/campus"


def foliage_points(kind):
	"""{node path: [(x, y, z), ...]} of the foliage.gd clusters of one kind ('tree' or 'lamp') in campus.tscn (Road/*)
	and props.tscn (Trees/*), as main has them."""
	import re
	out = {}
	for scene, prefix in (("campus.tscn", ""), ("props.tscn", "Props/")):
		text = (_SCENES / scene).read_text(encoding="utf-8")
		for m in re.finditer(r'\[node name="([^"]+)" type="Node3D" parent="([^"]+)"\]\nscript = ExtResource\("e10"\)\nkind = "(\w+)"\n'
				r'points = PackedVector3Array\(([^)]*)\)', text):
			if m.group(3) != kind:
				continue
			v = [float(t) for t in m.group(4).split(",")]
			out[prefix + m.group(2) + "/" + m.group(1)] = [tuple(v[k:k + 3]) for k in range(0, len(v), 3)]
	return out


# Trees (D-182 item 6): bàng along the Avenue, phượng near the buildings, xà cừ in the long rows (the campus edges and
# both sides of WestBranch). Index into SPECIES.
SPECIES = ["bang", "phuong", "xacu"]
NEAR_BUILDINGS = [(-5.2, 49.2, -10.8, 4.3), (0.0, 44.0, 54.0, 64.0), (-50.0, 30.0, 180.0, 200.0), (-60.0, 0.0, 90.0, 130.0),
	(45.0, 85.0, 195.0, 225.0), (170.0, 215.0, 20.0, 45.0)]


def tree_species(x, z):
	if abs(z + 50.0) < 1.0 or abs(z - 280.0) < 1.0 or abs(x + 70.0) < 1.0 or abs(x - 410.0) < 1.0:
		return 2
	if 60.0 <= x <= 96.0 and 0.0 <= z <= 176.0:
		return 2
	for x0, x1, z0, z1 in NEAR_BUILDINGS:
		if x0 - 22.0 <= x <= x1 + 22.0 and z0 - 22.0 <= z <= z1 + 22.0:
			return 1
	return 0


def lamp_yaw(x, z):
	"""Degrees about y turning the steel lamp's arm (+z in its frame) over the nearest road."""
	best = None
	roads = ROADS + [("WestBranch", 76.0, 84.0, -15.0, 169.0, "z")]
	for _name, x0, x1, z0, z1, along in roads:
		cx, cz = min(max(x, x0), x1), min(max(z, z0), z1)
		d = math.hypot(x - cx, z - cz)
		if best is None or d < best[0]:
			if along == "x":
				dz = ((z0 + z1) / 2) - z
				best = (d, 0.0 if dz > 0 else 180.0)
			else:
				dx = ((x0 + x1) / 2) - x
				best = (d, 90.0 if dx > 0 else -90.0)
	return best[1]
