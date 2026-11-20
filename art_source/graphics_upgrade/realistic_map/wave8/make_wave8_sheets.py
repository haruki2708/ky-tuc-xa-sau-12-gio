"""T-265 round 1: option sheets for the owner from previews/wave8/*.jpg (capture_wave8.gd): one sheet per thing to pick,
same cameras across options, chapter 4's real scene at night (the far views: chapter 3), with and without the torch.
Run: python -B art_source/graphics_upgrade/realistic_map/wave8/make_wave8_sheets.py
"""
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

sys.dont_write_bytecode = True
sys.stdout.reconfigure(encoding="utf-8")
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PREVIEWS = HERE.parent / "previews" / "wave8"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"

VIEW_NAMES = {
	"f1_backdoor": "tầng 1, từ cửa sau nhìn vào quầy", "f1_wide": "tầng 1 toàn cảnh (từ chân cầu thang)", "f1_counter": "quầy thủ thư, thanh sắt, ghế",
	"f1_map": "bản đồ trường ở 2 m", "f1_shelf": "tầng 1, một kệ", "f1_front_door": "cửa chính có chướng ngại (từ trong)",
	"f2_table": "tầng 2, bàn đọc có sổ quy tắc", "f2_shelf_window": "tầng 2, kệ và cửa sổ", "stairs": "cầu thang một nhịp, tay vịn",
	"f3_wide": "tầng 3 toàn cảnh", "f3_scare": "tầng 3, kệ ScareShelf3F", "back_out": "cửa sau từ ngoài (đóng)",
	"back_in_open": "cửa sau từ trong (mở)", "facade": "mặt trước từ sân", "facade_side": "mặt trước nhìn chéo",
	"far_stand": "chương 3: từ khán đài tây sân vận động", "far_track": "chương 3: từ đường chạy",
	"westexit_door": "chương 4: lối tây nhà ăn từ Start_split", "westexit_wall": "chương 4: tường tây nhà ăn và hè",
	"floor1": "tầng 1 nhìn từ trên", "floor3": "tầng 3 nhìn từ trên",
}


def font(size):
	return ImageFont.truetype(str(FONT), size)


def label(img, text, size=24, at=(0, 0)):
	draw = ImageDraw.Draw(img)
	f = font(size)
	box = draw.textbbox((0, 0), text, font=f)
	draw.rectangle([at[0], at[1], at[0] + box[2] + 20, at[1] + box[3] + 12], fill=(0, 0, 0))
	draw.text((at[0] + 10, at[1] + 4), text, font=f, fill=(240, 240, 235))


def tile(file, name, view, extra, size):
	path = PREVIEWS / file
	if not path.exists():
		img = Image.new("RGB", size, (60, 20, 20))
		label(img, "thiếu " + file, 20, (0, 60))
	else:
		img = Image.open(path).convert("RGB").resize(size)
	if name:
		label(img, name, 22)
	label(img, f"{VIEW_NAMES.get(view, view)}{' · ' + extra if extra else ''}", 18, (0, size[1] - 40))
	return img


def sheet(file, title, columns, rows, note="", size=(720, 405)):
	"""columns: [(prefix, name)], rows: [(view, suffix)]; the image is <prefix>_<view><suffix>.jpg."""
	head = 70 if not note else 112
	out = Image.new("RGB", (len(columns) * (size[0] + 8) - 8, head + len(rows) * (size[1] + 8)), (20, 20, 20))
	label(out, title, 28)
	if note:
		ImageDraw.Draw(out).text((12, 68), note, font=font(19), fill=(205, 205, 195))
	for r, (view, suffix) in enumerate(rows):
		for c, (prefix, name) in enumerate(columns):
			extra = {"": "không đèn pin", "_torch": "đèn pin"}.get(suffix, "")
			out.paste(tile(f"{prefix}_{view}{suffix}.jpg", name, view, extra, size), (c * (size[0] + 8), head + r * (size[1] + 8)))
	out.save(PREVIEWS / file, quality=84)
	print("wrote", file, out.size)


BEFORE = ("before", "Hiện tại (PS1)")
A = ("pilot_a", "Bộ a")
B = ("pilot_b", "Bộ b")
C = ("pilot_c", "Bộ c (đề xuất)")


def main():
	sheet("options_fill.jpg", "Mức đầy: M1 giữ bố cục thưa  /  M2 thêm đồ sát tường và chỗ trống ngoài lối đi  /  M3 dãy kệ giữa phòng (đổi navigation)",
		[BEFORE, ("pilot_a", "M1 (bộ a)"), ("options_fill_m2", "M2 (bộ a + đồ thêm)"), ("options_fill_m3", "M3 (bộ a + dãy kệ, chỉ ảnh mẫu)")],
		[("f1_backdoor", ""), ("f1_wide", "_torch"), ("f3_wide", "")],
		"M2: 21 món tầng 1, 23 món tầng 3 (kệ sát tường, kệ thấp dưới cửa sổ, tủ phích, bàn báo, xe đẩy, thùng sách, cây chết khô), ngoài nav + 0,6 m, có va chạm ở lượt 2. "
		"M3: chặn lối hiện có, phải làm lại navigation và tuyến xác (card riêng của integrator).", (640, 360))
	sheet("options_fill_top.jpg", "Mức đầy nhìn từ trên (trần, tầng trên và mái ẩn; thêm một đèn chiếu từ trên chỉ để chụp sơ đồ)",
		[("options_top_before", "Hiện tại (PS1)"), ("options_top_m1", "M1"), ("options_top_m2", "M2"), ("options_top_m3", "M3")],
		[("floor1", ""), ("floor3", "")],
		"Ảnh bố cục kèm số đo: options_fill_<m>_floor1/3.jpg (sơ đồ có vùng navigation, dải 0,6 m, vòng 1,5 m).", (640, 360))
	sheet("options_floor_walls.jpg", "Sàn và tường: F1 ceramic kem + vàng nhạt (như nhà ăn)  /  F2 đá mài + vôi trắng ngà, chân tường sơn xanh; tầng 3 xi măng (bộ c)",
		[BEFORE, ("pilot_a", "F1 ceramic, vàng nhạt"), ("pilot_b", "F2 đá mài, vôi ngà, sơn xanh"), ("pilot_c", "F1, tầng 3 sàn xi măng")],
		[("f1_wide", ""), ("f3_wide", "_torch"), ("f2_table", "")], size=(640, 360))
	sheet("options_shelves.jpg", "Kệ sách: kệ thép sơn xám, đầy  /  kệ gỗ, vơi, có đợt đổ nghiêng; tầng 3 kệ gỗ cũ đổ nghiêng (bộ c)",
		[BEFORE, ("pilot_a", "thép, đầy"), ("pilot_b", "gỗ, vơi"), ("pilot_c", "tầng 3: gỗ cũ, đổ nghiêng")],
		[("f1_shelf", "_torch"), ("f3_scare", "_torch"), ("f3_scare", "")],
		"Kệ mới khít khối va chạm cũ (đợt kệ đúng độ cao PS1). Sách: atlas 48 gáy, mỗi kệ một lưới (1 lần vẽ). Không rải sẵn sách dưới ScareShelf3F.", (640, 360))
	sheet("options_ceiling.jpg", "Trần: C2 tấm 60 × 60 ố vàng như nhà ăn, máng đèn tuýp  /  C1 trần bê tông trần có dầm và quạt trần",
		[BEFORE, A, B], [("f1_wide", ""), ("f2_table", ""), ("f1_backdoor", "")],
		"Hai đèn mỗi tầng giữ chỗ (máng có tuýp sáng ở đúng chỗ Light<t>_9/25); các máng khác tắt. Không thêm đèn.")
	sheet("options_counter.jpg", "Quầy thủ thư: Q1 gỗ dán mặt kính, CRT tắt, hộp phích  /  Q2 quầy xây ốp gạch men, mặt đá mài",
		[BEFORE, A, B], [("f1_counter", ""), ("f1_counter", "_torch"), ("f1_backdoor", "_torch")],
		"Mặt quầy mới cao 0,868 m: thanh sắt (đáy ống 0,8865 m) nằm trên, khe 1,9 cm; khối va chạm cũ (đỉnh 0,84 m) nằm trong quầy.")
	sheet("options_tables.jpg", "Bàn đọc: T1 bàn gỗ dài, ghế gỗ rời  /  T2 có vách ngăn nỉ xanh và đèn bàn (tắt)",
		[BEFORE, A, B], [("f2_table", ""), ("f2_table", "_torch")],
		"Sổ quy tắc trên ReadingTable13 đúng chỗ anchor ReadingDesk (0,89 m). Mặt bàn trong khối va chạm cũ.")
	sheet("options_window.jpg", "Cửa sổ nhìn từ trong: kính tối, song sắt, rèm bạc màu  /  cửa chớp gỗ khép (tường vẫn đặc)",
		[BEFORE, A, B], [("f2_shelf_window", ""), ("f2_shelf_window", "_torch"), ("f1_wide", "_torch")])
	sheet("options_facade.jpg", "Mặt ngoài: E1 tường vàng + lam bê tông đứng (phòng giả sau ô cửa)  /  E2 đá rửa xám + biển THƯ VIỆN (kính tối)",
		[BEFORE, A, B], [("facade", ""), ("facade_side", ""), ("back_out", "")],
		"Lam đứng nhô 0,45 m (giới hạn card mục 5), mái hắt cửa chính nhô 0,45 m. Dải đất: sân lát block trước cửa chính, hè bê tông 0,8 m và rãnh có nắp quanh nhà.")
	sheet("options_facade_far.jpg", "Mặt ngoài từ xa (chương 3, sân vận động): E1 / E2",
		[("ch3_before", "Hiện tại (PS1)"), ("ch3_a", "E1 vàng + lam"), ("ch3_b", "E2 đá rửa + biển")], [("far_stand", ""), ("far_track", "")])
	sheet("options_map.jpg", "Bản đồ trường: bản in trong khung kính nhôm  /  bản vẽ tay trên giấy kẻ ô dán bảng gỗ",
		[BEFORE, A, B], [("f1_map", ""), ("f1_map", "_torch")],
		"Năm khối nhà giữ đúng chỗ PS1, thêm giảng đường, nhà thi đấu, cổng trường cho khớp tài liệu ch4_map; hai vòng bút đỏ đúng đường FadedCircle cũ.")
	sheet("options_mess.jpg", "Mức bừa: gọn như nay (bộ a)  /  sách rơi trước kệ, giấy vương, ghế đổ, tấm trần rơi (bộ b, c)",
		[A, B, C], [("f1_backdoor", "_torch"), ("f3_wide", "")],
		"Chỉ là hình, không vật nào cao trên 3 cm nằm trên lối đi; không bày sẵn kết quả jumpscare (dưới ScareShelf3F để trống).")
	sheet("pilot_doors.jpg", "Cửa sau (gỗ sơn, hai ô kính lưới, treo dưới Hinge, quay 90° không cắm vào tường) và cửa chính có chướng ngại",
		[BEFORE, A, B], [("back_out", ""), ("back_out", "_torch"), ("back_in_open", "_torch"), ("f1_front_door", "_torch")], size=(640, 360))
	sheet("pilot_stairs.jpg", "Cầu thang: bậc đá mài trên dốc va chạm cũ, lan can thép dẹt tay vịn gỗ trong RailCollision",
		[BEFORE, A, B], [("stairs", ""), ("stairs", "_torch")])
	sheet("ch4_westexit.jpg", "Lối tây nhà ăn (T-263) nhìn từ Start_split, chương 4: lỗ cửa, hè và dải đợt 7 khớp nhau",
		[("ch4", "main hiện tại")], [("westexit_door", ""), ("westexit_door", "_torch"), ("westexit_wall", "")], size=(1280, 720))


# ------------------------------------------------------------------------------------------------ round 2 (D-185)

VIEW_NAMES.update({
	"f1_north": "tầng 1, khoang bắc: dãy kệ hai mặt", "stair_top": "đầu cầu thang tầng 2 nhìn về bàn đọc",
	"f2_well": "tầng 2, lan can mép tây ô cầu thang", "f2_wide": "tầng 2 toàn cảnh (khoang nam: dãy kệ)",
	"f3_south": "tầng 3, kho sách: khoang nam", "f3_scare2": "tầng 3, kệ ThrownBook3F", "facade_east": "mặt đông: ô cửa chỉ ở ngoài",
	"strip_west": "dải đất góc tây bắc, chỗ xác sinh ra",
})
R2_BEFORE = ("before", "Trước (PS1, main)")
R2_AFTER = ("after", "Sau (lượt 2, D-185)")


def round2():
	sheet("r2_floor1.jpg", "Tầng 1 trước/sau: sảnh mượn sách, quầy, bản đồ, cửa chính có chướng ngại",
		[R2_BEFORE, R2_AFTER], [("f1_backdoor", ""), ("f1_wide", "_torch"), ("f1_north", ""), ("f1_counter", "_torch"), ("f1_map", "_torch"),
		("f1_front_door", "_torch")], size=(800, 450))
	sheet("r2_floor2_stairs.jpg", "Cầu thang, lan can mép ô cầu thang, tầng 2 (phòng đọc) trước/sau",
		[R2_BEFORE, R2_AFTER], [("stairs", "_torch"), ("stair_top", ""), ("f2_well", "_torch"), ("f2_table", "_torch"), ("f2_wide", "")], size=(800, 450))
	sheet("r2_floor3.jpg", "Tầng 3 (kho sách cổ) trước/sau; hai chỗ jumpscare không bày sẵn gì",
		[R2_BEFORE, R2_AFTER], [("f3_wide", ""), ("f3_south", "_torch"), ("f3_scare", "_torch"), ("f3_scare2", "_torch")], size=(800, 450))
	sheet("r2_outside.jpg", "Bên ngoài trước/sau: cửa sau, mặt trước, mặt đông, dải đất (chương 4)",
		[R2_BEFORE, R2_AFTER], [("back_out", "_torch"), ("facade", ""), ("facade_side", ""), ("facade_east", ""), ("strip_west", "_torch")], size=(800, 450))
	sheet("r2_ch3.jpg", "Chương 3 trước/sau: thư viện nhìn từ sân vận động; ba góc toàn cảnh của đợt 7",
		[("ch3_before", "Trước"), ("ch3_after", "Sau")], [("far_stand", ""), ("far_track", ""), ("w_corridor4", ""), ("w_garden", ""), ("w_stand", "")],
		size=(800, 450))
	sheet("r2_occlusion.jpg", "Bật / tắt occlusion culling (khối che đang có của khuôn viên không ẩn nhầm vật mới)",
		[("after", "Occlusion bật"), ("occl_off", "Occlusion tắt")], [("f1_backdoor", ""), ("f1_wide", ""), ("facade", ""), ("facade_side", "")],
		size=(800, 450))
	# overview.jpg: the library after round 2, twelve stills.
	picks = [("after_f1_backdoor.jpg", "f1_backdoor"), ("after_f1_wide_torch.jpg", "f1_wide"), ("after_f1_north.jpg", "f1_north"),
		("after_f1_counter_torch.jpg", "f1_counter"), ("after_f1_map_torch.jpg", "f1_map"), ("after_stairs_torch.jpg", "stairs"),
		("after_f2_well_torch.jpg", "f2_well"), ("after_f2_wide.jpg", "f2_wide"), ("after_f3_wide.jpg", "f3_wide"),
		("after_f3_scare_torch.jpg", "f3_scare"), ("after_facade.jpg", "facade"), ("ch3_after_far_stand.jpg", "far_stand")]
	size = (640, 360)
	out = Image.new("RGB", (4 * (size[0] + 8) - 8, 70 + 3 * (size[1] + 8)), (20, 20, 20))
	label(out, "T-265 đợt 8 lượt 2 (D-185): thư viện ba tầng và dải đất quanh nhà — chương 4 ban đêm (ảnh cuối: chương 3)", 28)
	for k, (file, view) in enumerate(picks):
		out.paste(tile(file, "", view, "", size), ((k % 4) * (size[0] + 8), 70 + (k // 4) * (size[1] + 8)))
	out.save(PREVIEWS / "overview.jpg", quality=84)
	print("wrote overview.jpg", out.size)


VIEW_NAMES.update({
	"f3_south_edge": "tầng 3, mép nam ô cầu thang: WellRail_F3S (xa bên trái: F3NE)",
	"f2_flight_two": "tầng 2, chân nhịp hai: WellRail_F2SE bịt khe đông, lối lên để hở",
	"f2_east_slot": "tầng 2, đầu nhịp một nhìn về nam: WellRail_F2NE bịt đầu bắc khe đông",
})


def round3():
	"""r3_well.jpg: round 3's railings (card 1.14, D-186), three views without and with the torch."""
	views = ["f3_south_edge", "f2_flight_two", "f2_east_slot"]
	size = (800, 450)
	head = 70
	out = Image.new("RGB", (len(views) * (size[0] + 8) - 8, head + 2 * (size[1] + 8)), (20, 20, 20))
	label(out, "T-265 lượt 3 (D-186): lan can bịt các chỗ còn rơi được của ô cầu thang — chương 4 ban đêm", 28)
	for c, view in enumerate(views):
		for r, (suffix, extra) in enumerate((("", "không đèn pin"), ("_torch", "đèn pin"))):
			out.paste(tile("r3_%s%s.jpg" % (view, suffix), "", view, extra, size), (c * (size[0] + 8), head + r * (size[1] + 8)))
	out.save(PREVIEWS / "r3_well.jpg", quality=84)
	print("wrote r3_well.jpg", out.size)


if __name__ == "__main__":
	if sys.argv[1:] == ["round2"]:
		round2()
	elif sys.argv[1:] == ["round3"]:
		round3()
	else:
		main()