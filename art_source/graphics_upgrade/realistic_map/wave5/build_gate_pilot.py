"""T-262 round 1: the school gate pilot (card section 2, step 2) with the options the owner picks from. Blender 5.2.2,
bmesh only, no add-on, no Tripo. Every piece stands where the PS1 piece stood (gate_layout.py) and stays inside the PS1
colliders or above head height; nothing is put between Start_gate and the guard line higher than the PS1 barriers.
All glbs are in Godot world space with the origin at Godot (0, G, 0), except barrier.glb and cone.glb (origin on the
ground at the piece's centre).

  court.glb           the court's top (x 190..250, z -60..-20) and its 4 cm edges: Pavers (C2, grey "con sâu" blocks
                      of D-175/D-178) and Asphalt (C1); one of the two is shown
  outside.glb         seen through the gate, out of reach: the pavement and the street outside the wall (z -60..-72)
  court_cracks.glb    cracks where the PS1 RoadCrack212/222/233 ran and round the tilted pillar's foot
  pillars_plaster.glb P1: both pillars, rendered plaster whitewashed (D-175 K1) on a concrete plinth; Pillar209 tilted 7
                      degrees with its crack; pillars_brick.glb P2: the shafts faced with red brick, plinth and cap whitewashed
  gate_swing.glb      G1: two swing leaves of painted steel (green), vertical bars with spear tips over a sheet panel,
                      support wheels, lock and chain (the gate's 3 m)
  gate_folding.glb    G2: a stainless folding (accordion) gate in two halves, 1.9 m, on a ground track
  sign_arch.glb       SA: a steel truss arch over the gate, the blue sheet board hanging from it by its west hangers only,
                      its east end fallen onto the gate (board W5SignText; W5SignBlank swapped in for "no text")
  sign_band.glb       SB: a plastered sign band once bolted on brackets on the two pillar caps, the east bracket torn,
                      the band hanging the same way; sign_letters.glb: its raised red letters "TRƯỜNG ĐẠI HỌC" (text only)
  booth_masonry.glb   K1: a brick booth rendered and washed yellow, white skirting band, flat concrete roof, aluminium
                      sliding window with a grille, steel door; booth_prefab.glb K2: white composite panels on a blue
                      steel frame, the same window, corrugated roof; booth_interior.glb: desk, plastic chair, log book,
                      phone, flask, cup, fan, CCTV monitor, cap, calendar, key box (seen through the window)
  wall_plaster.glb    W1: the south wall from x 186 to the gate and from the gate to x 262: posts every 3 m, rendered
                      panels 1.8 m, iron bars to 3 m; wall_brick.glb W2: bare brick 2.7 m, brick piers, concrete coping
  barrier.glb         the portable red-and-white barricade (the PS1 barriers' place and 2.2 x 1.0 x 0.5 collider)
  cone.glb            a traffic cone (0.7 m) with two reflective bands
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave5/build_gate_pilot.py [-- name ...]
"""
import json
import math
from pathlib import Path
import random
import sys

import bpy
from mathutils import Vector

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE.parent / "wave1"))
sys.path.insert(0, str(HERE))
import w1kit  # noqa: E402
import gate_layout as L  # noqa: E402

ROOT = HERE.parents[3]
OUT = ROOT / "game/assets/models/graphics_pilot/realistic_map/wave5"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
G = L.G

PREVIEW = {"W5Plaster": ((0.85, 0.83, 0.78), 0.85), "W5Brick": ((0.55, 0.27, 0.16), 0.9), "W5GateGreen": ((0.15, 0.25, 0.18), 0.5),
	"W5Stainless": ((0.7, 0.7, 0.7), 0.3), "W5SignText": ((0.15, 0.25, 0.45), 0.5), "W5Band": ((0.8, 0.78, 0.72), 0.85),
	"W5LetterRed": ((0.55, 0.08, 0.06), 0.45), "W5BoothYellow": ((0.85, 0.7, 0.35), 0.85), "W5PlasterInner": ((0.8, 0.78, 0.7), 0.85),
	"W5Panel": ((0.78, 0.79, 0.77), 0.55), "W5FrameBlue": ((0.15, 0.3, 0.55), 0.5), "W5CourtPavers": ((0.5, 0.49, 0.46), 0.85),
	"W5CourtAsphalt": ((0.22, 0.22, 0.21), 0.9), "W5GroundCrack": ((0.1, 0.1, 0.1), 0.9), "W5BarrierStripes": ((0.7, 0.3, 0.3), 0.6),
	"W5ConeOrange": ((0.85, 0.32, 0.06), 0.55), "W5Reflect": ((0.85, 0.85, 0.82), 0.3), "W5DoorPaint": ((0.2, 0.3, 0.25), 0.5),
	"W1Concrete": ((0.52, 0.51, 0.47), 0.9), "W1Iron": ((0.17, 0.17, 0.16), 0.55), "W1Alu": ((0.8, 0.8, 0.78), 0.4),
	"W2Glass": ((0.5, 0.58, 0.56), 0.06)}

# The fallen board (SA) or band (SB): top-west corner hinged under the arch / on Pillar209's cap bracket, 14.5 x 1.27 m
# (the texture's 16 x 1.4 m scaled), turned 11 degrees down to the east so its east end rests on the swing gate's top.
SIGN = {"hinge": (210.5, -3.75), "length": 14.5, "height": 1.27, "angle": -11.0}
SIGN_SCALE = 14.5 / 16.0


def mat(name):
	color, rough = PREVIEW.get(name, ((0.5, 0.5, 0.5), 0.8))
	return w1kit.material(name, color, rough)


def B(p):
	"""Godot world point (origin of the glb at Godot (0, G, 0)) to Blender."""
	return Vector((p[0], -p[2], p[1] - G))


class GPart(w1kit.Part):
	"""w1kit.Part with helpers in Godot coordinates (x, y up, z)."""

	def face(self, m, pts, normal=None, uv=None):
		"""One polygon from Godot points; reversed if its winding disagrees with `normal` (Godot)."""
		vs = [B(p) for p in pts]
		if normal is not None:
			n = (vs[1] - vs[0]).cross(vs[2] - vs[0])
			if n.length < 1e-12 and len(vs) > 3:
				n = (vs[2] - vs[0]).cross(vs[3] - vs[0])
			if n.dot(Vector((normal[0], -normal[2], normal[1]))) < 0:
				vs.reverse()
				if uv is not None:
					uv = list(reversed(uv))
		made = [self.bm.verts.new(v) for v in vs]
		f = self.bm.faces.new(made)
		f.material_index = self.slot(m)
		f.smooth = False
		if uv is not None:
			for loop, t in zip(f.loops, uv):
				loop[self.uv].uv = t
			f.tag = True
		return f

	def xbox(self, m, lo, hi, xf=None, skip=()):
		"""A box from local lo..hi, its corners mapped by xf (local Godot -> world Godot); faces keyed by side."""
		xf = xf or (lambda p: p)
		x0, y0, z0 = lo
		x1, y1, z1 = hi
		c = {(i, j, k): xf((x1 if i else x0, y1 if j else y0, z1 if k else z0)) for i in (0, 1) for j in (0, 1) for k in (0, 1)}
		centre = Vector(xf(((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)))
		sides = {"-x": [(0, 0, 0), (0, 0, 1), (0, 1, 1), (0, 1, 0)], "+x": [(1, 0, 0), (1, 1, 0), (1, 1, 1), (1, 0, 1)],
			"-y": [(0, 0, 0), (1, 0, 0), (1, 0, 1), (0, 0, 1)], "+y": [(0, 1, 0), (0, 1, 1), (1, 1, 1), (1, 1, 0)],
			"-z": [(0, 0, 0), (0, 1, 0), (1, 1, 0), (1, 0, 0)], "+z": [(0, 0, 1), (1, 0, 1), (1, 1, 1), (0, 1, 1)]}
		out = {}
		for side, keys in sides.items():
			if side in skip:
				continue
			pts = [c[k] for k in keys]
			mid = sum((Vector(p) for p in pts), Vector()) / 4.0
			n = mid - centre
			out[side] = self.face(m, pts, (n.x, n.y, n.z))
		return out

	def gbox(self, m, lo, hi, skip=()):
		return list(self.xbox(m, lo, hi, None, skip).values())

	def beam(self, m, p0, p1, w, h, up=(0, 1, 0), caps=True):
		"""An oriented box from p0 to p1 (Godot), w wide, h tall about the `up` hint."""
		a, b = B(p0), B(p1)
		d = (b - a).normalized()
		u = Vector((up[0], -up[2], up[1]))
		side = d.cross(u)
		if side.length < 1e-6:
			side = d.cross(Vector((1, 0, 0)))
		side.normalize()
		upv = side.cross(d).normalized()
		c = [a + side * sx * w / 2 + upv * sy * h / 2 for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1))]
		e = [b + side * sx * w / 2 + upv * sy * h / 2 for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1))]
		verts = [self.bm.verts.new(v) for v in c + e]
		quads = [(0, 1, 5, 4), (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)]
		if caps:
			quads += [(3, 2, 1, 0), (4, 5, 6, 7)]
		faces = [self.bm.faces.new([verts[i] for i in q]) for q in quads]
		idx = self.slot(m)
		for f in faces:
			f.material_index = idx
			f.smooth = False
		return faces

	def pipe(self, m, pts, r, sides=8, cap=True):
		return self.tube(m, [B(p) for p in pts], r, segments=sides, cap=cap)

	def map_uv2(self, faces, fn):
		"""fn(Godot point) -> (u, v) image coordinates (v down); stored flipped for glTF."""
		def wrap(co):
			u, v = fn((co.x, co.z + G, -co.y))
			return (u, 1.0 - v)
		self.set_uv2(faces, wrap)


def set_uv(part, faces, fn):
	"""UV1 from fn(Godot point) -> (u, v) as Godot will read it (V flipped for glTF)."""
	for f in faces:
		for loop in f.loops:
			co = loop.vert.co
			u, v = fn((co.x, co.z + G, -co.y))
			loop[part.uv].uv = (u, 1.0 - v)
		f.tag = True


def export(path, objs):
	w1kit.export(path, objs)
	for o in objs:
		print("T262_PART %s %s %d tris %s" % (Path(path).name, o.name, w1kit.triangles([o]), [m.name for m in o.data.materials]))


def build(part, uv_size=None):
	for name in part.slots:
		mat(name)
	part.bm.normal_update()  # faces.new leaves normals at zero; w1kit's box projection reads them
	return part.build(uv_size=uv_size or {})


def ensure_uv2(part):
	"""Shell-shader materials read a mask on UV2: faces without their own sample its clean corner (w1kit.build)."""
	if not hasattr(part, "uv2"):
		part.set_uv2([], lambda co: (0.995, 0.995))


# ------------------------------------------------------------------------------------------------ court

def build_court():
	w1kit.reset()
	x0, x1 = L.COURT["x"]
	z0, z1 = L.COURT["z"]
	objs = []
	for name, m, tile in (("Pavers", "W5CourtPavers", 0.9), ("Asphalt", "W5CourtAsphalt", 2.0)):
		part = GPart(name)
		faces = [part.face(m, [(x0, G, z0), (x1, G, z0), (x1, G, z1), (x0, G, z1)], (0, 1, 0))]
		# The court's 4 cm edges down to the ground round it (north, west, east).
		faces.append(part.face(m, [(x0, L.GROUND, z1), (x1, L.GROUND, z1), (x1, G, z1), (x0, G, z1)], (0, 0, 1)))
		faces.append(part.face(m, [(x0, L.GROUND, z0), (x0, L.GROUND, z1), (x0, G, z1), (x0, G, z0)], (-1, 0, 0)))
		faces.append(part.face(m, [(x1, L.GROUND, z0), (x1, L.GROUND, z1), (x1, G, z1), (x1, G, z0)], (1, 0, 0)))
		set_uv(part, faces, lambda p, t=tile: ((p[0] + (p[1] - G) * 0.0) / t, (p[2] + (G - p[1])) / t))
		part.map_uv2(faces, court_uv2)
		objs.append(build(part))
	export(OUT / "court.glb", objs)


def court_uv2(p):
	return ((p[0] - 180.0) / 82.0, (p[2] + 72.0) / 85.0)


def build_outside():
	"""The pavement (level with the court) and the street (12 cm lower) outside the wall, out of reach."""
	w1kit.reset()
	xa, xb = 196.0, 244.0
	pave = GPart("Pavement")
	faces = [pave.face("W5CourtPavers", [(xa, G, -63.0), (xb, G, -63.0), (xb, G, -60.15), (xa, G, -60.15)], (0, 1, 0))]
	set_uv(pave, faces, lambda p: (p[0] / 0.9, p[2] / 0.9))
	pave.map_uv2(faces, court_uv2)
	kerb = GPart("Kerb")
	kerb.gbox("W1Concrete", (xa, G - 0.14, -63.15), (xb, G + 0.005, -63.0))
	road = GPart("Street")
	faces = [road.face("W5CourtAsphalt", [(xa - 8, G - 0.12, -76.0), (xb + 8, G - 0.12, -76.0), (xb + 8, G - 0.12, -63.15),
		(xa - 8, G - 0.12, -63.15)], (0, 1, 0))]
	set_uv(road, faces, lambda p: (p[0] / 2.0, p[2] / 2.0))
	road.map_uv2(faces, court_uv2)
	# A worn centre line, dashed.
	x = xa - 8
	while x < xb + 8:
		road.face("W4Paint", [(x, G - 0.118, -69.6), (x + 1.5, G - 0.118, -69.6), (x + 1.5, G - 0.118, -69.48), (x, G - 0.118, -69.48)], (0, 1, 0))
		x += 4.0
	export(OUT / "outside.glb", [build(pave), build(kerb, {"W1Concrete": 1.0}), build(road, {"W4Paint": 1.0})])


def crack_quad(part, a, b, width=0.5, v0=0.0):
	"""A crack strip lying on the court from a to b (x, z), the texture's 8 m along it."""
	(ax, az), (bx, bz) = a, b
	length = math.hypot(bx - ax, bz - az)
	dx, dz = (bx - ax) / length, (bz - az) / length
	nx, nz = -dz * width / 2, dx * width / 2
	y = G + 0.003
	pts = [(ax - nx, y, az - nz), (ax + nx, y, az + nz), (bx + nx, y, bz + nz), (bx - nx, y, bz - nz)]
	uv = [(0, v0), (1, v0), (1, v0 + length / 8.0), (0, v0 + length / 8.0)]
	return part.face("W5GroundCrack", pts, (0, 1, 0), [(u, 1.0 - v) for u, v in uv])


def build_cracks():
	w1kit.reset()
	part = GPart("Cracks")
	rng = random.Random(262)
	for i, x in enumerate(L.ROAD_CRACKS):
		# The PS1 crack zigzagged from (x, -54) to (x, -47.1): one strip with a slight lean, and a branch.
		top = (x + rng.uniform(-0.4, 0.4), -46.6)
		crack_quad(part, (x, -54.3), top, 0.5, rng.uniform(0, 0.1))
		mid = (x + (top[0] - x) * 0.45, -51.0)
		crack_quad(part, mid, (mid[0] + rng.choice((-1, 1)) * 1.6, -49.2), 0.35, 0.5)
	# The heaved ground at the tilted pillar's foot: short cracks out from its north and east sides.
	for a, b in (((209.3, -58.2), (210.1, -55.6)), ((209.9, -58.6), (212.3, -57.9)), ((208.6, -58.2), (207.6, -56.4))):
		crack_quad(part, a, b, 0.45, rng.uniform(0.2, 0.6))
	export(OUT / "court_cracks.glb", [build(part)])


# ------------------------------------------------------------------------------------------------ pillars

def pillar_xf(name):
	c, s, cx, cy = L.pillar_matrix(name)
	return lambda p: (cx + p[0] * c - p[1] * s, cy + p[0] * s + p[1] * c, L.PILLAR["z"] + p[2])


def pillar_local(name, w):
	c, s, cx, cy = L.pillar_matrix(name)
	dx, dy = w[0] - cx, w[1] - cy
	return (dx * c + dy * s, -dx * s + dy * c, w[2] - L.PILLAR["z"])


def pillar_uv(name, kind):
	"""UV1 on the pillar's own axes (so bricks and plaster tilt with Pillar209), UV2 into mask_gate's pillar band."""
	base_u = 0.0 if name == "Pillar209" else 0.5

	def uv1(p):
		lx, ly, lz = pillar_local(name, p)
		return lx, ly, lz

	def uv2(p):
		lx, ly, lz = pillar_local(name, p)
		s = (math.atan2(lz, lx) + math.pi) / math.tau
		return (base_u + 0.02 + s * 0.46, 0.75 - min(max((ly + 3.4) / 6.4, 0.0), 1.0) * 0.5)
	return uv1, uv2


def uv_local(part, faces, name, scale_u=1.0, scale_v=1.0):
	"""Box projection on the pillar's local axes."""
	part.bm.normal_update()
	for f in faces:
		nl = pillar_local(name, (f.normal.x, f.normal.z + G, -f.normal.y))
		nl = (nl[0] - pillar_local(name, (0, G, 0))[0], nl[1] - pillar_local(name, (0, G, 0))[1], nl[2] - pillar_local(name, (0, G, 0))[2])
		ax = max(range(3), key=lambda i: abs(nl[i]))
		for loop in f.loops:
			co = loop.vert.co
			lx, ly, lz = pillar_local(name, (co.x, co.z + G, -co.y))
			if ax == 1:
				u, v = lx, lz
			elif ax == 0:
				u, v = lz, ly
			else:
				u, v = lx, ly
			loop[part.uv].uv = (u * scale_u, v * scale_v)
		f.tag = True


def build_pillars(kind):
	w1kit.reset()
	objs = []
	for name in ("Pillar209", "Pillar231"):
		part = GPart(name)
		xf = pillar_xf(name)
		uv1, uv2 = pillar_uv(name, kind)
		shaft_m = "W5Brick" if kind == "brick" else "W5Plaster"
		plaster = []
		bricks = []
		concrete = []
		# Plinth (buried 0.3 m: Pillar209's tilt lifts its east corner 11 cm off the court).
		concrete += list(part.xbox("W1Concrete", (-0.695, -3.3, -0.695), (0.695, -2.55, 0.695), xf).values())
		shaft = list(part.xbox(shaft_m, (-0.62, -2.55, -0.62), (0.62, 2.45, 0.62), xf, skip=("-y", "+y")).values())
		(bricks if kind == "brick" else plaster).extend(shaft)
		# Two bands under the cap, the cap and its top block.
		for y0, y1, r in ((1.5, 1.6, 0.655), (2.0, 2.1, 0.655)):
			plaster += list(part.xbox("W5Plaster", (-r, y0, -r), (r, y1, r), xf).values())
		plaster += list(part.xbox("W5Plaster", (-0.695, 2.45, -0.695), (0.695, 2.75, 0.695), xf).values())
		plaster += list(part.xbox("W5Plaster", (-0.58, 2.75, -0.58), (0.58, 2.97, 0.58), xf).values())
		if kind == "plaster":
			# A raised panel frame on the court (north) face and the street face.
			for lz, sgn in ((0.62, 1), (-0.62, -1)):
				for a, b in (((-0.45, -1.9), (0.45, -1.9)), ((-0.45, 1.2), (0.45, 1.2)), ((-0.45, -1.9), (-0.45, 1.2)), ((0.45, -1.9), (0.45, 1.2))):
					lo = (min(a[0], b[0]) - 0.035, min(a[1], b[1]) - 0.035, lz if sgn > 0 else lz - 0.025)
					hi = (max(a[0], b[0]) + 0.035, max(a[1], b[1]) + 0.035, lz + 0.025 if sgn > 0 else lz)
					plaster += list(part.xbox("W5Plaster", lo, hi, xf).values())
		uv_local(part, plaster + concrete, name)
		if bricks:
			uv_local(part, bricks, name, 1.0 / 0.92, 1.0 / 0.84)
		part.map_uv2(plaster, uv2)
		ensure_uv2(part)
		if name == "Pillar209":
			# The PS1 PillarCrack: down the north face, from the cap band to the plinth (W1Crack is 0.5 x 2.4 m).
			pts = [xf((-0.32, -2.4, 0.627)), xf((0.18, -2.4, 0.627)), xf((0.3, 0.0, 0.627)), xf((-0.2, 0.0, 0.627))]
			part.face("W1Crack", pts, (0, 0, 1), [(0, 1), (1, 1), (1, 0), (0, 0)])
		objs.append(build(part, {"W1Concrete": 1.0}))
	export(OUT / f"pillars_{kind}.glb", objs)


# ------------------------------------------------------------------------------------------------ gates

GATE_X = (210.15, 229.85)


def build_gate_swing():
	"""G1: two 9.82 m leaves meeting at x 220, 3 m with the spear tips, all inside the Gate collider's 0.18 m."""
	w1kit.reset()
	part = GPart("Gate")
	M = "W5GateGreen"
	z = -59.0
	top, mid, bottom = G + 2.82, G + 0.95, G + 0.1
	for x0, x1, hinge_x in ((GATE_X[0], 219.97, GATE_X[0]), (220.03, GATE_X[1], GATE_X[1])):
		for xs in (x0 + 0.03, x1 - 0.03):
			part.beam(M, (xs, bottom - 0.04, z), (xs, top + 0.03, z), 0.06, 0.06)
		for y in (bottom, mid, top):
			part.beam(M, (x0 + 0.06, y, z), (x1 - 0.06, y, z), 0.06, 0.05, caps=False)
		part.beam(M, (x0 + 0.06, top - 0.32, z), (x1 - 0.06, top - 0.32, z), 0.03, 0.03, caps=False)
		# Sheet panel below the middle rail.
		part.gbox(M, (x0 + 0.06, bottom + 0.025, z - 0.006), (x1 - 0.06, mid - 0.025, z + 0.006))
		n = int((x1 - x0 - 0.12) / 0.125)
		step = (x1 - x0 - 0.12) / n
		for i in range(1, n):
			x = x0 + 0.06 + i * step
			part.beam(M, (x, mid + 0.025, z), (x, top + 0.1, z), 0.02, 0.02, caps=False)
			# Spear tip.
			a, b = top + 0.1, top + 0.18
			part.face(M, [(x - 0.02, a, z - 0.012), (x + 0.02, a, z - 0.012), (x, b, z)], (0, 0.3, -1))
			part.face(M, [(x - 0.02, a, z + 0.012), (x + 0.02, a, z + 0.012), (x, b, z)], (0, 0.3, 1))
			part.face(M, [(x - 0.02, a, z - 0.012), (x - 0.02, a, z + 0.012), (x, b, z)], (-1, 0.3, 0))
			part.face(M, [(x + 0.02, a, z - 0.012), (x + 0.02, a, z + 0.012), (x, b, z)], (1, 0.3, 0))
		# Two hinges on the pillar side and the support wheel under the free end.
		for y in (bottom + 0.3, top - 0.3):
			part.pipe("W1Iron", [(hinge_x, y - 0.08, z), (hinge_x, y + 0.08, z)], 0.025, 8)
		free = x1 - 0.25 if hinge_x == GATE_X[0] else x0 + 0.25
		part.pipe("W1Iron", [(free, G + 0.08, z - 0.035), (free, G + 0.08, z + 0.035)], 0.075, 10)
		part.beam("W1Iron", (free, G + 0.08, z), (free, bottom, z), 0.04, 0.03)
	# Lock box at the meeting stiles, a loop of chain and a padlock.
	part.gbox("W1Iron", (219.9, G + 1.05, z - 0.06), (220.1, G + 1.25, z + 0.06))
	pts = [(219.88 + 0.12 * math.cos(a), G + 1.3 + 0.1 * math.sin(a), z + 0.07) for a in [i / 10 * math.tau for i in range(11)]]
	part.pipe("W1Steel", pts, 0.008, 5, cap=False)
	part.gbox("W1Steel", (219.96, G + 1.12, z + 0.05), (220.03, G + 1.19, z + 0.075))
	export(OUT / "gate_swing.glb", [build(part, {M: 1.0, "W1Iron": 1.0, "W1Steel": 1.0})])


def build_gate_folding():
	"""G2: a stainless accordion gate, 1.9 m, closed from both pillars to a lock post at x 220."""
	w1kit.reset()
	part = GPart("Gate")
	M = "W5Stainless"
	z = -59.0
	H = 1.9
	part.gbox("W1Iron", (GATE_X[0], G - 0.005, z - 0.03), (GATE_X[1], G + 0.012, z + 0.03))  # ground track
	for x0, x1 in ((GATE_X[0], 219.95), (220.05, GATE_X[1])):
		n = int((x1 - x0) / 0.11)
		step = (x1 - x0) / n
		xs = [x0 + i * step for i in range(n + 1)]
		for i, x in enumerate(xs):
			part.beam(M, (x, G + 0.06, z), (x, G + H, z), 0.022, 0.04, caps=False)
			if i % 4 == 0:
				part.pipe("W1Rubber", [(x, G + 0.04, z - 0.02), (x, G + 0.04, z + 0.02)], 0.03, 8)
		tiers = 3
		for i in range(len(xs) - 1):
			xa, xb = xs[i], xs[i + 1]
			for t in range(tiers):
				ya = G + 0.12 + t * (H - 0.2) / tiers
				yb = ya + (H - 0.2) / tiers
				part.beam(M, (xa, ya, z), (xb, yb, z), 0.012, 0.02, up=(0, 0, 1), caps=False)
				part.beam(M, (xa, yb, z), (xb, ya, z), 0.012, 0.02, up=(0, 0, 1), caps=False)
		part.beam(M, (x0, G + H + 0.02, z), (x1, G + H + 0.02, z), 0.04, 0.04, caps=False)
	# End posts at the pillars and the lock post.
	for x in (GATE_X[0] + 0.03, GATE_X[1] - 0.03, 220.0):
		part.gbox(M, (x - 0.03, G, z - 0.035), (x + 0.03, G + H + 0.06, z + 0.035))
	part.gbox("W1Iron", (219.93, G + 1.0, z - 0.06), (220.07, G + 1.18, z + 0.06))
	export(OUT / "gate_folding.glb", [build(part, {M: 1.0, "W1Iron": 1.0, "W1Rubber": 1.0})])


# ------------------------------------------------------------------------------------------------ signs

def sign_frame():
	a = math.radians(SIGN["angle"])
	d = (math.cos(a), math.sin(a))
	up = (-d[1], d[0])
	hx, hy = SIGN["hinge"]
	return lambda u, v, z: (hx + d[0] * u + up[0] * v, hy + d[1] * u + up[1] * v, z)


def arch_y(x, chord):
	"""The arch's bottom (chord 0) or top (chord 1) line between the pillar caps."""
	t = (x - 209.0) / 22.0
	if chord == 0:
		return -3.78 + 1.15 * math.sin(math.pi * t)
	return -3.78 + 0.55 + 1.15 * math.sin(math.pi * t) - 0.12 * math.sin(math.pi * t)


def build_sign_arch():
	"""SA: the steel truss arch on the pillar caps and the board hanging from its two west hangers."""
	w1kit.reset()
	P = sign_frame()
	L_, H_ = SIGN["length"], SIGN["height"]
	arch = GPart("Arch")
	M = "W5GateGreen"
	z = -59.0
	xs = [209.0 + 22.0 * i / 40 for i in range(41)]
	for chord in (0, 1):
		arch.pipe(M, [(x, arch_y(x, chord), z) for x in xs], 0.05, 10, cap=True)
	for i in range(0, 40, 2):
		xa, xb = xs[i], xs[i + 2]
		xm = (xa + xb) / 2
		arch.pipe(M, [(xa, arch_y(xa, 0), z), (xm, arch_y(xm, 1), z)], 0.018, 6, cap=False)
		arch.pipe(M, [(xm, arch_y(xm, 1), z), (xb, arch_y(xb, 0), z)], 0.018, 6, cap=False)
	# Base plates on the caps.
	for x, y in ((208.75, -3.93), (231.0, -3.93)):
		arch.gbox("W1Iron", (x - 0.25, y, z - 0.25), (x + 0.25, y + 0.03, z + 0.25))
	objs = [build(arch, {M: 1.0, "W1Iron": 1.0})]
	board = GPart("Board")
	zf, zb = -58.935, -58.965
	corners = [(0, 0), (L_, 0), (L_, -H_), (0, -H_)]
	front = board.face("W5SignText", [P(u, v, zf) for u, v in corners], (0, 0, 1), [(u / L_, -v / H_) for u, v in corners])
	back = board.face("W5SignText", [P(u, v, zb) for u, v in corners], (0, 0, -1), [(1 - u / L_, -v / H_) for u, v in corners])
	for f in (front, back):
		for loop in f.loops:
			loop[board.uv].uv = (loop[board.uv].uv[0], 1.0 - loop[board.uv].uv[1])
	# Steel angle round the board's edge.
	for (ua, va), (ub, vb) in zip(corners, corners[1:] + corners[:1]):
		board.beam("W1Iron", P(ua, va, -58.95), P(ub, vb, -58.95), 0.04, 0.04, up=(0, 0, 1))
	objs.append(build(board, {"W1Iron": 1.0}))
	# Hangers: the two west ones hold, the east two hang broken from the arch.
	hang = GPart("Hangers")
	for u in (0.25, 2.1):
		top = P(u, 0.0, -58.95)
		hang.pipe("W1Steel", [(top[0], arch_y(top[0], 0) - 0.04, z), (top[0], top[1] + 0.02, -58.95)], 0.009, 5)
	for x, lean in ((221.5, 0.12), (227.0, -0.08)):
		hang.pipe("W1Steel", [(x, arch_y(x, 0) - 0.04, z), (x + lean, arch_y(x, 0) - 0.65, z + 0.04)], 0.009, 5)
	objs.append(build(hang, {"W1Steel": 1.0}))
	export(OUT / "sign_arch.glb", objs)


def build_sign_band():
	"""SB: the plastered band and its brackets: still bolted on Pillar209's cap, torn from Pillar231's."""
	w1kit.reset()
	P = sign_frame()
	L_, H_ = SIGN["length"], SIGN["height"]
	band = GPart("Band")
	zf, zb = -58.94, -59.06
	faces = []
	corners = [(0, 0), (L_, 0), (L_, -H_), (0, -H_)]
	faces.append(band.face("W5Band", [P(u, v, zf) for u, v in corners], (0, 0, 1)))
	faces.append(band.face("W5Band", [P(u, v, zb) for u, v in corners], (0, 0, -1)))
	for (ua, va), (ub, vb) in zip(corners, corners[1:] + corners[:1]):
		mu, mv = (ua + ub) / 2 - L_ / 2, (va + vb) / 2 + H_ / 2
		a = math.radians(SIGN["angle"])
		nx, ny = math.cos(a) * mu - math.sin(a) * mv, math.sin(a) * mu + math.cos(a) * mv
		faces.append(band.face("W5Band", [P(ua, va, zb), P(ub, vb, zb), P(ub, vb, zf), P(ua, va, zf)], (nx, ny, 0)))
	inv = SIGN_INVERSE()
	set_uv(band, faces, lambda p: (inv(p)[0], -inv(p)[1]))
	band.map_uv2(faces, lambda p: (inv(p)[0] / L_, -inv(p)[1] / H_))
	# A drip lip along the top.
	lip = list(band.xbox("W5Band", (0.0, -0.06, -59.08), (L_, 0.0, -58.92), lambda q: P(q[0], q[1], q[2])).values())
	set_uv(band, lip, lambda p: (inv(p)[0], -inv(p)[1]))
	band.map_uv2(lip, lambda p: (min(max(inv(p)[0] / L_, 0.0), 1.0), 0.02))
	objs = [build(band)]
	brk = GPart("Brackets")
	# Pillar209: an angle from its cap top to the band's corner. Pillar231: the empty bracket, bent up.
	cap209 = pillar_xf("Pillar209")((0.5, 2.97, 0.0))
	corner = P(0.15, -0.1, -59.0)
	brk.beam("W1Iron", (cap209[0], cap209[1] + 0.03, -59.0), corner, 0.06, 0.06, up=(0, 0, 1))
	brk.beam("W1Iron", (cap209[0] - 0.3, cap209[1] + 0.03, -59.0), (cap209[0] + 0.1, cap209[1] + 0.03, -59.0), 0.08, 0.02, up=(0, 1, 0))
	cap231 = (231.0, -3.93)
	brk.beam("W1Iron", (cap231[0] + 0.3, cap231[1] + 0.03, -59.0), (cap231[0] - 0.3, cap231[1] + 0.03, -59.0), 0.08, 0.02)
	brk.beam("W1Iron", (cap231[0] - 0.25, cap231[1] + 0.04, -59.0), (cap231[0] - 0.75, cap231[1] + 0.42, -58.98), 0.06, 0.06, up=(0, 0, 1))
	objs.append(build(brk, {"W1Iron": 1.0}))
	export(OUT / "sign_band.glb", objs)


def SIGN_INVERSE():
	a = math.radians(SIGN["angle"])
	d = (math.cos(a), math.sin(a))
	up = (-d[1], d[0])
	hx, hy = SIGN["hinge"]

	def inv(p):
		dx, dy = p[0] - hx, p[1] - hy
		return (dx * d[0] + dy * d[1], dx * up[0] + dy * up[1])
	return inv


def build_sign_letters():
	"""SB's raised letters (painted steel, 30 mm deep) on the band's court face, from sign_layout.json."""
	w1kit.reset()
	layout = json.loads((HERE / "sign_layout.json").read_text(encoding="utf-8"))
	k = SIGN_SCALE
	P = sign_frame()
	font = bpy.data.fonts.load(str(FONT))
	part = GPart("Letters")
	base_v = -layout["baseline_from_top"] * k
	depsgraph = bpy.context.evaluated_depsgraph_get()
	for ch, x, width in layout["letters"]:
		curve = bpy.data.curves.new("L_" + ch, "FONT")
		curve.body = ch
		curve.font = font
		curve.size = layout["em"] * k
		curve.extrude = 0.015
		curve.resolution_u = 3
		curve.align_x = "LEFT"
		curve.align_y = "TOP_BASELINE"
		obj = bpy.data.objects.new("L_" + ch, curve)
		bpy.context.scene.collection.objects.link(obj)
		depsgraph = bpy.context.evaluated_depsgraph_get()
		mesh = obj.evaluated_get(depsgraph).to_mesh()
		verts = []
		for v in mesh.vertices:
			# Blender text: x along, y up, z out of the face (+-extrude). Board: u, v; z towards the court (+z).
			u, vv, depth = x * k + v.co.x, base_v + v.co.y, v.co.z
			verts.append(P(u, vv, -58.925 + depth))
		faces = [list(p.vertices) for p in mesh.polygons]
		made = [part.bm.verts.new(B(p)) for p in verts]
		idx = part.slot("W5LetterRed")
		for f in faces:
			try:
				nf = part.bm.faces.new([made[i] for i in f])
			except ValueError:
				continue
			nf.material_index = idx
			nf.smooth = False
		obj.evaluated_get(depsgraph).to_mesh_clear()
		bpy.data.objects.remove(obj)
	# The font mesh keeps Blender's own winding (front +z, sides out); recalculating would flip open cap islands.
	export(OUT / "sign_letters.glb", [build(part, {"W5LetterRed": 1.0})])


# ------------------------------------------------------------------------------------------------ booth

BX = (237.55, 242.45)
BZ = (-55.95, -52.05)
WALL_T = 0.2
B_TOP = G + 2.9
WIN = L.BOOTH_WINDOW
DOOR = {"z": (-55.2, -54.2), "y": (G, G + 2.1)}


def booth_uv2(p):
	"""mask_gate's booth band: u round the booth from its north-west corner, v 3 m up."""
	x, y, z = p
	if abs(z - BZ[1]) < 0.25 and BX[0] - 0.1 <= x <= BX[1] + 0.1:
		s = x - BX[0]
	elif abs(x - BX[1]) < 0.25:
		s = 4.9 + (BZ[1] - z)
	elif abs(z - BZ[0]) < 0.25:
		s = 8.8 + (BX[1] - x)
	else:
		s = 13.7 + (z - BZ[0])
	return (min(max(s / 18.0, 0.0), 1.0), 1.0 - min(max((y - G) / 3.0, 0.0), 1.0) * 0.25)


def wall_with_holes(part, m, axis, at, t, span, holes, inner_m, inner_sign):
	"""One booth wall: a slab across `span` (along x for axis 'z', along z for axis 'x'), from G to B_TOP, `t` thick
	inwards from `at`, cut round `holes` [(a0, a1, y0, y1)]. The outer face uses m, the inner face inner_m."""
	cuts = sorted({span[0], span[1], *[h[0] for h in holes], *[h[1] for h in holes]})
	outer, inner = [], []
	for a0, a1 in zip(cuts, cuts[1:]):
		ys = [(G, B_TOP)]
		for h in holes:
			if h[0] <= a0 and a1 <= h[1]:
				ys = [(G, h[2]), (h[3], B_TOP)]
		for y0, y1 in ys:
			if y1 - y0 < 1e-4:
				continue
			o = at
			i = at + inner_sign * t
			if axis == "z":
				lo, hi = (a0, y0, min(o, i)), (a1, y1, max(o, i))
				sides = part.xbox(m, lo, hi)
				out_side, in_side = ("+z", "-z") if inner_sign < 0 else ("-z", "+z")
			else:
				lo, hi = (min(o, i), y0, a0), (max(o, i), y1, a1)
				sides = part.xbox(m, lo, hi)
				out_side, in_side = ("+x", "-x") if inner_sign < 0 else ("-x", "+x")
			outer.append(sides[out_side])
			inner.append(sides[in_side])
			sides[in_side].material_index = part.slot(inner_m)
			for key in ("-y", "+y"):
				if key in sides:
					sides[key].material_index = part.slot(inner_m)
			for key, f in sides.items():
				if key not in (out_side, in_side, "-y", "+y"):
					f.material_index = part.slot(inner_m)
	return outer, inner


def build_booth(kind):
	w1kit.reset()
	part = GPart("Booth")
	ext = "W5BoothYellow" if kind == "masonry" else "W5Panel"
	inner_m = "W5PlasterInner" if kind == "masonry" else "W5Panel"
	t = WALL_T if kind == "masonry" else 0.07
	win = (WIN["x"][0], WIN["x"][1], WIN["y"][0], WIN["y"][1])
	outer = []
	o, i = wall_with_holes(part, ext, "z", BZ[1], t, BX, [win], inner_m, -1)
	outer += o
	o, i = wall_with_holes(part, ext, "z", BZ[0], t, BX, [], inner_m, 1)
	outer += o
	o, i = wall_with_holes(part, ext, "x", BX[0], t, (BZ[0] + t, BZ[1] - t), [(DOOR["z"][0], DOOR["z"][1], DOOR["y"][0], DOOR["y"][1])], inner_m, 1)
	outer += o
	east_holes = [] if kind == "masonry" else [(-54.6, -53.4, G + 1.05, G + 2.0)]
	o, i = wall_with_holes(part, ext, "x", BX[1], t, (BZ[0] + t, BZ[1] - t), east_holes, inner_m, -1)
	outer += o
	if kind == "masonry":
		part.map_uv2(outer, booth_uv2)
		# Whitewashed skirting band and a white band under the roof.
		# Both bands run round the whole booth (the window lies between them); the skirting stops at the door.
		for y0, y1 in ((G, G + 0.3), (B_TOP - 0.18, B_TOP)):
			boxes = [((BX[0] - 0.012, y0, BZ[0] - 0.012), (BX[1] + 0.012, y1, BZ[0] + 0.01)),
				((BX[0] - 0.012, y0, BZ[1] - 0.01), (BX[1] + 0.012, y1, BZ[1] + 0.012)),
				((BX[1] - 0.01, y0, BZ[0]), (BX[1] + 0.012, y1, BZ[1]))]
			if y0 == G:
				boxes += [((BX[0] - 0.012, y0, BZ[0]), (BX[0] + 0.01, y1, DOOR["z"][0])),
					((BX[0] - 0.012, y0, DOOR["z"][1]), (BX[0] + 0.01, y1, BZ[1]))]
			else:
				boxes.append(((BX[0] - 0.012, y0, BZ[0]), (BX[0] + 0.01, y1, BZ[1])))
			for lo, hi in boxes:
				part.map_uv2(part.gbox("W5Plaster", lo, hi), booth_uv2)
		# Roof slab with its overhang (above 2.9 m) and the window sill.
		part.gbox("W1Concrete", (L.BOOTH_ROOF["x"][0], B_TOP, L.BOOTH_ROOF["z"][0]), (L.BOOTH_ROOF["x"][1], B_TOP + 0.15, L.BOOTH_ROOF["z"][1]))
		part.gbox("W1Concrete", (WIN["x"][0] - 0.1, WIN["y"][0] - 0.06, BZ[1] - 0.12), (WIN["x"][1] + 0.1, WIN["y"][0], BZ[1] + 0.03))
		door_m = "W5DoorPaint"
	else:
		# Blue steel frame: base channel, corner posts, eaves; corrugated roof over it.
		F = "W5FrameBlue"
		part.gbox(F, (BX[0] - 0.01, G, BZ[0] - 0.01), (BX[1] + 0.01, G + 0.12, BZ[1] + 0.01), skip=("-y",))
		for x in BX:
			for z in BZ:
				part.gbox(F, (x - 0.045, G, z - 0.045), (x + 0.045, B_TOP, z + 0.045))
		part.gbox(F, (BX[0] - 0.05, B_TOP - 0.12, BZ[0] - 0.05), (BX[1] + 0.05, B_TOP, BZ[1] + 0.05), skip=("-y",))
		faces = [part.face("W4RoofSheet", [(L.BOOTH_ROOF["x"][0], B_TOP + 0.1, L.BOOTH_ROOF["z"][0]), (L.BOOTH_ROOF["x"][1], B_TOP + 0.1, L.BOOTH_ROOF["z"][0]),
			(L.BOOTH_ROOF["x"][1], B_TOP + 0.16, L.BOOTH_ROOF["z"][1]), (L.BOOTH_ROOF["x"][0], B_TOP + 0.16, L.BOOTH_ROOF["z"][1])], (0, 1, 0))]
		faces.append(part.face("W4RoofSheet", [(L.BOOTH_ROOF["x"][0], B_TOP + 0.095, L.BOOTH_ROOF["z"][0]), (L.BOOTH_ROOF["x"][0], B_TOP + 0.155, L.BOOTH_ROOF["z"][1]),
			(L.BOOTH_ROOF["x"][1], B_TOP + 0.155, L.BOOTH_ROOF["z"][1]), (L.BOOTH_ROOF["x"][1], B_TOP + 0.095, L.BOOTH_ROOF["z"][0])], (0, -1, 0)))
		set_uv(part, faces, lambda p: ((p[0] - 237.0) / 2.0, (p[2] + 56.5) / 2.0))
		part.gbox(F, (L.BOOTH_ROOF["x"][0], B_TOP, L.BOOTH_ROOF["z"][0]), (L.BOOTH_ROOF["x"][1], B_TOP + 0.1, L.BOOTH_ROOF["z"][0] + 0.06))
		part.gbox(F, (L.BOOTH_ROOF["x"][0], B_TOP + 0.06, L.BOOTH_ROOF["z"][1] - 0.06), (L.BOOTH_ROOF["x"][1], B_TOP + 0.16, L.BOOTH_ROOF["z"][1]))
		# East window frame and glass.
		part.gbox("W1Alu", (BX[1] - 0.06, G + 1.0, -54.65), (BX[1] - 0.01, G + 1.05, -53.35))
		part.gbox("W1Alu", (BX[1] - 0.06, G + 2.0, -54.65), (BX[1] - 0.01, G + 2.05, -53.35))
		part.face("W2Glass", [(BX[1] - 0.035, G + 1.05, -54.6), (BX[1] - 0.035, G + 1.05, -53.4), (BX[1] - 0.035, G + 2.0, -53.4), (BX[1] - 0.035, G + 2.0, -54.6)], (1, 0, 0))
		door_m = "W5Panel"
	# North window: aluminium frame, three sliding panes, a sill; the masonry booth has a grille outside the glass.
	wz = BZ[1] - 0.07
	x0, x1, y0, y1 = win
	for lo, hi in (((x0, y0, wz - 0.03), (x1, y0 + 0.05, wz + 0.03)), ((x0, y1 - 0.05, wz - 0.03), (x1, y1, wz + 0.03)),
			((x0, y0, wz - 0.03), (x0 + 0.05, y1, wz + 0.03)), ((x1 - 0.05, y0, wz - 0.03), (x1, y1, wz + 0.03))):
		part.gbox("W1Alu", lo, hi)
	for k in range(1, 3):
		xm = x0 + (x1 - x0) * k / 3
		part.gbox("W1Alu", (xm - 0.02, y0, wz - 0.02), (xm + 0.02, y1, wz + 0.02))
	for k in range(3):
		xa, xb = x0 + (x1 - x0) * k / 3 + 0.02, x0 + (x1 - x0) * (k + 1) / 3 - 0.02
		dz = 0.012 if k % 2 else -0.012
		part.face("W2Glass", [(xa, y0 + 0.05, wz + dz), (xb, y0 + 0.05, wz + dz), (xb, y1 - 0.05, wz + dz), (xa, y1 - 0.05, wz + dz)], (0, 0, 1))
	if kind == "masonry":
		gz = BZ[1] + 0.025
		x = x0 + 0.06
		while x < x1 - 0.04:
			part.beam("W1Iron", (x, y0 - 0.02, gz), (x, y1 + 0.02, gz), 0.014, 0.014, caps=False)
			x += 0.12
		for y in (y0 + 0.02, y1 - 0.02):
			part.beam("W1Iron", (x0, y, gz), (x1, y, gz), 0.03, 0.006, caps=False)
	# Door (closed) in the west wall: a leaf, its frame, a handle 40 mm out.
	dx = BX[0] + 0.04
	part.gbox(door_m, (dx - 0.02, G + 0.01, DOOR["z"][0] + 0.03), (dx + 0.02, DOOR["y"][1] - 0.03, DOOR["z"][1] - 0.03))
	for lo, hi in (((BX[0] - 0.01, G, DOOR["z"][0]), (BX[0] + 0.06, DOOR["y"][1], DOOR["z"][0] + 0.04)),
			((BX[0] - 0.01, G, DOOR["z"][1] - 0.04), (BX[0] + 0.06, DOOR["y"][1], DOOR["z"][1])),
			((BX[0] - 0.01, DOOR["y"][1] - 0.04, DOOR["z"][0]), (BX[0] + 0.06, DOOR["y"][1], DOOR["z"][1]))):
		part.gbox("W1Alu" if kind == "prefab" else "W1Iron", lo, hi)
	part.beam("W1Steel", (BX[0] - 0.04, G + 1.0, DOOR["z"][1] - 0.14), (BX[0] - 0.04, G + 1.0, DOOR["z"][1] - 0.28), 0.02, 0.02)
	part.beam("W1Steel", (BX[0] - 0.04, G + 1.0, DOOR["z"][1] - 0.14), (BX[0] + 0.02, G + 1.0, DOOR["z"][1] - 0.14), 0.02, 0.02)
	# Floor and ceiling inside.
	part.face("W1Terrazzo", [(BX[0] + t, G + 0.02, BZ[0] + t), (BX[1] - t, G + 0.02, BZ[0] + t), (BX[1] - t, G + 0.02, BZ[1] - t),
		(BX[0] + t, G + 0.02, BZ[1] - t)], (0, 1, 0))
	part.face(inner_m, [(BX[0] + t, B_TOP - 0.01, BZ[0] + t), (BX[1] - t, B_TOP - 0.01, BZ[0] + t), (BX[1] - t, B_TOP - 0.01, BZ[1] - t),
		(BX[0] + t, B_TOP - 0.01, BZ[1] - t)], (0, -1, 0))
	ensure_uv2(part)
	uv = {"W5Panel": 1.0, "W1Concrete": 1.0, "W1Iron": 1.0, "W1Alu": 1.0, "W1Steel": 1.0, "W5FrameBlue": 1.0, "W5DoorPaint": 1.0}
	export(OUT / f"booth_{kind}.glb", [build(part, uv)])


def build_booth_interior():
	"""What the window shows: a desk under it, a plastic chair, the log book open, a phone, a flask and a cup, a desk
	fan, a CCTV monitor, a guard's cap; a calendar and a key box on the walls. Inside the Booth collider."""
	w1kit.reset()
	part = GPart("Interior")
	zt0, zt1 = BZ[1] - WALL_T - 0.62, BZ[1] - WALL_T - 0.02
	top = G + 0.76
	part.gbox("W1Wood", (238.0, top - 0.035, zt0), (242.0, top, zt1))
	for x in (238.05, 241.95):
		for z in (zt0 + 0.05, zt1 - 0.05):
			part.gbox("W1Wood", (x - 0.03, G + 0.02, z - 0.03), (x + 0.03, top - 0.035, z + 0.03))
	part.gbox("W1Wood", (238.0, G + 0.25, zt0 + 0.03), (242.0, top - 0.035, zt0 + 0.05))
	# Plastic chair (blue), pulled out a little.
	cx, cz = 240.2, -53.55
	part.gbox("W1Plastic", (cx - 0.21, G + 0.43, cz - 0.21), (cx + 0.21, G + 0.46, cz + 0.21))
	part.gbox("W1Plastic", (cx - 0.21, G + 0.46, cz - 0.23), (cx + 0.21, G + 0.86, cz - 0.2))
	for sx in (-1, 1):
		for sz in (-1, 1):
			part.pipe("W1Plastic", [(cx + sx * 0.17, G + 0.02, cz + sz * 0.17), (cx + sx * 0.19, G + 0.43, cz + sz * 0.19)], 0.018, 6)
	# Log book open, phone, flask, cup, cap, CCTV monitor, fan.
	part.gbox("W1LedgerSpine", (239.4, top, -52.75), (239.86, top + 0.012, -52.42))
	part.gbox("W1Pages", (239.41, top + 0.012, -52.74), (239.62, top + 0.026, -52.43))
	part.gbox("W1Pages", (239.64, top + 0.012, -52.74), (239.85, top + 0.026, -52.43))
	part.gbox("W1PhoneIvory", (240.35, top, -52.7), (240.57, top + 0.07, -52.48))
	part.gbox("W1PhoneIvory", (240.33, top + 0.07, -52.62), (240.59, top + 0.11, -52.56))
	part.cylinder("W1EnamelBlue", B((241.2, top + 0.17, -52.6)), 0.05, 0.34, segments=12)
	part.cylinder("W1Plastic", B((241.0, top + 0.05, -52.75)), 0.04, 0.1, segments=10)
	part.cylinder("W1Black", B((238.6, top + 0.04, -52.62)), 0.13, 0.08, segments=12, radius2=0.1)
	part.gbox("W1Black", (238.4, top + 0.075, -52.75), (238.8, top + 0.09, -52.62))
	part.gbox("W1Black", (241.45, top, -52.6), (241.9, top + 0.38, -52.28))
	part.gbox("W1Black", (241.5, top + 0.04, -52.62), (241.85, top + 0.34, -52.6))
	part.cylinder("W1Plastic", B((238.25, top + 0.02, -52.5)), 0.1, 0.04, segments=12)
	part.pipe("W1Steel", [(238.25, top + 0.04, -52.5), (238.25, top + 0.35, -52.5)], 0.012, 6)
	part.cylinder("W1Plastic", B((238.25, top + 0.42, -52.47)), 0.15, 0.1, axis="Y", segments=14)
	# On the walls: calendar (south wall), key box (east wall).
	cz0 = BZ[0] + WALL_T + 0.005
	part.face("W1Notices", [(239.6, G + 1.3, cz0), (240.0, G + 1.3, cz0), (240.0, G + 1.85, cz0), (239.6, G + 1.85, cz0)], (0, 0, 1),
		[(0.0, 1.0), (0.33, 1.0), (0.33, 0.0), (0.0, 0.0)])
	part.gbox("W1Alu", (BX[1] - WALL_T - 0.08, G + 1.4, -54.6), (BX[1] - WALL_T, G + 1.85, -54.2))
	ensure_uv2(part)
	export(OUT / "booth_interior.glb", [build(part, {"W1Wood": 1.0, "W1Plastic": 1.0, "W1Black": 1.0, "W1PhoneIvory": 1.0, "W1Alu": 1.0,
		"W1LedgerSpine": 1.0, "W1Pages": 1.0, "W1EnamelBlue": 1.0, "W1Steel": 1.0})])


# ------------------------------------------------------------------------------------------------ south wall

WALL_RUNS = [(186.0, 208.25), (231.75, 262.0)]
ZW = (-60.15, -59.85)


def wall_uv2(xm):
	def fn(p):
		k = int(round((xm - 186.0) / 3.0)) % 4
		return (k * 0.25 + min(max((p[0] - xm) / 3.0, 0.0), 1.0) * 0.249, 0.25 - min(max((p[1] - G) / 3.0, 0.0), 1.0) * 0.25)
	return fn


def build_wall(kind):
	w1kit.reset()
	part = GPart("Wall")
	bars = GPart("Bars")
	for x0, x1 in WALL_RUNS:
		posts = [x0]
		x = x0
		while x + 3.0 < x1 - 0.5:
			x += 3.0
			posts.append(x)
		posts.append(x1)
		for p in posts:
			a, b = max(p - 0.15, x0), min(p + 0.15, x1)
			if kind == "plaster":
				f = part.gbox("W5Plaster", (a, G, ZW[0]), (b, G + 2.92, ZW[1]))
				part.map_uv2(f, wall_uv2(p - 1.5))
				f = part.gbox("W5Plaster", (a - 0.02 if a > x0 else a, G + 2.92, ZW[0]), (b + 0.02 if b < x1 else b, G + 3.0, ZW[1]))
				part.map_uv2(f, wall_uv2(p - 1.5))
			else:
				part.gbox("W5Brick", (a, G, ZW[0]), (b, G + 2.9, ZW[1]))
				part.gbox("W1Concrete", (a, G + 2.9, ZW[0]), (b, G + 3.0, ZW[1]))
		for pa, pb in zip(posts, posts[1:]):
			a, b = pa + 0.15, pb - 0.15
			if b - a < 0.05:
				continue
			if kind == "plaster":
				f = part.gbox("W5Plaster", (a, G, -60.1), (b, G + 1.8, -59.9), skip=("-x", "+x"))
				part.map_uv2(f, wall_uv2(pa))
				f = part.gbox("W5Plaster", (a, G + 1.8, -60.13), (b, G + 1.86, -59.87), skip=("-x", "+x"))
				part.map_uv2(f, wall_uv2(pa))
				n = max(1, int((b - a) / 0.12))
				for i in range(1, n):
					x = a + (b - a) * i / n
					bars.beam("W5GateGreen", (x, G + 1.86, -60.0), (x, G + 2.93, -60.0), 0.02, 0.02, caps=False)
				bars.beam("W5GateGreen", (a, G + 2.93, -60.0), (b, G + 2.93, -60.0), 0.04, 0.04, caps=False)
				bars.beam("W5GateGreen", (a, G + 2.3, -60.0), (b, G + 2.3, -60.0), 0.03, 0.01, caps=False)
			else:
				part.gbox("W5Brick", (a, G, -60.11), (b, G + 2.7, -59.89), skip=("-x", "+x"))
				part.gbox("W1Concrete", (a, G + 2.7, -60.14), (b, G + 2.78, -59.86), skip=("-x", "+x"))
	ensure_uv2(part)
	objs = [build(part, {"W5Brick": 1.0, "W1Concrete": 1.0})]
	if bars.slots:
		objs.append(build(bars, {"W5GateGreen": 1.0}))
	# Brick UV: the box projection in metres; W5Brick's uv1_scale maps 0.92 x 0.84 m to the tile.
	export(OUT / f"wall_{kind}.glb", objs)


# ------------------------------------------------------------------------------------------------ barrier, cone

def build_barrier():
	"""Origin on the ground at the barricade's centre, board along x: 2.0 m, feet 0.5 m deep, 0.95 m tall."""
	w1kit.reset()
	G0 = G
	frame = GPart("Frame")
	M = "W4PoleSteel"
	for sx in (-1, 1):
		x = sx * 0.95
		frame.pipe(M, [(x, G0 + 0.03, -0.21), (x, G0 + 0.93, 0.0), (x, G0 + 0.03, 0.21)], 0.02, 8)
		frame.pipe(M, [(x, G0 + 0.18, -0.17), (x, G0 + 0.18, 0.17)], 0.012, 6)
		for z in (-0.21, 0.21):
			frame.gbox("W1Rubber", (x - 0.04, G0, z - 0.03), (x + 0.04, G0 + 0.03, z + 0.03))
	frame.pipe(M, [(-0.95, G0 + 0.93, 0.0), (0.95, G0 + 0.93, 0.0)], 0.02, 8, cap=False)
	board = GPart("Board")
	y0, y1 = G0 + 0.55, G0 + 0.85
	board.face("W5BarrierStripes", [(-0.93, y0, 0.012), (0.93, y0, 0.012), (0.93, y1, 0.012), (-0.93, y1, 0.012)], (0, 0, 1),
		[(0.035, 0.4), (0.965, 0.4), (0.965, 1.0), (0.035, 1.0)])
	board.face("W5BarrierStripes", [(-0.93, y0, -0.012), (0.93, y0, -0.012), (0.93, y1, -0.012), (-0.93, y1, -0.012)], (0, 0, -1),
		[(0.965, 0.4), (0.035, 0.4), (0.035, 1.0), (0.965, 1.0)])
	board.gbox(M, (-0.95, y0 - 0.02, -0.012), (0.95, y0, 0.012))
	board.gbox(M, (-0.95, y1, -0.012), (0.95, y1 + 0.02, 0.012))
	for x in (-0.95, 0.95):
		board.gbox(M, (x - 0.02, y0, -0.012), (x + 0.02, y1, 0.012))
	export(OUT / "barrier.glb", [build(frame, {M: 1.0, "W1Rubber": 1.0}), build(board, {M: 1.0})])


def build_cone():
	"""Origin on the ground at the cone's centre: a 0.4 m square rubber base and a 0.7 m orange body with two bands."""
	w1kit.reset()
	part = GPart("Cone")
	part.gbox("W1Rubber", (-0.2, G, -0.2), (0.2, G + 0.035, 0.2))
	h0, h1, r0, r1 = 0.035, 0.7, 0.16, 0.025

	def r(y):
		return r0 + (r1 - r0) * (y - h0) / (h1 - h0)
	cuts = [h0, 0.3, 0.38, 0.5, 0.56, h1]
	mats = ["W5ConeOrange", "W5Reflect", "W5ConeOrange", "W5Reflect", "W5ConeOrange"]
	segs = 16
	for (ya, yb), m in zip(zip(cuts, cuts[1:]), mats):
		for s in range(segs):
			a0, a1 = s / segs * math.tau, (s + 1) / segs * math.tau
			part.face(m, [(math.cos(a0) * r(ya), G + ya, math.sin(a0) * r(ya)), (math.cos(a1) * r(ya), G + ya, math.sin(a1) * r(ya)),
				(math.cos(a1) * r(yb), G + yb, math.sin(a1) * r(yb)), (math.cos(a0) * r(yb), G + yb, math.sin(a0) * r(yb))],
				(math.cos((a0 + a1) / 2), 0.2, math.sin((a0 + a1) / 2)))
	part.face("W5ConeOrange", [(math.cos(-s / segs * math.tau) * r1, G + h1, math.sin(-s / segs * math.tau) * r1) for s in range(segs)], (0, 1, 0))
	export(OUT / "cone.glb", [build(part, {"W5ConeOrange": 1.0, "W5Reflect": 1.0, "W1Rubber": 1.0})])


BUILDS = {"court": build_court, "outside": build_outside, "cracks": build_cracks,
	"pillars_plaster": lambda: build_pillars("plaster"), "pillars_brick": lambda: build_pillars("brick"),
	"gate_swing": build_gate_swing, "gate_folding": build_gate_folding,
	"sign_arch": build_sign_arch, "sign_band": build_sign_band, "sign_letters": build_sign_letters,
	"booth_masonry": lambda: build_booth("masonry"), "booth_prefab": lambda: build_booth("prefab"), "booth_interior": build_booth_interior,
	"wall_plaster": lambda: build_wall("plaster"), "wall_brick": lambda: build_wall("brick"),
	"barrier": build_barrier, "cone": build_cone}


if __name__ == "__main__":
	random.seed(262)
	args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for key in (args or list(BUILDS)):
		BUILDS[key]()
