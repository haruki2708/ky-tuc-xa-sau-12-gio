"""T-267 (D-188 point 8) A30: hang build_wave10_a30.py's meshes on room 407's small things, in the scenes the integrator
listed and nowhere else. Per mesh node only `mesh` changes and `surface_material_override/0` is added: the material the
scene gave the old box mesh (the PS1 surface shader on the same print), or, where the box had none (the shower
buttons), wave 10's plain plastic. The box meshes nothing uses any more go. In floor4.tscn one value changes:
Door407/Pivot/RulesPaper's z, from -0.025 to -0.063, onto the Tripo leaf's corridor face (its highest point under the
paper is z -0.0682: the paper's 8 mm box keeps 1.2 mm off it).
Run from the repository root (idempotent): python -B art_source/graphics_upgrade/realistic_map/wave10/patch_a30.py
"""
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
LEVELS = ROOT / "game/scenes/levels"
MESH = "res://assets/models/graphics_pilot/realistic_map/wave10/a30/"
PLASTIC = "res://assets/models/graphics_pilot/realistic_map/wave10/materials/A30Plastic.tres"
# scene -> {node path (the tscn's parent/name): mesh obj}
SCENES = {
	"ch1_models/dat_notebook.tscn": {"Cover": "notebook_cover", "Page": "notebook_pages",
		**{"Binding%d" % k: "notebook_ring" for k in range(7)}},
	"ch1v2/guitar_songbook.tscn": {**{"ChordString%d" % k: "chordstring" for k in range(6)}, "ChordFret0": "chordnut",
		**{"ChordFret%d" % k: "chordfret" for k in range(1, 4)}},
	"room407/khoa_outlet.tscn": {"Recess": "outlet_back", "TopTrim": "outlet_rail", "BottomTrim": "outlet_rail",
		"LeftTrim": "outlet_stile", "RightTrim": "outlet_stile", "Cover": "outlet_face", "ContactLeft": "outlet_slot",
		"ContactRight": "outlet_slot", "ScrewTop": "outlet_screw"},
	"ch1v2/trash_bin.tscn": {"Waste%d" % k: "waste%d" % k for k in range(3)},
	"room407/room407_anchors.tscn": {"ShowerYes/Button": "shower_button", "ShowerNo/Button": "shower_button"},
}
RULES = ('[node name="RulesPaper" type="Node3D" parent="Door407/Pivot"]\nposition = Vector3(-0.44, 1.39, -0.025)\n',
	'[node name="RulesPaper" type="Node3D" parent="Door407/Pivot"]\nposition = Vector3(-0.44, 1.39, -0.063)\n')
SUB_MESH = re.compile(r'(?m)^mesh = SubResource\("([^"]+)"\)$')


def node_key(header):
	name = re.search(r'name="([^"]+)"', header).group(1)
	parent = re.search(r'parent="([^"]*)"', header)
	if parent is None:
		return ""
	return name if parent.group(1) == "." else parent.group(1) + "/" + name


def patch(path, nodes):
	text = path.read_text(encoding="utf-8")
	if "/wave10/a30/" in text:
		return "already"
	blocks = re.split(r"(?m)^(?=\[)", text)
	subs = {}
	for block in blocks:
		m = re.match(r'\[sub_resource [^\]]*id="([^"]+)"', block)
		if m:
			subs[m.group(1)] = block
	ext_lines = []
	ids = {}

	def ext(kind, res):
		if res not in ids:
			ids[res] = "t267_a30_%d" % (len(ids) + 1)
			ext_lines.append('[ext_resource type="%s" path="%s" id="%s"]\n' % (kind, res, ids[res]))
		return ids[res]

	done = set()
	for i, block in enumerate(blocks):
		if not block.startswith("[node "):
			continue
		key = node_key(block.split("\n", 1)[0])
		if key not in nodes:
			continue
		old = SUB_MESH.search(block)
		assert old, (path.name, key)
		material = re.search(r'(?m)^material = (SubResource\("[^"]+"\))$', subs[old.group(1)])
		override = material.group(1) if material else 'ExtResource("%s")' % ext("Material", PLASTIC)
		mesh = 'ExtResource("%s")' % ext("ArrayMesh", MESH + nodes[key] + ".obj")
		blocks[i] = SUB_MESH.sub("mesh = %s\nsurface_material_override/0 = %s" % (mesh, override), block)
		done.add(key)
	assert done == set(nodes), (path.name, set(nodes) - done)
	# The new ext_resources after the last one there is, one block each; the blank line that closed the list after them.
	last_ext = max(i for i, b in enumerate(blocks) if b.startswith("[ext_resource "))
	gap = blocks[last_ext][len(blocks[last_ext].rstrip("\n")) + 1:]
	blocks[last_ext] = blocks[last_ext].rstrip("\n") + "\n"
	ext_lines[-1] += gap
	blocks[last_ext + 1:last_ext + 1] = ext_lines
	text = "".join(blocks)
	# Drop sub-resources nothing refers to any more (the old box meshes), then ext_resources likewise.
	while True:
		blocks = re.split(r"(?m)^(?=\[)", text)
		body = "".join(blocks)
		dropped = False
		kept = []
		for block in blocks:
			m = re.match(r'\[(sub|ext)_resource [^\]]*id="([^"]+)"', block)
			if m and body.count('%sResource("%s")' % ("Sub" if m.group(1) == "sub" else "Ext", m.group(2))) == 0:
				dropped = True
				continue
			kept.append(block)
		text = "".join(kept)
		if not dropped:
			break
	path.write_text(text, encoding="utf-8", newline="\n")
	return "patched %d nodes" % len(done)


def main():
	for rel, nodes in SCENES.items():
		print("T267_A30_PATCH", rel, patch(LEVELS / rel, nodes))
	floor4 = LEVELS / "floor4/floor4.tscn"
	text = floor4.read_text(encoding="utf-8")
	if RULES[1] in text:
		print("T267_A30_PATCH floor4 already")
	else:
		assert text.count(RULES[0]) == 1
		floor4.write_text(text.replace(RULES[0], RULES[1]), encoding="utf-8", newline="\n")
		print("T267_A30_PATCH floor4 RulesPaper z -0.025 -> -0.063")


if __name__ == "__main__":
	main()
