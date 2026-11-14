"""T-259 round 1: option sheets for the owner from previews/wave3/pilot_<config>_<view>_<dark|torch>.jpg
(capture_wave3.gd), plus references.jpg from real photos on Wikimedia Commons (CC0 / CC BY only, credited on the
sheet and in previews/wave3/README.md; not shipped in the game).
Run: python -B art_source/graphics_upgrade/realistic_map/wave3/make_wave3_sheets.py [--refs <folder with ref*.jpg and refs.json>]
"""
from pathlib import Path
import json
import sys

from PIL import Image, ImageDraw, ImageFont

sys.dont_write_bytecode = True
sys.stdout.reconfigure(encoding="utf-8")
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PREVIEWS = HERE.parent / "previews" / "wave3"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
TILE = (800, 450)

CONFIG_NAMES = {
	"before": "Hiện tại (PS1)",
	"t1": "T1 hoa sứ (đại)",
	"t2": "T2 bàng Đài Loan",
	"t3": "T3 bằng lăng",
	"mix": "T1 + T3 xen kẽ",
	"f2": "F2 dừa cạn, cẩm tú mai",
	"p2": "P2 gạch đỏ lá dừa",
	"k2": "K2 viền sơn vàng",
}
VIEW_NAMES = {
	"bench_wide": "ghế Ngư giữa hai bồn",
	"bench_close": "ghế Ngư, gần",
	"bed_close": "bồn Bed1_1, gần",
	"entry": "lối giữa các bồn",
	"lamp": "cột đèn vườn (x 1, z 24)",
	"floor4": "từ hành lang tầng 4 nhìn xuống",
}


def font(size):
	return ImageFont.truetype(str(FONT), size)


def label(img, text, size=24, at=(0, 0)):
	draw = ImageDraw.Draw(img)
	f = font(size)
	box = draw.textbbox((0, 0), text, font=f)
	draw.rectangle([at[0], at[1], at[0] + box[2] + 20, at[1] + box[3] + 12], fill=(0, 0, 0))
	draw.text((at[0] + 10, at[1] + 4), text, font=f, fill=(240, 240, 235))


def tile(config, view, light):
	path = PREVIEWS / f"pilot_{config}_{view}_{light}.jpg"
	img = Image.open(path).convert("RGB").resize(TILE)
	label(img, f"{CONFIG_NAMES[config]} · {VIEW_NAMES[view]}{' · đèn pin' if light == 'torch' else ''}", 20)
	return img


def sheet(name, title, rows, note=""):
	"""rows: list of lists of (config, view, light) or None."""
	cols = max(len(r) for r in rows)
	head = 70 if not note else 110
	out = Image.new("RGB", (cols * (TILE[0] + 8) - 8, head + len(rows) * (TILE[1] + 8)), (20, 20, 20))
	label(out, title, 34, (0, 0))
	if note:
		ImageDraw.Draw(out).text((12, 66), note, font=font(22), fill=(200, 200, 190))
	for r, row in enumerate(rows):
		for c, cell in enumerate(row):
			if cell is None:
				continue
			out.paste(tile(*cell), (c * (TILE[0] + 8), head + r * (TILE[1] + 8)))
	out.save(PREVIEWS / name, quality=85)
	print("wrote", name, out.size)


def references(folder):
	refs = json.loads((folder / "refs.json").read_text(encoding="utf-8"))
	names = {
		"Plumeria tree": "Hoa sứ / hoa đại (Plumeria), cây trồng ven đường",
		"Plumeria obtusa.jpg": "Hoa sứ trắng (Plumeria obtusa): hoa, lá",
		"Terminalia mantaly": "Bàng Đài Loan (Terminalia mantaly)",
		"Lagerstroemia": "Bằng lăng (Lagerstroemia speciosa)",
		"Ixora": "Trang (Ixora coccinea)",
		"Duranta": "Chuỗi ngọc (Duranta erecta), hàng rào",
		"Cuphea": "Cẩm tú mai (Cuphea hyssopifolia)",
		"Catharanthus": "Dừa cạn (Catharanthus roseus) trong bồn",
	}
	order = ["Plumeria tree", "Plumeria obtusa.jpg", "Terminalia mantaly", "Lagerstroemia", "Ixora", "Duranta", "Cuphea", "Catharanthus"]
	items = []
	for key in order:
		for i, r in enumerate(refs):
			if key in r["title"]:
				items.append((i, r, names[key]))
				break
	w, h = 600, 520
	out = Image.new("RGB", (4 * (w + 8) - 8, 70 + 2 * (h + 8)), (20, 20, 20))
	label(out, "Ảnh tham chiếu thật (Wikimedia Commons, CC0 / CC BY; chỉ để so, không đưa vào game)", 30)
	for n, (i, r, name) in enumerate(items):
		img = Image.open(folder / f"ref{i}.jpg").convert("RGB")
		img.thumbnail((w, h - 90))
		cell = Image.new("RGB", (w, h), (30, 30, 30))
		cell.paste(img, ((w - img.width) // 2, 0))
		draw = ImageDraw.Draw(cell)
		draw.text((8, h - 86), name, font=font(20), fill=(240, 240, 235))
		draw.text((8, h - 58), f"{r['artist'][:46]} · {r['license']}", font=font(16), fill=(190, 190, 180))
		draw.text((8, h - 34), r["title"].removeprefix("File:")[:62], font=font(14), fill=(160, 160, 150))
		out.paste(cell, ((n % 4) * (w + 8), 70 + (n // 4) * (h + 8)))
	out.save(PREVIEWS / "references.jpg", quality=85)
	lines = ["| Ảnh | Tác giả | Giấy phép | Nguồn |", "|---|---|---|---|"]
	for i, r, name in items:
		lines.append(f"| {name} | {r['artist']} | {r['license']} | {r['page']} |")
	print("\n".join(lines))


def main():
	trees = ["before", "t1", "t2", "t3", "mix"]
	sheet("options_trees.jpg", "T-259 lượt 1 — cây thấp trong bồn (cùng camera, chương 3 thật)", [
		[(c, "bench_wide", "dark") for c in trees],
		[(c, "bench_close", "dark") for c in trees],
		[(c, "bench_close", "torch") for c in trees],
		[(c, "floor4", "dark") for c in trees],
	] + [[(c, "bed_close", light) for c in trees[:4]] for light in ("dark", "torch")],
		"Cột 5 (T1 + T3): bồn Bed1_1 hoa sứ, Bed2_1 bằng lăng. Bồn F1, sân P1, viền K1 như nhau ở mọi cột.")
	sheet("options_beds.jpg", "T-259 lượt 1 — cây bụi, hoa trong bồn (F1, F2) và màu viền bồn (K1, K2)", [
		[("before", "bed_close", "dark"), ("t1", "bed_close", "dark"), ("f2", "bed_close", "dark"), ("k2", "bed_close", "dark")],
		[("before", "bed_close", "torch"), ("t1", "bed_close", "torch"), ("f2", "bed_close", "torch"), ("k2", "bed_close", "torch")],
		[("before", "bench_wide", "dark"), ("t1", "bench_wide", "dark"), ("f2", "bench_wide", "dark"), ("k2", "bench_wide", "dark")],
	], "Cột 2 = F1 viền chuỗi ngọc + 4 bụi trang đỏ, viền K1 quét vôi; cột 3 = F2; cột 4 = F1 với viền K2 sơn vàng. Cây T1 ở mọi cột.")
	sheet("options_paving.jpg", "T-259 lượt 1 — sân lát: P1 gạch block con sâu xám, P2 gạch đỏ lá dừa 30 × 30", [
		[("before", "bench_wide", "dark"), ("t1", "bench_wide", "dark"), ("p2", "bench_wide", "dark")],
		[("before", "bench_wide", "torch"), ("t1", "bench_wide", "torch"), ("p2", "bench_wide", "torch")],
		[("before", "bench_close", "torch"), ("t1", "bench_close", "torch"), ("p2", "bench_close", "torch")],
		[("before", "entry", "dark"), ("t1", "entry", "dark"), ("p2", "entry", "dark")],
		[("before", "floor4", "dark"), ("t1", "floor4", "dark"), ("p2", "floor4", "dark")],
	], "Góc mẫu lát cả sân 44 × 40 m (bồn PS1 khác vẫn còn). Cột 2 = P1, cột 3 = P2.")
	sheet("options_lamp_bench.jpg", "T-259 lượt 1 — ghế đá mài của Ngư, cột đèn vườn cầu tròn (một phương án)", [
		[("before", "bench_close", "dark"), ("t1", "bench_close", "dark"), ("t1", "bench_close", "torch")],
		[("before", "lamp", "dark"), ("t1", "lamp", "dark"), ("t1", "lamp", "torch")],
	], "Đèn: chỉ là hình quanh điểm đèn cũ (Flicker0, Flicker1), chao phát sáng theo đèn nhấp nháy; không thêm, không đổi đèn.")
	views = [("bench_wide", "dark"), ("bench_close", "torch"), ("bed_close", "dark"), ("entry", "dark"), ("lamp", "dark"), ("floor4", "dark")]
	sheet("pilot_overview.jpg", "T-259 lượt 1 — góc mẫu đề xuất (T1 + T3, F1, P1, K1) so với hiện tại", [
		[("before", v, l) for v, l in views[:3]],
		[("mix" if v in ("bench_wide", "bench_close", "entry", "floor4") else "t1", v, l) for v, l in views[:3]],
		[("before", v, l) for v, l in views[3:]],
		[("mix" if v in ("bench_wide", "bench_close", "entry", "floor4") else "t1", v, l) for v, l in views[3:]],
	])
	if "--refs" in sys.argv:
		references(Path(sys.argv[sys.argv.index("--refs") + 1]))


if __name__ == "__main__":
	main()
