"""T-262 round 2 (D-180): hangs the realistic gate, the whole south wall and the A16 gate strip into the scenes. Run once on
main's scenes (git checkout origin/main -- game/scenes/levels/campus/gate.tscn game/scenes/levels/campus/campus.tscn
game/scenes/levels/campus/props.tscn), steps in this order:
  python -B art_source/graphics_upgrade/realistic_map/wave5/patch_gate.py data gate campus props

- data: w5_ps1_props.json, main's data of every props.tscn chunk this wave touches (the builders place the new pieces
  where these PS1 pieces were; run it on main's props.tscn).
- gate.tscn: the PS1 meshes hidden (visible = false: Court, both pillars, the booth, the 21 bars, the two rails, the
  half-fallen sign and its 9 scars, the booth's window and roof, the 3 road cracks, the pillar crack); colliders, nodes
  and transforms unchanged. New node Real (gate_real.gd) with Court, Outside, Cracks, Pillars, Gate, Sign, Booth,
  Interior.
- campus.tscn: Fence/S/Mesh hidden (its collider kept), Road/Avenue/Mesh cut to x 0..180 (its BoxMesh 180 m long, the
  mesh 20 m west; the node Road/Avenue unchanged), new nodes WallSouth (wall_south.glb) and StripGate (strip_gate.glb,
  strip_gate_props.glb), both with gate_real.gd.
- props.tscn: the A16 pieces this wave replaces (list_a16_box.py kinds: cars, barriers, cones, papers, dropped bags,
  shoes, sandals, phones, the rubble pile) scaled to 0, entries kept; and the three corpse heads T-259/T-261 hid by
  mistake given back their main matrices (D-180: P_paper_box_p1_p0 #0, P_paper_box_p2_p2 #1, P_paper_box_p2_p4 #1).
"""
from pathlib import Path
import json
import math
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.append(str(HERE.parent / "wave4"))  # after wave5: wave4 has its own list_a16_box.py
import gate_layout as L  # noqa: E402
import list_a16_box as A16  # noqa: E402
import patch_stadium as PS  # noqa: E402  (scene text helpers: node_block, hide, add_ext)

ROOT = HERE.parents[3]
LEVELS = ROOT / "game/scenes/levels/campus"
W5 = "res://assets/models/graphics_pilot/realistic_map/wave5/"
PS1 = HERE / "w5_ps1_props.json"
REPLACED = ("car", "barrier", "cone", "paper", "dropped: backpack", "dropped: shoe", "dropped: sandal", "dropped: phone", "rubble")
GATE_HIDE = ["Court/Mesh", "Pillar209/Mesh", "Pillar231/Mesh", "Booth/Mesh", "HalfFallenSign", "BoothWindow", "BoothRoof", "PillarCrack",
	"GateCross0.5", "GateCross3.4"] + ["GateBar%d" % x for x in range(210, 231)] + ["SignScar%d" % i for i in range(9)] + \
	["RoadCrack212", "RoadCrack222", "RoadCrack233"]
HEAD_SOURCES = {"wave3": HERE.parent / "wave3" / "a16_ps1_props.json", "wave4": HERE.parent / "wave4" / "w4_ps1_props.json"}


def read(path):
	return path.read_text(encoding="utf-8")


def write(path, text):
	path.write_text(text, encoding="utf-8", newline="\n")


def replaced(name, values, k):
	c = values[k:k + 16]
	origin = tuple(c[9:12])
	scale = tuple(math.sqrt(sum(t * t for t in c[i:i + 3])) for i in (0, 3, 6))
	if max(scale) == 0 or not L.in_box(*origin):
		return None
	kind = A16.kind(name, origin, scale, c[12:15])
	return kind if kind in REPLACED else None


def step_data():
	chunks = PS.props_chunks(read(LEVELS / "props.tscn"))
	keep = {}
	for name, (parent, values) in chunks.items():
		if any(replaced(name, values, k) for k in range(0, len(values), 16)):
			keep[name] = {"parent": parent, "data": values}
	PS1.write_text(json.dumps(keep), encoding="utf-8", newline="\n")
	print("wrote", PS1.name, len(keep), "chunks")


def step_gate():
	path = LEVELS / "gate.tscn"
	text = read(path)
	for full in GATE_HIDE:
		parent, _, name = full.rpartition("/")
		text = PS.hide(text, name, parent or ".")
	text = PS.add_ext(text, [("Script", "res://scenes/levels/campus/gate_real.gd", "t262_real")] +
		[("PackedScene", W5 + glb + ".glb", "t262_" + key) for key, glb in (("court", "court"), ("outside", "outside"),
		("cracks", "court_cracks"), ("pillars", "pillars_plaster"), ("gate", "gate_swing"), ("sign", "sign_arch"),
		("booth", "booth_masonry"), ("interior", "booth_interior"))])
	nodes = ['\n[node name="Real" type="Node3D" parent="."]\nscript = ExtResource("t262_real")\n']
	for name, key in (("Court", "court"), ("Outside", "outside"), ("Cracks", "cracks"), ("Pillars", "pillars"), ("Gate", "gate"),
			("Sign", "sign"), ("Booth", "booth"), ("Interior", "interior")):
		nodes.append('\n[node name="%s" parent="Real" instance=ExtResource("t262_%s")]\nposition = Vector3(0, %g, 0)\n' % (name, key, L.G))
	text = text.rstrip("\n") + "\n" + "".join(nodes)
	write(path, text)
	print("patched gate.tscn:", len(GATE_HIDE), "PS1 nodes hidden")


def step_campus():
	path = LEVELS / "campus.tscn"
	text = read(path)
	text = PS.hide(text, "Mesh", "Fence/S")
	# Road/Avenue: one 220 m BoxMesh from x 0 to 220; its last 37 m are paved by the strip now. Cut the mesh to x 0..180.
	start, end = PS.node_block(text, "Mesh", "Road/Avenue")
	block = text[start:end]
	mesh_id = re.search(r'mesh = SubResource\("([^"]+)"\)', block).group(1)
	if "position" not in block:
		head_end = block.index("\n")
		block = block[:head_end] + "\nposition = Vector3(-20, 0, 0)" + block[head_end:]
		text = text[:start] + block + text[end:]
	m = re.search(r'(\[sub_resource type="BoxMesh" id="%s"\]\nsize = Vector3\()220(, 0\.03, 8\))' % re.escape(mesh_id), text)
	if m:
		text = text[:m.start()] + m.group(1) + "180" + m.group(2) + text[m.end():]
	if len(re.findall(r'mesh = SubResource\("%s"\)' % re.escape(mesh_id), text)) != 1:
		raise SystemExit("Road/Avenue's BoxMesh is shared")
	text = PS.add_ext(text, [("Script", "res://scenes/levels/campus/gate_real.gd", "t262_real"),
		("PackedScene", W5 + "wall_south.glb", "t262_wall"), ("PackedScene", W5 + "strip_gate.glb", "t262_strip"),
		("PackedScene", W5 + "strip_gate_props.glb", "t262_strip_props")])
	g = "%g" % L.G
	text = text.rstrip("\n") + "\n" + (
		'\n[node name="WallSouth" type="Node3D" parent="."]\nscript = ExtResource("t262_real")\n'
		'\n[node name="Wall" parent="WallSouth" instance=ExtResource("t262_wall")]\nposition = Vector3(0, %s, 0)\n'
		'\n[node name="StripGate" type="Node3D" parent="."]\nscript = ExtResource("t262_real")\n'
		'\n[node name="Ground" parent="StripGate" instance=ExtResource("t262_strip")]\nposition = Vector3(0, %s, 0)\n'
		'\n[node name="Props" parent="StripGate" instance=ExtResource("t262_strip_props")]\nposition = Vector3(0, %s, 0)\n' % (g, g, g))
	write(path, text)
	print("patched campus.tscn")


def step_props():
	path = LEVELS / "props.tscn"
	text = read(path)
	hidden = 0
	for name, entry in json.loads(PS1.read_text(encoding="utf-8")).items():
		start, end = PS.node_block(text, name, entry["parent"])
		block = text[start:end]
		m = re.search(r"data = PackedFloat32Array\(([^)]*)\)", block)
		values = m.group(1).split(",")
		floats = [float(v) for v in values]
		for k in range(0, len(floats), 16):
			if replaced(name, floats, k):
				for c in range(9):
					values[k + c] = "0"
				hidden += 1
		block = block[:m.start(1)] + ",".join(values) + block[m.end(1):]
		text = text[:start] + block + text[end:]
	restored = 0
	for name, index, wave in L.HEADS:
		source = json.loads(HEAD_SOURCES[wave].read_text(encoding="utf-8"))[name]
		main = source["data"] if isinstance(source, dict) else source
		start, end = PS.node_block(text, name, "Parts")
		block = text[start:end]
		m = re.search(r"data = PackedFloat32Array\(([^)]*)\)", block)
		values = m.group(1).split(",")
		k = index * 16
		assert tuple(round(float(v), 3) for v in values[k + 12:k + 15]) == L.SKIN, (name, index)
		assert all(float(v) == 0.0 for v in values[k:k + 9]), (name, index, "not hidden")
		for c in range(9):
			values[k + c] = "%g" % main[k + c]
		block = block[:m.start(1)] + ",".join(values) + block[m.end(1):]
		text = text[:start] + block + text[end:]
		restored += 1
	write(path, text)
	print("patched props.tscn:", hidden, "PS1 instances hidden,", restored, "heads given back")


if __name__ == "__main__":
	steps = {"data": step_data, "gate": step_gate, "campus": step_campus, "props": step_props}
	for key in sys.argv[1:]:
		steps[key]()
