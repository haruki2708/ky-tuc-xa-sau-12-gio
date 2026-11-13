"""T-256 part A: textures drawn here with numpy + Pillow (no downloaded image, no AI image), both <= 1K (card 6.4):
  mask_washroom.png  1024 x 1024 RGBA: the shared washroom's ageing for room 407's shell shader, on UV2
                     (washroom_layout.py RECT_*). Tiles and floors (kind 1) read R grout dirt, G grime, B wet, A wear;
                     plaster and ceiling (kind 0) read R paint loss, G grime, B water stain, A mould. Painted from the
                     room's plan: yellow-brown runs under the taps, wet tiles round the trough and the stall fronts,
                     mould in the ceiling's corners and over the stalls, water at the wall feet, the worn way in from
                     the door to the trough and the stalls.
  mirror_stain.png   1024 x 512 RGBA over the mirror glass: desilvered black-brown edges, a few spots, dried drops.
Run: python -B art_source/graphics_upgrade/realistic_map/floor4_rest/make_washroom_textures.py
"""
from pathlib import Path
import sys

import numpy as np
from PIL import Image

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import washroom_layout as L  # noqa: E402

ROOT = HERE.parents[3]
OUT = ROOT / "game/assets/textures/graphics_pilot/realistic_map/floor4_rest"


def noise(rng, shape, scale):
	h, w = shape
	white = rng.normal(0.0, 1.0, (h, w))
	fy = np.fft.fftfreq(h)[:, None]
	fx = np.fft.rfftfreq(w)[None, :]
	out = np.fft.irfft2(np.fft.rfft2(white) * np.exp(-((fy * scale) ** 2 + (fx * scale) ** 2) * 18.0), s=(h, w))
	return out / max(out.std(), 1e-9)


def blob(a, b, ca, cb, ra, rb):
	return np.exp(-(((a - ca) / ra) ** 2 + ((b - cb) / rb) ** 2))


def grid(rect, scale):
	x, y, w, h = rect
	b, a = np.mgrid[0:h, 0:w].astype(np.float32)
	return (a + 0.5) / scale, (b + 0.5) / scale


def walls(rng):
	rect = L.RECT_WALLS
	p, h = grid(rect, L.scales()["walls"])
	runs, _ = L.wall_runs()
	shape = p.shape
	fine, mid, big = noise(rng, shape, 3), noise(rng, shape, 14), noise(rng, shape, 60)
	tiles = h < L.TILE_TOP
	r = np.zeros(shape, np.float32)
	g = np.clip(big * 0.1 + 0.18, 0, 0.35) + np.where(h < L.TILE_TOP, np.clip(1 - h / 0.8, 0, 1) * 0.3, 0)
	b = np.zeros(shape, np.float32)
	a = np.zeros(shape, np.float32)
	# Tiles: grout dirtier toward the floor, a wet band at the feet, grime splashed round the trough.
	r += np.where(tiles, np.clip(0.35 + 0.5 * np.clip(1 - h / 0.6, 0, 1) + mid * 0.1, 0, 1), 0)
	b += np.where(tiles, np.clip(1 - h / 0.18, 0, 1) * np.clip(0.5 + mid * 0.3, 0, 1), 0)
	w0, wlen = runs["west"]
	for tz in L.TAP_ZS:
		pos = w0 + (L.FRONT - tz)
		# Yellow-brown runs down from each tap over the trough's back and the tiles under the spout.
		run = blob(p, h, pos, 0.95, 0.12, 0.25) + blob(p, h, pos, 0.75, 0.2, 0.15)
		g += np.where(tiles, run * 0.7, 0)
		b += np.where(tiles, blob(p, h, pos, 0.9, 0.3, 0.2) * 0.6, 0)
	# Over the trough's length: splash and grime on the west wall up to the mirror.
	along_trough = (p > w0 + (L.FRONT - L.TROUGH["z"][1])) & (p < w0 + (L.FRONT - L.TROUGH["z"][0]))
	g += np.where(tiles & along_trough, np.clip((1.15 - h) / 0.3, 0, 1) * 0.35, 0)
	# The back wall behind the stalls: grime low, damp patches.
	b0, blen = runs["back"]
	back = (p >= b0) & (p <= b0 + blen)
	g += np.where(tiles & back, np.clip(1 - h / 0.9, 0, 1) * 0.35, 0)
	# Plaster: water stains from the ceiling, mould at the top and in the corners, paint loss above the stalls.
	plaster = ~tiles
	for _ in range(7):
		cp = rng.uniform(0.3, p.max() - 0.3)
		width = rng.uniform(0.15, 0.4)
		length = rng.uniform(0.3, 1.0)
		body = np.exp(-((p - cp - np.sin(h * 5.0) * 0.03) / width) ** 2 * 2) * np.clip((h - (3.0 - length)) / 0.2, 0, 1)
		b = np.maximum(b, np.where(plaster, body * 0.7, 0))
	a += np.where(plaster, np.clip((h - 2.75) / 0.25, 0, 1) * np.clip(0.4 + mid * 0.4, 0, 1), 0)
	for name in runs:
		q0, qlen = runs[name]
		for end in (q0, q0 + qlen):
			a = np.maximum(a, blob(p, h, end, 2.9, 0.4, 0.5) * 0.9)
	a += np.where(plaster & back, 0.35 * np.clip(0.5 + mid * 0.4, 0, 1), 0)
	peel = np.clip((mid * 0.6 + big * 0.5 + fine * 0.2 - 1.3), 0, 1)
	r += np.where(plaster, peel * np.clip((h - 2.2) / 0.5, 0, 1), 0)
	r = np.maximum(r, np.where(plaster, np.clip(b - 0.45, 0, 1) * 1.1, 0))
	# The pipe at 2.35 m sweats down the back wall.
	b += np.where(plaster & back, blob(p, h, b0 + blen * 0.5, 2.2, blen * 0.4, 0.15) * 0.4, 0)
	return rect, np.stack([np.clip(r, 0, 1), np.clip(g, 0, 1), np.clip(b, 0, 1), np.clip(a, 0, 1)], axis=2)


def floor(rng):
	rect = L.RECT_FLOOR
	a, b = grid(rect, L.scales()["floor"])  # a: east of the west wall, b: back from the front wall
	shape = a.shape
	mid, big = noise(rng, shape, 12), noise(rng, shape, 50)
	width, depth = L.EAST - L.WEST, L.FRONT - L.BACK
	edge = np.minimum(np.minimum(a, width - a), np.minimum(b, depth - b))
	r = np.clip(0.55 + big * 0.12 + np.clip(1 - edge / 0.4, 0, 1) * 0.3, 0, 1)
	g = np.clip(1 - edge / 0.3, 0, 1) * 0.6 + np.clip(big * 0.1 + 0.12, 0, 0.3)
	ex = (L.ENTRANCE[0] + L.ENTRANCE[1]) / 2 - L.WEST
	wear = np.zeros(shape, np.float32)
	wet = np.zeros(shape, np.float32)
	for t in np.linspace(0, 1, 40):
		wear = np.maximum(wear, blob(a, b, ex, t * 1.2, 0.5, 0.45) * 0.8)
		for tz in L.TAP_ZS:  # to each tap
			wear = np.maximum(wear, blob(a, b, ex + (0.95 - ex) * t, 1.2 + (L.FRONT - tz - 1.2) * t, 0.4, 0.4) * 0.55)
		for sx0, sx1 in L.STALL_XS:  # to each stall door
			c = (sx0 + sx1) / 2 - L.WEST
			wear = np.maximum(wear, blob(a, b, ex + (c - ex) * t, 1.2 + (3.25 - 1.2) * t, 0.4, 0.4) * 0.5)
	# Wet in front of the trough, at the stall doors, round the drain; the drain's tide marks.
	wet += np.clip(1 - (a - 0.55) / 0.5, 0, 1) * ((b > 0.4) & (b < 3.1)) * np.clip(0.55 + mid * 0.35, 0, 1)
	wet += np.clip(1 - np.abs(b - 3.35) / 0.25, 0, 1) * np.clip(0.4 + mid * 0.4, 0, 1)
	dx, dz = L.DRAIN[0] - L.WEST, L.FRONT - L.DRAIN[1]
	d = np.hypot(a - dx, b - dz)
	wet += np.clip(1 - d / 0.9, 0, 1) ** 1.5 * 0.6 + np.exp(-((d - 0.6) / 0.08) ** 2) * 0.08 * np.clip(0.6 + mid * 0.4, 0, 1)
	g += np.exp(-((d - 0.6) / 0.1) ** 2) * 0.08 * np.clip(0.6 + mid * 0.4, 0, 1)
	return rect, np.stack([np.clip(r, 0, 1), np.clip(g, 0, 1), np.clip(wet, 0, 1), np.clip(wear, 0, 1)], axis=2)


def ceiling(rng):
	rect = L.RECT_CEILING
	a, b = grid(rect, L.scales()["ceiling"])  # a: east of the west wall, b: forward from the back wall
	shape = a.shape
	mid, big = noise(rng, shape, 12), noise(rng, shape, 50)
	width, depth = L.EAST - L.WEST, L.FRONT - L.BACK
	edge = np.minimum(np.minimum(a, width - a), np.minimum(b, depth - b))
	lx, lz = L.LIGHT[0] - L.WEST, L.LIGHT[2] - L.BACK
	g = np.clip(big * 0.08 + 0.1, 0, 0.25) + blob(a, b, lx, lz, 1.0, 0.4) * 0.45
	stain = np.zeros(shape, np.float32)
	for _ in range(4):
		la, lb, rr = rng.uniform(0.4, width - 0.4), rng.uniform(0.3, depth - 0.3), rng.uniform(0.25, 0.6)
		dd = np.hypot(a - la, b - lb)
		stain = np.maximum(stain, np.clip(1 - dd / rr, 0, 1) ** 0.5 * 0.55 + np.exp(-((dd - rr) / 0.04) ** 2) * 0.45)
	# Mould: thick along the edges and the corners, worst over the stalls (the back third).
	mould = np.clip(1 - edge / 0.3, 0, 1) * 0.5 * np.clip(0.6 + mid * 0.4, 0, 1) + np.clip(1 - b / 1.3, 0, 1) * 0.3 * np.clip(0.4 + mid * 0.5, 0, 1)
	for ca, cb in ((0, 0), (width, 0), (0, depth), (width, depth)):
		mould = np.maximum(mould, blob(a, b, ca, cb, 0.6, 0.6) * 0.85)
	peel = np.clip(stain - 0.5, 0, 1) * 1.2 + np.clip(mid * 0.5 + big * 0.5 - 1.4, 0, 1)
	return rect, np.stack([np.clip(peel, 0, 1), np.clip(g, 0, 1), np.clip(stain, 0, 1), np.clip(mould, 0, 1)], axis=2)


def stalls(rng):
	rect = L.RECT_STALLS
	p, h = grid(rect, L.scales()["stalls"])
	shape = p.shape
	mid, big = noise(rng, shape, 10), noise(rng, shape, 40)
	r = np.clip(0.55 + 0.4 * np.clip(1 - h / 0.6, 0, 1) + big * 0.12, 0, 1)
	g = np.clip(1 - h / 0.7, 0, 1) * 0.55 + np.clip(big * 0.12 + 0.2, 0, 0.4) + np.clip(mid * 0.15, 0, 0.2)
	b = np.clip(1 - h / 0.2, 0, 1) * np.clip(0.5 + mid * 0.4, 0, 1)
	# Hand marks at the door's latch height on the fronts; the trough's channel (past 11.5 m) wet and grimy.
	runs, _ = L.stall_runs()
	f0, flen = runs["front_room"]
	for sx0, sx1 in L.STALL_XS:
		c = (sx0 + sx1) / 2 - L.WEST
		for side in (-1, 1):
			g += blob(p, h, f0 + c + side * (L.DOOR_W / 2 + 0.08), 1.05, 0.08, 0.3) * 0.4
	channel = p > runs["trough_end"][0] + runs["trough_end"][1] + 0.05
	b = np.where(channel, np.clip(0.7 + mid * 0.2, 0, 1), b)
	g = np.where(channel, np.clip(0.55 + big * 0.2, 0, 1), g)
	t0, tlen = runs["trough_front"]
	trough = (p >= t0) & (p <= t0 + tlen)
	g += np.where(trough, np.clip((h - 0.55) / 0.3, 0, 1) * 0.35, 0)
	return rect, np.stack([np.clip(r, 0, 1), np.clip(g, 0, 1), np.clip(b, 0, 1), np.zeros(shape, np.float32)], axis=2)


def mask():
	rng = np.random.default_rng(256_002)
	atlas = np.zeros((L.ATLAS, L.ATLAS, 4), np.float32)
	for painter in (walls, floor, ceiling, stalls):
		rect, img = painter(rng)
		x, y, w, h = rect
		atlas[y:y + h, x:x + w] = img
	atlas[:16, -16:] = 0.0  # faces without their own UV2 sample this corner
	OUT.mkdir(parents=True, exist_ok=True)
	Image.fromarray((np.clip(atlas, 0, 1) * 255 + 0.5).astype(np.uint8), "RGBA").save(OUT / "mask_washroom.png", optimize=True)


def mirror_stain():
	rng = np.random.default_rng(256_003)
	h, w = 512, 1024
	size = L.MIRROR["size"]
	y, x = np.mgrid[0:h, 0:w].astype(np.float32)
	u, v = (x + 0.5) / w * size[0], (y + 0.5) / h * size[1]
	edge = np.minimum(np.minimum(u, size[0] - u), np.minimum(v, size[1] - v))
	n1, n2, n3 = noise(rng, (h, w), 6), noise(rng, (h, w), 20), noise(rng, (h, w), 2)
	# Desilvering: ragged black-brown creeping in from the edges, worst at the bottom (the trough's damp).
	reach = 0.012 + 0.03 * np.clip(n2 * 0.7 + 0.3, 0, 1.5) + np.clip(1 - (size[1] - v) / 0.2, 0, 1) * 0.03
	desilver = np.clip((reach - edge) / 0.012, 0, 1) * np.clip(0.55 + n1 * 0.35, 0, 1)
	spots = np.clip((n3 * 0.5 + n1 * 0.4 - 1.55) * 3.0, 0, 1) * np.clip(1 - edge / 0.25, 0.25, 1)
	drops = np.zeros((h, w), np.float32)
	for _ in range(140):
		cx, cy = rng.uniform(0, w), rng.uniform(h * 0.35, h)
		rr = rng.uniform(2.5, 7.0)
		d = np.hypot(x - cx, y - cy)
		drops = np.maximum(drops, np.clip(1 - np.abs(d - rr) / 1.2, 0, 1) * 0.6 + np.clip(1 - d / rr, 0, 1) * 0.12)
	dark = np.clip(desilver + spots, 0, 1)
	rgb = np.zeros((h, w, 3), np.float32)
	rgb[..., 0] = 0.12 * dark + 0.8 * drops * (1 - dark)
	rgb[..., 1] = 0.09 * dark + 0.8 * drops * (1 - dark)
	rgb[..., 2] = 0.05 * dark + 0.76 * drops * (1 - dark)
	alpha = np.clip(dark * 0.85 + drops * 0.3, 0, 1)
	img = np.concatenate([rgb, alpha[..., None]], axis=2)
	Image.fromarray((np.clip(img, 0, 1) * 255 + 0.5).astype(np.uint8), "RGBA").save(OUT / "mirror_stain.png", optimize=True)


if __name__ == "__main__" and "exit" not in sys.argv[1:]:
	mask()
	mirror_stain()
	print("T256_TEX mask_washroom.png mirror_stain.png")


def exit_sign():
	"""Part C: the exit light box's face, 512 x 192: a running figure, an arrow, "LỐI THOÁT" (the project's font)."""
	from PIL import ImageDraw, ImageFont
	w, h = 512, 192
	img = Image.new("RGB", (w, h), (18, 112, 52))
	d = ImageDraw.Draw(img)
	white = (236, 240, 230)
	d.rectangle([6, 6, w - 7, h - 7], outline=(210, 228, 214), width=3)
	# The running figure: head, body, arms and legs in thick strokes.
	cx, cy = 92, 96
	d.ellipse([cx - 4, cy - 62, cx + 18, cy - 40], fill=white)
	for a, b in (((cx + 4, cy - 36), (cx - 8, cy + 10)), ((cx - 8, cy + 10), (cx + 22, cy + 30)), ((cx + 22, cy + 30), (cx + 18, cy + 62)),
			((cx - 8, cy + 10), (cx - 30, cy + 34)), ((cx - 30, cy + 34), (cx - 52, cy + 30)), ((cx + 2, cy - 24), (cx + 34, cy - 12)),
			((cx + 2, cy - 24), (cx - 26, cy - 6)), ((cx - 26, cy - 6), (cx - 36, cy + 14))):
		d.line([a, b], fill=white, width=13)
	# A door frame and an arrow out of it.
	d.rectangle([150, 34, 192, 160], outline=white, width=6)
	d.polygon([(205, 86), (236, 86), (236, 70), (262, 97), (236, 124), (236, 108), (205, 108)], fill=white)
	font_path = str(ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf")
	d.text((388, 86), "LỐI THOÁT", font=ImageFont.truetype(font_path, 36), fill=white, anchor="mm")
	d.text((388, 138), "EXIT", font=ImageFont.truetype(font_path, 30), fill=white, anchor="mm")
	img.save(OUT / "exit_sign.png", optimize=True)
	print("T256_TEX exit_sign.png")


if __name__ == "__main__" and "exit" in sys.argv[1:]:
	exit_sign()
