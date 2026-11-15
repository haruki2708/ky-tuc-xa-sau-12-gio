"""T-262 round 1: option sheets for the owner from previews/wave5/pilot_<config>_<view>[_torch].jpg (capture_wave5.gd).
One sheet per thing to pick, same cameras across options, chapter 3's real scene at night, the twelve guards in place.
Run: python -B art_source/graphics_upgrade/realistic_map/wave5/make_wave5_sheets.py
"""
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

sys.dont_write_bytecode = True
sys.stdout.reconfigure(encoding="utf-8")
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PREVIEWS = HERE.parent / "previews" / "wave5"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"

VIEW_NAMES = {
	"start": "từ Start_gate nhìn cổng",
	"approach": "từ cuối đường vào sân cổng",
	"pillar_west": "sát trụ tây (nghiêng, nứt)",
	"sign": "biển rơi nửa, trước hàng bảo vệ",
	"barrier": "thanh chắn, cọc giao thông",
	"booth": "chốt bảo vệ",
	"booth_window": "nhìn qua cửa sổ chốt",
	"wall_east": "tường rào nam, phía chốt",
	"wall_west": "tường rào nam, phía tây cổng",
	"court": "mặt sân cổng",
	"gate_out": "nhìn qua cổng ra ngoài",
}


def font(size):
	return ImageFont.truetype(str(FONT), size)


def label(img, text, size=24, at=(0, 0)):
	draw = ImageDraw.Draw(img)
	f = font(size)
	box = draw.textbbox((0, 0), text, font=f)
	draw.rectangle([at[0], at[1], at[0] + box[2] + 20, at[1] + box[3] + 12], fill=(0, 0, 0))
	draw.text((at[0] + 10, at[1] + 4), text, font=f, fill=(240, 240, 235))


def tile(config, view, torch, name, size):
	img = Image.open(PREVIEWS / f"pilot_{config}_{view}{'_torch' if torch else ''}.jpg").convert("RGB").resize(size)
	label(img, name, 22)
	label(img, f"{VIEW_NAMES[view]} · {'đèn pin' if torch else 'không đèn pin'}", 18, (0, size[1] - 40))
	return img


def sheet(file, title, columns, rows, note="", size=(800, 450)):
	"""columns: [(config, name)], rows: [(view, torch)]."""
	head = 70 if not note else 112
	out = Image.new("RGB", (len(columns) * (size[0] + 8) - 8, head + len(rows) * (size[1] + 8)), (20, 20, 20))
	label(out, title, 32)
	if note:
		ImageDraw.Draw(out).text((12, 68), note, font=font(21), fill=(205, 205, 195))
	for r, (view, torch) in enumerate(rows):
		for c, (config, name) in enumerate(columns):
			out.paste(tile(config, view, torch, name, size), (c * (size[0] + 8), head + r * (size[1] + 8)))
	out.save(PREVIEWS / file, quality=84)
	print("wrote", file, out.size)


BEFORE = ("before", "Hiện tại (PS1)")


def main():
	sheet("options_gate.jpg", "Cánh cổng: G1 cổng sắt hai cánh, song đứng sơn xanh  /  G2 cổng xếp inox",
		[BEFORE, ("a", "G1 sắt hai cánh, sơn xanh, cao 3 m"), ("b", "G2 cổng xếp inox, cao 1,9 m")],
		[("sign", True), ("start", False), ("gate_out", False)],
		"Cùng camera, chương 3 thật, ban đêm, 12 bảo vệ đứng đúng chỗ. Cả hai nằm trong khối va chạm cổng cũ (20 × 4 × 0,18 m), không đổi va chạm.")
	sheet("options_sign.jpg", "Trụ và biển: P1 trụ trát quét vôi + SA biển ngang trên vòm thép  /  P2 trụ ốp gạch + SB biển chữ nổi trên trụ; có chữ hay không",
		[BEFORE, ("a", "P1 + SA, có chữ"), ("c", "P1 + SA, không chữ"), ("b", "P2 + SB chữ nổi, có chữ"), ("d", "P2 + SB, không chữ")],
		[("sign", True), ("pillar_west", True), ("start", False)],
		"Chữ mẫu \"TRƯỜNG ĐẠI HỌC\", phần tên trường đã bong chỉ còn vết keo (STORY: trường không tên); chủ dự án duyệt chữ. "
		"\"Không chữ\": mọi chữ đã rơi, chỉ còn vết keo, vết bu lông. Trụ tây vẫn nghiêng 7°, vết nứt giữ chỗ PS1.", (720, 405))
	sheet("options_booth.jpg", "Chốt bảo vệ: K1 chốt xây trát, quét vôi vàng  /  K2 chốt lắp ghép tấm composite, khung thép xanh",
		[BEFORE, ("a", "K1 xây trát, vôi vàng, mái bê tông"), ("b", "K2 lắp ghép composite, mái tôn")],
		[("booth", True), ("booth_window", True), ("approach", False)],
		"Cùng cửa sổ PS1 (3,6 × 1,1 m); bên trong: bàn, ghế nhựa, sổ trực, điện thoại, phích, quạt, màn hình, lịch, hộp chìa khoá (chỉ vẽ trong 30 m).")
	sheet("options_wall.jpg", "Tường rào nam: W1 tường trát quét vôi, song sắt phía trên  /  W2 tường gạch trần; góc mẫu x 186…262",
		[BEFORE, ("a", "W1 trát quét vôi + song sắt"), ("b", "W2 gạch trần, gờ bê tông")],
		[("wall_east", True), ("wall_west", True), ("approach", False)],
		"Cao 3 m đúng khối va chạm Fence/S; ngoài đoạn mẫu vẫn là tường PS1 (chỗ nối thấy rõ ở góc rộng). Lỗ cổng không còn tường phía sau: nhìn ra vỉa hè, lòng đường.")
	sheet("options_court.jpg", "Sân cổng: C2 lát block con sâu (như dải nối D-178)  /  C1 đường nhựa cũ; thanh chắn và cọc chung",
		[BEFORE, ("a", "C2 block con sâu xám"), ("b", "C1 nhựa đường cũ, nứt")],
		[("court", True), ("barrier", True), ("approach", False)],
		"Mặt sân giữ cao độ −9,90 (va chạm Court không đổi). Vệt bánh xe, vũng nước sát tường, dầu dưới ô tô; vết nứt đặt đúng chỗ RoadCrack PS1.")


if __name__ == "__main__" and "--overview" not in sys.argv:
	main()


# --- round 2 (D-180): overview.jpg from capture_t262.gd's before_*/after_* -----------------------------------------
OVERVIEW = [("g1_start", "", "từ Start_gate nhìn cổng"), ("g2_approach", "", "cuối đường vào sân cổng"),
	("g3_pillar_west", "_torch", "sát trụ tây (nghiêng, nứt), đèn pin"), ("g4_sign", "_torch", "biển rơi nửa, đèn pin"),
	("g5_booth", "_torch", "chốt bảo vệ, đèn pin"), ("g6_booth_window", "_torch", "qua cửa sổ chốt, đèn pin"),
	("g7_barrier", "_torch", "rào chắn, cọc, đèn pin"), ("g8_wall_east", "_torch", "tường rào nam phía chốt, đèn pin"),
	("g9_gate_out", "", "nhìn qua cổng ra ngoài"), ("g10_to_canteen", "", "từ cổng nhìn về nhà ăn"),
	("a1_avenue", "", "dải A16: cuối đại lộ"), ("a2_walk_canteen", "_torch", "dải A16: lối sang nhà ăn, đèn pin"),
	("a3_cars", "_torch", "dải A16: ô tô trong sân, đèn pin"), ("a4_court_east", "_torch", "góc đông bắc sân cổng, đèn pin"),
	("w1_wall_behind_b", "_torch", "tường nam sau nhà B, đèn pin"), ("w2_wall_far", "", "tường nam nhìn xa"),
	("w3_wall_east_end", "", "tường nam phía đông")]


def overview():
	tile = (960, 540)
	head = 70
	out = Image.new("RGB", (2 * tile[0] + 8, head + len(OVERVIEW) * (tile[1] + 8)), (20, 20, 20))
	label(out, "T-262 đợt 5 (D-180): cổng trường, chốt bảo vệ, tường rào nam, dải A16 đoạn cổng — trước (PS1) / sau, chương 3, cùng camera", 28)
	for r, (view, torch, name) in enumerate(OVERVIEW):
		for c, tag in enumerate(("before", "after")):
			img = Image.open(PREVIEWS / f"{tag}_{view}{torch}.jpg").convert("RGB").resize(tile)
			label(img, ("Trước · " if tag == "before" else "Sau · ") + name, 22)
			out.paste(img, (c * (tile[0] + 8), head + r * (tile[1] + 8)))
	out.save(PREVIEWS / "overview.jpg", quality=80)
	print("wrote overview.jpg", out.size)


if __name__ == "__main__" and "--overview" in sys.argv:
	overview()
