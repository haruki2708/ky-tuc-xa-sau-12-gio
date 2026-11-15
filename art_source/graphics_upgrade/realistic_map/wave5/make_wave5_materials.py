"""T-262 wave 5: the gate's Godot materials (W5*), each glb's .import (W1*..W5* placeholders mapped onto the shared .tres
through use_external, no texture inside a glb) and each new texture's .import written before Godot first sees the PNG:
VRAM compressed (compress/mode=2), normal maps flagged (compress/normal_map=1), mipmaps on (card section 5).

Reused (already in the game, CC0 Poly Haven, sources in art_source/graphics_upgrade/room407_corner/CREDITS.md and
room407_shell): Painted Plaster Wall + Peeling Painted Wall (whitewashed pillars and wall as wave 3's kerbs D-175 K1, the
booth's yellow wash, the sign band), Green Metal Rust (the approved green-painted steel: swing gate, arch, wall bars,
door), Aluminium (stainless folding gate); wave 3's grey "con sâu" pavers (D-175 P1, D-178); wave 1's shared materials.
Run: python -B art_source/graphics_upgrade/realistic_map/wave5/make_wave5_materials.py  (then godot --import twice)
"""
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave4"))
import make_wave4_materials as M4  # noqa: E402  (writers; its main is guarded)

ROOT = HERE.parents[3]
GAME = ROOT / "game"
MODELS = GAME / "assets/models/graphics_pilot/realistic_map/wave5"
MATS = MODELS / "materials"
TEXTURES = GAME / "assets/textures/graphics_pilot/realistic_map/wave5"
RES = dict(M4.RES, W5="res://assets/models/graphics_pilot/realistic_map/wave5/materials/")
CORNER, SHELL, OWN3 = M4.CORNER, M4.SHELL, M4.OWN3
OWN5 = "res://assets/textures/graphics_pilot/realistic_map/wave5/"
PLASTER = M4.PLASTER
PEEL = M4.PEEL
GREEN_RUST = M4.GREEN_RUST
tint_to = M4.tint_to


def wall(mask, tint, **extra):
	look = {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg", "base_arm": PLASTER + "arm.jpg",
		"mask": mask, "peel": True, "base_tint": tint, "grime_strength": 1.2, "stain_strength": 0.75, "mould_strength": 1.0,
		"grime_color": (0.42, 0.38, 0.3)}
	look.update(extra)
	return {"shader": look}


def looks():
	whitewash = (0.98, 1.06, 1.25)       # D-175 K1: the cream scan taken to a cool lime white
	yellow = tint_to(PLASTER + "cream_color.jpg", (0.78, 0.6, 0.27))  # vôi vàng
	return {
		# P1 pillars, W1 wall, the bands of K1 and P2: whitewash over render, grime at the foot, rust and rain runs.
		"W5Plaster": wall(OWN5 + "mask_gate.png", whitewash),
		"W5BoothYellow": wall(OWN5 + "mask_gate.png", yellow, stain_color=(0.62, 0.5, 0.3)),
		"W5PlasterInner": wall(OWN5 + "mask_gate.png", (1.0, 1.0, 0.92), grime_strength=0.6),
		# SB: the plastered sign band, the ghosts of its letters and their bolts' rust in the mask.
		"W5Band": wall(OWN5 + "mask_board_text.png", whitewash, stain_color=(0.55, 0.3, 0.14), stain_strength=1.0),
		"W5BandBlank": wall(OWN5 + "mask_board_blank.png", whitewash, stain_color=(0.55, 0.3, 0.14), stain_strength=1.0),
		"W5LetterRed": {"color": (0.5, 0.07, 0.05), "rough": 0.45, "metallic": 0.35},
		# P2, W2: fired clay brick (tile 0.92 x 0.84 m).
		"W5Brick": {"albedo": OWN5 + "brick_color.png", "orm": OWN5 + "brick_orm.png", "normal": OWN5 + "brick_normal.png",
			"scale_uv": (1 / 0.92, 1 / 0.84)},
		# G1 gate, SA arch, W1 bars: the approved green-painted steel, darker; K1 door a little lighter.
		"W5GateGreen": {**GREEN_RUST, "color": (0.3, 0.42, 0.34)},
		"W5DoorPaint": {**GREEN_RUST, "color": (0.5, 0.6, 0.55)},
		# G2: brushed stainless steel.
		"W5Stainless": {"albedo": SHELL + "aluminium_color.jpg", "orm": SHELL + "aluminium_arm.jpg",
			"color": tint_to(SHELL + "aluminium_color.jpg", (0.66, 0.67, 0.67)), "scale": 2.0, "metallic_value": 0.85},
		# SA board: the blue sheet with its white letters (or none).
		"W5SignText": {"albedo": OWN5 + "sign_text.png", "rough": 0.55, "metallic": 0.15},
		"W5SignBlank": {"albedo": OWN5 + "sign_blank.png", "rough": 0.55, "metallic": 0.15},
		# K2: composite panels on a blue steel frame.
		"W5Panel": {"albedo": OWN5 + "panel_color.png", "normal": OWN5 + "panel_normal.png", "rough": 0.5, "scale": 1.0},
		"W5FrameBlue": {"color": (0.12, 0.26, 0.5), "rough": 0.5, "metallic": 0.35},
		# C2 (D-175 P1, D-178): grey "con sâu" pavers; C1: old asphalt. One mask for both (wheel tracks, grime, puddles).
		"W5CourtPavers": {"shader": {"kind": 1, "base_albedo": OWN3 + "paving_block_color.png", "base_normal": OWN3 + "paving_block_normal.png",
			"base_arm": OWN3 + "paving_block_orm.png", "mask": OWN5 + "mask_court.png", "grime_strength": 1.0, "wear_strength": 0.7,
			"wet_strength": 0.8, "grout_strength": 1.0, "normal_strength": 0.7, "grime_color": (0.45, 0.42, 0.35)}},
		"W5CourtAsphalt": {"shader": {"kind": 1, "base_albedo": OWN5 + "asphalt_color.png", "base_normal": OWN5 + "asphalt_normal.png",
			"base_arm": OWN5 + "asphalt_orm.png", "mask": OWN5 + "mask_court.png", "grime_strength": 0.8, "wear_strength": 0.6,
			"wet_strength": 0.85, "grout_strength": 0.7, "normal_strength": 0.8, "grime_color": (0.5, 0.47, 0.4)}},
		"W5GroundCrack": {"albedo": OWN5 + "ground_crack.png", "rough": 0.9, "alpha_cut": 0.5},
		# Street furniture.
		"W5BarrierStripes": {"albedo": OWN5 + "barrier_stripes.png", "rough": 0.5},
		"W5ConeOrange": {"color": (0.78, 0.26, 0.05), "rough": 0.55},
		"W5Reflect": {"color": (0.8, 0.8, 0.78), "rough": 0.3, "metallic": 0.1},
	}


def write_material(name, look):
	if "shader" in look:
		M4.write_shader_material(name, look["shader"], M4.SHELL_SHADER)
		return
	look = dict(look)
	scale_uv = look.pop("scale_uv", None)
	alpha_cut = look.pop("alpha_cut", None)
	M4.write_material(name, look)
	path = MATS / f"{name}.tres"
	text = path.read_text(encoding="utf-8")
	if scale_uv:
		text = text.replace("[resource]\n", "[resource]\n", 1).rstrip("\n") + "\nuv1_scale = Vector3(%g, %g, 1)\n" % scale_uv
	if alpha_cut is not None:
		text = text.rstrip("\n") + "\ntransparency = 2\nalpha_scissor_threshold = %g\n" % alpha_cut
	path.write_text(text, encoding="utf-8", newline="\n")


def main():
	MATS.mkdir(parents=True, exist_ok=True)
	# The wave-4 writers write into their own folders: point them at wave 5.
	M4.MATS, M4.MODELS, M4.TEXTURES, M4.RES = MATS, MODELS, TEXTURES, RES
	M4.GLB_IMPORT = M4.GLB_IMPORT.replace("realistic_map/wave4/{glb}", "realistic_map/wave5/{glb}")
	all_looks = looks()
	for name, look in all_looks.items():
		write_material(name, look)
	known = set(all_looks)
	for wave in ("wave1", "wave2", "wave3", "wave4"):
		known |= {p.stem for p in (GAME / f"assets/models/graphics_pilot/realistic_map/{wave}/materials").glob("*.tres")}
	for glb in sorted(MODELS.glob("*.glb")):
		M4.write_glb_import(glb, known)
	M4.write_texture_imports()


if __name__ == "__main__":
	main()
