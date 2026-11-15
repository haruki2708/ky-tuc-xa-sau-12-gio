"""T-263 wave 6: the canteen's textures, drawn by code (numpy + Pillow), no AI image, no download.

  ceramic_*.png         F1: cream glazed ceramic floor tiles 40 x 40 cm, 4 mm joints; 1.6 m per 1024 px (colour, normal, ORM)
  ceiling_panel_*.png   C2: mineral-fibre ceiling panels 60 x 60 cm in a white T-bar grid; 2.4 m per 1024 px
  mask_floor.png        UV2 over x 166..214, z 14..62 (hall, kitchen, store): R grout dirt, G grime, B wet, A wear
  mask_ceiling.png      the same square for the ceiling: G dust round the tubes and fans, B water stains, A mould
  mask_walls.png        UV2 rows (canteen_layout.wall_uv2): hall inside, kitchen and store inside, front facade, spare;
                        R paint loss, G grime, B water runs, A mould
  price_wood.png        the five price boards (PriceText0..4, their words unchanged) painted black on wood, white letters
  price_print.png       the same five as printed boards (white, blue dish, red price)
  sign_canteen.png      SignText "NHÀ ĂN SINH VIÊN" on the red board over the door (10 x 1 m)
  slogan.png            SloganText "TIẾT KIỆM LƯƠNG THỰC, KHÔNG BỎ PHÍ CƠM" (14 x 0.7 m)
  tv_screen.png         the TV's lit screen: a news programme's layout without words (emission)
  palette.png           8 x 8 flat cells for the tableware, food and small kitchen things (palette.json)
Round 2 (D-181):
  posters.png           four wordless posters (hand washing, a balanced plate, no smoking, fire safety; aged paper),
                        ReturnSign's "TRẢ KHAY" (words unchanged) as a blue enamel sign, a hazard sticker
  mask_strip6.png       UV2 of the A16 strip's lawn over x 166..218, z 13..60 (ground_blend: R bare dirt, G wet)
  mask_yard6.png        the same square for the pavers and the yard's concrete (R grout dirt, G grime, B wet, A wear)
  mask_walls.png        row 3 now ages the outside walls but the front (splash, rain runs, AC drips, kitchen soot)
Run: python -B art_source/graphics_upgrade/realistic_map/wave6/make_wave6_textures.py [name ...]
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
import canteen_layout as L  # noqa: E402

ROOT = HERE.parents[3]
OUT = ROOT / "game/assets/textures/graphics_pilot/realistic_map/wave6"
FONT_BOLD = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_regular.ttf"
smooth_noise, smoothstep, wrap_normal = T3.smooth_noise, T3.smoothstep, T3.wrap_gradient_normal


def save(name, arr, mode="RGB"):
	OUT.mkdir(parents=True, exist_ok=True)
	img = Image.fromarray((np.clip(arr, 0.0, 1.0) * 255.0 + 0.5).astype(np.uint8), mode)
	img.save(OUT / name, optimize=True)
	print("T263_TEX", name, img.size)


def blur(a, r):
	img = Image.fromarray(np.clip(a * 255.0, 0, 255).astype(np.uint8))
	return np.asarray(img.filter(ImageFilter.GaussianBlur(r)), np.float64) / 255.0


# ---------------------------------------------------------------------------------------------- floor tiles (F1)

def ceramic():
	size, period = 1024, 1.6
	m = period / size
	rng = np.random.default_rng(263_01)
	yy, xx = np.mgrid[0:size, 0:size].astype(np.float64) * m
	tile = 0.4
	fx, fy = (xx / tile) % 1.0, (yy / tile) % 1.0
	tid = (np.floor(xx / tile).astype(int) % 4) * 4 + (np.floor(yy / tile).astype(int) % 4)
	edge = np.minimum(np.minimum(fx, 1 - fx), np.minimum(fy, 1 - fy)) * tile   # metres to the joint centre line
	joint = 1.0 - smoothstep(0.0016, 0.0026, edge)
	bevel = smoothstep(0.002, 0.0045, edge)
	tone = rng.normal(0, 1, 16)
	big = smooth_noise(rng, size, 120)
	mid = smooth_noise(rng, size, 14)
	fine = smooth_noise(rng, size, 1.4)
	# Printed "granite" speckles of the cheap cream tile, a faint cloud, two tiles a shade darker.
	cream = np.array([0.80, 0.76, 0.66])
	rgb = cream[None, None] * (1 + 0.025 * tone[tid] + 0.03 * big + 0.02 * mid)[..., None]
	speck = smoothstep(1.6, 2.4, fine) * 0.6 + smoothstep(2.2, 2.8, -fine) * 0.4
	rgb = rgb * (1 - 0.28 * speck[..., None]) + np.array([0.55, 0.47, 0.38]) * 0.28 * speck[..., None]
	cloud = smoothstep(0.4, 1.6, mid + 0.6 * big)
	rgb = rgb * (1 - 0.07 * cloud[..., None]) + np.array([0.7, 0.62, 0.5]) * 0.07 * cloud[..., None]
	# One chipped corner and a hairline crack.
	crack = np.zeros((size, size))
	cx = (xx - 0.4 * 2.3) * 7.0
	line = np.abs((yy - 0.4 * 1.2) - 0.18 * np.sin(cx) - 0.4 * (xx - 0.92)) < 0.0012
	crack[(line) & (tid == 9)] = 1.0
	chip = ((fx > 0.93) & (fy > 0.93) & (tid == 4)).astype(np.float64)
	grout = np.array([0.42, 0.39, 0.34]) * (1 + 0.15 * mid)[..., None]
	rgb = rgb * (1 - joint[..., None]) + grout * joint[..., None]
	rgb = rgb * (1 - 0.6 * crack[..., None]) * (1 - 0.35 * chip[..., None])
	height = bevel * (1.0 + 0.004 * fine) - 0.6 * crack - 0.4 * chip
	ao = 0.55 + 0.45 * smoothstep(0.0, 0.006, edge)
	ao *= 1 - 0.3 * crack
	rough = np.clip(0.42 + 0.08 * mid + 0.45 * joint + 0.25 * chip, 0, 1)
	save("ceramic_color.png", rgb)
	save("ceramic_normal.png", wrap_normal(height.astype(np.float32) * 3.0, 1.0))
	save("ceramic_orm.png", np.dstack([ao, rough, np.zeros_like(ao)]))


# ---------------------------------------------------------------------------------------------- ceiling panels (C2)

def ceiling_panels():
	size, period = 1024, 2.4
	m = period / size
	rng = np.random.default_rng(263_02)
	yy, xx = np.mgrid[0:size, 0:size].astype(np.float64) * m
	panel = 0.6
	fx, fy = (xx / panel) % 1.0, (yy / panel) % 1.0
	pid = (np.floor(xx / panel).astype(int) % 4) * 4 + (np.floor(yy / panel).astype(int) % 4)
	edge = np.minimum(np.minimum(fx, 1 - fx), np.minimum(fy, 1 - fy)) * panel
	bar = 1.0 - smoothstep(0.011, 0.013, edge)            # 24 mm T-bar faces
	lip = smoothstep(0.012, 0.02, edge)
	tone = rng.normal(0, 1, 16)
	mid = smooth_noise(rng, size, 10)
	fine = smooth_noise(rng, size, 1.2)
	# Fissured mineral fibre: short dark worms.
	worms = smooth_noise(rng, size, 2.5, aspect=0.35) + 0.6 * smooth_noise(rng, size, 3.0, aspect=2.5)
	fissure = smoothstep(1.7, 2.3, worms) * lip
	pores = (rng.random((size, size)) < 0.02) * lip
	base = np.array([0.84, 0.83, 0.79])
	rgb = base[None, None] * (1 + 0.03 * tone[pid] + 0.025 * mid + 0.02 * fine)[..., None]
	rgb *= (1 - 0.32 * fissure - 0.15 * pores)[..., None]
	rgb = rgb * (1 - bar[..., None]) + np.array([0.86, 0.86, 0.83]) * bar[..., None]
	height = 0.5 * lip - 0.25 * fissure - 0.1 * pores + 0.02 * fine * lip + 0.6 * bar
	ao = 0.7 + 0.3 * (smoothstep(0.013, 0.03, edge) + bar).clip(0, 1)
	rough = np.clip(0.95 - 0.5 * bar, 0, 1)
	save("ceiling_panel_color.png", rgb)
	save("ceiling_panel_normal.png", wrap_normal(height.astype(np.float32) * 2.5, 1.0))
	save("ceiling_panel_orm.png", np.dstack([ao, rough, np.zeros_like(ao)]))


# ---------------------------------------------------------------------------------------------- masks

def _floor_grid(size):
	x0, x1 = L.FLOOR_MASK["x"]
	z0, z1 = L.FLOOR_MASK["z"]
	v, u = np.mgrid[0:size, 0:size].astype(np.float64) + 0.5
	return x0 + u / size * (x1 - x0), z0 + v / size * (z1 - z0)


def _seg_dist(px, pz, a, b):
	ax, az = a
	bx, bz = b
	dx, dz = bx - ax, bz - az
	t = np.clip(((px - ax) * dx + (pz - az) * dz) / max(dx * dx + dz * dz, 1e-9), 0, 1)
	return np.hypot(px - (ax + t * dx), pz - (az + t * dz))


def _wall_dist(x, z):
	"""Distance to the nearest inside wall face of the hall, kitchen or store."""
	hall = np.minimum.reduce([x - 170.125, 209.875 - x, z - 20.125, np.where((x > 186) & (x < 210), 99.0, 43.875 - z)])
	back = np.minimum.reduce([np.abs(x - 186.125), np.abs(x - 197.875), np.abs(x - 198.125), np.abs(x - 209.875), 51.875 - z])
	return np.where(z <= 44.0, hall, np.where(z <= 52.0, back, 99.0))


def mask_floor():
	size = 1024
	x, z = _floor_grid(size)
	rng = np.random.default_rng(263_03)
	n1 = smooth_noise(rng, size, 6)
	n2 = smooth_noise(rng, size, 30)
	walls = _wall_dist(x, z)
	r = np.clip(0.55 + 0.25 * n2 + 0.3 * np.exp(-walls / 0.5), 0, 1)
	grime = 0.25 + 0.12 * n2 + 0.7 * np.exp(-walls / 0.35)
	for name, (tx, tz), yaw in L.tables():
		d = np.maximum(np.abs(x - tx) - 1.0, 0) + np.maximum(np.abs(z - tz) - 0.85, 0)
		grime += 0.35 * np.exp(-d / 0.35)
	# The queue along the counter and the hand-washing sinks, the tray return, the kitchen.
	grime += 0.35 * np.exp(-_seg_dist(x, z, (171.5, 40.6), (185.0, 40.6)) / 0.6)
	grime += 0.45 * ((x > 186) & (x < 198) & (z > 44) & (z < 52)) * (0.6 + 0.4 * np.exp(-np.abs(z - 50.6) / 1.2))
	grime += 0.3 * ((x > 198) & (z > 44) & (z < 52))
	wet = np.zeros_like(x)
	for name, (px, py, pz), yaw in L.floor_items("Spill"):
		wet += smoothstep(0.42, 0.18, np.hypot((x - px) / 1.0, (z - pz) / 0.75) + 0.12 * n1)
	wet += smoothstep(1.1, 0.3, np.hypot(x - 209.0, z - 23.85) + 0.3 * n1)     # under the hand basins
	wet += smoothstep(0.9, 0.2, np.hypot(x - 187.6, z - 49.3) + 0.3 * n1)      # kitchen sink
	wet += 0.5 * smoothstep(0.6, 0.0, np.abs(z - 50.2) + 0.25 * n1) * ((x > 188) & (x < 196))  # grease by the stoves
	wet = np.clip(wet, 0, 1)
	wear = np.zeros_like(x)
	for a, b, w in [((190, 18), (190, 44), 2.2), ((190, 22), (176, 40.5), 1.4), ((190, 22), (208.5, 39), 1.4),
			((176, 29.75), (210, 29.75), 0.9), ((172, 34.75), (210, 34.75), 0.9), ((192, 41), (192, 51), 1.2),
			((202, 41), (202, 52), 1.2), ((171.5, 40.5), (185, 40.5), 0.8), ((170, 40.5), (190, 40.5), 1.0)]:
		wear += np.exp(-(_seg_dist(x, z, a, b) / w) ** 2)
	wear = np.clip(wear * (0.8 + 0.25 * n1), 0, 1)
	save("mask_floor.png", np.dstack([r, np.clip(grime * (0.85 + 0.2 * n1), 0, 1), wet, wear]), "RGBA")


def mask_ceiling():
	size = 1024
	x, z = _floor_grid(size)
	rng = np.random.default_rng(263_04)
	n1 = smooth_noise(rng, size, 5)
	n2 = smooth_noise(rng, size, 40)
	grime = 0.15 + 0.1 * n2
	for tx, tz in L.TUBES:
		grime += 0.45 * np.exp(-((np.abs(x - tx) - 0.55).clip(0) ** 2 + (np.abs(z - tz) - 0.05).clip(0) ** 2) / 0.12)
	for fx, fz, yaw in L.FANS:
		grime += 0.6 * np.exp(-np.hypot(x - fx, z - fz) / 0.5)
	walls = _wall_dist(x, z)
	grime += 0.4 * np.exp(-walls / 0.4)
	stain = np.zeros_like(x)
	for cx, cz, r in [(176.5, 22.4, 1.6), (186.0, 33.5, 1.1), (199.5, 41.0, 2.0), (205.0, 26.0, 0.9), (172.0, 39.0, 1.3)]:
		d = np.hypot(x - cx, (z - cz) * 1.2) / r + 0.25 * n1 + 0.15 * n2
		body = smoothstep(1.0, 0.6, d)
		tide = np.exp(-((d - 0.95) / 0.05) ** 2)
		stain = np.maximum(stain, 0.65 * body + 0.35 * tide)
	stain = np.maximum(stain, 0.5 * smoothstep(0.6, 0.0, z - 20.0) * smoothstep(0.0, 1.2, n2 + 0.6))  # along the windows
	mould = np.clip(0.8 * np.exp(-walls / 0.25) * smoothstep(-0.2, 1.0, n2) + 0.5 * stain * smoothstep(0.5, 1.5, n1), 0, 1)
	save("mask_ceiling.png", np.dstack([np.zeros_like(x), np.clip(grime, 0, 1), np.clip(stain, 0, 1), mould]), "RGBA")


def mask_walls():
	w, h = 2048, 512
	rows = L.MASK_ROWS
	rh = h // rows
	rng = np.random.default_rng(263_05)
	out = np.zeros((h, w, 4))
	n1 = smooth_noise(rng, (h, w), 5)
	n2 = smooth_noise(rng, (h, w), 30)
	streak = smooth_noise(rng, (h, w), 2.0, aspect=12.0)
	for row, length in enumerate([L.HALL_PERIMETER, 80.0, 41.0, 128.0]):
		v, u = np.mgrid[0:rh, 0:w].astype(np.float64) + 0.5
		s = u / w * length                 # metres along
		y = (1.0 - v / rh) * L.WALL_H      # metres above the floor
		a, b = n1[row * rh:(row + 1) * rh], n2[row * rh:(row + 1) * rh]
		st = streak[row * rh:(row + 1) * rh]
		grime = 0.12 + 0.07 * b + 0.3 * smoothstep(1.0, 0.0, y) + 0.2 * smoothstep(3.6, 4.5, y)
		peel = 0.25 * smoothstep(0.9, 2.2, b + 0.5 * a) + 0.35 * smoothstep(0.6, 0.0, y) * smoothstep(0.2, 1.4, b)
		stain = 0.0 * s
		mould = 0.6 * smoothstep(0.5, 0.0, y) * smoothstep(-0.3, 1.0, b)
		if row == 0:
			# Front wall (s 0..39.75): runs under the ten windows; door and west exit: hand grime at 1..1.6 m.
			for wx in L.WINDOWS_X:
				sx = wx - 170.125
				under = smoothstep(1.4, 0.9, np.abs(s - sx)) * smoothstep(1.4, 1.2, y) * smoothstep(-0.5, 1.2, st)
				stain = np.maximum(stain, 0.7 * under)
			# The west exit (west face from z 43.875 down: s 103.25 + 3.375) and both jambs of the main door.
			for door_s in (106.6, 15.7, 24.1):
				grime = grime + 0.5 * np.exp(-((s - door_s) / 1.2) ** 2) * smoothstep(0.6, 1.2, y) * smoothstep(2.0, 1.4, y)
			for leak in (6.2, 52.5, 88.0, 110.0):
				stain = np.maximum(stain, 0.8 * smoothstep(1.2, 0.2, np.abs(s - leak) * 2.0 + 0.4 * a) * smoothstep(1.5, 4.4, y + 1.5 * st))
		elif row == 1:
			# Kitchen: soot over the stoves (back wall, s 8..20), grease all over the lower wall.
			soot = smoothstep(7.5, 9.0, s) * smoothstep(20.5, 19.0, s) * smoothstep(1.9, 2.6, y) * smoothstep(4.6, 3.2, y)
			grime = grime + 0.45 * soot * (0.8 + 0.2 * a) + 0.08
			mould = mould + 0.3 * smoothstep(0.4, 0.0, y)
		elif row == 2:
			# Facade: rain runs under each sill and the parapet, a dark plinth splash.
			for wx in L.WINDOWS_X:
				sx = wx - 169.5
				under = smoothstep(1.3, 0.6, np.abs(s - sx)) * smoothstep(1.4, 1.0, y) * smoothstep(-0.6, 1.0, st)
				stain = np.maximum(stain, 0.85 * under)
			stain = np.maximum(stain, 0.6 * smoothstep(3.4, 4.5, y) * smoothstep(-0.4, 1.2, st))
			grime = grime + 0.4 * smoothstep(0.5, 0.0, y)
			mould = mould + 0.5 * smoothstep(0.35, 0.0, y) * smoothstep(-0.5, 0.8, a)
		else:
			# Outside faces but the front (round 2, canteen_layout.OUT_RUNS): splash and moss at the foot, rain runs
			# from the roof edge, drips under the west wall's AC units, soot over the kitchen's exhaust, hands round
			# the west exit and the back door.
			runs = L.OUT_RUNS
			stain = 0.55 * smoothstep(3.0, 4.5, y) * smoothstep(-0.4, 1.2, st)
			grime = grime + 0.35 * smoothstep(0.55, 0.0, y)
			mould = mould + 0.55 * smoothstep(0.45, 0.0, y) * smoothstep(-0.5, 0.8, a)
			for z in L.AC_Z:
				sx = runs["west"] + (z - 19.875)
				drip = smoothstep(0.5, 0.1, np.abs(s - sx) + 0.15 * st) * smoothstep(2.4, 1.6, y) * smoothstep(-0.3, 1.0, st)
				stain = np.maximum(stain, 0.8 * drip)
				grime = grime + 0.25 * smoothstep(0.45, 0.0, np.abs(s - sx)) * smoothstep(0.3, 0.0, y)
			sx = runs["kitchen_back"] + (194.0 - 185.875)
			soot = smoothstep(1.2, 0.3, np.abs(s - sx) + 0.2 * a) * smoothstep(2.4, 3.0, y)
			grime = grime + 0.6 * soot
			for door_s in (runs["west"] + (40.5 - 19.875), runs["store_back"] + (202.0 - 198.0)):
				grime = grime + 0.45 * np.exp(-((s - door_s) / 1.6) ** 2) * smoothstep(0.5, 1.0, y) * smoothstep(2.2, 1.4, y)
		out[row * rh:(row + 1) * rh, :, 0] = np.clip(peel, 0, 1)
		out[row * rh:(row + 1) * rh, :, 1] = np.clip(grime * (0.85 + 0.25 * a), 0, 1)
		out[row * rh:(row + 1) * rh, :, 2] = np.clip(stain, 0, 1)
		out[row * rh:(row + 1) * rh, :, 3] = np.clip(mould, 0, 1)
	save("mask_walls.png", out, "RGBA")


# ---------------------------------------------------------------------------------------------- boards and text

BOARD_PX = L.PRICE_PX


def _text_layer(size, text, font_path, em, centre, ss=2, anchor="mm", tracking=0.0):
	w, h = size
	img = Image.new("L", (w * ss, h * ss), 0)
	d = ImageDraw.Draw(img)
	font = ImageFont.truetype(str(font_path), int(h * ss * em))
	if tracking == 0.0:
		d.text((centre[0] * ss, centre[1] * ss), text, font=font, fill=255, anchor=anchor)
	else:
		widths = [font.getlength(ch) + tracking * h * ss for ch in text]
		x = centre[0] * ss - sum(widths) / 2
		for ch, cw in zip(text, widths):
			d.text((x, centre[1] * ss), ch, font=font, fill=255, anchor="lm")
			x += cw
	return np.asarray(img.resize((w, h), Image.LANCZOS), np.float64) / 255.0


def _wood(rng, h, w):
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	grain = smooth_noise(rng, (h, w), 3, aspect=0.05)
	rings = np.sin(u / w * 40 + 3 * smooth_noise(rng, (h, w), 30)) * 0.5 + 0.5
	return np.array([0.42, 0.28, 0.16])[None, None] * (1 + 0.15 * grain + 0.1 * rings)[..., None]


def _price_board_wood(text, seed):
	w, h = BOARD_PX
	rng = np.random.default_rng(seed)
	wood = _wood(rng, h, w)
	mid = smooth_noise(rng, (h, w), 8)
	big = smooth_noise(rng, (h, w), 40)
	paint = np.array([0.07, 0.08, 0.075])[None, None] * (1 + 0.15 * big + 0.1 * mid)[..., None]
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	frame = ((u < 22) | (u > w - 23) | (v < 22) | (v > h - 23)).astype(np.float64)
	letters = _text_layer((w, h), text, FONT_BOLD, 0.56, (w / 2, h * 0.53), tracking=0.03)
	# Brushed by hand: slightly uneven strokes, chalky white; chips show the wood at the edges, never across a letter.
	letters = np.clip(letters * (0.85 + 0.15 * smoothstep(-1.5, 1.5, mid)), 0, 1)
	guard = np.clip(blur(letters, 4.0) * 4.0, 0, 1)
	chips = smoothstep(1.9, 2.4, mid + 0.4 * big) * (1 - guard)
	rgb = paint * (1 - chips[..., None]) + wood * chips[..., None]
	rgb = rgb * (1 - frame[..., None]) + wood * 0.8 * frame[..., None]
	white = np.array([0.86, 0.85, 0.8])
	rgb = rgb * (1 - letters[..., None]) + white * letters[..., None]
	rgb *= (1 - 0.25 * smoothstep(0.6, 1.0, v / h) * smoothstep(-0.5, 1.0, big))[..., None]   # grease at the foot
	return rgb


def _price_board_print(text, seed):
	w, h = BOARD_PX
	rng = np.random.default_rng(seed)
	mid = smooth_noise(rng, (h, w), 8)
	big = smooth_noise(rng, (h, w), 50)
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	rgb = np.array([0.86, 0.85, 0.8])[None, None] * (1 + 0.04 * big)[..., None]
	dish, price = text.rsplit(" ", 1)
	band = ((v > h * 0.12) & (v < h * 0.88) & (u > w * 0.62) & (u < w * 0.95)).astype(np.float64)
	rgb = rgb * (1 - band[..., None]) + np.array([0.62, 0.1, 0.08]) * band[..., None]
	word = _text_layer((w, h), dish, FONT_BOLD, 0.48, (w * 0.32, h * 0.53))
	num = _text_layer((w, h), price, FONT_BOLD, 0.62, (w * 0.785, h * 0.53))
	rgb = rgb * (1 - word[..., None]) + np.array([0.08, 0.18, 0.42]) * word[..., None]
	rgb = rgb * (1 - num[..., None]) + np.array([0.95, 0.93, 0.85]) * num[..., None]
	# Sun-faded print, a border line, fly specks and grease at the bottom.
	border = (((u > 10) & (u < 16)) | ((u > w - 17) & (u < w - 11)) | ((v > 10) & (v < 16)) | ((v > h - 17) & (v < h - 11))).astype(np.float64)
	rgb = rgb * (1 - border[..., None]) + np.array([0.08, 0.18, 0.42]) * border[..., None]
	fade = smoothstep(-0.5, 1.8, big) * 0.25
	rgb = rgb * (1 - fade[..., None]) + np.array([0.8, 0.78, 0.7]) * fade[..., None]
	specks = (rng.random((h, w)) < 0.004).astype(np.float64)
	rgb *= (1 - 0.6 * blur(specks, 0.7))[..., None]
	rgb *= (1 - 0.2 * smoothstep(0.65, 1.0, v / h) * smoothstep(-0.5, 1.0, mid))[..., None]
	return rgb


def price_boards(options=False):
	"""The wood boards (D-181); the printed ones (round 1's other option) only with price_print."""
	makers = [("price_wood.png", _price_board_wood)] + ([("price_print.png", _price_board_print)] if options else [])
	for name, maker in makers:
		atlas = np.zeros((1024, 2048, 3))
		for i, text in enumerate(L.PRICES):
			col, row = divmod(i, 3)
			board = maker(text, 263_10 + i)
			atlas[row * 340:row * 340 + BOARD_PX[1], col * 1024:(col + 1) * 1024] = board
		save(name, atlas)


def _red_board(size, text, em, seed, tracking=0.02, bolts=8):
	w, h = size
	rng = np.random.default_rng(seed)
	big = smooth_noise(rng, (h, w), 40)
	mid = smooth_noise(rng, (h, w), 7)
	streak = smooth_noise(rng, (h, w), 2, aspect=20.0)
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	red = np.array([0.52, 0.09, 0.07])
	faded = np.array([0.6, 0.3, 0.25])
	fade = smoothstep(-0.8, 1.8, big + 0.3 * mid)
	rgb = red[None, None] * (1 - fade[..., None]) + faded[None, None] * fade[..., None]
	letters = _text_layer((w, h), text, FONT_BOLD, em, (w / 2, h * 0.52), tracking=tracking)
	guard = np.clip(blur(letters, 3.0) * 4.0, 0, 1)
	yellow = np.array([0.93, 0.82, 0.5])
	rgb = rgb * (1 - letters[..., None]) + yellow * (1 - 0.15 * smoothstep(0, 2, big))[..., None] * letters[..., None]
	flake = smoothstep(2.2, 2.7, mid + 0.4 * big) * 0.85 * (1 - guard)
	rgb = rgb * (1 - flake[..., None]) + np.array([0.48, 0.47, 0.44]) * flake[..., None]
	rust = np.zeros((h, w))
	for i in range(bolts):
		bx = (i + 0.5) / bolts * w
		rust += np.exp(-((u - bx) / 5.0) ** 2) * np.exp(-v / (h * 0.8)) * smoothstep(-0.5, 1.0, streak)
	rust = np.clip(rust, 0, 1) * (1 - 0.6 * guard)
	rgb = rgb * (1 - 0.6 * rust[..., None]) + np.array([0.33, 0.17, 0.08]) * 0.6 * rust[..., None]
	rgb *= (1 - 0.35 * smoothstep(0.5, 1.0, v / h) * (0.5 + 0.3 * smoothstep(-1, 1, streak)))[..., None]
	return rgb


def signs():
	save("sign_canteen.png", _red_board((2048, 204), L.SIGN_TEXT, 0.58, 263_20, tracking=0.06, bolts=10))
	save("slogan.png", _red_board((2048, 104), L.SLOGAN_TEXT, 0.56, 263_21, tracking=0.01, bolts=14))


def tv_screen():
	"""A news programme as seen from across the hall: studio blue, a presenter's dark shape, a red strap with white
	blocks and a ticker, all without words (the voice carries the news; the screen is never read)."""
	w, h = 512, 320
	rng = np.random.default_rng(263_30)
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	rgb = np.array([0.08, 0.2, 0.42])[None, None] * (1 + 0.5 * (1 - v / h))[..., None]
	glow = np.exp(-(((u - w * 0.7) / (w * 0.35)) ** 2 + ((v - h * 0.35) / (h * 0.4)) ** 2))
	rgb += np.array([0.15, 0.25, 0.4]) * glow[..., None]
	# Presenter: head and shoulders, left of centre.
	head = ((u - w * 0.36) / 34) ** 2 + ((v - h * 0.38) / 42) ** 2 < 1
	body = (((u - w * 0.36) / 110) ** 2 + ((v - h * 0.82) / 80) ** 2 < 1) & (v > h * 0.52)
	shape = blur((head | body).astype(np.float64), 1.5)
	rgb = rgb * (1 - shape[..., None]) + np.array([0.12, 0.1, 0.1]) * shape[..., None]
	face = blur((((u - w * 0.36) / 26) ** 2 + ((v - h * 0.38) / 34) ** 2 < 1).astype(np.float64), 2)
	rgb = rgb * (1 - face[..., None]) + np.array([0.62, 0.45, 0.36]) * face[..., None]
	# Picture-in-picture: a hazy street, top right.
	pip = (u > w * 0.6) & (u < w * 0.93) & (v > h * 0.12) & (v < h * 0.5)
	street = np.array([0.35, 0.33, 0.3]) * (1 + 0.3 * smooth_noise(rng, (h, w), 6))[..., None]
	rgb = np.where(pip[..., None], street, rgb)
	# Lower third: red strap with white "text" blocks, a ticker under it.
	strap = (v > h * 0.68) & (v < h * 0.82) & (u > w * 0.04) & (u < w * 0.96)
	rgb = np.where(strap[..., None], np.array([0.75, 0.08, 0.06]), rgb)
	blocks = np.zeros((h, w), bool)
	x = w * 0.08
	while x < w * 0.88:
		bw = rng.uniform(14, 40)
		blocks |= (u > x) & (u < x + bw) & (v > h * 0.725) & (v < h * 0.775)
		x += bw + rng.uniform(5, 9)
	rgb = np.where(blocks[..., None], np.array([0.95, 0.93, 0.9]), rgb)
	ticker = (v > h * 0.84) & (v < h * 0.92)
	rgb = np.where(ticker[..., None], np.array([0.9, 0.85, 0.3]), rgb)
	tb = np.zeros((h, w), bool)
	x = 0.0
	while x < w:
		bw = rng.uniform(6, 22)
		tb |= (u > x) & (u < x + bw) & (v > h * 0.86) & (v < h * 0.9)
		x += bw + rng.uniform(4, 8)
	rgb = np.where((ticker & tb)[..., None], np.array([0.1, 0.1, 0.12]), rgb)
	# Scan lines and the old panel's uneven backlight.
	rgb *= (0.9 + 0.1 * (np.floor(v) % 3 != 0))[..., None]
	rgb *= (0.8 + 0.2 * np.exp(-(((u - w / 2) / w) ** 2 + ((v - h / 2) / h) ** 2) * 3))[..., None]
	# A low-resolution broadcast on an old panel: soft, no hard outline.
	rgb = np.dstack([blur(np.clip(rgb[..., c], 0, 1), 1.6) for c in range(3)])
	rgb *= (0.9 + 0.1 * (np.floor(v) % 3 != 0))[..., None]
	save("tv_screen.png", rgb)


# ---------------------------------------------------------------------------------------------- palette

PALETTE = {
	"porcelain": (0.86, 0.86, 0.82), "bowl_blue": (0.2, 0.3, 0.55), "rice": (0.88, 0.86, 0.78), "broth": (0.5, 0.36, 0.16),
	"greens": (0.2, 0.36, 0.1), "pork": (0.42, 0.22, 0.12), "egg": (0.82, 0.58, 0.16), "tofu": (0.84, 0.78, 0.6),
	"chopstick": (0.72, 0.57, 0.36), "chopstick_red": (0.55, 0.1, 0.07), "noodle": (0.86, 0.8, 0.58), "fish_sauce": (0.4, 0.24, 0.08),
	"spill": (0.32, 0.22, 0.1), "gas_red": (0.55, 0.1, 0.07), "gas_valve": (0.62, 0.55, 0.3), "sack": (0.82, 0.8, 0.72),
	"sack_print": (0.2, 0.35, 0.6), "cardboard": (0.55, 0.42, 0.26), "veg_green": (0.25, 0.45, 0.12), "onion": (0.62, 0.35, 0.4),
	"chili": (0.65, 0.08, 0.05), "black": (0.04, 0.04, 0.045), "white_plastic": (0.82, 0.82, 0.8), "blue_plastic": (0.12, 0.28, 0.6),
	"red_plastic": (0.6, 0.08, 0.06), "green_plastic": (0.15, 0.42, 0.25), "cream_paint": (0.82, 0.8, 0.72), "rubber": (0.07, 0.07, 0.07),
	"wood": (0.45, 0.3, 0.17), "bamboo": (0.66, 0.55, 0.33), "brass": (0.55, 0.45, 0.2), "charcoal": (0.1, 0.09, 0.08),
	"fluor": (0.9, 0.92, 0.88), "paper": (0.85, 0.83, 0.76), "led_green": (0.1, 0.5, 0.2), "rust": (0.35, 0.18, 0.08),
	# Round 2 (appended: the cells above keep their places, so round 1's glbs stay mapped).
	"bike_blue": (0.13, 0.22, 0.45), "bike_red": (0.5, 0.09, 0.07), "bike_green": (0.13, 0.3, 0.2), "chrome": (0.6, 0.6, 0.58),
	"saddle": (0.08, 0.065, 0.055), "ac_white": (0.78, 0.78, 0.74), "pvc_grey": (0.52, 0.53, 0.52), "bin_grey": (0.2, 0.23, 0.22),
	"oil_yellow": (0.74, 0.52, 0.12), "tape": (0.7, 0.58, 0.36), "sack_green": (0.24, 0.4, 0.28), "slop": (0.3, 0.24, 0.12),
	"door_green": (0.2, 0.34, 0.27), "steel_grey": (0.33, 0.34, 0.34), "copper": (0.5, 0.3, 0.16), "foam": (0.62, 0.6, 0.52),
}


def palette():
	size, cell = 64, 8
	rng = np.random.default_rng(263_40)
	weave = smooth_noise(rng, size, 1.0) * 0.03
	rgb = np.zeros((size, size, 3))
	index = {}
	for i, (key, col) in enumerate(PALETTE.items()):
		cy, cx = divmod(i, 8)
		rgb[cy * cell:(cy + 1) * cell, cx * cell:(cx + 1) * cell] = col
		index[key] = [cx, cy]
	rgb *= (1.0 + weave)[..., None]
	save("palette.png", rgb)
	(HERE / "palette.json").write_text(json.dumps(index, indent=0), encoding="utf-8", newline="\n")


# ---------------------------------------------------------------------------------------------- round 2

POSTER_PX = (256, 366)      # one poster (0.7 x 1.0 m) in posters.png; four side by side along the top
SIGN_PX = (486, 146)        # the "TRẢ KHAY" sign (1.0 x 0.3 m) at the bottom left; a hazard sticker beside it


def _aged_paper(rng, h, w):
	big = smooth_noise(rng, (h, w), 30)
	mid = smooth_noise(rng, (h, w), 6)
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	rgb = np.array([0.86, 0.83, 0.74])[None, None] * (1 + 0.05 * big + 0.03 * mid)[..., None]
	return rgb, big, mid, u, v


def _bars(rgb, u, v, x0, x1, y0, rows, rng, colour=(0.35, 0.33, 0.3), height=7, gap=13):
	"""Lines of small print (grey bars of ragged length), never letters: the posters carry no words."""
	for k in range(rows):
		end = x0 + (x1 - x0) * rng.uniform(0.55, 1.0)
		m = (u > x0) & (u < end) & (v > y0 + k * gap) & (v < y0 + k * gap + height)
		rgb[m] = rgb[m] * 0.3 + np.array(colour) * 0.7
	return rgb


def _poster(kind, seed):
	w, h = POSTER_PX
	rng = np.random.default_rng(seed)
	rgb, big, mid, u, v = _aged_paper(rng, h, w)
	if kind == 0:
		# Hand washing: a blue band, a tap over two hands and drops, three steps as small pictograms, print under them.
		rgb[(v > 14) & (v < 52)] = np.array([0.16, 0.36, 0.62])
		tap = ((u > 112) & (u < 150) & (v > 80) & (v < 96)) | ((u > 140) & (u < 152) & (v > 80) & (v < 118))
		rgb[tap] = np.array([0.45, 0.47, 0.5])
		for dy in (130, 150, 168):
			drop = ((u - 146) / 5) ** 2 + ((v - dy) / 8) ** 2 < 1
			rgb[drop] = np.array([0.3, 0.55, 0.85])
		for cx in (112, 160):
			hand = ((u - cx) / 30) ** 2 + ((v - 205) / 22) ** 2 < 1
			rgb[hand] = np.array([0.82, 0.62, 0.48])
		for k in range(3):
			cx = 48 + k * 80
			ring = np.abs(np.hypot(u - cx, v - 262) - 22) < 3
			rgb[ring] = np.array([0.16, 0.36, 0.62])
		rgb = _bars(rgb, u, v, 30, 226, 296, 4, rng)
	elif kind == 1:
		# A balanced plate: a green band, a round plate in four parts (rice, greens, meat, soup), print under it.
		rgb[(v > 14) & (v < 52)] = np.array([0.22, 0.48, 0.24])
		ang = np.arctan2(v - 160, u - 128)
		r = np.hypot(u - 128, v - 160)
		plate = r < 78
		cols = [np.array([0.9, 0.88, 0.8]), np.array([0.3, 0.55, 0.2]), np.array([0.62, 0.32, 0.16]), np.array([0.8, 0.6, 0.25])]
		for k in range(4):
			sector = plate & (ang >= -math.pi + k * math.pi / 2) & (ang < -math.pi + (k + 1) * math.pi / 2)
			rgb[sector] = cols[k]
		rgb[np.abs(r - 80) < 3] = np.array([0.5, 0.5, 0.48])
		rgb = _bars(rgb, u, v, 30, 226, 262, 6, rng)
	elif kind == 2:
		# No smoking: the round prohibition sign over a cigarette, print under it.
		cig = (u > 70) & (u < 186) & (v > 130) & (v < 150)
		rgb[cig] = np.array([0.95, 0.95, 0.93])
		rgb[(u > 160) & (u < 186) & (v > 130) & (v < 150)] = np.array([0.85, 0.5, 0.2])
		for k in range(3):
			smoke = np.abs(v - (112 - k * 12) - 6 * np.sin(u / 9 + k)) < 2.5
			rgb[smoke & (u > 60) & (u < 110)] = np.array([0.55, 0.55, 0.55])
		r = np.hypot(u - 128, v - 140)
		rgb[np.abs(r - 84) < 11] = np.array([0.75, 0.1, 0.08])
		slash = (np.abs((u - 128) + (v - 140)) / math.sqrt(2) < 10) & (r < 80)
		rgb[slash] = np.array([0.75, 0.1, 0.08])
		rgb = _bars(rgb, u, v, 40, 216, 262, 5, rng)
	else:
		# Fire safety: a red band, an extinguisher, an arrow, print under it.
		rgb[(v > 14) & (v < 52)] = np.array([0.72, 0.1, 0.07])
		body = (u > 104) & (u < 150) & (v > 110) & (v < 240)
		top = ((u - 127) / 23) ** 2 + ((v - 110) / 18) ** 2 < 1
		rgb[body | top] = np.array([0.75, 0.1, 0.08])
		rgb[(u > 118) & (u < 136) & (v > 80) & (v < 96)] = np.array([0.15, 0.15, 0.15])
		rgb[(u > 136) & (u < 178) & (v > 84) & (v < 92)] = np.array([0.15, 0.15, 0.15])
		rgb[(u > 112) & (u < 142) & (v > 140) & (v < 180)] = np.array([0.9, 0.88, 0.8])
		arrow = (u > 176) & (u < 220) & (np.abs(v - 175) < 0.6 * (220 - u)) & (v > 150) & (v < 200)
		rgb[arrow] = np.array([0.2, 0.5, 0.25])
		rgb = _bars(rgb, u, v, 30, 226, 268, 5, rng)
	# Age: sun-faded colours, water stain, a torn corner, tape at the top corners, fly specks.
	fade = smoothstep(-0.6, 1.6, big) * 0.3
	rgb = rgb * (1 - fade[..., None]) + np.array([0.82, 0.79, 0.7]) * fade[..., None]
	d = np.hypot((u - rng.uniform(40, 220)) / 60, (v - rng.uniform(220, 340)) / 45) + 0.2 * mid
	tide = np.exp(-((d - 1.0) / 0.06) ** 2) * 0.25 + smoothstep(1.0, 0.7, d) * 0.08
	rgb *= (1 - tide)[..., None]
	torn = (u > w - 34) & (v > h - 30) & ((u - (w - 34)) * 30 + (v - (h - 30)) * 34 > 520)
	rgb[torn] = np.array([0.04, 0.04, 0.04])  # the wall's shadow shows there (the mesh is a flat card)
	for tx in (14, w - 40):
		rgb[(u > tx) & (u < tx + 26) & (v < 18)] = np.array([0.76, 0.72, 0.58])
	specks = (rng.random((h, w)) < 0.003).astype(np.float64)
	rgb *= (1 - 0.6 * blur(specks, 0.7))[..., None]
	return rgb


def _return_sign(seed):
	"""ReturnSign "TRẢ KHAY" (the words unchanged) as a blue enamel sign, white letters, chipped edges."""
	w, h = SIGN_PX
	rng = np.random.default_rng(seed)
	big = smooth_noise(rng, (h, w), 20)
	mid = smooth_noise(rng, (h, w), 5)
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	rgb = np.array([0.1, 0.24, 0.5])[None, None] * (1 + 0.08 * big)[..., None]
	border = ((u < 12) | (u > w - 13) | (v < 12) | (v > h - 13)) & ~((u < 6) | (u > w - 7) | (v < 6) | (v > h - 7))
	rgb[border] = np.array([0.88, 0.88, 0.84])
	letters = _text_layer((w, h), L.RETURN_SIGN, FONT_BOLD, 0.44, (w / 2, h * 0.55), tracking=0.04)
	guard = np.clip(blur(letters, 3.0) * 4.0, 0, 1)
	rgb = rgb * (1 - letters[..., None]) + np.array([0.92, 0.92, 0.88]) * letters[..., None]
	edge = np.minimum.reduce([u, w - u, v, h - v])
	chips = smoothstep(1.6, 2.2, mid + 0.6 * big) * smoothstep(30, 6, edge) * (1 - guard)
	rgb = rgb * (1 - chips[..., None]) + np.array([0.1, 0.09, 0.08]) * chips[..., None]
	return rgb


def _hazard(seed):
	h = SIGN_PX[1]
	v, u = np.mgrid[0:h, 0:h].astype(np.float64)
	rgb = np.full((h, h, 3), 0.6)
	tri = (v > 18) & (v < h - 14) & (np.abs(u - h / 2) < (v - 18) * 0.62)
	rgb[tri] = np.array([0.1, 0.1, 0.1])
	inner = (v > 30) & (v < h - 22) & (np.abs(u - h / 2) < (v - 30) * 0.62 - 6)
	rgb[inner] = np.array([0.9, 0.72, 0.08])
	bolt = (np.abs((u - h / 2) - 0.5 * (v - 80)) < 5) & (v > 52) & (v < 112)
	rgb[bolt] = np.array([0.1, 0.1, 0.1])
	return rgb


def posters():
	atlas = np.zeros((512, 1024, 3)) + 0.5
	for k in range(4):
		atlas[0:POSTER_PX[1], k * 256:(k + 1) * 256] = _poster(k, 263_50 + k)
	atlas[366:366 + SIGN_PX[1], 0:SIGN_PX[0]] = _return_sign(263_55)
	atlas[366:366 + SIGN_PX[1], 500:500 + SIGN_PX[1]] = _hazard(263_56)
	save("posters.png", atlas)


def _strip_grid():
	X, Z = L.STRIP_UV["x"], L.STRIP_UV["z"]
	w = 1024
	h = int(round(w * (Z[1] - Z[0]) / (X[1] - X[0])))
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	return X[0] + u / (w - 1) * (X[1] - X[0]), Z[0] + v / (h - 1) * (Z[1] - Z[0]), (h, w)


def _rect_dist(x, z, x0, z0, x1, z1):
	dx = np.maximum(np.maximum(x0 - x, x - x1), 0.0)
	dz = np.maximum(np.maximum(z0 - z, z - z1), 0.0)
	return np.hypot(dx, dz)


# The ways people and the horde take round the canteen (from walk_canteen.gd's routes): the west side from Start_split
# to the front, the forecourt to the door, the back door north across the yard, the east side.
TRODDEN = [((167.4, 13.0), (167.4, 37.0), 1.0), ((190.0, 13.0), (190.0, 19.0), 1.6), ((202.0, 52.0), (202.0, 60.0), 1.2),
	((213.5, 13.0), (213.5, 60.0), 0.9), ((172.0, 47.0), (184.0, 56.0), 0.8), ((202.0, 58.0), (186.0, 60.0), 0.8)]


def mask_strip6():
	"""UV2 of the canteen strip's lawn (ground_blend: R bare dirt, G wet) over the A16 box: verges trodden bare along the
	forecourt, the walls' aprons and the yard; the ways round the building; wet under the eaves' drips and by the bins."""
	x, z, shape = _strip_grid()
	rng = np.random.default_rng(263_60)
	big = smooth_noise(rng, shape, 30)
	mid = smooth_noise(rng, shape, 8)
	ad = L.APRON + L.DRAIN
	paved = np.minimum.reduce([_rect_dist(x, z, L.FRONT_PAVED["x"][0], L.FRONT_PAVED["z"][0], L.FRONT_PAVED["x"][1], L.FRONT_PAVED["z"][1]),
		_rect_dist(x, z, L.YARD["x"][0], L.YARD["z"][0], L.YARD["x"][1], L.YARD["z"][1])]
		+ [_rect_dist(x, z, p["x"][0] - ad, p["z"][0], p["x"][1] + ad, p["z"][1] + ad) for p in L.FOOTPRINT_PARTS])
	verge = np.exp(-paved / 0.7) * 0.8
	ways = np.zeros_like(x)
	for a, b, wdt in TRODDEN:
		ways = np.maximum(ways, np.exp(-(_seg_dist(x, z, a, b) / wdt) ** 2))
	dirt = np.maximum(verge, ways * 0.85)
	dirt = np.clip(dirt * (0.7 + 0.45 * smoothstep(-1, 1.2, mid)) + 0.25 * smoothstep(0.9, 2.2, big), 0, 1)
	eaves = np.exp(-paved / 0.5) * smoothstep(-0.4, 1.2, big + 0.5 * mid)
	wet = np.clip(0.7 * eaves + 0.6 * smoothstep(1.8, 2.5, big), 0, 1)
	save("mask_strip6.png", np.dstack([dirt, wet, np.zeros_like(x), np.ones_like(x)]), "RGBA")


def mask_yard6():
	"""UV2 of the pavers and the concrete (room407_shell kind 1: R grout dirt, G grime, B wet, A wear) over the A16 box:
	grime against the walls and under the bikes, oil under the moped, wet round the drains, the bins and the gas
	cylinders, the trodden lines from the gate's walk to the door and out of the back door."""
	x, z, shape = _strip_grid()
	rng = np.random.default_rng(263_61)
	big = smooth_noise(rng, shape, 30)
	mid = smooth_noise(rng, shape, 7)
	walls = np.minimum.reduce([_rect_dist(x, z, p["x"][0], p["z"][0], p["x"][1], p["z"][1]) for p in L.FOOTPRINT_PARTS])
	grout = np.clip(0.5 + 0.3 * smoothstep(-1, 1.5, mid) + 0.3 * np.exp(-walls / 1.0), 0, 1)
	grime = 0.4 * np.exp(-walls / 0.8) + 0.25 * smoothstep(1.2, 2.2, big + 0.4 * mid)
	for bx, bz, _ in L.BIKES:
		grime += 0.3 * np.exp(-(((x - bx) / 0.9) ** 2 + ((z - bz) / 0.5) ** 2))
	oil = np.exp(-(((x - 207.6) / 0.8) ** 2 + ((z - 54.6) / 0.6) ** 2)) * smoothstep(-0.5, 1.2, mid)
	grime = np.clip(grime + 0.5 * oil, 0, 1)
	wet = 0.6 * np.exp(-walls / 0.5) * smoothstep(-0.3, 1.3, big + 0.5 * mid) + 0.7 * smoothstep(1.8, 2.5, big)
	for px, pz, r in [(205.6, 54.2, 1.2), (189.3, 53.0, 0.9), (202.0, 52.8, 1.4), (190.0, 18.6, 1.0)]:
		wet += 0.6 * smoothstep(r, 0.0, np.hypot(x - px, z - pz) + 0.3 * mid)
	wet = np.clip(wet + 0.4 * oil, 0, 1)
	wear = np.zeros_like(x)
	for a, b, wdt in [((190.0, 13.0), (190.0, 19.9), 1.8), ((186.0, 13.2), (217.0, 13.2), 1.4), ((202.0, 52.0), (202.0, 58.5), 1.3),
			((169.0, 16.0), (186.0, 16.0), 1.0)]:
		wear = np.maximum(wear, np.exp(-(_seg_dist(x, z, a, b) / wdt) ** 2))
	wear = np.clip(wear * (0.75 + 0.3 * smoothstep(-1, 1, mid)), 0, 1)
	save("mask_yard6.png", np.dstack([grout, grime, wet, wear]), "RGBA")


ALL = {"ceramic": ceramic, "ceiling_panels": ceiling_panels, "mask_floor": mask_floor, "mask_ceiling": mask_ceiling,
	"mask_walls": mask_walls, "price_boards": price_boards, "signs": signs, "tv_screen": tv_screen, "palette": palette,
	"posters": posters, "mask_strip6": mask_strip6, "mask_yard6": mask_yard6, "price_print": lambda: price_boards(True)}

if __name__ == "__main__":
	names = sys.argv[1:] or [k for k in ALL if k != "price_print"]
	for key in names:
		ALL[key]()
