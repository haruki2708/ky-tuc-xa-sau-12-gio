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


STEPS = {"shells": step_shells, "building_b": step_building_b, "backdrop": step_backdrop}

if __name__ == "__main__":
	for step in (sys.argv[1:] or list(STEPS)):
		STEPS[step]()
