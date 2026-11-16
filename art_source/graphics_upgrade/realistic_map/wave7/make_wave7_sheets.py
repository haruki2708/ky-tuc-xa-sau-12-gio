"""T-264 round 1: option sheets for the owner from previews/wave7/pilot_<shot>.jpg (capture_wave7.gd): one sheet per
question, same cameras across options, chapter 3's real scene at night, occlusion culling on unless marked.
Run: python -B art_source/graphics_upgrade/realistic_map/wave7/make_wave7_sheets.py
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


def tile(shot, name, view_name):
	path = PREVIEWS / f"pilot_{shot}.jpg"
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


if __name__ == "__main__":
	main()
