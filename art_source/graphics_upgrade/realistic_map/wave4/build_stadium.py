"""T-261 round 2 (D-178): the whole stadium and the garden-to-stadium strip. Blender 5.2.2, bmesh only, no add-on.
Uses build_stadium_pilot.py's pieces the owner picked (field, goal, main stand S1 with its roof, L1 pole, H1 fence,
pillars) and adds:

  stand_south.glb           the south stand (SecondaryBleachers): 7 bare concrete tiers, two aisles, front wall, ends,
                            rear parapet, soffit; no roof, as PS1 (stadium space)
  fence_b40.glb, gate_pillars.glb   rebuilt for all twelve fences, the six gates and their twelve pillars
  stadium_props.glb         what lay in the stadium (props.tscn, D-178 question 7) where each PS1 piece lay: hurdles,
                            gym bags, backpacks, shoes, trays, crates under the main stand, papers, sandals, phones
  strip_garden_stadium.glb  the A16 strip (x 50..110, z -11..176): worn lawn, the paver road (WestBranch and the
                            access road to the west gate), concrete kerbs
  strip_stadium_props.glb   the strip's litter and its two rubble piles with their pipes
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave4/build_stadium.py [-- name ...]
"""
import json
import math
from pathlib import Path
import random
import sys

import bmesh  # noqa: F401
import bpy
from mathutils import Matrix, Vector

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE))
import build_stadium_pilot as P  # noqa: E402
import stadium_layout as L  # noqa: E402

w1kit = P.w1kit
GPart, B, G, OUT, build, export, set_uv = P.GPart, P.B, P.G, P.OUT, P.build, P.export, P.set_uv
P.PREVIEW.update({"W4Palette": ((0.6, 0.6, 0.6), 0.6), "W1Wood": ((0.45, 0.32, 0.2), 0.8), "W3Litter": ((0.85, 0.85, 0.8), 0.9),
	"W4StripGround": ((0.2, 0.25, 0.12), 0.95), "W4RoadPavers": ((0.5, 0.49, 0.46), 0.9), "W3Brick": ((0.6, 0.36, 0.27), 0.9),
	"W1Rebar": ((0.3, 0.2, 0.15), 0.6)})
PALETTE = json.loads((HERE / "palette.json").read_text(encoding="utf-8"))


def ps1():
	return json.loads(L.W4_PS1_PROPS.read_text(encoding="utf-8"))


# ------------------------------------------------------------------------------------------------ south stand

def build_south():
	w1kit.reset()
	S = L.SOUTH
	t, r = S["tread"], S["riser"]
	M = "W4StandConcrete"

	def top(k):
		return S["tread0_top"] + r * k

	def front(k):
		return S["z0"] - t * k  # tread k's front edge (towards the track, +z); its back is front(k + 1)

	def v_of(k, extra):
		return (1.1 + k * 1.23 + extra) / P.PROFILE

	def u_of(x):
		bay = max(0, min(5, int((x - S["x"][0]) // 10.0)))
		return (bay % 2) * 0.4 + (x - (S["x"][0] + 10.0 * bay)) / 10.0 * 0.4, bay

	edges = [S["x"][0]] + [v for a in S["aisles"] for v in a] + [S["x"][1]]
	spans = [(edges[i], edges[i + 1], False) for i in range(0, len(edges), 2)] + [(a, b, True) for a, b in S["aisles"]]

	def cuts(x0, x1):
		c = [x0] + [S["x"][0] + 10.0 * i for i in range(1, 6) if x0 < S["x"][0] + 10.0 * i < x1] + [x1]
		return list(zip(c, c[1:]))

	steps = GPart("Steps")
	for k in range(S["tiers"]):
		y1 = top(k)
		y0 = y1 - r if k > 0 else G
		z0, z1 = front(k), front(k + 1)
		if k == 0:
			z0 = S["front_wall"]["z"][0]
		for sx0, sx1, aisle in spans:
			for x0, x1 in cuts(sx0, sx1):
				if not aisle:
					c = P.NOSING
					f = steps.face(M, [(x0, y0, z0), (x1, y0, z0), (x1, y1 - c, z0), (x0, y1 - c, z0)], (0, 0, 1))
					steps.map_uv2([f], lambda p, k=k: (u_of(p[0])[0], v_of(k, (p[1] - (top(k) - r)) * 0.95)))
					f = steps.face(M, [(x0, y1 - c, z0), (x1, y1 - c, z0), (x1, y1, z0 - c), (x0, y1, z0 - c)], (0, 1, 1))
					steps.map_uv2([f], lambda p, k=k: (u_of(p[0])[0], v_of(k, 0.37)))
					f = steps.face(M, [(x0, y1, z0 - c), (x0, y1, z1), (x1, y1, z1), (x1, y1, z0 - c)], (0, 1, 0))
					steps.map_uv2([f], lambda p, k=k: (u_of(p[0])[0], v_of(k, 0.38 + (front(k) - p[2]) * 0.94)))
				else:
					ym = (y0 + y1) / 2 if k > 0 else y1 - r / 2
					zm = (z0 + z1) / 2
					for ya, yb, za, zb in ((y0, ym, z0, zm), (ym, y1, zm, z1)):
						f = steps.face(M, [(x0, ya, za), (x1, ya, za), (x1, yb, za), (x0, yb, za)], (0, 0, 1))
						steps.map_uv2([f], lambda p, k=k: (u_of(p[0])[0], v_of(k, 0.2)))
						f = steps.face(M, [(x0, yb, za), (x0, yb, zb), (x1, yb, zb), (x1, yb, za)], (0, 1, 0))
						steps.map_uv2([f], lambda p, k=k: (u_of(p[0])[0], v_of(k, 0.38 + (front(k) - p[2]) * 0.94)))
	fz0, fz1 = S["front_wall"]["z"]
	for x0, x1 in S["front_wall"]["x"]:
		for a, b in cuts(x0, x1):
			faces = steps.gbox(M, (a, G, fz0), (b, -8.8, fz1))
			steps.map_uv2(faces, lambda p: (u_of(p[0])[0], (p[1] - G) / P.PROFILE))
		steps.gbox("W1Concrete", (x0 - 0.02, -8.8, fz0 - 0.04), (x1 + 0.02, -8.72, fz1 + 0.04))
	back = front(S["tiers"])  # 113.2
	soffit_back = L.south_ramp_y(back) - 0.42
	(top0, top1) = S["end_top"]
	for (xa, xb), xe, outward in ((S["ends"][0], S["x"][0], -1.0), (S["ends"][1], S["x"][1], 1.0)):
		prof = [(fz0, G)]
		for k in range(S["tiers"]):
			prof += [(front(k), top(k)), (front(k + 1), top(k))]
		prof += [(back, soffit_back)]
		steps.face("W1Concrete", [(xe, y, z) for z, y in prof], (outward, 0, 0))
		bottom = [(fz0, G + 0.9)]
		for k in range(1, S["tiers"]):
			bottom += [(front(k), top(k - 1) - 0.05), (front(k), top(k) - 0.05)]
		bottom += [(back, top(S["tiers"] - 1) - 0.05)]
		for xs, side in ((xa, -1.0), (xb, 1.0)):
			steps.face(M, [(xs, y, z) for z, y in bottom] + [(xs, top1[1], back), (xs, top0[1], top0[0])], (side, 0, 0))
		steps.face(M, [(xa, top0[1], top0[0]), (xb, top0[1], top0[0]), (xb, top1[1], back), (xa, top1[1], back)], (0, 1, 0.45))
		steps.face(M, [(xa, bottom[0][1], bottom[0][0]), (xb, bottom[0][1], bottom[0][0]), (xb, top0[1], top0[0]), (xa, top0[1], top0[0])], (0, 0, 1))
	steps.gbox(M, (S["x"][0] - 0.3, top(S["tiers"] - 1), S["rear"]["z"][0]), (S["x"][1] + 0.3, S["rear"]["y_top"], S["rear"]["z"][1]))
	objs = [build(steps, {"W1Concrete": 1.0})]
	structure = GPart("Structure")
	for x0, x1 in cuts(*S["x"]):
		structure.face("W1Concrete", [(x0, G, fz0), (x0, soffit_back, back), (x1, soffit_back, back), (x1, G, fz0)], (0, -1, -0.45))
	# Rear edge beam under the parapet, 2.1 m over the ground at its lowest.
	structure.gbox("W1Concrete", (S["x"][0] - 0.3, soffit_back - 0.3, S["rear"]["z"][0]), (S["x"][1] + 0.3, soffit_back + 0.05, back + 0.3))
	objs.append(build(structure, {"W1Concrete": 1.0}))
	export(OUT / "stand_south.glb", objs)


# ------------------------------------------------------------------------------------------------ fences, pillars

def build_fences():
	L.PILOT_FENCES = list(L.FENCES)
	L.PILOT_GATES = list(L.GATES)
	P.build_fence("b40")
	P.build_pillars()


# ------------------------------------------------------------------------------------------------ props

def frame_of(basis, origin):
	"""(origin Vector, x, y, z unit axes, scales) of a PS1 instance in Godot coordinates."""
	cols = [Vector(c) for c in basis]
	scales = [c.length for c in cols]
	axes = [c / s if s > 1e-9 else c for c, s in zip(cols, scales)]
	return Vector(origin), axes, scales


def to_world(frame, local):
	o, (ax, ay, az), _ = frame
	p = o + ax * local[0] + ay * local[1] + az * local[2]
	return (p.x, p.y, p.z)


def cell_uv(part, faces, key, rnd):
	"""Faces into one palette cell. bmesh operators run later (bevels) clear face tags, so the faces are kept on the
	part and tagged again just before it is built (retag)."""
	cx, cy = PALETTE[key]
	if not hasattr(part, "painted"):
		part.painted = []
	part.painted += list(faces)
	for f in faces:
		ju, jv = rnd.uniform(0.2, 0.8), rnd.uniform(0.2, 0.8)
		for loop in f.loops:
			co = loop.vert.co
			du = ((co.x * 7.3 + co.z * 3.1) % 1.0) * 0.15
			dv = ((co.y * 5.7 + co.z * 2.3) % 1.0) * 0.15
			loop[part.uv].uv = ((cx + ju + du - 0.075) / 8.0, 1.0 - (cy + jv + dv - 0.075) / 8.0)
		f.tag = True


def retag(part):
	for f in getattr(part, "painted", []):
		if f.is_valid:
			f.tag = True


def tint_key(rgba):
	return "%g,%g,%g" % tuple(round(t, 3) for t in rgba[:3])


def lbox(part, frame, mat, lo, hi):
	"""A box in an instance's local frame (Godot axes), returned as faces."""
	corners = [(x, y, z) for x in (lo[0], hi[0]) for y in (lo[1], hi[1]) for z in (lo[2], hi[2])]
	w = [to_world(frame, c) for c in corners]
	quads = [(0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3)]
	verts = [B(p) for p in w]
	return part.poly(mat, [tuple(v) for v in verts], quads)


def lpipe(part, frame, mat, a, b, radius, sides=6):
	return part.pipe(mat, [to_world(frame, a), to_world(frame, b)], radius, sides)


def surface_y(x, z):
	"""Top of the new floor at (x, z): track, infield, apron (stadium) or the ground under the main stand."""
	if L.inside_track(x, z, L.TRACK_R_IN):
		return L.PITCH_Y
	if L.inside_track(x, z, L.TRACK_R_OUT):
		return L.TRACK_Y
	return G + 0.004


def hurdle(part, frame, rnd):
	"""PS1 hurdle frame: posts at x +-0.55, top bar at 0.84. Steel uprights on L-shaped feet with counterweights,
	a red and white striped top board."""
	faces = []
	for x in (-0.55, 0.55):
		faces += lpipe(part, frame, "W4Palette", (x, 0.04, 0.0), (x, 0.80, 0.0), 0.016)
		faces += lbox(part, frame, "W4Palette", (x - 0.02, 0.0, -0.66), (x + 0.02, 0.04, 0.03))
		faces += lbox(part, frame, "W4Palette", (x - 0.05, 0.0, -0.62), (x + 0.05, 0.07, -0.5))
	cell_uv(part, faces, "steel", rnd)
	for i in range(6):
		x0 = -0.6 + i * 0.2
		f = lbox(part, frame, "W4Palette", (x0, 0.80, -0.012), (x0 + 0.2, 0.875, 0.012))
		cell_uv(part, f, "hurdle_red" if i % 2 == 0 else "hurdle_white", rnd)


def duffel(part, frame, key, rnd):
	o, axes, s = frame
	faces = []
	segs = 10
	length, ry, rz = s[0] * 0.48, s[1] * 0.5, s[2] * 0.5
	rings = []
	for i, x in enumerate((-length, -length * 0.92, length * 0.92, length)):
		shrink = 0.82 if i in (0, 3) else 1.0
		rings.append([(x, math.sin(a) * ry * shrink, math.cos(a) * rz * shrink) for a in (j / segs * math.tau for j in range(segs))])
	ax, ay, az = axes

	def world_dir(d):
		v = ax * d[0] + ay * d[1] + az * d[2]
		return (v.x, v.y, v.z)

	for ra, rb in zip(rings, rings[1:]):
		for j in range(segs):
			k = (j + 1) % segs
			a = (j + 0.5) / segs * math.tau
			faces.append(part.face("W4Palette", [to_world(frame, ra[j]), to_world(frame, rb[j]), to_world(frame, rb[k]), to_world(frame, ra[k])],
				world_dir((0.0, math.sin(a), math.cos(a)))))
	for ring, sign in ((rings[0], -1.0), (rings[-1], 1.0)):
		faces.append(part.face("W4Palette", [to_world(frame, p) for p in ring], world_dir((sign, 0.0, 0.0))))
	cell_uv(part, faces, key, rnd)
	handle = []
	for z in (-0.06, 0.06):
		pts = [(-0.12, ry * 0.9, z), (-0.07, ry + 0.07, z), (0.07, ry + 0.07, z), (0.12, ry * 0.9, z)]
		handle += part.pipe("W4Palette", [to_world(frame, p) for p in pts], 0.008, 4, cap=False)
	cell_uv(part, handle, "black", rnd)


def rounded(part, frame, key, size, rnd, bevel=0.025):
	"""A bevelled block of the instance's size (backpacks, pockets, shoes' uppers)."""
	hx, hy, hz = size[0] / 2, size[1] / 2, size[2] / 2
	lo = (-hx, -hy, -hz)
	hi = (hx, hy, hz)
	m = Matrix.Identity(4)
	o, axes, _ = frame
	bx, by, bz = (B((a.x, a.y + G, a.z)) for a in axes)
	m = Matrix(((bx.x, by.x, bz.x, 0), (bx.y, by.y, bz.y, 0), (bx.z, by.z, bz.z, 0), (0, 0, 0, 1)))
	m = Matrix.Translation(B(o)) @ m
	faces = part.box("W4Palette", lo, hi, bevel=min(bevel, min(size) * 0.4), segments=1, matrix=m)
	cell_uv(part, faces, key, rnd)
	return faces


def backpack(part, frame, key, rnd):
	o, axes, s = frame
	rounded(part, frame, key, (s[0] * 0.95, s[1] * 0.98, s[2] * 0.9), rnd, 0.05)
	straps = []
	for x in (-0.08, 0.08):
		pts = [(x, s[1] * 0.42, -s[2] * 0.45), (x, s[1] * 0.1, -s[2] * 0.7), (x, -s[1] * 0.38, -s[2] * 0.5)]
		straps += part.pipe("W4Palette", [to_world(frame, p) for p in pts], 0.012, 4, cap=False)
	cell_uv(part, straps, "black", rnd)


def shoe(part, frame, key, rnd):
	o, axes, s = frame
	sole = lbox(part, frame, "W4Palette", (-s[0] * 0.5, -s[1] * 0.5, -s[2] * 0.48), (s[0] * 0.5, -s[1] * 0.18, s[2] * 0.48))
	cell_uv(part, sole, "sole", rnd)
	rounded(part, (o + axes[1] * s[1] * 0.12 - axes[0] * s[0] * 0.06, axes, s), key, (s[0] * 0.8, s[1] * 0.62, s[2] * 0.86), rnd, 0.03)


def flat_item(part, x, z, yaw, size, key, rnd, thick=0.012):
	"""Sandal / phone / tray-like flat piece lying on the new floor at (x, z)."""
	y = surface_y(x, z)
	frame = (Vector((x, y + thick / 2 + 0.003, z)), [Vector((math.cos(yaw), 0, -math.sin(yaw))), Vector((0, 1, 0)),
		Vector((math.sin(yaw), 0, math.cos(yaw)))], (1, 1, 1))
	return frame, rounded(part, frame, key, (size[0], thick, size[1]), rnd, thick * 0.45)


def yaw_of(basis):
	x = Vector(basis[0])
	return math.atan2(-x.z, x.x)


def build_stadium_props():
	w1kit.reset()
	rnd = random.Random(2611)
	part = GPart("Props")
	wood = GPart("Crates")
	litter = P.GPart("Litter")
	counts = {}
	cells = [(0.0, 0.5, 0.5, 1.0), (0.5, 0.5, 1.0, 1.0), (0.0, 0.0, 0.5, 0.5), (0.5, 0.0, 1.0, 0.5)]
	for name, entry in ps1().items():
		for basis, origin, rgba in L.instances(entry["data"]):
			kind = L.prop_kind(name, basis, origin)
			if kind is None:
				continue
			counts[kind] = counts.get(kind, 0) + 1
			frame = frame_of(basis, origin)
			o, axes, s = frame
			key = tint_key(rgba)
			if kind == "hurdle_bar":
				# The frame's origin is on the ground under the bar (bar at 0.84 m up its frame).
				hurdle(part, (o - axes[1] * 0.84, axes, s), rnd)
			elif kind == "gym_bag":
				duffel(part, frame, key, rnd)
			elif kind == "backpack":
				backpack(part, frame, key, rnd)
			elif kind == "backpack_pocket":
				rounded(part, frame, key, (s[0] * 0.9, s[1] * 0.95, s[2] * 1.4), rnd, 0.025)
			elif kind == "shoe":
				shoe(part, frame, key, rnd)
			elif kind == "tray":
				base = lbox(part, frame, "W4Palette", (-s[0] / 2, -s[1] / 2, -s[2] / 2), (s[0] / 2, -s[1] / 2 + 0.006, s[2] / 2))
				rims = []
				for lo, hi in (((-s[0] / 2, -s[1] / 2, -s[2] / 2), (s[0] / 2, s[1] / 2, -s[2] / 2 + 0.008)),
						((-s[0] / 2, -s[1] / 2, s[2] / 2 - 0.008), (s[0] / 2, s[1] / 2, s[2] / 2)),
						((-s[0] / 2, -s[1] / 2, -s[2] / 2), (-s[0] / 2 + 0.008, s[1] / 2, s[2] / 2)),
						((s[0] / 2 - 0.008, -s[1] / 2, -s[2] / 2), (s[0] / 2, s[1] / 2, s[2] / 2))):
					rims += lbox(part, frame, "W4Palette", lo, hi)
				cell_uv(part, base + rims, key, rnd)
			elif kind == "tray_paper":
				f = lbox(part, frame, "W4Palette", (-s[0] / 2, -0.002, -s[2] / 2), (s[0] / 2, 0.002, s[2] / 2))
				cell_uv(part, f, "napkin", rnd)
			elif kind == "crate":
				# Slatted wooden crate inside the PS1 box (the pile keeps its collider).
				hx, hy, hz = s[0] / 2, s[1] / 2, s[2] / 2
				for sx in (-1, 1):
					for sz in (-1, 1):
						lbox(wood, frame, "W1Wood", (sx * hx - (0.05 if sx > 0 else 0) , -hy, sz * hz - (0.05 if sz > 0 else 0)),
							(sx * hx + (0.05 if sx < 0 else 0), hy, sz * hz + (0.05 if sz < 0 else 0)))
				for j in range(3):
					y0 = -hy + 0.03 + j * (s[1] - 0.06) / 3
					y1 = y0 + (s[1] - 0.06) / 3 - 0.04
					lbox(wood, frame, "W1Wood", (-hx, y0, -hz), (hx, y1, -hz + 0.02))
					lbox(wood, frame, "W1Wood", (-hx, y0, hz - 0.02), (hx, y1, hz))
					lbox(wood, frame, "W1Wood", (-hx, y0, -hz), (-hx + 0.02, y1, hz))
					lbox(wood, frame, "W1Wood", (hx - 0.02, y0, -hz), (hx, y1, hz))
				lbox(wood, frame, "W1Wood", (-hx, -hy, -hz), (hx, -hy + 0.02, hz))
				for j in range(4):
					x0 = -hx + j * s[0] / 4 + 0.01
					lbox(wood, frame, "W1Wood", (x0, hy - 0.02, -hz), (x0 + s[0] / 4 - 0.03, hy, hz))
			elif kind == "paper":
				x, _, z = origin
				size = max(0.18, min(0.34, s[0] * 1.3))
				a = rnd.uniform(0, math.tau)
				at = B((x, surface_y(x, z) + 0.006, z))
				P_card(litter, at, a, size, cells[rnd.randrange(4)])
			elif kind == "sandal":
				x, _, z = origin
				frame2, _ = flat_item(part, x, z, yaw_of(basis), (s[0] * 0.95, s[2] * 0.95), key, rnd)
				strap = []
				for sx in (-1, 1):
					pts = [(0.0, 0.006, s[2] * 0.22), (sx * s[0] * 0.38, 0.02, -s[2] * 0.02), (sx * s[0] * 0.46, 0.006, -s[2] * 0.08)]
					strap += part.pipe("W4Palette", [to_world(frame2, p) for p in pts], 0.004, 4, cap=False)
				cell_uv(part, strap, "black", rnd)
			elif kind == "phone":
				x, _, z = origin
				frame2, _ = flat_item(part, x, z, yaw_of(basis), (s[0], s[2]), "black", rnd, 0.009)
				f = lbox(part, frame2, "W4Palette", (-s[0] * 0.44, 0.0045, -s[2] * 0.45), (s[0] * 0.44, 0.0055, s[2] * 0.45))
				cell_uv(part, f, "screen", rnd)
	print("T261_PROPS", counts)
	retag(part)
	objs = [build(part, {"W4Palette": 1.0}), build(wood, {"W1Wood": 1.0})]
	if litter.bm.faces:
		objs.append(build(litter))
	export(OUT / "stadium_props.glb", objs)


# ------------------------------------------------------------------------------------------------ the A16 strip

GROUND_TOP = -9.93  # 1 cm over the PS1 ground tiles (-9.94), as wave 3's lawn
ROAD_TOP = -9.87  # the PS1 road's top: the PS1 cracks (decals, kept) lie on it as before
KERB_TOP = -9.84
X0, X1 = L.A16_BOX["x"]
Z0, Z1 = L.A16_BOX["z"]
WEST = (76.0, 84.0)  # Road/WestBranch x, z up to 169
ACCESS = (163.0, 169.0)  # Road/StadiumWestAccess z, x 84..110
KERB = 0.15


def strip_uv2(p):
	return ((p[0] - X0) / (X1 - X0), (p[2] - Z0) / (Z1 - Z0))


def grid(part, mat, x0, z0, x1, z1, y, cell=4.0):
	nx = max(1, int(round((x1 - x0) / cell)))
	nz = max(1, int(round((z1 - z0) / cell)))
	verts, quads = [], []
	for b in range(nz + 1):
		for a in range(nx + 1):
			verts.append(tuple(B((x0 + (x1 - x0) * a / nx, y, z0 + (z1 - z0) * b / nz))))
	for b in range(nz):
		for a in range(nx):
			k = b * (nx + 1) + a
			quads.append((k, k + 1, k + nx + 2, k + nx + 1))
	faces = part.poly(mat, verts, quads, recalc=False)
	for f in faces:
		f.normal_update()
		if f.normal.z < 0:
			f.normal_flip()
	return faces


def build_strip():
	w1kit.reset()
	ground = GPart("Ground")
	w0, w1 = WEST[0] - KERB, WEST[1] + KERB
	a0, a1 = ACCESS[0] - KERB, ACCESS[1] + KERB
	faces = []
	for x0, z0, x1, z1 in ((X0, Z0, w0, Z1), (w1, Z0, X1, a0), (w0, a1, X1, Z1)):
		faces += grid(ground, "W4StripGround", x0, z0, x1, z1, GROUND_TOP)
	ground.map_uv2(faces, strip_uv2)
	objs = [build(ground, {"W4StripGround": 1.0})]
	road = GPart("Road")
	faces = grid(road, "W4RoadPavers", WEST[0], Z0, WEST[1], ACCESS[1], ROAD_TOP, 2.0)
	faces += grid(road, "W4RoadPavers", WEST[1], ACCESS[0], X1, ACCESS[1], ROAD_TOP, 2.0)
	road.map_uv2(faces, strip_uv2)
	objs.append(build(road, {"W4RoadPavers": 0.9}))
	kerb = GPart("Kerbs")
	for lo, hi in (((w0, GROUND_TOP - 0.05, Z0), (WEST[0], KERB_TOP, a1)),  # west side of WestBranch, round its end
			((WEST[1], GROUND_TOP - 0.05, Z0), (w1, KERB_TOP, a0)),  # east side, to the access road
			((w0, GROUND_TOP - 0.05, ACCESS[1]), (X1, KERB_TOP, a1)),  # north side of both
			((w1, GROUND_TOP - 0.05, a0), (X1, KERB_TOP, ACCESS[0]))):  # south side of the access road
		kerb.gbox("W1Concrete", lo, hi, bevel=0.01)
	objs.append(build(kerb, {"W1Concrete": 0.8}))
	export(OUT / "strip_garden_stadium.glb", objs)


def strip_height(x, z):
	on_road = (WEST[0] <= x <= WEST[1] and z <= ACCESS[1]) or (x >= WEST[1] and ACCESS[0] <= z <= ACCESS[1])
	return (ROAD_TOP if on_road else GROUND_TOP) + 0.006


def build_strip_props():
	w1kit.reset()
	rnd = random.Random(2612)
	litter = P.GPart("Litter")
	rubble = w1kit.Part("Rubble")
	pipes = GPart("Pipes")
	cells = [(0.0, 0.5, 0.5, 1.0), (0.5, 0.5, 1.0, 1.0), (0.0, 0.0, 0.5, 0.5), (0.5, 0.0, 1.0, 0.5)]
	to_b = Matrix(((1, 0, 0), (0, 0, -1), (0, 1, 0)))
	count = {}
	for name, entry in ps1().items():
		for basis, origin, rgba in L.instances(entry["data"]):
			kind = None if L.prop_kind(name, basis, origin) else L.a16_kind(name, basis, origin)
			if kind is None:
				continue
			count[kind] = count.get(kind, 0) + 1
			x, y, z = origin
			if kind == "litter":
				size = max(0.18, min(0.42, Vector(basis[0]).length * 1.1))
				a = rnd.uniform(0, math.tau)
				cell = cells[rnd.randrange(4)]
				# T-262 (D-180): a skin-tinted 0.22 m box is a corpse's head, not paper: no card there (the random draws stay
				# the same, so every other card keeps its look); patch_gate.py gives the head back in props.tscn.
				if tint_key(rgba) != "0.9,0.7,0.6":
					P_card(litter, B((x, strip_height(x, z), z)), a, size, cell)
			elif kind == "rubble":
				mg = Matrix((Vector(basis[0]), Vector(basis[1]), Vector(basis[2]))).transposed()
				mb = to_b @ mg @ to_b.inverted()
				m = Matrix.Translation(B(origin)) @ mb.to_4x4() @ Matrix.Rotation(rnd.uniform(-0.15, 0.15), 4, "Z")
				rubble.box("W3Brick" if rnd.random() < 0.45 else "W1Concrete", (-0.5, -0.5, -0.5), (0.5, 0.5, 0.5), bevel=0.04, segments=1, matrix=m)
			else:  # rubble pipe
				ax = Vector(basis[1])
				half = ax * 0.5
				radius = max(0.012, Vector(basis[0]).length * 0.5)
				pipes.pipe("W1Rebar", [tuple(Vector(origin) - half), tuple(Vector(origin) + half)], radius, 8)
	for (cx, cz), r in L.A16_RUBBLE:  # loose bricks on and round each pile
		for k in range(12):
			rr = rnd.uniform(0, 1) ** 0.7
			a = rnd.uniform(0, math.tau)
			px, pz = cx + math.cos(a) * rr * r * 0.9, cz + math.sin(a) * rr * r * 0.9
			s = rnd.uniform(0.6, 1.0)
			m = Matrix.Translation(B((px, GROUND_TOP + 0.03 + 0.4 * (1 - rr) ** 1.5 * rnd.uniform(0.3, 1.0), pz))) @ \
				Matrix.Rotation(rnd.uniform(0, math.tau), 4, "Z") @ Matrix.Rotation(rnd.uniform(-0.6, 0.6), 4, "X")
			rubble.box("W3Brick", (-0.11 * s, -0.052 * s, -0.03), (0.11 * s, 0.052 * s, 0.03), bevel=0.006, segments=1, matrix=m)
	print("T261_STRIP_PROPS", count)
	objs = [litter_build(litter), rubble.build(uv_size={"W3Brick": 0.8, "W1Concrete": 0.8}), build(pipes, {"W1Rebar": 1.0})]
	export(OUT / "strip_stadium_props.glb", [o for o in objs if o is not None])


# Litter cards (wave 3's W3Litter atlas: a page, a flyer, crumpled paper, a bag), lying flat.
def P_card(part, at, angle, size, cell):
	u0, v0, u1, v1 = cell
	d = Vector((math.cos(angle), math.sin(angle), 0.0)) * size * 0.5
	n = Vector((-math.sin(angle), math.cos(angle), 0.0)) * size * 0.5
	pts = [at - d - n, at + d - n, at + d + n, at - d + n]
	verts = [part.bm.verts.new(p) for p in pts]
	f = part.bm.faces.new(verts)
	f.material_index = part.slot("W3Litter")
	for loop, uv in zip(f.loops, [(u0, v0), (u1, v0), (u1, v1), (u0, v1)]):
		loop[part.uv].uv = uv
	f.tag = True
	return f


def litter_build(part):
	return build(part) if part.bm.faces else None


TARGETS = {"south": build_south, "fences": build_fences, "props": build_stadium_props, "strip": build_strip,
	"strip_props": build_strip_props}


if __name__ == "__main__":
	args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for key in (args or TARGETS):
		TARGETS[key]()
