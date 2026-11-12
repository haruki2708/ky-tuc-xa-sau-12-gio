"""T-250: before/after sheets from previews/wave1/ (before_* and after_* of the same camera), one per area, and an
overview for the owner. Run: python -B art_source/graphics_upgrade/realistic_map/wave1/make_compare.py
"""
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
PREVIEWS = ROOT / "art_source/graphics_upgrade/realistic_map/previews/wave1"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
CAPTIONS = {
	"a01": "A01 bàn trực tầng 4", "a07": "A07 cầu thang thoát hiểm, cửa, đoạn sập", "a06": "A06 cầu thang chính",
}


def label(img, text, size=34):
	draw = ImageDraw.Draw(img)
	font = ImageFont.truetype(str(FONT), size)
	box = draw.textbbox((0, 0), text, font=font)
	draw.rectangle([0, 0, box[2] + 24, box[3] + 16], fill=(0, 0, 0))
	draw.text((12, 6), text, font=font, fill=(240, 240, 235))


def pair(before, after, width=960):
	a = Image.open(before).convert("RGB").resize((width, width * 9 // 16))
	b = Image.open(after).convert("RGB").resize((width, width * 9 // 16))
	label(a, "Trước (PS1)", 26)
	label(b, "Sau (T-250)", 26)
	out = Image.new("RGB", (width * 2 + 8, a.height), (20, 20, 20))
	out.paste(a, (0, 0))
	out.paste(b, (width + 8, 0))
	return out


def main():
	rows = {}
	for after in sorted(PREVIEWS.glob("after_*.jpg")):
		before = after.with_name(after.name.replace("after_", "before_", 1))
		area = after.stem.split("_")[2]
		if before.exists():
			rows.setdefault(area, []).append((before, after))
	overview = []
	for area, items in rows.items():
		sheet_rows = [pair(b, a) for b, a in items]
		height = sum(r.height + 8 for r in sheet_rows) + 60
		sheet = Image.new("RGB", (sheet_rows[0].width, height), (20, 20, 20))
		label(sheet, CAPTIONS.get(area, area), 40)
		y = 60
		for r in sheet_rows:
			sheet.paste(r, (0, y))
			y += r.height + 8
		sheet.save(PREVIEWS / f"compare_{area}.jpg", quality=88)
		overview.append(pair(*items[0]))
		print("T250_COMPARE", area, len(items))
	if overview:
		height = sum(r.height + 8 for r in overview)
		sheet = Image.new("RGB", (overview[0].width, height), (20, 20, 20))
		y = 0
		for r in overview:
			sheet.paste(r, (0, y))
			y += r.height + 8
		sheet = sheet.resize((sheet.width * 3 // 4, sheet.height * 3 // 4))
		sheet.save(PREVIEWS / "compare_overview.jpg", quality=88)


if __name__ == "__main__":
	main()
