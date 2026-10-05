extends TestCase

const PlayerScript = preload("res://scripts/player/player.gd")
const PLAYER: PackedScene = preload("res://scenes/player/player.tscn")
const ZOMBIE: PackedScene = preload("res://scenes/entity/zombie.tscn")
const GUARD: PackedScene = preload("res://scenes/entity/guard.tscn")
const COMPANION: PackedScene = preload("res://scenes/entity/companion.tscn")

class DoorStub extends Node3D:
	var is_open: bool = false
	func set_open(value: bool) -> void:
		is_open = value

var world: Ch3TestGeometry
var player: PlayerScript
var caught: Array[StringName] = []
var noises: Array[Array] = []
var old_mouse: Input.MouseMode


func before_each() -> void:
	old_mouse = Input.mouse_mode
	for action: StringName in PlayerScript.GAMEPLAY_ACTIONS:
		Input.action_release(action)
	world = Ch3TestGeometry.new()
	tree.root.add_child(world)
	player = PLAYER.instantiate()
	player.position = Vector3(0, 0.02, 3)
	world.add_child(player)
	player.set_physics_process(false)
	EventBus.player_caught.connect(_caught)
	EventBus.noise_emitted.connect(_noise)
	await _ticks(4)


func after_each() -> void:
	tree.paused = false
	for action: StringName in PlayerScript.GAMEPLAY_ACTIONS:
		Input.action_release(action)
	EventBus.player_caught.disconnect(_caught)
	EventBus.noise_emitted.disconnect(_noise)
	world.queue_free()
	await wait_frames(2)
	Input.mouse_mode = old_mouse
	GameState.reset()


func _caught(id: StringName) -> void:
	caught.append(id)


func _noise(at: Vector3, radius: float, source: StringName) -> void:
	noises.append([at, radius, source])


func _ticks(count: int = 2) -> void:
	for index: int in count:
		await tree.physics_frame
		await tree.process_frame


func _zombie(at: Vector3) -> Zombie:
	var zombie: Zombie = ZOMBIE.instantiate()
	zombie.position = at
	world.add_child(zombie)
	zombie.set_target(player)
	zombie.set_physics_process(false)
	return zombie


func test_zombie_wakes_only_near_and_seen_or_heard_then_stuns_and_catches_once() -> void:
	var zombie: Zombie = _zombie(Vector3(0, 0.02, 0))
	zombie.rotation.y = PI
	player.position.z = 30
	EventBus.noise_emitted.emit(zombie.position, 50, &"extinguisher")
	assert_eq(zombie.state, &"asleep")
	player.position.z = 3
	zombie._physics_process(0.3)
	assert_eq(zombie.state, &"hunting")
	zombie.stun(5)
	var frozen: Vector3 = zombie.position
	for index: int in 16:
		zombie._physics_process(0.3)
	assert_true(zombie.is_stunned())
	assert_eq(zombie.position, frozen)
	zombie._physics_process(0.3)
	assert_false(zombie.is_stunned())
	player.position = zombie.position + zombie.global_basis.z * -0.7
	zombie._physics_process(0.3)
	zombie._physics_process(0.3)
	assert_eq(caught, [&"zombie"])


func test_noise_through_wall_wakes_but_wall_prevents_grab() -> void:
	var zombie: Zombie = _zombie(Vector3(0, 0.02, 0))
	zombie.rotation.y = PI
	player.position.z = 0.8
	world.box(Vector3(0, 1, 0.4), Vector3(3, 2, 0.1))
	await _ticks()
	zombie._physics_process(0.3)
	assert_eq(zombie.state, &"asleep")
	EventBus.noise_emitted.emit(player.position, 5, &"step")
	assert_eq(zombie.state, &"hunting")
	zombie._physics_process(0.3)
	assert_true(caught.is_empty())
	assert_true(zombie.position.z < 0.3)


func test_navigation_climbs_real_steps_and_reaches_upper_landing() -> void:
	var zombie: Zombie = _zombie(Vector3(0, 0.02, 1))
	player.position = Vector3(0, 1.22, -8)
	zombie.wake()
	var start: Vector3 = zombie.position
	for index: int in 650:
		zombie.navigate_to(player.position, 1.5, 1.0 / 60.0)
		if index % 30 == 0:
			await _ticks(1)
	assert_true(zombie.position.z < -5.0, "navmesh leads through the stairs")
	assert_true(zombie.position.y > 1.15 and zombie.position.y < 1.3, "physical steps are climbed")
	assert_true(start.distance_to(zombie.position) > 6)


func test_wooden_door_takes_ten_seconds_and_crowd_does_not_multiply_damage() -> void:
	var door: DoorStub = DoorStub.new()
	world.add_child(door)
	var blocker: StaticBody3D = world.box(Vector3(0, 1, 1), Vector3(2, 2, 0.1))
	var adapter: ZombieDoor = ZombieDoor.new()
	adapter.door = door
	adapter.blocker = blocker
	world.add_child(adapter)
	adapter.set_physics_process(false)
	var zombie: Zombie = _zombie(Vector3(0, 0.02, 0.2))
	zombie.set_target(player)
	zombie.wake()
	await _ticks()
	for index: int in 9:
		assert_true(zombie._bash_door(1.0))
		adapter.bash(1.0, 10)
		adapter._physics_process(1.0)
		await _ticks(1)
	assert_false(door.is_open)
	assert_eq(adapter.damage_seconds, 9.0)
	zombie._bash_door(1.0)
	adapter._physics_process(1.0)
	assert_true(door.is_open)
	assert_true(adapter.is_broken)
	await _ticks()
	assert_eq(blocker.collision_layer, 0)


func test_horde_cap_idle_activation_clear_and_sparse_silent_updates() -> void:
	var anchors: Node3D = Node3D.new()
	world.add_child(anchors)
	for kind: String in ["ZombieSpawns", "ZombieIdle"]:
		var root: Node3D = Node3D.new()
		root.name = kind
		anchors.add_child(root)
		var zone: Node3D = Node3D.new()
		zone.name = "Road"
		root.add_child(zone)
		for index: int in 45:
			var marker: Marker3D = Marker3D.new()
			marker.position = Vector3(index * 2, 0, -70)
			zone.add_child(marker)
	var horde: ZombieHorde = ZombieHorde.new()
	horde.anchors = anchors
	horde.target = player
	world.add_child(horde)
	horde.spawn(&"Road", 60)
	assert_eq(horde.active_count(), 40)
	horde.place_idle(&"Road")
	horde.place_idle(&"Road")
	assert_eq(horde.get_child_count(), 85)
	for actor: Zombie in horde.get_children():
		actor.set_physics_process(false)
		actor.wake()
	assert_eq(horde.active_count(), 40)
	var far: Zombie = horde.get_child(0) as Zombie
	for index: int in 60:
		far._physics_process(1.0 / 60.0)
	assert_true(far.sparse)
	assert_true(far.update_count >= 3 and far.update_count <= 4)
	assert_false(far.audio_enabled)
	var idle: Zombie = horde.get_child(84) as Zombie
	idle.stun(5)
	assert_true(idle.is_stunned(), "direct hit still stuns an idle zombie at capacity")
	assert_eq(horde.active_count(), 40)
	horde.clear_zone(&"Road")
	assert_eq(horde.active_count(), 0)
	horde.clear_all()


func test_horde_queues_occupied_anchors_and_clears_pending_spawns() -> void:
	var anchors: Node3D = Node3D.new()
	world.add_child(anchors)
	var root: Node3D = Node3D.new()
	root.name = "ZombieSpawns"
	anchors.add_child(root)
	var zone: Node3D = Node3D.new()
	zone.name = "B4"
	root.add_child(zone)
	for index: int in 6:
		var point: Marker3D = Marker3D.new()
		point.position = Vector3(-5 + index * 2, 0.02, 0)
		zone.add_child(point)
	var horde: ZombieHorde = ZombieHorde.new()
	horde.anchors = anchors
	horde.target = player
	world.add_child(horde)
	horde.set_physics_process(false)
	horde.spawn(&"B4", 40)
	assert_eq(horde.active_count(), 6, "occupied anchors cannot stack characters")
	for actor: Zombie in horde.get_children():
		actor.set_physics_process(false)
		actor.position.z += 2
	await _ticks()
	horde._physics_process(0.3)
	assert_eq(horde.active_count(), 12, "queued spawn resumes after the anchor clears")
	horde.clear_all()
	await _ticks()
	horde._physics_process(0.3)
	assert_eq(horde.get_child_count(), 0, "clearing also cancels pending reinforcements")


func test_occluded_zombie_ticks_sparsely_and_model_head_drives_hitbox() -> void:
	var zombie: Zombie = _zombie(Vector3(0, 0.02, 0))
	var model: Node3D = Node3D.new()
	var head: Marker3D = Marker3D.new()
	head.name = "Head"
	head.position = Vector3(0.1, 1.75, 0)
	model.add_child(head)
	head.owner = model
	var scene: PackedScene = PackedScene.new()
	assert_eq(scene.pack(model), OK)
	model.free()
	zombie.set_body(scene)
	zombie.wake()
	world.box(Vector3(0, 1, 1), Vector3(3, 2, 0.1))
	await _ticks()
	for index: int in 60:
		zombie._physics_process(1.0 / 60.0)
	assert_true(zombie.sparse)
	assert_false(zombie.audio_enabled)
	assert_true(zombie.update_count >= 3 and zombie.update_count <= 4)
	assert_true(zombie.head_position().is_equal_approx(zombie.model.get_node("Head").global_position))
	assert_true(zombie.get_node("HeadHitbox").global_position.is_equal_approx(zombie.head_position()))


func test_bar_head_hits_misses_wall_occlusion_eight_hits_and_guard() -> void:
	player.position = Vector3(0, 0.02, 0)
	var zombie: Zombie = _zombie(Vector3(0, 0.02, -1.2))
	await _ticks()
	player.give_bar(8)
	var weapon: IronBarWeapon = player.bar_weapon
	weapon.set_physics_process(false)
	assert_true(weapon.swing())
	assert_true(zombie.is_stunned())
	assert_eq(weapon.hits_left, 7)
	assert_false(weapon.swing(), "swing cooldown prevents rapid repeat")
	weapon._physics_process(1)
	player.head.rotation.x = -0.7
	weapon.swing()
	assert_eq(weapon.hits_left, 7, "body/missed hits do not wear the bar")
	player.head.rotation.x = 0
	var wall: StaticBody3D = world.box(Vector3(0, 1.2, -0.5), Vector3(2, 2.4, 0.1))
	await _ticks()
	weapon._physics_process(1)
	weapon.swing()
	assert_eq(weapon.hits_left, 7, "wall blocks head hit")
	wall.queue_free()
	await _ticks()
	for index: int in 7:
		zombie._physics_process(5.1)
		zombie._physics_process(0.02)
		await _ticks(1)
		weapon._physics_process(1)
		weapon.swing()
	assert_eq(weapon.hits_left, 0)
	assert_false(weapon.visible)
	zombie.queue_free()
	var guard: CampusGuard = GUARD.instantiate()
	guard.position = Vector3(0, 0.02, -1)
	world.add_child(guard)
	guard.set_physics_process(false)
	await _ticks()
	player.give_bar(8)
	weapon.swing()
	assert_eq(caught, [&"guard"])


func test_stamina_twelve_seconds_recovery_hysteresis_panting_and_disabled_legacy() -> void:
	player._update_stamina(20, true, true)
	assert_eq(player.stamina, 1.0)
	assert_true(noises.is_empty())
	player.stamina_enabled = true
	for index: int in 120:
		player._update_stamina(0.1, true, true)
	assert_eq(player.stamina, 0.0)
	assert_true(player.exhausted)
	assert_true(noises.any(func(value: Array) -> bool: return value[1] == 8.0 and value[2] == &"pant"))
	player._update_stamina(2, false, false)
	assert_true(player.exhausted)
	assert_true(is_equal_approx(player.stamina, 0.24))
	player._update_stamina(0.5, false, false)
	assert_false(player.exhausted)
	player.spend_stamina(0.08)
	assert_true(is_equal_approx(player.stamina, 0.22))
	player._update_stamina(1, false, true)
	assert_true(is_equal_approx(player.stamina, 0.27))


func test_companion_waits_calls_resumes_and_never_stuns_zombies() -> void:
	var companion: Companion = COMPANION.instantiate()
	companion.player = player
	world.add_child(companion)
	companion.set_physics_process(false)
	var path: Node3D = Node3D.new()
	world.add_child(path)
	for name: String in ["P02", "P01_Wait_start"]:
		var point: Marker3D = Marker3D.new()
		point.name = name
		point.position = Vector3(0, 0, -7) if name == "P02" else Vector3.ZERO
		path.add_child(point)
	companion.follow_path(path)
	player.position.z = 30
	companion._physics_process(0.1)
	assert_eq(companion.state, &"waiting")
	companion._physics_process(8)
	assert_eq(companion.state, &"calling")
	player.position.z = 3
	companion._physics_process(0.1)
	assert_eq(companion.state, &"running")
	var zombie: Zombie = _zombie(companion.position + Vector3.RIGHT)
	zombie.wake()
	companion._physics_process(0.1)
	assert_false(zombie.is_stunned())
	assert_true(caught.is_empty())


func test_guard_warns_clears_warn_kills_and_zombie_avoids_radius() -> void:
	var guard: CampusGuard = GUARD.instantiate()
	guard.player = player
	world.add_child(guard)
	guard.set_physics_process(false)
	player.position = Vector3(0, 0, 2.8)
	guard._physics_process(0.1)
	assert_true(guard.warned)
	player.position.z = 4
	guard._physics_process(0.1)
	assert_false(guard.warned)
	var zombie: Zombie = _zombie(Vector3(0, 0, 3.5))
	var motion: Vector3 = zombie._guard_motion(Vector3(0, 0, -0.5))
	assert_true((zombie.position + motion).distance_to(guard.position) >= 3)
	zombie.queue_free()
	await _ticks()
	player.position.z = 1.4
	guard._physics_process(0.1)
	guard.struck()
	assert_eq(caught, [&"guard"])


func test_sparse_movement_climbs_steps_without_tunnelling() -> void:
	var zombie: Zombie = _zombie(Vector3(0, 0.02, 1))
	for index: int in 40:
		zombie.navigate_to(Vector3(0, 1.2, -8), 1.5, 0.3)
		await _ticks(1)
	assert_true(zombie.position.z < -5, "sparse AI must also climb the steps")
	assert_true(zombie.position.y > 1.15)


func test_pickup_by_e_mouse_swing_does_not_interact_and_typing_blocks_weapon() -> void:
	var bar: Interactable = load("res://scenes/interaction/iron_bar.tscn").instantiate()
	bar.position = Vector3(0, 1.6, 2)
	world.add_child(bar)
	await _ticks()
	Input.action_press("interact")
	player._physics_process(0.01)
	assert_not_null(player.bar_weapon)
	assert_eq(player.bar_weapon.hits_left, 8)
	var mouse: InputEventMouseButton = InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	player._unhandled_input(mouse)
	assert_false(Input.is_action_pressed("interact"), "armed mouse click cannot also activate E")
	assert_true(noises.any(func(value: Array) -> bool: return value[1] == 10.0 and value[2] == &"bar_swing"))
	player.bar_weapon._physics_process(1)
	EventBus.text_entry_changed.emit(true)
	assert_false(player.bar_weapon.swing())
	EventBus.text_entry_changed.emit(false)


func test_exhausted_player_walks_until_threshold_and_ch1_can_sprint() -> void:
	player.stamina_enabled = true
	player.spend_stamina(1)
	Input.action_press("move_forward")
	Input.action_press("sprint")
	player._physics_process(0.3)
	assert_true(Vector2(player.velocity.x, player.velocity.z).length() <= PlayerScript.WALK_SPEED + 0.001)
	player.stamina_enabled = false
	var value: float = player.stamina
	player._physics_process(0.3)
	assert_true(Vector2(player.velocity.x, player.velocity.z).length() > PlayerScript.WALK_SPEED)
	assert_eq(player.stamina, value)


func test_scene_load_and_pause_freezes_actors_and_stamina() -> void:
	var fixture: Node3D = load("res://scenes/entity/ch3_gameplay_test.tscn").instantiate()
	fixture.position.x = 40
	world.add_child(fixture)
	await _ticks()
	tree.paused = true
	var zombie: Zombie = tree.get_first_node_in_group(&"ch3_zombie") as Zombie
	var before: Vector3 = zombie.global_position
	await tree.create_timer(0.05, true).timeout
	assert_eq(zombie.global_position, before)
