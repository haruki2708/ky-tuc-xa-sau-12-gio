extends TestCase
## T-138 props: budgets, PS1 materials, scene APIs and the floor 4 contract.

const PROPS := {
	"desk": 1500, "hall_board": 1500, "sink": 1500, "stall_front": 1500,
	"desk_lamp": 500, "telephone": 500, "desk_items": 500, "tap": 500,
	"slippers_pair": 500, "shirt": 500, "towel": 500, "bucket": 500, "pa_horn": 500,
}
const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
## Nodes other lanes' code relies on (T-138 card, item 4).
const KEPT_NODES: Array[String] = [
	"Corridor/CorridorLight_401", "Corridor/CorridorLight_405", "Corridor/CorridorLight_408",
	"Corridor/CorridorLight_Desk", "Room407/Room407MainLight", "Room407/BunkA/Net_Phuc",
	"Room407/BunkA/Net_Viet", "Room407/BunkB/Net_Trung", "Room407/BunkB/Net_Dat",
	"Washroom/Mirror", "Door407/Pivot/RulesPaper", "Anchors/WashroomTapRunning",
	"Anchors/Slippers407", "Anchors/ClotheslineExtraShirt", "Anchors/HallBoard", "Anchors/DutyLog",
]


func _triangles(node: Node) -> int:
	var count := 0
	for child in node.find_children("*", "MeshInstance3D", true, false):
		count += (child as MeshInstance3D).mesh.get_faces().size() / 3
	return count


func test_props_load_within_budgets_with_ps1_materials() -> void:
	for name: String in PROPS:
		var scene := load("res://assets/models/props/%s.glb" % name) as PackedScene
		assert_not_null(scene, name + " loads")
		if scene == null:
			continue
		var model := scene.instantiate()
		var triangles := _triangles(model)
		assert_true(triangles > 0 and triangles < PROPS[name], "%s budget (%d)" % [name, triangles])
		for node in model.find_children("*", "MeshInstance3D", true, false):
			var instance := node as MeshInstance3D
			for surface in instance.mesh.get_surface_count():
				var material := instance.get_active_material(surface) as ShaderMaterial
				assert_not_null(material, name + " PS1 shader material")
				if material == null:
					continue
				assert_true(material.shader.resource_path.get_file().begins_with("ps1_surface"), name + " PS1 shader")
				var texture := material.get_shader_parameter("albedo_texture") as Texture2D
				assert_not_null(texture, name + " albedo texture")
				if texture != null:
					var path := texture.resource_path
					assert_true(path.begins_with("res://assets/textures/props/") or path.begins_with("res://assets/textures/kit/"),
						name + " canonical texture " + path)
					assert_true(texture.get_width() <= 256, name + " small texture")
		model.free()


func test_prop_textures_are_lossless_without_mipmaps() -> void:
	for file in DirAccess.get_files_at("res://assets/textures/props"):
		if not file.ends_with(".png"):
			continue
		var import := ConfigFile.new()
		assert_eq(import.load("res://assets/textures/props/%s.import" % file), OK, file + " import settings")
		assert_eq(import.get_value("params", "compress/mode"), 0, file + " lossless")
		assert_eq(import.get_value("params", "mipmaps/generate"), false, file + " no mipmaps")


func test_floor_keeps_code_nodes_and_uses_props() -> void:
	var floor_scene := FLOOR.instantiate()
	tree.root.add_child(floor_scene)
	await wait_frames(1)
	for path in KEPT_NODES:
		assert_not_null(floor_scene.get_node_or_null(path), "kept " + path)
	for path in ["DutyDesk/Desk/Model", "DutyDesk/HallBoard", "DutyDesk/Speaker", "DutyDesk/DeskTelephone",
			"Washroom/Sink_2/Model", "Washroom/Tap_2", "Washroom/StallDoor_1/Model", "Washroom/TapWater",
			"Corridor/Slippers_0", "Corridor/HangingCloth_0", "Corridor/Bucket_11/Model",
			"Room407/StudyDesk/Model", "Room407/Room407DeskLamp/Fixture"]:
		assert_not_null(floor_scene.get_node_or_null(path), "prop " + path)
	for gone in ["DutyDesk/HallBoardPaper", "DutyDesk/DutyLog", "Washroom/Notice", "Room407/Phone", "Room407/LightSwitch"]:
		assert_true(floor_scene.get_node_or_null(gone) == null, "placeholder removed: " + gone)
	assert_false(floor_scene.get_node("Washroom/TapWater").running, "water off until the story runs it")
	floor_scene.queue_free()
	await wait_frames(2)
	await tree.create_timer(0.4).timeout


func test_water_stream_runs_and_stops() -> void:
	var water := (load("res://scenes/levels/props/water_stream.tscn") as PackedScene).instantiate()
	tree.root.add_child(water)
	assert_false(water.visible, "off by default")
	water.set_running(true)
	assert_true(water.visible and water.running, "running shows the stream")
	await wait_frames(3)
	water.set_running(false)
	assert_false(water.visible, "stopped hides it")
	water.queue_free()


func test_slippers_and_cloth_take_their_colour_and_cloth_sways() -> void:
	var slippers := (load("res://scenes/levels/props/slippers_pair.tscn") as PackedScene).instantiate()
	slippers.color = Color(0.5, 0.1, 0.1)
	var other := (load("res://scenes/levels/props/slippers_pair.tscn") as PackedScene).instantiate()
	tree.root.add_child(slippers)
	tree.root.add_child(other)
	assert_eq(PropTint.current(slippers), Color(0.5, 0.1, 0.1), "colour set before ready")
	slippers.color = Color(0.1, 0.5, 0.1)
	assert_eq(PropTint.current(slippers), Color(0.1, 0.5, 0.1), "colour changes live")
	assert_eq(PropTint.current(other), other.color, "other pairs keep their own colour")
	var shirt := (load("res://scenes/levels/props/shirt_hanging.tscn") as PackedScene).instantiate()
	shirt.color = Color(0.9, 0.9, 0.9)
	tree.root.add_child(shirt)
	var before: float = shirt.rotation.x
	await tree.create_timer(0.3).timeout
	assert_true(absf(shirt.rotation.x - before) > 0.0001, "cloth sways")
	assert_true(absf(shirt.rotation.x) <= shirt.sway * 1.3, "sway stays small")
	for node in [slippers, other, shirt]:
		node.queue_free()


func test_door_prompt_follows_its_state() -> void:
	var floor_scene := FLOOR.instantiate()
	tree.root.add_child(floor_scene)
	await wait_frames(1)
	var door := floor_scene.get_node("Door407")
	assert_eq(door.prompt_key, "PROMPT_OPEN_DOOR", "closed door offers to open")
	door.set_open(true)
	assert_eq(door.prompt_key, "PROMPT_CLOSE_DOOR", "open door offers to close")
	door.set_open(false)
	assert_eq(door.prompt_key, "PROMPT_OPEN_DOOR", "closed again")
	floor_scene.queue_free()
	await wait_frames(2)
	await tree.create_timer(0.4).timeout
