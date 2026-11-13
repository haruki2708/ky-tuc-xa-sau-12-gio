"""T-253: before/after sheets from previews/wave2/ (before_* and after_* of the same camera), one per area, and an
overview for the owner. Run: python -B art_source/graphics_upgrade/realistic_map/wave2/make_compare.py
"""
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
PREVIEWS = ROOT / "art_source/graphics_upgrade/realistic_map/previews/wave2"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
OVERVIEW = ["a08_2_east", "a08_7_room_open_torch", "a09_2_door203_torch", "a09_3_room203_torch", "a10_3_manager_room_torch",
	"a10_4_window_torch", "a10_5_main_door_torch", "a11_2_extinguisher_close_torch"]
CAPTIONS = {
	"a08": "A08 tầng 3 nhà B", "a09": "A09 tầng 2, phòng 203", "a10": "A10 tầng 1, sảnh, phòng quản lý, cửa sổ",
	"a11": "A11 bình cứu hoả tầng 2, hộp báo cháy tầng 1 (hộp: ảnh mẫu, core chưa gắn)",
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
	label(b, "Sau (T-253)", 26)
	out = Image.new("RGB", (width * 2 + 8, a.height), (20, 20, 20))
	out.paste(a, (0, 0))
	out.paste(b, (width + 8, 0))
	return out


def sheet_of(rows, title=None, scale=1.0):
	height = sum(r.height + 8 for r in rows) + (60 if title else 0)
	sheet = Image.new("RGB", (rows[0].width, height), (20, 20, 20))
	y = 0
	if title:
		label(sheet, title, 40)
		y = 60
	for r in rows:
		sheet.paste(r, (0, y))
		y += r.height + 8
	if scale != 1.0:
		sheet = sheet.resize((int(sheet.width * scale), int(sheet.height * scale)))
	return sheet


def main():
	rows = {}

	def order(p):
		parts = p.stem.split("_")  # after, area, index, words...
		return (parts[1], int(parts[2]))
	for after in sorted(PREVIEWS.glob("after_*.jpg"), key=order):
		before = after.with_name(after.name.replace("after_", "before_", 1))
		area = after.stem.split("_")[1]
		if before.exists():
			rows.setdefault(area, []).append((before, after))
	for area, items in rows.items():
		sheet_of([pair(b, a) for b, a in items], CAPTIONS.get(area, area), 0.75).save(PREVIEWS / f"compare_{area}.jpg", quality=86)
		print("T253_COMPARE", area, len(items))
	overview = []
	for stem in OVERVIEW:
		after, before = PREVIEWS / ("after_" + stem + ".jpg"), PREVIEWS / ("before_" + stem + ".jpg")
		if after.exists() and before.exists():
			overview.append(pair(before, after))
	if overview:
		sheet_of(overview, None, 0.75).save(PREVIEWS / "compare_overview.jpg", quality=86)


if __name__ == "__main__":
	main()
