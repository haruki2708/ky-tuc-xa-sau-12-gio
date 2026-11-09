extends TestCase
## T-228: validate actual chapter placements, including the director's resized pick areas.

const CHAPTER := preload("res://scenes/main/chapter1.tscn")
const READABLE := preload("res://scenes/interaction/readable.tscn")
const ROOT := "Floor4/Room407/Anchors/"
const TARGETS := {
	"VietLocker/SearchVietLocker": HandTarget.Grip.HOOK,
	"PhucMattress/SearchPhucMattress": HandTarget.Grip.HOOK,
	"TrashBin/SearchTrashBin": HandTarget.Grip.HOOK,
	"WallKnock406/WallKnock406": HandTarget.Grip.GRIP,
	"PowerStrip/PowerStripInteract/Switch1": HandTarget.Grip.PINCH,
	"PowerStrip/PowerStripInteract/Switch2": HandTarget.Grip.PINCH,
	"PowerStrip/PowerStripInteract/Switch3": HandTarget.Grip.PINCH,
	"LanBlueEnd/Cable_blue": HandTarget.Grip.PINCH,
	"LanGrayEnd/Cable_gray": HandTarget.Grip.PINCH,
	"LanWallPort/LanSocket": HandTarget.Grip.PINCH,
	"DeskLampSwitch/DeskLampSwitch": HandTarget.Grip.PINCH,
}
## Owner approved keeping existing prop heights on 2026-11-01.
## Explicit exceptions, not a relaxed height limit for every target.
const HEIGHT_EXCEPTIONS := {
	"Switch1": Vector2(0.02, 0.10),
	"Switch2": Vector2(0.02, 0.10),
	"Switch3": Vector2(0.02, 0.10),
	"Cable_blue": Vector2(0.005, 0.04),
	"Cable_gray": Vector2(0.005, 0.04),
	"SearchTrashBin": Vector2(0.15, 0.20),
	"Ch1KhoaNote": Vector2(0.03, 0.08),
}

var world: Node3D
var previous_mouse: Input.MouseMode


func before_each() -> void:
	previous_mouse = Input.mouse_mode
	world = Node3D.new()
	tree.root.add_child(world)


func after_each() -> void:
	tree.paused = false
	world.queue_free()
	await wait_frames(2)
	Input.mouse_mode = previous_mouse
	GameState.reset()
	RuleSystem.reset()


func test_targets_at_actual_chapter_placements() -> void:
	var chapter := CHAPTER.instantiate()
	var director := chapter.get_node("Chapter1Director") as Chapter1Director
	director.auto_start = false
	Chapter1Director.resume_checkpoint = &""
	world.add_child(chapter)
	await wait_frames(2)
	var floor_y: float = chapter.get_node("Floor4/Room407").global_position.y
	var player := chapter.get_node("Player")
	assert_true(player.get("body") is PlayerBody, "D-151: chapter 1's player has Tran Trung's body")
	for path: String in TARGETS:
		_check_target(chapter.get_node(ROOT + path) as Interactable, TARGETS[path], false, floor_y)
	_check_target(chapter.get_node("Chapter1Director/DatLocker") as Interactable, HandTarget.Grip.PINCH, false, floor_y)
	_check_target(chapter.get_node("Floor4/Door407/Pivot/DoorLatch407") as Interactable, HandTarget.Grip.GRIP, false, floor_y)
	var papers: int = 0
	for entry: Array in chapter.PAPERS:
		var paper := chapter.get_node(String(entry[0]).to_pascal_case()) as Interactable
		_check_target(paper, HandTarget.Grip.PINCH, true, floor_y)
		_check_paper_edge(paper)
		papers += 1
	assert_eq(papers, 8, "all chapter papers are covered")
	var note := director._place_khoa_note(chapter.get_node(ROOT + "WallKnock406")) as Interactable
	_check_target(note, HandTarget.Grip.PINCH, true, floor_y)
	_check_paper_edge(note)
	var mattress := chapter.get_node(ROOT + "PhucMattress/SearchPhucMattress") as Interactable
	var model := chapter.get_node(ROOT + "PhucMattress/Pivot/MattressPhuc") as Node3D
	var bounds: AABB = model.global_transform * Room407Furnish.local_bounds(model)
	var grip_point := mattress.hand_target().global_position
	assert_true(grip_point.distance_to(grip_point.clamp(bounds.position, bounds.end)) <= 0.005,
		"mattress grip must touch the actual model, not float at the picking area")
	# Core triggers and climbing/hiding remain immediate; no marker is added here.
	for node: Node in chapter.find_children("*", "Area3D", true, false):
		if node is StoryTrigger or node is HideSpot:
			assert_eq(node.hand_target(), null, String(node.get_path()))
	# The room door is owned by the level; its handles take the hand once the body is on
	# (Protagonist.attach, D-151). The latch inside its subtree is a thing of its own, so the door
	# reaches for a lever, never for the latch's marker.
	var door := chapter.get_node("Floor4/Door407") as Interactable
	var latch := chapter.get_node("Floor4/Door407/Pivot/DoorLatch407") as Interactable
	for from: Vector3 in [Vector3.INF, latch.hand_target().global_position]:
		var marker := door.hand_target(from)
		assert_not_null(marker, "the door has its lever markers")
		if marker != null:
			assert_true(marker != latch.hand_target() and marker.lever != null
				and String(marker.lever.name).begins_with("Lever"), "the door takes a lever, not the latch")


func test_paper_marker_resizes_without_cross_instance_changes() -> void:
	var small := READABLE.instantiate()
	var large := READABLE.instantiate()
	small.size = Vector2(0.09, 0.06)
	large.size = Vector2(0.21, 0.30)
	world.add_child(small)
	world.add_child(large)
	_check_paper_edge(small)
	_check_paper_edge(large)
	var old_position: Vector3 = large.hand_target().position
	small.size = Vector2(0.01, 0.01)
	small.pick_depth = 0.15
	_check_paper_edge(small)
	assert_eq(large.hand_target().position, old_position, "resizing a card must not move another grip")
	assert_eq(small.hand_target().basis, Basis.IDENTITY, "paper grip preserves the sheet axes")


func test_shared_switch_and_excluded_interactions() -> void:
	for scene_name: String in ["light_switch", "desk_lamp_switch"]:
		var switch := load("res://scenes/interaction/%s.tscn" % scene_name).instantiate() as Interactable
		var light := OmniLight3D.new()
		world.add_child(light)
		switch.set("light", light)
		world.add_child(switch)
		switch.position.y = 1.35
		_check_target(switch, HandTarget.Grip.PINCH, false, 0.0)
	for scene_name: String in ["bunk_spot", "hide_spot", "gag_spot"]:
		var spot := load("res://scenes/interaction/%s.tscn" % scene_name).instantiate() as Interactable
		world.add_child(spot)
		assert_eq(spot.hand_target(), null, scene_name)


func _check_paper_edge(paper: Interactable) -> void:
	var target := paper.hand_target()
	assert_not_null(target, paper.name)
	if target == null:
		return
	var size: Vector2 = paper.get("size")
	assert_true(absf(target.position.x - maxf(0.0, size.x * 0.5 - 0.015)) < 0.0001, "right edge: " + paper.name)
	assert_true(absf(target.position.y) < 0.0001, "half height: " + paper.name)
	assert_true(target.position.z <= 0.004, "grip on paper face, not inflated pick depth: " + paper.name)


func _check_target(prop: Interactable, grip: HandTarget.Grip, pick_up: bool, floor_y: float) -> void:
	assert_not_null(prop)
	if prop == null:
		return
	var label := String(prop.get_path())
	var target := prop.hand_target()
	assert_not_null(target, label)
	if target == null:
		return
	assert_eq(target.get_parent(), prop, label + " direct child")
	assert_eq(target.grip, grip, label + " grip")
	assert_eq(target.pick_up, pick_up, label + " pick_up")
	var count: int = 0
	for child: Node in prop.get_children():
		if child is HandTarget:
			count += 1
	assert_eq(count, 1, label + " single grip")
	var closest: float = INF
	for child: Node in prop.get_children():
		var collision := child as CollisionShape3D
		if collision == null or not collision.shape is BoxShape3D:
			continue
		var half: Vector3 = (collision.shape as BoxShape3D).size * 0.5
		var local: Vector3 = collision.to_local(target.global_position)
		var nearest: Vector3 = collision.to_global(local.clamp(-half, half))
		closest = minf(closest, nearest.distance_to(target.global_position))
	# Owner approved 11 cm only for the mattress on 2026-11-01; its real surface is checked above.
	var tolerance: float = 0.11 if prop.name == &"SearchPhucMattress" else 0.05
	assert_true(closest <= tolerance + 0.00001, "%s grip distance %.4f m" % [label, closest])
	var height: float = target.global_position.y - floor_y
	var limits: Vector2 = HEIGHT_EXCEPTIONS.get(String(prop.name), Vector2(0.2, 1.9))
	assert_true(height >= limits.x - 0.0001 and height <= limits.y + 0.0001,
		"%s grip height %.4f m outside %s" % [label, height, limits])

