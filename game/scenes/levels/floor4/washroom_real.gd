extends Node3D
## T-256 (D-170) part A: the floor-4 shared washroom in room 407's style over its PS1 boxes, in every chapter (and the
## old demo main.tscn). Visual only: the PS1 meshes are hidden, never freed; no collider, light, sound, area or
## anchor is moved, added or renamed (washroom.tscn's contract, card T-256 section 2).
## - washroom.glb (art_source/graphics_upgrade/realistic_map/floor4_rest/build_washroom.py): shell, stalls with
##   their leaves standing open, the wash trough and taps, fixtures, props, the mirror's stain.
## - The mirror reflects for real as room 407's do (D-105, D-170): room 407's HD surface on mirror.tscn's glass (its
##   size, viewport and when it draws stay as test_mirror holds them); it follows the body that carries the current
##   camera (as room407.gd does), and where that player has Tran Trung's body its PS1 stand-in is hidden (as
##   Protagonist.attach does for room 407's mirrors). Its PS1 frame hides behind the new aluminium one.
## - The batten's tube glows with WashroomLight (on, off, flickering), as the corridor's do.

const MODEL := preload("res://assets/models/graphics_pilot/realistic_map/floor4_rest/washroom.glb")
const MIRROR_SHADER := preload("res://rendering/mirror_surface_hd.gdshader")
## The mirror surface's render layer (mirror.gd SURFACE_LAYER): its own reflection camera does not see it.
const SURFACE_LAYER := 1 << 18
const TUBE_COLOR := Color(0.85, 0.95, 0.8)
## PS1 meshes the real washroom replaces (their collision stays).
const REPLACED: Array[String] = ["Floor/Mesh", "WestWall/Mesh", "BackWall/Mesh", "EastWall/Mesh", "Ceiling/Mesh",
	"EntranceWest/Mesh", "EntranceEast/Mesh", "EntranceLintel/Mesh", "StallDoor_0/Model", "StallDoor_1/Model",
	"StallDoor_2/Model", "StallPartition_0/Mesh", "StallPartition_1/Mesh", "StallPartition_2/Mesh", "Sink_0/Model",
	"Sink_1/Model", "Sink_2/Model", "Tap_0", "Tap_1", "Tap_2", "WashroomLight/Fixture/Mesh", "Details", "Mirror/Frame"]

## Off only to compare with the PS1 washroom: set it before the washroom enters the tree.
@export var upgraded := true
var real: Node3D
var _tube: StandardMaterial3D
var _light: Light3D
var _light_energy := 1.0
var _mirror: Node3D


func _ready() -> void:
	if not upgraded:
		return
	real = MODEL.instantiate() as Node3D
	real.name = "Real"
	add_child(real)
	for path: String in REPLACED:
		var node := get_node_or_null(path) as Node3D
		if node != null:
			node.visible = false
	for mesh: MeshInstance3D in real.find_children("*", "MeshInstance3D", true, false):
		mesh.gi_mode = GeometryInstance3D.GI_MODE_STATIC
		if mesh.name == &"MirrorStain":
			mesh.layers = SURFACE_LAYER
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for surface in mesh.mesh.get_surface_count():
			var source := mesh.mesh.surface_get_material(surface)
			if source != null and source.resource_name == "WRTubeGlass":
				_tube = (mesh.get_active_material(surface) as StandardMaterial3D).duplicate() as StandardMaterial3D
				_tube.emission_enabled = true
				_tube.emission = TUBE_COLOR
				mesh.set_surface_override_material(surface, _tube)
	_light = get_node_or_null("WashroomLight") as Light3D
	if _light != null:
		_light_energy = maxf(_light.light_energy, 0.001)
	_mirror = get_node_or_null("Mirror") as Node3D
	if _mirror != null:
		_upgrade_mirror(_mirror)
	_process(0.0)


## The mirror (mirror.gd, already ready) with room 407's HD surface (smooth filtering, a faint glass tint).
func _upgrade_mirror(mirror: Node3D) -> void:
	var surface := mirror.get_node("Surface") as MeshInstance3D
	var viewport := mirror.get_node("ReflectionViewport") as SubViewport
	var material := surface.material_override as ShaderMaterial
	if material != null:
		material.shader = MIRROR_SHADER
		material.set_shader_parameter("reflection_texture", viewport.get_texture())


func _process(_delta: float) -> void:
	if real == null:
		return
	if _tube != null and _light != null:
		var on := _light.is_visible_in_tree() and _light.light_energy > 0.0
		_tube.emission_energy_multiplier = _light.light_energy / _light_energy if on else 0.0
	if _mirror != null:
		_follow_mirror()


## The mirror follows the body carrying the current camera as Head/Camera3D (room407.gd _update_mirror_follow); a
## player with Tran Trung's body shows its own mirror copy, so the PS1 stand-in hides (Protagonist.attach).
func _follow_mirror() -> void:
	var camera := get_viewport().get_camera_3d()
	var head := camera.get_parent() if camera != null else null
	var player := head.get_parent() as Node3D if head != null and head.name == &"Head" else null
	if player == null:
		return
	if _mirror.get("follow") != player:
		_mirror.set("follow", player)
	var stand_in := _mirror.get_node_or_null("ReflectionBody") as Node3D
	if stand_in != null:
		var bodied: bool = player.get("body") != null
		for mesh: MeshInstance3D in stand_in.find_children("*", "MeshInstance3D", true, false):
			if mesh.visible == bodied:
				mesh.visible = not bodied
