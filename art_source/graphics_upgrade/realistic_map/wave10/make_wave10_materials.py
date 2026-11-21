"""T-267 wave 10: each glb's .import (its placeholder materials mapped onto the shared wave 1-2 .tres through use_external,
no texture inside a glb). Wave 10 adds no material and no texture of its own (card section 5: reuse first); should one
come, its texture's .import is written VRAM compressed (compress/mode=2, normal maps compress/normal_map=1).
Run: python -B art_source/graphics_upgrade/realistic_map/wave10/make_wave10_materials.py  (then godot --import twice)
"""
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave4"))
import make_wave4_materials as M4  # noqa: E402  (writers; its main is guarded)

ROOT = HERE.parents[3]
GAME = ROOT / "game"
MODELS = GAME / "assets/models/graphics_pilot/realistic_map/wave10"
TEXTURES = GAME / "assets/textures/graphics_pilot/realistic_map/wave10"


def main():
	M4.MODELS, M4.TEXTURES = MODELS, TEXTURES
	M4.GLB_IMPORT = M4.GLB_IMPORT.replace("realistic_map/wave4/{glb}", "realistic_map/wave10/{glb}")
	known = set()
	for wave in ("wave1", "wave2"):
		known |= {p.stem for p in (GAME / f"assets/models/graphics_pilot/realistic_map/{wave}/materials").glob("*.tres")}
	for glb in sorted(MODELS.glob("*.glb")):
		M4.write_glb_import(glb, known)
	if TEXTURES.exists():
		M4.write_texture_imports()


if __name__ == "__main__":
	main()
