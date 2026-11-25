"""T-273: sheets of before | after | reference for the same camera.

    python -I compare.py <after folder under build/graphics> <out.jpg> [name filter ...] [--width=N]

before  build/graphics/anh_hien_trang/<area>/<name>.jpg   (capture_atlas.gd, look off)
after   build/graphics/<after folder>/<area>/<name>.jpg   (capture_atlas.gd -- --look=1 --out=<after folder>)
target  build/graphics/anh_gpt/<area>/<name>_gpt.png      (the 208 pictures the owner approved, D-200)

A filter keeps the stills whose "<area>/<name>" contains it; with none, every still that has an after picture.
"""
import os
import sys

from PIL import Image, ImageDraw

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', 'build', 'graphics'))


def main() -> None:
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    width = 480
    for a in sys.argv[1:]:
        if a.startswith('--width='):
            width = int(a.split('=')[1])
    after_root, out, filters = os.path.join(ROOT, args[0]), args[1], args[2:]
    height = width * 9 // 16
    rows = []
    for area in sorted(os.listdir(after_root)):
        folder = os.path.join(after_root, area)
        if not os.path.isdir(folder):
            continue
        for file in sorted(os.listdir(folder)):
            name = os.path.splitext(file)[0]
            if filters and not any(f in area + '/' + name for f in filters):
                continue
            rows.append((area, name, os.path.join(folder, file)))
    sheet = Image.new('RGB', (width * 3, (height + 14) * len(rows)), (16, 16, 16))
    draw = ImageDraw.Draw(sheet)
    for i, (area, name, after) in enumerate(rows):
        y = i * (height + 14)
        draw.text((4, y + 1), '%s/%s   before | after | reference' % (area, name), fill=(255, 235, 60))
        pictures = [os.path.join(ROOT, 'anh_hien_trang', area, name + '.jpg'), after,
                    os.path.join(ROOT, 'anh_gpt', area, name + '_gpt.png')]
        for column, path in enumerate(pictures):
            if os.path.exists(path):
                sheet.paste(Image.open(path).convert('RGB').resize((width, height), Image.LANCZOS), (column * width, y + 14))
    sheet.save(out, quality=88)
    print('%d rows -> %s' % (len(rows), out))


if __name__ == '__main__':
    main()
