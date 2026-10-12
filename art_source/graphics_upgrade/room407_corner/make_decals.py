"""Derive a reusable grime alpha from the CC0 plaster photograph; no AI images."""
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[3]
DEST = ROOT / "game/assets/models/graphics_pilot/room407_corner/textures"
source = Image.open(DEST / "plastered_wall_04_color.jpg").resize((512, 512)).convert("RGB")
grain = np.asarray(source).astype(float) / 255
y, x = np.mgrid[0:512, 0:512] / 511
mask = np.clip((1 - ((x - .5) / .48) ** 2) * ((1-y) ** .7)
               * (.55 + .3*np.sin(x*28+y*7) + .15*np.sin(x*113)), 0, 1)
mask *= np.clip(np.minimum(x, 1-x)*12, 0, 1) * np.clip(np.minimum(y, 1-y)*14, 0, 1)
rgb = np.clip(grain * np.array([.45, .35, .20]) * 255, 0, 255).astype("uint8")
Image.fromarray(np.dstack([rgb, (mask*130).astype("uint8")])).save(DEST / "water_stain.png")
print("RESULT: corner CC0-derived stain 512x512 PASS")
