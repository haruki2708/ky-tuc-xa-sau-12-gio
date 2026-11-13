"""T-256: before/after sheets from previews/floor4_rest/ (before_ch<N>_<set>_<view> and after_ch<N>_<set>_<view>, the same
camera; the survey's own before stills where main has them), one sheet per part and chapter, and an overview.
Run: python -B art_source/graphics_upgrade/realistic_map/floor4_rest/make_compare.py
"""
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PREVIEWS = HERE.parent / "previews" / "floor4_rest"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
CAPTIONS = {
	"03": "nhà vệ sinh từ cửa", "04": "máng rửa và gương", "a1": "từ cửa, không đèn pin", "a2": "ba buồng",
	"a3": "khe cửa buồng", "a4": "gương", "a5": "máng rửa", "a6": "nhìn ra cửa", "07": "dây phơi", "08": "trước phòng",
	"b1": "hành lang về phía tây", "b2": "hành lang về phía đông", "b3": "trước 402, 403", "c1": "tay gạt và lan can",
	"c2": "cửa thoát hiểm mở", "c3": "biển thoát hiểm", "d1": "feed CCTV hành lang", "d2": "trường quay nhìn lại",
}
PARTS = {"washroom": "A nhà vệ sinh chung", "corridor": "B đồ hành lang", "firedoor": "C cửa thoát hiểm", "cctv": "D trường quay CCTV"}
OVERVIEW = [("ch1", "washroom", "03_washroom_entry"), ("ch1", "washroom", "04_washroom_sinks"), ("ch1", "washroom", "a2_stalls"),
	("ch1", "corridor", "07_corridor_clothes"), ("ch1", "corridor", "b3_rooms_front"), ("ch3", "firedoor", "c1_handle_rail"),
	("ch3", "firedoor", "c3_sign_column"), ("ch1", "cctv", "d1_feed")]


def label(img, text, size=24):
	draw = ImageDraw.Draw(img)
	font = ImageFont.truetype(str(FONT), size)
	box = draw.textbbox((0, 0), text, font=font)
	draw.rectangle([0, 0, box[2] + 24, box[3] + 16], fill=(0, 0, 0))
	draw.text((12, 6), text, font=font, fill=(240, 240, 235))


def tile(path, text, width=960):
	img = Image.open(path).convert("RGB")
	img = img.resize((width, width * img.height // img.width))
	label(img, text)
	return img


def pair(chapter, part, view, width=960):
	caption = CAPTIONS.get(view[:2], view)
	after = PREVIEWS / f"after_{chapter}_{part}_{view}.jpg"
	before = PREVIEWS / f"before_{chapter}_{part}_{view}.jpg"
	b = tile(after, f"Sau (T-256): {caption}", width)
	a = tile(before, f"Trước: {caption}", width) if before.exists() else Image.new("RGB", b.size, (20, 20, 20))
	out = Image.new("RGB", (width * 2 + 8, max(a.height, b.height)), (20, 20, 20))
	out.paste(a, (0, 0))
	out.paste(b, (width + 8, 0))
	return out


def sheet_of(rows, title):
	height = sum(r.height + 8 for r in rows) + 60
	sheet = Image.new("RGB", (max(r.width for r in rows), height), (20, 20, 20))
	label(sheet, title, 38)
	y = 60
	for r in rows:
		sheet.paste(r, (0, y))
		y += r.height + 8
	return sheet


def save(sheet, name, max_height=7000):
	if sheet.height > max_height:
		sheet = sheet.resize((int(sheet.width * max_height / sheet.height), max_height))
	sheet.save(PREVIEWS / name, quality=88)
	print("T256_COMPARE", name, sheet.size)


def main():
	for part, title in PARTS.items():
		for chapter in ("ch1", "ch3"):
			prefix = f"after_{chapter}_{part}_"
			views = sorted(p.stem[len(prefix):] for p in PREVIEWS.glob(prefix + "*.jpg"))
			if views:
				save(sheet_of([pair(chapter, part, v) for v in views], f"T-256 {title}, {chapter.replace('ch', 'chương ')}: trước / sau"),
					f"compare_{part}_{chapter}.jpg")
	rows = [pair(c, p, v) for c, p, v in OVERVIEW if (PREVIEWS / f"after_{c}_{p}_{v}.jpg").exists()]
	if rows:
		save(sheet_of(rows, "T-256 tổng quan: nhà vệ sinh, đồ hành lang, cửa thoát hiểm, CCTV hành lang"), "overview.jpg")


if __name__ == "__main__":
	main()
