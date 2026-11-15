"""T-262 round 1: lists the A16 PS1 pieces inside this wave's gate box (gate_layout.A16_BOX) from main's campus.tscn
and props.tscn, sorted into what round 2 would replace (card section 3: litter and paper, cones, barriers, the PS1
cars; the court's dropped bags, shoes, phones; the rubble pile) and what stays (bodies and their heads, blood, cracks
and drag marks, bins, benches, planters, bicycles, mopeds, crates, lamps, trees). Only instances still shown on main
are listed (scale > 0). Writes a16_box_nodes.json next to this file.
Run: python -B art_source/graphics_upgrade/realistic_map/wave5/list_a16_box.py
"""
from pathlib import Path
import json
import math
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import gate_layout as L  # noqa: E402

ROOT = HERE.parents[3]
CAMPUS = ROOT / "game/scenes/levels/campus"
RUBBLE = ((213.95, -22.7), 1.4)  # the court's rubble pile (props.tscn Solids/Body_p5_m1/S6)


def close(a, b, tol=0.015):
	return all(abs(x - y) <= tol for x, y in zip(a, b))


def kind(name, origin, scale, tint):
	x, y, z = origin
	tex = name.split("_")[1]
	shape = name.split("_")[2]
	if tuple(round(t, 2) for t in tint) == L.SKIN:
		return "keep: body"
	near = lambda pts, r: any(math.hypot(x - p[0], z - p[1]) <= r for p in pts)  # noqa: E731
	if near([(b[0], b[1]) for b in L.BARRIERS], 1.6) and (close(scale, (0.6, 0.28, 0.06)) or close(scale, (0.07, 0.8, 0.5))):
		return "barrier"
	if near([(c[0], c[1]) for c in L.CONE_ROWS], 2.6) and (shape == "cone" or close(scale, (0.46, 0.04, 0.46))):
		return "cone"
	if near([(c[0], c[1]) for c in L.CARS], 3.2) and name.startswith("P_") and (scale[0] >= 2.2 or close(scale, (0.68, 0.24, 0.68))
			or close(scale, (0.18, 0.22, 1.7)) or close(scale, (0.08, 0.16, 0.3)) or close(scale, (0.08, 0.14, 0.3))):
		return "car"
	if name.startswith("D_paper") and y < -9.7:
		return "paper"
	if name.startswith("P_white_box") and (close(scale, (0.32, 0.42, 0.2)) or close(scale, (0.26, 0.2, 0.06))):
		return "dropped: backpack"
	if name.startswith("P_white_box") and close(scale, (0.26, 0.1, 0.1)):
		return "dropped: shoe"
	if name.startswith("D_white") and close(scale, (0.11, 1.0, 0.27)):
		return "dropped: sandal"
	if (name.startswith("D_white") and close(scale, (0.07, 1.0, 0.15))) or (name.startswith("D_iron") and close(scale, (0.012, 1.0, 0.17))):
		return "dropped: phone"
	if (name.startswith("P_white_box") and close(scale, (0.42, 0.03, 0.3))) or (name.startswith("P_paper_box") and close(scale, (0.34, 0.012, 0.16))):
		return "dropped: tray"
	if math.hypot(x - RUBBLE[0][0], z - RUBBLE[0][1]) <= RUBBLE[1] and (tex == "concrete" or close(scale, (0.04, 1.1, 0.04))):
		return "rubble"
	if name.startswith("D_red"):
		return "keep: blood"
	if name.startswith("D_iron"):
		return "keep: crack"
	if name.startswith("P_white_box") and (close(scale, (0.34, 0.24, 0.55)) or close(scale, (0.12, 0.12, 0.55)) or close(scale, (0.15, 0.15, 0.78))):
		return "keep: body"
	return "keep: other (%s %s)" % (tex, shape)


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
			if max(scale) == 0 or not L.in_box(*origin):
				continue
			hits.append({"index": i, "kind": kind(m.group(1), origin, scale, c[12:15]), "origin": [round(t, 3) for t in origin]})
		if hits:
			parent = "Decals" if m.group(1).startswith("D_") else "Parts"
			out[f"Props/{parent}/{m.group(1)}"] = {"instances": len(v) // 16, "in_box": hits}
	solids = []
	for m in re.finditer(r'\[node name="(S\d+)" type="CollisionShape3D" parent="Solids/([^"]+)"\]\nposition = Vector3\(([^)]*)\)', text):
		p = [float(t) for t in m.group(3).split(",")]
		if L.in_box(*p):
			solids.append(f"Props/Solids/{m.group(2)}/{m.group(1)} ({p[0]:.1f}, {p[2]:.1f})")
	lights = []
	for m in re.finditer(r'\[node name="([^"]+)" type="OmniLight3D" parent="Lights"\]\nposition = Vector3\(([^)]*)\)', text):
		p = [float(t) for t in m.group(2).split(",")]
		if L.in_box(p[0], -9.0, p[2]):
			lights.append(f"Props/Lights/{m.group(1)} ({p[0]:.1f}, {p[1]:.1f}, {p[2]:.1f})")
	return out, solids, lights


def campus():
	text = (CAMPUS / "campus.tscn").read_text(encoding="utf-8")
	tiles = []
	for m in re.finditer(r'\[node name="(Tile_(-?\d+)_(-?\d+))" type="StaticBody3D" parent="Ground"\]', text):
		x0, z0 = int(m.group(2)), int(m.group(3))
		if x0 < L.A16_BOX["x"][1] and x0 + 50 > L.A16_BOX["x"][0] and z0 < L.A16_BOX["z"][1] and z0 + 50 > L.A16_BOX["z"][0]:
			tiles.append(f"Ground/{m.group(1)}")
	return {
		"partly_in_box": ["Road/Avenue/Mesh (x 0..220, z -19..-11: x 180..220 inside; test_t261 keeps it visible)"],
		"ground_tiles_under_new_ground (kept, colliders unchanged)": tiles,
		"kept": ["Road/StreetLights_4_-1 (180, -20)", "Road/StreetLights_5_-1 (200, -20) (220, -20)",
			"Road/Trees_4_-1 (184, -7)", "Road/Trees_5_-1 (200, -7)", "Road/TreeTrunk104", "Road/TreeTrunk105",
			"Road/FallenMoped2 + Road/MopedBody2 (225, -25)", "Anchors/BarSpawns/B05 (228, -29)",
			"Fence/S (the wall: A14, its own option and scope question)"],
	}


def main():
	parts, solids, lights = props()
	result = {"box": L.A16_BOX, "campus.tscn": campus(), "props.tscn": parts, "props.tscn solids in box (kept)": solids,
		"props.tscn lights in box (kept)": lights}
	counts = {}
	for node, entry in parts.items():
		for hit in entry["in_box"]:
			counts[hit["kind"]] = counts.get(hit["kind"], 0) + 1
	result["counts"] = dict(sorted(counts.items()))
	(HERE / "a16_box_nodes.json").write_text(json.dumps(result, ensure_ascii=False, indent=1), encoding="utf-8", newline="\n")
	print(json.dumps(result["campus.tscn"], ensure_ascii=False, indent=1))
	for node, entry in parts.items():
		kinds = sorted({h["kind"] for h in entry["in_box"]})
		print(node, "%d/%d" % (len(entry["in_box"]), entry["instances"]), "; ".join(kinds))
	print("solids", len(solids), "lights", lights)
	for k, n in sorted(counts.items()):
		print("count", k, n)


if __name__ == "__main__":
	main()
