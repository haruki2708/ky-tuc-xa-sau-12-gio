"""T-261 wave 4: the stadium's measured layout (stadium.tscn on main 7b8431f), shared by the texture, Blender and sheet
scripts. Godot world coordinates (the Stadium root sits at the campus origin, transform 0). Every number here is read
from the PS1 scene (collision shapes, MultiMesh data of Stand_*, strip vertices of RunningSurface/Lane*), so the new
pieces stand where the old ones stood; nothing here changes a collider.
"""
import math

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
