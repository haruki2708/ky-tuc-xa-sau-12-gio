"""T-264 wave 7: the Godot materials (W7*), each glb's .import (placeholders mapped onto the shared .tres through
use_external, no texture inside a glb) and each new texture's .import written before Godot first sees the PNG: VRAM
compressed (compress/mode=2), normal maps flagged (compress/normal_map=1), mipmaps on (card section 6).

Reused (already in the game; sources in the earlier waves' CREDITS and art_source/graphics_upgrade/room407_corner,
room407_shell): Painted Plaster Wall + Peeling Painted Wall (the walls), Plastered Wall 04 (concrete road slabs), wave 3's
grass, soil and "con sâu" pavers, wave 5's asphalt, the shared W1/W2/W4/W5/W6 materials (concrete, iron, aluminium,
glass, galvanised steel, roof sheet, lamp body, gate green, the canteen's lime yellow).
Run: python -B art_source/graphics_upgrade/realistic_map/wave7/make_wave7_materials.py  (then godot --import twice)
"""
from pathlib import Path
import sys

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "wave4"))
import make_wave4_materials as M4  # noqa: E402  (writers; its main is guarded)

ROOT = HERE.parents[3]
GAME = ROOT / "game"
MODELS = GAME / "assets/models/graphics_pilot/realistic_map/wave7"
MATS = MODELS / "materials"
TEXTURES = GAME / "assets/textures/graphics_pilot/realistic_map/wave7"
RES = dict(M4.RES, W5="res://assets/models/graphics_pilot/realistic_map/wave5/materials/",
	W6="res://assets/models/graphics_pilot/realistic_map/wave6/materials/",
	W7="res://assets/models/graphics_pilot/realistic_map/wave7/materials/")
OWN7 = "res://assets/textures/graphics_pilot/realistic_map/wave7/"
OWN5 = "res://assets/textures/graphics_pilot/realistic_map/wave5/"
CORNER, PLASTER, tint_to = M4.CORNER, M4.PLASTER, M4.tint_to
INTERIOR_SHADER = RES["W7"] + "interior.gdshader"
FACADES = OWN7 + "mask_facades7.png"
ROAD = OWN7 + "mask_road7.png"


def paint(tint, mask=FACADES, **extra):
	look = {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg", "base_arm": PLASTER + "arm.jpg",
		"mask": mask, "peel": True, "base_tint": tint, "grime_strength": 1.2, "stain_strength": 0.9, "mould_strength": 1.0,
		"normal_strength": 0.6, "grime_color": (0.42, 0.38, 0.3)}
	look.update(extra)
	return {"shader": look}


def looks():
	lime_yellow = tint_to(PLASTER + "cream_color.jpg", (0.78, 0.6, 0.27))     # as the canteen's walls (D-181)
	pale_yellow = tint_to(PLASTER + "cream_color.jpg", (0.84, 0.74, 0.5))
	cream_grey = tint_to(PLASTER + "cream_color.jpg", (0.7, 0.68, 0.6))
	return {
		# Walls: W1 lime yellow as the canteen, or a cream-grey that reads apart from building B; white trims.
		"W7WallYellow": paint(lime_yellow),
		"W7WallPale": paint(pale_yellow),
		"W7WallGrey": paint(cream_grey),
		"W7Trim": paint((0.98, 1.06, 1.25)),
		"W7Concrete": {"shader": {"kind": 0, "base_albedo": CORNER + "fixtures_plastered_wall_04_small_color.jpg",
			"base_normal": CORNER + "fixtures_plastered_wall_04_small_normal.jpg", "base_arm": CORNER + "fixtures_plastered_wall_04_small_arm.jpg",
			"base_tint": tint_to(CORNER + "fixtures_plastered_wall_04_small_color.jpg", (0.52, 0.51, 0.48)), "mask": FACADES,
			"peel_strength": 0.0, "grime_strength": 1.2, "stain_strength": 1.0, "mould_strength": 1.0, "normal_strength": 0.8,
			"grime_color": (0.4, 0.37, 0.31), "stain_color": (0.5, 0.45, 0.36)}},
		# Glass: dark tinted panes on the upper floors (curtains behind), the fake rooms, flat colours.
		"W7GlassDark": {"color": (0.03, 0.035, 0.04), "rough": 0.08, "metallic": 0.4},
		"W7Palette": {"albedo": OWN7 + "palette7.png", "rough": 0.6, "nearest": True},
		# Ground: the Avenue's old asphalt with patches (wave 5's scan) or concrete slabs (wave 1's plaster scan), the
		# kerbs' whitewash, the verges' worn grass (wave 3) or block paving, worn white lines.
		"W7Asphalt": {"shader": {"kind": 1, "base_albedo": OWN5 + "asphalt_color.png", "base_normal": OWN5 + "asphalt_normal.png",
			"base_arm": OWN5 + "asphalt_orm.png", "mask": ROAD, "grime_strength": 0.9, "wear_strength": 0.6, "wet_strength": 0.85,
			"grout_strength": 0.8, "normal_strength": 0.8, "grime_color": (0.3, 0.29, 0.27)}},
		"W7RoadSlab": {"shader": {"kind": 1, "base_albedo": CORNER + "fixtures_plastered_wall_04_small_color.jpg",
			"base_normal": CORNER + "fixtures_plastered_wall_04_small_normal.jpg", "base_arm": CORNER + "fixtures_plastered_wall_04_small_arm.jpg",
			"base_tint": tint_to(CORNER + "fixtures_plastered_wall_04_small_color.jpg", (0.5, 0.49, 0.46)), "mask": ROAD,
			"grout_strength": 0.5, "grime_strength": 1.1, "wet_strength": 0.9, "wear_strength": 0.5, "normal_strength": 0.7,
			"grime_color": (0.38, 0.35, 0.3)}},
		"W7Kerb": paint((0.98, 1.06, 1.25), mask=ROAD, grime_strength=1.4, stain_strength=0.6),
		"W7Verge": {"ground": {"grass_albedo": M4.OWN3 + "ground_grass_color.png", "grass_normal": M4.OWN3 + "ground_grass_normal.png",
			"dirt_albedo": M4.OWN3 + "soil_color.png", "dirt_normal": M4.OWN3 + "soil_normal.png", "mask": OWN7 + "mask_verge7.png",
			"dirt_tint": (1.5, 1.4, 1.3), "grass_scale": 0.5, "dirt_scale": 1.25}},
		"W7Pavers": {"shader": {"kind": 1, "base_albedo": M4.OWN3 + "paving_block_color.png", "base_normal": M4.OWN3 + "paving_block_normal.png",
			"base_arm": M4.OWN3 + "paving_block_orm.png", "mask": ROAD, "grime_strength": 1.0, "wear_strength": 0.6, "wet_strength": 0.8,
			"grout_strength": 1.0, "normal_strength": 0.7, "grime_color": (0.45, 0.42, 0.35)}},
		"W7Paint": {"albedo": OWN7 + "paint_line.png", "rough": 0.7, "alpha_cut": 0.5},
		# Street light glass: a faint glow as the PS1 heads had (no light is added; Props/Lights stay as they are).
		"W7LampGlass": {"color": (0.7, 0.68, 0.6), "rough": 0.2, "emission": (1.0, 0.94, 0.78), "energy": 0.6},
		# Trees: the foliage shader of wave 3 (alpha scissor, no shadow from the cards is set per mesh).
		"W7LeafBang": {"foliage": {"albedo_tex": OWN7 + "leaf_bang.png", "tint": (0.82, 0.82, 0.82), "roughness_value": 0.85,
			"specular_value": 0.05, "translucency": 0.2}},
		"W7LeafPhuong": {"foliage": {"albedo_tex": OWN7 + "leaf_phuong.png", "tint": (0.82, 0.82, 0.82), "roughness_value": 0.85,
			"specular_value": 0.04, "translucency": 0.25}},
		"W7LeafXacu": {"foliage": {"albedo_tex": OWN7 + "leaf_xacu.png", "tint": (0.8, 0.8, 0.8), "roughness_value": 0.8,
			"specular_value": 0.06, "translucency": 0.15}},
	}


BARK = """[gd_resource type="StandardMaterial3D" format=3]

[ext_resource type="Texture2D" path="{own}bark_{name}_color.png" id="1"]
[ext_resource type="Texture2D" path="{own}bark_{name}_normal.png" id="2"]

[resource]
resource_name = "{res}"
albedo_color = Color(0.74, 0.72, 0.7, 1)
albedo_texture = ExtResource("1")
roughness = 0.75
normal_enabled = true
normal_scale = 0.7
normal_texture = ExtResource("2")
uv1_scale = Vector3(2.5, 2.5, 2.5)
"""

INTERIORS = {"W7RoomDorm": (0.0, 3.2, 0.85), "W7RoomClass": (1.0, 6.0, 0.85), "W7RoomGym": (2.0, 12.0, 0.8), "W7RoomLobby": (3.0, 6.0, 0.9)}


# Round 1's options the owner did not pick (D-182): not written (pass --options for build_wave7_pilot.py's option glbs).
ROUND1_OPTIONS = {"W7WallGrey", "W7RoadSlab"}


def write_material(name, look):
	if any(k in look for k in ("shader", "foliage", "ground")):
		M4.write_material(name, look)
		return
	look = dict(look)
	alpha_cut = look.pop("alpha_cut", None)
	M4.write_material(name, look)
	if alpha_cut is not None:
		path = MATS / f"{name}.tres"
		text = path.read_text(encoding="utf-8").rstrip("\n") + "\ntransparency = 2\nalpha_scissor_threshold = %g\n" % alpha_cut
		path.write_text(text, encoding="utf-8", newline="\n")


def main():
	MATS.mkdir(parents=True, exist_ok=True)
	M4.MATS, M4.MODELS, M4.TEXTURES, M4.RES = MATS, MODELS, TEXTURES, RES
	M4.GLB_IMPORT = M4.GLB_IMPORT.replace("realistic_map/wave4/{glb}", "realistic_map/wave7/{glb}")
	all_looks = {k: v for k, v in looks().items() if k not in ROUND1_OPTIONS or "--options" in sys.argv}
	for name, look in all_looks.items():
		write_material(name, look)
	for species, res in (("bang", "W7BarkBang"), ("phuong", "W7BarkPhuong"), ("xacu", "W7BarkXacu")):
		(MATS / f"{res}.tres").write_text(BARK.format(own=OWN7, name=species, res=res), encoding="utf-8", newline="\n")
	for name, (row, depth, dim) in INTERIORS.items():
		M4.write_shader_material(name, {"atlas": OWN7 + "interior_atlas.png", "row": row, "depth": depth, "dim": dim}, INTERIOR_SHADER)
	known = set(all_looks) | set(INTERIORS) | {"W7BarkBang", "W7BarkPhuong", "W7BarkXacu"}
	for wave in ("wave1", "wave2", "wave3", "wave4", "wave5", "wave6"):
		known |= {p.stem for p in (GAME / f"assets/models/graphics_pilot/realistic_map/{wave}/materials").glob("*.tres")}
	for glb in sorted(MODELS.glob("*.glb")):
		M4.write_glb_import(glb, known)
	M4.write_texture_imports()


if __name__ == "__main__":
	main()
