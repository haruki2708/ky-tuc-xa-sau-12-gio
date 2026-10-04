"""Run after the initial Godot import; only pins T-153 import files."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
for path in (ROOT / "game/assets/models/room407").glob("*.glb.import"):
    content = path.read_text(encoding="utf-8")
    content = re.sub(r'import_script/path="[^"]*"', 'import_script/path="res://assets/models/room407/room407_import.gd"', content)
    path.write_text(content, encoding="utf-8", newline="\n")
for path in (ROOT / "game/assets/textures/room407").glob("*.png.import"):
    content = path.read_text(encoding="utf-8")
    content = re.sub(r"compress/mode=\d+", "compress/mode=0", content)
    content = re.sub(r"mipmaps/generate=\w+", "mipmaps/generate=false", content)
    content = re.sub(r"detect_3d/compress_to=\d+", "detect_3d/compress_to=0", content)
    path.write_text(content, encoding="utf-8", newline="\n")
print("ROOM407_IMPORT_RESULT: PS1 materials and lossless textures pinned")
