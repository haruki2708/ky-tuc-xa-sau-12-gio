extends Node3D
## Isolated mechanic fixture; the production action and story belong to core.

class PreviewDoor extends Interactable:
	var room: StringName = &"407"
	var is_open: bool = false
	func set_open(value: bool) -> void:
		is_open = value
		$Pivot.rotation.y = -PI * 0.5 if value else 0.0
		$Blocker.collision_layer = 0 if value else 1
	func _on_interact(_player: Node) -> void:
		set_open(not is_open)

var player: CharacterBody3D
var first_slat: BedSlat


func _ready() -> void:
	GameState.chapter = 4
	GameState.set_flag(&"ch4_phone_charges", 3)
	var geometry: Ch3TestGeometry = Ch3TestGeometry.new()
	add_child(geometry)
	var light: DirectionalLight3D = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-40, -35, 0)
	add_child(light)
	player = load("res://scenes/player/player.tscn").instantiate()
	player.position = Vector3(0, 0.02, 2)
	add_child(player)
	for index: int in 3:
		var slat: BedSlat = load("res://scenes/interaction/bed_slat.tscn").instantiate()
		slat.bed = [1, 2, 4][index]
		slat.position = Vector3(-2, 0.8, -index * 1.5)
		add_child(slat)
		if index == 0:
			first_slat = slat
		var fake: HoldInteractable = load("res://scenes/interaction/fake_search_spot.tscn").instantiate()
		fake.name = ["FakeLocker", "FakeCeiling", "FakeVent"][index]
		fake.position = Vector3(2, 1, -index * 1.5)
		add_child(fake)
	var door: PreviewDoor = PreviewDoor.new()
	door.name = "Door407"
	door.position = Vector3(0, 0, -1.5)
	var pivot: Node3D = Node3D.new()
	pivot.name = "Pivot"
	door.add_child(pivot)
	var body: StaticBody3D = geometry.box(Vector3(0, 1.2, 0), Vector3(1.5, 2.4, 0.12))
	body.reparent(door, false)
	body.name = "Blocker"
	var mesh: Node3D = body.get_child(1) as Node3D
	mesh.reparent(pivot, false)
	mesh.position.y = 1.2
	add_child(door)
	door.add_to_group(&"room_doors")
	var adapter: ZombieDoor = ZombieDoor.new()
	adapter.door = door
	adapter.blocker = body
	adapter.durability_seconds = 90
	door.add_child(adapter)
	add_child(load("res://ui/hud/hud.tscn").instantiate())
	add_child(load("res://ui/pause/pause_menu.tscn").instantiate())
	await get_tree().physics_frame
	await get_tree().physics_frame
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--preview=door_burst" or argument == "--preview=door_burst_reduced":
			player.get("death_animation").reduced = argument.ends_with("reduced")
			EventBus.player_death_started.emit(&"door_burst")
		elif argument == "--preview=slat":
			player.position = Vector3(-2, 0.02, 1.5)
			player.get_node("Head").rotation.x = -0.6
			Input.action_press("interact")
			first_slat.interact(player)
		elif argument == "--preview=phone":
			player.get_node("Head/Camera3D/PhoneItem").throw_decoy()


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return
	if event.physical_keycode == KEY_G and not InputMap.has_action("throw_phone"):
		# Fixture fallback only. Do not register the missing production action here.
		player.get_node("Head/Camera3D/PhoneItem").throw_decoy()
	elif event.physical_keycode == KEY_1:
		EventBus.player_death_started.emit(&"door_burst")
	elif event.physical_keycode == KEY_R:
		get_tree().reload_current_scene()


func _exit_tree() -> void:
	Input.action_release("interact")
