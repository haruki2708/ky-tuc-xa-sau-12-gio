"""T-267 sheets (card section 6) in previews/wave10/. Round 1 (argument r1): survey_*, pilot_*, options_*.jpg from the
stills of survey_wave10.gd and capture_wave10_pilot.gd. Round 2 (default, r2): compare_rooms.jpg, compare_1080.jpg,
a30_compare.jpg, sync.jpg and overview.jpg from capture_wave10.gd's stills. Feeds are shown at x3 with nearest-neighbour
pixels, and also as the phone's Camera tab draws them (ui/phone/cctv.gdshader: grey, sampled on a 320 x 180 grid, every
other row at 78 %, grain).
Run: python -B art_source/graphics_upgrade/realistic_map/wave10/make_wave10_sheets.py [r1] [r2]
"""
from pathlib import Path
import random
import re
import sys

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PREVIEWS = HERE.parent / "previews/wave10"
SURVEY = HERE / "survey"
FONT = str(ROOT / "game/assets/fonts/be_vietnam_pro_regular.ttf")
BOLD = str(ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf")
FEED_W, FEED_H = 480, 360


def feeds_log():
	"""stem -> (draws, prims) from the capture logs."""
	found = {}
	for log in ("feeds.txt", "pilot_pilot.txt"):
		path = SURVEY / log
		if not path.exists():
			continue
		for line in path.read_text(encoding="utf-8").splitlines():
			m = re.match(r"FEED: (\S+) \S+ .*?feed draws (\d+) prims (\d+)", line)
			if m:
				found[m.group(1)] = (int(m.group(2)), int(m.group(3)))
	return found


LOG = feeds_log()


def phone(path):
	"""The feed as cctv.gdshader draws it (grain from a fixed seed)."""
	raw = SURVEY / "feeds" / (Path(path).name.replace("_feed.jpg", ".png"))
	if not raw.exists():
		raw = SURVEY / "feeds" / ("r2_" + Path(path).name.replace("_feed.jpg", ".png"))
	src = Image.open(raw).convert("RGB") if raw.exists() else Image.open(path).convert("RGB").resize((320, 240), Image.NEAREST)
	rng = random.Random(7)
	out = Image.new("L", (320, 180))
	px = out.load()
	sp = src.load()
	for y in range(180):
		sy = min(int((y + 0.5) / 180 * 240), 239)
		scan = 0.78 if y % 2 == 0 else 1.0
		for x in range(320):
			r, g, b = sp[x, sy]
			grey = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
			value = grey * scan + (rng.random() - 0.5) * 0.12
			px[x, y] = max(0, min(255, int(value * 255)))
	return out.resize((FEED_W, FEED_H), Image.NEAREST).convert("RGB")


def tile(path, size, caption=None, phone_look=False):
	path = PREVIEWS / path
	if phone_look:
		im = phone(path)
	else:
		im = Image.open(path).convert("RGB")
		im = im.resize(size, Image.NEAREST if path.name.endswith("_feed.jpg") else Image.LANCZOS)
	if im.size != size:
		im = im.resize(size, Image.NEAREST)
	if caption:
		d = ImageDraw.Draw(im)
		f = ImageFont.truetype(FONT, 15)
		w = d.textlength(caption, font=f)
		d.rectangle((0, 0, w + 14, 24), fill=(0, 0, 0))
		d.text((7, 3), caption, font=f, fill=(240, 240, 230))
	return im


def sheet(name, title, rows, notes=()):
	"""rows: [[(file, size, caption, phone_look), ...], ...]"""
	pad = 8
	width = max(sum(c[1][0] for c in row) + pad * (len(row) + 1) for row in rows)
	head = 48 + 24 * len(notes)
	height = head + sum(max(c[1][1] for c in row) + pad for row in rows) + pad
	out = Image.new("RGB", (width, height), (24, 24, 26))
	d = ImageDraw.Draw(out)
	d.text((pad, 8), title, font=ImageFont.truetype(BOLD, 24), fill=(255, 255, 255))
	for i, note in enumerate(notes):
		d.text((pad, 42 + 24 * i), note, font=ImageFont.truetype(FONT, 17), fill=(215, 215, 205))
	y = head
	for row in rows:
		x = pad
		for file, size, caption, look in row:
			out.paste(tile(file, size, caption, look), (x, y))
			x += size[0] + pad
		y += max(c[1][1] for c in row) + pad
	out.save(PREVIEWS / name, quality=88)
	print("sheet", name, out.size)


def draws(stem):
	value = LOG.get(stem)
	return "%d lần vẽ, %dk tam giác" % (value[0], round(value[1] / 1000)) if value else ""


F = (FEED_W, FEED_H)
HD = (640, 360)


def survey():
	rows = []
	for number, pose in (("102", "Hùng mở cửa"), ("306", "Kiệt, điện thoại sáng"), ("209", "Bảo co người"),
			("106", "Đăng ngồi dậy, đèn bàn"), ("310", "ba xác lao tới (chương 2)")):
		rows.append([
			("survey_%s_hall_feed.jpg" % number, F, "%s hành lang · %s" % (number, draws("survey_%s_hall" % number)), False),
			("survey_%s_room_feed.jpg" % number, F, "%s phòng · %s" % (number, draws("survey_%s_room" % number)), False),
			("survey_%s_room_feed.jpg" % number, F, "như trên điện thoại (xám, 320 × 180)", True),
			("survey_%s_room_1080.jpg" % number, HD, "%s · cùng camera, 1080p · %s" % (number, pose), False),
		])
	sheet("survey_feeds.jpg", "Hiện trạng (main): feed 320 × 240 phóng ×3, như điện thoại, và 1080p cùng camera", rows, [
		"Chương 1: director._cctv_scene() như test_cctv, quản lý giữ yên giữa hành lang và ở ManagerSpot; 310: chương 2, director._cctv_310().",
		"Lần vẽ, tam giác: của riêng SubViewport feed (RenderingServer). Feed hành lang thấy cả hành lang, phòng các phòng bên (không có occluder).",
	])


A30 = [
	("notebook", "Sổ Đạt (DatNote): 9 hộp, 108 tam giác · ch1_models/dat_notebook.tscn (B)"),
	("songbook", "Sổ hợp âm guitar: sổ + 10 hộp dây/phím, 228 · ch1v2/guitar_songbook.tscn (B)"),
	("outlet", "Ổ điện Khoa: 9 hộp, 108 · room407/khoa_outlet.tscn (B)"),
	("khoa_note", "Giấy Khoa (Ch1KhoaNote): 2 · interaction/readable.tscn (A), director đặt"),
	("trash_paper", "Giấy trong thùng rác: 3 lăng trụ + giấy xé, 42 · ch1v2/trash_bin, torn_paper (B)"),
	("shower_buttons", "Nút tắm Có/Không: 2 hộp trắng không vật liệu, 24 · room407_anchors.tscn (B)"),
	("router_led", "LED router: 1 hộp, 12 · ch1_models/router.tscn (B); router thật đã có"),
	("charger", "Bộ sạc Đạt: 5 hộp, 60 · ch1_models/charger.tscn (B); nằm trong tủ đóng, không thấy khi chơi"),
	("power_strip", "Ổ cắm nối dài: đã là hình thật (T-226), giữ"),
	("rules_paper", "Nội quy trên cửa 407 (Pivot/RulesPaper): không thấy từ trong · floor4.tscn (B)"),
]


def survey_a30():
	rows = []
	for i in range(0, len(A30), 2):
		rows.append([("survey_a30_%s_torch.jpg" % key, (800, 450), caption, False) for key, caption in A30[i:i + 2]])
	sheet("survey_a30.jpg", "Đồ nhỏ phòng 407 (A30), chương 1–2, đèn pin, cách 0,3–0,6 m", rows, [
		"Tổng ~620 tam giác hình khối (PLAN: 636/19). File sở hữu: (B) lane B, (A) lane A; chi tiết từng mesh ở wave10/survey/list.txt.",
	])


def pilot():
	rows = [
		[("pilot_306_room_ps1_feed.jpg", F, "306 phòng, main · " + draws("pilot_306_room_ps1"), False),
			("pilot_306_room_d1_feed.jpg", F, "hình mẫu D1 · " + draws("pilot_306_room_d1"), False),
			("pilot_306_room_d1_feed.jpg", F, "D1 như trên điện thoại", True),
			("pilot_306_inside_d1_1080.jpg", HD, "D1 · 1080p trong phòng (góc kiểm)", False)],
		[("pilot_306_hall_ps1_feed.jpg", F, "306 hành lang, main · " + draws("pilot_306_hall_ps1"), False),
			("pilot_306_hall_h1_feed.jpg", F, "hình mẫu H1 · " + draws("pilot_306_hall_h1"), False),
			("pilot_306_hall_h1_feed.jpg", F, "H1 như trên điện thoại", True),
			("pilot_306_hall_door_1080.jpg", HD, "H1 · 1080p cửa 306 từ hành lang", False)],
		[("pilot_306_room_ps1_1080.jpg", HD, "main · 1080p cùng Cam", False),
			("pilot_306_room_d1_1080.jpg", HD, "D1 · 1080p cùng Cam", False),
			("pilot_306_hall_h1_1080.jpg", HD, "H1 · 1080p cùng Hall/Cam", False)],
	]
	sheet("pilot_306.jpg", "Hình mẫu phòng 306 và hành lang (cùng một khung: quản lý giữ yên, chỉ đổi phần hình)", rows, [
		"Vỏ phòng, hành lang tầng 1–3 nhà B (vật liệu đợt 1–2), cửa mở vào trong, bảng số xanh sau Label3D, bóng đèn ngủ ở NightLight.",
		"Mùng PS1 giữ nguyên (hợp đồng), người khối giữ nguyên. Đồ 407: bàn, ghế, quạt, nệm, gối, chăn, khăn, xô, đồ trên bàn.",
	])


def options():
	sheet("options_d.jpg", "Đồ trong phòng: D1 (giường tầng, tủ thép nhẹ đợt 2) hay D2 (giường, tủ Tripo của 407)", [
		[("pilot_306_room_ps1_feed.jpg", F, "main · " + draws("pilot_306_room_ps1"), False),
			("pilot_306_room_d1_feed.jpg", F, "D1 · " + draws("pilot_306_room_d1"), False),
			("pilot_306_room_d2_feed.jpg", F, "D2 · " + draws("pilot_306_room_d2"), False)],
		[("pilot_306_room_ps1_feed.jpg", F, "main, điện thoại", True),
			("pilot_306_room_d1_feed.jpg", F, "D1, điện thoại", True),
			("pilot_306_room_d2_feed.jpg", F, "D2, điện thoại", True)],
		[("pilot_306_inside_d1_1080.jpg", (728, 410), "D1 · 1080p", False),
			("pilot_306_inside_d2_1080.jpg", (728, 410), "D2 · 1080p", False)],
	], [
		"Phòng 306: main 4.464 tam giác / 29 vật liệu; D1 105.280 / 38; D2 148.494 / 37 (phần lớn là gối, chăn, bàn, quạt, đồ Tripo 407 chung).",
		"Bộ nhớ hình: chương 1 +73 MB (mask hành lang đợt 2 4096 px chưa nén: ~60 MB), chương 3 +0 MB. D2 thêm 0 MB (đồ 407 đã nạp).",
	])
	sheet("options_w.jpg", "Tường sau: W1 (trơn như nay) hay W2 (cửa ban công và cửa sổ đóng)", [
		[("pilot_306_back_ps1_feed.jpg", F, "main, từ chỗ Cam của 310 · " + draws("pilot_306_back_ps1"), False),
			("pilot_306_back_w1_feed.jpg", F, "W1 · " + draws("pilot_306_back_w1"), False),
			("pilot_306_back_w2_feed.jpg", F, "W2 · " + draws("pilot_306_back_w2"), False)],
		[("pilot_310_room_kit_w1_before_feed.jpg", F, "310 thật, W1 · " + draws("pilot_310_room_kit_w1_before"), False),
			("pilot_310_room_kit_before_feed.jpg", F, "310 thật, W2 · " + draws("pilot_310_room_kit_before"), False),
			("pilot_310_room_kit_before_feed.jpg", F, "310 W2, điện thoại", True)],
		[("pilot_306_back_w2_1080.jpg", (728, 410), "W2 · 1080p", False),
			("pilot_306_back_w1_1080.jpg", (728, 410), "W1 · 1080p", False)],
	], [
		"Chỉ feed phòng 310 nhìn về tường sau; bốn phòng kia có Cam đặt sát tường sau, không thấy. W2: +864 tam giác, +5 lần vẽ ở feed 310.",
	])
	sheet("options_h.jpg", "Hành lang trước cửa: H1 (hành lang tầng 1–3 đợt 2) hay H2 (vật liệu cctv_corridor tầng 4, T-256)", [
		[("pilot_306_hall_ps1_feed.jpg", F, "main · " + draws("pilot_306_hall_ps1"), False),
			("pilot_306_hall_h1_feed.jpg", F, "H1 · " + draws("pilot_306_hall_h1"), False),
			("pilot_306_hall_h2_feed.jpg", F, "H2 · " + draws("pilot_306_hall_h2"), False)],
		[("pilot_306_hall_ps1_1080.jpg", HD, "main · 1080p", False),
			("pilot_306_hall_h1_1080.jpg", HD, "H1 · 1080p", False),
			("pilot_306_hall_h2_1080.jpg", HD, "H2 · 1080p", False)],
		[("pilot_102_hall_kit_feed.jpg", F, "102 (tầng 1, lan can xây) · " + draws("pilot_102_hall_kit"), False),
			("pilot_209_hall_kit_feed.jpg", F, "209 (tầng 2, lan can sắt) · " + draws("pilot_209_hall_kit"), False),
			("pilot_310_hall_kit_feed.jpg", F, "310 (tầng 3) · " + draws("pilot_310_hall_kit"), False)],
	], [
		"Cùng hình học (1.502 tam giác): H2 chỉ đổi vật liệu sang bộ CV* của hành lang trường quay tầng 4 để so. Tường ngoài: lan can mở, ngoài trời tối.",
		"Start, Cam, Tube, cột va chạm OuterWall giữ nguyên. Feed hành lang thấy cả các phòng bên cạnh, nên lần vẽ cao sẵn (main 111–310).",
	])
	rows = []
	for number, sign in (("102", "Hùng mở cửa, số 102"), ("306", "điện thoại Kiệt sáng"), ("209", "mùng, Bảo co người"),
			("106", "đèn bàn Đăng"), ("310", "ba xác, nạn nhân")):
		kit = "pilot_306_room_d1" if number == "306" else "pilot_%s_room_kit" % number
		rows.append([("survey_%s_room_feed.jpg" % number, F, "%s main · %s" % (number, sign), False),
			("%s_feed.jpg" % kit, F, "%s bộ mới (D1) · %s" % (number, draws(kit)), False),
			("survey_%s_room_feed.jpg" % number, F, "main, điện thoại", True),
			("%s_feed.jpg" % kit, F, "bộ mới, điện thoại", True)])
	sheet("options_signs.jpg", "Dấu hiệu trên feed 320 × 240: main và bộ mới (vỏ, hành lang, D1; đồ riêng của 102, 209, 106 còn PS1)", rows, [
		"Đọc được: nạn nhân trên giường, quản lý, số phòng (bảng xanh), điện thoại 306, mùng 209, đèn bàn 106, ba xác 310.",
	])


def r2_log():
	"""stem -> {state: (draws, prims)} and stem -> occluder pixels, from round 2's capture logs (the room-310 rerun wins)."""
	draws_by, occ = {}, {}
	for log in ("r2_cctv.txt", "r2_cctv310.txt"):  # cctv310: a run of room 310 alone, if one was made after
		path = SURVEY / log
		if not path.exists():
			continue
		for line in path.read_text(encoding="utf-8").splitlines():
			m = re.match(r"FEED (\S+) \S+ \| before feed draws (\d+) prims (\d+).*?\| after feed draws (\d+) prims (\d+).*?"
				r"\| after, occluders off feed draws (\d+) prims (\d+)", line)
			if m:
				v = [int(x) for x in m.groups()[1:]]
				draws_by[m.group(1)] = {"before": v[0:2], "after": v[2:4], "off": v[4:6]}
			m = re.match(r"OCCLUDERS (\S+) \S+: on/off differ in (\d+) pixels \((\d+) over 6/255\)", line)
			if m:
				occ[m.group(1)] = (int(m.group(2)), int(m.group(3)))
	return draws_by, occ


R2, OCC = r2_log()


def r2(stem, state):
	v = R2.get(stem, {}).get(state)
	return "%d lần vẽ, %dk tam giác" % (v[0], round(v[1] / 1000)) if v else ""


ROOMS2 = (("102", "Hùng mở cửa"), ("306", "Kiệt, điện thoại sáng"), ("209", "Bảo co người, mùng"),
	("106", "Đăng ngồi dậy, đèn bàn"), ("310", "ba xác lao tới (chương 2)"))


def compare_rooms():
	rows = []
	for number, pose in ROOMS2:
		hall = "%s_hall" % number
		room = "%s_room" % number
		rows.append([
			("before_%s_feed.jpg" % hall, F, "%s hành lang, main · %s" % (number, r2(hall, "before")), False),
			("after_%s_feed.jpg" % hall, F, "sau · %s" % r2(hall, "after"), False),
			("before_%s_feed.jpg" % room, F, "%s phòng, main · %s" % (number, r2(room, "before")), False),
			("after_%s_feed.jpg" % room, F, "sau · %s" % r2(room, "after"), False),
			("after_%s_feed.jpg" % room, F, "sau, như trên điện thoại · %s" % pose, True),
		])
	sheet("compare_rooms.jpg", "Năm phòng và năm hành lang: feed 320 × 240 (×3) trước/sau, cùng một khung", rows, [
		"Chương 1: director._cctv_scene() như test_cctv, quản lý và nạn nhân giữ yên, thời gian gần như dừng; 310: chương 2, sau _cctv_310().",
		"Lần vẽ, tam giác: của riêng SubViewport feed. Sau: occluder bật (feed chép far, bật occlusion culling từ 1324a2a).",
		"D2 (giường, tủ, bàn, ghế, quạt, nệm, gối, chăn của 407), W2, mùng 407 cùng trạng thái, cửa mở vào trong, bảng số xanh; hành lang H1.",
	])


def compare_1080():
	rows = []
	for number, pose in ROOMS2:
		rows.append([("before_%s_room_1080.jpg" % number, HD, "%s main · 1080p cùng Cam" % number, False),
			("after_%s_room_1080.jpg" % number, HD, "%s sau · %s" % (number, pose), False),
			("after_%s_hall_1080.jpg" % number, HD, "%s hành lang sau · 1080p cùng Hall/Cam" % number, False)])
	rows.append([("before_corridor_cam_feed.jpg", F, "feed hành lang tầng 4 (cam_corridor), main · " + r2("corridor_cam", "before"), False),
		("after_corridor_cam_feed.jpg", F, "sau (Corridor không đụng) · " + r2("corridor_cam", "after"), False),
		("after_310_room_before_lunge_1080.jpg", HD, "310 sau, trước khi thua (W2: cửa ban công, cửa sổ)", False)])
	sheet("compare_1080.jpg", "Cùng camera ở 1080p: trước (main) và sau", rows, [
		"Người khối (sinh viên, xác) và quản lý không thuộc đợt này. Ánh sáng không đổi: NightLight, Hall/Tube, DeskLamp của 106.",
	])


A30_R2 = [
	("notebook", "Sổ Đạt: bìa bo góc, khối trang, gáy lò xo"),
	("songbook", "Sổ hợp âm: ô hợp âm in trên trang (nét mực phẳng)"),
	("outlet", "Ổ điện Khoa: khung bo cạnh, mặt ổ, hai khe, vít"),
	("trash_paper", "Giấy vo trong thùng rác (3 nắm)"),
	("shower_buttons", "Nút tắm Có / Không: đế và nút bấm (chương 2)"),
]


def a30_compare():
	rows = []
	for key, caption in A30_R2:
		rows.append([("survey_a30_%s_torch.jpg" % key, (640, 360), "trước (lượt 1) · " + caption, False),
			("a30_%s_after.jpg" % key, (640, 360), "sau", False)])
	rows.append([("a30_rules_paper_edge_before.jpg", (640, 360), "nội quy cửa 407 từ hành lang, trước: cách cánh Tripo 4,35 cm", False),
		("a30_rules_paper_edge_after.jpg", (640, 360), "sau: sát chỗ nhô nhất của cánh (1,2 mm)", False)])
	sheet("a30_compare.jpg", "Đồ nhỏ phòng 407 (A30): trước và sau, cùng góc, đèn pin", rows, [
		"Chỉ đổi mesh và vật liệu trên đúng các node cũ (dấu vân tay các node khác trùng main); hình bao lệch tối đa 1,2 cm.",
		"Nội quy: chỉ đổi z của Door407/Pivot/RulesPaper (-0,025 -> -0,063); tờ phẳng vắt qua ô cánh lõm 1,6 cm nên mép còn hở theo ô lõm.",
	])


SYNC_VIEWS = (("room407_door", "407 từ cửa (cửa mở cho ảnh)"), ("corridor_stairs", "hành lang tầng 4 từ đầu cầu thang"),
	("washroom", "nhà vệ sinh chung"), ("room403_open", "phòng 403 (cửa mở cho ảnh)"))


def sync():
	rows = []
	for view, caption in SYNC_VIEWS:
		rows.append([("sync_ch%d_%s.jpg" % (c, view), (480, 270), "chương %d · %s" % (c, caption), False) for c in (1, 2, 3, 4)])
	sheet("sync.jpg", "Đồng bộ bốn chương: cùng góc ở chương 1–4", rows, [
		"Khác do truyện, chương: đèn bàn 407 bật ở chương 1–2; chương 3–4 tầng 4 nằm trong nhà B giữa khuôn viên (trời, ánh sáng môi trường).",
	])


def overview():
	rows = [
		[("after_306_room_1080.jpg", (800, 450), "306 sau (D2, mùng 407, cửa mở vào trong, bảng số xanh)", False),
			("after_306_room_feed.jpg", (600, 450), "feed 306 sau · " + r2("306_room", "after"), False),
			("after_306_room_feed.jpg", (600, 450), "như trên điện thoại", True)],
		[("after_102_hall_1080.jpg", (800, 450), "hành lang 102 (H1, tầng 1: lan can xây)", False),
			("after_209_room_feed.jpg", (600, 450), "209 sau · " + r2("209_room", "after"), False),
			("after_310_room_1080.jpg", (600, 450), "310 sau _cctv_310 (W2)", False)],
		[("a30_notebook_after.jpg", (666, 375), "A30: sổ Đạt", False), ("a30_outlet_after.jpg", (666, 375), "ổ điện Khoa", False),
			("a30_shower_buttons_after.jpg", (666, 375), "nút tắm", False)],
		[("sync_ch1_room407_door.jpg", (500, 281), "chương 1", False), ("sync_ch2_room407_door.jpg", (500, 281), "chương 2", False),
			("sync_ch3_room407_door.jpg", (500, 281), "chương 3", False), ("sync_ch4_room407_door.jpg", (500, 281), "chương 4", False)],
	]
	sheet("overview.jpg", "T-267 đợt 10 (lượt 2): năm phòng trường quay CCTV, đồ nhỏ phòng 407, đồng bộ bốn chương", rows, [
		"Phòng 112.629–156.690 tam giác (trần 160.000); glb đợt 10 < 5.000; feed phòng 112–140 lần vẽ (trần 150), feed hành lang 92–135 (trần 250).",
		"Bộ nhớ hình: chương 1 1.150 -> 1.166 MB (+16, trần 25); chương 3 không thêm do đồ mới (trần 5). Occluder bật/tắt: không điểm ảnh nào lệch quá 6/255.",
	])


def main():
	jobs = sys.argv[1:] or ["r2"]
	if "r1" in jobs:
		survey()
		survey_a30()
		pilot()
		options()
	if "r2" in jobs:
		compare_rooms()
		compare_1080()
		a30_compare()
		sync()
		overview()


if __name__ == "__main__":
	main()
