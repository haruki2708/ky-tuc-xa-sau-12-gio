extends Node3D
## Integration fixture only. Accepted gags here demonstrate core's API calls.

var player: CharacterBody3D
var door: StuckDoor
var door_collision: CollisionShape3D
var yes: ShowerChoice
var no: ShowerChoice
var status: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_box(self, Vector3(0, -0.1, 0), Vector3(14, 0.2, 14), Color(0.24, 0.26, 0.3), true)
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 3, 0)
	light.omni_range = 14
	light.light_energy = 2
	add_child(light)
	player = load("res://scenes/player/player.tscn").instantiate()
	player.position = Vector3(0, 0.02, 2.5)
	add_child(player)
	for index: int in 3:
		var item: CarryItem = _prop("carry_item", Vector3(-2 + index, 1.05, 0)) as CarryItem
		item.item_id = [&"rag", &"towel", &"shirt"][index]
		item.prompt_key = ["PROMPT_CH2_CARRY_RAG", "PROMPT_CH2_CARRY_TOWEL", "PROMPT_CH2_CARRY_SHIRT"][index]
		var item_label: Label3D = _label(item, item.prompt_key, Vector3(0, 0.25, 0))
		item.picked.connect(func(_id: StringName) -> void: item_label.hide())
		item.dropped.connect(func(_id: StringName) -> void: item_label.show())
		_box(self, item.position - Vector3(0, 0.1, 0), Vector3(0.7, 0.1, 0.5), Color(0.3, 0.25, 0.2))
		var corpse: Node3D = Node3D.new()
		corpse.position = Vector3(-2 + index * 1.3, 0, -2)
		add_child(corpse)
		corpse.add_to_group(&"ch2_corpse")
		_box(corpse, Vector3(0, 0.7, 0), Vector3(0.4, 0.8, 0.3), Color(0.25, 0.28, 0.22))
		var head: MeshInstance3D = _box(corpse, Vector3(0, 1.3, 0), Vector3(0.3, 0.35, 0.3), Color(0.5, 0.5, 0.4))
		head.name = "Head"
		var spot: GagSpot = load("res://scenes/interaction/gag_spot.tscn").instantiate()
		spot.position = Vector3(0, 1.25, 0.22)
		spot.bed = [1, 2, 4][index]
		corpse.add_child(spot)
		spot.gag_requested.connect(func(_bed: int, _id: StringName) -> void:
			var held: CarryItem = CarryItem.held_by(player)
			if held != null:
				held.consume()
				spot.set_gagged(true)
				spot.get_node("Placeholder").hide())
		_label(spot, "PROMPT_CH2_GAG", Vector3(0, 0.5, 0))
	door = _prop("stuck_door", Vector3(2.2, 0.95, -1)) as StuckDoor
	door.room = self
	var body: StaticBody3D = StaticBody3D.new()
	door.add_child(body)
	door_collision = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(0.85, 1.9, 0.06)
	door_collision.shape = shape
	body.add_child(door_collision)
	_label(door, "PROMPT_CH2_DOOR_BASH", Vector3(0, 1.1, 0))
	_prop("shower_stall", Vector3(4.2, 0, -1.7))
	_box(self, Vector3(4.2, 0.005, -1.7), Vector3(1.4, 0.01, 1.4), Color(0.2, 0.45, 0.5))
	var screen: ShowerScreen = _prop("shower_screen", Vector3(4.2, 1.55, -2.35)) as ShowerScreen
	yes = _prop("shower_choice", Vector3(4.05, 1.25, -2.35)) as ShowerChoice
	no = _prop("shower_choice", Vector3(4.35, 1.25, -2.35)) as ShowerChoice
	yes.name = "ShowerYes"
	no.name = "ShowerNo"
	no.run_water = false
	no.prompt_key = "PROMPT_CH2_SHOWER_NO"
	_label(yes, yes.prompt_key, Vector3(0, -0.15, 0))
	_label(no, no.prompt_key, Vector3(0, -0.15, 0))
	_label(screen, "UI_CH2_TEST_STALL", Vector3(0, 0.4, 0))
	add_child(load("res://ui/hud/hud.tscn").instantiate())
	add_child(load("res://ui/pause/pause_menu.tscn").instantiate())
	var overlay: CanvasLayer = CanvasLayer.new()
	var help: Label = Label.new()
	help.text = tr("UI_CH2_TEST_HELP")
	help.position = Vector2(20, 20)
	help.add_theme_font_size_override("font_size", 16)
	status = Label.new()
	status.position = Vector2(20, 50)
	status.text = tr("UI_CH2_TEST_DISABLED")
	overlay.add_child(help)
	overlay.add_child(status)
	add_child(overlay)
	screen.wiped.connect(func() -> void: status.text = tr("UI_CH2_TEST_WIPED"))
	EventBus.shower_choice_made.connect(func(value: bool) -> void:
		status.text = tr("PROMPT_CH2_SHOWER_YES" if value else "PROMPT_CH2_SHOWER_NO"))
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--death-preview="):
			preview_death.call_deferred(StringName(argument.trim_prefix("--death-preview=")))


func _prop(scene: String, at: Vector3) -> Node3D:
	var prop: Node3D = load("res://scenes/interaction/" + scene + ".tscn").instantiate()
	prop.position = at
	add_child(prop)
	return prop


func _box(parent: Node3D, at: Vector3, size: Vector3, color: Color, solid: bool = false) -> MeshInstance3D:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = size
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	box.material = material
	mesh.mesh = box
	mesh.position = at
	parent.add_child(mesh)
	if solid:
		var body: StaticBody3D = StaticBody3D.new()
		var collision: CollisionShape3D = CollisionShape3D.new()
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)
		mesh.add_child(body)
	return mesh


func _label(parent: Node3D, key: String, at: Vector3) -> Label3D:
	var label: Label3D = Label3D.new()
	label.text = tr(key)
	label.position = at
	label.font_size = 28
	label.pixel_size = 0.004
	parent.add_child(label)
	return label


func set_bathroom_door_open(value: bool) -> void:
	door.get_node("Placeholder").visible = not value
	door_collision.set_deferred("disabled", value)


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_1: preview_death(&"corpse_lunge")
		KEY_2: preview_death(&"scald")
		KEY_R: get_tree().reload_current_scene()
		KEY_T:
			yes.set_enabled(not yes.enabled)
			no.set_enabled(yes.enabled)
			status.text = tr("UI_CH2_TEST_ENABLED" if yes.enabled else "UI_CH2_TEST_DISABLED")


func preview_death(kind: StringName) -> void:
	var death: PlayerDeath = player.get("death_animation") as PlayerDeath
	if death.active:
		return
	for label: Node in find_children("*", "Label3D", true, false):
		(label as Label3D).hide()
	if kind == &"scald":
		player.global_position = Vector3(4.2, 0.02, -1.3)
	EventBus.player_death_started.emit(kind)
	if kind == &"corpse_lunge" and not death.reduced:
		# Placeholder animation only: production lunge belongs to B/core.
		var corpse: Node3D = death._corpse
		if is_instance_valid(corpse):
			var tween: Tween = create_tween()
			tween.tween_interval(0.3)
			tween.tween_property(corpse, "global_position", player.global_position - player.global_basis.z * 0.6, 0.4)
