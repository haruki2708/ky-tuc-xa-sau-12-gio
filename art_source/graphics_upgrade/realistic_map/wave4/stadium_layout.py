"""T-261 wave 4: the stadium's measured layout (stadium.tscn on main 7b8431f), shared by the texture, Blender and sheet
scripts. Godot world coordinates (the Stadium root sits at the campus origin, transform 0). Every number here is read
from the PS1 scene (collision shapes, MultiMesh data of Stand_*, strip vertices of RunningSurface/Lane*), so the new
pieces stand where the old ones stood; nothing here changes a collider.
"""
import math
from pathlib import Path

G = -9.9  # ground and TrackBounds top

# --- running track (RunningSurface / Lane0..7): a stadium shape, two half circles joined by straights.
TRACK_CX = (155.805, 240.195)  # west and east curve centres (x), both at z = TRACK_CZ
TRACK_CZ = 166.0
TRACK_R_IN = 36.19  # inner edge (the infield's edge, z 129.81 / 202.19 on the straights)
LANE_W = 1.22
LANES = 7
TRACK_R_OUT = TRACK_R_IN + LANES * LANE_W + 0.08  # 44.81: the PS1 outer line (r 44.755, 0.05 wide) lies inside
LINE_R = [36.215 + LANE_W * i for i in range(LANES + 1)]  # Lane0..7 centre lines
LINE_W = 0.05
TRACK_Y = -9.873
STRAIGHT = TRACK_CX[1] - TRACK_CX[0]  # 84.39 m

# --- pitch (Grass, PitchLine*, PitchEdge*, Goal*): goal lines x 150 / 246, touchlines z 137 / 195.
PITCH = {"x": (150.0, 246.0), "z": (137.0, 195.0), "cx": 198.0, "cz": 166.0}
PITCH_Y = -9.885
GOALS = [(150.0, 166.0, 1.0), (246.0, 166.0, -1.0)]  # goal line centre and the direction the mouth faces (+x/-x)
GOAL_W, GOAL_H = 7.32, 2.44

# --- the stadium floor (TrackBounds: 176 x 92 box, top at G) and the ground behind the main stand.
BOUNDS = {"x": (110.0, 286.0), "z": (120.0, 212.0)}
FIELD_MASK = {"x": (110.0, 286.0), "z": (120.0, 212.0)}  # UV2 of the apron/infield = this rect (mask_field.png)
BEHIND = {"x": (140.0, 246.0), "z": (212.6, 234.0)}  # under and behind the main stand (B02, B03, the way round)

# --- main stand (MainBleachers): 18 tiers, tread 0.85 deep, riser 0.38, x 158..238.
STAND_X = (158.0, 238.0)
TIERS = 18
TREAD, RISER = 0.85, 0.38
STAND_Z0 = 212.7  # first tread's front edge; the collision ramp starts here at G
TREAD0_TOP = -9.71  # PS1 tread k top = -9.71 + 0.38 k (the ramp passes through each tread's middle)
FRONT_WALL = {"z": (212.2, 212.6), "y": (G, -8.8), "x": [(158.0, 170.0), (176.0, 195.0), (201.0, 220.0), (226.0, 238.0)]}
AISLES = [(170.0, 176.0), (195.0, 201.0), (220.0, 226.0)]
REAR_PARAPET = {"z": (228.0, 228.3), "y": (-3.06, -1.86)}
END_WALLS = [(157.7, 158.0), (238.0, 238.3)]  # sloped parapets on the slab's ends (EndWest/EndEast)
COLUMNS_X = [158.0 + 10.0 * i for i in range(9)]  # RoofColumn0..8 (collision 0.55 square, y G..-3.9)
COLUMN_Z = 228.9
ROOF = {"front_z": 214.0, "back_z": 231.6, "front_y": 0.65, "back_y": 0.05}  # PS1 fascia z 214.3, beams y 0.05..0.12
B02 = (154.0, -9.9, 221.0)
B03 = (164.0, -9.82, 225.5)
# The four PS1 pipes B03 lies among (Stand_iron_box_p4_p5): origin, yaw (radians about y), length 1.7, radius 0.0225.
B03_PIPES = [((163.0 + 0.25 * i, -9.83, 225.5), math.atan2(-c, a)) for i, (a, c) in
	enumerate([(0.0435, -0.0116), (0.0411, -0.0183), (0.0377, -0.0245), (0.0334, -0.0301)])]


def tread_top(k):
	return TREAD0_TOP + RISER * k


def tread_front(k):
	return STAND_Z0 + TREAD * k


def ramp_y(z):
	"""Top of the MainBleachers slab collision (a straight ramp from (212.7, G) to (228, -3.06))."""
	return G + max(0.0, (z - STAND_Z0) * (6.84 / 15.3))


# --- fences (Fence0..11, 1.3 m tall, 0.08 thick) and gates (GatePost<x>_<z>_<+-5>: 0.35 square, 3.6 m tall).
FENCE_H = 1.3
FENCES = {
	"Fence0": ((110.0, 212.4), (143.0, 212.4)), "Fence1": ((153.0, 212.4), (158.0, 212.4)),
	"Fence2": ((238.0, 212.4), (243.0, 212.4)), "Fence3": ((253.0, 212.4), (286.0, 212.4)),
	"Fence4": ((110.0, 119.8), (143.0, 119.8)), "Fence5": ((153.0, 119.8), (168.0, 119.8)),
	"Fence6": ((228.0, 119.8), (243.0, 119.8)), "Fence7": ((253.0, 119.8), (286.0, 119.8)),
	"Fence8": ((110.0, 119.8), (110.0, 161.0)), "Fence9": ((110.0, 171.0), (110.0, 212.4)),
	"Fence10": ((286.0, 119.8), (286.0, 161.0)), "Fence11": ((286.0, 171.0), (286.0, 212.4)),
}
GATES = {  # gate name -> (post a, post b, outward normal (x, z))
	"West": ((110.0, 161.0), (110.0, 171.0), (-1.0, 0.0)), "East": ((286.0, 161.0), (286.0, 171.0), (1.0, 0.0)),
	"NorthWest": ((143.0, 212.4), (153.0, 212.4), (0.0, 1.0)), "NorthEast": ((243.0, 212.4), (253.0, 212.4), (0.0, 1.0)),
	"SouthWest": ((143.0, 119.8), (153.0, 119.8), (0.0, -1.0)), "SouthEast": ((243.0, 119.8), (253.0, 119.8), (0.0, -1.0)),
}
POST_H = 3.6

# --- floodlights: Pole0..3 (collision 0.3 square, y G..8.1), Floodlights/Light0..3 at y 5.1 over each pole.
POLES = [(112.0, 122.0), (284.0, 122.0), (112.0, 210.0), (284.0, 210.0)]
POLE_TOP = 8.1
HEAD_Y = 7.1  # the PS1 FloodHousing row

# --- round 1 pilot: what is built and where the stills look.
PILOT_POLE = 2  # Pole2, north-west, between the west gate and the stand's west end
PILOT_GATES = ["West", "NorthWest"]
PILOT_FENCES = ["Fence0", "Fence1", "Fence8", "Fence9"]

# --- A16 box of this wave (card section 3; fixed in round 1 from the real route, see README).
A16_BOX = {"x": (50.0, 110.0), "z": (-11.0, 176.0), "y": (-10.5, -6.0)}


def track_point(s, r):
	"""Point on the track at arc position s (metres from the west end of the north straight, running clockwise seen
	from above: north straight west->east, east curve, south straight east->west, west curve) and radius r from the
	curve centres. Returns (x, z, tangent angle)."""
	half = math.pi * r
	total = 2 * STRAIGHT + 2 * half
	s %= total
	cw, ce = TRACK_CX
	if s < STRAIGHT:  # north straight (z = cz + r), going +x
		return cw + s, TRACK_CZ + r
	s -= STRAIGHT
	if s < half:  # east curve, from north round to south
		a = math.pi / 2 - s / r
		return ce + r * math.cos(a), TRACK_CZ + r * math.sin(a)
	s -= half
	if s < STRAIGHT:  # south straight going -x
		return ce - s, TRACK_CZ - r
	s -= STRAIGHT
	a = -math.pi / 2 - s / r  # west curve, from south round to north
	return cw + r * math.cos(a), TRACK_CZ + r * math.sin(a)


def inside_track(x, z, r):
	"""True if (x, z) is inside the stadium shape of radius r."""
	cw, ce = TRACK_CX
	if cw <= x <= ce:
		return abs(z - TRACK_CZ) <= r
	c = cw if x < cw else ce
	return math.hypot(x - c, z - TRACK_CZ) <= r


# --- round 2 (D-178) -------------------------------------------------------------------------------------------
# South stand (SecondaryBleachers): 7 tiers, tread 0.9 deep going -z, riser 0.4, x 168..228; no roof (as PS1).
SOUTH = {"x": (168.0, 228.0), "tiers": 7, "tread": 0.9, "riser": 0.4, "z0": 119.5, "tread0_top": -9.7,
	"front_wall": {"z": (119.6, 120.0), "y": (G, -8.8), "x": [(168.0, 180.0), (186.0, 210.0), (216.0, 228.0)]},
	"aisles": [(180.0, 186.0), (210.0, 216.0)], "rear": {"z": (112.9, 113.2), "y_top": -5.9},
	"ends": [(167.7, 168.0), (228.0, 228.3)], "end_top": ((119.74, -8.69), (113.44, -5.89))}


def south_ramp_y(z):
	"""Top of the SecondaryBleachers slab collision (from (119.5, G) down-z to (113.2, -7.1))."""
	return G + max(0.0, (SOUTH["z0"] - z) * (2.8 / 6.3))


# The stadium's props (props.tscn, T-192 scatter.py) replaced in round 2 (D-178 question 7): what people dropped,
# hurdles, crates. Bodies (arms, legs, torsos, heads), blood (D_red_quad), cracks and drag marks (D_iron_quad, but the
# phones' thin dark edge) and bins stay. Signature = (texture, kind, rounded scale) of one MultiMesh instance.
STADIUM_AREA = {"x": (108.0, 290.0), "z": (108.0, 236.0)}
PROP_KINDS = {
	("white", "box", (0.04, 0.84, 0.04)): "hurdle_post",
	("white", "box", (1.2, 0.07, 0.05)): "hurdle_bar",
	("white", "box", (0.75, 0.32, 0.3)): "gym_bag",
	("white", "box", (0.32, 0.42, 0.2)): "backpack",
	("white", "box", (0.26, 0.2, 0.06)): "backpack_pocket",
	("white", "box", (0.26, 0.1, 0.1)): "shoe",
	("white", "box", (0.42, 0.03, 0.3)): "tray",
	("paper", "box", (0.34, 0.01, 0.16)): "tray_paper",
	("white", "box", (0.8, 0.6, 0.8)): "crate",
	("paper", "quad", (0.18, 1.0, 0.26)): "paper",
	("white", "quad", (0.11, 1.0, 0.27)): "sandal",
	("white", "quad", (0.07, 1.0, 0.15)): "phone",
	("iron", "quad", (0.01, 1.0, 0.17)): "phone_edge",
}
W4_PS1_PROPS = Path(__file__).resolve().parent / "w4_ps1_props.json"


def chunk_signature(node):
	"""props.tscn node name (P_<texture>_<kind>_<chunk>) -> (texture, kind)."""
	parts = node.split("_")
	return parts[1], parts[2]


def prop_kind(node, basis, origin):
	"""Kind of a props.tscn instance this wave replaces inside the stadium, or None."""
	x, _, z = origin
	if not (STADIUM_AREA["x"][0] <= x <= STADIUM_AREA["x"][1] and STADIUM_AREA["z"][0] <= z <= STADIUM_AREA["z"][1]):
		return None
	scale = tuple(round(math.sqrt(sum(t * t for t in col)), 2) for col in basis)
	if max(scale) == 0:
		return None
	return PROP_KINDS.get((*chunk_signature(node), scale))


def instances(values):
	"""boxes.gd data -> [(basis columns, origin, rgba)]."""
	out = []
	for k in range(0, len(values), 16):
		v = values[k:k + 16]
		out.append(((tuple(v[0:3]), tuple(v[3:6]), tuple(v[6:9])), tuple(v[9:12]), tuple(v[12:16])))
	return out


def a16_kind(node, basis, origin):
	"""A16 box pieces (list_a16_box.py rules): 'litter', 'rubble', 'rubble pipe' or None."""
	x, y, z = origin
	box = A16_BOX
	if not (box["x"][0] <= x <= box["x"][1] and box["z"][0] <= z <= box["z"][1] and box["y"][0] <= y <= box["y"][1]):
		return None
	scale = tuple(math.sqrt(sum(t * t for t in col)) for col in basis)
	if max(scale) == 0:
		return None
	near = any((x - cx) ** 2 + (z - cz) ** 2 <= r * r for (cx, cz), r in A16_RUBBLE)
	if node.startswith(("P_paper", "D_paper")) and y < -9.7:
		return "litter"
	if near and node.startswith("P_concrete_box") and max(scale) < 1.0:
		return "rubble"
	if near and node.startswith("P_iron_cylinder") and abs(scale[1] - 1.1) < 0.05:
		return "rubble pipe"
	return None


A16_RUBBLE = [((86.95, 151.44), 1.6), ((99.2, 173.5), 1.5)]  # props.tscn Solids/Body_p2_p3/S1, Body_p2_p4/S1
# T-259 already zeroed some instances of this chunk inside its strip; the rest all lie in this wave's box, so the
# whole node is hidden instead (test_t259_garden checks that every zeroed instance there is in its strip).
HIDE_WHOLE = ["Decals/D_paper_quad_p0_p0"]
