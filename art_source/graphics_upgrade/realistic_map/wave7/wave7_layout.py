"""T-264 wave 7: the background buildings, building B's outside and the rest of the campus ground, measured from main's
scenes (survey/*.tsv, survey_wave7.gd). Godot world coordinates (shells.tscn and campus.tscn sit at the origin).
Shared by the lister, the Blender pilot, the texture and sheet scripts. Pure Python (Blender's interpreter imports it).
"""
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
