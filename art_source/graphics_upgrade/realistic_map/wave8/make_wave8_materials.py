"""T-265 wave 8: the library's Godot materials (W8*), each glb's .import (placeholders mapped onto the shared .tres through
use_external, no texture inside a glb) and each new texture's .import written before Godot first sees the PNG: VRAM
compressed (compress/mode=2), normal maps flagged (compress/normal_map=1), mipmaps on (card section 6).

Reused (already in the game; sources in the earlier waves' CREDITS): the approved plaster paint (D-175/D-180/D-181), wave
6's cream ceramic tile and ceiling panels, wave 1's terrazzo and grey paint, wave 1's concrete scan, the worn desk wood,
wave 7's ground (verge, pavers, kerbs over the whole campus: the ring round the library joins wave 7's edges) and its
fake rooms; shared materials of waves 1, 2, 6 and 7 (W1Wood, W1Iron, W1Alu, W1Brass, W2Glass, W2Tube, W6Plenum,
W6FanPaint, W6ScreenOff, W7GlassDark, W7RoomClass, W7Verge, W7Pavers, W7Kerb...).
Run: python -B art_source/graphics_upgrade/realistic_map/wave8/make_wave8_materials.py  (then godot --import twice)
"""
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave4"))
import make_wave4_materials as M4  # noqa: E402  (writers; its main is guarded)

ROOT = HERE.parents[3]
GAME = ROOT / "game"
MODELS = GAME / "assets/models/graphics_pilot/realistic_map/wave8"
MATS = MODELS / "materials"
TEXTURES = GAME / "assets/textures/graphics_pilot/realistic_map/wave8"
RES = dict(M4.RES, W5="res://assets/models/graphics_pilot/realistic_map/wave5/materials/",
	W6="res://assets/models/graphics_pilot/realistic_map/wave6/materials/",
	W7="res://assets/models/graphics_pilot/realistic_map/wave7/materials/",
	W8="res://assets/models/graphics_pilot/realistic_map/wave8/materials/")
CORNER, SHELL, OWN1, OWN3 = M4.CORNER, M4.SHELL, M4.OWN1, M4.OWN3
OWN6 = "res://assets/textures/graphics_pilot/realistic_map/wave6/"
OWN7 = "res://assets/textures/graphics_pilot/realistic_map/wave7/"
OWN8 = "res://assets/textures/graphics_pilot/realistic_map/wave8/"
PLASTER = M4.PLASTER
CONCRETE = CORNER + "fixtures_plastered_wall_04_small_"
tint_to = M4.tint_to


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
	walls = OWN8 + "mask_walls8.png"
	floor = OWN8 + "mask_floor8.png"
	ceiling = OWN8 + "mask_ceiling8.png"
	pale_yellow = tint_to(PLASTER + "cream_color.jpg", (0.86, 0.79, 0.55))
	ivory = tint_to(PLASTER + "cream_color.jpg", (0.86, 0.84, 0.75))
	dado_green = tint_to(PLASTER + "cream_color.jpg", (0.24, 0.38, 0.32))
	lime_yellow = tint_to(PLASTER + "cream_color.jpg", (0.78, 0.6, 0.27))
	return {
		# F1: cream ceramic 40 x 40 and pale yellow paint as the canteen (D-181), a ceramic skirting; F2: terrazzo, ivory
		# limewash over a green oil-paint dado 1.2 m; F3 (the top floor's store): bare cement floor.
		"W8FloorCeramic": tiles(OWN6 + "ceramic_", floor, (1.0, 1.0, 1.0), grime_color=(0.42, 0.36, 0.27), wet_strength=0.9),
		"W8FloorTerrazzo": tiles(OWN1 + "terrazzo_", floor, (1.02, 1.0, 0.95), grime_color=(0.42, 0.36, 0.27), grout_strength=0.4,
			normal_strength=0.5),
		"W8FloorCement": tiles(CONCRETE, floor, tint_to(CONCRETE + "color.jpg", (0.47, 0.46, 0.43)), ext="jpg", arm="arm",
			grout_strength=0.0, grime_strength=1.2, wear_strength=0.9, grime_color=(0.4, 0.37, 0.31), normal_strength=0.6),
		"W8WallYellow": paint(walls, pale_yellow),
		"W8WallIvory": paint(walls, ivory, grime_strength=1.1),
		"W8DadoGreen": paint(walls, dado_green, grime_strength=0.8, normal_strength=0.4),
		"W8Skirting": tiles(OWN6 + "ceramic_", walls, (0.95, 0.93, 0.88), grout_strength=0.3, wet_strength=0.0, wear_strength=0.0),
		# C2: the canteen's stained panels under this building's own stains; C1: the bare slab, whitewashed grey, with beams.
		"W8CeilingPanel": {"shader": {"kind": 0, "base_albedo": OWN6 + "ceiling_panel_color.png", "base_normal": OWN6 + "ceiling_panel_normal.png",
			"base_arm": OWN6 + "ceiling_panel_orm.png", "mask": ceiling, "peel_strength": 0.0, "grime_strength": 1.0,
			"stain_strength": 1.2, "mould_strength": 0.8, "normal_strength": 0.6, "grime_color": (0.5, 0.45, 0.36),
			"stain_color": (0.74, 0.58, 0.32)}},
		"W8CeilingConcrete": paint(ceiling, tint_to(PLASTER + "cream_color.jpg", (0.72, 0.71, 0.66)), peel_strength=0.6, stain_strength=1.1,
			stain_color=(0.62, 0.5, 0.3)),
		"W8TubeDead": {"color": (0.62, 0.63, 0.6), "rough": 0.35},
		# Shelves: steel baked enamel (grey-green as school library racks) or the old stained wood of the store.
		"W8ShelfSteel": {"albedo": OWN1 + "paint_grey_color.png", "normal": OWN1 + "paint_grey_normal.png", "orm": OWN1 + "paint_grey_orm.png",
			"color": tint_to(OWN1 + "paint_grey_color.png", (0.46, 0.5, 0.48)), "scale": 2.0, "metallic_value": 0.2},
		"W8ShelfWood": {"albedo": CORNER + "study_desk_wood_table_worn_color.jpg", "orm": CORNER + "study_desk_wood_table_worn_arm.jpg",
			"normal": CORNER + "study_desk_wood_table_worn_normal.jpg", "color": (0.62, 0.5, 0.4), "scale": 1.81818},
		"W8Books": {"albedo": OWN8 + "books.png", "rough": 0.82},
		# The map: printed under glass in an aluminium frame, or drawn by hand on squared paper.
		"W8MapPrint": {"albedo": OWN8 + "map_print.png", "rough": 0.5},
		"W8MapDrawn": {"albedo": OWN8 + "map_drawn.png", "rough": 0.9},
		"W8Palette": {"albedo": OWN8 + "palette8.png", "rough": 0.6, "nearest": True},
		# Facades: E1 the approved lime yellow with whitewashed bands and bare concrete fins; E2 washed pebble render with the
		# enamel sign. Their masks: mask_walls8.png row 3.
		"W8FacadeYellow": paint(walls, lime_yellow, grime_strength=1.2, stain_strength=0.9, mould_strength=1.0,
			stain_color=(0.62, 0.5, 0.3), grime_color=(0.42, 0.38, 0.3)),
		"W8FacadeWhite": paint(walls, (0.98, 1.06, 1.25), grime_strength=1.2, stain_strength=0.8, mould_strength=1.0,
			grime_color=(0.42, 0.38, 0.3)),
		"W8Concrete": {"shader": {"kind": 0, "base_albedo": CONCRETE + "color.jpg", "base_normal": CONCRETE + "normal.jpg",
			"base_arm": CONCRETE + "arm.jpg", "base_tint": tint_to(CONCRETE + "color.jpg", (0.52, 0.51, 0.48)), "mask": walls,
			"peel_strength": 0.0, "grime_strength": 1.2, "stain_strength": 1.0, "mould_strength": 1.0, "normal_strength": 0.8,
			"grime_color": (0.4, 0.37, 0.31), "stain_color": (0.5, 0.45, 0.36)}},
		"W8WashedStone": {"shader": {"kind": 0, "base_albedo": OWN8 + "washed_stone_color.png", "base_normal": OWN8 + "washed_stone_normal.png",
			"base_arm": OWN8 + "washed_stone_orm.png", "mask": walls, "peel_strength": 0.0, "grime_strength": 1.1, "stain_strength": 1.0,
			"mould_strength": 1.0, "normal_strength": 0.9, "grime_color": (0.38, 0.36, 0.31), "stain_color": (0.45, 0.42, 0.36)}},
		"W8Sign": {"albedo": OWN8 + "sign_library.png", "rough": 0.55, "metallic": 0.2},
		# Ground ring: cast concrete aprons on wave 7's road mask (whole campus UV2, so the edges join).
		"W8Apron": {"shader": {"kind": 1, "base_albedo": CONCRETE + "color.jpg", "base_normal": CONCRETE + "normal.jpg",
			"base_arm": CONCRETE + "arm.jpg", "base_tint": tint_to(CONCRETE + "color.jpg", (0.5, 0.49, 0.46)), "mask": OWN7 + "mask_road7.png",
			"grout_strength": 0.0, "grime_strength": 1.1, "wet_strength": 0.9, "wear_strength": 0.5, "normal_strength": 0.7,
			"grime_color": (0.4, 0.37, 0.31)}},
	}


def main():
	MATS.mkdir(parents=True, exist_ok=True)
	M4.MATS, M4.MODELS, M4.TEXTURES, M4.RES = MATS, MODELS, TEXTURES, RES
	M4.GLB_IMPORT = M4.GLB_IMPORT.replace("realistic_map/wave4/{glb}", "realistic_map/wave8/{glb}")
	all_looks = looks()
	for name, look in all_looks.items():
		if "shader" in look:
			M4.write_shader_material(name, look["shader"], M4.SHELL_SHADER)
		else:
			M4.write_material(name, look)
	known = set(all_looks)
	for wave in ("wave1", "wave2", "wave3", "wave4", "wave5", "wave6", "wave7"):
		known |= {p.stem for p in (GAME / f"assets/models/graphics_pilot/realistic_map/{wave}/materials").glob("*.tres")}
	for glb in sorted(MODELS.glob("*.glb")):
		M4.write_glb_import(glb, known)
	M4.write_texture_imports()


if __name__ == "__main__":
	main()
