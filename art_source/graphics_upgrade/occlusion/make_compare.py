"""T-260: compare the occlusion-culling stills (previews/off_* and on_* of the same camera, time stopped, so any
difference is something culled that should have been drawn) and the walk frames (build/haru/t260_walk/, the same path
walked off then on), and write the owner's sheets: previews/compare_ch1.jpg, compare_ch3.jpg (off left, on right).
Prints, per pair, the share of pixels that differ by more than 24 (of 255) and where.
Run: python -B art_source/graphics_upgrade/occlusion/make_compare.py
"""
from pathlib import Path
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFont

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
PREVIEWS = ROOT / "art_source/graphics_upgrade/occlusion/previews"
WALK = ROOT / "build/haru/t260_walk"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
CAPTIONS = {"ch1": "Chương 1: tầng 4 (trái tắt, phải bật occlusion culling)",
	"ch3": "Chương 3: tầng 4, nhà B, khuôn viên (trái tắt, phải bật occlusion culling)"}
THRESHOLD = 24


def label(img, text, size=34):
	draw = ImageDraw.Draw(img)
	font = ImageFont.truetype(str(FONT), size)
	box = draw.textbbox((0, 0), text, font=font)
	draw.rectangle([0, 0, box[2] + 24, box[3] + 16], fill=(0, 0, 0))
	draw.text((12, 6), text, font=font, fill=(240, 240, 235))


def differs(a, b):
	"""Share (%) of pixels differing by more than THRESHOLD, and the box around them (None when none)."""
	d = ImageChops.difference(a, b).convert("L").point(lambda v: 255 if v > THRESHOLD else 0)
	return d.histogram()[255] * 100.0 / (d.width * d.height), d.getbbox()


def main():
	worst = 0.0
	for chapter in CAPTIONS:
		rows = []
		for off in sorted(PREVIEWS.glob(f"off_{chapter}_*.jpg")):
			on = off.with_name(off.name.replace("off_", "on_", 1))
			if not on.exists():
				continue
			a, b = Image.open(off).convert("RGB"), Image.open(on).convert("RGB")
			share, box = differs(a, b)
			worst = max(worst, share)
			print(f"T260_STILL {off.stem[4:]:40s} differ {share:6.3f}%  box {box}")
			a, b = a.resize((960, 540)), b.resize((960, 540))
			label(a, "Tắt: " + off.stem[8:], 22)
			label(b, "Bật", 22)
			row = Image.new("RGB", (1928, 540), (20, 20, 20))
			row.paste(a, (0, 0))
			row.paste(b, (968, 0))
			rows.append(row)
		if not rows:
			continue
		sheet = Image.new("RGB", (1928, sum(r.height + 8 for r in rows) + 60), (20, 20, 20))
		label(sheet, CAPTIONS[chapter], 40)
		y = 60
		for r in rows:
			sheet.paste(r, (0, y))
			y += r.height + 8
		sheet.save(PREVIEWS / f"compare_{chapter}.jpg", quality=86)
		print("T260_COMPARE", chapter, len(rows))
	walks = {}
	for off in sorted(WALK.glob("off_*.jpg")):
		on = off.with_name(off.name.replace("off_", "on_", 1))
		if on.exists():
			share, box = differs(Image.open(off).convert("RGB"), Image.open(on).convert("RGB"))
			name = off.stem[4:].rsplit("_", 1)[0]
			best = walks.get(name, (0, 0.0, None, ""))
			walks[name] = (best[0] + 1, max(best[1], share), box if share > best[1] else best[2],
				off.stem if share > best[1] else best[3])
	for name, (count, share, box, frame) in sorted(walks.items()):
		worst = max(worst, share)
		print(f"T260_WALK {name:40s} frames {count:4d}  worst differ {share:6.3f}% at {frame} box {box}")
	print(f"T260_WORST {worst:.3f}%")


if __name__ == "__main__":
	main()
