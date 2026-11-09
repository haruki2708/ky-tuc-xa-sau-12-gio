extends TestCase
## T-231: validate real placements after chapter directors finish setup.

const ROOT := "Floor4/Room407/Anchors/"
const SPECS := {
	"readable": [HandTarget.Grip.PINCH, true],
	"search_spot": [HandTarget.Grip.HOOK, false],
	"wall_knock": [HandTarget.Grip.GRIP, false],
	"power_strip_switch": [HandTarget.Grip.PINCH, false],
	"lan_cable": [HandTarget.Grip.PINCH, false],
	"lan_socket": [HandTarget.Grip.PINCH, false],
	"light_switch": [HandTarget.Grip.PINCH, false],
	"door_latch": [HandTarget.Grip.GRIP, false],
	"puzzle_station": [HandTarget.Grip.PINCH, false],
	"carry_item": [HandTarget.Grip.PINCH, false],
	"shower_screen": [HandTarget.Grip.PINCH, false],
	"shower_choice": [HandTarget.Grip.PINCH, false],
	"stuck_door": [HandTarget.Grip.GRIP, false],
	"iron_bar": [HandTarget.Grip.GRIP, false],
	"bed_slat": [HandTarget.Grip.HOOK, false],
}
## T-228 exceptions approved on 2026-11-01 and confirmed in D-142.
const SHARED_HEIGHTS := {
	"Switch1": Vector2(0.02, 0.10), "Switch2": Vector2(0.02, 0.10), "Switch3": Vector2(0.02, 0.10),
	"Cable_blue": Vector2(0.005, 0.04), "Cable_gray": Vector2(0.005, 0.04),
	"SearchTrashBin": Vector2(0.15, 0.20),
}
## Owner approved these existing placements on 2026-11-07.
const NEW_HEIGHTS := {
	"Carry_towel": Vector2(2.14, 2.19),
	"SearchCeiling": Vector2(2.90, 2.95),
	"SearchVent": Vector2(2.33, 2.38),
}
const COMMON_COUNTS := {
	"readable": 8, "search_spot": 3, "wall_knock": 1, "power_strip_switch": 3,
	"lan_cable": 2, "lan_socket": 1, "light_switch": 1, "door_latch": 1, "puzzle_station": 1,
}

var chapter: Node3D
var previous_mouse: Input.MouseMode


func before_each() -> void:
	previous_mouse = Input.mouse_mode
	Chapter1Director.resume_checkpoint = &""
	GameState.reset()
	RuleSystem.reset()


func after_each() -> void:
	tree.paused = false
	if is_instance_valid(chapter):
		chapter.queue_free()
	await wait_frames(3)
	Input.mouse_mode = previous_mouse
	GameState.reset()
	RuleSystem.reset()


func test_chapter2_actual_hand_targets_and_exclusions() -> void:
	await _load_chapter(2)
	var counts := COMMON_COUNTS.duplicate()
	counts.merge({"carry_item": 3, "shower_screen": 1, "shower_choice": 2, "stuck_door": 1})
	_check_inventory(counts)
	for path: String in ["RagSpot/Carry_rag", "TowelSpot/Carry_towel", "ShirtSpot/Carry_shirt",
			"ShowerScreen/Wipe", "ShowerYes/Choice", "ShowerNo/Choice"]:
		_check_known_target(ROOT + path)
	_check_known_target("Floor4/Room407/Extension/BathroomDoor/StuckDoor")
	for bed: int in [1, 2, 4]:
		assert_eq(chapter.get_node(ROOT + "Gag%d/GagSpot" % bed).hand_target(), null)
	var stall := chapter.get_node(ROOT + "ShowerStall/ShowerStallArea")
	assert_false(stall is Interactable, "standing in the shower is not a hand action")
	assert_true(_markers(stall).is_empty(), "no marker on a standing region")


func test_chapter3_actual_hand_targets_after_bars_settle() -> void:
	await _load_chapter(3)
	var counts := COMMON_COUNTS.duplicate()
	counts["iron_bar"] = 7
	_check_inventory(counts)
	_check_bars("Chapter3Director")
	_check_core_uses(["FireKey", "FireDoor", "Extinguisher2F", "FireAlarm1F"])


func test_chapter4_actual_hand_targets_and_hospital_exclusions() -> void:
	await _load_chapter(4)
	var counts := COMMON_COUNTS.duplicate()
	counts.erase("puzzle_station")
	counts["search_spot"] = 6
	counts["iron_bar"] = 7
	counts["bed_slat"] = 3
	_check_inventory(counts)
	_check_bars("Chapter4Director")
	for bed: int in [1, 2, 4]:
		_check_known_target("Campus/Anchors/Ch4/Room407/Slat%d/BedSlat%d" % [bed, bed])
	for spot: String in ["Locker", "Ceiling", "Vent"]:
		_check_known_target("Campus/Anchors/Ch4/Room407/Fake%s/Search%s" % [spot, spot])
	_check_core_uses(["FireKey", "FireDoor", "Extinguisher2F",
		"Ch4/ReadingDesk", "Ch4/MapBoard", "Ch4/LibrarianSeat"])
	var back_door := chapter.get_node("Campus/Library/BackDoor/Use_BackDoor") as Interactable
	assert_eq(back_door.hand_target(), null, "core library door is a handoff proposal only")
	var director := chapter.get_node("Chapter4Director") as Chapter4Director
	director._show_hospital()
	assert_not_null(director._hospital)
	assert_true(_markers(director._hospital).is_empty(), "hospital is a cinematic, not a hand interaction")
	for node: Node in director._hospital.find_children("*", "Area3D", true, false):
		assert_false(node is Interactable, "hospital inventory must be revised if hand interactions are added")


func _load_chapter(number: int) -> void:
	chapter = load("res://scenes/main/chapter%d.tscn" % number).instantiate()
	var director := chapter.get_node("Chapter%dDirector" % number) as Chapter1Director
	director.auto_start = false
	tree.root.add_child(chapter)
	# Let deferred campus attachment and physics raycasts settle every iron bar.
	for frame: int in 3:
		await tree.physics_frame
		await tree.process_frame
	assert_eq(chapter.get_node("Player").get("body"), null, "production player has no body")


func _check_inventory(expected: Dictionary) -> void:
	var found: Dictionary = {}
	for node: Node in chapter.find_children("*", "Area3D", true, false):
		var prop := node as Interactable
		if prop == null:
			continue
		if prop is HideSpot or prop is GagSpot or prop is StoryTrigger or prop is Ch3Use:
			assert_eq(prop.hand_target(), null, String(prop.get_path()) + " excluded")
			continue
		if prop == chapter.get_node("Floor4/Door407"):
			assert_eq(prop.hand_target(), null, "room door must not borrow the latch target")
			continue
		var script_name: String = prop.get_script().resource_path.get_file().get_basename()
		assert_true(SPECS.has(script_name), "unclassified interactable: " + String(prop.get_path()))
		if not SPECS.has(script_name):
			continue
		found[script_name] = int(found.get(script_name, 0)) + 1
		_check_prop(prop, script_name)
	assert_eq(found, expected, "real inventory must cover every hand interaction")


func _check_known_target(path: String) -> void:
	var prop := chapter.get_node_or_null(path) as Interactable
	assert_not_null(prop, path)
	if prop != null:
		assert_not_null(prop.hand_target(), path)


func _check_prop(prop: Interactable, script_name: String) -> void:
	var targets := _markers(prop)
	var label := String(chapter.get_path_to(prop))
	assert_eq(targets.size(), 1, label + " exactly one marker")
	var target := prop.hand_target()
	assert_not_null(target, label)
	if target == null:
		return
	assert_eq(target.get_parent(), prop, label + " direct child")
	assert_eq(target.grip, SPECS[script_name][0], label + " grip")
	assert_eq(target.pick_up, SPECS[script_name][1], label + " pick_up")
	var distance: float = INF
	for child: Node in prop.get_children():
		var collider := child as CollisionShape3D
		if collider == null or not collider.shape is BoxShape3D:
			continue
		var half: Vector3 = (collider.shape as BoxShape3D).size * 0.5
		var local := collider.to_local(target.global_position)
		var closest := collider.to_global(local.clamp(-half, half))
		distance = minf(distance, target.global_position.distance_to(closest))
	# Preserve the owner-approved T-228 mattress exception; no new collision exception.
	var tolerance: float = 0.11 if prop.name == &"SearchPhucMattress" else 0.05
	assert_true(distance <= tolerance + 0.00001, "%s collision distance %.4f" % [label, distance])
	var floor_y: float = -9.9 if script_name == "iron_bar" else 0.0
	var height: float = target.global_position.y - floor_y
	var limits: Vector2 = SHARED_HEIGHTS.get(String(prop.name), NEW_HEIGHTS.get(String(prop.name), Vector2(0.2, 1.9)))
	if script_name == "iron_bar":
		# Campus bar spawns share the outdoor ground datum; some rest on fallen props.
		# Owner approved near-floor pickups; the upper reach limit remains unchanged.
		limits = _bar_height_limits(prop)
	assert_true(height >= limits.x - 0.0001 and height <= limits.y + 0.0001,
		"%s height %.4f outside %s" % [label, height, limits])
	if script_name == "readable":
		var size: Vector2 = prop.get("size")
		assert_true(absf(target.position.x - maxf(0.0, size.x * 0.5 - 0.015)) < 0.0001, label + " paper edge")
		assert_true(absf(target.position.y) < 0.0001, label + " paper midpoint")
		assert_eq(target.basis, Basis.IDENTITY, label + " paper axes")


func _check_bars(director_path: String) -> void:
	_check_known_target("Campus/Library/Counter/IronBar")
	var spawns := chapter.get_node("Campus/Anchors/BarSpawns")
	var bars: Array[Node] = []
	for node: Node in chapter.get_node(director_path).get_children():
		if node is Interactable and node.get_script().resource_path == "res://scripts/interaction/iron_bar.gd":
			bars.append(node)
	assert_eq(bars.size(), spawns.get_child_count(), "every bar spawn must be instantiated")
	for spawn: Node3D in spawns.get_children():
		var matches: int = 0
		for bar: Node3D in bars:
			if Vector2(bar.global_position.x, bar.global_position.z).distance_to(
					Vector2(spawn.global_position.x, spawn.global_position.z)) < 0.001:
				matches += 1
				assert_not_null((bar as Interactable).hand_target(), spawn.name)
				print("T231_BAR ", chapter.name, "/", spawn.name, " position=", bar.global_position)
		assert_eq(matches, 1, "one settled bar at " + String(spawn.name))



func _bar_height_limits(bar: Node3D) -> Vector2:
	# The library counter bar is not one of the six director spawns.
	if bar == chapter.get_node("Campus/Library/Counter/IronBar"):
		return Vector2(0.2, 1.9)
	var low_spawns := {
		"B03": Vector2(0.08, 0.12),
		"B02": Vector2(0.01, 0.04), "B04": Vector2(0.01, 0.04),
		"B05": Vector2(0.01, 0.04), "B06": Vector2(0.01, 0.04),
	}
	for spawn: Node3D in chapter.get_node("Campus/Anchors/BarSpawns").get_children():
		if Vector2(bar.global_position.x, bar.global_position.z).distance_to(
				Vector2(spawn.global_position.x, spawn.global_position.z)) < 0.001:
			return low_spawns.get(String(spawn.name), Vector2(0.2, 1.9))
	return Vector2(0.2, 1.9)

func _check_core_uses(paths: Array) -> void:
	for path: String in paths:
		var use := chapter.get_node_or_null("Campus/Anchors/" + path + "/Use_" + path.get_file()) as Ch3Use
		assert_not_null(use, path)
		if use != null:
			assert_eq(use.hand_target(), null, path + " core proposal only")


func _markers(node: Node) -> Array[HandTarget]:
	var result: Array[HandTarget] = []
	for child: Node in node.find_children("*", "Marker3D", true, false):
		if child is HandTarget:
			result.append(child)
	return result
