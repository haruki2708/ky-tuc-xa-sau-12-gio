"""T-263 wave 6: the canteen's Godot materials (W6*), each glb's .import (placeholders mapped onto the shared .tres through
use_external, no texture inside a glb) and each new texture's .import written before Godot first sees the PNG: VRAM
compressed (compress/mode=2), normal maps flagged (compress/normal_map=1), mipmaps on (card section 5).

Reused (already in the game; sources in art_source/graphics_upgrade/room407_corner/CREDITS.md, room407_shell and the
earlier waves' CREDITS): Painted Plaster Wall + Peeling Painted Wall (walls, dado, facade, as the approved plaster of
D-175/D-180), Long White Tiles (wainscot, the tiled counter and stove), Anti-skid tiles (kitchen floor), wave 1's
terrazzo (F2), the self-drawn aluminium (stainless, pots), wave 1/2/4 shared materials (W1Concrete, W1Iron, W1Alu,
W1Granite, W1Black, W1Enamel, W1RedPlastic, W1Wood, W1Clock*, W2Glass, W2Tube, W4RoofSheet, W4PoleSteel, W4SteelFrame).
Run: python -B art_source/graphics_upgrade/realistic_map/wave6/make_wave6_materials.py  (then godot --import twice)
"""
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave4"))
import make_wave4_materials as M4  # noqa: E402  (writers; its main is guarded)
sys.path.insert(0, str(HERE))
import canteen_layout as L  # noqa: E402

ROOT = HERE.parents[3]
GAME = ROOT / "game"
MODELS = GAME / "assets/models/graphics_pilot/realistic_map/wave6"
MATS = MODELS / "materials"
TEXTURES = GAME / "assets/textures/graphics_pilot/realistic_map/wave6"
RES = dict(M4.RES, W5="res://assets/models/graphics_pilot/realistic_map/wave5/materials/",
	W6="res://assets/models/graphics_pilot/realistic_map/wave6/materials/")
CORNER, SHELL, OWN1 = M4.CORNER, M4.SHELL, M4.OWN1
OWN6 = "res://assets/textures/graphics_pilot/realistic_map/wave6/"
FURNISHED = "res://assets/models/graphics_pilot/room407_furnished/"
PLASTER = M4.PLASTER
TILES = FURNISHED + "bath_tiles_long_white_tiles_"
tint_to = M4.tint_to

SIZES = L.SIZES


def paint(mask, tint, **extra):
	look = {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg", "base_arm": PLASTER + "arm.jpg",
		"mask": mask, "peel": True, "base_tint": tint, "grime_strength": 1.0, "stain_strength": 0.8, "mould_strength": 0.9,
		"normal_strength": 0.6, "grime_color": (0.45, 0.4, 0.32)}
	look.update(extra)
	return {"shader": look}


def tiles(base, mask, tint, ext="png", arm="orm", **extra):
	look = {"kind": 1, "base_albedo": base + "color." + ext, "base_normal": base + "normal." + ext, "base_arm": base + arm + "." + ext,
		"mask": mask, "base_tint": tint, "grout_strength": 1.0, "grime_strength": 1.0, "wet_strength": 1.0, "wear_strength": 0.8,
		"normal_strength": 0.7}
	look.update(extra)
	return {"shader": look}


def looks():
	walls = OWN6 + "mask_walls.png"
	floor = OWN6 + "mask_floor.png"
	pale_yellow = tint_to(PLASTER + "cream_color.jpg", (0.86, 0.79, 0.55))
	pale_green = tint_to(PLASTER + "cream_color.jpg", (0.64, 0.74, 0.64))
	dado_green = tint_to(PLASTER + "cream_color.jpg", (0.26, 0.4, 0.33))
	lime_yellow = tint_to(PLASTER + "cream_color.jpg", (0.78, 0.6, 0.27))   # vôi vàng (D-180 K1)
	return {
		# F1: cream ceramic 40 x 40 with white tile wainscot and pale yellow paint; F2: terrazzo, pale green paint
		# over a dark green oil-paint dado.
		"W6FloorCeramic": tiles(OWN6 + "ceramic_", floor, (1.0, 1.0, 1.0), grime_color=(0.42, 0.36, 0.27), wet_strength=0.9),
		"W6FloorTerrazzo": tiles(OWN1 + "terrazzo_", floor, (1.02, 1.0, 0.95), grime_color=(0.42, 0.36, 0.27), grout_strength=0.4,
			normal_strength=0.5),
		"W6WallYellow": paint(walls, pale_yellow),
		"W6WallGreen": paint(walls, pale_green),
		"W6Wainscot": tiles(TILES, walls, (0.96, 0.96, 0.92), ext="jpg", arm="arm", grout_strength=1.2, grime_strength=0.6, wet_strength=0.35,
			wear_strength=0.0, grime_color=(0.5, 0.44, 0.34)),
		"W6DadoGreen": paint(walls, dado_green, grime_strength=0.8, normal_strength=0.4),
		# C2: stained mineral-fibre panels (no paint to peel); the plenum behind the missing ones.
		"W6CeilingPanel": {"shader": {"kind": 0, "base_albedo": OWN6 + "ceiling_panel_color.png", "base_normal": OWN6 + "ceiling_panel_normal.png",
			"base_arm": OWN6 + "ceiling_panel_orm.png", "mask": OWN6 + "mask_ceiling.png", "peel_strength": 0.0, "grime_strength": 1.0,
			"stain_strength": 1.2, "mould_strength": 0.8, "normal_strength": 0.6, "grime_color": (0.5, 0.45, 0.36),
			"stain_color": (0.74, 0.58, 0.32)}},
		"W6Plenum": {"color": (0.035, 0.034, 0.032), "rough": 1.0},
		# Kitchen: anti-skid floor tiles, greasy; the K1 stove's cream glazed tiles under soot.
		"W6KitchenFloor": tiles(SHELL + "anti_skid_tiles_", floor, tint_to(SHELL + "anti_skid_tiles_color.jpg", (0.5, 0.48, 0.44)), ext="jpg", arm="arm", grout_strength=1.3,
			grime_strength=0.9, wet_strength=1.0, wear_strength=0.6, grime_color=(0.36, 0.3, 0.22)),
		"W6StoveTile": tiles(TILES, walls, (0.95, 0.9, 0.78), ext="jpg", arm="arm", grout_strength=1.5, grime_strength=1.3, wet_strength=0.4,
			wear_strength=0.0, grime_color=(0.22, 0.19, 0.15)),
		"W6CounterTile": tiles(TILES, walls, (1.0, 1.0, 0.97), ext="jpg", arm="arm", grout_strength=0.7, grime_strength=0.6, wet_strength=0.3,
			wear_strength=0.0, grime_color=(0.5, 0.44, 0.34)),
		# Facade: lime-washed yellow walls, whitewashed pilasters, bands and parapet (as the gate's booth and pillars).
		"W6FacadeYellow": paint(walls, lime_yellow, grime_strength=1.2, stain_strength=0.9, mould_strength=1.0,
			stain_color=(0.62, 0.5, 0.3), grime_color=(0.42, 0.38, 0.3)),
		"W6FacadeWhite": paint(walls, (0.98, 1.06, 1.25), grime_strength=1.2, stain_strength=0.8, mould_strength=1.0,
			grime_color=(0.42, 0.38, 0.3)),
		# Metal: brushed stainless (tables, counter, trays, hood, K2 range), dull aluminium pots, black cast iron.
		"W6Stainless": {"albedo": SHELL + "aluminium_color.jpg", "orm": SHELL + "aluminium_arm.jpg",
			"color": tint_to(SHELL + "aluminium_color.jpg", (0.72, 0.72, 0.7)), "scale": 2.0, "metallic_value": 0.25},
		"W6PotAlu": {"albedo": SHELL + "aluminium_color.jpg", "orm": SHELL + "aluminium_arm.jpg",
			"color": tint_to(SHELL + "aluminium_color.jpg", (0.46, 0.46, 0.44)), "scale": 1.0, "metallic_value": 0.7},
		"W6CastIron": {"color": (0.07, 0.07, 0.068), "rough": 0.55, "metallic": 0.55},
		# Plastics, tableware and food (palette cells), boards with their words, the TV.
		"W6PlasticBlue": {"color": (0.08, 0.18, 0.45), "rough": 0.45},
		"W6Palette": {"albedo": OWN6 + "palette.png", "rough": 0.45, "nearest": True},
		"W6PriceWood": {"albedo": OWN6 + "price_wood.png", "rough": 0.75},
		"W6PricePrint": {"albedo": OWN6 + "price_print.png", "rough": 0.4},
		"W6Sign": {"albedo": OWN6 + "sign_canteen.png", "rough": 0.55, "metallic": 0.15},
		"W6Slogan": {"albedo": OWN6 + "slogan.png", "rough": 0.6, "metallic": 0.1},
		"W6ScreenOff": {"color": (0.018, 0.02, 0.024), "rough": 0.12, "metallic": 0.2},
		"W6FanPaint": {"color": (0.74, 0.72, 0.64), "rough": 0.45, "metallic": 0.1},
		"W6Shutter": {"color": (0.52, 0.53, 0.5), "rough": 0.55, "metallic": 0.25},
	}


SCREEN_ON = """[gd_resource type="StandardMaterial3D" format=3]

[ext_resource type="Texture2D" path="%stv_screen.png" id="1"]

[resource]
resource_name = "W6ScreenOn"
albedo_color = Color(0.05, 0.05, 0.05, 1)
roughness = 0.15
emission_enabled = true
emission_energy_multiplier = 1.6
emission_texture = ExtResource("1")
""" % OWN6


def main():
	MATS.mkdir(parents=True, exist_ok=True)
	M4.MATS, M4.MODELS, M4.TEXTURES, M4.RES = MATS, MODELS, TEXTURES, RES
	M4.GLB_IMPORT = M4.GLB_IMPORT.replace("realistic_map/wave4/{glb}", "realistic_map/wave6/{glb}")
	all_looks = looks()
	for name, look in all_looks.items():
		if "shader" in look:
			M4.write_shader_material(name, look["shader"], M4.SHELL_SHADER)
		else:
			M4.write_material(name, look)
	(MATS / "W6ScreenOn.tres").write_text(SCREEN_ON, encoding="utf-8", newline="\n")
	known = set(all_looks) | {"W6ScreenOn"}
	for wave in ("wave1", "wave2", "wave3", "wave4", "wave5"):
		known |= {p.stem for p in (GAME / f"assets/models/graphics_pilot/realistic_map/{wave}/materials").glob("*.tres")}
	for glb in sorted(MODELS.glob("*.glb")):
		M4.write_glb_import(glb, known)
	M4.write_texture_imports()


if __name__ == "__main__":
	main()
