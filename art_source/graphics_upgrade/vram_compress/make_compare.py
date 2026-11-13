"""T-257: before/after sheets for the VRAM texture compression, from previews/ (before_* and after_* of the same camera,
taken in the real chapter 1 and 3 scenes). One sheet per chapter (whole frames, scaled) and one sheet of 1:1 close-ups,
where compression artefacts would show first. Also prints how much each pair differs (PSNR; the only large differences
are the ceiling and standing fans, which turn between the two passes).
Run: python -B art_source/graphics_upgrade/vram_compress/make_compare.py
"""
import math
from pathlib import Path
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFont

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
PREVIEWS = ROOT / "art_source/graphics_upgrade/vram_compress/previews"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
CAPTIONS = {
	"ch1": "Chương 1: phòng 407, hành lang, bàn trực, phòng 402",
	"ch3": "Chương 3: cầu thang, hành lang tầng 3, sảnh, phòng quản lý",
}
CLOSE_UPS = ["ch1_01_bunk_a_bedding", "ch1_08_blanket_close", "ch1_07_floor_and_wall", "ch1_12_wall_close",
	"ch1_02_lockers", "ch1_06_bathroom", "ch1_03_phuc_desk", "ch1_10_duty_desk"]
CROP = (700, 400)


def label(img, text, size=34):
	draw = ImageDraw.Draw(img)
	font = ImageFont.truetype(str(FONT), size)
	box = draw.textbbox((0, 0), text, font=font)
	draw.rectangle([0, 0, box[2] + 24, box[3] + 16], fill=(0, 0, 0))
	draw.text((12, 6), text, font=font, fill=(240, 240, 235))


def side_by_side(a, b, size):
	label(a, "Trước (không nén)", size)
	label(b, "Sau (nén VRAM)", size)
	out = Image.new("RGB", (a.width * 2 + 8, a.height), (20, 20, 20))
	out.paste(a, (0, 0))
	out.paste(b, (a.width + 8, 0))
	return out


def stack(rows, caption, path):
	height = sum(r.height + 8 for r in rows) + 60
	sheet = Image.new("RGB", (rows[0].width, height), (20, 20, 20))
	label(sheet, caption, 40)
	y = 60
	for r in rows:
		sheet.paste(r, (0, y))
		y += r.height + 8
	sheet.save(path, quality=88)


def psnr(a, b):
	d = ImageChops.difference(a, b).convert("L")
	mse = sum(v * v * c for v, c in enumerate(d.histogram())) / (d.width * d.height)
	return 99.0 if mse == 0 else 10 * math.log10(255 * 255 / mse)


def load(name):
	return (Image.open(PREVIEWS / f"before_{name}.jpg").convert("RGB"),
		Image.open(PREVIEWS / f"after_{name}.jpg").convert("RGB"))


def main():
	names = sorted(p.stem.removeprefix("after_") for p in PREVIEWS.glob("after_*.jpg"))
	for chapter in CAPTIONS:
		rows = []
		for name in (n for n in names if n.startswith(chapter + "_")):
			a, b = load(name)
			print(f"T257_PAIR {name} PSNR {psnr(a, b):.1f} dB")
			rows.append(side_by_side(a.resize((960, 540)), b.resize((960, 540)), 26))
		stack(rows, CAPTIONS[chapter], PREVIEWS / f"compare_{chapter}.jpg")
		print("T257_COMPARE", chapter, len(rows))
	rows = []
	for name in CLOSE_UPS:
		a, b = load(name)
		box = ((a.width - CROP[0]) // 2, (a.height - CROP[1]) // 2, (a.width + CROP[0]) // 2, (a.height + CROP[1]) // 2)
		rows.append(side_by_side(a.crop(box), b.crop(box), 22))
	stack(rows, "Cận cảnh 1:1 (giữa khung hình 1080p)", PREVIEWS / "compare_closeup.jpg")
	print("T257_COMPARE closeup", len(rows))


if __name__ == "__main__":
	main()
