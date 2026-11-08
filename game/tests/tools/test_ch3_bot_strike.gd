extends TestCase
## Real input and weapon/head hitboxes; no chapter bot or director is run.

func test_bot_strikes_dressed_zombie_heads_with_real_mouse_input() -> void:
	var saved := GameState.to_dict()
	var mouse := Input.mouse_mode
	var world := Node3D.new()
	tree.root.add_child(world)
	var player := load("res://scenes/player/player.tscn").instantiate() as CharacterBody3D
	player.name = "Player"
	world.add_child(player)
	player.set_physics_process(false)
	var helper := preload("res://scripts/debug/ch3_actions.gd").new()
	helper.world = world
	helper.profile = {"bindings": {"bar_head_path": "HeadHitbox"}}
	world.add_child(helper)
	for number in range(1, 11):
		var zombie := load("res://scenes/entity/zombie.tscn").instantiate() as Zombie
		zombie.position = Vector3(0, 0, -1.4)
		world.add_child(zombie)
		zombie.set_physics_process(false)
		zombie.set_body(load("res://assets/models/campus/zombie_%02d.tscn" % number))
		zombie.get_node("HeadHitbox").global_position = zombie.head_position()
		zombie.wake()
		player.give_bar(8)
		for frame in 3: await tree.physics_frame
		await helper.strike_blocker()
		for frame in 3: await tree.physics_frame
		assert_true(zombie.is_stunned(), "bot must hit dressed head %02d" % number)
		assert_eq(helper.hits, 7, "a real head hit consumes one bar use")
		zombie.free()
	world.queue_free()
	await wait_frames(3)
	Input.mouse_mode = mouse
	GameState.from_dict(saved)
