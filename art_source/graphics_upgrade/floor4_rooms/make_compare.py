"""T-255: before/after sheets from previews/ (before_ch<N>_rooms_<view> and after_ch<N>_rooms_<view>, the same camera),
one sheet per chapter, an overview for the owner, and a sheet of the views only the new rooms have (no before).
Run: python -B art_source/graphics_upgrade/floor4_rooms/make_compare.py
"""
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PREVIEWS = HERE / "previews"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
OVERVIEW = [("ch1", "01_corridor_401"), ("ch1", "02_in_401"), ("ch1", "09_in_408"), ("ch1", "10_bath_401"),
	("ch1", "11_balcony_401"), ("ch3", "14_facade_outside")]
CAPTIONS = {"01": "hành lang nhìn vào 401", "02": "trong 401", "03": "401 nhìn ra cửa", "04": "trong 402", "05": "trong 403",
	"06": "trong 404", "07": "trong 405", "08": "trong 406", "09": "trong 408", "10": "nhà tắm 401", "11": "ban công 401",
	"12": "hành lang phía tây", "13": "từ ban công 407", "14": "mặt sau nhà B", "15": "402 nhìn ra cửa",
	"16": "408 nhìn ra cửa", "17": "nhà tắm 408", "18": "404 nhìn ra cửa"}


def label(img, text, size=30):
	draw = ImageDraw.Draw(img)
	font = ImageFont.truetype(str(FONT), size)
	box = draw.textbbox((0, 0), text, font=font)
	draw.rectangle([0, 0, box[2] + 24, box[3] + 16], fill=(0, 0, 0))
	draw.text((12, 6), text, font=font, fill=(240, 240, 235))


def tile(path, text, width=960):
	img = Image.open(path).convert("RGB").resize((width, width * 9 // 16))
	label(img, text, 24)
	return img


def pair(chapter, view, width=960):
	caption = CAPTIONS.get(view[:2], view)
	a = tile(PREVIEWS / f"before_{chapter}_rooms_{view}.jpg", f"Trước: {caption}", width)
	b = tile(PREVIEWS / f"after_{chapter}_rooms_{view}.jpg", f"Sau (T-255): {caption}", width)
	out = Image.new("RGB", (width * 2 + 8, a.height), (20, 20, 20))
	out.paste(a, (0, 0))
	out.paste(b, (width + 8, 0))
	return out


def sheet_of(rows, title):
	height = sum(r.height + 8 for r in rows) + 60
	sheet = Image.new("RGB", (max(r.width for r in rows), height), (20, 20, 20))
	label(sheet, title, 40)
	y = 60
	for r in rows:
		sheet.paste(r, (0, y))
		y += r.height + 8
	return sheet


def save(sheet, name, max_height=7000):
	if sheet.height > max_height:
		sheet = sheet.resize((int(sheet.width * max_height / sheet.height), max_height))
	sheet.save(PREVIEWS / name, quality=88)
	print("T255_COMPARE", name, sheet.size)


def main():
	for chapter in ("ch1", "ch3"):
		views = sorted(p.stem.split("_rooms_")[1] for p in PREVIEWS.glob(f"after_{chapter}_rooms_*.jpg"))
		rows = [pair(chapter, v) for v in views if (PREVIEWS / f"before_{chapter}_rooms_{v}.jpg").exists()]
		if rows:
			save(sheet_of(rows, f"T-255 phòng tầng 4, {chapter.replace('ch', 'chương ')}: trước / sau"), f"compare_{chapter}.jpg")
		new = [v for v in views if not (PREVIEWS / f"before_{chapter}_rooms_{v}.jpg").exists()]
		if new:
			tiles = [tile(PREVIEWS / f"after_{chapter}_rooms_{v}.jpg", "Mới: " + CAPTIONS.get(v[:2], v)) for v in new]
			rows = []
			for k in range(0, len(tiles), 2):
				row = Image.new("RGB", (960 * 2 + 8, tiles[k].height), (20, 20, 20))
				for j, t in enumerate(tiles[k:k + 2]):
					row.paste(t, (j * 968, 0))
				rows.append(row)
			save(sheet_of(rows, f"T-255 góc chỉ phòng mới có, {chapter.replace('ch', 'chương ')}"), f"new_views_{chapter}.jpg")
	rows = [pair(c, v) for c, v in OVERVIEW if (PREVIEWS / f"after_{c}_rooms_{v}.jpg").exists()]
	if rows:
		save(sheet_of(rows, "T-255 tổng quan: phòng 401-406, 408 sâu như 407, nhà tắm, ban công, đồ mỗi phòng một khác"), "overview.jpg")


if __name__ == "__main__":
	main()
