"""T-267 (D-188 point 5) wave 10: the CCTV corridor's own small masks, drawn here (numpy + Pillow, no downloaded image,
no AI image), in place of wave 2's three 4096 px masks (uncompressed, ~60 MB of video memory in chapters 1-2, where
building B is not loaded). One corridor serves all five rooms (cctv_hall.glb, Room<n> local metres: x -0.85..4.85,
z 0.1 (room wall) .. 2.55 (outer edge), the doorway x 2.0..2.9, the batten over x 2.8, z 1.25). Same channels as wave 2
(room407_shell.gdshader on UV2), at most 512 px, imported VRAM compressed (make_wave10_materials.py):
  mask_cctv_hall_wall.png     512 x 256  kind 0: R paint loss, G grime, B water stain, A mould. u along the corridor
                                         (the end walls use its first 2.45 m), v up the wall (image top = ceiling):
                                         the foot of the wall, hand marks and kicks by both jambs, the rubbed band where
                                         people lean, one leak from the ceiling, damp in the corners.
  mask_cctv_hall_floor.png    512 x 256  kind 1: G grime, B wet, A wear. u along, v across (image top = the open side):
                                         dirt at the wall and the curb, the path down the corridor and into the door,
                                         rain blown in under the rail.
  mask_cctv_hall_ceiling.png  256 x 128  kind 0: soot over the batten, damp along the open edge, one leak.
Run: python -B art_source/graphics_upgrade/realistic_map/wave10/make_wave10_textures.py
"""
from pathlib import Path
import sys

import numpy as np
from PIL import Image

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
OUT = ROOT / "game/assets/textures/graphics_pilot/realistic_map/wave10"
HX0, HX1, HZ0, HZ_OUT, CEIL = -0.85, 4.85, 0.1, 2.55, 3.0
DOOR = (2.0, 2.9)
CURB = 2.355
LAMP = (2.8, 1.25)


def smooth_noise(rng, shape, scale):
	"""Noise of unit variance low-passed at about `scale` pixels (wave 2's)."""
	h, w = shape
	white = rng.normal(0.0, 1.0, (h, w))
	fy = np.fft.fftfreq(h)[:, None]
	fx = np.fft.rfftfreq(w)[None, :]
	lowpass = np.exp(-((fy * scale) ** 2 + (fx * scale) ** 2) * 18.0)
	out = np.fft.irfft2(np.fft.rfft2(white) * lowpass, s=(h, w))
	return out / max(out.std(), 1e-9)


def blob(x, y, cx, cy, rx, ry):
	return np.exp(-(((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2))


def save_rgba(name, channels):
	OUT.mkdir(parents=True, exist_ok=True)
	rgba = np.stack([np.clip(c, 0.0, 1.0) for c in channels], axis=2)
	Image.fromarray((rgba * 255.0 + 0.5).astype(np.uint8), "RGBA").save(OUT / name, optimize=True)
	print("T267_TEX", name, rgba.shape[1], "x", rgba.shape[0])


def wall():
	w, h = 512, 256
	rng = np.random.default_rng(267_100)
	x = np.broadcast_to(np.linspace(HX0, HX1, w)[None, :], (h, w))
	y = np.broadcast_to(np.linspace(CEIL, 0.0, h)[:, None], (h, w))
	fine, mid, big = smooth_noise(rng, (h, w), 3), smooth_noise(rng, (h, w), 14), smooth_noise(rng, (h, w), 70)
	grime = np.clip(1.0 - y / 0.06, 0, 1) ** 1.4 * 0.8 + np.clip(1.0 - y / 0.18, 0, 1) * 0.3
	grime += np.exp(-((y - 1.05) / 0.22) ** 2) * np.clip(0.25 + mid * 0.2, 0, 0.45) * 0.5
	grime += np.clip(big * 0.07 + 0.06, 0, 0.18) + fine * 0.025
	for side, edge in ((-1, DOOR[0] - 0.08), (1, DOOR[1] + 0.08)):
		grime += blob(x, y, edge + side * 0.08, 1.15, 0.1, 0.32) * 0.34
		grime += blob(x, y, edge + side * 0.05, 0.12, 0.16, 0.12) * 0.35
	grime += blob(x, y, sum(DOOR) / 2, 2.85, 0.75, 0.08) * 0.18
	for kx in (0.35, 1.3, 3.6, 4.3):
		grime += blob(x, y, kx, rng.uniform(0.1, 0.3), rng.uniform(0.04, 0.09), rng.uniform(0.03, 0.08)) * rng.uniform(0.3, 0.55)
	# One leak from the ceiling over the west part, a tide line, mould where it starts; damp in both corners.
	sx, width, length = 0.9, 0.22, 1.1
	wobble = sx + np.sin(y * 7.0 + sx) * 0.03
	body = np.exp(-((x - wobble) / width) ** 2 * 2.0) * np.clip((y - (CEIL - length)) / 0.25, 0, 1)
	tide = np.exp(-((y - (CEIL - length)) / 0.03) ** 2) * np.exp(-((x - wobble) / (width * 1.2)) ** 2)
	stain = body * (0.5 + 0.3 * np.clip(fine * 0.5 + 0.5, 0, 1)) + tide * 0.5
	mould = blob(x, y, sx, CEIL - 0.05, width * 0.8, 0.12) * 0.55
	for ex in (HX0, HX1):
		mould = np.maximum(mould, blob(x, y, ex, 0.05, 0.4, 0.15) * 0.6)
	peel = np.clip((mid * 0.6 + big * 0.55 + fine * 0.2 - 1.25) * 0.9, 0, 1) * (0.3 + 0.7 * np.clip((y - 1.2) / 1.2, 0, 1))
	peel = np.maximum(peel, np.clip(stain - 0.45, 0, 1) * 1.2)
	for ex in (HX0, HX1):
		peel = np.maximum(peel, blob(x, y, ex, 0.4, 0.35, 0.35) * 0.55 * np.clip(0.6 + mid * 0.4, 0, 1))
	save_rgba("mask_cctv_hall_wall.png", (peel, grime, stain, mould))


def floor():
	w, h = 512, 256
	rng = np.random.default_rng(267_200)
	x = np.broadcast_to(np.linspace(HX0, HX1, w)[None, :], (h, w))
	z = np.broadcast_to(np.linspace(HZ_OUT, HZ0, h)[:, None], (h, w))
	fine, mid, big = smooth_noise(rng, (h, w), 3), smooth_noise(rng, (h, w), 16), smooth_noise(rng, (h, w), 80)
	grime = np.clip(1.0 - (z - HZ0) / 0.22, 0, 1) ** 1.6 * 0.75 + np.clip(1.0 - (CURB - z) / 0.3, 0, 1) ** 1.4 * 0.7
	grime += np.clip(big * 0.08 + 0.06, 0, 0.2) + fine * 0.03
	for ex in (HX0, HX1):
		grime += blob(x, z, ex, 1.3, 0.5, 1.4) * 0.18
	lane = 1.3 + np.sin(x * 0.9) * 0.12
	wear = np.exp(-((z - lane) / 0.55) ** 2) * np.clip(0.55 + mid * 0.2, 0, 1)
	door = sum(DOOR) / 2
	wear += blob(x, z, door, 0.6, 0.5, 0.6) * 0.45
	grime += blob(x, z, door, 0.3, 0.6, 0.2) * 0.25
	wet = np.clip(1.0 - (CURB - z) / 0.25, 0, 1) * np.clip(mid * 0.5 + 0.3, 0, 1) * 0.6
	wet = np.maximum(wet, blob(x, z, 0.4, 1.7, 0.45, 0.3) * np.clip(0.75 + fine * 0.25, 0, 1) * 0.45)
	wet = np.clip((wet - 0.08) * 1.2, 0, 1)
	save_rgba("mask_cctv_hall_floor.png", (np.zeros_like(x), grime, wet, wear))


def ceiling():
	w, h = 256, 128
	rng = np.random.default_rng(267_300)
	x = np.broadcast_to(np.linspace(HX0, HX1, w)[None, :], (h, w))
	z = np.broadcast_to(np.linspace(HZ_OUT, HZ0, h)[:, None], (h, w))
	fine, mid, big = smooth_noise(rng, (h, w), 2), smooth_noise(rng, (h, w), 8), smooth_noise(rng, (h, w), 40)
	grime = np.clip(big * 0.08 + 0.08, 0, 0.2) + fine * 0.02
	grime += blob(x, z, LAMP[0], LAMP[1], 1.1, 0.45) * 0.45
	damp = np.clip(1.0 - (HZ_OUT - z) / 0.6, 0, 1) * np.clip(0.4 + mid * 0.35, 0, 1)
	grime += damp * 0.35
	stain = damp * 0.45
	mould = np.clip(1.0 - (HZ_OUT - z) / 0.2, 0, 1) * np.clip(0.3 + big * 0.3, 0, 1) * 0.5
	d = np.hypot((x - 0.6) / 1.0, (z - 0.9) / 0.8)
	r = 0.4
	stain = np.maximum(stain, np.clip(1.0 - d / r, 0, 1) ** 0.5 * 0.55 + np.exp(-((d - r) / 0.04) ** 2) * 0.5)
	peel = np.clip(stain - 0.5, 0, 1) * 1.3 + np.clip(mid * 0.5 + big * 0.5 - 1.5, 0, 1) * 0.6
	save_rgba("mask_cctv_hall_ceiling.png", (peel, grime, stain, mould))


if __name__ == "__main__":
	wall()
	floor()
	ceiling()
