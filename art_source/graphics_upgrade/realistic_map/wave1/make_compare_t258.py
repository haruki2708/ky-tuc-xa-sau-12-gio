"""T-258: before/after sheet of the main stairwell's east wall on floor 4, from previews/floor4_rest/t258_before_<view>.jpg
and t258_after_<view>.jpg (capture_t258.gd, the same camera, chapter 3): compare_t258.jpg.
Run: python -B art_source/graphics_upgrade/realistic_map/wave1/make_compare_t258.py
"""
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PREVIEWS = HERE.parent / "previews" / "floor4_rest"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
VIEWS = [
	("w1_sinks", "nhà vệ sinh: máng rửa và gương"),
	("w2_mirror", "gương, nhìn gần"),
	("w3_trough", "máng rửa"),
	("w4_wall_top", "đỉnh tường tây, sát trần"),
	("s1_landing4", "chiếu nghỉ tầng 4 cầu thang chính"),
	("s2_flight4b", "từ vế 4B nhìn lên tường"),
	("s3_wall_end", "đầu tường, chỗ chiếu nghỉ gặp hành lang"),
	("o1_behind_b", "từ ngoài, sau nhà B"),
]
WIDTH = 800


def label(img, text, size=22):
	draw = ImageDraw.Draw(img)
	font = ImageFont.truetype(str(FONT), size)
	box = draw.textbbox((0, 0), text, font=font)
	draw.rectangle([0, 0, box[2] + 24, box[3] + 14], fill=(0, 0, 0))
	draw.text((12, 5), text, font=font, fill=(240, 240, 235))


def tile(path, text):
	img = Image.open(path).convert("RGB")
	img = img.resize((WIDTH, WIDTH * img.height // img.width))
	label(img, text)
	return img


def main():
	rows = []
	for view, caption in VIEWS:
		before = tile(PREVIEWS / f"t258_before_{view}.jpg", f"Trước: {caption}")
		after = tile(PREVIEWS / f"t258_after_{view}.jpg", f"Sau (T-258): {caption}")
		row = Image.new("RGB", (WIDTH * 2 + 8, before.height), (20, 20, 20))
		row.paste(before, (0, 0))
		row.paste(after, (WIDTH + 8, 0))
		rows.append(row)
	sheet = Image.new("RGB", (rows[0].width, sum(r.height + 8 for r in rows) + 56), (20, 20, 20))
	label(sheet, "T-258: tường giếng thang chính ở tầng 4, chương 3", 32)
	y = 56
	for row in rows:
		sheet.paste(row, (0, y))
		y += row.height + 8
	out = PREVIEWS / "compare_t258.jpg"
	sheet.save(out, quality=86)
	print("wrote", out)


main()
