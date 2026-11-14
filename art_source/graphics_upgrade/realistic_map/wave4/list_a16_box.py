"""T-261 round 1: lists the A16 PS1 pieces inside this wave's box (stadium_layout.A16_BOX) from main's campus.tscn and
props.tscn: the road meshes, the ground tiles the new ground lies on, and in props.tscn only litter (paper on the
ground) and broken bricks (the two rubble piles with their pipes). Benches, bins, bicycles, cars, cones, lamps, trees,
static corpse pieces and dark drag marks stay (card section 3). Writes a16_box_nodes.json next to this file.
Run: python -B art_source/graphics_upgrade/realistic_map/wave4/list_a16_box.py
"""
from pathlib import Path
import json
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import stadium_layout as L  # noqa: E402

ROOT = HERE.parents[3]
CAMPUS = ROOT / "game/scenes/levels/campus"
BOX = L.A16_BOX
# The two rubble piles' colliders (props.tscn Solids/Body_p2_p3/S1, Body_p2_p4/S1), with a margin.
RUBBLE = [((86.95, 151.44), 1.6), ((99.2, 173.5), 1.5)]


def in_box(x, y, z):
	return BOX["x"][0] <= x <= BOX["x"][1] and BOX["z"][0] <= z <= BOX["z"][1] and BOX["y"][0] <= y <= BOX["y"][1]


def kind(name, origin, scale):
	x, y, z = origin
	near_rubble = any((x - cx) ** 2 + (z - cz) ** 2 <= r * r for (cx, cz), r in RUBBLE)
	if name.startswith(("P_paper", "D_paper")) and y < -9.7:
		return "litter"
	if near_rubble and name.startswith("P_concrete_box") and max(scale) < 1.0:
		return "rubble"
	if near_rubble and name.startswith("P_iron_cylinder") and abs(scale[1] - 1.1) < 0.05:
		return "rubble pipe"
	return None


def props():
	text = (CAMPUS / "props.tscn").read_text(encoding="utf-8")
	out = {}
	for block in re.split(r"\n(?=\[node )", text):
		m = re.search(r'name="([^"]+)"', block.split("\n", 1)[0])
		d = re.search(r"data = PackedFloat32Array\(([^)]*)\)", block)
		if not m or not d:
			continue
		v = [float(t) for t in d.group(1).split(",")]
		hits = []
		for i in range(len(v) // 16):
			c = v[i * 16:i * 16 + 16]
			origin = tuple(c[9:12])
			scale = tuple(sum(t * t for t in c[k:k + 3]) ** 0.5 for k in (0, 3, 6))
			if max(scale) == 0 or not in_box(*origin):
				continue
			k = kind(m.group(1), origin, scale)
			if k:
				hits.append({"index": i, "kind": k, "origin": [round(t, 3) for t in origin]})
		if hits:
			parent = "Decals" if m.group(1).startswith("D_") else "Parts"
			out[f"Props/{parent}/{m.group(1)}"] = {"instances": len(v) // 16, "in_box": hits}
	return out


def campus():
	text = (CAMPUS / "campus.tscn").read_text(encoding="utf-8")
	roads, tiles = [], []
	for name in ("WestBranch", "StadiumWestAccess"):
		m = re.search(r'\[node name="%s" type="Node3D" parent="Road"\]\nposition = Vector3\(([^)]*)\)' % name, text)
		roads.append({"path": f"Road/{name}/Mesh", "position": [float(t) for t in m.group(1).split(",")]})
	for m in re.finditer(r'\[node name="(Tile_(-?\d+)_(-?\d+))" type="StaticBody3D" parent="Ground"\]', text):
		x0, z0 = int(m.group(2)), int(m.group(3))
		if x0 < BOX["x"][1] and x0 + 50 > BOX["x"][0] and z0 < BOX["z"][1] and z0 + 50 > BOX["z"][0] + 1:
			tiles.append(f"Ground/{m.group(1)}")
	return {"hide_whole": roads, "ground_tiles_under_new_ground (kept, colliders unchanged)": tiles}


def main():
	result = {"box": BOX, "campus.tscn": campus(), "props.tscn": props()}
	counts = {}
	for node, entry in result["props.tscn"].items():
		for hit in entry["in_box"]:
			counts[hit["kind"]] = counts.get(hit["kind"], 0) + 1
	result["counts"] = counts
	(HERE / "a16_box_nodes.json").write_text(json.dumps(result, ensure_ascii=False, indent=1), encoding="utf-8", newline="\n")
	print(json.dumps(result["campus.tscn"], ensure_ascii=False))
	for node, entry in result["props.tscn"].items():
		kinds = sorted({h["kind"] for h in entry["in_box"]})
		print(node, "%d/%d" % (len(entry["in_box"]), entry["instances"]), ",".join(kinds))
	print("counts", counts)


if __name__ == "__main__":
	main()
