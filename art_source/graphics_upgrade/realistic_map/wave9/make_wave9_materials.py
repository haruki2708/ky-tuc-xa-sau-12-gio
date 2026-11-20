"""T-266 wave 9: the pilot's Godot materials (W9*), each glb's .import (placeholders mapped onto the shared .tres through
use_external, no texture inside a glb) and each new texture's .import written before Godot first sees the PNG: VRAM compressed
(compress/mode=2), normal maps flagged (compress/normal_map=1), mipmaps on (card section 5).

Reused (already in the game, sources in the earlier waves' CREDITS): W1WoodPale, W1Steel, W1Alu, W1Enamel, W1Iron, W1DoorPaint,
W2Tube, W2Glass, W6Stainless, W6ScreenOn, W8FloorCeramic, W8WallIvory, W8DadoGreen, W8Skirting, W8CeilingPanel, WRVent,
CCClothGrey; the room door's own textures (room407_shell/doors/door_room_*), the curtain cloth scans of floor4_rooms, wave 1's
grey paint normal, wave 6's ceiling panel.
Run: python -B art_source/graphics_upgrade/realistic_map/wave9/make_wave9_materials.py  (then godot --import twice)
"""
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave4"))
import make_wave4_materials as M4  # noqa: E402  (writers; its main is guarded)

ROOT = HERE.parents[3]
GAME = ROOT / "game"
MODELS = GAME / "assets/models/graphics_pilot/realistic_map/wave9"
MATS = MODELS / "materials"
TEXTURES = GAME / "assets/textures/graphics_pilot/realistic_map/wave9"
RES = dict(M4.RES, W5="res://assets/models/graphics_pilot/realistic_map/wave5/materials/",
	W6="res://assets/models/graphics_pilot/realistic_map/wave6/materials/",
	W7="res://assets/models/graphics_pilot/realistic_map/wave7/materials/",
	W8="res://assets/models/graphics_pilot/realistic_map/wave8/materials/",
	W9="res://assets/models/graphics_pilot/realistic_map/wave9/materials/",
	WR="res://assets/models/graphics_pilot/realistic_map/floor4_rest/materials/",
	CC="res://assets/models/graphics_pilot/realistic_map/floor4_rest/materials/")
OWN1 = M4.OWN1
OWN6 = "res://assets/textures/graphics_pilot/realistic_map/wave6/"
OWN8 = "res://assets/textures/graphics_pilot/realistic_map/wave8/"
OWN9 = "res://assets/textures/graphics_pilot/realistic_map/wave9/"
ROOMS = "res://assets/textures/graphics_pilot/floor4_rooms/"
DOOR = "res://assets/models/graphics_pilot/room407_shell/doors/door_room_door_room_"


def looks():
	return {
		# Room 407: the slat's underside (the scrap's words; the capture swaps the style), raw pine on cut edges and splinters.
		"W9SlatUnder": {"albedo": OWN9 + "slat_2_loang.png", "rough": 0.85},
		"W9RawWood": {"albedo": OWN9 + "slat_plain.png", "rough": 0.88, "normal": OWN1 + "paint_grey_normal.png", "normal_scale": 0.2},
		"W9Skin": {"albedo": OWN9 + "zombie_skin.png", "rough": 0.62},
		"W9Soot": {"color": (0.05, 0.05, 0.045), "rough": 0.95},
		"W9HatchPaint": {"color": (0.6, 0.59, 0.55), "rough": 0.45, "metallic": 0.1, "normal": OWN1 + "paint_grey_normal.png", "normal_scale": 0.3},
		"W9Void": {"color": (0.015, 0.015, 0.015), "rough": 1.0},
		"W9Gypsum": {"albedo": OWN6 + "ceiling_panel_color.png", "color": (0.72, 0.71, 0.67), "rough": 0.9,
			"normal": OWN6 + "ceiling_panel_normal.png", "normal_scale": 0.6},
		# The ward (rough pilot): vinyl, sheets and blanket kept under ~0.6 so brightness 1.45 does not burn them white.
		"W9Vinyl": {"color": (0.16, 0.3, 0.26), "rough": 0.38},
		"W9Sheet": {"albedo": ROOMS + "curtain_grey.jpg", "color": (0.98, 1.0, 0.98), "rough": 0.95, "scale": 3.0},
		"W9Blanket": {"albedo": OWN9 + "blanket_check.png", "rough": 0.95},
		"W9Bandage": {"albedo": ROOMS + "curtain_grey.jpg", "color": (1.12, 1.1, 1.02), "rough": 0.9, "scale": 6.0},
		"W9Hair": {"color": (0.04, 0.035, 0.03), "rough": 0.6},
		"W9SkinPatient": {"color": (0.6, 0.48, 0.4), "rough": 0.6},
		"W9Laminate": {"color": (0.5, 0.53, 0.5), "rough": 0.4},
		"W9Cabinet": {"color": (0.55, 0.56, 0.5), "rough": 0.45, "normal": OWN1 + "paint_grey_normal.png", "normal_scale": 0.4},
		"W9WindowDay": {"color": (0.5, 0.55, 0.57), "rough": 0.2, "emission": (0.55, 0.6, 0.64), "energy": 0.35},
		"W9CorridorGlow": {"color": (0.5, 0.52, 0.5), "rough": 0.9, "emission": (0.5, 0.52, 0.48), "energy": 0.25},
		"W9DadoLine": {"color": (0.2, 0.3, 0.27), "rough": 0.5},
		# The ward's own paint, tiles and ceiling (D-166: a public ward, soft and light): the approved plaster, wave 6's ceramic
		# and ceiling panels, lighter and cleaner than the library's night versions.
		"W9WardWall": {"shader": {"kind": 0, "base_albedo": M4.PLASTER + "cream_color.jpg", "base_normal": M4.PLASTER + "normal.jpg",
			"base_arm": M4.PLASTER + "arm.jpg", "mask": OWN8 + "mask_walls8.png", "peel": True,
			"base_tint": M4.tint_to(M4.PLASTER + "cream_color.jpg", (0.62, 0.61, 0.55)), "grime_strength": 0.5, "stain_strength": 0.4,
			"mould_strength": 0.3, "normal_strength": 0.5, "grime_color": (0.45, 0.42, 0.36)}},
		"W9WardDado": {"shader": {"kind": 0, "base_albedo": M4.PLASTER + "cream_color.jpg", "base_normal": M4.PLASTER + "normal.jpg",
			"base_arm": M4.PLASTER + "arm.jpg", "mask": OWN8 + "mask_walls8.png", "peel": True,
			"base_tint": M4.tint_to(M4.PLASTER + "cream_color.jpg", (0.36, 0.48, 0.43)), "grime_strength": 0.6, "stain_strength": 0.3,
			"mould_strength": 0.3, "normal_strength": 0.4, "grime_color": (0.4, 0.4, 0.34)}},
		"W9WardFloor": {"shader": {"kind": 1, "base_albedo": OWN6 + "ceramic_color.png", "base_normal": OWN6 + "ceramic_normal.png",
			"base_arm": OWN6 + "ceramic_orm.png", "mask": OWN8 + "mask_floor8.png", "base_tint": (0.66, 0.67, 0.65), "grout_strength": 0.8,
			"grime_strength": 0.5, "wet_strength": 0.2, "wear_strength": 0.4, "normal_strength": 0.6, "grime_color": (0.45, 0.42, 0.36)}},
		"W9WardCeiling": {"shader": {"kind": 0, "base_albedo": OWN6 + "ceiling_panel_color.png", "base_normal": OWN6 + "ceiling_panel_normal.png",
			"base_arm": OWN6 + "ceiling_panel_orm.png", "mask": OWN8 + "mask_ceiling8.png", "base_tint": (0.66, 0.66, 0.63), "peel_strength": 0.0,
			"grime_strength": 0.4, "stain_strength": 0.35, "mould_strength": 0.2, "normal_strength": 0.5, "grime_color": (0.5, 0.47, 0.4),
			"stain_color": (0.74, 0.62, 0.4)}},
		"W9MonitorScreen": {"albedo": OWN9 + "monitor_screen.png", "color": (0.2, 0.2, 0.2), "rough": 0.2,
			"emission": (1.0, 1.0, 1.0), "energy": 0.8},
	}


SPECIAL = {
	# The room door's own look (the game's door_room textures): rm holds roughness in green, metal in blue.
	"W9DoorRoom": '[gd_resource type="StandardMaterial3D" format=3]\n\n'
		f'[ext_resource type="Texture2D" path="{DOOR}basecolor.jpg" id="1"]\n'
		f'[ext_resource type="Texture2D" path="{DOOR}normal.jpg" id="2"]\n'
		f'[ext_resource type="Texture2D" path="{DOOR}rm.jpg" id="3"]\n\n'
		'[resource]\nresource_name = "W9DoorRoom"\nalbedo_texture = ExtResource("1")\nmetallic = 1.0\nmetallic_texture = ExtResource("3")\n'
		'metallic_texture_channel = 2\nroughness_texture = ExtResource("3")\nroughness_texture_channel = 1\nnormal_enabled = true\n'
		'normal_texture = ExtResource("2")\n',
	"W9Cracks": '[gd_resource type="StandardMaterial3D" format=3]\n\n'
		f'[ext_resource type="Texture2D" path="{OWN9}door_cracks.png" id="1"]\n\n'
		'[resource]\nresource_name = "W9Cracks"\ntransparency = 2\nalpha_scissor_threshold = 0.35\nalbedo_texture = ExtResource("1")\n'
		'roughness = 0.85\n',
	"W9Screen": '[gd_resource type="StandardMaterial3D" format=3]\n\n'
		f'[ext_resource type="Texture2D" path="{OWN9}screen_mesh.png" id="1"]\n\n'
		'[resource]\nresource_name = "W9Screen"\ntransparency = 2\nalpha_scissor_threshold = 0.4\ncull_mode = 2\nalbedo_texture = ExtResource("1")\n'
		'roughness = 0.8\nmetallic = 0.3\nuv1_scale = Vector3(1, 1, 1)\n',
	"W9CurtainNet": '[gd_resource type="StandardMaterial3D" format=3]\n\n'
		f'[ext_resource type="Texture2D" path="{OWN9}screen_mesh.png" id="1"]\n\n'
		'[resource]\nresource_name = "W9CurtainNet"\ntransparency = 2\nalpha_scissor_threshold = 0.4\ncull_mode = 2\n'
		'albedo_color = Color(1.4, 1.5, 1.45, 1)\nalbedo_texture = ExtResource("1")\nroughness = 0.9\nuv1_scale = Vector3(1.5, 1.5, 1.5)\n',
	# Y1's shadows: no light added; the two figures as a soft dark stain on the pleats (alpha), lit like the curtain.
	"W9Shadow": '[gd_resource type="StandardMaterial3D" format=3]\n\n'
		f'[ext_resource type="Texture2D" path="{OWN9}nurse_shadow.png" id="1"]\n\n'
		'[resource]\nresource_name = "W9Shadow"\ntransparency = 1\ncull_mode = 2\nalbedo_texture = ExtResource("1")\nroughness = 1.0\n',
	"W9Curtain": '[gd_resource type="StandardMaterial3D" format=3]\n\n'
		f'[ext_resource type="Texture2D" path="{ROOMS}curtain_blue.jpg" id="1"]\n\n'
		'[resource]\nresource_name = "W9Curtain"\ncull_mode = 2\nalbedo_color = Color(0.98, 1.13, 0.91, 1)\nalbedo_texture = ExtResource("1")\n'
		'roughness = 0.95\n',
	"W9IVBag": '[gd_resource type="StandardMaterial3D" format=3]\n\n[resource]\nresource_name = "W9IVBag"\ntransparency = 1\n'
		'albedo_color = Color(0.82, 0.85, 0.84, 0.45)\nroughness = 0.15\n',
}


def main():
	MATS.mkdir(parents=True, exist_ok=True)
	M4.MATS, M4.MODELS, M4.TEXTURES, M4.RES = MATS, MODELS, TEXTURES, RES
	M4.GLB_IMPORT = M4.GLB_IMPORT.replace("realistic_map/wave4/{glb}", "realistic_map/wave9/{glb}")
	all_looks = looks()
	for name, look in all_looks.items():
		M4.write_material(name, look)
	for name, text in SPECIAL.items():
		(MATS / f"{name}.tres").write_text(text, encoding="utf-8", newline="\n")
	known = set(all_looks) | set(SPECIAL)
	for wave in ("wave1", "wave2", "wave3", "wave4", "wave5", "wave6", "wave7", "wave8", "floor4_rest"):
		known |= {p.stem for p in (GAME / f"assets/models/graphics_pilot/realistic_map/{wave}/materials").glob("*.tres")}
	for glb in sorted(MODELS.glob("*.glb")):
		M4.write_glb_import(glb, known)
	M4.write_texture_imports()


if __name__ == "__main__":
	main()
