"""T-255: the proposed floor-4 plan (top view) for the owner: rooms 401-406, 408 next to room 407, as built.
Run: python -B art_source/graphics_upgrade/floor4_rooms/draw_plan.py"""
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageFont

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import rooms_layout as L  # noqa: E402

ROOT = HERE.parents[2]
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
S = 52  # px per metre
X0, X1, Z0, Z1 = -0.5, 44.8, 4.6, -9.2
W, H = int((X1 - X0) * S), int((Z0 - Z1) * S) + 120


def P(x, z):
    return ((x - X0) * S, (Z0 - z) * S + 90)


def rect(d, x0, z0, x1, z1, fill=None, outline=(40, 40, 40), width=2):
    a, b = P(min(x0, x1), max(z0, z1)), P(max(x0, x1), min(z0, z1))
    d.rectangle([a, b], fill=fill, outline=outline, width=width)


def main():
    img = Image.new("RGB", (W, H), (246, 244, 238))
    d = ImageDraw.Draw(img)
    big = ImageFont.truetype(str(FONT), 30)
    mid = ImageFont.truetype(str(FONT), 20)
    small = ImageFont.truetype(str(FONT), 15)
    d.text((20, 20), "T-255 đề xuất: tầng 4 nhìn từ trên (mét). Phòng 401–406, 408 sâu như 407, nhà tắm (xanh lam), ban công (vàng)",
        font=big, fill=(20, 20, 20))
    rect(d, 0, 4.0, 44, 0.1, (226, 222, 212))
    d.text(P(18, 2.6), "HÀNH LANG 44 m (giữ nguyên)", font=mid, fill=(80, 80, 80))
    rect(d, 0, 0.1, 6, -5, (215, 228, 236))
    d.text(P(1.2, -2.3), "Nhà vệ sinh chung", font=small, fill=(60, 60, 60))
    for room in L.ROOMS:
        rect(d, room.x0, L.WALL_ROOM, room.x1, L.BACK_IN, (250, 249, 245))
        # old back wall (PS1) and old depth
        a, b = P(room.x0, -5.0), P(room.x1, -5.0)
        d.line([a, b], fill=(200, 80, 60), width=2)
        rect(d, room.bath[0], L.BATH_FRONT_IN, room.bath[1], L.BACK_IN, (196, 220, 240))
        rect(d, room.x0 - 0.04, L.BACK_OUT, room.x1 + 0.04, L.BALCONY_OUT, (246, 230, 170))
        # bunks 0.9 x 2.0, lockers, desks
        bunks = [(room.x0, room.x0 + 0.9), (room.x1 - 0.9, room.x1)]
        if room.number == "408":
            bunks = [(room.x0, room.x0 + 0.9), (room.x0 + 1.1, room.x0 + 2.0), (room.x1 - 0.9, room.x1)]
        for a0, a1 in bunks:
            rect(d, a0, -0.85, a1, -2.85, (180, 205, 180))
        # zombie spawn box
        c0, c1, z0, z1 = L.SPAWN_CLEAR
        rect(d, room.door_x + c0, z1, room.door_x + c1, z0, None, (200, 40, 40), 1)
        d.ellipse([P(room.door_x - 0.12, -1.38), P(room.door_x + 0.12, -1.62)], fill=(200, 40, 40))
        # doors
        rect(d, room.door_x + L.DOOR[0], 0.12, room.door_x + L.DOOR[1], -0.12, (60, 120, 70))
        rect(d, room.bath_door[0], L.BATH_FRONT_ROOM, room.bath_door[1], L.BATH_FRONT_IN, (60, 120, 70))
        rect(d, room.balcony_door[0], L.BACK_IN, room.balcony_door[1], L.BACK_OUT, (60, 120, 70))
        d.text(P(room.x0 + 0.15, -0.25), room.number, font=big, fill=(30, 30, 30))
        d.text(P((room.bath[0] + room.bath[1]) / 2 - 0.5, -5.5), "tắm, WC", font=small, fill=(30, 60, 100))
        d.text(P(room.x0 + 0.2, -7.6), "ban công", font=small, fill=(110, 90, 20))
    rect(d, 30.1, -0.1, 37.9, L.BACK_IN, (232, 232, 232))
    d.text(P(32.5, -3.0), "407 (giữ nguyên)", font=mid, fill=(80, 80, 80))
    rect(d, 35.375, -4.075, 37.9, -6.925, (196, 220, 240))
    rect(d, 30.06, L.BACK_OUT, 35.14, L.BALCONY_OUT, (246, 230, 170))
    legend = ["Đỏ: tường sau PS1 cũ (sâu 5 m)", "Xanh lá: giường tầng 0,9 × 2 m", "Khung đỏ: chỗ xác sống ra (giữ trống)",
        "Xanh đậm: cửa (cửa phòng giữ chỗ cũ, cửa nhà tắm và ban công như 407)"]
    for k, text in enumerate(legend):
        d.text((20 + k * 560, H - 40), text, font=small, fill=(30, 30, 30))
    out = HERE / "previews"
    out.mkdir(exist_ok=True)
    img.save(out / "plan_proposal.png", optimize=True)
    print("T255_PLAN", img.size)


main()
