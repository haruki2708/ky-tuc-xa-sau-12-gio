"""T-255: the shared Godot materials (F4*) of the floor-4 room shells and furniture tints, and each room glb's .import
mapping its placeholders onto them (W1* onto wave 1's). Room 407's looks (room407_furnish.gd SHELL_LOOKS: its plaster,
floor and bathroom tiles, exterior render) on this task's mask atlas (make_room_textures.py); no texture is copied.
Run: python -B art_source/graphics_upgrade/floor4_rooms/make_room_materials.py
"""
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[0] / "realistic_map" / "wave2"))
import make_wave2_materials as M  # noqa: E402

ROOT = HERE.parents[2]
MODELS = ROOT / "game/assets/models/graphics_pilot/floor4_rooms"
RES_F4 = "res://assets/models/graphics_pilot/floor4_rooms/materials/"
SHELL = "res://assets/textures/graphics_pilot/room407_shell/"
CORNER = "res://assets/models/graphics_pilot/room407_corner/"
FURN = "res://assets/models/graphics_pilot/room407_furnished/"
PLASTER = CORNER + "architecture_painted_plaster_wall_"
MASK = "res://assets/textures/graphics_pilot/floor4_rooms/mask_rooms.png"
FRAME = "res://assets/models/graphics_pilot/room407_shell/frames_distressed_painted_planks_"
WALL = {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg",
	"base_arm": PLASTER + "arm.jpg", "peel": True, "mask": MASK}
LOOKS = {
	"F4Wall": {"shader": {**WALL, "base_tint": (0.95, 0.91, 0.83), "grime_strength": 1.5, "stain_strength": 1.3,
		"mould_strength": 1.2}},
	"F4Ceiling": {"shader": {**WALL, "base_tint": (1.0, 0.97, 0.88), "normal_strength": 0.5, "grime_strength": 1.4,
		"stain_strength": 1.3}},
	"F4Exterior": {"shader": {"kind": 0, "base_albedo": SHELL + "plastered_wall_02_color.jpg",
		"base_normal": SHELL + "plastered_wall_02_normal.jpg", "base_arm": SHELL + "plastered_wall_02_arm.jpg",
		"mask": MASK, "peel": True, "base_tint": (1.0, 0.9, 0.66)}},
	"F4Floor": {"shader": {"kind": 1, "base_albedo": CORNER + "floor_interior_tiles_color.jpg",
		"base_normal": CORNER + "floor_interior_tiles_normal.jpg", "base_arm": CORNER + "floor_interior_tiles_arm.jpg",
		"mask": MASK, "grime_strength": 1.6, "wet_strength": 1.3, "grout_strength": 1.3}},
	"F4Skirting": {"shader": {"kind": 1, "base_albedo": CORNER + "floor_interior_tiles_color.jpg",
		"base_normal": CORNER + "floor_interior_tiles_normal.jpg", "base_arm": CORNER + "floor_interior_tiles_arm.jpg",
		"mask": MASK}},
	"F4BathFloor": {"shader": {"kind": 1, "base_albedo": SHELL + "anti_skid_tiles_color.jpg",
		"base_normal": SHELL + "anti_skid_tiles_normal.jpg", "base_arm": SHELL + "anti_skid_tiles_arm.jpg",
		"mask": MASK, "base_tint": (0.86, 0.84, 0.82)}},
	"F4BalconyFloor": {"shader": {"kind": 1, "base_albedo": SHELL + "floor_tiles_08_color.jpg",
		"base_normal": SHELL + "floor_tiles_08_normal.jpg", "base_arm": SHELL + "floor_tiles_08_arm.jpg", "mask": MASK}},
	"F4BathTiles": {"albedo": FURN + "bath_tiles_long_white_tiles_color.jpg", "orm": FURN + "bath_tiles_long_white_tiles_arm.jpg",
		"normal": FURN + "bath_tiles_long_white_tiles_normal.jpg", "normal_scale": 0.7},
	"F4FrameGreen": {"albedo": SHELL + "frame_green_color.jpg", "orm": FRAME + "arm.jpg", "normal": FRAME + "normal.jpg",
		"normal_scale": 0.6},
	"F4Alu": {"albedo": SHELL + "aluminium_color.jpg", "orm": SHELL + "aluminium_arm.jpg", "scale": 2.0, "color": (0.92, 0.92, 0.9)},
	"F4Louvre": {"color": (0.66, 0.7, 0.68), "rough": 0.3},
	"F4Drain": {"color": (0.5, 0.5, 0.48), "rough": 0.35, "metal": 1.0},
	"F4Enamel": {"color": (0.78, 0.75, 0.64), "rough": 0.42},
	"F4TubeGlass": {"color": (0.92, 0.94, 0.9), "rough": 0.25},
	"F4Wire": {"color": (0.16, 0.16, 0.15), "rough": 0.85},
}


def main():
	M.MATS = MODELS / "materials"
	M.RES_W2 = RES_F4
	M.IMPORT = M.IMPORT.replace("realistic_map/wave2/{glb}", "floor4_rooms/{glb}")
	for name, look in LOOKS.items():
		M.write_material(name, look)
	known = M.wave1_names() | set(LOOKS)
	old = M.glb_materials
	M.glb_materials = lambda path: [n for n in _names(path) if n[:2] in ("W1", "F4")]
	for glb in sorted(MODELS.glob("*.glb")):
		M.write_import(glb, known)


def _names(path):
	import json
	data = path.read_bytes()
	length = int.from_bytes(data[12:16], "little")
	return [m["name"] for m in json.loads(data[20:20 + length].decode("utf-8")).get("materials", [])]


if __name__ == "__main__":
	main()
