"""T-263 round 1: lists the A16 PS1 pieces inside this wave's box round the canteen (canteen_layout.A16_BOX less the
wave-8 corner A16_WAVE8) from the branch's campus.tscn and props.tscn (main plus step 0), sorted into what round 2
would replace (card section 3: litter and paper, dropped bags, sandals, trays) and what stays (drag marks, bodies, blood,
cracks, bins, the two kiosks, the drinks machine, the bicycle, the moped, lamps). Only instances still shown are listed
(scale > 0). canteen.tscn's own outside pieces (bikes, bins, gas cylinders, AC units) are A15, listed apart.
Writes a16_box_nodes.json next to this file.
Run: python -B art_source/graphics_upgrade/realistic_map/wave6/list_a16_box.py
"""
from pathlib import Path
import json
import math
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import canteen_layout as L  # noqa: E402

ROOT = HERE.parents[3]
CAMPUS = ROOT / "game/scenes/levels/campus"
SKIN = (0.9, 0.7, 0.6)
KIOSKS = [(214.0, 17.4), (219.5, 17.4)]       # props.tscn Solids/Body_p5_p0 S1, S3: two roofed stalls by the front
MACHINE = (182.2, 16.0)                       # Body_p4_p0 S1: a drinks machine
BICYCLE = (208.4, 17.1)                       # Body_p5_p0 S4
MOPED = (207.6, 54.6)                         # Body_p5_p1 S0


def close(a, b, tol=0.015):
	return all(abs(x - y) <= tol for x, y in zip(a, b))


def kind(name, origin, scale, tint):
	x, y, z = origin
	near = lambda p, r: math.hypot(x - p[0], z - p[1]) <= r  # noqa: E731
	if tuple(round(t, 2) for t in tint) == SKIN:
		return "keep: body"
	if name.startswith("D_iron"):
		return "keep: drag mark"
	if name.startswith("D_red"):
		return "keep: blood"
	if any(near(k, 2.6) for k in KIOSKS):
		return "keep: kiosk"
	if near(MACHINE, 0.8):
		return "keep: drinks machine"
	if near(BICYCLE, 0.9):
		return "keep: bicycle"
	if near(MOPED, 1.3):
		return "keep: moped"
	if name.startswith("D_paper") and y < -9.7:
		return "paper"
	if name.startswith("D_white") and close(scale, (0.11, 1.0, 0.27)):
		return "dropped: sandal"
	if name.startswith("P_white_box") and (close(scale, (0.32, 0.42, 0.2)) or close(scale, (0.26, 0.2, 0.06))):
		return "dropped: backpack"
	if (name.startswith("P_white_box") and close(scale, (0.42, 0.03, 0.3))) or (name.startswith("P_paper_box") and close(scale, (0.34, 0.012, 0.16))):
		return "dropped: tray"
	return "keep: other (%s)" % name


def props():
	text = (CAMPUS / "props.tscn").read_text(encoding="utf-8")
	out = {}
	for block in re.split(r"\n(?=\[node )", text):
		m = re.search(r'name="([^"]+)"', block.split("\n", 1)[0])
		d = re.search(r"data = PackedFloat32Array\(([^)]*)\)", block)
		if not m or not d or "\nvisible = false" in block:
			continue
		v = [float(t) for t in d.group(1).split(",")]
		hits = []
		for i in range(len(v) // 16):
			c = v[i * 16:i * 16 + 16]
			origin = tuple(c[9:12])
			scale = tuple(sum(t * t for t in c[k:k + 3]) ** 0.5 for k in (0, 3, 6))
			if max(scale) == 0 or not L.in_a16(origin[0], origin[2]):
				continue
			hits.append({"index": i, "kind": kind(m.group(1), origin, scale, c[12:15]), "origin": [round(t, 3) for t in origin]})
		if hits:
			parent = "Decals" if m.group(1).startswith("D_") else "Parts"
			out[f"Props/{parent}/{m.group(1)}"] = {"instances": len(v) // 16, "in_box": hits}
	solids = []
	for m in re.finditer(r'\[node name="(S\d+)" type="CollisionShape3D" parent="Solids/([^"]+)"\]\nposition = Vector3\(([^)]*)\)', text):
		p = [float(t) for t in m.group(3).split(",")]
		if L.in_a16(p[0], p[2]):
			solids.append(f"Props/Solids/{m.group(2)}/{m.group(1)} ({p[0]:.1f}, {p[2]:.1f})")
	return out, solids


def campus():
	text = (CAMPUS / "campus.tscn").read_text(encoding="utf-8")
	tiles = []
	for m in re.finditer(r'\[node name="(Tile_(-?\d+)_(-?\d+))" type="StaticBody3D" parent="Ground"\]', text):
		x0, z0 = int(m.group(2)), int(m.group(3))
		if x0 < L.A16_BOX["x"][1] and x0 + 50 > L.A16_BOX["x"][0] and z0 < L.A16_BOX["z"][1] and z0 + 50 > L.A16_BOX["z"][0]:
			tiles.append(f"Ground/{m.group(1)}")
	return {
		"ground_tiles_under_new_ground (meshes and colliders kept: the new lawn lies 1 cm over them as in waves 3-5)": tiles,
		"edge": "T-262's StripGate ends at z 13 (lawn x 180..262; paved walk x 186..217 at z 7..13 heading for the door): "
			"round 2 continues the walk from z 13 to the step (z 17.9) and the lawn from z 13.",
		"kept (not A16)": ["Anchors/*, Zones/Canteen, Navigation/CanteenEntry, KitchenEntry, StoreEntry, StoreExit",
			"Ch4/Start_split (167, 40.5) and the ground west of the hall north of z 37 (wave 8)"],
		"canteen.tscn pieces outside the walls (A15, round 2 with the canteen)": ["Bike0..5 (x 172..181, z 17.2)",
			"Bin205, Bin206.2 (z 54.2)", "GasCylinder0, GasCylinder1 (189..189.6, 53)", "ACUnit24/30/36, ACGrill* (west wall)",
			"Chimney (192, 51)"],
	}


def main():
	parts, solids = props()
	result = {"box": {"x": L.A16_BOX["x"], "z": L.A16_BOX["z"], "less (wave 8)": L.A16_WAVE8}, "campus.tscn": campus(),
		"props.tscn": parts, "props.tscn solids in box (kept)": solids}
	counts = {}
	for node, entry in parts.items():
		for hit in entry["in_box"]:
			counts[hit["kind"]] = counts.get(hit["kind"], 0) + 1
	result["counts"] = dict(sorted(counts.items()))
	(HERE / "a16_box_nodes.json").write_text(json.dumps(result, ensure_ascii=False, indent=1), encoding="utf-8", newline="\n")
	for node, entry in parts.items():
		kinds = sorted({h["kind"] for h in entry["in_box"]})
		print(node, "%d/%d" % (len(entry["in_box"]), entry["instances"]), "; ".join(kinds))
	print("solids", solids)
	for k, n in sorted(counts.items()):
		print("count", k, n)


if __name__ == "__main__":
	main()
