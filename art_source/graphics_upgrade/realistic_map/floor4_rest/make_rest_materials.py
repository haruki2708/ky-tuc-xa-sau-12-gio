"""T-256: the Godot materials (WR*, and later the parts' own) of the floor-4 rest (washroom, corridor props, CCTV set),
and each glb's .import mapping its placeholders onto them (W1* onto wave 1's). Room 407's scans and shell shader, no
texture copied; this task's only new textures are the washroom's mask and the mirror's stain (make_washroom_textures.py).
Run: python -B art_source/graphics_upgrade/realistic_map/floor4_rest/make_rest_materials.py
"""
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave2"))
import make_wave2_materials as M  # noqa: E402

ROOT = HERE.parents[3]
MODELS = ROOT / "game/assets/models/graphics_pilot/realistic_map/floor4_rest"
RES = "res://assets/models/graphics_pilot/realistic_map/floor4_rest/materials/"
SHELL = "res://assets/textures/graphics_pilot/room407_shell/"
CORNER = "res://assets/models/graphics_pilot/room407_corner/"
FURN = "res://assets/models/graphics_pilot/room407_furnished/"
PLASTER = CORNER + "architecture_painted_plaster_wall_"
TEX = "res://assets/textures/graphics_pilot/realistic_map/floor4_rest/"
MASK = TEX + "mask_washroom.png"
FRAME = "res://assets/models/graphics_pilot/room407_shell/frames_distressed_painted_planks_"
TILES = {"kind": 1, "base_albedo": FURN + "bath_tiles_long_white_tiles_color.jpg",
	"base_normal": FURN + "bath_tiles_long_white_tiles_normal.jpg", "base_arm": FURN + "bath_tiles_long_white_tiles_arm.jpg",
	"mask": MASK}
ANTI_SKID = {"kind": 1, "base_albedo": SHELL + "anti_skid_tiles_color.jpg", "base_normal": SHELL + "anti_skid_tiles_normal.jpg",
	"base_arm": SHELL + "anti_skid_tiles_arm.jpg", "mask": MASK}
WALL = {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg",
	"base_arm": PLASTER + "arm.jpg", "peel": True, "mask": MASK}
LOOKS = {
	# Pale green glazed tiles, smaller than room 407's bathroom's white ones (D-170: not the same room).
	"WRTiles": {"shader": {**TILES, "base_tint": (0.66, 0.74, 0.69), "grout_strength": 1.8, "grime_strength": 2.0,
		"wet_strength": 0.9, "normal_strength": 0.7, "grime_color": (0.5, 0.43, 0.32)}},
	"WRFloor": {"shader": {**ANTI_SKID, "base_tint": (0.62, 0.66, 0.64), "grout_strength": 1.3, "grime_strength": 1.5,
		"wet_strength": 1.2, "wear_strength": 1.0}},
	"WRStepTop": {"shader": {**ANTI_SKID, "base_tint": (0.58, 0.62, 0.6), "grime_strength": 1.6, "wet_strength": 1.3}},
	"WRPlaster": {"shader": {**WALL, "base_tint": (0.88, 0.88, 0.8), "grime_strength": 1.5, "stain_strength": 1.4,
		"mould_strength": 1.4}},
	"WRCeiling": {"shader": {**WALL, "base_tint": (0.92, 0.92, 0.86), "normal_strength": 0.5, "grime_strength": 1.4,
		"stain_strength": 1.3, "mould_strength": 1.5}},
	"WRDoorPaint": {"albedo": SHELL + "frame_green_color.jpg", "orm": FRAME + "arm.jpg", "normal": FRAME + "normal.jpg",
		"normal_scale": 0.6, "color": (0.72, 0.92, 1.0)},
	"WRCeramic": {"color": (0.9, 0.9, 0.86), "rough": 0.12},
	"WRChrome": {"color": (0.8, 0.8, 0.78), "rough": 0.24, "metal": 1.0},
	"WRPipe": {"color": (0.5, 0.51, 0.5), "rough": 0.55, "metal": 0.7},
	"WRPVC": {"color": (0.55, 0.57, 0.58), "rough": 0.55},
	"WRTubeGlass": {"color": (0.92, 0.94, 0.9), "rough": 0.25},
	"WRBlue": {"color": (0.1, 0.28, 0.58), "rough": 0.45},
	"WRRed": {"color": (0.58, 0.08, 0.06), "rough": 0.45},
	"WRGreen": {"color": (0.15, 0.44, 0.24), "rough": 0.45},
	"WRPink": {"color": (0.8, 0.44, 0.56), "rough": 0.45},
	"WRYellow": {"color": (0.82, 0.66, 0.2), "rough": 0.45},
	"WRGrey": {"color": (0.46, 0.48, 0.48), "rough": 0.5},
	"WRMop": {"color": (0.66, 0.64, 0.56), "rough": 0.95},
	"WRTowel": {"color": (0.46, 0.56, 0.66), "rough": 0.95, "two_sided": True},
	"WRSoap": {"color": (0.82, 0.72, 0.52), "rough": 0.35},
	"WRVent": {"color": (0.6, 0.58, 0.53), "rough": 0.9},
	"WRCork": {"color": (0.5, 0.38, 0.25), "rough": 0.9},
	"WRMirrorStain": {"albedo": TEX + "mirror_stain.png", "alpha": 1.0, "rough": 0.6},
}


def main():
	M.MATS = MODELS / "materials"
	M.RES_W2 = RES
	M.IMPORT = M.IMPORT.replace("realistic_map/wave2/{glb}", "realistic_map/floor4_rest/{glb}")
	M.MATS.mkdir(parents=True, exist_ok=True)
	for name, look in LOOKS.items():
		M.write_material(name, look)
	known = M.wave1_names() | set(LOOKS)
	M.glb_materials = lambda path: [n for n in _names(path) if n[:2] in ("W1", "WR", "CC", "CD")]
	for glb in sorted(MODELS.glob("*.glb")):
		M.write_import(glb, known)


def _names(path):
	import json
	data = path.read_bytes()
	length = int.from_bytes(data[12:16], "little")
	return [m["name"] for m in json.loads(data[20:20 + length].decode("utf-8")).get("materials", [])]


if __name__ == "__main__":
	main()
