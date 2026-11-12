extends Node3D
## T-252 visual-only module. RoomDoor remains the sole owner of door state and collision.

const ASSETS := "res://assets/models/graphics_pilot/realistic_map/floor4_rooms/"
const TEXTURES := "res://assets/models/graphics_pilot/room407_corner/"
const SCANS := {
	"Plaster": "architecture_painted_plaster_wall",
	"Tile": "floor_interior_tiles",
	"Steel": "bunk_a_green_metal_rust",
	"Wood": "study_desk_wood_table_worn",
	"Linen": "bunk_a_rough_linen_square",
	"Check": "bunk_a_bedding_fabric_pattern_05",
	"Blanket": "bunk_a_bedding_polar_fleece_square",
}
static var materials: Dictionary[String, StandardMaterial3D] = {}
@export var room: String = "401"
@export var width: int = 4
var furnishings: Node3D
var door: Node3D
var hinge: Node3D


func _ready() -> void:
	_make_materials()
	door = get_parent().get_parent().get_node("LockedDoor_" + room) as Node3D
	hinge = door.get_node("Hinge") as Node3D
	_add_part(self, "shell_%d" % width, "Shell", Vector3.ZERO)
	furnishings = Node3D.new()
	furnishings.name = "Furnishings"
	add_child(furnishings)
	_add_part(furnishings, "curtains", "Curtains", Vector3.ZERO)
	var half := float(width) / 2.0
	var variant := int(room) % 3
	_add_part(furnishings, "bunk", "BunkWest", Vector3(-half + 0.67, 0, -3.45))
	_add_part(furnishings, "bunk", "BunkEast", Vector3(half - 0.67, 0, -1.45), PI)
	_add_part(furnishings, "locker", "Locker", Vector3(half - 0.65, 0, -3.9))
	_add_part(furnishings, "desk", "Desk", Vector3((variant - 1) * 0.16, 0, -4.48))
	_add_part(furnishings, "stool", "Stool", Vector3((variant - 1) * 0.23, 0, -3.68), (variant - 1) * 0.26)
	_update_visibility()
	# Preserve the existing unfurnished-407 comparison mode, including its shared partition.
	var floor4 := get_parent().get_parent().get_parent()
	var room407 := floor4.get_node_or_null("Room407") if floor4 != null else null
	if room407 != null and room407.get("furnished") == false:
		_restore_legacy_comparison()


func _restore_legacy_comparison() -> void:
	hide()
	set_process(false)
	var corridor := get_parent().get_parent()
	for child: Node in get_parent().get_children():
		if child != self:
			for mesh: MeshInstance3D in child.find_children("*", "MeshInstance3D", true, false):
				mesh.show()
	for prefix: String in ["Floor_", "BackWall_", "Ceiling_"]:
		var legacy := corridor.get_node_or_null(prefix + room + "/Mesh") as Node3D
		if legacy != null:
			legacy.show()
	var partition := 38 if room == "408" else 6 + (int(room) - 401) * 4
	(corridor.get_node("RoomPartition_%d/Mesh" % partition) as Node3D).show()
	if room == "408":
		(corridor.get_node("Room408BackWall/Mesh") as Node3D).show()
		(corridor.get_node("Room408EastWall/Mesh") as Node3D).show()


func _process(_delta: float) -> void:
	_update_visibility()


func _update_visibility() -> void:
	# Keep furniture through the closing swing, so it cannot pop out through an open gap.
	furnishings.visible = bool(door.get("is_open")) or absf(hinge.rotation.y) > 0.001


func _add_part(parent: Node3D, asset: String, label: String, at: Vector3, yaw: float = 0.0) -> void:
	var part := (load(ASSETS + asset + ".glb") as PackedScene).instantiate() as Node3D
	part.name = label
	part.position = at
	part.rotation.y = yaw
	parent.add_child(part)
	var meshes := part.find_children("*", "MeshInstance3D", true, false)
	if part is MeshInstance3D:
		meshes.append(part)
	for mesh: MeshInstance3D in meshes:
		for surface: int in mesh.mesh.get_surface_count():
			var source := mesh.mesh.surface_get_material(surface)
			mesh.set_surface_override_material(surface, materials[String(source.resource_name)])


static func _make_materials() -> void:
	if not materials.is_empty():
		return
	for label: String in SCANS:
		var material := StandardMaterial3D.new()
		material.resource_name = "T252_" + label
		var prefix: String = TEXTURES + SCANS[label] + "_"
		var color_path := prefix + "color.jpg"
		if label == "Plaster":
			color_path = TEXTURES + "architecture_painted_plaster_wall_cream_color.jpg"
		material.albedo_texture = load(color_path) as Texture2D
		material.normal_enabled = true
		material.normal_texture = load(prefix + "normal.jpg") as Texture2D
		material.normal_scale = 0.65
		var arm := load(prefix + "arm.jpg") as Texture2D
		material.roughness_texture = arm
		material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
		material.metallic_texture = arm
		material.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_BLUE
		material.metallic = 1.0
		material.ao_enabled = true
		material.ao_texture = arm
		material.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		material.cull_mode = BaseMaterial3D.CULL_DISABLED if label == "Linen" else BaseMaterial3D.CULL_BACK
		materials[label] = material
	var dark := StandardMaterial3D.new()
	dark.resource_name = "T252_Dark"
	dark.albedo_color = Color(0.045, 0.06, 0.065)
	dark.roughness = 0.42
	materials["Dark"] = dark
