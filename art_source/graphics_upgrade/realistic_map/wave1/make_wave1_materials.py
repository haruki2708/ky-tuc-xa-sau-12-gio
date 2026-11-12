"""T-250 wave 1: the shared Godot materials for the W1* placeholder materials of the wave-1 glbs, and each glb's
.import mapping its materials onto them (use_external), so the glbs carry no texture copies.

Scans are the CC0 Poly Haven sets already in the game (room 407, T-213/T-222: Wood Table Worn, Green Metal Rust,
Painted Plaster Wall, Plastered Wall 04, aluminium); the rest are drawn by make_wave1_textures.py.
Run: python -B art_source/graphics_upgrade/realistic_map/wave1/make_wave1_materials.py  (then let Godot import)
"""
from pathlib import Path
import json
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
MODELS = ROOT / "game/assets/models/graphics_pilot/realistic_map/wave1"
MATS = MODELS / "materials"
RES_MATS = "res://assets/models/graphics_pilot/realistic_map/wave1/materials/"
CORNER = "res://assets/models/graphics_pilot/room407_corner/"
SHELL = "res://assets/textures/graphics_pilot/room407_shell/"
OWN = "res://assets/textures/graphics_pilot/realistic_map/wave1/"
WOOD = {"albedo": CORNER + "study_desk_wood_table_worn_color.jpg", "orm": CORNER + "study_desk_wood_table_worn_arm.jpg",
	"normal": CORNER + "study_desk_wood_table_worn_normal.jpg", "scale": 1 / 0.55}
GREEN_RUST = {"albedo": CORNER + "fixtures_green_metal_rust_color.jpg", "orm": CORNER + "fixtures_green_metal_rust_arm.jpg",
	"normal": CORNER + "fixtures_green_metal_rust_normal.jpg", "scale": 1.0}
PLASTER = CORNER + "architecture_painted_plaster_wall_"

# name: dict(albedo/orm/normal/scale/color/rough/metal/normal_scale/cull)
LOOKS = {
	"W1Wood": {**WOOD, "color": (0.92, 0.86, 0.8)},
	"W1WoodPale": {"color": (0.6, 0.48, 0.34), "rough": 0.78, "normal": WOOD["normal"], "scale": WOOD["scale"], "normal_scale": 0.4},
	"W1Steel": {"color": (0.6, 0.6, 0.58), "rough": 0.38, "metal": 1.0},
	"W1Brass": {"color": (0.74, 0.58, 0.3), "rough": 0.34, "metal": 1.0},
	"W1Black": {"color": (0.03, 0.03, 0.03), "rough": 0.6},
	"W1RedPlastic": {"color": (0.52, 0.05, 0.04), "rough": 0.45},
	"W1Paper": {"color": (0.84, 0.83, 0.78), "rough": 0.9},
	"W1Pencil": {"color": (0.8, 0.58, 0.08), "rough": 0.5},
	"W1Pages": {"albedo": OWN + "ledger_pages.png", "rough": 0.9},
	"W1PageEdge": {"color": (0.8, 0.77, 0.68), "rough": 0.95},
	"W1Ledger": {"albedo": OWN + "ledger_cover.png", "rough": 0.85},
	"W1LedgerSpine": {"color": (0.3, 0.07, 0.06), "rough": 0.8},
	"W1Enamel": {"color": (0.88, 0.88, 0.84), "rough": 0.2},
	"W1EnamelBlue": {"color": (0.08, 0.16, 0.42), "rough": 0.25},
	"W1PenBlue": {"color": (0.1, 0.2, 0.6), "rough": 0.35},
	"W1Plastic": {"color": (0.12, 0.3, 0.42), "rough": 0.5},
	"W1Rubber": {"color": (0.12, 0.1, 0.1), "rough": 0.85},
	"W1PhoneIvory": {"color": (0.72, 0.68, 0.56), "rough": 0.45},
	"W1PhoneKey": {"color": (0.84, 0.83, 0.78), "rough": 0.5},
	"W1Cord": {"color": (0.68, 0.64, 0.53), "rough": 0.6},
	"W1ClockCase": {"color": (0.78, 0.76, 0.68), "rough": 0.4},
	"W1ClockDial": {"albedo": OWN + "clock_dial.png", "rough": 0.6},
	"W1ClockHand": {"color": (0.03, 0.03, 0.035), "rough": 0.4, "metal": 0.3},
	"W1ClockSecond": {"color": (0.6, 0.06, 0.04), "rough": 0.4},
	"W1SpeakerPaint": {"albedo": OWN + "paint_grey_color.png", "orm": OWN + "paint_grey_orm.png",
		"normal": OWN + "paint_grey_normal.png", "scale": 2.0},
	"W1Iron": {"color": (0.17, 0.17, 0.16), "rough": 0.55, "metal": 0.6},
	"W1SpeakerInner": {"color": (0.05, 0.05, 0.05), "rough": 0.85},
	"W1Cork": {"albedo": OWN + "cork_color.png", "orm": OWN + "cork_orm.png", "normal": OWN + "cork_normal.png", "scale": 2.0},
	"W1Alu": {"albedo": SHELL + "aluminium_color.jpg", "orm": SHELL + "aluminium_arm.jpg", "scale": 2.0, "color": (0.92, 0.92, 0.9)},
	"W1Notices": {"albedo": OWN + "notices.png", "rough": 0.85},
	"W1PinRed": {"color": (0.7, 0.08, 0.06), "rough": 0.35},
	"W1PinBlue": {"color": (0.1, 0.25, 0.65), "rough": 0.35},
	# Stairwells (A06, A07). Plaster and terrazzo use room 407's shell shader with this wave's masks on UV2;
	# their UV1 is already in scan repeats (build_stairs.py uv_size).
	"W1StairWall": {"shader": {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg",
		"base_arm": PLASTER + "arm.jpg", "mask": OWN + "mask_stair_wall.png", "peel": True,
		"base_tint": (0.9, 0.88, 0.82), "grime_strength": 1.2, "stain_strength": 0.45}},
	"W1StairDado": {"shader": {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg",
		"base_arm": PLASTER + "arm.jpg", "mask": OWN + "mask_stair_wall.png", "peel": True,
		"base_tint": (0.6, 0.7, 0.68), "grime_strength": 1.3, "stain_strength": 0.35}},
	"W1StairSide": {"shader": {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg",
		"base_arm": PLASTER + "arm.jpg", "mask": OWN + "mask_stair_wall.png", "peel": True,
		"base_tint": (0.6, 0.7, 0.68), "grime_strength": 1.2, "stain_strength": 0.3}},
	"W1Soffit": {"shader": {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg",
		"base_arm": PLASTER + "arm.jpg", "mask": OWN + "mask_stair_wall.png", "peel": True,
		"base_tint": (0.93, 0.92, 0.86), "normal_strength": 0.5, "stain_strength": 0.4}},
	"W1Terrazzo": {"shader": {"kind": 1, "base_albedo": OWN + "terrazzo_color.png", "base_normal": OWN + "terrazzo_normal.png",
		"base_arm": OWN + "terrazzo_orm.png", "mask": OWN + "mask_stair_floor.png", "grime_strength": 0.75,
		"wear_strength": 0.7, "normal_strength": 0.5}},
	"W1Groove": {"color": (0.07, 0.07, 0.07), "rough": 0.8},
	"W1OldWall": {"albedo": "res://assets/textures/campus/wall.png", "rough": 0.9, "nearest": True, "triplanar": 0.5},
	"W1RailWood": {**WOOD, "color": (0.62, 0.5, 0.42)},
	"W1RailSteel": {**GREEN_RUST, "color": (0.85, 0.9, 0.85)},
	"W1Rebar": {"color": (0.27, 0.15, 0.08), "rough": 0.8, "metal": 0.5},
	"W1Concrete": {"albedo": CORNER + "fixtures_plastered_wall_04_small_color.jpg",
		"orm": CORNER + "fixtures_plastered_wall_04_small_arm.jpg", "normal": CORNER + "fixtures_plastered_wall_04_small_normal.jpg",
		"scale": 1 / 0.8, "color": (0.52, 0.51, 0.47)},
	"W1Crack": {"albedo": OWN + "crack.png", "rough": 0.9, "scissor": True},
	# Fire door (A07): the corridor's green paint over steel.
	"W1DoorPaint": {**GREEN_RUST, "color": (0.88, 0.95, 0.9)},
	"W1Granite": {"albedo": SHELL + "granite_color.jpg", "orm": SHELL + "granite_arm.jpg", "scale": 1.0},
	"W1ExitSign": {"color": (0.12, 0.4, 0.18), "rough": 0.35},
}
PLASTER_PREFIX = None
SHELL_SHADER = "res://rendering/room407_shell.gdshader"
PEEL = {"layer_albedo": SHELL + "wall_peel_color.jpg", "layer_normal": SHELL + "peeling_painted_wall_normal.jpg",
	"layer_arm": SHELL + "peeling_painted_wall_arm.jpg", "layer_scale": 2.0 / 1.8}


def write_shader_material(name, params):
	params = dict(params)
	if params.pop("peel", False):
		params.update(PEEL)
	params["noise"] = SHELL + "noise.png"
	ext = [("Shader", SHELL_SHADER)]
	lines = [f'resource_name = "{name}"', 'shader = ExtResource("1")']
	for key, value in params.items():
		if isinstance(value, str):
			ext.append(("Texture2D", value))
			lines.append(f'shader_parameter/{key} = ExtResource("{len(ext)}")')
		elif isinstance(value, tuple):
			lines.append(f"shader_parameter/{key} = Color(%g, %g, %g, 1)" % value)
		elif isinstance(value, int) and not isinstance(value, bool):
			lines.append(f"shader_parameter/{key} = {value}")
		else:
			lines.append(f"shader_parameter/{key} = %g" % value)
	head = '[gd_resource type="ShaderMaterial" format=3]\n\n'
	head += "".join(f'[ext_resource type="{k}" path="{p}" id="{i + 1}"]\n' for i, (k, p) in enumerate(ext))
	(MATS / f"{name}.tres").write_text(head + "\n[resource]\n" + "\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def write_material(name, look):
	if "shader" in look:
		MATS.mkdir(parents=True, exist_ok=True)
		write_shader_material(name, look["shader"])
		return
	ext = []
	lines = [f'resource_name = "{name}"']
	textured = "orm" in look
	kind = "ORMMaterial3D" if textured else "StandardMaterial3D"

	def tex(path):
		ext.append(path)
		return f'ExtResource("{len(ext)}")'

	color = look.get("color", (1.0, 1.0, 1.0))
	lines.append("albedo_color = Color(%g, %g, %g, 1)" % color)
	if "albedo" in look:
		lines.append("albedo_texture = " + tex(look["albedo"]))
	if textured:
		lines.append("orm_texture = " + tex(look["orm"]))
	else:
		lines.append("roughness = %g" % look.get("rough", 0.6))
		if look.get("metal", 0.0) > 0.0:
			lines.append("metallic = %g" % look["metal"])
	if "normal" in look:
		lines.append("normal_enabled = true")
		lines.append("normal_scale = %g" % look.get("normal_scale", 1.0))
		lines.append("normal_texture = " + tex(look["normal"]))
	if "scale" in look:
		s = look["scale"]
		lines.append("uv1_scale = Vector3(%g, %g, %g)" % (s, s, s))
	if look.get("nearest"):
		lines.append("texture_filter = 0")
	if "triplanar" in look:
		s = look["triplanar"]
		lines += ["uv1_triplanar = true", "uv1_world_triplanar = true", "uv1_scale = Vector3(%g, %g, %g)" % (s, s, s)]
	if look.get("scissor"):
		lines += ["transparency = 2", "alpha_scissor_threshold = 0.5"]
	head = f'[gd_resource type="{kind}" format=3]\n\n'
	head += "".join(f'[ext_resource type="Texture2D" path="{p}" id="{i + 1}"]\n' for i, p in enumerate(ext))
	text = head + ("\n" if ext else "") + "[resource]\n" + "\n".join(lines) + "\n"
	MATS.mkdir(parents=True, exist_ok=True)
	(MATS / f"{name}.tres").write_text(text, encoding="utf-8", newline="\n")


IMPORT = """[remap]

importer="scene"
importer_version=1
type="PackedScene"

[deps]

source_file="res://assets/models/graphics_pilot/realistic_map/wave1/{glb}"

[params]

nodes/root_type=""
nodes/root_name=""
nodes/root_script=null
mesh_library/use_node_names_as_mesh_names=false
array_mesh/deduplicate_surfaces=true
nodes/apply_root_scale=true
nodes/root_scale=1.0
nodes/import_as_skeleton_bones=false
nodes/use_name_suffixes=true
nodes/use_node_type_suffixes=true
meshes/ensure_tangents=true
meshes/generate_lods=true
meshes/create_shadow_meshes=true
meshes/light_baking=1
meshes/lightmap_texel_size=0.2
meshes/force_disable_compression=false
skins/use_named_skins=true
animation/import=false
animation/fps=30
animation/trimming=false
animation/remove_immutable_tracks=true
animation/import_rest_as_RESET=false
import_script/path=""
materials/extract=0
materials/extract_format=0
materials/extract_path=""
_subresources={subresources}
gltf/naming_version=2
gltf/embedded_image_handling=1
gltf/texture_map_mode=1
"""


def glb_materials(path):
	"""Material names in a .glb (its JSON chunk)."""
	data = path.read_bytes()
	length = int.from_bytes(data[12:16], "little")
	doc = json.loads(data[20:20 + length].decode("utf-8"))
	return [m["name"] for m in doc.get("materials", []) if m.get("name", "").startswith("W1")]


def write_import(glb):
	names = glb_materials(glb)
	missing = [n for n in names if n not in LOOKS]
	if missing:
		raise SystemExit("%s: no look for %s" % (glb.name, missing))
	entries = ",\n".join('"%s": {\n"use_external/enabled": true,\n"use_external/fallback_path": "%s%s.tres",\n"use_external/path": "%s%s.tres"\n}'
		% (n, RES_MATS, n, RES_MATS, n) for n in names)
	sub = '{\n"materials": {\n' + entries + "\n}\n}"
	target = glb.with_name(glb.name + ".import")
	text = IMPORT.format(glb=glb.name, subresources=sub)
	if target.exists():
		# Keep Godot's uid and imported path; replace only the mapping.
		old = target.read_text(encoding="utf-8")
		old = re.sub(r"_subresources=\{.*?\n\}\n(?=gltf/)", "_subresources=" + sub + "\n", old, flags=re.S) if "_subresources={\n" in old \
			else old.replace("_subresources={}", "_subresources=" + sub)
		text = old
	target.write_text(text, encoding="utf-8", newline="\n")
	print("T250_IMPORT", glb.name, len(names), "materials")


def main():
	for name, look in LOOKS.items():
		write_material(name, look)
	for glb in sorted(MODELS.glob("*.glb")):
		write_import(glb)


if __name__ == "__main__":
	main()
