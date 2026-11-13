"""T-256 (D-170) part C: the fire door's corridor-side lever no longer runs into the railing's handrail when the door
stands open (integrator's measurement 13/11: the outer lever 2 cm into the handrail at 1.05 m), and the plain green
box over the door becomes an exit light box (unlit). FireDoor-local metres, as wave 1's build_fire_door.py:
  fire_door_handle_compact.glb  FireDoor/Leaf/Handle  wave 1's levers with the corridor-side one (local -Z face) on a
                                short neck: its bar 31 mm off the leaf (wave 1: 56 mm), so open it stays 3 mm short of
                                the handrail and 2 cm short of the balusters. Same origin (the spindle), same node.
  exit_sign.glb                 FireDoor/ExitSign  a light box "LỐI THOÁT" over the door, its face on the corridor side,
                                enclosing wave 1's sign box (left in its frame, hidden inside this one); EndCover, a
                                plastered pier over the PS1 strip at the corridor's east end by the railing
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/floor4_rest/build_fire_door_rest.py
"""
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave1"))
import w1kit as kit  # noqa: E402
from mathutils import Vector  # noqa: E402

OUT = kit.ROOT / "game/assets/models/graphics_pilot/realistic_map/floor4_rest"
T = 0.045  # leaf thickness (wave 1)
HEAD = 2.40  # wave 1 HEAD: the sign box sat at HEAD + 0.18 .. + 0.32, z -0.14 .. -0.08, x -0.2 .. 0.2


def G(x, y, z):
	return Vector((x, -z, y))


def handle():
	"""Wave 1's lever handles (pointing to the hinge side, origin at the spindle); the corridor face's on a short neck."""
	part = kit.Part("Handle")
	for face in (-1, 1):
		zf = face * (T / 2 + 0.005)
		part.cylinder("W1Steel", tuple(G(0, 0, zf + face * 0.006)), 0.026, 0.012, axis="Y", segments=20)
		if face < 0:
			part.cylinder("W1Steel", tuple(G(0, 0, zf + face * 0.016)), 0.011, 0.012, axis="Y", segments=12)
			part.tube("W1Steel", [G(0, 0, zf + face * 0.022), G(-0.03, 0, zf + face * 0.026), G(-0.12, -0.006, zf + face * 0.026),
				G(-0.14, -0.012, zf + face * 0.02)], 0.0085, 10)
		else:
			part.cylinder("W1Steel", tuple(G(0, 0, zf + face * 0.028)), 0.011, 0.034, axis="Y", segments=12)
			part.tube("W1Steel", [G(0, 0, zf + face * 0.045), G(-0.03, 0, zf + face * 0.05), G(-0.12, -0.006, zf + face * 0.05),
				G(-0.14, -0.012, zf + face * 0.042)], 0.0095, 10)
	return part.build()


def exit_sign():
	"""A light box: an aluminium body, a green diffuser face carrying the sign (exit_sign.png), unlit."""
	part = kit.Part("ExitSign")
	x0, x1, y0, y1, z0, z1 = -0.215, 0.215, HEAD + 0.165, HEAD + 0.335, -0.152, -0.075
	part.box("W1Alu", tuple(G(x0, y0, z0 + 0.006)), tuple(G(x1, y1, z1)), bevel=0.006)
	face = part.poly("CDExitFace", [G(x0 + 0.012, y0 + 0.012, z0), G(x1 - 0.012, y0 + 0.012, z0), G(x1 - 0.012, y1 - 0.012, z0),
		G(x0 + 0.012, y1 - 0.012, z0)], [(0, 1, 2, 3)], recalc=False)[0]
	face.normal_update()
	if face.normal.dot(G(0, 0, -1)) < 0:
		face.normal_flip()
	# The face looks to the corridor (FireDoor local -Z): seen from there, its left is local +X.
	part.planar_uv([face], G(x1 - 0.012, y0 + 0.012, z0), G(-1, 0, 0), G(0, 1, 0), size=(x1 - x0 - 0.024, y1 - y0 - 0.024))
	# Two screws holding it to the plastered panel.
	for x in (x0 + 0.03, x1 - 0.03):
		part.cylinder("W1Steel", tuple(G(x, y1 - 0.02, z0 + 0.003)), 0.004, 0.004, axis="Y", segments=8)
	return part.build()


def end_cover():
	"""Thấy thêm 1: the fire stairwell's PS1 front box (FireStairs/FrontRail) and wave 1's old-wall top show as a
	chequered strip at the corridor's east end by the railing, from the door frame's head to the ceiling. A plastered
	pier in the corridor's colour covers it: world x 43.84..44.06, z 3.95..4.18, y 2.38..3.05 (FireDoor local:
	x = 2 - z, z = x - 44)."""
	part = kit.Part("EndCover")
	part.box("CVWall", tuple(G(-2.18, 2.38, -0.16)), tuple(G(-1.95, 3.05, 0.06)), bevel=0.004)
	return part.build(uv_size={"CVWall": 2.0})


def main():
	kit.reset()
	kit.material("W1Steel", (0.6, 0.6, 0.58), 0.38, 1.0)
	kit.material("W1Alu", (0.8, 0.8, 0.78), 0.35, 1.0)
	kit.material("CDExitFace", (0.1, 0.45, 0.2), 0.4)
	OUT.mkdir(parents=True, exist_ok=True)
	obj = handle()
	kit.export(OUT / "fire_door_handle_compact.glb", [obj])
	obj.select_set(False)
	kit.material("CVWall", (0.8, 0.76, 0.64), 0.85)
	kit.export(OUT / "exit_sign.glb", [exit_sign(), end_cover()])


main()
