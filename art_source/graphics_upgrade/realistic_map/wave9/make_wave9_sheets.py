"""T-266 round 1: the owner's sheets (previews/wave9/options_*.jpg, survey_sheet_*.jpg) from the stills of capture_wave9.gd and
capture_wave9_pilot.gd, captions in Vietnamese.
Run: python -B art_source/graphics_upgrade/realistic_map/wave9/make_wave9_sheets.py
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PREV = HERE.parent / "previews/wave9"
TEX = ROOT / "game/assets/textures/graphics_pilot/realistic_map/wave9"
FONT = str(ROOT / "game/assets/fonts/be_vietnam_pro_regular.ttf")
BOLD = str(ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf")
CW, CH, CAP, TITLE = 640, 360, 34, 52


def cell(path, caption, size=(CW, CH)):
	src = PREV / path if not str(path).startswith("TEX:") else TEX / str(path)[4:]
	img = Image.open(src).convert("RGB")
	img = img.resize(size, Image.LANCZOS) if img.size[0] / img.size[1] > 1.5 else img.resize((size[0], int(size[0] * img.size[1] / img.size[0])), Image.LANCZOS).crop((0, 0) + size)
	out = Image.new("RGB", (size[0], size[1] + CAP), (24, 24, 24))
	out.paste(img, (0, CAP))
	ImageDraw.Draw(out).text((10, 6), caption, font=ImageFont.truetype(FONT, 18), fill=(240, 240, 235))
	return out


def sheet(name, title, rows, note=None):
	cols = max(len(r) for r in rows)
	w = cols * CW + (cols + 1) * 6
	h = TITLE + len(rows) * (CH + CAP + 6) + 6 + (40 if note else 0)
	out = Image.new("RGB", (w, h), (12, 12, 12))
	d = ImageDraw.Draw(out)
	d.text((10, 10), title, font=ImageFont.truetype(BOLD, 26), fill=(255, 255, 255))
	y = TITLE
	for row in rows:
		x = 6
		for item in row:
			if item is not None:
				out.paste(cell(*item), (x, y))
			x += CW + 6
		y += CH + CAP + 6
	if note:
		d.text((10, y + 4), note, font=ImageFont.truetype(FONT, 18), fill=(220, 220, 210))
	out.save(PREV / name, quality=88)
	print("T266_SHEET", name, out.size)


def main():
	sheet("options_slat.jpg", "Vạt giường 2 (tầng dưới, ngồi xổm nhìn) — PS1 / V1 ván ép liền / V2 giát nan / V2b ván ghép (đề xuất)", [
		[("survey_407_bed2_low_before_torch.jpg", "PS1 trước khi lật"), ("survey_407_bed2_low_after_torch.jpg", "PS1 sau khi lật: ván 0,86 m ở 70° xuyên tầng trên")],
		[("pilot_bed2_v1_before_torch.jpg", "V1 trước khi lật (vạt nằm dưới nệm)"), ("pilot_bed2_v1_n0_after_torch.jpg", "V1 sau khi lật (62°, rộng 0,72 m, dưới tầng trên)")],
		[("pilot_bed2_v2_before_torch.jpg", "V2 trước khi lật"), ("pilot_bed2_v2_n0_after_torch.jpg", "V2 (nan 9 cm, khe 7 cm): chữ vắt qua các nan")],
		[("pilot_bed2_v2b_before_torch.jpg", "V2b trước khi lật"), ("pilot_bed2_v2b_n0_after_torch.jpg", "V2b (9 tấm 14,5 cm, khe 1,6 cm): đọc được chữ")],
	], "V1: 12 tam giác, 3 vật liệu. V2, V2b: 348 tam giác (9 nan hoặc tấm, 2 thanh dọc, đinh), 4 vật liệu (4 lần vẽ, cộng bóng).")
	sheet("options_bedding.jpg", "Nệm, chăn, gối khi lật vạt (giường 2, V2b) — N0 như nay / N1 dựng theo ván / N2 rơi xuống sàn", [
		[("pilot_bed2_v2b_n0_after_torch.jpg", "N0 (như main): ván xuyên qua nệm, chăn, gối"), ("pilot_bed2_v2b_n1_after_torch.jpg", "N1: nệm, chăn, gối dựng nghiêng theo ván, sát tường")],
		[("pilot_bed2_v2b_n2_after_torch.jpg", "N2: nệm, chăn, gối rơi xuống sàn cạnh giường"), ("pilot_bed2_v2b_n1_side_torch.jpg", "N1 nhìn chéo từ lối đi")],
		[("pilot_bed2_v2b_n2_side_torch.jpg", "N2 nhìn chéo từ lối đi (không va chạm: đi xuyên)"), ("pilot_bed2_v1_n1_side_torch.jpg", "V1 + N1 nhìn chéo")],
	], "N1, N2 chỉ dời ba món Tripo có sẵn (furnished_prop), trả lại khi thoát; không thêm lưới. N2 có va chạm là đổi gameplay: chỉ làm khi chọn.")
	sheet("options_ink.jpg", "Chữ ở mặt dưới vạt (giường 2, V2b + N1, đèn pin, ngồi xổm cách khoảng 1 m)", [
		[("pilot_bed2_v2b_read_loang_torch.jpg", "Mực loang (bút dạ thấm vân gỗ, quệt nhòe) — đề xuất"), ("pilot_bed2_v2b_read_bi_torch.jpg", "Bút bi xanh tô đè nhiều lần")],
		[("pilot_bed2_v2b_read_khac_torch.jpg", "Khắc bằng vật nhọn (nét gỗ mới, mép tối)"), ("pilot_bed2_v2b_read_phieu_torch.jpg", "Thêm: mảnh phiếu photocopy dán, điền bút bi")],
		[("pilot_bed2_read_loang_torch.jpg", "So sánh: V2 nan hẹp che mất nhiều chữ"), ("pilot_bed2_read_phieu_torch.jpg", "V2 nan hẹp + mảnh phiếu: giấy bị cắt theo khe (không thật)")],
	], None)
	sheet("options_ink_beds.jpg", "Ba vạt ba mảnh (texture mực loang, mặt dưới 1,45 × 0,72 m)", [
		[("TEX:slat_1_loang.png", "Giường 1: Phiếu điều tra… / Giới tính: Nam / Tuổi: 20"), ("TEX:slat_2_loang.png", "Giường 2: …người sống sót… / Ngày sinh / Phòng: 407")],
		[("TEX:slat_4_loang.png", "Giường 4: …sau thảm họa động đất / Tòa: B / Họ và tên"), None],
	], "Ba vạt ba mảnh, đúng chữ mảnh phiếu của UI (UI_CH4_FORM_SCRAP_1/2/4 và các cột của ch4_form.gd). Texture 2048×1024, nén VRAM.")
	sheet("options_vent_hatch.jpg", "Ô thông gió (FakeVent) và tấm trần (FakeCeiling) — PS1 / mới / sau khi tìm (phương án phản hồi)", [
		[("survey_407_fake_vent_torch.jpg", "PS1: hộp tối + 6 thanh"), ("pilot_vent_torch.jpg", "Cửa chớp tôn sơn, lưới chắn côn trùng, muội"),
			("pilot_vent_open_torch.jpg", "Sau khi tìm: chớp treo lệch một vít")],
		[("survey_407_fake_ceiling_torch.jpg", "PS1: tấm kem 0,8 × 0,8"), ("pilot_hatch_h1_torch.jpg", "H1: nắp thăm trần tôn sơn có khung, 2 khóa"),
			("pilot_hatch_h2_torch.jpg", "H2: tấm thạch cao lỏng, một cạnh võng")],
		[("pilot_hatch_h1_open_torch.jpg", "H1 sau khi tìm: nắp hé xuống, thấy khoảng tối"), ("pilot_vent_ceiling_torch.jpg", "Cùng một góc: chớp mới và H1"), None],
	], "Chớp 144 tam giác (3 vật liệu + muội), H1 134, H2 62. Phản hồi tìm: script hình của lane B nghe tín hiệu searched, không sửa core.")
	sheet("options_door.jpg", "Cửa 407 bị phá — nhìn từ trong phòng (đèn pin). Hàng trên: main hiện nay. Hàng giữa: hình mẫu", [
		[("survey_407_door_00_torch.jpg", "Main 0 %"), ("survey_407_door_30_torch.jpg", "Main 30 %: vết nứt PS1 bị cánh che"),
			("survey_407_door_60_torch.jpg", "Main 60 %: cánh Tripo vẫn hiện, không thấy lỗ"), ("survey_407_door_80_torch.jpg", "Main 80 %: tay hộp xuyên cánh nguyên")],
		[("pilot_door_00_torch.jpg", "Mẫu 0 %"), ("pilot_door_30_torch.jpg", "Mẫu 30 %: nứt toác trên cánh thật"),
			("pilot_door_60_torch.jpg", "Mẫu 60 %: cánh thủng, mảnh gỗ toác"), ("pilot_door_80_torch.jpg", "Mẫu 80 %: tay xác thò qua lỗ")],
		[("pilot_door_30_close_torch.jpg", "Mẫu 30 % gần"), ("pilot_door_60_close_torch.jpg", "Mẫu 60 % gần: thấy hành lang qua lỗ"),
			("pilot_door_80_close_torch.jpg", "Mẫu 80 % gần"), ("pilot_door_80_corridor.jpg", "Mẫu 80 % từ hành lang (cần xác, xem ghi chú)")],
	], "Cánh vỡ = cánh cửa phòng của game (door_room.glb) cắt lỗ, giảm còn 2.300 tam giác, cùng texture; tay 444; nứt 18. Lỗ đặt dưới tờ nội quy phía hành lang.")
	sheet("options_ward_nurse.jpg", "Hai y tá chỉ có tiếng — Y1 rèm quây có bóng / Y2 cửa hé, tiếng từ hành lang / Y3 như nay (kết thật, độ sáng 1,0)", [
		[("pilot_ward_y1_all_k1_100.jpg", "Y1, khung K1 (như main)"), ("pilot_ward_y2_all_k1_100.jpg", "Y2, khung K1"), ("pilot_ward_y3_all_k1_100.jpg", "Y3, khung K1")],
		[("pilot_ward_y1_all_k2_100.jpg", "Y1, khung K2 (ngước 11°)"), ("pilot_ward_y2_all_k2_100.jpg", "Y2, khung K2"), ("pilot_ward_y3_all_k2_100.jpg", "Y3, khung K2")],
		[("pilot_ward_y1_all_corner.jpg", "Y1 nhìn từ góc phòng (sau rèm)"), ("pilot_ward_y2_all_corner.jpg", "Y2 nhìn từ góc phòng"), ("survey_ward_all_corner.jpg", "Main (PS1) từ góc phòng")],
	], "Y1: rèm 1.324 tam giác (kể cả lớp bóng), không thêm đèn: bóng là một lớp mờ trên nếp rèm. Y2: cửa và đoạn hành lang 144 tam giác; Nurse1/2 dời ra cửa.")
	sheet("options_ward_frame.jpg", "Khung hình kết — hàng 1: main (PS1); hàng 2: K1 (24°, như nay); hàng 3: K2 (11°). Rèm Y1, thân T1", [
		[("survey_ward_all_wake_100.jpg", "Main, kết thật, 1,0"), ("survey_ward_all_wake_145.jpg", "Main, kết thật, 1,45"),
			("survey_ward_alone_wake_100.jpg", "Main, một mình, 1,0"), ("survey_ward_alone_wake_145.jpg", "Main, một mình, 1,45")],
		[("pilot_ward_y1_all_k1_100.jpg", "K1, kết thật, 1,0"), ("pilot_ward_y1_all_k1_145.jpg", "K1, kết thật, 1,45"),
			("pilot_ward_y1_alone_k1_100.jpg", "K1, một mình, 1,0"), ("pilot_ward_y1_alone_k1_145.jpg", "K1, một mình, 1,45")],
		[("pilot_ward_y1_all_k2_100.jpg", "K2, kết thật, 1,0"), ("pilot_ward_y1_all_k2_145.jpg", "K2, kết thật, 1,45"),
			("pilot_ward_y1_alone_k2_100.jpg", "K2, một mình, 1,0"), ("pilot_ward_y1_alone_k2_145.jpg", "K2, một mình, 1,45")],
	], "Ánh sáng giữ nguyên (môi trường riêng, CeilingLight 0,75). Ở 1,45 chỉ thẻ tên trắng (UI lane D) cháy trắng; vải, trần, tường giữ màu.")
	sheet("options_ward_patient.jpg", "Trung trên giường (T1/T2) và hai giường bên ở kết một mình (khung K2, độ sáng 1,0)", [
		[("pilot_ward_y1_all_k2_100.jpg", "T1: chăn có dáng người, cẳng tay quấn băng, dây truyền"), ("pilot_ward_t2_all_k2_100.jpg", "T2: chỉ chăn có dáng người"),
			("pilot_ward_y1_side.jpg", "T1 nhìn từ bên giường")],
		[("pilot_ward_y1_alone_k2_100.jpg", "Một mình: ga phẳng, chăn gấp ở chân giường"), ("pilot_ward_rolled_alone_k2_100.jpg", "Một mình: nệm cuộn ở đầu giường"),
			("pilot_ward_rolled_alone_corner.jpg", "Nệm cuộn nhìn từ góc")],
	], "Giường inox 616 tam giác/giường, người bên cạnh 2.168, T1 2.030 (mỗi Bed_* dưới 8.000). Cả phòng mẫu khoảng 13.000 tam giác.")
	sheet("options_chapters.jpg", "Ô thông gió và tấm trần ở bốn chương — C1 giữ như nay (chỉ chương 3–4) / C2 có ở cả bốn chương", [
		[("survey_ch1_vent_ceiling_torch.jpg", "Chương 1 (cùng góc): không có ô thông gió, không có tấm trần"),
			("survey_ch3_vent_ceiling_torch.jpg", "Chương 3: có (PS1), vì Campus có ở chương 3")],
		[("survey_ch4_vent_ceiling_torch.jpg", "Chương 4 (main, PS1)"), ("pilot_vent_ceiling_torch.jpg", "Chương 4, hình mẫu (chớp mới, H1)")],
	], "Chương 1–2 không nạp Campus nên không có nhánh Room407 của ch4_anchors.tscn.")
	sheet("survey_sheet_407.jpg", "Khảo sát phòng 407 ở chương 4 thật (run_from room407; đèn tuýp tắt, đèn bàn 0,5; đèn pin)", [
		[("survey_407_room_door.jpg", "Từ cửa, không đèn pin"), ("survey_407_room_door_torch.jpg", "Từ cửa, đèn pin"), ("survey_407_room_door_flipped_80_torch.jpg", "Lật cả ba, cửa 80 %")],
		[("survey_407_bed1_before_torch.jpg", "Giường 1 trước"), ("survey_407_bed2_before_torch.jpg", "Giường 2 trước"), ("survey_407_bed4_before_torch.jpg", "Giường 4 trước")],
		[("survey_407_bed1_after_torch.jpg", "Giường 1 sau"), ("survey_407_bed2_after_torch.jpg", "Giường 2 sau"), ("survey_407_bed4_after_torch.jpg", "Giường 4 sau")],
		[("survey_407_fake_locker_torch.jpg", "FakeLocker (tủ Phúc mở sẵn)"), ("survey_407_fake_ceiling_torch.jpg", "FakeCeiling"), ("survey_407_fake_vent_torch.jpg", "FakeVent")],
		[("survey_407_door_00_torch.jpg", "Cửa 0 %"), ("survey_407_door_30_torch.jpg", "Cửa 30 %"), ("survey_407_door_60_torch.jpg", "Cửa 60 %")],
		[("survey_407_door_80_torch.jpg", "Cửa 80 %"), ("survey_407_door_80_corridor.jpg", "Cửa 80 % từ hành lang"), ("survey_ch3_room_door_torch.jpg", "Chương 3, từ cửa")],
	])
	sheet("survey_sheet_ward.jpg", "Khảo sát phòng bệnh (main): đúng khung Camera_Wake, hai kết, hai độ sáng; nhìn từ góc", [
		[("survey_ward_all_wake_100.jpg", "Kết thật, 1,0"), ("survey_ward_all_wake_145.jpg", "Kết thật, 1,45"), ("survey_ward_all_corner.jpg", "Kết thật, góc phòng")],
		[("survey_ward_alone_wake_100.jpg", "Một mình, 1,0"), ("survey_ward_alone_wake_145.jpg", "Một mình, 1,45"), ("survey_ward_alone_corner.jpg", "Một mình, góc phòng")],
	])


if __name__ == "__main__":
	main()
