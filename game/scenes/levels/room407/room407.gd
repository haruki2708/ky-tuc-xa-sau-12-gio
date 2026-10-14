extends Node3D
## Environment APIs only. No rules, damage, death or puzzle decisions.

const SURFACE := preload("res://rendering/room407_surface.gdshader")
var blood_stage: int = 0
var slashed_amount: float = 0.0
var _drip_time: float = 0.0
var desk_lamp_on: bool = true
## T-215 (D-102): the approved furnished room draws the room; the PS1 meshes hide but every
## node, collision and API stays. False keeps the PS1 room (comparisons, old captures).
@export var furnished: bool = true
## PS1 meshes that stay: story states, puzzles and clue props (paths under Room407).
const KEEP_PS1: Array[String] = ["Anchors", "Details/BloodSeep", "Details/BloodPools", "Details/SlashRips",
	"Details/Debris", "Details/CleaningRag", "Ch2Bathroom", "Cables", "Zones"]
## Inside KEEP_PS1, the PS1 meshes that a furnished model draws instead.
const REPLACED_PS1: Array[String] = ["Anchors/VietLocker/Back", "Anchors/VietLocker/West",
	"Anchors/VietLocker/East", "Anchors/VietLocker/Shelf*", "Anchors/VietLocker/Pivot",
	"Anchors/PhucMattress/Pivot", "Anchors/TeamPhoto", "Anchors/TrashBin/Base", "Anchors/TrashBin/Slat*",
	"Anchors/Router/Model/Case", "Anchors/Router/Model/Antenna*", "Anchors/Router/Model/Vent*",
	# D-106: the readable ch1_phuc_card (every chapter places it) draws the card.
	"Anchors/PhucCard/Card", "Anchors/PhucCard/Photo", "Anchors/PhucCard/Head"]
## Furnished props carried by a moving PS1 node (net stir and hide, mattress lift, slashed pillow).
const FOLLOW := {"NetViet": "BunkA/Net_Viet", "NetPhuc": "BunkA/Net_Phuc", "NetTrung": "BunkB/Net_Trung",
	"NetDat": "BunkB/Net_Dat", "MattressPhuc": "Anchors/PhucMattress/Pivot",
	"BlanketPhuc": "Anchors/PhucMattress/Pivot", "PillowPhuc": "Anchors/PhucMattress/Pivot",
	"PillowTrung": "Details/TrungPillow"}
## The playable corridor wall reaches z = -0.1 while the pilot shell's door wall face is z = 0:
## the door wall, the things on it and its decals come 0.105 m into the room.
const DOOR_WALL_SHIFT := -0.105
const DOOR_WALL_PARTS: Array[String] = ["architecture/FrontWallWest", "architecture/FrontWallEast",
	"architecture/DoorLintel", "fixtures/RoomDoor", "TripoProps/Conduits"]
const TUBE_ENERGY := 1.2
## D-104: inside the room the night and the lit tube look like the approved pilot
## (previews/room_centre_torch_after.png, room_centre_tube_after.png); the corridor keeps floor 4's night.
const INSIDE := AABB(Vector3(0.1, -0.5, -6.95), Vector3(7.8, 4.0, 6.95))
const ROOM_ENVIRONMENT := {"ambient_light_color": Color(0.48, 0.57, 0.7), "ambient_light_energy": 0.06,
	"fog_light_color": Color(0.25, 0.30, 0.36), "fog_density": 0.004}
const ROOM_TORCH := {"light_energy": 5.0, "spot_angle": 38.0, "spot_angle_attenuation": 1.3,
	"spot_range": 10.0, "light_size": 0.025}
const TUBE_LIGHT := {"light_color": Color(0.88, 0.94, 0.80), "omni_range": 9.0, "light_size": 0.25,
	"shadow_enabled": true, "flicker_energy": 2.6}
## Seconds to blend between the corridor and the room look at the door.
const BLEND_TIME := 0.35
## D-105: planar mirrors (mirror.gd) on the glass of the furnished mirrors, in model space:
## glass centre, size, yaw of its outward normal (both models face their glass to -Z) and the
## angle in radians the glass leans back (about 1 degree; measured by ray casts on the models).
const MIRROR := preload("res://scenes/levels/mirror.tscn")
const MIRROR_SHADER := preload("res://rendering/mirror_surface_hd.gdshader")
const MIRROR_GLASS := {
	"MirrorSmall": {"centre": Vector3(0.0, 0.289, 0.037), "size": Vector2(0.38, 0.448), "yaw": PI, "lean": 0.017},
	"FullMirror": {"centre": Vector3(0.0, 0.604, -0.072), "size": Vector2(0.384, 1.146), "yaw": deg_to_rad(166.8),
		"lean": 0.022},
}
## Reflection texels per metre of glass, capped so the tall mirror stays cheap.
const MIRROR_TEXELS := 1000.0
const MIRROR_MAX_TEXELS := 800
var _furnished: Node3D
var _tubes: Array[StandardMaterial3D] = []
var _trung_blanket: Node3D
var _inside_weight: float = 0.0
var _environment: Environment
var _torch: SpotLight3D
var _mirrors: Array[Node3D] = []


func _ready() -> void:
	# The chapter-2 screen replaces the mixer; the physical pipe stays in place.
	$Extension/ShowerMixer.visible = false
	_apply_surface($Floor/Mesh, preload("res://assets/textures/room407/room_tile.png"), Vector2(20, 12))
	for node in [$WestWall/Mesh, $EastWall/Mesh]:
		_apply_surface(node, preload("res://assets/textures/room407/room_wall.png"), Vector2(2, 1))
	for net in [$BunkA/Net_Phuc, $BunkA/Net_Viet, $BunkB/Net_Dat, $BunkB/Net_Trung]:
		PropTint.apply(net, Color(.58, .62, .58))
	if furnished:
		_furnish()
	set_blood_stage(blood_stage)
	set_slashed(slashed_amount)


func _apply_surface(mesh: MeshInstance3D, texture: Texture2D, uv_scale: Vector2) -> void:
	var material := ShaderMaterial.new()
	material.shader = SURFACE
	material.set_shader_parameter("albedo_texture", texture)
	material.set_shader_parameter("uv_scale", uv_scale)
	mesh.material_override = material


func set_blood_stage(stage: int) -> void:
	blood_stage = clampi(stage, 0, 2)
	if not is_node_ready():
		return
	$Details/BloodSeep.visible = blood_stage >= 1
	$Details/BloodPools.visible = blood_stage >= 2
	for number in [1, 2, 4]:
		var body := get_node_or_null("Anchors/Corpse%d/Body" % number)
		if body:
			body.set_blood_visible(blood_stage > 0)
	_drip_time = 0.0


func set_slashed(amount: float) -> void:
	slashed_amount = clampf(amount, 0.0, 1.0) if is_finite(amount) else 0.0
	if not is_node_ready():
		return
	var count := ceili(slashed_amount * 8.0)
	for i in range(8):
		var section := get_node("Details/TrungBedding/Section%d" % i) as Node3D
		section.visible = i >= count
		(get_node("Details/SlashRips/Rip%d" % i) as Node3D).visible = i < count
		(get_node("Details/Debris/Scrap%d" % i) as Node3D).visible = i < count
	$Details/SlashRips.visible = count > 0
	$Details/Debris.visible = count > 0
	$Details/TrungPillow.visible = slashed_amount < 1.0
	if _trung_blanket:
		_trung_blanket.visible = count == 0


func set_flicker(value: bool) -> void:
	$Room407MainLight.set_flicker(value)
	$Room407DeskLamp.set_flicker(value)


func set_bathroom_door_open(value: bool) -> void:
	$Extension/BathroomDoor.set_open(value)


func set_stuck_shake(strength: float) -> void:
	$Extension/BathroomDoor.set_stuck_shake(strength)


func set_water(on: bool, temperature: int) -> void:
	$Ch2Bathroom.set_water(on, temperature)


func set_steam(level: float) -> void:
	$Ch2Bathroom.set_steam(level)


func flash_reflection() -> void:
	$Ch2Bathroom.flash_reflection()


func set_desk_lamp(value: bool) -> void:
	desk_lamp_on = value
	$Room407DeskLamp.set_flicker(false)
	$Room407DeskLamp.light_energy = .5 if value else 0.0
	$Room407DeskLamp.visible = true


func set_plugged(cable_id: StringName, value: bool) -> bool:
	return $Cables.set_plugged(cable_id,value)


func _process(delta: float) -> void:
	if _furnished:
		_blend_room_lighting(delta)
		_update_mirror_follow()
	if not _tubes.is_empty():
		var light := $Room407MainLight as Light3D
		var glow := TUBE_ENERGY * clampf(light.light_energy, 0.0, 1.0) if light.is_visible_in_tree() else 0.0
		for material in _tubes:
			material.emission_energy_multiplier = glow
	if blood_stage == 0:
		return
	_drip_time += delta
	for number in [1, 2, 4]:
		var drop := get_node("Details/BloodSeep/Droplet%d" % number) as Node3D
		var top := 1.45 if number != 2 else .68
		drop.position.y = lerpf(top, .03, fmod(_drip_time * .7 + number * .27, 1.0))


## T-215: build the D-102 room, hide the PS1 meshes it replaces and hang its moving parts on
## the old nodes so every script, tween and story state keeps driving them.
func _furnish() -> void:
	_furnished = Room407Furnish.build()
	add_child(_furnished)
	for mesh: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
		if _furnished.is_ancestor_of(mesh):
			continue
		var path := String(get_path_to(mesh))
		if not _matches(path, KEEP_PS1) or _matches(path, REPLACED_PS1):
			mesh.visible = false
	var props := _furnished.get_node("TripoProps")
	for path: String in DOOR_WALL_PARTS:
		(_furnished.get_node(path) as Node3D).position.z += DOOR_WALL_SHIFT
	for prop: Node3D in props.get_children():
		var row: Dictionary = prop.get_meta(&"placement")
		if row.get("mount", "") == "wall" and row.position[2] > -0.05:
			prop.position.z += DOOR_WALL_SHIFT
	for decal: Node3D in _furnished.get_node("Decals").get_children():
		if decal.get_meta(&"placement").project == "+z":
			decal.position.z += DOOR_WALL_SHIFT
	for prop_name: String in FOLLOW:
		_carry(props.get_node(prop_name), get_node(FOLLOW[prop_name]))
	# Viet's locker: the body stays, the door swings on hinged.gd's Pivot moved to the model's hinge.
	var locker := props.get_node("LockerViet") as Node3D
	var door_pivot := locker.find_child("DoorPivot", true, false) as Node3D
	var anchor_pivot := $Anchors/VietLocker/Pivot as Node3D
	var angle := anchor_pivot.rotation.y
	anchor_pivot.rotation.y = 0.0
	anchor_pivot.global_position = door_pivot.global_position
	for door: Node in door_pivot.get_children():
		# "Door" is already the PS1 door's collision body under the anchor's Pivot.
		door.name = "Furnished" + door.name
		_carry(door as Node3D, anchor_pivot)
	anchor_pivot.rotation.y = angle
	var bath_pivot := $Extension/BathroomDoor/Pivot as Node3D
	angle = bath_pivot.rotation.y
	bath_pivot.rotation.y = 0.0
	_carry(_furnished.get_node("fixtures/BathroomDoor"), bath_pivot)
	bath_pivot.rotation.y = angle
	_fit_mirror_effects(props.get_node("MirrorSmall"))
	_trung_blanket = props.get_node("BlanketTrung")
	_tubes = Room407Furnish.tube_materials(_furnished)
	for property: String in TUBE_LIGHT:
		$Room407MainLight.set(property, TUBE_LIGHT[property])
	for prop_name: String in MIRROR_GLASS:
		_hang_mirror(props.get_node(prop_name), MIRROR_GLASS[prop_name])


## D-105: a mirror.gd reflection on the model's glass, 4 mm in front of it, rendered only
## while the player is in the room, in front of the glass and looking at it.
func _hang_mirror(model: Node3D, glass: Dictionary) -> void:
	var basis := Basis(Vector3.UP, glass.yaw) * Basis(Vector3.RIGHT, -glass.lean)
	var pose := model.global_transform * Transform3D(basis, glass.centre + basis.z * 0.004)
	var mirror := MIRROR.instantiate() as Node3D
	mirror.name = "Reflective" + model.name
	var size: Vector2 = glass.size * pose.basis.get_scale().x
	mirror.mirror_size = size
	mirror.room_bounds = INSIDE
	mirror.require_in_view = true
	(mirror.get_node("Frame") as Node3D).visible = false
	var surface := mirror.get_node("Surface") as MeshInstance3D
	var quad := QuadMesh.new()
	quad.size = size
	surface.mesh = quad
	var material := ShaderMaterial.new()
	material.shader = MIRROR_SHADER
	surface.material_override = material
	var texels := minf(MIRROR_TEXELS, MIRROR_MAX_TEXELS / maxf(size.x, size.y))
	(mirror.get_node("ReflectionViewport") as SubViewport).size = Vector2i(roundi(size.x * texels), roundi(size.y * texels))
	add_child(mirror)
	mirror.global_transform = Transform3D(pose.basis.orthonormalized(), pose.origin)
	_mirrors.append(mirror)


## The mirrors reflect the body that carries the current camera as Head/Camera3D (the player).
func _update_mirror_follow() -> void:
	var camera := get_viewport().get_camera_3d()
	var head := camera.get_parent() if camera else null
	var body := head.get_parent() as Node3D if head and head.name == &"Head" else null
	for mirror in _mirrors:
		if mirror.follow != body:
			mirror.follow = body


func _exit_tree() -> void:
	# Floor 4's Environment is shared by every instance of the scene: hand it back untouched.
	_apply_room_lighting(0.0)
	_environment = null
	_torch = null


## Blends the world environment and the phone torch (any "Flashlight" under the camera)
## toward ROOM_ENVIRONMENT / ROOM_TORCH while the camera is inside the room.
func _blend_room_lighting(delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	var inside := camera != null and INSIDE.has_point(to_local(camera.global_position))
	var weight := move_toward(_inside_weight, 1.0 if inside else 0.0, delta / BLEND_TIME)
	var world := get_viewport().find_world_3d()
	var environment := world.environment if world else null
	var torch := camera.find_child("Flashlight", true, false) as SpotLight3D if camera else null
	if environment != _environment or torch != _torch:
		_apply_room_lighting(0.0)
		_environment = environment
		_torch = torch
	elif weight == _inside_weight:
		return
	_inside_weight = weight
	_apply_room_lighting(weight)


func _apply_room_lighting(weight: float) -> void:
	if is_instance_valid(_environment):
		_blend(_environment, ROOM_ENVIRONMENT, weight)
		var room := weight > 0.5
		_environment.ssao_enabled = room or _environment.get_meta(&"outside_ssao")
		_environment.ssao_radius = 0.35 if room else _environment.get_meta(&"outside_ssao_radius")
	if is_instance_valid(_torch):
		_blend(_torch, ROOM_TORCH, weight)


## Lerps target's properties from their own values (kept in meta on first use) toward room.
static func _blend(target: Object, room: Dictionary, weight: float) -> void:
	if not target.has_meta(&"outside_lighting"):
		var outside := {}
		for property: String in room:
			outside[property] = target.get(property)
		target.set_meta(&"outside_lighting", outside)
		if target is Environment:
			target.set_meta(&"outside_ssao", (target as Environment).ssao_enabled)
			target.set_meta(&"outside_ssao_radius", (target as Environment).ssao_radius)
	var outside: Dictionary = target.get_meta(&"outside_lighting")
	for property: String in room:
		target.set(property, lerp(outside[property], room[property], weight))


## Chapter 2's fog sheet and manager reflection were sized for the PS1 mirror (0.5 x 0.65 m,
## centre y 1.55): fit them to the furnished mirror with the same proportions.
func _fit_mirror_effects(mirror: Node3D) -> void:
	var glass: AABB = mirror.transform * Room407Furnish.local_bounds(mirror)
	var scale_y := glass.size.y / 0.65
	var fog := $Ch2Bathroom/MirrorFog as Node3D
	fog.position = Vector3(glass.end.x + 0.01, glass.get_center().y, glass.get_center().z)
	fog.scale = Vector3(glass.size.z / 0.5, scale_y, 1.0)
	var reflection := $Ch2Bathroom/Reflection as Node3D
	reflection.position = Vector3(glass.end.x + 0.025, glass.position.y + 0.035 * scale_y, glass.get_center().z)
	reflection.scale = Vector3(0.26 * scale_y, 0.26 * scale_y, 0.025)


## The room door leaf of the shell, for floor4.gd to hang on Door407 (null without the furnished room).
func furnished_room_door() -> Node3D:
	return _furnished.get_node_or_null("fixtures/RoomDoor") as Node3D if _furnished else null


func _carry(node: Node3D, holder: Node3D) -> void:
	node.set_meta(&"furnished", true)
	var pose := node.global_transform
	node.get_parent().remove_child(node)
	holder.add_child(node)
	node.global_transform = pose


static func _matches(path: String, patterns: Array[String]) -> bool:
	for pattern in patterns:
		if path == pattern or path.begins_with(pattern + "/") or path.match(pattern) or path.match(pattern + "/*"):
			return true
	return false
