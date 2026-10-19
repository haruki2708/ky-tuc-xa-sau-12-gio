from html import escape
DONE, DOING, TODO, HERE = "done", "doing", "todo", "here"
STY = {DONE: ("#e3f4e3", "#2e7d32", "✓"), DOING: ("#fff4cc", "#b8860b", "…"), TODO: ("#f1f1f1", "#9a9a9a", "○"), HERE: ("#ffe0c2", "#d9480f", "●")}
phases = [
    ("GĐ 0 · 02–03/10", "Demo PS1 15–20 phút", DONE, [("Cơ chế nội quy bị sửa · tag demo-v1", DONE)]),
    ("GĐ 1 · 04/10", "Đổi hướng: game 3–4 tiếng, 4 chương", DONE, [("Cốt truyện v2 theo video · D-029, D-034, D-035", DONE)]),
    ("GĐ 2 · 04–10/10", "Làm 4 chương", DOING, [
        ("Chương 1 Tổng tắc — tạm chốt D-071", DONE),
        ("Chương 2 Trò chơi — tạm chốt D-073", DONE),
        ("Chương 3 Truy sát — chơi thử dừng ở tầng 1", DOING),
        ("Chương 4 Người sống sót — chưa chơi tay", TODO)]),
    ("GĐ 3 · từ 10/10", "Đồ họa gần chân thực (D-076)", DOING, [
        ("G0 Chuẩn bị — D-079", DONE),
        ("G1 Hợp đồng kỹ thuật, balo — D-085", DONE),
        ("G2 Mẫu balo Tripo đạt, chọn lượt 2 xanh navy — D-086", DONE),
        ("G3 Phòng 407 đủ đồ vào bản chơi, 1080p ≥ 97 FPS — D-103…D-114", DONE),
        ("G4 Nhân vật: quản lý trước, đã vào bản chơi — D-115…D-120", HERE),
        ("G4 Nhân vật chính có thân, tay cầm nắm thật — D-121, card T-220", TODO),
        ("G4 Xác sống (làm trước), bạn học, bảo vệ", TODO),
        ("G5 Hành lang tầng 4 → nhà B → khuôn viên → thư viện/bệnh viện", TODO)]),
    ("GĐ 4", "Ghép bản hoàn chỉnh (D-059)", TODO, [("Chơi liền 4 chương, 1 file lưu, bot + FPS, chơi tay trọn game", TODO)]),
    ("GĐ 5", "Phát hành theo chương", TODO, [("Nền tảng, giá, ngày: chưa quyết", TODO)]),
]
W, X0, BW = 760, 70, 660
y = 70; parts = []
F = "font-family='Segoe UI, Arial, sans-serif'"
for i, (when, title, st, items) in enumerate(phases):
    fill, stroke, mark = STY[st]
    h = 48 + 26 * len(items) + 10
    cy = y + 24
    if i < len(phases) - 1:
        parts.append(f"<line x1='40' y1='{cy}' x2='40' y2='{y + h + 18 + 24}' stroke='#bbb' stroke-width='3'/>")
    parts.append(f"<circle cx='40' cy='{cy}' r='13' fill='{fill}' stroke='{stroke}' stroke-width='3'/>")
    parts.append(f"<text x='40' y='{cy + 5}' text-anchor='middle' {F} font-size='14' font-weight='700' fill='{stroke}'>{mark}</text>")
    parts.append(f"<rect x='{X0}' y='{y}' width='{BW}' height='{h}' rx='10' fill='{fill}' stroke='{stroke}' stroke-width='{3 if st == HERE else 1.5}'/>")
    parts.append(f"<text x='{X0 + 16}' y='{y + 22}' {F} font-size='12' fill='#555'>{escape(when)}</text>")
    parts.append(f"<text x='{X0 + 16}' y='{y + 42}' {F} font-size='17' font-weight='700' fill='#222'>{escape(title)}</text>")
    iy = y + 68
    for text, s2 in items:
        f2, k2, m2 = STY[s2]
        parts.append(f"<rect x='{X0 + 16}' y='{iy - 14}' width='20' height='20' rx='5' fill='{f2}' stroke='{k2}' stroke-width='{2.5 if s2 == HERE else 1.2}'/>")
        parts.append(f"<text x='{X0 + 26}' y='{iy + 1}' text-anchor='middle' {F} font-size='12' font-weight='700' fill='{k2}'>{m2}</text>")
        wt = "700" if s2 == HERE else "400"
        col = "#b33a00" if s2 == HERE else "#222"
        parts.append(f"<text x='{X0 + 46}' y='{iy + 1}' {F} font-size='14' font-weight='{wt}' fill='{col}'>{escape(text)}</text>")
        iy += 26
    y += h + 18
legend_y = 30
leg = []
lx = 70
for key, label in ((DONE, "Xong"), (DOING, "Đang làm"), (HERE, "Đang ở đây"), (TODO, "Chưa làm")):
    f2, k2, m2 = STY[key]
    leg.append(f"<rect x='{lx}' y='{legend_y - 14}' width='20' height='20' rx='5' fill='{f2}' stroke='{k2}' stroke-width='1.5'/><text x='{lx + 10}' y='{legend_y + 1}' text-anchor='middle' {F} font-size='12' font-weight='700' fill='{k2}'>{m2}</text><text x='{lx + 28}' y='{legend_y + 1}' {F} font-size='13' fill='#333'>{label}</text>")
    lx += 140
H = y + 10
svg = (f"<svg xmlns='http://www.w3.org/2000/svg' width='{W}' height='{H}' viewBox='0 0 {W} {H}'>"
       f"<rect width='{W}' height='{H}' fill='#ffffff'/>" + "".join(leg) + "".join(parts) + "</svg>\n")
import os
HERE_DIR = os.path.dirname(os.path.abspath(__file__))
open(os.path.join(HERE_DIR, "roadmap.svg"), "w", encoding="utf-8", newline="\n").write(svg)

p = os.path.join(HERE_DIR, "ROADMAP.md")
s = open(p, encoding="utf-8").read()
a = s.index("## 1. Bản đồ tổng")
b = s.index("Bản chữ (xem được trong terminal / Notepad):")
s = s[:a] + "## 1. Bản đồ tổng\n\n![Bản đồ lộ trình](roadmap.svg)\n\n(Ảnh `docs/roadmap.svg` sinh bằng `python docs/build_roadmap_svg.py`: sửa danh sách `phases` trong script rồi chạy lại khi cập nhật file này. Script cũng ghi lại mục 1 của file này.)\n\n" + s[b:]
open(p, "w", encoding="utf-8", newline="").write(s)
print("ok", H)
