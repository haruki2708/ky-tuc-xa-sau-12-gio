"""T-264 round 1: option sheets for the owner from previews/wave7/pilot_<shot>.jpg (capture_wave7.gd): one sheet per
question, same cameras across options, chapter 3's real scene at night, occlusion culling on unless marked.
--round2: round 2's before/after sheets (r2_*.jpg) from capture_wave7_r2.gd (D-182 picks, scenes patched).
--round3: round 3's sheets (r3_*.jpg, capture_wave7_r3.gd) and overview.jpg.
Run: python -B art_source/graphics_upgrade/realistic_map/wave7/make_wave7_sheets.py [--round2 | --round3]
"""
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

sys.dont_write_bytecode = True
sys.stdout.reconfigure(encoding="utf-8")
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PREVIEWS = HERE.parent / "previews" / "wave7"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
SIZE = (800, 450)
VIEW = {"a_garden": "nhà A từ vườn", "a_foot": "chân nhà A, cửa chính", "a_foot_torch": "chân nhà A, đèn pin", "a_window": "ô cửa có bóng người (tầng 3)",
	"a_corridor4": "từ hành lang tầng 4 nhà B", "gym_corner": "góc nhà thể chất", "gym_door_torch": "cửa chính nhà thể chất, đèn pin",
	"gym_door_occoff": "cửa nhà thể chất, tắt khối che", "b_upper": "nhà B tầng 5–6 từ vườn", "b_back_torch": "mặt sau nhà B tầng 1–3, đèn pin",
	"road": "đại lộ đoạn mẫu", "road_trees": "cây ven đường", "road_lamp": "đèn đường, ghế, xe máy đổ", "road_trees_torch": "cây, đèn pin",
	"fence": "hàng rào tây", "fence_torch": "hàng rào tây, đèn pin", "w_corridor4": "toàn cảnh từ hành lang tầng 4", "w_garden": "toàn cảnh giữa vườn",
	"w_stand": "toàn cảnh từ khán đài"}


def font(size):
	return ImageFont.truetype(str(FONT), size)


def label(img, text, size=22, at=(0, 0)):
	draw = ImageDraw.Draw(img)
	f = font(size)
	box = draw.textbbox((0, 0), text, font=f)
	draw.rectangle([at[0], at[1], at[0] + box[2] + 20, at[1] + box[3] + 12], fill=(0, 0, 0))
	draw.text((at[0] + 10, at[1] + 4), text, font=f, fill=(240, 240, 235))


PREFIX = "pilot_"


def tile(shot, name, view_name):
	path = PREVIEWS / f"{PREFIX}{shot}.jpg"
	img = Image.open(path).convert("RGB").resize(SIZE)
	label(img, name)
	label(img, view_name, 18, (0, SIZE[1] - 40))
	return img


def sheet(file, title, rows, note=""):
	"""rows: [(row label, [(shot, view key), ...])]."""
	cols = max(len(r[1]) for r in rows)
	head = 110 if note else 70
	out = Image.new("RGB", (cols * (SIZE[0] + 8), head + len(rows) * (SIZE[1] + 8)), (20, 20, 20))
	label(out, title, 28)
	if note:
		ImageDraw.Draw(out).text((12, 66), note, font=font(20), fill=(205, 205, 195))
	for r, (name, shots) in enumerate(rows):
		for c, (shot, view) in enumerate(shots):
			out.paste(tile(shot, name, VIEW[view]), (c * (SIZE[0] + 8), head + r * (SIZE[1] + 8)))
	out.save(PREVIEWS / file, quality=82)
	print("wrote", file, out.size)


def main():
	a_views = ["a_garden", "a_foot", "a_window", "a_corridor4"]
	sheet("options_interior.jpg", "T-264 · Nội thất nhìn qua cửa (nhà A, kiểu A2, tường vàng)", [
		("Trước (PS1)", [("before_" + v, v) for v in a_views]),
		("a · phòng thật tầng trệt + sảnh, tầng trên kính tối có rèm", [("interior_a_" + v, v) for v in a_views]),
		("b · phòng giả bằng shader sau mọi ô cửa", [("interior_b_" + v, v) for v in a_views]),
		("c · chỉ sảnh cửa chính, còn lại kính tối có rèm", [("interior_c_" + v, v) for v in a_views])],
		"Phòng giả (b) là một tấm phẳng 0,3 m sau kính, shader vẽ phòng sâu 3,2 m (giường tầng, tủ). Không thêm đèn: đèn pin rọi vào thấy phòng.")
	sheet("options_occlusion.jpg", "T-264 · Bật / tắt khối che (occlusion culling) của core", [
		("a · bật", [("interior_a_a_foot", "a_foot"), ("interior_a_a_corridor4", "a_corridor4")]),
		("a · tắt", [("interior_a_a_foot_occoff", "a_foot"), ("interior_a_a_corridor4_occoff", "a_corridor4")]),
		("b · bật", [("interior_b_a_foot", "a_foot"), ("interior_b_a_corridor4", "a_corridor4")]),
		("A1 hành lang · bật", [("gallery_a_foot", "a_foot"), ("gallery_a_corridor4", "a_corridor4")]),
		("A1 hành lang · tắt", [("gallery_a_foot_occoff", "a_foot"), ("gallery_a_corridor4_occoff", "a_corridor4")])],
		"Khối che chỉ bỏ vật khi cả hộp bao nằm sau nó; độ sâu cần ghi trong Handoff để integrator thu hộp vào.")
	sheet("options_building_a.jpg", "T-264 · Kiểu nhà A", [
		("A2 · tường có cửa sổ từng phòng", [("interior_b_a_garden", "a_garden"), ("interior_b_a_foot", "a_foot"), ("interior_b_a_corridor4", "a_corridor4")]),
		("A1 · hành lang hở có lan can như nhà B", [("gallery_a_garden", "a_garden"), ("gallery_a_foot", "a_foot"), ("gallery_a_corridor4", "a_corridor4")])])
	sheet("options_wall_colour.jpg", "T-264 · Màu tường nhà nền", [
		("Vàng như nhà ăn", [("interior_b_a_garden", "a_garden"), ("gym_r1_gym_corner", "gym_corner")]),
		("Kem xám, khác nhà B", [("grey_a_garden", "a_garden"), ("grey_gym_corner", "gym_corner")])])
	sheet("options_gym_roof.jpg", "T-264 · Nhà thể chất (giảng đường cùng kiểu)", [
		("Trước (PS1)", [("before_gym_corner", "gym_corner"), ("before_gym_door", "gym_door_torch")]),
		("R1 · mái bằng, lam bê tông", [("gym_r1_gym_corner", "gym_corner"), ("gym_r1_gym_door_torch", "gym_door_torch")]),
		("R2 · mái tôn vòm", [("gym_r2_gym_corner", "gym_corner"), ("gym_r2_gym_door_torch", "gym_door_torch")])])
	sheet("options_b_outside.jpg", "T-264 · Mặt ngoài nhà B (tầng 5–6 phía trước, tầng 1–3 phía sau)", [
		("Trước (PS1)", [("before_b_upper", "b_upper"), ("before_b_back", "b_back_torch")]),
		("Phòng giả sau kính", [("b_fake_b_upper", "b_upper"), ("b_fake_b_back_torch", "b_back_torch")]),
		("Kính tối có rèm", [("b_dark_b_upper", "b_upper"), ("b_dark_b_back_torch", "b_back_torch")])],
		"Tầng 5–6 làm hành lang bị chặn (đồng bộ tầng dưới); mặt sau giữ tường phòng thật, cửa sổ phẳng ngoài mặt tường.")
	g_views = ["road", "road_trees", "road_lamp", "road_trees_torch"]
	sheet("options_ground.jpg", "T-264 · Mặt đường, vỉa, lề, cây, đèn đường (đại lộ x 112…176)", [
		("Trước (PS1)", [("before_road", "road"), ("before_road_trees", "road_trees"), ("before_road_lamp", "road_lamp"), ("before_road_trees", "road_trees")]),
		("Nhựa cũ có vá + cỏ úa và đất + cột thép cần vươn", [("ground_asphalt_" + v, v) for v in g_views]),
		("Bê tông tấm + lát block + cột bê tông ly tâm", [("ground_slab_" + v, v) for v in g_views])],
		"Cây: bàng (x 120, 168), phượng vĩ (x 136), xà cừ (x 152); mật độ giữ như nay. Ghế đá, xe máy đổ đúng chỗ PS1.")
	sheet("options_fence.jpg", "T-264 · Hàng rào bắc, đông, tây (đoạn mẫu phía tây)", [
		("Trước (PS1)", [("before_fence", "fence"), ("before_fence", "fence_torch")]),
		("W1 · như tường rào nam (D-180)", [("fence_w1", "fence"), ("fence_w1_torch", "fence_torch")]),
		("B40 · lưới trên cột ống", [("fence_b40", "fence"), ("fence_b40_torch", "fence_torch")])])
	sheet("wide_views.jpg", "T-264 · Ba góc toàn cảnh, trước / góc mẫu (khối che bật)", [
		("Trước (PS1)", [("before_w_corridor4", "w_corridor4"), ("before_w_garden", "w_garden"), ("before_w_stand", "w_stand")]),
		("Góc mẫu (A2, phòng giả, R1, nhựa, cỏ, cột thép, W1)", [("after_w_corridor4", "w_corridor4"), ("after_w_garden", "w_garden"), ("after_w_stand", "w_stand")])])

VIEW.update({"a_window": "ô cửa bóng người thứ hai (x 18)", "a_window2": "ô cửa bóng người thứ ba (x 31 → 32)", "a_corner": "góc đông nhà A",
	"a_window_torch": "ô cửa bóng người, đèn pin", "a_corridor4": "nhà A từ hành lang tầng 4 nhà B (x 37)",
	"a_corridor4_torch": "từ hành lang tầng 4, đèn pin (12 m, không tới nhà A)", "a_foot_occoff": "chân nhà A, tắt khối che",
	"a_corridor4_occoff": "từ hành lang tầng 4, tắt khối che", "lecture": "giảng đường, cửa chính", "lecture_corner": "góc đông giảng đường",
	"lecture_occoff": "giảng đường, tắt khối che", "gym_door": "cửa chính nhà thể chất", "b_upper_near": "nhà B tầng 5–6 nhìn lên",
	"b_upper_eye": "nhà B tầng 5–6 ngang tầm (camera bay)", "b_upper_near_occoff": "nhà B tầng 5–6, tắt khối che", "b_back": "mặt sau nhà B",
	"b_back_wide": "mặt sau nhà B, xa", "ch1_corridor4": "chương 1: từ hành lang tầng 4 (x 37)", "ch1_corridor4_wide": "chương 1: hành lang tầng 4 (x 20, khăn phơi che)"})


def round2():
	global PREFIX
	PREFIX = "r2_"
	pair = lambda views: [("Trước (main)", [("before_" + v, v) for v in views]), ("Sau (lượt 2)", [("after_" + v, v) for v in views])]
	sheet("r2_building_a.jpg", "T-264 lượt 2 · Nhà A (A2, vàng, phòng giả sau mọi ô cửa, ba bóng người)",
		pair(["a_garden", "a_foot", "a_corner"]) + pair(["a_window", "a_window2", "a_corridor4"]),
		"Bóng người thứ ba dời từ x 31 (trúng trụ) vào ô cửa x 31,5…33,5 (D-182 mục 8). Không thêm đèn.")
	sheet("r2_lecture_gym.jpg", "T-264 lượt 2 · Giảng đường (R1, lam bê tông) và nhà thể chất (R2, mái tôn vòm)",
		pair(["lecture", "lecture_corner", "gym_corner", "gym_door"]))
	sheet("r2_building_b.jpg", "T-264 lượt 2 · Mặt ngoài nhà B (tầng 5–6 hành lang bị chặn, mặt sau tầng 1–3 và 5–6, vỏ hai tháp cầu thang)",
		pair(["b_upper", "b_upper_eye", "b_back", "b_back_wide"]),
		"Hai tháp cầu thang có vỏ mới (lớp ngoài 4 mm, ô thoáng, mái). Tầng 4 phía sau (ban công T-255) giữ như cũ; cửa sổ phòng quản lý (lối thoát) để trống.")
	sheet("r2_torch_occlusion.jpg", "T-264 lượt 2 · Đèn pin và khối che bật / tắt", [
		("Đèn pin", [("after_a_foot_torch", "a_foot_torch"), ("after_a_window_torch", "a_window_torch"), ("after_gym_door_torch", "gym_door_torch"),
			("after_a_corridor4_torch", "a_corridor4_torch")]),
		("Khối che bật", [("after_a_foot", "a_foot"), ("after_lecture", "lecture"), ("after_gym_door", "gym_door"), ("after_b_upper_near", "b_upper_near")]),
		("Khối che tắt", [("after_a_foot_occoff", "a_foot_occoff"), ("after_lecture_occoff", "lecture_occoff"), ("after_gym_door_occoff", "gym_door_occoff"),
			("after_b_upper_near_occoff", "b_upper_near_occoff")])],
		"Bật và tắt khối che cho ảnh như nhau: không vật nào bị ẩn sai.")
	sheet("r2_wide_chapter1.jpg", "T-264 lượt 2 · Ba góc toàn cảnh và nhà A bản nhẹ chương 1–2", [
		("Trước (main)", [("before_w_corridor4", "w_corridor4"), ("before_w_garden", "w_garden"), ("before_w_stand", "w_stand")]),
		("Sau (lượt 2)", [("after_w_corridor4", "w_corridor4"), ("after_w_garden", "w_garden"), ("after_w_stand", "w_stand")]),
		("Chương 1: trước / sau", [("before_ch1_corridor4", "ch1_corridor4"), ("after_ch1_corridor4", "ch1_corridor4"), ("after_ch1_corridor4_wide", "ch1_corridor4_wide")])],
		"Bản nhẹ: vỏ A2 kính tối, không phòng giả, không song sắt, không bóng người, không bóng đổ, không va chạm.")

VIEW.update({"road": "đại lộ (x 125, nhìn đông)", "road_props": "đại lộ: ghế, xe máy, đèn, xe đạp", "road_west": "đại lộ phía tây: ô tô, biển, cột đèn đổ",
	"trees_b": "cây phượng sau nhà B", "shelter": "mái che xe đạp", "kiosk": "ki-ốt ở góc nhà ăn", "east_branch": "nhánh đông (x 310)",
	"north_loop": "đường vòng bắc sân vận động", "fence_w": "hàng rào tây", "fence_n": "hàng rào bắc", "lecture_fc": "sân trước giảng đường",
	"gym_fc": "sân trước nhà thể chất", "b_back": "ban công tầng 4 sau nhà B", "road_props_torch": "đại lộ, đèn pin",
	"fence_w_torch": "hàng rào tây, đèn pin", "shelter_torch": "mái che xe, đèn pin", "trees_b_torch": "cây sau nhà B, đèn pin",
	"ch4_lecture": "chương 4: sân trước giảng đường", "ch4_library_way": "chương 4: đường sang thư viện"})


def round3():
	global PREFIX
	PREFIX = "r3_"
	pair = lambda views: [("Trước (main)", [("before_" + v, v) for v in views]), ("Sau (lượt 3)", [("after_" + v, v) for v in views])]
	sheet("r3_roads.jpg", "T-264 lượt 3 · Đường nhựa cũ, vạch mờ, vỉa quét vôi, lề cỏ úa và đất, đèn thép cần vươn",
		pair(["road", "road_props", "road_west", "east_branch"]),
		"Ghế, xe máy, ô tô, biển, cột đèn đổ, gạch vụn, giấy làm lại đúng chỗ PS1 (365 bản thu về 0). Vệt nứt, vệt kéo giữ nguyên.")
	sheet("r3_trees_props.jpg", "T-264 lượt 3 · Cây (bàng, phượng, xà cừ), mái che xe, ki-ốt, đường vòng bắc",
		pair(["trees_b", "shelter", "kiosk", "north_loop"]))
	sheet("r3_fences_forecourts.jpg", "T-264 lượt 3 · Hàng rào B40 bắc, đông, tây; sân trước lát block; ban công tầng 4 đổi màu",
		pair(["fence_w", "fence_n", "lecture_fc", "gym_fc", "b_back"]),
		"Ngoài hàng rào: dải cỏ 40 m (tường PS1 che, lưới B40 thì nhìn xuyên). Ban công 401–408 cùng màu mặt sau mới.")
	sheet("r3_wide.jpg", "T-264 lượt 3 · Ba góc toàn cảnh và chương 4 (khối che bật)",
		pair(["w_corridor4", "w_garden", "w_stand"]) + [("Chương 4: trước / sau", [("before_ch4_lecture", "ch4_lecture"),
		("after_ch4_lecture", "ch4_lecture"), ("after_ch4_library_way", "ch4_library_way")])],
		"Số lần vẽ (cùng lần chạy): hành lang tầng 4 1.933 → 1.924, giữa vườn 316 → 292, khán đài 4.502 → 4.463.")
	sheet("r3_torch.jpg", "T-264 lượt 3 · Đèn pin (12 m)", [("Đèn pin", [("after_road_props_torch", "road_props_torch"),
		("after_fence_w_torch", "fence_w_torch"), ("after_shelter_torch", "shelter_torch"), ("after_trees_b_torch", "trees_b_torch")])])
	sheet("overview.jpg", "T-264 · Đồ hoạ thật đợt 7: nhà nền, mặt ngoài nhà B, mặt đất, đường, cây, đèn, hàng rào (chương 3, ban đêm)", [
		("Lượt 3", [("after_w_corridor4", "w_corridor4"), ("after_w_garden", "w_garden"), ("after_w_stand", "w_stand")]),
		("Lượt 3", [("after_road", "road"), ("after_shelter", "shelter"), ("after_fence_w", "fence_w")]),
		("Lượt 3", [("after_lecture_fc", "lecture_fc"), ("after_b_back", "b_back"), ("after_road_props", "road_props")])])

if __name__ == "__main__":
	round3() if "--round3" in sys.argv else (round2() if "--round2" in sys.argv else main())
