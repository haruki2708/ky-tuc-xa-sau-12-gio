extends TestCase
## D-151: Tran Trung's body in chapter 1 (T-227). Only chapter 1 has it; every thing chapter 1 uses
## by hand can be reached by the body from somewhere the player's capsule can stand (D-152: leaning
## over furniture, crouched, up on the toes) and the hand really gets there; dying puts the body
## away; lying in bed at the start keeps it.

const CHAPTERS := ["res://scenes/main/chapter1.tscn", "res://scenes/main/chapter2.tscn",
	"res://scenes/main/chapter3.tscn", "res://scenes/main/chapter4.tscn"]
## Standing spots tried around each HandTarget: rings this far out (metres) at RING_STEPS headings.
const RINGS: Array[float] = [0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.9, 1.0]
const RING_STEPS := 48

var world: Node3D
var chapter: Node3D
var director: Chapter1Director
var player: CharacterBody3D
var body: PlayerBody


func before_each() -> void:
	world = Node3D.new()
	tree.root.add_child(world)


func after_each() -> void:
	tree.paused = false
	world.queue_free()
	await wait_frames(2)
	GameState.reset()
	RuleSystem.reset()


func _open_chapter1() -> void:
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	chapter = (load(CHAPTERS[0]) as PackedScene).instantiate() as Node3D
	director = chapter.get_node("Chapter1Director") as Chapter1Director
	director.auto_start = false
	world.add_child(chapter)
	await wait_frames(3)
	player = chapter.get_node("Player") as CharacterBody3D
	body = player.get("body") as PlayerBody


## Puts the player, standing, on the first spot around `thing`'s HandTarget where its capsule fits and
## the body can reach it, facing it. False if there is none.
func _stand_within_reach(thing: Interactable) -> bool:
	var shape := player.get("body_shape") as CollisionShape3D
	var space := player.get_world_3d().direct_space_state
	var goal: Vector3 = thing.hand_target().global_position
	for radius: float in RINGS:
		for step in RING_STEPS:
			var heading: float = TAU * step / RING_STEPS
			var spot := Vector3(goal.x + radius * sin(heading), 0.02, goal.z + radius * cos(heading))
			var query := PhysicsShapeQueryParameters3D.new()
			query.shape = shape.shape
			query.transform = Transform3D(Basis.IDENTITY, spot + shape.position + Vector3.UP * 0.04)
			query.collision_mask = player.collision_mask
			query.exclude = [player.get_rid()]
			if not space.intersect_shape(query, 1).is_empty():
				continue
			player.global_position = spot
			var toward := goal - spot
			player.global_rotation = Vector3(0.0, atan2(-toward.x, -toward.z), 0.0)
			await tree.physics_frame
			if body.can_reach(thing):
				return true
	return false


func _freeze_player() -> void:
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)


## T-243 (D-161), T-249 (D-165): chapters 1, 2 and 3 have the body; 4 not yet.
func test_chapters_one_to_three_turn_the_body_on() -> void:
	for index in CHAPTERS.size():
		var scene := (load(CHAPTERS[index]) as PackedScene).instantiate()
		assert_eq(scene.get("protagonist_body"), index <= 2, CHAPTERS[index])
		scene.free()
	await _open_chapter1()
	assert_not_null(body, "chapter 1's player has the body")
	assert_true(body != null and body.get_parent() == player, "the body rides the player")
	# The mirrors show the body's mirror copy, not their PS1 stand-in.
	var mirrors: int = 0
	for mirror: Node in chapter.get_node("Floor4/Room407").find_children("*", "", true, false):
		if mirror.has_method("set_lag") and mirror.has_node("ReflectionBody"):
			mirrors += 1
			assert_eq(mirror.get("follow"), player, "mirror follows the player: " + mirror.name)
			for mesh: MeshInstance3D in mirror.get_node("ReflectionBody").find_children("*", "MeshInstance3D", true, false):
				assert_false(mesh.visible, "PS1 reflection body hidden: " + String(mesh.get_path()))
	assert_true(mirrors >= 1, "room 407 has its mirrors")


## With a body a thing used by hand needs the HandTarget within reach (player.gd hides the prompt
## otherwise), so a thing out of reach from everywhere would block the chapter.
func test_every_hand_thing_can_be_reached_from_a_standing_spot() -> void:
	await _open_chapter1()
	director._place_khoa_note(chapter.get_node("Floor4/Room407/Anchors/WallKnock406"))
	await wait_frames(2)
	_freeze_player()
	var checked: int = 0
	var failed: Array[String] = []
	var kinds: Dictionary = {}
	for node: Node in chapter.find_children("*", "", true, false):
		var thing := node as Interactable
		if thing == null or not thing.is_visible_in_tree() or thing is HideSpot or thing.hand_target() == null:
			continue
		checked += 1
		if await _stand_within_reach(thing):
			# T-239: the grip the body itself takes from here (a paper's edges, a door's side).
			var kind: StringName = body._reach_kind(thing.hand_target(body._reach_from(), body._reach_rank))
			kinds[kind] = int(kinds.get(kind, 0)) + 1
		else:
			failed.append("%s (hand at %s)" % [thing.get_path(), thing.hand_target().global_position])
	assert_true(checked >= 20, "chapter 1 has its hand things (%d)" % checked)
	assert_true(failed.is_empty(), "out of reach from every standing spot: " + ", ".join(failed))
	print("D152_REACH: %d hand things reachable in chapter 1 %s" % [checked, kinds])


## D-152, as T-241 changed it (owner, 10/11): standing at a desk, bending down to the floor, up on
## the toes over a locker: the hand gets to the thing at the touch, it is used, and the body never
## crouches for it (D-152's lean of 75 degrees and its crouch are gone).
func test_standing_bending_down_and_toes_put_the_hand_on_the_thing() -> void:
	await _open_chapter1()
	director._place_khoa_note(chapter.get_node("Floor4/Room407/Anchors/WallKnock406"))
	await wait_frames(2)
	_freeze_player()
	var seen: Dictionary = {}
	for name: String in ["Ch1VietPhoto", "Ch1DatNote", "Ch1TeamPhoto", "Ch1PhucCard", "Ch1PhucSchedule", "Ch1KhoaNote"]:
		var thing := chapter.get_node(name) as Interactable
		assert_true(await _stand_within_reach(thing), name + " within reach")
		# T-239: the grip the body itself takes from here (a paper has one per edge).
		var kind: StringName = body._reach_kind(thing.hand_target(body._reach_from(), body._reach_rank))
		seen[kind] = true
		var was_crouched: bool = bool(player.get("crouched"))
		body.perform(thing)
		assert_true(body.acting, name + " reaching")
		var closest: float = INF
		for frame in range(int(PlayerBody.CONTACT * 60.0) + 6):
			await tree.physics_frame
			closest = minf(closest, body._hand_tip().distance_to(body._marker.global_position))
		assert_false(bool(player.get("crouched")), name + ": the body does not crouch for it")
		assert_true(closest <= 0.06 + body.finger_reach * body._scale(),
			"%s (%s): the hand gets to it (%.3f m)" % [name, kind, closest])
		# Papers open their document; close it so the paper is put back and the hand comes home.
		for frame in range(150):
			await tree.physics_frame
			if not body.acting:
				break
			if body._reading:
				# As the player closing the reading view (it pauses the game while open).
				(chapter.get_node("DocumentView") as Node).call("close_view")
				tree.paused = false
		assert_false(body.acting, name + " done")
		player.set_physics_process(true)
		await tree.physics_frame
		await tree.physics_frame
		player.set_physics_process(false)
		if not was_crouched:
			assert_false(bool(player.get("crouched")), name + " stands back up")
	assert_true(seen.has(&"near") and seen.has(&"stoop") and seen.has(&"up"), "standing, bent down and tiptoe reaches covered: %s" % [seen.keys()])
	assert_false(seen.has(&"kneel") or seen.has(&"lean"), "no crouch or deep lean of the body's own: %s" % [seen.keys()])


func test_dying_puts_the_body_away_and_lets_go_of_a_paper() -> void:
	await _open_chapter1()
	var paper := chapter.get_node("Ch1DatCard") as Interactable
	_freeze_player()
	assert_true(await _stand_within_reach(paper), "the card is within reach for this test")
	body.perform(paper)
	for frame in range(20):
		await tree.physics_frame
	assert_true(body.acting, "reaching for the card")
	EventBus.player_death_started.emit(&"manager_kill")
	await tree.physics_frame
	assert_false(body.acting, "the hand action stops")
	assert_false(body.visible, "the body is put away for the death camera")
	assert_true(body.is_dead(), "and stays away")
	assert_false(body.can_handle(paper), "no more hand actions")
	for mesh: MeshInstance3D in paper.find_children("*", "MeshInstance3D", true, false):
		assert_true(mesh.visible, "the card is back where it lay: " + mesh.name)
	await tree.physics_frame
	assert_false(body.visible, "still hidden a frame later")


func test_lying_in_bed_at_the_start_shows_the_body_in_bed() -> void:
	await _open_chapter1()
	director.lie_on(Chapter1Director.TRUNG_BED)
	for frame in range(4):
		await tree.physics_frame
	assert_true(player.is_hidden(), "the player lies in Trung's bed")
	assert_true(body.in_bed(), "the body lies in the bed")
	assert_true(body.visible, "and shows there")
	director.get_up()
	for frame in range(4):
		await tree.physics_frame
	assert_false(body.in_bed(), "up again")
	assert_true(body.visible, "standing body shows")
