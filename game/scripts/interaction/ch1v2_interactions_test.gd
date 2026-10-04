extends Node3D
## Standalone mechanic preview. Mission rules remain in the chapter director.

var player: CharacterBody3D
var bunk: HideSpot
var manager: DormManager
var strip: PowerStrip


func _ready() -> void:
	var floor_body: StaticBody3D = StaticBody3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(14, 0.2, 14)
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	floor_body.add_child(collision)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = shape.size
	mesh.mesh = box
	floor_body.add_child(mesh)
	floor_body.position.y = -0.1
	add_child(floor_body)
	var ceiling: MeshInstance3D = MeshInstance3D.new()
	var ceiling_box: BoxMesh = BoxMesh.new()
	ceiling_box.size = Vector3(14, 0.15, 14)
	ceiling.mesh = ceiling_box
	ceiling.position.y = 3.2
	add_child(ceiling)
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 2.5, 0)
	light.omni_range = 12
	add_child(light)
	player = load("res://scenes/player/player.tscn").instantiate()
	player.position = Vector3(0, 0.02, 2)
	player.set("max_breath_seconds", 6.0)
	add_child(player)
	_prop("wall_knock", Vector3(-2.5, 1.2, -2))
	for index: int in 3:
		var spot: Interactable = _prop("search_spot", Vector3(-1.5 + index * 0.7, 0.8, -2))
		spot.set("spot_id", [&"viet_locker", &"phuc_mattress", &"bin"][index])
		spot.prompt_key = ["PROMPT_SEARCH_LOCKER", "PROMPT_SEARCH_MATTRESS", "PROMPT_SEARCH_BIN"][index]
	strip = _prop("power_strip", Vector3(1.4, 0.65, -2))
	var lamp: OmniLight3D = OmniLight3D.new()
	lamp.position = Vector3(2.5, 1, -2)
	lamp.omni_range = 2
	add_child(lamp)
	var control: Node3D = load("res://scenes/interaction/desk_lamp_switch.tscn").instantiate()
	control.set("light", lamp)
	control.position = Vector3(2.5, 0.7, -2)
	add_child(control)
	var blue: LanCable = _prop("lan_cable", Vector3(-1, 0.8, 0))
	var gray: LanCable = _prop("lan_cable", Vector3(1, 0.8, 0))
	gray.cable_id = &"gray"
	var gray_material: StandardMaterial3D = StandardMaterial3D.new()
	gray_material.albedo_color = Color(0.4, 0.4, 0.4)
	gray.get_node("Placeholder").material_override = gray_material
	blue.name = "BlueCable"
	gray.name = "GrayCable"
	_prop("lan_socket", Vector3(0, 1.2, -2))
	bunk = _prop("bunk_spot", Vector3(3, 0, 0))
	manager = load("res://scenes/entity/manager.tscn").instantiate()
	manager.position = Vector3(0, 0.02, -4)
	manager.player = player
	add_child(manager)
	var hud: Node = load("res://ui/hud/hud.tscn").instantiate()
	add_child(hud)
	add_child(load("res://ui/pause/pause_menu.tscn").instantiate())
	var overlay: CanvasLayer = CanvasLayer.new()
	var help: Label = Label.new()
	help.text = tr("UI_CH1V2_TEST_HELP")
	help.position = Vector2(20, 20)
	help.add_theme_color_override("font_shadow_color", Color.BLACK)
	help.add_theme_constant_override("shadow_offset_x", 2)
	help.add_theme_constant_override("shadow_offset_y", 2)
	overlay.add_child(help)
	add_child(overlay)
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--death-preview="):
			preview_death.call_deferred(StringName(argument.trim_prefix("--death-preview=")))


func _prop(scene: String, at: Vector3) -> Node3D:
	var prop: Node3D = load("res://scenes/interaction/" + scene + ".tscn").instantiate()
	prop.position = at
	add_child(prop)
	return prop


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_1: preview_death(&"fall_back")
		KEY_2: preview_death(&"manager_kill")
		KEY_3: preview_death(&"bed_burst")
		KEY_T:
			strip.trip()
			strip.set_locked(20.0)
		KEY_R: get_tree().reload_current_scene()


func preview_death(kind: StringName) -> void:
	if player.get("death_animation").active:
		return
	if kind == &"bed_burst":
		player.call("lie_on", bunk)
	elif kind == &"manager_kill":
		manager.global_position = player.global_position - player.global_basis.z * 1.7
		manager.kill_player()
	EventBus.player_death_started.emit(kind)
