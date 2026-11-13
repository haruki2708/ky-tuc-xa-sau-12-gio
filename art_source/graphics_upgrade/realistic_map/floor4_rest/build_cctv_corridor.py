"""T-256 (D-170) part D: the CCTV corridor set (game/scenes/levels/cctv/cctv_set.tscn, node Corridor) as the real
floor-4 corridor, shortened to 405..407: plastered room wall and ceiling, the tiled floor and skirting, room 407's
green door frames, painted panel leaves (light: the feed is 320 x 240), aluminium number plates behind the old
Label3D numbers, a tube batten over the Tube light, and the open railing where the PS1 set had a wall (its collision
stays). Corridor-local metres: floor x 0..10, z 0..4, room wall face z 0, ceiling y 3.0; the doors where the set has
them (kit door.glb at Door40x: x d - 0.88 .. d, the 3.2 m pitch kept so the camera sees what it saw).
  cctv_corridor.glb   Set (walls, floor, ceiling, frames, leaves, plates, batten), Railing
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/floor4_rest/build_cctv_corridor.py
"""
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave2"))
sys.path.insert(0, str(HERE))
import w2kit as K  # noqa: E402
from w2kit import gbox  # noqa: E402
import build_washroom as W  # noqa: E402

OUT = W.OUT
PX, NX, PY, NY, PZ, NZ = W.PX, W.NX, W.PY, W.NY, W.PZ, W.NZ
DOORS = {"405": 1.5, "406": 4.7, "407": 7.9}  # Door40x origins: the kit leaf spans x d - 0.88 .. d
LENGTH, DEPTH, CEILING = 10.0, 4.0, 3.0
DOOR_H = 2.1
PREVIEW = {
	"CVWall": ((0.8, 0.76, 0.64), 0.85, 0.0), "CVCeiling": ((0.82, 0.8, 0.72), 0.9, 0.0),
	"CVFloor": ((0.6, 0.5, 0.42), 0.5, 0.0), "CVSkirting": ((0.6, 0.5, 0.42), 0.5, 0.0),
	"CVFrame": ((0.12, 0.3, 0.2), 0.6, 0.0), "CVLeaf": ((0.15, 0.35, 0.25), 0.6, 0.0),
	"CVRail": ((0.2, 0.32, 0.24), 0.5, 0.4), "CVTube": ((0.9, 0.95, 0.85), 0.25, 0.0),
}
SIZES = {"CVWall": 2.0, "CVCeiling": 2.0, "CVFloor": 1.0, "CVSkirting": 1.0, "CVFrame": 1.0, "CVLeaf": 1.2}
K.SIZES.update(SIZES)


def materials():
	W.materials()
	for name, (colour, rough, metal) in PREVIEW.items():
		K.material(name, colour, rough, metal)


def set_part():
	part = K.Part("Set")
	c = 0.003
	holes = [(d - 0.9, 0.0, d + 0.02, DOOR_H + 0.02) for d in DOORS.values()]
	W.plane(part, "CVWall", (0.0, 0.0, c), PX, PY, LENGTH, CEILING - c, holes)
	W.plane(part, "CVFloor", (0.0, 0.0, DEPTH), PX, NZ, LENGTH, DEPTH)
	W.plane(part, "CVCeiling", (0.0, CEILING - c, 0.0), PX, PZ, LENGTH, DEPTH + 0.15)
	for x, u in ((c, PZ), (LENGTH - c, NZ)):
		W.plane(part, "CVWall", (x, 0.0, 0.0) if u == PZ else (x, 0.0, DEPTH), u, PY, DEPTH, CEILING - c)
	# Tile skirting along the room wall between the doorways, and the slab's edge under the railing.
	edges = [0.0] + sorted(v for d in DOORS.values() for v in (d - 0.97, d + 0.09)) + [LENGTH]
	for a, b in zip(edges[0::2], edges[1::2]):
		gbox(part, "CVSkirting", (a, 0.0, c), (b, 0.1, c + 0.008))
	gbox(part, "CVSkirting", (0.0, -0.18, DEPTH - 0.02), (LENGTH, 0.0, DEPTH + 0.06))
	for number, d in DOORS.items():
		door(part, d)
		# Room 407's aluminium plate behind the set's Label3D number (x d + 0.44, y 2.3, z 0.02).
		gbox(part, "W1Alu", (d + 0.32, 2.23, c), (d + 0.56, 2.37, 0.016), bevel=0.004)
	# A tube batten over the Tube light (5, 2.8, 2): unlit glass glowing as the light shines.
	gbox(part, "W1Enamel", (4.38, CEILING - 0.05, 1.955), (5.62, CEILING, 2.045), bevel=0.008)
	part.cylinder("CVTube", K.G(5.0, CEILING - 0.062, 2.0), 0.013, 1.2, axis="X", segments=8)
	return W.build(part)


def door(part, d):
	"""Room 407's green frame round the doorway and a painted panel leaf, shut, with its lever."""
	x0, x1 = d - 0.9, d + 0.02
	for xa, xb in ((x0 - 0.07, x0), (x1, x1 + 0.07)):
		gbox(part, "CVFrame", (xa, 0.0, 0.0), (xb, DOOR_H + 0.09, 0.022), bevel=0.003)
	gbox(part, "CVFrame", (x0, DOOR_H + 0.02, 0.0), (x1, DOOR_H + 0.09, 0.022), bevel=0.003)
	for xa, xb in ((x0, x0 + 0.02), (x1 - 0.02, x1)):
		gbox(part, "CVFrame", (xa, 0.0, -0.2), (xb, DOOR_H + 0.02, 0.0))
	gbox(part, "CVLeaf", (x0 + 0.015, 0.01, -0.06), (x1 - 0.015, DOOR_H + 0.005, -0.02))
	# Raised panels: two tall, one low, as the room doors have.
	for (y0, y1) in ((0.12, 0.8), (0.95, 1.95)):
		for (a, b) in ((x0 + 0.1, d - 0.47), (d - 0.43, x1 - 0.1)):
			gbox(part, "CVLeaf", (a, y0, -0.02), (b, y1, -0.012), bevel=0.006)
	lever = (x0 + 0.1, 1.05)
	gbox(part, "W1Steel", (lever[0] - 0.02, lever[1] - 0.06, -0.02), (lever[0] + 0.02, lever[1] + 0.06, -0.012))
	W.gtube(part, "W1Steel", [(lever[0], lever[1] + 0.02, -0.012), (lever[0], lever[1] + 0.02, 0.03), (lever[0] + 0.11, lever[1] + 0.02, 0.035)],
		0.008, 8)


def railing():
	part = K.Part("Railing")
	z = DEPTH - 0.01
	posts = [0.03, 2.0, 4.0, 6.0, 8.0, LENGTH - 0.03]
	for x in posts:
		gbox(part, "CVRail", (x - 0.025, 0.0, z - 0.025), (x + 0.025, 1.08, z + 0.025))
	W.gtube(part, "CVRail", [(0.0, 1.07, z), (LENGTH, 1.07, z)], 0.025, 10)
	gbox(part, "CVRail", (0.0, 0.17, z - 0.012), (LENGTH, 0.2, z + 0.012))
	gbox(part, "CVRail", (0.0, 0.98, z - 0.012), (LENGTH, 1.0, z + 0.012))
	k = 0
	x = 0.125
	while x < LENGTH - 0.05:
		if all(abs(x - p) > 0.06 for p in posts):
			gbox(part, "CVRail", (x - 0.008, 0.2, z - 0.008), (x + 0.008, 0.98, z + 0.008))
			k += 1
		x += 0.125
	return W.build(part)


def main():
	materials()
	K.w1kit.export(OUT / "cctv_corridor.glb", [set_part(), railing()])


main()
