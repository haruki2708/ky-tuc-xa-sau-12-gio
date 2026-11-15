"""T-263 round 1: option sheets for the owner from previews/wave6/pilot_<config>_<view>[_tv][_torch].jpg (capture_wave6.gd),
one sheet per thing to pick, same cameras across options, chapter 3's real scene at night, the canteen horde's six
idle zombies in place; and heads.jpg (step 0) from heads_<n>_<before|after>[_torch].jpg (capture_t263.gd).
Run: python -B art_source/graphics_upgrade/realistic_map/wave6/make_wave6_sheets.py
"""
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

sys.dont_write_bytecode = True
sys.stdout.reconfigure(encoding="utf-8")
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PREVIEWS = HERE.parent / "previews" / "wave6"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"

VIEW_NAMES = {
	"door": "từ cửa chính nhìn sảnh", "door_in": "từ cửa chính nhìn thẳng vào bếp", "counter_out": "từ quầy nhìn ra cửa",
	"tv": "TV trên tường tây", "counter": "quầy chia cơm, bảng giá", "tables": "giữa các bàn, xác sống đứng",
	"table_close": "một bàn gần", "ceiling": "trần, quạt, đèn tuýp", "kitchen": "bếp và đồng hồ (4 giờ)",
	"kitchen_side": "bếp nhìn chéo", "facade": "mặt tiền từ sân", "facade_side": "mặt tiền nhìn chéo", "west_exit": "lối tây",
}


def font(size):
	return ImageFont.truetype(str(FONT), size)


def label(img, text, size=24, at=(0, 0)):
	draw = ImageDraw.Draw(img)
	f = font(size)
	box = draw.textbbox((0, 0), text, font=f)
	draw.rectangle([at[0], at[1], at[0] + box[2] + 20, at[1] + box[3] + 12], fill=(0, 0, 0))
	draw.text((at[0] + 10, at[1] + 4), text, font=f, fill=(240, 240, 235))


def tile(config, view, suffix, name, size):
	img = Image.open(PREVIEWS / f"pilot_{config}_{view}{suffix}.jpg").convert("RGB").resize(size)
	label(img, name, 22)
	extra = {"": "không đèn pin", "_torch": "đèn pin", "_tv": "TV bật"}[suffix]
	label(img, f"{VIEW_NAMES[view]} · {extra}", 18, (0, size[1] - 40))
	return img


def sheet(file, title, columns, rows, note="", size=(800, 450)):
	"""columns: [(config, name)] or [(config, name, suffix)], rows: [(view, suffix)]."""
	head = 70 if not note else 112
	out = Image.new("RGB", (len(columns) * (size[0] + 8) - 8, head + len(rows) * (size[1] + 8)), (20, 20, 20))
	label(out, title, 30)
	if note:
		ImageDraw.Draw(out).text((12, 68), note, font=font(20), fill=(205, 205, 195))
	for r, (view, suffix) in enumerate(rows):
		for c, column in enumerate(columns):
			config, name = column[0], column[1]
			sfx = column[2] if len(column) > 2 else suffix
			out.paste(tile(config, view, sfx, name, size), (c * (size[0] + 8), head + r * (size[1] + 8)))
	out.save(PREVIEWS / file, quality=84)
	print("wrote", file, out.size)


BEFORE = ("before", "Hiện tại (PS1)")


def main():
	sheet("options_tables.jpg", "Bàn ghế: T1 bàn inox liền 6 ghế đôn tròn  /  T2 bàn mặt đá, ghế nhựa đỏ/xanh rời",
		[BEFORE, ("a", "T1 inox liền ghế (mức bừa M1)"), ("d", "T2 mặt đá + ghế nhựa rời (M1)")],
		[("tables", ""), ("table_close", "_torch"), ("door", "")],
		"Cả hai giữ khối va chạm bàn cũ 2,6 × 0,9 × 2 m; ghế rời của T2 chỉ là hình, đặt trong khối đó. 21 bàn gộp thành 3 lưới (3 lần vẽ).")
	sheet("options_floor_walls.jpg", "Sàn và tường: F1 gạch ceramic 40 × 40 kem, tường vàng nhạt, ốp gạch men trắng chân tường  /  F2 sàn đá mài, tường xanh nhạt, chân tường sơn dầu xanh",
		[BEFORE, ("a", "F1 ceramic kem, vàng nhạt, gạch men"), ("b", "F2 đá mài, xanh nhạt, sơn dầu")],
		[("door_in", ""), ("tv", ""), ("west_exit", "_torch")],
		"Chân tường cao 1,4 m; vết bẩn, ố nước dưới cửa sổ, mốc góc tường theo mặt nạ riêng của sảnh. Cửa sổ thật (nhìn ra ngoài được), có song sắt.", (720, 405))
	sheet("options_counter.jpg", "Quầy chia cơm: Q1 quầy inox có kính chắn  /  Q2 quầy xây ốp gạch men trắng; bảng giá gỗ sơn đen chữ trắng  /  bảng in",
		[BEFORE, ("a", "Q1 inox + bảng gỗ sơn đen"), ("b", "Q2 ốp gạch men + bảng in")],
		[("counter", ""), ("counter", "_torch"), ("counter_out", "")],
		"Chữ bảng giá giữ đúng: CƠM 5, RAU 3, THỊT 8, CANH 2, MÌ 6. Ô chia cơm: cửa cuốn kéo xuống còn hở 30 cm. Quầy nằm trong khối va chạm cũ.")
	sheet("options_ceiling.jpg", "Trần: C2 trần thạch cao tấm 60 × 60 ố vàng (6 tấm rơi, 2 tấm võng)  /  C1 trần tôn lộ xà gồ thép",
		[BEFORE, ("a", "C2 tấm 60 × 60 ố vàng"), ("b", "C1 tôn lộ xà gồ, kèo thép")],
		[("ceiling", ""), ("door", ""), ("tables", "")],
		"Quạt trần (đứng yên, cánh đúng góc PS1) và 20 đèn tuýp giữ đúng chỗ; 3 đèn trần CeilingLight giữ nguyên, không thêm đèn.")
	sheet("options_kitchen.jpg", "Bếp: K1 bếp gạch ốp men, chảo gang, nồi nhôm lớn  /  K2 bếp inox công nghiệp",
		[BEFORE, ("a", "K1 bếp gạch ốp men"), ("b", "K2 bếp inox")],
		[("kitchen", "_torch"), ("kitchen_side", "_torch"), ("kitchen", "")],
		"Đồng hồ bếp dừng ở 4 giờ (meta stopped_hour = 4), chụp hút chia hai nửa để đồng hồ luôn thấy được. Bếp, bàn sơ chế, chậu rửa trong khối va chạm cũ.")
	sheet("options_mess.jpg", "Mức bừa sau khi bỏ chạy: M1 như hiện nay  /  M2 bừa hơn (bát đổ, khay, đũa rơi nhiều hơn; với T2 thì ghế đổ)",
		[("a", "T1 + M1"), ("c", "T1 + M2"), ("d", "T2 + M1"), ("b", "T2 + M2 (ghế đổ)")],
		[("tables", ""), ("table_close", "_torch"), ("door", "")],
		"Không đổi va chạm: đồ rơi chỉ là hình; ghế đổ nằm trong khối va chạm bàn.", (720, 405))
	sheet("options_tv.jpg", "TV trên tường tây: tắt / bật (Canteen/TV/Screen.visible, như PS1)",
		[("before", "PS1 tắt", ""), ("before", "PS1 bật", "_tv"), ("a", "Mới tắt", ""), ("a", "Mới bật", "_tv")],
		[("tv", ""), ("door", "")],
		"Màn bật là bản tin không có chữ (giọng đọc ROOM_CH3_TV_NEWS giữ nguyên). Nhìn thấy từ cửa chính và từ giữa sảnh.", (720, 405))
	sheet("options_facade.jpg", "Mặt tiền (chung cho mọi phương án): tường quét vôi vàng, trụ và gờ quét vôi trắng, song sắt, biển \"NHÀ ĂN SINH VIÊN\"",
		[BEFORE, ("a", "Góc mẫu")],
		[("facade", ""), ("facade_side", "_torch")],
		"Biển và khẩu hiệu giữ đúng chữ; mái hiên, cột, bậc đúng chỗ PS1. Sân trước, hai bên, sân sau là dải A16 (lượt 2).", (960, 540))


def heads():
	size = (800, 450)
	views = [("heads_1", "_torch"), ("heads_2", "_torch"), ("heads_3", "_torch")]
	out = Image.new("RGB", (2 * (size[0] + 8) - 8, 70 + len(views) * (size[1] + 8)), (20, 20, 20))
	label(out, "Bước 0: trả đầu 6 xác trong vườn (T-259 ẩn nhầm cả node P_paper_box_p0_p0) — trước / sau, đèn pin", 28)
	for r, (view, suffix) in enumerate(views):
		for c, tag in enumerate(("before", "after")):
			img = Image.open(PREVIEWS / f"{view}_{tag}{suffix}.jpg").convert("RGB").resize(size)
			label(img, ("Trước" if tag == "before" else "Sau") + " · xác %s" % view[-1], 22)
			out.paste(img, (c * (size[0] + 8), 70 + r * (size[1] + 8)))
	out.save(PREVIEWS / "heads.jpg", quality=84)
	print("wrote heads.jpg", out.size)


if __name__ == "__main__":
	main()
	heads()
