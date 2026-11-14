"""T-259 wave 3 (D-166): the garden's textures, drawn here with numpy + Pillow. No downloaded image, no AI image.

  leaf_plumeria.png      hoa sứ / hoa đại (Plumeria obtusa): four single leaves (columns), a flower cluster, a bud tuft
  leaf_mantaly.png       bàng Đài Loan (Terminalia mantaly): leaf rosettes seen from above and the side
  leaf_lagerstroemia.png bằng lăng (Lagerstroemia speciosa): leafy twigs, a purple panicle, old red leaves
  shrubs.png             4 x 4 cells: chuỗi ngọc (Duranta), trang đỏ (Ixora) leaves and flower balls, cẩm tú mai
                         (Cuphea), dừa cạn (Catharanthus) pink and white, grass, a weed, fallen leaves
  hedge_color/normal     a trimmed golden Duranta hedge's leafy face (tiles every 0.5 m)
  bark_<tree>_color/normal  the three barks (tile every 0.4 m)
  soil_color/normal      bed soil with grit and dry leaves (tiles every 0.8 m)
  paving_block_*         gạch block "con sâu": grey wavy concrete pavers 225 x 112.5 mm in running bond (0.9 m tile)
  paving_red_*           gạch đỏ "lá dừa" 300 x 300 mm with chevron grooves, laid crosswise (1.2 m tile)
  mask_paving.png        the 44 x 40 m paving's ageing (UV2): R grout dirt, G grime, B wet, A wear
                         (room407_shell.gdshader kind 1), painted for the real bed layout and walking lines
  mask_kerb.png          the 12 bed kerbs (one row each, UV2): R paint loss, G grime, B water stain, A mould (kind 0)
  mask_bench.png         stone benches (UV2 from the side): kind 1 channels
Leaf atlases carry alpha for alpha-scissor cards; colour is pushed into the transparent pixels so mipmaps and
VRAM compression do not draw dark rims.
Round 2:
  ground_grass_*         trodden lawn of the B-to-garden strip (2 m tile); mask_strip.png its dirt/wet mask (UV2)
  litter.png             paper, flyer, crumpled paper, plastic bag (alpha cut-out)
  board_papers.png       the notice board's six sheets (lines only, no words, as the PS1 papers)
Run: python -B art_source/graphics_upgrade/realistic_map/wave3/make_wave3_textures.py [name ...]
(the pilot options not picked in D-175 are drawn only when named: mantaly, paving_red, bark_mantaly)
"""
from pathlib import Path
import math
import sys

import numpy as np
from PIL import Image, ImageFilter

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
OUT = ROOT / "game/assets/textures/graphics_pilot/realistic_map/wave3"
SS = 2  # supersampling of the drawn atlases


# ---------------------------------------------------------------------------------------------- helpers

def smooth_noise(rng, size, scale, aspect=1.0):
	"""Tileable noise of unit variance, low-passed at about `scale` pixels (aspect > 1 stretches it along y)."""
	h, w = (size if isinstance(size, tuple) else (size, size))
	white = rng.normal(0.0, 1.0, (h, w))
	fy = np.fft.fftfreq(h)[:, None] * aspect
	fx = np.fft.rfftfreq(w)[None, :]
	lowpass = np.exp(-((fy * scale) ** 2 + (fx * scale) ** 2) * 18.0)
	out = np.fft.irfft2(np.fft.rfft2(white) * lowpass, s=(h, w))
	return out / max(out.std(), 1e-9)


def smoothstep(a, b, x):
	den = np.asarray(b - a, dtype=np.float64)
	den = np.where(np.abs(den) < 1e-9, 1e-9, den)
	t = np.clip((x - a) / den, 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)


def normal_from_height(height, strength):
	gy, gx = np.gradient(height)
	n = np.stack([-gx * strength, gy * strength, np.ones_like(height)], axis=2)
	n /= np.linalg.norm(n, axis=2, keepdims=True)
	return n * 0.5 + 0.5


def wrap_gradient_normal(height, strength):
	"""normal_from_height for a tiling height field (wraps at the edges)."""
	gx = (np.roll(height, -1, 1) - np.roll(height, 1, 1)) * 0.5
	gy = (np.roll(height, -1, 0) - np.roll(height, 1, 0)) * 0.5
	n = np.stack([-gx * strength, gy * strength, np.ones_like(height)], axis=2)
	n /= np.linalg.norm(n, axis=2, keepdims=True)
	return n * 0.5 + 0.5


def save(name, arr, mode="RGB"):
	OUT.mkdir(parents=True, exist_ok=True)
	img = Image.fromarray((np.clip(arr, 0.0, 1.0) * 255.0 + 0.5).astype(np.uint8), mode)
	img.save(OUT / name, optimize=True)
	print("T259_TEX", name, img.size)


def push_pull(rgb, alpha):
	"""Fills transparent texels with the colour of the nearest leaves (pyramid push-pull)."""
	levels = []
	c, a = rgb * alpha[..., None], alpha.copy()
	while min(a.shape) > 4:
		levels.append((c, a))
		h, w = a.shape
		c = c.reshape(h // 2, 2, w // 2, 2, 3).sum(axis=(1, 3))
		a = a.reshape(h // 2, 2, w // 2, 2).sum(axis=(1, 3))
		c = c / np.maximum(a, 1e-6)[..., None] * np.minimum(a, 1.0)[..., None]
		a = np.minimum(a, 1.0)
	fill = c / np.maximum(a, 1e-6)[..., None]
	for c, a in reversed(levels):
		fill = np.repeat(np.repeat(fill, 2, axis=0), 2, axis=1)
		own = c / np.maximum(a, 1e-6)[..., None]
		fill = own * a[..., None] + fill * (1.0 - a[..., None])
	return fill


class Canvas:
	"""A supersampled RGBA canvas that leaves, petals and stems are composited onto (painter's order)."""

	def __init__(self, w, h, seed):
		self.w, self.h = w * SS, h * SS
		self.rgb = np.zeros((self.h, self.w, 3), np.float32)
		self.a = np.zeros((self.h, self.w), np.float32)
		self.rng = np.random.default_rng(seed)
		self.grain = smooth_noise(self.rng, (self.h, self.w), 10.0 * SS).astype(np.float32)
		self.fine = smooth_noise(self.rng, (self.h, self.w), 2.5 * SS).astype(np.float32)

	def over(self, y0, x0, rgb, a):
		h, w = a.shape
		dst_a = self.a[y0:y0 + h, x0:x0 + w]
		dst = self.rgb[y0:y0 + h, x0:x0 + w]
		dst[:] = rgb * a[..., None] + dst * (1.0 - a[..., None])
		dst_a[:] = a + dst_a * (1.0 - a)

	def _box(self, pts, pad):
		xs, ys = [p[0] for p in pts], [p[1] for p in pts]
		x0 = int(max(min(xs) - pad, 0))
		x1 = int(min(max(xs) + pad, self.w - 1))
		y0 = int(max(min(ys) - pad, 0))
		y1 = int(min(max(ys) + pad, self.h - 1))
		if x1 <= x0 or y1 <= y0:
			return None
		yy, xx = np.mgrid[y0:y1 + 1, x0:x1 + 1].astype(np.float32)
		return y0, x0, xx, yy

	def leaf(self, base, angle, length, width, color, shape=(0.9, 0.7), curve=0.0, veins=10, vein_slope=0.9,
			vein_light=0.07, midrib=(0.85, 0.9, 0.55), fold=0.1, yellow=0.0, spots=0.0, holes=0, petiole=0.0,
			gloss=0.0, tip_round=0.0):
		"""One leaf in canvas pixels (unscaled): base (x, y), angle in radians (0 = +x, image y down)."""
		s = SS
		bx, by = base[0] * s, base[1] * s
		L, W = length * s, width * s
		d = (math.cos(angle), math.sin(angle))
		n = (-d[1], d[0])
		tip = (bx + d[0] * L, by + d[1] * L)
		mid = (bx + d[0] * L * 0.5 + n[0] * curve * L * 0.25, by + d[1] * L * 0.5 + n[1] * curve * L * 0.25)
		back = (bx - d[0] * petiole * s, by - d[1] * petiole * s)
		box = self._box([back, tip, mid], W * 0.6 + abs(curve) * L * 0.3 + 4)
		if box is None:
			return
		y0, x0, xx, yy = box
		rx, ry = xx - bx, yy - by
		along = rx * d[0] + ry * d[1]
		t = along / L
		side = rx * n[0] + ry * n[1] - curve * L * (t ** 2)
		a_, b_ = shape
		peak = (a_ / (a_ + b_)) ** a_ * (b_ / (a_ + b_)) ** b_
		tc = np.clip(t, 1e-4, 1 - 1e-4)
		prof = (tc ** a_) * ((1 - tc) ** b_) / peak
		if tip_round > 0:
			prof = np.maximum(prof, np.sqrt(np.clip(1 - ((tc - (1 - tip_round)) / tip_round) ** 2, 0, 1)) * (tc > 1 - tip_round) * prof.max())
		hw = W * 0.5 * prof
		u = side / np.maximum(hw, 1e-3)
		inside = (t >= 0) & (t <= 1) & (np.abs(u) <= 1)
		edge_aa = np.clip((hw - np.abs(side)) / 1.2 + 0.5, 0, 1) * (t >= 0) * (t <= 1)
		alpha = edge_aa.astype(np.float32)
		g = self.grain[y0:y0 + alpha.shape[0], x0:x0 + alpha.shape[1]]
		f = self.fine[y0:y0 + alpha.shape[0], x0:x0 + alpha.shape[1]]
		col = np.empty(alpha.shape + (3,), np.float32)
		col[:] = color
		col *= (1.0 + 0.07 * g + 0.03 * f)[..., None]
		# Tip and base a little lighter, the blade darker towards its margin.
		col *= (1.0 + 0.05 * smoothstep(0.75, 1.0, t))[..., None]
		col *= (1.0 - 0.16 * smoothstep(0.7, 1.0, np.abs(u)))[..., None]
		if gloss > 0:
			col += gloss * np.exp(-((u + 0.35) ** 2) / 0.05)[..., None] * smoothstep(0.1, 0.5, t)[..., None]
		# Lateral veins run out and forward from the midrib.
		vv = t * veins - np.abs(u) * vein_slope
		vein = np.exp(-((vv - np.round(vv)) ** 2) / (2 * (0.06 + 0.04 * np.abs(u)) ** 2)) * (np.abs(u) < 0.92)
		col += (vein_light * vein * (1 - 0.6 * np.abs(u)))[..., None]
		# Midrib: a pale line a few percent of the blade's width, thinning to the tip.
		rib_w = max(W * 0.022, 1.2) * (1.0 - 0.7 * np.clip(t, 0, 1))
		rib = (1.0 - smoothstep(rib_w * 0.5, rib_w, np.abs(side))) * (t > 0) * (t < 0.97)
		pale = np.clip(np.array(color, np.float32) * 1.3 + np.array([0.08, 0.07, 0.02], np.float32), 0, 1)
		col = col * (1 - rib[..., None]) + pale * rib[..., None]
		col *= np.where(side > 0, 1.0 - fold, 1.0)[..., None]
		if yellow > 0:
			yel = np.array([0.72, 0.62, 0.18], np.float32)
			amount = np.clip(yellow * (0.6 + 0.6 * g + 0.5 * t), 0, 1)
			col = col * (1 - amount[..., None]) + yel * amount[..., None] * (1 + 0.05 * f[..., None])
		if spots > 0:
			spot = smoothstep(1.3 - spots, 1.6 - spots, f * 0.6 + g * 0.6)
			col = col * (1 - 0.8 * spot[..., None]) + np.array([0.32, 0.2, 0.08]) * 0.8 * spot[..., None]
		for _ in range(holes):
			ht = self.rng.uniform(0.25, 0.85)
			hu = self.rng.uniform(-0.7, 0.7)
			hr = self.rng.uniform(0.06, 0.16) * W
			cx = bx + d[0] * L * ht + n[0] * hu * W * 0.4
			cy = by + d[1] * L * ht + n[1] * hu * W * 0.4
			dist = np.hypot(xx - cx, yy - cy)
			alpha *= np.clip((dist - hr) / 1.5, 0, 1)
			col *= (1 - 0.35 * np.exp(-((dist - hr) / 3.0) ** 2))[..., None]
		if petiole > 0:
			pt = -along / (petiole * s)
			stalk = (pt >= 0) & (pt <= 1) & (np.abs(rx * n[0] + ry * n[1]) <= max(W * 0.035, 1.6))
			alpha = np.maximum(alpha, stalk.astype(np.float32))
			col[stalk] = np.array(color) * 1.2
		self.over(y0, x0, col, alpha)

	def stem(self, pts, width0, width1, color):
		"""A tapered stalk along a polyline (canvas pixels)."""
		s = SS
		pts = [(p[0] * s, p[1] * s) for p in pts]
		total = sum(math.dist(a, b) for a, b in zip(pts, pts[1:]))
		run = 0.0
		for a, b in zip(pts, pts[1:]):
			seg = math.dist(a, b)
			box = self._box([a, b], max(width0, width1) * s + 3)
			if box is None or seg < 1e-3:
				run += seg
				continue
			y0, x0, xx, yy = box
			dx, dy = (b[0] - a[0]) / seg, (b[1] - a[1]) / seg
			along = np.clip((xx - a[0]) * dx + (yy - a[1]) * dy, 0, seg)
			px, py = a[0] + dx * along, a[1] + dy * along
			dist = np.hypot(xx - px, yy - py)
			t = (run + along) / max(total, 1e-3)
			wid = (width0 + (width1 - width0) * t) * s * 0.5
			alpha = np.clip((wid - dist) / 1.2 + 0.5, 0, 1).astype(np.float32)
			col = np.empty(alpha.shape + (3,), np.float32)
			col[:] = color
			col *= (1 - 0.35 * (dist / np.maximum(wid, 1e-3)) ** 2)[..., None]
			self.over(y0, x0, col, alpha)
			run += seg

	def disc(self, centre, radius, color, soft=1.2, shade=0.25):
		s = SS
		cx, cy, r = centre[0] * s, centre[1] * s, radius * s
		box = self._box([(cx - r, cy - r), (cx + r, cy + r)], 3)
		if box is None:
			return
		y0, x0, xx, yy = box
		dist = np.hypot(xx - cx, yy - cy)
		alpha = np.clip((r - dist) / soft + 0.5, 0, 1).astype(np.float32)
		col = np.empty(alpha.shape + (3,), np.float32)
		col[:] = color
		col *= (1 - shade * np.clip((yy - cy) / max(r, 1e-3), -1, 1) * 0.5 - shade * 0.5 * (dist / max(r, 1e-3)) ** 2)[..., None]
		self.over(y0, x0, col, alpha)

	def flower(self, centre, radius, petals, color, eye=None, eye_r=0.25, twist=0.35, rot=0.0, shape=(1.3, 0.45), lobed=0.0):
		"""A flat flower: `petals` obovate petals in a pinwheel around the centre."""
		for k in range(petals):
			ang = rot + k / petals * math.tau
			off = radius * 0.08
			base = (centre[0] + math.cos(ang + math.pi / 2) * off * twist * 4, centre[1] + math.sin(ang + math.pi / 2) * off * twist * 4)
			shade = 1.0 - 0.06 * (k % 2)
			self.leaf(base, ang + twist * 0.3, radius, radius * 0.95, tuple(c * shade for c in color), shape=shape,
				veins=0, vein_light=0.0, fold=0.0, midrib=color, tip_round=lobed)
		if eye is not None:
			self.disc(centre, radius * eye_r, eye, soft=1.5, shade=0.1)

	def finish(self):
		"""Downsamples, returns (rgb with pushed colour, alpha)."""
		h, w = self.h // SS, self.w // SS
		prem = self.rgb * self.a[..., None]
		prem = prem.reshape(h, SS, w, SS, 3).mean(axis=(1, 3))
		a = self.a.reshape(h, SS, w, SS).mean(axis=(1, 3))
		rgb = prem / np.maximum(a, 1e-6)[..., None]
		rgb = push_pull(np.clip(rgb, 0, 1), np.clip(a, 0, 1) ** 0.5 * (a > 0.02))
		return rgb, a


def save_rgba(name, canvas):
	rgb, a = canvas.finish()
	save(name, np.dstack([rgb, a]), "RGBA")


def jitter(rng, color, amount=0.08):
	f = 1.0 + rng.uniform(-amount, amount)
	hue = rng.uniform(-amount, amount) * 0.5
	return (max(color[0] * f + hue * 0.3, 0), max(color[1] * f, 0), max(color[2] * f - hue * 0.3, 0))


# ---------------------------------------------------------------------------------------------- trees

PLUMERIA_GREEN = (0.16, 0.30, 0.10)


def plumeria():
	"""Hoa đại: long leathery obovate-lanceolate leaves with many parallel veins, white flowers with a yellow eye."""
	c = Canvas(1024, 1024, 259_01)
	rng = c.rng
	# Top half: four single leaves in 256 x 512 columns, base at the bottom centre, tip up.
	looks = [dict(color=PLUMERIA_GREEN), dict(color=(0.20, 0.34, 0.12), gloss=0.04),
		dict(color=(0.22, 0.32, 0.10), yellow=0.45, spots=0.35), dict(color=(0.15, 0.28, 0.10), holes=3, spots=0.2)]
	for col, look in enumerate(looks):
		x = col * 256 + 128
		c.leaf((x, 500), -math.pi / 2, 470, 150, shape=(0.95, 0.62), curve=rng.uniform(-0.05, 0.05), veins=26,
			vein_slope=0.35, vein_light=0.08, fold=0.12, petiole=8, **{"gloss": 0.03, **look})
	# Bottom left: a cluster of five to seven flowers on a stout green stalk, buds.
	cx, cy = 256, 760
	c.stem([(256, 1020), (250, 880), (256, 790)], 16, 9, (0.24, 0.32, 0.14))
	for k in range(9):
		ang = -math.pi / 2 + rng.uniform(-1.2, 1.2)
		length = rng.uniform(40, 110)
		tip = (cx + math.cos(ang) * length, cy + math.sin(ang) * length * 0.8)
		c.stem([(cx, cy + 30), tip], 5, 3, (0.30, 0.36, 0.16))
		if k < 6:
			c.flower(tip, rng.uniform(52, 66), 5, (0.95, 0.94, 0.88), eye=(0.98, 0.78, 0.22), eye_r=0.42,
				rot=rng.uniform(0, math.tau), twist=0.45)
		else:
			c.leaf((tip[0], tip[1] + 18), ang, 34, 14, (0.86, 0.84, 0.7), veins=0, vein_light=0, fold=0.1)
	# Bottom right: a young leaf tuft at a branch tip (pale, upright), for the tips without flowers.
	for k in range(9):
		ang = -math.pi / 2 + (k - 4) * 0.22 + rng.uniform(-0.05, 0.05)
		c.leaf((768, 1010), ang, rng.uniform(300, 420), rng.uniform(80, 105), (0.24, 0.40, 0.13), shape=(0.95, 0.62),
			veins=22, vein_slope=0.35, fold=0.1, petiole=6, gloss=0.03, curve=(k - 4) * 0.03)
	save_rgba("leaf_plumeria.png", c)


def mantaly():
	"""Bàng Đài Loan: tiny obovate leaves in whorled rosettes at twig ends, tiered."""
	c = Canvas(1024, 1024, 259_02)
	rng = c.rng
	base_col = (0.20, 0.36, 0.11)

	def rosette(cx, cy, r, count, top=True):
		for k in range(count):
			ang = k / count * math.tau + rng.uniform(-0.2, 0.2)
			ln = r * rng.uniform(0.75, 1.0)
			squash = 1.0 if top else 0.45
			c.leaf((cx, cy), ang if top else math.atan2(math.sin(ang) * squash, math.cos(ang)), ln, ln * 0.55,
				jitter(rng, base_col, 0.12), shape=(1.4, 0.45), veins=5, vein_slope=0.8, vein_light=0.05, fold=0.08,
				tip_round=0.25, gloss=0.02, yellow=0.25 if rng.random() < 0.08 else 0.0)

	for cell, (ox, oy) in enumerate([(0, 0), (512, 0), (0, 512), (512, 512)]):
		if cell < 2:
			# Seen from above: a twig fan with 6-9 rosettes.
			twigs = 7 if cell == 0 else 9
			c.stem([(ox + 256, oy + 256), (ox + 256 + 10, oy + 260)], 6, 5, (0.3, 0.26, 0.2))
			for k in range(twigs):
				ang = k / twigs * math.tau + rng.uniform(-0.2, 0.2)
				dist = rng.uniform(100, 200)
				tip = (ox + 256 + math.cos(ang) * dist, oy + 256 + math.sin(ang) * dist)
				c.stem([(ox + 256, oy + 256), tip], 5, 2, (0.32, 0.28, 0.22))
				rosette(tip[0], tip[1], rng.uniform(48, 62), int(rng.integers(6, 10)))
			rosette(ox + 256, oy + 256, 55, 8)
		elif cell == 2:
			# Side view: a horizontal twig with rosettes standing up and drooping.
			c.stem([(ox + 20, oy + 300), (ox + 260, oy + 290), (ox + 492, oy + 305)], 7, 3, (0.32, 0.27, 0.21))
			for k in range(8):
				x = ox + 50 + k * 58 + rng.uniform(-10, 10)
				y = oy + 295 + rng.uniform(-8, 8)
				rosette(x, y, rng.uniform(55, 75), int(rng.integers(6, 9)), top=False)
		else:
			# Sparse: a few twigs with small rosettes, some bare.
			for k in range(4):
				ang = -math.pi / 2 + (k - 1.5) * 0.6
				tip = (ox + 256 + math.cos(ang) * 200, oy + 470 + math.sin(ang) * 200 * 1.8)
				c.stem([(ox + 256, oy + 500), tip], 6, 2, (0.32, 0.28, 0.22))
				rosette(tip[0], tip[1], 50, int(rng.integers(5, 8)))
	save_rgba("leaf_mantaly.png", c)


def lagerstroemia():
	"""Bằng lăng: elliptic leaves in near-opposite pairs on twigs; a purple panicle; old red-orange leaves."""
	c = Canvas(1024, 1024, 259_03)
	rng = c.rng
	green = (0.17, 0.31, 0.11)

	def twig(ox, oy, colour, old=0.0):
		pts = [(ox + 256 + rng.uniform(-20, 20), oy + 505), (ox + 250, oy + 330), (ox + 262, oy + 150), (ox + 256, oy + 30)]
		c.stem(pts, 8, 3, (0.36, 0.3, 0.22))
		for k in range(7):
			t = 0.12 + k * 0.125
			y = oy + 505 - t * 470
			x = ox + 256 + math.sin(t * 5) * 8
			for side in (-1, 1):
				ang = -math.pi / 2 + side * rng.uniform(0.75, 1.15)
				ln = rng.uniform(150, 200) * (1.05 - 0.4 * t)
				c.leaf((x, y), ang, ln, ln * 0.42, jitter(rng, colour, 0.1), shape=(0.85, 0.85), veins=9,
					vein_slope=0.75, vein_light=0.06, fold=0.12, gloss=0.04, curve=side * 0.06, petiole=6,
					yellow=old * rng.uniform(0.5, 1.0), spots=old * 0.4)

	twig(0, 0, green)
	twig(512, 0, (0.19, 0.33, 0.12))
	# Purple panicle: crinkled six-petal flowers on a cone, round buds.
	ox, oy = 0, 512
	c.stem([(256, 1020), (256, 560)], 9, 3, (0.36, 0.3, 0.24))
	for k in range(4):
		side = -1 if k % 2 else 1
		c.leaf((256, 1000 - k * 40), -math.pi / 2 + side * 1.0, 170, 70, jitter(rng, green, 0.1), shape=(0.85, 0.85),
			veins=9, vein_slope=0.75, fold=0.12, gloss=0.04)
	for k in range(34):
		t = rng.uniform(0.0, 1.0) ** 0.8
		y = oy + 60 + t * 330
		spread = 30 + t * 150
		x = 256 + rng.uniform(-spread, spread)
		if rng.random() < 0.3:
			c.disc((x, y), rng.uniform(9, 13), (0.42, 0.26, 0.5), shade=0.3)
		else:
			c.flower((x, y), rng.uniform(26, 38), 6, jitter(rng, (0.62, 0.42, 0.80), 0.08), eye=(0.9, 0.78, 0.3),
				eye_r=0.22, rot=rng.uniform(0, math.tau), twist=0.2, shape=(1.0, 0.35), lobed=0.3)
	# Old leaves turning red-orange before they drop (bằng lăng does this in the dry season).
	twig(512, 512, (0.42, 0.20, 0.08), old=0.3)
	save_rgba("leaf_lagerstroemia.png", c)


# ---------------------------------------------------------------------------------------------- shrubs

def shrubs():
	"""4 x 4 cells of 256 px; each cell is one card (clusters fill the cell, bottom centre is the ground)."""
	c = Canvas(1024, 1024, 259_04)
	rng = c.rng

	def cell(col, row):
		return col * 256, row * 256

	def cluster(ox, oy, count, leaf_len, leaf_w, colour, shape=(0.9, 0.7), veins=5, spread=1.0, gloss=0.03,
			up=True, yellow=0.0, tip_round=0.0):
		for k in range(count):
			cx = ox + 128 + rng.normal(0, 52 * spread)
			cy = oy + 128 + rng.normal(0, 52 * spread) * 0.9
			cx = min(max(cx, ox + 24), ox + 232)
			cy = min(max(cy, oy + 24), oy + 232)
			ang = rng.uniform(0, math.tau) if not up else -math.pi / 2 + rng.uniform(-1.6, 1.6)
			ln = leaf_len * rng.uniform(0.75, 1.1)
			c.leaf((cx, cy), ang, ln, ln * leaf_w, jitter(rng, colour, 0.12), shape=shape, veins=veins,
				vein_slope=0.8, vein_light=0.05, fold=0.1, gloss=gloss, yellow=yellow if rng.random() < 0.15 else 0.0,
				tip_round=tip_round)

	# Row 0: chuỗi ngọc vàng (golden Duranta) x2, trang đỏ (Ixora) leaves x2.
	for col in (0, 1):
		ox, oy = cell(col, 0)
		cluster(ox, oy, 150, 26, 0.55, (0.46, 0.55, 0.12), veins=4, shape=(0.8, 0.8))
		cluster(ox, oy, 60, 24, 0.55, (0.30, 0.42, 0.10), veins=4, shape=(0.8, 0.8))
	for col in (2, 3):
		ox, oy = cell(col, 0)
		cluster(ox, oy, 46, 70, 0.32, (0.10, 0.25, 0.08), veins=8, shape=(0.9, 0.9), gloss=0.05)
	# Row 1: Ixora flower balls x2 (dense domes of four-petal red flowers), cẩm tú mai x2.
	for col in (0, 1):
		ox, oy = cell(col, 1)
		cluster(ox, oy, 14, 70, 0.32, (0.10, 0.25, 0.08), veins=8, shape=(0.9, 0.9), spread=0.9)
		for k in range(150):
			r = math.sqrt(rng.random()) * 88
			a = rng.uniform(0, math.tau)
			x, y = ox + 128 + math.cos(a) * r, oy + 120 + math.sin(a) * r * 0.8
			shade = 1.0 - 0.35 * max(0.0, (y - (oy + 120)) / 70.0)
			c.flower((x, y), rng.uniform(8, 11), 4, (0.86 * shade, 0.12 * shade, 0.06 * shade), rot=rng.uniform(0, 1.6),
				twist=0.1, shape=(1.0, 0.4), lobed=0.4)
	for col in (2, 3):
		ox, oy = cell(col, 1)
		cluster(ox, oy, 520, 15, 0.28, (0.14, 0.30, 0.09), veins=0, shape=(0.6, 0.6), spread=0.75)
		cluster(ox, oy, 200, 13, 0.28, (0.10, 0.22, 0.07), veins=0, shape=(0.6, 0.6), spread=0.6)
		for k in range(70):
			x, y = ox + 128 + rng.normal(0, 40), oy + 128 + rng.normal(0, 36)
			c.flower((x, y), rng.uniform(4.5, 6.5), 6, (0.62, 0.30, 0.66), rot=rng.uniform(0, 1), twist=0.1, shape=(1.0, 0.4))
	# Row 2: dừa cạn (Catharanthus) pink x2, white x1, leaves only x1.
	for col in range(4):
		ox, oy = cell(col, 2)
		cluster(ox, oy, 34, 48, 0.5, (0.12, 0.30, 0.10), veins=6, shape=(0.8, 0.8), gloss=0.07)
		if col < 3:
			petal = (0.9, 0.45, 0.62) if col < 2 else (0.94, 0.94, 0.9)
			for k in range(9 if col < 2 else 8):
				x, y = ox + rng.uniform(40, 216), oy + rng.uniform(36, 200)
				c.flower((x, y), rng.uniform(15, 19), 5, jitter(rng, petal, 0.05), eye=(0.62, 0.08, 0.2), eye_r=0.24,
					rot=rng.uniform(0, math.tau), twist=0.5, shape=(1.2, 0.35), lobed=0.35)
	# Row 3: grass tufts x2, a broadleaf weed, fallen leaves.
	for col in (0, 1):
		ox, oy = cell(col, 3)
		for k in range(60):
			ang = -math.pi / 2 + rng.normal(0, 0.45)
			ln = rng.uniform(110, 230)
			c.leaf((ox + 128 + rng.normal(0, 14), oy + 252), ang, ln, rng.uniform(5, 8), jitter(rng, (0.22, 0.36, 0.12), 0.18),
				shape=(0.4, 0.9), veins=0, vein_light=0, fold=0.15, curve=rng.normal(0, 0.12),
				yellow=0.7 if rng.random() < 0.18 else 0.0)
	ox, oy = cell(2, 3)
	for k in range(9):
		ang = -math.pi / 2 + (k - 4) * 0.33
		c.leaf((ox + 128, oy + 250), ang, rng.uniform(80, 130), 44, jitter(rng, (0.18, 0.34, 0.12), 0.1), shape=(0.7, 0.8),
			veins=6, fold=0.1, petiole=20, holes=1 if k % 3 == 0 else 0)
	ox, oy = cell(3, 3)
	for k in range(30):
		x, y = ox + rng.uniform(25, 231), oy + rng.uniform(25, 231)
		c.leaf((x, y), rng.uniform(0, math.tau), rng.uniform(30, 60), rng.uniform(12, 22),
			jitter(rng, (0.36, 0.25, 0.12), 0.25), veins=6, fold=0.2, yellow=0.3, spots=0.4)
	save_rgba("shrubs.png", c)


def hedge():
	"""A trimmed golden Duranta hedge face (0.5 m per 512 px, tiling): tiny leaves over dark gaps."""
	size = 512
	rng = np.random.default_rng(259_05)
	c = Canvas(size, size, 259_05)
	c.rgb[:] = (0.05, 0.08, 0.03)
	c.a[:] = 1.0
	for k in range(5200):
		x, y = rng.uniform(0, size), rng.uniform(0, size)
		ang = rng.uniform(0, math.tau)
		ln = rng.uniform(16, 26)
		depth = rng.random()
		tone = (0.44, 0.54, 0.12) if depth > 0.35 else (0.26, 0.38, 0.09)
		for dx in (-size, 0, size):
			for dy in (-size, 0, size):
				px, py = x + dx, y + dy
				if -30 < px < size + 30 and -30 < py < size + 30:
					c.leaf((px, py), ang, ln, ln * 0.55, jitter(rng, tone, 0.12), shape=(0.8, 0.8), veins=3,
						vein_light=0.04, fold=0.12, gloss=0.03)
	rgb, a = c.finish()
	lum = rgb.mean(axis=2)
	height = lum / lum.max()
	save("hedge_color.png", rgb)
	save("hedge_normal.png", wrap_gradient_normal(np.asarray(Image.fromarray((height * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.0)), np.float32) / 255.0, 6.0))


# ---------------------------------------------------------------------------------------------- bark, soil

def bark(name, base, size=512, seed=0, kind="smooth"):
	rng = np.random.default_rng(seed)
	big = smooth_noise(rng, size, 60)
	mid = smooth_noise(rng, size, 14)
	fine = smooth_noise(rng, size, 3)
	if kind == "plumeria":
		# Smooth grey skin, fine horizontal wrinkles, lenticels (short horizontal dashes).
		wrinkle = smooth_noise(rng, size, 3, aspect=0.12)
		height = 0.35 * mid + 0.4 * wrinkle + 0.15 * fine
		rgb = np.array(base)[None, None, :] * (1 + 0.06 * big + 0.04 * mid)[..., None]
		dash = np.zeros((size, size), np.float32)
		for k in range(260):
			x, y = rng.integers(0, size), rng.integers(0, size)
			w, h = rng.integers(5, 14), 2
			ys = (np.arange(y, y + h) % size)
			xs = (np.arange(x, x + w) % size)
			dash[np.ix_(ys, xs)] = 1.0
		dash = np.asarray(Image.fromarray((dash * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.8)), np.float32) / 255
		rgb = rgb * (1 - 0.25 * dash[..., None]) + np.array([0.62, 0.6, 0.52]) * 0.25 * dash[..., None]
		height -= dash * 0.8
		lichen = smoothstep(1.2, 1.8, big + 0.5 * mid)
		rgb = rgb * (1 - 0.35 * lichen[..., None]) + np.array([0.55, 0.58, 0.48]) * 0.35 * lichen[..., None]
		strength = 2.0
	elif kind == "mantaly":
		# Grey-brown with fine vertical fissures and pale lichen.
		fissure = smooth_noise(rng, size, 7, aspect=12.0)
		ridges = np.abs(fissure)
		height = -smoothstep(0.35, 0.0, ridges) * 1.0 + 0.3 * fine
		rgb = np.array(base)[None, None, :] * (1 + 0.08 * big + 0.05 * mid)[..., None]
		rgb *= (1 - 0.3 * smoothstep(0.35, 0.0, ridges))[..., None]
		lichen = smoothstep(1.4, 2.0, big + 0.6 * mid)
		rgb = rgb * (1 - 0.5 * lichen[..., None]) + np.array([0.6, 0.64, 0.52]) * 0.5 * lichen[..., None]
		strength = 3.0
	else:
		# Bằng lăng: smooth bark shedding in patches (cream, grey, tan).
		patches = smooth_noise(rng, size, 40) + 0.4 * mid
		tones = [np.array([0.62, 0.57, 0.48]), np.array([0.48, 0.47, 0.44]), np.array([0.58, 0.47, 0.34])]
		t1 = smoothstep(-0.4, -0.25, patches)
		t2 = smoothstep(0.55, 0.7, patches)
		rgb = tones[0][None, None, :] * (1 - t1[..., None]) + tones[1][None, None, :] * t1[..., None]
		rgb = rgb * (1 - t2[..., None]) + tones[2][None, None, :] * t2[..., None]
		rgb *= (1 + 0.04 * fine)[..., None]
		rgb *= (1 - 0.2 * (smoothstep(-0.32, -0.25, patches) - smoothstep(-0.25, -0.18, patches)))[..., None]
		height = 0.3 * t1 + 0.4 * t2 + 0.1 * fine
		strength = 2.5
	save(f"bark_{name}_color.png", np.clip(rgb, 0, 1))
	save(f"bark_{name}_normal.png", wrap_gradient_normal(height.astype(np.float32), strength))


def soil():
	size = 512  # 0.8 m
	rng = np.random.default_rng(259_06)
	big = smooth_noise(rng, size, 50)
	mid = smooth_noise(rng, size, 10)
	fine = smooth_noise(rng, size, 2)
	rgb = np.array([0.15, 0.11, 0.08])[None, None, :] * (1 + 0.15 * big + 0.1 * mid + 0.08 * fine)[..., None]
	height = 0.5 * mid + 0.3 * fine
	c = Canvas(size, size, 259_07)
	c.rgb[:] = np.repeat(np.repeat(rgb, SS, axis=0), SS, axis=1)
	c.a[:] = 1.0
	for k in range(140):
		x, y = rng.uniform(0, size), rng.uniform(0, size)
		c.disc((x, y), rng.uniform(1.5, 4.5), jitter(rng, (0.42, 0.40, 0.36), 0.2), shade=0.5)
	for k in range(60):
		x, y = rng.uniform(10, size - 10), rng.uniform(10, size - 10)
		c.leaf((x, y), rng.uniform(0, math.tau), rng.uniform(20, 45), rng.uniform(9, 16),
			jitter(rng, (0.3, 0.2, 0.1), 0.3), veins=5, fold=0.25, yellow=0.2, spots=0.4)
	rgb2, _ = c.finish()
	diff = np.abs(rgb2 - rgb).sum(axis=2)
	height = height + 2.0 * smoothstep(0.02, 0.1, diff)
	save("soil_color.png", rgb2)
	save("soil_normal.png", wrap_gradient_normal(height.astype(np.float32), 3.0))


# ---------------------------------------------------------------------------------------------- paving

def paving_block():
	"""Gạch block con sâu: 225 x 112.5 mm grey concrete pavers, wavy long sides, running bond; 0.9 m per 1024 px."""
	size = 1024
	m = 0.9 / size
	rng = np.random.default_rng(259_08)
	yy, xx = np.mgrid[0:size, 0:size].astype(np.float64) * m
	row_h, length = 0.1125, 0.225
	wave = 0.011 * np.sin(xx / 0.1125 * math.tau)
	rv = (yy - wave) / row_h
	row = np.floor(rv).astype(int) % 8
	fy = rv - np.floor(rv)
	shift = (row % 2) * 0.5 * length
	cv = (xx + shift) / length
	col = np.floor(cv).astype(int) % 4
	fx = cv - np.floor(cv)
	# Distance to the joints in metres.
	dy = np.minimum(fy, 1 - fy) * row_h
	dx = np.minimum(fx, 1 - fx) * length
	edge = np.minimum(dx, dy)
	pid = row * 4 + col
	tone = rng.normal(0, 1, 32)
	tilt = rng.normal(0, 1, (32, 2))
	big = smooth_noise(rng, size, 90)
	mid = smooth_noise(rng, size, 12)
	fine = smooth_noise(rng, size, 1.6)
	pores = (rng.random((size, size)) < 0.012).astype(np.float32)
	bevel = smoothstep(0.0015, 0.007, edge)
	height = bevel * (1.0 + 0.04 * tone[pid] + 0.03 * (tilt[pid, 0] * (fx - 0.5) + tilt[pid, 1] * (fy - 0.5))) + 0.05 * fine * bevel - 0.25 * pores * bevel
	base = np.array([0.50, 0.49, 0.46])
	rgb = base[None, None, :] * (1 + 0.05 * tone[pid] + 0.06 * big + 0.04 * mid + 0.05 * fine)[..., None]
	# Aggregate specks, a few stained pavers, sand and dirt in the joints.
	specks = smoothstep(2.0, 2.6, fine)
	rgb = rgb * (1 - 0.25 * specks[..., None]) + np.array([0.7, 0.68, 0.62]) * 0.25 * specks[..., None]
	stained = (tone[pid] > 1.2)[..., None]
	rgb = np.where(stained, rgb * np.array([0.82, 0.8, 0.76]), rgb)
	joint = 1 - bevel
	rgb = rgb * (1 - joint[..., None]) + np.array([0.22, 0.2, 0.17])[None, None, :] * (1 + 0.2 * mid)[..., None] * joint[..., None]
	ao = 0.55 + 0.45 * smoothstep(0.0, 0.01, edge)
	rough = np.clip(0.86 + 0.06 * mid + 0.1 * joint, 0, 1)
	save("paving_block_color.png", rgb)
	save("paving_block_normal.png", wrap_gradient_normal(height.astype(np.float32) * 6.0, 1.0))
	save("paving_block_orm.png", np.dstack([ao, rough, np.zeros_like(ao)]))


def paving_red():
	"""Gạch đỏ lá dừa: 300 x 300 mm terracotta, chevron grooves either side of a centre line, tiles laid
	crosswise in a checker; 8 mm cement joints. 1.2 m per 1024 px."""
	size = 1024
	m = 1.2 / size
	rng = np.random.default_rng(259_09)
	yy, xx = np.mgrid[0:size, 0:size].astype(np.float64) * m
	tile = 0.3
	tx, ty = np.floor(xx / tile).astype(int) % 4, np.floor(yy / tile).astype(int) % 4
	u, v = xx % tile, yy % tile
	cross = (tx + ty) % 2 == 1
	u2, v2 = np.where(cross, v, u), np.where(cross, u, v)
	joint_d = np.minimum.reduce([u, tile - u, v, tile - v])
	inner = smoothstep(0.003, 0.0055, joint_d)
	# Chevron grooves: the leaf's ribs.
	rib = (u2 + np.abs(v2 - tile / 2)) / 0.022
	gro = np.abs(rib - np.round(rib)) * 0.022
	groove = (1 - smoothstep(0.0012, 0.0024, gro)) * smoothstep(0.012, 0.016, joint_d)
	midline = (1 - smoothstep(0.0012, 0.0024, np.abs(v2 - tile / 2))) * smoothstep(0.012, 0.016, joint_d)
	groove = np.maximum(groove, midline)
	tid = tx * 4 + ty
	tone = rng.normal(0, 1, 16)
	big = smooth_noise(rng, size, 80)
	mid = smooth_noise(rng, size, 10)
	fine = smooth_noise(rng, size, 1.5)
	base = np.array([0.55, 0.26, 0.16])
	rgb = base[None, None, :] * (1 + 0.08 * tone[tid] + 0.07 * big + 0.05 * mid + 0.05 * fine)[..., None]
	burnt = (tone[tid] < -1.0)[..., None]
	rgb = np.where(burnt, rgb * np.array([0.78, 0.74, 0.72]), rgb)
	rgb = rgb * (1 - 0.45 * groove[..., None])
	chips = smoothstep(2.1, 2.5, mid + 0.6 * fine) * smoothstep(0.02, 0.006, joint_d)
	rgb = rgb * (1 - chips[..., None]) + np.array([0.62, 0.36, 0.24]) * chips[..., None]
	joint = 1 - inner
	cement = np.array([0.36, 0.35, 0.32])[None, None, :] * (1 + 0.12 * mid)[..., None]
	rgb = rgb * (1 - joint[..., None]) + cement * joint[..., None]
	height = inner * (1 - 0.5 * groove) - 0.6 * chips + 0.04 * fine
	ao = np.clip(0.55 + 0.45 * smoothstep(0.0, 0.009, joint_d) - 0.18 * groove, 0, 1)
	rough = np.clip(0.8 + 0.06 * mid + 0.12 * joint + 0.06 * groove, 0, 1)
	save("paving_red_color.png", rgb)
	save("paving_red_normal.png", wrap_gradient_normal(height.astype(np.float32) * 5.0, 1.0))
	save("paving_red_orm.png", np.dstack([ao, rough, np.zeros_like(ao)]))


# ---------------------------------------------------------------------------------------------- masks

BEDS = [(6 + 16 * j, 12 + 10 * i) for i in range(4) for j in range(3)]  # Bed{i}_{j} centres (x, z)
PATHS_X = [14.0, 30.0]
PATHS_Z = [17.0, 27.0, 37.0]


def bed_distance(px, pz):
	"""Distance (m) from each point to the nearest bed box (6 x 4 m)."""
	best = np.full(px.shape, 1e9)
	for bx, bz in BEDS:
		dx = np.maximum(np.abs(px - bx) - 3.0, 0)
		dz = np.maximum(np.abs(pz - bz) - 2.0, 0)
		best = np.minimum(best, np.hypot(dx, dz))
	return best


def mask_paving():
	size = 1024
	rng = np.random.default_rng(259_10)
	v, u = np.mgrid[0:size, 0:size].astype(np.float64) / (size - 1)
	px, pz = u * 44.0, 8.0 + v * 40.0  # UV2 u = x / 44, v = (z - 8) / 40
	big = smooth_noise(rng, size, 70)
	mid = smooth_noise(rng, size, 18)
	fine = smooth_noise(rng, size, 4)
	near_bed = np.exp(-bed_distance(px, pz) / 0.8)
	# Walking lines: the aisles between bed columns and rows, the entrance from building B, round Ngư's bench.
	walk = np.zeros_like(px)
	for x in PATHS_X:
		walk = np.maximum(walk, np.exp(-((px - x) / 1.4) ** 2))
	for z in PATHS_Z:
		walk = np.maximum(walk, np.exp(-((pz - z) / 1.2) ** 2) * 0.8)
	walk = np.maximum(walk, np.exp(-((px - 22) / 1.5) ** 2) * (pz < 11))
	walk = np.maximum(walk, np.exp(-(((px - 22) / 2.0) ** 2 + ((pz - 27.4) / 1.0) ** 2)))
	edge = np.minimum.reduce([px, 44 - px, pz - 8, 48 - pz])
	near_edge = np.exp(-edge / 1.2)
	walk *= 0.75 + 0.25 * smoothstep(-1, 1, mid)
	grout = np.clip(0.55 + 0.35 * near_bed + 0.25 * near_edge - 0.45 * walk + 0.15 * big, 0, 1)
	grime = np.clip(0.18 + 0.55 * near_bed * (0.7 + 0.3 * mid) + 0.3 * near_edge + 0.2 * smoothstep(0.8, 1.8, big + 0.5 * mid), 0, 1)
	wet = np.zeros_like(px)
	for k in range(9):
		bx, bz = BEDS[int(rng.integers(0, len(BEDS)))]
		side = rng.choice([-1, 1])
		cx = bx + rng.uniform(-2.5, 2.5)
		cz = bz + side * rng.uniform(2.3, 3.0)
		r = rng.uniform(0.4, 0.9)
		blob = np.exp(-(((px - cx) ** 2 + (pz - cz) ** 2) / r ** 2) * 2.0) + 0.15 * fine
		wet = np.maximum(wet, smoothstep(0.45, 0.75, blob))
	wear = np.clip(walk * (0.7 + 0.3 * fine), 0, 1)
	save("mask_paving.png", np.dstack([grout, grime, wet * 0.7, wear]), "RGBA")


def mask_kerb():
	"""12 rows of 1024 x 85 px, row r = bed index (i * 3 + j). u: perimeter (20 m), v: 0 bottom of the outer face,
	0.735 top edge, 0.912 inner edge, 1 soil line."""
	w, rows, rh = 1024, 12, 85
	h = rows * rh + 4
	rng = np.random.default_rng(259_11)
	out = np.zeros((h, w, 4))
	big = smooth_noise(rng, (h, w), 40)
	mid = smooth_noise(rng, (h, w), 8)
	streak = smooth_noise(rng, (h, w), 3, aspect=0.08)
	for r in range(rows):
		y0 = r * rh
		v = 1.0 - (np.arange(rh) / (rh - 1))[:, None] * np.ones((1, w))
		u = np.ones((rh, 1)) * (np.arange(w) / (w - 1))[None, :]
		b, m_, s = big[y0:y0 + rh], mid[y0:y0 + rh], streak[y0:y0 + rh]
		corner = np.zeros_like(u)
		for cu in (0.0, 0.3, 0.5, 0.8, 1.0):
			corner = np.maximum(corner, np.exp(-((u - cu) / 0.015) ** 2))
		height_m = np.clip(v / 0.735, 0, 1) * 0.5
		bottom = np.exp(-height_m / 0.12) * (v < 0.735)
		top = smoothstep(0.66, 0.74, v)
		peel = np.clip(0.25 * bottom + 0.35 * corner * (v < 0.8) + 0.25 * top * smoothstep(0.8, 1.6, m_) + 0.2 * smoothstep(1.2, 2.0, b + 0.5 * m_), 0, 1)
		grime = np.clip(0.75 * bottom + 0.5 * top + 0.12 + 0.15 * b * 0.5, 0, 1)
		stain = np.clip(smoothstep(0.6, 1.4, s) * smoothstep(0.1, 0.7, v) * (v < 0.74) * 0.8, 0, 1)
		mould = np.clip(np.exp(-height_m / 0.07) * (v < 0.735) * smoothstep(-0.6, 0.8, b + 0.6 * m_), 0, 1)
		out[y0:y0 + rh] = np.dstack([peel, grime, stain, mould])
	save("mask_kerb.png", out, "RGBA")


def mask_bench():
	"""UV2 from the front: u along the bench (-1.3..1.3 m), v height (0..0.6 m)."""
	size = 512
	rng = np.random.default_rng(259_12)
	v, u = np.mgrid[0:size, 0:size].astype(np.float64) / (size - 1)
	v = 1.0 - v
	mid = smooth_noise(rng, size, 20)
	fine = smooth_noise(rng, size, 4)
	grout = np.clip(0.5 + 0.2 * mid, 0, 1)
	grime = np.clip(0.25 + 0.6 * np.exp(-v / 0.15) + 0.15 * smoothstep(0.8, 1.8, mid), 0, 1)
	wet = np.zeros_like(u)
	wear = np.clip(np.exp(-((u - 0.5) / 0.3) ** 2) * smoothstep(0.85, 0.95, v) * (0.7 + 0.3 * fine), 0, 1)
	save("mask_bench.png", np.dstack([grout, grime, wet, wear]), "RGBA")


# ---------------------------------------------------------------------------------------------- round 2: strip, litter

def ground_grass():
	"""Trodden lawn seen from above (2 m per 1024 px, tiling): short blades over dark soil, a few dry ones."""
	size = 1024
	c = Canvas(size, size, 259_20)
	rng = c.rng
	big = smooth_noise(rng, (size * SS, size * SS), 60 * SS)
	c.rgb[:] = np.array([0.13, 0.11, 0.08], np.float32) * (1 + 0.15 * big)[..., None]
	c.a[:] = 1.0
	for k in range(9000):
		x, y = rng.uniform(0, size), rng.uniform(0, size)
		ang = rng.uniform(0, math.tau)
		ln = rng.uniform(14, 34)
		roll = rng.random()
		tone = (0.36, 0.34, 0.16) if roll < 0.12 else (0.16, 0.27, 0.09) if roll < 0.7 else (0.22, 0.33, 0.11)
		width = rng.uniform(2.2, 3.6)
		col = jitter(rng, tone, 0.15)
		bend = rng.normal(0, 0.15)
		for dx in (-size, 0, size):
			for dy in (-size, 0, size):
				px, py = x + dx, y + dy
				if -40 < px < size + 40 and -40 < py < size + 40:
					c.leaf((px, py), ang, ln, width, col, shape=(0.4, 0.9), veins=0, vein_light=0.0, fold=0.15, curve=bend)
	rgb, _ = c.finish()
	lum = rgb.mean(axis=2)
	lum8 = Image.fromarray((np.clip(lum / max(lum.max(), 1e-3), 0, 1) * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.8))
	save("ground_grass_color.png", rgb)
	save("ground_grass_normal.png", wrap_gradient_normal(np.asarray(lum8, np.float32) / 255.0, 5.0))


STRIP = (-6.0, 4.0, 56.0, 46.0)  # x0, z0, width, depth of the A16 strip: UV2 u = (x + 6) / 56, v = (z - 4) / 46


def mask_strip():
	"""UV2 over the strip (1024 x 844): R bare dirt (along B's front, from B to the garden entry, round the paving),
	G wet (by the gutter); B, A unused."""
	w, h = 1024, 844
	rng = np.random.default_rng(259_21)
	v, u = np.mgrid[0:h, 0:w].astype(np.float64)
	px = STRIP[0] + u / (w - 1) * STRIP[2]
	pz = STRIP[1] + v / (h - 1) * STRIP[3]
	big = smooth_noise(rng, (h, w), 40)
	mid = smooth_noise(rng, (h, w), 10)
	dirt = np.exp(-((pz - 5.4) / 1.0) ** 2)
	dirt = np.maximum(dirt, np.exp(-((px - 22) / 1.6) ** 2) * (pz < 9))
	dirt = np.maximum(dirt, np.exp(-((px - 2) / 1.3) ** 2) * (pz < 9) * 0.8)
	gap = np.minimum.reduce([np.abs(px - 0), np.abs(px - 44), np.abs(pz - 8), np.abs(pz - 48)])
	dirt = np.maximum(dirt, np.exp(-gap / 0.5) * 0.7)
	dirt = np.clip(dirt * (0.75 + 0.35 * smoothstep(-1, 1, mid)) + 0.25 * smoothstep(1.0, 2.0, big), 0, 1)
	wet = np.clip(np.exp(-((pz - 6.6) / 0.35) ** 2) * smoothstep(0.2, 1.2, big + 0.5 * mid), 0, 1)
	save("mask_strip.png", np.dstack([dirt, wet, np.zeros_like(px), np.ones_like(px)]), "RGBA")


def litter():
	"""2 x 2 cells: an exercise-book page, a printed flyer (lines only, no words), crumpled white paper, a torn plastic
	bag; alpha cut-out, a little dirt."""
	from PIL import ImageDraw
	size = 1024
	rng = np.random.default_rng(259_22)
	img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
	d = ImageDraw.Draw(img)
	d.polygon([(40, 60), (470, 40), (480, 470), (30, 480)], fill=(226, 222, 205, 255))
	for k in range(14):
		y = 90 + k * 27
		d.line([(40, y + 2), (474, y - 8)], fill=(150, 170, 200, 255), width=2)
		if k % 3 != 2:
			d.line([(90, y - 4), (90 + int(rng.integers(150, 360)), y - 9)], fill=(40, 60, 140, 255), width=3)
	d.line([(85, 55), (75, 475)], fill=(200, 90, 90, 255), width=2)
	d.rectangle([560, 40, 990, 480], fill=(205, 205, 198, 255))
	d.rectangle([590, 70, 960, 200], fill=(70, 72, 76, 255))
	for k in range(9):
		y = 225 + k * 26
		d.line([(590, y), (590 + int(rng.integers(200, 370)), y)], fill=(95, 95, 95, 255), width=8)
	cx, cy = 256, 768
	d.polygon([(cx + math.cos(k / 18 * math.tau) * (170 + rng.uniform(-40, 30)),
		cy + math.sin(k / 18 * math.tau) * (170 + rng.uniform(-40, 30))) for k in range(18)], fill=(222, 220, 212, 255))
	for k in range(14):
		a = rng.uniform(0, math.tau)
		r1, r2 = rng.uniform(0, 60), rng.uniform(90, 160)
		d.line([(cx + math.cos(a) * r1, cy + math.sin(a) * r1), (cx + math.cos(a + 0.3) * r2, cy + math.sin(a + 0.3) * r2)],
			fill=(150, 148, 140, 255), width=3)
	cx, cy = 768, 768
	d.polygon([(cx + math.cos(k / 22 * math.tau) * (200 + rng.uniform(-50, 20)),
		cy + math.sin(k / 22 * math.tau) * (170 + rng.uniform(-50, 20))) for k in range(22)], fill=(40, 80, 150, 255))
	for k in range(10):
		a = rng.uniform(0, math.tau)
		d.line([(cx, cy), (cx + math.cos(a) * 170, cy + math.sin(a) * 140)], fill=(70, 115, 185, 255), width=4)
	arr = np.asarray(img).astype(np.float32) / 255.0
	arr[..., :3] *= np.clip(0.85 + 0.1 * smooth_noise(rng, size, 30), 0.6, 1.0)[..., None]
	rgb = push_pull(arr[..., :3], arr[..., 3])
	save("litter.png", np.dstack([rgb, arr[..., 3]]), "RGBA")


def board_papers():
	"""Six notices for the garden notice board (1024 x 512, three sheets a row): lines, a grid, a stamp ring; no words,
	as on the PS1 board."""
	from PIL import ImageDraw
	w, h = 1024, 512
	rng = np.random.default_rng(259_23)
	img = Image.new("RGB", (w, h), (60, 50, 40))
	d = ImageDraw.Draw(img)
	for k in range(6):
		x0, y0 = (k % 3) * 341 + 10, (k // 3) * 256 + 8
		x1, y1 = x0 + 320, y0 + 240
		d.rectangle([x0, y0, x1, y1], fill=(230, 226, 210) if k % 2 == 0 else (238, 232, 196))
		d.line([(x0 + 60, y0 + 22), (x1 - 60, y0 + 22)], fill=(40, 40, 40), width=6)
		if k in (1, 4):
			for r in range(6):
				for col in range(4):
					d.rectangle([x0 + 20 + col * 70, y0 + 45 + r * 30, x0 + 90 + col * 70, y0 + 75 + r * 30], outline=(90, 90, 90))
		else:
			for r in range(9):
				y = y0 + 50 + r * 18
				d.line([(x0 + 20, y), (x0 + 20 + int(rng.integers(150, 280)), y)], fill=(70, 70, 70), width=4)
		d.ellipse([x1 - 90, y1 - 70, x1 - 30, y1 - 10], outline=(170, 40, 40), width=4)
	arr = np.asarray(img).astype(np.float32) / 255.0
	arr *= (1 - 0.12 * smoothstep(0.8, 2.0, smooth_noise(rng, (h, w), 25)))[..., None] * np.array([1.0, 0.97, 0.9])
	save("board_papers.png", arr)


# Pilot options the owner did not pick (D-175) are drawn only when named.
PILOT_ONLY = {"mantaly", "paving_red", "bark_mantaly"}
ALL = {"plumeria": plumeria, "mantaly": mantaly, "lagerstroemia": lagerstroemia, "shrubs": shrubs, "hedge": hedge,
	"bark": lambda: [bark("plumeria", (0.46, 0.45, 0.41), seed=259_13, kind="plumeria"),
		bark("lagerstroemia", (0.55, 0.52, 0.46), seed=259_15, kind="lager")],
	"bark_mantaly": lambda: bark("mantaly", (0.36, 0.32, 0.28), seed=259_14, kind="mantaly"),
	"soil": soil, "paving_block": paving_block, "paving_red": paving_red, "mask_paving": mask_paving,
	"mask_kerb": mask_kerb, "mask_bench": mask_bench, "ground_grass": ground_grass, "mask_strip": mask_strip,
	"litter": litter, "board_papers": board_papers}


if __name__ == "__main__":
	for key in (sys.argv[1:] or [k for k in ALL if k not in PILOT_ONLY]):
		ALL[key]()
