"""Before/after sheets of the T-222 captures (previews/before|after -> previews/compare_*.jpg).
python -B make_compare.py
"""
from pathlib import Path

from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent / "previews"
SHEETS = {
    "compare_room": ["room_centre_tube", "door_overview_tube", "back_overview_tube", "door_wall_torch", "bunk_a_torch",
                     "bunk_b_tube"],
    "compare_details": ["t222_ceiling_tube", "t222_room_door_torch", "t222_bath_door_tube", "t222_skirting_torch",
                        "t222_switch_torch", "t222_wet_feet_torch"],
    "compare_balcony": ["balcony_side_tube", "t222_balcony_door_tube", "t222_balcony_out_torch", "t222_balcony_back_tube",
                        "bathroom_tube", "corridor_door_tube"],
}
W, H = 640, 360


def main():
    for sheet, views in SHEETS.items():
        out = Image.new("RGB", (2 * W, len(views) * (H + 4)), (0, 0, 0))
        draw = ImageDraw.Draw(out)
        for row, view in enumerate(views):
            for col, side in enumerate(("before", "after")):
                path = HERE / side / f"{view}.png"
                if not path.exists():
                    continue
                out.paste(Image.open(path).convert("RGB").resize((W, H)), (col * W, row * (H + 4)))
                draw.text((col * W + 8, row * (H + 4) + 6), f"{'TRUOC' if side == 'before' else 'SAU'}  {view}", fill=(255, 230, 0))
        out.save(HERE / f"{sheet}.jpg", quality=86, optimize=True)
        print("SHEET", sheet, len(views))


if __name__ == "__main__":
    main()
