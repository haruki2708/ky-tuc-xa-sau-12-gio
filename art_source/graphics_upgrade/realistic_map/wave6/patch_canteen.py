"""T-263: scene patches for wave 6 (canteen, kitchen, store, the A16 strip round the canteen). Steps run in the order given:
  python -B art_source/graphics_upgrade/realistic_map/wave6/patch_canteen.py heads                     (round 1, step 0)
  python -B art_source/graphics_upgrade/realistic_map/wave6/patch_canteen.py data canteen exit campus props   (round 2)

- heads (round 1, step 0; HARU allowed it, card T-263 section 2.0): T-259 hid props.tscn Parts/P_paper_box_p0_p0 whole
  (wave3/garden_layout.py A16_HIDE "all"), and with it the heads of six static corpses in the garden (instances #1-3 and
  #10-12, the skin-tinted 0.22 m boxes). The node is shown again and only its seven other instances, the ones T-259
  replaced (#0 a rice tray, #4-9 the notice board's six sheets), are scaled to 0, entries kept. wave3/build_garden.py no
  longer lays a paper card where those heads are (strip_props.glb rebuilt).
Round 2 (D-181), on main's canteen.tscn, canteen_west_exit.tscn, campus.tscn and the branch's props.tscn (main plus step
0, which touched no chunk in this wave's box):
- data: w6_ps1_props.json, main's data of every props.tscn chunk with a piece this wave replaces (canteen_layout.
  replaced_kind: papers, sandals, a backpack, trays in the A16 box); build_canteen.py's strip_props lays the new ones there.
- canteen: every PS1 MeshInstance3D and Label3D hidden (visible = false; colliders, nodes, transforms, metas, lights
  unchanged; the words of SignText, SloganText, PriceText0..4 and ReturnSign live on in the new boards' textures). New
  node Real (canteen_real.gd) with the picked glbs; the TV's lit screen (tv_screen.glb) hangs under TV/Screen as Lit,
  so campus.gd's set_canteen_tv still turns it on and off.
- exit: canteen_west_exit.tscn's five meshes hidden (the walls', the lintel's, the jambs'); colliders and navigation kept.
- campus: new node StripCanteen (canteen_real.gd) with strip_canteen.glb and strip_canteen_props.glb.
- props: the replaced pieces scaled to 0 (entries kept).
"""
from pathlib import Path
import json
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import canteen_layout as L  # noqa: E402

ROOT = HERE.parents[3]
LEVELS = ROOT / "game/scenes/levels/campus"
EXIT = ROOT / "game/scenes/levels/ch4/canteen_west_exit.tscn"
W6 = "res://assets/models/graphics_pilot/realistic_map/wave6/"
SCRIPT = "res://scenes/levels/campus/canteen_real.gd"
PS1 = HERE / "w6_ps1_props.json"
SKIN = (0.9, 0.7, 0.6)
HEAD_CHUNK = "P_paper_box_p0_p0"
# Real's children (node name, glb): the owner's picks (D-181) and round 2's pieces.
REAL = [("HallShell", "hall_shell"), ("Windows", "windows"), ("Ceiling", "ceiling_panels"), ("LightsFans", "lights_fans"),
	("Tables", "tables_inox"), ("Tableware", "tableware_mess"), ("Counter", "counter_inox"), ("PriceBoards", "price_boards"),
	("TV", "tv"), ("KitchenRoom", "kitchen_room"), ("Stove", "kitchen_k1"), ("Clock", "clock"), ("Facade", "facade"),
	("HallEast", "hall_east"), ("Store", "store"), ("Outside", "outside"), ("Bikes", "bikes")]
STRIP = [("Ground", "strip_canteen"), ("Props", "strip_canteen_props")]


def read(path):
	return path.read_text(encoding="utf-8")


def write(path, text):
	path.write_text(text, encoding="utf-8", newline="\n")


def node_block(text, name, parent):
	head = '[node name="%s" type="Node3D" parent="%s"]' % (name, parent)
	start = text.index(head)
	end = text.find("\n[", start + len(head))
	return start, (len(text) if end < 0 else end + 1)


def add_ext(text, entries):
	"""Insert ext_resources (type, path, id) after the last one already there."""
	lines = "".join('[ext_resource type="%s" path="%s" id="%s"]\n' % e for e in entries)
	last = [m.end() for m in re.finditer(r"^\[ext_resource [^\n]*\]\n", text, re.M)]
	at = last[-1] if last else text.index("\n\n") + 2
	return text[:at] + lines + text[at:]


def hide_types(text, types):
	"""visible = false in every node block of the given types; returns (text, count)."""
	count = 0

	def sub(m):
		nonlocal count
		count += 1
		return m.group(0) + "\nvisible = false"
	pattern = r'^\[node name="[^"]+" type="(?:%s)" parent="[^"]*"\]' % "|".join(types)
	return re.sub(pattern, sub, text, flags=re.M), count


def step_heads():
	path = LEVELS / "props.tscn"
	text = read(path)
	start, end = node_block(text, HEAD_CHUNK, "Parts")
	block = text[start:end]
	assert "\nvisible = false" in block, "already shown"
	block = block.replace("\nvisible = false", "", 1)
	m = re.search(r"data = PackedFloat32Array\(([^)]*)\)", block)
	values = m.group(1).split(",")
	assert len(values) == 13 * 16, len(values)
	heads = zeroed = 0
	for k in range(0, len(values), 16):
		if tuple(round(float(v), 3) for v in values[k + 12:k + 15]) == SKIN:
			heads += 1
			continue
		for c in range(9):
			values[k + c] = "0"
		zeroed += 1
	assert heads == 6 and zeroed == 7, (heads, zeroed)
	block = block[:m.start(1)] + ",".join(values) + block[m.end(1):]
	write(path, text[:start] + block + text[end:])
	print("patched props.tscn: %s shown, %d heads back, %d replaced instances scaled to 0" % (HEAD_CHUNK, heads, zeroed))


def props_chunks(text):
	"""{chunk name: (parent, [floats])} of props.tscn's Parts and Decals."""
	out = {}
	for m in re.finditer(r'\[node name="([^"]+)" type="Node3D" parent="(Parts|Decals)"\]\n(.*?)(?=\n\[|\Z)', text, re.S):
		d = re.search(r"data = PackedFloat32Array\(([^)]*)\)", m.group(3))
		if d:
			out[m.group(1)] = (m.group(2), [float(t) for t in d.group(1).split(",")])
	return out


def step_data():
	keep = {}
	for name, (parent, values) in props_chunks(read(LEVELS / "props.tscn")).items():
		if any(L.replaced_kind(name, values[k:k + 16]) for k in range(0, len(values), 16)):
			keep[name] = {"parent": parent, "data": values}
	PS1.write_text(json.dumps(keep), encoding="utf-8", newline="\n")
	print("wrote", PS1.name, len(keep), "chunks")


def step_canteen():
	path = LEVELS / "canteen.tscn"
	text = read(path)
	assert 'node name="Real"' not in text, "already patched"
	text, hidden = hide_types(text, ["MeshInstance3D", "Label3D"])
	text = add_ext(text, [("Script", SCRIPT, "t263_real")] + [("PackedScene", W6 + glb + ".glb", "t263_" + glb) for _, glb in REAL]
		+ [("PackedScene", W6 + "tv_screen.glb", "t263_tv_screen")])
	# TV/Screen's global position (TV + Screen's local one; no rotation): Lit cancels it so the glb sits at (0, G, 0).
	tv = re.search(r'\[node name="TV" type="Node3D" parent="\."\]\nposition = Vector3\(([^)]*)\)', text).group(1)
	sc = re.search(r'\[node name="Screen" type="Node3D" parent="TV"\]\nposition = Vector3\(([^)]*)\)', text).group(1)
	at = [float(a) + float(b) for a, b in zip(tv.split(","), sc.split(","))]
	lit = (-at[0], L.G - at[1], -at[2])
	nodes = ['\n[node name="Real" type="Node3D" parent="."]\nscript = ExtResource("t263_real")\n']
	for name, glb in REAL:
		nodes.append('\n[node name="%s" parent="Real" instance=ExtResource("t263_%s")]\nposition = Vector3(0, %g, 0)\n' % (name, glb, L.G))
	nodes.append('\n[node name="Lit" parent="TV/Screen" instance=ExtResource("t263_tv_screen")]\nposition = Vector3(%s)\n'
		% ", ".join("%g" % round(v, 4) for v in lit))
	text = text.rstrip("\n") + "\n" + "".join(nodes)
	write(path, text)
	print("patched canteen.tscn: %d PS1 meshes and labels hidden, Real with %d layers, TV/Screen/Lit at %s" % (hidden, len(REAL), lit))


def step_exit():
	text = read(EXIT)
	text, hidden = hide_types(text, ["MeshInstance3D"])
	assert hidden == 5, hidden
	write(EXIT, text)
	print("patched canteen_west_exit.tscn: %d meshes hidden" % hidden)


def step_campus():
	path = LEVELS / "campus.tscn"
	text = read(path)
	assert 'node name="StripCanteen"' not in text, "already patched"
	text = add_ext(text, [("Script", SCRIPT, "t263_real")] + [("PackedScene", W6 + glb + ".glb", "t263_" + glb) for _, glb in STRIP])
	nodes = ['\n[node name="StripCanteen" type="Node3D" parent="."]\nscript = ExtResource("t263_real")\n']
	for name, glb in STRIP:
		nodes.append('\n[node name="%s" parent="StripCanteen" instance=ExtResource("t263_%s")]\nposition = Vector3(0, %g, 0)\n' % (name, glb, L.G))
	write(path, text.rstrip("\n") + "\n" + "".join(nodes))
	print("patched campus.tscn: StripCanteen")


def step_props():
	path = LEVELS / "props.tscn"
	text = read(path)
	hidden = 0
	for name, entry in json.loads(PS1.read_text(encoding="utf-8")).items():
		start, end = node_block(text, name, entry["parent"])
		block = text[start:end]
		m = re.search(r"data = PackedFloat32Array\(([^)]*)\)", block)
		values = m.group(1).split(",")
		floats = [float(v) for v in values]
		assert floats == entry["data"], name + " differs from main's"
		for k in range(0, len(floats), 16):
			if L.replaced_kind(name, floats[k:k + 16]):
				for c in range(9):
					values[k + c] = "0"
				hidden += 1
		block = block[:m.start(1)] + ",".join(values) + block[m.end(1):]
		text = text[:start] + block + text[end:]
	write(path, text)
	print("patched props.tscn: %d PS1 instances scaled to 0" % hidden)


if __name__ == "__main__":
	steps = {"heads": step_heads, "data": step_data, "canteen": step_canteen, "exit": step_exit, "campus": step_campus, "props": step_props}
	for key in sys.argv[1:]:
		steps[key]()
