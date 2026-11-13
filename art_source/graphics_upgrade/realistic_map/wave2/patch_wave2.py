"""T-253 wave 2: hangs the wave-2 glbs under building_b.tscn's nodes and hides only the PS1 meshes they replace.
Idempotent; never touches a collider, transform, marker or name that is already there (wave 1's Scene helper).
Run: python -B art_source/graphics_upgrade/realistic_map/wave2/patch_wave2.py [a08] [a09] [a10] [a11]
"""
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave1"))
sys.path.insert(0, str(HERE))
from patch_scenes import Scene  # noqa: E402
import layout as L  # noqa: E402

ROOT = Path(__file__).resolve().parents[4]
BUILDING = ROOT / "game/scenes/levels/campus/building_b.tscn"
W2 = "res://assets/models/graphics_pilot/realistic_map/wave2/"
FONT = "res://assets/fonts/be_vietnam_pro_semibold.ttf"
WALL_DOOR = 'path="res://assets/models/kit/wall_door.glb" id="e9"'
# The room plate's digits (KitDetail<N>/Plate<i>/Number): black print on the aluminium, lit like it.
NUMBER = ('font = ExtResource("w2_font")\nfont_size = 64\npixel_size = 0.0016\noutline_size = 0\n'
	'modulate = Color(0.06, 0.06, 0.065, 1)\nshaded = true\ndouble_sided = false\nalpha_cut = 1\n'
	'texture_filter = 3\nposition = Vector3(0, 0.11, -0.009)\n')


def block(scene, name, parent):
	found = scene.header(name, parent)
	if found is None:
		raise SystemExit("missing node %s/%s" % (parent, name))
	end = scene.text.find("\n[", found.end())
	return found, (end if end >= 0 else len(scene.text))


def set_props(scene, name, parent, props, keep=("text",)):
	"""Replaces a node's property lines, keeping those whose key is in `keep`."""
	found, end = block(scene, name, parent)
	lines = scene.text[found.end():end].split("\n")
	kept = [line for line in lines if line and line.split(" = ")[0] in keep]
	scene.text = scene.text[:found.end()] + "".join(line + "\n" for line in kept) + props + scene.text[end:]


def common(scene):
	scene.ext(W2 + "room_door_leaf_right.glb", "w2_leaf_r")
	scene.ext(W2 + "room_door_leaf_left.glb", "w2_leaf_l")
	scene.ext(W2 + "room_plate.glb", "w2_plate")
	scene.ext(FONT, "w2_font", "FontFile")
	# Every lower-floor doorway's PS1 surround (the wall_door kit, only used by KitDetail<N>/Frame<i>) becomes the
	# wave-2 door surround: same nodes, same transforms.
	if WALL_DOOR in scene.text:
		scene.text = scene.text.replace(WALL_DOOR, 'path="%sdoor_surround.glb" id="e9"' % W2)


def kit_detail(scene, floor):
	kit = "KitDetail%d" % floor
	for i in range(L.BAYS):
		scene.hide("RailingTop%d" % i, kit)
		scene.hide("Tube%d" % i, kit)
		for j in range(11):
			scene.hide("Railing%d_%d" % (i, j), kit)
		plate = "%s/Plate%d" % (kit, i)
		scene.hide("Mesh", plate)
		if "w2_font" not in block_text(scene, "Number", plate):
			set_props(scene, "Number", plate, NUMBER)
		scene.instance("Model", plate, "w2_plate")


def block_text(scene, name, parent):
	found, end = block(scene, name, parent)
	return scene.text[found.end():end]


def room_doors(scene, floor):
	for i in range(L.BAYS):
		if not L.has_room_door(floor, i):
			continue
		leaf = "Floor%d/Door%d/Hinge/Leaf" % (floor, i)
		scene.hide("Mesh", leaf)
		scene.instance("LeafRight", leaf, "w2_leaf_r", "position = Vector3(0.85, -1.19, 0)\n")
		scene.instance("LeafLeft", leaf, "w2_leaf_l", "position = Vector3(-0.85, -1.19, 0)\n")


def room_interiors(scene, floor):
	for body, room in re.findall(r'^\[node name="([^"]+)" type="StaticBody3D" parent="Floor%d/(RoomInterior_\d+)"\]' % floor,
			scene.text, re.M):
		scene.hide("Mesh", "Floor%d/%s/%s" % (floor, room, body))


def hall(scene, floor):
	scene.ext(W2 + "floor%d_hall.glb" % floor, "w2_hall%d" % floor)
	scene.ext(W2 + "floor%d_rooms.glb" % floor, "w2_rooms%d" % floor)
	scene.instance("W2Hall", "Floor%d" % floor, "w2_hall%d" % floor)
	scene.instance("W2Rooms", "Floor%d" % floor, "w2_rooms%d" % floor)
	kit_detail(scene, floor)
	room_doors(scene, floor)
	room_interiors(scene, floor)


def a08(scene):
	"""Floor 3: corridor, doors, plates, lamps, balustrade, the rooms behind the doors."""
	common(scene)
	hall(scene, 3)


def main():
	jobs = {"a08": a08}
	scene = Scene(BUILDING)
	for name in sys.argv[1:] or list(jobs):
		jobs[name](scene)
		print("T253_PATCH", name)
	scene.save()


if __name__ == "__main__":
	main()
