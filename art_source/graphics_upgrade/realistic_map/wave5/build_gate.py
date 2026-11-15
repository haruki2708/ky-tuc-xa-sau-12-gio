"""T-262 round 2 (D-180): the gate (A14) with the picked options, the whole south wall and the A16 gate strip. Blender
5.2.2, bmesh only, no add-on, no Tripo. Uses build_gate_pilot.py's pieces the owner picked (C2 court, the outside strip,
the cracks, P1 pillars, G1 gate, SA sign with text, K1 booth) and adds:

  booth_interior.glb      K1's interior in one atlas material (W5BoothAtlas): desk, plastic chair, log book, phone,
                          flask, cup, fan, CCTV monitor, cap, calendar, key box and the terrazzo floor
  wall_south.glb          W1 along all of Fence/S (x -80..420 less the gate, D-180 question 6): rendered panels and posts
                          (Solid_NN), iron bars near (BarsNear_NN), one flat bar card per panel far (BarsFar_NN); a mesh
                          each per 30 m chunk; gate_real.gd sets the near/far draw distances
  strip_gate.glb          the A16 gate box (x 180..262, z -60..13): worn lawn, the paved walk from the court to the box's
                          edge towards the canteen, the Avenue's last 37 m paved, kerbs and edging
  strip_gate_props.glb    where each PS1 piece lay (main's props.tscn, w5_ps1_props.json): the five cars (an old sedan
                          in the PS1 car's colour, on its 4.4 x 1.5 x 1.9 m collider), the two barricades, the six cones,
                          the dropped backpacks, shoes, sandals and phones (wave 4's palette), the papers (wave 3's litter
                          cards) and the rubble pile with its rods
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave5/build_gate.py [-- name ...]
(after patch_gate.py data, which writes w5_ps1_props.json from main's props.tscn)
"""
import json
import math
from pathlib import Path
import random
import sys

import bpy  # noqa: F401
from mathutils import Matrix, Vector

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE.parent / "wave1"))
sys.path.insert(0, str(HERE))
import build_gate_pilot as P5  # noqa: E402
import gate_layout as L  # noqa: E402
import list_a16_box as A16  # noqa: E402

w1kit = P5.w1kit
GPart, B, G, OUT, build, export, set_uv, ensure_uv2 = P5.GPart, P5.B, P5.G, P5.OUT, P5.build, P5.export, P5.set_uv, P5.ensure_uv2
P5.PREVIEW.update({"W5BarsCard": ((0.3, 0.42, 0.34), 0.55), "W5BoothAtlas": ((0.5, 0.45, 0.4), 0.6), "W5StripGround": ((0.2, 0.25, 0.12), 0.95),
	"W5CarRed": ((0.5, 0.09, 0.06), 0.42), "W5CarBlue": ((0.11, 0.2, 0.46), 0.42), "W5CarWhite": ((0.7, 0.7, 0.68), 0.42),
	"W5CarGrey": ((0.19, 0.2, 0.23), 0.42), "W5CarGlass": ((0.035, 0.045, 0.05), 0.08), "W5CarLamp": ((0.66, 0.66, 0.62), 0.15),
	"W5CarTail": ((0.42, 0.04, 0.03), 0.25), "W4Palette": ((0.6, 0.6, 0.6), 0.6), "W3Litter": ((0.85, 0.85, 0.8), 0.9),
	"W3Brick": ((0.6, 0.36, 0.27), 0.9), "W1Rebar": ((0.3, 0.2, 0.15), 0.6), "W1Rubber": ((0.12, 0.1, 0.1), 0.85),
	"W1Black": ((0.03, 0.03, 0.03), 0.6), "W1Steel": ((0.6, 0.6, 0.58), 0.38), "W4PoleSteel": ((0.55, 0.56, 0.55), 0.45)})
PALETTE = json.loads((HERE.parent / "wave4" / "palette.json").read_text(encoding="utf-8"))
PS1 = HERE / "w5_ps1_props.json"
CAR_PAINT = {"red": "W5CarRed", "blue": "W5CarBlue", "white": "W5CarWhite", "grey": "W5CarGrey"}


def ps1():
	return json.loads(PS1.read_text(encoding="utf-8"))


def instances(values):
	for k in range(0, len(values), 16):
		v = values[k:k + 16]
		yield k // 16, (v[0:3], v[3:6], v[6:9]), tuple(v[9:12]), tuple(v[12:16])


def surface_y(x, z):
	"""Top of the new floor at (x, z): the court and the walk (G), the road (ROAD_TOP) or the lawn (GROUND_TOP)."""
	if 190.0 <= x <= 250.0 and -60.0 <= z <= -20.0:
		return G
	r = L.ROAD
	if r["x"][0] <= x <= r["x"][1] and r["z"][0] <= z <= r["z"][1]:
		return L.ROAD_TOP
	for w in (L.WALK_N, L.WALK_W):
		if w["x"][0] <= x <= w["x"][1] and w["z"][0] <= z <= w["z"][1]:
			return G
	return L.GROUND_TOP


# ------------------------------------------------------------------------------------------------ frames, palette

def frame_of(basis, origin):
	cols = [Vector(c) for c in basis]
	scales = [c.length for c in cols]
	axes = [c / s if s > 1e-9 else c for c, s in zip(cols, scales)]
	return Vector(origin), axes, scales


def yaw_frame(x, y, z, yaw_deg):
	"""A frame on the ground turned yaw degrees about y (Godot Basis(Vector3.UP, yaw), as the PS1 props and colliders)."""
	a = math.radians(yaw_deg)
	return Vector((x, y, z)), [Vector((math.cos(a), 0, -math.sin(a))), Vector((0, 1, 0)), Vector((math.sin(a), 0, math.cos(a)))], (1, 1, 1)


def to_world(frame, local):
	o, (ax, ay, az), _ = frame
	p = o + ax * local[0] + ay * local[1] + az * local[2]
	return (p.x, p.y, p.z)


def world_dir(frame, d):
	_, (ax, ay, az), _ = frame
	v = ax * d[0] + ay * d[1] + az * d[2]
	return (v.x, v.y, v.z)


def lface(part, frame, m, pts, normal, uv=None):
	return part.face(m, [to_world(frame, p) for p in pts], world_dir(frame, normal), uv)


def lbox(part, frame, m, lo, hi):
	"""A box in a frame (local Godot axes), outward faces."""
	x0, y0, z0 = lo
	x1, y1, z1 = hi
	sides = [([(x0, y0, z0), (x0, y0, z1), (x0, y1, z1), (x0, y1, z0)], (-1, 0, 0)), ([(x1, y0, z0), (x1, y1, z0), (x1, y1, z1), (x1, y0, z1)], (1, 0, 0)),
		([(x0, y0, z0), (x1, y0, z0), (x1, y0, z1), (x0, y0, z1)], (0, -1, 0)), ([(x0, y1, z0), (x0, y1, z1), (x1, y1, z1), (x1, y1, z0)], (0, 1, 0)),
		([(x0, y0, z0), (x0, y1, z0), (x1, y1, z0), (x1, y0, z0)], (0, 0, -1)), ([(x0, y0, z1), (x1, y0, z1), (x1, y1, z1), (x0, y1, z1)], (0, 0, 1))]
	return [lface(part, frame, m, pts, n) for pts, n in sides]


def lpipe(part, frame, m, pts, radius, sides=6, cap=True):
	return part.pipe(m, [to_world(frame, p) for p in pts], radius, sides, cap)


def cell_uv(part, faces, key, rnd):
	"""Faces into one wave-4 palette cell (8 x 8); bevels clear face tags, so painted faces are re-tagged at build."""
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


# ------------------------------------------------------------------------------------------------ booth interior

ATLAS = {"wood": (0, 0), "floor": (1, 0), "pages": (2, 0), "calendar": (3, 0), "plastic": (0, 1), "spine": (1, 1), "ivory": (2, 1),
	"enamel": (3, 1), "black": (0, 2), "steel": (1, 2), "alu": (2, 2), "cap": (3, 2)}  # make_wave5_textures.ATLAS_CELLS


def atlas(part, faces, key, fill=False):
	"""Faces into a 128 px cell of booth_atlas.png (4 x 4): flat cells at their centre; textured cells (fill) mapped by
	the face's own extent, inset 4 px so mipmaps do not bleed."""
	cx, cy = ATLAS[key]
	u0, v0 = (cx * 128 + 4) / 512, (cy * 128 + 4) / 512
	span = 120 / 512
	for f in faces:
		if not fill:
			for loop in f.loops:
				loop[part.uv].uv = (u0 + span / 2, 1.0 - (v0 + span / 2))
		else:
			n = f.normal if f.normal.length > 0 else Vector((0, 0, 1))
			ax = max(range(3), key=lambda i: abs(n[i]))
			a, b = [i for i in range(3) if i != ax]
			ca = [loop.vert.co[a] for loop in f.loops]
			cb = [loop.vert.co[b] for loop in f.loops]
			la, lb = max(max(ca) - min(ca), 1e-6), max(max(cb) - min(cb), 1e-6)
			for loop in f.loops:
				s = (loop.vert.co[a] - min(ca)) / la
				t = (loop.vert.co[b] - min(cb)) / lb
				loop[part.uv].uv = (u0 + s * span, 1.0 - (v0 + t * span))
		f.tag = True


def build_booth_interior():
	"""K1's interior (as the pilot's, one material): seen through the window, inside the Booth collider."""
	w1kit.reset()
	part = GPart("Interior")
	M = "W5BoothAtlas"
	BX, BZ, T = P5.BX, P5.BZ, P5.WALL_T

	def box(key, lo, hi, fill=False):
		faces = part.gbox(M, lo, hi)
		part.bm.normal_update()
		atlas(part, faces, key, fill)

	part.bm.normal_update()
	f = part.face(M, [(BX[0] + T, G + 0.02, BZ[0] + T), (BX[1] - T, G + 0.02, BZ[0] + T), (BX[1] - T, G + 0.02, BZ[1] - T),
		(BX[0] + T, G + 0.02, BZ[1] - T)], (0, 1, 0))
	part.bm.normal_update()
	atlas(part, [f], "floor", True)
	zt0, zt1 = BZ[1] - T - 0.62, BZ[1] - T - 0.02
	top = G + 0.76
	box("wood", (238.0, top - 0.035, zt0), (242.0, top, zt1), True)
	for x in (238.05, 241.95):
		for z in (zt0 + 0.05, zt1 - 0.05):
			box("wood", (x - 0.03, G + 0.02, z - 0.03), (x + 0.03, top - 0.035, z + 0.03), True)
	box("wood", (238.0, G + 0.25, zt0 + 0.03), (242.0, top - 0.035, zt0 + 0.05), True)
	cx, cz = 240.2, -53.55
	box("plastic", (cx - 0.21, G + 0.43, cz - 0.21), (cx + 0.21, G + 0.46, cz + 0.21))
	box("plastic", (cx - 0.21, G + 0.46, cz - 0.23), (cx + 0.21, G + 0.86, cz - 0.2))
	for sx in (-1, 1):
		for sz in (-1, 1):
			faces = part.pipe(M, [(cx + sx * 0.17, G + 0.02, cz + sz * 0.17), (cx + sx * 0.19, G + 0.43, cz + sz * 0.19)], 0.018, 6)
			atlas(part, faces, "plastic")
	box("spine", (239.4, top, -52.75), (239.86, top + 0.012, -52.42))
	box("pages", (239.41, top + 0.012, -52.74), (239.62, top + 0.026, -52.43), True)
	box("pages", (239.64, top + 0.012, -52.74), (239.85, top + 0.026, -52.43), True)
	box("ivory", (240.35, top, -52.7), (240.57, top + 0.07, -52.48))
	box("ivory", (240.33, top + 0.07, -52.62), (240.59, top + 0.11, -52.56))
	atlas(part, part.cylinder(M, B((241.2, top + 0.17, -52.6)), 0.05, 0.34, segments=12), "enamel")
	atlas(part, part.cylinder(M, B((241.0, top + 0.05, -52.75)), 0.04, 0.1, segments=10), "plastic")
	atlas(part, part.cylinder(M, B((238.6, top + 0.04, -52.62)), 0.13, 0.08, segments=12, radius2=0.1), "cap")
	box("cap", (238.4, top + 0.075, -52.75), (238.8, top + 0.09, -52.62))
	box("black", (241.45, top, -52.6), (241.9, top + 0.38, -52.28))
	box("steel", (241.5, top + 0.04, -52.62), (241.85, top + 0.34, -52.6))
	atlas(part, part.cylinder(M, B((238.25, top + 0.02, -52.5)), 0.1, 0.04, segments=12), "plastic")
	atlas(part, part.pipe(M, [(238.25, top + 0.04, -52.5), (238.25, top + 0.35, -52.5)], 0.012, 6), "steel")
	atlas(part, part.cylinder(M, B((238.25, top + 0.42, -52.47)), 0.15, 0.1, axis="Y", segments=14), "plastic")
	cz0 = BZ[0] + T + 0.005
	f = part.face(M, [(239.6, G + 1.3, cz0), (240.0, G + 1.3, cz0), (240.0, G + 1.85, cz0), (239.6, G + 1.85, cz0)], (0, 0, 1))
	part.bm.normal_update()
	atlas(part, [f], "calendar", True)
	box("alu", (BX[1] - T - 0.08, G + 1.4, -54.6), (BX[1] - T, G + 1.85, -54.2))
	export(OUT / "booth_interior.glb", [build(part, {M: 1.0})])


# ------------------------------------------------------------------------------------------------ south wall

def build_wall_south():
	"""W1 along all of Fence/S: posts every 3 m (inside the 0.3 m collider), rendered panels 1.8 m, iron bars to 3 m.
	One Solid / BarsNear / BarsFar mesh per 30 m chunk."""
	w1kit.reset()
	chunks = {}
	ZW = P5.ZW
	y0 = G - 0.06  # buried under the lawn (-9.93) and the ground tiles (-9.94)

	def parts(x):
		k = int((x - L.WALL_X[0]) // L.WALL_CHUNK)
		if k not in chunks:
			chunks[k] = (GPart("Solid_%02d" % k), GPart("BarsNear_%02d" % k), GPart("BarsFar_%02d" % k))
		return chunks[k]

	for x0, x1 in L.WALL_RUNS:
		posts = [x0]
		x = x0
		while x + 3.0 < x1 - 0.5:
			x += 3.0
			posts.append(x)
		posts.append(x1)
		for p in posts:
			solid = parts(p)[0]
			a, b = max(p - 0.15, x0), min(p + 0.15, x1)
			f = solid.gbox("W5Plaster", (a, y0, ZW[0]), (b, G + 2.92, ZW[1]))
			solid.map_uv2(f, P5.wall_uv2(p - 1.5))
			f = solid.gbox("W5Plaster", (a - 0.02 if a > x0 else a, G + 2.92, ZW[0]), (b + 0.02 if b < x1 else b, G + 3.0, ZW[1]))
			solid.map_uv2(f, P5.wall_uv2(p - 1.5))
		for pa, pb in zip(posts, posts[1:]):
			solid, near, far = parts((pa + pb) / 2)
			a, b = pa + 0.15, pb - 0.15
			if b - a < 0.05:
				continue
			f = solid.gbox("W5Plaster", (a, y0, -60.1), (b, G + 1.8, -59.9), skip=("-x", "+x"))
			solid.map_uv2(f, P5.wall_uv2(pa))
			f = solid.gbox("W5Plaster", (a, G + 1.8, -60.13), (b, G + 1.86, -59.87), skip=("-x", "+x"))
			solid.map_uv2(f, P5.wall_uv2(pa))
			n = max(1, int((b - a) / 0.12))
			for i in range(1, n):
				xb = a + (b - a) * i / n
				near.beam("W5GateGreen", (xb, G + 1.86, -60.0), (xb, G + 2.93, -60.0), 0.02, 0.02, caps=False)
			near.beam("W5GateGreen", (a, G + 2.93, -60.0), (b, G + 2.93, -60.0), 0.04, 0.04, caps=False)
			near.beam("W5GateGreen", (a, G + 2.3, -60.0), (b, G + 2.3, -60.0), 0.03, 0.01, caps=False)
			# Far: one alpha-cut card, the bars' texture 0.48 m wide (4 bars) by 1.1 m from the rail at 2.97 m down.
			yb, yt = G + 1.86, G + 2.96
			far.face("W5BarsCard", [(a, yb, -60.0), (b, yb, -60.0), (b, yt, -60.0), (a, yt, -60.0)], (0, 0, 1),
				[((0.0) / 0.48, 0.0), ((b - a) / 0.48, 0.0), ((b - a) / 0.48, 1.0), (0.0, 1.0)])
	objs = []
	for k in sorted(chunks):
		solid, near, far = chunks[k]
		ensure_uv2(solid)
		objs.append(build(solid))
		objs.append(build(near, {"W5GateGreen": 1.0}))
		objs.append(build(far))
	export(OUT / "wall_south.glb", objs)


# ------------------------------------------------------------------------------------------------ the strip's ground

def strip_uv2(p):
	return ((p[0] - 180.0) / 82.0, (p[2] + 60.0) / 73.0)


def grid(part, mat, x0, z0, x1, z1, y, cell=4.0):
	nx = max(1, int(round((x1 - x0) / cell)))
	nz = max(1, int(round((z1 - z0) / cell)))
	faces = []
	for b in range(nz):
		for a in range(nx):
			xa, xb = x0 + (x1 - x0) * a / nx, x0 + (x1 - x0) * (a + 1) / nx
			za, zb = z0 + (z1 - z0) * b / nz, z0 + (z1 - z0) * (b + 1) / nz
			faces.append(part.face(mat, [(xa, y, za), (xb, y, za), (xb, y, zb), (xa, y, zb)], (0, 1, 0)))
	return faces


def build_strip():
	w1kit.reset()
	lawn = GPart("Lawn")
	faces = []
	for x0, z0, x1, z1 in L.LAWN:
		faces += grid(lawn, "W5StripGround", x0, z0, x1, z1, L.GROUND_TOP)
	lawn.map_uv2(faces, strip_uv2)
	objs = [build(lawn, {"W5StripGround": 1.0})]
	walk = GPart("Walk")
	faces = []
	for w in (L.WALK_N, L.WALK_W):
		faces += grid(walk, "W5CourtPavers", w["x"][0], w["z"][0], w["x"][1], w["z"][1], G, 3.0)
	r = L.ROAD
	faces += grid(walk, "W5CourtPavers", r["x"][0], r["z"][0], r["x"][1], r["z"][1], L.ROAD_TOP, 3.0)
	# The road's east end, 3 cm over the walk.
	faces.append(walk.face("W5CourtPavers", [(r["x"][1], G, r["z"][0]), (r["x"][1], G, r["z"][1]), (r["x"][1], L.ROAD_TOP, r["z"][1]),
		(r["x"][1], L.ROAD_TOP, r["z"][0])], (1, 0, 0)))
	set_uv(walk, faces, lambda p: (p[0] / 0.9, p[2] / 0.9))
	walk.map_uv2(faces, P5.court_uv2)
	objs.append(build(walk))
	kerb = GPart("Kerbs")
	lo_y = L.GROUND_TOP - 0.05
	for z0, z1 in ((r["z"][0] - L.KERB, r["z"][0]), (r["z"][1], r["z"][1] + L.KERB)):
		kerb.gbox("W1Concrete", (r["x"][0], lo_y, z0), (r["x"][1], L.KERB_TOP, z1))
	e = L.EDGE
	top = G + 0.01
	for lo, hi in (((L.WALK_N["x"][0] - e, lo_y, -20.0), (L.WALK_N["x"][0], top, r["z"][0] - L.KERB)),
			((L.WALK_N["x"][0] - e, lo_y, r["z"][1] + L.KERB), (L.WALK_N["x"][0], top, L.WALK_W["z"][0] - e)),
			((L.WALK_N["x"][1], lo_y, -20.0), (L.WALK_N["x"][1] + e, top, 13.0)),
			((L.WALK_W["x"][0] - e, lo_y, L.WALK_W["z"][0] - e), (L.WALK_N["x"][0], top, L.WALK_W["z"][0])),
			((L.WALK_W["x"][0] - e, lo_y, L.WALK_W["z"][0]), (L.WALK_W["x"][0], top, 13.0))):
		kerb.gbox("W1Concrete", lo, hi)
	objs.append(build(kerb, {"W1Concrete": 0.8}))
	export(OUT / "strip_gate.glb", objs)


# ------------------------------------------------------------------------------------------------ the strip's props

def car(part, frame, paint):
	"""An old four-door sedan, front +x, on its 4.4 x 1.5 x 1.9 m collider: lofted body with wheel arches, glasshouse
	(dark glass, painted pillars and roof), wheels with steel hubs, bumpers, lamps, tail lights, plates, mirrors."""
	top_line = [(-2.18, 0.66), (-2.14, 0.82), (-2.05, 0.9), (-1.6, 0.94), (-1.25, 0.95), (1.0, 0.93), (1.5, 0.87), (1.95, 0.8),
		(2.14, 0.74), (2.18, 0.6)]

	def ytop(x):
		for (xa, ya), (xb, yb) in zip(top_line, top_line[1:]):
			if xa <= x <= xb:
				return ya + (yb - ya) * (x - xa) / (xb - xa)
		return top_line[-1][1]

	def width(x):
		return 0.86 - 0.07 * max(0.0, (abs(x) - 1.55) / 0.63) ** 2

	wheels_x = (-1.32, 1.32)

	def bottom(x):
		for xw in wheels_x:
			d = (x - xw) / 0.42
			if abs(d) < 1.0:
				return 0.22 + 0.42 * math.sqrt(1.0 - d * d)
		return 0.22

	xs = [-2.18, -2.14, -2.05, -1.9, -1.76]
	xs += [-1.74 + 0.07 * i for i in range(13)] + [-0.8, -0.4, 0.0, 0.4, 0.82]
	xs += [0.9 + 0.07 * i for i in range(13)] + [1.76, 1.9, 2.05, 2.14, 2.18]
	xs = sorted(set(round(x, 4) for x in xs))
	rings = []
	for x in xs:
		t, b, w = ytop(x), bottom(x), width(x)
		half = [(t + 0.015, 0.0), (t - 0.01, w * 0.82), (t - 0.07, w), (min(b + 0.06, t - 0.08), w), (b, w - 0.05), (b, 0.0)]
		ring = half + [(y, -z) for y, z in reversed(half[1:-1])]
		rings.append([(x, y, z) for y, z in ring])
	n = len(rings[0])
	for ra, rb in zip(rings, rings[1:]):
		for j in range(n):
			k = (j + 1) % n
			quad = [ra[j], rb[j], rb[k], ra[k]]
			mid = Vector([sum(p[i] for p in quad) / 4 for i in range(3)])
			m = "W1Black" if j in (4, 5) else paint
			lface(part, frame, m, quad, (0.0, mid.y - 0.55, mid.z))
	lface(part, frame, paint, rings[0], (-1, 0, 0))
	lface(part, frame, paint, list(reversed(rings[-1])), (1, 0, 0))
	# Glasshouse.
	xa, xrf, xrr, xc = 1.0, 0.32, -0.62, -1.25
	yf, yr_, ya, yc = ytop(1.0), 1.42, 1.455, ytop(-1.25)
	wg, rw = width(0.0) - 0.06, 0.6
	for s in (1, -1):
		lface(part, frame, "W5CarGlass", [(xc, yc, s * wg), (xa, yf, s * wg), (xrf, yr_, s * rw), (xrr, yr_, s * rw)], (0, 0.3, s))
		for p0, p1 in (((xa, yf, s * wg), (xrf, yr_, s * rw)), ((xc, yc, s * wg), (xrr, yr_, s * rw)), ((-0.16, (yf + yc) / 2, s * wg), (-0.16, yr_, s * rw))):
			q0, q1 = to_world(frame, (p0[0], p0[1], p0[2] + s * 0.012)), to_world(frame, (p1[0], p1[1], p1[2] + s * 0.012))
			part.beam(paint, q0, q1, 0.07, 0.025, up=world_dir(frame, (0, 0, s)))
		q0, q1 = to_world(frame, (xc, yc + 0.012, s * (wg + 0.01))), to_world(frame, (xa, yf + 0.012, s * (wg + 0.01)))
		part.beam("W1Black", q0, q1, 0.03, 0.025, up=world_dir(frame, (0, 0, s)))
	lface(part, frame, "W5CarGlass", [(xa, yf, -wg), (xa, yf, wg), (xrf, yr_, rw), (xrf, yr_, -rw)], (0.6, 1, 0))
	lface(part, frame, "W5CarGlass", [(xc, yc, wg), (xc, yc, -wg), (xrr, yr_, -rw), (xrr, yr_, rw)], (-0.6, 1, 0))
	for s in (1, -1):
		lface(part, frame, paint, [(xrr, yr_, s * rw), (xrf, yr_, s * rw), (xrf, ya, 0.0), (xrr, ya, 0.0)], (0, 1, 0.2 * s))
	# Wheels: tyre and a steel hub.
	segs = 14
	for xw in wheels_x:
		for s in (1, -1):
			zc = s * 0.76
			pts = [(xw + 0.31 * math.cos(a), 0.31 + 0.31 * math.sin(a)) for a in (i / segs * math.tau for i in range(segs))]
			for i in range(segs):
				j = (i + 1) % segs
				(x0, y0), (x1, y1) = pts[i], pts[j]
				am = (i + 0.5) / segs * math.tau
				lface(part, frame, "W1Rubber", [(x0, y0, zc - 0.1), (x1, y1, zc - 0.1), (x1, y1, zc + 0.1), (x0, y0, zc + 0.1)], (math.cos(am), math.sin(am), 0))
			lface(part, frame, "W1Rubber", [(x, y, zc + s * 0.1) for x, y in pts], (0, 0, s))
			hub = [(xw + 0.19 * math.cos(a), 0.31 + 0.19 * math.sin(a)) for a in (i / 10 * math.tau for i in range(10))]
			lface(part, frame, "W1Steel", [(x, y, zc + s * 0.105) for x, y in hub], (0, 0, s))
	# Bumpers, lamps, tail lights, plates, mirrors.
	lbox(part, frame, "W1Black", (2.06, 0.24, -0.84), (2.185, 0.42, 0.84))
	lbox(part, frame, "W1Black", (-2.185, 0.24, -0.84), (-2.06, 0.42, 0.84))
	for s in (1, -1):
		lface(part, frame, "W5CarLamp", [(2.185, 0.46, s * 0.42), (2.185, 0.46, s * 0.74), (2.185, 0.57, s * 0.74), (2.185, 0.57, s * 0.42)], (1, 0, 0))
		lface(part, frame, "W5CarTail", [(-2.185, 0.52, s * 0.5), (-2.185, 0.52, s * 0.78), (-2.185, 0.64, s * 0.78), (-2.185, 0.64, s * 0.5)], (-1, 0, 0))
		lbox(part, frame, paint, (0.82, 0.97, s * 0.84 if s > 0 else -0.94), (0.94, 1.06, 0.94 if s > 0 else -0.84))
	for x, nx in ((2.19, 1), (-2.19, -1)):  # plates on the bumpers, inside the 4.4 m collider
		lface(part, frame, "W5Reflect", [(x, 0.28, -0.22), (x, 0.28, 0.22), (x, 0.38, 0.22), (x, 0.38, -0.22)], (nx, 0, 0))


def barricade(part, frame):
	"""The pilot's barricade (barrier.glb) in a frame: board along local x, feet 0.42 m deep, 0.95 m tall."""
	M = "W4PoleSteel"
	for sx in (-1, 1):
		x = sx * 0.95
		lpipe(part, frame, M, [(x, 0.03, -0.21), (x, 0.93, 0.0), (x, 0.03, 0.21)], 0.02, 8)
		lpipe(part, frame, M, [(x, 0.18, -0.17), (x, 0.18, 0.17)], 0.012, 6)
		for z in (-0.21, 0.21):
			lbox(part, frame, "W1Rubber", (x - 0.04, 0.0, z - 0.03), (x + 0.04, 0.03, z + 0.03))
	lpipe(part, frame, M, [(-0.95, 0.93, 0.0), (0.95, 0.93, 0.0)], 0.02, 8, cap=False)
	y0, y1 = 0.55, 0.85
	lface(part, frame, "W5BarrierStripes", [(-0.93, y0, 0.012), (0.93, y0, 0.012), (0.93, y1, 0.012), (-0.93, y1, 0.012)], (0, 0, 1),
		[(0.035, 0.4), (0.965, 0.4), (0.965, 1.0), (0.035, 1.0)])
	lface(part, frame, "W5BarrierStripes", [(-0.93, y0, -0.012), (0.93, y0, -0.012), (0.93, y1, -0.012), (-0.93, y1, -0.012)], (0, 0, -1),
		[(0.965, 0.4), (0.035, 0.4), (0.035, 1.0), (0.965, 1.0)])
	lbox(part, frame, M, (-0.95, y0 - 0.02, -0.012), (0.95, y0, 0.012))
	lbox(part, frame, M, (-0.95, y1, -0.012), (0.95, y1 + 0.02, 0.012))
	for x in (-0.95, 0.95):
		lbox(part, frame, M, (x - 0.02, y0, -0.012), (x + 0.02, y1, 0.012))


def cone(part, frame):
	"""The pilot's cone (cone.glb) in a frame: origin on the ground at the base's centre, 0.7 m, two bands."""
	lbox(part, frame, "W1Rubber", (-0.2, 0.0, -0.2), (0.2, 0.035, 0.2))
	h0, h1, r0, r1 = 0.035, 0.7, 0.16, 0.025

	def r(y):
		return r0 + (r1 - r0) * (y - h0) / (h1 - h0)
	cuts = [h0, 0.3, 0.38, 0.5, 0.56, h1]
	mats = ["W5ConeOrange", "W5Reflect", "W5ConeOrange", "W5Reflect", "W5ConeOrange"]
	segs = 12
	for (ya, yb), m in zip(zip(cuts, cuts[1:]), mats):
		for s in range(segs):
			a0, a1 = s / segs * math.tau, (s + 1) / segs * math.tau
			lface(part, frame, m, [(math.cos(a0) * r(ya), ya, math.sin(a0) * r(ya)), (math.cos(a1) * r(ya), ya, math.sin(a1) * r(ya)),
				(math.cos(a1) * r(yb), yb, math.sin(a1) * r(yb)), (math.cos(a0) * r(yb), yb, math.sin(a0) * r(yb))],
				(math.cos((a0 + a1) / 2), 0.2, math.sin((a0 + a1) / 2)))
	lface(part, frame, "W5ConeOrange", [(math.cos(-s / segs * math.tau) * r1, h1, math.sin(-s / segs * math.tau) * r1) for s in range(segs)], (0, 1, 0))


def rounded(part, frame, key, size, rnd, bevel=0.025):
	"""A bevelled block of the instance's size in a palette cell (backpacks, pockets, shoes' uppers, flat items)."""
	hx, hy, hz = size[0] / 2, size[1] / 2, size[2] / 2
	o, axes, _ = frame
	bx, by, bz = (Vector((a.x, -a.z, a.y)) for a in axes)
	m = Matrix(((bx.x, by.x, bz.x, 0), (bx.y, by.y, bz.y, 0), (bx.z, by.z, bz.z, 0), (0, 0, 0, 1)))
	m = Matrix.Translation(B(o)) @ m
	faces = part.box("W4Palette", (-hx, -hy, -hz), (hx, hy, hz), bevel=min(bevel, min(size) * 0.4), segments=1, matrix=m)
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


def yaw_of(basis):
	x = Vector(basis[0])
	return math.atan2(-x.z, x.x)


def flat_item(part, x, z, yaw, size, key, rnd, thick=0.012):
	y = surface_y(x, z)
	frame = (Vector((x, y + thick / 2 + 0.003, z)), [Vector((math.cos(yaw), 0, -math.sin(yaw))), Vector((0, 1, 0)),
		Vector((math.sin(yaw), 0, math.cos(yaw)))], (1, 1, 1))
	return frame, rounded(part, frame, key, (size[0], thick, size[1]), rnd, thick * 0.45)


def litter_card(part, at, angle, size, cell):
	"""Wave 3's W3Litter cards (a page, a flyer, crumpled paper, a bag), lying flat at `at` (Blender)."""
	u0, v0, u1, v1 = cell
	d = Vector((math.cos(angle), math.sin(angle), 0.0)) * size * 0.5
	n = Vector((-math.sin(angle), math.cos(angle), 0.0)) * size * 0.5
	verts = [part.bm.verts.new(p) for p in (at - d - n, at + d - n, at + d + n, at - d + n)]
	f = part.bm.faces.new(verts)
	f.material_index = part.slot("W3Litter")
	for loop, uv in zip(f.loops, [(u0, v0), (u1, v0), (u1, v1), (u0, v1)]):
		loop[part.uv].uv = uv
	f.tag = True


def build_strip_props():
	w1kit.reset()
	rnd = random.Random(2621)
	cars = GPart("Cars")
	street = GPart("Furniture")  # barricades and cones
	props = GPart("Props")       # dropped things, palette
	litter = GPart("Litter")
	rubble = w1kit.Part("Rubble")
	rods = GPart("Rods")
	cells = [(0.0, 0.5, 0.5, 1.0), (0.5, 0.5, 1.0, 1.0), (0.0, 0.0, 0.5, 0.5), (0.5, 0.0, 1.0, 0.5)]
	to_b = Matrix(((1, 0, 0), (0, 0, -1), (0, 1, 0)))
	for x, z, yaw, colour in L.CARS:
		car(cars, yaw_frame(x, surface_y(x, z), z, yaw), CAR_PAINT[colour])
	for x, z, yaw in L.BARRIERS:
		barricade(street, yaw_frame(x, surface_y(x, z), z, yaw))
	counts = {}
	for name, entry in ps1().items():
		for index, basis, origin, rgba in instances(entry["data"]):
			scale = tuple(Vector(c).length for c in basis)
			if max(scale) == 0 or not L.in_box(*origin):
				continue
			kind = A16.kind(name, origin, scale, rgba)
			counts[kind] = counts.get(kind, 0) + 1
			frame = frame_of(basis, origin)
			o, axes, s = frame
			x, y, z = origin
			key = tint_key(rgba)
			if kind == "cone" and name.startswith("P_white_cone"):
				# The PS1 cone is a unit cone scaled (.36, .7, .36) about its middle; the new one stands on its base.
				ay = axes[1]
				base = o - ay * 0.35
				up_now = ay.y
				cone(street, (Vector((base.x, base.y + (surface_y(x, z) - G) * (1 if up_now > 0.9 else 0), base.z)), axes, (1, 1, 1)))
			elif kind == "dropped: backpack":
				if abs(s[1] - 0.42) < 0.02:
					backpack(props, frame, key, rnd)
				else:
					rounded(props, frame, key, (s[0] * 0.9, s[1] * 0.95, s[2] * 1.4), rnd, 0.025)
			elif kind == "dropped: shoe":
				shoe(props, frame, key, rnd)
			elif kind == "dropped: sandal":
				frame2, _ = flat_item(props, x, z, yaw_of(basis), (s[0] * 0.95, s[2] * 0.95), key, rnd)
				strap = []
				for sx in (-1, 1):
					pts = [(0.0, 0.006, s[2] * 0.22), (sx * s[0] * 0.38, 0.02, -s[2] * 0.02), (sx * s[0] * 0.46, 0.006, -s[2] * 0.08)]
					strap += props.pipe("W4Palette", [to_world(frame2, p) for p in pts], 0.004, 4, cap=False)
				cell_uv(props, strap, "black", rnd)
			elif kind == "dropped: phone" and name.startswith("D_white"):
				frame2, _ = flat_item(props, x, z, yaw_of(basis), (s[0], s[2]), "black", rnd, 0.009)
				f = lbox(props, frame2, "W4Palette", (-s[0] * 0.44, 0.0045, -s[2] * 0.45), (s[0] * 0.44, 0.0055, s[2] * 0.45))
				cell_uv(props, f, "screen", rnd)
			elif kind == "paper":
				size = max(0.18, min(0.42, s[0] * 1.3))
				a = rnd.uniform(0, math.tau)
				litter_card(litter, B((x, surface_y(x, z) + 0.006, z)), a, size, cells[rnd.randrange(4)])
			elif kind == "rubble" and name.startswith("P_concrete"):
				mg = Matrix((Vector(basis[0]), Vector(basis[1]), Vector(basis[2]))).transposed()
				mb = to_b @ mg @ to_b.inverted()
				m = Matrix.Translation(B(origin)) @ mb.to_4x4() @ Matrix.Rotation(rnd.uniform(-0.15, 0.15), 4, "Z")
				rubble.box("W3Brick" if rnd.random() < 0.45 else "W1Concrete", (-0.5, -0.5, -0.5), (0.5, 0.5, 0.5), bevel=0.04, segments=1, matrix=m)
			elif kind == "rubble":
				half = Vector(basis[1]) * 0.5
				rods.pipe("W1Rebar", [tuple(Vector(origin) - half), tuple(Vector(origin) + half)], max(0.012, Vector(basis[0]).length * 0.5), 8)
	cx, cz, r = 213.95, -22.7, 1.4
	for k in range(10):
		rr = rnd.uniform(0, 1) ** 0.7
		a = rnd.uniform(0, math.tau)
		px, pz = cx + math.cos(a) * rr * r * 0.9, cz + math.sin(a) * rr * r * 0.9
		sc = rnd.uniform(0.6, 1.0)
		m = Matrix.Translation(B((px, surface_y(px, pz) + 0.03 + 0.35 * (1 - rr) ** 1.5 * rnd.uniform(0.3, 1.0), pz))) @ \
			Matrix.Rotation(rnd.uniform(0, math.tau), 4, "Z") @ Matrix.Rotation(rnd.uniform(-0.6, 0.6), 4, "X")
		rubble.box("W3Brick", (-0.11 * sc, -0.052 * sc, -0.03), (0.11 * sc, 0.052 * sc, 0.03), bevel=0.006, segments=1, matrix=m)
	print("T262_STRIP_PROPS", dict(sorted(counts.items())))
	retag(props)
	objs = [build(cars, {"W1Black": 1.0, "W1Rubber": 1.0, "W1Steel": 1.0}), build(street, {"W4PoleSteel": 1.0, "W1Rubber": 1.0}),
		build(props, {"W4Palette": 1.0}), build(litter), rubble.build(uv_size={"W3Brick": 0.8, "W1Concrete": 0.8}), build(rods, {"W1Rebar": 1.0})]
	export(OUT / "strip_gate_props.glb", objs)


# ------------------------------------------------------------------------------------------------ targets

TARGETS = {"court": lambda: P5.build_court(("Pavers",)), "outside": P5.build_outside, "cracks": P5.build_cracks,
	"pillars": lambda: P5.build_pillars("plaster"), "gate": P5.build_gate_swing, "sign": P5.build_sign_arch,
	"booth": lambda: P5.build_booth("masonry"), "interior": build_booth_interior, "wall": build_wall_south,
	"strip": build_strip, "strip_props": build_strip_props}


if __name__ == "__main__":
	random.seed(2620)
	args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for key in (args or TARGETS):
		TARGETS[key]()
