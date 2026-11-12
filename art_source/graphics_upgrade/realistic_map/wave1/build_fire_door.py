"""T-250 (D-166) wave 1, A07: the fire-stair door at the east end of the floor-4 corridor, as a pair of painted steel
leaves in a steel frame (the opening is 3.8 m: the PS1 door was one 3.8 m slab). Run with Blender 5.2.2:
  blender -b --factory-startup -P <this file>

Frames (Godot): FireDoor (44, 0, 2) turned 90 degrees: its local +X runs to world -Z, local -Z faces the corridor.
  fire_door_frame.glb   FireDoor/Frame   jambs, head, the plastered panel up to the corridor ceiling, a threshold
  fire_door_leaf.glb    FireDoor/Leaf/Model  the active leaf on FireDoor/Leaf (hinge at local x -1.9, the PS1
                        leaf's pivot): 1.937 m wide, three hinges; origin = the hinge axis at Leaf's height (1.2 m)
  fire_door_lock.glb    FireDoor/Leaf/Lock   escutcheons and key cylinder on both faces; origin = the keyhole
  fire_door_handle.glb  FireDoor/Leaf/Handle lever handles on both faces; origin = the spindle (its local Z, through
                        the leaf, is the axis a hand turns it about)
  fire_door_leaf_b.glb  FireDoor/LeafB/Model the passive leaf (1.817 m, flush bolts), hinged 4 cm off the corridor
                        wall so it opens flat against it; door.gd swings LeafB the other way with Leaf
"""
import math
import sys
from pathlib import Path

from mathutils import Matrix, Vector

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w1kit as kit  # noqa: E402

T = 0.045  # leaf thickness
HEAD = 2.40  # PS1 leaf top (its box was 2.4 high from the floor)
CEIL = 3.02  # corridor ceiling
LEAF_Y = 1.2  # Leaf node height
LOCK_X = 1.937 - 0.065  # from the hinge
HANDLE_Y = 1.05 - LEAF_Y
KEY_Y = 0.978 - LEAF_Y


def G(x, y, z):
	return Vector((x, -z, y))


def leaf_panel(part, width, sign):
	"""A flush steel leaf from its hinge (x 0) along sign*x: folded edges, two pressed panels per face, a kick plate."""
	x0, x1 = sorted((sign * 0.004, sign * width))
	y0, y1 = 0.012 - LEAF_Y, HEAD - 0.012 - LEAF_Y
	part.box("W1DoorPaint", tuple(G(x0, y0, -T / 2)), tuple(G(x1, y1, T / 2)), bevel=0.004)
	for face in (-1, 1):
		zf = face * (T / 2)
		for py0, py1 in ((0.32, 1.12), (1.26, 2.22)):
			a, b = x0 + 0.13, x1 - 0.13
			# A pressed rectangle: a raised flat 3 mm proud with bevelled edges.
			part.box("W1DoorPaint", tuple(G(a, py0 - LEAF_Y, zf)), tuple(G(b, py1 - LEAF_Y, zf + face * 0.003)), bevel=0.0025)
		part.box("W1Steel", tuple(G(x0 + 0.03, 0.03 - LEAF_Y, zf)), tuple(G(x1 - 0.03, 0.24 - LEAF_Y, zf + face * 0.0015)), bevel=0.001)


def hinges(part, sign):
	for y in (0.25, 1.2, 2.12):
		c = G(0.0, y - LEAF_Y, -T / 2 - 0.006)
		part.cylinder("W1Steel", tuple(c), 0.011, 0.13, axis="Z", segments=12, matrix=Matrix.Rotation(-math.pi / 2, 4, "X") @ Matrix.Rotation(math.pi / 2, 4, "X"))
		part.box("W1Steel", tuple(G(0.0, y - LEAF_Y - 0.06, -T / 2 - 0.002)), tuple(G(sign * 0.045, y - LEAF_Y + 0.06, -T / 2)))


def leaf_a():
	part = kit.Part("Leaf")
	leaf_panel(part, 1.937, 1)
	hinges(part, 1)
	return [part.build(uv_size={"W1DoorPaint": 1.0})]


def leaf_b():
	part = kit.Part("LeafB")
	leaf_panel(part, 1.817, -1)
	hinges(part, -1)
	# Flush bolts at the meeting edge, top and bottom (the passive leaf has no lock of its own).
	for y in (0.12, 2.25):
		for face in (-1, 1):
			zf = face * (T / 2)
			part.box("W1Steel", tuple(G(-1.80, y - LEAF_Y - 0.08, zf)), tuple(G(-1.77, y - LEAF_Y + 0.08, zf + face * 0.004)), bevel=0.001)
	return [part.build(uv_size={"W1DoorPaint": 1.0})]


def lock():
	"""Mortise lock furniture: a long escutcheon on each face with the key cylinder (origin at the keyhole)."""
	part = kit.Part("Lock")
	for face in (-1, 1):
		zf = face * (T / 2)
		part.box("W1Steel", tuple(G(-0.022, -0.06, zf)), tuple(G(0.022, 0.19, zf + face * 0.005)), bevel=0.003, segments=2)
		cyl = part.cylinder("W1Brass", tuple(G(0, 0, zf + face * 0.008)), 0.0135, 0.007, axis="Y", segments=16)
		part.box("W1Black", tuple(G(-0.0016, -0.008, zf + face * 0.0115)), tuple(G(0.0016, 0.007, zf + face * 0.0122)))
		part.cylinder("W1Black", tuple(G(0, 0.004, zf + face * 0.0118)), 0.0032, 0.001, axis="Y", segments=10)
	return [part.build()]


def handle():
	"""Lever handles on both faces, pointing to the hinge side (origin at the spindle)."""
	part = kit.Part("Handle")
	for face in (-1, 1):
		zf = face * (T / 2 + 0.005)
		part.cylinder("W1Steel", tuple(G(0, 0, zf + face * 0.006)), 0.026, 0.012, axis="Y", segments=20)
		part.cylinder("W1Steel", tuple(G(0, 0, zf + face * 0.028)), 0.011, 0.034, axis="Y", segments=12)
		part.tube("W1Steel", [G(0, 0, zf + face * 0.045), G(-0.03, 0, zf + face * 0.05), G(-0.12, -0.006, zf + face * 0.05),
			G(-0.14, -0.012, zf + face * 0.042)], 0.0095, 10)
	return [part.build()]


def frame():
	part = kit.Part("Frame")
	depth = 0.10
	# Jambs at both sides of the 3.8 m opening and the head over the leaves; a plastered panel up to the ceiling.
	for x0, x1 in ((-1.95, -1.90), (1.90, 1.95)):
		part.box("W1DoorPaint", tuple(G(x0, 0.0, -depth / 2)), tuple(G(x1, HEAD + 0.05, depth / 2)), bevel=0.003)
		# The stop the leaves close against.
		part.box("W1DoorPaint", tuple(G(x0 + (0.05 if x0 < 0 else -0.015), 0.0, depth / 2 - 0.035)),
			tuple(G(x1 + (0.015 if x0 < 0 else -0.05), HEAD, depth / 2 - 0.02)))
	part.box("W1DoorPaint", tuple(G(-1.95, HEAD, -depth / 2)), tuple(G(1.95, HEAD + 0.05, depth / 2)), bevel=0.003)
	part.box("W1DoorPaint", tuple(G(-1.9, HEAD - 0.015, depth / 2 - 0.035)), tuple(G(1.9, HEAD, depth / 2 - 0.02)))
	panel = part.box("W1StairWall", tuple(G(-1.95, HEAD + 0.05, -0.08)), tuple(G(1.95, CEIL + 0.01, 0.08)))
	# A worn granite threshold strip, 8 mm proud.
	part.box("W1Granite", tuple(G(-1.9, -0.01, -0.07)), tuple(G(1.9, 0.008, 0.07)), bevel=0.003)
	# Exit sign box over the door (unlit: the stairwell's lights stay as they are).
	part.box("W1ExitSign", tuple(G(-0.2, HEAD + 0.18, -0.08 - 0.06)), tuple(G(0.2, HEAD + 0.32, -0.08)), bevel=0.004)
	return [part.build(uv_size={"W1StairWall": 2.0, "W1DoorPaint": 1.0})]


def main():
	kit.reset()
	kit.material("W1DoorPaint", (0.2, 0.32, 0.22), 0.55)
	kit.material("W1Steel", (0.6, 0.6, 0.58), 0.38, 1.0)
	kit.material("W1Brass", (0.78, 0.62, 0.32), 0.32, 1.0)
	kit.material("W1Black", (0.03, 0.03, 0.03), 0.6)
	kit.material("W1StairWall", (0.8, 0.76, 0.64), 0.85)
	kit.material("W1Granite", (0.3, 0.3, 0.3), 0.5)
	kit.material("W1ExitSign", (0.1, 0.4, 0.15), 0.4)
	for name, fn in (("fire_door_frame", frame), ("fire_door_leaf", leaf_a), ("fire_door_leaf_b", leaf_b),
			("fire_door_lock", lock), ("fire_door_handle", handle)):
		objs = fn()
		kit.export(kit.OUT / (name + ".glb"), objs)
		for obj in objs:
			obj.select_set(False)


main()
