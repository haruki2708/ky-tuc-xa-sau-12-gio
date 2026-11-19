"""T-265 round 2 (D-185): scene patches, on main's scenes (each step refuses to run twice).
  python -B art_source/graphics_upgrade/realistic_map/wave8/patch_wave8.py library shells campus

- library: library.tscn's 667 PS1 meshes hidden (visible = false; colliders, nodes, transforms, metas, lights, navigation
  unchanged; the iron bar is an instance of iron_bar.tscn and keeps its own model). New node Real (library_real.gd) at
  (-45, 0, -195), so its children's origin is the world's (0, G, 0) as the glbs': the shells, stairs and railing, the
  counter, the librarian's chair, the map, the tables, the stacks and books of each floor, the loose pieces and the mess,
  the doors, the barricade, the facade. Real/Added: one StaticBody3D (layer 1, a box) per added piece over 0.3 m
  (wave8_layout.FINAL) and the two railings along the well's west edge (wave8_layout.RAILS): the only new colliders.
  BackDoor/Hinge/LeafReal: the new leaf, under Hinge so room_door.gd swings it.
- shells: Shells/LibraryBand0..2's meshes hidden.
- campus: node StripLibrary (library_real.gd) with strip.glb: the ground in wave 8's box (x 39..91, z 189..231) less the
  floor, its edges on wave 7's.
props.tscn is not touched: the box holds no corpse piece; its two rubble piles and their colliders stay, as do the
scraps of paper by them.
"""
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import wave8_layout as L  # noqa: E402

ROOT = HERE.parents[3]
LIBRARY = ROOT / "game/scenes/levels/library/library.tscn"
LEVELS = ROOT / "game/scenes/levels/campus"
W8 = "res://assets/models/graphics_pilot/realistic_map/wave8/"
SCRIPT = "res://scenes/levels/library/library_real.gd"
REAL = [("Shell_F1", "shell_f1"), ("Shell_F2", "shell_f2"), ("Shell_F3", "shell_f3"), ("Stairs", "stairs"), ("Counter", "counter_q1"),
	("LibrarianChair", "librarian_chair"), ("Map", "map_print"), ("Tables", "tables"), ("Shelves_F1", "shelves_f1"),
	("Shelves_F2", "shelves_f2"), ("Shelves_F3N", "shelves_f3n"), ("Shelves_F3S", "shelves_f3s"), ("Fill_F1", "fill_f1"),
	("Fill_F2", "fill_f2"), ("Fill_F3", "fill_f3"), ("BackFrame", "back_frame"), ("FrontDoor", "front_door"),
	("Barricade", "barricade"), ("Facade", "facade")]
ORIGIN = L.ORIGIN


def read(path):
	return path.read_text(encoding="utf-8")


def write(path, text):
	path.write_text(text, encoding="utf-8", newline="\n")


def add_ext(text, entries):
	lines = "".join('[ext_resource type="%s" path="%s" id="%s"]\n' % e for e in entries)
	last = [m.end() for m in re.finditer(r"^\[ext_resource [^\n]*\]\n", text, re.M)]
	at = last[-1] if last else text.index("\n\n") + 2
	return text[:at] + lines + text[at:]


def add_sub(text, blocks):
	"""Insert sub_resources before the first node."""
	at = text.index("\n[node ")
	return text[:at] + "\n" + "\n".join(blocks) + text[at:]


def hide_meshes(text):
	count = 0

	def sub(m):
		nonlocal count
		count += 1
		return m.group(0) + "\nvisible = false"
	return re.sub(r'^\[node name="[^"]+" type="MeshInstance3D" parent="[^"]*"\]', sub, text, flags=re.M), count


def fmt(v):
	return "%g" % round(v, 4)


def added_bodies():
	"""(name, centre in Real's frame, size) of every added collider."""
	out = []
	for piece in L.FINAL + L.RAILS:
		if piece["height"] <= 0.3:
			continue
		x0, x1, z0, z1 = piece["box"]
		y = L.LEVELS[piece["level"]] - L.G
		out.append((piece["name"], ((x0 + x1) / 2, y + piece["height"] / 2, (z0 + z1) / 2), (x1 - x0, piece["height"], z1 - z0)))
	return out


def step_library():
	text = read(LIBRARY)
	assert 'node name="Real"' not in text, "already patched"
	text, hidden = hide_meshes(text)
	assert hidden == 667, hidden
	text = add_ext(text, [("Script", SCRIPT, "t265_real")] + [("PackedScene", W8 + glb + ".glb", "t265_" + glb) for _, glb in REAL]
		+ [("PackedScene", W8 + "back_leaf.glb", "t265_back_leaf")])
	bodies = added_bodies()
	subs = ['[sub_resource type="BoxShape3D" id="t265_box%d"]\nsize = Vector3(%s, %s, %s)\n' % (k, fmt(s[0]), fmt(s[1]), fmt(s[2]))
		for k, (_, _, s) in enumerate(bodies)]
	text = add_sub(text, subs)
	nodes = ['\n[node name="Real" type="Node3D" parent="."]\nposition = Vector3(%s, 0, %s)\nscript = ExtResource("t265_real")\n'
		% (fmt(-ORIGIN[0]), fmt(-ORIGIN[2]))]
	for name, glb in REAL:
		nodes.append('\n[node name="%s" parent="Real" instance=ExtResource("t265_%s")]\n' % (name, glb))
	nodes.append('\n[node name="Added" type="Node3D" parent="Real"]\n')
	for k, (name, c, _) in enumerate(bodies):
		nodes.append('\n[node name="%s" type="StaticBody3D" parent="Real/Added"]\nposition = Vector3(%s, %s, %s)\ncollision_layer = 1\n'
			'collision_mask = 0\n\n[node name="Collision" type="CollisionShape3D" parent="Real/Added/%s"]\nshape = SubResource("t265_box%d")\n'
			% (name, fmt(c[0]), fmt(c[1]), fmt(c[2]), name, k))
	nodes.append('\n[node name="LeafReal" parent="BackDoor/Hinge" instance=ExtResource("t265_back_leaf")]\n')
	write(LIBRARY, text.rstrip("\n") + "\n" + "".join(nodes))
	print("patched library.tscn: %d PS1 meshes hidden, Real with %d layers, %d added colliders, BackDoor/Hinge/LeafReal" % (hidden, len(REAL), len(bodies)))


def step_shells():
	path = LEVELS / "shells.tscn"
	text = read(path)
	count = 0
	for k in range(3):
		head = '[node name="Mesh" type="MeshInstance3D" parent="LibraryBand%d"]' % k
		assert text.count(head) == 1, head
		block_end = text.index("\n", text.index(head) + len(head))
		assert not text[block_end:block_end + 17].startswith("\nvisible = false"), "already hidden"
		text = text.replace(head, head + "\nvisible = false", 1)
		count += 1
	write(path, text)
	print("patched shells.tscn: %d library bands hidden" % count)


def step_campus():
	path = LEVELS / "campus.tscn"
	text = read(path)
	assert 'node name="StripLibrary"' not in text, "already patched"
	text = add_ext(text, [("Script", SCRIPT, "t265_real"), ("PackedScene", W8 + "strip.glb", "t265_strip")])
	nodes = '\n[node name="StripLibrary" type="Node3D" parent="."]\nscript = ExtResource("t265_real")\n' \
		'\n[node name="Ground" parent="StripLibrary" instance=ExtResource("t265_strip")]\nposition = Vector3(0, %s, 0)\n' % fmt(L.G)
	write(path, text.rstrip("\n") + "\n" + nodes)
	print("patched campus.tscn: StripLibrary")


if __name__ == "__main__":
	steps = {"library": step_library, "shells": step_shells, "campus": step_campus}
	for key in sys.argv[1:]:
		steps[key]()
