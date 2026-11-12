"""T-250 (D-166) wave 1: textures drawn here (numpy + Pillow), no downloaded image and no AI image.

  clock_dial.png        the duty desk's wall clock face (aged white, minutes, numerals in Be Vietnam Pro, OFL)
  cork_color/orm/normal the notice board's cork (granules, pin holes, sun fade)
  notices.png           the papers pinned on the board (a duty rota grid, two notices, a hand note); text is
                        drawn as lines, only two headings are words ("THÔNG BÁO", "LỊCH TRỰC")
  terrazzo_color/orm/normal  the stair treads and landings (grey cement with marble chips, polished)
  ledger_cover.png      the duty logbook's cloth cover and label
Run: python -B art_source/graphics_upgrade/realistic_map/wave1/make_wave1_textures.py
"""
from pathlib import Path
import math
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
OUT = ROOT / "game/assets/textures/graphics_pilot/realistic_map/wave1"
FONT_BOLD = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_regular.ttf"


def smooth_noise(rng, size, scale):
	"""Tileable noise of unit variance, low-passed at about `scale` pixels."""
	white = rng.normal(0.0, 1.0, (size, size))
	fy = np.fft.fftfreq(size)[:, None]
	fx = np.fft.rfftfreq(size)[None, :]
	lowpass = np.exp(-((fy * scale) ** 2 + (fx * scale) ** 2) * 18.0)
	out = np.fft.irfft2(np.fft.rfft2(white) * lowpass, s=(size, size))
	return out / max(out.std(), 1e-9)


def save_rgb(name, rgb):
	OUT.mkdir(parents=True, exist_ok=True)
	img = Image.fromarray((np.clip(rgb, 0.0, 1.0) * 255.0 + 0.5).astype(np.uint8), "RGB")
	img.save(OUT / name, optimize=True)


def normal_from_height(height, strength):
	gy, gx = np.gradient(height)
	n = np.stack([-gx * strength, gy * strength, np.ones_like(height)], axis=2)
	n /= np.linalg.norm(n, axis=2, keepdims=True)
	return n * 0.5 + 0.5


def clock_dial():
	size = 1024
	rng = np.random.default_rng(250_01)
	yy, xx = np.mgrid[0:size, 0:size]
	c = (size - 1) / 2.0
	r = np.hypot(xx - c, yy - c) / c
	# Aged white: yellower towards the rim, a few fly specks.
	base = np.array([0.93, 0.92, 0.86])
	rim = np.array([0.84, 0.79, 0.66])
	t = np.clip((r - 0.55) / 0.45, 0, 1)[..., None] ** 1.6
	grain = smooth_noise(rng, size, 60)[..., None] * 0.012
	rgb = base * (1 - t) + rim * t + grain
	img = Image.fromarray((np.clip(rgb, 0, 1) * 255).astype(np.uint8), "RGB")
	draw = ImageDraw.Draw(img)
	ink = (24, 24, 26)
	for minute in range(60):
		a = minute / 60.0 * math.tau
		outer = 0.94
		inner = 0.86 if minute % 5 == 0 else 0.905
		width = 9 if minute % 5 == 0 else 3
		x0, y0 = c + math.sin(a) * outer * c, c - math.cos(a) * outer * c
		x1, y1 = c + math.sin(a) * inner * c, c - math.cos(a) * inner * c
		draw.line([(x0, y0), (x1, y1)], fill=ink, width=width)
	font = ImageFont.truetype(str(FONT_BOLD), 96)
	for hour in range(1, 13):
		a = hour / 12.0 * math.tau
		x, y = c + math.sin(a) * 0.70 * c, c - math.cos(a) * 0.70 * c
		draw.text((x, y), str(hour), font=font, fill=ink, anchor="mm")
	# A small maker's mark: a plain ring and bar, no brand.
	draw.ellipse([c - 38, c + 150, c + 38, c + 226], outline=(150, 40, 36), width=5)
	draw.line([(c - 60, c + 262), (c + 60, c + 262)], fill=(120, 118, 110), width=4)
	arr = np.asarray(img).astype(np.float32) / 255.0
	specks = rng.random((size, size)) < 0.00018
	specks = np.asarray(Image.fromarray((specks * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(3))) > 0
	arr[specks] *= 0.55
	save_rgb("clock_dial.png", arr)


def cork():
	size = 1024  # 0.5 m
	rng = np.random.default_rng(250_02)
	fine = smooth_noise(rng, size, 3.0)
	mid = smooth_noise(rng, size, 9.0)
	big = smooth_noise(rng, size, 90.0)
	granules = np.clip(fine * 0.6 + mid * 0.5, -3, 3)
	light = np.array([0.70, 0.52, 0.33])
	dark = np.array([0.36, 0.22, 0.11])
	t = np.clip(0.5 + granules * 0.22, 0, 1)[..., None]
	rgb = dark * (1 - t) + light * t
	rgb *= (1.0 + big[..., None] * 0.04)
	# Pin holes all over (years of notices).
	holes = np.zeros((size, size), np.float32)
	for _ in range(700):
		x, y = rng.integers(0, size, 2)
		holes[y, x] = 1.0
	holes = np.asarray(Image.fromarray((holes * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(3))).astype(np.float32) / 255
	rgb *= 1.0 - holes[..., None] * 0.6
	save_rgb("cork_color.png", rgb)
	height = granules * 0.5 - holes * 2.0
	save_rgb("cork_normal.png", normal_from_height(height, 1.2))
	rough = np.clip(0.86 + fine * 0.04, 0, 1)
	save_rgb("cork_orm.png", np.stack([np.clip(1.0 - holes * 0.5, 0, 1), rough, np.zeros_like(rough)], axis=2))


def _paper(draw, box, rng, heading=None, kind="lines", font=None, small=None, tint=(0.95, 0.94, 0.89)):
	x0, y0, x1, y1 = box
	base = tuple(int(v * 255) for v in tint)
	draw.rectangle(box, fill=base)
	ink = (40, 42, 50)
	pad = int((x1 - x0) * 0.08)
	y = y0 + pad
	if heading:
		draw.text(((x0 + x1) // 2, y + 20), heading, font=font, fill=(150, 26, 24) if kind != "grid" else ink, anchor="mt")
		y += 90
	if kind == "lines":
		while y < y1 - pad - 20:
			length = (x1 - x0 - 2 * pad) * (0.55 + 0.45 * rng.random())
			if rng.random() < 0.12:
				y += 18
				continue
			# Words of printed text: short dark runs with gaps, x-height 6 px.
			xx = x0 + pad
			while xx < x0 + pad + length:
				word = 14 + rng.gamma(2.0, 12.0)
				draw.rectangle([xx, y + 1, min(xx + word, x0 + pad + length), y + 7], fill=(70, 72, 80))
				if rng.random() < 0.3:
					draw.rectangle([xx + 2, y - 2, xx + 5, y + 1], fill=(70, 72, 80))
				xx += word + 9
			y += 24
		draw.rectangle([x1 - pad - 140, y1 - pad - 30, x1 - pad, y1 - pad - 24], fill=(70, 70, 80))
		draw.ellipse([x1 - pad - 120, y1 - pad - 110, x1 - pad - 20, y1 - pad - 10], outline=(170, 40, 40), width=6)
	elif kind == "grid":
		rows, cols = 9, 5
		gx0, gy0, gx1, gy1 = x0 + pad, y, x1 - pad, y1 - pad
		for r in range(rows + 1):
			yy = gy0 + (gy1 - gy0) * r / rows
			draw.line([(gx0, yy), (gx1, yy)], fill=ink, width=3 if r in (0, 1, rows) else 2)
		for c in range(cols + 1):
			xx = gx0 + (gx1 - gx0) * c / cols
			draw.line([(xx, gy0), (xx, gy1)], fill=ink, width=3 if c in (0, cols) else 2)
		for r in range(1, rows):
			for c in range(cols):
				if rng.random() < 0.85:
					cx = gx0 + (gx1 - gx0) * (c + 0.15) / cols
					cy = gy0 + (gy1 - gy0) * (r + 0.42) / rows
					w = (gx1 - gx0) / cols * (0.3 + 0.45 * rng.random())
					draw.rectangle([cx, cy, cx + w, cy + 6], fill=(70, 72, 82) if c else (30, 30, 36))
	elif kind == "note":
		# Biro handwriting: wavy strokes.
		while y < y1 - pad:
			xx = x0 + pad
			end = x1 - pad - rng.random() * (x1 - x0) * 0.3
			pts = []
			while xx < end:
				pts.append((xx, y + math.sin(xx * 0.21 + rng.random()) * 5 + rng.normal(0, 1.2)))
				xx += 6
			if len(pts) > 1:
				draw.line(pts, fill=(28, 46, 120), width=3)
			y += 42


def notices():
	w, h = 2048, 1024
	rng = np.random.default_rng(250_03)
	img = Image.new("RGB", (w, h), (0, 0, 0))
	draw = ImageDraw.Draw(img)
	font = ImageFont.truetype(str(FONT_BOLD), 54)
	# Four sheets side by side (UV islands in build_duty_desk.py use these boxes).
	_paper(draw, (0, 0, 680, 1000), rng, "LỊCH TRỰC", "grid", font, tint=(0.94, 0.93, 0.88))
	_paper(draw, (690, 0, 1370, 1000), rng, "THÔNG BÁO", "lines", font, tint=(0.95, 0.95, 0.91))
	_paper(draw, (1380, 0, 1880, 700), rng, None, "lines", font, tint=(0.92, 0.89, 0.80))
	_paper(draw, (1380, 710, 1880, 1020), rng, None, "note", font, tint=(0.96, 0.90, 0.52))
	img = img.filter(ImageFilter.GaussianBlur(0.7))
	arr = np.asarray(img).astype(np.float32) / 255.0
	# Age: yellowing and a damp tide mark on the old sheet, dust.
	yy, xx = np.mgrid[0:h, 0:w]
	yellow = np.clip(smooth_noise(rng, 2048, 120)[:h, :w] * 0.5 + 0.5, 0, 1)[..., None]
	arr *= 1.0 - 0.08 * yellow * np.array([0.0, 0.3, 0.9])
	tide = np.exp(-((np.hypot(xx - 1700, yy - 560) - 120) ** 2) / 200.0)
	arr *= 1.0 - (tide * 0.25)[..., None] * np.array([0.2, 0.45, 0.9])
	save_rgb("notices.png", arr)


def terrazzo():
	size = 2048  # 1 m
	rng = np.random.default_rng(250_04)
	matrix = np.array([0.55, 0.535, 0.50])
	rgb = np.ones((size, size, 3)) * matrix
	rgb += smooth_noise(rng, size, 40)[..., None] * 0.025 + smooth_noise(rng, size, 4)[..., None] * 0.02
	height = np.zeros((size, size))
	img = Image.new("L", (size, size), 0)
	chips = Image.new("RGB", (size, size), (0, 0, 0))
	dm = ImageDraw.Draw(img)
	dc = ImageDraw.Draw(chips)
	# Old đá mài: small chips, low contrast against a warm grey cement, worn flat.
	palette = [(0.74, 0.73, 0.69), (0.68, 0.67, 0.63), (0.40, 0.39, 0.37), (0.30, 0.29, 0.28),
		(0.60, 0.52, 0.46), (0.64, 0.62, 0.58), (0.50, 0.49, 0.46)]
	weights = np.array([0.26, 0.2, 0.14, 0.06, 0.08, 0.16, 0.1])
	for _ in range(16000):
		x, y = rng.random(2) * size
		r = rng.gamma(2.0, 2.0) + 1.5
		n = rng.integers(5, 8)
		ang = rng.random() * math.tau
		pts = []
		for k in range(n):
			a = ang + k / n * math.tau + rng.normal(0, 0.25)
			rr = r * (0.6 + 0.6 * rng.random())
			pts.append((x + math.cos(a) * rr, y + math.sin(a) * rr * (0.7 + 0.5 * rng.random())))
		col = palette[rng.choice(len(palette), p=weights / weights.sum())]
		shade = 1.0 + rng.normal(0, 0.05)
		dc.polygon(pts, fill=tuple(int(np.clip(v * shade, 0, 1) * 255) for v in col))
		dm.polygon(pts, fill=255)
	mask = np.asarray(img).astype(np.float32) / 255.0
	chip_rgb = np.asarray(chips).astype(np.float32) / 255.0
	rgb = rgb * (1 - mask[..., None]) + chip_rgb * mask[..., None]
	# Wear and grime soften the contrast a little; polish leaves the chips flush.
	rgb *= 1.0 + smooth_noise(rng, size, 200)[..., None] * 0.03
	height = mask * 0.15 + smooth_noise(rng, size, 3) * 0.05
	save_rgb("terrazzo_color.png", rgb)
	save_rgb("terrazzo_normal.png", normal_from_height(height, 0.6))
	rough = np.clip(0.42 + (1 - mask) * 0.16 + smooth_noise(rng, size, 60) * 0.05, 0, 1)
	save_rgb("terrazzo_orm.png", np.stack([np.ones_like(rough), rough, np.zeros_like(rough)], axis=2))


def ledger_cover():
	w, h = 512, 512
	rng = np.random.default_rng(250_05)
	weave = smooth_noise(rng, 512, 1.5) * 0.04
	base = np.array([0.09, 0.17, 0.26])
	rgb = base + weave[..., None] + smooth_noise(rng, 512, 60)[..., None] * 0.02
	# Worn corners and edges show the board underneath.
	yy, xx = np.mgrid[0:h, 0:w] / 511.0
	edge = np.minimum(np.minimum(xx, 1 - xx), np.minimum(yy, 1 - yy))
	worn = np.clip(1 - edge / 0.04, 0, 1) * np.clip(0.5 + smooth_noise(rng, 512, 8) * 0.4, 0, 1)
	rgb = rgb * (1 - worn[..., None]) + np.array([0.42, 0.38, 0.32]) * worn[..., None]
	img = Image.fromarray((np.clip(rgb, 0, 1) * 255).astype(np.uint8), "RGB")
	d = ImageDraw.Draw(img)
	d.rectangle([150, 120, 362, 230], fill=(226, 220, 196), outline=(40, 40, 40), width=3)
	for i in range(3):
		d.rectangle([172, 150 + i * 26, 340 - i * 30, 158 + i * 26], fill=(50, 50, 70))
	save_rgb("ledger_cover.png", np.asarray(img).astype(np.float32) / 255.0)


def ledger_pages():
	"""The open duty logbook: two ruled pages (date, time, entry, signature) half filled in biro."""
	w, h = 1024, 768
	rng = np.random.default_rng(250_06)
	img = Image.new("RGB", (w, h), (236, 231, 214))
	d = ImageDraw.Draw(img)
	blue = (34, 52, 128)
	for page in range(2):
		x0 = page * 512 + 26
		x1 = page * 512 + 486
		cols = [x0, x0 + 64, x0 + 116, x1 - 90, x1]
		for c in cols:
			d.line([(c, 40), (c, h - 30)], fill=(150, 120, 120) if c == cols[1] else (120, 140, 170), width=2)
		row = 40
		filled = 13 if page == 0 else 6
		k = 0
		while row < h - 40:
			d.line([(x0, row), (x1, row)], fill=(150, 170, 200), width=1)
			if k < filled and row > 40:
				# date, time, a line of entry, a scribbled signature
				for cx0, cx1 in ((cols[0] + 6, cols[1] - 6), (cols[1] + 6, cols[2] - 6)):
					d.line([(cx0, row + 16), (cx1 - rng.random() * 12, row + 15)], fill=blue, width=2)
				xx = cols[2] + 8
				end = cols[3] - 10 - rng.random() * 120
				pts = []
				while xx < end:
					pts.append((xx, row + 14 + math.sin(xx * 0.25 + k) * 4 + rng.normal(0, 1.0)))
					xx += 5
				if len(pts) > 1:
					d.line(pts, fill=blue, width=2)
				sx = cols[3] + 14
				d.line([(sx, row + 18), (sx + 20, row + 8), (sx + 34, row + 20), (sx + 56, row + 10)], fill=blue, width=2)
			row += 28
			k += 1
	img = img.filter(ImageFilter.GaussianBlur(0.6))
	arr = np.asarray(img).astype(np.float32) / 255.0
	yy, xx = np.mgrid[0:h, 0:w]
	gutter = np.exp(-((xx - 512) ** 2) / (2 * 30.0 ** 2))
	arr *= (1.0 - 0.18 * gutter)[..., None]
	arr *= 1.0 - 0.05 * np.clip(smooth_noise(rng, 1024, 80)[:h, :w] * 0.5 + 0.5, 0, 1)[..., None]
	save_rgb("ledger_pages.png", arr)


def paint_grey():
	"""Old grey-white enamel paint on steel (the PA horn): dust, chips to dark primer and rust bleed."""
	size = 1024  # 0.5 m
	rng = np.random.default_rng(250_07)
	paint = np.array([0.74, 0.74, 0.70])
	dust = np.clip(smooth_noise(rng, size, 70) * 0.5 + 0.5, 0, 1)
	chips = smooth_noise(rng, size, 6) + smooth_noise(rng, size, 30) * 0.8
	chip = (chips > 3.1).astype(np.float32)
	rust = np.clip((smooth_noise(rng, size, 12) - 1.4) * 0.8, 0, 1) * np.clip(smooth_noise(rng, size, 90) + 0.3, 0, 1)
	rgb = paint * (1 - 0.12 * dust[..., None]) + smooth_noise(rng, size, 3)[..., None] * 0.01
	rgb = rgb * (1 - chip[..., None]) + np.array([0.22, 0.2, 0.18]) * chip[..., None]
	rgb = rgb * (1 - rust[..., None] * 0.8) + np.array([0.42, 0.22, 0.10]) * rust[..., None] * 0.8
	save_rgb("paint_grey_color.png", rgb)
	rough = np.clip(0.48 + dust * 0.25 + chip * 0.2 + rust * 0.3, 0, 1)
	metal = chip * 0.6
	save_rgb("paint_grey_orm.png", np.stack([np.ones_like(rough), rough, metal], axis=2))
	save_rgb("paint_grey_normal.png", normal_from_height(-chip * 0.6 + rust * 0.4 + smooth_noise(rng, size, 2) * 0.03, 1.5))


def save_rgba(name, rgba):
	OUT.mkdir(parents=True, exist_ok=True)
	img = Image.fromarray((np.clip(rgba, 0.0, 1.0) * 255.0 + 0.5).astype(np.uint8), "RGBA")
	img.save(OUT / name, optimize=True)


def stair_masks():
	"""Ageing masks for the stairwells (room407_shell.gdshader on UV2). Row 0 is UV2 v = 1.
	mask_stair_wall: one storey of a wall (u along the face, v = height over the floor line / 3.3):
	  R paint loss, G grime, B water stain, A mould.
	mask_stair_floor: one tread or landing (u across, v from the nosing to the back): R grout, G grime, B wet, A wear.
	The top-right texels stay clean: faces without their own UV2 sample there."""
	rng = np.random.default_rng(250_10)
	n = 1024
	v = 1.0 - np.mgrid[0:n, 0:n][0] / (n - 1)
	u = np.mgrid[0:n, 0:n][1] / (n - 1)
	fine = smooth_noise(rng, n, 6)
	mid = smooth_noise(rng, n, 30)
	big = smooth_noise(rng, n, 140)
	grime = np.clip(1.0 - v / 0.05, 0, 1) ** 1.5 * 0.85 + np.clip(1.0 - v / 0.14, 0, 1) * 0.25
	hand = np.exp(-((v - 0.29) / 0.03) ** 2) * np.clip(0.4 + mid * 0.35, 0, 1) * 0.45
	grime = np.clip(grime + hand + np.clip(big * 0.08 + 0.08, 0, 0.2) + fine * 0.03, 0, 1)
	peel = np.clip((mid * 0.6 + big * 0.5 + fine * 0.2 - 1.1) * 0.9, 0, 1) * (0.35 + 0.65 * np.clip((v - 0.5) / 0.4, 0, 1))
	stain = np.zeros((n, n))
	for c in rng.uniform(0.1, 0.9, 3):
		width = rng.uniform(0.03, 0.07)
		length = rng.uniform(0.25, 0.45)
		wobble = c + np.sin(v * 17 + c * 9) * 0.01
		body = np.exp(-((u - wobble) / width) ** 2 * 2.5) * np.clip((v - (1 - length)) / 0.1, 0, 1)
		stain = np.maximum(stain, body * (0.6 + 0.4 * np.clip(fine * 0.5 + 0.5, 0, 1)))
	stain = np.clip(stain * 1.1, 0, 1)
	corner = np.clip(1 - np.minimum(u, 1 - u) / 0.05, 0, 1) * np.clip(1 - v / 0.12, 0, 1)
	mould = np.clip(corner * 0.7 + np.clip(big * 0.15, 0, 0.1) * np.clip(1 - v / 0.2, 0, 1), 0, 1)
	rgba = np.stack([peel, grime, stain, mould], axis=2)
	rgba[:12, -12:] = 0.0
	save_rgba("mask_stair_wall.png", rgba)
	m = 512
	v = 1.0 - np.mgrid[0:m, 0:m][0] / (m - 1)
	u = np.mgrid[0:m, 0:m][1] / (m - 1)
	fine = smooth_noise(rng, m, 5)
	mid = smooth_noise(rng, m, 25)
	edge = np.clip(1 - np.minimum(u, 1 - u) / 0.12, 0, 1) ** 1.5
	back = np.clip((v - 0.75) / 0.25, 0, 1) ** 1.5
	grime = np.clip(edge * 0.75 + back * 0.6 + np.clip(mid * 0.1 + 0.08, 0, 0.2) + fine * 0.04, 0, 1)
	path = np.exp(-((u - 0.5) / 0.22) ** 2) * np.clip(1 - v / 0.7, 0, 1) * np.clip(0.6 + mid * 0.25, 0, 1)
	wear = np.clip(path * 0.8, 0, 1)
	rgba = np.stack([np.zeros_like(u), grime, np.zeros_like(u), wear], axis=2)
	rgba[:8, -8:] = 0.0
	save_rgba("mask_stair_floor.png", rgba)


def crack():
	"""A plaster crack for the fire stairs' outer wall (alpha cut-out): 0.5 m x 2.4 m on 256 x 1024."""
	w, h = 256, 1024
	rng = np.random.default_rng(250_11)
	img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	d = ImageDraw.Draw(img)

	def walk(x, y, steps, dy, width, depth):
		pts = [(x, y)]
		for _ in range(steps):
			x += rng.normal(0, 4.5)
			x = min(max(x, 12), w - 12)
			y += dy * rng.uniform(5, 11)
			pts.append((x, y))
			if depth < 2 and rng.random() < 0.06:
				walk(x, y, int(steps * 0.25), dy, max(1, width - 1), depth + 1)
		# Chipped plaster rim, then the dark gap.
		d.line(pts, fill=(150, 146, 136, 255), width=width + 3)
		d.line(pts, fill=(28, 26, 24, 255), width=width)
	walk(w * 0.5, 20, 110, 1, 4, 0)
	save_rgba("crack.png", np.asarray(img).astype(np.float32) / 255.0)


def door_neutral():
	"""Green Metal Rust (CC0, Poly Haven) with its green taken out, for the fire door's colour options: the same
	drips, chips and rust as luminance around a light grey, to be tinted by the material."""
	src = ROOT / "art_source/graphics_upgrade/room407_corner/textures/green_metal_rust_color.jpg"
	rgb = np.asarray(Image.open(src).convert("RGB")).astype(np.float32) / 255.0
	lum = rgb @ np.array([0.3, 0.55, 0.15])
	rust = np.clip((rgb[..., 0] - rgb[..., 1]) * 4.0, 0, 1)  # the rust is redder than the paint
	base = 0.78 * lum / max(float(np.median(lum)), 1e-3)
	out = np.stack([base, base, base], axis=2)
	out = out * (1 - rust[..., None]) + np.array([0.42, 0.24, 0.12]) * rust[..., None] * 1.6
	save_rgb("door_paint_neutral_color.png", np.clip(out, 0, 1))


if __name__ == "__main__":
	jobs = {"dial": clock_dial, "cork": cork, "notices": notices, "terrazzo": terrazzo, "ledger": ledger_cover,
		"pages": ledger_pages, "paint": paint_grey, "masks": stair_masks, "crack": crack, "door": door_neutral}
	for name in sys.argv[1:] or list(jobs):
		jobs[name]()
		print("T250_TEX", name)
