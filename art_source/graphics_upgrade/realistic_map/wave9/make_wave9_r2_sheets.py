"""T-266 round 2: the review sheets (previews/wave9/compare_*.jpg) and overview.jpg from capture_wave9_r2.gd's before_* /
after_* stills (same camera, chapter 4's real scene) and round 1's survey_ward_* (main's ward). Captions in Vietnamese.
Run: python -B art_source/graphics_upgrade/realistic_map/wave9/make_wave9_r2_sheets.py
"""
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE))
import make_wave9_sheets as S  # noqa: E402  (cell, sheet; its main is guarded)

PREV = S.PREV


def crop_cell(path, box, caption, size=(S.CW, S.CH)):
	img = Image.open(PREV / path).convert("RGB").crop(box).resize(size, Image.LANCZOS)
	out = Image.new("RGB", (size[0], size[1] + S.CAP), (24, 24, 24))
	out.paste(img, (0, S.CAP))
	ImageDraw.Draw(out).text((10, 6), caption, font=ImageFont.truetype(S.FONT, 18), fill=(240, 240, 235))
	return out


def sheet_cells(name, title, rows, note=None):
	"""Like S.sheet, but each row item is a ready cell image (or a (path, caption) pair)."""
	cols = max(len(r) for r in rows)
	w = cols * S.CW + (cols + 1) * 6
	h = S.TITLE + len(rows) * (S.CH + S.CAP + 6) + 6 + (40 if note else 0)
	out = Image.new("RGB", (w, h), (12, 12, 12))
	d = ImageDraw.Draw(out)
	d.text((10, 10), title, font=ImageFont.truetype(S.BOLD, 26), fill=(255, 255, 255))
	y = S.TITLE
	for row in rows:
		x = 6
		for item in row:
			if item is not None:
				out.paste(item if isinstance(item, Image.Image) else S.cell(*item), (x, y))
			x += S.CW + 6
		y += S.CH + S.CAP + 6
	if note:
		d.text((10, y + 4), note, font=ImageFont.truetype(S.FONT, 18), fill=(220, 220, 210))
	out.save(PREV / name, quality=88)
	print("T266_SHEET", name, out.size)


def main():
	S.sheet("compare_407_room.jpg", "Phòng 407 chương 4 từ cửa (đèn pin) — trước (main) / sau", [
		[("before_407_room_torch.jpg", "Trước: chưa lật"), ("after_407_room_torch.jpg", "Sau: chưa lật")],
		[("before_407_room_flipped_torch.jpg", "Trước: lật cả ba (ván PS1 70°, đồ giường không động)"),
			("after_407_room_flipped_124_torch.jpg", "Sau: lật 1-2-4")],
		[("after_407_room_flipped_214_torch.jpg", "Sau: lật 2-1-4 (đồ nằm đúng chỗ như trên)"),
			("after_407_room_flipped_door80_torch.jpg", "Sau: lật cả ba, cửa hỏng 80 %")],
	])
	S.sheet("compare_407_bedding.jpg", "N2: nệm, chăn, gối rơi xuống sàn (không va chạm), mỗi giường một chỗ, thứ tự nào cũng vậy", [
		[("before_407_bunkA_flipped_torch.jpg", "Trước: giường tầng A lật (ván xuyên nệm)"), ("after_407_bunkA_flipped_124_torch.jpg", "Sau: lật 1-2-4")],
		[("after_407_bunkA_flipped_214_torch.jpg", "Sau: lật 2-1-4"), ("after_407_bunkB_flipped_124_torch.jpg", "Sau: giường tầng B (giường 4)")],
		[("after_407_floor_flipped_124_torch.jpg", "Sau: nhìn từ trên, lật 1-2-4"), ("after_407_floor_flipped_214_torch.jpg", "Sau: nhìn từ trên, lật 2-1-4")],
	], "Giường 1: nệm trước tầng A, gối, chăn trên nệm. Giường 2: nệm ra trước đầu chiếu, chăn trên nệm, gối cạnh. Giường 4: như giường 1.")
	S.sheet("compare_407_fall.jpg", "Đường rơi (0,55 s): tầng trên qua mép thanh chắn, chúc sát thành giường; tầng dưới ra thấp", [
		[("after_407_bunkA_fall_30_torch.jpg", "t 0,30: nhấc qua cột (đáy 1,53 m), tầng dưới đã ra ngoài"),
			("after_407_bunkA_fall_45_torch.jpg", "t 0,45: chúc qua mép thanh chắn")],
		[("after_407_bunkA_fall_60_torch.jpg", "t 0,60: rơi đứng sát thành giường"), ("after_407_bunkA_fall_80_torch.jpg", "t 0,80: đổ ra, nằm xuống")],
		[("after_407_bunkB_fall_45_torch.jpg", "Giường 4, t 0,45"), ("after_407_bunkB_fall_80_torch.jpg", "Giường 4, t 0,80")],
	])
	S.sheet("compare_407_slats.jpg", "Vạt V2b, chữ mực loang ba mảnh (đọc dưới đèn pin) — trước / sau", [
		[("before_407_bed1_read_torch.jpg", "Trước: giường 1"), ("after_407_bed1_read_torch.jpg", "Sau: giường 1 (70°)")],
		[("before_407_bed2_read_torch.jpg", "Trước: giường 2"), ("after_407_bed2_read_torch.jpg", "Sau: giường 2 (62°, dưới tầng trên)")],
		[("before_407_bed4_read_torch.jpg", "Trước: giường 4"), ("after_407_bed4_read_torch.jpg", "Sau: giường 4 (70°)")],
		[("before_407_bed2_low_torch.jpg", "Trước: giường 2 ngồi xổm"), ("after_407_bed2_low_torch.jpg", "Sau: giường 2 ngồi xổm")],
	])
	S.sheet("compare_407_spots.jpg", "Nắp trần H1, cửa chớp thông gió (C2), phản hồi khi tìm xong — trước / sau / sau khi tìm", [
		[("before_407_fake_ceiling_torch.jpg", "Trước: tấm trần PS1"), ("after_407_fake_ceiling_torch.jpg", "Sau: nắp thăm trần"),
			("after_407_fake_ceiling_searched_torch.jpg", "Sau khi tìm: nắp hé xuống 28°")],
		[("before_407_fake_vent_torch.jpg", "Trước: ô thông gió PS1"), ("after_407_fake_vent_torch.jpg", "Sau: cửa chớp tôn sơn, lưới, muội"),
			("after_407_fake_vent_searched_torch.jpg", "Sau khi tìm: treo lệch một vít")],
		[("before_407_fake_locker_torch.jpg", "Trước: tủ Phúc (mở sẵn)"), ("after_407_fake_locker_torch.jpg", "Sau: tủ Phúc giữ nguyên"),
			("after_407_vent_ceiling_searched_torch.jpg", "Sau khi tìm: cả hai, nhìn chung")],
	])
	S.sheet("compare_407_door.jpg", "Cửa 407 bị phá, từ trong phòng — trước (main: hư hại nằm sau cánh) / sau", [
		[("before_407_door_00_torch.jpg", "Trước 0 %"), ("after_407_door_00_torch.jpg", "Sau 0 %")],
		[("before_407_door_30_torch.jpg", "Trước 30 %"), ("after_407_door_30_torch.jpg", "Sau 30 %: nứt toác trên cánh thật")],
		[("before_407_door_60_close_torch.jpg", "Trước 60 %: không thấy lỗ"), ("after_407_door_60_close_torch.jpg", "Sau 60 %: cánh vỡ, thấy hành lang")],
		[("before_407_door_80_close_torch.jpg", "Trước 80 %: tay hộp xuyên cánh nguyên"), ("after_407_door_80_close_torch.jpg", "Sau 80 %: tay xác, tay áo hoodie rách")],
	])
	S.sheet("compare_407_corridor.jpg", "Cửa 407 từ hành lang, bốn xác tự đi tới cửa rồi dừng (chương 4 thật)", [
		[("before_407_door_60_corridor_crowd.jpg", "Trước 60 %"), ("after_407_door_60_corridor_crowd.jpg", "Sau 60 %")],
		[("before_407_door_80_corridor_crowd.jpg", "Trước 80 %"), ("after_407_door_80_corridor_crowd.jpg", "Sau 80 %")],
		[("before_407_door_80_corridor_close.jpg", "Trước 80 %, gần"), ("after_407_door_80_corridor_close.jpg", "Sau 80 %, gần: xác che kín lỗ và tay")],
	])
	S.sheet("compare_ch1.jpg", "C2: phòng 407 ở chương 1, cùng góc — trước / sau", [
		[("before_ch1_vent_ceiling_torch.jpg", "Trước"), ("after_ch1_vent_ceiling_torch.jpg", "Sau: cửa chớp và nắp thăm trần (chỉ là hình)")],
		[("before_ch1_room_door_torch.jpg", "Trước, từ cửa"), ("after_ch1_room_door_torch.jpg", "Sau, từ cửa")],
	])
	S.sheet("compare_ward.jpg", "Phòng bệnh, khung Camera_Wake — trước (main, K1 24°) / sau (K2 11°)", [
		[("survey_ward_all_wake_100.jpg", "Trước, kết thật, độ sáng 1,0"), ("after_ward_all_wake_100.jpg", "Sau, kết thật, 1,0")],
		[("survey_ward_all_wake_145.jpg", "Trước, kết thật, 1,45"), ("after_ward_all_wake_145.jpg", "Sau, kết thật, 1,45")],
		[("survey_ward_alone_wake_100.jpg", "Trước, kết một mình, 1,0"), ("after_ward_alone_wake_100.jpg", "Sau, kết một mình, 1,0")],
		[("survey_ward_alone_wake_145.jpg", "Trước, kết một mình, 1,45"), ("after_ward_alone_wake_145.jpg", "Sau, kết một mình, 1,45")],
	])
	sheet_cells("compare_ward_detail.jpg", "Phòng bệnh: thẻ tên từ mắt Trung (cắt khung K2, 1,45), góc phòng", [
		[crop_cell("after_ward_all_wake_145.jpg", (80, 480, 560, 750), "Kết thật: thẻ Ngư (bên trái khung)"),
			crop_cell("after_ward_all_wake_145.jpg", (1040, 480, 1520, 750), "Kết thật: thẻ Nhật (bên phải khung)")],
		[("after_ward_all_corner.jpg", "Kết thật, từ góc phòng"), ("after_ward_alone_corner.jpg", "Kết một mình, từ góc phòng")],
		[("after_ward_all_side.jpg", "Kết thật, cạnh giường Trung"), ("after_ward_alone_side.jpg", "Kết một mình, cạnh giường Trung")],
	])
	overview()


def overview():
	"""One page: the main pairs, small."""
	pairs = [("before_407_room_flipped_torch.jpg", "after_407_room_flipped_124_torch.jpg", "407 lật cả ba"),
		("before_407_bed2_read_torch.jpg", "after_407_bed2_read_torch.jpg", "Vạt giường 2"),
		("before_407_fake_vent_torch.jpg", "after_407_fake_vent_searched_torch.jpg", "Thông gió (sau: đã tìm)"),
		("before_407_door_80_close_torch.jpg", "after_407_door_80_close_torch.jpg", "Cửa 80 %"),
		("before_407_door_80_corridor_close.jpg", "after_407_door_80_corridor_close.jpg", "Hành lang, có xác"),
		("before_ch1_vent_ceiling_torch.jpg", "after_ch1_vent_ceiling_torch.jpg", "Chương 1 (C2)"),
		("survey_ward_all_wake_145.jpg", "after_ward_all_wake_145.jpg", "Kết thật 1,45"),
		("survey_ward_alone_wake_100.jpg", "after_ward_alone_wake_100.jpg", "Kết một mình 1,0")]
	cw, ch, cap = 480, 270, 26
	cols = 4
	rows = (len(pairs) + 1) // 2
	w = cols * cw + (cols + 1) * 5
	h = 50 + rows * (ch + cap + 5) + 5
	out = Image.new("RGB", (w, h), (12, 12, 12))
	d = ImageDraw.Draw(out)
	d.text((10, 10), "T-266 lượt 2 — đợt 9: phòng 407 ở chương 4, phòng bệnh của đoạn kết (mỗi cặp: trước | sau)",
		font=ImageFont.truetype(S.BOLD, 24), fill=(255, 255, 255))
	small = ImageFont.truetype(S.FONT, 16)
	for i, (before, after, label) in enumerate(pairs):
		r, c = divmod(i, 2)
		for k, (path, tag) in enumerate(((before, "trước"), (after, "sau"))):
			x = 5 + (c * 2 + k) * (cw + 5)
			y = 50 + r * (ch + cap + 5)
			img = Image.open(PREV / path).convert("RGB").resize((cw, ch), Image.LANCZOS)
			out.paste(img, (x, y + cap))
			d.text((x + 6, y + 4), "%s — %s" % (label, tag), font=small, fill=(235, 235, 230))
	out.save(PREV / "overview.jpg", quality=88)
	print("T266_SHEET overview.jpg", out.size)


if __name__ == "__main__":
	main()
