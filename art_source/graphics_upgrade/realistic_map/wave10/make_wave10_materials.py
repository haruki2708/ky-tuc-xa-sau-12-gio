"""T-267 wave 10: the corridor's own materials and each glb's .import (its placeholder materials mapped onto shared .tres
through use_external, no texture inside a glb). Reuse first (card section 5): the room's shell, door, balcony door and
the corridor's rails, batten and night stay on wave 1-2's materials. D-188 point 5: the corridor's walls, floor and
ceiling get their own materials (CW*), wave 2's hall looks on the same scans (room 407's plaster, wave 1's terrazzo)
with this wave's small masks (make_wave10_textures.py) instead of wave 2's 4096 px ones. The open upper net
(build_wave10_net.py) maps onto CWNetWeave / CWNetHem: room 407's net look on room 407's weave texture.
Every texture in this wave's folder imports VRAM compressed (compress/mode=2; normal maps compress/normal_map=1).
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
MATS = MODELS / "materials"
TEXTURES = GAME / "assets/textures/graphics_pilot/realistic_map/wave10"
OWN10 = "res://assets/textures/graphics_pilot/realistic_map/wave10/"
WEAVE = "res://assets/models/graphics_pilot/room407_furnished/mosquito_net_lower_open_mosquito_net_weave.png"
PLASTER = {"base_albedo": M4.PLASTER + "cream_color.jpg", "base_normal": M4.PLASTER + "normal.jpg",
	"base_arm": M4.PLASTER + "arm.jpg"}
TERRAZZO = {"base_albedo": M4.OWN1 + "terrazzo_color.png", "base_normal": M4.OWN1 + "terrazzo_normal.png",
	"base_arm": M4.OWN1 + "terrazzo_orm.png"}
# Wave 2's W2HallWall / W2HallDado / W2HallCeiling / W2HallFloor, each on its own small mask.
HALL = {
	"CWHallWall": {"kind": 0, **PLASTER, "mask": OWN10 + "mask_cctv_hall_wall.png", "base_tint": (0.9, 0.88, 0.82),
		"grime_strength": 1.2, "stain_strength": 0.45, "peel": True},
	"CWHallDado": {"kind": 0, **PLASTER, "mask": OWN10 + "mask_cctv_hall_wall.png", "base_tint": (0.6, 0.7, 0.68),
		"grime_strength": 1.3, "stain_strength": 0.35, "peel": True},
	"CWHallCeiling": {"kind": 0, **PLASTER, "mask": OWN10 + "mask_cctv_hall_ceiling.png", "base_tint": (0.93, 0.92, 0.86),
		"normal_strength": 0.5, "stain_strength": 0.4, "peel": True},
	"CWHallFloor": {"kind": 1, **TERRAZZO, "mask": OWN10 + "mask_cctv_hall_floor.png", "grime_strength": 0.75,
		"wear_strength": 0.7, "normal_strength": 0.5},
}
# Room 407's nets as Godot imports them from build_nets.py's glb (BLENDED, no back-face culling).
NETS = {
	"CWNetWeave": '[gd_resource type="StandardMaterial3D" format=3]\n\n'
		f'[ext_resource type="Texture2D" path="{WEAVE}" id="1"]\n\n'
		'[resource]\nresource_name = "CWNetWeave"\ntransparency = 1\ncull_mode = 2\n'
		'albedo_texture = ExtResource("1")\nroughness = 0.9\n',
	"CWNetHem": '[gd_resource type="StandardMaterial3D" format=3]\n\n'
		'[resource]\nresource_name = "CWNetHem"\ncull_mode = 2\nalbedo_color = Color(0.82, 0.81, 0.76, 1)\nroughness = 0.95\n',
}


## A30 (build_wave10_a30.py): room 407's small things, set on their mesh nodes (surface_material_override/0). The cover
## and the page keep the prints they had (the game's own 128 px sport.png and paper.png, now smoothly filtered and lit,
## not PS1-snapped); the rest are plain colours, no texture.
CH1 = "res://assets/textures/ch1_models/"
A30 = {
	"A30Cover": {"albedo": CH1 + "sport.png", "rough": 0.62},
	"A30Paper": {"albedo": CH1 + "paper.png", "rough": 0.92},
	"A30Ring": {"color": (0.62, 0.63, 0.62), "rough": 0.32, "metallic": 1.0},
	"A30Ink": {"color": (0.05, 0.05, 0.065), "rough": 0.9},
	"A30Ivory": {"color": (0.72, 0.7, 0.58), "rough": 0.42},
	"A30Dark": {"color": (0.035, 0.031, 0.025), "rough": 0.7},
	"A30Steel": {"color": (0.55, 0.55, 0.53), "rough": 0.38, "metallic": 0.85},
	"A30Plastic": {"color": (0.86, 0.86, 0.83), "rough": 0.34},
}


def main():
	MATS.mkdir(parents=True, exist_ok=True)
	M4.MATS, M4.MODELS, M4.TEXTURES = MATS, MODELS, TEXTURES
	for name, look in A30.items():
		M4.write_material(name, look)
	M4.RES["CW"] = "res://assets/models/graphics_pilot/realistic_map/wave10/materials/"
	M4.GLB_IMPORT = M4.GLB_IMPORT.replace("realistic_map/wave4/{glb}", "realistic_map/wave10/{glb}")
	for name, params in HALL.items():
		M4.write_shader_material(name, params, M4.SHELL_SHADER)
	for name, text in NETS.items():
		(MATS / f"{name}.tres").write_text(text, encoding="utf-8", newline="\n")
	known = set(HALL) | set(NETS)
	for wave in ("wave1", "wave2"):
		known |= {p.stem for p in (GAME / f"assets/models/graphics_pilot/realistic_map/{wave}/materials").glob("*.tres")}
	for glb in sorted(MODELS.glob("*.glb")):
		M4.write_glb_import(glb, known)
	if TEXTURES.exists():
		M4.write_texture_imports()


if __name__ == "__main__":
	main()
