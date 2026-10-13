"""Textures for the lived-in pass of room 407 (D-100). Run: python -B <this file>.
No AI images: grime decals are derived from the CC0 plaster photographs of the corner pilot
(Poly Haven, room407_corner/textures); paper items are drawn here with Be Vietnam Pro (OFL).
  paper/   calendar, timetable, sticky notes, dyed linen for the mat binding and the curtain
           (embedded in GLBs by build_lived_in.py)
  game/.../room407_furnished/decals/   RGBA decals placed by decals.json (Godot Decal nodes)
Paper text is everyday dorm life only, never a story clue.
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PHOTOS = HERE.parent / "room407_corner" / "textures"
PAPER = HERE / "paper"
DECALS = ROOT / "game/assets/textures/graphics_pilot/room407_furnished/decals"
FONT = ROOT / "game/assets/fonts/be_vietnam_pro_regular.ttf"
FONT_BOLD = ROOT / "game/assets/fonts/be_vietnam_pro_semibold.ttf"
RNG = np.random.default_rng(407)


def font(size, bold=False):
    return ImageFont.truetype(str(FONT_BOLD if bold else FONT), size)


def grain(name, size):
    """Luminance detail of a CC0 photo, 0..1, used to break up every mask."""
    image = Image.open(PHOTOS / name).convert("L").resize(size, Image.LANCZOS)
    g = np.asarray(image).astype(float) / 255
    return (g - g.min()) / max(1e-6, g.max() - g.min())


def blobs(w, h, count, radius, softness):
    """Soft random blotches as a float mask."""
    y, x = np.mgrid[0:h, 0:w]
    mask = np.zeros((h, w))
    for _ in range(count):
        cx, cy = RNG.uniform(0, w), RNG.uniform(0, h)
        r = RNG.uniform(.4, 1.0) * radius
        mask = np.maximum(mask, np.clip(1 - np.hypot(x - cx, (y - cy) * RNG.uniform(.7, 1.4)) / r, 0, 1) ** softness)
    return mask


def value_noise(w, h, cells):
    """Smooth random field, 0..1, with features about w / cells across."""
    small = Image.fromarray((RNG.random((cells, cells)) * 255).astype("uint8"))
    return np.asarray(small.resize((w, h), Image.BICUBIC)).astype(float) / 255


def edge_fade(w, h, margin=.12):
    y, x = np.mgrid[0:h, 0:w]
    fx = np.clip(np.minimum(x, w - 1 - x) / (w * margin), 0, 1)
    fy = np.clip(np.minimum(y, h - 1 - y) / (h * margin), 0, 1)
    return fx * fy


def save_rgba(path, rgb, alpha):
    path.parent.mkdir(parents=True, exist_ok=True)
    rgba = np.dstack([np.clip(rgb, 0, 255), np.clip(alpha * 255, 0, 255)]).astype("uint8")
    Image.fromarray(rgba, "RGBA").save(path, optimize=True)


def decals():
    # Dirt rising from the floor along walls: kicked shoes, mop water, dust.
    w, h = 1024, 256
    g = grain("plastered_wall_04_color.jpg", (w, h))
    y = np.mgrid[0:h, 0:w][0] / (h - 1)
    rise = np.clip((y - .25) / .75, 0, 1) ** 1.6
    scuffs = blobs(w, h, 26, 60, 1.5) * (y > .55)
    alpha = np.clip(rise * (.35 + .65 * g) * .75 + scuffs * .35, 0, .85) * edge_fade(w, h, .04)
    save_rgba(DECALS / "wall_base_grime.png", np.dstack([g * 70 + 40, g * 60 + 34, g * 45 + 26]), alpha)
    # Black mould in damp corners (bathroom, under the balcony door).
    w = h = 512
    g = grain("plastered_wall_04_color.jpg", (w, h))
    speck = (RNG.random((h, w)) > .55).astype(float)
    spots = Image.fromarray((speck * 255).astype("uint8")).filter(ImageFilter.GaussianBlur(1.2))
    spots = np.asarray(spots).astype(float) / 255
    body = blobs(w, h, 14, 120, 1.2)
    alpha = np.clip(body * (.45 + .55 * spots) * (.6 + .4 * g), 0, .9) * edge_fade(w, h)
    save_rgba(DECALS / "mould.png", np.dstack([g * 25 + 18, g * 30 + 24, g * 22 + 16]), alpha)
    # Greasy hand marks round the light switch and door edge.
    w = h = 256
    mark = np.zeros((h, w))
    yy, xx = np.mgrid[0:h, 0:w]
    for _ in range(9):
        cx, cy = RNG.normal(w / 2, w / 7), RNG.normal(h / 2, h / 6)
        for finger in range(4):
            fx, fy = cx + (finger - 1.5) * 14, cy - abs(finger - 1.5) * 6
            mark = np.maximum(mark, np.clip(1 - np.hypot((xx - fx) / 7, (yy - fy) / 13), 0, 1))
    g = grain("plastered_wall_04_color.jpg", (w, h))
    alpha = np.clip(mark * .35 * (.5 + .5 * g) + blobs(w, h, 6, 50, 2) * .15, 0, .45) * edge_fade(w, h)
    save_rgba(DECALS / "hand_smudges.png", np.dstack([g * 40 + 50, g * 38 + 44, g * 30 + 36]), alpha)
    # Flaking paint: torn-edged islands where the cream skin is gone, grey plaster underneath,
    # a pale lifted rim and a dark shadow line where the flakes curl.
    w = h = 512
    g = grain("plastered_wall_04_color.jpg", (w, h))
    plaster = np.asarray(Image.open(PHOTOS / "plastered_wall_04_color.jpg").convert("RGB").resize((w, h))).astype(float)
    rough = value_noise(w, h, 6) * .55 + value_noise(w, h, 18) * .3 + g * .15
    hole = ((rough * edge_fade(w, h, .25)) > .42).astype(float)
    hole_img = Image.fromarray((hole * 255).astype("uint8")).filter(ImageFilter.GaussianBlur(.8))
    core = np.asarray(hole_img).astype(float) / 255
    grown = np.asarray(hole_img.filter(ImageFilter.MaxFilter(9)).filter(ImageFilter.GaussianBlur(1.5))).astype(float) / 255
    rim = np.clip(grown - core, 0, 1)
    rgb = (plaster * (.75 + .25 * g[..., None])) * core[..., None] + np.array([238, 228, 200]) * rim[..., None]
    shadow = np.asarray(Image.fromarray((core * 255).astype("uint8")).filter(ImageFilter.GaussianBlur(3))).astype(float) / 255
    rgb = rgb * (1 - .35 * np.clip(shadow - core, 0, 1)[..., None] * 3)
    save_rgba(DECALS / "peeling_paint.png", rgb, np.clip(core + rim * .9, 0, 1) * edge_fade(w, h, .05))
    # Grime collected in floor corners and along the bathroom threshold.
    g = grain("plastered_wall_04_color.jpg", (w, h))
    patch = value_noise(w, h, 5) * .6 + g * .4
    alpha = np.clip((patch - .35) * 1.6, 0, .65) * edge_fade(w, h, .3)
    save_rgba(DECALS / "floor_grime.png", np.dstack([g * 50 + 30, g * 44 + 26, g * 34 + 20]), alpha)
    # Brown water stain for the ceiling (leak from the floor above).
    g = grain("plastered_wall_04_color.jpg", (w, h))
    ring = blobs(w, h, 5, 170, .8)
    tide = np.clip(1 - np.abs(ring - .35) / .08, 0, 1)
    alpha = np.clip(ring * .28 + tide * .45, 0, .7) * (.6 + .4 * g) * edge_fade(w, h)
    save_rgba(DECALS / "ceiling_leak.png", np.dstack([g * 60 + 110, g * 50 + 82, g * 30 + 45]), alpha)


def paper_tone(w, h):
    g = grain("plastered_wall_04_color.jpg", (w, h))
    base = np.dstack([243 + g * 8, 238 + g * 8, 226 + g * 8])
    return Image.fromarray(np.clip(base, 0, 255).astype("uint8"), "RGB")


def calendar():
    w, h = 768, 1088
    image = paper_tone(w, h)
    d = ImageDraw.Draw(image)
    d.rectangle([0, 0, w, 300], fill=(196, 52, 46))
    d.text((w / 2, 110), "THÁNG 10", font=font(96, True), fill=(255, 246, 236), anchor="mm")
    d.text((w / 2, 215), "Âm lịch: tháng 8 - tháng 9", font=font(34), fill=(255, 226, 214), anchor="mm")
    heads = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
    cell_w, top = w / 7, 330
    for i, head in enumerate(heads):
        d.text((cell_w * (i + .5), top + 28), head, font=font(34, True),
               fill=(196, 52, 46) if head == "CN" else (60, 56, 52), anchor="mm")
    day, col, row = 1, 3, 0  # starts on a Thursday
    while day <= 31:
        cx, cy = cell_w * (col + .5), top + 110 + row * 125
        d.text((cx, cy), str(day), font=font(52, True), fill=(196, 52, 46) if col == 6 else (40, 38, 36), anchor="mm")
        d.text((cx + 26, cy + 40), str((day + 18) % 30 + 1), font=font(20), fill=(130, 124, 118), anchor="mm")
        if day in (9, 16, 23):  # pen circles: someone counts down to something mundane
            d.ellipse([cx - 44, cy - 42, cx + 44, cy + 42], outline=(30, 60, 150), width=4)
        if day < 13:  # days crossed off
            d.line([cx - 34, cy - 30, cx + 34, cy + 30], fill=(30, 60, 150), width=4)
        day += 1
        col += 1
        if col == 7:
            col, row = 0, row + 1
    d.rectangle([w / 2 - 14, 8, w / 2 + 14, 30], fill=(70, 66, 62))  # hanging hole
    image.save(PAPER / "calendar.png", optimize=True)


def timetable():
    w, h = 1088, 768
    image = paper_tone(w, h)
    d = ImageDraw.Draw(image)
    d.text((w / 2, 60), "THỜI KHÓA BIỂU - HỌC KỲ 1", font=font(46, True), fill=(30, 30, 34), anchor="mm")
    days = ["", "Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7"]
    rows = [("Sáng", ["Giải tích 1", "Vật lý ĐC", "", "Lập trình C", "Giải tích 1", "GDTC"]),
            ("Chiều", ["Tiếng Anh 2", "", "Triết học", "Vật lý ĐC", "", ""]),
            ("Tối", ["", "Thực hành C", "", "", "Tiếng Anh 2", ""])]
    x0, y0, cw, ch = 40, 120, (w - 80) / 7, 190
    for i, label in enumerate(days):
        d.rectangle([x0 + i * cw, y0, x0 + (i + 1) * cw, y0 + 60], outline=(40, 40, 44), width=2, fill=(220, 226, 236) if i else None)
        d.text((x0 + (i + .5) * cw, y0 + 30), label, font=font(28, True), fill=(30, 30, 34), anchor="mm")
    for r, (part, subjects) in enumerate(rows):
        top = y0 + 60 + r * ch
        d.rectangle([x0, top, x0 + cw, top + ch], outline=(40, 40, 44), width=2, fill=(220, 226, 236))
        d.text((x0 + cw / 2, top + ch / 2), part, font=font(30, True), fill=(30, 30, 34), anchor="mm")
        for c, subject in enumerate(subjects, start=1):
            d.rectangle([x0 + c * cw, top, x0 + (c + 1) * cw, top + ch], outline=(40, 40, 44), width=2)
            if subject:
                d.multiline_text((x0 + (c + .5) * cw, top + ch / 2 - 14), subject.replace(" ", "\n", 1),
                                 font=font(26), fill=(36, 36, 40), anchor="mm", align="center")
                d.text((x0 + (c + .5) * cw, top + ch - 30), f"P.{RNG.integers(101, 409)}", font=font(20),
                       fill=(110, 110, 116), anchor="mm")
    d.line([x0 + 3.1 * cw, y0 + 60 + 1.4 * ch, x0 + 3.9 * cw, y0 + 60 + 1.75 * ch], fill=(200, 40, 40), width=4)
    image.save(PAPER / "timetable.png", optimize=True)


def sticky_notes():
    w, h = 768, 256
    image = Image.new("RGB", (w, h), (0, 0, 0))
    d = ImageDraw.Draw(image)
    notes = [((250, 232, 120), "Đóng tiền điện\ntháng 10!!"), ((248, 182, 196), "Mua mì + trứng\n+ nước rửa bát"),
             ((178, 226, 170), "Trả Đạt 50k")]
    for i, (color, text) in enumerate(notes):
        x = i * 256
        g = grain("plastered_wall_04_color.jpg", (256, 256))
        tone = np.clip(np.array(color) * (.94 + .06 * g[..., None]), 0, 255).astype("uint8")
        image.paste(Image.fromarray(tone, "RGB"), (x, 0))
        d.rectangle([x, 0, x + 255, 40], fill=tuple(int(c * .9) for c in color))
        d.multiline_text((x + 128, 150), text, font=font(30), fill=(40, 46, 120), anchor="mm", align="center")
    image.save(PAPER / "sticky_notes.png", optimize=True)


def dyed_linen():
    """Dyed copies of the CC0 linen scan: mat binding (navy) and the balcony curtain (faded green)."""
    linen = np.asarray(Image.open(PHOTOS / "rough_linen_square_color.jpg").convert("RGB")).astype(float)
    grey = linen.mean(axis=2, keepdims=True) / 255
    for name, color in (("binding_navy", (52, 62, 96)), ("curtain_green", (150, 172, 140))):
        dyed = np.clip(grey * 1.6 * np.array(color), 0, 255).astype("uint8")
        Image.fromarray(dyed).resize((512, 512), Image.LANCZOS).save(PAPER / (name + ".jpg"), quality=90)


def main():
    PAPER.mkdir(parents=True, exist_ok=True)
    dyed_linen()
    decals()
    calendar()
    timetable()
    sticky_notes()
    for path in sorted(list(PAPER.glob("*.*")) + list(DECALS.glob("*.png"))):
        print(path.relative_to(ROOT), Image.open(path).size, path.stat().st_size)
    print("RESULT: lived-in textures PASS")


if __name__ == "__main__":
    main()
