"""Derive a reusable grime alpha from the CC0 plaster photograph; no AI images."""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[3]
SOURCE = Path(__file__).resolve().parent / "textures"
DEST = ROOT / "game/assets/models/graphics_pilot/room407_corner/textures"
source = Image.open(SOURCE / "plastered_wall_04_color.jpg").resize((512, 512)).convert("RGB")
grain = np.asarray(source).astype(float) / 255
y, x = np.mgrid[0:512, 0:512] / 511
mask = np.clip((1 - ((x - .5) / .48) ** 2) * ((1-y) ** .7)
               * (.55 + .3*np.sin(x*28+y*7) + .15*np.sin(x*113)), 0, 1)
mask *= np.clip(np.minimum(x, 1-x)*12, 0, 1) * np.clip(np.minimum(y, 1-y)*14, 0, 1)
rgb = np.clip(grain * np.array([.45, .35, .20]) * 255, 0, 255).astype("uint8")
Image.fromarray(np.dstack([rgb, (mask*130).astype("uint8")])).save(DEST / "water_stain.png")
print("RESULT: corner CC0-derived stain 512x512 PASS")

# Cream wall paint like the current room: warm the CC0 painted plaster photo, keep its stains.
paint = np.asarray(Image.open(SOURCE / "painted_plaster_wall_color.jpg").convert("RGB")).astype(float)
grey = paint.mean(axis=2, keepdims=True)
cream = np.clip(grey * np.array([1.02, 0.96, 0.80]) + (paint - grey) * 0.6, 0, 255).astype("uint8")
Image.fromarray(cream).save(SOURCE / "painted_plaster_wall_cream_color.jpg", quality=92)
print("RESULT: cream wall paint variant PASS")

# colormass scans are 1024x1017 / 1024x1026; GPU block compression wants square power-of-two maps.
for asset in ("rough_linen", "polar_fleece"):
    for suffix in ("color", "normal", "arm"):
        image = Image.open(SOURCE / f"{asset}_{suffix}.jpg").convert("RGB")
        image.resize((1024, 1024), Image.LANCZOS).save(SOURCE / f"{asset}_square_{suffix}.jpg", quality=92)
print("RESULT: square 1024 fabric maps PASS")
