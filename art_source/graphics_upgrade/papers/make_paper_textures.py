"""D-106: paper textures for room 407's readable papers, one per DocumentData.style plus photos.

Drawn from scratch (no fonts, no photos): text is abstract ink strokes, never legible, because the
words appear in the close-up reader. Deterministic. Output: game/assets/textures/papers/<look>.png; photo_family is a warmer indoor snapshot
(RGBA; alpha cuts torn or rounded edges).

    python -I make_paper_textures.py
"""
import math
import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

OUT = Path(__file__).resolve().parents[3] / "game" / "assets" / "textures" / "papers"
SHEET = (512, 724)  # A-series 1:1.414
CARD = (512, 341)  # 3:2 cards and photos


def paper_base(size, tone, seed, grain=7.0):
    rng = np.random.default_rng(seed)
    w, h = size
    base = np.ones((h, w, 3), np.float32) * np.array(tone, np.float32)
    # Fibres: low-frequency blotches plus fine grain.
    low = rng.normal(0, 1, (h // 16 + 1, w // 16 + 1)).astype(np.float32)
    low = np.array(Image.fromarray(low).resize((w, h), Image.BICUBIC))
    fine = rng.normal(0, 1, (h, w)).astype(np.float32)
    base += (low * 4.0 + fine * grain)[..., None]
    # Edges a little darker (handled, aged).
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    edge = np.minimum(np.minimum(xx, w - 1 - xx), np.minimum(yy, h - 1 - yy))
    base -= (np.clip(1.0 - edge / 40.0, 0, 1) ** 2 * 18.0)[..., None]
    img = Image.fromarray(np.clip(base, 0, 255).astype(np.uint8), "RGB").convert("RGBA")
    return img


def stain(img, rng, count, color, radius):
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for _ in range(count):
        x, y = rng.uniform(0, img.size[0]), rng.uniform(0, img.size[1])
        r = rng.uniform(radius * 0.4, radius)
        d.ellipse((x - r, y - r, x + r, y + r), outline=color + (70,), width=3, fill=color + (22,))
    return Image.alpha_composite(img, layer.filter(ImageFilter.GaussianBlur(2)))


def fold(img, horizontal=True):
    w, h = img.size
    layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    if horizontal:
        d.line((0, h // 2, w, h // 2 + 3), fill=(90, 85, 75, 60), width=2)
        d.line((0, h // 2 + 3, w, h // 2 + 6), fill=(255, 255, 250, 50), width=2)
    else:
        d.line((w // 2, 0, w // 2 + 2, h), fill=(90, 85, 75, 60), width=2)
    return Image.alpha_composite(img, layer.filter(ImageFilter.GaussianBlur(1)))


def printed_lines(d, rng, x0, x1, y0, y1, step, color, height):
    """Typed text: word blocks of varying width, ragged right edge."""
    y = y0
    while y < y1:
        x = x0 + (rng.uniform(18, 30) if rng.random() < 0.15 else 0)
        end = x1 - rng.uniform(0, 90) if rng.random() < 0.3 else x1
        while x < end:
            word = rng.uniform(8, 38)
            d.rectangle((x, y, min(x + word, end), y + height), fill=color)
            x += word + rng.uniform(5, 8)
        y += step


def pen_words(d, rng, x0, x1, y, color, width=2, slant=0.25):
    """Handwriting: wobbly loops, one polyline per word."""
    x = x0
    while x < x1 - 20:
        word = rng.uniform(20, 70)
        pts = []
        t = 0.0
        while t < word:
            amp = rng.uniform(3, 8)
            pts.append((x + t + amp * slant, y - amp * abs(math.sin(t * 0.55 + rng.uniform(0, 0.4)))))
            t += rng.uniform(1.6, 2.6)
        if len(pts) > 1:
            d.line(pts, fill=color, width=width, joint="curve")
        x += word + rng.uniform(8, 16)


def torn_alpha(img, rng, sides="top"):
    w, h = img.size
    mask = Image.new("L", img.size, 255)
    d = ImageDraw.Draw(mask)
    if "top" in sides:
        pts = [(0, 0)]
        for x in range(0, w + 8, 8):
            pts.append((x, rng.uniform(4, 16)))
        pts.append((w, 0))
        d.polygon(pts, fill=0)
    img.putalpha(mask.filter(ImageFilter.GaussianBlur(0.8)))
    return img


def rounded_alpha(img, radius):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, img.size[0] - 1, img.size[1] - 1), radius, fill=255)
    img.putalpha(mask)
    return img


def photocopy(seed=11):
    rng = random.Random(seed)
    img = paper_base(SHEET, (232, 230, 222), seed)
    d = ImageDraw.Draw(img)
    # Header: institution line, title, rule.
    d.rectangle((150, 50, 362, 58), fill=(60, 60, 62))
    d.rectangle((110, 76, 402, 92), fill=(35, 35, 38))
    d.line((60, 112, 452, 112), fill=(70, 70, 72), width=2)
    for i in range(9):
        y = 140 + i * 54
        d.rectangle((60, y, 72, y + 9), fill=(40, 40, 42))  # rule number
        printed_lines(d, rng, 84, 452, y, y + 40, 14, (75, 75, 78), 5)
    # Toner specks and a darker photocopy edge band.
    for _ in range(260):
        x, y = rng.uniform(0, 512), rng.uniform(0, 724)
        r = rng.uniform(0.5, 1.6)
        d.ellipse((x - r, y - r, x + r, y + r), fill=(60, 60, 60, 180))
    d.rectangle((0, 0, 511, 6), fill=(120, 120, 118))
    return fold(img)


def handwritten(seed=23):
    rng = random.Random(seed)
    img = paper_base(SHEET, (236, 232, 214), seed)
    d = ImageDraw.Draw(img)
    for y in range(80, 724, 26):
        d.line((0, y, 512, y), fill=(150, 175, 205), width=1)
    d.line((62, 0, 62, 724), fill=(210, 120, 120), width=2)
    ink = (28, 45, 120)
    lines = list(range(104, 600, 26))
    for i, y in enumerate(lines):
        if rng.random() < 0.12:
            continue
        end = 470 if i < len(lines) - 3 else rng.uniform(200, 380)
        pen_words(d, rng, 74 + (24 if rng.random() < 0.2 else 0), end, y - 4, ink)
    # Underlined word and a crossed-out one.
    d.line((120, 108, 220, 106), fill=ink, width=2)
    d.line((300, 262, 380, 250), fill=ink, width=3)
    img = stain(img, rng, 2, (150, 120, 70), 60)
    return torn_alpha(fold(img), rng, "top")


def stamped(seed=37):
    rng = random.Random(seed)
    img = paper_base(CARD, (238, 238, 234), seed, grain=4.0)
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, 512, 70), fill=(30, 70, 140))
    d.rectangle((90, 18, 400, 30), fill=(235, 238, 245))
    d.rectangle((140, 40, 350, 50), fill=(200, 210, 230))
    # Photo box with an anonymous head-and-shoulders silhouette.
    d.rectangle((26, 92, 146, 252), fill=(180, 195, 210), outline=(90, 100, 115), width=2)
    d.ellipse((60, 112, 112, 172), fill=(95, 100, 110))
    d.pieslice((40, 165, 132, 290), 180, 360, fill=(95, 100, 110))
    for i in range(5):
        y = 100 + i * 30
        d.rectangle((170, y, 230, y + 8), fill=(110, 110, 115))
        d.rectangle((245, y, 245 + rng.uniform(120, 230), y + 10), fill=(40, 40, 45))
    # Barcode.
    x = 170
    while x < 470:
        bar = rng.choice((2, 3, 5))
        d.rectangle((x, 268, x + bar, 310), fill=(30, 30, 30))
        x += bar + rng.choice((2, 3, 4))
    # Red seal half over the photo.
    seal = Image.new("RGBA", CARD, (0, 0, 0, 0))
    s = ImageDraw.Draw(seal)
    s.ellipse((100, 190, 190, 280), outline=(190, 30, 35, 200), width=5)
    s.ellipse((116, 206, 174, 264), outline=(190, 30, 35, 170), width=2)
    s.regular_polygon((145, 235, 14), 5, fill=(190, 30, 35, 190))
    img = Image.alpha_composite(img, seal.filter(ImageFilter.GaussianBlur(0.7)))
    return rounded_alpha(img, 22)


def notice(seed=41):
    rng = random.Random(seed)
    img = paper_base(SHEET, (240, 240, 236), seed, grain=5.0)
    d = ImageDraw.Draw(img)
    d.rectangle((90, 60, 422, 92), fill=(20, 20, 22))
    d.rectangle((160, 108, 352, 118), fill=(60, 60, 62))
    for i in range(10):
        y = 150 + i * 50
        d.ellipse((60, y, 70, y + 10), fill=(25, 25, 25))
        printed_lines(d, rng, 84, 452, y, y + 30, 14, (55, 55, 58), 6)
    tape = Image.new("RGBA", SHEET, (0, 0, 0, 0))
    t = ImageDraw.Draw(tape)
    t.polygon([(20, 10), (110, 0), (118, 36), (28, 46)], fill=(230, 220, 180, 120))
    t.polygon([(400, 0), (494, 12), (486, 48), (392, 36)], fill=(230, 220, 180, 120))
    return Image.alpha_composite(img, tape)


def log(seed=53):
    rng = random.Random(seed)
    img = paper_base(SHEET, (226, 222, 205), seed)
    d = ImageDraw.Draw(img)
    cols = (40, 120, 190, 400, 472)
    for x in cols:
        d.line((x, 60, x, 700), fill=(120, 110, 100), width=2)
    for y in range(60, 701, 32):
        d.line((40, y, 472, y), fill=(150, 140, 125), width=1)
    d.rectangle((40, 20, 472, 50), fill=(70, 65, 60))
    ink = (25, 30, 70)
    for y in range(124, 700, 32):
        if rng.random() < 0.2:
            continue
        pen_words(d, rng, cols[0] + 6, cols[1] - 4, y - 6, ink, slant=0.1)
        pen_words(d, rng, cols[1] + 6, cols[2] - 4, y - 6, ink, slant=0.1)
        pen_words(d, rng, cols[2] + 6, rng.uniform(260, 395), y - 6, ink)
    return stain(img, rng, 3, (130, 100, 60), 50)


def photo(seed=67, people=5, ground=(70, 80, 60), sky=(40, 45, 55)):
    """A dim snapshot: anonymous shapes in a lit room, white border. No people's faces."""
    rng = np.random.default_rng(seed)
    w, h = CARD
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    sky = np.stack([sky[0] + yy * 0.15, sky[1] + yy * 0.12, sky[2] + yy * 0.1], -1)
    img = Image.fromarray(np.clip(sky, 0, 255).astype(np.uint8), "RGB").convert("RGBA")
    d = ImageDraw.Draw(img)
    d.rectangle((0, 210, w, h), fill=ground)  # floor or pitch
    for i in range(people):
        x = w / 2 + (i - (people - 1) / 2) * 85 + rng.uniform(-10, 10)
        tone = tuple(int(c) for c in rng.uniform(60, 160, 3))
        d.ellipse((x - 16, 95, x + 16, 135), fill=(150, 120, 100))
        d.rounded_rectangle((x - 30, 132, x + 30, 250), 14, fill=tone + (255,))
    img = img.filter(ImageFilter.GaussianBlur(3))
    glare = Image.new("RGBA", CARD, (0, 0, 0, 0))
    ImageDraw.Draw(glare).polygon([(300, 0), (420, 0), (200, h), (90, h)], fill=(255, 255, 255, 26))
    img = Image.alpha_composite(img, glare)
    framed = Image.new("RGBA", CARD, (240, 238, 230, 255))
    framed.paste(img.resize((w - 28, h - 28)), (14, 14))
    return framed


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for name, fn in (("photocopy", photocopy), ("handwritten", handwritten), ("stamped", stamped),
                     ("notice", notice), ("log", log), ("photo", photo),
                     ("photo_family", lambda: photo(71, 3, (120, 95, 70), (150, 140, 120)))):
        fn().save(OUT / (name + ".png"))
        print("wrote", OUT / (name + ".png"))


if __name__ == "__main__":
    main()
