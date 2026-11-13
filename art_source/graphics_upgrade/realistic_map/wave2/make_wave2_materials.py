"""T-253 wave 2: this wave's shared Godot materials (W2*) and each wave-2 glb's .import, which maps W1* placeholders
onto wave 1's materials (game/assets/models/graphics_pilot/realistic_map/wave1/materials, approved in D-167; not
copied, not changed) and W2* onto …/wave2/materials. No texture is copied into a glb.

Scans: the CC0 Poly Haven sets already in the game (Painted Plaster Wall, the room-407 mattress linen and tatami);
the rest is drawn by ../wave1/make_wave1_textures.py (terrazzo, grey enamel paint) and make_wave2_textures.py.
Run: python -B art_source/graphics_upgrade/realistic_map/wave2/make_wave2_materials.py  (then let Godot import)
"""
from pathlib import Path
import json
import re
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[4]
MODELS = ROOT / "game/assets/models/graphics_pilot/realistic_map/wave2"
MATS = MODELS / "materials"
RES_W1 = "res://assets/models/graphics_pilot/realistic_map/wave1/materials/"
RES_W2 = "res://assets/models/graphics_pilot/realistic_map/wave2/materials/"
CORNER = "res://assets/models/graphics_pilot/room407_corner/"
SHELL = "res://assets/textures/graphics_pilot/room407_shell/"
FURNISHED = "res://assets/models/graphics_pilot/room407_furnished/"
OWN1 = "res://assets/textures/graphics_pilot/realistic_map/wave1/"
OWN2 = "res://assets/textures/graphics_pilot/realistic_map/wave2/"
PLASTER = CORNER + "architecture_painted_plaster_wall_"
PAINT = {"albedo": OWN1 + "paint_grey_color.png", "orm": OWN1 + "paint_grey_orm.png", "normal": OWN1 + "paint_grey_normal.png"}
LINEN = FURNISHED + "bunk_mattress_rough_linen_square_"
TATAMI = FURNISHED + "bunk_mattress_tatami_mat_"
SHELL_SHADER = "res://rendering/room407_shell.gdshader"
PEEL = {"layer_albedo": SHELL + "wall_peel_color.jpg", "layer_normal": SHELL + "peeling_painted_wall_normal.jpg",
	"layer_arm": SHELL + "peeling_painted_wall_arm.jpg", "layer_scale": 2.0 / 1.8}
WALL = {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg",
	"base_arm": PLASTER + "arm.jpg", "peel": True}

LOOKS = {
	# Corridors (A08-A10): wave 1's stair wall, dado, terrazzo and soffit, on this wave's corridor masks.
	"W2HallWall": {"shader": {**WALL, "mask": OWN2 + "mask_hall_wall.png", "base_tint": (0.9, 0.88, 0.82),
		"grime_strength": 1.2, "stain_strength": 0.45}},
	"W2HallDado": {"shader": {**WALL, "mask": OWN2 + "mask_hall_wall.png", "base_tint": (0.6, 0.7, 0.68),
		"grime_strength": 1.3, "stain_strength": 0.35}},
	"W2HallCeiling": {"shader": {**WALL, "mask": OWN2 + "mask_hall_ceiling.png", "base_tint": (0.93, 0.92, 0.86),
		"normal_strength": 0.5, "stain_strength": 0.4}},
	"W2HallFloor": {"shader": {"kind": 1, "base_albedo": OWN1 + "terrazzo_color.png", "base_normal": OWN1 + "terrazzo_normal.png",
		"base_arm": OWN1 + "terrazzo_orm.png", "mask": OWN2 + "mask_hall_floor.png", "grime_strength": 0.75,
		"wear_strength": 0.7, "normal_strength": 0.5}},
	"W2Divider": {"color": (0.36, 0.31, 0.22), "rough": 0.55, "metal": 0.6},
	"W2Tube": {"color": (0.92, 0.95, 0.88), "rough": 0.3, "emission": (0.86, 0.92, 0.78), "energy": 1.6},
	# Rooms.
	"W2Mattress": {"albedo": LINEN + "color.jpg", "orm": LINEN + "arm.jpg", "normal": LINEN + "normal.jpg", "scale": 2.0,
		"color": (0.82, 0.78, 0.72)},
	"W2Chieu": {"albedo": TATAMI + "color.jpg", "orm": TATAMI + "arm.jpg", "normal": TATAMI + "normal.jpg", "scale": 2.0},
	"W2Pillow": {"albedo": LINEN + "color.jpg", "orm": LINEN + "arm.jpg", "normal": LINEN + "normal.jpg", "scale": 3.0,
		"color": (0.72, 0.76, 0.84)},
	"W2BunkPaint": {**PAINT, "scale": 2.0, "color": (0.32, 0.45, 0.52)},
	"W2LockerPaint": {**PAINT, "scale": 2.0, "color": (0.66, 0.72, 0.66)},
	# Floor 1 (A10): glass of the main door and the manager's window, the knife.
	"W2Glass": {"color": (0.5, 0.58, 0.56), "alpha": 0.25, "rough": 0.06},
	"W2Blade": {"color": (0.72, 0.72, 0.7), "rough": 0.22, "metal": 1.0},
	"W2Grip": {"color": (0.07, 0.06, 0.05), "rough": 0.55},
	# A11: the fire extinguisher and the fire alarm.
	"W2ExtRed": {**PAINT, "scale": 4.0, "color": (0.74, 0.07, 0.05)},
	"W2ExtLabel": {"albedo": OWN2 + "extinguisher_label.png", "rough": 0.45},
	"W2Gauge": {"albedo": OWN2 + "gauge_dial.png", "rough": 0.12},
	"W2AlarmRed": {**PAINT, "scale": 4.0, "color": (0.72, 0.07, 0.05)},
	"W2AlarmFace": {"albedo": OWN2 + "alarm_face.png", "rough": 0.4},
	"W2AlarmButton": {"color": (0.9, 0.88, 0.82), "rough": 0.2},
}


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
	MATS.mkdir(parents=True, exist_ok=True)
	if "shader" in look:
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
	if "alpha" in look:
		lines += ["transparency = 1", "albedo_color = Color(%g, %g, %g, %g)" % (*color, look["alpha"])]
	else:
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


IMPORT = """[remap]

importer="scene"
importer_version=1
type="PackedScene"

[deps]

source_file="res://assets/models/graphics_pilot/realistic_map/wave2/{glb}"

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
	data = path.read_bytes()
	length = int.from_bytes(data[12:16], "little")
	doc = json.loads(data[20:20 + length].decode("utf-8"))
	return [m["name"] for m in doc.get("materials", []) if m.get("name", "")[:2] in ("W1", "W2")]


def wave1_names():
	return {p.stem for p in (ROOT / "game/assets/models/graphics_pilot/realistic_map/wave1/materials").glob("*.tres")}


def write_import(glb, known):
	names = glb_materials(glb)
	missing = [n for n in names if n not in known]
	if missing:
		raise SystemExit("%s: no material for %s" % (glb.name, missing))
	entries = []
	for n in names:
		path = (RES_W1 if n.startswith("W1") else RES_W2) + n + ".tres"
		entries.append('"%s": {\n"use_external/enabled": true,\n"use_external/fallback_path": "%s",\n"use_external/path": "%s"\n}' % (n, path, path))
	sub = '{\n"materials": {\n' + ",\n".join(entries) + "\n}\n}"
	target = glb.with_name(glb.name + ".import")
	text = IMPORT.format(glb=glb.name, subresources=sub)
	if target.exists():
		# Keep Godot's uid and imported path; replace only the mapping.
		old = target.read_text(encoding="utf-8")
		old = re.sub(r"_subresources=\{.*?\n\}\n(?=gltf/)", "_subresources=" + sub + "\n", old, flags=re.S) if "_subresources={\n" in old \
			else old.replace("_subresources={}", "_subresources=" + sub)
		text = old
	target.write_text(text, encoding="utf-8", newline="\n")
	print("T253_IMPORT", glb.name, len(names), "materials")


def main():
	for name, look in LOOKS.items():
		write_material(name, look)
	known = wave1_names() | set(LOOKS)
	for glb in sorted(MODELS.glob("*.glb")):
		write_import(glb, known)


if __name__ == "__main__":
	main()
