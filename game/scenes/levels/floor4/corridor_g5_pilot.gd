extends Node3D
## T-233 (D-142, option A): the floor-4 corridor pilot segment around doors 406 and 407 in room 407's style,
## built over an untouched Floor4 (floor4.tscn). Visual only: every PS1 mesh it replaces is hidden, never
## freed, and no collider, marker, light or navigation node is moved, renamed or added.
## Walk it with the player; G switches between the segment and the PS1 corridor, R between the two
## railings (dense balusters / the PS1 rhythm). Sources: art_source/graphics_upgrade/floor4_corridor/.

const SEGMENT := "res://assets/models/graphics_pilot/floor4_corridor/"
const MASKS := "res://assets/textures/graphics_pilot/floor4_corridor/"
const SHELL_SHADER := preload("res://rendering/room407_shell.gdshader")
const SHELL_TEX := Room407Furnish.SHELL_TEX
const CORNER := "res://assets/models/graphics_pilot/room407_corner/"
const PLASTER := CORNER + "architecture_painted_plaster_wall_"
const FRAME_SCAN := "res://assets/models/graphics_pilot/room407_shell/frames_distressed_painted_planks_"
const DOOR := "res://assets/models/graphics_pilot/room407_shell/doors/door_room.glb"
const LEVER := "res://assets/models/graphics_pilot/room407_shell/doors/door_lever.glb"
## The segment (segment_layout.py X0, X1): Floor4 x 26..34, the whole width of the corridor.
const X_RANGE := Vector2(26.0, 34.0)
const CORRIDOR_LENGTH := 44.0
const PARTS: Array[String] = ["shell", "frames", "lamps", "railing_dense", "railing_classic"]
## PS1 meshes of the segment, hidden (their colliders stay): the room wall's kit pieces, the lamp boxes
## and 406's PS1 leaf. Rail bars are found by position; the 44 m floor, roof and rails are split.
const REPLACED: Array[String] = ["Corridor/Facade_406_W", "Corridor/Doorway_406", "Corridor/Facade_406_E",
	"Corridor/Facade_407_W", "Corridor/Doorway_407", "Corridor/Facade_407_E",
	"Corridor/CorridorLight_406/Fixture", "Corridor/CorridorLight_407/Fixture", "Corridor/LockedDoor_406/Hinge/Leaf"]
const SPLIT: Array[String] = ["Corridor/Floor/Mesh", "Corridor/Roof/Mesh", "Corridor/RailingTop/Mesh",
	"Corridor/RailingLow/Mesh"]
## Each tube batten glows with the corridor light above it (story_director flickers and kills them).
const LAMP_LIGHTS := {"Lamp0": "Corridor/CorridorLight_406", "Lamp1": "Corridor/CorridorLight_407"}
## 406's Tripo leaf (segment_layout.py LEAF_406): Floor4 centre of its foot, the levers like room 407's.
const LEAF_406_CENTRE := Vector3(27.995, 0.0, -0.025)
const LEVER_ROSE := Vector3(-0.38, 1.05, 0.02)
## Same lever size as Door407 (floor4.gd LEVER_SCALE, D-133): the leaf sits as deep in the wall.
const LEVER_SCALE := 1.4
## Shader looks of the Corr* placeholder materials (build_segment.py), room 407's shell shader and scans.
## The wall is room 407's cream plaster, a little greyer (option A: kem xam).
const SHELL_LOOKS := {
	"CorrWall": {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg",
		"base_arm": PLASTER + "arm.jpg", "mask": MASKS + "mask_walls.png", "peel": true,
		"base_tint": Color(0.9, 0.88, 0.82), "grime_strength": 1.4, "stain_strength": 1.2},
	"CorrCeiling": {"kind": 0, "base_albedo": PLASTER + "cream_color.jpg", "base_normal": PLASTER + "normal.jpg",
		"base_arm": PLASTER + "arm.jpg", "mask": MASKS + "mask_ceiling.png", "peel": true,
		"base_tint": Color(0.95, 0.94, 0.88), "normal_strength": 0.5, "grime_strength": 1.3, "stain_strength": 1.2},
	"CorrFloor": {"kind": 1, "base_albedo": SHELL_TEX + "floor_tiles_08_color.jpg",
		"base_normal": SHELL_TEX + "floor_tiles_08_normal.jpg", "base_arm": SHELL_TEX + "floor_tiles_08_arm.jpg",
		"mask": MASKS + "mask_floor.png", "grime_strength": 1.4, "grout_strength": 1.2},
	"CorrSkirting": {"kind": 1, "base_albedo": SHELL_TEX + "floor_tiles_08_color.jpg",
		"base_normal": SHELL_TEX + "floor_tiles_08_normal.jpg", "base_arm": SHELL_TEX + "floor_tiles_08_arm.jpg",
		"mask": MASKS + "mask_floor.png"},
}
## The other Corr* materials: CC0 scans already in the game (no copies) or plain paint.
const LOOKS := {
	"CorrFrameGreen": {"albedo": SHELL_TEX + "frame_green_color.jpg", "normal": FRAME_SCAN + "normal.jpg",
		"orm": FRAME_SCAN + "arm.jpg", "normal_scale": 0.6},
	"CorrGranite": {"albedo": SHELL_TEX + "granite_color.jpg", "orm": SHELL_TEX + "granite_arm.jpg"},
	"CorrRailSteel": {"albedo": CORNER + "fixtures_green_metal_rust_color.jpg",
		"normal": CORNER + "fixtures_green_metal_rust_normal.jpg", "orm": CORNER + "fixtures_green_metal_rust_arm.jpg",
		"normal_scale": 0.6},
	"CorrHinge": {"color": Color(0.32, 0.31, 0.29), "roughness": 0.45, "metallic": 1.0},
	"CorrEnamel": {"color": Color(0.78, 0.75, 0.64), "roughness": 0.42},
	"CorrTubeGlass": {"color": Color(0.92, 0.94, 0.9), "roughness": 0.25},
	"CorrTubeCap": {"color": Color(0.55, 0.55, 0.52), "roughness": 0.4, "metallic": 1.0},
}

@export var start_upgraded := true
var floor4: Node3D
var segment: Node3D


func _ready() -> void:
	floor4 = $Floor4
	segment = build(floor4)
	set_upgraded(floor4, start_upgraded)


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode == KEY_G:
		set_upgraded(floor4, not segment.visible)
	elif key.keycode == KEY_R:
		set_railing(floor4, "classic" if (segment.get_node("railing_dense") as Node3D).visible else "dense")


## Adds node "G5Segment" to floor4 (at its origin) and swaps the segment's PS1 visuals for it.
static func build(floor4: Node3D) -> Node3D:
	var root := Node3D.new()
	root.name = "G5Segment"
	floor4.add_child(root)
	for part: String in PARTS:
		var model := (load(SEGMENT + "segment_%s.glb" % part) as PackedScene).instantiate() as Node3D
		model.name = part
		root.add_child(model)
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		mesh.gi_mode = GeometryInstance3D.GI_MODE_STATIC
		_apply_looks(mesh)
	var ps1: Array[Node3D] = []
	var added: Array[Node3D] = []
	for path: String in REPLACED:
		for mesh: Node in floor4.get_node(path).find_children("*", "MeshInstance3D", true, false):
			ps1.append(mesh as Node3D)
	for bar: Node in floor4.get_node("Corridor").find_children("RailBar_*", "Node3D", false, false):
		var x := (bar as Node3D).global_position.x - floor4.global_position.x
		if x >= X_RANGE.x - 0.01 and x <= X_RANGE.y + 0.01:
			ps1.append(bar.get_node("Mesh") as Node3D)
	for path: String in SPLIT:
		var mesh := floor4.get_node(path) as MeshInstance3D
		ps1.append(mesh)
		added.append_array(_split(mesh))
	added.append(_hang_leaf_406(floor4))
	root.set_meta(&"ps1", ps1)
	root.set_meta(&"added", added)
	var sync := TubeSync.new()
	sync.name = "TubeSync"
	root.add_child(sync)
	for lamp: String in LAMP_LIGHTS:
		var tubes: Array[MeshInstance3D] = []
		for mesh: Node in root.get_node("lamps").find_children("FluorescentTube*", "MeshInstance3D", true, false):
			if absf((mesh as Node3D).global_position.x - (floor4.get_node(LAMP_LIGHTS[lamp]) as Node3D).global_position.x) < 0.7:
				tubes.append(mesh as MeshInstance3D)
		sync.add_lamp(floor4.get_node(LAMP_LIGHTS[lamp]) as Light3D, tubes)
	set_railing(floor4, "dense")
	set_upgraded(floor4, true)
	return root


## true: the segment; false: the PS1 corridor as floor4.tscn draws it (for before/after captures).
static func set_upgraded(floor4: Node3D, on: bool) -> void:
	var root := floor4.get_node("G5Segment") as Node3D
	root.visible = on
	for node: Node3D in root.get_meta(&"ps1"):
		node.visible = not on
	for node: Node3D in root.get_meta(&"added"):
		node.visible = on


## "dense": balusters every 12.5 cm (pilot default); "classic": the PS1 rhythm of one every 0.5 m.
static func set_railing(floor4: Node3D, variant: String) -> void:
	var root := floor4.get_node("G5Segment")
	(root.get_node("railing_dense") as Node3D).visible = variant == "dense"
	(root.get_node("railing_classic") as Node3D).visible = variant == "classic"


static func _apply_looks(mesh: MeshInstance3D) -> void:
	for surface in mesh.mesh.get_surface_count():
		var source := mesh.mesh.surface_get_material(surface)
		if source == null:
			continue
		var look_name := source.resource_name
		if SHELL_LOOKS.has(look_name):
			mesh.set_surface_override_material(surface, _shell_material(look_name))
		elif LOOKS.has(look_name):
			mesh.set_surface_override_material(surface, _material(look_name))
	if String(mesh.name).begins_with("FluorescentTube") or mesh.find_parent("lamps") != null:
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


static func _shell_material(look_name: String) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = SHELL_SHADER
	var parameters: Dictionary = SHELL_LOOKS[look_name].duplicate()
	if parameters.get("peel", false):
		parameters.merge(Room407Furnish.PEEL)
	parameters.erase("peel")
	parameters["noise"] = SHELL_TEX + "noise.png"
	for parameter: String in parameters:
		var value: Variant = parameters[parameter]
		material.set_shader_parameter(parameter, load(value) if value is String else value)
	return material


static func _material(look_name: String) -> BaseMaterial3D:
	var look: Dictionary = LOOKS[look_name]
	var material := ORMMaterial3D.new()
	material.resource_name = look_name
	material.albedo_color = look.get("color", Color.WHITE)
	material.roughness = look.get("roughness", 1.0)
	material.metallic = look.get("metallic", 0.0)
	if look.has("albedo"):
		material.albedo_texture = load(look.albedo)
	if look.has("orm"):
		material.orm_texture = load(look.orm)
	if look.has("normal"):
		material.normal_enabled = true
		material.normal_texture = load(look.normal)
		material.normal_scale = look.get("normal_scale", 1.0)
	return material


## Two copies of a 44 m PS1 box mesh outside the segment; the original is hidden while the segment shows.
static func _split(mesh: MeshInstance3D) -> Array[Node3D]:
	var box := mesh.mesh as BoxMesh
	var pieces: Array[Node3D] = []
	var start := mesh.position.x - box.size.x / 2.0
	var parent := mesh.get_parent() as Node3D
	var x0 := X_RANGE.x - parent.position.x
	var x1 := X_RANGE.y - parent.position.x
	for span: Vector2 in [Vector2(start, x0), Vector2(x1, start + CORRIDOR_LENGTH)]:
		var piece := MeshInstance3D.new()
		piece.name = "G5" + String(mesh.name) + ("West" if span.x == start else "East")
		var part := box.duplicate() as BoxMesh
		part.size.x = span.y - span.x
		piece.mesh = part
		piece.material_override = mesh.material_override
		piece.position = Vector3((span.x + span.y) / 2.0, mesh.position.y, mesh.position.z)
		parent.add_child(piece)
		pieces.append(piece)
	return pieces


## Room 407's Tripo leaf and levers on 406's hinge, so RoomDoor.set_open() swings them (out, +90 degrees).
static func _hang_leaf_406(floor4: Node3D) -> Node3D:
	var hinge := floor4.get_node("Corridor/LockedDoor_406/Hinge") as Node3D
	var angle := hinge.rotation.y
	hinge.rotation.y = 0.0
	var leaf := (load(DOOR) as PackedScene).instantiate() as Node3D
	leaf.name = "G5Leaf"
	hinge.add_child(leaf)
	leaf.global_transform = Transform3D(floor4.global_basis, floor4.to_global(LEAF_406_CENTRE))
	var lever_scene := load(LEVER) as PackedScene
	for side: float in [-1.0, 1.0]:
		# Lever axes (room407_shell build_shell.py place_lever): X the bar toward the hinges, Z out of the face.
		var out := Vector3(0, 0, side)
		var bar := Vector3.RIGHT
		var lever := lever_scene.instantiate() as Node3D
		lever.name = "LeverCorridor" if side > 0.0 else "LeverRoom"
		leaf.add_child(lever)
		lever.transform = Transform3D(Basis(bar, out.cross(bar), out).scaled(Vector3.ONE * LEVER_SCALE),
			Vector3(LEVER_ROSE.x, LEVER_ROSE.y, LEVER_ROSE.z * side))
	for mesh: MeshInstance3D in leaf.find_children("*", "MeshInstance3D", true, false):
		mesh.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	hinge.rotation.y = angle
	return leaf


## Keeps each tube batten's glow with its corridor light (on, off, flickering).
class TubeSync extends Node:
	var lamps: Array = []

	func add_lamp(light: Light3D, tubes: Array[MeshInstance3D]) -> void:
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.92, 0.94, 0.9)
		material.roughness = 0.25
		material.emission_enabled = true
		material.emission = Room407Furnish.TUBE_COLOR
		for tube: MeshInstance3D in tubes:
			tube.material_override = material
		lamps.append([light, material, maxf(light.light_energy, 0.001)])
		_update()

	func _process(_delta: float) -> void:
		_update()

	func _update() -> void:
		for lamp: Array in lamps:
			var light := lamp[0] as Light3D
			var on := light.is_visible_in_tree() and light.light_energy > 0.0
			(lamp[1] as StandardMaterial3D).emission_energy_multiplier = light.light_energy / lamp[2] if on else 0.0
