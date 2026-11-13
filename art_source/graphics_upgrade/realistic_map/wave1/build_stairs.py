"""T-250 (D-166) wave 1, A06 + A07: building B's two stairwells, built to the colliders of building_b.tscn
(art_source/campus/build_campus.py stairs(): landings x0..x0+5 x z 0..4, turns z -6.2..-4.8, ramps 2.16 m wide,
4.8 m long, 1.65 m drop; walls at x0, x0+5, z -6.2 and z 4.025). Run with Blender 5.2.2:
  blender -b --factory-startup -P <this file> [-- main|fire]

Each stairwell gives one glb in Godot world coordinates (instanced at the identity under MainStairs / FireStairs):
  <side>_stairs.glb  Steps     every flight as concrete steps under terrazzo treads and risers. Each visible
                               tread's top, at its centre, lies on the hidden collision ramp (the ramp cannot match
                               a step everywhere: a tread is 7.5 cm above it at its nosing and below it at its back)
                     Landings  floor landings and turn landings, terrazzo, slab edges, plastered soffits
                     Walls     plaster and a painted dado on the inside faces (3 mm in front of the PS1 wall boxes,
                               whose outer faces stay), terrazzo skirting, the walls carried up past the old 2.75 m top
                     Rails     wall handrails and the steel balustrade at the stair well; T-254: the balustrade
                               on floor 4's landing edge over the well and flight 4B (its collider is in the scene)
                     Upper     the storey above floor 4: a turn landing, the flight up to floor 5 and the floor-5
                               landing (the ceiling over floor 4), the flight from floor 4 broken off over the well,
                               out of reach; the rubble that blocks it (UpperRubble's box) and the stairwell's roof
                     Rubble    fire stairs only: the flight from floor 2 to floor 1 fallen, its top jammed with
                               debris in the Collapse box, the rest broken on the ground floor
                     Crack     fire stairs only: the crack on the outer wall (Clues/CrackStair)
Frame: G(x, y, z) maps Godot world coordinates to Blender's.
"""
import math
import random
import sys
from pathlib import Path

import bmesh
from mathutils import Matrix, Vector

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parent))
import w1kit as kit  # noqa: E402

LANDING_T = 0.24
TREAD_T = 0.03
NOSE = 0.025
WAIST = 0.20
SKIRT = 0.12
DADO = 1.1
CEILING = 3.06
TOP = 6.3  # inside height the walls are carried to (the old boxes stop at 2.75)
PLASTER = 2.0  # m, Painted Plaster Wall scan (shell shader has no uv1_scale)
TERRAZZO = 1.0
LANDING_RAIL_Z = 0.025  # the line of the rails standing on a floor landing's edge (z 0 .. 0.05 on the slab)


def G(x, y, z):
	return Vector((x, -z, y))


def flight_count(y0, y1):
	return max(4, math.ceil(abs(y1 - y0) / 0.15))


class Well:
	def __init__(self, side):
		self.side = side
		self.x0 = 44.0 if side == "fire" else -5.0
		# Inside wall faces: west x0, east x0+5; Fire's west and Main's east are the partial (corridor) walls.
		self.partial = "west" if side == "fire" else "east"
		self.flights = []
		for upper in (4, 3, 2):
			y = (upper - 4) * 3.3
			if side == "fire" and upper == 2:
				continue
			x0 = self.x0
			self.flights.append(("%dA" % upper, x0 + 0.12, x0 + 2.28, 0.0, -4.8, y, y - 1.65))
			self.flights.append(("%dB" % upper, x0 + 2.72, x0 + 4.88, -4.8, 0.0, y - 1.65, y - 3.3))
		self.turns = [(upper - 4) * 3.3 - 1.65 for upper in (4, 3, 2) if not (side == "fire" and upper == 2)]


def tread_tops(z0, z1, y0, y1):
	n = flight_count(y0, y1)
	dz = (z1 - z0) / n
	return n, dz, [(z0 + dz * i, z0 + dz * (i + 1), y0 + (y1 - y0) * (i + 0.5) / n) for i in range(n)]


def ramp_at(z, z0, z1, y0, y1):
	t = (z - z0) / (z1 - z0)
	return y0 + (y1 - y0) * t


def tread_uv2(part, faces, za, zb, xa, xb):
	"""Mask UV2 over one tread or landing: u across the width, v from the nosing (0) to the back (1)."""
	def fn(co):
		x = co.x
		z = -co.y
		return ((x - xa) / (xb - xa), (z - za) / (zb - za))
	part.set_uv2(faces, fn)


def build_flight(steps, xa, xb, z0, z1, y0, y1, wall_x=None, start=0.0, stop=1.0, broken=False, seed=0):
	"""Concrete steps (stepped top, sloped soffit WAIST under the ramp) clad in terrazzo treads and risers.
	wall_x: the flight is carried to that wall face; start/stop: the part of the flight (from its (z0, y0) end) that
	still stands; broken: torn concrete and bent bars at a cut end."""
	n, dz, treads = tread_tops(z0, z1, y0, y1)
	sgn = 1 if dz > 0 else -1
	lo_x = min(xa, wall_x) if wall_x is not None and wall_x < xa else xa
	hi_x = max(xb, wall_x) if wall_x is not None and wall_x > xb else xb
	first = int(math.ceil(start * n - 1e-6))
	last = int(math.floor(stop * n + 1e-6)) - 1
	for i, (za, zb, top) in enumerate(treads):
		if i < first or i > last:
			continue
		below = treads[i + 1][2] if i + 1 < n else y1
		core_top = top - TREAD_T
		# Concrete body under this tread, down to the soffit line under its back edge.
		soffit_a = ramp_at(za, z0, z1, y0, y1) - WAIST
		soffit_b = ramp_at(zb, z0, z1, y0, y1) - WAIST
		zs = sorted((za, zb))
		body = steps.poly("W1StairSide", [
			G(lo_x, core_top, za), G(lo_x, core_top, zb), G(lo_x, soffit_b, zb), G(lo_x, soffit_a, za),
			G(hi_x, core_top, za), G(hi_x, core_top, zb), G(hi_x, soffit_b, zb), G(hi_x, soffit_a, za)],
			[(0, 1, 2, 3), (7, 6, 5, 4), (0, 4, 5, 1), (3, 2, 6, 7), (0, 3, 7, 4), (1, 5, 6, 2)])
		for f in body:
			n_ = f.normal
			if n_.z < -0.5:
				f.material_index = steps.slot("W1Soffit")
		# Riser below this tread's nosing (terrazzo), from the next tread (or landing) up to under this one; a
		# flight cut at its lower end shows the broken core instead.
		if i < last or stop >= 1.0:
			riser = steps.box("W1Terrazzo", tuple(G(lo_x, below, zb)), tuple(G(hi_x, core_top, zb - sgn * 0.015)))
			tread_uv2(steps, riser, zb - sgn * 0.015, zb, lo_x, hi_x)
		# Tread slab with its nosing over the riser, an anti-slip groove pair near the nose.
		nose_z = zb + sgn * NOSE
		tread = steps.box("W1Terrazzo", tuple(G(lo_x, core_top, za)), tuple(G(hi_x, top, nose_z)), bevel=0.004)
		tread_uv2(steps, tread, nose_z, za, lo_x, hi_x)
		for k in (0.045, 0.07):
			zg = nose_z - sgn * k
			steps.box("W1Groove", tuple(G(xa + 0.06, top - 0.002, zg - 0.006)), tuple(G(xb - 0.06, top + 0.0008, zg + 0.006)))
	if broken and first <= last:
		# The torn end: jagged concrete and bent bars where the flight broke away.
		if stop < 1.0:
			za_, zb_, top = treads[last]
			za, sgn = zb_, -sgn
		else:
			za, zb, top = treads[first]
		rng = random.Random(seed)
		for k in range(9):
			x = xa + (xb - xa) * (k + 0.5) / 9
			bend = Vector((rng.uniform(-0.05, 0.05), rng.uniform(-0.25, -0.05), rng.uniform(0.05, 0.25) * -sgn))
			p0 = G(x, top - 0.12 - rng.random() * 0.08, za)
			p1 = p0 + Vector((bend.x, -bend.z, bend.y)) * 0.5
			p2 = p1 + Vector((bend.x * 0.5, -bend.z * 0.4, bend.y * 1.6))
			steps.tube("W1Rebar", [p0, p1, p2], 0.006, 6)
		for k in range(5):
			x = xa + (xb - xa) * (k + rng.random()) / 5
			c = G(x, top - 0.1 - rng.random() * 0.1, za - sgn * rng.uniform(0.0, 0.06))
			rock(steps, c, rng.uniform(0.08, 0.16), rng, "W1Concrete")


def rock(part, centre, size, rng, mat_name="W1Concrete", flat=1.0):
	"""An irregular chunk: the convex hull of jittered points."""
	pts = []
	for _ in range(11):
		v = Vector((rng.gauss(0, 1), rng.gauss(0, 1), rng.gauss(0, 1) * flat))
		v.normalize()
		pts.append(centre + Vector((v.x * size * rng.uniform(0.6, 1.3), v.y * size * rng.uniform(0.6, 1.3), v.z * size * rng.uniform(0.5, 1.0) * flat)))
	verts = [part.bm.verts.new(p) for p in pts]
	hull = bmesh.ops.convex_hull(part.bm, input=verts)
	faces = [g for g in hull["geom"] if isinstance(g, bmesh.types.BMFace)]
	for g in hull.get("geom_interior", []) + hull.get("geom_unused", []):
		if isinstance(g, bmesh.types.BMVert) and g.is_valid and not g.link_faces:
			part.bm.verts.remove(g)
	bmesh.ops.recalc_face_normals(part.bm, faces=faces)
	return part._finish(faces, mat_name)


def heap(part, rng, xa, xb, za, zb, y_low, y_high, front=None, well_x=None, core=True):
	"""A packed pile of broken concrete filling x xa..xb, z za..zb (za > zb), between y_low(z) and y_high(z):
	a few big hidden blocks inside, then a skin of smaller chunks on the top, on its face towards +Z (front,
	the z it must not pass) and towards the well (well_x, the x it must not pass)."""
	def jitter(v):
		return v + rng.uniform(-0.05, 0.05)
	if core:
		for k in range(10):
			z = rng.uniform(zb + 0.5, za - 0.5)
			lo, hi = y_low(z), y_high(z)
			if hi - lo < 0.5:
				continue
			size = min(0.55, (hi - lo) * 0.45, (xb - xa) * 0.3)
			rock(part, G(rng.uniform(xa + size, xb - size), (lo + hi) / 2, z), size, rng, "W1Concrete", flat=0.8)
	step = 0.3
	x = xa + 0.15
	while x < xb - 0.1:
		z = za - 0.2
		while z > zb + 0.1:
			size = rng.uniform(0.16, 0.26)
			top = y_high(z) - size * 0.55
			if top > y_low(z):
				xx = min(jitter(x), xb - size * 1.3) if well_x is None else min(jitter(x), well_x - size * 1.3)
				zz = min(jitter(z), (front if front is not None else za) - size * 1.3)
				rock(part, G(xx, top, zz), size, rng, "W1Concrete" if rng.random() > 0.25 else "W1Terrazzo", flat=rng.uniform(0.5, 0.9))
			z -= step
		x += step
	if front is not None:
		x = xa + 0.15
		while x < xb - 0.1:
			z = front
			y = y_low(z) + 0.15
			while y < y_high(z) - 0.12:
				size = rng.uniform(0.17, 0.27)
				xx = min(jitter(x), (well_x if well_x is not None else xb) - size * 1.3)
				rock(part, G(xx, jitter(y), front - size * 1.3 - rng.uniform(0.0, 0.08)), size, rng,
					"W1Concrete" if rng.random() > 0.3 else "W1Terrazzo", flat=rng.uniform(0.6, 1.0))
				y += 0.27
			x += 0.29
	if well_x is not None:
		z = za - 0.3
		while z > zb + 0.2:
			y = y_low(z) + 0.15
			while y < y_high(z) - 0.12:
				size = rng.uniform(0.16, 0.25)
				rock(part, G(well_x - size * 1.3, jitter(y), min(jitter(z), (front if front is not None else za) - size * 1.3)), size, rng,
					"W1Concrete", flat=rng.uniform(0.6, 1.0))
				y += 0.28
			z -= 0.3


def slab(part, xa, xb, za, zb, top, thick=LANDING_T, edge_faces=True):
	"""A landing: terrazzo top (UV2 over it), terrazzo edge band, plastered soffit."""
	t = part.box("W1Terrazzo", tuple(G(xa, top - 0.03, za)), tuple(G(xb, top, zb)))
	tops = [f for f in t if f.normal.z > 0.9]
	tread_uv2(part, tops, za, zb, xa, xb)
	body = part.box("W1StairSide", tuple(G(xa, top - thick, za)), tuple(G(xb, top - 0.03, zb)))
	for f in body:
		if f.normal.z < -0.5:
			f.material_index = part.slot("W1Soffit")


def wall_lines(well, face):
	"""Floor lines on one inside face, bottom to top: lists of (h, y) over the face's horizontal axis
	(z for the x faces, x for the z faces)."""
	x0 = well.x0
	if face in ("west", "east"):
		zr = (-6.2, 4.025)
		if face == well.partial:
			zr = (-6.2, -0.2)
		hs = sorted({zr[0], zr[1]} | {h for h in (-4.8, 0.0) if zr[0] < h < zr[1]})

		def prof(kind, Y):
			def f(z):
				if kind == "A":
					return Y if z >= 0 else (Y - 1.65 * min(-z, 4.8) / 4.8)
				return Y - 3.3 if z >= 0 else (Y - 3.3 + 1.65 * min(-z, 4.8) / 4.8)
			return [(h, f(h)) for h in hs]
		kind = "A" if face == "west" else "B"
		# The ground floor, each storey's profile, and the storey above floor 4 (visual) on top.
		lines = [[(h, -9.9) for h in hs]]
		for Y in ((-6.6, -3.3, 0.0, 3.3) if kind == "A" else (-6.6, -3.3, 0.0, 3.3, 6.6)):
			lines.append(prof(kind, Y))
		lines = [line for line in lines if min(y for _, y in line) < TOP - 0.5]
		lines = [[(h, min(y, TOP - 0.5)) for h, y in line] for line in lines]
		return lines, hs
	xs = [x0, x0 + 5.0]
	levels = [-9.9, -8.25, -4.95, -1.65, 1.65] if face == "back" else [-9.9, -6.6, -3.3, 0.0, 3.3]
	return [[(h, y) for h in xs] for y in levels], xs


def face_inset(well, face):
	"""How far in front of the old wall face the plaster goes: the corridor-side wall carries building B's floor
	walls (Floor1-3 East/West, x 44 +/- 0.1 and 0 +/- 0.1), which stand 10 cm into the stairwell; cover them."""
	return 0.103 if face == well.partial else 0.003


def face_point(well, face, h, y, inset=0.003):
	x0 = well.x0
	if face == "west":
		return G(x0 + inset, y, h)
	if face == "east":
		return G(x0 + 5.0 - inset, y, h)
	if face == "back":
		return G(h, y, -6.2 + inset)
	return G(h, y, 4.025 - inset)


def band(part, well, face, lower, upper, mat_name, v0, v1, inset=0.003, uv2=True):
	"""Quads between two lines (same h breakpoints) on a face, UV2 u along the face, v from v0 to v1."""
	hs = [p[0] for p in lower]
	h_min, h_max = min(hs), max(hs)
	faces = []
	for (h0, a0), (h1, a1), (_, b0), (_, b1) in zip(lower, lower[1:], upper, upper[1:]):
		if max(b0 - a0, b1 - a1) <= 1e-4:
			continue
		quad = [face_point(well, face, h0, a0, inset), face_point(well, face, h1, a1, inset),
			face_point(well, face, h1, b1, inset), face_point(well, face, h0, b0, inset)]
		made = part.poly(mat_name, quad, [(0, 1, 2, 3)], recalc=False)
		# Face the stairwell's inside.
		centre = Vector((well.x0 + 2.5, 0, 0))
		f = made[0]
		f.normal_update()
		inward = {"west": Vector((1, 0, 0)), "east": Vector((-1, 0, 0)), "back": Vector((0, -1, 0)), "front": Vector((0, 1, 0))}[face]
		if f.normal.dot(inward) < 0:
			f.normal_flip()
		if uv2:
			def fn(co, h_min=h_min, h_max=h_max, lower=lower, upper=upper):
				h = co.x if face in ("back", "front") else -co.y
				y = co.z
				# Interpolate the band's lower line at h; v rises with height above it.
				lo = _interp(lower, h)
				return ((h - h_min) / max(h_max - h_min, 1e-6), v0 + (y - lo) / 3.3)
			part.set_uv2(made, fn)
		faces += made
	return faces


def _interp(line, h):
	pts = sorted(line)
	for (h0, y0), (h1, y1) in zip(pts, pts[1:]):
		if h0 <= h <= h1:
			t = 0 if h1 == h0 else (h - h0) / (h1 - h0)
			return y0 + (y1 - y0) * t
	return pts[0][1] if h < pts[0][0] else pts[-1][1]


def walls(part, well):
	for face in ("west", "east", "back", "front"):
		lines, hs = wall_lines(well, face)
		lines.sort(key=lambda line: sum(y for _, y in line))
		ceiling = [(h, TOP) for h in hs]
		for k, line in enumerate(lines):
			above = lines[k + 1] if k + 1 < len(lines) else ceiling
			inset = face_inset(well, face)
			dado = [(h, min(y + DADO, _interp(above, h))) for h, y in line]
			band(part, well, face, line, dado, "W1StairDado", 0.0, DADO / 3.3, inset=inset)
			band(part, well, face, dado, above, "W1StairWall", DADO / 3.3, 1.0, inset=inset)
			# Terrazzo skirting along the floor line, 1 cm proud.
			skirt = [(h, y + SKIRT) for h, y in line]
			band(part, well, face, line, skirt, "W1Terrazzo", 0.0, 0.04, inset=inset + 0.01, uv2=False)
			# Its top edge.
			for (h0, a0), (h1, a1) in zip(skirt, skirt[1:]):
				p = [face_point(well, face, h0, a0, inset), face_point(well, face, h1, a1, inset),
					face_point(well, face, h1, a1, inset + 0.01), face_point(well, face, h0, a0, inset + 0.01)]
				f = part.poly("W1Terrazzo", p, [(0, 1, 2, 3)], recalc=False)[0]
				f.normal_update()
				if f.normal.z < 0:
					f.normal_flip()
	# The partial wall's end at z -0.2, facing the landing (plaster over the old box's end and the floor walls').
	xw = well.x0 - 0.16 if well.partial == "west" else well.x0 + 5.0 - 0.103
	end = part.poly("W1StairWall", [G(xw, -9.9, -0.197), G(xw + 0.263, -9.9, -0.197), G(xw + 0.263, TOP, -0.197), G(xw, TOP, -0.197)],
		[(0, 1, 2, 3)], recalc=False)
	end[0].normal_update()
	if end[0].normal.dot(Vector((0, -1, 0))) < 0:
		end[0].normal_flip()
	# Above the old 2.75 m tops: solid wall boxes outside too (their outer faces match the PS1 walls), and a roof.
	x0 = well.x0
	for lo, hi in (((x0 - 0.16, 2.74, -6.4), (x0, TOP + 0.3, -0.2 if well.partial == "west" else 4.175)),
			((x0 + 5.0, 2.74, -6.4), (x0 + 5.16, TOP + 0.3, -0.2 if well.partial == "east" else 4.175)),
			((x0 - 0.16, 2.74, -6.4), (x0 + 5.16, TOP + 0.3, -6.2)), ((x0 - 0.16, 2.74, 4.025), (x0 + 5.16, TOP + 0.3, 4.175))):
		b = part.box("W1OldWall", tuple(G(*lo)), tuple(G(*hi)))
	part.box("W1OldWall", tuple(G(x0 - 0.16, TOP, -6.4)), tuple(G(x0 + 5.16, TOP + 0.3, 4.175)))
	roof = part.box("W1Soffit", tuple(G(x0, TOP - 0.004, -6.2)), tuple(G(x0 + 5.0, TOP, 4.025)))


def rails(part, well, flights, upper_flights):
	"""Wall handrails beside each flight; the well balustrade (square bars, wooden rail) on the flights' inner
	edges, round the well's ends and across it at the floor landings."""
	x0 = well.x0
	for name, xa, xb, z0, z1, y0, y1 in flights + upper_flights:
		if name.startswith("U"):
			continue
		n, dz, treads = tread_tops(z0, z1, y0, y1)
		wall_side = "west" if name.endswith("A") else "east"
		off = face_inset(well, wall_side) + 0.047
		wall_x = x0 + off if wall_side == "west" else x0 + 5.0 - off
		# Wall handrail: a round wooden rail on steel brackets, 0.9 m over the pitch line.
		pts = []
		for k in range(2):
			z = z0 + (z1 - z0) * (0.03 if k == 0 else 0.97)
			pts.append(G(wall_x + (0.03 if wall_side == "west" else -0.03), ramp_at(z, z0, z1, y0, y1) + 0.9, z))
		part.tube("W1RailWood", pts, 0.022, 10)
		for k in range(4):
			t = 0.12 + 0.76 * k / 3
			z = z0 + (z1 - z0) * t
			h = ramp_at(z, z0, z1, y0, y1) + 0.9
			xa_ = wall_x - (0.05 if wall_side == "west" else -0.05)
			part.tube("W1Steel", [G(xa_, h - 0.05, z), G(xa_ + (0.06 if wall_side == "west" else -0.06), h - 0.05, z),
				G(xa_ + (0.08 if wall_side == "west" else -0.08), h - 0.02, z)], 0.006, 6)
		# Well balustrade on the inner edge.
		edge_x = xb - 0.025 if name.endswith("A") else xa + 0.025
		top_pts = [G(edge_x, y0 + 0.95, z0), G(edge_x, y1 + 0.95, z1)]
		part.tube("W1RailWood", top_pts, 0.028, 10)
		part.tube("W1RailSteel", [G(edge_x, y0 + 0.12, z0), G(edge_x, y1 + 0.12, z1)], 0.009, 6)
		count = int(abs(z1 - z0) / 0.12)
		for k in range(count + 1):
			z = z0 + (z1 - z0) * k / count
			i = min(n - 1, int((z - z0) / dz)) if dz != 0 else 0
			foot = treads[i][2]
			head = ramp_at(z, z0, z1, y0, y1) + 0.95
			part.box("W1RailSteel", tuple(G(edge_x - 0.007, foot, z - 0.007)), tuple(G(edge_x + 0.007, head, z + 0.007)))
		for z, y in ((z0, y0), (z1, y1)):
			part.box("W1RailSteel", tuple(G(edge_x - 0.025, y, z - 0.025)), tuple(G(edge_x + 0.025, y + 1.02, z + 0.025)))
	# Round the well's far end at each turn landing and across it at the floor landings.
	for name, xa, xb, z0, z1, y0, y1 in flights:
		if name.endswith("A"):
			y = y1
			z = -4.8 + 0.025
			part.tube("W1RailWood", [G(x0 + 2.255, y + 0.95, z), G(x0 + 2.745, y + 0.95, z)], 0.028, 10)
			for k in range(4):
				x = x0 + 2.3 + k * 0.13
				part.box("W1RailSteel", tuple(G(x - 0.007, y, z - 0.007)), tuple(G(x + 0.007, y + 0.95, z + 0.007)))
	for y in (-3.3, -6.6, -9.9):
		if well.side == "fire" and y == -9.9:
			continue
		z = LANDING_RAIL_Z
		part.tube("W1RailWood", [G(x0 + 2.255, y + 0.95, z), G(x0 + 2.745, y + 0.95, z)], 0.028, 10)
	landing_rail(part, well)


def landing_rail_span(well):
	"""T-254: floor 4's landing edge left open over the well and flight 4B, from flight 4A's top newel (x0 + 2.255)
	to the plaster on the side-B wall."""
	return well.x0 + 2.255, well.x0 + 5.0 - face_inset(well, "east")


def landing_rail(part, well):
	"""T-254: the balustrade on floor 4's landing edge over the well and flight 4B, in the well balustrade's style:
	square steel bars every ~12 cm, a lower steel rail, the wooden handrail at 0.95 m, joined to flight 4A's top newel
	and ending at a newel against the side-B wall. It stands on the slab (z 0 .. 0.05, the line of the lower floors'
	rails across the well), inside its collider <Side>Stairs/Landing4Rail in building_b.tscn (5 cm x 1 m)."""
	xa, xb = landing_rail_span(well)
	z = LANDING_RAIL_Z
	end = xb - 0.025  # the wall newel's centre
	part.tube("W1RailWood", [G(xa, 0.95, z), G(end, 0.95, z)], 0.028, 10)
	part.tube("W1RailSteel", [G(xa, 0.12, z), G(end, 0.12, z)], 0.009, 6)
	count = max(2, round((end - xa) / 0.12))
	for k in range(1, count):
		x = xa + (end - xa) * k / count
		part.box("W1RailSteel", tuple(G(x - 0.007, 0.0, z - 0.007)), tuple(G(x + 0.007, 0.95, z + 0.007)))
	part.box("W1RailSteel", tuple(G(end - 0.025, 0.0, z - 0.025)), tuple(G(end + 0.025, 1.02, z + 0.025)))


def upper_storey(steps, part, well):
	"""Above floor 4: turn landing at 1.65, the flight up from floor 4 broken over the well, the flight to floor 5,
	the floor-5 landing (the ceiling over floor 4) and the rubble that fills UpperRubble's box."""
	x0 = well.x0
	slab(steps, x0, x0 + 5.0, -6.2, -4.8, 1.65)
	slab(steps, x0, x0 + 5.0, 0.0, 4.0, 3.3)
	# The flight from floor 4 on side B rose to the turn; its first 40 % fell into the well.
	build_flight(steps, x0 + 2.72, x0 + 4.88, 0.0, -4.8, 0.0, 1.65, wall_x=x0 + 5.0, start=0.4, broken=True, seed=7)
	# Flight to floor 5 on side A (above flight 4A).
	build_flight(steps, x0 + 0.12, x0 + 2.28, -4.8, 0.0, 1.65, 3.3, wall_x=x0)
	rng = random.Random(41 if well.side == "fire" else 42)
	# UpperRubble's box (x0..x0+5, y 3.2..5.2, z -2.4..0): a pile on the flight to floor 5 and the floor-5
	# landing's edge, spilling over the flight's edge into the well; the way up is shut.
	heap(part, rng, x0 + 0.15, x0 + 2.4, -0.1, -2.4, lambda z: ramp_at(z, -4.8, 0.0, 1.65, 3.3), lambda z: 4.7 + 0.2 * z,
		well_x=x0 + 2.65)
	heap(part, rng, x0 + 0.15, x0 + 4.85, 0.6, 0.05, lambda z: 3.3, lambda z: 4.6 - 0.5 * z, core=False)
	for k in range(10):
		p0 = G(x0 + rng.uniform(0.3, 2.2), rng.uniform(3.4, 4.4), rng.uniform(-2.2, -0.2))
		d = Vector((rng.uniform(-0.3, 1), rng.uniform(-1, 1), rng.uniform(-0.6, 0.2))).normalized()
		part.tube("W1Rebar", [p0, p0 + d * 0.5, p0 + d * 0.8 + Vector((0, 0, -0.25))], 0.007, 6)
	# Pieces hanging over the broken flight's top, well above reach (>= 2.5 m over the floor-4 landing).
	for k in range(5):
		c = G(x0 + 2.85 + k * 0.45, 2.95 + rng.uniform(0, 0.25), -0.3 - rng.uniform(0, 0.4))
		rock(part, c, rng.uniform(0.14, 0.22), rng, "W1Concrete", flat=0.5)


def collapse(steps, part, well):
	"""Fire stairs: the flight from floor 2 to floor 1 is down. Its top 1.6 m still hangs from the floor-2 landing,
	buried under debris jammed in the Collapse box (x 44..46.5, y -6.6..-4.6, z -4.2..0); the rest lies broken on the
	ground floor."""
	x0 = well.x0
	build_flight(steps, x0 + 0.12, x0 + 2.28, 0.0, -4.8, -6.6, -8.25, wall_x=x0, stop=0.4, broken=True, seed=3)
	rng = random.Random(250)
	# A slab of the fallen flight wedged from the broken end of flight 2A down to the back wall: the pile rests
	# on it and on the stub.
	tilt = Matrix.Translation(G(x0 + 1.2, -7.75, -3.0)) @ Matrix.Rotation(math.radians(-28), 4, "X")
	part.box("W1Concrete", (-1.05, -1.25, -0.12), (1.05, 1.25, 0.1), bevel=0.02, matrix=tilt)
	part.box("W1Terrazzo", (-1.05, -1.25, 0.1), (1.05, 1.25, 0.13), matrix=tilt)
	# Debris jammed in the box, its face towards the floor-2 landing (z 0) a wall of chunks up past eye height,
	# its top under flight 3A's soffit; never past the box's walkable neighbours (the landing at z > 0, flight 3B
	# at x > 46.72).
	def low(z):
		return ramp_at(z, 0.0, -4.8, -6.6, -8.25) if z > -1.9 else -7.3 - (abs(z) - 1.9) * 0.4

	def high(z):
		return min(-4.72, ramp_at(z, 0.0, -4.8, -3.3, -4.95) - WAIST - 0.14)
	heap(part, rng, x0 + 0.12, x0 + 2.45, -0.02, -4.15, low, high, front=0.0, well_x=x0 + 2.47)
	for k in range(12):
		# Bars stick out of the debris towards the corridor wall side, never over flight 3B or the landing.
		p0 = G(x0 + rng.uniform(0.3, 1.6), rng.uniform(-6.3, -5.1), rng.uniform(-3.8, -0.9))
		d = Vector((rng.uniform(-1, 0.1), rng.uniform(-0.2, 0.6), rng.uniform(-0.3, 0.6))).normalized()
		part.tube("W1Rebar", [p0, p0 + d * 0.4, p0 + d * 0.6 + Vector((0, 0, 0.15))], 0.007, 6)
	# Ground floor under the fallen flights: a slab at -9.93 (1 cm over the campus ground, which is what one walks
	# on), and flat pieces of the fallen flight and turn landing against the walls.
	steps.box("W1Concrete", tuple(G(x0, -9.96, -6.2)), tuple(G(x0 + 5.0, -9.93, 0.0)))
	for k in range(9):
		c = G(x0 + rng.choice([rng.uniform(0.3, 1.0), rng.uniform(4.0, 4.7)]), -9.93 + 0.06, rng.uniform(-5.9, -0.6))
		rock(part, c, rng.uniform(0.2, 0.35), rng, "W1Concrete", flat=0.25)


def spill(part, well):
	"""The Collapse box's top (y -4.6) stands up to 14 cm over flight 3A's last treads (z -3.78 .. -4.2): a low
	layer of broken concrete there gives that bump its look; its top is the box's top."""
	x0 = well.x0
	rng = random.Random(251)
	for y, za, zb in ((-4.685, -3.82, -4.14), (-4.765, -3.97, -4.17)):
		x = x0 + 0.25
		while x < x0 + 2.2:
			size = rng.uniform(0.11, 0.16)
			z = rng.uniform(zb + size, za - size)
			rock(part, G(min(x + rng.uniform(-0.04, 0.04), x0 + 2.25 - size * 1.3), y, z), size, rng, "W1Concrete", flat=0.4)
			x += 0.17


def ground(steps, well):
	"""Under the main stairs at floor 1: a slab at -9.93 instead of the campus grass."""
	x0 = well.x0
	steps.box("W1Concrete", tuple(G(x0, -9.96, -6.2)), tuple(G(x0 + 5.0, -9.93, 0.0)))


def crack(part, well):
	"""Clues/CrackStair (49, -2, -3): a crack down the outer wall over flight 4B, a cut-out strip on the plaster."""
	x = well.x0 + 5.0 - 0.0045
	quad = [G(x, -2.75, -2.75), G(x, -2.75, -3.25), G(x, -0.35, -3.25), G(x, -0.35, -2.75)]
	f = part.poly("W1Crack", quad, [(0, 1, 2, 3)], recalc=False)
	f[0].normal_update()
	if f[0].normal.dot(Vector((-1, 0, 0))) < 0:
		f[0].normal_flip()
	part.planar_uv(f, tuple(G(x, -2.75, -2.75)), tuple(Vector((0, 1, 0))), tuple(Vector((0, 0, 1))), size=(0.5, 2.4))


def main():
	kit.reset()
	kit.material("W1Terrazzo", (0.58, 0.58, 0.55), 0.45)
	kit.material("W1StairSide", (0.7, 0.68, 0.62), 0.85)
	kit.material("W1Soffit", (0.75, 0.73, 0.66), 0.9)
	kit.material("W1Groove", (0.08, 0.08, 0.08), 0.7)
	kit.material("W1StairWall", (0.8, 0.76, 0.64), 0.85)
	kit.material("W1StairDado", (0.45, 0.52, 0.48), 0.8)
	kit.material("W1OldWall", (0.5, 0.5, 0.48), 0.9)
	kit.material("W1RailWood", (0.35, 0.2, 0.1), 0.5)
	kit.material("W1RailSteel", (0.18, 0.3, 0.2), 0.5, 0.5)
	kit.material("W1Steel", (0.6, 0.6, 0.58), 0.38, 1.0)
	kit.material("W1Rebar", (0.25, 0.14, 0.08), 0.8, 0.6)
	kit.material("W1Concrete", (0.55, 0.55, 0.52), 0.9)
	kit.material("W1Crack", (0.1, 0.1, 0.1), 0.9)
	which = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else ["main", "fire"]
	sizes = {"W1StairWall": PLASTER, "W1StairDado": PLASTER, "W1Soffit": PLASTER, "W1StairSide": PLASTER,
		"W1Terrazzo": TERRAZZO}
	for side in which:
		well = Well(side)
		steps = kit.Part("Steps")
		landings = kit.Part("Landings")
		wall_part = kit.Part("Walls")
		rail_part = kit.Part("Rails")
		upper = kit.Part("Upper")
		for name, xa, xb, z0, z1, y0, y1 in well.flights:
			wall_x = well.x0 if name.endswith("A") else well.x0 + 5.0
			build_flight(steps, xa, xb, z0, z1, y0, y1, wall_x=wall_x)
		for floor in (1, 2, 3, 4):
			slab(landings, well.x0, well.x0 + 5.0, 0.0, 4.0, (floor - 4) * 3.3)
		for y in well.turns:
			slab(landings, well.x0, well.x0 + 5.0, -6.2, -4.8, y)
		walls(wall_part, well)
		rails(rail_part, well, well.flights, [])
		upper_storey(upper, upper, well)
		objs = [steps.build(uv_size=sizes), landings.build(uv_size=sizes), wall_part.build(uv_size=sizes),
			rail_part.build(uv_size=sizes), upper.build(uv_size=sizes)]
		if side == "fire":
			rubble = kit.Part("Rubble")
			collapse(rubble, rubble, well)
			objs.append(rubble.build(uv_size=sizes))
			spilled = kit.Part("Spill")
			spill(spilled, well)
			objs.append(spilled.build(uv_size=sizes))
			crack_part = kit.Part("Crack")
			crack(crack_part, well)
			objs.append(crack_part.build())
		else:
			base = kit.Part("Ground")
			ground(base, well)
			objs.append(base.build(uv_size=sizes))
		kit.export(kit.OUT / ("%s_stairs.glb" % side), objs)
		kit.reset()
		for m in ("W1Terrazzo", "W1StairSide", "W1Soffit", "W1Groove", "W1StairWall", "W1StairDado", "W1OldWall",
				"W1RailWood", "W1RailSteel", "W1Steel", "W1Rebar", "W1Concrete", "W1Crack"):
			kit.material(m)


main()
