"""T-253 (D-167) wave 2, A11: the floor-2 fire extinguisher (bottle apart from its wall bracket) and the floor-1 fire
alarm (its push button its own node), built in Blender (D-166: Blender first, no Tripo). Run with Blender 5.2.2:
  blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave2/build_fire_kit.py

Local frames (Godot metres, +X away from the fire stairs' east wall is -X here: the wall is at local x +0.137):
  extinguisher.glb          under BuildingB/FireExtinguisher (48.86, -5.8, 2.4): a 4 kg ABC powder bottle, label to
                            the landing (-X); objects Body (bottle, neck, valve, carry handle, gauge, pin, hose) and
                            Lever (origin on its pivot, to squeeze); empty Grip on the carry handle (T-247 row 7)
  extinguisher_bracket.glb  under BuildingB/ExtinguisherBracket (same place): the steel bracket screwed to the wall
                            (it stays when the bottle is lifted off) and the fire-orders board beside it
  fire_alarm.glb            for core's FireAlarm1F marker (0.9, -8.5, 0.12), facing +Z (the corridor): the red manual
                            call point, its face, object Button (origin on the button's face centre, presses along
                            -Z), the lamp and the conduit up to the ceiling; empty Press on the button (T-247 row 8)
"""
import math
import sys
from pathlib import Path

import bpy

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w2kit as K  # noqa: E402
from w2kit import G, gbox  # noqa: E402

WALL_X = 48.997 - 48.86  # the plaster of the fire stairs' east wall, local to the extinguisher node
R = 0.08  # bottle radius


def cylinder_uv(part, faces, y0, y1):
	"""Wrap UV1 round the bottle: u by angle (u 0.5 faces -X, the landing), v up the band."""
	for f in faces:
		us = []
		for loop in f.loops:
			co = loop.vert.co
			us.append((math.atan2(co.y, co.x) / math.tau) % 1.0)
		if max(us) - min(us) > 0.5:
			us = [u + 1.0 if u < 0.5 else u for u in us]
		for loop, u in zip(f.loops, us):
			loop[part.uv].uv = (u, (loop.vert.co.z - y0) / (y1 - y0))
	K.keep_uv(part, faces)


def empty(name, at):
	obj = bpy.data.objects.new(name, None)
	obj.location = G(*at)
	bpy.context.scene.collection.objects.link(obj)
	return obj


def extinguisher():
	body = K.Part("Body")
	# Bottle: a foot ring, the drawn steel can, a domed shoulder, the neck.
	prof = [(0.0, -0.252), (0.07, -0.252), (0.078, -0.246), (R, -0.24), (R, 0.13), (0.077, 0.165), (0.066, 0.192),
		(0.047, 0.208), (0.026, 0.215), (0.0, 0.216)]
	body.lathe("W2ExtRed", prof, segments=32)
	label = body.lathe("W2ExtLabel", [(R + 0.0008, -0.13), (R + 0.0008, 0.09)], segments=32, close_ends=False)
	cylinder_uv(body, label, -0.13, 0.09)
	body.lathe("W1Black", [(0.075, -0.252), (0.082, -0.252), (0.082, -0.228), (0.075, -0.228)], segments=32)
	# Neck and valve: brass collar, black valve body, a gauge on the landing side.
	body.cylinder("W1Brass", tuple(G(0, 0.228, 0)), 0.021, 0.03, axis="Z", segments=16)
	gbox(body, "W1Black", (-0.035, 0.243, -0.022), (0.03, 0.29, 0.022), bevel=0.006)
	body.cylinder("W1Steel", tuple(G(-0.045, 0.266, 0)), 0.017, 0.012, axis="X", segments=16)
	face = body.cylinder("W2Gauge", tuple(G(-0.052, 0.266, 0)), 0.0145, 0.002, axis="X", segments=16)
	for f in face:
		if f.normal.x < -0.5:
			K.planar_uv(body, [f], tuple(G(-0.053, 0.2515, -0.0145)), (0, -1, 0), (0, 0, 1), size=(0.029, 0.029))
	# The carry handle (fixed), level, towards the landing; the safety pin and its seal through the valve.
	gbox(body, "W1Steel", (-0.13, 0.282, -0.013), (-0.02, 0.29, 0.013), bevel=0.002)
	gbox(body, "W1Black", (-0.13, 0.276, -0.016), (-0.07, 0.296, 0.016), bevel=0.004)
	ring = [G(0.0 + 0.016 * math.cos(a), 0.31 + 0.016 * math.sin(a), 0.03) for a in [k / 12 * math.tau for k in range(13)]]
	body.tube("W1Steel", ring, 0.0018, 6, cap=False)
	body.tube("W1Steel", [G(0.0, 0.3, -0.03), G(0.0, 0.3, 0.03)], 0.0018, 6)
	gbox(body, "W1RedPlastic", (-0.004, 0.292, 0.026), (0.004, 0.302, 0.034))
	# Hose from the valve down the bottle's right side (+Z), its nozzle in a clip on the bottle.
	pts = [G(0.0, 0.255, 0.024), G(0.0, 0.25, 0.06), G(0.012, 0.18, 0.09), G(0.02, 0.0, 0.092), G(0.015, -0.12, 0.09)]
	body.tube("W1Black", pts, 0.0075, 8)
	body.cylinder("W1Black", tuple(G(0.015, -0.15, 0.09)), 0.011, 0.07, axis="Z", segments=10)
	body.tube("W1Steel", [G(0.04, -0.12, 0.074), G(0.0, -0.12, 0.098), G(-0.02, -0.12, 0.082)], 0.0025, 6, cap=False)
	lever = K.Part("Lever")
	# The squeeze lever over the carry handle, pivoting on the valve's back (+X).
	gbox(lever, "W1Steel", (-0.125, 0.3, -0.012), (0.03, 0.307, 0.012), bevel=0.002)
	gbox(lever, "W1Steel", (0.012, 0.29, -0.012), (0.03, 0.307, 0.012))
	objs = [K.build(body), K.build(lever, origin=tuple(G(0.025, 0.298, 0.0)))]
	objs.append(empty("Grip", (-0.085, 0.286, 0.0)))
	return objs


def bracket():
	part = K.Part("Bracket")
	x_wall = WALL_X
	# Back plate screwed to the wall, the strap round the bottle's back, the hook under the valve.
	gbox(part, "W1Iron", (x_wall - 0.004, -0.14, -0.03), (x_wall, 0.24, 0.03), bevel=0.002)
	strap = [G((R + 0.004) * math.cos(a), -0.05, (R + 0.004) * math.sin(a)) for a in [math.radians(d) for d in range(-75, 76, 15)]]
	part.tube("W1Iron", strap, 0.004, 6)
	for side in (-1, 1):
		gbox(part, "W1Iron", ((R + 0.004) * math.cos(math.radians(75)), -0.062, side * (R + 0.004) * math.sin(math.radians(75)) - 0.003),
			(x_wall - 0.004, -0.038, side * (R + 0.004) * math.sin(math.radians(75)) + 0.003))
	gbox(part, "W1Iron", (0.03, 0.17, -0.012), (x_wall - 0.004, 0.18, 0.012))
	gbox(part, "W1Iron", (0.026, 0.17, -0.012), (0.036, 0.24, 0.012))
	for sy in (-0.12, 0.22):
		part.cylinder("W1Steel", tuple(G(x_wall - 0.006, sy, 0.0)), 0.005, 0.004, axis="X", segments=8)
	# The fire-orders board (tiêu lệnh chữa cháy) on the wall beside it: aluminium frame, printed sheet.
	bz0, bz1, by0, by1 = 0.42, 0.9, -0.05, 0.62
	gbox(part, "W1Alu", (x_wall - 0.012, by0, bz0), (x_wall, by1, bz1), bevel=0.003)
	sheet = K.quad(part, "W2Orders", (x_wall - 0.0125, by0 + 0.02, bz1 - 0.02), (x_wall - 0.0125, by0 + 0.02, bz0 + 0.02),
		(x_wall - 0.0125, by1 - 0.02, bz0 + 0.02), (x_wall - 0.0125, by1 - 0.02, bz1 - 0.02), (-1, 0, 0))
	K.planar_uv(part, [sheet], tuple(G(x_wall - 0.0125, by0 + 0.02, bz0 + 0.02)), (0, -1, 0), (0, 0, 1),
		size=(bz1 - bz0 - 0.04, by1 - by0 - 0.04))
	return [K.build(part)]


def alarm():
	box = K.Part("Box")
	w, h = 0.1, 0.12
	gbox(box, "W2AlarmRed", (-w, -h, -0.036), (w, h, 0.012), bevel=0.008, segments=2)
	face = K.quad(box, "W2AlarmFace", (-w + 0.006, -h + 0.006, 0.0125), (w - 0.006, -h + 0.006, 0.0125),
		(w - 0.006, h - 0.006, 0.0125), (-w + 0.006, h - 0.006, 0.0125), (0, 0, 1))
	K.planar_uv(box, [face], tuple(G(-w + 0.006, -h + 0.006, 0.0125)), (1, 0, 0), (0, 0, 1), size=(2 * w - 0.012, 2 * h - 0.012))
	# The status lamp, the conduit and its box up to the ceiling (floor 1's ceiling 1.63 m over the marker).
	box.cylinder("W1RedPlastic", tuple(G(0.07, 0.095, 0.016)), 0.006, 0.008, axis="Y", segments=10)
	gbox(box, "W1Enamel", (-0.011, h, -0.036), (0.011, 1.625, -0.016))
	gbox(box, "W1Enamel", (-0.035, h - 0.005, -0.036), (0.035, h + 0.06, -0.006), bevel=0.004)
	button = K.Part("Button")
	# A round push button over the printed ring; origin on its face so pressing moves it along -Z.
	bz = 0.0125
	button.cylinder("W2AlarmButton", tuple(G(0.0, -0.008, bz + 0.0065)), 0.032, 0.013, axis="Y", segments=24)
	button.cylinder("W1Black", tuple(G(0.0, -0.008, bz + 0.0005)), 0.036, 0.001, axis="Y", segments=24)
	objs = [K.build(box), K.build(button, origin=tuple(G(0.0, -0.008, bz + 0.013)))]
	objs.append(empty("Press", (0.0, -0.008, bz + 0.013)))
	return objs


def main():
	K.materials()
	K.material("W2Orders", (0.9, 0.88, 0.82), 0.6)
	K.material("W1RedPlastic", (0.52, 0.05, 0.04), 0.45)
	for name, fn in (("extinguisher.glb", extinguisher), ("extinguisher_bracket.glb", bracket), ("fire_alarm.glb", alarm)):
		K.export(name, fn())
		K.reset()
		K.materials()
		K.material("W2Orders", (0.9, 0.88, 0.82), 0.6)
		K.material("W1RedPlastic", (0.52, 0.05, 0.04), 0.45)


main()
