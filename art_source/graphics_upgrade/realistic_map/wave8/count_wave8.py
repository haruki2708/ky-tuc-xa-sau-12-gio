"""T-265: triangles and materials per glb and per part (mesh) of the wave-8 pilot, for the options table in the card's
Handoff and the README. Reads the glbs directly (no Blender, no Godot).
Run: python -B art_source/graphics_upgrade/realistic_map/wave8/count_wave8.py
"""
from pathlib import Path
import json
import struct
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
MODELS = ROOT / "game/assets/models/graphics_pilot/realistic_map/wave8"


def parts(path):
	data = path.read_bytes()
	length = struct.unpack_from("<I", data, 12)[0]
	doc = json.loads(data[20:20 + length])
	mats = [m["name"] for m in doc.get("materials", [])]
	out = {}
	for mesh in doc["meshes"]:
		tris = 0
		used = set()
		for prim in mesh["primitives"]:
			tris += doc["accessors"][prim["indices"]]["count"] // 3
			used.add(mats[prim["material"]] if "material" in prim else "-")
		out[mesh.get("name", "?")] = (tris, sorted(used))
	return out


def main():
	total = 0
	result = {}
	for glb in sorted(MODELS.glob("*.glb")):
		p = parts(glb)
		t = sum(v[0] for v in p.values())
		total += t
		mats = sorted({m for v in p.values() for m in v[1]})
		result[glb.stem] = {"triangles": t, "materials": mats, "parts": {k: v[0] for k, v in p.items()}}
		print("%-18s %7d tris %2d mats  %s" % (glb.stem, t, len(mats), ", ".join("%s %d" % (k, v[0]) for k, v in p.items())))
	print("total", total)
	(Path(__file__).parent / "survey/pilot_counts.json").write_text(json.dumps(result, indent=1), encoding="utf-8", newline="\n")


if __name__ == "__main__":
	main()
