"""Pin only T-154 PNG imports to lossless, no mipmaps or 3D compression."""
from pathlib import Path
import re
root = Path(__file__).resolve().parents[2] / 'game/assets/textures/ch1_models'
for path in root.glob('*.png.import'):
    text = path.read_text(encoding='utf-8')
    for key,value in [('compress/mode','0'),('mipmaps/generate','false'),('detect_3d/compress_to','0')]:
        text = re.sub(re.escape(key) + r'=.*', key + '=' + value, text)
    path.write_text(text,encoding='utf-8',newline='\n')
