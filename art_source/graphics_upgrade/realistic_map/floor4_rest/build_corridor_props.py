"""T-256 (D-170) part B: the floor-4 corridor's loose things, modelled in Blender, Floor4 metres:
  corridor_props.glb
    Line          the clothesline: a wire sagging a little between eye hooks screwed into the ceiling's edge
    Props         small things that need no collision: slippers, shoes, a broom and dustpan, an umbrella, a football...
    Solid_<name>  things a bucket's size or more, each its own object: corridor_props.gd gives each a box collider
                  inside its bounds (D-135); they stand against the room wall between the doors (z <= 0.5) or by
                  the railing (z >= 3.35), never within 1.2 m in front of a door (card section 3)
    Bucket_11, Bucket_19, Bucket_35   the old buckets' new looks, about their collision box's foot (x, 0, 0.35)
  cloths.glb      Cloth0..4: what hangs on the line at HangingCloth_0..4 (origin on the line; they sway with the old
                  nodes, hanging_cloth.gd). Anchors/ClotheslineExtraShirt stays free: the old demo hangs its own shirt there
Each room's front differs (D-170): 401 a shoe rack, 402 a stool and a basin, 403 trainers and a ball, 404 a guitar case,
405 moving boxes, 406 a water jug and a carton of noodles, 407 an umbrella, the old 408 a broom.
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/floor4_rest/build_corridor_props.py
"""
import math
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave2"))
sys.path.insert(0, str(HERE))
import w2kit as K  # noqa: E402
from w2kit import G, gbox  # noqa: E402
import build_washroom as W  # noqa: E402

OUT = W.OUT
PX, NX, PY, NY, PZ, NZ = W.PX, W.NX, W.PY, W.NY, W.PZ, W.NZ
PREVIEW = {
	"CCCardboard": ((0.55, 0.42, 0.28), 0.85, 0.0), "CCTape": ((0.7, 0.6, 0.4), 0.4, 0.0),
	"CCRubber": ((0.12, 0.12, 0.12), 0.7, 0.0), "CCCanvas": ((0.2, 0.22, 0.25), 0.8, 0.0),
	"CCBag": ((0.24, 0.16, 0.11), 0.75, 0.0),
	"CCStraw": ((0.62, 0.5, 0.3), 0.9, 0.0), "CCWire": ((0.25, 0.25, 0.24), 0.5, 0.6),
	"CCClothBlue": ((0.3, 0.42, 0.6), 0.95, 0.0), "CCClothRed": ((0.6, 0.25, 0.25), 0.95, 0.0),
	"CCClothGrey": ((0.5, 0.5, 0.5), 0.95, 0.0), "CCClothWhite": ((0.82, 0.82, 0.78), 0.95, 0.0),
	"CCClothGreen": ((0.3, 0.45, 0.32), 0.95, 0.0), "CCClothNavy": ((0.18, 0.22, 0.35), 0.95, 0.0),
	"CCClothYellow": ((0.75, 0.62, 0.3), 0.95, 0.0),
}
WALL = 0.1  # the room wall's corridor face
LINE = {"x": (16.0, 32.0), "y": 2.15, "z": 3.87, "drops": [16.0, 21.5, 24.1, 28.5, 32.0], "sag": 0.03}


def materials():
	W.materials()
	for name, (colour, rough, metal) in PREVIEW.items():
		K.material(name, colour, rough, metal)


# ---------------------------------------------------------------- the clothesline

def line_y(x):
	drops = LINE["drops"]
	for a, b in zip(drops, drops[1:]):
		if a <= x <= b:
			t = (x - a) / (b - a)
			return LINE["y"] - 4.0 * LINE["sag"] * t * (1.0 - t)
	return LINE["y"]


def clothesline():
	part = K.Part("Line")
	z = LINE["z"]
	x0, x1 = LINE["x"]
	pts = [(x0 + (x1 - x0) * k / 160, line_y(x0 + (x1 - x0) * k / 160), z) for k in range(161)]
	W.gtube(part, "CCWire", pts, 0.0025, 5)
	for x in LINE["drops"]:
		W.gtube(part, "CCWire", [(x, 2.985, z), (x, line_y(x) + 0.01, z)], 0.0018, 5)
		part.cylinder("W1Steel", G(x, 2.99, z), 0.008, 0.02, axis="Z", segments=8)
		lathe_ring(part, (x, line_y(x) + 0.012, z))
	return W.build(part)


def lathe_ring(part, at):
	x, y, z = at
	pts = [(x + math.cos(a) * 0.012, y + math.sin(a) * 0.012, z) for a in [k / 10 * math.tau for k in range(11)]]
	W.gtube(part, "W1Steel", pts, 0.002, 5)


# ---------------------------------------------------------------- props

def shoe(part, mat, at, yaw, size=0.27):
	"""A shoe: a rounded sole and an upper, toe toward its yaw."""
	x, y, z = at
	a = math.radians(yaw)
	u = (math.cos(a), 0.0, math.sin(a))
	n = (-math.sin(a), 0.0, math.cos(a))
	W.obox(part, "CCRubber", (x, y + 0.012, z), (u, PY, n), (size / 2, 0.012, 0.045))
	W.obox(part, mat, (x - u[0] * 0.03, y + 0.05, z - u[2] * 0.03), (u, PY, n), (size / 2 - 0.04, 0.03, 0.04))
	W.obox(part, mat, (x + u[0] * (size / 2 - 0.05), y + 0.035, z + u[2] * (size / 2 - 0.05)), (u, PY, n), (0.045, 0.02, 0.04))


def slippers(part, mat, at, yaw):
	x, y, z = at
	a = math.radians(yaw)
	n = (-math.sin(a), 0.0, math.cos(a))
	u = (math.cos(a), 0.0, math.sin(a))
	for s in (-1, 1):
		c = (x + n[0] * s * 0.06, y, z + n[2] * s * 0.06)
		W.obox(part, mat, (c[0], 0.008, c[2]), (u, PY, n), (0.13, 0.008, 0.045))
		W.obox(part, mat, (c[0] + u[0] * 0.05, 0.022, c[2] + u[2] * 0.05), (u, PY, n), (0.03, 0.006, 0.047))


def broom(part, at, lean_to=(0.0, 0.0, -1.0)):
	x, y, z = at
	top = (x + lean_to[0] * 0.18, 1.25, z + lean_to[2] * 0.18)
	W.gtube(part, "W1WoodPale", [(x, 0.18, z), top], 0.012, 6)
	W.obox(part, "CCStraw", (x, 0.1, z), (PX, PY, PZ), (0.13, 0.1, 0.03))
	W.obox(part, "CCWire", (x, 0.205, z), (PX, PY, PZ), (0.1, 0.012, 0.025))


def cardboard(part, name_mat, lo, hi):
	gbox(part, name_mat, lo, hi, bevel=0.004)
	cx = (lo[0] + hi[0]) / 2
	gbox(part, "CCTape", (cx - 0.025, hi[1], lo[2] - 0.001), (cx + 0.025, hi[1] + 0.001, hi[2] + 0.001))


def solids():
	"""Things a bucket's size or more: one object each (corridor_props.gd boxes them)."""
	objs = []

	def solid(name):
		return K.Part("Solid_" + name)

	# 401 (tidy): a two-tier shoe rack with shoes, east of the washroom bay.
	p = solid("ShoeRack401")
	x0, x1, z0, z1 = 6.35, 6.95, WALL + 0.03, WALL + 0.31
	for y in (0.06, 0.26):
		for z in (z0 + 0.03, z1 - 0.03):
			W.gtube(p, "W1Steel", [(x0, y, z), (x1, y, z)], 0.006, 6)
		for k in range(5):
			x = x0 + 0.05 + k * (x1 - x0 - 0.1) / 4
			W.gtube(p, "W1Steel", [(x, y, z0 + 0.03), (x, y, z1 - 0.03)], 0.003, 4)
	for x in (x0, x1):
		for z in (z0 + 0.03, z1 - 0.03):
			W.gtube(p, "W1Steel", [(x, 0.0, z), (x, 0.42, z)], 0.007, 6)
	shoe(p, "CCCanvas", (6.5, 0.27, 0.27), 90)
	shoe(p, "CCCanvas", (6.61, 0.27, 0.27), 90)
	shoe(p, "W1Black", (6.78, 0.07, 0.26), 85)
	shoe(p, "W1Black", (6.89, 0.07, 0.26), 95)
	objs.append(W.build(p))
	# 402 (messy, food): a red plastic stool by the wall with a basin on it.
	p = solid("Stool402")
	W.lathe_at(p, "WRRed", [(0.15, 0.0), (0.13, 0.27), (0.14, 0.28), (0.14, 0.3), (0.0, 0.3)], (13.35, 0.0, 0.32), segments=4,
		scale=(1.0, 1.0))
	W.basin(p, "WRBlue", (13.35, 0.3, 0.32), r=0.18, h=0.08)
	objs.append(W.build(p))
	# 404 (music): a guitar case leaning on the wall.
	p = solid("GuitarBag404")
	# A soft gig bag leaning on the wall: the guitar's two bulbs and its neck, a zip and a strap.
	up = (0.0, 0.985, -0.17)
	out = (0.0, 0.17, 0.985)
	axes = ((1, 0, 0), up, out)
	x = 17.3

	def along(h, d=0.0):
		return (x, h * up[1] + d * out[1], 0.2 + h * up[2] + d * out[2])
	W.lathe_at(p, "CCBag", [(0.0, -0.055), (0.17, -0.055), (0.19, -0.03), (0.19, 0.03), (0.17, 0.055), (0.0, 0.055)],
		along(0.22), segments=16, scale=(1.0, 1.0))
	W.obox(p, "CCBag", along(0.45), axes, (0.15, 0.08, 0.05))
	W.lathe_at(p, "CCBag", [(0.0, -0.05), (0.13, -0.05), (0.15, -0.025), (0.15, 0.025), (0.13, 0.05), (0.0, 0.05)],
		along(0.58), segments=14)
	W.obox(p, "CCBag", along(0.88), axes, (0.055, 0.22, 0.035))
	W.obox(p, "CCBag", along(1.12), axes, (0.075, 0.07, 0.035))
	W.gtube(p, "W1Black", [along(0.05, 0.056), along(1.15, 0.036)], 0.004, 4)
	objs.append(W.build(p))
	# 405 (two have moved out): moving boxes, taped.
	p = solid("Boxes405")
	cardboard(p, "CCCardboard", (21.25, 0.0, WALL + 0.02), (21.8, 0.4, WALL + 0.42))
	cardboard(p, "CCCardboard", (21.85, 0.0, WALL + 0.04), (22.3, 0.34, WALL + 0.38))
	cardboard(p, "CCCardboard", (21.32, 0.4, WALL + 0.05), (21.74, 0.68, WALL + 0.36))
	objs.append(W.build(p))
	# 406 (they cook): a 20 L water jug and a carton of instant noodles.
	p = solid("Kitchen406")
	W.lathe_at(p, "WRBlue", [(0.0, 0.0), (0.13, 0.002), (0.14, 0.04), (0.14, 0.34), (0.1, 0.42), (0.03, 0.44), (0.03, 0.48),
		(0.0, 0.48)], (25.4, 0.0, 0.3), segments=20)
	cardboard(p, "CCCardboard", (25.65, 0.0, WALL + 0.03), (26.1, 0.28, WALL + 0.36))
	objs.append(W.build(p))
	# By the railing: a basin of washing soaking under the line, a bucket, a plastic chair.
	p = solid("Basin1850")
	W.basin(p, "WRRed", (18.5, 0.0, 3.68), r=0.26, h=0.12)
	gbox(p, "CCClothBlue", (18.35, 0.09, 3.6), (18.62, 0.13, 3.78), bevel=0.02)
	objs.append(W.build(p))
	p = solid("Bucket2600")
	W.bucket(p, "WRGreen", (26.0, 0.0, 3.72), r=0.15, h=0.3)
	objs.append(W.build(p))
	p = solid("Chair1350")
	chair(p, (13.5, 0.0, 3.68))
	objs.append(W.build(p))
	# The washroom's cleaning corner outside its door: a mop bucket.
	p = solid("MopBucket")
	W.bucket(p, "WRGrey", (4.45, 0.0, 0.3), r=0.16, h=0.3)
	objs.append(W.build(p))
	return objs


def chair(part, at):
	"""A blue plastic chair with its back to the railing."""
	x, y, z = at
	gbox(part, "WRBlue", (x - 0.22, 0.42, z - 0.2), (x + 0.22, 0.45, z + 0.18), bevel=0.012)
	gbox(part, "WRBlue", (x - 0.22, 0.45, z + 0.15), (x + 0.22, 0.85, z + 0.18), bevel=0.012)
	for sx in (-0.19, 0.19):
		for sz in (-0.17, 0.15):
			W.gtube(part, "WRBlue", [(x + sx, 0.0, z + sz), (x + sx * 1.02, 0.43, z + sz * 1.02)], 0.016, 6)


def small_props():
	part = K.Part("Props")
	# Slippers outside the doors, each room its own (none within 1.2 m in front of a door).
	for at, yaw, mat in (((9.3, 0, 0.24), 95, "WRBlue"), ((9.55, 0, 0.26), 80, "WRPink"), ((29.3, 0, 0.24), 100, "WRGreen"),
			((29.55, 0, 0.25), 85, "W1Black"), ((29.8, 0, 0.24), 92, "WRBlue"), ((10.9, 0, 0.25), 90, "W1Black"),
			((43.2, 0, 0.26), 270, "WRRed")):
		slippers(part, mat, at, yaw)
	# 403 (football): trainers and a ball.
	shoe(part, "CCClothWhite", (14.55, 0.0, 0.24), 80)
	shoe(part, "CCClothWhite", (14.7, 0.0, 0.25), 95)
	W.lathe_at(part, "CCClothWhite", [(0.0, 0.0)] + [(0.11 * math.sin(a), 0.11 - 0.11 * math.cos(a)) for a in
		[k / 10 * math.pi for k in range(1, 10)]] + [(0.0, 0.22)], (15.05, 0.0, 0.3), segments=14)
	# A broom and dustpan by the sealed old 408 door and by the washroom; an umbrella beside 407.
	broom(part, (36.6, 0.0, 0.16), lean_to=(0.0, 0.0, -0.4))
	gbox(part, "WRGrey", (36.85, 0.0, 0.15), (37.1, 0.03, 0.37), bevel=0.005)
	gbox(part, "WRGrey", (36.85, 0.0, 0.14), (37.1, 0.12, 0.16))
	broom(part, (5.3, 0.0, 0.16), lean_to=(0.0, 0.0, -0.4))
	W.gtube(part, "CCCanvas", [(33.8, 0.05, 0.25), (33.86, 0.85, 0.13)], 0.04, 8)
	W.gtube(part, "W1Black", [(33.86, 0.85, 0.13), (33.87, 0.95, 0.12), (33.83, 0.98, 0.12)], 0.009, 6)
	# A tied plastic bag by 405's boxes and the bin by the washroom.
	W.lathe_at(part, "W1Black", [(0.0, 0.0), (0.15, 0.03), (0.17, 0.18), (0.08, 0.3), (0.02, 0.36), (0.0, 0.36)],
		(22.7, 0.0, 0.3), segments=10)
	return W.build(part)


def old_buckets():
	"""The three old buckets' looks (their collision boxes stay): about (0, 0, 0) at the box's foot."""
	objs = []
	for name, mat, x in (("Bucket_11", "WRBlue", 11.0), ("Bucket_19", "WRRed", 19.0), ("Bucket_35", "WRGrey", 35.0)):
		p = K.Part(name)
		W.bucket(p, mat, (x, 0.0, 0.35), r=0.14, h=0.32)
		objs.append(W.build(p))
	return objs


# ---------------------------------------------------------------- the washing

def tshirt(part, mat, width=0.5, length=0.68):
	"""A T-shirt on a wire hanger: origin on the line, hanging in the x-y plane, 1.5 cm thick."""
	hw = width / 2
	top = -0.17
	outline = [(-0.07, top), (-hw + 0.04, top - 0.03), (-hw - 0.08, top - 0.16), (-hw + 0.0, top - 0.24),
		(-hw + 0.04, top - 0.16), (-hw + 0.06, top - length), (hw - 0.06, top - length), (hw - 0.04, top - 0.16),
		(hw, top - 0.24), (hw + 0.08, top - 0.16), (hw - 0.04, top - 0.03), (0.07, top), (0.0, top - 0.05)]
	slab(part, mat, outline, 0.008)
	hanger(part, width * 0.85, top + 0.01)


def towel(part, mat, width=0.55, drop=0.62, back=0.42):
	"""A towel folded over the line: a front and a back panel and the fold round the line."""
	hw = width / 2
	for z, length in ((0.012, drop), (-0.012, back)):
		part.poly(mat, [G(-hw, -0.006, z), G(hw, -0.006, z), G(hw, -length, z), G(-hw, -length, z)], [(0, 1, 2, 3)], recalc=False)
		part.poly(mat, [G(hw, -0.006, z), G(-hw, -0.006, z), G(-hw, -length, z), G(hw, -length, z)], [(0, 1, 2, 3)], recalc=False)
	W.gtube(part, mat, [(-hw, 0.004, 0.0), (hw, 0.004, 0.0)], 0.013, 8)


def trousers(part, mat, width=0.4, drop=0.95):
	"""Trousers folded over the line by the waist: two legs each side."""
	for z in (0.01, -0.01):
		outline = [(-width / 2, -0.01), (width / 2, -0.01), (width / 2 + 0.02, -drop), (0.03, -drop), (0.0, -0.3),
			(-0.03, -drop), (-width / 2 - 0.02, -drop)]
		slab(part, mat, outline, 0.006, z=z)
	W.gtube(part, mat, [(-width / 2, 0.0, 0.0), (width / 2, 0.0, 0.0)], 0.012, 8)


def slab(part, mat, outline, half, z=0.0):
	n = len(outline)
	verts = [G(x, y, z + half) for x, y in outline] + [G(x, y, z - half) for x, y in outline]
	faces = [list(range(n)), list(reversed(range(n, 2 * n)))] + [(i, (i + 1) % n, n + (i + 1) % n, n + i) for i in range(n)]
	part.poly(mat, verts, faces, recalc=True)


def hanger(part, width, y):
	hw = width / 2
	W.gtube(part, "CCWire", [(-hw, y, 0.0), (0.0, y + 0.12, 0.0), (hw, y, 0.0), (-hw, y, 0.0)], 0.002, 4)
	W.gtube(part, "CCWire", [(0.0, y + 0.12, 0.0), (0.0, y + 0.16, 0.0), (0.02, y + 0.19, 0.0), (0.0, 0.006, -0.0),
		(-0.012, -0.004, 0.0)], 0.002, 4)


def cloths():
	objs = []
	for name, kind, mat in (("Cloth0", "shirt", "CCClothBlue"), ("Cloth1", "towel", "CCClothRed"), ("Cloth2", "trousers", "CCClothNavy"),
			("Cloth3", "towel", "CCClothWhite"), ("Cloth4", "shirt", "CCClothGreen")):
		p = K.Part(name)
		{"shirt": tshirt, "towel": towel, "trousers": trousers}[kind](p, mat)
		objs.append(W.build(p))
	return objs


def main():
	materials()
	K.w1kit.export(OUT / "corridor_props.glb", [clothesline(), small_props()] + solids() + old_buckets())
	K.reset()
	materials()
	K.w1kit.export(OUT / "cloths.glb", cloths())


main()
