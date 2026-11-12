"""T-250 wave 1: hangs the new glbs under building_b.tscn's nodes and hides only the PS1 meshes they replace.
Idempotent; never touches a collider, transform, marker or name that is already there.
Run: python -B art_source/graphics_upgrade/realistic_map/wave1/patch_scenes.py [a01] [a07] [a06]
"""
from pathlib import Path
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
BUILDING = ROOT / "game/scenes/levels/campus/building_b.tscn"
W1 = "res://assets/models/graphics_pilot/realistic_map/wave1/"


class Scene:
	def __init__(self, path):
		self.path = path
		self.text = path.read_text(encoding="utf-8")

	def save(self):
		self.path.write_text(self.text, encoding="utf-8", newline="\n")

	def ext(self, path, ext_id, kind="PackedScene"):
		if f'id="{ext_id}"' in self.text:
			return
		line = f'[ext_resource type="{kind}" path="{path}" id="{ext_id}"]\n'
		last = [m.end() for m in re.finditer(r"^\[ext_resource [^\n]*\]\n", self.text, re.M)][-1]
		self.text = self.text[:last] + line + self.text[last:]

	def header(self, name, parent):
		pattern = r'^\[node name="%s"[^\n]*parent="%s"[^\n]*\]\n' % (re.escape(name), re.escape(parent))
		return re.search(pattern, self.text, re.M)

	def hide(self, name, parent):
		found = self.header(name, parent)
		if found is None:
			raise SystemExit("missing node %s/%s" % (parent, name))
		end = self.text.find("\n[", found.end())
		block = self.text[found.end():end if end >= 0 else len(self.text)]
		if "visible = false" in block:
			return
		self.text = self.text[:found.end()] + "visible = false\n" + self.text[found.end():]

	def instance(self, name, parent, ext_id, props=""):
		if self.header(name, parent) is not None:
			return
		self.text = self.text.rstrip("\n") + f'\n\n[node name="{name}" parent="{parent}" instance=ExtResource("{ext_id}")]\n{props}'
		if not self.text.endswith("\n"):
			self.text += "\n"

	def node(self, name, parent, kind="Node3D", props=""):
		if self.header(name, parent) is not None:
			return
		self.text = self.text.rstrip("\n") + f'\n\n[node name="{name}" type="{kind}" parent="{parent}"]\n{props}'
		if not self.text.endswith("\n"):
			self.text += "\n"


DESK = ROOT / "game/scenes/levels/floor4/duty_desk.tscn"
DESK_MODELS = {  # ext id: (old path, new path)
	"e1": ("res://assets/models/props/desk.glb", W1 + "duty_desk.glb"),
	"e2": ("res://assets/models/props/desk_items.glb", W1 + "duty_desk_items.glb"),
	"e3": ("res://assets/models/props/telephone.glb", W1 + "desk_phone.glb"),
	"e4": ("res://assets/models/kit/plastic_stool.glb", "res://assets/models/graphics_pilot/room407_batch1/stool.glb"),
	"e5": ("res://assets/models/props/hall_board.glb", W1 + "notice_board.glb"),
	"e6": ("res://assets/models/props/pa_horn.glb", W1 + "pa_speaker.glb"),
	"e7": ("res://assets/models/props/desk_lamp.glb", "res://assets/models/graphics_pilot/room407_batch2/desk_lamp.glb"),
}
# Node transforms in the desk scene: the new models face +Z (the corridor) with no 180-degree turn.
DESK_PLACES = {
	("Model", "Desk"): "position = Vector3(0, -0.4, 0)\nrotation_degrees = Vector3(0, 0, 0)",
	("DeskItems", "."): "position = Vector3(2, 0.8, 0.42)\nrotation_degrees = Vector3(0, 0, 0)",
	("DeskTelephone", "."): "position = Vector3(2.4, 0.8, 0.43)\nrotation_degrees = Vector3(0, -8, 0)",
	("DutyStool", "."): "position = Vector3(3, 0, 0.5)\nrotation_degrees = Vector3(0, 15, 0)",
	# Back on the corridor wall (z 0.1), cork face 2 cm proud.
	("HallBoard", "."): "position = Vector3(0.5, 1.6, 0.1)\nrotation_degrees = Vector3(0, 0, 0)",
	("Speaker", "."): "position = Vector3(2, 2.55, 0.1)\nrotation_degrees = Vector3(0, 0, 0)",
	# Room 407's lamp, as room 407 hangs it under its light: base 0.26 m under and 0.12 m behind the bulb.
	("Fixture", "DutyDeskLamp"): "position = Vector3(0, -0.26, -0.12)\nrotation_degrees = Vector3(0, 180, 0)",
}


def desk_scene():
	"""duty_desk.tscn: the new models in place of the PS1 ones (same node names), the drawer script on the root."""
	scene = Scene(DESK)
	for ext_id, (old, new) in DESK_MODELS.items():
		scene.text = scene.text.replace(f'path="{old}" id="{ext_id}"', f'path="{new}" id="{ext_id}"')
	scene.ext("res://scenes/levels/floor4/duty_desk.gd", "w1_script", "Script")
	if 'script = ExtResource("w1_script")' not in scene.text:
		scene.text = scene.text.replace('[node name="DutyDesk" type="Node3D"]\n', '[node name="DutyDesk" type="Node3D"]\nscript = ExtResource("w1_script")\n')
	for (name, parent), props in DESK_PLACES.items():
		found = scene.header(name, parent)
		if found is None:
			raise SystemExit("missing desk node %s/%s" % (parent, name))
		end = scene.text.find("\n[", found.end())
		block = scene.text[found.end():end]
		kept = [line for line in block.split("\n") if line and not line.startswith(("position =", "rotation_degrees ="))]
		scene.text = scene.text[:found.end()] + props + "\n" + "".join(line + "\n" for line in kept) + scene.text[end:]
	scene.save()


def a01(scene):
	"""Wall clock over the duty desk (stopped at 4:00) and the fire key in the desk's drawer."""
	desk_scene()
	scene.ext(W1 + "wall_clock.glb", "w1_clock")
	scene.ext(W1 + "duty_key.glb", "w1_key")
	for child in ["Case", "Dial", "Minute", "Hour"] + ["Tick%d" % i for i in range(12)]:
		scene.hide(child, "DeskClock")
	# The clock's back on the corridor wall (z 0.1); DeskClock stays at its old centre.
	scene.instance("Model", "DeskClock", "w1_clock", "position = Vector3(0, 0, -0.078)\n")
	scene.hide("Mesh", "KeyStem")
	scene.hide("Mesh", "KeyTooth")
	# On the drawer bottom (y 0.650), a little turned; KeyStem keeps its place.
	scene.instance("Model", "KeyStem", "w1_key", "position = Vector3(0, -0.01, 0)\nrotation_degrees = Vector3(0, 12, 0)\n")


def stair_meshes(scene, side, flights):
	"""Hides a stairwell's PS1 treads, landing and turn slabs (their colliders stay) and hangs the new stairwell."""
	parent = "%sStairs" % side
	for k in (1, 2, 3, 4):
		scene.hide("Mesh", "%s/Landing%d" % (parent, k))
	for flight, count in flights:
		turn = flight[0]
		if scene.header("Turn%s" % turn, parent) is not None:
			path = "%s/Turn%s" % (parent, turn)
			scene.hide("Mesh", path)
		for i in range(count):
			scene.hide("Tread%02d" % i, "%s/%sStairsDown%s" % (parent, side, flight))
	scene.hide("Mesh", "%s/UpperRubble" % parent)


def count_treads(scene, side, flight):
	return len(re.findall(r'^\[node name="Tread\d\d" type="Node3D" parent="%sStairs/%sStairsDown%s"\]' % (side, side, flight),
		scene.text, re.M))


def a07(scene):
	"""Fire stairs, fire door (two leaves, lock and handle as their own nodes), collapse, crack."""
	scene.ext(W1 + "fire_stairs.glb", "w1_fire_stairs")
	for name in ("frame", "leaf", "leaf_b", "lock", "handle"):
		scene.ext(W1 + "fire_door_%s.glb" % name, "w1_door_" + name)
	flights = [(f, count_treads(scene, "Fire", f)) for f in ("4A", "4B", "3A", "3B")]
	stair_meshes(scene, "Fire", flights)
	scene.hide("Mesh", "FireStairs/Collapse")
	scene.instance("W1Stairs", "FireStairs", "w1_fire_stairs")
	scene.hide("FireRubbleDetail", ".")
	scene.hide("StairCrack", ".")
	for y in ("0", "-3.3", "-6.6"):
		scene.hide("Handrail_48.9_" + y, ".")
	# Door: the PS1 slab's mesh hides (its node and collision stay: test_campus reads Leaf/Mesh's position).
	scene.hide("Mesh", "FireDoor/Leaf")
	scene.instance("Frame", "FireDoor", "w1_door_frame")
	scene.instance("Model", "FireDoor/Leaf", "w1_door_leaf")
	scene.instance("Lock", "FireDoor/Leaf", "w1_door_lock", "position = Vector3(1.872, -0.222, 0)\n")
	scene.instance("Handle", "FireDoor/Leaf", "w1_door_handle", "position = Vector3(1.872, -0.15, 0)\n")
	scene.node("LeafB", "FireDoor", "Node3D", "position = Vector3(1.86, 1.2, 0)\n")
	scene.instance("Model", "FireDoor/LeafB", "w1_door_leaf_b")


def a06(scene):
	"""Main stairs: steps, landings, walls, rails, the blocked storey above floor 4."""
	scene.ext(W1 + "main_stairs.glb", "w1_main_stairs")
	flights = [(f, count_treads(scene, "Main", f)) for f in ("4A", "4B", "3A", "3B", "2A", "2B")]
	stair_meshes(scene, "Main", flights)
	scene.instance("W1Stairs", "MainStairs", "w1_main_stairs")
	scene.hide("UpperRubbleDetail", ".")
	for y in ("0", "-3.3", "-6.6"):
		scene.hide("Handrail_-4.9_" + y, ".")


def main():
	jobs = {"a01": a01, "a07": a07, "a06": a06}
	scene = Scene(BUILDING)
	for name in sys.argv[1:] or list(jobs):
		jobs[name](scene)
		print("T250_PATCH", name)
	scene.save()


if __name__ == "__main__":
	main()
