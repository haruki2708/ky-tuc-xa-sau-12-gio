"""T-265 wave 8: the library's textures, drawn by code (numpy + Pillow), no AI image, no download.

  mask_floor8.png      UV2 of the three floors (wave8_layout.floor_uv2: one row per floor, x 45..85, z 195..225):
                       R grout dirt, G grime, B wet, A wear (room407_shell kind 1)
  mask_ceiling8.png    the same rows for the ceilings: G dust round the lights, B water stains, A mould
  mask_walls8.png      UV2 rows (wave8_layout.wall_uv2): the inside walls of floors 1, 2, 3 and the outside walls (all four
                       faces unrolled); R paint loss, G grime, B water runs, A mould (kind 0)
  books.png            the book atlas: 48 spines (cloth, leather, paper; faded colours, gold or white bands, a library
                       label with a call number in blocks, no readable word) over the page edges and the covers
  map_print.png        M1 map: the campus plan printed in colour (the five PS1 blocks where the PS1 drew them, the other
                       three of chapter 4's map document), the two red marker rings round dormitories A and B
  map_drawn.png        M2 map: the same plan drawn by hand in marker on squared paper
  sign_library.png     "THƯ VIỆN" in raised letters for the E2 facade (Be Vietnam Pro)
  washed_stone_*.png   E2: "đá rửa" (washed pebble render) 1 m per 1024 px (colour, normal, ORM)
  palette8.png         8 x 8 flat cells for the small things (palette8.json)
Run: python -B art_source/graphics_upgrade/realistic_map/wave8/make_wave8_textures.py [name ...]
"""
from pathlib import Path
import json
import math
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
sys.path.insert(0, str(HERE.parent / "wave3"))
import make_wave3_textures as T3  # noqa: E402  (helpers only; its main is guarded)
import wave8_layout as L  # noqa: E402

ROOT = HERE.parents[3]
OUT = ROOT / "game/assets/textures/graphics_pilot/realistic_map/wave8"
FONT_BOLD = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_regular.ttf"
smooth_noise, smoothstep, wrap_normal = T3.smooth_noise, T3.smoothstep, T3.wrap_gradient_normal


def save(name, arr, mode="RGB"):
	OUT.mkdir(parents=True, exist_ok=True)
	img = Image.fromarray((np.clip(arr, 0.0, 1.0) * 255.0 + 0.5).astype(np.uint8), mode)
	img.save(OUT / name, optimize=True)
	print("T265_TEX", name, img.size)


def blur(a, r):
	img = Image.fromarray(np.clip(a * 255.0, 0, 255).astype(np.uint8))
	return np.asarray(img.filter(ImageFilter.GaussianBlur(r)), np.float64) / 255.0


def _seg_dist(px, pz, a, b):
	ax, az = a
	bx, bz = b
	dx, dz = bx - ax, bz - az
	t = np.clip(((px - ax) * dx + (pz - az) * dz) / max(dx * dx + dz * dz, 1e-9), 0, 1)
	return np.hypot(px - (ax + t * dx), pz - (az + t * dz))


def _box_dist(x, z, x0, x1, z0, z1):
	return np.hypot(np.maximum(np.maximum(x0 - x, x - x1), 0), np.maximum(np.maximum(z0 - z, z - z1), 0))


# ---------------------------------------------------------------------------------------------- masks

def _floor_rows(size):
	"""Per floor row: world x, z of each texel."""
	rh = size // 3
	v, u = np.mgrid[0:rh, 0:size].astype(np.float64) + 0.5
	return L.IN_W + u / size * (L.IN_E - L.IN_W), L.IN_S + v / rh * (L.IN_N - L.IN_S), rh


def mask_floor8():
	size = 1024
	x, z, rh = _floor_rows(size)
	rng = np.random.default_rng(265_01)
	out = np.zeros((size, size, 4))
	walls = np.minimum.reduce([x - L.IN_W, L.IN_E - x, z - L.IN_S, L.IN_N - z])
	for level in range(3):
		n1 = smooth_noise(rng, (rh, size), 5)
		n2 = smooth_noise(rng, (rh, size), 30)
		dust = (0.15, 0.25, 0.5)[level]
		r = np.clip(0.5 + 0.25 * n2 + 0.3 * np.exp(-walls / 0.5) + 0.3 * dust, 0, 1)
		grime = dust + 0.12 * n2 + 0.65 * np.exp(-walls / 0.3)
		for sx in L.SHELF_X:
			sz = L.SHELF_Z[level]
			grime += 0.45 * np.exp(-_box_dist(x, z, sx - 1.55, sx + 1.55, sz - 0.32, sz + 0.32) / 0.25)
		if level == 1:
			for tx in L.TABLES_X:
				grime += 0.3 * np.exp(-_box_dist(x, z, tx - 1.5, tx + 1.5, L.TABLE_Z - 1.6, L.TABLE_Z + 1.6) / 0.4)
		if level == 0:
			cx, _, cz = L.COUNTER["at"]
			grime += 0.4 * np.exp(-_box_dist(x, z, cx - 2.5, cx + 2.5, cz - 0.7, cz + 0.7) / 0.3)
			grime += 0.35 * np.exp(-_box_dist(x, z, 63.6, 66.4, 195.1, 196.8) / 0.3)    # the barricade
		wear = np.zeros_like(x)
		paths = [((46.0, 211.0), (78.0, 211.0), 1.1), ((65.0, 196.5), (65.0, 224.5), 1.0), ((77.5, 197.0), (77.5, 211.0), 0.5),
			((78.0, 197.0), (84.0, 197.0), 0.7), ((81.0, 209.0), (81.0, 213.0), 0.8)]
		if level == 0:
			paths += [((60.0, 207.6), (65.0, 211.0), 0.6), ((46.5, 211.0), (48.0, 211.0), 0.6)]
		if level == 1:
			paths += [((60.2, 216.0), (63.0, 211.0), 0.6)]
		for a, b, w in paths:
			wear += np.exp(-(_seg_dist(x, z, a, b) / w) ** 2)
		wear = np.clip(wear * (0.7 - 0.2 * level + 0.25 * n1), 0, 1)
		wet = np.zeros_like(x)
		if level == 0:
			wet += smoothstep(2.6, 0.4, np.hypot(x - 65.0, (z - 224.6) * 1.4) + 0.4 * n1)      # rain tracked in at the back door
		for wx in L.WINDOWS_X:
			for wz in (L.IN_S, L.IN_N):
				wet += 0.6 * (level == 2) * smoothstep(0.9, 0.2, np.hypot((x - wx) / 1.4, z - wz) + 0.3 * n1)
		block = np.dstack([r, np.clip(grime * (0.85 + 0.2 * n1), 0, 1), np.clip(wet, 0, 1), wear])
		out[level * rh:(level + 1) * rh] = block
	save("mask_floor8.png", out, "RGBA")


def mask_ceiling8():
	size = 1024
	x, z, rh = _floor_rows(size)
	rng = np.random.default_rng(265_02)
	out = np.zeros((size, size, 4))
	walls = np.minimum.reduce([x - L.IN_W, L.IN_E - x, z - L.IN_S, L.IN_N - z])
	for level in range(3):
		n1 = smooth_noise(rng, (rh, size), 5)
		n2 = smooth_noise(rng, (rh, size), 40)
		grime = 0.15 + 0.1 * n2 + 0.4 * np.exp(-walls / 0.4)
		for lx in L.LIGHTS_X:
			grime += 0.5 * np.exp(-((np.abs(x - lx) - 0.65).clip(0) ** 2 + (np.abs(z - L.LIGHT_Z) - 0.12).clip(0) ** 2) / 0.15)
		stain = np.zeros_like(x)
		spots = [(52.0, 199.0, 1.4), (63.0, 221.0, 1.0), (76.0, 214.0, 1.8)]
		if level == 2:
			spots += [(48.0, 220.0, 2.4), (58.0, 205.0, 1.7), (70.0, 200.0, 2.1), (82.0, 222.0, 1.5), (66.0, 213.0, 1.2)]
		for cx, cz, rr in spots:
			d = np.hypot(x - cx, (z - cz) * 1.15) / rr + 0.25 * n1 + 0.15 * n2
			stain = np.maximum(stain, 0.65 * smoothstep(1.0, 0.6, d) + 0.35 * np.exp(-((d - 0.95) / 0.05) ** 2))
		mould = np.clip(0.8 * np.exp(-walls / 0.25) * smoothstep(-0.2, 1.0, n2) + 0.5 * stain * smoothstep(0.5, 1.5, n1), 0, 1)
		out[level * rh:(level + 1) * rh] = np.dstack([np.zeros_like(x), np.clip(grime, 0, 1), np.clip(stain, 0, 1), mould])
	save("mask_ceiling8.png", out, "RGBA")


def mask_walls8():
	w, h = 2048, 1024
	rows = L.WALL_ROWS
	rh = h // rows
	rng = np.random.default_rng(265_03)
	out = np.zeros((h, w, 4))
	n1 = smooth_noise(rng, (h, w), 5)
	n2 = smooth_noise(rng, (h, w), 30)
	streak = smooth_noise(rng, (h, w), 2.0, aspect=12.0)
	for row in range(rows):
		length, height = L.WALL_ROW_SIZE[row]
		v, u = np.mgrid[0:rh, 0:w].astype(np.float64) + 0.5
		s = u / w * length
		y = (1.0 - v / rh) * height
		a, b = n1[row * rh:(row + 1) * rh], n2[row * rh:(row + 1) * rh]
		st = streak[row * rh:(row + 1) * rh]
		if row < 3:
			grime = 0.12 + 0.07 * b + 0.3 * smoothstep(0.9, 0.0, y) + 0.2 * smoothstep(2.6, 3.3, y) + 0.08 * row
			peel = 0.2 * smoothstep(0.9, 2.2, b + 0.5 * a) + 0.3 * smoothstep(0.6, 0.0, y) * smoothstep(0.2, 1.4, b) + 0.1 * row * smoothstep(0.5, 1.5, b)
			stain = 0.0 * s
			mould = 0.5 * smoothstep(0.5, 0.0, y) * smoothstep(-0.3, 1.0, b)
			# Runs under each window (the walls are solid; the frames leaked), more on the top floor under the roof.
			for k, wx in enumerate(L.WINDOWS_X):
				for s0 in (wx - L.IN_W, L.RUN_BACK + (L.IN_E - wx)):
					under = smoothstep(1.5, 1.0, np.abs(s - s0)) * smoothstep(1.2, 0.9, y) * smoothstep(-0.5, 1.2, st)
					stain = np.maximum(stain, (0.5 + 0.2 * row) * under)
			if row == 2:
				for leak in (8.0, 31.0, 52.0, 77.0, 96.0, 121.0):
					stain = np.maximum(stain, 0.8 * smoothstep(1.4, 0.2, np.abs(s - leak) * 1.6 + 0.4 * a) * smoothstep(1.0, 3.3, y + 1.4 * st))
			if row == 0:
				# Hands at the back door (back wall s RUN_BACK + 20) and round the map board (west wall, z 211).
				for door_s in (L.RUN_BACK + (L.IN_E - 65.0),):
					grime = grime + 0.5 * np.exp(-((s - door_s) / 1.6) ** 2) * smoothstep(0.5, 1.0, y) * smoothstep(2.0, 1.4, y)
		else:
			grime = 0.15 + 0.08 * b + 0.4 * smoothstep(0.6, 0.0, y) + 0.25 * smoothstep(9.5, 10.4, y)
			peel = 0.25 * smoothstep(0.8, 2.0, b + 0.5 * a)
			stain = 0.6 * smoothstep(8.6, 10.3, y) * smoothstep(-0.4, 1.2, st)
			for k in range(3):
				base = L.FLOOR_H * k
				for wx in L.WINDOWS_X:
					for s0 in (wx - L.OUT_W, L.OUT_RUN_BACK + (L.OUT_E - wx)):
						under = smoothstep(1.4, 0.7, np.abs(s - s0)) * smoothstep(base + 1.1, base + 0.4, y) * smoothstep(base - 0.6, base + 0.4, y) * smoothstep(-0.6, 1.0, st)
						stain = np.maximum(stain, 0.8 * under)
			mould = 0.6 * smoothstep(0.4, 0.0, y) * smoothstep(-0.5, 0.8, a) + 0.4 * smoothstep(9.8, 10.4, y) * smoothstep(0.0, 1.0, b)
			# The back door (back face s OUT_RUN_BACK + 20): hands and the zombies' hammering, mud splashed up.
			door_s = L.OUT_RUN_BACK + (L.OUT_E - 65.0)
			grime = grime + 0.6 * np.exp(-((s - door_s) / 1.8) ** 2) * smoothstep(2.4, 0.2, y)
		out[row * rh:(row + 1) * rh, :, 0] = np.clip(peel, 0, 1)
		out[row * rh:(row + 1) * rh, :, 1] = np.clip(grime * (0.85 + 0.25 * a), 0, 1)
		out[row * rh:(row + 1) * rh, :, 2] = np.clip(stain, 0, 1)
		out[row * rh:(row + 1) * rh, :, 3] = np.clip(mould, 0, 1)
	save("mask_walls8.png", out, "RGBA")


# ---------------------------------------------------------------------------------------------- books

BOOK_COLOURS = [(0.42, 0.11, 0.09), (0.12, 0.2, 0.36), (0.13, 0.28, 0.18), (0.36, 0.25, 0.14), (0.09, 0.09, 0.1), (0.62, 0.55, 0.42),
	(0.5, 0.18, 0.12), (0.2, 0.33, 0.42), (0.55, 0.42, 0.18), (0.32, 0.12, 0.22), (0.7, 0.66, 0.56), (0.22, 0.22, 0.26),
	(0.6, 0.3, 0.12), (0.16, 0.38, 0.36), (0.75, 0.7, 0.6), (0.4, 0.38, 0.3)]


def books():
	"""1024 x 1024: 16 x 3 spines (64 x 256 px, u across the spine, v down it) over a page-edge strip (512 x 256, lines along
	u) and a cover strip (512 x 256, the cloth)."""
	size = 1024
	rng = np.random.default_rng(265_04)
	img = np.zeros((size, size, 3))
	fine = smooth_noise(rng, size, 1.5)
	mid = smooth_noise(rng, size, 12)
	for row in range(3):
		for col in range(16):
			x0, y0 = col * 64, row * 256
			k = row * 16 + col
			base = np.array(BOOK_COLOURS[(k * 7 + row) % len(BOOK_COLOURS)]) * rng.uniform(0.85, 1.12)
			cell = np.ones((256, 64, 3)) * base
			cell *= (1 + 0.06 * fine[y0:y0 + 256, x0:x0 + 64] + 0.08 * mid[y0:y0 + 256, x0:x0 + 64])[..., None]
			# Rounded spine: darker towards both edges; faded at the top (the light), worn at the head and tail.
			u = (np.arange(64) + 0.5) / 64
			cell *= (0.72 + 0.28 * np.sin(u * math.pi) ** 0.6)[None, :, None]
			fade = np.linspace(0.18, 0.0, 256)[:, None, None] * rng.uniform(0.3, 1.0)
			cell = cell * (1 - fade) + np.array([0.72, 0.68, 0.6]) * fade
			gold = rng.random() < 0.6
			band = np.array([0.72, 0.6, 0.32]) if gold else np.array([0.85, 0.82, 0.74])
			for yb in (14 + rng.integers(0, 6), 236 - rng.integers(0, 6)):
				cell[yb:yb + 3] = band * (0.8 + 0.2 * rng.random())
				if rng.random() < 0.5:
					cell[yb + 6:yb + 8] = band * 0.85
			# Title as blocks of gold or ink (no readable word), a library label near the tail with call-number marks.
			ty = 40 + rng.integers(0, 30)
			for line in range(rng.integers(1, 3)):
				length = min(int(rng.integers(40, 110)), 180 - ty)
				if length < 12:
					break
				cell[ty:ty + length, 26:38] = cell[ty:ty + length, 26:38] * 0.4 + band * 0.6
				for gap in range(ty + 8, ty + length, rng.integers(9, 16)):
					cell[gap:gap + 2, 24:40] = cell[gap - 3, 10]
				ty += length + 16
			if rng.random() < 0.85:
				ly = 188 + rng.integers(-10, 8)
				cell[ly:ly + 30, 8:56] = np.array([0.86, 0.84, 0.76]) * rng.uniform(0.85, 1.0)
				for mark in range(3):
					cell[ly + 6 + mark * 8:ly + 10 + mark * 8, 16:16 + rng.integers(14, 32)] = (0.2, 0.18, 0.16)
			# Scuffs and a water stain on some.
			if rng.random() < 0.3:
				sy = rng.integers(60, 200)
				stain = np.exp(-(((np.arange(256) - sy) / 30.0) ** 2))[:, None, None] * 0.25
				cell = cell * (1 - stain) + np.array([0.55, 0.45, 0.3]) * stain
			img[y0:y0 + 256, x0:x0 + 64] = cell
	# Page edges: cream with fine lines along u, yellowed toward the outside.
	y0 = 768
	v = (np.arange(256) + 0.5) / 256
	lines = 0.92 + 0.08 * np.sin(np.arange(512)[None, :] * 0.9 + fine[y0:y0 + 256, :512] * 2.0)
	paper = np.array([0.86, 0.82, 0.7])[None, None] * lines[..., None]
	paper *= (0.85 + 0.15 * np.sin(v * math.pi))[:, None, None]
	img[y0:, :512] = paper * (1 + 0.04 * mid[y0:, :512])[..., None]
	# Covers: book cloth (a weave), mid grey-brown; the atlas' spines tint it per book in the mesh's UVs (cells).
	weave = 0.9 + 0.05 * np.sin(np.arange(512)[None, :] * 1.7) + 0.05 * np.sin(np.arange(256)[:, None] * 1.7)
	img[y0:, 512:] = np.array([0.42, 0.36, 0.3])[None, None] * (weave * (1 + 0.08 * mid[y0:, 512:]))[..., None]
	save("books.png", img)


# ---------------------------------------------------------------------------------------------- the campus map

MAP_PX = (2048, 1342)   # the paper 2.9 x 1.9 m (MapBoard/Paper)


def _map_xy(lx, ly):
	w, h = MAP_PX
	return ((lx + 1.45) / 2.9 * w, (0.95 - ly) / 1.9 * h)


def _font(size, bold=False):
	return ImageFont.truetype(str(FONT_BOLD if bold else FONT), int(size))


def _rot_text(base, xy, text, font, fill, angle=0.0):
	layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
	ImageDraw.Draw(layer).text(xy, text, font=font, fill=fill, anchor="mm")
	if angle:
		layer = layer.rotate(angle, center=xy, resample=Image.BICUBIC)
	base.alpha_composite(layer)


def _map_rings(img, ss, strength, rng, width=10):
	"""The two red marker rings where the PS1 FadedCircle0_*/1_* run: ellipses r 0.51 x 0.24 round (-0.7, 0.57), (0.6, 0.45)."""
	layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
	d = ImageDraw.Draw(layer)
	for cx, cy in ((-0.7, 0.57), (0.6, 0.45)):
		pts = []
		for j in range(181):
			a = j / 180 * math.tau * 1.04
			r = 0.51 + 0.008 * math.sin(a * 7)
			px, py = _map_xy(cx + r * math.cos(a), cy + 0.24 * math.sin(a))
			pts.append((px * ss, py * ss))
		d.line(pts, fill=(176, 28, 26, int(255 * strength)), width=int(width * ss), joint="curve")
	layer = layer.filter(ImageFilter.GaussianBlur(1.2 * ss))
	img.alpha_composite(layer)


def _blocks():
	"""(label, x, y, w, h): the five PS1 blocks as the PS1 drew them (MapBoard/DormB...), then the other three places of
	chapter 4's map document where they stand on the campus (lecture halls south-west, the gym west, the gate north-east)."""
	return [("KÝ TÚC XÁ B", -0.7, 0.57, 0.8, 0.22), ("KÝ TÚC XÁ A", 0.6, 0.45, 0.7, 0.28), ("THƯ VIỆN", -0.7, -0.55, 0.5, 0.35),
		("NHÀ ĂN", 0.8, -0.1, 0.4, 0.26), ("SÂN VẬN ĐỘNG", 0.7, -0.65, 0.55, 0.42), ("GIẢNG ĐƯỜNG", -1.18, -0.5, 0.36, 0.2),
		("NHÀ THI ĐẤU", -1.18, 0.0, 0.34, 0.3), ("CỔNG TRƯỜNG", 1.24, 0.78, 0.24, 0.08)]


def map_print():
	ss = 2
	w, h = MAP_PX
	img = Image.new("RGBA", (w * ss, h * ss), (233, 229, 214, 255))
	d = ImageDraw.Draw(img)
	rng = np.random.default_rng(265_05)
	# Campus ground (pale green), the wall round it, roads (grey) and the avenue, paths.
	X = lambda lx, ly: tuple(v * ss for v in _map_xy(lx, ly))  # noqa: E731
	d.rectangle([X(-1.38, 0.84), X(1.38, -0.9)], fill=(206, 222, 190, 255), outline=(120, 120, 110, 255), width=6 * ss)
	for (ax, ay, bx, by, wd) in [(-1.38, 0.72, 1.38, 0.72, 0.07), (0.15, 0.84, 0.15, -0.9, 0.06), (-1.38, -0.3, 1.38, -0.3, 0.05),
			(1.08, 0.86, 1.08, -0.9, 0.05)]:
		d.line([X(ax, ay), X(bx, by)], fill=(176, 176, 170, 255), width=int(wd / 1.9 * h * ss))
	for label, x, y, bw, bh in _blocks():
		col = (128, 140, 160, 255) if not label.startswith("SÂN") else (150, 120, 100, 255)
		if label == "THƯ VIỆN":
			col = (170, 128, 70, 255)
		d.rectangle([X(x - bw / 2, y + bh / 2), X(x + bw / 2, y - bh / 2)], fill=col, outline=(60, 60, 60, 255), width=3 * ss)
		if label.startswith("SÂN"):
			d.ellipse([X(x - bw / 2 + 0.05, y + bh / 2 - 0.05), X(x + bw / 2 - 0.05, y - bh / 2 + 0.05)], outline=(240, 240, 230, 255), width=4 * ss)
		size = 34 if bw > 0.45 else 26
		d.text(X(x, (y + bh / 2 + 0.05) if y - bh / 2 < -0.8 else (y - bh / 2 - 0.06)), label, font=_font(size * ss, True), fill=(40, 40, 40, 255), anchor="mm")
	# Title, compass, legend, scale and a "you are here" dot at the library.
	d.text(X(0.0, 0.895), "SƠ ĐỒ KHUÔN VIÊN", font=_font(48 * ss, True), fill=(30, 50, 90, 255), anchor="mm")
	cx, cy = X(1.3, -0.78)
	d.polygon([(cx, cy - 60 * ss), (cx - 18 * ss, cy), (cx + 18 * ss, cy)], fill=(40, 40, 40, 255))
	d.text((cx, cy + 22 * ss), "B", font=_font(30 * ss, True), fill=(40, 40, 40, 255), anchor="mm")
	px, py = X(-0.7, -0.52)
	d.ellipse([px - 16 * ss, py - 16 * ss, px + 16 * ss, py + 16 * ss], fill=(200, 40, 30, 255))
	d.text(X(-0.7, -0.64), "BẠN ĐANG Ở ĐÂY", font=_font(22 * ss, True), fill=(250, 240, 225, 255), anchor="mm")
	img = img.resize((w, h), Image.LANCZOS)
	# Faded print: sun-bleached toward the top, foxing spots, a crease.
	arr = np.asarray(img, np.float64)[..., :3] / 255.0
	fine = smooth_noise(rng, (h, w), 2.0)
	mid = smooth_noise(rng, (h, w), 40)
	bleach = np.linspace(0.25, 0.05, h)[:, None, None] * (1 + 0.3 * mid[..., None])
	arr = arr * (1 - bleach) + np.array([0.9, 0.88, 0.8]) * bleach
	spots = smoothstep(2.4, 3.2, smooth_noise(rng, (h, w), 6)) * 0.35
	arr = arr * (1 - spots[..., None]) + np.array([0.62, 0.5, 0.34]) * spots[..., None]
	arr *= (1 + 0.03 * fine)[..., None]
	img = Image.fromarray((np.clip(arr, 0, 1) * 255).astype(np.uint8)).convert("RGBA")
	big = img.resize((w * ss, h * ss), Image.BICUBIC)
	_map_rings(big, ss, 0.62, rng)
	save("map_print.png", np.asarray(big.resize((w, h), Image.LANCZOS).convert("RGB"), np.float64) / 255.0)


def map_drawn():
	ss = 2
	w, h = MAP_PX
	rng = np.random.default_rng(265_06)
	paper = np.ones((h, w, 3)) * np.array([0.9, 0.88, 0.8])
	paper *= (1 + 0.03 * smooth_noise(rng, (h, w), 3) + 0.04 * smooth_noise(rng, (h, w), 60))[..., None]
	grid = ((np.arange(w) % 40) < 2)[None, :] | ((np.arange(h) % 40) < 2)[:, None]
	paper[grid] = paper[grid] * 0.9 + np.array([0.55, 0.65, 0.75]) * 0.1
	img = Image.fromarray((np.clip(paper, 0, 1) * 255).astype(np.uint8)).convert("RGBA").resize((w * ss, h * ss), Image.BICUBIC)
	d = ImageDraw.Draw(img)
	X = lambda lx, ly: tuple(v * ss for v in _map_xy(lx, ly))  # noqa: E731
	ink = (40, 48, 70, 255)

	def wobbly_rect(x0, y0, x1, y1, width):
		pts = []
		for (ax, ay), (bx, by) in (((x0, y0), (x1, y0)), ((x1, y0), (x1, y1)), ((x1, y1), (x0, y1)), ((x0, y1), (x0, y0))):
			for t in np.linspace(0, 1, 8):
				pts.append(X(ax + (bx - ax) * t + rng.normal(0, 0.003), ay + (by - ay) * t + rng.normal(0, 0.003)))
		d.line(pts + [pts[0]], fill=ink, width=int(width * ss), joint="curve")

	wobbly_rect(-1.36, 0.83, 1.36, -0.88, 4)
	for (ax, ay, bx, by) in [(-1.36, 0.72, 1.36, 0.72), (0.15, 0.83, 0.15, -0.88), (-1.36, -0.3, 1.36, -0.3), (1.08, 0.84, 1.08, -0.88)]:
		d.line([X(ax, ay + 0.03), X(bx, by + 0.03)], fill=ink, width=2 * ss)
		d.line([X(ax, ay - 0.03), X(bx, by - 0.03)], fill=ink, width=2 * ss)
	for label, x, y, bw, bh in _blocks():
		wobbly_rect(x - bw / 2, y + bh / 2, x + bw / 2, y - bh / 2, 4)
		# Hatching.
		x0p, y0p = X(x - bw / 2, y + bh / 2)
		x1p, y1p = X(x + bw / 2, y - bh / 2)
		step = 18 * ss
		for k in range(int((x1p - x0p + y1p - y0p) / step)):
			a = x0p + k * step
			pts = [(max(x0p, a - (y1p - y0p)), y0p + (a - max(x0p, a - (y1p - y0p)))), (min(a, x1p), y0p + (a - min(a, x1p)))]
			pts = [(px, min(max(py, y0p), y1p)) for px, py in pts]
			d.line(pts, fill=(60, 70, 100, 110), width=1 * ss)
		_rot_text(img, X(x, (y + bh / 2 + 0.055) if y - bh / 2 < -0.8 else (y - bh / 2 - 0.065)), label, _font((30 if bw > 0.45 else 24) * ss), ink, angle=rng.uniform(-2.5, 2.5))
	_rot_text(img, X(0.0, 0.89), "SƠ ĐỒ KHUÔN VIÊN", _font(44 * ss, True), ink, angle=-1.2)
	_rot_text(img, X(1.3, -0.8), "↑ B", _font(34 * ss, True), ink)
	_map_rings(img, ss, 0.68, rng, width=12)
	# Tape at the corners (drawn later on the board in the mesh as well).
	for cx, cy in ((-1.42, 0.92), (1.42, 0.92), (-1.42, -0.92), (1.42, -0.92)):
		px, py = X(cx, cy)
		d.rectangle([px - 50 * ss, py - 20 * ss, px + 50 * ss, py + 20 * ss], fill=(230, 220, 170, 150))
	save("map_drawn.png", np.asarray(img.resize((w, h), Image.LANCZOS).convert("RGB"), np.float64) / 255.0)


# ---------------------------------------------------------------------------------------------- facade

def sign_library():
	w, h = 2048, 320       # 4.0 x 0.625 m
	ss = 2
	rng = np.random.default_rng(265_07)
	img = Image.new("L", (w * ss, h * ss), 0)
	d = ImageDraw.Draw(img)
	d.text((w * ss / 2, h * ss / 2), "THƯ VIỆN", font=_font(h * ss * 0.62, True), fill=255, anchor="mm")
	text = np.asarray(img.resize((w, h), Image.LANCZOS), np.float64) / 255.0
	shade = np.asarray(Image.fromarray((text * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(5)), np.float64) / 255.0
	# A deep red enamelled board (opaque), its paint chalky and streaked, brass letters with a drop shadow.
	board = np.array([0.3, 0.08, 0.06]) * (1 + 0.1 * smooth_noise(rng, (h, w), 20) + 0.05 * smooth_noise(rng, (h, w), 2))[..., None]
	runs = smoothstep(0.5, 2.0, smooth_noise(rng, (h, w), 3, aspect=10.0)) * np.linspace(0.1, 0.4, h)[:, None]
	board = board * (1 - runs[..., None]) + np.array([0.45, 0.4, 0.36]) * runs[..., None]
	board *= (1 - 0.45 * np.roll(np.roll(shade, 4, 0), 4, 1))[..., None]
	letters = np.array([0.74, 0.62, 0.36]) * (1 + 0.08 * smooth_noise(rng, (h, w), 4))[..., None]
	rust = smoothstep(1.2, 2.2, smooth_noise(rng, (h, w), 3)) * 0.4
	letters = letters * (1 - rust[..., None]) + np.array([0.35, 0.22, 0.12]) * rust[..., None]
	alpha = text[..., None]
	save("sign_library.png", letters * alpha + board * (1 - alpha))


def washed_stone():
	size, period = 1024, 1.0
	rng = np.random.default_rng(265_08)
	yy, xx = np.mgrid[0:size, 0:size].astype(np.float64)
	cement = np.ones((size, size, 3)) * np.array([0.5, 0.49, 0.46])
	height = np.zeros((size, size))
	rgb = cement * (1 + 0.05 * smooth_noise(rng, size, 6))[..., None]
	stones = [(0.86, 0.85, 0.82), (0.62, 0.6, 0.56), (0.25, 0.25, 0.26), (0.55, 0.47, 0.38), (0.75, 0.72, 0.66), (0.4, 0.38, 0.36)]
	n = 26000
	cx = rng.uniform(0, size, n)
	cy = rng.uniform(0, size, n)
	r = rng.uniform(2.0, 6.5, n)
	kinds = rng.integers(0, len(stones), n)
	for i in range(n):
		x0, x1 = int(cx[i] - r[i]) - 1, int(cx[i] + r[i]) + 2
		y0, y1 = int(cy[i] - r[i]) - 1, int(cy[i] + r[i]) + 2
		ys = np.arange(y0, y1) % size
		xs = np.arange(x0, x1) % size
		gy, gx = np.meshgrid(np.arange(y0, y1), np.arange(x0, x1), indexing="ij")
		d = np.hypot((gx - cx[i]) / 1.0, (gy - cy[i]) / rng.uniform(0.75, 1.0)) / r[i]
		inside = d < 1.0
		dome = np.sqrt(np.clip(1 - d * d, 0, 1))
		sub = height[np.ix_(ys, xs)]
		take = inside & (dome > sub)
		sub[take] = dome[take]
		height[np.ix_(ys, xs)] = sub
		col = np.array(stones[kinds[i]]) * rng.uniform(0.85, 1.12)
		patch = rgb[np.ix_(ys, xs)]
		patch[take] = col * (0.8 + 0.2 * dome[take])[..., None]
		rgb[np.ix_(ys, xs)] = patch
	ao = 0.55 + 0.45 * smoothstep(0.0, 0.5, height)
	rough = np.clip(0.75 - 0.25 * height, 0, 1)
	save("washed_stone_color.png", rgb * ao[..., None] ** 0.5)
	save("washed_stone_normal.png", wrap_normal(height.astype(np.float32) * 2.2, 1.0))
	save("washed_stone_orm.png", np.dstack([ao, rough, np.zeros_like(ao)]))


# ---------------------------------------------------------------------------------------------- palette

PALETTE = {
	"crt_beige": (0.66, 0.63, 0.55), "screen_dark": (0.03, 0.035, 0.04), "keyboard": (0.58, 0.56, 0.5), "black": (0.04, 0.04, 0.045),
	"stamp_red": (0.45, 0.08, 0.06), "ink_pad": (0.08, 0.1, 0.25), "plant_dead": (0.36, 0.3, 0.17), "leaf_dry": (0.45, 0.38, 0.2),
	"pot_terracotta": (0.5, 0.27, 0.16), "soil": (0.16, 0.12, 0.09), "trolley_grey": (0.38, 0.4, 0.4), "rubber": (0.05, 0.05, 0.05),
	"cardboard": (0.55, 0.43, 0.28), "tape": (0.7, 0.62, 0.42), "paper": (0.86, 0.84, 0.77), "newspaper": (0.68, 0.66, 0.6),
	"label_white": (0.9, 0.89, 0.84), "curtain_beige": (0.62, 0.57, 0.46), "curtain_green": (0.4, 0.47, 0.38), "curtain_blue": (0.36, 0.42, 0.5),
	"felt_green": (0.1, 0.25, 0.14), "brass": (0.55, 0.42, 0.2), "plastic_blue": (0.1, 0.22, 0.48), "plastic_red": (0.5, 0.1, 0.08),
	"tag_yellow": (0.75, 0.65, 0.2), "dust_sheet": (0.7, 0.68, 0.62), "binding_red": (0.35, 0.09, 0.07), "binding_green": (0.12, 0.23, 0.15),
	"binding_brown": (0.3, 0.2, 0.12), "ledger_blue": (0.1, 0.17, 0.3), "fan_cream": (0.74, 0.72, 0.64), "lamp_green": (0.12, 0.28, 0.2),
	"bulb_off": (0.6, 0.6, 0.56), "chrome": (0.55, 0.55, 0.55), "seat_vinyl": (0.18, 0.12, 0.1), "foam": (0.72, 0.62, 0.4),
	"cable": (0.08, 0.08, 0.08), "sticker_blue": (0.2, 0.35, 0.6), "chalk": (0.82, 0.82, 0.78), "rust": (0.38, 0.2, 0.1),
}


def palette():
	cells = {}
	img = np.zeros((512, 512, 3))
	rng = np.random.default_rng(265_09)
	for i, (key, rgb) in enumerate(PALETTE.items()):
		cx, cy = i % 8, i // 8
		cells[key] = [cx, cy]
		block = np.ones((64, 64, 3)) * np.array(rgb)
		block *= (1 + 0.05 * rng.normal(0, 1, (64, 64)))[..., None]
		img[cy * 64:(cy + 1) * 64, cx * 64:(cx + 1) * 64] = block
	save("palette8.png", img)
	(HERE / "palette8.json").write_text(json.dumps(cells, indent=0), encoding="utf-8", newline="\n")


ALL = {"mask_floor8": mask_floor8, "mask_ceiling8": mask_ceiling8, "mask_walls8": mask_walls8, "books": books, "map_print": map_print,
	"map_drawn": map_drawn, "sign_library": sign_library, "washed_stone": washed_stone, "palette": palette}


if __name__ == "__main__":
	names = sys.argv[1:] or list(ALL)
	for name in names:
		ALL[name]()
