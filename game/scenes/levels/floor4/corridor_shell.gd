class_name Floor4CorridorShell
extends RefCounted
## T-237 (D-148): the whole floor-4 corridor in room 407's style (T-235, D-144), built by floor4.gd for every
## chapter and by its pilot scene (corridor_g5_pilot.gd) from this one code. Visual only: every PS1 mesh it
## replaces is hidden, never freed, and no collider, marker, light or navigation node is moved, renamed or added
## (gameplay contract: art_source/graphics_upgrade/floor4_corridor/PLAN.md section 2).
## The playable corridor has the owner's picks only: aluminium room plates (A) and the old 408 doorway walled up
## (style 1); the pilot adds the other variants on top (add_part).
## Sources: art_source/graphics_upgrade/floor4_corridor/.

const MODELS := "res://assets/models/graphics_pilot/floor4_corridor/corridor_"
const MASKS := "res://assets/textures/graphics_pilot/floor4_corridor/"
const SHELL_SHADER := preload("res://rendering/room407_shell.gdshader")
const SHELL_TEX := Room407Furnish.SHELL_TEX
const CORNER := "res://assets/models/graphics_pilot/room407_corner/"
const PLASTER := CORNER + "architecture_painted_plaster_wall_"
const FRAME_SCAN := "res://assets/models/graphics_pilot/room407_shell/frames_distressed_painted_planks_"
const WOOD := CORNER + "study_desk_wood_table_worn_"
const DOOR := "res://assets/models/graphics_pilot/room407_shell/doors/door_room.glb"
const LEVER := "res://assets/models/graphics_pilot/room407_shell/doors/door_lever.glb"
## Node floor4 gets (at its origin); the pieces hung elsewhere under floor 4 are named G5* too.
const ROOT := "G5Corridor"
## What the playable corridor shows (D-148). The walled-up 408 doorway is part of the shell.
const PARTS: Array[String] = ["shell", "frames", "lamps", "railing", "plates_alu"]
## Rooms whose RoomDoor gets room 407's Tripo leaf (407 keeps its own Door407).
const ROOM_DOORS: Array[String] = ["401", "402", "403", "404", "405", "406", "408"]
## The plaster end walls hang under the caps, so Campus (which hides the caps to open the stairs) hides them too.
const END_CAPS := {"EndWest": "Corridor/WestEnd", "EndEast": "Corridor/EastEnd"}
## PS1 meshes the corridor replaces (their colliders stay): every kit piece of the room wall, the plates, rail
## bars, lamp boxes and leaves, the slabs, rails and caps, the old 408 panel and the washroom entrance's wall.
const REPLACED_PREFIXES: Array[String] = ["Doorway_", "Facade_", "RoomPlate_", "RailBar_"]
const REPLACED: Array[String] = ["Corridor/Former408Wall", "Corridor/Room408FrontWest", "Corridor/Sealed408",
	"Corridor/Floor/Mesh", "Corridor/Roof/Mesh", "Corridor/RailingTop/Mesh", "Corridor/RailingLow/Mesh",
	"Corridor/WestEnd/Mesh", "Corridor/EastEnd/Mesh", "Washroom/EntranceWest", "Washroom/EntranceEast",
	"Washroom/EntranceLintel"]
## Room 407's Tripo leaf (corridor_layout.py LEAF): its foot centre from the hinge, the levers like room 407's.
const LEAF_FROM_HINGE := Vector3(-0.445, -0.01, -0.025)
const LEVER_ROSE := Vector3(-0.38, 1.05, 0.02)
## Same lever size as Door407 (floor4.gd LEVER_SCALE, D-133): the leaf sits as deep in the wall.
const LEVER_SCALE := 1.4
## Shader looks of the Corr* placeholder materials (build_corridor.py), room 407's shell shader and scans.
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
	"CorrPlateAlu": {"albedo": SHELL_TEX + "aluminium_color.jpg", "orm": SHELL_TEX + "aluminium_arm.jpg",
		"color": Color(0.92, 0.92, 0.9)},
	"CorrPlateInk": {"color": Color(0.035, 0.035, 0.035), "roughness": 0.55},
	"CorrPlateEnamel": {"color": Color(0.06, 0.16, 0.38), "roughness": 0.22},
	"CorrPlatePrint": {"color": Color(0.86, 0.86, 0.82), "roughness": 0.3},
	"CorrScrew": {"color": Color(0.5, 0.5, 0.48), "roughness": 0.4, "metallic": 1.0},
	"CorrBoard": {"albedo": WOOD + "color.jpg", "normal": WOOD + "normal.jpg", "orm": WOOD + "arm.jpg",
		"color": Color(1.0, 0.96, 0.9), "normal_scale": 0.8},
}


## Adds node G5Corridor to floor4 (at its origin) and swaps the corridor's PS1 visuals for it; floor4 must be in
## the tree. A floor that already has it keeps it (the pilot and captures run over a floor that built it).
static func build(floor4: Node3D) -> Node3D:
	var existing := floor4.get_node_or_null(ROOT) as Node3D
	if existing != null:
		return existing
	var root := Node3D.new()
	root.name = ROOT
	floor4.add_child(root)
	for part: String in PARTS:
		add_part(root, part)
	var added: Array[Node3D] = []
	var ends := (load(MODELS + "ends.glb") as PackedScene).instantiate() as Node3D
	root.add_child(ends)
	for end: String in END_CAPS:
		var wall := ends.get_node(end) as Node3D
		wall.reparent(floor4.get_node(END_CAPS[end]), true)
		wall.name = "G5" + end
		_prepare(wall as MeshInstance3D)
		added.append(wall)
	ends.free()
	var ps1: Array[Node3D] = []
	var corridor := floor4.get_node("Corridor")
	for child: Node in corridor.get_children():
		if REPLACED_PREFIXES.any(func(prefix: String) -> bool: return String(child.name).begins_with(prefix)):
			ps1.append_array(_meshes(child))
		elif String(child.name).begins_with("CorridorLight_"):
			ps1.append_array(_meshes(child.get_node("Fixture")))
	for path: String in REPLACED:
		ps1.append_array(_meshes(floor4.get_node(path)))
	for room: String in ROOM_DOORS:
		ps1.append_array(_meshes(corridor.get_node("LockedDoor_%s/Hinge/Leaf" % room)))
		added.append(_hang_leaf(floor4, room))
	root.set_meta(&"ps1", ps1)
	root.set_meta(&"added", added)
	var sync := TubeSync.new()
	sync.name = "TubeSync"
	root.add_child(sync)
	for lamp: Node in root.get_node("lamps").get_children():
		var light := corridor.get_node(String(lamp.name).trim_prefix("Lamp_")) as Light3D
		sync.add_lamp(light, lamp as MeshInstance3D)
	set_upgraded(floor4, true)
	return root


## One corridor_<part>.glb under the corridor root, in its looks; returns it.
static func add_part(root: Node3D, part: String) -> Node3D:
	var model := (load(MODELS + part + ".glb") as PackedScene).instantiate() as Node3D
	model.name = part
	root.add_child(model)
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		_prepare(mesh)
	return model


## true: the new corridor; false: the PS1 corridor as floor4.tscn draws it (before/after captures, pilot key G).
static func set_upgraded(floor4: Node3D, on: bool) -> void:
	var root := floor4.get_node(ROOT) as Node3D
	root.visible = on
	for node: Node3D in root.get_meta(&"ps1"):
		node.visible = not on
	for node: Node3D in root.get_meta(&"added"):
		node.visible = on


static func _meshes(node: Node) -> Array[Node3D]:
	var found: Array[Node3D] = []
	if node is MeshInstance3D:
		found.append(node as Node3D)
	for mesh: Node in node.find_children("*", "MeshInstance3D", true, false):
		found.append(mesh as Node3D)
	return found


static func _prepare(mesh: MeshInstance3D) -> void:
	mesh.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	for surface in mesh.mesh.get_surface_count():
		var source := mesh.mesh.surface_get_material(surface)
		if source == null:
			continue
		var look_name := source.resource_name
		if SHELL_LOOKS.has(look_name):
			mesh.set_surface_override_material(surface, _shell_material(look_name))
		elif LOOKS.has(look_name):
			mesh.set_surface_override_material(surface, _material(look_name))
	if mesh.find_parent("lamps") != null:
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


## Room 407's Tripo leaf and levers on a RoomDoor's hinge, so RoomDoor.set_open() swings them (out, +90 degrees).
static func _hang_leaf(floor4: Node3D, room: String) -> Node3D:
	var hinge := floor4.get_node("Corridor/LockedDoor_%s/Hinge" % room) as Node3D
	var angle := hinge.rotation.y
	hinge.rotation.y = 0.0
	var leaf := (load(DOOR) as PackedScene).instantiate() as Node3D
	leaf.name = "G5Leaf"
	hinge.add_child(leaf)
	var foot := floor4.to_local(hinge.global_position) + LEAF_FROM_HINGE
	leaf.global_transform = Transform3D(floor4.global_basis, floor4.to_global(foot))
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


## Keeps each batten's tubes glowing with its corridor light (on, off, flickering).
class TubeSync extends Node:
	var lamps: Array = []

	func add_lamp(light: Light3D, batten: MeshInstance3D) -> void:
		var material := StandardMaterial3D.new()
		material.resource_name = "CorrTubeGlow"
		material.albedo_color = Color(0.92, 0.94, 0.9)
		material.roughness = 0.25
		material.emission_enabled = true
		material.emission = Room407Furnish.TUBE_COLOR
		for surface in batten.mesh.get_surface_count():
			var source := batten.mesh.surface_get_material(surface)
			if source != null and source.resource_name == "CorrTubeGlass":
				batten.set_surface_override_material(surface, material)
		lamps.append([light, material, maxf(light.light_energy, 0.001)])
		_update()

	func _process(_delta: float) -> void:
		_update()

	func _update() -> void:
		for lamp: Array in lamps:
			var light := lamp[0] as Light3D
			var on := light.is_visible_in_tree() and light.light_energy > 0.0
			(lamp[1] as StandardMaterial3D).emission_energy_multiplier = light.light_energy / lamp[2] if on else 0.0
