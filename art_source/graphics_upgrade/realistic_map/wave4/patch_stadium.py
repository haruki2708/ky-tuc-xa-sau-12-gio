"""T-261 round 2 (D-178): hangs the realistic stadium and the garden-to-stadium strip into the scenes. Run once on main's
scenes (git checkout origin/main -- game/scenes/levels/campus/stadium.tscn game/scenes/levels/campus/props.tscn
game/scenes/levels/campus/campus.tscn), steps in this order:
  python -B art_source/graphics_upgrade/realistic_map/wave4/patch_stadium.py data stadium props campus

- data: w4_ps1_props.json, main's data of every props.tscn chunk this wave touches (the builders place the new pieces
  where these PS1 pieces were; run it on main's props.tscn).
- stadium.tscn: PS1 meshes hidden (visible = false: Grass, the stands' walls, gate posts, poles, the strips of the
  track and lines, goals, flood housings, every Stand_* batch); colliders, Floodlights and its lights untouched. New
  node Real (stadium_real.gd) with Field, Goals, MainStand, SouthStand, Poles/Pole0..3, Fences, Pillars, Props.
- props.tscn: the replaced instances scaled to 0 (entry kept): in the stadium hurdles, bags, backpacks, shoes, trays,
  crates, papers, sandals, phones (stadium_layout.PROP_KINDS); in the A16 box litter and the two rubble piles.
  D_paper_quad_p0_p0 is hidden whole (stadium_layout.HIDE_WHOLE).
- campus.tscn: Road/WestBranch/Mesh and Road/StadiumWestAccess/Mesh hidden; new node StripGardenStadium (garden_real.gd)
  with the strip's ground, road, kerbs (Ground) and its litter and rubble (Props).
"""
from pathlib import Path
import json
import math
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import stadium_layout as L  # noqa: E402

ROOT = HERE.parents[3]
LEVELS = ROOT / "game/scenes/levels/campus"
W4 = "res://assets/models/graphics_pilot/realistic_map/wave4/"


def read(path):
	return path.read_text(encoding="utf-8")


def write(path, text):
	path.write_text(text, encoding="utf-8", newline="\n")


def node_block(text, name, parent):
	head = '[node name="%s" type=' % name
	start = None
	for m in re.finditer(re.escape('[node name="%s"' % name), text):
		line = text[m.start():text.index("\n", m.start())]
		if ('parent="%s"' % parent) in line:
			start = m.start()
			break
	if start is None:
		raise SystemExit("no node %s under %s" % (name, parent))
	end = text.find("\n[", start + 1)
	return start, (len(text) if end < 0 else end)


def hide(text, name, parent):
	start, end = node_block(text, name, parent)
	block = text[start:end]
	if "\nvisible = false" in block:
		return text
	head_end = block.index("\n")
	block = block[:head_end] + "\nvisible = false" + block[head_end:]
	return text[:start] + block + text[end:]


def add_ext(text, entries):
	"""entries: [(type, path, id)] added after the last ext_resource."""
	last = text.rfind("[ext_resource")
	at = text.index("\n", last) + 1
	add = "".join('[ext_resource type="%s" path="%s" id="%s"]\n' % e for e in entries)
	return text[:at] + add + text[at:]


def props_chunks(text):
	"""{node name: (parent, [floats])} of every boxes.gd chunk in props.tscn."""
	out = {}
	for m in re.finditer(r'\[node name="([^"]+)" type="Node3D" parent="(Parts|Decals)"\]', text):
		end = text.find("\n[", m.end())
		block = text[m.end():end]
		d = re.search(r"data = PackedFloat32Array\(([^)]*)\)", block)
		if d:
			out[m.group(1)] = (m.group(2), [float(v) for v in d.group(1).split(",")])
	return out


def step_data():
	chunks = props_chunks(read(LEVELS / "props.tscn"))
	keep = {}
	for name, (parent, values) in chunks.items():
		for basis, origin, _ in L.instances(values):
			if L.prop_kind(name, basis, origin) or L.a16_kind(name, basis, origin):
				keep[name] = {"parent": parent, "data": values}
				break
	L.W4_PS1_PROPS.write_text(json.dumps(keep), encoding="utf-8", newline="\n")
	print("wrote", L.W4_PS1_PROPS.name, len(keep), "chunks")


def ps1_props():
	return json.loads(L.W4_PS1_PROPS.read_text(encoding="utf-8"))


def step_props():
	path = LEVELS / "props.tscn"
	text = read(path)
	hidden = 0
	for name, entry in ps1_props().items():
		parent = entry["parent"]
		if "%s/%s" % (parent, name) in L.HIDE_WHOLE:
			text = hide(text, name, parent)
			continue
		start, end = node_block(text, name, parent)
		block = text[start:end]
		m = re.search(r"data = PackedFloat32Array\(([^)]*)\)", block)
		values = m.group(1).split(",")
		for k, (basis, origin, _) in enumerate(L.instances([float(v) for v in values])):
			if L.prop_kind(name, basis, origin) or L.a16_kind(name, basis, origin):
				for c in range(9):
					values[k * 16 + c] = "0"
				hidden += 1
		block = block[:m.start(1)] + ",".join(values) + block[m.end(1):]
		text = text[:start] + block + text[end:]
	write(path, text)
	print("patched props.tscn:", hidden, "PS1 instances hidden")


STADIUM_HIDE_PREFIX = ("RunningSurface", "Lane", "StartLane", "PitchLine", "PitchEdge", "GoalPost", "GoalCross", "FloodHousing", "Stand_")


def step_stadium():
	path = LEVELS / "stadium.tscn"
	text = read(path)
	hidden = 0
	for m in list(re.finditer(r'\[node name="([^"]+)" type="[^"]+" parent="([^"]*)"\]', text)):
		name, parent = m.group(1), m.group(2)
		full = name if parent == "." else parent + "/" + name
		mesh = name == "Mesh" and (parent == "Grass" or parent.startswith(("MainBleachers/", "SecondaryBleachers/", "GatePost", "Pole", "Goal")))
		top = parent == "." and name.startswith(STADIUM_HIDE_PREFIX)
		if mesh or top:
			text = hide(text, name, parent)
			hidden += 1
	text = add_ext(text, [("Script", "res://scenes/levels/campus/stadium_real.gd", "t261_real"),
		("PackedScene", W4 + "field.glb", "t261_field"), ("PackedScene", W4 + "goal.glb", "t261_goal"),
		("PackedScene", W4 + "stand.glb", "t261_stand"), ("PackedScene", W4 + "stand_south.glb", "t261_south"),
		("PackedScene", W4 + "pole_steel.glb", "t261_pole"), ("PackedScene", W4 + "fence_b40.glb", "t261_fence"),
		("PackedScene", W4 + "gate_pillars.glb", "t261_pillars"), ("PackedScene", W4 + "stadium_props.glb", "t261_props")])
	g = "%g" % L.G
	nodes = ['\n[node name="Real" type="Node3D" parent="."]\nscript = ExtResource("t261_real")\n']
	for name, res in (("Field", "t261_field"), ("MainStand", "t261_stand"), ("SouthStand", "t261_south"), ("Fences", "t261_fence"),
			("Pillars", "t261_pillars"), ("Props", "t261_props")):
		nodes.append('\n[node name="%s" parent="Real" instance=ExtResource("%s")]\nposition = Vector3(0, %s, 0)\n' % (name, res, g))
	nodes.append('\n[node name="Goals" type="Node3D" parent="Real"]\n')
	for i, (x, z, face) in enumerate(L.GOALS):
		rot = "" if face > 0 else "transform = Transform3D(-1, 0, 0, 0, 1, 0, 0, 0, -1, %g, %s, %g)\n" % (x, g, z)
		pos = "position = Vector3(%g, %s, %g)\n" % (x, g, z) if face > 0 else ""
		nodes.append('\n[node name="Goal%d" parent="Real/Goals" instance=ExtResource("t261_goal")]\n%s%s' % (i, rot, pos))
	nodes.append('\n[node name="Poles" type="Node3D" parent="Real"]\n')
	for i, (x, z) in enumerate(L.POLES):
		# The lamps face the pitch centre: the glb's +x turned towards (198, 166). A .tscn Transform3D lists the basis
		# by rows (x.x, y.x, z.x, x.y, ...): with x = (cos, 0, -sin), z = (sin, 0, cos) that is (c, 0, s, 0, 1, 0, -s, 0, c).
		yaw = math.atan2(-(L.TRACK_CZ - z), 198.0 - x)
		c, s = math.cos(yaw), -math.sin(yaw)
		nodes.append('\n[node name="Pole%d" parent="Real/Poles" instance=ExtResource("t261_pole")]\n'
			'transform = Transform3D(%.6f, 0, %.6f, 0, 1, 0, %.6f, 0, %.6f, %g, %s, %g)\n' % (i, c, -s, s, c, x, g, z))
	text = text.rstrip("\n") + "\n" + "".join(nodes)
	write(path, text)
	print("patched stadium.tscn:", hidden, "PS1 nodes hidden")


def step_campus():
	path = LEVELS / "campus.tscn"
	text = read(path)
	for name in ("WestBranch", "StadiumWestAccess"):
		text = hide(text, "Mesh", "Road/" + name)
	text = add_ext(text, [("PackedScene", W4 + "strip_garden_stadium.glb", "t261_strip"),
		("PackedScene", W4 + "strip_stadium_props.glb", "t261_strip_props")])
	text = text.rstrip("\n") + "\n" + (
		'\n[node name="StripGardenStadium" type="Node3D" parent="."]\nscript = ExtResource("t259_real")\n'
		'\n[node name="Ground" parent="StripGardenStadium" instance=ExtResource("t261_strip")]\nposition = Vector3(0, %g, 0)\n'
		'\n[node name="Props" parent="StripGardenStadium" instance=ExtResource("t261_strip_props")]\nposition = Vector3(0, %g, 0)\n' % (L.G, L.G))
	write(path, text)
	print("patched campus.tscn")


if __name__ == "__main__":
	steps = {"data": step_data, "stadium": step_stadium, "props": step_props, "campus": step_campus}
	for key in sys.argv[1:]:
		steps[key]()
