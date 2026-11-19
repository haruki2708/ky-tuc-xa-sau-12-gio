"""T-264 round 2 (D-182): hang the buildings in the scenes. Plain text edits of the .tscn files, each step refuses to run
twice. Nothing is removed: the PS1 meshes are hidden (visible = false), colliders, nodes, metas stay; the one node moved
is WindowSilhouette2 (x 31 -> 32, into its window; card section 1).

  Real nodes carry shells_real.gd (no shadow from glass, fake rooms, grilles, frames, small things; ranges).
  shells       shells.tscn: every MeshInstance3D hidden but wave 8's LibraryBand*; Real/BuildingA, Real/Lecture, Real/Gym
               at (0, G, 0); a Figure (figure.glb) under each WindowSilhouette node; WindowSilhouette2 to x 32
  building_b   building_b.tscn: UpperFloor5/6 and UpperWindow5_*/6_* meshes hidden; Real/Outside (b_outside.glb)
  backdrop     floor4/garden_backdrop.tscn: BuildingA (bldga_light.glb), chapters 1-2's light building A
Run: python -B art_source/graphics_upgrade/realistic_map/wave7/patch_wave7.py [step ...]
"""
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[4]
LEVELS = ROOT / "game/scenes/levels"
W7 = "res://assets/models/graphics_pilot/realistic_map/wave7/"
SCRIPT = "res://scenes/levels/campus/shells_real.gd"
G = -9.9
SHELLS_REAL = [("BuildingA", "bldga"), ("Lecture", "lecture"), ("Gym", "gym")]
FIGURE_X = 32.0


def read(path):
	return path.read_text(encoding="utf-8")


def write(path, text):
	path.write_text(text, encoding="utf-8", newline="\n")


def add_ext(text, entries):
	"""Insert ext_resources (type, path, id) after the last one already there."""
	lines = "".join('[ext_resource type="%s" path="%s" id="%s"]\n' % e for e in entries)
	last = [m.end() for m in re.finditer(r"^\[ext_resource [^\n]*\]\n", text, re.M)]
	at = last[-1] if last else text.index("\n\n") + 2
	return text[:at] + lines + text[at:]


def hide_meshes(text, keep):
	"""visible = false in every MeshInstance3D block whose parent does not match keep; returns (text, count)."""
	count = 0

	def sub(m):
		nonlocal count
		if keep(m.group(1)):
			return m.group(0)
		count += 1
		return m.group(0) + "\nvisible = false"
	return re.sub(r'^\[node name="[^"]+" type="MeshInstance3D" parent="([^"]*)"\]', sub, text, flags=re.M), count


def step_shells():
	path = LEVELS / "campus/shells.tscn"
	text = read(path)
	assert 'node name="Real"' not in text, "already patched"
	text, hidden = hide_meshes(text, lambda parent: parent.startswith("LibraryBand"))
	assert hidden == 164, hidden
	old = '[node name="WindowSilhouette2" type="Node3D" parent="."]\nposition = Vector3(31, -1.9, 53.8)\n'
	assert old in text
	text = text.replace(old, old.replace("Vector3(31,", "Vector3(%g," % FIGURE_X))
	text = add_ext(text, [("Script", SCRIPT, "t264_real")] + [("PackedScene", W7 + glb + ".glb", "t264_" + glb) for _, glb in SHELLS_REAL]
		+ [("PackedScene", W7 + "figure.glb", "t264_figure")])
	nodes = ['\n[node name="Real" type="Node3D" parent="."]\nscript = ExtResource("t264_real")\n']
	for name, glb in SHELLS_REAL:
		nodes.append('\n[node name="%s" parent="Real" instance=ExtResource("t264_%s")]\nposition = Vector3(0, %g, 0)\n' % (name, glb, G))
	for k in range(3):
		nodes.append('\n[node name="Figure" parent="WindowSilhouette%d" instance=ExtResource("t264_figure")]\n' % k)
	write(path, text.rstrip("\n") + "\n" + "".join(nodes))
	print("patched shells.tscn: %d PS1 meshes hidden, Real with %d buildings, 3 figures, WindowSilhouette2 at x %g" % (hidden, len(SHELLS_REAL), FIGURE_X))


def step_building_b():
	path = LEVELS / "campus/building_b.tscn"
	text = read(path)
	assert 'node name="Real"' not in text, "already patched"
	text, hidden = hide_meshes(text, lambda parent: not re.fullmatch(r"Upper(Floor[56]|Window[56]_\d+)", parent))
	assert hidden == 24, hidden
	text = add_ext(text, [("Script", SCRIPT, "t264_real"), ("PackedScene", W7 + "b_outside.glb", "t264_b_outside")])
	nodes = '\n[node name="Real" type="Node3D" parent="."]\nscript = ExtResource("t264_real")\n\n[node name="Outside" parent="Real" instance=ExtResource("t264_b_outside")]\nposition = Vector3(0, %g, 0)\n' % G
	write(path, text.rstrip("\n") + "\n" + nodes)
	print("patched building_b.tscn: %d PS1 meshes hidden, Real/Outside" % hidden)


def step_backdrop():
	path = LEVELS / "floor4/garden_backdrop.tscn"
	text = read(path)
	assert 'node name="BuildingA"' not in text, "already patched"
	text = add_ext(text, [("PackedScene", W7 + "bldga_light.glb", "t264_bldga_light")])
	node = '\n[node name="BuildingA" parent="." instance=ExtResource("t264_bldga_light")]\nposition = Vector3(0, %g, 0)\n' % G
	write(path, text.rstrip("\n") + "\n" + node)
	print("patched garden_backdrop.tscn: BuildingA (light)")


# ------------------------------------------------------------------------------------------------ round 3

def props_chunks(text):
	"""{chunk name: (parent, [floats])} of props.tscn's Parts and Decals."""
	out = {}
	for m in re.finditer(r'\[node name="([^"]+)" type="Node3D" parent="(Parts|Decals)"\]\n(.*?)(?=\n\[|\Z)', text, re.S):
		d = re.search(r"data = PackedFloat32Array\(([^)]*)\)", m.group(3))
		if d:
			out[m.group(1)] = (m.group(2), [float(t) for t in d.group(1).split(",")])
	return out


def step_data():
	"""w7_ps1_props.json: main's data of every props.tscn chunk with an instance in the rest of A16 or within 4 m of it
	(pieces of objects whose anchor is in the rest), read before props is patched."""
	sys.path.insert(0, str(Path(__file__).resolve().parent))
	import wave7_layout as L
	keep = {}
	for name, (parent, values) in props_chunks(read(LEVELS / "campus/props.tscn")).items():
		for k in range(0, len(values), 16):
			x, z = values[k + 9], values[k + 11]
			if any(L.region(x + dx, z + dz) == "rest" for dx in (-4, 0, 4) for dz in (-4, 0, 4)):
				keep[name] = {"parent": parent, "data": values}
				break
	(Path(__file__).resolve().parent / "w7_ps1_props.json").write_text(json.dumps(keep), encoding="utf-8", newline="\n")
	print("wrote w7_ps1_props.json", len(keep), "chunks")


def _layout():
	sys.path.insert(0, str(Path(__file__).resolve().parent))
	import rest_props as RP
	import wave7_layout as L
	return L, RP


def step_props():
	"""Every instance rest_props.py replaces scaled to 0 (its 9 basis numbers), nothing else; a chunk left with no
	instance at all is hidden too (none of them holds a corpse piece: the rest has none)."""
	L, RP = _layout()
	path = LEVELS / "campus/props.tscn"
	text = read(path)
	replaced, _objects = RP.classify(RP.load())
	by_chunk = {}
	for (name, k) in replaced:
		by_chunk.setdefault(name, []).append(k)
	zeroed = hidden = 0
	for name, idx in sorted(by_chunk.items()):
		m = re.search(r'(\[node name="%s" type="Node3D" parent="(?:Parts|Decals)"\]\n)(.*?)(?=\n\[|\Z)' % re.escape(name), text, re.S)
		block = m.group(2)
		d = re.search(r"data = PackedFloat32Array\(([^)]*)\)", block)
		tokens = d.group(1).split(",")
		for k in idx:
			assert any(float(tokens[k * 16 + c]) != 0.0 for c in range(9)), (name, k)
			for c in range(9):
				tokens[k * 16 + c] = "0"
			zeroed += 1
		new_block = block[:d.start(1)] + ",".join(tokens) + block[d.end(1):]
		if all(all(float(tokens[k + c]) == 0.0 for c in range(9)) for k in range(0, len(tokens), 16)):
			assert "visible = false" not in new_block
			new_block = "visible = false\n" + new_block
			hidden += 1
		text = text[:m.start(2)] + new_block + text[m.end(2):]
	assert zeroed == 365, zeroed
	write(path, text)
	print("patched props.tscn: %d instances scaled to 0 in %d chunks, %d chunks emptied and hidden" % (zeroed, len(by_chunk), hidden))


def covered_tiles():
	"""Ground/Tile_* whose whole 50 x 50 m the new ground covers (or a far building stands on): their meshes go."""
	L, _RP = _layout()
	text = read(LEVELS / "campus/campus.tscn")
	feet = [L.BUILDING_A, L.LECTURE, L.GYM]
	out = []
	for m in re.finditer(r'\[node name="(Tile_(-?\d+)_(-?\d+))" type="StaticBody3D" parent="Ground"\]', text):
		x0, z0 = int(m.group(2)), int(m.group(3))
		ok = True
		for i in range(51):
			for j in range(51):
				x, z = x0 + min(i, 49.9) if i else x0 + 0.05, z0 + min(j, 49.9) if j else z0 + 0.05
				if L.ground_kind(x, z) is None and not any(b["x"][0] <= x <= b["x"][1] and b["z"][0] <= z <= b["z"][1] for b in feet):
					ok = False
					break
			if not ok:
				break
		if ok:
			out.append(m.group(1))
	return out


def step_campus():
	L, _RP = _layout()
	path = LEVELS / "campus/campus.tscn"
	text = read(path)
	assert 'node name="StripRest"' not in text, "already patched"
	tiles = covered_tiles()
	hide = ["Ground/%s" % t for t in tiles] + ["Road/Avenue", "Road/EastBranch", "Road/StadiumEastAccess", "Fence/N", "Fence/E", "Fence/W"]
	count = 0
	for parent in hide:
		head = '[node name="Mesh" type="MeshInstance3D" parent="%s"]\n' % parent
		assert text.count(head) == 1, parent
		text = text.replace(head, head + "visible = false\n")
		count += 1
	for name in ["RoadBench0", "RoadBench1", "RoadBench2", "FallenMoped0", "FallenMoped1", "FallenMoped2"]:
		head = '[node name="%s" type="Node3D" parent="Road"]\n' % name
		assert text.count(head) == 1, name
		text = text.replace(head, head + "visible = false\n")
		count += 1
	text = add_ext(text, [("Script", "res://scenes/levels/campus/rest_real.gd", "t264_rest")] + [("PackedScene", W7 + g + ".glb", "t264_" + g)
		for g in ("ground", "fences", "rest_props")])
	nodes = ['\n[node name="StripRest" type="Node3D" parent="."]\nscript = ExtResource("t264_rest")\n']
	for name, glb in (("Ground", "ground"), ("Fences", "fences"), ("Props", "rest_props")):
		nodes.append('\n[node name="%s" parent="StripRest" instance=ExtResource("t264_%s")]\nposition = Vector3(0, %g, 0)\n' % (name, glb, G))
	write(path, text.rstrip("\n") + "\n" + "".join(nodes))
	print("patched campus.tscn: %d tiles' meshes, 3 roads, 3 fences, 3 benches and 3 mopeds hidden (%d), StripRest" % (len(tiles), count))


STEPS = {"shells": step_shells, "building_b": step_building_b, "backdrop": step_backdrop, "data": step_data, "props": step_props,
	"campus": step_campus}
ROUND3 = ["data", "props", "campus"]

if __name__ == "__main__":
	for step in (sys.argv[1:] or ROUND3):
		STEPS[step]()
