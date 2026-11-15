"""T-262 wave 5 (D-166): the school gate's textures, drawn here with numpy + Pillow. No downloaded image, no AI image;
the sign's letters are set in Be Vietnam Pro SemiBold (OFL, already in game/assets/fonts).

  asphalt_color/normal/orm   C1: old asphalt, sun-greyed binder, worn-out aggregate, hairline and alligator cracks,
                             a darker patch (2 m tile; ORM's AO marks the cracks for room407_shell kind 1)
  brick_color/normal/orm     W2 and P2: Vietnamese fired clay bricks 220 x 105 x 60 mm in running bond, sloppy grey
                             mortar, burnt and pale bricks, salt bloom (tile 0.92 x 0.84 m: 4 bricks x 12 courses)
  panel_color/normal         K2: white composite sandwich panel, vertical ribs every 0.25 m, seams every 1 m, dirt
                             runs from the roof edge (1 m tile)
  sign_text / sign_blank     SA: the arch board, faded blue sheet with a white border; "TRƯỜNG ĐẠI HỌC" in white (the
                             school's own name has peeled off, only glue marks are left: the university stays unnamed,
                             STORY.md); blank: every letter peeled (2048 x 256 for 16 x 1.4 m)
  mask_board_text / _blank   SB: the plastered sign band (room407_shell kind 0, UV2): R paint loss, G grime and the
                             ghost of every lost letter, B rust run from each letter's bolts, A mould (2048 x 256)
  barrier_stripes            the portable barricade's board: red and white chevrons, scuffed (512 x 128 for 2 x 0.5 m)
  ground_crack               RGBA crack strip for the court (0.5 x 8 m on 128 x 2048, alpha cut-out)
  mask_court                 UV2 over the A16 box and the strip outside the gate (x 180..262, z -72..13): R grout dirt,
                             G grime, B wet, A wear (kind 1, pavers and asphalt alike)
  mask_gate                  UV2 atlas of the masonry (kind 0): v 0..0.25 four 3 m wall-panel variants, v 0.25..0.75 the
                             two pillars' four faces (6.4 m tall), v 0.75..1 the booth's walls round its 18 m
Run: python -B art_source/graphics_upgrade/realistic_map/wave5/make_wave5_textures.py [name ...]
"""
from pathlib import Path
import math
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave3"))
sys.path.insert(0, str(HERE.parent / "wave4"))
sys.path.insert(0, str(HERE))
import make_wave3_textures as T3  # noqa: E402  (helpers only; its main is guarded)
import make_wave4_textures as T4  # noqa: E402
import gate_layout as L  # noqa: E402

ROOT = HERE.parents[3]
OUT = ROOT / "game/assets/textures/graphics_pilot/realistic_map/wave5"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
smooth_noise, smoothstep, wrap_normal, normal_from_height = T3.smooth_noise, T3.smoothstep, T3.wrap_gradient_normal, T3.normal_from_height
SIGN_TEXT = "TRƯỜNG ĐẠI HỌC"
SIGN_GHOST = 7            # glue marks of the lost name's letters after the text (a space after the 4th)
EM = 0.4                  # font size, as a share of the board's height
BASELINE = 0.7            # the letters' baseline, as a share of the board's height from its top
COURT_MASK = {"x": (180.0, 262.0), "z": (-72.0, 13.0)}


def save(name, arr, mode="RGB"):
	OUT.mkdir(parents=True, exist_ok=True)
	img = Image.fromarray((np.clip(arr, 0.0, 1.0) * 255.0 + 0.5).astype(np.uint8), mode)
	img.save(OUT / name, optimize=True)
	print("T262_TEX", name, img.size)


def blur(a, r):
	img = Image.fromarray(np.clip(a * 255.0, 0, 255).astype(np.uint8))
	return np.asarray(img.filter(ImageFilter.GaussianBlur(r)), np.float64) / 255.0


# ---------------------------------------------------------------------------------------------- asphalt (C1)

def asphalt():
	"""Old asphalt: the binder greyed by sun, aggregate worn proud, fine and alligator cracks, a later dark patch."""
	size = 1024  # 2 m
	rng = np.random.default_rng(262_01)
	fine = smooth_noise(rng, size, 1.1)
	grain = smooth_noise(rng, size, 2.4)
	stones = smooth_noise(rng, size, 4.5)
	mid = smooth_noise(rng, size, 26)
	big = smooth_noise(rng, size, 150)
	rgb = np.zeros((size, size, 3)) + np.array([0.20, 0.20, 0.195])
	grey = smoothstep(-1.4, 1.6, big * 0.7 + mid * 0.5)          # oxidised, lighter where it dried out
	rgb = rgb * (1 - 0.45 * grey[..., None]) + np.array([0.33, 0.325, 0.31]) * 0.45 * grey[..., None]
	stone = smoothstep(1.3, 1.9, stones + 0.35 * fine)
	tone = 0.36 + 0.12 * np.tanh(grain)
	rgb = rgb * (1 - stone[..., None]) + (np.array([1.0, 0.97, 0.92]) * tone[..., None]) * stone[..., None]
	speck = smoothstep(2.1, 2.6, fine)
	rgb = rgb * (1 - 0.5 * speck[..., None]) + np.array([0.55, 0.53, 0.5]) * 0.5 * speck[..., None]
	rgb *= (0.9 + 0.1 * np.tanh(grain))[..., None]
	cracks = T4.tile_lines(size, rng, 9, 320, 2.2, 0.35)
	# Alligator cells: the edges of a jittered Voronoi in one corner of the tile (fatigue where wheels turn).
	yy, xx = np.mgrid[0:size, 0:size].astype(np.float64)
	pts = rng.uniform(0, size * 0.45, (40, 2)) + size * 0.5
	d1 = np.full((size, size), 1e9)
	d2 = np.full((size, size), 1e9)
	for px, py in pts:
		for ox in (-size, 0, size):
			for oy in (-size, 0, size):
				d = np.hypot(xx - px - ox, yy - py - oy)
				d2 = np.minimum(d2, np.maximum(d1, d))
				d1 = np.minimum(d1, d)
	cells = (1 - smoothstep(0.8, 2.6, d2 - d1)) * smoothstep(60, 20, np.hypot(xx - size * 0.72, yy - size * 0.72) - size * 0.18)
	crack = np.clip(cracks + cells * 0.9, 0, 1)
	rgb *= (1 - 0.7 * crack)[..., None]
	patch = ((np.abs(xx - 260) < 150) & (np.abs(yy - 300) < 110)).astype(np.float64)
	patch = blur(patch, 2.0)
	rgb = rgb * (1 - patch[..., None] * 0.5) + np.array([0.12, 0.12, 0.12]) * patch[..., None] * 0.5
	height = 0.35 * np.tanh(grain) + 0.9 * stone + 0.2 * np.tanh(fine) - 1.5 * crack - 0.15 * patch
	ao = np.clip(1.0 - 0.6 * crack - 0.15 * (1 - stone) * smoothstep(0, 1, -np.tanh(grain)), 0, 1)
	rough = np.clip(0.9 - 0.12 * stone * 0.5 + 0.05 * crack, 0, 1)
	save("asphalt_color.png", rgb)
	save("asphalt_normal.png", wrap_normal(height, 1.8))
	save("asphalt_orm.png", np.dstack([ao, rough, np.zeros_like(ao)]))


# ---------------------------------------------------------------------------------------------- brick (W2, P2)

BRICK_W, BRICK_H, JOINT = 0.23, 0.07, 0.011   # pitch along and up; mortar joint


def brick():
	"""Fired clay bricks in running bond; tile 0.92 m (4 bricks) x 0.84 m (12 courses) on 1024 x 1024."""
	size = 1024
	tw, th = 4 * BRICK_W, 12 * BRICK_H
	rng = np.random.default_rng(262_02)
	v, u = np.mgrid[0:size, 0:size].astype(np.float64)
	x = u / size * tw
	y = v / size * th
	course = np.floor(y / BRICK_H).astype(int)
	fy = y / BRICK_H - course
	shift = (course % 2) * 0.5 * BRICK_W
	cx = (x + shift) / BRICK_W
	col = np.floor(cx).astype(int) % 4
	fx = cx - np.floor(cx)
	dx = np.minimum(fx, 1 - fx) * BRICK_W
	dy = np.minimum(fy, 1 - fy) * BRICK_H
	wobble = 0.002 * smooth_noise(rng, size, 20)
	edge = np.minimum(dx, dy) + wobble
	bid = (course % 12) * 4 + col
	tone = rng.normal(0, 1, 48)
	burnt = rng.random(48) < 0.12
	pale = rng.random(48) < 0.1
	fine = smooth_noise(rng, size, 1.4)
	mid = smooth_noise(rng, size, 9)
	big = smooth_noise(rng, size, 120)
	base = np.array([0.56, 0.27, 0.16])
	rgb = base[None, None] * (1 + 0.07 * tone[bid] + 0.05 * mid + 0.06 * fine)[..., None]
	rgb = np.where(burnt[bid][..., None], rgb * np.array([0.62, 0.55, 0.55]), rgb)
	rgb = np.where(pale[bid][..., None], rgb * 0.6 + np.array([0.68, 0.48, 0.34]) * 0.4, rgb)
	chips = smoothstep(1.6, 2.4, fine + 0.6 * mid) * smoothstep(0.02, 0.006, edge)
	brick_face = smoothstep(JOINT * 0.5 - 0.0015, JOINT * 0.5 + 0.0015, edge) * (1 - chips * 0.8)
	mortar = np.array([0.5, 0.48, 0.45]) * (0.85 + 0.15 * np.tanh(mid + fine))[..., None]
	rgb = rgb * brick_face[..., None] + mortar * (1 - brick_face)[..., None]
	salt = smoothstep(1.2, 2.4, big + 0.5 * mid) * 0.35
	rgb = rgb * (1 - salt[..., None]) + np.array([0.72, 0.7, 0.66]) * salt[..., None]
	height = brick_face * (1.0 + 0.04 * tone[bid] + 0.08 * fine) - 0.3 * chips + (1 - brick_face) * 0.1 * fine
	ao = np.clip(0.55 + 0.45 * brick_face, 0, 1)
	rough = np.clip(0.88 + 0.06 * (1 - brick_face), 0, 1)
	save("brick_color.png", rgb)
	save("brick_normal.png", wrap_normal(height * 5.0, 1.0))
	save("brick_orm.png", np.dstack([ao, rough, np.zeros_like(ao)]))


# ---------------------------------------------------------------------------------------------- panel (K2)

def panel():
	"""White composite sandwich panel (1 m tile): shallow ribs every 0.25 m, a seam at the tile edge, dirt runs."""
	size = 1024
	rng = np.random.default_rng(262_03)
	v, u = np.mgrid[0:size, 0:size].astype(np.float64) / size
	rib = np.abs(((u * 4.0) % 1.0) - 0.5)
	ribh = smoothstep(0.47, 0.5, rib) * 0.6
	seam = smoothstep(0.004, 0.0, np.minimum(u, 1 - u))
	runs = smooth_noise(rng, (size, size), 3, aspect=25.0)  # long down the panel
	big = smooth_noise(rng, size, 90)
	rgb = np.zeros((size, size, 3)) + np.array([0.78, 0.79, 0.77])
	dirt = np.clip(smoothstep(0.6, 2.2, runs + 0.5 * big) * 0.5 + 0.15 * smoothstep(0.5, 2.0, big), 0, 1)
	rgb = rgb * (1 - dirt[..., None] * 0.45) + np.array([0.42, 0.4, 0.34]) * dirt[..., None] * 0.45
	rgb *= (1 - 0.35 * seam)[..., None]
	height = -ribh - 2.0 * seam + 0.02 * smooth_noise(rng, size, 2)
	save("panel_color.png", rgb)
	save("panel_normal.png", wrap_normal(height * 3.0, 1.0))


# ---------------------------------------------------------------------------------------------- signs (SA, SB)

SIGN_PX = (2048, 256)      # 16 m x 1.4 m


def _letters(draw_size):
	"""Glyph boxes of SIGN_TEXT laid out on the board (px), then SIGN_GHOST boxes for the lost name."""
	w, h = draw_size
	font = ImageFont.truetype(str(FONT), int(h * EM))
	x = 0
	boxes = []
	for ch in SIGN_TEXT:
		if ch == " ":
			x += int(h * 0.22)
			continue
		bb = font.getbbox(ch, anchor="ls")
		boxes.append((ch, x, bb))
		x += (bb[2] - bb[0]) + int(h * 0.06)
	ghosts = []
	gx = x + int(h * 0.3)
	rng = np.random.default_rng(262_04)
	for i in range(SIGN_GHOST):
		gw = int(h * rng.uniform(0.26, 0.36))
		ghosts.append((gx, gw))
		gx += gw + int(h * 0.06) + (int(h * 0.22) if i == 3 else 0)
	# The whole line (kept text and the lost name) centred on the board.
	shift = (w - (gx - int(h * 0.06))) // 2
	return font, [(ch, bx + shift, bb) for ch, bx, bb in boxes], [(g + shift, gw) for g, gw in ghosts]


def _board(text):
	w, h = SIGN_PX
	ss = 2
	rng = np.random.default_rng(262_05)
	big = smooth_noise(rng, (h, w), 40)
	mid = smooth_noise(rng, (h, w), 8)
	streak = smooth_noise(rng, (h, w), 2, aspect=20.0)  # runs down the board
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	blue = np.array([0.10, 0.22, 0.42])
	faded = np.array([0.24, 0.33, 0.45])
	fade = smoothstep(-1.0, 1.8, big + 0.3 * mid)
	rgb = blue[None, None] * (1 - fade[..., None]) + faded[None, None] * fade[..., None]
	# White border 50 mm, inset 40 mm.
	b0, b1 = 0.04 / 1.4 * h, 0.09 / 1.4 * h
	bx0, bx1 = 0.04 / 16 * w, 0.09 / 16 * w
	dist = np.minimum.reduce([v, h - 1 - v, u * (h / 1.4) / (w / 16), (w - 1 - u) * (h / 1.4) / (w / 16)])
	border = ((dist > b0) & (dist < b1)).astype(np.float64)
	img = Image.new("L", (w * ss, h * ss), 0)
	ghost = Image.new("L", (w * ss, h * ss), 0)
	d, dg = ImageDraw.Draw(img), ImageDraw.Draw(ghost)
	font, boxes, ghosts = _letters((w * ss, h * ss))
	base = int(h * ss * BASELINE)
	for ch, x, bb in boxes:
		if text:
			d.text((x, base), ch, font=font, fill=255, anchor="ls")
		else:
			# No text: every letter has gone, leaving glue marks that cannot be read as words.
			dg.rounded_rectangle((x + bb[0], base - int(h * ss * 0.37), x + bb[2], base + int(h * ss * 0.01)), radius=int(h * ss * 0.05), fill=255)
	for gx, gw in ghosts:
		dg.rounded_rectangle((gx, base - int(h * ss * 0.37), gx + gw, base + int(h * ss * 0.01)), radius=int(h * ss * 0.05), fill=255)
	letters = np.asarray(img.resize((w, h), Image.LANCZOS), np.float64) / 255.0
	marks = np.asarray(ghost.resize((w, h), Image.LANCZOS), np.float64) / 255.0
	marks = np.clip(blur(marks, 1.2) * (0.5 + 0.5 * smoothstep(-0.8, 0.8, mid)), 0, 1)
	white = np.array([0.82, 0.82, 0.78])
	# The vinyl letters are scuffed but every stroke and accent stays readable (a lost accent would change the word):
	# no paint flake and only a light rust run crosses a letter.
	guard = np.clip(blur(letters, 4.0) * 4.0, 0, 1)
	peel = smoothstep(1.4, 2.4, mid + 0.5 * big) * 0.4
	letters *= 1 - peel
	rgb = rgb * (1 - border[..., None]) + white * border[..., None]
	rgb = rgb * (1 - 0.35 * marks[..., None]) + np.array([0.5, 0.52, 0.5]) * 0.35 * marks[..., None]
	rgb = rgb * (1 - letters[..., None]) + white * letters[..., None]
	# Bare galvanised sheet where the paint flaked, rust runs from the eight bolts along the top, grime at the bottom.
	flake = smoothstep(2.3, 2.7, mid + 0.4 * big) * 0.8 * (1 - guard)
	rgb = rgb * (1 - flake[..., None]) + np.array([0.5, 0.5, 0.48]) * flake[..., None]
	rust = np.zeros((h, w))
	for i in range(8):
		bx = (i + 0.5) / 8 * w
		rust += np.exp(-((u - bx) / 6.0) ** 2) * smoothstep(0.0, 0.3, v / h) * np.exp(-v / (h * 0.7)) * smoothstep(-0.5, 1.0, streak)
	rust = np.clip(rust, 0, 1) * (1 - 0.6 * guard)
	rgb = rgb * (1 - 0.7 * rust[..., None]) + np.array([0.36, 0.18, 0.08]) * 0.7 * rust[..., None]
	grime = smoothstep(0.55, 1.0, v / h) * (0.4 + 0.3 * smoothstep(-1, 1, streak))
	rgb *= (1 - 0.45 * grime)[..., None]
	return rgb


def signs():
	save("sign_text.png", _board(True))
	save("sign_blank.png", _board(False))
	# The same layout in board metres for the Blender letters (SB): origin left on the baseline, em size.
	import json
	w, h = SIGN_PX
	ss = 4
	font, boxes, ghosts = _letters((w * ss, h * ss))
	k = 16.0 / (w * ss)
	layout = {"board": [16.0, 1.4], "baseline_from_top": BASELINE * 1.4, "em": EM * 1.4,
		"letters": [[ch, round(x * k, 4), round((bb[2] - bb[0]) * k, 4)] for ch, x, bb in boxes],
		"ghosts": [[round(gx * k, 4), round(gw * k, 4)] for gx, gw in ghosts]}
	(HERE / "sign_layout.json").write_text(json.dumps(layout, ensure_ascii=False, indent=1), encoding="utf-8", newline="\n")


def _board_mask(text):
	"""The plastered band's mask (kind 0): the 3D letters stand on it; their ghosts where they fell."""
	w, h = SIGN_PX
	ss = 2
	rng = np.random.default_rng(262_06)
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	big = smooth_noise(rng, (h, w), 40)
	mid = smooth_noise(rng, (h, w), 8)
	streak = smooth_noise(rng, (h, w), 2, aspect=20.0)  # runs down the board
	ghost = Image.new("L", (w * ss, h * ss), 0)
	dg = ImageDraw.Draw(ghost)
	font, boxes, ghosts = _letters((w * ss, h * ss))
	base = int(h * ss * BASELINE)
	if not text:
		for ch, x, bb in boxes:
			dg.rounded_rectangle((x + bb[0], base - int(h * ss * 0.37), x + bb[2], base + int(h * ss * 0.01)), radius=int(h * ss * 0.05), fill=255)
	for gx, gw in ghosts:
		dg.rounded_rectangle((gx, base - int(h * ss * 0.37), gx + gw, base + int(h * ss * 0.01)), radius=int(h * ss * 0.05), fill=255)
	marks = np.asarray(ghost.resize((w, h), Image.LANCZOS), np.float64) / 255.0
	marks = blur(marks, 1.5)
	# Each letter (standing or lost) hung on two bolts: rust runs down from them.
	cols = [x + (bb[2] - bb[0]) / 2 for ch, x, bb in boxes] + [gx + gw / 2 for gx, gw in ghosts]
	rust = np.zeros((h, w))
	for c in cols:
		c /= ss
		rust += np.exp(-((u - c) / 4.0) ** 2) * smoothstep(0.25, 0.35, v / h) * np.exp(-(v / h - 0.3) / 0.45) * smoothstep(-0.6, 1.0, streak)
	rust = np.clip(rust, 0, 1)
	grime = np.clip(0.5 * marks + 0.3 * smoothstep(0.6, 1.0, v / h) + 0.25 * smoothstep(0.5, 2.0, big), 0, 1)
	paint = smoothstep(0.9, 2.1, mid + 0.6 * big) * 0.7
	mould = np.clip(smoothstep(0.75, 1.0, v / h) * smoothstep(-0.5, 1.5, big) * 0.6, 0, 1)
	save("mask_board_%s.png" % ("text" if text else "blank"), np.dstack([paint, grime, rust, mould]), "RGBA")


def board_masks():
	_board_mask(True)
	_board_mask(False)


# ---------------------------------------------------------------------------------------------- barrier, crack

def barrier_stripes():
	"""Red and white chevrons (2 x 0.5 m on 512 x 128), worn at the edges, scuffed, a bit of mud."""
	w, h = 512, 128
	rng = np.random.default_rng(262_07)
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	xm = u / w * 2.0
	ym = v / h * 0.5
	band = np.floor((np.abs(xm - 1.0) + ym) / 0.2).astype(int) % 2
	red = np.array([0.62, 0.08, 0.06])
	white = np.array([0.8, 0.8, 0.77])
	rgb = np.where(band[..., None] == 0, red, white)
	mid = smooth_noise(rng, (h, w), 6)
	fine = smooth_noise(rng, (h, w), 1.2)
	scuff = smoothstep(1.4, 2.2, mid + 0.6 * fine) * 0.8
	rgb = rgb * (1 - scuff[..., None]) + np.array([0.45, 0.45, 0.43]) * scuff[..., None]
	edge = np.minimum.reduce([v, h - 1 - v, u, w - 1 - u]) / h
	mud = smoothstep(0.65, 1.0, v / h) * (0.5 + 0.5 * smoothstep(-1, 1, mid))
	rgb = rgb * (1 - 0.5 * mud[..., None]) + np.array([0.3, 0.25, 0.18]) * 0.5 * mud[..., None]
	rgb *= (0.92 + 0.08 * smoothstep(0, 0.1, edge))[..., None]
	save("barrier_stripes.png", rgb)


def ground_crack():
	"""A branching crack in the court (alpha cut-out): 0.5 x 8 m on 128 x 2048, the dark gap and a pale broken rim."""
	w, h = 128, 2048
	rng = np.random.default_rng(262_08)
	img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
	d = ImageDraw.Draw(img)

	def walk(x, y, steps, width, depth):
		pts = [(x, y)]
		for _ in range(steps):
			x += rng.normal(0, 3.2)
			x = min(max(x, 10), w - 10)
			y += rng.uniform(6, 13)
			pts.append((x, y))
			if depth < 2 and rng.random() < 0.07:
				walk(x, y, int(steps * 0.2), max(1, width - 1), depth + 1)
			if y > h - 10:
				break
		d.line(pts, fill=(96, 94, 90, 255), width=width + 3)
		d.line(pts, fill=(14, 13, 12, 255), width=width)
	walk(w * 0.5, 4, 220, 4, 0)
	save("ground_crack.png", np.asarray(img).astype(np.float64) / 255.0, "RGBA")


# ---------------------------------------------------------------------------------------------- masks

def mask_court():
	"""UV2 over x 180..262, z -72..13 (1024 x 1062): pavers or asphalt (kind 1). Two wheel tracks from the gate north to
	the Avenue (x 215, 225) and along it, polished and dark; grime against the wall, the pillars, the booth and the
	kerbs; puddles in the low corners and along the wall; oil under the parked cars; trodden lanes of the walk."""
	X, Z = COURT_MASK["x"], COURT_MASK["z"]
	w, h = 1024, int(round(1024 * (Z[1] - Z[0]) / (X[1] - X[0])))
	rng = np.random.default_rng(262_09)
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	x = X[0] + u / (w - 1) * (X[1] - X[0])
	z = Z[0] + v / (h - 1) * (Z[1] - Z[0])
	big = smooth_noise(rng, (h, w), 30)
	mid = smooth_noise(rng, (h, w), 7)
	tracks = np.zeros_like(x)
	for tx in (215.0, 225.0):
		tracks = np.maximum(tracks, np.exp(-((x - tx) / 0.5) ** 2) * (z > -58.5) * (z < -15.0))
	for tz in (-16.5, -13.5):
		tracks = np.maximum(tracks, np.exp(-((z - tz) / 0.5) ** 2) * (x < 222.0))
	wall = np.abs(z - (-60.0))
	near = np.minimum.reduce([wall, np.hypot(x - 209.0, z + 59.0) - 0.8, np.hypot(x - 231.0, z + 59.0) - 0.8,
		np.maximum(np.abs(x - 240.0) - 2.5, np.abs(z + 54.0) - 2.0)])
	near = np.maximum(near, 0.0)
	court_edge = np.minimum(np.abs(x - 190.0), np.abs(x - 250.0))
	grout = np.clip(0.5 + 0.3 * smoothstep(-1, 1.5, mid) + 0.3 * np.exp(-near / 1.2), 0, 1)
	grime = np.clip(0.45 * np.exp(-near / 1.0) + 0.25 * tracks + 0.3 * smoothstep(1.2, 2.2, big + 0.4 * mid)
		+ 0.2 * np.exp(-court_edge / 0.8), 0, 1)
	oil = np.zeros_like(x)
	for cx, cz, yaw, _ in L.CARS:
		oil = np.maximum(oil, np.exp(-(((x - cx) / 1.1) ** 2 + ((z - cz) / 1.1) ** 2)) * smoothstep(-0.5, 1.2, mid))
	grime = np.clip(grime + 0.5 * oil, 0, 1)
	wet = np.clip(np.exp(-wall / 0.6) * smoothstep(-0.3, 1.3, big + 0.5 * mid) * 0.9
		+ smoothstep(1.8, 2.5, big) * 0.8 + 0.4 * oil, 0, 1)
	walk = np.exp(-((x - 220.0) / 2.0) ** 2) * (z > -42) * 0.5 + np.exp(-((z + 24.5) / 1.6) ** 2) * (x < 222) * (x > 194) * 0.4
	wear = np.clip(tracks * 0.7 + walk * smoothstep(-1, 1, mid), 0, 1)
	save("mask_court.png", np.dstack([grout, grime, wet, wear]), "RGBA")


GATE_MASK = 1024


def mask_gate():
	"""Kind 0 atlas: v 0..0.25 wall panels (4 x 3 m variants across u, 3 m up), v 0.25..0.75 the pillars (u 0..0.5
	Pillar209, 0.5..1 Pillar231: four 1.4 m faces round, 6.4 m up from 0.4 m under the court), v 0.75..1 the booth (its
	18 m round, 3 m up). Image v grows downwards from the top of each band's top; within a band v = 0 is the ground."""
	n = GATE_MASK
	rng = np.random.default_rng(262_10)
	vv, uu = np.mgrid[0:n, 0:n].astype(np.float64) / (n - 1)
	big = smooth_noise(rng, n, 40)
	mid = smooth_noise(rng, n, 10)
	streak = smooth_noise(rng, (n, n), 2.5, aspect=25.0)  # rain runs, long down the wall
	paint = np.zeros((n, n))
	grime = np.zeros((n, n))
	stain = np.zeros((n, n))
	mould = np.zeros((n, n))
	# Wall panels: height m = (0.25 - vv) / 0.25 * 3 within band 0..0.25 (ground at the band's bottom).
	band = vv < 0.25
	hm = (0.25 - vv) / 0.25 * 3.0
	paint = np.where(band, smoothstep(0.7, 2.0, mid + 0.7 * big) * 0.8, paint)
	grime = np.where(band, np.clip(np.exp(-hm / 0.35) * 0.9 + 0.2 * smoothstep(0.5, 2, big), 0, 1), grime)
	stain = np.where(band, smoothstep(0.3, 1.7, streak + 0.4 * mid) * smoothstep(0.6, 2.6, hm) * 0.8, stain)
	mould = np.where(band, np.clip(np.exp(-hm / 0.3) * 0.8 * smoothstep(-0.5, 1.2, big + mid), 0, 1), mould)
	# Pillars: 6.4 m over the band v 0.25..0.75.
	band = (vv >= 0.25) & (vv < 0.75)
	hm = (0.75 - vv) / 0.5 * 6.4 - 0.4
	paint = np.where(band, smoothstep(0.9, 2.1, mid + big) * 0.7 + np.exp(-((uu % 0.5 - 0.06) / 0.02) ** 2) * smoothstep(3.0, 5.0, hm) * 0.6, paint)
	grime = np.where(band, np.clip(np.exp(-np.maximum(hm, 0) / 0.6) * 0.8 + 0.2 * smoothstep(0.5, 2, big), 0, 1), grime)
	stain = np.where(band, smoothstep(0.4, 1.8, streak + 0.4 * mid) * smoothstep(1.0, 5.8, hm) * 0.85, stain)
	mould = np.where(band, np.clip(np.exp(-np.maximum(hm, 0) / 0.35) * 0.8, 0, 1), mould)
	# Booth: 3 m over v 0.75..1.
	band = vv >= 0.75
	hm = (1.0 - vv) / 0.25 * 3.0
	paint = np.where(band, smoothstep(1.0, 2.2, mid + 0.8 * big) * 0.6, paint)
	grime = np.where(band, np.clip(np.exp(-hm / 0.3) * 0.8 + 0.25 * smoothstep(0.6, 2, big + mid), 0, 1), grime)
	stain = np.where(band, smoothstep(0.3, 1.6, streak + 0.4 * mid) * smoothstep(1.2, 2.9, hm) * 0.9, stain)
	mould = np.where(band, np.clip(np.exp(-hm / 0.25) * 0.7, 0, 1), mould)
	save("mask_gate.png", np.dstack([paint, grime, stain, mould]), "RGBA")


ALL = {"asphalt": asphalt, "brick": brick, "panel": panel, "signs": signs, "board_masks": board_masks,
	"barrier_stripes": barrier_stripes, "ground_crack": ground_crack, "mask_court": mask_court, "mask_gate": mask_gate}


if __name__ == "__main__":
	names = sys.argv[1:] or list(ALL)
	for key in names:
		ALL[key]()
