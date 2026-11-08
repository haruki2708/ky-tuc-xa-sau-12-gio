"""T-233, T-235: before/after sheets of the corridor captures (before_* | after_* -> compare_*.jpg).
Run after the "g5" stage of run_stage.ps1:  python -B make_compare.py
Round 2 (T-235, the whole corridor) lives in previews/round2/; round 1's sheets (T-233) stay in previews/.
Every view was taken before (PS1) and after in one run, same camera and scene lights; the variant sheets put
the two room plates and the two looks of the old 408 doorway side by side.
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent / "previews" / "round2"
VIEWS = ["01_west_night", "02_east_night", "03_door407_night", "09_sealed_old408_night", "10_door408_torch",
         "13_door403_night", "14_door403_open_torch", "15_door408_night", "16_seal_night", "17_plate_night",
         "18_plate_torch", "19_west_end_night", "20_east_end_night", "21_west_end_campus_torch",
         "22_east_end_campus_torch"]
# (sheet, left image, left label, right image, right label)
VARIANTS = [
    ("compare_plates_night", "after_17_plate_night", "Biển A (mặc định): nhôm, số dập nổi sơn đen",
     "after_17b_plate_enamel_night", "Biển B: men xanh, số in trắng"),
    ("compare_plates_torch", "after_18_plate_torch", "Biển A, đèn pin", "after_18b_plate_enamel_torch", "Biển B, đèn pin"),
    ("compare_seal_variants", "after_16_seal_night", "Cửa 408 cũ, kiểu 1 (mặc định): xây kín, trát, giữ khung",
     "after_16b_seal_boarded_night", "Kiểu 2: ốp ván bắt vít trong khung cũ"),
]
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
    rows = []  # (left image, right image, label) for the overview
    for view in VIEWS:
        before, after = HERE / f"before_{view}.jpg", HERE / f"after_{view}.jpg"
        if not (before.exists() and after.exists()):
            print("SKIP", view)
            continue
        pair(before, f"TRƯỚC: hành lang PS1   ({view})", after, "SAU: cả hành lang, lượt 2 (T-235)",
             HERE / f"compare_{view}.jpg")
        rows.append((before, after, f"{view}   TRƯỚC (PS1)  |  SAU (T-235)"))
    for sheet, left, left_label, right, right_label in VARIANTS:
        if (HERE / f"{left}.jpg").exists() and (HERE / f"{right}.jpg").exists():
            pair(HERE / f"{left}.jpg", left_label, HERE / f"{right}.jpg", right_label, HERE / f"{sheet}.jpg")
            rows.append((HERE / f"{left}.jpg", HERE / f"{right}.jpg", f"{left_label}  |  {right_label}"))
    # One page with every pair, small, to look through first.
    thumb_w, thumb_h = 640, 360
    overview = Image.new("RGB", (2 * thumb_w, len(rows) * (thumb_h + 30)), (12, 12, 12))
    draw = ImageDraw.Draw(overview)
    small = font(18)
    for row, (left, right, label) in enumerate(rows):
        y = row * (thumb_h + 30)
        for col, path in enumerate((left, right)):
            overview.paste(Image.open(path).convert("RGB").resize((thumb_w, thumb_h), Image.LANCZOS), (col * thumb_w, y + 30))
        draw.text((8, y + 4), label, fill=(255, 225, 60), font=small)
    overview.save(HERE / "compare_overview.jpg", quality=84, optimize=True)
    print("RESULT: corridor compare sheets", len(rows))


if __name__ == "__main__":
    main()
