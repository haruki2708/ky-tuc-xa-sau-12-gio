"""T-264 round 1, step 1: the A16 that is left after waves 3-6 (card section 0), counted from the branch's scenes (main):
props.tscn's MultiMesh instances (boxes.gd, 16 floats each) sorted into what they are (art_source/campus/scatter.py
made them: a body's torso, head, arms and legs, blood, drag marks, everything else) and where they lie (a done strip,
wave 8's library zone, building B, the background buildings' footprints, or what is left for this wave); campus.tscn's
roads, trees, trunks, street lights, benches, mopeds, fences and ground tiles in the same regions. Heads are counted per
node before anything is touched (T-259 hid a whole node and with it nine corpse heads).
Writes a16_rest.json next to this file and prints a summary.
Run: python -B art_source/graphics_upgrade/realistic_map/wave7/list_a16_rest.py
"""
from pathlib import Path
import json
import math
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import wave7_layout as L  # noqa: E402

ROOT = HERE.parents[3]
CAMPUS = ROOT / "game/scenes/levels/campus"


def close(a, b, tol=0.015):
	return all(abs(x - y) <= tol for x, y in zip(a, b))


def what(name, c):
	"""scatter.py's piece this instance is (body parts by their box sizes, blood, drag marks), else 'other'."""
	scale = tuple(math.sqrt(sum(t * t for t in c[k:k + 3])) for k in (0, 3, 6))
	tint = tuple(round(t, 2) for t in c[12:15])
	if name.startswith("P_paper_box") and tint == L.SKIN and close(scale, (0.22, 0.22, 0.22), 0.02):
		return "body: head"
	if name.startswith("P_white_box"):
		for sig, part in (((0.34, 0.24, 0.55), "body: torso"), ((0.12, 0.12, 0.55), "body: arm"), ((0.15, 0.15, 0.78), "body: leg")):
			if close(scale, sig):
				return part
	if name.startswith("D_red"):
		return "blood"
	if name.startswith("D_iron"):
		return "drag mark"
	return "other"


def props():
	text = (CAMPUS / "props.tscn").read_text(encoding="utf-8")
	out = {}
	for m in re.finditer(r'\[node name="([^"]+)" type="Node3D" parent="(Parts|Decals)"\]\n(.*?)(?=\n\[|\Z)', text, re.S):
		d = re.search(r"data = PackedFloat32Array\(([^)]*)\)", m.group(3))
		if not d:
			continue
		v = [float(t) for t in d.group(1).split(",")]
		hidden = "\nvisible = false" in m.group(3)
		chunk = {"parent": m.group(2), "instances": len(v) // 16, "node_hidden": hidden, "heads": 0, "regions": {}}
		for i in range(len(v) // 16):
			c = v[i * 16:i * 16 + 16]
			zero = c[0] == 0 and c[4] == 0 and c[8] == 0
			kind = what(m.group(1), c)
			if kind == "body: head":
				chunk["heads"] += 1
			region = "zeroed" if zero else L.region(c[9], c[11])
			reg = chunk["regions"].setdefault(region, {})
			reg[kind] = reg.get(kind, 0) + 1
			if region == "rest" and kind == "other":
				chunk.setdefault("rest_other", []).append(i)
		out["%s/%s" % (m.group(2), m.group(1))] = chunk
	return out


def vec3s(text):
	vals = [float(t) for t in text.split(",") if t.strip()]
	return [tuple(vals[k:k + 3]) for k in range(0, len(vals), 3)]


def campus():
	text = (CAMPUS / "campus.tscn").read_text(encoding="utf-8")
	props_text = (CAMPUS / "props.tscn").read_text(encoding="utf-8")
	out = {"trees": {}, "lamps": {}, "extra_trees": {}}
	for source, key, pattern in ((text, "trees", r'\[node name="(Trees_[^"]+)"[^\]]*parent="Road"\][^\[]*?points = PackedVector3Array\(([^)]*)\)'),
			(text, "lamps", r'\[node name="(StreetLights_[^"]+)"[^\]]*parent="Road"\][^\[]*?points = PackedVector3Array\(([^)]*)\)'),
			(props_text, "extra_trees", r'\[node name="(ExtraTrees_[^"]+)"[^\]]*parent="Trees"\][^\[]*?points = PackedVector3Array\(([^)]*)\)')):
		for m in re.finditer(pattern, source, re.S):
			pts = vec3s(m.group(2))
			regions = {}
			for p in pts:
				r = L.region(p[0], p[2])
				regions[r] = regions.get(r, 0) + 1
			out[key][m.group(1)] = {"points": len(pts), "regions": regions}
	trunks = {}
	for m in re.finditer(r'\[node name="(TreeTrunk\d+)" type="StaticBody3D" parent="Road"\]\nposition = Vector3\(([^)]*)\)', text):
		p = [float(t) for t in m.group(2).split(",")]
		trunks.setdefault(L.region(p[0], p[2]), []).append(m.group(1))
	out["trunks"] = {r: len(v) for r, v in trunks.items()}
	for name in ("RoadBench", "BenchBody", "FallenMoped", "MopedBody"):
		hits = {}
		for m in re.finditer(r'\[node name="(%s\d+)" type="[^"]+" parent="Road"\]\nposition = Vector3\(([^)]*)\)' % name, text):
			p = [float(t) for t in m.group(2).split(",")]
			hits[m.group(1)] = [round(p[0], 1), round(p[2], 1), L.region(p[0], p[2])]
		out[name] = hits
	tiles = {}
	for m in re.finditer(r'\[node name="(Tile_(-?\d+)_(-?\d+))" type="StaticBody3D" parent="Ground"\]', text):
		x0, z0 = int(m.group(2)), int(m.group(3))
		cells = {}
		for dx in range(5, 50, 10):
			for dz in range(5, 50, 10):
				r = L.region(x0 + dx, z0 + dz)
				cells[r] = cells.get(r, 0) + 1
		tiles[m.group(1)] = cells
	out["ground_tiles"] = tiles
	return out


def main():
	p = props()
	c = campus()
	totals = {}
	heads = 0
	for chunk in p.values():
		heads += chunk["heads"]
		for region, kinds in chunk["regions"].items():
			for kind, n in kinds.items():
				totals.setdefault(region, {}).setdefault(kind, 0)
				totals[region][kind] += n
	result = {"regions": L.REGIONS_DOC, "props_totals": totals, "heads_total": heads, "props": p, "campus": c}
	(HERE / "a16_rest.json").write_text(json.dumps(result, ensure_ascii=False, indent=1), encoding="utf-8", newline="\n")
	print("heads in props.tscn:", heads)
	for region, kinds in sorted(totals.items()):
		print(region, dict(sorted(kinds.items())))
	rest_chunks = {k: v["regions"]["rest"] for k, v in p.items() if "rest" in v["regions"]}
	print("chunks with pieces left for wave 7:", len(rest_chunks))
	for key in ("trees", "lamps", "extra_trees"):
		agg = {}
		for v in c[key].values():
			for r, n in v["regions"].items():
				agg[r] = agg.get(r, 0) + n
		print(key, len(c[key]), "nodes", agg)
	print("trunks", c["trunks"])
	for name in ("RoadBench", "FallenMoped"):
		print(name, c[name])


if __name__ == "__main__":
	main()
