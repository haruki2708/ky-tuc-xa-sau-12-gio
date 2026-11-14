"""T-261 wave 4: the stadium's Godot materials (W4*), the track and pitch shaders, each glb's .import (W1*/W3*/W4*
placeholders mapped onto the shared .tres through use_external, no texture inside a glb) and each new texture's .import
written before Godot first sees the PNG: VRAM compressed (compress/mode=2), normal maps flagged (compress/normal_map=1),
mipmaps on (card section 5).

Reused (already in the game, CC0 Poly Haven, sources in art_source/graphics_upgrade/room407_corner/CREDITS.md and
room407_shell): Plastered Wall 04 (stand concrete, W1Concrete), Painted Plaster Wall + Peeling Painted Wall (gate pillars,
as wave 3's whitewashed kerbs), Green Metal Rust (roof steel, bar fence: the approved green-painted steel), Aluminium
(galvanised poles and pipe fence); wave 1's grey door paint (white paint); wave 3's lawn and soil (living grass, apron).
Run: python -B art_source/graphics_upgrade/realistic_map/wave4/make_wave4_materials.py  (then godot --import twice)
"""
from pathlib import Path
import json
import re
import sys

import numpy as np
from PIL import Image

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
GAME = ROOT / "game"
MODELS = GAME / "assets/models/graphics_pilot/realistic_map/wave4"
MATS = MODELS / "materials"
TEXTURES = GAME / "assets/textures/graphics_pilot/realistic_map/wave4"
RES = {"W1": "res://assets/models/graphics_pilot/realistic_map/wave1/materials/",
	"W2": "res://assets/models/graphics_pilot/realistic_map/wave2/materials/",
	"W3": "res://assets/models/graphics_pilot/realistic_map/wave3/materials/",
	"W4": "res://assets/models/graphics_pilot/realistic_map/wave4/materials/"}
CORNER = "res://assets/models/graphics_pilot/room407_corner/"
SHELL = "res://assets/textures/graphics_pilot/room407_shell/"
OWN1 = "res://assets/textures/graphics_pilot/realistic_map/wave1/"
OWN3 = "res://assets/textures/graphics_pilot/realistic_map/wave3/"
OWN4 = "res://assets/textures/graphics_pilot/realistic_map/wave4/"
SHELL_SHADER = "res://rendering/room407_shell.gdshader"
FOLIAGE_SHADER = RES["W3"] + "foliage.gdshader"
GROUND_SHADER = RES["W3"] + "ground_blend.gdshader"
TRACK_SHADER = RES["W4"] + "track.gdshader"
PITCH_SHADER = RES["W4"] + "pitch.gdshader"
PLASTER = CORNER + "architecture_painted_plaster_wall_"
PEEL = {"layer_albedo": SHELL + "wall_peel_color.jpg", "layer_normal": SHELL + "peeling_painted_wall_normal.jpg",
	"layer_arm": SHELL + "peeling_painted_wall_arm.jpg", "layer_scale": 2.0 / 1.8}
GREEN_RUST = {"albedo": CORNER + "fixtures_green_metal_rust_color.jpg", "orm": CORNER + "fixtures_green_metal_rust_arm.jpg",
	"normal": CORNER + "fixtures_green_metal_rust_normal.jpg", "scale": 1.0}


def mean_color(res_path):
	img = Image.open(GAME / res_path.replace("res://", "")).convert("RGB")
	return np.asarray(img, np.float32).reshape(-1, 3).mean(0) / 255.0


def tint_to(res_path, target):
	m = mean_color(res_path)
	return tuple(round(float(t / max(c, 1e-3)), 3) for t, c in zip(target, m))


TRACK_COMMON = {"noise": SHELL + "noise.png", "mask": OWN4 + "mask_field.png"}
PITCH_COMMON = {"grass_albedo": OWN3 + "ground_grass_color.png", "grass_normal": OWN3 + "ground_grass_normal.png",
	"dirt_albedo": OWN3 + "soil_color.png", "dirt_normal": OWN3 + "soil_normal.png", "turf_albedo": OWN4 + "turf_color.png",
	"turf_normal": OWN4 + "turf_normal.png", "mask": OWN4 + "mask_field.png", "noise": SHELL + "noise.png"}


def looks():
	return {
		# The stadium floor: TrackBounds' ground round the track (bare trodden dirt with grass at the edges).
		"W4Apron": {"ground": {"grass_albedo": OWN3 + "ground_grass_color.png", "grass_normal": OWN3 + "ground_grass_normal.png",
			"dirt_albedo": OWN3 + "soil_color.png", "dirt_normal": OWN3 + "soil_normal.png", "mask": OWN4 + "mask_field.png",
			"dirt_tint": (1.45, 1.35, 1.25), "grass_scale": 0.5, "dirt_scale": 0.9}},
		# R1: faded red rubber, painted lane lines a third gone. R2: cinder, chalked lines.
		"W4TrackRubber": {"track": {**TRACK_COMMON, "surface_albedo": OWN4 + "track_rubber_color.png",
			"surface_normal": OWN4 + "track_rubber_normal.png", "line_color": (0.78, 0.77, 0.73), "line_wear": 0.32,
			"line_softness": 0.003, "inner_wear": 0.45, "wear_color": (0.5, 0.36, 0.31), "roughness_value": 0.86}},
		"W4TrackCinder": {"track": {**TRACK_COMMON, "surface_albedo": OWN4 + "track_cinder_color.png",
			"surface_normal": OWN4 + "track_cinder_normal.png", "line_color": (0.74, 0.73, 0.68), "line_wear": 0.45,
			"line_softness": 0.012, "line_width": 0.065, "inner_wear": 0.35, "wear_color": (0.26, 0.21, 0.18), "roughness_value": 0.95}},
		# C1: living grass, dry and bald in patches; C2: old artificial turf worn to the crumb in the goalmouths.
		"W4PitchGrass": {"pitch": {**PITCH_COMMON, "kind": 0}},
		"W4Turf": {"pitch": {**PITCH_COMMON, "kind": 1}},
		# White paint (goal frame, kerb, fascia, track marks): wave 1's grey door paint taken to an old off-white.
		"W4Paint": {"albedo": OWN1 + "paint_grey_color.png", "normal": OWN1 + "paint_grey_normal.png",
			"orm": OWN1 + "paint_grey_orm.png", "color": tint_to(OWN1 + "paint_grey_color.png", (0.66, 0.66, 0.63)), "scale": 1.0},
		"W4Net": {"foliage": {"albedo_tex": OWN4 + "net.png", "tint": (0.8, 0.8, 0.78), "roughness_value": 0.9,
			"specular_value": 0.15, "translucency": 0.15}},
		"W4Chainlink": {"foliage": {"albedo_tex": OWN4 + "chainlink.png", "tint": (0.9, 0.9, 0.9), "roughness_value": 0.55,
			"specular_value": 0.4, "translucency": 0.0}},
		# Main stand: wave 1's concrete scan, aged by mask_stand.png (grime in the tread corners, water runs down the
		# risers, mould low down); no paint (peel 0).
		"W4StandConcrete": {"shader": {"kind": 0, "base_albedo": CORNER + "fixtures_plastered_wall_04_small_color.jpg",
			"base_normal": CORNER + "fixtures_plastered_wall_04_small_normal.jpg", "base_arm": CORNER + "fixtures_plastered_wall_04_small_arm.jpg",
			"base_tint": tint_to(CORNER + "fixtures_plastered_wall_04_small_color.jpg", (0.5, 0.49, 0.46)), "mask": OWN4 + "mask_stand.png",
			"peel_strength": 0.0, "grime_strength": 1.2, "stain_strength": 0.9, "mould_strength": 0.9, "normal_strength": 0.8,
			"grime_color": (0.42, 0.39, 0.33), "stain_color": (0.62, 0.52, 0.38)}},
		# S2 seats: moulded polypropylene, sun-faded blue (red at run time for the colour question).
		"W4Seat": {"color": (0.14, 0.25, 0.42), "rough": 0.5},
		"W4SeatRed": {"color": (0.46, 0.12, 0.1), "rough": 0.5},
		# Roof: the approved green-painted steel, a little lighter; galvanised corrugated sheet.
		"W4SteelFrame": {**GREEN_RUST, "color": (0.5, 0.62, 0.55)},
		"W4RoofSheet": {"albedo": OWN4 + "roof_sheet_color.png", "normal": OWN4 + "roof_sheet_normal.png", "rough": 0.5,
			"metallic": 0.45, "scale": 1.0},
		# Floodlights: galvanised pole and frame, dark lamp bodies, the glass glows only while Floodlights is shown.
		"W4PoleSteel": {"albedo": SHELL + "aluminium_color.jpg", "orm": SHELL + "aluminium_arm.jpg",
			"color": tint_to(SHELL + "aluminium_color.jpg", (0.5, 0.51, 0.5)), "scale": 1.0, "metallic_value": 0.6},
		"W4FloodBody": {"color": (0.15, 0.16, 0.17), "rough": 0.5, "metallic": 0.4},
		"W4FloodGlass": {"color": (0.7, 0.7, 0.66), "rough": 0.15, "emission": (1.0, 0.97, 0.88), "energy": 4.0},
		# Gate pillars: whitewash over plaster as wave 3's kerbs (D-175 K1), grime and moss at the foot (mask_stand.png).
		"W4Pillar": {"shader": {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg",
			"base_arm": PLASTER + "arm.jpg", "mask": OWN4 + "mask_stand.png", "peel": True, "base_tint": (0.98, 1.06, 1.25),
			"grime_strength": 1.2, "stain_strength": 0.7, "mould_strength": 1.0, "grime_color": (0.42, 0.38, 0.3)}},
	}


TRACK = """shader_type spatial;
// T-261: running track. UV.x = metres across from the inner kerb, UV.y = metres along the track; UV2 = mask_field.png
// (G wet). Lane lines are painted (or chalked) here, worn by a noise texture; lane 1 is worn lighter by feet.
uniform sampler2D surface_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D noise : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform sampler2D mask : hint_default_black, filter_linear, repeat_disable;
uniform float tile = 0.5;
uniform vec3 line_color : source_color = vec3(0.8);
uniform float line_width = 0.05;
uniform float lane_width = 1.22;
uniform float first_line = 0.025;
uniform float lines = 8.0;
uniform float line_wear = 0.35;
uniform float line_softness = 0.003;
uniform float inner_wear = 0.4;
uniform vec3 wear_color : source_color = vec3(0.5, 0.4, 0.35);
uniform float roughness_value = 0.88;
uniform float wet_strength = 0.7;

void fragment() {
	vec2 uv = UV * tile;
	vec3 base = texture(surface_albedo, uv).rgb;
	vec4 nf = texture(noise, UV * vec2(0.9, 0.23));
	vec4 nb = texture(noise, UV * 0.031);
	vec4 m = texture(mask, UV2);
	float k = (UV.x - first_line) / lane_width;
	float lane_pos = fract(k);
	float worn = inner_wear * (exp(-UV.x / 1.6) + 0.3 * exp(-lane_pos * 5.0)) * smoothstep(0.25, 0.75, nb.b + 0.3 * nf.g);
	base = mix(base, wear_color * (0.85 + 0.3 * nf.r), clamp(worn, 0.0, 0.8));
	float idx = clamp(round(k), 0.0, lines - 1.0);
	float d = abs(UV.x - (first_line + idx * lane_width));
	float line = 1.0 - smoothstep(line_width * 0.5 - line_softness, line_width * 0.5 + line_softness, d);
	float gone = smoothstep(line_wear - 0.12, line_wear + 0.12, 1.0 - (nf.g * 0.6 + nb.r * 0.4));
	base = mix(base, line_color * (0.85 + 0.2 * nf.r), line * (1.0 - gone));
	float wet = clamp(m.g * wet_strength, 0.0, 1.0);
	ALBEDO = base * (1.0 - 0.35 * wet);
	ROUGHNESS = mix(roughness_value - 0.1 * line, 0.2, wet);
	NORMAL_MAP = mix(texture(surface_normal, uv).rgb, vec3(0.5, 0.5, 1.0), line * 0.6 + wet * 0.5);
	SPECULAR = 0.4;
}
"""

PITCH = """shader_type spatial;
// T-261: the infield. UV = world (x, z) in metres; UV2 = mask_field.png (R bare dirt, G wet, B dry grass, A turf worn to
// the crumb). kind 0 living grass (C1), kind 1 artificial turf (C2). The pitch markings (96 x 58 m, centre 198, 166)
// are drawn here and worn by the noise texture.
uniform int kind = 0;
uniform sampler2D grass_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D grass_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D dirt_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D dirt_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D turf_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D turf_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D mask : hint_default_black, filter_linear, repeat_disable;
uniform sampler2D noise : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec3 dry_tint : source_color = vec3(1.0, 0.82, 0.5);
uniform vec3 line_color : source_color = vec3(0.72, 0.72, 0.68);
uniform float line_wear = 0.45;
uniform vec2 centre = vec2(198.0, 166.0);
uniform vec2 half_size = vec2(48.0, 29.0);

float seg(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a, ba = b - a;
	return length(pa - ba * clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0));
}

float markings(vec2 w) {
	vec2 p = w - centre;
	vec2 q = abs(p);
	float d = seg(q, vec2(0.0, half_size.y), half_size);       // touchlines
	d = min(d, seg(q, vec2(half_size.x, 0.0), half_size));      // goal lines
	d = min(d, seg(q, vec2(0.0), vec2(0.0, half_size.y)));      // halfway line
	d = min(d, abs(length(p) - 9.15));                           // centre circle
	float pa = half_size.x - 16.5;                               // penalty areas
	d = min(d, seg(q, vec2(pa, 0.0), vec2(pa, 20.16)));
	d = min(d, seg(q, vec2(pa, 20.16), vec2(half_size.x, 20.16)));
	float ga = half_size.x - 5.5;                                // goal areas
	d = min(d, seg(q, vec2(ga, 0.0), vec2(ga, 9.16)));
	d = min(d, seg(q, vec2(ga, 9.16), vec2(half_size.x, 9.16)));
	vec2 spot = vec2(half_size.x - 11.0, 0.0);
	if (q.x < pa) {
		d = min(d, abs(length(q - spot) - 9.15));                // penalty arcs
	}
	d = min(d, max(length(q - spot) - 0.06, 0.0));               // penalty spots
	d = min(d, max(length(p) - 0.06, 0.0));                      // centre spot
	if (q.x <= half_size.x && q.y <= half_size.y) {
		d = min(d, abs(length(q - half_size) - 1.0));            // corner arcs
	}
	return d;
}

void fragment() {
	vec2 w = UV;
	vec4 m = texture(mask, UV2);
	vec4 nf = texture(noise, w * 0.37);
	vec4 nb = texture(noise, w * 0.043);
	float line = 1.0 - smoothstep(0.055, 0.075, markings(w));
	float gone = smoothstep(line_wear - 0.15, line_wear + 0.15, 1.0 - (nf.g * 0.55 + nb.r * 0.45));
	line *= 1.0 - gone;
	vec3 albedo;
	vec3 nrm;
	float rough;
	if (kind == 0) {
		vec3 grass = texture(grass_albedo, w * 0.5).rgb;
		vec3 dry = grass * dry_tint * 1.25;
		grass = mix(grass, dry, clamp(m.b * (0.6 + 0.6 * nf.b), 0.0, 1.0));
		vec3 dirt = texture(dirt_albedo, w * 0.9).rgb * vec3(1.45, 1.35, 1.25);
		float bald = smoothstep(0.35, 0.7, m.r + (texture(grass_albedo, w * 0.19).g - 0.25) * 0.6 + (nf.a - 0.5) * 0.3);
		albedo = mix(grass, dirt, bald);
		nrm = mix(texture(grass_normal, w * 0.5).rgb, texture(dirt_normal, w * 0.9).rgb, bald);
		albedo = mix(albedo, line_color * (0.75 + 0.25 * grass.g * 3.0), line);
		rough = 0.93;
	} else {
		vec3 turf = texture(turf_albedo, w).rgb * mix(vec3(1.0), vec3(1.25, 1.2, 1.0), m.b * 0.6);
		float bare = smoothstep(0.4, 0.75, m.a + (nf.a - 0.5) * 0.35);
		vec3 crumb = vec3(0.05) * (0.8 + 0.4 * nf.r);
		float lum = dot(texture(turf_albedo, w).rgb, vec3(0.33)) * 2.5;
		albedo = mix(turf, crumb, bare);
		albedo = mix(albedo, line_color * clamp(lum, 0.6, 1.1), line * (1.0 - bare));
		nrm = mix(texture(turf_normal, w).rgb, vec3(0.5, 0.5, 1.0), bare * 0.6);
		rough = mix(0.75, 0.9, bare);
	}
	float wet = clamp(m.g * 0.7, 0.0, 1.0);
	ALBEDO = albedo * (1.0 - 0.35 * wet);
	ROUGHNESS = mix(rough, 0.25, wet);
	NORMAL_MAP = nrm;
	SPECULAR = 0.3;
}
"""


def fmt(value):
	if isinstance(value, bool):
		return "true" if value else "false"
	if isinstance(value, (tuple, list)):
		return "Color(%s, 1)" % ", ".join("%g" % v for v in value) if len(value) == 3 else "Vector2(%g, %g)" % tuple(value)
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
		elif isinstance(value, int) and not isinstance(value, bool):
			lines.append(f"shader_parameter/{key} = {value}")
		else:
			lines.append(f"shader_parameter/{key} = {fmt(value)}")
	head = '[gd_resource type="ShaderMaterial" format=3]\n\n'
	head += "".join(f'[ext_resource type="{k}" path="{p}" id="{i + 1}"]\n' for i, (k, p) in enumerate(ext))
	(MATS / f"{name}.tres").write_text(head + "\n[resource]\n" + "\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def write_material(name, look):
	for key, shader in (("shader", SHELL_SHADER), ("foliage", FOLIAGE_SHADER), ("ground", GROUND_SHADER),
			("track", TRACK_SHADER), ("pitch", PITCH_SHADER)):
		if key in look:
			write_shader_material(name, look[key], shader)
			return
	ext = []
	lines = [f'resource_name = "{name}"']
	textured = "orm" in look
	kind = "ORMMaterial3D" if textured else "StandardMaterial3D"

	def tex(path):
		ext.append(path)
		return f'ExtResource("{len(ext)}")'

	lines.append("albedo_color = Color(%g, %g, %g, 1)" % tuple(look.get("color", (1.0, 1.0, 1.0))))
	if "albedo" in look:
		lines.append("albedo_texture = " + tex(look["albedo"]))
	if textured:
		lines.append("orm_texture = " + tex(look["orm"]))
		if "metallic_value" in look:
			lines.append("metallic = %g" % look["metallic_value"])
	else:
		lines.append("roughness = %g" % look.get("rough", 0.6))
		if "metallic" in look:
			lines.append("metallic = %g" % look["metallic"])
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

source_file="res://assets/models/graphics_pilot/realistic_map/wave4/{glb}"

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
meshes/generate_lods=false
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
	return [m["name"] for m in doc.get("materials", [])]


def write_glb_import(glb, known):
	names = glb_materials(glb)
	missing = [n for n in names if n not in known]
	if missing:
		raise SystemExit("%s: no shared material for %s" % (glb.name, missing))
	entries = []
	for n in names:
		path = RES[n[:2]] + n + ".tres"
		entries.append('"%s": {\n"use_external/enabled": true,\n"use_external/fallback_path": "%s",\n"use_external/path": "%s"\n}' % (n, path, path))
	sub = '{\n"materials": {\n' + ",\n".join(entries) + "\n}\n}"
	target = glb.with_name(glb.name + ".import")
	text = GLB_IMPORT.format(glb=glb.name, subresources=sub)
	if target.exists():
		old = target.read_text(encoding="utf-8")
		text = re.sub(r"_subresources=\{.*?\n\}\n(?=gltf/)", "_subresources=" + sub + "\n", old, flags=re.S) if "_subresources={\n" in old \
			else old.replace("_subresources={}", "_subresources=" + sub)
	target.write_text(text, encoding="utf-8", newline="\n")
	print("T261_IMPORT", glb.name, names)


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
	(MATS / "track.gdshader").write_text(TRACK, encoding="utf-8", newline="\n")
	(MATS / "pitch.gdshader").write_text(PITCH, encoding="utf-8", newline="\n")
	all_looks = looks()
	for name, look in all_looks.items():
		write_material(name, look)
	known = set(all_looks)
	for wave in ("wave1", "wave2", "wave3"):
		known |= {p.stem for p in (GAME / f"assets/models/graphics_pilot/realistic_map/{wave}/materials").glob("*.tres")}
	for glb in sorted(MODELS.glob("*.glb")):
		write_glb_import(glb, known)
	write_texture_imports()


if __name__ == "__main__":
	main()
