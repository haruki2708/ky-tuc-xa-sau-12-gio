"""T-266 round 1: the ward's plan seen from above and its section at x = 0, with Camera_Wake's view (K1: pitch 24 degrees as
main; K2: 11 degrees), from survey/plan_geometry.json (survey_wave9.gd: main's hospital_room.tscn). Also draws Y1's curtain
line and Y2's doorway (options), the markers, and lists what is in and out of the frame (16:9, fov 78 vertical).
Run: python -B art_source/graphics_upgrade/realistic_map/wave9/plan_wave9.py  -> previews/wave9/plan_hospital.jpg
"""
import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
OUT = HERE.parent / "previews/wave9/plan_hospital.jpg"
GEO = json.loads((HERE / "survey/plan_geometry.json").read_text(encoding="utf-8"))
FONT = str(ROOT / "game/assets/fonts/be_vietnam_pro_regular.ttf")
BOLD = str(ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf")
S = 110            # px per metre
ASPECT = 16 / 9
FOV_V = 78.0
FOV_H = math.degrees(2 * math.atan(math.tan(math.radians(FOV_V / 2)) * ASPECT))
CAM = GEO["camera_wake"]["pos"]

COLORS = {"Bed": (150, 165, 180), "Mattress": (190, 205, 215), "Cabinet": (180, 170, 140), "IV": (90, 90, 90), "Monitor": (60, 60, 60),
	"Window": (120, 170, 220), "Patient": (200, 180, 160), "Fixture": (230, 230, 170)}


def font(size, bold=False):
	return ImageFont.truetype(BOLD if bold else FONT, size)


def plan():
	w, h = int(6.6 * S), int(7.6 * S)
	img = Image.new("RGB", (w, h), (250, 250, 247))
	d = ImageDraw.Draw(img)
	ox, oz = w / 2, int(0.55 * S) + 3.0 * S       # world (0, 0) -> pixel; +x right, +z down (foot wall at the bottom)

	def P(x, z):
		return (ox + x * S, oz + z * S)

	d.rectangle([P(-2.5, -3.0), P(2.5, 3.0)], outline=(40, 40, 40), width=4)
	for name, box in GEO["hospital"].items():
		if name.startswith("marker:") or "Trace" in name or name in ("Floor", "Ceiling", "West", "East", "HeadWall", "FootWall", "Screen", "WindowCross"):
			continue
		key = next((k for k in COLORS if k in name), None)
		if key is None or "End" in name or "Leg" in name or "Hook" in name or "Base" in name:
			continue
		a, b = box["min"], box["max"]
		d.rectangle([P(a[0], a[2]), P(b[0], b[2])], fill=COLORS[key], outline=(80, 80, 80))
	# Y1 curtain (track round Trung's bed, drawn across the foot at z 1.5) and Y2's doorway in the foot wall
	d.line([P(-1.12, -1.25), P(-1.12, 1.5), P(1.12, 1.5), P(1.12, -1.25)], fill=(60, 150, 140), width=2)
	d.line([P(-1.1, 1.5), P(1.1, 1.5)], fill=(40, 130, 120), width=6)
	d.text(P(-1.08, 1.53), "Y1: rèm kéo ngang chân giường (z 1,5)", font=font(15), fill=(40, 120, 110))
	d.line([P(0.8, 3.0), P(1.7, 3.0)], fill=(250, 250, 247), width=7)
	d.line([P(1.7, 3.0), P(1.7 - 0.9 * math.cos(math.radians(25)), 3.0 - 0.9 * math.sin(math.radians(25)))], fill=(70, 110, 70), width=5)
	d.text(P(0.55, 3.08), "Y2: cửa hé 25°, tiếng từ hành lang", font=font(15), fill=(70, 110, 70))
	# markers
	for name, box in GEO["hospital"].items():
		if not name.startswith("marker:"):
			continue
		x, _, z = box["at"]
		label = name.split(":")[1]
		col = (200, 40, 40) if "Nurse" in label else ((40, 90, 200) if "Card" in label else (120, 60, 160))
		d.ellipse([P(x - 0.06, z - 0.06), P(x + 0.06, z + 0.06)], fill=col)
		d.text(P(x + 0.08, z - 0.05), label.replace("Bed_", ""), font=font(14), fill=col)
	# view cone (horizontal), eye at Camera_Wake looking +z
	cx, cz = CAM[0], CAM[2]
	ln = 3.8
	for sign in (-1, 1):
		a = math.radians(FOV_H / 2) * sign
		d.line([P(cx, cz), P(cx + math.sin(a) * ln, cz + math.cos(a) * ln)], fill=(230, 120, 20), width=3)
	d.ellipse([P(cx - 0.08, cz - 0.08), P(cx + 0.08, cz + 0.08)], fill=(230, 120, 20))
	d.text(P(cx + 0.1, cz - 0.3), "Camera_Wake (mắt Trung)\nngang %.0f° (16:9)" % FOV_H, font=font(15), fill=(200, 100, 10))
	d.text(P(-2.45, -2.95), "TƯỜNG ĐẦU GIƯỜNG (z −3)", font=font(15, True), fill=(60, 60, 60))
	d.text(P(-2.45, 2.72), "TƯỜNG CHÂN GIƯỜNG (z +3)", font=font(15, True), fill=(60, 60, 60))
	d.text(P(1.4, -2.6), "cửa sổ\n(tường đông)", font=font(14), fill=(60, 110, 170))
	d.text(P(-2.45, -0.15), "Nhật\n(x −1,65)\nphải khung", font=font(14), fill=(60, 60, 60))
	d.text(P(1.8, -0.15), "Ngư\n(x +1,65)\ntrái khung", font=font(14), fill=(60, 60, 60))
	d.text((12, 8), "Nhìn từ trên (x sang phải, z xuống dưới). 1 ô = 1 m", font=font(16, True), fill=(30, 30, 30))
	for k in range(-2, 3):
		d.line([P(k, -3.0), P(k, 3.0)], fill=(225, 225, 220), width=1)
	for k in range(-3, 4):
		d.line([P(-2.5, k), P(2.5, k)], fill=(225, 225, 220), width=1)
	return img


def section():
	w, h = int(6.6 * S), int(4.2 * S)
	img = Image.new("RGB", (w, h), (250, 250, 247))
	d = ImageDraw.Draw(img)
	ox, oy = int(0.8 * S), int(3.6 * S)

	def P(z, y):
		return (ox + (z + 3.0) * S * 0.86, oy - y * S)

	d.rectangle([P(-3.0, 3.0), P(3.0, 0.0)], outline=(40, 40, 40), width=3)
	hosp = GEO["hospital"]
	for name in ("Bed_Trung/Frame", "Bed_Trung/Mattress", "Bed_Trung/Patient/Blanket", "Bed_Trung/End1.04", "Cabinet_Trung", "Monitor", "CeilingLight/Fixture"):
		a, b = hosp[name]["min"], hosp[name]["max"]
		key = next((k for k in COLORS if k in name), "Bed")
		d.rectangle([P(a[2], b[1]), P(b[2], a[1])], fill=COLORS[key], outline=(80, 80, 80))
	card = hosp["marker:Bed_Trung/Card"]["at"]
	d.ellipse([P(card[2] - 0.04, card[1] + 0.04), P(card[2] + 0.04, card[1] - 0.04)], fill=(40, 90, 200))
	d.text(P(card[2] + 0.05, card[1] + 0.12), "thẻ Trung", font=font(14), fill=(40, 90, 200))
	for nurse in ("Nurse1", "Nurse2"):
		at = hosp["marker:" + nurse]["at"]
		d.line([P(at[2], 0.0), P(at[2], 1.62)], fill=(200, 40, 40), width=6)
	d.text(P(1.95, 1.75), "y tá đứng (1,6 m)\nở Nurse1/2", font=font(14), fill=(200, 40, 40))
	d.line([P(1.5, 0.38), P(1.5, 2.94)], fill=(40, 130, 120), width=5)
	d.text(P(1.0, 2.75), "Y1", font=font(14, True), fill=(40, 130, 120))
	cz, cy = CAM[2], CAM[1]
	for pitch, col, tag in ((24.0, (230, 120, 20), "K1 24°"), (11.0, (40, 140, 60), "K2 11°")):
		for edge in (-1, 1):
			a = math.radians(pitch + edge * FOV_V / 2)
			# ray until it meets the ceiling or the floor or the foot wall
			for t in [k * 0.02 for k in range(1, 400)]:
				z, y = cz + math.cos(a) * t, cy + math.sin(a) * t
				if y >= 3.0 or y <= 0.0 or z >= 3.0:
					break
			d.line([P(cz, cy), P(z, y)], fill=col, width=3)
		d.text(P(-2.9, 2.6 if pitch > 20 else 2.3), "%s: mép trên %+.0f°, mép dưới %+.0f°" % (tag, pitch + FOV_V / 2, pitch - FOV_V / 2),
			font=font(15, True), fill=col)
	d.text((12, 8), "Mặt cắt dọc x = 0 (z sang phải: từ đầu giường tới chân giường)", font=font(16, True), fill=(30, 30, 30))
	return img


def main():
	top, side = plan(), section()
	notes = [
		"Trong khung K1 (như main): trần (nửa trên), tường chân giường, nửa xa hai tường bên,",
		"chăn của Trung ở mép dưới, thẻ của Trung (giữa, y -0,60 của khung), chân hai giường bên",
		"và hai thẻ ở hai góc dưới (x ±0,74), một mép cửa sổ ở mép trái.",
		"Ngoài khung: máy theo dõi và MonitorAudio (sau đầu), tủ, đèn trần (ngay trên đầu),",
		"ba cây truyền (ngang vai), gối và đầu của Trung.",
		"Nurse1/Nurse2 ở sàn (y 0) dưới tâm khung, cách mắt 1,9 m: người đứng đó chiếm giữa khung.",
		"K2 (11°): thấy thân người dưới chăn, tay đặt trên chăn, hai giường bên rõ hơn;",
		"trần còn khoảng 1/3 khung.",
	]
	w = top.width + side.width
	out = Image.new("RGB", (w, max(top.height, side.height + 30 * len(notes) + 40)), (250, 250, 247))
	out.paste(top, (0, 0))
	out.paste(side, (top.width, 0))
	d = ImageDraw.Draw(out)
	for i, line in enumerate(notes):
		d.text((top.width + 14, side.height + 20 + i * 30), line, font=font(15), fill=(30, 30, 30))
	OUT.parent.mkdir(parents=True, exist_ok=True)
	out.save(OUT, quality=90)
	print("T266_PLAN", OUT.name, out.size, "fov_h %.1f" % FOV_H)


if __name__ == "__main__":
	main()
