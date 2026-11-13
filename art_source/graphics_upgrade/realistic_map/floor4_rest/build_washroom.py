"""T-256 (D-170) part A: the floor-4 shared washroom in room 407's style, one glb in Floor4 metres:
  game/assets/models/graphics_pilot/realistic_map/floor4_rest/washroom.glb
    Shell     walls tiled to 1.8 m (plaster above), the floor falling a centimetre to its drain, the ceiling
    Stalls    three tiled masonry stalls: fronts with a doorway, partitions, the step, the squat pan, a low tap
              with its pipe, the painted leaves standing a little open into each stall (no interaction, D-170)
    Trough    the long tiled wash trough over the three Sink boxes, three wall taps on an exposed supply pipe,
              the drain and its pipe, the riser and the pipe along the back wall to the stall taps
    Fixtures  the mirror's aluminium frame, the notice board at Anchors/WashroomNotice, the tube batten, a
              ventilation block, hooks
    Props     buckets, dippers, basins, a mop and its bucket, soap dishes, a jug, a bin, a towel (all modelled here)
    MirrorStain  a quad 1.5 mm in front of the glass: the desilvered, water-spotted edge (washroom_real.gd puts it
              on the mirror surface's render layer so the reflection does not see it)
No collision (washroom.tscn keeps its boxes). Shell faces carry UV2 into mask_washroom.png (make_washroom_textures.py).
Run from the repository root:
  blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/floor4_rest/build_washroom.py
"""
import math
import sys
from pathlib import Path

from mathutils import Matrix, Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave2"))
sys.path.insert(0, str(HERE))
import w2kit as K  # noqa: E402
from w2kit import G, gbox  # noqa: E402
import washroom_layout as L  # noqa: E402

OUT = K.w1kit.ROOT / "game/assets/models/graphics_pilot/realistic_map/floor4_rest"
# UV1 repeats (metres) of the shell-shader scans: smaller tiles than room 407's bathroom (1.27) so the two differ.
SIZES = {"WRTiles": 0.62, "WRFloor": 0.6, "WRPlaster": 2.0, "WRCeiling": 2.0, "WRStepTop": 0.6, "WRDoorPaint": 1.2}
K.SIZES.update(SIZES)
PREVIEW = {
	"WRTiles": ((0.78, 0.88, 0.82), 0.4, 0.0), "WRFloor": ((0.5, 0.52, 0.5), 0.6, 0.0),
	"WRPlaster": ((0.8, 0.78, 0.68), 0.85, 0.0), "WRCeiling": ((0.82, 0.8, 0.72), 0.9, 0.0),
	"WRStepTop": ((0.5, 0.52, 0.5), 0.6, 0.0), "WRCeramic": ((0.9, 0.9, 0.87), 0.15, 0.0),
	"WRChrome": ((0.8, 0.8, 0.8), 0.22, 1.0), "WRPipe": ((0.55, 0.56, 0.55), 0.5, 0.7),
	"WRPVC": ((0.55, 0.57, 0.58), 0.55, 0.0), "WRDoorPaint": ((0.35, 0.55, 0.55), 0.6, 0.0),
	"WRTubeGlass": ((0.92, 0.94, 0.9), 0.25, 0.0), "WRBlue": ((0.1, 0.3, 0.65), 0.45, 0.0),
	"WRRed": ((0.62, 0.08, 0.06), 0.45, 0.0), "WRGreen": ((0.15, 0.48, 0.25), 0.45, 0.0),
	"WRPink": ((0.85, 0.45, 0.6), 0.45, 0.0), "WRYellow": ((0.85, 0.7, 0.2), 0.45, 0.0),
	"WRGrey": ((0.5, 0.52, 0.52), 0.5, 0.0), "WRMop": ((0.72, 0.7, 0.62), 0.95, 0.0),
	"WRTowel": ((0.55, 0.62, 0.7), 0.95, 0.0), "WRSoap": ((0.85, 0.75, 0.55), 0.35, 0.0),
	"WRVent": ((0.62, 0.6, 0.55), 0.9, 0.0), "WRMirrorStain": ((0.3, 0.28, 0.2), 0.8, 0.0),
	"WRCork": ((0.55, 0.42, 0.28), 0.9, 0.0),
}
PX, NX, PY, NY, PZ, NZ = (1, 0, 0), (-1, 0, 0), (0, 1, 0), (0, -1, 0), (0, 0, 1), (0, 0, -1)
SC = L.scales()


def materials():
	K.materials()
	for name, (colour, rough, metal) in PREVIEW.items():
		K.material(name, colour, rough, metal)


def build(part):
	"""K.build after clearing face tags: bmesh's recalc_face_normals (obox) leaves faces tagged, and a tagged face
	keeps its UV1 (0, 0) instead of the kit's metric projection. Faces with their own UV1 are K.keep_uv'ed."""
	for f in part.bm.faces:
		f.tag = False
	return K.build(part)


def _ab(co, origin, u, v):
	p = (co.x, co.z, -co.y)
	d = tuple(p[i] - origin[i] for i in range(3))
	return sum(d[i] * u[i] for i in range(3)), sum(d[i] * v[i] for i in range(3))


def plane(part, mat, origin, u, v, w, h, holes=(), uv2=None):
	"""Rectangle origin + a*u + b*v (a 0..w, b 0..h; Godot vectors; the face looks along u x v) with rectangular
	holes [(a0, b0, a1, b1)]; UV1 left to the kit (metric box projection / SIZES), UV2 from uv2(a, b)."""
	cuts_a = sorted({0.0, w} | {c for hole in holes for c in (hole[0], hole[2]) if 0.0 < c < w})
	cuts_b = sorted({0.0, h} | {c for hole in holes for c in (hole[1], hole[3]) if 0.0 < c < h})
	normal = (u[1] * v[2] - u[2] * v[1], u[2] * v[0] - u[0] * v[2], u[0] * v[1] - u[1] * v[0])
	faces = []

	def at(a, b):
		return tuple(origin[i] + u[i] * a + v[i] * b for i in range(3))
	for a0, a1 in zip(cuts_a, cuts_a[1:]):
		for b0, b1 in zip(cuts_b, cuts_b[1:]):
			am, bm = (a0 + a1) / 2, (b0 + b1) / 2
			if any(h0 <= am <= h2 and h1 <= bm <= h3 for h0, h1, h2, h3 in holes):
				continue
			f = K.quad(part, mat, at(a0, b0), at(a1, b0), at(a1, b1), at(a0, b1), normal)
			if uv2 is not None:
				part.set_uv2([f], lambda co, origin=origin, u=u, v=v: uv2(*_ab(co, origin, u, v)))
			faces.append(f)
	return faces


def obox(part, mat, centre, axes, half, smooth=False):
	"""A box with its own axes (three unit Godot vectors) and half sizes, centred at `centre` (Godot)."""
	verts = []
	for sx in (-1, 1):
		for sy in (-1, 1):
			for sz in (-1, 1):
				p = [centre[i] + axes[0][i] * half[0] * sx + axes[1][i] * half[1] * sy + axes[2][i] * half[2] * sz
					for i in range(3)]
				verts.append(G(*p))
	idx = [(0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3)]
	return part.poly(mat, verts, idx, smooth=smooth)


def gtube(part, mat, points, radius, segments=8):
	return part.tube(mat, [G(*p) for p in points], radius, segments=segments)


def lathe_at(part, mat, profile, at, segments=20, scale=(1.0, 1.0), smooth=True, close_ends=True):
	"""A lathe (radius, height) about the Godot Y axis through `at` (Godot), scaled in x and z."""
	m = Matrix.Translation(G(*at)) @ Matrix.Diagonal((scale[0], scale[1], 1.0, 1.0))
	return part.lathe(mat, profile, segments=segments, matrix=m, smooth=smooth, close_ends=close_ends)


# ---------------------------------------------------------------- shell

def wall_uv(run):
	runs, _ = L.wall_runs()
	p0, _ = runs[run]
	return lambda a, b: L.to_uv(L.RECT_WALLS, p0 + a, b, SC["walls"])


def shell():
	part = K.Part("Shell")
	c, t = L.COVER, L.TILE_T
	H = L.CEILING - c
	e0, e1, etop = L.ENTRANCE
	# (run, origin on the wall face, u along the run, length, holes in (a, b))
	walls = [
		("front", (L.EAST, 0.0, L.FRONT - c), NX, L.EAST - L.WEST, [(L.EAST - e1, 0.0, L.EAST - e0, etop)], NZ),
		("west", (L.WEST + c, 0.0, L.FRONT), NZ, L.FRONT - L.BACK, [], PX),
		("back", (L.WEST, 0.0, L.BACK + c), PX, L.EAST - L.WEST, [], PZ),
		("east", (L.EAST - c, 0.0, L.BACK), PZ, L.FRONT - L.BACK, [], NX),
	]
	for run, origin, u, length, holes, n in walls:
		upper = [(a0, 0.0, a1, b1 - L.TILE_TOP) for a0, b0, a1, b1 in holes if b1 > L.TILE_TOP]
		o_up = (origin[0], L.TILE_TOP, origin[2])
		plane(part, "WRPlaster", o_up, u, PY, length, H - L.TILE_TOP, upper,
			lambda a, b, f=wall_uv(run): f(a, b + L.TILE_TOP))
		o_tile = tuple(origin[i] + n[i] * t for i in range(3))
		lower = [(a0, b0, a1, min(b1, L.TILE_TOP)) for a0, b0, a1, b1 in holes]
		plane(part, "WRTiles", o_tile, u, PY, length, L.TILE_TOP, lower, wall_uv(run))
		# Bullnose along the tiles' top.
		a = tuple(o_tile[i] + PY[i] * L.TILE_TOP for i in range(3))
		b = tuple(a[i] + u[i] * length for i in range(3))
		lo = [min(a[i], b[i]) for i in range(3)]
		hi = [max(a[i], b[i]) for i in range(3)]
		k = [i for i in (0, 2) if abs(n[i]) > 0.5][0]
		lo[k], hi[k] = min(a[k], a[k] + n[k] * 0.007), max(a[k], a[k] + n[k] * 0.007)
		hi[1] += 0.012
		lo[1] -= 0.002
		faces = gbox(part, "WRTiles", tuple(lo), tuple(hi))
		part.set_uv2(faces, lambda co, f=wall_uv(run): f(0.5, L.TILE_TOP))
	# The entrance's inner edge: tile trims down both sides and across the head of the tiles.
	for x in (e0, e1):
		gbox(part, "WRTiles", (x - 0.012, 0.0, L.FRONT - c - t - 0.006), (x + 0.012, L.TILE_TOP, L.FRONT - c))
	# Floor: a grid falling to the drain; stalls have their own step.
	floor(part)
	plane(part, "WRCeiling", (L.WEST, H, L.BACK), PX, PZ, L.EAST - L.WEST, L.FRONT - L.BACK, (),
		lambda a, b: L.to_uv(L.RECT_CEILING, a, b, SC["ceiling"]))
	return build(part)


def floor(part):
	nx, nz = 20, 12
	x0, x1, z0, z1 = L.WEST, L.EAST, L.FRONT_Z[1], L.FRONT
	dx, dz = (x1 - x0) / nx, (z1 - z0) / nz

	def y_at(x, z):
		d = math.hypot(x - L.DRAIN[0], z - L.DRAIN[1])
		k = max(0.0, 1.0 - d / 2.6)
		return -L.FALL * k * k * (3 - 2 * k)
	for i in range(nx):
		for j in range(nz):
			xa, xb = x0 + i * dx, x0 + (i + 1) * dx
			za, zb = z0 + j * dz, z0 + (j + 1) * dz
			pts = [(xa, y_at(xa, za), za), (xb, y_at(xb, za), za), (xb, y_at(xb, zb), zb), (xa, y_at(xa, zb), zb)]
			f = K.quad(part, "WRFloor", *pts, PY)
			part.set_uv2([f], lambda co: L.to_uv(L.RECT_FLOOR, co.x - L.WEST, L.FRONT - (-co.y), SC["floor"]))
	# The drain: a stainless grate in a small square, a little lower still.
	cx, cz = L.DRAIN
	y = -L.FALL - 0.001
	gbox(part, "WRChrome", (cx - 0.08, y - 0.004, cz - 0.08), (cx + 0.08, y + 0.0005, cz + 0.08))
	for k in range(6):
		z = cz - 0.06 + k * 0.024
		gbox(part, "W1Black", (cx - 0.06, y + 0.0004, z), (cx + 0.06, y + 0.0009, z + 0.012))


# ---------------------------------------------------------------- stalls

def stall_uv(run):
	runs, _ = L.stall_runs()
	p0, _ = runs[run]
	return lambda a, b: L.to_uv(L.RECT_STALLS, p0 + a, b, SC["stalls"])


def stalls():
	part = K.Part("Stalls")
	zb, zr = L.FRONT_Z
	top = L.STALL_TOP
	# Fronts: one tiled slab from wall to wall, three doorways; reveals, head and top cap.
	holes = []
	for (sx0, sx1) in L.STALL_XS:
		c = (sx0 + sx1) / 2
		holes.append((c - L.DOOR_W / 2, c + L.DOOR_W / 2))
	plane(part, "WRTiles", (L.WEST, 0.0, zr), PX, PY, L.EAST - L.WEST, top,
		[(h0 - L.WEST, 0.0, h1 - L.WEST, L.DOOR_TOP) for h0, h1 in holes], stall_uv("front_room"))
	plane(part, "WRTiles", (L.EAST, 0.0, zb), NX, PY, L.EAST - L.WEST, top,
		[(L.EAST - h1, 0.0, L.EAST - h0, L.DOOR_TOP) for h0, h1 in holes], stall_uv("front_back"))
	gbox(part, "WRTiles", (L.WEST, top, zb - 0.005), (L.EAST, top + 0.015, zr + 0.005), bevel=0.004)
	for h0, h1 in holes:
		# The doorway's reveals: the west one looks east (+x), the east one west.
		plane(part, "WRTiles", (h0, 0.0, zr), NZ, PY, zr - zb, L.DOOR_TOP)
		plane(part, "WRTiles", (h1, 0.0, zb), PZ, PY, zr - zb, L.DOOR_TOP)
		plane(part, "WRTiles", (h0, L.DOOR_TOP, zb), PX, PZ, h1 - h0, zr - zb)
		# Painted steel linings round the doorway (5 mm proud of the tiles).
		for x0, x1 in ((h0, h0 + 0.035), (h1 - 0.035, h1)):
			gbox(part, "WRDoorPaint", (x0, 0.0, zb - 0.004), (x1, L.DOOR_TOP, zr + 0.004))
		gbox(part, "WRDoorPaint", (h0, L.DOOR_TOP - 0.035, zb - 0.004), (h1, L.DOOR_TOP, zr + 0.004))
	# Partitions: thin tiled masonry from the front to the back wall.
	for k, x in enumerate(L.PARTITIONS):
		for side, n in (("w", NX), ("e", PX)):
			xf = x - 0.04 if side == "w" else x + 0.04
			u = PZ if n == NX else NZ
			origin = (xf, 0.0, L.BACK) if n == NX else (xf, 0.0, zb)
			plane(part, "WRTiles", origin, u, PY, zb - L.BACK, top, (), stall_uv("part%d_%s" % (k, side)))
		gbox(part, "WRTiles", (x - 0.045, top, L.BACK), (x + 0.045, top + 0.015, zb), bevel=0.004)
	for k, (sx0, sx1) in enumerate(L.STALL_XS):
		stall_inside(part, k, sx0, sx1)
	for k, (sx0, sx1) in enumerate(L.STALL_XS):
		leaf(part, k, (sx0 + sx1) / 2)
	return build(part)


def stall_inside(part, k, sx0, sx1):
	"""The step with the squat pan, the low tap and its drop from the back-wall pipe."""
	zb = L.FRONT_Z[0]
	P = L.PLATFORM_H
	x0, x1 = sx0 + (0.04 if k > 0 else 0.0), sx1 - (0.04 if k < 2 else 0.0)
	faces = gbox(part, "WRTiles", (x0, 0.0, L.BACK), (x1, P, zb - 0.002), bevel=0.006)
	part.set_uv2(faces, lambda co: L.to_uv(L.RECT_STALLS, 0.3, 0.05, SC["stalls"]))
	plane(part, "WRStepTop", (x0, P + 0.001, zb - 0.002), PX, NZ, x1 - x0, (zb - 0.002) - L.BACK, (),
		lambda a, b: L.to_uv(L.RECT_STALLS, 1.0 + a, 0.1 + b * 0.5, SC["stalls"]))
	c = (sx0 + sx1) / 2
	squat_pan(part, c, P, -4.3)
	# The stall's own tap low on the back wall, on a drop from the pipe that runs along it at 2.35 m.
	tx = c + 0.42
	wall = L.BACK + L.COVER + L.TILE_T
	gtube(part, "WRPipe", [(tx, 2.35, wall + 0.03), (tx, 0.72, wall + 0.03)], 0.011)
	gtube(part, "WRPipe", [(tx, 0.72, wall + 0.03), (tx, 0.66, wall + 0.03)], 0.014)
	tap(part, (tx, 0.62, wall), PZ, 0.11)


def squat_pan(part, cx, y0, cz):
	"""A white ceramic squat pan set in the step: rim, bowl falling to the hole at the back, two ribbed footrests."""
	rings = [(1.0, 0.0, 0.0), (0.74, 0.0, 0.0), (0.6, -0.04, -0.02), (0.42, -0.09, -0.05), (0.2, -0.13, -0.09)]
	a, b = 0.2, 0.3
	n = 28
	vert_rings = []
	for s, dy, dz in rings:
		ring = []
		for i in range(n):
			t = i / n * math.tau
			ring.append(G(cx + math.cos(t) * a * s, y0 + 0.012 + dy, cz + math.sin(t) * b * s + dz))
		vert_rings.append(ring)
	verts = [v for ring in vert_rings for v in ring]
	faces = []
	for r in range(len(vert_rings) - 1):
		for i in range(n):
			j = (i + 1) % n
			faces.append((r * n + i, r * n + j, (r + 1) * n + j, (r + 1) * n + i))
	made = part.poly("WRCeramic", verts, faces, smooth=True, recalc=False)
	for f in made:
		f.normal_update()
		if f.normal.z < 0:
			f.normal_flip()
	hole = [G(cx + math.cos(i / n * math.tau) * a * 0.2, y0 + 0.012 - 0.13, cz + math.sin(i / n * math.tau) * b * 0.2 - 0.09)
		for i in range(n)]
	h = part.poly("W1Black", hole, [list(range(n))], recalc=False)[0]
	h.normal_update()
	if h.normal.z < 0:
		h.normal_flip()
	# The outer lip standing 12 mm over the step tiles.
	lathe_at(part, "WRCeramic", [(1.0, -0.002), (1.0, 0.012)], (cx, y0, cz), segments=n, scale=(a, b), close_ends=False)
	for side in (-1, 1):
		fx = cx + side * 0.13
		obox(part, "WRCeramic", (fx, y0 + 0.016, cz + 0.12), (PX, PY, PZ), (0.045, 0.006, 0.1))
		for r in range(4):
			obox(part, "WRCeramic", (fx, y0 + 0.024, cz + 0.05 + r * 0.045), (PX, PY, PZ), (0.04, 0.003, 0.008))


def tap(part, at, out, reach):
	"""A chrome wall tap: the wall rose, the valve body, a cross handle on top and a spout curving down, its mouth
	`reach` metres out from the wall (out: the Godot direction away from the wall)."""
	x, y, z = at
	o = out

	def p(d, dy=0.0):
		return (x + o[0] * d, y + dy, z + o[2] * d)
	gtube(part, "WRChrome", [p(0.0), p(0.012)], 0.024, segments=12)
	gtube(part, "WRChrome", [p(0.012), p(0.06)], 0.014, segments=12)
	gtube(part, "WRChrome", [p(0.036, 0.0), p(0.036, 0.045)], 0.006, segments=8)
	# The cross handle: one bar across the wall, one out from it.
	side = (o[2], 0.0, -o[0])
	top = (x + o[0] * 0.036, y + 0.045, z + o[2] * 0.036)
	gtube(part, "WRChrome", [(top[0] - side[0] * 0.024, top[1], top[2] - side[2] * 0.024),
		(top[0] + side[0] * 0.024, top[1], top[2] + side[2] * 0.024)], 0.0045, 8)
	gtube(part, "WRChrome", [(top[0] - o[0] * 0.022, top[1], top[2] - o[2] * 0.022),
		(top[0] + o[0] * 0.022, top[1], top[2] + o[2] * 0.022)], 0.0045, 8)
	gtube(part, "WRChrome", [p(0.05), p(reach - 0.025), p(reach - 0.006, -0.008), p(reach, -0.03)], 0.008, segments=10)


def leaf(part, k, c):
	"""Stall k's painted leaf, standing open into the stall by its angle, with hinges, a bolt, a handle, a hook."""
	spec = L.DOORS[k]
	w, yb, yt = L.LEAF
	t = 0.025
	zb = L.FRONT_Z[0]
	theta = math.radians(spec["open"])
	if spec["hinge"] == "west":
		hinge = (c - L.DOOR_W / 2 + 0.04, zb - t / 2 - 0.002)
		along = (math.cos(theta), -math.sin(theta))
	else:
		hinge = (c + L.DOOR_W / 2 - 0.04, zb - t / 2 - 0.002)
		along = (-math.cos(theta), -math.sin(theta))
	u = (along[0], 0.0, along[1])
	n = (-along[1], 0.0, along[0])  # the leaf's face normal (one of the two)
	mid = (hinge[0] + u[0] * w / 2, (yb + yt) / 2, hinge[1] + u[2] * w / 2)
	obox(part, "WRDoorPaint", mid, (u, PY, n), (w / 2, (yt - yb) / 2, t / 2))
	# A kick plate and a top rail standing 2 mm proud on both faces: an old plywood leaf's frame.
	for s in (-1, 1):
		for yy, hh in ((yb + 0.06, 0.06), (yt - 0.05, 0.05)):
			cpos = (mid[0] + n[0] * s * (t / 2 + 0.001), yy, mid[2] + n[2] * s * (t / 2 + 0.001))
			obox(part, "WRDoorPaint", cpos, (u, PY, n), (w / 2 - 0.01, hh, 0.002))
	for yy in (yb + 0.2, yt - 0.2):
		hp = (hinge[0] - u[0] * 0.006, yy, hinge[1] - u[2] * 0.006)
		part.cylinder("W1Iron", G(*hp), 0.009, 0.1, axis="Z", segments=8)
	# Slide bolt on the stall side, the pull handle on the room side, a coat hook up top inside.
	inner = n if n[2] < 0 else (-n[0], 0.0, -n[2])  # the face looking into the stall
	room = (-inner[0], 0.0, -inner[2])
	free = (hinge[0] + u[0] * (w - 0.06), hinge[1] + u[2] * (w - 0.06))
	for side, mat, size in ((inner, "WRChrome", (0.05, 0.012, 0.008)), (room, "W1Iron", (0.006, 0.07, 0.012))):
		cpos = (free[0] + side[0] * (t / 2 + size[2]), 1.0, free[1] + side[2] * (t / 2 + size[2]))
		obox(part, mat, cpos, (u, PY, side), size)
	hook = (hinge[0] + u[0] * w / 2 + inner[0] * (t / 2 + 0.02), yt - 0.18, hinge[1] + u[2] * w / 2 + inner[2] * (t / 2 + 0.02))
	obox(part, "WRChrome", hook, (u, PY, inner), (0.006, 0.03, 0.02))


# ---------------------------------------------------------------- trough, taps, pipes

def trough():
	part = K.Part("Trough")
	T = L.TROUGH
	x0, x1 = T["x"]
	z0, z1 = T["z"]
	top, rim, bottom = T["top"], T["rim"], T["bottom"]
	c, t = L.COVER, L.TILE_T
	# Outer faces: the front (facing +x), the two ends.
	plane(part, "WRTiles", (x1, 0.0, z1), NZ, PY, z1 - z0, top, (), stall_uv("trough_front"))
	plane(part, "WRTiles", (x0 + c + t, 0.0, z1), PX, PY, x1 - x0 - c - t, top, (), stall_uv("trough_end"))
	plane(part, "WRTiles", (x1, 0.0, z0), NX, PY, x1 - x0 - c - t, top, (), stall_uv("trough_end"))
	# The rim: bullnose tiles all round the channel.
	ix0, ix1, iz0, iz1 = x0 + c + t + rim * 0.6, x1 - rim, z0 + rim, z1 - rim
	for lo, hi in (((x0 + c + t, top - 0.03, z0), (ix0, top, z1)), ((ix1, top - 0.03, z0), (x1 + 0.006, top + 0.004, z1)),
			((ix0, top - 0.03, z0), (ix1, top, iz0)), ((ix0, top - 0.03, iz1), (ix1, top, z1))):
		faces = gbox(part, "WRTiles", lo, hi, bevel=0.006)
		part.set_uv2(faces, lambda co: L.to_uv(L.RECT_STALLS, 11.6, 0.2, SC["stalls"]))
	# The channel: sides and a bottom falling to the drain at the south end.
	b_n, b_s = bottom + 0.025, bottom

	def yb(z):
		return b_s + (b_n - b_s) * (z - iz0) / (iz1 - iz0)
	verts = [G(ix0, yb(iz0), iz0), G(ix1, yb(iz0), iz0), G(ix1, yb(iz1), iz1), G(ix0, yb(iz1), iz1)]
	f = part.poly("WRTiles", verts, [(0, 1, 2, 3)], recalc=False)[0]
	f.normal_update()
	if f.normal.z < 0:
		f.normal_flip()
	part.set_uv2([f], lambda co: L.to_uv(L.RECT_STALLS, 12.2 + (-co.y - iz0) * 0.3, 0.6, SC["stalls"]))
	ytop = top - 0.03
	for a, b, n in (((ix0, iz0), (ix0, iz1), PX), ((ix1, iz1), (ix1, iz0), NX), ((ix1, iz0), (ix0, iz0), PZ),
			((ix0, iz1), (ix1, iz1), NZ)):
		v = [G(a[0], yb(a[1]), a[1]), G(b[0], yb(b[1]), b[1]), G(b[0], ytop, b[1]), G(a[0], ytop, a[1])]
		f = K.quad(part, "WRTiles", (a[0], yb(a[1]), a[1]), (b[0], yb(b[1]), b[1]), (b[0], ytop, b[1]), (a[0], ytop, a[1]), n)
		part.set_uv2([f], lambda co: L.to_uv(L.RECT_STALLS, 12.4, 0.5, SC["stalls"]))
	# Drain grate at the south end, its pipe out through the end face and down to a floor trap.
	dz = iz0 + 0.06
	part.cylinder("WRChrome", G(0.38, yb(dz) + 0.002, dz), 0.035, 0.004, axis="Z", segments=16)
	gtube(part, "WRPVC", [(0.38, 0.5, z0 - 0.02), (0.38, 0.5, z0 - 0.09), (0.38, 0.45, z0 - 0.13), (0.38, 0.02, z0 - 0.13)], 0.022, 10)
	part.cylinder("WRPVC", G(0.38, 0.015, z0 - 0.13), 0.05, 0.03, axis="Z", segments=16)
	# The three wall taps over the channel, on a tee from the exposed supply pipe under the mirror.
	wall = L.WEST + c + t
	for tz in L.TAP_ZS:
		tap(part, (wall, 1.0, tz), PX, L.TAP_SPOUT[0] - wall)
		gtube(part, "WRPipe", [(wall + 0.03, L.PIPE_Y, tz), (wall + 0.03, 1.03, tz)], 0.011)
	pz0, pz1 = -0.6, -3.4
	gtube(part, "WRPipe", [(wall + 0.03, L.PIPE_Y, pz0), (wall + 0.03, L.PIPE_Y, pz1)], 0.013)
	part.cylinder("WRPipe", G(wall + 0.03, L.PIPE_Y, pz0), 0.016, 0.03, axis="Y", segments=10)  # end cap (along z)
	# The riser at the trough's end up to the pipe that runs back along the west wall and the back wall to the stalls.
	rz = -3.42
	gtube(part, "WRPipe", [(wall + 0.03, L.PIPE_Y, rz + 0.02), (wall + 0.03, L.PIPE_Y, rz), (wall + 0.03, 2.35, rz),
		(wall + 0.03, 2.35, L.BACK + 0.06), (wall + 0.06, 2.35, L.BACK + c + t + 0.03), (L.EAST - 0.1, 2.35, L.BACK + c + t + 0.03)], 0.013)
	gtube(part, "WRPipe", [(wall + 0.03, 0.0, rz), (wall + 0.03, L.PIPE_Y, rz)], 0.015)
	for z in (-1.2, -2.4, rz - 0.6):
		gbox(part, "W1Iron", (wall, L.PIPE_Y - 0.02 if z > rz else 2.33, z - 0.012), (wall + 0.05, L.PIPE_Y + 0.02 if z > rz else 2.37, z + 0.012))
	return build(part)


# ---------------------------------------------------------------- fixtures

def fixtures():
	part = K.Part("Fixtures")
	c, t = L.COVER, L.TILE_T
	wall = L.WEST + c + t
	# Mirror frame: an aluminium angle round the glass (the glass is mirror.gd's Surface, sized by washroom_real.gd).
	mx, my, mz = L.MIRROR["centre"]
	w, h = L.MIRROR["size"]
	for (y0, y1, z0, z1) in ((my - h / 2 - 0.02, my - h / 2, mz - w / 2 - 0.02, mz + w / 2 + 0.02),
			(my + h / 2, my + h / 2 + 0.02, mz - w / 2 - 0.02, mz + w / 2 + 0.02),
			(my - h / 2, my + h / 2, mz - w / 2 - 0.02, mz - w / 2), (my - h / 2, my + h / 2, mz + w / 2, mz + w / 2 + 0.02)):
		gbox(part, "W1Alu", (wall, y0, z0), (mx + 0.006, y1, z1), bevel=0.002)
	gbox(part, "W1Black", (wall, my - h / 2, mz - w / 2), (mx - 0.004, my + h / 2, mz + w / 2))
	# Notice board where core pastes the washroom notice: cork in an aluminium frame, 5 mm behind the paper.
	nx, ny, nz = L.NOTICE["centre"]
	nw, nh = L.NOTICE["size"]
	gbox(part, "WRCork", (wall, ny - nh / 2, nz - nw / 2), (nx - 0.006, ny + nh / 2, nz + nw / 2))
	for (y0, y1, z0, z1) in ((ny - nh / 2 - 0.015, ny - nh / 2, nz - nw / 2 - 0.015, nz + nw / 2 + 0.015),
			(ny + nh / 2, ny + nh / 2 + 0.015, nz - nw / 2 - 0.015, nz + nw / 2 + 0.015),
			(ny - nh / 2, ny + nh / 2, nz - nw / 2 - 0.015, nz - nw / 2), (ny - nh / 2, ny + nh / 2, nz + nw / 2, nz + nw / 2 + 0.015)):
		gbox(part, "W1Alu", (wall, y0, z0), (nx - 0.002, y1, z1), bevel=0.002)
	# The tube batten over WashroomLight (washroom_real.gd lights its tube with the light).
	lx, ly, lz = L.LIGHT
	H = L.CEILING - c
	gbox(part, "W1Enamel", (lx - 0.64, H - 0.05, lz - 0.045), (lx + 0.64, H, lz + 0.045), bevel=0.008)
	part.cylinder("WRTubeGlass", G(lx, H - 0.062, lz), 0.013, 1.2, axis="X", segments=10)
	for end in (-0.61, 0.61):
		gbox(part, "W1Alu", (lx + end - 0.015, H - 0.08, lz - 0.02), (lx + end + 0.015, H - 0.05, lz + 0.02))
	# A ventilation block high in the back wall over the middle stall: a concrete frame, square holes (blind).
	vx0, vx1, vy0, vy1 = 2.55, 3.45, 2.46, 2.84
	vz = L.BACK + c
	gbox(part, "WRVent", (vx0, vy0, vz), (vx1, vy1, vz + 0.03))
	cols, rows = 5, 2
	for i in range(cols):
		for j in range(rows):
			hx0 = vx0 + 0.04 + i * (vx1 - vx0 - 0.08) / cols + 0.015
			hx1 = vx0 + 0.04 + (i + 1) * (vx1 - vx0 - 0.08) / cols - 0.015
			hy0 = vy0 + 0.04 + j * (vy1 - vy0 - 0.08) / rows + 0.015
			hy1 = vy0 + 0.04 + (j + 1) * (vy1 - vy0 - 0.08) / rows - 0.015
			gbox(part, "W1Black", (hx0, hy0, vz + 0.0305), (hx1, hy1, vz + 0.0315))
	# Hooks on the east wall by the entrance.
	ew = L.EAST - c - t
	for k in range(4):
		z = -0.75 - k * 0.24
		gbox(part, "WRChrome", (ew - 0.012, 1.6, z - 0.012), (ew, 1.64, z + 0.012))
		gtube(part, "WRChrome", [(ew - 0.006, 1.62, z), (ew - 0.05, 1.62, z), (ew - 0.06, 1.65, z)], 0.004, 6)
	return build(part)


# ---------------------------------------------------------------- props

def bucket(part, mat, at, r=0.15, h=0.3, handle=True):
	x, y, z = at
	lathe_at(part, mat, [(r * 0.78, 0.0), (r * 0.8, 0.004), (r, h - 0.02), (r * 1.06, h), (r * 1.06, h + 0.008),
		(r * 0.99, h + 0.008), (r * 0.94, h - 0.02), (r * 0.74, 0.012)], (x, y, z), segments=24)
	if handle:
		pts = [(x - r * 1.05, y + h - 0.04, z)] + [(x + r * 1.05 * math.cos(a), y + h + 0.06 * math.sin(a), z)
			for a in [math.pi - math.pi * k / 10 for k in range(11)]] + [(x + r * 1.05, y + h - 0.04, z)]
		gtube(part, "W1Iron", pts, 0.0025, 6)


def dipper(part, mat, at, yaw=0.0):
	"""A plastic dipper (gáo): a round bowl and a straight handle."""
	x, y, z = at
	lathe_at(part, mat, [(0.0, 0.0), (0.045, 0.004), (0.07, 0.04), (0.074, 0.075), (0.07, 0.075), (0.064, 0.04),
		(0.04, 0.008), (0.0, 0.006)], (x, y, z), segments=18)
	a = math.radians(yaw)
	d = (math.cos(a), math.sin(a))
	obox(part, mat, (x + d[0] * 0.15, y + 0.07, z + d[1] * 0.15), ((d[0], 0.0, d[1]), PY, (-d[1], 0.0, d[0])), (0.085, 0.006, 0.014))


def basin(part, mat, at, r=0.24, h=0.11):
	lathe_at(part, mat, [(r * 0.62, 0.0), (r * 0.64, 0.004), (r, h - 0.01), (r * 1.06, h), (r * 1.06, h + 0.006),
		(r * 0.98, h + 0.006), (r * 0.94, h - 0.012), (r * 0.6, 0.01)], at, segments=28)


def props():
	part = K.Part("Props")
	P = L.PLATFORM_H
	colours = ["WRBlue", "WRRed", "WRGreen"]
	dippers = ["WRYellow", "WRBlue", "WRPink"]
	for k, (sx0, sx1) in enumerate(L.STALL_XS):
		c = (sx0 + sx1) / 2
		bx, bz = c + 0.42, L.BACK + 0.25
		bucket(part, colours[k], (bx, P, bz), r=0.15, h=0.3)
		dipper(part, dippers[k], (bx - 0.02, P + 0.31, bz + 0.03), yaw=60 + k * 35)
		# A small bin for the paper in the far corner.
		lathe_at(part, "WRGrey", [(0.08, 0.0), (0.09, 0.22), (0.095, 0.225), (0.088, 0.225), (0.078, 0.008)],
			(c - 0.55, P, L.BACK + 0.14), segments=16)
	# The cleaning corner by the entrance: a mop bucket with its mop leaning on the wall, a basin.
	bucket(part, "WRGrey", (5.55, 0.0, -0.42), r=0.16, h=0.3)
	mx, mz = 5.62, -0.72
	gtube(part, "W1WoodPale", [(mx - 0.02, 0.06, mz), (5.86, 1.36, mz - 0.08)], 0.012, 8)
	for k in range(14):
		a = k / 14 * math.tau
		ex, ez = mx - 0.02 + math.cos(a) * 0.09, mz + math.sin(a) * 0.09
		gtube(part, "WRMop", [(mx - 0.02, 0.07, mz), ((mx - 0.02 + ex) / 2, 0.04, (mz + ez) / 2), (ex, 0.008, ez)], 0.012, 5)
	basin(part, "WRRed", (5.58, 0.0, -2.15))
	basin(part, "WRBlue", (5.6, 0.112, -2.12), r=0.2, h=0.09)
	# A bin by the entrance, soap dishes on the trough's wall rim, a jug at its end.
	lathe_at(part, "WRBlue", [(0.13, 0.0), (0.15, 0.36), (0.155, 0.365), (0.146, 0.365), (0.125, 0.01)],
		(1.95, 0.0, -0.32), segments=20)
	wall = L.WEST + L.COVER + L.TILE_T
	for k, tz in enumerate(L.TAP_ZS):
		sz = tz + 0.24
		gbox(part, ["WRPink", "WRBlue", "WRGreen"][k], (wall + 0.03, 0.86, sz - 0.06), (wall + 0.13, 0.875, sz + 0.06), bevel=0.004)
		if k != 1:
			gbox(part, "WRSoap", (wall + 0.045, 0.875, sz - 0.04), (wall + 0.115, 0.895, sz + 0.04), bevel=0.008)
	# A jug on the floor by the trough's end.
	lathe_at(part, "WRYellow", [(0.0, 0.0), (0.07, 0.002), (0.075, 0.15), (0.068, 0.16), (0.0, 0.16)], (0.36, 0.0, -0.3), segments=18)
	obox(part, "WRYellow", (0.36, 0.08, -0.22), (PZ, PY, PX), (0.012, 0.05, 0.01))
	# A towel on the second hook.
	ew = L.EAST - L.COVER - L.TILE_T
	z = -0.99
	part.poly("WRTowel", [G(ew - 0.055, 1.64, z - 0.2), G(ew - 0.055, 1.64, z + 0.2), G(ew - 0.03, 1.08, z + 0.17),
		G(ew - 0.03, 1.08, z - 0.19)], [(0, 1, 2, 3)], recalc=False)
	part.poly("WRTowel", [G(ew - 0.06, 1.64, z + 0.2), G(ew - 0.06, 1.64, z - 0.2), G(ew - 0.07, 1.25, z - 0.18),
		G(ew - 0.07, 1.25, z + 0.19)], [(0, 1, 2, 3)], recalc=False)
	return build(part)


def mirror_stain():
	part = K.Part("MirrorStain")
	mx, my, mz = L.MIRROR["centre"]
	w, h = L.MIRROR["size"]
	x = mx + 0.0015
	f = K.quad(part, "WRMirrorStain", (x, my - h / 2, mz + w / 2), (x, my - h / 2, mz - w / 2), (x, my + h / 2, mz - w / 2),
		(x, my + h / 2, mz + w / 2), PX)
	part.planar_uv([f], G(x, my - h / 2, mz + w / 2), G(0, 0, -1) - G(0, 0, 0), G(0, 1, 0) - G(0, 0, 0), size=(w, h))
	K.keep_uv(part, [f])
	return build(part)


def main():
	materials()
	objs = [shell(), stalls(), trough(), fixtures(), props(), mirror_stain()]
	OUT.mkdir(parents=True, exist_ok=True)
	K.w1kit.export(OUT / "washroom.glb", objs)


if __name__ == "__main__":
	main()
