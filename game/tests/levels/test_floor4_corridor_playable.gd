extends TestCase
## T-237 (D-148): the new floor-4 corridor (corridor_shell.gd) is in the playable build of all four chapters, and
## with Campus (chapters 3-4) a real player body still walks from it down both staircases: the main stairs at
## X=0 and, once the fire door opens, the fire stairs at X=44. Same steering as test_fire_stairs (T-188): the
## scene's capsule, floor snap and move_and_slide, no teleporting between waypoints.

const FLOOR := "res://scenes/levels/floor4/floor4.tscn"
var fixture: Node3D
var floor4: Node3D
var campus: Node3D
var player: CharacterBody3D
var _mouse_mode: Input.MouseMode


func before_each() -> void:
	_mouse_mode = Input.mouse_mode
	fixture = Node3D.new()
	tree.root.add_child(fixture)
	floor4 = load(FLOOR).instantiate() as Node3D
	campus = load("res://scenes/levels/campus/campus.tscn").instantiate() as Node3D
	fixture.add_child(floor4)
	fixture.add_child(campus)
	player = load("res://scenes/player/player.tscn").instantiate() as CharacterBody3D
	player.position = Vector3(30, 0.03, 3)
	fixture.add_child(player)
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	for frame in 3:
		await tree.physics_frame


func after_each() -> void:
	fixture.queue_free()
	await wait_frames(3)
	Input.mouse_mode = _mouse_mode


func _step(direction: Vector3, speed: float = 2.2) -> void:
	player.velocity.x = direction.x * speed
	player.velocity.z = direction.z * speed
	if not player.is_on_floor():
		player.velocity += player.get_gravity() * player.get_physics_process_delta_time()
	else:
		player.velocity.y = 0.0
	player.move_and_slide()


func _walk_to(target: Vector3, label: String) -> bool:
	for frame in 360:
		await tree.physics_frame
		var offset := target - player.global_position
		offset.y = 0
		if offset.length() < 0.15 and absf(player.position.y - target.y) < 0.15:
			return true
		_step(offset.normalized())
	var blockers: Array[String] = []
	for index in player.get_slide_collision_count():
		var collider := player.get_slide_collision(index).get_collider() as Node
		if collider != null:
			blockers.append(String(collider.name))
	assert_true(false, "%s unreachable; feet=%s target=%s blockers=%s" % [label, player.position, target, blockers])
	return false


func _walk(route: Array, labels: Array) -> bool:
	for index in route.size():
		if not await _walk_to(route[index], labels[index]):
			return false
	return true


## The walk must cross the new corridor, not the PS1 one: it is built, shown, and its end walls went with the caps.
func _assert_new_corridor_with_open_ends() -> void:
	var corridor := floor4.get_node_or_null(Floor4CorridorShell.ROOT) as Node3D
	assert_not_null(corridor, "Floor4 built the new corridor")
	if corridor == null:
		return
	assert_true(corridor.is_visible_in_tree(), "new corridor shown")
	assert_false((floor4.get_node("Corridor/Floor/Mesh") as Node3D).visible, "PS1 floor slab hidden")
	for cap: String in ["WestEnd/G5EndWest", "EastEnd/G5EndEast"]:
		assert_false((floor4.get_node("Corridor/" + cap) as Node3D).is_visible_in_tree(), cap + " hidden with its cap")


func test_every_chapter_plays_on_the_new_corridor() -> void:
	for chapter in range(1, 5):
		var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate()
		var chapter_floor := scene.get_node_or_null("Floor4")
		assert_not_null(chapter_floor, "chapter %d has Floor4" % chapter)
		if chapter_floor != null:
			assert_eq(chapter_floor.scene_file_path, FLOOR, "chapter %d instances floor4.tscn" % chapter)
			assert_eq(chapter_floor.get("upgraded_corridor"), true, "chapter %d keeps the new corridor on" % chapter)
		scene.free()


func test_real_player_walks_the_corridor_down_the_main_stairs() -> void:
	_assert_new_corridor_with_open_ends()
	var route: Array[Vector3] = [
		Vector3(20, 0.03, 3), Vector3(10, 0.03, 3), Vector3(1, 0.03, 3), Vector3(-0.5, 0, 2),
		Vector3(-3.8, 0, 0.6), Vector3(-3.8, -1.65, -5.4), Vector3(-1.2, -1.65, -5.4),
		Vector3(-1.2, -3.3, 0.5), Vector3(-0.5, -3.3, 2), Vector3(3, -3.3, 2),
	]
	var labels: Array[String] = ["corridor 20", "corridor 10", "west end", "main landing", "4A top", "4A turn",
		"4B top", "floor3 landing", "floor3 hall link", "floor3 hall"]
	if not await _walk(route, labels):
		return
	assert_true(player.is_on_floor(), "walking on floor 3")
	assert_true(absf(player.position.y + 3.3) < 0.1, "down one storey: feet=%s" % player.position)


func test_fire_door_holds_then_opens_onto_the_fire_stairs() -> void:
	_assert_new_corridor_with_open_ends()
	if not await _walk([Vector3(40, 0.03, 3), Vector3(43.2, 0.03, 2)], ["corridor 40", "east end"]):
		return
	# Shut, the fire door stops him at the end of the corridor.
	for frame in 120:
		await tree.physics_frame
		_step(Vector3.RIGHT)
	assert_true(player.position.x < 44.0, "shut fire door holds: feet=%s" % player.position)
	campus.set_fire_door_open(true)
	await tree.physics_frame
	var route: Array[Vector3] = [Vector3(45.2, 0, 2), Vector3(45.2, 0, 0.4), Vector3(45.2, -1.65, -5.4),
		Vector3(47.8, -1.65, -5.4), Vector3(47.8, -3.3, 0.5)]
	if not await _walk(route, ["fire door", "4A top", "4A turn", "4B top", "floor3 landing"]):
		return
	assert_true(player.is_on_floor() and absf(player.position.y + 3.3) < 0.1, "floor 3 landing: feet=%s" % player.position)
