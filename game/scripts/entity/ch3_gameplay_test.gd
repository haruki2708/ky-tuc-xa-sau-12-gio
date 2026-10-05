extends Node3D
## Primitive mechanic preview; core owns chapter progression and verdicts.

var player: CharacterBody3D
var horde: ZombieHorde


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(Ch3TestGeometry.new())
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 5, 0)
	light.omni_range = 25
	light.light_energy = 3
	add_child(light)
	player = load("res://scenes/player/player.tscn").instantiate()
	player.position = Vector3(0, 0.02, 4)
	player.set("stamina_enabled", true)
	add_child(player)
	var bar: Interactable = load("res://scenes/interaction/iron_bar.tscn").instantiate()
	bar.position = Vector3(0, 0.8, 2.7)
	add_child(bar)
	var zombie: Zombie = load("res://scenes/entity/zombie.tscn").instantiate()
	zombie.position = Vector3(0, 1.21, -7)
	zombie.rotation.y = PI
	add_child(zombie)
	zombie.set_target(player)
	var guard: CampusGuard = load("res://scenes/entity/guard.tscn").instantiate()
	guard.position = Vector3(5, 0.02, 0)
	guard.player = player
	add_child(guard)
	var path: Node3D = Node3D.new()
	add_child(path)
	for index: int in 3:
		var point: Marker3D = Marker3D.new()
		point.name = ["P01", "P02_Wait_stairs", "P03"][index]
		point.position = [Vector3(-4, 0, 0), Vector3(0, 1.2, -6), Vector3(5, 1.2, -8)][index]
		path.add_child(point)
	for index: int in 2:
		var ally: Companion = load("res://scenes/entity/companion.tscn").instantiate()
		ally.member = &"minh_nhat" if index == 0 else &"ngu"
		ally.position = Vector3(-4 - index, 0.02, 3)
		ally.player = player
		add_child(ally)
		ally.follow_path(path)
	var anchors: Node3D = Node3D.new()
	add_child(anchors)
	var spawns: Node3D = Node3D.new()
	spawns.name = "ZombieSpawns"
	anchors.add_child(spawns)
	var zone: Node3D = Node3D.new()
	zone.name = "Test"
	spawns.add_child(zone)
	for index: int in 40:
		var point: Marker3D = Marker3D.new()
		point.position = Vector3(-7 + index % 10 * 1.5, 1.22, -8.5 + index / 10 * 0.8)
		zone.add_child(point)
	horde = ZombieHorde.new()
	horde.anchors = anchors
	horde.target = player
	add_child(horde)
	add_child(load("res://ui/hud/hud.tscn").instantiate())
	add_child(load("res://ui/pause/pause_menu.tscn").instantiate())
	EventBus.player_caught.connect(_caught)
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--death-preview="):
			zombie.global_position = player.global_position + Vector3.FORWARD * 0.8
			zombie.face(player.global_position)
			zombie.play_pose(&"grab")
			zombie.set_physics_process(false)
			EventBus.player_death_started.emit.call_deferred(StringName(argument.trim_prefix("--death-preview=")))


func _caught(entity: StringName) -> void:
	EventBus.player_death_started.emit(&"guard_shock" if entity == &"guard" else &"zombie_grab")


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_R: get_tree().reload_current_scene()
		KEY_1: EventBus.player_death_started.emit(&"zombie_grab")
		KEY_2: EventBus.player_death_started.emit(&"guard_shock")
		KEY_3: horde.spawn(&"Test", 40)
		KEY_4: player.call("give_bar", 8)
