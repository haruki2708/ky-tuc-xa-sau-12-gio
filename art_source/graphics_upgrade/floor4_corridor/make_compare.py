"""T-233: before/after sheets of the pilot captures (previews/before_* | after_* -> previews/compare_*.jpg).
Run after the "g5" stage of run_stage.ps1:  python -B make_compare.py
Views 01-04 compare with T-229's survey photos (same camera, same scene lights); the others were taken
before/after in one run. The railing variant sheet puts the two railings side by side.
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent / "previews"
VIEWS = ["01_west_night", "02_east_night", "03_door407_night", "04_door407_torch", "13_door406_night",
         "14_door406_torch", "15_railing_night", "16_railing_torch", "17_wall_base_torch", "18_ceiling_lamp_night",
         "19_door406_open_torch", "21_segment_in_corridor_night"]
# (sheet, left image, left label, right image, right label)
VARIANTS = [("compare_20_railing_variants", "after_15_railing_night", "Lan can A1: song đứng cách 12,5 cm (mặc định của mẫu)",
             "after_20_railing_night_classic", "Lan can A2: giữ nhịp 0,5 m như bản PS1")]
W, H = 960, 540
BAR = 44


def font(size):
    for name in ("C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf"):
        if Path(name).exists():
            return ImageFont.truetype(name, size)
    return ImageFont.load_default()


def pair(left, left_label, right, right_label, out):
    sheet = Image.new("RGB", (2 * W, H + BAR), (12, 12, 12))
    draw = ImageDraw.Draw(sheet)
    big = font(24)
    for col, (path, label) in enumerate(((left, left_label), (right, right_label))):
        sheet.paste(Image.open(path).convert("RGB").resize((W, H), Image.LANCZOS), (col * W, BAR))
        draw.text((col * W + 12, 8), label, fill=(255, 225, 60), font=big)
    sheet.save(out, quality=88, optimize=True)


def main():
    made = []
    for view in VIEWS:
        before, after = HERE / f"before_{view}.jpg", HERE / f"after_{view}.jpg"
        if not (before.exists() and after.exists()):
            print("SKIP", view)
            continue
        pair(before, f"TRƯỚC: hành lang PS1   ({view})", after, "SAU: mẫu đoạn 406–407, phương án A (T-233)",
             HERE / f"compare_{view}.jpg")
        made.append(view)
    for sheet, left, left_label, right, right_label in VARIANTS:
        if (HERE / f"{left}.jpg").exists() and (HERE / f"{right}.jpg").exists():
            pair(HERE / f"{left}.jpg", left_label, HERE / f"{right}.jpg", right_label, HERE / f"{sheet}.jpg")
            made.append(sheet)
    # One page with every pair, small, to look through first.
    rows = [v for v in made if not v.startswith("compare_")]
    thumb_w, thumb_h = 640, 360
    overview = Image.new("RGB", (2 * thumb_w, len(rows) * (thumb_h + 30)), (12, 12, 12))
    draw = ImageDraw.Draw(overview)
    small = font(18)
    for row, view in enumerate(rows):
        y = row * (thumb_h + 30)
        for col, side in enumerate(("before", "after")):
            img = Image.open(HERE / f"{side}_{view}.jpg").convert("RGB").resize((thumb_w, thumb_h), Image.LANCZOS)
            overview.paste(img, (col * thumb_w, y + 30))
        draw.text((8, y + 4), f"{view}   TRƯỚC (PS1)  |  SAU (mẫu T-233)", fill=(255, 225, 60), font=small)
    overview.save(HERE / "compare_overview.jpg", quality=84, optimize=True)
    print("RESULT: corridor compare sheets", len(made))


if __name__ == "__main__":
    main()
