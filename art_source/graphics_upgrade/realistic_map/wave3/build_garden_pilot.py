"""T-259 round 1: the pilot corner round Ngư's bench (Bed1_1, Bed2_1, NguBench, the paving, one garden lamp) with the
options the owner picks from. Blender 5.2.2, bmesh/mesh data only, no add-on, no Tripo.

  tree_plumeria.glb      option T1 hoa sứ / hoa đại (Plumeria obtusa)
  tree_mantaly.glb       option T2 bàng Đài Loan (Terminalia mantaly)
  tree_lagerstroemia.glb option T3 bằng lăng (Lagerstroemia speciosa)
      each: Bark + Leaves (near) and BarkFar + LeavesFar (far, for visibility_range); origin = paving level at the
      trunk (Godot y -9.9), so heights below are metres above the paving.
  beds_pilot.glb         the two beds' kerbs and soil, in garden space (origin = Godot (0, -9.9, 0))
  planting_a.glb         option F1: trimmed golden Duranta (chuỗi ngọc) border + four Ixora (trang đỏ) shrubs
  planting_b.glb         option F2: four Cuphea (cẩm tú mai) mounds + twelve periwinkle (dừa cạn) clumps, grass
  paving_block.glb       option P1: gạch block con sâu; paving_red.glb  option P2: gạch đỏ lá dừa (garden space)
  bench_ngu.glb          Ngư's terrazzo bench (origin at its centre on the paving)
  garden_lamp.glb        cast-iron garden lamp with an opal globe round the old light point (globe centre 2.9 m)

Gameplay contract (T-251): every tree part lower than 2 m above the paving lies inside its LowCrown's
CanopyCollision cone (radius 1.1 m at 1.2 m, 0.175 m at 2.8 m); below 1.2 m only the trunk (radius <= 0.13 m, as the
PS1 trunk). The cone is an octagon: the check uses its inscribed circle, so any turn of the tree fits.
check_canopy() prints the margin; leaves that would break it are not added.
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave3/build_garden_pilot.py [-- name ...]
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
import w1kit  # noqa: E402

ROOT = HERE.parents[3]
OUT = ROOT / "game/assets/models/graphics_pilot/realistic_map/wave3"
UP = Vector((0, 0, 1))
PLASTER = 2.0
TERRAZZO = 1.0
BARK_TILE = 0.4

# CanopyShape of garden.tscn in tree space (Blender z = metres above the paving).
CONE_BOTTOM, CONE_TOP, R_BOTTOM, R_TOP = 1.2, 2.8, 1.1, 0.175
FREE_HEIGHT = 2.0  # above this the crown may be wider than the collision (card section 4)


def cone_radius(z):
	"""The canopy is an octagonal frustum (corners at R): use its inscribed circle, so a tree turned any way about
	its trunk still fits."""
	t = (z - CONE_BOTTOM) / (CONE_TOP - CONE_BOTTOM)
	return (R_BOTTOM + (R_TOP - R_BOTTOM) * t) * math.cos(math.pi / 8)


def allowed(co, trunk_r=0.13):
	"""True if a tree vertex keeps the T-251 contract."""
	if co.z >= FREE_HEIGHT:
		return True
	r = math.hypot(co.x, co.y)
	if co.z < CONE_BOTTOM:
		return r <= trunk_r
	return r <= cone_radius(co.z) - 0.01


# ---------------------------------------------------------------------------------------------- mesh buffer

class Buf:
	"""Plain vertex/face lists with per-vertex UV and (optional) custom normals; one material slot list."""

	def __init__(self, name):
		self.name = name
		self.v, self.uv, self.n, self.f, self.fm = [], [], [], [], []
		self.slots = []

	def slot(self, mat):
		if mat not in self.slots:
			self.slots.append(mat)
		return self.slots.index(mat)

	def vert(self, co, uv, n):
		self.v.append(Vector(co))
		self.uv.append(uv)
		self.n.append(Vector(n).normalized())
		return len(self.v) - 1

	def face(self, idx, mat):
		self.f.append(tuple(idx))
		self.fm.append(self.slot(mat))

	def tris(self):
		return sum(len(f) - 2 for f in self.f)

	def build(self, collection=None):
		mesh = bpy.data.meshes.new(self.name)
		mesh.from_pydata([tuple(v) for v in self.v], [], self.f)
		uv = mesh.uv_layers.new(name="UVMap")
		for poly in mesh.polygons:
			poly.material_index = self.fm[poly.index]
			poly.use_smooth = True
			for li in poly.loop_indices:
				uv.data[li].uv = self.uv[mesh.loops[li].vertex_index]
		mesh.update()
		mesh.normals_split_custom_set_from_vertices([tuple(n) for n in self.n])
		for name in self.slots:
			mesh.materials.append(w1kit.material(name, *PREVIEW.get(name, ((0.5, 0.5, 0.5), 0.8))))
		obj = bpy.data.objects.new(self.name, mesh)
		(collection or bpy.context.scene.collection).objects.link(obj)
		return obj


PREVIEW = {"W3BarkPlumeria": ((0.45, 0.44, 0.4), 0.8), "W3BarkMantaly": ((0.36, 0.32, 0.28), 0.85),
	"W3BarkLager": ((0.55, 0.52, 0.46), 0.7), "W3LeafPlumeria": ((0.16, 0.3, 0.1), 0.6),
	"W3LeafMantaly": ((0.2, 0.36, 0.11), 0.6), "W3LeafLager": ((0.17, 0.31, 0.11), 0.6),
	"W3Shrubs": ((0.2, 0.35, 0.1), 0.6), "W3ShrubCore": ((0.04, 0.08, 0.03), 0.9), "W3Hedge": ((0.4, 0.5, 0.12), 0.7),
	"W3Soil": ((0.15, 0.11, 0.08), 0.95), "W3Kerb": ((0.8, 0.74, 0.55), 0.8), "W3PavingBlock": ((0.5, 0.49, 0.46), 0.9),
	"W3PavingRed": ((0.55, 0.26, 0.16), 0.85), "W3Bench": ((0.6, 0.6, 0.57), 0.5), "W3LampPaint": ((0.1, 0.18, 0.12), 0.5),
	"W3LampGlobe": ((0.95, 0.94, 0.85), 0.2), "W1Concrete": ((0.52, 0.51, 0.47), 0.9)}


def frame(direction):
	"""Two unit vectors perpendicular to `direction`."""
	d = direction.normalized()
	side = d.cross(UP)
	if side.length < 1e-4:
		side = d.cross(Vector((1, 0, 0)))
	side.normalize()
	return side, side.cross(d).normalized()


def tube(buf, mat, pts, radii, sides, cap_tip=True):
	"""A tapered round tube along points; UV in metres (u round the bark, v along it); smooth radial normals."""
	pts = [Vector(p) for p in pts]
	rings = []
	prev = None
	length = 0.0
	for i, p in enumerate(pts):
		ahead = (pts[min(i + 1, len(pts) - 1)] - pts[max(i - 1, 0)]).normalized()
		side, up = frame(ahead)
		if prev is not None:
			# Parallel transport keeps the seam from twisting.
			side = (prev - ahead * prev.dot(ahead)).normalized()
			up = side.cross(ahead).normalized()
		prev = side
		if i > 0:
			length += (p - pts[i - 1]).length
		ring = []
		circ = math.tau * radii[0]
		for k in range(sides + 1):
			a = k / sides * math.tau
			nrm = side * math.cos(a) + up * math.sin(a)
			ring.append(buf.vert(p + nrm * radii[i], (k / sides * circ, length), nrm))
		rings.append(ring)
	for a, b in zip(rings, rings[1:]):
		for k in range(sides):
			buf.face((a[k], b[k], b[k + 1], a[k + 1]), mat)
	if cap_tip:
		d = (pts[-1] - pts[-2]).normalized()
		tip = buf.vert(pts[-1] + d * radii[-1] * 0.6, (0.0, length + radii[-1]), d)
		for k in range(sides):
			buf.face((rings[-1][k + 1], rings[-1][k], tip), mat)


def card(buf, mat, origin, up_axis, normal, width, height, cell, base=0.0, bend=0.0, radial_from=None, normal_mix=0.55):
	"""A textured quad (2 x 2 vertices, or 3 rows when bent): `origin` is the card's bottom centre (or `base`
	fraction up from it), `up_axis` runs from the texture's bottom to its top. UV cell = (u0, v0, u1, v1).
	Normals blend the card normal with the direction from `radial_from` (crown centre) for soft foliage."""
	up_axis = up_axis.normalized()
	normal = (normal - up_axis * normal.dot(up_axis)).normalized()
	side = up_axis.cross(normal).normalized()
	u0, v0, u1, v1 = cell
	rows = 3 if bend else 2
	idx = []
	start = Vector(origin) - up_axis * height * base
	for r in range(rows):
		t = r / (rows - 1)
		row = []
		for c in range(2):
			s = c * 2 - 1
			co = start + up_axis * height * t + side * width * 0.5 * s + normal * bend * 4 * t * (1 - t) * height * 0
			co = co - UP * bend * height * t * t
			n = normal
			if radial_from is not None:
				radial = (co - Vector(radial_from))
				if radial.length > 1e-4:
					n = (normal * (1 - normal_mix) + radial.normalized() * normal_mix).normalized()
					if n.dot(normal) < 0:
						n = (n + normal * 0.6).normalized()
			row.append(buf.vert(co, (u0 + (u1 - u0) * c, v0 + (v1 - v0) * t), n))
		idx.append(row)
	for a, b in zip(idx, idx[1:]):
		buf.face((a[0], a[1], b[1], b[0]), mat)
	return [i for row in idx for i in row]


def leaf_blade(buf, mat, base, direction, width_axis, length, width, cell, fold=0.012, droop=0.05, radial_from=None):
	"""A long leaf as 3 x 3 vertices: folded along its midrib, arching and drooping (plumeria)."""
	d = direction.normalized()
	w = (width_axis - d * width_axis.dot(d)).normalized()
	nrm = w.cross(d).normalized()
	if nrm.z < 0:
		nrm, w = -nrm, -w
	u0, v0, u1, v1 = cell
	rows = []
	for r, t in enumerate((0.0, 0.5, 1.0)):
		centre = Vector(base) + d * length * t + nrm * 0.03 * length * math.sin(t * math.pi) - UP * droop * t * t
		row = []
		for c, s in enumerate((-1.0, 0.0, 1.0)):
			co = centre + w * width * 0.5 * s + nrm * (fold if s == 0 else 0.0) * math.sin(t * math.pi + 0.3)
			n = nrm
			if radial_from is not None:
				radial = co - Vector(radial_from)
				if radial.length > 1e-4:
					n = (nrm * 0.45 + radial.normalized() * 0.55).normalized()
			row.append(buf.vert(co, (u0 + (u1 - u0) * (c / 2), v0 + (v1 - v0) * t), n))
		rows.append(row)
	verts = [buf.v[i] for row in rows for i in row]
	return rows, verts


def commit_blade(buf, mat, rows):
	for a, b in zip(rows, rows[1:]):
		buf.face((a[0], a[1], b[1], b[0]), mat)
		buf.face((a[1], a[2], b[2], b[1]), mat)


def rotate_toward(d, azimuth, angle):
	"""Tilts direction d by `angle` towards the horizontal azimuth (radians)."""
	side, up = frame(d)
	axis_dir = side * math.cos(azimuth) + up * math.sin(azimuth)
	return (d * math.cos(angle) + axis_dir * math.sin(angle)).normalized()


# ---------------------------------------------------------------------------------------------- trees

def plumeria(rng):
	"""Thick grey dichotomous branches, rosettes of long leaves at the blunt tips, white flowers on some tips."""
	bark, leaves = Buf("Bark"), Buf("Leaves")
	far_bark, far_leaves = Buf("BarkFar"), Buf("LeavesFar")
	segs, tips = [], []
	trunk = [Vector((0, 0, 0.38)), Vector((0.01, 0.01, 0.8)), Vector((0.02, 0.0, 1.2)), Vector((0.03, 0.01, 1.42))]
	segs.append((trunk, [0.115, 0.105, 0.1, 0.095], 0))
	max_level = 4

	def branch(start, direction, radius, level):
		length = rng.uniform(0.42, 0.6) * (1.0 if level < 3 else 0.85)
		pts = [Vector(start)]
		d = Vector(direction)
		for k in range(3):
			d = (d + UP * 0.07 + Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), 0)) * 0.04).normalized()
			pts.append(pts[-1] + d * length / 3)
		radii = [radius, radius * 0.96, radius * 0.92, radius * 0.88]
		segs.append((pts, radii, level))
		if level == max_level or (level >= 3 and rng.random() < 0.12):
			tips.append((pts[-1], d))
			return
		count = 3 if rng.random() < 0.32 else 2
		az0 = rng.uniform(0, math.tau)
		for c in range(count):
			spread = rng.uniform(0.32, 0.5) if level < 2 else rng.uniform(0.4, 0.62)
			child = rotate_toward(d, az0 + c * math.tau / count + rng.uniform(-0.3, 0.3), spread)
			branch(pts[-1] - d * 0.03, child, radius * 0.83, level + 1)

	for c in range(3):
		d = rotate_toward(UP, c * math.tau / 3 + rng.uniform(-0.2, 0.2), rng.uniform(0.3, 0.42))
		branch(trunk[-1] - UP * 0.04, d, 0.08, 1)
	for pts, radii, level in segs:
		tube(bark, "W3BarkPlumeria", pts, radii, 9 if level == 0 else (7 if level < 2 else (6 if level < 3 else 5)))
		if level <= 2:
			tube(far_bark, "W3BarkPlumeria", [pts[0], pts[-1]], [radii[0], radii[-1]], 5)
	centre = Vector((0, 0, 2.6))
	cols = [(0.0, 0.25), (0.25, 0.5), (0.5, 0.75), (0.75, 1.0)]
	added = dropped = 0
	for pos, d in tips:
		count = int(rng.integers(12, 17))  # round 2 (D-175): 12-16 leaves a rosette keeps the garden near 88k triangles
		for k in range(count):
			az = k / count * math.tau + rng.uniform(-0.2, 0.2)
			side, up = frame(d)
			horiz = (side * math.cos(az) + up * math.sin(az))
			elev = rng.uniform(0.25, 1.15)  # radians above the plane across the tip
			direction = (horiz * math.cos(elev) + d * math.sin(elev)).normalized()
			length = rng.uniform(0.25, 0.36)
			roll = rng.random()
			col = cols[0] if roll < 0.6 else cols[1] if roll < 0.82 else cols[2] if roll < 0.91 else cols[3]
			cell = (col[0], 0.5 + 0.5 * (1 - 505 / 512), col[1], 0.5 + 0.5 * (1 - 25 / 512))
			rows, verts = leaf_blade(leaves, "W3LeafPlumeria", pos + d * 0.01, direction, horiz.cross(d),
				length * 480 / 470, length * 0.29 * 256 / 150, cell, droop=rng.uniform(0.02, 0.08), radial_from=centre)
			if all(allowed(v) for v in verts):
				commit_blade(leaves, "W3LeafPlumeria", rows)
				added += 1
			else:
				dropped += 1
		if rng.random() < 0.6:
			# A flower cluster on a stalk standing out of the rosette (two crossed cards).
			for k in range(2):
				nrm = rotate_toward(Vector((1, 0, 0)), 0, 0)
				nrm = Vector((math.cos(k * math.pi / 2 + 0.4), math.sin(k * math.pi / 2 + 0.4), 0))
				card(leaves, "W3LeafPlumeria", pos + d * 0.02, (d + UP).normalized(), nrm, 0.3, 0.3,
					(0.0, 0.0, 0.5, 0.5), radial_from=centre, normal_mix=0.3)
		# Far: one fan card across each tip.
		for k in range(2):
			nrm = Vector((math.cos(k * math.pi / 2), math.sin(k * math.pi / 2), 0))
			card(far_leaves, "W3LeafPlumeria", pos - d * 0.05, d, nrm, 0.7, 0.42, (0.5, 0.0, 1.0, 0.5),
				radial_from=centre)
	print("T259_PLUMERIA tips %d leaves %d dropped %d" % (len(tips), added, dropped))
	return [bark, leaves, far_bark, far_leaves]


def mantaly(rng):
	"""A straight trunk with whorled horizontal tiers of branches; leaf rosettes as flat plates on each tier."""
	bark, leaves = Buf("Bark"), Buf("Leaves")
	far_bark, far_leaves = Buf("BarkFar"), Buf("LeavesFar")
	top = 5.0
	trunk = [Vector((0.01 * math.sin(z * 3), 0.01 * math.cos(z * 2), z)) for z in [0.38 + i * (top - 0.38) / 9 for i in range(10)]]
	radii = [0.105 - 0.065 * i / 9 for i in range(10)]
	tube(bark, "W3BarkMantaly", trunk, radii, 8)
	tube(far_bark, "W3BarkMantaly", [trunk[0], trunk[-1]], [radii[0], radii[-1]], 5)
	tiers = [(2.2, 1.85), (2.75, 1.65), (3.28, 1.45), (3.78, 1.2), (4.22, 0.95), (4.6, 0.72), (4.9, 0.45)]
	centre = Vector((0, 0, 3.4))
	az_off = rng.uniform(0, math.tau)
	for t, (z, reach) in enumerate(tiers):
		count = 5 if t < 4 else 4
		az_off += 0.6
		for b in range(count):
			az = az_off + b * math.tau / count + rng.uniform(-0.25, 0.25)
			out = Vector((math.cos(az), math.sin(az), 0))
			L = reach * rng.uniform(0.85, 1.05)
			pts = [Vector((0, 0, z)), Vector((0, 0, z)) + out * L * 0.35 + UP * 0.03,
				Vector((0, 0, z)) + out * L * 0.7 + UP * 0.07, Vector((0, 0, z)) + out * L + UP * 0.14]
			tube(bark, "W3BarkMantaly", pts, [0.032 * (1.1 - t * 0.08), 0.024, 0.016, 0.01], 5)
			# Plates of rosettes along the outer two thirds, slightly tilted, and one side-view card.
			for k in range(7):
				f = 0.22 + k * 0.13
				at = Vector((0, 0, z)) + out * L * f + UP * (0.05 + 0.1 * f * f) + out.cross(UP) * rng.uniform(-0.12, 0.12)
				size = rng.uniform(0.72, 0.95) * (1.0 - 0.3 * (t / 6))
				tilt = Vector((rng.uniform(-0.18, 0.18), rng.uniform(-0.18, 0.18), 1)).normalized()
				spin = rng.uniform(0, math.tau)
				up_axis = Vector((math.cos(spin), math.sin(spin), 0))
				up_axis = (up_axis - tilt * up_axis.dot(tilt)).normalized()
				cell = (0.0, 0.5, 0.5, 1.0) if rng.random() < 0.5 else (0.5, 0.5, 1.0, 1.0)
				card(leaves, "W3LeafMantaly", at, up_axis, tilt, size, size, cell, base=0.5, radial_from=centre, normal_mix=0.35)
				if k % 3 == 0:
					card(far_leaves, "W3LeafMantaly", at, up_axis, tilt, size * 1.5, size * 1.5, cell, base=0.5,
						radial_from=centre, normal_mix=0.35)
			side_n = out.cross(UP).normalized()
			card(leaves, "W3LeafMantaly", Vector((0, 0, z)) + out * L * 0.65 + UP * 0.08, out, side_n, 0.3, L * 0.75,
				(0.0, 0.0, 0.5, 0.5), base=0.5, radial_from=centre, normal_mix=0.3)
	# A small leader rosette at the top.
	for k in range(2):
		nrm = Vector((math.cos(k * math.pi / 2), math.sin(k * math.pi / 2), 0))
		card(leaves, "W3LeafMantaly", Vector((0, 0, top - 0.25)), UP, nrm, 0.45, 0.45, (0.5, 0.0, 1.0, 0.5), radial_from=centre)
	return [bark, leaves, far_bark, far_leaves]


def lagerstroemia(rng):
	"""Short trunk forking into three steep limbs, a rounded crown of leafy twig cards, purple panicles on top."""
	bark, leaves = Buf("Bark"), Buf("Leaves")
	far_bark, far_leaves = Buf("BarkFar"), Buf("LeavesFar")
	trunk = [Vector((0, 0, 0.38)), Vector((0.005, 0.0, 0.9)), Vector((0.01, 0.005, 1.4)), Vector((0.01, 0.005, 1.55))]
	tube(bark, "W3BarkLager", trunk, [0.12, 0.11, 0.1, 0.095], 9)
	tube(far_bark, "W3BarkLager", [trunk[0], trunk[-1]], [0.12, 0.095], 5)
	ends = []
	for c in range(3):
		d = rotate_toward(UP, c * math.tau / 3 + rng.uniform(-0.25, 0.25), rng.uniform(0.28, 0.36))
		pts = [trunk[-1] - UP * 0.05]
		for k in range(4):
			d = (d + Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), 0.3)) * 0.06).normalized()
			pts.append(pts[-1] + d * 0.42)
		tube(bark, "W3BarkLager", pts, [0.07, 0.062, 0.055, 0.048, 0.042], 7)
		tube(far_bark, "W3BarkLager", [pts[0], pts[-1]], [0.07, 0.042], 5)
		for s in range(4):
			start = pts[2 + s % 3]
			sd = rotate_toward(d, rng.uniform(0, math.tau), rng.uniform(0.5, 0.9))
			sp = [start]
			for k in range(3):
				sd = (sd + UP * 0.05 + Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), 0)) * 0.08).normalized()
				sp.append(sp[-1] + sd * rng.uniform(0.25, 0.4))
			tube(bark, "W3BarkLager", sp, [0.032, 0.026, 0.02, 0.014], 5)
			ends.append(sp[-1])
		ends.append(pts[-1])
	centre = Vector((0, 0, 3.45))
	radii = Vector((2.0, 2.0, 1.25))
	added = dropped = 0
	for i in range(260):
		# Points on and inside the crown ellipsoid, denser towards the shell.
		u, v = rng.uniform(0, math.tau), math.acos(rng.uniform(-0.85, 1.0))
		r = rng.uniform(0.62, 1.0) ** 0.5
		dirn = Vector((math.sin(v) * math.cos(u), math.sin(v) * math.sin(u), math.cos(v)))
		at = centre + Vector((dirn.x * radii.x, dirn.y * radii.y, dirn.z * radii.z)) * r
		out = (at - centre).normalized()
		up_axis = (out + UP * 0.4 + Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), rng.uniform(-1, 1))) * 0.3).normalized()
		nrm = up_axis.cross(Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), rng.uniform(-1, 1)))).normalized()
		size = rng.uniform(0.5, 0.72)
		roll = rng.random()
		cell = (0.0, 0.5, 0.5, 1.0) if roll < 0.48 else (0.5, 0.5, 1.0, 1.0) if roll < 0.96 else (0.5, 0.0, 1.0, 0.5)
		before = len(leaves.v)
		idx = card(leaves, "W3LeafLager", at - up_axis * size * 0.35, up_axis, nrm, size, size, cell,
			radial_from=centre, normal_mix=0.6)
		if all(allowed(leaves.v[j]) for j in idx):
			added += 1
			if i % 3 == 0:
				far_before = len(far_leaves.v)
				idx = card(far_leaves, "W3LeafLager", at - up_axis * size * 0.5, up_axis, nrm, size * 1.6, size * 1.6, cell,
					radial_from=centre, normal_mix=0.6)
				if not all(allowed(far_leaves.v[j]) for j in idx):
					del far_leaves.v[far_before:], far_leaves.uv[far_before:], far_leaves.n[far_before:]
					far_leaves.f.pop()
					far_leaves.fm.pop()
		else:
			del leaves.v[before:], leaves.uv[before:], leaves.n[before:]
			leaves.f.pop()
			leaves.fm.pop()
			dropped += 1
	# Panicles stand out of the crown's upper half.
	for k in range(16):
		u = rng.uniform(0, math.tau)
		v = rng.uniform(0.15, 0.95)
		dirn = Vector((math.sin(v) * math.cos(u), math.sin(v) * math.sin(u), math.cos(v)))
		at = centre + Vector((dirn.x * radii.x, dirn.y * radii.y, dirn.z * radii.z)) * 0.92
		up_axis = (dirn + UP * 1.5).normalized()
		for c in range(2):
			nrm = Vector((math.cos(u + c * math.pi / 2), math.sin(u + c * math.pi / 2), 0))
			card(leaves, "W3LeafLager", at - up_axis * 0.08, up_axis, nrm, 0.32, 0.38, (0.0, 0.0, 0.5, 0.5),
				radial_from=centre, normal_mix=0.4)
	print("T259_LAGER cards %d dropped %d" % (added, dropped))
	return [bark, leaves, far_bark, far_leaves]


def check_canopy(name, bufs):
	worst = 9.0
	bad = 0
	for buf in bufs:
		for v in buf.v:
			if v.z >= FREE_HEIGHT:
				continue
			r = math.hypot(v.x, v.y)
			limit = 0.13 if v.z < CONE_BOTTOM else cone_radius(v.z)
			worst = min(worst, limit - r)
			if r > limit:
				bad += 1
	print("T259_CANOPY %s below 2 m: %d vertices outside, smallest margin %.3f m" % (name, bad, worst))
	return bad


def export_bufs(path, bufs):
	objs = [b.build() for b in bufs if b.v]
	w1kit.export(path, objs)
	for b in bufs:
		print("T259_PART %s %s %d tris" % (Path(path).name, b.name, b.tris()))


def build_trees():
	for name, fn, seed in (("plumeria", plumeria, 1), ("mantaly", mantaly, 2), ("lagerstroemia", lagerstroemia, 3)):
		w1kit.reset()
		import numpy as np
		rng = np.random.default_rng(259_100 + seed)
		bufs = fn(rng)
		if check_canopy(name, bufs):
			raise SystemExit("canopy contract broken: " + name)
		export_bufs(OUT / f"tree_{name}.glb", bufs)


# ---------------------------------------------------------------------------------------------- beds

PILOT_BEDS = {"1_1": (22.0, 22.0), "2_1": (22.0, 32.0)}  # Godot (x, z) of Bed1_1 and Bed2_1
BED_HALF = (3.0, 2.0)
KERB = 0.12
TOP = 0.5
SOIL = 0.44


def g2b(x, z, y=0.0):
	"""Godot garden coordinates (y above the paving) to Blender."""
	return Vector((x, -z, y))


def kerb_uv2(row):
	def fn(co, cx, cy):
		lx, ly = co.x - cx, co.y - cy
		hx, hy = BED_HALF
		# Position round the perimeter, starting at the (-x, +y) corner, clockwise seen from above.
		if abs(ly - hy) <= KERB + 0.01 and abs(lx) <= hx:
			s = lx + hx
		elif abs(lx - hx) <= KERB + 0.01:
			s = 6.0 + (hy - ly)
		elif abs(ly + hy) <= KERB + 0.01:
			s = 10.0 + (hx - lx)
		else:
			s = 16.0 + (ly + hy)
		u = min(max(s / 20.0, 0.0), 1.0)
		inner = abs(lx) < hx - KERB + 0.004 and abs(ly) < hy - KERB + 0.004
		if co.z > TOP - 0.004:
			edge = min(hx - abs(lx), hy - abs(ly))
			v = 0.735 + min(edge / KERB, 1.0) * 0.177
		elif inner:
			v = 0.912 + min((TOP - co.z) / 0.06, 1.0) * 0.088
		else:
			v = co.z / TOP * 0.735
		image_y = row * 85 + (1.0 - v) * 84 + 0.5
		return (u, 1.0 - image_y / 1024.0)
	return fn


def build_beds():
	w1kit.reset()
	objs = []
	for key, (gx, gz) in PILOT_BEDS.items():
		i, j = (int(k) for k in key.split("_"))
		row = i * 3 + j
		centre = g2b(gx, gz)
		hx, hy = BED_HALF
		part = w1kit.Part("Kerb_" + key)
		faces = []
		faces += part.box("W3Kerb", (centre.x - hx, centre.y + hy - KERB, 0), (centre.x + hx, centre.y + hy, TOP), bevel=0.012, segments=2)
		faces += part.box("W3Kerb", (centre.x - hx, centre.y - hy, 0), (centre.x + hx, centre.y - hy + KERB, TOP), bevel=0.012, segments=2)
		faces += part.box("W3Kerb", (centre.x - hx, centre.y - hy + KERB, 0), (centre.x - hx + KERB, centre.y + hy - KERB, TOP), bevel=0.012, segments=2)
		faces += part.box("W3Kerb", (centre.x + hx - KERB, centre.y - hy + KERB, 0), (centre.x + hx, centre.y + hy - KERB, TOP), bevel=0.012, segments=2)
		fn = kerb_uv2(row)
		part.set_uv2(faces, lambda co, fn=fn, cx=centre.x, cy=centre.y: fn(co, cx, cy))
		objs.append(part.build(uv_size={"W3Kerb": PLASTER}))
		# Soil: a gently mounded grid inside the kerb.
		soil = w1kit.Part("Soil_" + key)
		nx, ny = 14, 9
		ix, iy = hx - KERB, hy - KERB
		verts, quads = [], []
		rnd = random.Random(row)
		for b in range(ny + 1):
			for a in range(nx + 1):
				x = -ix + 2 * ix * a / nx
				y = -iy + 2 * iy * b / ny
				edge = min(ix - abs(x), iy - abs(y))
				z = SOIL + 0.035 * min(edge / 0.6, 1.0) + (rnd.uniform(-0.008, 0.008) if 0 < a < nx and 0 < b < ny else 0)
				verts.append((centre.x + x, centre.y + y, z))
		for b in range(ny):
			for a in range(nx):
				k = b * (nx + 1) + a
				quads.append((k, k + 1, k + nx + 2, k + nx + 1))
		soil.poly("W3Soil", verts, quads, recalc=False)
		objs.append(soil.build(uv_size={"W3Soil": 0.8}))
	w1kit.export(OUT / "beds_pilot.glb", objs)


def shrub_cards(buf, rng, centre, radius, height, count, cells, core=False, normal_mix=0.6, size=(0.32, 0.45)):
	"""A rounded shrub: cards whose bottom-to-top runs outward from the shrub's centre, plus a dark core."""
	c = Vector(centre)
	mid = c + UP * height * 0.45
	for k in range(count):
		u, v = rng.uniform(0, math.tau), math.acos(rng.uniform(-0.2, 1.0))
		dirn = Vector((math.sin(v) * math.cos(u), math.sin(v) * math.sin(u), math.cos(v)))
		at = mid + Vector((dirn.x * radius, dirn.y * radius, dirn.z * height * 0.55)) * rng.uniform(0.35, 0.8)
		up_axis = (dirn + UP * 0.5).normalized()
		nrm = up_axis.cross(Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), rng.uniform(-1, 1)))).normalized()
		s = rng.uniform(*size)
		card(buf, "W3Shrubs", at - up_axis * s * 0.45, up_axis, nrm, s, s, cells[int(rng.integers(0, len(cells)))],
			radial_from=mid, normal_mix=normal_mix)
	if core:
		# Low dome of dark leaves under the cards, so the shrub reads solid.
		ring = []
		for k in range(8):
			a = k / 8 * math.tau
			ring.append(buf.vert(c + Vector((math.cos(a) * radius * 0.75, math.sin(a) * radius * 0.75, 0.02)), (0, 0),
				Vector((math.cos(a), math.sin(a), 0.6))))
		ring2 = []
		for k in range(8):
			a = (k + 0.5) / 8 * math.tau
			ring2.append(buf.vert(c + Vector((math.cos(a) * radius * 0.5, math.sin(a) * radius * 0.5, height * 0.55)), (0, 0),
				Vector((math.cos(a), math.sin(a), 1.2))))
		top = buf.vert(c + UP * height * 0.7, (0, 0), UP)
		for k in range(8):
			buf.face((ring[k], ring[(k + 1) % 8], ring2[k]), "W3ShrubCore")
			buf.face((ring[(k + 1) % 8], ring2[(k + 1) % 8], ring2[k]), "W3ShrubCore")
			buf.face((ring2[k], ring2[(k + 1) % 8], top), "W3ShrubCore")


def shrub_cell(col, row):
	"""UV rectangle of shrubs.png's cell (col, row) counted from the image's top-left, 4 x 4."""
	return (col * 0.25, 1.0 - (row + 1) * 0.25, (col + 1) * 0.25, 1.0 - row * 0.25)


SHRUB_SPOTS = [(-1.9, 0.6), (-0.8, -0.95), (1.0, 0.8), (2.0, -0.65)]


def build_plantings():
	import numpy as np
	for option in ("a", "b"):
		w1kit.reset()
		bufs = []
		for key, (gx, gz) in PILOT_BEDS.items():
			rng = np.random.default_rng(259_200 + (1 if option == "a" else 2) * 10 + int(key[0]))
			centre = g2b(gx, gz)
			buf = Buf("Planting_" + key)
			hedge = w1kit.Part("Hedge_" + key) if option == "a" else None
			ix, iy = BED_HALF[0] - KERB, BED_HALF[1] - KERB
			if option == "a":
				# A trimmed hedge band just inside the kerb, 0.26 m wide, its top 0.36 m over the soil.
				w, h = 0.26, 0.36
				z0, z1 = SOIL - 0.02, SOIL + h
				boxes = [((-ix, iy - w), (ix, iy)), ((-ix, -iy), (ix, -iy + w)), ((-ix, -iy + w), (-ix + w, iy - w)),
					((ix - w, -iy + w), (ix, iy - w))]
				for (ax, ay), (bx, by) in boxes:
					hedge.box("W3Hedge", (centre.x + ax, centre.y + ay, z0), (centre.x + bx, centre.y + by, z1), bevel=0.07, segments=2)
				# Ragged leafy layer over the flat clipped top (two rows of near-flat cards), then a fringe on the edges.
				for (ax, ay), (bx, by) in boxes:
					length = max(bx - ax, by - ay)
					along = Vector((1, 0, 0)) if bx - ax > by - ay else Vector((0, 1, 0))
					across = Vector((0, 1, 0)) if along.x else Vector((1, 0, 0))
					n = int(length / 0.2)
					for k in range(n):
						for row in (-0.25, 0.25):
							t = (k + rng.uniform(0.1, 0.9)) / n
							mid = Vector(((ax + bx) * 0.5, (ay + by) * 0.5, 0))
							at = centre + mid + along * (t - 0.5) * length + across * row * w + UP * (z1 + 0.005)
							tilt = Vector((rng.uniform(-0.3, 0.3), rng.uniform(-0.3, 0.3), 1)).normalized()
							spin = rng.uniform(0, math.tau)
							up_axis = Vector((math.cos(spin), math.sin(spin), 0))
							up_axis = (up_axis - tilt * up_axis.dot(tilt)).normalized()
							card(buf, "W3Shrubs", at, up_axis, tilt, 0.3, 0.3, shrub_cell(int(rng.integers(0, 2)), 0), base=0.5,
								radial_from=at - UP * 0.4, normal_mix=0.3)
				for (ax, ay), (bx, by) in boxes:
					length = max(bx - ax, by - ay)
					along = Vector((1, 0, 0)) if bx - ax > by - ay else Vector((0, 1, 0))
					n = int(length / 0.22)
					for k in range(n):
						t = (k + rng.uniform(0.2, 0.8)) / n
						at = centre + Vector((ax + (bx - ax) * (t if along.x else 0.5), ay + (by - ay) * (t if along.y else 0.5), z1 - 0.05))
						tilt = Vector((rng.uniform(-0.5, 0.5), rng.uniform(-0.5, 0.5), 1)).normalized()
						nrm = along.cross(tilt).normalized()
						card(buf, "W3Shrubs", at, tilt, nrm, 0.26, 0.16, shrub_cell(int(rng.integers(0, 2)), 0),
							radial_from=at - UP * 0.3, normal_mix=0.5)
				# Four Ixora shrubs with red flower balls (three each: the PS1 bed's twelve flower clumps).
				for sx, sy in SHRUB_SPOTS:
					base = centre + Vector((sx * 0.92, sy * 0.85, SOIL))
					shrub_cards(buf, rng, base, 0.42, 0.75, 40, [shrub_cell(2, 0), shrub_cell(3, 0)], size=(0.38, 0.52))
					for k in range(3):
						a = k / 3 * math.tau + rng.uniform(-0.4, 0.4)
						at = base + Vector((math.cos(a) * 0.2, math.sin(a) * 0.2, 0.62 + rng.uniform(-0.05, 0.08)))
						for c in range(2):
							nrm = Vector((math.cos(a + c * math.pi / 2), math.sin(a + c * math.pi / 2), 0.3)).normalized()
							card(buf, "W3Shrubs", at - UP * 0.1, (UP + Vector((math.cos(a), math.sin(a), 0)) * 0.4).normalized(),
								nrm, 0.24, 0.24, shrub_cell(int(rng.integers(0, 2)), 1), radial_from=base + UP * 0.3, normal_mix=0.4)
			else:
				# Four Cuphea mounds, twelve periwinkle clumps, grass tufts along the kerb, a weed or two.
				for sx, sy in SHRUB_SPOTS:
					base = centre + Vector((sx * 0.92, sy * 0.85, SOIL))
					shrub_cards(buf, rng, base, 0.36, 0.42, 30, [shrub_cell(2, 1), shrub_cell(3, 1)], size=(0.3, 0.42))
				spots = []
				while len(spots) < 12:
					x, y = rng.uniform(-ix + 0.3, ix - 0.3), rng.uniform(-iy + 0.3, iy - 0.3)
					if math.hypot(x, y) < 0.55 or any(math.hypot(x - sx * 0.92, y - sy * 0.85) < 0.5 for sx, sy in SHRUB_SPOTS):
						continue
					if any(math.hypot(x - a, y - b) < 0.55 for a, b in spots):
						continue
					spots.append((x, y))
				for n, (x, y) in enumerate(spots):
					base = centre + Vector((x, y, SOIL))
					cell = shrub_cell(n % 3, 2) if n % 4 else shrub_cell(3, 2)
					shrub_cards(buf, rng, base, 0.2, 0.28, 4, [cell, shrub_cell(n % 2, 2)], core=False, size=(0.24, 0.32))
				for k in range(18):
					side = k % 4
					t = rng.uniform(-0.9, 0.9)
					x = (t * ix if side < 2 else (-1 if side == 2 else 1) * (ix - 0.12))
					y = ((-1 if side == 0 else 1) * (iy - 0.12) if side < 2 else t * iy)
					base = centre + Vector((x, y, SOIL - 0.01))
					for c in range(2):
						a = rng.uniform(0, math.pi) + c * math.pi / 2
						card(buf, "W3Shrubs", base, UP, Vector((math.cos(a), math.sin(a), 0)), 0.28, 0.24,
							shrub_cell(int(rng.integers(0, 2)), 3), radial_from=base - UP * 0.2, normal_mix=0.4)
				for k in range(3):
					base = centre + Vector((rng.uniform(-ix + 0.4, ix - 0.4), rng.uniform(-iy + 0.4, iy - 0.4), SOIL))
					for c in range(2):
						a = rng.uniform(0, math.pi) + c * math.pi / 2
						card(buf, "W3Shrubs", base, UP, Vector((math.cos(a), math.sin(a), 0)), 0.3, 0.3, shrub_cell(2, 3),
							radial_from=base - UP * 0.2, normal_mix=0.4)
			# Fallen leaves flat on the soil.
			for k in range(6):
				at = centre + Vector((rng.uniform(-ix + 0.3, ix - 0.3), rng.uniform(-iy + 0.3, iy - 0.3), SOIL + 0.045))
				a = rng.uniform(0, math.tau)
				card(buf, "W3Shrubs", at, Vector((math.cos(a), math.sin(a), 0)), UP, 0.4, 0.4, shrub_cell(3, 3), base=0.5)
			bufs.append(buf)
			if hedge is not None:
				bufs.append(hedge)
		objs = []
		for b in bufs:
			if isinstance(b, Buf):
				objs.append(b.build())
				print("T259_PART planting_%s %s %d tris" % (option, b.name, b.tris()))
			else:
				objs.append(b.build(uv_size={"W3Hedge": 0.5}))
		w1kit.export(OUT / f"planting_{option}.glb", objs)


# ---------------------------------------------------------------------------------------------- paving, bench, lamp

def build_paving():
	for option, mat, tile in (("block", "W3PavingBlock", 0.9), ("red", "W3PavingRed", 1.2)):
		w1kit.reset()
		part = w1kit.Part("Paving")
		faces = part.box(mat, (0.0, -48.0, -0.06), (44.0, -8.0, 0.0))
		part.set_uv2(faces, lambda co: (co.x / 44.0, 1.0 - ((-co.y) - 8.0) / 40.0))
		obj = part.build(uv_size={mat: tile})
		w1kit.export(OUT / f"paving_{option}.glb", [obj])


def build_bench():
	"""Ghế đá mài: terrazzo seat slab on two slab legs; the seat top at the PS1 seat's 0.57 m (Ngư's anchor)."""
	w1kit.reset()
	part = w1kit.Part("Bench")
	seat_top = 0.57
	faces = []
	faces += part.box("W3Bench", (-1.17, -0.27, seat_top - 0.075), (1.17, 0.27, seat_top), bevel=0.014, segments=3)
	for x in (-0.85, 0.85):
		# A leg tapering a little towards the top, with a shallow plinth.
		verts = []
		for z, half_d, half_w in ((0.0, 0.24, 0.05), (seat_top - 0.075, 0.2, 0.04)):
			for sy in (-1, 1):
				for sx in (-1, 1):
					verts.append((x + sx * half_w, sy * half_d, z))
		quads = [(0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3)]
		faces += part.poly("W3Bench", verts, quads)
		faces += part.box("W3Bench", (x - 0.08, -0.26, 0.0), (x + 0.08, 0.26, 0.04), bevel=0.01, segments=2)
	part.set_uv2(faces, lambda co: ((co.x + 1.3) / 2.6, co.z / 0.6))
	obj = part.build(uv_size={"W3Bench": TERRAZZO})
	w1kit.export(OUT / "bench_ngu.glb", [obj])


def build_lamp():
	"""Garden lamp: concrete footing, fluted cast base, steel post, collar, opal globe (centre 2.9 m = the light)."""
	w1kit.reset()
	part = w1kit.Part("Post")
	part.box("W1Concrete", (-0.16, -0.16, -0.05), (0.16, 0.16, 0.1), bevel=0.012, segments=2)
	base = [(0.11, 0.1), (0.11, 0.16), (0.085, 0.2), (0.07, 0.3), (0.06, 0.45), (0.052, 0.55), (0.06, 0.58), (0.042, 0.6)]
	part.lathe("W3LampPaint", base, segments=16)
	part.cylinder("W3LampPaint", (0, 0, 1.6), 0.038, 2.04, segments=12, cap=False)
	collar = [(0.042, 2.6), (0.06, 2.62), (0.06, 2.66), (0.045, 2.68), (0.05, 2.7), (0.075, 2.74), (0.07, 2.76)]
	part.lathe("W3LampPaint", collar, segments=16)
	post = part.build(uv_size={"W3LampPaint": 1.0, "W1Concrete": 0.8})
	globe = w1kit.Part("Globe")
	profile = [(0.0001, 2.745)]
	for k in range(1, 12):
		a = -math.pi / 2 + k / 12 * math.pi
		profile.append((max(math.cos(a) * 0.16, 0.0001), 2.9 + math.sin(a) * 0.16))
	profile.append((0.012, 3.06))
	globe.lathe("W3LampGlobe", profile, segments=20)
	globe.cylinder("W3LampPaint", (0, 0, 3.07), 0.014, 0.03, segments=8)
	lamp_globe = globe.build(uv_size={"W3LampGlobe": 1.0, "W3LampPaint": 1.0})
	w1kit.export(OUT / "garden_lamp.glb", [post, lamp_globe])


BUILDS = {"trees": build_trees, "beds": build_beds, "plantings": build_plantings, "paving": build_paving,
	"bench": build_bench, "lamp": build_lamp}


if __name__ == "__main__":
	args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for key in (args or BUILDS):
		BUILDS[key]()
