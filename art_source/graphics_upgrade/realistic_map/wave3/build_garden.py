"""T-259 round 2 (D-175): the whole garden (A12), the B-to-garden strip (A16) and the light copy seen from floor 4 in
chapters 1-2 (A05). Blender 5.2.2, no add-on, no Tripo. Reuses the pilot's builders (build_garden_pilot.py).

  tree_plumeria_{a,b,c}.glb, tree_lagerstroemia_{a,b}.glb   tree variants (Bark, Leaves near; BarkFar, LeavesFar far)
  garden_beds.glb       the 12 kerbs (whitewash, one UV2 row each in mask_kerb.png) and their soil, garden space
  garden_planting.glb   F1 in all 12 beds: clipped golden Duranta border + four Ixora, each bed turned/shifted a little
  bench_back.glb        terrazzo bench with a back (Bench0-3); bench_ngu.glb, garden_lamp.glb, paving_block.glb: pilot
  fallen_bunk.glb       the toppled steel bunk (frame, planks, upper guard rail at the old collision top) and the four
                        detached rails, garden space
  garden_backdrop.glb   chapters 1-2 light copy: lawn, paving, beds, far trees, lamps, the distant street lamp's pole
  strip_b_garden.glb    A16: lawn of the strip (x -6..50, z 4.2..50), the paving's curb, the gutter along B's front
  strip_props.glb       A16: litter where the PS1 papers lay, three rubble piles in their old colliders, the notice board

Garden space: origin at Godot (0, -9.9, 0) (the paving top), Blender (x, y, z) = Godot (x, -z, y + 9.9).
Run: blender -b --factory-startup -P art_source/graphics_upgrade/realistic_map/wave3/build_garden.py [-- target ...]
"""
import math
from pathlib import Path
import random
import sys

import bpy
from mathutils import Matrix, Vector

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "wave1"))
import numpy as np  # noqa: E402
import w1kit  # noqa: E402
import build_garden_pilot as pilot  # noqa: E402
import garden_layout as L  # noqa: E402
from build_garden_pilot import Buf, card, tube, shrub_cards, shrub_cell, UP  # noqa: E402

OUT = pilot.OUT
SEEDS = {"plumeria": {"a": 259_101, "b": 259_111, "c": 259_121}, "lagerstroemia": {"a": 259_103, "b": 259_113}}
FAR_FROM = 40.0


def g2b(x, z, y=0.0):
	"""Godot (x, z) and height over the paving to Blender garden space."""
	return Vector((x, -z, y))


def tree_bufs(species, variant):
	rng = np.random.default_rng(SEEDS[species][variant])
	return (pilot.plumeria if species == "plumeria" else pilot.lagerstroemia)(rng)


def build_trees():
	for species, variants in SEEDS.items():
		for variant in variants:
			w1kit.reset()
			bufs = tree_bufs(species, variant)
			if pilot.check_canopy("%s_%s" % (species, variant), bufs):
				raise SystemExit("canopy contract broken")
			pilot.export_bufs(OUT / ("tree_%s_%s.glb" % (species, variant)), bufs)


# ---------------------------------------------------------------------------------------------- beds, planting

def kerb_part(part, i, j, simple=False):
	gx, gz = L.BEDS[(i, j)]
	centre = g2b(gx, gz)
	hx, hy = pilot.BED_HALF
	k, top = pilot.KERB, pilot.TOP
	faces = []
	bevel = 0.0 if simple else 0.012
	if simple:
		faces += part.box("W3Kerb", (centre.x - hx, centre.y - hy, 0), (centre.x + hx, centre.y + hy, top))
	else:
		faces += part.box("W3Kerb", (centre.x - hx, centre.y + hy - k, 0), (centre.x + hx, centre.y + hy, top), bevel=bevel, segments=2)
		faces += part.box("W3Kerb", (centre.x - hx, centre.y - hy, 0), (centre.x + hx, centre.y - hy + k, top), bevel=bevel, segments=2)
		faces += part.box("W3Kerb", (centre.x - hx, centre.y - hy + k, 0), (centre.x - hx + k, centre.y + hy - k, top), bevel=bevel, segments=2)
		faces += part.box("W3Kerb", (centre.x + hx - k, centre.y - hy + k, 0), (centre.x + hx, centre.y + hy - k, top), bevel=bevel, segments=2)
	fn = pilot.kerb_uv2(i * 3 + j)
	part.set_uv2(faces, lambda co, fn=fn, cx=centre.x, cy=centre.y: fn(co, cx, cy))


def soil_part(part, i, j):
	gx, gz = L.BEDS[(i, j)]
	centre = g2b(gx, gz)
	nx, ny = 14, 9
	ix, iy = pilot.BED_HALF[0] - pilot.KERB, pilot.BED_HALF[1] - pilot.KERB
	rnd = random.Random(i * 3 + j)
	verts, quads = [], []
	for b in range(ny + 1):
		for a in range(nx + 1):
			x = -ix + 2 * ix * a / nx
			y = -iy + 2 * iy * b / ny
			edge = min(ix - abs(x), iy - abs(y))
			z = pilot.SOIL + 0.035 * min(edge / 0.6, 1.0) + (rnd.uniform(-0.008, 0.008) if 0 < a < nx and 0 < b < ny else 0)
			verts.append((centre.x + x, centre.y + y, z))
	for b in range(ny):
		for a in range(nx):
			k = b * (nx + 1) + a
			quads.append((k, k + 1, k + nx + 2, k + nx + 1))
	part.poly("W3Soil", verts, quads, recalc=False)


def build_beds():
	w1kit.reset()
	kerbs = w1kit.Part("Kerbs")
	soil = w1kit.Part("Soil")
	for (i, j) in L.BEDS:
		kerb_part(kerbs, i, j)
		soil_part(soil, i, j)
	w1kit.export(OUT / "garden_beds.glb", [kerbs.build(uv_size={"W3Kerb": pilot.PLASTER}), soil.build(uv_size={"W3Soil": 0.8})])


def planting_bed(buf, hedge, rng, i, j):
	"""F1 with a per-bed twist: the shrub pattern mirrored or turned, shifted, shrubs a little bigger or smaller."""
	gx, gz = L.BEDS[(i, j)]
	centre = g2b(gx, gz)
	ix, iy = pilot.BED_HALF[0] - pilot.KERB, pilot.BED_HALF[1] - pilot.KERB
	w, h = 0.26, 0.36
	z0, z1 = pilot.SOIL - 0.02, pilot.SOIL + h * rng.uniform(0.92, 1.08)
	boxes = [((-ix, iy - w), (ix, iy)), ((-ix, -iy), (ix, -iy + w)), ((-ix, -iy + w), (-ix + w, iy - w)),
		((ix - w, -iy + w), (ix, iy - w))]
	for (ax, ay), (bx, by) in boxes:
		hedge.box("W3Hedge", (centre.x + ax, centre.y + ay, z0), (centre.x + bx, centre.y + by, z1), bevel=0.07, segments=2)
	for (ax, ay), (bx, by) in boxes:
		length = max(bx - ax, by - ay)
		along = Vector((1, 0, 0)) if bx - ax > by - ay else Vector((0, 1, 0))
		across = Vector((0, 1, 0)) if along.x else Vector((1, 0, 0))
		n = int(length / 0.2)
		mid = Vector(((ax + bx) * 0.5, (ay + by) * 0.5, 0))
		for k in range(n):
			for row in (-0.25, 0.25):
				t = (k + rng.uniform(0.1, 0.9)) / n
				at = centre + mid + along * (t - 0.5) * length + across * row * w + UP * (z1 + 0.005)
				tilt = Vector((rng.uniform(-0.3, 0.3), rng.uniform(-0.3, 0.3), 1)).normalized()
				spin = rng.uniform(0, math.tau)
				up_axis = Vector((math.cos(spin), math.sin(spin), 0))
				up_axis = (up_axis - tilt * up_axis.dot(tilt)).normalized()
				card(buf, "W3Shrubs", at, up_axis, tilt, 0.3, 0.3, shrub_cell(int(rng.integers(0, 2)), 0), base=0.5,
					radial_from=at - UP * 0.4, normal_mix=0.3)
		n = int(length / 0.22)
		for k in range(n):
			t = (k + rng.uniform(0.2, 0.8)) / n
			at = centre + Vector((ax + (bx - ax) * (t if along.x else 0.5), ay + (by - ay) * (t if along.y else 0.5), z1 - 0.05))
			tilt = Vector((rng.uniform(-0.5, 0.5), rng.uniform(-0.5, 0.5), 1)).normalized()
			card(buf, "W3Shrubs", at, tilt, along.cross(tilt).normalized(), 0.26, 0.16, shrub_cell(int(rng.integers(0, 2)), 0),
				radial_from=at - UP * 0.3, normal_mix=0.5)
	sx = -1 if (i + j) % 2 else 1
	sy = -1 if i % 2 else 1
	for sx0, sy0 in pilot.SHRUB_SPOTS:
		x = sx * sx0 * 0.92 + rng.uniform(-0.15, 0.15)
		y = sy * sy0 * 0.85 + rng.uniform(-0.12, 0.12)
		base = centre + Vector((x, y, pilot.SOIL))
		size = rng.uniform(0.85, 1.15)
		shrub_cards(buf, rng, base, 0.42 * size, 0.75 * size, 40, [shrub_cell(2, 0), shrub_cell(3, 0)], size=(0.38 * size, 0.52 * size))
		for k in range(3):
			a = k / 3 * math.tau + rng.uniform(-0.4, 0.4)
			at = base + Vector((math.cos(a) * 0.2 * size, math.sin(a) * 0.2 * size, 0.62 * size + rng.uniform(-0.05, 0.08)))
			for c in range(2):
				nrm = Vector((math.cos(a + c * math.pi / 2), math.sin(a + c * math.pi / 2), 0.3)).normalized()
				card(buf, "W3Shrubs", at - UP * 0.1, (UP + Vector((math.cos(a), math.sin(a), 0)) * 0.4).normalized(), nrm,
					0.24, 0.24, shrub_cell(int(rng.integers(0, 2)), 1), radial_from=base + UP * 0.3, normal_mix=0.4)
	for k in range(6):
		at = centre + Vector((rng.uniform(-ix + 0.3, ix - 0.3), rng.uniform(-iy + 0.3, iy - 0.3), pilot.SOIL + 0.045))
		a = rng.uniform(0, math.tau)
		card(buf, "W3Shrubs", at, Vector((math.cos(a), math.sin(a), 0)), UP, 0.4, 0.4, shrub_cell(3, 3), base=0.5)


def build_planting():
	w1kit.reset()
	buf = Buf("Planting")
	hedge = w1kit.Part("Hedges")
	for (i, j) in L.BEDS:
		planting_bed(buf, hedge, np.random.default_rng(259_300 + i * 3 + j), i, j)
	objs = [buf.build(), hedge.build(uv_size={"W3Hedge": 0.5})]
	print("T259_PART garden_planting Planting %d tris" % buf.tris())
	w1kit.export(OUT / "garden_planting.glb", objs)


# ---------------------------------------------------------------------------------------------- benches, bunk

def build_bench_back():
	"""Ghế đá mài with a back (Bench0-3): origin on the paving at the bench's centre; back towards +z (Godot)."""
	w1kit.reset()
	part = w1kit.Part("Bench")
	faces = []
	seat_top = 0.48
	# Godot +z is Blender -y.
	faces += part.box("W3Bench", (-1.15, -0.17, seat_top - 0.07), (1.15, 0.25, seat_top), bevel=0.012, segments=3)
	for x in (-0.85, 0.85):
		verts = []
		for z, d0, d1, hw in ((0.0, -0.2, 0.22, 0.05), (seat_top - 0.07, -0.16, 0.2, 0.04)):
			for yy in (d0, d1):
				for sx in (-1, 1):
					verts.append((x + sx * hw, yy, z))
		faces += part.poly("W3Bench", verts, [(0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3)])
		faces += part.box("W3Bench", (x - 0.07, -0.22, 0.0), (x + 0.07, 0.24, 0.035), bevel=0.01, segments=2)
		# Back support: a short block from the seat's back edge up to the back slab.
		faces += part.box("W3Bench", (x - 0.05, -0.27, seat_top - 0.02), (x + 0.05, -0.19, 0.66), bevel=0.008, segments=2)
	back = Matrix.Translation((0, -0.245, 0.74)) @ Matrix.Rotation(math.radians(8), 4, "X")
	faces += part.box("W3Bench", (-1.15, -0.035, -0.17), (1.15, 0.035, 0.17), bevel=0.012, segments=3, matrix=back)
	part.set_uv2(faces, lambda co: ((co.x + 1.3) / 2.6, co.z / 0.95))
	w1kit.export(OUT / "bench_back.glb", [part.build(uv_size={"W3Bench": pilot.TERRAZZO})])


def build_bunk():
	"""The toppled steel bunk lying on its side in the kit bunk's old box (x 6.3..8.0, height 0.05..0.95, z 36..38):
	posts along x (feet at 6.3, tops at 8.0), the upper bed's guard rail on top at the old collision top (0.95), where
	bar B01 rests. Planks hang in the lower bed, two are missing from the upper one, one lies on the paving."""
	w1kit.reset()
	frame = w1kit.Part("Frame")
	planks = w1kit.Part("Planks")
	t = 0.032
	lo, hi = L.FALLEN_BUNK["aabb_min"], L.FALLEN_BUNK["aabb_max"]
	x0, x1 = lo[0] + 0.02, hi[0] - 0.02
	zb0, zb1 = lo[1] - L.PAVING_Y + t / 2, hi[1] - L.PAVING_Y - t / 2  # tube centres, heights over the paving
	ends = (-(lo[2] + 0.04), -(hi[2] - 0.04))  # Blender y of the bunk's two ends

	def bar(a, b, size=t):
		a, b = Vector(a), Vector(b)
		mn = Vector((min(a.x, b.x), min(a.y, b.y), min(a.z, b.z))) - Vector((size / 2,) * 3)
		mx = Vector((max(a.x, b.x), max(a.y, b.y), max(a.z, b.z))) + Vector((size / 2,) * 3)
		frame.box("W2BunkPaint", mn, mx, bevel=0.004, segments=1)

	for y in ends:
		for zb in (zb0, zb1):
			bar((x0, y, zb), (x1, y, zb))  # posts
		for x in (x0 + 0.06, x0 + 0.35, x0 + 1.4, x1):
			bar((x, y, zb0), (x, y, zb1))  # end cross bars, bed ends
	for x in (x0 + 0.35, x0 + 1.4):
		for zb in (zb0, zb1):
			bar((x, ends[0], zb), (x, ends[1], zb))  # bed side rails
	bar((x1, ends[0], zb1), (x1, ends[1], zb1))  # upper guard rail on top: B01 rests on it
	for x in (x0 + 0.7, x0 + 1.0):
		bar((x, ends[1], zb0), (x, ends[1], zb1), 0.026)  # ladder rungs at one end
	rnd = random.Random(259)
	for bed_x, keep in ((x0 + 0.35, (0, 1, 2, 3, 4, 5)), (x0 + 1.4, (0, 2, 5))):
		for k in range(6):
			if k not in keep:
				continue
			y0 = ends[0] - 0.08 - k * 0.31
			sag = rnd.uniform(-0.02, 0.02)
			planks.box("W1Wood", (bed_x - 0.012 + sag, y0 - 0.12, zb0 + 0.02), (bed_x + 0.012 + sag, y0, zb1 - 0.02), bevel=0.003)
	# One plank fallen on the paving beside the bunk.
	m = Matrix.Translation(g2b(8.75, 36.6, 0.012)) @ Matrix.Rotation(math.radians(28), 4, "Z")
	planks.box("W1Wood", (-0.06, -0.42, -0.012), (0.06, 0.42, 0.012), bevel=0.003, matrix=m)
	# The four detached rails (garden.tscn DetachedRail0-3: 1.2 m, 3.5 cm square, turned about the vertical).
	rails = w1kit.Part("Rails")
	for (x, y, z), yaw in L.DETACHED_RAILS:
		m = Matrix.Translation(g2b(x, z, y - L.PAVING_Y)) @ Matrix.Rotation(math.radians(yaw), 4, "Z")
		rails.box("W2BunkPaint", (-0.0175, -0.6, -0.0175), (0.0175, 0.6, 0.0175), bevel=0.003, matrix=m)
	objs = [frame.build(uv_size={"W2BunkPaint": 1.0}), planks.build(uv_size={"W1Wood": 1.0}), rails.build(uv_size={"W2BunkPaint": 1.0})]
	w1kit.export(OUT / "fallen_bunk.glb", objs)


# ---------------------------------------------------------------------------------------------- chapter 1-2 light copy

def transform_buf(dst, src, matrix, mat):
	rot = matrix.to_3x3()
	base = len(dst.v)
	for v, uv, n in zip(src.v, src.uv, src.n):
		dst.vert(matrix @ v, uv, rot @ n)
	for f in src.f:
		dst.face(tuple(base + i for i in f), mat)


def build_backdrop():
	"""Floor 4's view in chapters 1-2 (no campus there): the same garden, light: no collision, no shadow, far trees."""
	w1kit.reset()
	objs = []
	ground = w1kit.Part("Ground")
	# Far past the fog (density 0.032: 1 % left at 150 m), so its edge never shows.
	ground.poly("W3GroundFar", [(-150, -4.2, -0.04), (200, -4.2, -0.04), (200, -250, -0.04), (-150, -250, -0.04)], [(0, 3, 2, 1)], recalc=False)
	objs.append(ground.build(uv_size={"W3GroundFar": 2.0}))
	paving = w1kit.Part("Paving")
	faces = paving.poly("W3PavingBlock", [(0, -8, 0), (44, -8, 0), (44, -48, 0), (0, -48, 0)], [(0, 3, 2, 1)], recalc=False)
	paving.set_uv2(faces, lambda co: (co.x / 44.0, 1.0 - ((-co.y) - 8.0) / 40.0))
	objs.append(paving.build(uv_size={"W3PavingBlock": 0.9}))
	kerbs = w1kit.Part("Kerbs")
	tops = w1kit.Part("BedTops")
	for (i, j), (gx, gz) in L.BEDS.items():
		kerb_part(kerbs, i, j, simple=True)
		c = g2b(gx, gz)
		tops.box("W3Hedge", (c.x - 2.86, c.y - 1.86, 0.5), (c.x + 2.86, c.y + 1.86, 0.8), bevel=0.08, segments=1)
	objs.append(kerbs.build(uv_size={"W3Kerb": pilot.PLASTER}))
	objs.append(tops.build(uv_size={"W3Hedge": 0.5}))
	merged = {}
	cache = {}
	for (i, j), (name, yaw) in L.trees().items():
		species, variant = name[len("tree_"):-len(".glb")].rsplit("_", 1)
		if (species, variant) not in cache:
			cache[(species, variant)] = tree_bufs(species, variant)
		bufs = cache[(species, variant)]
		gx, gz = L.BEDS[(i, j)]
		matrix = Matrix.Translation(g2b(gx, gz)) @ Matrix.Rotation(math.radians(yaw), 4, "Z")
		tag = "Plumeria" if species == "plumeria" else "Lager"
		for src, part in ((bufs[2], "Bark"), (bufs[3], "Leaves")):
			key = part + tag
			if key not in merged:
				merged[key] = Buf(key)
			transform_buf(merged[key], src, matrix, ("W3Bark" if part == "Bark" else "W3Leaf") + tag)
	for buf in merged.values():
		objs.append(buf.build())
		print("T259_PART backdrop %s %d tris" % (buf.name, buf.tris()))
	posts = w1kit.Part("LampPosts")
	globes = w1kit.Part("LampGlobes")
	for x, z in L.LAMPS:
		c = g2b(x, z)
		posts.cylinder("W3LampPaint", (c.x, c.y, 1.37), 0.045, 2.74, segments=6, cap=False)
		globes.cylinder("W3LampGlobe", (c.x, c.y, 2.9), 0.16, 0.3, segments=8, radius2=0.12)
	x, y, z = L.DISTANT_LAMP
	head = y - L.PAVING_Y
	c = g2b(x, z)
	posts.cylinder("W3LampPaint", (c.x, c.y, (head - 0.2) / 2), 0.08, head - 0.2, segments=8, radius2=0.05, cap=False)
	globes.cylinder("W3LampGlobe", (c.x, c.y, head), 0.2, 0.36, segments=10, radius2=0.14)
	objs.append(posts.build(uv_size={"W3LampPaint": 1.0}))
	objs.append(globes.build(uv_size={"W3LampGlobe": 1.0}))
	w1kit.export(OUT / "garden_backdrop.glb", objs)


# ---------------------------------------------------------------------------------------------- A16 strip

def build_strip():
	"""Lawn over the strip (x -6..50, z 4.2..50) round the paving, the paving's concrete curb, the covered gutter
	along building B's front (z 6.45..6.8)."""
	w1kit.reset()
	ground = w1kit.Part("Lawn")
	y = L.GROUND_Y - L.PAVING_Y + 0.01  # 1 cm over the PS1 lawn
	x0, x1 = L.STRIP["x"]
	z0, z1 = L.B_FRONT_Z, L.STRIP["z"][1]
	cx0, cx1, cz0, cz1 = -0.12, 44.12, 7.88, 48.12
	g0, g1 = 6.45, 6.8
	rects = [(x0, z0, x1, g0), (x0, g1, x1, cz0), (x0, cz1, x1, z1), (x0, cz0, cx0, cz1), (cx1, cz0, x1, cz1)]
	faces = []
	for ax, az, bx, bz in rects:
		nx = max(1, int((bx - ax) / 4))
		nz = max(1, int((bz - az) / 4))
		verts, quads = [], []
		for b in range(nz + 1):
			for a in range(nx + 1):
				verts.append((ax + (bx - ax) * a / nx, -(az + (bz - az) * b / nz), y))
		for b in range(nz):
			for a in range(nx):
				k = b * (nx + 1) + a
				quads.append((k, k + nx + 1, k + nx + 2, k + 1))
		faces += ground.poly("W3StripGround", verts, quads, recalc=False)
	ground.set_uv2(faces, lambda co: ((co.x + 6.0) / 56.0, 1.0 - ((-co.y) - 4.0) / 46.0))
	objs = [ground.build(uv_size={"W3StripGround": 1.0})]
	curb = w1kit.Part("Curb")
	top = 0.03
	for a, b in (((cx0, cz0), (0.0, cz1)), ((44.0, cz0), (cx1, cz1)), ((0.0, cz0), (44.0, 8.0)), ((0.0, 48.0), (44.0, cz1))):
		curb.box("W1Concrete", (a[0], -b[1], -0.05), (b[0], -a[1], top), bevel=0.01, segments=1)
	objs.append(curb.build(uv_size={"W1Concrete": 0.8}))
	gutter = w1kit.Part("Gutter")
	gy = y
	gutter.box("W1Concrete", (x0, -g0 - 0.06, gy - 0.25), (x1, -g0, gy + 0.005))
	gutter.box("W1Concrete", (x0, -g1, gy - 0.25), (x1, -g1 + 0.06, gy + 0.005))
	gutter.poly("W3GutterDark", [(x0, -g0, gy - 0.2), (x1, -g0, gy - 0.2), (x1, -g1, gy - 0.2), (x0, -g1, gy - 0.2)], [(0, 3, 2, 1)], recalc=False)
	rnd = random.Random(2591)
	x = x0
	while x < x1 - 0.1:
		length = min(0.48, x1 - x)
		if rnd.random() > 0.03:
			tilt = 0.008 if rnd.random() < 0.08 else 0.0
			gutter.box("W1Concrete", (x + 0.01, -g1 + 0.06, gy - 0.04 - tilt), (x + length - 0.01, -g0 - 0.06, gy))
		x += 0.5
	objs.append(gutter.build(uv_size={"W1Concrete": 0.8}))
	w1kit.export(OUT / "strip_b_garden.glb", objs)


def litter_height(x, z):
	inside = 0.0 <= x <= 44.0 and 8.0 <= z <= 48.0
	return 0.004 if inside else L.GROUND_Y - L.PAVING_Y + 0.014


def build_strip_props():
	w1kit.reset()
	rnd = random.Random(2592)
	litter = Buf("Litter")
	cells = [(0.0, 0.5, 0.5, 1.0), (0.5, 0.5, 1.0, 1.0), (0.0, 0.0, 0.5, 0.5), (0.5, 0.0, 1.0, 0.5)]
	count = 0
	for node, mode in L.A16_HIDE.items():
		if "paper" not in node:
			continue
		for basis, origin, colour in L.props_instances(node):
			if mode == "strip" and not L.in_strip(origin):
				continue
			if L.on_board(origin):
				continue
			x, _, z = origin
			size = max(0.18, min(0.42, math.hypot(*basis[0]) * 1.1))
			a = rnd.uniform(0, math.tau)
			at = g2b(x, z, litter_height(x, z))
			card(litter, "W3Litter", at, Vector((math.cos(a), math.sin(a), 0)), UP, size, size,
				cells[rnd.randrange(4)], base=0.5)
			count += 1
	print("T259_LITTER %d pieces" % count)
	objs = [litter.build()]
	# The three rubble piles, piece by piece where the PS1 boxes and pipes lay (props.tscn P_concrete_box_p0_p1,
	# P_iron_cylinder_p0_p1; all inside the piles' colliders Body_p0_p1/S0-S2), plus loose bricks on top.
	to_b = Matrix(((1, 0, 0), (0, 0, -1), (0, 1, 0)))  # Godot axes to Blender's

	def placed(basis, origin):
		cols = [Vector(c) for c in basis]
		mg = Matrix((cols[0], cols[1], cols[2])).transposed()  # columns are the basis vectors
		mb = to_b @ mg @ to_b.inverted()
		x, y, z = origin
		return Matrix.Translation(g2b(x, z, y - L.PAVING_Y)) @ mb.to_4x4()

	rubble = w1kit.Part("Rubble")
	for basis, origin, colour in L.props_instances("P_concrete_box_p0_p1"):
		brick = rnd.random() < 0.4
		rubble.box("W3Brick" if brick else "W1Concrete", (-0.5, -0.5, -0.5), (0.5, 0.5, 0.5), bevel=0.04, segments=1,
			matrix=placed(basis, origin) @ Matrix.Rotation(rnd.uniform(-0.15, 0.15), 4, "Z"))
	for (ax, az), (bx, bz) in L.RUBBLE_BOXES:
		cx, cz = (ax + bx) / 2, (az + bz) / 2
		for k in range(14):
			r = rnd.uniform(0, 1) ** 0.7
			a = rnd.uniform(0, math.tau)
			px = cx + math.cos(a) * r * (bx - ax) * 0.4
			pz = cz + math.sin(a) * r * (bz - az) * 0.4
			s = rnd.uniform(0.6, 1.0)
			m = Matrix.Translation(g2b(px, pz, 0.03 + 0.45 * (1 - r) ** 1.5 * rnd.uniform(0.3, 1.0))) @ \
				Matrix.Rotation(rnd.uniform(0, math.tau), 4, "Z") @ Matrix.Rotation(rnd.uniform(-0.6, 0.6), 4, "X")
			rubble.box("W3Brick", (-0.11 * s, -0.052 * s, -0.03), (0.11 * s, 0.052 * s, 0.03), bevel=0.006, segments=1, matrix=m)
	objs.append(rubble.build(uv_size={"W3Brick": 0.8, "W1Concrete": 0.8}))
	pipes = Buf("Pipes")
	for basis, origin, colour in L.props_instances("P_iron_cylinder_p0_p1"):
		m = placed(basis, origin)
		a, b = m @ Vector((0, 0, -0.5)), m @ Vector((0, 0, 0.5))
		radius = max(0.012, Vector(basis[0]).length * 0.5)
		tube(pipes, "W1Rebar", [a, (a + b) / 2, b], [radius, radius, radius], 8)
	objs.append(pipes.build())
	# Notice board inside its old collider (x 29.3..31.7, z 10.95..11.45, height 2.2), sheets towards building B (-z).
	board = w1kit.Part("NoticeBoard")
	lo, hi = L.NOTICE_BOARD["min"], L.NOTICE_BOARD["max"]
	for x in (lo[0] + 0.14, hi[0] - 0.14):
		board.box("W3LampPaint", g2b(x - 0.03, 11.23, 0.0) + Vector((0, -0.03, 0)), g2b(x + 0.03, 11.17, 2.05), bevel=0.005)
	board.box("W1Wood", g2b(lo[0] + 0.2, 11.24, 0.82), g2b(hi[0] - 0.2, 11.14, 2.02), bevel=0.01, segments=1)
	board.box("W3LampPaint", g2b(lo[0] + 0.16, 11.25, 0.79), g2b(hi[0] - 0.16, 11.11, 0.83))
	board.box("W3LampPaint", g2b(lo[0] + 0.16, 11.25, 2.01), g2b(hi[0] - 0.16, 11.11, 2.05))
	roof = Matrix.Translation(g2b(30.5, 11.2, 2.14)) @ Matrix.Rotation(math.radians(-6), 4, "X")
	board.box("W3LampPaint", (-1.18, -0.24, -0.015), (1.18, 0.24, 0.015), matrix=roof)
	sheets = w1kit.Part("Sheets")
	# The PS1 board's six papers sat at x 29.6 / 30.5 / 31.4, 1.3 and 1.9 m up; the sheets keep those places.
	for k, (x, yh) in enumerate([(29.6, 1.15), (30.5, 1.15), (31.4, 1.15), (29.6, 1.7), (30.5, 1.7), (31.4, 1.7)]):
		u0, v0 = (k % 3) / 3.0, 0.5 if k < 3 else 0.0
		faces = sheets.poly("W3Papers", [(x - 0.19, -11.135, yh - 0.24), (x + 0.19, -11.135, yh - 0.24),
			(x + 0.19, -11.135, yh + 0.24), (x - 0.19, -11.135, yh + 0.24)], [(0, 3, 2, 1)], recalc=False)
		# Seen from building B's side (-z), so u runs towards -x.
		sheets.planar_uv(faces, (x + 0.19, -11.135, yh - 0.24), (-1, 0, 0), (0, 0, 1), (u0 + 0.01, u0 + 0.32), (v0 + 0.03, v0 + 0.47), (0.38, 0.48))
	objs += [board.build(uv_size={"W3LampPaint": 1.0, "W1Wood": 1.0}), sheets.build()]
	w1kit.export(OUT / "strip_props.glb", objs)


TARGETS = {"trees": build_trees, "beds": build_beds, "planting": build_planting, "bench": build_bench_back,
	"bunk": build_bunk, "backdrop": build_backdrop, "strip": build_strip, "props": build_strip_props}


if __name__ == "__main__":
	args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
	for key in (args or TARGETS):
		TARGETS[key]()
