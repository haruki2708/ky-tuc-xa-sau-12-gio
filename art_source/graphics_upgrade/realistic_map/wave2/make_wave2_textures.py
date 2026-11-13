"""T-253 (D-167) wave 2: textures drawn here (numpy + Pillow), no downloaded image and no AI image.

  mask_hall_wall.png    corridor face of the room walls, floors 1-3 (room407_shell.gdshader kind 0 on UV2):
                        R paint loss, G grime, B water stain, A mould. One row per floor (row 0 = floor 3 at the
                        top of the image, floor 1 at the bottom); u = x / 44 along the corridor, v = height / 3.03
                        inside the row. Drawn at the real places: scuffs and hand marks by every door's latch and
                        hinge, rubbed bands where people lean, damp from the ceiling here and there, none repeating.
  mask_hall_floor.png   corridor floors (kind 1): G grime, B wet, A wear (no grout: the terrazzo has none).
                        u = x / 44, v = z / 4 inside the floor's row: dirt along the wall and the rail curb, the
                        worn path down the middle, the turns into each door and the stairs, rain blown in at the rail.
  mask_hall_ceiling.png corridor ceilings (kind 0): soot over the lamps, damp along the open edge, a few leaks.
  extinguisher_label.png, gauge_dial.png, alarm_face.png   the fire extinguisher's label and gauge, the fire alarm's
                        face (A11). Words are drawn with Be Vietnam Pro (OFL, in the game already).
Run: python -B art_source/graphics_upgrade/realistic_map/wave2/make_wave2_textures.py [job ...]
"""
from pathlib import Path
import math
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import layout as L  # noqa: E402

ROOT = Path(__file__).resolve().parents[4]
OUT = ROOT / "game/assets/textures/graphics_pilot/realistic_map/wave2"
FONT_BOLD = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_regular.ttf"
ROWS = (3, 2, 1)  # floors from the top of the image down


def smooth_noise(rng, shape, scale):
	"""Noise of unit variance low-passed at about `scale` pixels (any 2-D shape)."""
	h, w = shape
	white = rng.normal(0.0, 1.0, (h, w))
	fy = np.fft.fftfreq(h)[:, None]
	fx = np.fft.rfftfreq(w)[None, :]
	lowpass = np.exp(-((fy * scale) ** 2 + (fx * scale) ** 2) * 18.0)
	out = np.fft.irfft2(np.fft.rfft2(white) * lowpass, s=(h, w))
	return out / max(out.std(), 1e-9)


def save_rgba(name, rgba):
	OUT.mkdir(parents=True, exist_ok=True)
	img = Image.fromarray((np.clip(rgba, 0.0, 1.0) * 255.0 + 0.5).astype(np.uint8), "RGBA")
	img.save(OUT / name, optimize=True)


def save_rgb(name, rgb):
	OUT.mkdir(parents=True, exist_ok=True)
	img = Image.fromarray((np.clip(rgb, 0.0, 1.0) * 255.0 + 0.5).astype(np.uint8), "RGB")
	img.save(OUT / name, optimize=True)


def blob(x, y, cx, cy, rx, ry):
	return np.exp(-(((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2))


def hall_wall():
	"""4096 x 1536: three rows of 512 px for 44 m x 3.03 m (93 px/m along, 169 px/m up)."""
	w, rh = 4096, 512
	rows = []
	for floor in ROWS:
		rng = np.random.default_rng(253_100 + floor)
		x = np.broadcast_to(np.linspace(0.0, 44.0, w)[None, :], (rh, w))
		h = np.broadcast_to(np.linspace(L.CEILING, 0.0, rh)[:, None], (rh, w))  # image row 0 = top of the wall
		fine = smooth_noise(rng, (rh, w), 4)
		mid = smooth_noise(rng, (rh, w), 22)
		big = smooth_noise(rng, (rh, w), 120)
		# Grime: the foot of the wall, mop splash and shoe scuffs, a rubbed band where backs and bags lean.
		grime = np.clip(1.0 - h / 0.06, 0, 1) ** 1.4 * 0.8 + np.clip(1.0 - h / 0.18, 0, 1) * 0.3
		lean = np.exp(-((h - 1.05) / 0.22) ** 2) * np.clip(0.25 + mid * 0.2, 0, 0.45) * 0.5
		grime = grime + lean + np.clip(big * 0.07 + 0.06, 0, 0.18) + fine * 0.025
		peel = np.zeros((rh, w))
		stain = np.zeros((rh, w))
		mould = np.zeros((rh, w))
		for i in range(L.BAYS):
			cx = L.door_x(i)
			darker = 0.6 + 0.4 * rng.random()
			for side in (-1, 1):
				# Hand marks on the wall beside both jambs, heavier on the latch side (the leaves meet in the middle,
				# people push the wall as they go in), and kicks at the foot of the architraves.
				edge = cx + side * (L.DOOR_HALF + 0.12)
				grime = grime + blob(x, h, edge + side * 0.08, 1.15, 0.1, 0.32) * (0.28 + 0.12 * rng.random()) * darker
				grime = grime + blob(x, h, edge + side * 0.05, 0.12, 0.16, 0.12) * 0.35 * darker
			# Above the door: soot from years of the corridor lamp and dust on the head.
			grime = grime + blob(x, h, cx, 2.85, 0.75, 0.08) * 0.18
			# Kicks along the wall where people stop and wait.
			for _ in range(rng.integers(2, 5)):
				kx = cx + rng.uniform(-2.6, 2.6)
				if abs(kx - cx) < L.DOOR_HALF + 0.15:
					continue
				grime = grime + blob(x, h, kx, rng.uniform(0.1, 0.3), rng.uniform(0.04, 0.09), rng.uniform(0.03, 0.08)) * rng.uniform(0.3, 0.6)
		# Water: runs from the ceiling where the floor above leaks (not on doors), tide lines darker.
		for _ in range(rng.integers(3, 6)):
			sx = rng.uniform(0.5, 43.5)
			if min(abs(sx - L.door_x(i)) for i in range(L.BAYS)) < L.DOOR_HALF + 0.25:
				continue
			width = rng.uniform(0.12, 0.35)
			length = rng.uniform(0.5, 1.6)
			wobble = sx + np.sin(h * 7.0 + sx) * 0.03
			body = np.exp(-((x - wobble) / width) ** 2 * 2.0) * np.clip((h - (L.CEILING - length)) / 0.25, 0, 1)
			tide = np.exp(-((h - (L.CEILING - length)) / 0.03) ** 2) * np.exp(-((x - wobble) / (width * 1.2)) ** 2)
			stain = np.maximum(stain, body * (0.5 + 0.3 * np.clip(fine * 0.5 + 0.5, 0, 1)) + tide * 0.5)
			mould = np.maximum(mould, blob(x, h, sx, L.CEILING - 0.05, width * 0.8, 0.12) * 0.55)
		# Paint loss: a few patches in the upper wall, flakes over the damp, edges by the stairwells.
		patches = np.clip((mid * 0.6 + big * 0.55 + fine * 0.2 - 1.25) * 0.9, 0, 1) * (0.3 + 0.7 * np.clip((h - 1.2) / 1.2, 0, 1))
		peel = np.maximum(peel, patches)
		peel = np.maximum(peel, np.clip(stain - 0.45, 0, 1) * 1.2)
		for ex in (0.0, 44.0):
			peel = np.maximum(peel, blob(x, h, ex, 0.4, 0.35, 0.35) * 0.55 * np.clip(0.6 + mid * 0.4, 0, 1))
			mould = np.maximum(mould, blob(x, h, ex, 0.05, 0.4, 0.15) * 0.6)
		rows.append(np.stack([np.clip(peel, 0, 1), np.clip(grime, 0, 1), np.clip(stain, 0, 1), np.clip(mould, 0, 1)], axis=2))
	rgba = np.concatenate(rows, axis=0)
	save_rgba("mask_hall_wall.png", rgba)


def hall_floor():
	"""4096 x 1536: three rows of 512 px for 44 m x 4 m (z 0 at the bottom of each row)."""
	w, rh = 4096, 512
	rows = []
	for floor in ROWS:
		rng = np.random.default_rng(253_200 + floor)
		x = np.broadcast_to(np.linspace(0.0, 44.0, w)[None, :], (rh, w))
		z = np.broadcast_to(np.linspace(4.0, 0.0, rh)[:, None], (rh, w))
		fine = smooth_noise(rng, (rh, w), 4)
		mid = smooth_noise(rng, (rh, w), 24)
		big = smooth_noise(rng, (rh, w), 140)
		# Grime gathers at the foot of the wall and at the rail's curb, and in the corners at both ends.
		grime = np.clip(1.0 - (z - L.FACE) / 0.22, 0, 1) ** 1.6 * 0.75 + np.clip(1.0 - (L.RAIL_FRONT - z) / 0.3, 0, 1) ** 1.4 * 0.7
		grime = grime + np.clip(big * 0.08 + 0.06, 0, 0.2) + fine * 0.03
		for ex in (0.0, 44.0):
			grime = grime + blob(x, z, ex, 2.0, 0.6, 2.2) * 0.15
		# The worn path down the corridor, wandering a little; the turns into each door and onto the stairs.
		lane = 2.0 + np.sin(x * 0.21 + floor) * 0.25 + np.sin(x * 0.07) * 0.2
		wear = np.exp(-((z - lane) / 0.75) ** 2) * np.clip(0.55 + mid * 0.2, 0, 1)
		for i in range(L.BAYS):
			cx = L.door_x(i)
			busy = 0.4 if floor == 1 and i in L.F1_SHUT else 1.0
			wear = wear + blob(x, z, cx, 0.9, 0.55, 0.9) * 0.45 * busy
			grime = grime + blob(x, z, cx, 0.35, 0.7, 0.25) * 0.25 * busy
		for ex in (0.0, 44.0):
			wear = wear + blob(x, z, ex, 2.0, 1.4, 1.6) * 0.4
		# Wet: rain blown in under the rail, a mopped patch, a puddle by the stairs on the lower floors.
		wet = np.clip(1.0 - (L.RAIL_FRONT - z) / 0.25, 0, 1) * np.clip(mid * 0.5 + 0.3, 0, 1) * 0.6
		for _ in range(rng.integers(1, 3)):
			wet = np.maximum(wet, blob(x, z, rng.uniform(3, 41), rng.uniform(1.0, 3.2), rng.uniform(0.4, 1.0), rng.uniform(0.25, 0.6))
				* np.clip(0.75 + fine * 0.25, 0, 1) * rng.uniform(0.35, 0.6))
		if floor == 1:
			wet = np.maximum(wet, blob(x, z, L.MAIN_DOOR_X, 3.7, 1.3, 0.4) * 0.5)
		wet = np.clip((wet - 0.08) * 1.2, 0, 1)
		rows.append(np.stack([np.zeros_like(x), np.clip(grime, 0, 1), wet, np.clip(wear, 0, 1)], axis=2))
	save_rgba("mask_hall_floor.png", np.concatenate(rows, axis=0))


def hall_ceiling():
	"""4096 x 768: three rows of 256 px for 44 m x 4 m (z 0 at the bottom of each row)."""
	w, rh = 4096, 256
	rows = []
	for floor in ROWS:
		rng = np.random.default_rng(253_300 + floor)
		x = np.broadcast_to(np.linspace(0.0, 44.0, w)[None, :], (rh, w))
		z = np.broadcast_to(np.linspace(4.0, 0.0, rh)[:, None], (rh, w))
		fine = smooth_noise(rng, (rh, w), 3)
		mid = smooth_noise(rng, (rh, w), 14)
		big = smooth_noise(rng, (rh, w), 80)
		grime = np.clip(big * 0.08 + 0.08, 0, 0.2) + fine * 0.02
		for lx in L.LIGHTS_X:
			grime = grime + blob(x, z, lx, L.LIGHT_Z, 1.1, 0.45) * (0.35 + 0.2 * rng.random())
		# The open edge: rain and damp along it, flakes.
		damp = np.clip(1.0 - (4.0 - z) / 0.6, 0, 1) * np.clip(0.4 + mid * 0.35, 0, 1)
		grime = grime + damp * 0.35
		stain = damp * 0.45
		mould = np.clip(1.0 - (4.0 - z) / 0.2, 0, 1) * np.clip(0.3 + big * 0.3, 0, 1) * 0.5
		for _ in range(rng.integers(2, 4)):
			lx, lz = rng.uniform(1.5, 42.5), rng.uniform(0.6, 3.4)
			r = rng.uniform(0.25, 0.6)
			d = np.hypot((x - lx) / 1.0, (z - lz) / 0.8)
			ring = np.exp(-((d - r) / 0.04) ** 2)
			stain = np.maximum(stain, np.clip(1.0 - d / r, 0, 1) ** 0.5 * 0.55 + ring * 0.5)
		peel = np.clip(stain - 0.5, 0, 1) * 1.3 + np.clip((mid * 0.5 + big * 0.5 - 1.5), 0, 1) * 0.6
		rows.append(np.stack([np.clip(peel, 0, 1), np.clip(grime, 0, 1), np.clip(stain, 0, 1), np.clip(mould, 0, 1)], axis=2))
	save_rgba("mask_hall_ceiling.png", np.concatenate(rows, axis=0))


def extinguisher_label():
	"""The label wrapped round the cylinder (u round, v up): 1024 x 512, a printed sheet a bit scuffed."""
	w, h = 1024, 512
	rng = np.random.default_rng(253_400)
	img = Image.new("RGB", (w, h), (178, 24, 22))
	d = ImageDraw.Draw(img)
	# The sheet faces the corridor: it spans u 0.3..0.7 of the cylinder.
	x0, x1 = int(w * 0.3), int(w * 0.7)
	d.rectangle([x0, 40, x1, h - 40], fill=(232, 228, 214))
	d.rectangle([x0, 40, x1, 120], fill=(196, 30, 26))
	big = ImageFont.truetype(str(FONT_BOLD), 46)
	small = ImageFont.truetype(str(FONT_BOLD), 26)
	d.text(((x0 + x1) // 2, 80), "BÌNH CHỮA CHÁY", font=big, fill=(245, 240, 230), anchor="mm")
	d.text(((x0 + x1) // 2, 160), "BỘT ABC  4 kg", font=small, fill=(40, 36, 34), anchor="mm")
	# Instructions as four pictograms with lines of print under each.
	for k in range(4):
		cx = x0 + 30 + k * (x1 - x0 - 60) // 4 + (x1 - x0 - 60) // 8
		d.ellipse([cx - 34, 200, cx + 34, 268], outline=(196, 30, 26), width=5)
		d.text((cx, 234), str(k + 1), font=small, fill=(196, 30, 26), anchor="mm")
		for r in range(4):
			length = 70 - r * 8 - rng.integers(0, 12)
			d.rectangle([cx - length // 2, 290 + r * 18, cx + length // 2, 296 + r * 18], fill=(70, 66, 62))
	for r in range(3):
		d.rectangle([x0 + 40, 400 + r * 20, x1 - 40 - rng.integers(0, 120), 406 + r * 20], fill=(70, 66, 62))
	img = img.filter(ImageFilter.GaussianBlur(0.6))
	arr = np.asarray(img).astype(np.float32) / 255.0
	# Scuffs and fading on the sheet's edges, dust.
	noise = smooth_noise(rng, (h, w), 30)
	arr *= (1.0 - 0.06 * np.clip(noise * 0.5 + 0.5, 0, 1))[..., None]
	save_rgb("extinguisher_label.png", arr)


def gauge_dial():
	size = 256
	img = Image.new("RGB", (size, size), (236, 234, 226))
	d = ImageDraw.Draw(img)
	c = size / 2
	# Red, green, red arcs: the needle stands in the green.
	for a0, a1, col in ((200, 250, (200, 30, 26)), (250, 290, (40, 150, 60)), (290, 340, (200, 30, 26))):
		d.arc([c - 100, c - 100, c + 100, c + 100], a0, a1, fill=col, width=22)
	ang = math.radians(268)
	d.line([(c, c), (c + math.cos(ang) * 95, c + math.sin(ang) * 95)], fill=(20, 20, 20), width=6)
	d.ellipse([c - 10, c - 10, c + 10, c + 10], fill=(20, 20, 20))
	save_rgb("gauge_dial.png", np.asarray(img.filter(ImageFilter.GaussianBlur(0.5))).astype(np.float32) / 255.0)


def alarm_face():
	"""The fire alarm's front: 512 x 640 for 0.2 x 0.25 m; a round push button sits in the middle (geometry)."""
	w, h = 512, 640
	rng = np.random.default_rng(253_500)
	img = Image.new("RGB", (w, h), (176, 22, 20))
	d = ImageDraw.Draw(img)
	big = ImageFont.truetype(str(FONT_BOLD), 70)
	small = ImageFont.truetype(str(FONT_BOLD), 34)
	d.text((w // 2, 90), "BÁO CHÁY", font=big, fill=(246, 240, 232), anchor="mm")
	# The button's ring (the button is geometry over it) and a short instruction under it.
	d.ellipse([w // 2 - 150, h // 2 - 150 + 20, w // 2 + 150, h // 2 + 150 + 20], outline=(246, 240, 232), width=10)
	d.text((w // 2, h - 80), "NHẤN MẠNH", font=small, fill=(246, 240, 232), anchor="mm")
	img = img.filter(ImageFilter.GaussianBlur(0.7))
	arr = np.asarray(img).astype(np.float32) / 255.0
	noise = smooth_noise(rng, (h, w), 40)
	arr *= (1.0 - 0.08 * np.clip(noise * 0.5 + 0.5, 0, 1))[..., None]
	save_rgb("alarm_face.png", arr)


if __name__ == "__main__":
	jobs = {"wall": hall_wall, "floor": hall_floor, "ceiling": hall_ceiling, "label": extinguisher_label,
		"gauge": gauge_dial, "alarm": alarm_face}
	for name in sys.argv[1:] or list(jobs):
		jobs[name]()
		print("T253_TEX", name)
