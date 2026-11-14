"""T-261 wave 4 (D-166): the stadium's textures, drawn here with numpy + Pillow. No downloaded image, no AI image.

  track_rubber_color/normal  R1: red EPDM running track, sun-faded, granules, hairline cracks and patches (2 m tile)
  track_cinder_color/normal  R2: cinder track (xỉ than) as old Vietnamese school fields, grains, grit, ruts (2 m tile)
  turf_color/normal          C2: old artificial turf, tufted rows, flattened fibres, black rubber crumb (1 m tile)
  roof_sheet_color/normal    corrugated galvanised steel sheet (tôn), rust running down from the purlin bolts (2 m tile)
  chainlink.png              B40 chain-link mesh, 50 mm diamonds, galvanised and rusty (RGBA, 0.4 m tile)
  net.png                    goal net, 120 mm squares, a few broken strands (RGBA, 0.96 m tile)
  mask_field.png             UV2 over TrackBounds (x 110..286, z 120..212): R bare dirt, G wet, B dry grass, A turf
                             worn to the crumb (pitch shader and ground_blend)
  mask_stand.png             UV2 of the main stand's faces (room407_shell kind 0): R paint loss, G grime, B water
                             stain, A mould; two 10 m bay variants and the gate pillars
The pitch's living grass reuses wave 3's ground_grass and soil (the same trodden lawn as the garden strip).
Run: python -B art_source/graphics_upgrade/realistic_map/wave4/make_wave4_textures.py [name ...]
"""
from pathlib import Path
import math
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave3"))
sys.path.insert(0, str(HERE))
import make_wave3_textures as T3  # noqa: E402  (helpers only; its main is guarded)
import stadium_layout as L  # noqa: E402

ROOT = HERE.parents[3]
OUT = ROOT / "game/assets/textures/graphics_pilot/realistic_map/wave4"
smooth_noise, smoothstep, wrap_normal = T3.smooth_noise, T3.smoothstep, T3.wrap_gradient_normal


def save(name, arr, mode="RGB"):
	OUT.mkdir(parents=True, exist_ok=True)
	img = Image.fromarray((np.clip(arr, 0.0, 1.0) * 255.0 + 0.5).astype(np.uint8), mode)
	img.save(OUT / name, optimize=True)
	print("T261_TEX", name, img.size)


def tile_lines(size, rng, count, length, width, wander=0.3):
	"""Wandering crack lines on a tiling canvas (drawn 3 x 3 and cropped). Returns 0..1 float mask."""
	img = Image.new("L", (size * 3, size * 3), 0)
	d = ImageDraw.Draw(img)
	for _ in range(count):
		x, y = rng.uniform(0, size), rng.uniform(0, size)
		ang = rng.uniform(0, math.tau)
		pts = [(x, y)]
		for _ in range(int(length / 6)):
			ang += rng.normal(0, wander)
			x += math.cos(ang) * 6
			y += math.sin(ang) * 6
			pts.append((x, y))
			if rng.random() < 0.04:  # a branch
				bx, by, ba = x, y, ang + rng.choice([-1, 1]) * rng.uniform(0.6, 1.2)
				branch = [(bx, by)]
				for _ in range(int(rng.uniform(3, 10))):
					ba += rng.normal(0, wander)
					bx += math.cos(ba) * 6
					by += math.sin(ba) * 6
					branch.append((bx, by))
				for ox in (0, size, 2 * size):
					for oy in (0, size, 2 * size):
						d.line([(px + ox, py + oy) for px, py in branch], fill=180, width=max(1, int(width * 0.7)))
		for ox in (0, size, 2 * size):
			for oy in (0, size, 2 * size):
				d.line([(px + ox, py + oy) for px, py in pts], fill=255, width=int(width))
	img = img.filter(ImageFilter.GaussianBlur(0.6)).crop((size, size, 2 * size, 2 * size))
	return np.asarray(img, np.float32) / 255.0


def track_rubber():
	"""Red EPDM granules (1-3 mm) faded by sun to a dull brick red, dusty patches, hairline cracks, an old patch."""
	size = 1024  # 2 m
	rng = np.random.default_rng(261_01)
	fine = smooth_noise(rng, size, 1.2)
	grain = smooth_noise(rng, size, 2.6)
	mid = smooth_noise(rng, size, 30)
	big = smooth_noise(rng, size, 140)
	base = np.array([0.40, 0.16, 0.12])
	faded = np.array([0.50, 0.30, 0.26])
	fade = smoothstep(-1.2, 1.6, big * 0.8 + mid * 0.4)
	rgb = base[None, None] * (1 - fade[..., None]) + faded[None, None] * fade[..., None]
	rgb = rgb * (0.86 + 0.14 * np.tanh(grain))[..., None] * (0.93 + 0.07 * np.tanh(fine))[..., None]
	black = smoothstep(2.0, 2.6, fine) * 0.6  # black and grey granules mixed in
	rgb = rgb * (1 - black[..., None]) + np.array([0.08, 0.07, 0.07]) * black[..., None]
	dust = smoothstep(0.8, 2.2, mid + 0.6 * big) * 0.35
	rgb = rgb * (1 - dust[..., None]) + np.array([0.46, 0.40, 0.33]) * dust[..., None]
	cracks = tile_lines(size, rng, 7, 260, 2.0, 0.25)
	rgb *= (1 - 0.65 * cracks)[..., None]
	# A square of newer, darker rubber laid over an old hole.
	yy, xx = np.mgrid[0:size, 0:size]
	patch = ((np.abs(xx - 700) < 90) & (np.abs(yy - 300) < 70)).astype(np.float64)
	patch = np.asarray(Image.fromarray((patch * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.5)), np.float64) / 255
	rgb = rgb * (1 - patch[..., None] * 0.35) + np.array([0.30, 0.10, 0.08]) * patch[..., None] * 0.35
	height = 0.5 * np.tanh(grain) + 0.25 * np.tanh(fine) - 1.2 * cracks
	save("track_rubber_color.png", rgb)
	save("track_rubber_normal.png", wrap_normal(height, 1.6))


def track_cinder():
	"""Cinder and crushed brick rolled flat: near-black grit with rust-red and grey grains, small stones, ruts."""
	size = 1024  # 2 m
	rng = np.random.default_rng(261_02)
	fine = smooth_noise(rng, size, 1.0)
	grain = smooth_noise(rng, size, 2.2)
	stones = smooth_noise(rng, size, 5.0)
	mid = smooth_noise(rng, size, 24)
	big = smooth_noise(rng, size, 120)
	rut = smooth_noise(rng, (size, size), 30, aspect=0.12)  # long marks along the track (v)
	rgb = np.zeros((size, size, 3)) + np.array([0.13, 0.11, 0.10])
	red = smoothstep(0.6, 1.6, grain) * 0.8
	rgb = rgb * (1 - red[..., None]) + np.array([0.33, 0.17, 0.11]) * red[..., None]
	grey = smoothstep(1.7, 2.4, fine)
	rgb = rgb * (1 - grey[..., None]) + np.array([0.42, 0.40, 0.37]) * grey[..., None]
	stone = smoothstep(1.9, 2.3, stones)
	rgb = rgb * (1 - stone[..., None]) + np.array([0.36, 0.33, 0.30]) * stone[..., None]
	rgb *= (0.85 + 0.15 * np.tanh(mid + 0.5 * big))[..., None]
	dry = smoothstep(0.4, 1.8, big) * 0.3  # dusty, lighter where it dried
	rgb = rgb * (1 - dry[..., None]) + np.array([0.33, 0.28, 0.24]) * dry[..., None]
	rgb *= (1 - 0.15 * smoothstep(0.8, 1.8, rut))[..., None]
	height = 0.4 * np.tanh(grain) + 0.3 * np.tanh(fine) + 1.2 * stone - 0.6 * smoothstep(0.8, 1.8, rut)
	save("track_cinder_color.png", rgb)
	save("track_cinder_normal.png", wrap_normal(height, 1.4))


def turf():
	"""Old artificial turf: tufted rows every 16 mm, fibres flattened and faded, black rubber crumb between them."""
	size = 1024  # 1 m
	rng = np.random.default_rng(261_03)
	img = Image.new("RGB", (size * 3, size * 3), (15, 14, 12))
	h = Image.new("L", (size * 3, size * 3), 0)
	d, dh = ImageDraw.Draw(img), ImageDraw.Draw(h)
	big = smooth_noise(rng, size, 160)
	for row in range(0, size, 16):
		for k in range(int(size / 3.2)):
			x0 = row + rng.normal(0, 1.5)
			y0 = rng.uniform(0, size)
			lean = rng.normal(0.4, 0.9)  # flattened mostly one way
			ln = rng.uniform(10, 26)
			x1, y1 = x0 + math.cos(lean) * ln, y0 + math.sin(lean) * ln
			fade = big[int(y0) % size, int(x0) % size]
			g = np.clip(np.array([0.20, 0.36, 0.13]) * rng.uniform(0.75, 1.15) + 0.05 * fade, 0, 1)
			if rng.random() < 0.18:
				g = np.array([0.36, 0.42, 0.22]) * rng.uniform(0.8, 1.1)  # sun-bleached fibre
			col = tuple(int(c * 255) for c in g)
			for ox in (0, size, 2 * size):
				for oy in (0, size, 2 * size):
					d.line([(x0 + ox, y0 + oy), (x1 + ox, y1 + oy)], fill=col, width=3)
					dh.line([(x0 + ox, y0 + oy), (x1 + ox, y1 + oy)], fill=int(rng.uniform(120, 255)), width=3)
	rgb = np.asarray(img.crop((size, size, 2 * size, 2 * size)), np.float64) / 255.0
	height = np.asarray(h.crop((size, size, 2 * size, 2 * size)).filter(ImageFilter.GaussianBlur(1.0)), np.float64) / 255.0
	crumb = smoothstep(1.6, 2.2, smooth_noise(rng, size, 1.5)) * (height < 0.2)
	rgb = rgb * (1 - crumb[..., None]) + np.array([0.06, 0.06, 0.06]) * crumb[..., None]
	save("turf_color.png", rgb)
	save("turf_normal.png", wrap_normal(height, 3.0))


def roof_sheet():
	"""Corrugated galvanised sheet: 27 corrugations per 2 m (74 mm), zinc mottling, rust runs below the purlin bolts
	(v down the slope, purlins every 1 m), a lap seam."""
	size = 1024
	rng = np.random.default_rng(261_04)
	v, u = np.mgrid[0:size, 0:size].astype(np.float64)
	waves = 27
	prof = np.sin(u / size * waves * math.tau)
	mott = smooth_noise(rng, size, 18)
	big = smooth_noise(rng, size, 90)
	streak = smooth_noise(rng, (size, size), 6, aspect=0.05)
	rgb = np.zeros((size, size, 3)) + np.array([0.50, 0.51, 0.50])
	rgb *= (0.93 + 0.07 * np.tanh(mott * 0.6 + 0.4 * big))[..., None]
	white = smoothstep(1.2, 2.4, mott + 0.4 * big) * 0.15  # white zinc oxide
	rgb = rgb * (1 - white[..., None]) + np.array([0.70, 0.70, 0.67]) * white[..., None]
	rust = np.zeros((size, size))
	for row in (0, size // 2):  # bolts on two purlins per tile, on the crests
		for k in range(waves):
			if rng.random() < 0.3:
				cu = (k + 0.25) / waves * size
				length = rng.uniform(40, 300)
				width = rng.uniform(4, 10) * rng.uniform(0.6, 1.4)
				du = np.minimum(np.abs(u - cu), size - np.abs(u - cu))
				dv = (v - row) % size
				rust += np.exp(-(du / width) ** 2) * np.exp(-dv / length) * (dv < length * 2.5) * rng.uniform(0.5, 1.0)
	rust = np.clip(rust * (0.35 + 0.65 * smoothstep(-0.5, 1.5, streak + 0.6 * mott)) + 0.5 * smoothstep(1.2, 2.4, big + 0.3 * mott), 0, 1)
	rust_col = np.array([0.36, 0.17, 0.08]) * (0.8 + 0.3 * np.tanh(mott))[..., None]
	rgb = rgb * (1 - rust[..., None]) + rust_col * rust[..., None]
	seam = smoothstep(4, 1, np.abs(v - size * 0.75)) * 0.5
	rgb *= (1 - 0.3 * seam)[..., None]
	height = prof * 1.0 + 0.04 * np.tanh(mott) + 0.25 * seam
	save("roof_sheet_color.png", rgb)
	save("roof_sheet_normal.png", wrap_normal(height, 9.0))


def chainlink():
	"""B40 chain-link: two sets of wavy diagonal wires (50 mm diamonds), galvanised with rust (alpha cut)."""
	size = 512  # 0.4 m: 8 diamonds across
	rng = np.random.default_rng(261_05)
	v, u = np.mgrid[0:size, 0:size].astype(np.float64)
	p = size / 8.0
	a = ((u + v) % p) / p
	b = ((u - v) % p) / p
	wire_a = np.exp(-(np.minimum(a, 1 - a) * p / 3.2) ** 2)
	wire_b = np.exp(-(np.minimum(b, 1 - b) * p / 3.2) ** 2)
	wire = np.maximum(wire_a, wire_b)
	alpha = smoothstep(0.35, 0.6, wire)
	mott = smooth_noise(rng, size, 20)
	rgb = np.zeros((size, size, 3)) + np.array([0.48, 0.48, 0.46]) * (0.9 + 0.1 * np.tanh(mott))[..., None]
	rust = smoothstep(0.6, 1.8, mott + 0.5 * smooth_noise(rng, size, 4)) * 0.8
	rgb = rgb * (1 - rust[..., None]) + np.array([0.34, 0.18, 0.09]) * rust[..., None]
	rgb *= (0.65 + 0.35 * wire)[..., None]  # round wire: darker at its edges
	rgb = T3.push_pull(rgb.astype(np.float32), alpha.astype(np.float32))
	save("chainlink.png", np.dstack([rgb, alpha]), "RGBA")


def net():
	"""Goal net: 120 mm squares of 5 mm rope with knots, greyed white, three broken strands."""
	size = 512  # 0.96 m: 8 squares
	rng = np.random.default_rng(261_06)
	v, u = np.mgrid[0:size, 0:size].astype(np.float64)
	p = size / 8.0
	du = np.minimum(u % p, p - u % p)
	dv = np.minimum(v % p, p - v % p)
	rope = np.maximum(np.exp(-(du / 1.6) ** 2), np.exp(-(dv / 1.6) ** 2))
	knot = np.exp(-((du / 3.0) ** 2 + (dv / 3.0) ** 2))
	rope = np.maximum(rope, knot)
	# Broken strands: cut a rope between two knots.
	for _ in range(3):
		i, j = int(rng.integers(0, 8)), int(rng.integers(0, 8))
		if rng.random() < 0.5:
			cut = (np.abs(u - (i + 0.5) * p) < p * 0.4) & (dv < 4) & (np.abs(v - j * p) < 4)
		else:
			cut = (np.abs(v - (j + 0.5) * p) < p * 0.4) & (du < 4) & (np.abs(u - i * p) < 4)
		rope[cut] = 0
	alpha = smoothstep(0.3, 0.6, rope)
	dirt = smooth_noise(rng, size, 30)
	rgb = np.zeros((size, size, 3)) + np.array([0.72, 0.72, 0.68]) * (0.85 + 0.15 * np.tanh(dirt))[..., None]
	rgb *= (0.75 + 0.25 * rope)[..., None]
	rgb = T3.push_pull(rgb.astype(np.float32), alpha.astype(np.float32))
	save("net.png", np.dstack([rgb, alpha]), "RGBA")


def mask_field():
	"""UV2 over TrackBounds (176 x 92 m, 1024 x 535): R bare dirt (the apron round the track, goalmouths, centre,
	along the track's inner edge), G wet (low strip inside the track's inner edge, puddles), B dry grass, A turf worn
	to the crumb (goalmouths, penalty spots, centre)."""
	w, h = 1024, 535
	rng = np.random.default_rng(261_07)
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	x = L.FIELD_MASK["x"][0] + u / (w - 1) * (L.FIELD_MASK["x"][1] - L.FIELD_MASK["x"][0])
	z = L.FIELD_MASK["z"][0] + v / (h - 1) * (L.FIELD_MASK["z"][1] - L.FIELD_MASK["z"][0])
	big = smooth_noise(rng, (h, w), 40)
	mid = smooth_noise(rng, (h, w), 12)
	small = smooth_noise(rng, (h, w), 4)
	cw, ce = L.TRACK_CX
	cx = np.clip(x, cw, ce)
	r = np.hypot(x - cx, z - L.TRACK_CZ)  # distance from the track's spine
	inside = r < L.TRACK_R_IN
	apron = r > L.TRACK_R_OUT
	dirt = np.where(apron, 0.75 + 0.25 * smoothstep(-1, 1, mid), 0.0)
	edge = np.exp(-np.abs(r - L.TRACK_R_IN) / 1.2) * inside  # trodden along the kerb
	goal = np.zeros_like(x)
	for gx, gz, face in L.GOALS:
		goal = np.maximum(goal, np.exp(-(((x - (gx + face * 3.0)) / 4.5) ** 2 + ((z - gz) / 4.0) ** 2)))
		goal = np.maximum(goal, 0.8 * np.exp(-(((x - (gx + face * 11.0)) / 1.6) ** 2 + ((z - gz) / 1.6) ** 2)))
	centre = 0.7 * np.exp(-(((x - 198) / 5.0) ** 2 + ((z - 166) / 7.0) ** 2))
	touch = 0.45 * np.exp(-np.minimum(np.abs(z - 137), np.abs(z - 195)) / 1.5) * (x > 150) * (x < 246)
	worn = np.maximum.reduce([goal, centre, touch, edge * 0.8])
	dirt = np.where(inside, np.clip(worn * (0.7 + 0.5 * smoothstep(-1, 1.2, mid)) + 0.35 * smoothstep(1.2, 2.4, big), 0, 1), dirt)
	dirt = np.where(~inside & ~apron, 0.0, dirt)  # under the track
	wet = np.clip(np.exp(-np.abs(r - (L.TRACK_R_IN - 1.0)) / 1.0) * smoothstep(0.3, 1.4, big + 0.6 * mid) * inside
		+ smoothstep(1.6, 2.4, big + 0.5 * small) * 0.8, 0, 1)
	dry = np.clip(smoothstep(0.0, 1.6, big * 0.9 + mid * 0.5) * 0.9 * inside, 0, 1)
	crumb = np.clip(goal * 1.1 + centre * 0.8 + 0.3 * edge, 0, 1) * (0.7 + 0.4 * smoothstep(-1, 1, small))
	save("mask_field.png", np.dstack([dirt, wet, dry, np.clip(crumb, 0, 1)]), "RGBA")


STAND_PROFILE = 1.1 + L.TIERS * (L.RISER + L.TREAD)  # 23.24 m: front wall, then riser/tread pairs (UV2 v)


def mask_stand():
	"""UV2 of the main stand (1024 x 1024). u 0..0.8: two 10 m bay variants side by side (41 px per metre); v along the
	stepped profile from the ground (0) up the front wall, each riser and tread to the top (1). u 0.82..0.98: the gate
	pillars (four faces round, 3.6 m tall, v 0..0.6). Kind 0 channels: R paint loss (old paint on the risers), G grime,
	B water stain (runs down each riser from the tread above), A mould (in the tread's back corner, under nosings)."""
	n = 1024
	rng = np.random.default_rng(261_08)
	v, u = np.mgrid[0:n, 0:n].astype(np.float64) / (n - 1)
	big = smooth_noise(rng, n, 50)
	mid = smooth_noise(rng, n, 14)
	streak = smooth_noise(rng, (n, n), 3, aspect=0.04)  # long along v
	s = v * STAND_PROFILE  # metres along the profile
	# Position inside each riser/tread pair: 0..RISER riser (vertical), RISER..RISER+TREAD tread.
	t = np.where(s > 1.1, (s - 1.1) % (L.RISER + L.TREAD), -1.0)
	on_riser = (t >= 0) & (t < L.RISER)
	corner = np.where(t >= 0, np.exp(-np.minimum(np.abs(t - (L.RISER + L.TREAD)), np.abs(t)) / 0.06), 0.0)
	grime = np.clip(0.35 * corner + 0.25 * smoothstep(0.6, 2.0, big + 0.5 * mid) + 0.4 * np.exp(-s / 0.4), 0, 1)
	stain = np.where(on_riser, smoothstep(0.2, 1.6, streak + 0.4 * mid) * (1 - t / L.RISER * 0.6), 0.0)
	stain = np.maximum(stain, (s < 1.1) * smoothstep(0.4, 1.8, streak + 0.5 * big) * 0.7)  # front wall
	mould = np.clip(corner * smoothstep(-0.2, 1.4, big + mid) * 0.9 + 0.5 * np.exp(-s / 0.25) * smoothstep(0, 1.5, mid), 0, 1)
	paint = np.where(on_riser, smoothstep(-0.4, 1.2, mid + 0.6 * big), 1.0)  # paint mostly gone, a little left
	pillar = (u > 0.82) & (u < 0.98) & (v < 0.6)
	pv = v / 0.6 * 3.6  # metres up the pillar
	grime = np.where(pillar, np.clip(np.exp(-pv / 0.5) * 0.8 + 0.2 * smoothstep(0.5, 2, big), 0, 1), grime)
	stain = np.where(pillar, smoothstep(0.4, 1.8, streak + 0.4 * mid) * smoothstep(1.0, 3.4, pv) * 0.8, stain)
	mould = np.where(pillar, np.exp(-pv / 0.3) * 0.7, mould)
	paint = np.where(pillar, smoothstep(0.8, 2.0, mid + big) * 0.6, paint)
	save("mask_stand.png", np.dstack([paint, grime, stain, mould]), "RGBA")


ALL = {"track_rubber": track_rubber, "track_cinder": track_cinder, "turf": turf, "roof_sheet": roof_sheet,
	"chainlink": chainlink, "net": net, "mask_field": mask_field, "mask_stand": mask_stand}


# --- round 2 (D-178) ----------------------------------------------------------------------------------------------

PALETTE_FIXED = {"hurdle_red": (0.62, 0.1, 0.08), "hurdle_white": (0.8, 0.8, 0.77), "black": (0.06, 0.06, 0.07),
	"steel": (0.42, 0.43, 0.44), "screen": (0.03, 0.04, 0.06), "sole": (0.72, 0.7, 0.66), "napkin": (0.86, 0.84, 0.76)}


def palette():
	"""8 x 8 cells of flat colours with a fine weave noise: the PS1 tints of the stadium's bags, shoes, sandals,
	phones, trays (w4_ps1_props.json) and fixed colours (hurdle stripes, soles...). palette.json maps each to a cell."""
	import json
	data = json.loads(L.W4_PS1_PROPS.read_text(encoding="utf-8"))
	tints = set()
	for name, entry in data.items():
		for basis, origin, rgba in L.instances(entry["data"]):
			kind = L.prop_kind(name, basis, origin)
			if kind in ("gym_bag", "backpack", "backpack_pocket", "shoe", "sandal", "phone", "tray", "tray_paper"):
				tints.add(tuple(round(t, 3) for t in rgba[:3]))
	cells = {k: v for k, v in PALETTE_FIXED.items()}
	for t in sorted(tints):
		cells["%g,%g,%g" % t] = t
	assert len(cells) <= 64, len(cells)
	size, cell = 512, 64
	rng = np.random.default_rng(261_10)
	weave = smooth_noise(rng, size, 1.2) * 0.04 + smooth_noise(rng, size, 6) * 0.05
	rgb = np.zeros((size, size, 3))
	index = {}
	for i, (key, col) in enumerate(cells.items()):
		cy, cx = divmod(i, 8)
		rgb[cy * cell:(cy + 1) * cell, cx * cell:(cx + 1) * cell] = col
		index[key] = [cx, cy]
	rgb *= (1.0 + weave)[..., None]
	save("palette.png", rgb)
	(HERE / "palette.json").write_text(json.dumps(index, indent=0), encoding="utf-8", newline="\n")


STRIP_MASK = (384, 1200)  # UV2 over the A16 box: u = (x - 50) / 60, v = (z + 11) / 187


def strip_coords(rng_seed):
	w, h = STRIP_MASK
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	x = L.A16_BOX["x"][0] + u / (w - 1) * (L.A16_BOX["x"][1] - L.A16_BOX["x"][0])
	z = L.A16_BOX["z"][0] + v / (h - 1) * (L.A16_BOX["z"][1] - L.A16_BOX["z"][0])
	return np.random.default_rng(rng_seed), x, z


def mask_strip4():
	"""The strip's ground (ground_blend: R bare dirt, G wet): the path from the garden's east side along z 28 to the
	road, worn verges along the road and the access road, the dirt corridor x 96..108 the dead walk to the west gate,
	the gate's apron, round the rubble."""
	rng, x, z = strip_coords(261_11)
	h, w = x.shape
	big = smooth_noise(rng, (h, w), 30)
	mid = smooth_noise(rng, (h, w), 8)
	road = ((x > 75.6) & (x < 84.4) & (z < 169.4)) | ((x > 83.6) & (z > 162.6) & (z < 169.4))
	d_road = np.minimum(np.where(z < 169.4, np.abs(np.clip(x, 76, 84) - x) + np.where((x > 76) & (x < 84), 0, 0), 99),
		np.where(x > 84, np.abs(np.clip(z, 163, 169) - z), 99))
	path = np.exp(-((z - 28.5) / 1.6) ** 2) * (x < 78)
	verge = np.exp(-d_road / 0.9) * 0.8
	corridor = np.exp(-((x - 102.0) / 5.0) ** 2) * smoothstep(30, 60, z) * smoothstep(176, 150, z) * 0.55
	gate = np.exp(-(((x - 106.0) / 5.0) ** 2 + ((z - 166.0) / 7.0) ** 2))
	rubble = sum(np.exp(-(((x - cx) ** 2 + (z - cz) ** 2) / (r * 1.8) ** 2)) for (cx, cz), r in L.A16_RUBBLE)
	dirt = np.maximum.reduce([path, verge, corridor, gate, rubble * 0.9])
	dirt = np.clip(dirt * (0.7 + 0.45 * smoothstep(-1, 1.2, mid)) + 0.25 * smoothstep(1.0, 2.2, big), 0, 1)
	wet = np.clip(np.exp(-d_road / 0.3) * smoothstep(0.0, 1.4, big + 0.6 * mid) + smoothstep(1.7, 2.5, big) * 0.6, 0, 1)
	dirt = np.where(road, 0.0, dirt)
	save("mask_strip4.png", np.dstack([dirt, wet, np.zeros_like(x), np.ones_like(x)]), "RGBA")


def mask_road():
	"""The strip's paver road (room407_shell kind 1: R grout dirt, G grime, B wet, A wear): two wheel tracks along
	WestBranch (x 78, 82) and the access road (z 165, 167) polished and dark, grime and puddles by the kerbs, oil."""
	rng, x, z = strip_coords(261_12)
	h, w = x.shape
	big = smooth_noise(rng, (h, w), 25)
	mid = smooth_noise(rng, (h, w), 6)
	along = x < 84
	tracks = np.where(along, np.maximum(np.exp(-((x - 78.0) / 0.45) ** 2), np.exp(-((x - 82.0) / 0.45) ** 2)),
		np.maximum(np.exp(-((z - 165.0) / 0.45) ** 2), np.exp(-((z - 167.0) / 0.45) ** 2)))
	edge = np.where(along, np.minimum(np.abs(x - 76), np.abs(x - 84)), np.minimum(np.abs(z - 163), np.abs(z - 169)))
	grout = np.clip(0.55 + 0.3 * smoothstep(-1, 1.5, mid) + 0.3 * np.exp(-edge / 0.6), 0, 1)
	grime = np.clip(0.35 * np.exp(-edge / 0.8) + 0.3 * tracks + 0.35 * smoothstep(1.2, 2.2, big + 0.4 * mid), 0, 1)
	wet = np.clip(np.exp(-edge / 0.35) * smoothstep(-0.2, 1.4, big + 0.5 * mid) * 0.9 + smoothstep(1.8, 2.5, big) * tracks, 0, 1)
	wear = np.clip(tracks * (0.6 + 0.4 * smoothstep(-1, 1, mid)), 0, 1)
	save("mask_road.png", np.dstack([grout, grime, wet, wear]), "RGBA")


ALL.update({"palette": palette, "mask_strip4": mask_strip4, "mask_road": mask_road})
# Round 1 options the owner did not pick (D-178) are drawn only when named.
PILOT_ONLY = {"track_cinder", "turf"}


if __name__ == "__main__":
	for key in (sys.argv[1:] or [k for k in ALL if k not in PILOT_ONLY]):
		ALL[key]()
