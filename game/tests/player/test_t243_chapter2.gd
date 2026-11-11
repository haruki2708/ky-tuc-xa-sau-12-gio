extends TestCase
## T-243 (D-161, D-162): Tran Trung's body in chapter 2, measured in chapter 2 as it plays.
## - The player has the body; the balcony door is used by hand as in chapter 1 (T-242).
## - The bathroom door stays round 4's swollen door: no hand swings it, three shoves open it.

const CHAPTER := "res://scenes/main/chapter2.tscn"

var world: Node3D
var chapter: Node3D
var director: Chapter2Director
var room: Node3D
var player: CharacterBody3D
var body: PlayerBody


func before_each() -> void:
	world = Node3D.new()
	tree.root.add_child(world)


func after_each() -> void:
	Input.action_release("interact")
	tree.paused = false
	world.queue_free()
	await wait_frames(2)
	GameState.reset()
	RuleSystem.reset()


func _open_chapter2() -> void:
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	chapter = (load(CHAPTER) as PackedScene).instantiate() as Node3D
	director = chapter.get_node("Chapter2Director") as Chapter2Director
	director.auto_start = false
	world.add_child(chapter)
	await wait_frames(3)
	room = chapter.get_node("Floor4/Room407") as Node3D
	player = chapter.get_node("Player") as CharacterBody3D
	body = player.get("body") as PlayerBody
	player.set_physics_process(false)


func test_chapter_2_has_the_body() -> void:
	await _open_chapter2()
	assert_not_null(body, "chapter 2's player has the body")
	assert_true(body != null and body.get_parent() == player, "the body rides the player")
	assert_not_null(HingedDoor.of(room.get_node("Extension/BalconyDoor")), "the balcony door is used by hand")


## D-162: round 4's swollen bathroom door is never opened by hand; three shoves open it, as before.
func test_the_bathroom_door_stays_the_stuck_one() -> void:
	await _open_chapter2()
	var door := room.get_node("Extension/BathroomDoor") as Node3D
	assert_true(HingedDoor.of(door) == null, "no HingedDoor on the bathroom door")
	var stuck := door.get_node_or_null("StuckDoor") as StuckDoor
	assert_not_null(stuck, "round 4's stuck door is there")
	if stuck == null:
		return
	director._bathroom_door(false)
	assert_false(door.get("is_open"), "round 4: shut")
	assert_true(stuck.enabled, "and stuck")
	var opened := [false]
	stuck.opened.connect(func() -> void: opened[0] = true)
	for shove: int in 3:
		assert_false(opened[0], "not open before shove %d" % (shove + 1))
		stuck.interact(player)
		await tree.physics_frame
	assert_true(opened[0] and door.get("is_open"), "the third shove opens it")
	assert_eq(stuck.bash_count, 3, "three shoves")
