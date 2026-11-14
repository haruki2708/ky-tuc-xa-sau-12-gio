"""T-261 round 1: the stadium pilot (card section 2) with the options the owner picks from. Blender 5.2.2, bmesh only,
no add-on, no Tripo. Every piece stands where the PS1 piece stood (stadium_layout.py); no collider is changed, and
no visual solid is put where the player can walk but the old collision did not stop them.

  field.glb          the stadium floor: Apron (TrackBounds' ground round the track), Track (the 7-lane ring, lane lines
                     drawn by the track shader), Kerb (inner edge), Infield (grass inside the track, pitch markings
                     drawn by the pitch shader), Marks (finish line, the PS1 staggered start marks). Stadium space.
                     Options swap materials at run time: R1 W4TrackRubber / R2 W4TrackCinder, C1 W4PitchGrass / C2 W4Turf.
  goal.glb           one goal: round steel frame, rear supports, net (origin at the goal line's centre, mouth facing +x)
  stand.glb          the whole main stand (x 158..238): Steps (treads, risers, aisle half-steps, front wall, ends,
                     rear parapet), Structure (soffit, raker beams, columns), Roof (trusses, purlins, fascia), RoofSheet
                     (corrugated sheet, three sheets missing), Ground (under and behind the stand), Pipes (B03's)
  stand_seats.glb    option S2: moulded plastic seats on every tread outside the aisles (W4Seat; W4SeatRed at run time)
  pole_steel.glb     option L1: tapered galvanised steel pole, step bolts, 6-lamp head frame (origin at the pole's foot,
                     lamps face +x); pole_concrete.glb  option L2: spun concrete pole, the same head frame
  fence_b40.glb      option H1: B40 chain-link on galvanised pipe posts, gate leaves folded back (pilot fences, stadium
                     space); fence_bars.glb  option H2: iron bar railing painted green, the same layout
  gate_pillars.glb   the West and NorthWest gates' plastered pillars round the PS1 GatePost colliders
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave4/build_stadium_pilot.py [-- name ...]
"""
import math
from pathlib import Path
import random
import sys

import bpy
from mathutils import Matrix, Vector

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE.parent / "wave1"))
sys.path.insert(0, str(HERE))
import w1kit  # noqa: E402
import stadium_layout as L  # noqa: E402

ROOT = HERE.parents[3]
OUT = ROOT / "game/assets/models/graphics_pilot/realistic_map/wave4"
G = L.G

PREVIEW = {"W4Apron": ((0.3, 0.28, 0.2), 0.95), "W4TrackRubber": ((0.45, 0.18, 0.13), 0.9), "W4Paint": ((0.85, 0.85, 0.82), 0.6),
	"W4PitchGrass": ((0.2, 0.3, 0.12), 0.95), "W4Net": ((0.8, 0.8, 0.78), 0.8), "W4StandConcrete": ((0.5, 0.49, 0.46), 0.9),
	"W4SteelFrame": ((0.35, 0.38, 0.4), 0.6), "W4RoofSheet": ((0.5, 0.5, 0.5), 0.5), "W4Seat": ((0.15, 0.3, 0.55), 0.5),
	"W4PoleSteel": ((0.55, 0.56, 0.55), 0.45), "W4FloodBody": ((0.2, 0.21, 0.22), 0.5), "W4FloodGlass": ((0.9, 0.9, 0.85), 0.2),
	"W4Chainlink": ((0.5, 0.5, 0.48), 0.5), "W4Pillar": ((0.8, 0.78, 0.7), 0.85), "W3LampPaint": ((0.1, 0.18, 0.12), 0.5),
	"W1Concrete": ((0.52, 0.51, 0.47), 0.9), "W1Iron": ((0.3, 0.28, 0.26), 0.6)}


def mat(name):
	color, rough = PREVIEW.get(name, ((0.5, 0.5, 0.5), 0.8))
	return w1kit.material(name, color, rough)


def B(p):
	"""Godot world point (stadium space, origin at Godot (0, G, 0)) to Blender."""
	return Vector((p[0], -p[2], p[1] - G))


class GPart(w1kit.Part):
	"""w1kit.Part with helpers in Godot coordinates (x, y up, z)."""

	def __init__(self, name):
		super().__init__(name)
		self.made = []

	def face(self, m, pts, normal=None, uv=None):
		"""One polygon from Godot points; reversed if its winding disagrees with `normal` (Godot)."""
		vs = [B(p) for p in pts]
		if normal is not None:
			n = (vs[1] - vs[0]).cross(vs[2] - vs[0])
			if n.length < 1e-12:
				n = (vs[2] - vs[0]).cross(vs[3] - vs[0]) if len(vs) > 3 else n
			if n.dot(B((normal[0], normal[1] + G, normal[2]))) < 0:
				vs.reverse()
				if uv is not None:
					uv = list(reversed(uv))
		made = [self.bm.verts.new(v) for v in vs]
		f = self.bm.faces.new(made)
		f.material_index = self.slot(m)
		if uv is not None:
			for loop, t in zip(f.loops, uv):
				loop[self.uv].uv = t
			f.tag = True
		return f

	def gbox(self, m, lo, hi, bevel=0.0):
		return self.box(m, B(lo), B(hi), bevel=bevel, segments=1)

	def beam(self, m, p0, p1, w, h, up=(0, 1, 0), caps=True):
		"""An oriented box from p0 to p1 (Godot), w wide, h tall about the `up` hint."""
		a, b = B(p0), B(p1)
		d = (b - a).normalized()
		u = B((up[0], up[1] + G, up[2]))
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
		print("T261_PART %s %s %d tris %s" % (Path(path).name, o.name, w1kit.triangles([o]), [m.name for m in o.data.materials]))


def build(part, uv_size=None):
	for name in part.slots:
		mat(name)
	return part.build(uv_size=uv_size or {})


# ------------------------------------------------------------------------------------------------ field

def stations(r, per_curve=72):
	"""Points round the track's stadium shape at radius r: (x, z, outward normal (nx, nz), arc metres at r)."""
	cw, ce = L.TRACK_CX
	cz = L.TRACK_CZ
	out = []
	s = 0.0
	# North straight west -> east, east curve, south straight east -> west, west curve.
	for i in range(4):
		x = cw + L.STRAIGHT * i / 4
		out.append((x, cz + r, (0.0, 1.0)))
	for k in range(per_curve):
		a = math.pi / 2 - math.pi * k / per_curve
		out.append((ce + r * math.cos(a), cz + r * math.sin(a), (math.cos(a), math.sin(a))))
	for i in range(4):
		x = ce - L.STRAIGHT * i / 4
		out.append((x, cz - r, (0.0, -1.0)))
	for k in range(per_curve):
		a = -math.pi / 2 - math.pi * k / per_curve
		out.append((cw + r * math.cos(a), cz + r * math.sin(a), (math.cos(a), math.sin(a))))
	return out


def field_uv2(p):
	fx, fz = L.FIELD_MASK["x"], L.FIELD_MASK["z"]
	return ((p[0] - fx[0]) / (fx[1] - fx[0]), (p[2] - fz[0]) / (fz[1] - fz[0]))


def ray_to_bounds(x, z, nx, nz):
	bx, bz = L.BOUNDS["x"], L.BOUNDS["z"]
	ts = []
	if nx > 1e-9:
		ts.append(((bx[1] - x) / nx, "x1"))
	if nx < -1e-9:
		ts.append(((bx[0] - x) / nx, "x0"))
	if nz > 1e-9:
		ts.append(((bz[1] - z) / nz, "z1"))
	if nz < -1e-9:
		ts.append(((bz[0] - z) / nz, "z0"))
	t, side = min(ts)
	return (x + nx * t, z + nz * t), side


CORNERS = {("x0", "z1"): (110.0, 212.0), ("z1", "x0"): (110.0, 212.0), ("x1", "z1"): (286.0, 212.0),
	("z1", "x1"): (286.0, 212.0), ("x1", "z0"): (286.0, 120.0), ("z0", "x1"): (286.0, 120.0),
	("x0", "z0"): (110.0, 120.0), ("z0", "x0"): (110.0, 120.0)}


def build_field():
	w1kit.reset()
	y_apron, y_in, y_track = G + 0.004, L.PITCH_Y, L.TRACK_Y
	inner = stations(L.TRACK_R_IN)
	outer = stations(L.TRACK_R_OUT)
	n = len(inner)
	# Track ring: UV x = metres across from the inner edge, y = metres along (scaled to whole 2 m tiles).
	track = GPart("Track")
	lengths = [0.0]
	r_mid = (L.TRACK_R_IN + L.TRACK_R_OUT) / 2
	mid = stations(r_mid)
	for i in range(1, n + 1):
		a, b = mid[i - 1], mid[i % n]
		lengths.append(lengths[-1] + math.hypot(b[0] - a[0], b[1] - a[1]))
	scale = round(lengths[-1] / 2.0) * 2.0 / lengths[-1]
	width = L.TRACK_R_OUT - L.TRACK_R_IN
	faces = []
	for i in range(n):
		j = (i + 1) % n
		s0, s1 = lengths[i] * scale, lengths[i + 1] * scale
		pts = [(inner[i][0], y_track, inner[i][1]), (outer[i][0], y_track, outer[i][1]),
			(outer[j][0], y_track, outer[j][1]), (inner[j][0], y_track, inner[j][1])]
		uv = [(0.0, 1 - s0), (width, 1 - s0), (width, 1 - s1), (0.0, 1 - s1)]
		faces.append(track.face("W4TrackRubber", pts, (0, 1, 0), uv))
	track.map_uv2(faces, field_uv2)
	objs = [build(track)]
	print("T261_TRACK length %.2f m (UV scaled x %.5f), %d stations" % (lengths[-1], scale, n))
	# Kerb: a 50 mm painted kerb on the inner edge, 50 mm proud of the track.
	kerb = GPart("Kerb")
	r0, r1 = L.TRACK_R_IN - 0.05, L.TRACK_R_IN
	k0, k1 = stations(r0), inner
	yt = y_track + 0.05
	for i in range(n):
		j = (i + 1) % n
		kerb.face("W4Paint", [(k0[i][0], yt, k0[i][1]), (k1[i][0], yt, k1[i][1]), (k1[j][0], yt, k1[j][1]), (k0[j][0], yt, k0[j][1])], (0, 1, 0))
		kerb.face("W4Paint", [(k1[i][0], y_track, k1[i][1]), (k1[j][0], y_track, k1[j][1]), (k1[j][0], yt, k1[j][1]), (k1[i][0], yt, k1[i][1])],
			(k1[i][2][0], 0, k1[i][2][1]))
		kerb.face("W4Paint", [(k0[i][0], y_in, k0[i][1]), (k0[j][0], y_in, k0[j][1]), (k0[j][0], yt, k0[j][1]), (k0[i][0], yt, k0[i][1])],
			(-k0[i][2][0], 0, -k0[i][2][1]))
	objs.append(build(kerb, {"W4Paint": 1.0}))
	# Infield: one polygon inside the kerb; UV = world (x, z) in metres (the pitch shader draws the markings from it).
	infield = GPart("Infield")
	ring = stations(L.TRACK_R_IN - 0.05)
	f = infield.face("W4PitchGrass", [(p[0], y_in, p[1]) for p in ring], (0, 1, 0))
	set_uv(infield, [f], lambda p: (p[0], p[2]))
	infield.map_uv2([f], field_uv2)
	objs.append(build(infield))
	# Apron: from the track's outer edge out to TrackBounds, along each station's normal (corners filled).
	apron = GPart("Apron")
	faces = []
	for i in range(n):
		j = (i + 1) % n
		hi, si = ray_to_bounds(outer[i][0], outer[i][1], *outer[i][2])
		hj, sj = ray_to_bounds(outer[j][0], outer[j][1], *outer[j][2])
		pts = [(outer[i][0], y_apron, outer[i][1]), (hi[0], y_apron, hi[1])]
		if si != sj:
			c = CORNERS[(si, sj)]
			pts.append((c[0], y_apron, c[1]))
		pts += [(hj[0], y_apron, hj[1]), (outer[j][0], y_apron, outer[j][1])]
		faces.append(apron.face("W4Apron", pts, (0, 1, 0)))
	set_uv(apron, faces, lambda p: (p[0], p[2]))
	apron.map_uv2(faces, field_uv2)
	objs.append(build(apron))
	# Marks: the finish line at the end of the home (north) straight and the PS1 staggered start marks.
	marks = GPart("Marks")
	ym = y_track + 0.004
	x = L.TRACK_CX[1]
	marks.face("W4Paint", [(x - 0.025, ym, L.TRACK_CZ + L.TRACK_R_IN), (x - 0.025, ym, L.TRACK_CZ + L.TRACK_R_OUT - 0.08),
		(x + 0.025, ym, L.TRACK_CZ + L.TRACK_R_OUT - 0.08), (x + 0.025, ym, L.TRACK_CZ + L.TRACK_R_IN)], (0, 1, 0))
	# Staggered start marks on the south straight at the PS1 StartLane0..6 x (175 + 0.8 k), one across each lane's
	# middle (the PS1 marks stepped 1.22 m from z 126, so the last two lay off the track).
	for k in range(L.LANES):
		cx = 175.0 + 0.8 * k
		cz = L.TRACK_CZ - (L.TRACK_R_IN + L.LANE_W * (k + 0.5))
		marks.face("W4Paint", [(cx - 0.025, ym, cz - 0.55), (cx - 0.025, ym, cz + 0.55), (cx + 0.025, ym, cz + 0.55),
			(cx + 0.025, ym, cz - 0.55)], (0, 1, 0))
	objs.append(build(marks, {"W4Paint": 1.0}))
	export(OUT / "field.glb", objs)


# ------------------------------------------------------------------------------------------------ goal

def build_goal():
	"""Local frame: origin at the goal line's centre on the ground, the mouth facing +x (Godot), posts at z +-3.66."""
	w1kit.reset()
	frame = GPart("Frame")
	r = 0.06
	hw, h, depth, back_h = L.GOAL_W / 2 + r, L.GOAL_H + r, 2.0, 1.5
	G0 = G  # build at Godot y = G so B() puts the origin on the ground
	for z in (-hw, hw):
		frame.pipe("W4Paint", [(0, G0, z), (0, G0 + h, z)], r, 12)
	frame.pipe("W4Paint", [(0, G0 + h, -hw - r), (0, G0 + h, hw + r)], r, 12)
	# Rear supports: ground frame and two bent stanchions from the crossbar's ends.
	rr = 0.025
	frame.pipe("W3LampPaint", [(0, G0 + 0.03, -hw), (-depth, G0 + 0.03, -hw), (-depth, G0 + 0.03, hw), (0, G0 + 0.03, hw)], rr, 6)
	for z in (-hw, hw):
		frame.pipe("W3LampPaint", [(-0.05, G0 + h - 0.05, z), (-depth * 0.6, G0 + back_h + 0.15, z), (-depth, G0 + back_h, z),
			(-depth, G0 + 0.03, z)], rr, 6)
	frame.pipe("W3LampPaint", [(-depth, G0 + back_h, -hw), (-depth, G0 + back_h, hw)], rr, 6)
	objs = [build(frame, {"W4Paint": 1.0, "W3LampPaint": 1.0})]
	net = GPart("Net")
	sag = 0.12
	top = [(0, G0 + h - 0.02, -hw), (0, G0 + h - 0.02, hw), (-depth, G0 + back_h, hw), (-depth, G0 + back_h, -hw)]
	nets = [
		top,
		[(-depth, G0 + back_h, -hw), (-depth, G0 + back_h, hw), (-depth - sag, G0, hw), (-depth - sag, G0, -hw)],
	]
	faces = [net.face("W4Net", q, (0, 1, 0) if q is top else (-1, 0, 0)) for q in nets]
	for z, nz in ((-hw, -1), (hw, 1)):
		faces.append(net.face("W4Net", [(0, G0 + h - 0.02, z), (-depth, G0 + back_h, z), (-depth - sag, G0, z), (0, G0, z)], (0, 0, nz)))
	# Net UV in metres / 0.96 (one tile per 8 squares), projected per panel.
	for f in faces:
		nrm = f.normal
		for loop in f.loops:
			co = loop.vert.co
			if abs(nrm.z) > 0.6:  # roof panel: along x and y (Blender)
				u, v = co.y, co.x
			elif abs(nrm.x) > abs(nrm.y):
				u, v = co.y, co.z
			else:
				u, v = co.x, co.z
			loop[net.uv].uv = (u / 0.96, v / 0.96)
		f.tag = True
	objs.append(build(net))
	export(OUT / "goal.glb", objs)


# ------------------------------------------------------------------------------------------------ stand

PROFILE = 1.1 + L.TIERS * (L.RISER + L.TREAD)


def bay_of(x):
	return max(0, min(7, int((x - L.STAND_X[0]) // 10.0)))


def stand_u(x, bay):
	return (bay % 2) * 0.4 + (x - (L.STAND_X[0] + 10.0 * bay)) / 10.0 * 0.4


def x_cuts(x0, x1):
	"""Cut [x0, x1] at every bay boundary."""
	cuts = [x0] + [L.STAND_X[0] + 10.0 * i for i in range(1, 8) if x0 < L.STAND_X[0] + 10.0 * i < x1] + [x1]
	return list(zip(cuts, cuts[1:]))


def in_aisle(x0, x1):
	return any(a <= x0 and x1 <= b for a, b in L.AISLES)


def seat_spans():
	"""x spans of seating (between the stand's ends and the aisles)."""
	edges = [L.STAND_X[0]] + [v for a in L.AISLES for v in a] + [L.STAND_X[1]]
	return [(edges[i], edges[i + 1]) for i in range(0, len(edges), 2)]


def build_stand():
	w1kit.reset()
	objs = []
	steps = GPart("Steps")
	M = "W4StandConcrete"
	spans = []
	for a, b in seat_spans():
		spans.append((a, b, False))
	for a, b in L.AISLES:
		spans.append((a, b, True))
	for k in range(L.TIERS):
		y1 = L.tread_top(k)
		y0 = y1 - L.RISER if k > 0 else G
		z0, z1 = L.tread_front(k), L.tread_front(k + 1)
		if k == 0:
			z0 = L.FRONT_WALL["z"][1]
		for sx0, sx1, aisle in spans:
			for x0, x1 in x_cuts(sx0, sx1):
				bay = bay_of((x0 + x1) / 2)
				if not aisle:
					# Riser, a 30 mm chamfered nosing, tread.
					c = NOSING
					f = steps.face(M, [(x0, y0, z0), (x1, y0, z0), (x1, y1 - c, z0), (x0, y1 - c, z0)], (0, 0, -1))
					steps.map_uv2([f], lambda p, k=k, bay=bay: (stand_u(p[0], bay), (1.1 + k * 1.23 + (p[1] - (L.tread_top(k) - L.RISER))) / PROFILE))
					f = steps.face(M, [(x0, y1 - c, z0), (x1, y1 - c, z0), (x1, y1, z0 + c), (x0, y1, z0 + c)], (0, 1, -1))
					steps.map_uv2([f], lambda p, k=k, bay=bay: (stand_u(p[0], bay), (1.1 + k * 1.23 + 0.37) / PROFILE))
					f = steps.face(M, [(x0, y1, z0 + c), (x0, y1, z1), (x1, y1, z1), (x1, y1, z0 + c)], (0, 1, 0))
					steps.map_uv2([f], lambda p, k=k, bay=bay: (stand_u(p[0], bay), (1.1 + k * 1.23 + 0.38 + (p[2] - L.tread_front(k))) / PROFILE))
				else:
					# Aisle: two half-steps per tier (0.19 m rise, 0.425 m going).
					ym = (y0 + y1) / 2 if k > 0 else y1 - L.RISER / 2
					zm = (z0 + z1) / 2
					for ya, yb, za, zb in ((y0, ym, z0, zm), (ym, y1, zm, z1)):
						f = steps.face(M, [(x0, ya, za), (x1, ya, za), (x1, yb, za), (x0, yb, za)], (0, 0, -1))
						steps.map_uv2([f], lambda p, k=k, bay=bay: (stand_u(p[0], bay), (1.1 + k * 1.23 + 0.2) / PROFILE))
						f = steps.face(M, [(x0, yb, za), (x0, yb, zb), (x1, yb, zb), (x1, yb, za)], (0, 1, 0))
						steps.map_uv2([f], lambda p, k=k, bay=bay: (stand_u(p[0], bay), (1.1 + k * 1.23 + 0.38 + (p[2] - L.tread_front(k))) / PROFILE))
	# Front wall with its coping; a gap at each aisle.
	fz0, fz1 = L.FRONT_WALL["z"]
	for x0, x1 in L.FRONT_WALL["x"]:
		for a, b in x_cuts(x0, x1):
			bay = bay_of((a + b) / 2)
			faces = steps.gbox(M, (a, G, fz0), (b, -8.8, fz1))
			steps.map_uv2(faces, lambda p, bay=bay: (stand_u(p[0], bay), (p[1] - G) / PROFILE))
		cap = steps.gbox("W1Concrete", (x0 - 0.02, -8.8, fz0 - 0.04), (x1 + 0.02, -8.72, fz1 + 0.04))
	# Stand ends: the slab's side (stepped top, inclined soffit) and the sloped end parapet on it.
	for xe, outward in ((L.STAND_X[0], -1.0), (L.STAND_X[1], 1.0)):
		prof = [(L.FRONT_WALL["z"][1], G)]
		for k in range(L.TIERS):
			y1 = L.tread_top(k)
			prof += [(L.tread_front(k), y1), (L.tread_front(k + 1), y1)]
		prof += [(L.REAR_PARAPET["z"][0], L.ramp_y(228.0) - 0.42)]
		f = steps.face("W1Concrete", [(xe, y, z) for z, y in prof], (outward, 0, 0))
		# The end parapet (EndWest/EndEast collider: 0.3 thick, top 0.66 m over its centre line).
		xa, xb = (L.END_WALLS[0] if outward < 0 else L.END_WALLS[1])
		top0, top1 = (212.45, -8.69), (228.0, -1.86)
		bottom = [(L.FRONT_WALL["z"][1], G + 0.9)]
		for k in range(1, L.TIERS):
			bottom += [(L.tread_front(k), L.tread_top(k - 1) - 0.05), (L.tread_front(k), L.tread_top(k) - 0.05)]
		bottom += [(228.0, L.tread_top(L.TIERS - 1) - 0.05)]
		for xs, side in ((xa, -1.0), (xb, 1.0)):
			pts = [(xs, y, z) for z, y in bottom] + [(xs, top1[1], top1[0]), (xs, top0[1], top0[0])]
			steps.face(M, pts, (side, 0, 0))
		steps.face(M, [(xa, top0[1], top0[0]), (xb, top0[1], top0[0]), (xb, top1[1], top1[0]), (xa, top1[1], top1[0])], (0, 1, -0.45))
		steps.face(M, [(xa, bottom[0][1], bottom[0][0]), (xb, bottom[0][1], bottom[0][0]), (xb, top0[1], top0[0]), (xa, top0[1], top0[0])], (0, 0, -1))
	# Rear parapet.
	steps.gbox(M, (L.STAND_X[0] - 0.3, L.tread_top(L.TIERS - 1), L.REAR_PARAPET["z"][0]), (L.STAND_X[1] + 0.3, L.REAR_PARAPET["y"][1], L.REAR_PARAPET["z"][1]))
	objs.append(build(steps, {"W1Concrete": 1.0}))

	structure = GPart("Structure")
	# Soffit: the slab's inclined underside, 0.42 under the ramp (the collision's 0.4 m), with the rear beam.
	zf, zb = L.FRONT_WALL["z"][1], L.REAR_PARAPET["z"][0]
	ys0, ys1 = G - 0.0, L.ramp_y(zb) - 0.42
	for x0, x1 in x_cuts(*L.STAND_X):
		structure.face("W1Concrete", [(x0, ys0, zf), (x1, ys0, zf), (x1, ys1, zb), (x0, ys1, zb)], (0, -1, 0.45))
	structure.gbox("W1Concrete", (L.STAND_X[0] - 0.3, ys1 - 0.5, zb), (L.STAND_X[1] + 0.3, L.tread_top(L.TIERS - 1), COLUMN_BACK))
	# Raker beams under the soffit at each column line: 0 deep at the front, 0.55 m from z 221 back.
	for xc in L.COLUMNS_X:
		pts = []
		for z in (219.0, 221.0, zb):
			depth = 0.0 if z <= 219.0 else 0.55
			pts.append((z, L.ramp_y(z) - 0.42, L.ramp_y(z) - 0.42 - depth))
		for (za, ta, ba), (zb_, tb, bb) in zip(pts, pts[1:]):
			for xs, side in ((xc - 0.15, -1), (xc + 0.15, 1)):
				structure.face("W1Concrete", [(xs, ta, za), (xs, tb, zb_), (xs, bb, zb_), (xs, ba, za)], (side, 0, 0))
			structure.face("W1Concrete", [(xc - 0.15, ba, za), (xc + 0.15, ba, za), (xc + 0.15, bb, zb_), (xc - 0.15, bb, zb_)], (0, -1, 0))
		# Column: 0.5 square concrete (inside the 0.55 collider), ground to the roof truss.
		structure.gbox("W1Concrete", (xc - 0.25, G, L.COLUMN_Z - 0.25), (xc + 0.25, ROOF_COLUMN_TOP, L.COLUMN_Z + 0.25))
	objs.append(build(structure, {"W1Concrete": 1.0}))

	roof = GPart("Roof")
	sheet = GPart("RoofSheet")
	fz, bz, fy, by = L.ROOF["front_z"], L.ROOF["back_z"], L.ROOF["front_y"], L.ROOF["back_y"]

	def roof_y(z):
		return fy + (by - fy) * (z - fz) / (bz - fz)

	x_lo, x_hi = L.STAND_X[0] - 0.5, L.STAND_X[1] + 0.5
	missing = {3, 4, 46}  # sheets blown off: moonlight falls through onto the west end
	faces = []
	for i in range(int(x_hi - x_lo)):
		if i in missing:
			continue
		a, b = x_lo + i, x_lo + i + 1
		faces.append(sheet.face("W4RoofSheet", [(a, roof_y(fz), fz), (a, roof_y(bz), bz), (b, roof_y(bz), bz), (b, roof_y(fz), fz)], (0, 1, 0)))
		faces.append(sheet.face("W4RoofSheet", [(a, roof_y(fz) - 0.02, fz), (b, roof_y(fz) - 0.02, fz), (b, roof_y(bz) - 0.02, bz),
			(a, roof_y(bz) - 0.02, bz)], (0, -1, 0)))
	slope_len = math.hypot(bz - fz, by - fy)
	set_uv(sheet, faces, lambda p: ((p[0] - x_lo) / 2.0, (p[2] - fz) / (bz - fz) * slope_len / 2.0))
	objs.append(build(sheet))
	# Fascia and rear beam.
	roof.gbox("W4SteelFrame", (x_lo, roof_y(fz) - 0.3, fz - 0.12), (x_hi, roof_y(fz) + 0.06, fz))  # gutter fascia
	roof.gbox("W4SteelFrame", (x_lo, roof_y(bz) - 0.35, bz - 0.25), (x_hi, roof_y(bz) - 0.02, bz))
	# Trusses at the columns: top chord under the sheet, bottom chord from the column head to the tip, Warren web.
	for xc in L.COLUMNS_X:
		tip = (fz + 0.2, roof_y(fz + 0.2) - 0.1)
		head = (L.COLUMN_Z, ROOF_COLUMN_TOP)
		back = (bz - 0.2, roof_y(bz - 0.2) - 0.1)
		top_pts = [(z, roof_y(z) - 0.1) for z in (tip[0], L.COLUMN_Z, back[0])]
		roof.beam("W4SteelFrame", (xc, top_pts[0][1], top_pts[0][0]), (xc, top_pts[1][1], top_pts[1][0]), 0.12, 0.14)
		roof.beam("W4SteelFrame", (xc, top_pts[1][1], top_pts[1][0]), (xc, top_pts[2][1], top_pts[2][0]), 0.12, 0.14)
		roof.beam("W4SteelFrame", (xc, head[1], head[0]), (xc, tip[1] - 0.05, tip[0]), 0.1, 0.12)
		roof.beam("W4SteelFrame", (xc, head[1], head[0]), (xc, back[1] - 0.25, back[0]), 0.1, 0.12)
		panels = 9
		for p in range(panels + 1):
			t = p / panels
			z = head[0] + (tip[0] - head[0]) * t
			yb = head[1] + (tip[1] - 0.05 - head[1]) * t
			yt = roof_y(z) - 0.1
			if p < panels:
				zn = head[0] + (tip[0] - head[0]) * (p + 1) / panels
				ybn = head[1] + (tip[1] - 0.05 - head[1]) * (p + 1) / panels
				roof.beam("W4SteelFrame", (xc, yb, z), (xc, roof_y(zn) - 0.1, zn) if p % 2 == 0 else (xc, ybn, zn), 0.06, 0.06, caps=False)
				if p % 2 == 1:
					roof.beam("W4SteelFrame", (xc, yt, z), (xc, ybn, zn), 0.06, 0.06, caps=False)
			roof.beam("W4SteelFrame", (xc, yb, z), (xc, yt, z), 0.06, 0.06, caps=False)
		# Strut from the column's side to the bottom chord (the PS1 braces).
		# It leaves the column 0.45 m over the rear parapet, so it stays 2 m over the top row (SirenSpot is on x 198).
		roof.beam("W4SteelFrame", (xc, -1.4, L.COLUMN_Z - 0.25), (xc, head[1] + (tip[1] - head[1]) * 0.35, head[0] + (tip[0] - head[0]) * 0.35), 0.1, 0.1)
	# Purlins along the stand every 1.6 m of slope.
	z = fz + 0.4
	while z < bz - 0.2:
		roof.beam("W4SteelFrame", (x_lo, roof_y(z) - 0.08, z), (x_hi, roof_y(z) - 0.08, z), 0.06, 0.12, caps=False)
		z += 1.6
	objs.append(build(roof, {"W4SteelFrame": 1.0}))

	ground = GPart("Ground")
	bx, bz2 = L.BEHIND["x"], L.BEHIND["z"]
	f = ground.face("W4Apron", [(bx[0], G + 0.004, bz2[0]), (bx[0], G + 0.004, bz2[1]), (bx[1], G + 0.004, bz2[1]), (bx[1], G + 0.004, bz2[0])], (0, 1, 0))
	set_uv(ground, [f], lambda p: (p[0], p[2]))
	ground.map_uv2([f], lambda p: (min(max((p[0] - 110.0) / 176.0, 0.0), 1.0), 0.999))  # the apron's edge: bare, trodden dirt
	objs.append(build(ground))

	pipes = GPart("Pipes")
	extra = [((162.4, -9.876, 226.6), 0.5), ((165.2, -9.876, 224.0), -0.2), ((160.8, -9.876, 223.2), 1.1)]
	for (ox, oy, oz), yaw in L.B03_PIPES + extra:
		dx, dz = math.sin(yaw) * 0.85, math.cos(yaw) * 0.85
		pipes.pipe("W1Iron", [(ox - dx, -9.8775, oz - dz), (ox + dx, -9.8775, oz + dz)], 0.0225, 8)
	objs.append(build(pipes, {"W1Iron": 1.0}))
	export(OUT / "stand.glb", objs)


COLUMN_BACK = 228.6
NOSING = 0.03
ROOF_COLUMN_TOP = -0.75


def seat_mesh(part, cx, ty, z0):
	"""One moulded seat on a tread whose front edge is z0 and top ty, centred at x = cx (faces +z? no: the track,
	which is -z). Pan 0.42 m wide at 0.40 m, back up to 0.78 m, on a pedestal; 26 triangles."""
	w = 0.21
	zf = z0 + 0.14  # pan front
	zp = zf + 0.36  # pan back
	pan_y = ty + 0.40
	prof = [(zf, pan_y), (zf + 0.18, pan_y - 0.03), (zp, pan_y), (zp + 0.06, ty + 0.78)]  # (z, y) along the shell
	front = [(zf - 0.02, pan_y - 0.06)]
	faces = []
	for (za, ya), (zb, yb) in zip(prof, prof[1:]):
		faces.append(part.face("W4Seat", [(cx - w, ya, za), (cx + w, ya, za), (cx + w, yb, zb), (cx - w, yb, zb)], (0, 1, -1)))
	under = [(zf - 0.02, pan_y - 0.04), (zp - 0.02, pan_y - 0.05), (zp + 0.03, ty + 0.76)]
	for (za, ya), (zb, yb) in zip(under, under[1:]):
		faces.append(part.face("W4Seat", [(cx - w, ya, za), (cx - w, yb, zb), (cx + w, yb, zb), (cx + w, ya, za)], (0, -1, 1)))
	faces.append(part.face("W4Seat", [(cx - w, prof[0][1], prof[0][0]), (cx - w, under[0][1], under[0][0]), (cx + w, under[0][1], under[0][0]),
		(cx + w, prof[0][1], prof[0][0])], (0, 0, -1)))
	faces.append(part.face("W4Seat", [(cx - w, prof[-1][1], prof[-1][0]), (cx + w, prof[-1][1], prof[-1][0]), (cx + w, under[-1][1], under[-1][0]),
		(cx - w, under[-1][1], under[-1][0])], (0, 1, 1)))
	for side in (-1, 1):
		pts = [(cx + side * w, y, z) for z, y in prof] + [(cx + side * w, y, z) for z, y in reversed(under)]
		faces.append(part.face("W4Seat", pts, (side, 0, 0)))
	# Pedestal.
	faces += part.beam("W4Seat", (cx, ty, zf + 0.2), (cx, pan_y - 0.05, zf + 0.2), 0.12, 0.16, caps=False)
	return faces


def build_seats():
	w1kit.reset()
	part = GPart("Seats")
	count = 0
	for k in range(L.TIERS):
		for a, b in seat_spans():
			n = int((b - a - 0.2) // 0.5)
			start = a + (b - a - n * 0.5) / 2 + 0.25
			for i in range(n):
				seat_mesh(part, start + i * 0.5, L.tread_top(k), L.tread_front(k))
				count += 1
	print("T261_SEATS", count)
	export(OUT / "stand_seats.glb", [build(part, {"W4Seat": 1.0})])


# ------------------------------------------------------------------------------------------------ floodlight poles

def head_frame(part):
	"""Six lamps in two rows on a galvanised frame at the pole's top, aimed at +x and 22 degrees down. Pole-local Godot
	frame (origin at the foot: y up from G)."""
	top = G + (L.POLE_TOP - G)  # pole top (Godot y)
	ys = (L.HEAD_Y - 0.45, L.HEAD_Y + 0.55)
	part.beam("W4PoleSteel", (0.18, ys[0] - 0.35, 0), (0.18, ys[1] + 0.35, 0), 0.08, 0.08)
	for y in ys:
		part.beam("W4PoleSteel", (0.18, y - 0.32, -1.5), (0.18, y - 0.32, 1.5), 0.06, 0.06)
	part.beam("W4PoleSteel", (0.0, ys[0] - 0.35, 0), (0.18, ys[0] - 0.35, 0), 0.08, 0.08)
	part.beam("W4PoleSteel", (0.0, ys[1] + 0.2, 0), (0.18, ys[1] + 0.2, 0), 0.08, 0.08)
	glass = []
	tilt = math.radians(22)
	for y in ys:
		for z in (-1.0, 0.0, 1.0):
			c = Vector((0.42, y, z))
			fwd = Vector((math.cos(tilt), -math.sin(tilt), 0.0))
			up = Vector((math.sin(tilt), math.cos(tilt), 0.0))
			side = Vector((0, 0, 1))
			hw, hh, d = 0.27, 0.22, 0.2
			def p(a, b, cdepth):
				q = c + side * a + up * b + fwd * cdepth
				return (q.x, q.y, q.z)
			back = [p(-hw * 0.8, -hh * 0.8, -d), p(hw * 0.8, -hh * 0.8, -d), p(hw * 0.8, hh * 0.8, -d), p(-hw * 0.8, hh * 0.8, -d)]
			front = [p(-hw, -hh, 0.0), p(hw, -hh, 0.0), p(hw, hh, 0.0), p(-hw, hh, 0.0)]
			n_f = (fwd.x, fwd.y, fwd.z)
			glass.append(part.face("W4FloodGlass", front, n_f))
			part.face("W4FloodBody", back, (-fwd.x, -fwd.y, -fwd.z))
			for i in range(4):
				j = (i + 1) % 4
				mid = Vector(front[i]) + Vector(front[j]) - c * 2
				part.face("W4FloodBody", [front[i], front[j], back[j], back[i]], (mid.x, mid.y, mid.z))
			# Yoke to the frame.
			part.beam("W4FloodBody", (0.2, c.y, z), (c.x - 0.12, c.y, z), 0.04, 0.04, caps=False)
	return glass


def build_pole(kind):
	w1kit.reset()
	part = GPart("Pole")
	height = L.POLE_TOP - G
	if kind == "steel":
		r0, r1, mat_pole = 0.21, 0.11, "W4PoleSteel"
		part.gbox("W1Concrete", (-0.26, G, -0.26), (0.26, G + 0.22, 0.26), bevel=0.02)
		part.gbox("W4PoleSteel", (-0.24, G + 0.22, -0.24), (0.24, G + 0.25, 0.24))
		for sx in (-1, 1):
			for sz in (-1, 1):
				part.pipe("W4PoleSteel", [(sx * 0.19, G + 0.25, sz * 0.19), (sx * 0.19, G + 0.31, sz * 0.19)], 0.018, 6)
	else:
		r0, r1, mat_pole = 0.2, 0.12, "W1Concrete"
		part.gbox("W1Concrete", (-0.25, G, -0.25), (0.25, G + 0.12, 0.25), bevel=0.02)
	segs = 16
	rings = 6
	for i in range(rings):
		ya, yb = G + 0.22 + (height - 0.22) * i / rings, G + 0.22 + (height - 0.22) * (i + 1) / rings
		ra, rb = r0 + (r1 - r0) * i / rings, r0 + (r1 - r0) * (i + 1) / rings
		for s in range(segs):
			a0, a1 = s / segs * math.tau, (s + 1) / segs * math.tau
			part.face(mat_pole, [(math.cos(a0) * ra, ya, math.sin(a0) * ra), (math.cos(a1) * ra, ya, math.sin(a1) * ra),
				(math.cos(a1) * rb, yb, math.sin(a1) * rb), (math.cos(a0) * rb, yb, math.sin(a0) * rb)],
				(math.cos((a0 + a1) / 2), 0, math.sin((a0 + a1) / 2)))
	part.face(mat_pole, [(math.cos(-s / segs * math.tau) * r1, G + height, math.sin(-s / segs * math.tau) * r1) for s in range(segs)], (0, 1, 0))
	# Step bolts up the back (away from the pitch), alternating sides, from 2.5 m.
	y = G + 2.5
	k = 0
	while y < L.HEAD_Y - 1.2:
		t = (y - G) / height
		r = r0 + (r1 - r0) * t
		side = 1 if k % 2 == 0 else -1
		part.beam("W4PoleSteel", (-r * 0.7, y, side * r * 0.7), (-r - 0.16, y, side * (r + 0.1)), 0.025, 0.025, caps=False)
		y += 0.38
		k += 1
	# Cable box at hand height.
	part.gbox("W4FloodBody", (-r0 - 0.12, G + 1.1, -0.14), (-r0, G + 1.5, 0.14))
	head_frame(part)
	obj = build(part, {"W1Concrete": 1.0, "W4PoleSteel": 1.0, "W4FloodBody": 1.0})
	export(OUT / f"pole_{kind}.glb", [obj])


# ------------------------------------------------------------------------------------------------ fences and gates

def fence_runs():
	"""The pilot fences as (start, end) in Godot x/z; gate leaves come from the gates."""
	return [L.FENCES[name] for name in L.PILOT_FENCES]


def build_fence(kind):
	w1kit.reset()
	frame = GPart("Fence")
	mesh = GPart("Mesh")
	paint = "W4PoleSteel" if kind == "b40" else "W3LampPaint"
	top = G + L.FENCE_H
	mesh_faces = []

	def run(a, b, height, offset=0.0, leaf=False):
		(ax, az), (bx, bz) = a, b
		length = math.hypot(bx - ax, bz - az)
		dx, dz = (bx - ax) / length, (bz - az) / length
		nx, nz = -dz, dx
		ax, az, bx, bz = ax + nx * offset, az + nz * offset, bx + nx * offset, bz + nz * offset
		yt = G + height
		posts = max(1, round(length / 2.5))
		for i in range(posts + 1):
			px, pz = ax + (bx - ax) * i / posts, az + (bz - az) * i / posts
			if kind == "b40":
				frame.pipe(paint, [(px, G + (0.02 if not leaf else 0.05), pz), (px, yt + 0.04, pz)], 0.03 if not leaf else 0.021, 8)
			else:
				frame.beam(paint, (px, G, pz), (px, yt + 0.03, pz), 0.05, 0.05)
		if kind == "b40":
			frame.pipe(paint, [(ax, yt, az), (bx, yt, bz)], 0.021, 8, cap=False)
			frame.pipe(paint, [(ax, G + 0.08, az), (bx, G + 0.08, bz)], 0.004 if not leaf else 0.021, 4, cap=False)
			f = mesh.face("W4Chainlink", [(ax, G + 0.04, az), (bx, G + 0.04, bz), (bx, yt - 0.01, bz), (ax, yt - 0.01, az)], (nx, 0, nz))
			mesh_faces.append((f, ax, az, dx, dz))
		else:
			frame.beam(paint, (ax, yt - 0.02, az), (bx, yt - 0.02, bz), 0.05, 0.04, caps=False)
			frame.beam(paint, (ax, G + 0.12, az), (bx, G + 0.12, bz), 0.05, 0.04, caps=False)
			bars = int(length / 0.13)
			for i in range(1, bars):
				px, pz = ax + (bx - ax) * i / bars, az + (bz - az) * i / bars
				frame.beam(paint, (px, G + 0.1, pz), (px, yt - 0.02, pz), 0.016, 0.016, caps=False)
	for a, b in fence_runs():
		run(a, b, L.FENCE_H)
	# Gate leaves: each 4.8 m leaf swung right back and lying flat along the fence outside the opening, 0.14 m out.
	for name in L.PILOT_GATES:
		(ax, az), (bx, bz), (ox, oz) = L.GATES[name]
		length = math.hypot(bx - ax, bz - az)
		dx, dz = (bx - ax) / length, (bz - az) / length
		for (px, pz), sgn in (((ax, az), -1), ((bx, bz), 1)):
			start = (px + dx * sgn * 0.3, pz + dz * sgn * 0.3)
			end = (px + dx * sgn * 5.1, pz + dz * sgn * 5.1)
			# offset sign: the run's left normal is (-dz, dx) of its own direction; push it outward (ox, oz).
			rdx, rdz = end[0] - start[0], end[1] - start[1]
			ln = math.hypot(rdx, rdz)
			left = (-rdz / ln, rdx / ln)
			off = 0.14 * (1 if left[0] * ox + left[1] * oz > 0 else -1)
			run(start, end, 1.8, off, leaf=True)
	for f, ax, az, dx, dz in mesh_faces:
		for loop in f.loops:
			co = loop.vert.co
			along = (co.x - ax) * dx + ((-co.y) - az) * dz
			loop[mesh.uv].uv = (along / 0.4, -(co.z) / 0.4)
		f.tag = True
	objs = [build(frame, {paint: 1.0})]
	if mesh_faces:
		objs.append(build(mesh))
	export(OUT / f"fence_{kind}.glb", objs)


def build_pillars():
	w1kit.reset()
	part = GPart("Pillars")
	half, cap = 0.225, 0.275
	for name in L.PILOT_GATES:
		for (px, pz) in L.GATES[name][:2]:
			faces = part.gbox("W4Pillar", (px - half, G, pz - half), (px + half, G + L.POST_H - 0.14, pz + half))
			part.map_uv2(faces, lambda p, px=px, pz=pz: (0.82 + ((p[0] - px + half) + (p[2] - pz + half)) / 1.8 * 0.16 % 0.16,
				(1.0 - (p[1] - G) / L.POST_H) * 0.6))
			faces = part.gbox("W4Pillar", (px - cap, G + L.POST_H - 0.14, pz - cap), (px + cap, G + L.POST_H, pz + cap), bevel=0.02)
			part.map_uv2(faces, lambda p: (0.9, 0.02))
	export(OUT / "gate_pillars.glb", [build(part, {"W4Pillar": 1.0})])


BUILDS = {"field": build_field, "goal": build_goal, "stand": build_stand, "seats": build_seats,
	"pole_steel": lambda: build_pole("steel"), "pole_concrete": lambda: build_pole("concrete"),
	"fence_b40": lambda: build_fence("b40"), "fence_bars": lambda: build_fence("bars"), "pillars": build_pillars}


if __name__ == "__main__":
	random.seed(261)
	args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for key in (args or list(BUILDS)):
		BUILDS[key]()
