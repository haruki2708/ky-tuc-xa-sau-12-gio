class_name Room407Furnish
extends RefCounted
## The furnished room 407 approved in D-102 (D-096…D-101), built from data for the playable
## room (room407.gd, T-215) and its visual pilot: the T-213 shell, every Tripo/Blender prop
## of placements.json and the grime decals of decals.json. Visual only: no collision.

const SHELL := "res://assets/models/graphics_pilot/room407_corner/"
const PLACEMENTS := "res://data/room407/placements.json"
const DECALS := "res://data/room407/decals.json"
const TUBE_COLOR := Color(0.88, 0.94, 0.80)
## Models and decal textures stay loaded once read: floor 4 (and this room) is rebuilt on every
## chapter load, retry and test, and ~120 GLBs would otherwise be read from disk each time.
static var _cache: Dictionary = {}


static func _resource(path: String) -> Resource:
	if not _cache.has(path):
		_cache[path] = load(path)
	return _cache[path]


static func placements() -> Array:
	return JSON.parse_string(FileAccess.get_file_as_string(PLACEMENTS))


static func decal_rows() -> Array:
	return JSON.parse_string(FileAccess.get_file_as_string(DECALS))


## Node "Furnished" in room-local space: floor/architecture/fixtures, TripoProps, Decals.
## Each prop and decal keeps its data row as meta "placement".
static func build() -> Node3D:
	var root := Node3D.new()
	root.name = "Furnished"
	for part: String in ["floor", "architecture", "fixtures"]:
		var model := (_resource(SHELL + part + ".glb") as PackedScene).instantiate() as Node3D
		model.name = part
		root.add_child(model)
	# The corner pilot's Blender desk lamp is replaced by the Tripo lamp.
	for node: Node in root.get_node("fixtures").find_children("Lamp*", "", true, false):
		(node as Node3D).hide()
	var props := Node3D.new()
	props.name = "TripoProps"
	root.add_child(props)
	for row: Dictionary in placements():
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
	for row: Dictionary in decal_rows():
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
