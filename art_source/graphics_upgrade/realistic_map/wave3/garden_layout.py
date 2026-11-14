"""T-259 round 2 (D-175): the garden's layout, shared by build_garden.py / build_strip.py (Blender) and
patch_garden.py (scenes). Godot world coordinates; the garden and floor 4 both sit at the campus origin (chapters 1-4).
"""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[4]
PAVING_Y = -9.9  # paving top; garden-space glbs are built with this as y 0
GROUND_Y = -9.94  # the PS1 lawn tiles' top

# Bed{i}_{j}: i = row along z, j = column along x (garden.tscn).
BEDS = {(i, j): (6.0 + 16.0 * j, 12.0 + 10.0 * i) for i in range(4) for j in range(3)}
# D-175: 8 plumeria, 4 crape myrtle spread so floor 4 does not see them bunched: one a row, columns 0, 2, 1, 0.
LAGER = {(0, 0), (1, 2), (2, 1), (3, 0)}
PLUMERIA_VARIANTS = ["a", "b", "c"]
LAGER_VARIANTS = ["a", "b"]


def trees():
	"""(i, j) -> (glb name, yaw in degrees). Variants cycle, yaw varies per bed."""
	out = {}
	p = l = 0
	for i in range(4):
		for j in range(3):
			if (i, j) in LAGER:
				name = "tree_lagerstroemia_%s.glb" % LAGER_VARIANTS[l % len(LAGER_VARIANTS)]
				l += 1
			else:
				name = "tree_plumeria_%s.glb" % PLUMERIA_VARIANTS[p % len(PLUMERIA_VARIANTS)]
				p += 1
			out[(i, j)] = (name, (i * 3 + j) * 67 % 360)
	return out


BENCHES = {"Bench0": (2.0, 22.0), "Bench1": (42.0, 22.0), "Bench2": (6.0, 47.0), "Bench3": (38.0, 47.0)}
NGU_BENCH = (22.0, 28.0)
LAMPS = [(1.0, 10.0), (1.0, 24.0), (1.0, 40.0), (43.0, 10.0), (43.0, 24.0), (43.0, 40.0)]
DISTANT_LAMP = (15.0, -1.0, 19.0)  # floor4/corridor.tscn DistantStreetLamp (OmniLight3D), chapters 1-2
FALLEN_BUNK = {"aabb_min": (6.3, -9.85, 36.0), "aabb_max": (8.0, -8.95, 38.0)}  # kit bunk_bed on its side
DETACHED_RAILS = [((7.6, -9.78, 36.8), 20), ((7.9, -9.78, 36.8), 27), ((8.2, -9.78, 36.8), 34), ((8.5, -9.78, 36.8), 41)]
# A16 strip (card section 3) and the notice board's collider (props.tscn Body_p0_p0/S0).
STRIP = {"x": (-6.0, 50.0), "z": (4.0, 50.0), "y": (-10.5, -6.0)}
B_FRONT_Z = 4.2  # building B's ground-floor rails stand at z 4.1-4.18
NOTICE_BOARD = {"min": (29.3, -9.9, 10.95), "max": (31.7, -7.7, 11.45)}
RUBBLE_BOXES = [((6.21, 49.1), (9.8, 52.9)), ((19.96, 48.97), (24.04, 53.03)), ((33.97, 49.0), (38.04, 53.0))]


PS1_PROPS = Path(__file__).resolve().parent / "a16_ps1_props.json"


def props_data(text, node):
	block = text[text.index('[node name="%s"' % node):]
	block = block[:block.index("\n[node", 1)]
	return [float(v) for v in re.search(r"data = PackedFloat32Array\(([^)]*)\)", block).group(1).split(",")]


def props_instances(node):
	"""Instances of a props.tscn MultiMesh chunk (boxes.gd: 16 floats each) as main had them before this wave hid
	some (a16_ps1_props.json, written by patch_garden.py from main's props.tscn): [(basis columns, origin, rgba)]."""
	values = json.loads(PS1_PROPS.read_text(encoding="utf-8"))[node]
	out = []
	for k in range(0, len(values), 16):
		v = values[k:k + 16]
		out.append(((v[0:3], v[3:6], v[6:9]), tuple(v[9:12]), tuple(v[12:16])))
	return out


def in_strip(origin):
	x, y, z = origin
	return STRIP["x"][0] <= x <= STRIP["x"][1] and STRIP["z"][0] <= z <= STRIP["z"][1] and STRIP["y"][0] <= y <= STRIP["y"][1]


def on_board(origin):
	lo, hi = NOTICE_BOARD["min"], NOTICE_BOARD["max"]
	return all(lo[k] - 0.05 <= origin[k] <= hi[k] + 0.05 for k in range(3))


# A16 PS1 pieces this wave replaces (props.tscn), by chunk: "all" hides the node, "strip" hides the instances whose
# origin lies in the strip, "rubble" those in the three rubble piles' colliders (scale set to 0, the entry kept). Static corpse pieces (white boxes, red quads), the dark
# drag marks (iron quads) and the bin are left as they are (PLAN section 2: corpses are not environment work).
A16_HIDE = {
	"P_paper_box_p0_p0": "all", "P_paper_box_p0_p1": "all", "P_paper_box_p1_p0": "strip",
	"D_paper_quad_m1_p0": "all", "D_paper_quad_p0_p0": "strip",
	"P_concrete_box_p0_p1": "rubble", "P_iron_cylinder_p0_p1": "rubble",
	"P_iron_box_p0_p0": "all", "P_wood_box_p0_p0": "all",
}


def in_rubble(origin):
	x, _, z = origin
	return any(ax - 0.3 <= x <= bx + 0.3 and az - 0.3 <= z <= bz + 0.3 for (ax, az), (bx, bz) in RUBBLE_BOXES)
