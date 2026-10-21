class_name Room407Furnish
extends RefCounted
## The furnished room 407 approved in D-102 (D-096…D-101), built from data for the playable
## room (room407.gd, T-215) and its visual pilot: the T-213 shell, every Tripo/Blender prop
## of placements.json and the grime decals of decals.json. Visual only: no collision.

const SHELL := "res://assets/models/graphics_pilot/room407_corner/"
## T-222 (D-126): the upgraded shell (walls, ceiling, floor, frames, balcony); the playable room keeps
## the T-213 shell ("corner") until the owner approves the pilot.
const SHELL_T222 := "res://assets/models/graphics_pilot/room407_shell/"
const SHELL_PARTS := {"corner": ["floor", "architecture", "fixtures"],
	"t222": ["floor", "architecture", "ceiling", "frames", "fixtures", "balcony", "outside"]}
## Outside the balcony (outside.glb): the sky, lit windows and the courtyard lamp glow through the night fog,
## drawn at this fraction of their texture.
const OUTSIDE_UNLIT := {"OutsideSky": 0.3, "OutsideWindowLit": 0.75, "OutsideLampLit": 1.0}
## The blocks are lit only by the night ambient: their render is darkened to read as night.
const OUTSIDE_TINT := {"OutsideFacade": 0.42, "OutsideConcrete": 0.55}
const SHELL_SHADER := preload("res://rendering/room407_shell.gdshader")
const SHELL_TEX := "res://assets/textures/graphics_pilot/room407_shell/"
const CORNER_TEX := "res://assets/models/graphics_pilot/room407_corner/"
const PLASTER := CORNER_TEX + "architecture_painted_plaster_wall_"
const PEEL := {"layer_albedo": SHELL_TEX + "wall_peel_color.jpg", "layer_normal": SHELL_TEX + "peeling_painted_wall_normal.jpg",
	"layer_arm": SHELL_TEX + "peeling_painted_wall_arm.jpg", "layer_scale": 2.0 / 1.8}
## Shader parameters of the T-222 shell materials (glTF placeholders named Shell*, build_shell.py).
const SHELL_LOOKS := {
	"ShellWall": {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg",
		"base_arm": PLASTER + "arm.jpg", "mask": SHELL_TEX + "mask_walls.png", "peel": true,
		"base_tint": Color(0.95, 0.91, 0.83), "grime_strength": 1.5, "stain_strength": 1.3, "mould_strength": 1.2},
	"ShellCeiling": {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg",
		"base_arm": PLASTER + "arm.jpg", "mask": SHELL_TEX + "mask_ceiling.png", "peel": true,
		"base_tint": Color(1.0, 0.97, 0.88), "normal_strength": 0.5, "grime_strength": 1.4, "stain_strength": 1.3},
	"ShellExterior": {"kind": 0, "base_albedo": SHELL_TEX + "plastered_wall_02_color.jpg",
		"base_normal": SHELL_TEX + "plastered_wall_02_normal.jpg", "base_arm": SHELL_TEX + "plastered_wall_02_arm.jpg",
		"mask": SHELL_TEX + "mask_balcony.png", "peel": true, "base_tint": Color(1.0, 0.9, 0.66)},
	"ShellFloor": {"kind": 1, "base_albedo": CORNER_TEX + "floor_interior_tiles_color.jpg",
		"base_normal": CORNER_TEX + "floor_interior_tiles_normal.jpg", "base_arm": CORNER_TEX + "floor_interior_tiles_arm.jpg",
		"mask": SHELL_TEX + "mask_floor.png", "grime_strength": 1.6, "wet_strength": 1.3, "grout_strength": 1.3},
	"ShellSkirting": {"kind": 1, "base_albedo": CORNER_TEX + "floor_interior_tiles_color.jpg",
		"base_normal": CORNER_TEX + "floor_interior_tiles_normal.jpg", "base_arm": CORNER_TEX + "floor_interior_tiles_arm.jpg",
		"mask": SHELL_TEX + "mask_floor.png"},
	"ShellBathfloor": {"kind": 1, "base_albedo": SHELL_TEX + "anti_skid_tiles_color.jpg",
		"base_normal": SHELL_TEX + "anti_skid_tiles_normal.jpg", "base_arm": SHELL_TEX + "anti_skid_tiles_arm.jpg",
		"mask": SHELL_TEX + "mask_floor.png", "base_tint": Color(0.86, 0.84, 0.82)},
	"ShellBalconyfloor": {"kind": 1, "base_albedo": SHELL_TEX + "floor_tiles_08_color.jpg",
		"base_normal": SHELL_TEX + "floor_tiles_08_normal.jpg", "base_arm": SHELL_TEX + "floor_tiles_08_arm.jpg",
		"mask": SHELL_TEX + "mask_balcony.png"},
}
const PLACEMENTS := "res://data/room407/placements.json"
## T-222: washing on the balcony line, and the chapter-2 towel (room407.gd hangs it on TowelSpot).
const PLACEMENTS_T222 := "res://data/room407/placements_t222.json"
const DECALS := "res://data/room407/decals.json"
const TUBE_COLOR := Color(0.88, 0.94, 0.80)
## Models and decal textures stay loaded once read: floor 4 (and this room) is rebuilt on every
## chapter load, retry and test, and ~120 GLBs would otherwise be read from disk each time.
static var _cache: Dictionary = {}


static func _resource(path: String) -> Resource:
	if not _cache.has(path):
		_cache[path] = load(path)
	return _cache[path]


static func placements(shell: String = "corner") -> Array:
	var rows: Array = JSON.parse_string(FileAccess.get_file_as_string(PLACEMENTS))
	if shell == "t222":
		rows += JSON.parse_string(FileAccess.get_file_as_string(PLACEMENTS_T222))
	return rows


static func decal_rows() -> Array:
	return JSON.parse_string(FileAccess.get_file_as_string(DECALS))


## Node "Furnished" in room-local space: the shell parts (SHELL_PARTS), TripoProps, Decals.
## Each prop and decal keeps its data row as meta "placement". shell: "corner" or "t222".
static func build(shell: String = "corner") -> Node3D:
	var root := Node3D.new()
	root.name = "Furnished"
	for part: String in SHELL_PARTS[shell]:
		var folder := SHELL if shell == "corner" else SHELL_T222
		var model := (_resource(folder + part + ".glb") as PackedScene).instantiate() as Node3D
		model.name = part
		root.add_child(model)
		if shell == "t222":
			_apply_shell_looks(model)
	# The corner pilot's Blender desk lamp is replaced by the Tripo lamp.
	for node: Node in root.get_node("fixtures").find_children("Lamp*", "", true, false):
		(node as Node3D).hide()
	var props := Node3D.new()
	props.name = "TripoProps"
	root.add_child(props)
	for row: Dictionary in placements(shell):
		var model := (_resource(row.model) as PackedScene).instantiate() as Node3D
		model.name = row.name
		model.position = Vector3(row.position[0], row.position[1], row.position[2])
		model.rotation_degrees = Vector3(row.get("rot_x", 0.0), row.yaw, 0)
		if row.get("mount", "") == "wall":
			# The row position is a point on the wall: push the model's back (+Z) onto it.
			model.position += model.basis * Vector3(0, 0, -local_bounds(model).end.z)
		model.set_meta(&"placement", row)
		props.add_child(model)
	var decals := Node3D.new()
	decals.name = "Decals"
	root.add_child(decals)
	# The T-222 shell paints its grime into the surfaces themselves.
	for row: Dictionary in decal_rows() if shell == "corner" else []:
		var decal := decal(row)
		decal.set_meta(&"placement", row)
		decals.add_child(decal)
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		mesh.gi_mode = GeometryInstance3D.GI_MODE_STATIC
		if String(mesh.name).begins_with("FluorescentTube"):
			var material := mesh.get_active_material(0).duplicate() as StandardMaterial3D
			material.emission_enabled = true
			material.emission = TUBE_COLOR
			mesh.material_override = material
	return root


## T-222: the Shell* placeholder materials become room407_shell.gdshader with their SHELL_LOOKS.
static func _apply_shell_looks(model: Node3D) -> void:
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		for surface in mesh.mesh.get_surface_count():
			var material := mesh.mesh.surface_get_material(surface)
			if material and SHELL_LOOKS.has(material.resource_name):
				mesh.set_surface_override_material(surface, shell_material(material.resource_name))
			elif material and OUTSIDE_UNLIT.has(material.resource_name):
				var unlit := material.duplicate() as StandardMaterial3D
				unlit.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				unlit.disable_fog = true
				unlit.albedo_color = Color(1, 1, 1) * OUTSIDE_UNLIT[material.resource_name]
				mesh.set_surface_override_material(surface, unlit)
				mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			elif material and OUTSIDE_TINT.has(material.resource_name):
				var night := material.duplicate() as StandardMaterial3D
				night.albedo_color *= OUTSIDE_TINT[material.resource_name]
				mesh.set_surface_override_material(surface, night)


static func shell_material(look_name: String) -> ShaderMaterial:
	var key := "shell:" + look_name
	if not _cache.has(key):
		var look: Dictionary = SHELL_LOOKS[look_name]
		var material := ShaderMaterial.new()
		material.shader = SHELL_SHADER
		var parameters := look.duplicate()
		if parameters.get("peel", false):
			parameters.merge(PEEL)
		parameters.erase("peel")
		parameters["noise"] = SHELL_TEX + "noise.png"
		for parameter: String in parameters:
			var value: Variant = parameters[parameter]
			material.set_shader_parameter(parameter, _resource(value) if value is String else value)
		_cache[key] = material
	return _cache[key]


## Emissive materials of the ceiling tube meshes (lit with the main light).
static func tube_materials(root: Node3D) -> Array[StandardMaterial3D]:
	var result: Array[StandardMaterial3D] = []
	for mesh: MeshInstance3D in root.find_children("FluorescentTube*", "MeshInstance3D", true, false):
		result.append(mesh.material_override as StandardMaterial3D)
	return result


## Unrotated bounds of a model in its own space (all meshes).
static func local_bounds(model: Node3D) -> AABB:
	var result := AABB()
	var first := true
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		var to_model := Transform3D()
		var node: Node = mesh
		while node != model:
			to_model = (node as Node3D).transform * to_model
			node = node.get_parent()
		var box: AABB = to_model * mesh.get_aabb()
		result = box if first else result.merge(box)
		first = false
	return result


## D-100 grime decal. "project" is the direction it prints towards (into the surface):
## -y floor, +y ceiling, -x west faces, +x east faces, -z back faces, +z the door wall.
## "size" is [width, height on the surface, projection depth].
static func decal(row: Dictionary) -> Decal:
	var result := Decal.new()
	result.name = row.name
	result.texture_albedo = _resource(row.texture) as Texture2D
	# Decals print along local -Y with the image on local X/Z.
	result.size = Vector3(row.size[0], row.size[2], row.size[1])
	result.position = Vector3(row.position[0], row.position[1], row.position[2])
	result.modulate = Color(1, 1, 1, row.get("opacity", 1.0))
	result.upper_fade = 0.1
	result.lower_fade = 0.1
	var turns := {"-y": Vector3.ZERO, "+y": Vector3(180, 0, 0), "-x": Vector3(0, 0, -90), "+x": Vector3(0, 0, 90),
		"-z": Vector3(90, 0, 0), "+z": Vector3(-90, 0, 0)}
	result.rotation_degrees = turns[row.project]
	# On x-facing walls the turn stands local X upright: spin it back so the image's top stays up.
	var spin: float = row.get("spin", 0.0) + (90.0 if row.project in ["-x", "+x"] else 0.0)
	if spin != 0.0:
		result.rotate_object_local(Vector3.UP, deg_to_rad(spin))
	return result
