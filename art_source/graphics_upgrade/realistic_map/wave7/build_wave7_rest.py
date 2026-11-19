"""T-264 round 3 (D-182): the rest of the campus ground (A16 less the earlier strips, wave 8 and the buildings). Blender
5.2.2, bmesh only, no add-on, no Tripo. Godot world coordinates, every glb's root at Godot (0, G, 0) unless said.

  ground.glb          the verges (worn grass and dirt, W7Verge, mask over the whole campus), the Avenue, EastBranch and
                      StadiumEastAccess in old asphalt with patches and worn lines, whitewashed kerbs, the three
                      forecourts in "con sâu" blocks with concrete edging (D-182 item 5), and a 40 m band of verge outside
                      the north, east and west fences (seen through the chain-link)
  fences.glb          B40 chain-link on pipe posts along Fence/N, E and W (D-182 item 7), inside their colliders
  tree_<sp>.glb       bàng, phượng, xà cừ at the origin (the trunk's foot): Bark, Leaves (near), LeavesMid (every other
                      card, 1.3 x, mid range), Far (two crossed cards, tree_far_<sp>.png); rest_real.gd hangs them as
                      MultiMeshes on the PS1 clusters' points
  lamp_steel.glb      the galvanised street light with an arm (D-182 item 5) at the origin, the arm over +z
  rest_props.glb      what props.tscn's rest of A16 held (rest_props.py): cars (wave 5's sedan), mopeds, bicycles (wave
                      6's), the bike shelters, the kiosk, planters, bins, signposts, the fallen and leaning lamps, benches,
                      rubble and rods, papers, glass, sandals, shoes; plus the Avenue's three benches and the three fallen
                      mopeds (Road/RoadBench*, FallenMoped*), on their colliders. One object per 80 m cell and kind
                      (Props_*, Small_*, Shrubs_*), so they cull as the PS1 chunks did
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave7/build_wave7_rest.py [-- name ...]
(after patch_wave7.py data, which writes w7_ps1_props.json from main's props.tscn)
"""
import math
from pathlib import Path
import random
import sys

import bpy  # noqa: F401
from mathutils import Matrix, Vector
import numpy as np

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE))
import build_wave7_pilot as P  # noqa: E402  (wave 1, 3, 5 kits; its main is guarded)
sys.path.insert(0, str(HERE.parent / "wave5"))
sys.path.insert(0, str(HERE.parent / "wave6"))
import build_gate as W5  # noqa: E402  (car, frames, palette 4 helpers)
import build_canteen as W6  # noqa: E402  (bicycle wheels, palette 6)
import rest_props as RP  # noqa: E402
import wave7_layout as L  # noqa: E402

w1kit, GPart, B, G, TP = P.w1kit, P.GPart, P.B, P.G, P.TP
lbox, lface, lpipe, to_world, frame_of = W5.lbox, W5.lface, W5.lpipe, W5.to_world, W5.frame_of
W5.surface_y = RP.surface_y      # wave 5's flat_item lays things on this wave's floor
P.GP.PREVIEW.update({"W7Verge": ((0.22, 0.24, 0.12), 0.95), "W7Asphalt": ((0.16, 0.16, 0.15), 0.9), "W7Pavers": ((0.45, 0.44, 0.42), 0.85),
	"W7Kerb": ((0.75, 0.75, 0.72), 0.8), "W7Paint": ((0.8, 0.8, 0.75), 0.7), "W4Chainlink": ((0.5, 0.5, 0.48), 0.5),
	"W7GlassDark": ((0.03, 0.035, 0.04), 0.08), "W6Palette": ((0.5, 0.5, 0.5), 0.6), "W3Soil": ((0.15, 0.11, 0.08), 0.95)})
TP.PREVIEW.update({"W7FarBang": ((0.17, 0.3, 0.1), 0.8), "W7FarPhuong": ((0.2, 0.33, 0.1), 0.8), "W7FarXacu": ((0.11, 0.22, 0.08), 0.8)})
CELL = 80.0
SIZES = {"W7Verge": 1.0, "W7Pavers": 0.9, "W7Asphalt": 4.0, "W7Kerb": 1.0, "W1Concrete": 0.8, "W4PoleSteel": 1.0, "W1Terrazzo": 1.0,
	"W7Palette": 1.0, "W4Palette": 1.0, "W6Palette": 1.0, "W3Brick": 0.8, "W1Rebar": 1.0, "W4FloodBody": 1.0, "W4RoofSheet": 1.0,
	"W3Soil": 1.0, "W1Black": 1.0, "W1Rubber": 1.0, "W1Steel": 1.0}


def build(part, extra=None):
	sizes = dict(SIZES)
	sizes.update(extra or {})
	return P.build(part, sizes)


# ------------------------------------------------------------------------------------------------ ground

def road_y(x, z):
	"""The Avenue climbs to T-262's paved stretch (-9.87 at x 180) over its last 3 m; the rest lies at ROAD_Y."""
	x0, x1, top = L.AVENUE_JOIN
	if -19.0 <= z <= -11.0 and x > x0:
		return L.ROAD_Y + (top - L.ROAD_Y) * min(1.0, (x - x0) / (x1 - x0))
	return L.ROAD_Y


def tiles(part, mat, x0, x1, z0, z1, yfn, step):
	"""A cell as a grid of quads no bigger than `step`, heights from yfn(x, z)."""
	nx = max(1, int(math.ceil((x1 - x0) / step - 1e-6)))
	nz = max(1, int(math.ceil((z1 - z0) / step - 1e-6)))
	faces = []
	for i in range(nx):
		for j in range(nz):
			xa, xb = x0 + (x1 - x0) * i / nx, x0 + (x1 - x0) * (i + 1) / nx
			za, zb = z0 + (z1 - z0) * j / nz, z0 + (z1 - z0) * (j + 1) / nz
			faces.append(part.face(mat, [(xa, yfn(xa, za), za), (xb, yfn(xb, za), za), (xb, yfn(xb, zb), zb), (xa, yfn(xa, zb), zb)], (0, 1, 0)))
	return faces


def build_ground():
	w1kit.reset()
	verge, paved, road, kerb, edge, paint, outside = (GPart(n) for n in ("Verge", "Paved", "Road", "Kerbs", "Edge", "Paint", "Outside"))
	uv2 = lambda q: L.campus_uv2(q[0], q[2])  # noqa: E731
	fv, fp, fr = [], [], []
	for kind, x0, x1, z0, z1 in L.ground_cells():
		if kind == "verge":
			fv += tiles(verge, "W7Verge", x0, x1, z0, z1, lambda x, z: L.VERGE_Y, 20.0)
		elif kind == "paved":
			fp += tiles(paved, "W7Pavers", x0, x1, z0, z1, lambda x, z: L.PAVED_Y, 6.0)
		elif kind == "road":
			fr += tiles(road, "W7Asphalt", x0, x1, z0, z1, road_y, 4.0)
	verge.map_uv2(fv, uv2)
	paved.map_uv2(fp, uv2)
	road.map_uv2(fr, uv2)
	# Kerbs: 1 m whitewashed blocks along the roads' sides and dead ends (none where the Avenue meets T-262's stretch or
	# where the access road meets EastBranch).
	K, lo_y = L.KERB, L.VERGE_Y - 0.06
	runs = [("x", -11.0, -11.0 + K, 0.0, 180.0), ("x", -19.0 - K, -19.0, 0.0, 180.0), ("z", -K, 0.0, -19.0 - K, -11.0 + K),
		("z", 306.0 - K, 306.0, -30.0, 163.0), ("z", 314.0, 314.0 + K, -30.0 - K, 166.0 + K), ("x", -30.0 - K, -30.0, 306.0 - K, 314.0 + K),
		("x", 166.0, 166.0 + K, 312.0, 314.0 + K), ("x", 163.0 - K, 163.0, 284.0, 306.0), ("x", 169.0, 169.0 + K, 284.0, 312.0 + K),
		("z", 312.0, 312.0 + K, 166.0 + K, 169.0 + K), ("z", 284.0 - K, 284.0, 163.0 - K, 169.0 + K)]
	fk = []
	for axis, c0, c1, s0, s1 in runs:
		s = s0
		while s < s1 - 0.01:
			e = min(s1, s + 1.0)
			top = L.KERB_TOP + (road_y(e, -15.0) - L.ROAD_Y if axis == "x" and c0 < -10.0 else 0.0)
			if axis == "x":
				fk += kerb.gbox("W7Kerb", (s + 0.004, lo_y, c0), (e - 0.004, top, c1))
			else:
				fk += kerb.gbox("W7Kerb", (c0, lo_y, s + 0.004), (c1, top, e - 0.004))
			s = e
	kerb.map_uv2(fk, uv2)
	# Forecourt edging: concrete strips round the paving's open sides, 1 cm proud.
	for _name, x0, x1, z0, z1 in L.FORECOURTS:
		E = L.EDGE
		for lo, hi in (((x0 - E, lo_y, z0 - E), (x1 + E, L.PAVED_Y + 0.01, z0)), ((x0 - E, lo_y, z0), (x0, L.PAVED_Y + 0.01, z1)),
				((x1, lo_y, z0), (x1 + E, L.PAVED_Y + 0.01, z1))):
			edge.gbox("W1Concrete", lo, hi)
	# Worn lines: the Avenue's dashed centre and edge lines, the branches' dashed centres.
	py = L.ROAD_Y + 0.004
	lines = [("x", -15.0, 0.0, 177.0, True), ("x", -18.65, 0.0, 177.0, False), ("x", -11.35, 0.0, 177.0, False),
		("z", 310.0, -30.0, 163.0, True), ("x", 166.0, 284.0, 306.0, True)]
	for axis, c, s0, s1, dashed in lines:
		step = 6.0 if dashed else (s1 - s0)
		s = s0
		while s < s1 - 0.5:
			e = min(s1, s + (3.0 if dashed else step))
			u = (e - s) / 2.0
			if axis == "x":
				paint.face("W7Paint", [(s, py, c - 0.06), (e, py, c - 0.06), (e, py, c + 0.06), (s, py, c + 0.06)], (0, 1, 0), [(0, 1), (u, 1), (u, 0), (0, 0)])
			else:
				paint.face("W7Paint", [(c - 0.06, py, s), (c - 0.06, py, e), (c + 0.06, py, e), (c + 0.06, py, s)], (0, 1, 0), [(0, 1), (u, 1), (u, 0), (0, 0)])
			s += step
	P.keep(paint, list(paint.bm.faces))
	# Outside the north, east and west fences: worn verge to 40 m out (the PS1 walls hid it; the chain-link does not).
	X0, X1, Z0, Z1 = L.CAMPUS
	fo = []
	for x0, x1, z0, z1 in ((X0 - 40.0, X0 - 0.2, Z0 - 2.0, Z1 + 40.0), (X0 - 0.2, X1 + 0.2, Z1 + 0.2, Z1 + 40.0), (X1 + 0.2, X1 + 40.0, Z0 - 2.0, Z1 + 40.0)):
		fo += tiles(outside, "W7Verge", x0, x1, z0, z1, lambda x, z: L.VERGE_Y - 0.004, 40.0)
	outside.map_uv2(fo, uv2)
	objs = [build(p) for p in (verge, paved, road, kerb, edge, paint, outside) if p.bm.faces]
	P.export("ground.glb", objs)


# ------------------------------------------------------------------------------------------------ fences

def build_fences():
	"""B40 on pipe posts every 2.5 m, a low concrete plinth, a top rail; inside each 0.3 x 3 m collider."""
	w1kit.reset()
	solid, mesh = GPart("FenceSolid"), GPart("Chainlink")
	X0, X1, Z0, Z1 = L.CAMPUS
	sides = [("z", X0, Z0 + 0.35, Z1), ("x", Z1, X0, X1), ("z", X1, Z0 + 0.35, Z1)]
	for axis, c, s0, s1 in sides:
		def P3(s, y, axis=axis, c=c):
			return (c, y, s) if axis == "z" else (s, y, c)
		lo, hi = P3(s0, G - 0.06), P3(s1, G + 0.25)
		w = 0.12
		solid.gbox("W1Concrete", (min(lo[0], hi[0]) - (w if axis == "z" else 0), lo[1], min(lo[2], hi[2]) - (w if axis == "x" else 0)),
			(max(lo[0], hi[0]) + (w if axis == "z" else 0), hi[1], max(lo[2], hi[2]) + (w if axis == "x" else 0)))
		n = int(round((s1 - s0) / 2.5))
		for k in range(n + 1):
			s = s0 + (s1 - s0) * k / n
			x, _, z = P3(s, 0.0)
			corner = k in (0, n)
			solid.cylinder("W4PoleSteel", tuple(B((x, G + 1.35, z))), 0.045 if corner else 0.03, 2.4, segments=8)
			if k % 4 == 0 and not corner:   # a brace every 10 m
				solid.pipe("W4PoleSteel", [P3(s, G + 0.25), P3(s + 0.9, G + 2.0)], 0.018, sides=5)
		solid.pipe("W4PoleSteel", [P3(s0, G + 2.5), P3(s1, G + 2.5)], 0.022, sides=6)
		solid.pipe("W4PoleSteel", [P3(s0, G + 0.3), P3(s1, G + 0.3)], 0.006, sides=4)
		length = s1 - s0
		normal = (1, 0, 0) if axis == "z" else (0, 0, 1)
		mesh.face("W4Chainlink", [P3(s0, G + 0.25), P3(s1, G + 0.25), P3(s1, G + 2.48), P3(s0, G + 2.48)], normal,
			[(0.0, 0.0), (length / 0.5, 0.0), (length / 0.5, 2.23 / 0.5), (0.0, 2.23 / 0.5)])
	P.keep(mesh, list(mesh.bm.faces))
	P.export("fences.glb", [build(solid), build(mesh)])


# ------------------------------------------------------------------------------------------------ trees, lamp

def build_trees():
	"""The pilot's three trees (build_wave7_pilot.build_tree) plus a mid-range crown (every other card, 1.3 x) and a far
	card pair, at the origin (the trunk's foot)."""
	orig_card, orig_export = TP.card, P.export
	for sp in L.SPECIES:
		mid, far = TP.Buf("LeavesMid"), TP.Buf("Far")
		count = [0]

		def card(buf, mat, origin, up_axis, normal, width, height, cell, mid=mid, count=count, **kw):
			res = orig_card(buf, mat, origin, up_axis, normal, width, height, cell, **kw)
			if getattr(buf, "name", "") == "Leaves":
				count[0] += 1
				if count[0] % 2 == 0:
					orig_card(mid, mat, origin, up_axis, normal, width * 1.3, height * 1.3, cell, **kw)
			return res

		def export(name, objs, mid=mid, far=far, sp=sp):
			mat = "W7Far" + sp.capitalize()
			for n in (Vector((1, 0, 0)), Vector((0, 1, 0))):
				orig_card(far, mat, Vector((0, 0, 0)), Vector((0, 0, 1)), n, 14.0, 14.0, (0.0, 0.0, 1.0, 1.0), base=0.0,
					radial_from=(0, 0, 8.0), normal_mix=0.45)
			low = [v for v in mid.v if v.z < 2.0]
			print("T264_TREE_MID %s: %d tris, %d verts under 2 m" % (sp, mid.tris(), len(low)))
			orig_export(name, objs + [mid.build(), far.build()])

		TP.card, P.export = card, export
		try:
			P.build_tree(sp)
		finally:
			TP.card, P.export = orig_card, orig_export


def build_lamp():
	"""The steel street light at the origin: a 7 m tapered pole on a base plate, the arm curving out 1.3 m over +z, the
	lamp housing with its faintly glowing glass (the PS1 head glowed; the lights in Props/Lights stand at the pole's top)."""
	w1kit.reset()
	pole, head, glass = GPart("Pole"), GPart("Head"), GPart("LampGlass")
	pole.cylinder("W4PoleSteel", tuple(B((0.0, G + 3.5, 0.0))), 0.085, 7.0, segments=8, radius2=0.05)
	pole.cylinder("W4PoleSteel", tuple(B((0.0, G + 0.3, 0.0))), 0.14, 0.6, segments=8)
	pole.gbox("W1Concrete", (-0.3, G - 0.05, -0.3), (0.3, G + 0.06, 0.3))
	pole.pipe("W4PoleSteel", [(0.0, G + 6.6, 0.0), (0.0, G + 7.0, 0.25), (0.0, G + 7.18, 0.8), (0.0, G + 7.2, 1.3)], 0.035, sides=6)
	head.gbox("W4FloodBody", (-0.15, G + 7.08, 1.15), (0.15, G + 7.24, 1.8))
	glass.face("W7LampGlass", [(-0.12, G + 7.07, 1.2), (0.12, G + 7.07, 1.2), (0.12, G + 7.07, 1.75), (-0.12, G + 7.07, 1.75)], (0, -1, 0))
	P.export("lamp_steel.glb", [build(pole), build(head), build(glass)])


# ------------------------------------------------------------------------------------------------ props

def bdir(v):
	return Vector((v[0], -v[2], v[1]))


def frame_matrix(frame):
	"""Blender matrix of a Godot frame for Blender-local geometry (x along, y = -z across, z = y up)."""
	o, (ax, ay, az), _ = frame
	cx, cy, cz = bdir(ax), bdir(-az), bdir(ay)
	m = Matrix(((cx.x, cy.x, cz.x, 0), (cx.y, cy.y, cz.y, 0), (cx.z, cy.z, cz.z, 0), (0, 0, 0, 1)))
	return Matrix.Translation(B(o)) @ m


def rot(rx=0.0, ry=0.0, rz=0.0):
	"""Godot Basis.from_euler (YXZ) in degrees, as scatter.py's euler() feeds the PS1 pieces; columns as Vectors."""
	m = Matrix.Rotation(math.radians(ry), 3, "Y") @ Matrix.Rotation(math.radians(rx), 3, "X") @ Matrix.Rotation(math.radians(rz), 3, "Z")
	return m


def rbox(part, frame, mat, centre, size, r=None):
	"""A box of `size` centred at `centre` in a Godot frame, turned by r (3 x 3, Godot local); outward faces."""
	r = r or Matrix.Identity(3)
	hx, hy, hz = (s / 2 for s in size)
	c = Vector(centre)

	def at(p):
		return to_world(frame, tuple(c + r @ Vector(p)))
	sides = [([(-hx, -hy, -hz), (-hx, -hy, hz), (-hx, hy, hz), (-hx, hy, -hz)], (-1, 0, 0)), ([(hx, -hy, -hz), (hx, hy, -hz), (hx, hy, hz), (hx, -hy, hz)], (1, 0, 0)),
		([(-hx, -hy, -hz), (hx, -hy, -hz), (hx, -hy, hz), (-hx, -hy, hz)], (0, -1, 0)), ([(-hx, hy, -hz), (-hx, hy, hz), (hx, hy, hz), (hx, hy, -hz)], (0, 1, 0)),
		([(-hx, -hy, -hz), (-hx, hy, -hz), (hx, hy, -hz), (hx, -hy, -hz)], (0, 0, -1)), ([(-hx, -hy, hz), (hx, -hy, hz), (hx, hy, hz), (-hx, hy, hz)], (0, 0, 1))]
	out = []
	for pts, n in sides:
		nn = r @ Vector(n)
		out.append(lface(part, frame, mat, [tuple(c + r @ Vector(p)) for p in pts], tuple(nn)))
	return out


def lcyl(part, frame, mat, a, b, radius, sides=10):
	return lpipe(part, frame, mat, [a, b], radius, sides, True)


PAL6 = W6.cell_uv


def pal7(part, faces, key, rnd):
	return P.pal(part, faces, key, rnd)


def nearest(rgba, table):
	return min(table, key=lambda k: sum((a - b) ** 2 for a, b in zip(table[k], rgba[:3])))


CAR_TINTS = {"W5CarRed": (0.75, 0.12, 0.1), "W5CarBlue": (0.2, 0.36, 0.85), "W5CarWhite": (0.85, 0.85, 0.85), "W5CarGrey": (0.5, 0.6, 0.5)}
MOPED_TINTS = {"moped_red": (0.85, 0.16, 0.12), "moped_blue": (0.2, 0.36, 0.85), "moped_yellow": (0.95, 0.82, 0.22), "moped_grey": (0.28, 0.3, 0.36)}
KIOSK_TINTS = {"kiosk_yellow": (0.9, 0.75, 0.4), "kiosk_blue": (0.4, 0.7, 0.8), "kiosk_red": (0.85, 0.35, 0.3)}
BIN_TINTS = {"green_plastic": (0.25, 0.5, 0.3), "blue_plastic": (0.2, 0.3, 0.6), "bin_grey": (0.5, 0.5, 0.5)}


def moped(part, frame, tint, rnd):
	"""An underbone moped standing in its frame (Blender-local: x along, y across, z up), wheels on the frame's ground."""
	m = frame_matrix(frame)
	paint = nearest(tint, MOPED_TINTS)
	for cx in (-0.6, 0.62):
		f = part.cylinder("W7Palette", (cx, 0.0, 0.28), 0.28, 0.09, axis="Y", segments=14, matrix=m)
		pal7(part, f, "rubber", rnd)
		f = part.cylinder("W7Palette", (cx, -0.002, 0.28), 0.16, 0.095, axis="Y", segments=10, matrix=m)
		pal7(part, f, "chrome", rnd)
	for lo, hi, key in (((-0.45, -0.17, 0.33), (0.35, 0.17, 0.6), paint), ((-0.5, -0.14, 0.6), (0.12, 0.14, 0.72), "seat"),
			((0.3, -0.12, 0.42), (0.55, 0.12, 0.92), paint), ((0.45, -0.32, 0.93), (0.52, 0.32, 0.97), "black"),
			((0.52, -0.08, 0.83), (0.6, 0.08, 0.93), "lamp_white"), ((-0.75, -0.08, 0.52), (-0.6, 0.08, 0.6), "lamp_red"),
			((-0.6, 0.14, 0.16), (0.05, 0.2, 0.24), "chrome"), ((0.5, -0.03, 0.28), (0.58, 0.03, 0.88), "black")):
		f = part.box("W7Palette", lo, hi, matrix=m)
		pal7(part, f, key, rnd)


def bicycle(part, frame, paint, rnd, along_z=False):
	"""Wave 6's step-through bicycle in a Godot frame (local x along, y up, z across), wheels at x -0.55 / 0.55."""
	def xf(p):
		lx, ly, lz = p
		if along_z:
			lx, lz = lz, -lx
		return to_world(frame, (lx, ly, lz))
	for cx in (-0.55, 0.55):
		W6._wheel(part, xf, cx, rnd)
	tubes = [[(0.4, 0.78, 0.0), (0.18, 0.5, 0.0), (-0.02, 0.32, 0.0), (-0.08, 0.3, 0.0)], [(-0.08, 0.3, 0.0), (-0.2, 0.86, 0.0)],
		[(-0.08, 0.3, 0.03), (-0.55, 0.33, 0.04)], [(-0.08, 0.3, -0.03), (-0.55, 0.33, -0.04)],
		[(-0.19, 0.8, 0.03), (-0.55, 0.33, 0.04)], [(-0.19, 0.8, -0.03), (-0.55, 0.33, -0.04)], [(0.36, 0.62, 0.0), (0.42, 0.86, 0.0)]]
	for pts in tubes:
		PAL6(part, part.pipe("W6Palette", [xf(p) for p in pts], 0.016, sides=6), paint, rnd)
	for s in (0.04, -0.04):
		PAL6(part, part.pipe("W6Palette", [xf((0.38, 0.66, s)), xf((0.5, 0.45, s)), xf((0.55, 0.33, s))], 0.011, sides=5), "chrome", rnd)
	PAL6(part, part.pipe("W6Palette", [xf((0.42, 0.86, 0.0)), xf((0.44, 0.98, 0.0)), xf((0.36, 1.0, 0.0))], 0.012, sides=5), "chrome", rnd)
	PAL6(part, part.pipe("W6Palette", [xf((0.3, 0.99, -0.28)), xf((0.36, 1.0, -0.1)), xf((0.36, 1.0, 0.1)), xf((0.3, 0.99, 0.28))], 0.011, sides=5), "chrome", rnd)
	PAL6(part, part.pipe("W6Palette", [xf((-0.36, 0.975, 0.0)), xf((-0.24, 0.985, 0.0)), xf((-0.13, 0.975, 0.0))], 0.05, sides=6), "saddle", rnd)
	for cx in (-0.55, 0.55):
		arc = [xf((cx + math.cos(math.radians(d)) * 0.37, 0.33 + math.sin(math.radians(d)) * 0.37, 0.0)) for d in range(20, 170, 25)]
		PAL6(part, part.pipe("W6Palette", arc, 0.022, sides=4, cap=False), paint, rnd)


def object_frame(anchor, local):
	"""The scatter.py object's frame from its anchor piece (placed at `local` in it, unturned), dropped to the new floor."""
	_name, _k, basis, origin, _rgba, _s = anchor
	o, axes, _ = frame_of(basis, origin)
	o = o - axes[0] * local[0] - axes[1] * local[1] - axes[2] * local[2]
	o = Vector((o.x, o.y + RP.surface_y(origin[0], origin[2]) - G, o.z))
	return o, axes, (1, 1, 1)


ANCHOR_AT = {"car": (0, 0.6, 0), "moped": (0, 0.5, 0), "bicycle": (-0.22, 0.78, 0), "kiosk": (0, 1.15, 0), "planter": (0, 0.3, 0),
	"bin": (0, 0.42, 0), "signpost": (0, 1.4, 0), "lamp_fallen": (0, 3.2, 0), "lamp_leaning": (0, 3.4, 0), "lit_lamp": (0, 2.6, 0),
	"bench": (0, 0.45, 0), "shelter": (0, 2.55, 0)}


def build_object(kind, anchor, parts, rnd):
	fr = object_frame(anchor, ANCHOR_AT[kind])
	big, small, shrubs = parts
	rgba = anchor[4]
	if kind == "car":
		W5.car(big, fr, nearest(rgba, CAR_TINTS))
	elif kind == "moped":
		moped(big, fr, rgba, rnd)
	elif kind == "bicycle":
		bicycle(big, fr, "bike_blue" if rnd.random() < 0.5 else "bike_red", rnd)
	elif kind == "shelter":
		length = anchor[5][0] - 0.4
		for px in (-length / 2 + 0.1, length / 2 - 0.1):
			for pz in (-1.25, 1.25):
				rbox(big, fr, "W4PoleSteel", (px, 1.25, pz), (0.1, 2.5, 0.1))
		rbox(big, fr, "W4RoofSheet", (0, 2.6, 0), (length + 0.4, 0.04, 2.9), rot(rx=-4))
		for pz in (-1.0, 0.0, 1.0):
			rbox(big, fr, "W4PoleSteel", (0, 2.53 - pz * 0.07, pz), (length + 0.2, 0.08, 0.06))
		f = rbox(big, fr, "W1Concrete", (0, 1.0, -1.3), (length, 2.0, 0.1))
		count = max(3, int(length // 1.4))
		for i in range(count):
			bx = -length / 2 + 0.7 + i * ((length - 1.2) / max(1, count - 1))
			o, axes, s = fr
			bike_fr = (o + axes[0] * bx, axes, s)
			bicycle(big, bike_fr, ["bike_blue", "bike_red", "bike_green"][i % 3], rnd, along_z=True)
			lpipe(big, fr, "W4PoleSteel", [(bx - 0.25, 0.0, -0.75), (bx - 0.25, 0.45, -0.75), (bx + 0.25, 0.45, -0.75), (bx + 0.25, 0.0, -0.75)], 0.02, 6, False)
	elif kind == "kiosk":
		paint = nearest(rgba, KIOSK_TINTS)
		pal7(big, rbox(big, fr, "W7Palette", (0, 1.15, 0), (3.0, 2.3, 2.0)), paint, rnd)
		pal7(big, rbox(big, fr, "W7Palette", (0, 1.0, 1.02), (2.6, 1.5, 0.05)), "shutter_grey", rnd)
		for k in range(14):
			pal7(big, rbox(big, fr, "W7Palette", (0, 0.3 + k * 0.1, 1.05), (2.56, 0.012, 0.012)), "steel_grey", rnd)
		pal7(big, rbox(big, fr, "W7Palette", (0, 2.45, 0.9), (3.6, 0.06, 1.5), rot(rx=-10)), "awning_red", rnd)
		pal7(big, rbox(big, fr, "W7Palette", (0, 2.0, 1.04), (2.2, 0.38, 0.04)), "sign_blue", rnd)
		rbox(big, fr, "W1Terrazzo", (0, 1.1, 1.2), (3.0, 0.08, 0.5))
		for sx in (-1.4, 1.4):
			rbox(big, fr, "W4PoleSteel", (sx, 1.7, 1.55), (0.04, 1.3, 0.04))
	elif kind == "planter":
		rbox(big, fr, "W1Concrete", (0, 0.3, 0), (2.4, 0.6, 0.9))
		lface(big, fr, "W3Soil", [(-1.12, 0.58, -0.37), (1.12, 0.58, -0.37), (1.12, 0.58, 0.37), (-1.12, 0.58, 0.37)], (0, 1, 0))
		nrng = np.random.default_rng(rnd.randrange(1 << 30))
		cells = [TP.shrub_cell(c, r) for c in range(2) for r in range(2)]
		for bx in (-0.75, 0.0, 0.75):
			centre = B(to_world(fr, (bx, 0.58, 0.0)))
			TP.shrub_cards(shrubs, nrng, centre, 0.42, 0.75, 26, cells)
	elif kind == "bin":
		key = nearest(rgba, BIN_TINTS)
		PAL6(big, lcyl(big, fr, "W6Palette", (0, 0.0, 0), (0, 0.8, 0), 0.25, 12), key, rnd)
		PAL6(big, lcyl(big, fr, "W6Palette", (0, 0.8, 0), (0, 0.86, 0), 0.27, 12), key, rnd)
		PAL6(big, lcyl(big, fr, "W6Palette", (0, 0.86, 0), (0, 0.9, 0), 0.08, 8), "black", rnd)
	elif kind == "signpost":
		lcyl(big, fr, "W4PoleSteel", (0, 0.0, 0), (0, 2.8, 0), 0.05, 8)
		pal7(big, rbox(big, fr, "W7Palette", (0, 2.5, 0.07), (1.4, 0.55, 0.03)), "sign_blue", rnd)
		pal7(big, rbox(big, fr, "W7Palette", (0, 2.5, 0.09), (0.7, 0.1, 0.012)), "sign_white", rnd)
		for a in (40, -40):
			pal7(big, rbox(big, fr, "W7Palette", (0.28, 2.5, 0.09), (0.28, 0.09, 0.012), rot(rz=a)), "sign_white", rnd)
	elif kind in ("lamp_fallen", "lamp_leaning", "lit_lamp"):
		h, arm = {"lamp_fallen": (6.4, 1.0), "lamp_leaning": (6.8, 1.0), "lit_lamp": (5.2, 0.8)}[kind]
		lpipe(big, fr, "W4PoleSteel", [(0, 0.0, 0), (0, h * 0.5, 0), (0, h, 0)], 0.075, 8, True)
		lcyl(big, fr, "W4PoleSteel", (0, 0.0, 0), (0, 0.5, 0), 0.13, 8)
		lpipe(big, fr, "W4PoleSteel", [(0, h - 0.1, 0), (arm * 0.5, h - 0.04, 0), (arm, h - 0.1, 0)], 0.03, 6, True)
		rbox(big, fr, "W4FloodBody", (arm, h - 0.15, 0), (0.5, 0.12, 0.3))
		glass = "W7LampGlass" if kind == "lit_lamp" else "W4FloodBody"
		lface(big, fr, glass, [(arm - 0.22, h - 0.215, -0.12), (arm + 0.22, h - 0.215, -0.12), (arm + 0.22, h - 0.215, 0.12), (arm - 0.22, h - 0.215, 0.12)], (0, -1, 0))
	elif kind == "bench":
		rbox(big, fr, "W1Terrazzo", (0, 0.45, 0), (2.0, 0.1, 0.5))
		rbox(big, fr, "W1Terrazzo", (0, 0.78, 0.22), (2.0, 0.45, 0.08))
		for lx in (-0.8, 0.8):
			rbox(big, fr, "W1Concrete", (lx, 0.22, 0), (0.1, 0.45, 0.45))


def road_furniture(parts, rnd):
	"""Road/RoadBench0..2 and Road/FallenMoped0..2 (campus.tscn), on their colliders BenchBody* (2.4 x 0.8 x 0.6) and
	MopedBody* (1.8 x 0.6 x 1.1): the pilot's concrete bench and moped on its side."""
	for x, z in ((62.0, -22.0), (102.0, -22.0), (148.0, -22.0)):
		part = parts(x, z)[0]
		y = RP.surface_y(x, z)
		for dx in (-0.85, 0.85):
			part.gbox("W1Concrete", (x + dx - 0.08, y, z - 0.25), (x + dx + 0.08, G + 0.42, z + 0.25))
			part.gbox("W1Concrete", (x + dx - 0.08, G + 0.42, z + 0.18), (x + dx + 0.08, G + 0.8, z + 0.28))
		part.gbox("W1Terrazzo", (x - 1.18, G + 0.42, z - 0.28), (x + 1.18, G + 0.5, z + 0.18))
		part.gbox("W1Terrazzo", (x - 1.18, G + 0.55, z + 0.18), (x + 1.18, G + 0.79, z + 0.26))
	for x, z, colour in ((61.0, -11.0, "moped_blue"), (145.0, -18.0, "moped_red"), (225.0, -25.0, "moped_yellow")):
		part = parts(x, z)[0]
		y = RP.surface_y(x, z)
		lie = Matrix.Translation(B((x, y + 0.3, z + 0.07))) @ Matrix.Rotation(math.radians(8), 4, "Z") @ Matrix.Rotation(math.radians(88), 4, "X") @ \
			Matrix.Translation((0, 0, -0.55))
		for cx in (-0.62, 0.62):
			pal7(part, part.cylinder("W7Palette", (cx, 0.0, 0.3), 0.29, 0.09, axis="Y", segments=14, matrix=lie), "rubber", rnd)
			pal7(part, part.cylinder("W7Palette", (cx, -0.002, 0.3), 0.17, 0.095, axis="Y", segments=10, matrix=lie), "chrome", rnd)
		for lo, hi, key in (((-0.45, -0.17, 0.35), (0.35, 0.17, 0.62), colour), ((-0.5, -0.14, 0.62), (0.15, 0.14, 0.75), "seat"),
				((0.3, -0.12, 0.45), (0.55, 0.12, 0.95), colour), ((0.45, -0.32, 0.95), (0.52, 0.32, 0.99), "black"),
				((0.52, -0.08, 0.85), (0.6, 0.08, 0.95), "lamp_white"), ((-0.75, -0.08, 0.55), (-0.6, 0.08, 0.62), "lamp_red"),
				((-0.6, 0.14, 0.18), (0.05, 0.2, 0.26), "chrome"), ((0.5, -0.03, 0.3), (0.58, 0.03, 0.9), "black")):
			pal7(part, part.box("W7Palette", lo, hi, matrix=lie), key, rnd)


def build_rest_props():
	w1kit.reset()
	rnd = random.Random(26431)
	data = RP.load()
	replaced, objects = RP.classify(data)
	cells = {}

	def parts(x, z):
		key = (int(math.floor(x / CELL)), int(math.floor(z / CELL)))
		if key not in cells:
			tag = "%d_%d" % key
			cells[key] = (GPart("Props_" + tag), GPart("Small_" + tag), TP.Buf("Shrubs_" + tag))
		return cells[key]

	counts = {}
	for oid, kind, anchor in objects:
		counts[kind] = counts.get(kind, 0) + 1
		build_object(kind, anchor, parts(anchor[3][0], anchor[3][2]), rnd)
	road_furniture(parts, rnd)
	litter_cells = [(0.0, 0.5, 0.5, 1.0), (0.5, 0.5, 1.0, 1.0), (0.0, 0.0, 0.5, 0.5), (0.5, 0.0, 1.0, 0.5)]
	to_b = Matrix(((1, 0, 0), (0, 0, -1), (0, 1, 0)))
	for it in RP.instances(data):
		name, k, basis, origin, rgba, s = it
		kind = replaced.get((name, k), (None, None))[0]
		if kind not in ("rubble", "rod", "paper", "glass", "sandal", "shoe"):
			continue
		counts[kind] = counts.get(kind, 0) + 1
		x, y, z = origin
		dy = RP.surface_y(x, z) - G
		small = parts(x, z)[1]
		if kind == "rubble":
			mg = Matrix((Vector(basis[0]), Vector(basis[1]), Vector(basis[2]))).transposed()
			m = Matrix.Translation(B((x, y + dy, z))) @ (to_b @ mg @ to_b.inverted()).to_4x4() @ Matrix.Rotation(rnd.uniform(-0.15, 0.15), 4, "Z")
			parts(x, z)[0].box("W3Brick" if rnd.random() < 0.4 else "W1Concrete", (-0.5, -0.5, -0.5), (0.5, 0.5, 0.5), bevel=0.04, segments=1, matrix=m)
		elif kind == "rod":
			half = Vector(basis[1]) * 0.5
			o = Vector((x, y + dy, z))
			small.pipe("W1Rebar", [tuple(o - half), tuple(o + half)], 0.012, 6)
		elif kind == "paper":
			size = max(0.18, min(0.42, s[0] * 1.3))
			W5.litter_card(small, B((x, RP.surface_y(x, z) + 0.006, z)), rnd.uniform(0, math.tau), size, litter_cells[rnd.randrange(4)])
		elif kind == "glass":
			a = rnd.uniform(0, math.tau)
			sy = RP.surface_y(x, z) + 0.005
			pts = [(x + math.cos(a + d) * r * s[0], sy, z + math.sin(a + d) * r * s[2] * 1.4) for d, r in ((0.0, 0.6), (2.3, 0.55), (4.1, 0.45))]
			small.face("W7GlassDark", pts, (0, 1, 0))
		elif kind == "sandal":
			frame2, _ = W5.flat_item(small, x, z, W5.yaw_of(basis), (s[0] * 0.95, s[2] * 0.95), W5.tint_key(rgba), rnd)
			strap = []
			for sx in (-1, 1):
				pts = [(0.0, 0.006, s[2] * 0.22), (sx * s[0] * 0.38, 0.02, -s[2] * 0.02), (sx * s[0] * 0.46, 0.006, -s[2] * 0.08)]
				strap += small.pipe("W4Palette", [to_world(frame2, p) for p in pts], 0.004, 4, cap=False)
			W5.cell_uv(small, strap, "black", rnd)
		elif kind == "shoe":
			o, axes, sc = frame_of(basis, origin)
			W5.shoe(small, (Vector((o.x, o.y + dy, o.z)), axes, sc), W5.tint_key(rgba), rnd)
	print("T264_REST_PROPS", dict(sorted(counts.items())), "cells", len(cells))
	objs = []
	for key in sorted(cells):
		big, small, shrubs = cells[key]
		W5.retag(big)
		W5.retag(small)
		for p in (big, small):
			if p.bm.faces:
				p.bm.normal_update()
				objs.append(build(p))
		if shrubs.f:
			objs.append(shrubs.build())
	P.export("rest_props.glb", objs)


BUILDS = {"ground": build_ground, "fences": build_fences, "trees": build_trees, "lamp": build_lamp, "props": build_rest_props}

if __name__ == "__main__":
	random.seed(2643)
	args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for key in (args or list(BUILDS)):
		BUILDS[key]()
