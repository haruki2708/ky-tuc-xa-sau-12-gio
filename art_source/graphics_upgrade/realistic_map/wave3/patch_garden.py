"""T-259 round 2 (D-175): hangs the wave-3 garden into the scenes. Run once on main's scene files:
  git checkout origin/main -- game/scenes/levels/campus/garden.tscn game/scenes/levels/campus/props.tscn \
      game/scenes/levels/campus/campus.tscn game/scenes/levels/floor4/corridor.tscn
  python -B art_source/graphics_upgrade/realistic_map/wave3/patch_garden.py
- garden.tscn: PS1 meshes hidden (visible = false; nodes, colliders, anchors, lights unchanged), GardenLights_* get
  real_lamp (foliage.gd), new node Real (garden_real.gd) with the paving, beds, planting, 12 trees, 5 benches, the
  fallen bunk.
- props.tscn: the A16 PS1 litter, rubble and notice board this wave replaces (garden_layout.A16_HIDE): whole chunks
  hidden, or the instances lying in the strip scaled to 0 (entries kept).
- campus.tscn: new node StripBGarden (garden_real.gd) with the strip's lawn, curb, gutter and props.
- corridor.tscn (floor 4, chapters 1-2): YardTree_* and DistantStreetLamp's Fixture and Stem hidden (the light stays),
  GardenBackdrop added.
"""
from pathlib import Path
import json
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import garden_layout as L  # noqa: E402

ROOT = L.ROOT
LEVELS = ROOT / "game/scenes/levels"
W3 = "res://assets/models/graphics_pilot/realistic_map/wave3/"
MARK = "t259_"


def read(path):
	text = path.read_text(encoding="utf-8")
	if MARK in text:
		raise SystemExit("%s is already patched; check out main's copy first" % path.name)
	return text


def add_ext(text, entries):
	"""Inserts ext_resource lines after the last existing one."""
	lines = "".join('[ext_resource type="%s" path="%s" id="%s"]\n' % e for e in entries)
	last = list(re.finditer(r"^\[ext_resource [^\n]*\]\n", text, re.M))[-1]
	return text[:last.end()] + lines + text[last.end():]


def set_visible_false(text, name, parent):
	header = '[node name="%s" type=' % name
	pattern = re.compile(r'^\[node name="%s"[^\n]*parent="%s"[^\n]*\]\n' % (re.escape(name), re.escape(parent)), re.M)
	m = pattern.search(text)
	if m is None:
		raise SystemExit("node %s (parent %s) not found" % (name, parent))
	block_end = text.find("\n[", m.end())
	block = text[m.end():block_end if block_end >= 0 else len(text)]
	if "visible = false" in block:
		return text
	return text[:m.end()] + "visible = false\n" + text[m.end():]


def patch_garden():
	path = LEVELS / "campus/garden.tscn"
	text = read(path)
	ext = [("Script", "res://scenes/levels/campus/garden_real.gd", "t259_real"),
		("PackedScene", W3 + "paving_block.glb", "t259_paving"),
		("PackedScene", W3 + "garden_beds.glb", "t259_beds"),
		("PackedScene", W3 + "garden_planting.glb", "t259_planting"),
		("PackedScene", W3 + "bench_ngu.glb", "t259_bench_ngu"),
		("PackedScene", W3 + "bench_back.glb", "t259_bench_back"),
		("PackedScene", W3 + "fallen_bunk.glb", "t259_bunk"),
		("PackedScene", W3 + "garden_lamp.glb", "t259_lamp")]
	trees = L.trees()
	for glb in sorted({name for name, _ in trees.values()}):
		ext.append(("PackedScene", W3 + glb, "t259_" + glb[:-4]))
	text = add_ext(text, ext)
	# PS1 meshes: hidden, never removed (card section 4).
	hide = [("Mesh", "Paving"), ("Mesh", "NguBench"), ("BrokenBunk", ".")]
	for (i, j) in L.BEDS:
		hide += [("Mesh", "Bed%d_%d" % (i, j)), ("Soil", "Bed%d_%d" % (i, j)), ("LowTrunk%d_%d" % (i, j), "."),
			("LowCrown%d_%d" % (i, j), ".")]
		for k in range(4):
			hide.append(("Bush%d_%d_%d" % (i, j, k), "."))
			for m in range(3):
				hide.append(("Flower%d_%d_%d_%d" % (i, j, k, m), "."))
	hide += [("NguBenchLeg21.15", "."), ("NguBenchLeg22.85", ".")]
	hide += [("Bench%d" % b, ".") for b in range(4)]
	hide += [("DetachedRail%d" % r, ".") for r in range(4)]
	for name, parent in hide:
		text = set_visible_false(text, name, parent)
	for node in ("GardenLights_0_0", "GardenLights_0_1", "GardenLights_1_0", "GardenLights_1_1"):
		m = re.search(r'^\[node name="%s"[^\n]*\]\n' % node, text, re.M)
		# At the end of the node's block, after its script line: Godot drops a script property set before the script.
		end = text.find("\n[", m.end())
		text = text[:end].rstrip("\n") + '\nreal_lamp = ExtResource("t259_lamp")\n' + text[end:]
	nodes = ['\n[node name="Real" type="Node3D" parent="."]\nscript = ExtResource("t259_real")\n']
	for name, ext_id in (("Paving", "t259_paving"), ("Beds", "t259_beds"), ("Planting", "t259_planting")):
		nodes.append('\n[node name="%s" parent="Real" instance=ExtResource("%s")]\nposition = Vector3(0, %g, 0)\n' % (name, ext_id, L.PAVING_Y))
	nodes.append('\n[node name="Trees" type="Node3D" parent="Real"]\n')
	for (i, j), (glb, yaw) in sorted(trees.items()):
		x, z = L.BEDS[(i, j)]
		nodes.append('\n[node name="Tree%d_%d" parent="Real/Trees" instance=ExtResource("t259_%s")]\nposition = Vector3(%g, %g, %g)\n'
			'rotation_degrees = Vector3(0, %d, 0)\n' % (i, j, glb[:-4], x, L.PAVING_Y, z, yaw))
	nodes.append('\n[node name="Benches" type="Node3D" parent="Real"]\n')
	x, z = L.NGU_BENCH
	nodes.append('\n[node name="NguBench" parent="Real/Benches" instance=ExtResource("t259_bench_ngu")]\nposition = Vector3(%g, %g, %g)\n'
		% (x, L.PAVING_Y, z))
	for name, (x, z) in L.BENCHES.items():
		nodes.append('\n[node name="%s" parent="Real/Benches" instance=ExtResource("t259_bench_back")]\nposition = Vector3(%g, %g, %g)\n'
			% (name, x, L.PAVING_Y, z))
	nodes.append('\n[node name="FallenBunk" parent="Real" instance=ExtResource("t259_bunk")]\nposition = Vector3(0, %g, 0)\n' % L.PAVING_Y)
	text = text.rstrip("\n") + "\n" + "".join(nodes)
	path.write_text(text, encoding="utf-8", newline="\n")
	print("patched", path.name, len(hide), "PS1 nodes hidden")


def patch_props():
	path = LEVELS / "campus/props.tscn"
	text = read(path)
	# Main's data of every chunk touched, so the builders place the new pieces where the PS1 ones were.
	L.PS1_PROPS.write_text(json.dumps({node: L.props_data(text, node) for node in L.A16_HIDE}), encoding="utf-8", newline="\n")
	hidden = 0
	for node, mode in L.A16_HIDE.items():
		if mode == "all":
			parent = "Decals" if node.startswith("D_") else "Parts"
			text = set_visible_false(text, node, parent)
			hidden += len(L.props_instances(node))
			continue
		start = text.index('[node name="%s"' % node)
		end = text.index("\n[node", start + 1)
		block = text[start:end]
		m = re.search(r"data = PackedFloat32Array\(([^)]*)\)", block)
		values = m.group(1).split(",")
		for k in range(0, len(values), 16):
			origin = tuple(float(v) for v in values[k + 9:k + 12])
			if (L.in_rubble(origin) if mode == "rubble" else L.in_strip(origin)):
				for c in range(9):
					values[k + c] = "0"
				hidden += 1
		block = block[:m.start(1)] + ",".join(values) + block[m.end(1):]
		text = text[:start] + block + text[end:]
	path.write_text(text, encoding="utf-8", newline="\n")
	print("patched", path.name, hidden, "PS1 pieces hidden")


def patch_campus():
	path = LEVELS / "campus/campus.tscn"
	text = read(path)
	text = add_ext(text, [("Script", "res://scenes/levels/campus/garden_real.gd", "t259_real"),
		("PackedScene", W3 + "strip_b_garden.glb", "t259_strip"),
		("PackedScene", W3 + "strip_props.glb", "t259_strip_props")])
	text = text.rstrip("\n") + "\n" + (
		'\n[node name="StripBGarden" type="Node3D" parent="."]\nscript = ExtResource("t259_real")\n'
		'\n[node name="Lawn" parent="StripBGarden" instance=ExtResource("t259_strip")]\nposition = Vector3(0, %g, 0)\n'
		'\n[node name="Props" parent="StripBGarden" instance=ExtResource("t259_strip_props")]\nposition = Vector3(0, %g, 0)\n'
		% (L.PAVING_Y, L.PAVING_Y))
	path.write_text(text, encoding="utf-8", newline="\n")
	print("patched", path.name)


def patch_corridor():
	path = LEVELS / "floor4/corridor.tscn"
	text = read(path)
	text = add_ext(text, [("PackedScene", "res://scenes/levels/floor4/garden_backdrop.tscn", "t259_backdrop")])
	for k in range(4):
		text = set_visible_false(text, "YardTree_%d" % k, ".")
	for name in ("Fixture", "Stem"):
		text = set_visible_false(text, name, "DistantStreetLamp")
	text = text.rstrip("\n") + "\n" + '\n[node name="GardenBackdrop" parent="." instance=ExtResource("t259_backdrop")]\n'
	path.write_text(text, encoding="utf-8", newline="\n")
	print("patched", path.name)


if __name__ == "__main__":
	steps = {"garden": patch_garden, "props": patch_props, "campus": patch_campus, "corridor": patch_corridor}
	for key in (sys.argv[1:] or steps):
		steps[key]()
