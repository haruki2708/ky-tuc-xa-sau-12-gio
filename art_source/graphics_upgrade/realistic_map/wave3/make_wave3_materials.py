"""T-259 wave 3: the garden's Godot materials (W3*), the foliage shader, each glb's .import (W1*/W3* placeholders mapped
onto the shared .tres through use_external, no texture inside a glb) and each new texture's .import written before
Godot first sees the PNG: VRAM compressed (compress/mode=2), normal maps flagged, mipmaps on (card section 5, T-257).

Scans already in the game (CC0 Poly Haven): Painted Plaster Wall (kerbs), Green Metal Rust (lamp post), Plastered
Wall 04 (lamp footing, wave 1's W1Concrete); wave 1's own terrazzo (bench). The rest is make_wave3_textures.py.
Run: python -B art_source/graphics_upgrade/realistic_map/wave3/make_wave3_materials.py  (then godot --import twice)
"""
from pathlib import Path
import json
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
MODELS = ROOT / "game/assets/models/graphics_pilot/realistic_map/wave3"
MATS = MODELS / "materials"
TEXTURES = ROOT / "game/assets/textures/graphics_pilot/realistic_map/wave3"
RES_W1 = "res://assets/models/graphics_pilot/realistic_map/wave1/materials/"
RES_W3 = "res://assets/models/graphics_pilot/realistic_map/wave3/materials/"
CORNER = "res://assets/models/graphics_pilot/room407_corner/"
SHELL = "res://assets/textures/graphics_pilot/room407_shell/"
OWN1 = "res://assets/textures/graphics_pilot/realistic_map/wave1/"
OWN3 = "res://assets/textures/graphics_pilot/realistic_map/wave3/"
PLASTER = CORNER + "architecture_painted_plaster_wall_"
SHELL_SHADER = "res://rendering/room407_shell.gdshader"
FOLIAGE_SHADER = RES_W3 + "foliage.gdshader"
PEEL = {"layer_albedo": SHELL + "wall_peel_color.jpg", "layer_normal": SHELL + "peeling_painted_wall_normal.jpg",
	"layer_arm": SHELL + "peeling_painted_wall_arm.jpg", "layer_scale": 2.0 / 1.8}
GREEN_RUST = {"albedo": CORNER + "fixtures_green_metal_rust_color.jpg", "orm": CORNER + "fixtures_green_metal_rust_arm.jpg",
	"normal": CORNER + "fixtures_green_metal_rust_normal.jpg", "scale": 1.0}
KERB = {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg",
	"base_arm": PLASTER + "arm.jpg", "mask": OWN3 + "mask_kerb.png", "peel": True, "grime_strength": 1.3,
	"stain_strength": 0.6, "mould_strength": 1.0, "grime_color": (0.42, 0.38, 0.3)}
PAVING = {"kind": 1, "mask": OWN3 + "mask_paving.png", "grime_strength": 0.9, "wear_strength": 0.6,
	"wet_strength": 0.8, "grout_strength": 1.0, "normal_strength": 0.7, "grime_color": (0.5, 0.46, 0.36)}

LOOKS = {
	# Trees: bark (UV in metres, 0.4 m per repeat), foliage cards (alpha scissor, both sides, no shadow casting:
	# the MeshInstance3D named Leaves* has cast_shadow off where it is placed).
	"W3BarkPlumeria": {"albedo": OWN3 + "bark_plumeria_color.png", "normal": OWN3 + "bark_plumeria_normal.png",
		"rough": 0.72, "scale": 2.5, "normal_scale": 0.8, "color": (0.68, 0.68, 0.66)},
	"W3BarkMantaly": {"albedo": OWN3 + "bark_mantaly_color.png", "normal": OWN3 + "bark_mantaly_normal.png",
		"rough": 0.85, "scale": 2.5, "normal_scale": 1.0, "color": (0.75, 0.73, 0.7)},
	"W3BarkLager": {"albedo": OWN3 + "bark_lagerstroemia_color.png", "normal": OWN3 + "bark_lagerstroemia_normal.png",
		"rough": 0.62, "scale": 2.5, "normal_scale": 0.6, "color": (0.72, 0.7, 0.68)},
	"W3LeafPlumeria": {"foliage": {"albedo_tex": OWN3 + "leaf_plumeria.png", "tint": (0.85, 0.85, 0.85),
		"roughness_value": 0.85, "specular_value": 0.04, "translucency": 0.2}},
	"W3LeafMantaly": {"foliage": {"albedo_tex": OWN3 + "leaf_mantaly.png", "tint": (0.8, 0.82, 0.8), "roughness_value": 0.85, "specular_value": 0.04, "translucency": 0.2}},
	"W3LeafLager": {"foliage": {"albedo_tex": OWN3 + "leaf_lagerstroemia.png", "tint": (0.82, 0.82, 0.82),
		"roughness_value": 0.85, "specular_value": 0.04, "translucency": 0.2}},
	"W3Shrubs": {"foliage": {"albedo_tex": OWN3 + "shrubs.png", "tint": (0.78, 0.78, 0.78), "roughness_value": 0.85, "specular_value": 0.04, "translucency": 0.2}},
	"W3ShrubCore": {"color": (0.035, 0.07, 0.025), "rough": 0.95},
	"W3Hedge": {"albedo": OWN3 + "hedge_color.png", "normal": OWN3 + "hedge_normal.png", "rough": 0.85, "normal_scale": 1.0,
		"color": (0.42, 0.48, 0.34)},
	# Beds: painted plaster kerbs (two paint colours to choose from), soil.
	"W3Kerb": {"shader": {**KERB, "base_tint": (0.76, 0.68, 0.5)}},
	"W3KerbWhite": {"shader": {**KERB, "base_tint": (0.78, 0.78, 0.75)}},
	"W3Soil": {"albedo": OWN3 + "soil_color.png", "normal": OWN3 + "soil_normal.png", "rough": 0.95},
	# Paving options (UV1 in tile repeats, UV2 over the whole 44 x 40 m).
	"W3PavingBlock": {"shader": {**PAVING, "base_albedo": OWN3 + "paving_block_color.png",
		"base_normal": OWN3 + "paving_block_normal.png", "base_arm": OWN3 + "paving_block_orm.png"}},
	"W3PavingRed": {"shader": {**PAVING, "base_albedo": OWN3 + "paving_red_color.png",
		"base_normal": OWN3 + "paving_red_normal.png", "base_arm": OWN3 + "paving_red_orm.png"}},
	# Ngư's bench: wave 1's terrazzo, weathered outdoors.
	"W3Bench": {"shader": {"kind": 1, "base_albedo": OWN1 + "terrazzo_color.png", "base_normal": OWN1 + "terrazzo_normal.png",
		"base_arm": OWN1 + "terrazzo_orm.png", "mask": OWN3 + "mask_bench.png", "base_tint": (0.6, 0.6, 0.58),
		"grime_strength": 1.4, "wear_strength": 0.5, "normal_strength": 0.5, "grime_color": (0.48, 0.45, 0.36)}},
	# Garden lamp: dark green paint over steel, opal globe (its glow follows the Flicker light at run time).
	"W3LampPaint": {**GREEN_RUST, "color": (0.42, 0.55, 0.47)},
	"W3LampGlobe": {"color": (0.8, 0.8, 0.74), "rough": 0.25, "emission": (0.78, 0.78, 0.55), "energy": 1.1},
}

FOLIAGE = """shader_type spatial;
// T-259: leaf, flower and grass cards. Alpha scissor (no blending), both sides lit with the crown's soft normals.
render_mode cull_disabled, depth_draw_opaque;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform vec3 tint : source_color = vec3(1.0);
uniform float alpha_cut : hint_range(0.0, 1.0) = 0.42;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.6;
uniform float specular_value : hint_range(0.0, 1.0) = 0.35;
uniform float translucency : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	vec4 texel = texture(albedo_tex, UV);
	ALBEDO = texel.rgb * tint;
	ALPHA = texel.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_cut;
	ROUGHNESS = roughness_value;
	SPECULAR = specular_value;
	BACKLIGHT = texel.rgb * tint * translucency;
	// Godot turns the normal round on the back of a two-sided card; foliage keeps the crown's normal on both sides.
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
}
"""


def fmt(value):
	if isinstance(value, tuple):
		return "Color(%g, %g, %g, 1)" % value
	if isinstance(value, int) and not isinstance(value, bool):
		return str(value)
	return "%g" % value


def write_shader_material(name, params, shader_path):
	params = dict(params)
	if params.pop("peel", False):
		params.update(PEEL)
	if shader_path == SHELL_SHADER:
		params["noise"] = SHELL + "noise.png"
	ext = [("Shader", shader_path)]
	lines = [f'resource_name = "{name}"', 'shader = ExtResource("1")']
	for key, value in params.items():
		if isinstance(value, str):
			ext.append(("Texture2D", value))
			lines.append(f'shader_parameter/{key} = ExtResource("{len(ext)}")')
		else:
			lines.append(f"shader_parameter/{key} = {fmt(value)}")
	head = '[gd_resource type="ShaderMaterial" format=3]\n\n'
	head += "".join(f'[ext_resource type="{k}" path="{p}" id="{i + 1}"]\n' for i, (k, p) in enumerate(ext))
	(MATS / f"{name}.tres").write_text(head + "\n[resource]\n" + "\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def write_material(name, look):
	MATS.mkdir(parents=True, exist_ok=True)
	if "shader" in look:
		write_shader_material(name, look["shader"], SHELL_SHADER)
		return
	if "foliage" in look:
		write_shader_material(name, look["foliage"], FOLIAGE_SHADER)
		return
	ext = []
	lines = [f'resource_name = "{name}"']
	textured = "orm" in look
	kind = "ORMMaterial3D" if textured else "StandardMaterial3D"

	def tex(path):
		ext.append(path)
		return f'ExtResource("{len(ext)}")'

	lines.append("albedo_color = Color(%g, %g, %g, 1)" % look.get("color", (1.0, 1.0, 1.0)))
	if "albedo" in look:
		lines.append("albedo_texture = " + tex(look["albedo"]))
	if textured:
		lines.append("orm_texture = " + tex(look["orm"]))
	else:
		lines.append("roughness = %g" % look.get("rough", 0.6))
	if "normal" in look:
		lines += ["normal_enabled = true", "normal_scale = %g" % look.get("normal_scale", 1.0), "normal_texture = " + tex(look["normal"])]
	if "emission" in look:
		lines += ["emission_enabled = true", "emission = Color(%g, %g, %g, 1)" % look["emission"],
			"emission_energy_multiplier = %g" % look.get("energy", 1.0)]
	if "scale" in look:
		s = look["scale"]
		lines.append("uv1_scale = Vector3(%g, %g, %g)" % (s, s, s))
	head = f'[gd_resource type="{kind}" format=3]\n\n'
	head += "".join(f'[ext_resource type="Texture2D" path="{p}" id="{i + 1}"]\n' for i, p in enumerate(ext))
	text = head + ("\n" if ext else "") + "[resource]\n" + "\n".join(lines) + "\n"
	(MATS / f"{name}.tres").write_text(text, encoding="utf-8", newline="\n")


GLB_IMPORT = """[remap]

importer="scene"
importer_version=1
type="PackedScene"

[deps]

source_file="res://assets/models/graphics_pilot/realistic_map/wave3/{glb}"

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
meshes/generate_lods={lods}
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

TEXTURE_PARAMS = """[params]

compress/mode=2
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map={normal}
compress/channel_pack=0
mipmaps/generate=true
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=1
"""


def glb_materials(path):
	data = path.read_bytes()
	length = int.from_bytes(data[12:16], "little")
	doc = json.loads(data[20:20 + length].decode("utf-8"))
	return [m["name"] for m in doc.get("materials", []) if m.get("name", "")[:2] in ("W1", "W3")]


def write_glb_import(glb, known):
	names = glb_materials(glb)
	missing = [n for n in names if n not in known]
	if missing:
		raise SystemExit("%s: no material for %s" % (glb.name, missing))
	entries = []
	for n in names:
		path = (RES_W1 if n.startswith("W1") else RES_W3) + n + ".tres"
		entries.append('"%s": {\n"use_external/enabled": true,\n"use_external/fallback_path": "%s",\n"use_external/path": "%s"\n}' % (n, path, path))
	sub = '{\n"materials": {\n' + ",\n".join(entries) + "\n}\n}"
	target = glb.with_name(glb.name + ".import")
	# Leaf cards must not be decimated by automatic LODs; trees carry their own far versions.
	lods = "false"
	text = GLB_IMPORT.format(glb=glb.name, subresources=sub, lods=lods)
	if target.exists():
		old = target.read_text(encoding="utf-8")
		old = re.sub(r"_subresources=\{.*?\n\}\n(?=gltf/)", "_subresources=" + sub + "\n", old, flags=re.S) if "_subresources={\n" in old \
			else old.replace("_subresources={}", "_subresources=" + sub)
		text = old
	target.write_text(text, encoding="utf-8", newline="\n")
	print("T259_IMPORT", glb.name, len(names), "materials")


def write_texture_imports():
	for png in sorted(TEXTURES.glob("*.png")):
		target = png.with_name(png.name + ".import")
		normal = "1" if png.stem.endswith("_normal") else "0"
		params = TEXTURE_PARAMS.format(normal=normal)
		if target.exists():
			old = target.read_text(encoding="utf-8")
			text = old[:old.index("[params]")] + params
		else:
			text = '[remap]\n\nimporter="texture"\ntype="CompressedTexture2D"\n\n' + params
		target.write_text(text, encoding="utf-8", newline="\n")


def main():
	MATS.mkdir(parents=True, exist_ok=True)
	(MATS / "foliage.gdshader").write_text(FOLIAGE, encoding="utf-8", newline="\n")
	for name, look in LOOKS.items():
		write_material(name, look)
	known = {p.stem for p in (ROOT / "game/assets/models/graphics_pilot/realistic_map/wave1/materials").glob("*.tres")} | set(LOOKS)
	for glb in sorted(MODELS.glob("*.glb")):
		write_glb_import(glb, known)
	write_texture_imports()


if __name__ == "__main__":
	main()
