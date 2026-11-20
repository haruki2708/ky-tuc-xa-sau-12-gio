"""T-266 wave 9, round 1: the pilot's textures, drawn by script (no AI image, no download). Fonts: Be Vietnam Pro (OFL, already
in the game). Wood: Poly Haven's Wood Table Worn (CC0, already in the game: room407_corner/study_desk_wood_table_worn_*).

  slat_<bed>_<style>.png   2048 x 1024, the underside of a slat panel (u along the bed, 1.45 m; v across, 0.72 m; text up =
                           away from the hinge): raw pine underside + the scrap's words in one of four hands:
                             loang  marker ink that bled into the grain, smeared (the design's "chữ loang lổ")
                             bi     blue ballpoint gone over several times, pressed in
                             khac   scratched in with a sharp point (pale raw wood, a dark lip)
                             phieu  a torn strip of the photocopied form glued on, the values in ballpoint (the UI's scrap)
                           bed 2 in all four; beds 1 and 4 in the recommended hand only
  door_cracks.png          1024 x 2048 RGBA over the room door's room face (0.89 x 2.1 m): splits from where the arm comes
                           through, raw splinters, dents and scuffs; alpha 0 elsewhere
  zombie_skin.png          512 x 512, the hand through the door: pale, mottled, bruised, dried blood under the nails
  nurse_shadow.png         1024 x 1024 RGBA, Y1: two soft standing silhouettes for the bed curtain (no light added)
  blanket_check.png        512 x 512, the ward's thin blanket: pale blue check, washed out
  screen_mesh.png          256 x 256 RGBA, the vent's insect mesh (dusty)
Run: python -B art_source/graphics_upgrade/realistic_map/wave9/make_wave9_textures.py
"""
import math
from pathlib import Path
import random
import sys

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
GAME = ROOT / "game"
OUT = GAME / "assets/textures/graphics_pilot/realistic_map/wave9"
FONT_REG = GAME / "assets/fonts/be_vietnam_pro_regular.ttf"
FONT_BOLD = GAME / "assets/fonts/be_vietnam_pro_semibold.ttf"
WOOD = GAME / "assets/models/graphics_pilot/room407_corner/study_desk_wood_table_worn_color.jpg"

# The three scraps as lane D's form shows them (strings.csv UI_CH4_FORM_SCRAP_<n>, ch4_form.gd columns, director FORM_FIELDS).
SCRAPS = {
	1: {"head": "Phiếu điều tra…", "lines": ["Giới tính: Nam", "Tuổi: 20"]},
	2: {"head": "…người sống sót…", "lines": ["Ngày sinh: 11/03/2006", "Phòng: 407"]},
	4: {"head": "…sau thảm họa động đất", "lines": ["Tòa: B", "Họ và tên: ……………"]},
}
STYLES = ("loang", "bi", "khac", "phieu")
RECOMMENDED = "loang"
W, H = 2048, 1024      # 1.45 m x 0.72 m: 1412 px per metre
PILOT = "--pilot" in sys.argv   # round 1's other hands for bed 2 (bi, khac, phieu); round 2 ships loang only (D-187)


def rng(seed):
	return random.Random(seed)


def save(img, name):
	OUT.mkdir(parents=True, exist_ok=True)
	img.save(OUT / name, optimize=True)
	print("T266_TEXTURE", name, img.size, img.mode)


def noise(shape, scale, seed, octaves=4):
	"""Smooth value noise 0..1."""
	r = np.random.default_rng(seed)
	h, w = shape
	out = np.zeros(shape, np.float32)
	amp, total = 1.0, 0.0
	for o in range(octaves):
		cells = max(2, int(scale * (2 ** o)))
		grid = r.random((cells + 1, int(cells * w / h) + 2)).astype(np.float32)
		img = Image.fromarray((grid * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)
		out += np.asarray(img, np.float32) / 255.0 * amp
		total += amp
		amp *= 0.5
	return out / total


# ------------------------------------------------------------------------------------------------ wood

def raw_wood(seed):
	"""Unfinished pine underside: the worn table scan's grain (along u), bleached and yellowed, streaks and knots by script."""
	src = Image.open(WOOD).convert("L")
	tile = src.resize((768, 768), Image.BICUBIC)
	img = Image.new("L", (W, H))
	for x in range(0, W, 768):
		for y in range(0, H, 768):
			img.paste(tile, (x, y))
	lum = np.asarray(img, np.float32) / 255.0
	lum = (lum - lum.mean()) / max(lum.std(), 1e-3)
	r = np.random.default_rng(seed)
	streak = np.asarray(Image.fromarray((r.random((48, 6)) * 255).astype(np.uint8)).resize((W, H), Image.BICUBIC), np.float32) / 255.0
	fine = np.asarray(Image.fromarray((r.random((260, 12)) * 255).astype(np.uint8)).resize((W, H), Image.BICUBIC), np.float32) / 255.0
	grain = 0.5 + 0.12 * lum + 0.22 * (streak - 0.5) + 0.16 * (fine - 0.5)
	base = np.array([0.66, 0.53, 0.36], np.float32)
	out = base * (0.7 + 0.6 * grain)[..., None]
	stain = noise((H, W), 3, seed)[..., None]
	out *= 0.88 + 0.16 * stain
	yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
	for _ in range(2):  # knots
		kx, ky = r.uniform(0.1, 0.9) * W, r.uniform(0.2, 0.8) * H
		d = np.sqrt(((xx - kx) / 2.2) ** 2 + (yy - ky) ** 2)
		k = np.clip(1 - d / r.uniform(18, 30), 0, 1) ** 1.5
		out = out * (1 - 0.6 * k[..., None]) + np.array([0.3, 0.2, 0.1]) * 0.6 * k[..., None]
	edge = np.minimum(np.minimum(xx, W - 1 - xx) / 140.0, np.minimum(yy, H - 1 - yy) / 90.0)
	out *= (0.75 + 0.25 * np.clip(edge, 0, 1))[..., None]
	return np.clip(out, 0, 1)


# ------------------------------------------------------------------------------------------------ hand lettering

def glyph_mask(text, font_path, size, seed, wobble=0.07, slant=-4.0, spacing=0.02):
	"""Text as a handwritten-looking mask: each glyph turned, lifted and sized a little differently."""
	r = rng(seed)
	font = ImageFont.truetype(str(font_path), size)
	width = int(size * 0.75 * len(text) + size * 2)
	mask = Image.new("L", (width, int(size * 2.2)), 0)
	x = size * 0.3
	for ch in text:
		if ch == " ":
			x += size * 0.32
			continue
		s = int(size * r.uniform(0.92, 1.08))
		f = ImageFont.truetype(str(font_path), s)
		box = f.getbbox(ch)
		gw, gh = box[2] - box[0] + 8, int(s * 1.9)
		g = Image.new("L", (gw + 20, gh), 0)
		ImageDraw.Draw(g).text((10 - box[0], int(s * 0.35)), ch, font=f, fill=255)
		g = g.rotate(slant + r.uniform(-7, 7), resample=Image.BICUBIC, expand=False)
		dy = int(r.uniform(-wobble, wobble) * size)
		mask.paste(ImageChops.lighter(mask.crop((int(x), dy, int(x) + g.width, dy + g.height)), g), (int(x), dy))
		x += (box[2] - box[0]) + size * (spacing + r.uniform(-0.03, 0.04))
	bbox = mask.getbbox() or (0, 0, 1, 1)
	return mask.crop(bbox)


def lay_out(bed, font, sizes, seed):
	"""The scrap's head and lines placed on the panel (L mask, W x H)."""
	r = rng(seed)
	panel = Image.new("L", (W, H), 0)
	data = SCRAPS[bed]
	rows = [(data["head"], sizes[0])] + [(t, sizes[1]) for t in data["lines"]]
	y = int(H * 0.12)
	for i, (text, size) in enumerate(rows):
		m = glyph_mask(text, font, size, seed * 31 + i)
		limit = int(W * (0.84 if i == 0 else 0.76))
		if m.width > limit:  # the longest head (bed 4) is scaled to fit the panel
			m = m.resize((limit, int(m.height * limit / m.width)), Image.LANCZOS)
		m = m.rotate(r.uniform(-2.5, 2.5), resample=Image.BICUBIC, expand=True)
		x = int(W * (0.1 if i == 0 else 0.17) + r.uniform(-40, 40))
		panel.paste(ImageChops.lighter(panel.crop((x, y, x + m.width, y + m.height)), m), (x, y))
		y += m.height + int(size * 0.35)
	return panel


def to_np(mask):
	return np.asarray(mask, np.float32) / 255.0


def ink_loang(wood, bed, seed):
	"""Felt-marker ink, bled into the grain, smeared by a palm, two drips."""
	r = rng(seed)
	m = lay_out(bed, FONT_BOLD, (150, 118), seed)
	dry = np.clip(noise((H, W), 30, seed + 5, 2) * 2.2 - 0.55, 0.15, 1)
	core = to_np(m.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.GaussianBlur(2))) * dry
	bleed = to_np(m.filter(ImageFilter.MaxFilter(13)).filter(ImageFilter.GaussianBlur(14)))
	grain = np.asarray(Image.fromarray((wood.mean(axis=2) * 255).astype(np.uint8)), np.float32) / 255.0
	soak = np.clip(bleed * (0.55 + 0.9 * (0.6 - grain)), 0, 1)
	# smears: the ink dragged along the grain at a few places
	smear = Image.new("L", (W, H), 0)
	sd = ImageDraw.Draw(smear)
	for _ in range(5):
		x, y = r.uniform(0.1, 0.85) * W, r.uniform(0.15, 0.8) * H
		sd.ellipse((x, y, x + r.uniform(160, 380), y + r.uniform(30, 70)), fill=int(r.uniform(60, 120)))
	smear = to_np(smear.filter(ImageFilter.GaussianBlur(18))) * to_np(m.filter(ImageFilter.MaxFilter(31)).filter(ImageFilter.GaussianBlur(25)))
	drips = Image.new("L", (W, H), 0)
	dd = ImageDraw.Draw(drips)
	for _ in range(2):
		x = r.uniform(0.25, 0.75) * W
		y = r.uniform(0.3, 0.5) * H
		dd.line((x, y, x + r.uniform(-6, 6), y + r.uniform(90, 200)), fill=200, width=7)
	drips = to_np(drips.filter(ImageFilter.GaussianBlur(2)))
	ink = np.array([0.05, 0.045, 0.05], np.float32)
	a = np.clip(np.maximum.reduce([core * 0.95, soak * 0.7, smear * 0.7, drips * 0.8]), 0, 1)[..., None]
	return wood * (1 - a) + ink * a


def ink_bi(wood, bed, seed):
	"""Blue ballpoint, each stroke gone over three or four times, pressed into the soft wood."""
	r = rng(seed)
	m = lay_out(bed, FONT_REG, (128, 100), seed)
	thin = m.filter(ImageFilter.MinFilter(3))
	acc = np.zeros((H, W), np.float32)
	for i in range(4):
		dx, dy = r.randint(-3, 3), r.randint(-3, 3)
		layer = to_np(ImageChops.offset(thin, dx, dy).filter(ImageFilter.GaussianBlur(0.8)))
		acc = np.maximum(acc, layer * r.uniform(0.6, 0.9))
	groove = to_np(m.filter(ImageFilter.GaussianBlur(1.5)))
	ink = np.array([0.1, 0.14, 0.42], np.float32)
	out = wood * (1 - 0.25 * groove[..., None])
	a = np.clip(acc * 1.05, 0, 0.95)[..., None]
	return out * (1 - a) + ink * a


def ink_khac(wood, bed, seed):
	"""Scratched with a nail or a key: thin single cuts (the glyphs worn to their middle), gone over twice, pale fresh wood
	with a dark lip below."""
	r = rng(seed)
	m = lay_out(bed, FONT_REG, (140, 112), seed)
	thin = m.filter(ImageFilter.MinFilter(7))
	cuts = Image.new("L", (W, H), 0)
	for _ in range(2):
		cuts = ImageChops.lighter(cuts, ImageChops.offset(thin, r.randint(-2, 2), r.randint(-2, 2)))
	cut = to_np(cuts.filter(ImageFilter.GaussianBlur(0.6))) * np.clip(noise((H, W), 60, seed + 3, 2) * 1.6, 0.4, 1)
	lip = to_np(ImageChops.offset(cuts, 0, 3).filter(ImageFilter.GaussianBlur(1.0)))
	pale = np.array([0.88, 0.8, 0.62], np.float32)
	dark = np.array([0.16, 0.1, 0.06], np.float32)
	out = wood * (1 - 0.75 * lip[..., None]) + dark * 0.75 * lip[..., None]
	return out * (1 - cut[..., None]) + pale * cut[..., None]


def ink_phieu(wood, bed, seed):
	"""A torn strip of the photocopied form glued on (tape at the corners), the values filled in ballpoint, damp-stained."""
	r = rng(seed)
	out = wood.copy()
	pw, ph = int(W * 0.78), int(H * 0.7)
	px, py = int(W * 0.1), int(H * 0.14)
	paper = Image.new("L", (pw, ph), 0)
	pd = ImageDraw.Draw(paper)
	pts = []
	for i in range(24):  # torn outline
		t = i / 24.0
		if t < 0.25:
			pts.append((t * 4 * pw, r.uniform(0, 14)))
		elif t < 0.5:
			pts.append((pw - r.uniform(0, 28), (t - 0.25) * 4 * ph))
		elif t < 0.75:
			pts.append(((0.75 - t) * 4 * pw, ph - r.uniform(0, 14)))
		else:
			pts.append((r.uniform(0, 28), (1 - t) * 4 * ph))
	pd.polygon(pts, fill=255)
	pmask = np.zeros((H, W), np.float32)
	pmask[py:py + ph, px:px + pw] = to_np(paper)
	toner = noise((H, W), 40, seed, 2) * 0.12
	paper_rgb = np.array([0.8, 0.79, 0.74], np.float32) - toner[..., None]
	stain = np.clip(noise((H, W), 4, seed + 1) * 1.6 - 0.7, 0, 1)[..., None]
	paper_rgb = paper_rgb * (1 - 0.3 * stain) + np.array([0.55, 0.45, 0.28]) * 0.3 * stain
	out = out * (1 - pmask[..., None]) + paper_rgb * pmask[..., None]
	# printed labels (photocopy grey-black) and the values in ballpoint
	text = Image.new("L", (W, H), 0)
	blue = Image.new("L", (W, H), 0)
	td, bd = ImageDraw.Draw(text), ImageDraw.Draw(blue)
	head = ImageFont.truetype(str(FONT_BOLD), 92)
	field = ImageFont.truetype(str(FONT_REG), 78)
	data = SCRAPS[bed]
	td.text((px + 70, py + 50), data["head"].upper(), font=head, fill=235)
	y = py + 220
	for line in data["lines"]:
		label, _, value = line.partition(":")
		td.text((px + 90, y), label + ":", font=field, fill=225)
		lw = td.textlength(label + ":", font=field)
		td.line((px + 110 + lw, y + 88, px + pw - 120, y + 88), fill=150, width=3)
		v = glyph_mask(value.strip(), FONT_REG, 84, seed + y)
		blue.paste(ImageChops.lighter(blue.crop((int(px + 140 + lw), y - 6, int(px + 140 + lw) + v.width, y - 6 + v.height)), v),
			(int(px + 140 + lw), y - 6))
		y += 150
	ta = to_np(text.filter(ImageFilter.GaussianBlur(0.9))) * (0.75 + 0.25 * noise((H, W), 60, seed + 2, 2))
	ba = to_np(blue.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.GaussianBlur(0.8)))
	out = out * (1 - ta[..., None] * 0.85) + np.array([0.08, 0.08, 0.08]) * ta[..., None] * 0.85
	out = out * (1 - ba[..., None] * 0.9) + np.array([0.1, 0.14, 0.42]) * ba[..., None] * 0.9
	# yellowed tape on two corners
	tape = Image.new("L", (W, H), 0)
	tdraw = ImageDraw.Draw(tape)
	for cx, cy in ((px + 10, py + 10), (px + pw - 30, py + ph - 20)):
		tdraw.polygon([(cx - 90, cy - 20), (cx + 70, cy - 60), (cx + 100, cy + 10), (cx - 60, cy + 50)], fill=150)
	tp = to_np(tape.filter(ImageFilter.GaussianBlur(2)))[..., None]
	out = out * (1 - tp * 0.5) + np.array([0.75, 0.62, 0.32]) * tp * 0.5
	return out


INKS = {"loang": ink_loang, "bi": ink_bi, "khac": ink_khac, "phieu": ink_phieu}


def make_slats():
	for bed in (1, 2, 4):
		wood = raw_wood(100 + bed)
		for style in STYLES:
			if style != RECOMMENDED and (bed != 2 or not PILOT):
				continue
			out = INKS[style](wood, bed, 1000 * bed + STYLES.index(style))
			save(Image.fromarray((np.clip(out, 0, 1) * 255).astype(np.uint8)), "slat_%d_%s.png" % (bed, style))
	# plain underside (the slat's other faces, and beds whose text is not shown)
	save(Image.fromarray((raw_wood(99) * 255).astype(np.uint8)).resize((1024, 512), Image.BICUBIC), "slat_plain.png")


# ------------------------------------------------------------------------------------------------ door

DOOR_W, DOOR_H = 1024, 2048     # 0.89 x 2.1 m (u from the latch edge to the hinge edge, v top down)
HOLE = (0.42, 0.533)            # the arm's hole centre in the leaf, (u, v) fractions: 0.98 m up, 0.37 m from the latch


def crack_path(r, start, angle, length, step=10):
	pts = [start]
	x, y = start
	for _ in range(int(length / step)):
		angle += r.uniform(-0.35, 0.35)
		x += math.cos(angle) * step
		y += math.sin(angle) * step
		pts.append((x, y))
	return pts


def make_door_cracks():
	r = rng(7)
	cx, cy = HOLE[0] * DOOR_W, HOLE[1] * DOOR_H
	dark = Image.new("L", (DOOR_W, DOOR_H), 0)
	light = Image.new("L", (DOOR_W, DOOR_H), 0)
	dd, ld = ImageDraw.Draw(dark), ImageDraw.Draw(light)
	for i in range(11):
		a = i / 11 * math.tau + r.uniform(-0.2, 0.2)
		length = r.uniform(180, 520) * (1.5 if abs(math.sin(a)) > 0.8 else 1.0)   # along the grain (v) runs longer
		start = (cx + math.cos(a) * r.uniform(20, 60), cy + math.sin(a) * r.uniform(20, 60))
		pts = crack_path(r, start, a, length)
		for k in range(len(pts) - 1):
			w = max(2, int(13 * (1 - k / len(pts))))
			dd.line((pts[k], pts[k + 1]), fill=255, width=w)
			ld.line(((pts[k][0] + 4, pts[k][1] + 3), (pts[k + 1][0] + 4, pts[k + 1][1] + 3)), fill=230, width=max(2, w))
		if r.random() < 0.6:  # a branch
			j = len(pts) // 2
			b = crack_path(r, pts[j], a + r.choice((-0.8, 0.8)), length * 0.4)
			dd.line(b, fill=230, width=4)
	# dents and scuffs where the bodies hit (corridor side mostly; a few show through as raised splinters)
	for _ in range(30):
		x, y = r.gauss(cx, 130), r.gauss(cy, 220)
		s = r.uniform(6, 22)
		ld.ellipse((x - s, y - s * 0.4, x + s, y + s * 0.4), fill=int(r.uniform(150, 230)))
	core = to_np(dark.filter(ImageFilter.GaussianBlur(0.8)))
	pale = to_np(light.filter(ImageFilter.GaussianBlur(1.2)))
	rgb = np.zeros((DOOR_H, DOOR_W, 3), np.float32)
	rgb[:] = (0.62, 0.5, 0.32)                                          # raw wood in the splinters
	rgb = rgb * (1 - core[..., None]) + np.array([0.03, 0.025, 0.02]) * core[..., None]
	alpha = np.clip(np.maximum(core, pale * 0.85), 0, 1)
	out = np.dstack([rgb, alpha])
	save(Image.fromarray((out * 255).astype(np.uint8), "RGBA"), "door_cracks.png")


# ------------------------------------------------------------------------------------------------ the hand, the ward

def make_skin():
	n1 = noise((512, 512), 6, 21)
	n2 = noise((512, 512), 24, 22, 2)
	base = np.array([0.56, 0.5, 0.42], np.float32)
	grey = np.array([0.42, 0.44, 0.4], np.float32)
	mix = np.clip(n1 * 1.4 - 0.2, 0, 1)[..., None]
	out = base * (1 - mix) + grey * mix
	out *= (0.88 + 0.2 * n2)[..., None]
	bruise = np.clip(noise((512, 512), 3, 23) * 2.2 - 1.3, 0, 1)[..., None]
	out = out * (1 - 0.55 * bruise) + np.array([0.28, 0.2, 0.3]) * 0.55 * bruise
	blood = np.clip(noise((512, 512), 5, 24) * 2.6 - 1.8, 0, 1)[..., None]
	out = out * (1 - 0.8 * blood) + np.array([0.2, 0.03, 0.03]) * 0.8 * blood
	# the nails' band (v 0.9..1 of the hand's UV strip): dark, blood under them
	out[460:, :] = out[460:, :] * 0.5 + np.array([0.18, 0.06, 0.05]) * 0.5
	save(Image.fromarray((np.clip(out, 0, 1) * 255).astype(np.uint8)), "zombie_skin.png")


def silhouette(draw, cx, base, height, r, cap=False):
	"""A standing figure's outline: head, shoulders, coat, legs (pixels)."""
	head = height * 0.075
	draw.ellipse((cx - head, base - height, cx + head, base - height + head * 2.3), fill=255)
	if cap:
		draw.rectangle((cx - head * 1.1, base - height - head * 0.35, cx + head * 1.1, base - height + head * 0.5), fill=255)
	sh = height * 0.16
	draw.polygon([(cx - sh * 0.45, base - height * 0.83), (cx + sh * 0.45, base - height * 0.83), (cx + sh, base - height * 0.76),
		(cx + sh * 1.05, base - height * 0.4), (cx + sh * 0.95, base - height * 0.3), (cx - sh * 0.95, base - height * 0.3),
		(cx - sh * 1.05, base - height * 0.4), (cx - sh, base - height * 0.76)], fill=255)
	draw.rectangle((cx - sh * 0.55, base - height * 0.32, cx + sh * 0.55, base - height * 0.02), fill=255)
	# an arm bent, a clipboard
	draw.polygon([(cx + sh * 0.9, base - height * 0.72), (cx + sh * 1.4, base - height * 0.55), (cx + sh * 1.1, base - height * 0.5),
		(cx + sh * 0.75, base - height * 0.6)], fill=255)


def make_nurse_shadow():
	"""Round 2 (D-187 point 7): two ordinary people standing still behind the curtain, as a soft shadow layer on its pleats
	(no light added). The layer spans x 1.1..-1.1 (u) and y 2.4..0.38 (v, the curtain's hem) in HospitalRoom space; the
	figures stand at Nurse2 (x +0.72, screen left) and Nurse1 (x -0.72, screen right), about 1.6 m tall. Left: a nurse in
	profile facing the other, her hair in a bun, reading a chart on a clipboard held at her chest. Right: a nurse turned
	three-quarters toward her, one arm hanging, the other hand in a tunic pocket. Drawn at 2048 and blurred to ~1 cm, the
	edges of people 0.4 m behind a cloth."""
	size = 2048
	img = Image.new("L", (size, size), 0)
	d = ImageDraw.Draw(img)

	def px(xc, sx, y):
		return ((1.1 - xc + sx) / 2.2 * size, (2.4 - y) / 2.02 * size)

	def poly(xc, pts):
		d.polygon([px(xc, sx, y) for sx, y in pts], fill=255)

	def ell(xc, sx, y, rx, ry):
		a, b = px(xc, sx - rx, y + ry), px(xc, sx + rx, y - ry)
		d.ellipse((a[0], a[1], b[0], b[1]), fill=255)

	def limb(xc, pts, w0, w1):
		"""A tapered limb along screen points."""
		n = len(pts)
		left, right = [], []
		for i, (sx, y) in enumerate(pts):
			a = pts[max(i - 1, 0)]
			b = pts[min(i + 1, n - 1)]
			dx, dy = b[0] - a[0], b[1] - a[1]
			ln = math.hypot(dx, dy) or 1.0
			nx, ny = -dy / ln, dx / ln
			w = (w0 + (w1 - w0) * i / max(n - 1, 1)) / 2
			left.append((sx + nx * w, y + ny * w))
			right.append((sx - nx * w, y - ny * w))
		poly(xc, left + right[::-1])
		ell(xc, pts[0][0], pts[0][1], w0 / 2, w0 / 2)
		ell(xc, pts[-1][0], pts[-1][1], w1 / 2, w1 / 2)

	# Left: in profile, facing screen right; head a little bowed over the chart.
	a = 0.72
	ell(a, 0.0, 1.47, 0.083, 0.105)
	poly(a, [(0.06, 1.50), (0.1, 1.455), (0.075, 1.43)])				 # nose and brow
	ell(a, -0.095, 1.5, 0.045, 0.045)									 # bun
	poly(a, [(-0.03, 1.39), (0.045, 1.39), (0.04, 1.31), (-0.035, 1.31)])  # neck
	poly(a, [(-0.1, 1.34), (0.03, 1.35), (0.1, 1.27), (0.105, 1.15), (0.08, 1.0), (0.1, 0.88), (0.115, 0.78), (-0.125, 0.78),
		(-0.13, 0.9), (-0.085, 1.04), (-0.105, 1.18), (-0.12, 1.3)])		 # tunic in profile
	limb(a, [(-0.01, 1.3), (0.01, 1.07)], 0.08, 0.065)					# upper arm
	limb(a, [(0.01, 1.07), (0.13, 1.13), (0.2, 1.19)], 0.06, 0.05)		# forearm to the chart
	poly(a, [(0.16, 1.075), (0.205, 1.055), (0.335, 1.315), (0.29, 1.335)])  # clipboard, tilted toward her
	poly(a, [(0.28, 1.315), (0.31, 1.305), (0.322, 1.335), (0.292, 1.345)])  # its clip
	limb(a, [(0.04, 0.84), (0.06, 0.38)], 0.1, 0.085)					 # front leg
	limb(a, [(-0.07, 0.84), (-0.05, 0.38)], 0.1, 0.085)				   # back leg
	# Right: three-quarters toward the left figure, short hair, one arm hanging, the other hand in the tunic pocket.
	b = -0.72
	ell(b, -0.012, 1.55, 0.08, 0.106)
	poly(b, [(-0.078, 1.6), (0.07, 1.62), (0.086, 1.54), (-0.086, 1.53)])  # hair over the crown
	poly(b, [(-0.034, 1.47), (0.034, 1.47), (0.04, 1.39), (-0.04, 1.39)])  # neck
	poly(b, [(-0.19, 1.405), (0.19, 1.41), (0.205, 1.34), (0.17, 1.2), (0.152, 1.08), (0.168, 0.94), (0.178, 0.8), (-0.172, 0.8),
		(-0.165, 0.94), (-0.15, 1.08), (-0.168, 1.2), (-0.2, 1.34)])         # tunic: shoulders, waist, hips
	ell(b, -0.178, 1.365, 0.045, 0.045)
	ell(b, 0.178, 1.365, 0.045, 0.045)
	limb(b, [(-0.205, 1.35), (-0.245, 1.1), (-0.24, 0.87)], 0.068, 0.052)  # arm hanging, apart from the waist
	ell(b, -0.238, 0.84, 0.03, 0.042)                                     # hand
	limb(b, [(0.205, 1.35), (0.275, 1.12), (0.185, 0.98)], 0.068, 0.054)  # elbow out, hand in the pocket
	limb(b, [(-0.08, 0.84), (-0.085, 0.38)], 0.115, 0.09)                 # trousers
	limb(b, [(0.08, 0.84), (0.09, 0.38)], 0.115, 0.09)
	img = img.resize((1024, 1024), Image.LANCZOS)
	soft = to_np(img.filter(ImageFilter.GaussianBlur(5)))
	# a touch fainter toward the hem (the legs stand farther from the cloth than the shoulders lean)
	yy = np.linspace(0, 1, 1024, dtype=np.float32)[:, None]
	alpha = soft * (0.46 - 0.08 * yy)
	rgb = np.zeros((1024, 1024, 3), np.float32) + np.array([0.07, 0.09, 0.1])
	save(Image.fromarray((np.dstack([rgb, alpha]) * 255).astype(np.uint8), "RGBA"), "nurse_shadow.png")


def make_blanket():
	"""Round 2: the ward's thin blanket, 1024 px for 0.5 m: a washed pale blue with a fine double check and a loose weave."""
	n = 1024
	yy, xx = np.mgrid[0:n, 0:n]
	img = np.zeros((n, n, 3), np.float32) + np.array([0.62, 0.68, 0.73], np.float32)
	line = np.zeros((n, n), np.float32)
	for off in (0, 14):
		line = np.maximum(line, (((xx + off) % 256) < 5).astype(np.float32))
		line = np.maximum(line, (((yy + off) % 256) < 5).astype(np.float32))
	line = to_np(Image.fromarray((line * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.2)))
	img = img * (1 - 0.3 * line[..., None]) + np.array([0.32, 0.43, 0.57]) * 0.3 * line[..., None]
	weave = ((xx // 2 + yy // 2) % 2).astype(np.float32)
	img *= (0.95 + 0.04 * weave + 0.1 * (noise((n, n), 40, 31, 2) - 0.5))[..., None]
	img *= (0.93 + 0.1 * noise((n, n), 3, 32))[..., None]
	save(Image.fromarray((np.clip(img, 0, 1) * 255).astype(np.uint8)), "blanket_check.png")


def make_bandage():
	"""Round 2: crepe bandage for Trung's forearm (u round the arm, v along it, 0.12 m per tile): off-white, the turns
	overlapping on a slant, a faint stain."""
	n = 256
	yy, xx = np.mgrid[0:n, 0:n].astype(np.float32)
	base = np.zeros((n, n, 3), np.float32) + np.array([0.82, 0.8, 0.74], np.float32)
	turn = ((yy + xx * 0.35) % 64) / 64.0
	edge = np.clip(1 - np.abs(turn - 0.03) / 0.03, 0, 1)
	crepe = 0.5 + 0.5 * np.sin(yy * 1.9 + xx * 0.6)
	base *= (0.93 + 0.05 * crepe - 0.18 * edge)[..., None]
	stain = np.clip(noise((n, n), 3, 51) * 2.2 - 1.4, 0, 1)[..., None]
	base = base * (1 - 0.25 * stain) + np.array([0.7, 0.6, 0.45]) * 0.25 * stain
	save(Image.fromarray((np.clip(base, 0, 1) * 255).astype(np.uint8)), "bandage.png")


def make_screen():
	img = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
	d = ImageDraw.Draw(img)
	for i in range(0, 256, 8):
		d.line((i, 0, i, 255), fill=(60, 62, 58, 230), width=2)
		d.line((0, i, 255, i), fill=(60, 62, 58, 230), width=2)
	a = np.asarray(img, np.float32) / 255.0
	dust = np.clip(noise((256, 256), 6, 41) * 1.5 - 0.5, 0, 1)
	a[..., :3] = a[..., :3] * (1 - dust[..., None] * 0.6) + np.array([0.5, 0.47, 0.42]) * dust[..., None] * 0.6
	a[..., 3] = np.maximum(a[..., 3], dust * 0.5)
	save(Image.fromarray((a * 255).astype(np.uint8), "RGBA"), "screen_mesh.png")


def make_monitor():
	"""The bedside monitor's screen (seen from the corner only): dark, a green trace, a few readings."""
	img = Image.new("RGB", (512, 384), (6, 10, 9))
	d = ImageDraw.Draw(img)
	font = ImageFont.truetype(str(FONT_BOLD), 54)
	small = ImageFont.truetype(str(FONT_REG), 26)
	pts = []
	for x in range(0, 360, 2):
		t = (x % 90) / 90.0
		y = 120 - (70 if 0.42 < t < 0.46 else (-25 if 0.47 < t < 0.5 else 6 * math.sin(t * 9)))
		pts.append((10 + x, y))
	d.line(pts, fill=(60, 220, 110), width=3)
	d.line([(10 + x, 260 + 14 * math.sin(x / 18.0)) for x in range(0, 360, 2)], fill=(80, 170, 230), width=3)
	d.text((385, 70), "72", font=font, fill=(60, 220, 110))
	d.text((385, 220), "97", font=font, fill=(80, 170, 230))
	d.text((388, 40), "HR", font=small, fill=(60, 200, 100))
	d.text((388, 190), "SpO2", font=small, fill=(80, 160, 220))
	save(img, "monitor_screen.png")


def main():
	make_monitor()
	make_slats()
	make_door_cracks()
	make_skin()
	make_nurse_shadow()
	make_blanket()
	make_bandage()
	make_screen()


if __name__ == "__main__":
	main()
