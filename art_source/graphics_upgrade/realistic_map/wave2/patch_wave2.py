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
	scene.ext(W2 + "room_door_leaf.glb", "w2_leaf")
	scene.ext(W2 + "door_surround.glb", "w2_surround")
	scene.ext(W2 + "room_plate.glb", "w2_plate")
	scene.ext(FONT, "w2_font", "FontFile")


def hide_kit_mesh(scene, frame):
	"""The wall_door kit under a Frame keeps its collision (WorldCollision: the 0.9 x 2.1 m doorway); only its mesh
	node (the instance's child wall_door) hides, by an override of that child (an editable instance)."""
	if scene.header("wall_door", frame) is None:
		scene.text = scene.text.rstrip(NL) + NL + NL + '[node name="wall_door" parent="%s" index="0"]' % frame + NL + "visible = false" + NL
	EDITABLE.add(frame)


EDITABLE = set()
NL = "\n"
EDITABLE_LINE = re.compile(r'^\[editable path="([^"]+)"\]\n', re.M)


def finish_editable(scene):
	"""[editable] entries go last in a .tscn: drop them and append every one again."""
	found = set(EDITABLE_LINE.findall(scene.text))
	scene.text = EDITABLE_LINE.sub("", scene.text).rstrip(NL) + NL
	paths = sorted(found | EDITABLE)
	if paths:
		scene.text += NL + "".join('[editable path="%s"]' % p + NL for p in paths)


def kit_detail(scene, floor):
	kit = "KitDetail%d" % floor
	for i in range(L.BAYS):
		scene.hide("RailingTop%d" % i, kit)
		scene.hide("Tube%d" % i, kit)
		for j in range(11):
			scene.hide("Railing%d_%d" % (i, j), kit)
		frame = "%s/Frame%d" % (kit, i)
		hide_kit_mesh(scene, frame)
		scene.instance("Surround", frame, "w2_surround")
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
		door = "Floor%d/Door%d" % (floor, i)
		# The visual pivot moves onto the doorway's edge (as floor 4's doors); Blocker and collision stay.
		set_props(scene, "Hinge", door, "position = Vector3(%g, 0.01, 0)\n" % L.HINGE_X, keep=("metadata/t190",))
		leaf = door + "/Hinge/Leaf"
		scene.hide("Mesh", leaf)
		scene.instance("Model", leaf, "w2_leaf", "position = Vector3(0.85, -1.19, 0)\n")


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


P407 = "res://assets/models/graphics_pilot/"
# Room 203 (A09): room 407's furniture (its light, baked versions) inside the PS1 bed and desk colliders
# (Room203BedBody 1.1 x 1.7 x 2 at (12.1, -5.75, -4.6), Room203DeskBody 1.5 x 0.8 x 0.7 at (15.2, -6.2, -5.8)),
# placed as room 407 places them (data/room407/placements.json); small things outside the room's nav areas.
ROOM203 = [  # name, model, position, yaw
	("BunkFrame", "room407_batch2/bunk_frame.glb", (12.1, -6.6, -4.6), 0),
	("MattressLow", "room407_furnished/bunk_mattress.glb", (12.1, -6.22, -4.6), 0),
	("MattressHigh", "room407_furnished/bunk_mattress.glb", (12.1, -5.45, -4.6), 0),
	("PillowLow", "room407_batch2/pillow.glb", (12.1, -6.17, -3.93), 4),
	("PillowHigh", "room407_batch2/pillow.glb", (12.1, -5.4, -3.93), -6),
	("BlanketLow", "room407_batch2/blanket_messy.glb", (12.1, -6.17, -4.85), 180),
	("BlanketHigh", "room407_batch2/blanket_folded.glb", (12.1, -5.4, -5.28), 3),
	("Desk", "room407_batch2/desk.glb", (15.2, -6.6, -5.8), 180),
	("Books", "room407_batch2/books.glb", (15.55, -5.84, -5.95), 12),
	("Notebook", "room407_batch2/notebook.glb", (14.9, -5.84, -5.75), -20),
	("Stool", "room407_batch1/stool.glb", (15.05, -6.6, -5.05), 15),
	("Bucket", "room407_batch1/bucket.glb", (12.35, -6.6, -7.05), 0),
	("Slippers", "room407_batch1/slippers.glb", (12.85, -6.6, -3.1), 70),
]


def a09(scene):
	"""Floor 2: as floor 3; room 203 furnished with room 407's bed and desk, its double door folded back open."""
	common(scene)
	hall(scene, 2)
	scene.hide("Room203Bed", ".")
	scene.hide("Room203Desk", ".")
	scene.node("Room203Furnished", ".")
	for name, model, pos, yaw in ROOM203:
		ext_id = "w2_407_" + model.split("/")[-1][:-4]
		scene.ext(P407 + model, ext_id)
		scene.instance(name, "Room203Furnished", ext_id, "position = Vector3(%g, %g, %g)\nrotation_degrees = Vector3(0, %g, 0)\n" % (*pos, yaw))
	# 203 has no door node (it stays open, D-062): its leaf stands folded back flat against the inside of the wall.
	scene.instance("Room203Leaf", ".", "w2_leaf", "position = Vector3(14.2, -6.59, -0.088)\nrotation_degrees = Vector3(0, 180, 0)\n")


def a11(scene):
	"""The floor-2 extinguisher: FireExtinguisher keeps its node and place (its PS1 cone is drawn on no layer, so
	its children still show), the bottle under it, the bracket its own node on the wall; the PS1 handle hides.
	The floor-1 alarm is core's (Yêu cầu thay đổi): only its glb is built."""
	scene.ext(W2 + "extinguisher.glb", "w2_ext")
	scene.ext(W2 + "extinguisher_bracket.glb", "w2_ext_bracket")
	found, end = block(scene, "FireExtinguisher", ".")
	if "layers = 0" not in scene.text[found.end():end]:
		scene.text = scene.text[:found.end()] + "layers = 0\n" + scene.text[found.end():]
	scene.instance("Model", "FireExtinguisher", "w2_ext")
	scene.hide("ExtinguisherHandle", ".")
	scene.node("ExtinguisherBracket", ".", "Node3D", "position = Vector3(48.86, -5.8, 2.4)\n")
	scene.instance("Model", "ExtinguisherBracket", "w2_ext_bracket")


W1 = "res://assets/models/graphics_pilot/realistic_map/wave1/"
# Floor 1's spawn alcoves (bays 1, 4, 6): their doors were broken in; the leaf lies on the floor inside, clear of the
# alcove's nav strip (x +/- 0.65 of the door).
BROKEN = ((1.9, -0.017, -0.6), (-90, 8, 0))


def a10(scene):
	"""Floor 1: the corridor and lobby, the shut doors, the broken-in alcove doors, the manager's room (desk, knife,
	window and its steps), the main door (two glass leaves, the chain round the handles)."""
	common(scene)
	hall(scene, 1)
	for i in L.F1_SHUT:
		door = "Floor1/Door%d" % i
		scene.hide("Mesh", door)
		scene.instance("Model", door, "w2_leaf", "position = Vector3(%g, -1.19, 0)\n" % L.HINGE_X)
	scene.node("F1BrokenDoors", ".")
	(ox, oy, oz), rot = BROKEN
	for i in L.F1_ALCOVES:
		scene.instance("Door%dLeaf" % i, "F1BrokenDoors", "w2_leaf",
			"position = Vector3(%g, %g, %g)\nrotation_degrees = Vector3(%g, %g, %g)\n" % (L.door_x(i) + ox, L.G + oy, oz, *rot))
	# Room 101's leaf stands open, folded back against the inside of its wall (clear of ManagerRoom's nav).
	scene.instance("ManagerDoorLeaf", ".", "w2_leaf", "position = Vector3(%g, -9.89, -0.088)\nrotation_degrees = Vector3(0, 180, 0)\n" % (L.door_x(0) + L.HINGE_X))
	# The manager's room: wave 1's desk (inside ManagerDeskBody, its sitter's side to the back wall), the knife.
	scene.ext(W1 + "duty_desk.glb", "w2_manager_desk")
	scene.hide("ManagerDesk", ".")
	scene.instance("ManagerDeskModel", ".", "w2_manager_desk", "position = Vector3(1.4, -9.9, -3.2)\nrotation_degrees = Vector3(0, 180, 0)\n")
	scene.ext(W2 + "knife.glb", "w2_knife")
	scene.hide("Blade", "Knife")
	scene.hide("Grip", "Knife")
	scene.instance("Model", "Knife", "w2_knife")
	scene.ext(W2 + "manager_window.glb", "w2_window")
	scene.ext(W2 + "manager_room.glb", "w2_manager_room")
	for ramp in ("WindowApproach", "WindowExit"):
		for k in range(7):
			scene.hide("Tread%02d" % k, ramp)
	scene.hide("Mesh", "WindowBridge")
	for k in range(9):
		scene.hide("GlassShard%d" % k, ".")
	scene.instance("W2ManagerWindow", ".", "w2_window")
	scene.instance("W2ManagerRoom", ".", "w2_manager_room")
	# The lobby room (bay 3): wave 1's notice board on its back wall and on its west wall.
	scene.ext(W1 + "notice_board.glb", "w2_notice_board")
	scene.node("W2Lobby", ".")
	scene.instance("NoticeBack", "W2Lobby", "w2_notice_board", "position = Vector3(19.25, -8.35, -7.494)\n")
	scene.instance("NoticeWest", "W2Lobby", "w2_notice_board", "position = Vector3(16.583, -8.35, -4.2)\nrotation_degrees = Vector3(0, 90, 0)\n")
	# The main door: the frame and piers, the glass leaves (LeafB swung by door.gd), the chain round the handles.
	for name in ("frame", "leaf", "leaf_b", "chain"):
		scene.ext(W2 + "main_door_%s.glb" % name, "w2_main_" + name)
	scene.hide("Mesh", "MainDoor/Leaf")
	scene.instance("Frame", "MainDoor", "w2_main_frame")
	scene.instance("Model", "MainDoor/Leaf", "w2_main_leaf")
	scene.node("LeafB", "MainDoor", "Node3D", "position = Vector3(1.5, 1.2, 0)\n")
	scene.instance("Model", "MainDoor/LeafB", "w2_main_leaf_b")
	for name in ["Chain-30", "Chain30"] + ["ChainLink%d" % k for k in range(14)]:
		scene.hide(name, "MainDoor/Chains")
	scene.instance("Model", "MainDoor/Chains", "w2_main_chain")


def main():
	jobs = {"a08": a08, "a09": a09, "a10": a10, "a11": a11}
	scene = Scene(BUILDING)
	for name in sys.argv[1:] or list(jobs):
		jobs[name](scene)
		print("T253_PATCH", name)
	finish_editable(scene)
	scene.save()


if __name__ == "__main__":
	main()
