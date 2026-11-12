"""Arrange untouched chapter screenshots into labelled before/after sheets."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
OUT = HERE.parent / 'previews/t252'
FONT_PATH = HERE.parents[3] / 'game/assets/fonts/be_vietnam_pro_regular.ttf'
FONT = ImageFont.truetype(str(FONT_PATH), 25)
SMALL = ImageFont.truetype(str(FONT_PATH), 21)


def sheet(chapter, views, filename):
    cell_w, cell_h, label_h = 960, 540, 36
    canvas = Image.new('RGB', (cell_w*2, 80+(cell_h+label_h)*len(views)), '#171b20')
    draw = ImageDraw.Draw(canvas)
    draw.text((18, 10), f'T-252 | Chương {chapter} | Cùng camera, ánh sáng và trạng thái cửa', font=FONT, fill='white')
    draw.text((18, 45), 'TRƯỚC — PS1 A03, hành lang G5 giữ nguyên', font=SMALL, fill='#c3cbd2')
    draw.text((cell_w+18, 45), 'SAU — module Blender, vật liệu CC0 phòng 407', font=SMALL, fill='#c3cbd2')
    for row, view in enumerate(views):
        for col, state in enumerate(['before', 'after']):
            file = OUT/f'ch{chapter}_{state}_{view}.jpg'
            with Image.open(file) as image:
                assert image.size == (1920,1080), file
                canvas.paste(image.resize((cell_w,cell_h), Image.Resampling.LANCZOS),
                             (col*cell_w,80+row*(cell_h+label_h)))
            label = ('Phòng '+view.split('_')[1]+' — mở cửa để kiểm hình, có đèn pin'
                     if view.startswith('room_') else 'Dọc hành lang — cửa đóng như đầu chương')
            draw.text((col*cell_w+15,80+row*(cell_h+label_h)+cell_h+3),label,font=SMALL,fill='white')
    canvas.save(OUT/filename, quality=92)


if __name__ == '__main__':
    for chapter in [1,3]:
        sheet(chapter, ['hall_west_closed', 'room_401_inspection_torch', 'room_403_inspection_torch',
                        'room_408_inspection_torch', 'room_408_side_inspection_torch'], f'compare_ch{chapter}.jpg')
        sheet(chapter, [f'room_{n}_inspection_torch' for n in [402,404,405,406]]+['hall_east_closed'],
              f'compare_ch{chapter}_remaining.jpg')
    print('RESULT: T-252 four before/after sheets PASS (40 source screenshots, no exposure edits)')
