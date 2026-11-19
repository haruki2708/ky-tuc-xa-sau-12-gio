"""T-264 wave 7: textures drawn by code (numpy + Pillow; wave 3's leaf canvas), no AI image, no download.

  leaf_bang.png, bark_bang_*        bàng (Terminalia catappa): big obovate leaves in rosettes at the twig ends, a few
                                    turning red; grey-brown fissured bark
  leaf_phuong.png, bark_phuong_*    phượng vĩ (Delonix regia): feathery bipinnate fronds, one cell of scarlet flowers; smooth
                                    pale grey bark
  leaf_xacu.png, bark_xacu_*        xà cừ (Khaya senegalensis): dense pinnate sprays of small dark leaflets; scaly grey bark
  interior_atlas.png                fake rooms seen through the windows (4 x 4 cells of 256 px: rows dorm room, classroom,
                                    gym hall, lobby; columns side wall, floor, ceiling, back wall), dim as at night
  mask_facades7.png                 UV2 rows (wave7_layout.FACADE_ROWS) for the shells' and building B's outside: R paint
                                    loss, G grime, B rain runs, A mould
  mask_road7.png, mask_verge7.png   the pilot's Avenue stretch (x 112..176, z -26..0): R patches and cracks (kind 1 grout),
                                    G grime, B puddles, A wheel polish; the verges' bare dirt (R) and wet (G)
  paint_line.png                    worn white road paint (alpha cut), 2 m along
  palette7.png                      8 x 8 flat cells for the small things (palette7.json)
Run: python -B art_source/graphics_upgrade/realistic_map/wave7/make_wave7_textures.py [name ...]
"""
from pathlib import Path
import json
import math
import sys

import numpy as np
from PIL import Image, ImageFilter

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "wave3"))
import make_wave3_textures as T3  # noqa: E402  (canvas, bark, noise; its main is guarded)
import wave7_layout as L  # noqa: E402

ROOT = HERE.parents[3]
OUT = ROOT / "game/assets/textures/graphics_pilot/realistic_map/wave7"
T3.OUT = OUT
smooth_noise, smoothstep = T3.smooth_noise, T3.smoothstep


def save(name, arr, mode="RGB"):
	OUT.mkdir(parents=True, exist_ok=True)
	img = Image.fromarray((np.clip(arr, 0.0, 1.0) * 255.0 + 0.5).astype(np.uint8), mode)
	img.save(OUT / name, optimize=True)
	print("T264_TEX", name, img.size)


def blur(a, r):
	img = Image.fromarray(np.clip(a * 255.0, 0, 255).astype(np.uint8))
	return np.asarray(img.filter(ImageFilter.GaussianBlur(r)), np.float64) / 255.0


# ---------------------------------------------------------------------------------------------- trees

def leaf_bang():
	"""Bàng: big leathery obovate leaves (narrow at the base) in rosettes at the tips of tiered twigs; old ones red."""
	c = T3.Canvas(1024, 1024, 264_01)
	rng = c.rng
	green = (0.17, 0.32, 0.1)

	def rosette(cx, cy, r, count, top=True, red=0.08):
		for k in range(count):
			ang = k / count * math.tau + rng.uniform(-0.25, 0.25)
			ln = r * rng.uniform(0.7, 1.0)
			col = T3.jitter(rng, (0.55, 0.16, 0.06) if rng.random() < red else green, 0.12)
			a = ang if top else math.atan2(math.sin(ang) * 0.4, math.cos(ang))
			c.leaf((cx, cy), a, ln, ln * 0.5, col, shape=(1.5, 0.5), veins=9, vein_slope=0.7, vein_light=0.06, fold=0.1,
				tip_round=0.35, gloss=0.03, petiole=4)

	for cell, (ox, oy) in enumerate([(0, 0), (512, 0), (0, 512), (512, 512)]):
		if cell < 2:
			for k in range(5):
				ang = k / 5 * math.tau + rng.uniform(-0.3, 0.3)
				tip = (ox + 256 + math.cos(ang) * 150, oy + 256 + math.sin(ang) * 150)
				c.stem([(ox + 256, oy + 256), tip], 7, 3, (0.33, 0.28, 0.22))
				rosette(tip[0], tip[1], rng.uniform(95, 120), int(rng.integers(5, 8)), red=0.12 if cell else 0.05)
			rosette(ox + 256, oy + 256, 110, 7)
		elif cell == 2:
			c.stem([(ox + 10, oy + 300), (ox + 260, oy + 286), (ox + 500, oy + 300)], 9, 4, (0.33, 0.28, 0.22))
			for k in range(4):
				rosette(ox + 70 + k * 120, oy + 290, rng.uniform(100, 125), int(rng.integers(5, 7)), top=False)
		else:
			for k in range(3):
				ang = -math.pi / 2 + (k - 1) * 0.7
				tip = (ox + 256 + math.cos(ang) * 210, oy + 480 + math.sin(ang) * 330)
				c.stem([(ox + 256, oy + 505), tip], 8, 3, (0.33, 0.28, 0.22))
				rosette(tip[0], tip[1], 100, int(rng.integers(5, 7)), red=0.3)
	T3.save_rgba("leaf_bang.png", c)


def leaf_phuong():
	"""Phượng vĩ: bipinnate fronds (a rachis with pinnae of many tiny leaflets), feathery; one cell of red flowers."""
	c = T3.Canvas(1024, 1024, 264_02)
	rng = c.rng
	green = (0.2, 0.36, 0.1)

	def frond(x0, y0, angle, length, scale=1.0):
		tip = (x0 + math.cos(angle) * length, y0 + math.sin(angle) * length)
		c.stem([(x0, y0), tip], 4 * scale, 2, (0.3, 0.36, 0.16))
		pinnae = int(10 * scale) + 4
		for k in range(1, pinnae):
			t = k / pinnae
			px, py = x0 + (tip[0] - x0) * t, y0 + (tip[1] - y0) * t
			for side in (-1, 1):
				a = angle + side * 1.15
				pl = length * 0.28 * (1.0 - 0.6 * abs(t - 0.45)) * scale
				ptip = (px + math.cos(a) * pl, py + math.sin(a) * pl)
				c.stem([(px, py), ptip], 2, 1, (0.26, 0.36, 0.14))
				for j in range(1, 9):
					s = j / 9
					lx, ly = px + (ptip[0] - px) * s, py + (ptip[1] - py) * s
					for side2 in (-1, 1):
						c.leaf((lx, ly), a + side2 * 1.35, 13 * scale, 5 * scale, T3.jitter(rng, green, 0.12), shape=(1.0, 0.8),
							veins=0, vein_light=0.0, fold=0.05)

	for cell, (ox, oy) in enumerate([(0, 0), (512, 0), (0, 512)]):
		for k in range(3 if cell < 2 else 2):
			frond(ox + 256 + rng.uniform(-30, 30), oy + 500, -math.pi / 2 + (k - 1) * 0.55 + rng.uniform(-0.1, 0.1), 430, 1.0)
	# Flowers: scarlet five-petal blooms in loose clusters among a couple of fronds (the season the chapter has).
	ox, oy = 512, 512
	frond(ox + 200, oy + 505, -math.pi / 2 - 0.4, 380, 0.8)
	for k in range(26):
		x, y = ox + 256 + rng.uniform(-200, 200), oy + 200 + rng.uniform(-150, 150)
		c.flower((x, y), rng.uniform(26, 38), 5, T3.jitter(rng, (0.82, 0.16, 0.06), 0.1), eye=(0.95, 0.75, 0.3), eye_r=0.18,
			rot=rng.uniform(0, math.tau), twist=0.3, shape=(1.2, 0.6))
	T3.save_rgba("leaf_phuong.png", c)


def leaf_xacu():
	"""Xà cừ: pinnate sprays of small dark glossy leaflets, dense; crowns read as dark rounded masses."""
	c = T3.Canvas(1024, 1024, 264_03)
	rng = c.rng
	dark = (0.11, 0.24, 0.08)
	for cell, (ox, oy) in enumerate([(0, 0), (512, 0), (0, 512), (512, 512)]):
		for k in range(7):
			a = -math.pi / 2 + (k - 3) * 0.33 + rng.uniform(-0.08, 0.08)
			ln = rng.uniform(300, 430)
			x0, y0 = ox + 256, oy + 505
			tip = (x0 + math.cos(a) * ln, y0 + math.sin(a) * ln)
			c.stem([(x0, y0), tip], 4, 2, (0.28, 0.24, 0.18))
			for j in range(2, 10):
				t = j / 10
				px, py = x0 + (tip[0] - x0) * t, y0 + (tip[1] - y0) * t
				for side in (-1, 1):
					col = T3.jitter(rng, dark if rng.random() > 0.15 else (0.2, 0.33, 0.12), 0.1)
					c.leaf((px, py), a + side * rng.uniform(0.9, 1.2), rng.uniform(42, 60), rng.uniform(18, 24), col, shape=(0.9, 0.8),
						veins=4, vein_slope=0.8, vein_light=0.04, fold=0.12, gloss=0.06)
	T3.save_rgba("leaf_xacu.png", c)


def barks():
	T3.bark("bang", (0.36, 0.32, 0.27), seed=264_04, kind="mantaly")
	T3.bark("phuong", (0.5, 0.49, 0.45), seed=264_05, kind="plumeria")
	T3.bark("xacu", (0.42, 0.4, 0.36), seed=264_06, kind="mantaly")


# ---------------------------------------------------------------------------------------------- interiors

def interior_atlas():
	"""4 x 4 cells of 256 px. Rows: 0 dorm room, 1 classroom, 2 gym hall, 3 lobby. Columns: 0 side wall, 1 floor, 2 ceiling,
	3 back wall. Lit as rooms at night with the lights off: low values; the torch lights them through the glass."""
	n, cell = 1024, 256
	rng = np.random.default_rng(264_10)
	out = np.zeros((n, n, 3))
	v, u = np.mgrid[0:cell, 0:cell].astype(np.float64) / cell
	noise = smooth_noise(rng, cell, 12)

	def put(row, col, rgb):
		out[row * cell:(row + 1) * cell, col * cell:(col + 1) * cell] = np.clip(rgb, 0, 1)

	def wall(base, dado, dado_h=0.3):
		rgb = np.array(base)[None, None] * (1 + 0.06 * noise)[..., None]
		low = (1 - v) < dado_h
		rgb[low] = np.array(dado) * (1 + 0.05 * noise[low])[..., None]
		return rgb * (1 - 0.25 * smoothstep(0.85, 1.0, 1 - v))[..., None]

	def rect(rgb, x0, y0, x1, y1, col):
		m = (u >= x0) & (u <= x1) & (v >= y0) & (v <= y1)
		rgb[m] = col
		return rgb

	# Dorm room: cream walls, green dado; tiled floor; plain ceiling; back wall: a bunk bed, a hanging towel, a poster.
	put(0, 0, rect(wall((0.5, 0.48, 0.4), (0.18, 0.28, 0.22)), 0.15, 0.25, 0.4, 0.5, (0.45, 0.25, 0.2)))
	floor = np.array([0.32, 0.3, 0.27])[None, None] * (1 + 0.08 * noise)[..., None]
	floor[((u * 6) % 1 < 0.03) | ((v * 6) % 1 < 0.03)] *= 0.7
	put(0, 1, floor)
	put(0, 2, np.array([0.42, 0.41, 0.37])[None, None] * (1 + 0.04 * noise)[..., None])
	back = wall((0.5, 0.48, 0.4), (0.18, 0.28, 0.22))
	for y0 in (0.35, 0.68):
		back = rect(back, 0.08, y0, 0.62, y0 + 0.06, (0.14, 0.2, 0.17))
		back = rect(back, 0.1, y0 - 0.12, 0.6, y0, (0.55, 0.55, 0.6))
	back = rect(back, 0.08, 0.3, 0.1, 1.0, (0.14, 0.2, 0.17))
	back = rect(back, 0.6, 0.3, 0.62, 1.0, (0.14, 0.2, 0.17))
	back = rect(back, 0.74, 0.3, 0.9, 0.55, (0.2, 0.32, 0.55))
	back = rect(back, 0.7, 0.62, 0.95, 1.0, (0.3, 0.22, 0.16))
	put(0, 3, back)
	# Classroom: pale walls, a blackboard on the back wall, terrazzo floor with desk rows seen from above.
	put(1, 0, rect(wall((0.52, 0.52, 0.46), (0.35, 0.36, 0.33)), 0.2, 0.3, 0.8, 0.55, (0.12, 0.14, 0.13)))
	floor = np.array([0.38, 0.37, 0.34])[None, None] * (1 + 0.1 * noise)[..., None]
	for y0 in (0.15, 0.45, 0.75):
		floor = rect(floor, 0.1, y0, 0.9, y0 + 0.12, (0.26, 0.18, 0.12))
	put(1, 1, floor)
	put(1, 2, np.array([0.44, 0.44, 0.41])[None, None] * (1 + 0.03 * noise)[..., None])
	back = wall((0.52, 0.52, 0.46), (0.35, 0.36, 0.33))
	back = rect(back, 0.12, 0.25, 0.88, 0.62, (0.1, 0.17, 0.13))
	back = rect(back, 0.12, 0.62, 0.88, 0.64, (0.4, 0.3, 0.2))
	back = rect(back, 0.3, 0.7, 0.7, 0.92, (0.3, 0.2, 0.13))
	put(1, 3, back)
	# Gym hall: high brick-red dado, wooden floor with court lines, steel truss ceiling, a hoop and wall bars at the back.
	put(2, 0, wall((0.48, 0.46, 0.42), (0.36, 0.18, 0.12), 0.35))
	floor = np.array([0.42, 0.28, 0.16])[None, None] * (1 + 0.1 * smooth_noise(rng, cell, 3, aspect=8.0))[..., None]
	floor[(np.abs(u - 0.5) < 0.006) | (np.abs(np.hypot(u - 0.5, v - 0.5) - 0.18) < 0.006)] = (0.75, 0.7, 0.6)
	put(2, 1, floor)
	ceil = np.array([0.25, 0.26, 0.27])[None, None] * np.ones((cell, cell, 1))
	ceil[((u * 5) % 1 < 0.04) | ((v * 3) % 1 < 0.04)] = (0.45, 0.47, 0.46)
	put(2, 2, ceil)
	back = wall((0.48, 0.46, 0.42), (0.36, 0.18, 0.12), 0.35)
	back = rect(back, 0.42, 0.2, 0.58, 0.32, (0.85, 0.85, 0.82))
	back = rect(back, 0.47, 0.32, 0.53, 0.34, (0.7, 0.3, 0.1))
	for x0 in np.arange(0.05, 0.3, 0.04):
		back = rect(back, x0, 0.45, x0 + 0.015, 1.0, (0.4, 0.28, 0.16))
	put(2, 3, back)
	# Lobby: terrazzo floor, a notice board and a stair's first flight at the back.
	put(3, 0, rect(wall((0.5, 0.49, 0.43), (0.3, 0.3, 0.28)), 0.25, 0.3, 0.75, 0.6, (0.38, 0.3, 0.2)))
	floor = np.array([0.4, 0.39, 0.36])[None, None] * (1 + 0.12 * smooth_noise(rng, cell, 2))[..., None]
	put(3, 1, floor)
	put(3, 2, np.array([0.42, 0.42, 0.39])[None, None] * (1 + 0.03 * noise)[..., None])
	back = wall((0.5, 0.49, 0.43), (0.3, 0.3, 0.28))
	for k in range(8):
		y = 1.0 - (k + 1) * 0.07
		back = rect(back, 0.45 + k * 0.05, y, 0.95, y + 0.07, (0.36 + 0.02 * (k % 2), 0.35, 0.32))
	back = rect(back, 0.08, 0.3, 0.35, 0.55, (0.38, 0.3, 0.2))
	put(3, 3, back)
	save("interior_atlas.png", out)


# ---------------------------------------------------------------------------------------------- masks

def mask_facades():
	w, h = 2048, 1024
	rows = len(L.FACADE_ROWS)
	rh = h // rows
	rng = np.random.default_rng(264_20)
	out = np.zeros((h, w, 4))
	n1 = smooth_noise(rng, (h, w), 5)
	n2 = smooth_noise(rng, (h, w), 30)
	streak = smooth_noise(rng, (h, w), 2.0, aspect=12.0)
	for row, (name, length, height, windows, sill) in enumerate(L.FACADE_ROWS):
		v, u = np.mgrid[0:rh, 0:w].astype(np.float64) + 0.5
		s = u / w * length
		y = (1.0 - v / rh) * height
		a, b, st = n1[row * rh:(row + 1) * rh], n2[row * rh:(row + 1) * rh], streak[row * rh:(row + 1) * rh]
		grime = 0.12 + 0.07 * b + 0.35 * smoothstep(0.7, 0.0, y) + 0.15 * smoothstep(height - 1.2, height, y)
		peel = 0.25 * smoothstep(0.9, 2.2, b + 0.5 * a)
		mould = 0.6 * smoothstep(0.6, 0.0, y) * smoothstep(-0.3, 1.0, b)
		stain = 0.55 * smoothstep(height - 1.8, height, y) * smoothstep(-0.4, 1.2, st)
		for wx in windows:
			for fy in sill:
				under = smoothstep(1.2, 0.7, np.abs(s - wx)) * smoothstep(fy, fy - 0.4, y) * smoothstep(fy - 2.4, fy - 1.0, y)
				stain = np.maximum(stain, 0.75 * under * smoothstep(-0.6, 1.0, st))
		out[row * rh:(row + 1) * rh, :, 0] = np.clip(peel, 0, 1)
		out[row * rh:(row + 1) * rh, :, 1] = np.clip(grime * (0.85 + 0.25 * a), 0, 1)
		out[row * rh:(row + 1) * rh, :, 2] = np.clip(stain, 0, 1)
		out[row * rh:(row + 1) * rh, :, 3] = np.clip(mould, 0, 1)
	save("mask_facades7.png", out, "RGBA")


def _road_grid():
	X, Z = L.ROAD_PILOT["x"], L.ROAD_PILOT["z"]
	w = 1024
	h = int(round(w * (Z[1] - Z[0]) / (X[1] - X[0])))
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	return X[0] + u / (w - 1) * (X[1] - X[0]), Z[0] + v / (h - 1) * (Z[1] - Z[0]), (h, w)


def mask_road():
	x, z, shape = _road_grid()
	rng = np.random.default_rng(264_21)
	big = smooth_noise(rng, shape, 30)
	mid = smooth_noise(rng, shape, 6)
	r = L.ROAD
	kerb = np.minimum(np.abs(z - r["z"][0]), np.abs(z - r["z"][1]))
	tracks = sum(np.exp(-((z - tz) / 0.35) ** 2) for tz in (-12.4, -13.9, -16.1, -17.6))
	# Patches: darker rectangles of newer asphalt; cracks: thin dark meanders.
	patch = np.zeros_like(x)
	for px, pz, pw, pd in [(121.0, -14.5, 3.2, 2.0), (139.5, -17.0, 2.0, 1.4), (150.0, -12.8, 4.5, 1.6), (166.0, -15.5, 2.4, 2.4)]:
		patch = np.maximum(patch, ((np.abs(x - px) < pw / 2) & (np.abs(z - pz) < pd / 2)).astype(np.float64))
	crack = np.zeros_like(x)
	cn = smooth_noise(rng, shape, 4, aspect=6.0)
	crack = np.exp(-(cn / 0.04) ** 2) * smoothstep(0.5, 1.4, big)
	grout = np.clip(0.4 * patch + 0.6 * crack, 0, 1)
	grime = np.clip(0.3 * np.exp(-kerb / 0.6) + 0.25 * smoothstep(1.0, 2.2, big + 0.4 * mid) + 0.35 * patch, 0, 1)
	wet = np.clip(np.exp(-kerb / 0.4) * smoothstep(-0.2, 1.2, big + 0.5 * mid) * 0.9 + smoothstep(1.9, 2.5, big) * 0.7, 0, 1)
	wear = np.clip(tracks * 0.6, 0, 1)
	save("mask_road7.png", np.dstack([grout, grime, wet, wear]), "RGBA")


def mask_verge():
	x, z, shape = _road_grid()
	rng = np.random.default_rng(264_22)
	big = smooth_noise(rng, shape, 25)
	mid = smooth_noise(rng, shape, 7)
	r = L.ROAD
	kerb = np.minimum(np.abs(z - (r["z"][0] - 0.3)), np.abs(z - (r["z"][1] + 0.3)))
	trunks = sum(np.exp(-(((x - tx) ** 2 + (z - tz) ** 2) / 1.2 ** 2)) for tx, tz in L.PILOT_TREES)
	dirt = np.clip(0.75 * np.exp(-kerb / 0.9) + 0.8 * trunks + 0.3 * smoothstep(0.8, 2.0, big + 0.5 * mid), 0, 1)
	wet = np.clip(0.5 * np.exp(-kerb / 0.5) * smoothstep(-0.3, 1.2, big) + 0.5 * smoothstep(1.9, 2.5, big), 0, 1)
	save("mask_verge7.png", np.dstack([dirt, wet, np.zeros_like(x), np.ones_like(x)]), "RGBA")


def _campus_grid(w=2048):
	X, Z = L.CAMPUS[0:2], L.CAMPUS[2:4]
	h = int(round(w * (Z[1] - Z[0]) / (X[1] - X[0])))
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	return X[0] + (u + 0.5) / w * (X[1] - X[0]), Z[0] + (v + 0.5) / h * (Z[1] - Z[0]), (h, w)


def _box_dist(x, z, x0, x1, z0, z1):
	"""Distance from each point to a rectangle (0 inside)."""
	dx = np.maximum(np.maximum(x0 - x, x - x1), 0.0)
	dz = np.maximum(np.maximum(z0 - z, z - z1), 0.0)
	return np.hypot(dx, dz)


def mask_road_campus():
	"""Round 3: the whole campus in UV2 (wave7_layout.campus_uv2), 2048 x 1434 (0.24 m a pixel). R: patches and cracks,
	G: grime by the kerbs and in the patches, B: puddles by the kerbs, A: polish in the wheel tracks. The forecourts'
	block paving reads the same mask (grout, grime, wet, wear)."""
	x, z, shape = _campus_grid()
	rng = np.random.default_rng(264_31)
	big = smooth_noise(rng, shape, 120)
	mid = smooth_noise(rng, shape, 24)
	kerb = np.full(shape, 99.0)
	tracks = np.zeros(shape)
	patch = np.zeros(shape)
	for name, x0, x1, z0, z1, along in L.ROADS:
		across, c0, c1 = (z, z0, z1) if along == "x" else (x, x0, x1)
		mid_line = (c0 + c1) / 2
		inside = _box_dist(x, z, x0, x1, z0, z1) == 0
		kerb = np.minimum(kerb, np.where(inside, np.minimum(across - c0, c1 - across), 99.0))
		for off in (-2.6, -1.1, 1.1, 2.6):
			if c1 - c0 < 7.0:
				off *= 0.7
			tracks = np.maximum(tracks, inside * np.exp(-((across - mid_line - off) / 0.35) ** 2))
		lr = np.random.default_rng(abs(hash(name)) % 1000)
		length = (x1 - x0) if along == "x" else (z1 - z0)
		for k in range(int(length / 14)):
			s = lr.uniform(0, length)
			w, d = lr.uniform(1.2, 4.5), lr.uniform(0.8, (c1 - c0) * 0.45)
			cc = lr.uniform(c0 + d / 2, c1 - d / 2)
			px, pz = (x0 + s, cc) if along == "x" else (cc, z0 + s)
			pw, pd = (w, d) if along == "x" else (d, w)
			patch = np.maximum(patch, ((np.abs(x - px) < pw / 2) & (np.abs(z - pz) < pd / 2)).astype(np.float64))
	for name, x0, x1, z0, z1 in L.FORECOURTS:
		inside = _box_dist(x, z, x0, x1, z0, z1) == 0
		kerb = np.minimum(kerb, np.where(inside, np.minimum(np.minimum(x - x0, x1 - x), np.minimum(z - z0, z1 - z)), 99.0))
	cn = smooth_noise(rng, shape, 5, aspect=6.0)
	crack = np.exp(-(cn / 0.035) ** 2) * smoothstep(0.4, 1.4, big + 0.3 * mid)
	grout = np.clip(0.4 * patch + 0.6 * crack, 0, 1)
	grime = np.clip(0.3 * np.exp(-kerb / 0.6) + 0.25 * smoothstep(1.0, 2.2, big + 0.4 * mid) + 0.35 * patch, 0, 1)
	wet = np.clip(np.exp(-kerb / 0.4) * smoothstep(-0.2, 1.2, big + 0.5 * mid) * 0.9 + smoothstep(1.9, 2.5, big) * 0.7, 0, 1)
	wear = np.clip(tracks * 0.6, 0, 1)
	save("mask_road7.png", np.dstack([grout, grime, wet, wear]), "RGBA")


def mask_verge_campus():
	"""Round 3: the verges over the whole campus (campus UV2). R bare dirt: along the kerbs and the forecourts' edging,
	round every tree's foot, along the walked lines (the routes round the buildings, the north loop round the stadium,
	the fences' feet), in big worn patches; G wet."""
	x, z, shape = _campus_grid()
	rng = np.random.default_rng(264_32)
	big = smooth_noise(rng, shape, 90)
	mid = smooth_noise(rng, shape, 20)
	fine = smooth_noise(rng, shape, 4)
	edge = np.full(shape, 99.0)
	for name, x0, x1, z0, z1, along in L.ROADS:
		edge = np.minimum(edge, _box_dist(x, z, x0 - L.KERB, x1 + L.KERB, z0 - L.KERB, z1 + L.KERB))
	for name, x0, x1, z0, z1 in L.FORECOURTS:
		edge = np.minimum(edge, _box_dist(x, z, x0 - L.EDGE, x1 + L.EDGE, z0 - L.EDGE, z1))
	trunks = np.zeros(shape)
	for pts in L.foliage_points("tree").values():
		for tx, _ty, tz in pts:
			trunks = np.maximum(trunks, np.exp(-(((x - tx) ** 2 + (z - tz) ** 2) / 1.6 ** 2)))
	walk = np.zeros(shape)
	for x0, x1, z0, z1 in (L.BUILDING_A["x"] + L.BUILDING_A["z"], L.LECTURE["x"] + L.LECTURE["z"], L.GYM["x"] + L.GYM["z"]):
		d = _box_dist(x, z, x0, x1, z0, z1)
		walk = np.maximum(walk, np.exp(-((d - 0.9) / 0.8) ** 2))
	walk = np.maximum(walk, np.exp(-((z - 245.0) / 1.4) ** 2) * ((x > 100) & (x < 312)))     # the north loop (walked, T-261)
	walk = np.maximum(walk, np.exp(-((x - 310.0) / 1.4) ** 2) * ((z > 166) & (z < 245)))
	for fx in (L.CAMPUS[0], L.CAMPUS[1]):
		walk = np.maximum(walk, 0.6 * np.exp(-((x - fx) / 1.2) ** 2))
	walk = np.maximum(walk, 0.6 * np.exp(-((z - L.CAMPUS[3]) / 1.2) ** 2))
	walk *= smoothstep(-1.0, 0.6, mid + 0.4 * fine)
	dirt = np.clip(0.75 * np.exp(-edge / 0.9) + 0.8 * trunks + 0.7 * walk + 0.35 * smoothstep(0.7, 2.0, big + 0.5 * mid) + 0.12 * fine, 0, 1)
	wet = np.clip(0.5 * np.exp(-edge / 0.5) * smoothstep(-0.3, 1.2, big) + 0.5 * smoothstep(1.9, 2.5, big + 0.3 * mid), 0, 1)
	save("mask_verge7.png", np.dstack([dirt, wet, np.zeros_like(x), np.ones_like(x)]), "RGBA")


def tree_far():
	"""Far cards (crossed quads, past 85 m): each species' crown drawn from its own leaf atlas cells over a crown profile,
	the trunk under it; RGBA 512 x 512, alpha cut. The shapes follow build_wave7_rest.py's trees (heights, crown spans)."""
	shapes = {
		# (crown bottom, crown top, trunk top, half width at a height fraction 0..1 of the crown, tiers)
		"bang": (3.8, 11.6, 10.5, lambda t: 4.4 * (1 - t) ** 0.9 + 0.5, 5),
		"phuong": (3.4, 8.2, 4.5, lambda t: 6.6 * np.sqrt(np.clip(1 - ((t - 0.35) / 0.68) ** 2, 0, 1)), 0),
		"xacu": (4.8, 13.6, 11.0, lambda t: 4.2 * np.sqrt(np.clip(1 - ((t - 0.42) / 0.6) ** 2, 0, 1)), 0),
	}
	size = 512
	span = 14.0   # the card is 14 m wide, 14 m tall (Godot metres), its foot at the trunk's foot
	for sp, (y0, y1, trunk_top, half, tiers) in shapes.items():
		atlas = np.asarray(Image.open(OUT / f"leaf_{sp}.png").convert("RGBA"), np.float64) / 255.0
		rng = np.random.default_rng({"bang": 1, "phuong": 2, "xacu": 3}[sp] + 264_40)
		out = np.zeros((size, size, 4))
		px = size / span
		# Trunk: a tapered strip of the bark colour.
		bark = np.asarray(Image.open(OUT / f"bark_{sp}_color.png").convert("RGB"), np.float64).mean(axis=(0, 1)) / 255.0 * 0.7
		for row in range(size):
			h = (size - 1 - row) / px
			if h > trunk_top:
				continue
			w = (0.22 - 0.12 * h / trunk_top) * px
			c0, c1 = int(size / 2 - w), int(size / 2 + w) + 1
			out[row, c0:c1, :3] = bark * (0.8 + 0.2 * (row % 7 == 0))
			out[row, c0:c1, 3] = 1.0
		# Leaf sprays: random cells of the atlas, scaled to 1.4..2.2 m, inside the crown profile; darker inside and below.
		count = {"bang": 260, "phuong": 300, "xacu": 380}[sp]
		cells = [(0, 0), (512, 0), (0, 512), (512, 512)]
		for k in range(count):
			t = rng.uniform(0, 1) ** 0.85
			if tiers:
				t = (np.floor(t * tiers) + rng.uniform(0.2, 0.8)) / tiers
			yy = y0 + t * (y1 - y0)
			hw = float(half(t))
			xx = rng.uniform(-hw, hw)
			s = rng.uniform(1.4, 2.2) * px
			if sp == "bang":
				cx, cy = cells[rng.integers(0, 2)]
			elif sp == "phuong":   # fronds, a flower spray now and then (as the near tree: cell 3 on half its twigs)
				cx, cy = cells[3] if rng.random() < 0.1 else cells[rng.integers(0, 3)]
			else:
				cx, cy = cells[rng.integers(0, 4)]
			src = atlas[cy:cy + 512, cx:cx + 512]
			n = max(4, int(s))
			idx = (np.arange(n) * 512 / n).astype(int)
			spr = src[idx][:, idx]
			if rng.random() < 0.5:
				spr = spr[:, ::-1]
			shade = 0.55 + 0.45 * (t * 0.6 + 0.4) * (0.6 + 0.4 * abs(xx) / max(hw, 0.1))
			r0 = int(size - 1 - yy * px - n / 2)
			c0 = int(size / 2 + xx * px - n / 2)
			ra, rb = max(r0, 0), min(r0 + n, size)
			ca, cb = max(c0, 0), min(c0 + n, size)
			if ra >= rb or ca >= cb:
				continue
			piece = spr[ra - r0:rb - r0, ca - c0:cb - c0]
			a = (piece[..., 3:4] > 0.5).astype(np.float64)
			out[ra:rb, ca:cb, :3] = out[ra:rb, ca:cb, :3] * (1 - a) + piece[..., :3] * shade * a
			out[ra:rb, ca:cb, 3:4] = np.maximum(out[ra:rb, ca:cb, 3:4], a)
		save(f"tree_far_{sp}.png", out, "RGBA")


def paint_line():
	"""Worn white road paint 2 m long (1024 px) by 12 cm (64 px), alpha cut: chipped edges, holes where tyres rub."""
	w, h = 1024, 64
	rng = np.random.default_rng(264_23)
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	n = smooth_noise(rng, (h, w), 6)
	fine = smooth_noise(rng, (h, w), 1.5)
	edge = smoothstep(0, 6, v) * smoothstep(h, h - 6, v)
	alpha = np.clip(edge * smoothstep(-0.9, -0.2, n + 0.4 * fine), 0, 1)
	rgb = np.dstack([np.full((h, w), 0.78), np.full((h, w), 0.77), np.full((h, w), 0.72)]) * (1 + 0.06 * fine)[..., None]
	save("paint_line.png", np.dstack([rgb, alpha]), "RGBA")


# ---------------------------------------------------------------------------------------------- palette

PALETTE = {
	"black": (0.04, 0.04, 0.045), "rubber": (0.06, 0.06, 0.06), "chrome": (0.6, 0.6, 0.58), "steel_grey": (0.33, 0.34, 0.34),
	"moped_red": (0.5, 0.08, 0.06), "moped_blue": (0.12, 0.2, 0.45), "seat": (0.06, 0.05, 0.05), "lamp_red": (0.45, 0.04, 0.03),
	"lamp_white": (0.75, 0.75, 0.7), "curtain_blue": (0.18, 0.26, 0.42), "curtain_green": (0.2, 0.32, 0.24),
	"curtain_beige": (0.55, 0.5, 0.4), "curtain_pink": (0.55, 0.36, 0.38), "silhouette": (0.025, 0.024, 0.022),
	"towel_white": (0.7, 0.7, 0.66), "clothes_blue": (0.15, 0.25, 0.5), "clothes_red": (0.5, 0.12, 0.1), "terrazzo": (0.55, 0.54, 0.5),
	"concrete": (0.5, 0.49, 0.46), "door_green": (0.2, 0.34, 0.27), "door_blue": (0.18, 0.3, 0.45), "ac_white": (0.78, 0.78, 0.74),
	"pvc_grey": (0.52, 0.53, 0.52), "rust": (0.35, 0.18, 0.08), "paper": (0.85, 0.83, 0.76), "flower_red": (0.75, 0.12, 0.05),
	# Round 3 (appended: the cells above keep their places): mopeds, the kiosk, signs.
	"moped_yellow": (0.6, 0.48, 0.1), "moped_grey": (0.24, 0.25, 0.27), "kiosk_yellow": (0.62, 0.5, 0.24), "kiosk_blue": (0.24, 0.42, 0.5),
	"kiosk_red": (0.55, 0.2, 0.15), "awning_red": (0.48, 0.07, 0.05), "sign_blue": (0.06, 0.18, 0.4), "sign_white": (0.78, 0.78, 0.75),
	"shutter_grey": (0.36, 0.37, 0.38),
}


def palette():
	size, cell = 64, 8
	rng = np.random.default_rng(264_30)
	weave = smooth_noise(rng, size, 1.0) * 0.03
	rgb = np.zeros((size, size, 3))
	index = {}
	for i, (key, col) in enumerate(PALETTE.items()):
		cy, cx = divmod(i, 8)
		rgb[cy * cell:(cy + 1) * cell, cx * cell:(cx + 1) * cell] = col
		index[key] = [cx, cy]
	rgb *= (1.0 + weave)[..., None]
	save("palette7.png", rgb)
	(HERE / "palette7.json").write_text(json.dumps(index, indent=0), encoding="utf-8", newline="\n")


# Round 3 replaces the pilot's two masks (the Avenue stretch) by the whole campus's (same files, campus UV2).
ALL = {"leaf_bang": leaf_bang, "leaf_phuong": leaf_phuong, "leaf_xacu": leaf_xacu, "barks": barks, "interior_atlas": interior_atlas,
	"mask_facades": mask_facades, "mask_road": mask_road_campus, "mask_verge": mask_verge_campus, "paint_line": paint_line,
	"palette": palette, "tree_far": tree_far}

if __name__ == "__main__":
	for key in sys.argv[1:] or list(ALL):
		ALL[key]()
