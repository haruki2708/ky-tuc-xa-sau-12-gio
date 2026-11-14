"""T-261 round 1: option sheets for the owner from previews/wave4/pilot_<config>_<view>_<off|on>[_torch].jpg
(capture_wave4.gd). One sheet per thing to pick, same cameras across options, chapter 3's real scene at night.
Run: python -B art_source/graphics_upgrade/realistic_map/wave4/make_wave4_sheets.py
"""
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

sys.dont_write_bytecode = True
sys.stdout.reconfigure(encoding="utf-8")
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PREVIEWS = HERE.parent / "previews" / "wave4"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
TILE = (800, 450)

VIEW_NAMES = {
	"west_gate": "cổng tây, từ ngoài vào",
	"gate_in": "Start_stadium, trong cổng tây",
	"track_curve": "khúc cua tây của đường chạy",
	"goal": "khung thành tây",
	"stand_front": "khán đài chính từ mép sân",
	"stand_top": "hàng cao nhất nhìn xuống",
	"under_stand": "gầm khán đài (B03, ống sắt)",
	"stand_end": "đầu hồi tây khán đài (B02)",
	"nw_gate": "cổng tây bắc, cạnh khán đài",
	"pole": "cột đèn pha tây bắc (Pole2)",
}
LIGHTS = {"off": "đèn pha tắt", "on": "đèn pha bật", "off_torch": "đèn pha tắt, đèn pin"}


def font(size):
	return ImageFont.truetype(str(FONT), size)


def label(img, text, size=24, at=(0, 0)):
	draw = ImageDraw.Draw(img)
	f = font(size)
	box = draw.textbbox((0, 0), text, font=f)
	draw.rectangle([at[0], at[1], at[0] + box[2] + 20, at[1] + box[3] + 12], fill=(0, 0, 0))
	draw.text((at[0] + 10, at[1] + 4), text, font=f, fill=(240, 240, 235))


def tile(config, view, light, name):
	img = Image.open(PREVIEWS / f"pilot_{config}_{view}_{light}.jpg").convert("RGB").resize(TILE)
	label(img, name, 22)
	label(img, f"{VIEW_NAMES[view]} · {LIGHTS[light]}", 18, (0, TILE[1] - 40))
	return img


def sheet(file, title, columns, rows, note=""):
	"""columns: [(config, name)], rows: [(view, light)]."""
	head = 70 if not note else 112
	out = Image.new("RGB", (len(columns) * (TILE[0] + 8) - 8, head + len(rows) * (TILE[1] + 8)), (20, 20, 20))
	label(out, title, 34)
	if note:
		ImageDraw.Draw(out).text((12, 68), note, font=font(22), fill=(205, 205, 195))
	for r, (view, light) in enumerate(rows):
		for c, column in enumerate(columns):
			config, name = column[0], column[1]
			shot = column[2] if len(column) > 2 else light  # a column may fix the floodlight state
			out.paste(tile(config, view, shot, name), (c * (TILE[0] + 8), head + r * (TILE[1] + 8)))
	out.save(PREVIEWS / file, quality=84)
	print("wrote", file, out.size)


BEFORE = ("before", "Hiện tại (PS1)")


def main():
	sheet("options_track.jpg", "Đường chạy: R1 cao su đỏ bạc màu, nứt  /  R2 xỉ than, vạch vôi",
		[BEFORE, ("a", "R1 cao su đỏ bạc màu"), ("b", "R2 xỉ than (sân trường cũ)")],
		[("track_curve", "off_torch"), ("gate_in", "on"), ("stand_top", "on")],
		"Cùng camera, chương 3 thật, ban đêm. Vạch làn sơn (R1) mòn khoảng 1/3; vạch vôi (R2) mòn gần nửa.")
	sheet("options_pitch.jpg", "Mặt sân: C1 cỏ thật úa loang lổ  /  C2 cỏ nhân tạo cũ",
		[BEFORE, ("a", "C1 cỏ thật, trọc ở cầu môn"), ("b", "C2 cỏ nhân tạo, lộ hạt cao su")],
		[("goal", "off_torch"), ("goal", "on"), ("stand_top", "off")],
		"Vạch sân đầy đủ (vòng giữa, vòng cấm, chấm phạt đền) vẽ bằng shader, mòn từng đoạn; vũng nước nhỏ giữ chung hai phương án.")
	sheet("options_stand.jpg", "Khán đài chính: S1 bậc bê tông trần  /  S2 ghế nhựa (xanh hoặc đỏ); mái tôn khung thép chung",
		[BEFORE, ("a", "S1 bê tông trần"), ("b", "S2 ghế nhựa xanh"), ("c", "S2 ghế nhựa đỏ")],
		[("stand_front", "off_torch"), ("stand_top", "on"), ("under_stand", "off_torch")],
		"Ghế không có va chạm (như dải ghế PS1): người chơi đi xuyên qua ghế khi lên bậc. Mái: tôn kẽm rỉ, kèo thép sơn xanh, thiếu 3 tấm.")
	sheet("options_pole.jpg", "Cột đèn pha: L1 thép mạ kẽm côn  /  L2 bê tông ly tâm; chao 6 đèn sáng theo Floodlights",
		[BEFORE, ("a", "L1 thép côn mạ kẽm"), ("b", "L2 bê tông ly tâm")],
		[("pole", "off"), ("pole", "on"), ("west_gate", "on")],
		"Không thêm đèn: 4 đèn pha cũ giữ nguyên; chỉ mặt kính chao phát sáng khi Floodlights bật.")
	sheet("options_fence.jpg", "Hàng rào và cổng: H1 lưới B40 trên cột ống  /  H2 song sắt sơn xanh; trụ cổng trát vôi",
		[BEFORE, ("a", "H1 lưới B40"), ("b", "H2 song sắt")],
		[("west_gate", "off"), ("nw_gate", "off"), ("stand_end", "off_torch")],
		"Cao 1,3 m đúng khối va chạm cũ; cánh cổng mở gập sát rào phía ngoài (không chắn lối).")
	sheet("floodlights.jpg", "Đèn pha tắt và bật, cùng camera (PS1 và phương án a)",
		[("before", "PS1, đèn pha tắt", "off"), ("before", "PS1, đèn pha bật", "on"), ("a", "a, đèn pha tắt", "off"), ("a", "a, đèn pha bật", "on")],
		[("gate_in", "off"), ("stand_front", "off"), ("stand_top", "off"), ("pole", "off")],
		"Chương 3 tắt đèn pha trước đoạn sân; director bật lúc vào sân rồi tắt sau 1,5 giây (cảnh doạ stadium_lights).")


if __name__ == "__main__":
	main()
