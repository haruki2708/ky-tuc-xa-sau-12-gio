"""T-262 wave 5: the school gate's measured layout, shared by the textures, the Blender builds, the A16 lister and the
option sheets. Every number is read off main's scenes (commit 1b63065): game/scenes/levels/campus/gate.tscn,
campus.tscn (Fence/S, Road/Avenue, Anchors, Zones) and props.tscn (the court's street props).

Godot world coordinates (x east, y up, z south is negative: the gate's wall is at z -60, the campus lies north of it).
Nothing here changes a collider: the new pieces stay inside the PS1 colliders or above head height (card section 4).
"""
import math

G = -9.9            # the court's top (Court: 60 x 0.04 x 40 at y -9.92)
GROUND = -9.94      # the ground tiles' top round the court (Ground/Tile_*: y -10.09, 0.3 thick)
ROAD_Y = -9.87      # Road/Avenue's top (a 0.03 m BoxMesh at y -9.885; it has no collider)
HEAD = 2.0          # head room the player needs (capsule 1.75 m)

COURT = {"x": (190.0, 250.0), "z": (-60.0, -20.0)}
GATE = {"x": (210.0, 230.0), "y": (G, G + 4.0), "z": (-59.09, -58.91)}   # Gate/Gate collider (20 x 4 x 0.18)
PILLAR = {"size": 1.4, "height": 6.0, "y": -6.9, "z": -59.0}
PILLARS = {"Pillar209": (209.0, 7.0), "Pillar231": (231.0, 0.0)}        # x, rotation about z (deg; top leans -x)
BOOTH = {"x": (237.5, 242.5), "y": (G, G + 3.0), "z": (-56.0, -52.0)}    # Booth collider (5 x 3 x 4)
BOOTH_WINDOW = {"x": (238.2, 241.8), "y": (-8.75, -7.65), "z": -52.0}    # PS1 BoothWindow (3.6 x 1.1, north face)
BOOTH_ROOF = {"x": (237.25, 242.75), "y": (-6.89, -6.67), "z": (-56.25, -51.75)}  # PS1 BoothRoof 5.5 x 0.22 x 4.5
WALL = {"x": (-80.0, 420.0), "y": (G, G + 3.0), "z": (-60.15, -59.85)}   # campus.tscn Fence/S (500 x 3 x 0.3)
SIGN_PS1 = {"centre": (219.0, -4.1, -59.0), "size": (18.0, 1.5, 0.18), "roll": -13.0}  # HalfFallenSign
SCARS_PS1 = [(213.0 + i * 1.3, -4.5 + (i % 2) * 0.3, -58.85) for i in range(9)]       # SignScar0..8
ROAD_CRACKS = [212.0, 222.0, 233.0]       # RoadCrack*: 7 branches from (x, -9.88, -54) to z -47.1
PILLAR_CRACK = (208.9, -5.4, -58.27)      # PillarCrack (north face of Pillar209, y -8.0..-5.4)

GUARD_LINE = [(210.0 + i * 20.0 / 11.0, G, -54.0) for i in range(12)]     # Anchors/GuardLine/G01..G12
GUARD_BOOTH = (240.0, G, -51.0)
GATE_PILLAR_CLUE = (209.0, G, -58.0)
START_GATE = (220.0, G, -25.0)
EYE = 1.6           # eye height used for the sightlines; a guard's chest is 1.3 m up
CHEST = 1.3

# The A16 gate box this wave (card step 1, fixed by the route walk, walk_route.gd): the court, the Avenue's last 40 m
# and the ground the companions, the bot and the gate horde cross from the court to the canteen's front, up to the
# canteen box (x 170..210, z 13..51, wave 6), which it does not enter. The wall line z -60 is the box's south edge.
A16_BOX = {"x": (180.0, 262.0), "z": (-60.0, 13.0), "y": (-10.5, -6.0)}
CANTEEN_BOX = {"x": (170.0, 210.0), "z": (13.0, 51.0)}

# Street props of the court (props.tscn, art_source/campus/scatter.py set_pieces and route_pass): the solid ones and
# their collider (Solids/Body_*/S*: barrier s17 2.2 x 1.0 x 0.5, car s16 4.4 x 1.5 x 1.9).
BARRIERS = [(213.0, -49.5, 8.0), (227.0, -49.5, -6.0)]
CONE_ROWS = [(203.0, -47.5, 3), (235.0, -47.5, 3)]
CARS = [(208.0, -37.0, 62.0, "red"), (238.5, -33.5, 100.0, "blue"), (236.0, -26.0, 10.0, "white"),
	(227.13, -20.63, 170.76, "grey"), (187.62, -6.28, 76.7, "grey")]
BAR_B05 = (228.0, G, -29.0)               # an iron bar lies here in chapter 3 (test_t249: reached bending down)

SKIN = (0.9, 0.7, 0.6)                    # a body's head: P_paper_box 0.22 m with this tint (never litter)

# --- round 2 (D-180) ---------------------------------------------------------------------------------------------
GROUND_TOP = -9.93   # the strip's lawn: 1 cm over the PS1 ground tiles (-9.94), as waves 3 and 4
ROAD_TOP = -9.87     # Road/Avenue's top: its last 40 m keeps the height, so the PS1 cracks (kept) lie on it as before
KERB_TOP = -9.84
KERB = 0.15
EDGE = 0.12          # concrete edging along the paved walk
ROAD = {"x": (180.0, 217.0), "z": (-19.0, -11.0)}            # the Avenue's end, paved (the PS1 mesh keeps x 0..180)
WALK_N = {"x": (217.0, 223.0), "z": (-20.0, 13.0)}           # paved walk from the court's north edge to the box edge
WALK_W = {"x": (186.0, 217.0), "z": (7.0, 13.0)}             # and west towards the canteen's door (x ~190, z 20)
# Lawn rectangles (x0, z0, x1, z1): the box less the court, the road with its kerbs and the walk with its edging.
LAWN = [(180.0, -60.0, 190.0, -19.15), (250.0, -60.0, 262.0, -20.0), (190.0, -20.0, 216.88, -19.15),
	(223.12, -20.0, 262.0, 13.0), (180.0, -10.85, 216.88, 6.88), (180.0, 6.88, 185.88, 13.0)]
WALL_X = (-80.0, 420.0)
WALL_RUNS = [(-80.0, 208.25), (231.75, 420.0)]   # Fence/S's whole length less the gate between the pillars
WALL_CHUNK = 30.0     # one mesh per 30 m (10 modules): culled apart; bars near / bar card far
BARS_NEAR = 45.0      # 3D bars up to this distance, the flat bar card from there (visibility ranges, gate_real.gd)
PAINT = {"red": (0.85, 0.16, 0.12), "blue": (0.2, 0.36, 0.85), "white": (0.95, 0.95, 0.98), "grey": (0.28, 0.3, 0.36)}
HEADS = [("P_paper_box_p1_p0", 0, "wave3"), ("P_paper_box_p2_p2", 1, "wave4"), ("P_paper_box_p2_p4", 1, "wave4")]


def pillar_matrix(name):
	"""(cos, sin, cx, cy) of the pillar's rotation about z through its centre (Godot x, y)."""
	x, deg = PILLARS[name]
	a = math.radians(deg)
	return math.cos(a), math.sin(a), x, PILLAR["y"]


def pillar_point(name, lx, ly, lz):
	"""A point in the pillar's own frame (centre origin, y up) to Godot world."""
	c, s, cx, cy = pillar_matrix(name)
	return (cx + lx * c - ly * s, cy + lx * s + ly * c, PILLAR["z"] + lz)


def in_box(x, y, z, box=A16_BOX, grow=0.0):
	return (box["x"][0] - grow <= x <= box["x"][1] + grow and box["z"][0] - grow <= z <= box["z"][1] + grow
		and box["y"][0] <= y <= box["y"][1])
