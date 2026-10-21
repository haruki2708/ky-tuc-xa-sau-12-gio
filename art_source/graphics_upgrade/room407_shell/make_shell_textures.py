"""Derived textures of the T-222 shell (all from the CC0 scans or drawn here; no AI images).
  wall_peel_*        peeling_painted_wall repainted from red to the room's cream (the exposed plaster stays)
  frame_green_*      distressed_painted_planks repainted the dark green of the room door; frame_cream_* for the
                     bathroom door frame (normal/arm maps are the scan's)
  noise.png          tileable RGBA noise for the shell shader (R fine, G medium, B large, A cells)
  aluminium_*        brushed, oxidised aluminium of the balcony door frame (512, tiling)
  granite_*          speckled threshold stone (512, tiling)
  cobweb.png         a corner cobweb (alpha)
  night_sky.png      equirectangular night: town glow at the horizon, thin cloud, the moon, a few stars
  window_lit.png, window_dark.png   windows of the block across the courtyard
Run: python -B make_shell_textures.py   (numpy, Pillow)
"""
import colorsys
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SCANS = HERE / "textures"
CORNER = HERE.parent / "room407_corner" / "textures"
OUT = ROOT / "game/assets/textures/graphics_pilot/room407_shell"
RNG = np.random.default_rng(407)


def load(path):
    return np.asarray(Image.open(path).convert("RGB"), np.float64) / 255.0


def save(arr, name, mode="RGB", quality=None):
    img = Image.fromarray((np.clip(arr, 0, 1) * 255 + 0.5).astype(np.uint8), mode)
    path = OUT / name
    if path.suffix == ".jpg":
        img.save(path, quality=quality or 92, optimize=True)
    else:
        img.save(path, optimize=True)
    print("TEX", name, img.size, flush=True)


def tile_noise(size, power, seed):
    """Tileable noise from filtered white noise (FFT), normalised 0..1."""
    rng = np.random.default_rng(seed)
    white = rng.normal(size=(size, size))
    fy = np.fft.fftfreq(size)[:, None]
    fx = np.fft.fftfreq(size)[None, :]
    f = np.sqrt(fx * fx + fy * fy)
    f[0, 0] = 1
    out = np.real(np.fft.ifft2(np.fft.fft2(white) / f ** power))
    out -= out.min()
    return out / out.max()


def hsv_paint(rgb, paint_mask, target_rgb, keep_value=0.85):
    """Repaint where paint_mask: take the target colour, keep the scan's light/dark variation."""
    lum = rgb.mean(axis=2, keepdims=True)
    mean = (lum[..., 0] * paint_mask).sum() / max(paint_mask.sum(), 1)
    shade = (lum / mean) ** keep_value
    painted = np.asarray(target_rgb)[None, None, :] * shade
    m = paint_mask[..., None]
    return rgb * (1 - m) + painted * m


def saturation(rgb):
    mx, mn = rgb.max(axis=2), rgb.min(axis=2)
    return (mx - mn) / np.maximum(mx, 1e-4)


def wall_peel():
    rgb = load(SCANS / "peeling_painted_wall_color.jpg")
    cream = load(CORNER / "painted_plaster_wall_cream_color.jpg").reshape(-1, 3).mean(axis=0)
    red = (rgb[..., 0] - rgb[..., 2])
    paint = np.clip((red - 0.05) / 0.10, 0, 1)
    paint = np.asarray(Image.fromarray((paint * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.8)), np.float64) / 255
    out = hsv_paint(rgb, paint, cream * 1.04, 0.8)
    # Exposed plaster a touch warmer and darker than the scan (old lime under cream paint).
    bare = 1 - paint
    out = out * (1 - bare[..., None] * 0.12) + bare[..., None] * np.array([0.03, 0.02, 0.0])
    save(out, "wall_peel_color.jpg")


def frames():
    rgb = load(SCANS / "distressed_painted_planks_color.jpg")
    sat = saturation(rgb)
    hue = np.asarray(Image.fromarray((rgb * 255).astype(np.uint8)).convert("HSV"), np.float64)[..., 0] / 255
    chips = np.clip((sat - 0.28) / 0.12, 0, 1) * ((hue < 0.12) | (hue > 0.9))  # orange/rust: bare wood
    paint = 1 - chips
    for name, colour in (("frame_green_color.jpg", (0.13, 0.24, 0.17)), ("frame_cream_color.jpg", (0.80, 0.77, 0.66))):
        out = hsv_paint(rgb, paint, colour, 0.9)
        wood = rgb * np.array([0.95, 0.78, 0.62])
        out = out * (1 - chips[..., None]) + wood * chips[..., None]
        save(out, name)


def noise():
    n = np.stack([tile_noise(512, 0.6, 1), tile_noise(512, 1.1, 2), tile_noise(512, 1.6, 3)], axis=-1)
    # Cells: distance to jittered points (tiling), for flakes and blisters.
    pts = RNG.random((60, 2)) * 512
    yy, xx = np.mgrid[0:512, 0:512]
    d = np.full((512, 512), 1e9)
    for px, py in pts:
        for ox in (-512, 0, 512):
            for oy in (-512, 0, 512):
                d = np.minimum(d, np.hypot(xx - px - ox, yy - py - oy))
    cells = d / d.max()
    save(np.concatenate([n, cells[..., None]], axis=-1), "noise.png", "RGBA")


def aluminium():
    s = 512
    brushed = np.tile(np.asarray(Image.fromarray((tile_noise(s, 0.8, 12) * 255).astype(np.uint8)).resize((s, 1), Image.BILINEAR), np.float64) / 255, (s, 1))
    spots = tile_noise(s, 0.9, 13)
    oxid = np.clip((spots - 0.62) / 0.08, 0, 1)
    grime = tile_noise(s, 1.6, 14)
    base = 0.55 + 0.08 * (brushed - 0.5) - 0.12 * (grime - 0.5)
    rgb = np.stack([base * 0.98, base, base * 1.02], -1)
    rgb = rgb * (1 - oxid[..., None] * 0.25) + oxid[..., None] * np.array([0.78, 0.78, 0.74]) * 0.25
    save(rgb, "aluminium_color.jpg")
    rough = np.clip(0.38 + 0.15 * (grime - 0.5) + 0.35 * oxid + 0.05 * (brushed - 0.5), 0, 1)
    save(np.stack([np.ones((s, s)), rough, np.full((s, s), 0.9)], -1), "aluminium_arm.jpg")


def granite():
    s = 512
    base = tile_noise(s, 1.2, 21)
    speck = tile_noise(s, 0.1, 22)
    dark = (speck > 0.66).astype(float)
    light = (speck < 0.30).astype(float)
    g = 0.30 + 0.08 * (base - 0.5) - 0.18 * dark + 0.25 * light
    rgb = np.stack([g * 1.02, g, g * 0.97], -1)
    save(rgb, "granite_color.jpg")
    save(np.stack([np.ones((s, s)), 0.35 + 0.2 * dark, np.zeros((s, s))], -1), "granite_arm.jpg")


def cobweb():
    s = 512
    img = np.zeros((s, s))
    yy, xx = np.mgrid[0:s, 0:s] / s
    # Corner at (0, 0): radial threads and sagging spiral threads.
    r, a = np.hypot(xx, yy), np.arctan2(yy, xx)
    for k in range(9):
        ang = math.pi / 2 * (k + RNG.uniform(-0.3, 0.3)) / 8
        img = np.maximum(img, np.clip(1 - np.abs(np.sin(a - ang)) * r * s / 1.2, 0, 1) * (r < 0.95))
    for k in range(1, 14):
        rad = k * 0.065 + RNG.uniform(-0.01, 0.01)
        sag = rad * (1 + 0.12 * np.sin(a * 2) ** 2) - 0.03 * np.sin(a * 16) ** 2 * rad
        img = np.maximum(img, np.clip(1 - np.abs(r - sag) * s / 1.1, 0, 1) * 0.8 * (r < 0.95))
    dust = tile_noise(s, 1.3, 31)
    alpha = np.clip(img * (0.45 + 0.4 * dust) + 0.18 * np.clip(1 - r / 0.35, 0, 1) * dust, 0, 1)
    alpha *= np.clip((0.97 - r) / 0.1, 0, 1)
    rgb = np.full((s, s, 3), 0.74)
    save(np.concatenate([rgb, alpha[..., None]], -1), "cobweb.png", "RGBA")


def night_sky():
    w, h = 2048, 1024
    yy, xx = np.mgrid[0:h, 0:w]
    elev = (0.5 - (yy + 0.5) / h) * math.pi  # +pi/2 up
    azim = (xx + 0.5) / w * 2 * math.pi
    up = np.clip(np.sin(elev), -1, 1)
    # Stored bright (8-bit banding); the game draws it at a fraction (Room407Furnish OUTSIDE_LOOKS).
    zen = np.array([0.025, 0.04, 0.085])
    hor = np.array([0.30, 0.22, 0.16])  # sodium town glow under low cloud
    t = np.clip(up, 0, 1) ** 0.45
    sky = hor[None, None] * (1 - t[..., None]) + zen[None, None] * t[..., None]
    sky[up < 0] = hor * 0.6
    # Thin cloud lit from below by the town.
    cloud = tile_noise(1024, 1.3, 41)
    cloud = np.asarray(Image.fromarray((cloud * 255).astype(np.uint8)).resize((w, h)), np.float64) / 255
    cover = np.clip((cloud - 0.45) / 0.3, 0, 1) * np.clip(up * 4, 0, 1) * np.clip(1.2 - up, 0, 1)
    sky = sky * (1 - 0.5 * cover[..., None]) + cover[..., None] * np.array([0.24, 0.2, 0.18]) * (1 - t[..., None] * 0.6)
    # Azimuth 0 looks straight out of the balcony (-z), +x to the right: the moon is a little right, 30 degrees up.
    m_az, m_el = math.radians(20), math.radians(30)
    cos_d = np.sin(elev) * math.sin(m_el) + np.cos(elev) * math.cos(m_el) * np.cos(azim - m_az)
    d = np.degrees(np.arccos(np.clip(cos_d, -1, 1)))
    disc = np.clip((1.3 - d) / 0.08, 0, 1)
    maria = tile_noise(256, 1.4, 42)[(yy % 256), (xx % 256)]
    halo = 0.35 * np.exp(-d / 3.0) + 0.15 * np.exp(-d / 14)
    sky += halo[..., None] * np.array([0.55, 0.62, 0.75]) * (1 - 0.6 * cover[..., None])
    sky = sky * (1 - disc[..., None]) + disc[..., None] * (np.array([0.92, 0.93, 0.88]) * (0.8 + 0.2 * maria[..., None]))
    # A few faint stars where the cloud is thin.
    stars = (RNG.random((h, w)) > 0.9993) & (up > 0.15) & (cover < 0.2)
    sky[stars] += 0.5 * RNG.random(stars.sum())[:, None]
    save(sky, "night_sky.png")


def facade():
    """1k, yellow-washed render for the blocks outside (far away: colour only)."""
    rgb = load(SCANS / "plastered_wall_02_color.jpg")
    img = Image.fromarray((np.clip(rgb * np.array([1.0, 0.86, 0.6]), 0, 1) * 255).astype(np.uint8)).resize((1024, 1024))
    save(np.asarray(img, np.float64) / 255, "facade_color.jpg")


def windows():
    s = 256
    yy, xx = np.mgrid[0:s, 0:s] / s
    frame = ((xx < 0.04) | (xx > 0.96) | (yy < 0.04) | (yy > 0.96) | (np.abs(xx - 0.5) < 0.015)).astype(float)
    curtain_fold = 0.5 + 0.5 * np.sin(xx * 46 + np.sin(yy * 9) * 0.6)
    lit = np.array([1.0, 0.72, 0.40])[None, None] * (0.55 + 0.35 * curtain_fold[..., None]) * (0.7 + 0.3 * (1 - yy[..., None]))
    lit = lit * (1 - frame[..., None]) + frame[..., None] * 0.04
    save(lit, "window_lit.png")
    refl = 0.03 + 0.03 * (1 - yy) + 0.015 * np.sin(xx * 9 + yy * 3)
    dark = np.stack([refl * 0.8, refl * 0.9, refl * 1.1], -1) * (1 - frame[..., None]) + frame[..., None] * 0.05
    save(dark, "window_dark.png")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    wall_peel()
    frames()
    noise()
    aluminium()
    granite()
    cobweb()
    night_sky()
    facade()
    windows()
    print("RESULT: shell textures PASS")


if __name__ == "__main__":
    main()
