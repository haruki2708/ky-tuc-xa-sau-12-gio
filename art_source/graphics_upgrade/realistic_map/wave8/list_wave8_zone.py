"""T-265 round 1, step 1: wave 8's outdoor box (x 39..91, z 189..231 less the library's own floor x 45..85, z 195..225),
counted from the branch's scenes (main after wave 7 round 3) before anything is touched: props.tscn's MultiMesh instances
(boxes.gd, 16 floats each) sorted into what they are (wave 7's list_a16_rest.what: a body's torso, head, arms and legs,
blood, drag marks, everything else) with their indices, which are already scaled to 0, the heads per node; props.tscn's
solid colliders (Solids/*), campus.tscn's trees, trunks, street lights, benches, mopeds and ground tiles in the box; and
whether wave 7's StripRest ground glb has faces in it.
Writes zone8.json next to this file and prints a summary.
Run: python -B art_source/graphics_upgrade/realistic_map/wave8/list_wave8_zone.py
"""
from pathlib import Path
import json
import math
import re
import struct
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave7"))
import list_a16_rest as W7  # noqa: E402  (what(), vec3s(); its main is guarded)

ROOT = HERE.parents[3]
CAMPUS = ROOT / "game/scenes/levels/campus"
BOX = (39.0, 91.0, 189.0, 231.0)
FLOOR = (45.0, 85.0, 195.0, 225.0)


def where(x, z):
	if not (BOX[0] <= x <= BOX[1] and BOX[2] <= z <= BOX[3]):
		return None
	if FLOOR[0] <= x <= FLOOR[1] and FLOOR[2] <= z <= FLOOR[3]:
		return "library floor"
	return "outside"


def props():
	text = (CAMPUS / "props.tscn").read_text(encoding="utf-8")
	out = {}
	heads_all = 0
	for m in re.finditer(r'\[node name="([^"]+)" type="Node3D" parent="(Parts|Decals)"\]\n(.*?)(?=\n\[|\Z)', text, re.S):
		d = re.search(r"data = PackedFloat32Array\(([^)]*)\)", m.group(3))
		if not d:
			continue
		v = [float(t) for t in d.group(1).split(",")]
		hidden = "\nvisible = false" in m.group(3)
		heads = 0
		inside = []
		for i in range(len(v) // 16):
			c = v[i * 16:i * 16 + 16]
			kind = W7.what(m.group(1), c)
			if kind == "body: head":
				heads += 1
			w = where(c[9], c[11])
			if w is None:
				continue
			zero = c[0] == 0 and c[4] == 0 and c[8] == 0
			scale = [round(math.sqrt(sum(t * t for t in c[k:k + 3])), 3) for k in (0, 3, 6)]
			inside.append({"index": i, "kind": kind, "where": w, "zeroed": zero, "at": [round(c[9], 2), round(c[10], 2), round(c[11], 2)],
				"scale": scale, "tint": [round(t, 2) for t in c[12:15]]})
		heads_all += heads
		if inside:
			out["%s/%s" % (m.group(2), m.group(1))] = {"instances": len(v) // 16, "node_hidden": hidden, "heads_in_node": heads,
				"in_box": inside}
	return out, heads_all


def solids():
	text = (CAMPUS / "props.tscn").read_text(encoding="utf-8")
	shapes = {m.group(1): m.group(2) for m in re.finditer(r'\[sub_resource type="BoxShape3D" id="([^"]+)"\]\nsize = Vector3\(([^)]*)\)', text)}
	out = []
	for m in re.finditer(r'\[node name="([^"]+)" type="CollisionShape3D" parent="(Solids/[^"]+)"\]\nposition = Vector3\(([^)]*)\)\n'
			r'shape = SubResource\("([^"]+)"\)(?:\nrotation_degrees = Vector3\(([^)]*)\))?', text):
		p = [float(t) for t in m.group(3).split(",")]
		w = where(p[0], p[2])
		if w is None:
			continue
		out.append({"path": "Props/%s/%s" % (m.group(2), m.group(1)), "at": p, "size": shapes.get(m.group(4)), "yaw": m.group(5),
			"where": w})
	return out


def campus():
	text = (CAMPUS / "campus.tscn").read_text(encoding="utf-8")
	props_text = (CAMPUS / "props.tscn").read_text(encoding="utf-8")
	out = {}
	for source, key, pattern in ((text, "trees", r'\[node name="(Trees_[^"]+)"[^\]]*parent="Road"\][^\[]*?points = PackedVector3Array\(([^)]*)\)'),
			(text, "lamps", r'\[node name="(StreetLights_[^"]+)"[^\]]*parent="Road"\][^\[]*?points = PackedVector3Array\(([^)]*)\)'),
			(props_text, "extra_trees", r'\[node name="(ExtraTrees_[^"]+)"[^\]]*parent="Trees"\][^\[]*?points = PackedVector3Array\(([^)]*)\)'),
			(props_text, "prop_lights", r'\[node name="([^"]+)"[^\]]*parent="Lights"\][^\[]*?points = PackedVector3Array\(([^)]*)\)')):
		hits = {}
		for m in re.finditer(pattern, source, re.S):
			pts = [p for p in W7.vec3s(m.group(2)) if where(p[0], p[2])]
			if pts:
				hits[m.group(1)] = [[round(c, 2) for c in p] for p in pts]
		out[key] = hits
	for name in ("TreeTrunk", "RoadBench", "BenchBody", "FallenMoped", "MopedBody"):
		hits = {}
		for m in re.finditer(r'\[node name="(%s\d+)" type="[^"]+" parent="Road"\]\nposition = Vector3\(([^)]*)\)' % name, text):
			p = [float(t) for t in m.group(2).split(",")]
			if where(p[0], p[2]):
				hits[m.group(1)] = [round(p[0], 2), round(p[2], 2)]
		out[name] = hits
	tiles = []
	for m in re.finditer(r'\[node name="(Tile_(-?\d+)_(-?\d+))" type="StaticBody3D" parent="Ground"\]', text):
		x0, z0 = int(m.group(2)), int(m.group(3))
		if x0 < BOX[1] and x0 + 50 > BOX[0] and z0 < BOX[3] and z0 + 50 > BOX[2]:
			tiles.append(m.group(1))
	out["ground_tiles"] = tiles
	road = []
	for m in re.finditer(r'\[node name="([^"]+)" type="MeshInstance3D" parent="Road"\]\nposition = Vector3\(([^)]*)\)', text):
		p = [float(t) for t in m.group(2).split(",")]
		if BOX[0] - 120 <= p[0] <= BOX[1] + 120 and BOX[2] - 120 <= p[2] <= BOX[3] + 120:
			road.append([m.group(1), p])
	out["road_meshes_near"] = road
	return out


def glb_faces_in_box(path):
	"""Counts triangles of a glb (positions in Godot world, origin at (0, G, 0) as wave 7 builds them) whose centre falls in
	the box's outside ring and on the library's floor."""
	data = path.read_bytes()
	length = struct.unpack_from("<I", data, 12)[0]
	doc = json.loads(data[20:20 + length])
	binary_at = 20 + length + 8
	counts = {}
	for mesh in doc["meshes"]:
		for prim in mesh["primitives"]:
			acc = doc["accessors"][prim["attributes"]["POSITION"]]
			view = doc["bufferViews"][acc["bufferView"]]
			base = binary_at + view.get("byteOffset", 0) + acc.get("byteOffset", 0)
			stride = view.get("byteStride", 12)
			pos = [struct.unpack_from("<fff", data, base + i * stride) for i in range(acc["count"])]
			ia = doc["accessors"][prim["indices"]]
			iv = doc["bufferViews"][ia["bufferView"]]
			ibase = binary_at + iv.get("byteOffset", 0) + ia.get("byteOffset", 0)
			fmt = {5123: "<H", 5125: "<I"}[ia["componentType"]]
			size = struct.calcsize(fmt)
			idx = [struct.unpack_from(fmt, data, ibase + i * size)[0] for i in range(ia["count"])]
			for t in range(0, len(idx), 3):
				cx = sum(pos[k][0] for k in idx[t:t + 3]) / 3
				cz = sum(pos[k][2] for k in idx[t:t + 3]) / 3
				w = where(cx, cz)
				if w:
					key = "%s: %s" % (mesh.get("name", "?"), w)
					counts[key] = counts.get(key, 0) + 1
	return counts


def main():
	p, heads_all = props()
	result = {"box": BOX, "library_floor": FLOOR, "props": p, "heads_in_props_tscn": heads_all, "solids": solids(), "campus": campus()}
	ground = {}
	for glb in sorted((ROOT / "game/assets/models/graphics_pilot/realistic_map/wave7").glob("*.glb")):
		if glb.stat().st_size < 30_000_000:
			try:
				counts = glb_faces_in_box(glb)
			except (KeyError, struct.error):
				continue
			if counts:
				ground[glb.name] = counts
	result["wave7_glb_faces_in_box"] = ground
	(HERE / "zone8.json").write_text(json.dumps(result, ensure_ascii=False, indent=1), encoding="utf-8", newline="\n")
	print("heads in props.tscn (all):", heads_all)
	kinds = {}
	for key, chunk in p.items():
		for e in chunk["in_box"]:
			k = (e["where"], e["kind"], "zeroed" if e["zeroed"] else "shown")
			kinds[k] = kinds.get(k, 0) + 1
		print("%s: %d instances, %d in the box, node heads %d%s" % (key, chunk["instances"], len(chunk["in_box"]), chunk["heads_in_node"],
			" (node hidden)" if chunk["node_hidden"] else ""))
	for k, n in sorted(kinds.items()):
		print("  ", k, n)
	print("solids:", [(s["path"], s["at"], s["size"]) for s in result["solids"]])
	for key, value in result["campus"].items():
		print(key, value if not isinstance(value, dict) else {k: len(v) if isinstance(v, list) else v for k, v in value.items()})
	print("wave 7 glbs with faces in the box:", ground)


if __name__ == "__main__":
	main()
