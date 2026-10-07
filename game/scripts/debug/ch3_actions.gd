extends "res://scripts/debug/chapter_actions.gd"
## Real player input follows navigation paths. Never teleports the player.

const POLICY := preload("res://scripts/debug/ch3_policy.gd")
var profile: Dictionary = {}
var hits: int = 0
var stamina: float = 1.0
var exhausted: bool = false
var zombies: Array[Node3D] = []
var companions: Dictionary = {}
var swings: int = 0
var bar_received: bool = false


func _ready() -> void:
	super._ready()
	EventBus.bar_picked.connect(func(value: int) -> void: hits = value; bar_received = true)
	EventBus.bar_swung.connect(func(_hit: bool, value: int) -> void: hits = value; swings += 1)
	EventBus.bar_broken.connect(func() -> void: hits = 0)
	EventBus.stamina_changed.connect(func(value: float, tired: bool) -> void: stamina = value; exhausted = tired)
	EventBus.zombie_woke.connect(func(zombie: Node3D) -> void:
		if zombie not in zombies: zombies.append(zombie))
	EventBus.companion_state_changed.connect(func(member: StringName, state: StringName) -> void:
		if state == &"joined": companions[member] = true)
	EventBus.player_failed.connect(func(_reason: StringName) -> void: cancel())


func release_movement() -> void:
	for action in ["move_forward", "sprint", "crouch"]: Input.action_release(action)


func cancel() -> void:
	super.cancel()
	release_movement()


func guard_positions() -> Array[Vector3]:
	var points: Array[Vector3] = []
	for path: String in profile.get("bindings", {}).get("guard_paths", []):
		var guard := world.get_node_or_null(path) as Node3D
		if guard != null: points.append(guard.global_position)
	return points


func walk(point: Dictionary, allow_guard: bool = false) -> Dictionary:
	var actor := player_node() as CharacterBody3D
	var label := str(point.get("anchor", point.get("position", [])))
	if actor == null: return result("FAIL", "Player missing")
	var target_position: Vector3
	if point.has("anchor"):
		var target := world.get_node_or_null(str(point.anchor)) as Node3D
		if target == null: return result("FAIL", "Route anchor missing: " + label)
		target_position = target.global_position
	else:
		var xyz: Array = point.position
		target_position = Vector3(xyz[0], xyz[1], xyz[2])
	var map := actor.get_world_3d().navigation_map
	# The outdoor mesh has hundreds of regions that register over several
	# physics frames after a scene (re)load: wait for them, bounded.
	var path := PackedVector3Array()
	var sync_deadline := Time.get_ticks_msec() + 10000
	while true:
		if NavigationServer3D.map_get_iteration_id(map) != 0:
			path = NavigationServer3D.map_get_path(map, actor.global_position, target_position, true)
			if POLICY.path_reaches(path, target_position): break
		if Time.get_ticks_msec() >= sync_deadline:
			if NavigationServer3D.map_get_iteration_id(map) == 0: return result("SKIP", "T-183 navigation map not synchronized")
			return result("FAIL", "navmesh cannot reach " + label)
		await get_tree().physics_frame
	for guard_path: String in profile.get("bindings", {}).get("guard_paths", []):
		if world.get_node_or_null(guard_path) == null: return result("SKIP", "guard binding missing: " + guard_path)
	if not allow_guard and not POLICY.avoids_guards(path, guard_positions()): return result("FAIL", "route enters guard warning radius")
	var deadline := Time.get_ticks_msec() + int(float(point.get("timeout", 180.0)) * 1000.0)
	for next: Vector3 in path:
		while is_instance_valid(actor) and actor.global_position.distance_to(next) > 0.6:
			if _cancelled or Time.get_ticks_msec() >= deadline:
				release_movement()
				return result("FAIL", "walk cancelled/timed out: " + label)
			if incoming != &"":
				await super.execute({"op": "answer_call"})
				incoming = &""
			if get_tree().paused:
				release_movement()
				await get_tree().process_frame
				continue
			var direction := next - actor.global_position
			actor.rotation.y = atan2(-direction.x, -direction.z)
			Input.action_press("move_forward")
			if stamina > 0.35 and not exhausted: Input.action_press("sprint")
			else: Input.action_release("sprint")
			if point.get("crouch", false): Input.action_press("crouch")
			await strike_blocker()
			await get_tree().physics_frame
	release_movement()
	if not is_instance_valid(actor): return result("FAIL", "player freed during walk")
	return result("PASS", "navmesh reached " + label)


## Each loop and wait is bounded, observes real state, and never changes it.
func step(point: Dictionary) -> Dictionary:
	if point.has("loop"):
		var deadline := Time.get_ticks_msec() + int(float(point.timeout) * 1000.0)
		while not acknowledged(point.until, null, world):
			for leg: Dictionary in point.loop:
				if _cancelled or Time.get_ticks_msec() >= deadline: return result("FAIL", "route loop cancelled/timed out")
				var outcome := await step(leg)
				if outcome.status != "PASS": return outcome
				if acknowledged(point.until, null, world): break
		return result("PASS", "route loop acknowledged")
	var outcome := await walk(point)
	if outcome.status != "PASS": return outcome
	if point.has("action"):
		outcome = await perform(point.action)
		if outcome.status != "PASS": return outcome
	var started := Time.get_ticks_msec()
	var seconds := float(point.get("wait_seconds", 0.0))
	var limit := float(point.get("wait_timeout", seconds + 3.0))
	while true:
		if _cancelled: return result("FAIL", "waypoint wait cancelled")
		var elapsed := (Time.get_ticks_msec() - started) / 1000.0
		if elapsed >= seconds and (not point.has("wait_for") or acknowledged(point.wait_for, null, world)): break
		if elapsed > limit: return result("FAIL", "waypoint acknowledgement timed out")
		await get_tree().process_frame
	return outcome


func strike_blocker() -> void:
	var actor := player_node() as CharacterBody3D
	if actor == null or hits <= 0: return
	var camera := actor.get_viewport().get_camera_3d()
	if camera == null: return
	for zombie: Node3D in zombies:
		if not is_instance_valid(zombie) or not zombie.has_method("is_stunned"): continue
		var offset := zombie.global_position - actor.global_position
		if not POLICY.should_strike(offset.length(), (-actor.global_basis.z).dot(offset.normalized()), zombie.is_stunned(), false, hits, stamina): continue
		var head := zombie.get_node_or_null(str(profile.bindings.bar_head_path)) as Node3D
		if head == null: continue
		camera.look_at(head.global_position)
		var ray := PhysicsRayQueryParameters3D.create(camera.global_position, head.global_position, 0xFFFFFFFF, [actor.get_rid()])
		var hit := actor.get_world_3d().direct_space_state.intersect_ray(ray)
		if hit.is_empty() or not (hit.collider == zombie or zombie.is_ancestor_of(hit.collider)): continue
		var before := swings
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = true
		Input.parse_input_event(event)
		await get_tree().process_frame
		event.pressed = false
		Input.parse_input_event(event)
		var until := Time.get_ticks_msec() + 1000
		while swings == before and Time.get_ticks_msec() < until and not _cancelled: await get_tree().process_frame
		return


## Explicit integration binding, with postcondition; no guessed gameplay flags.
func perform(key: String) -> Dictionary:
	var spec: Variant = profile.get("actions", {}).get(key)
	if not spec is Dictionary: return result("SKIP", "action not bound: " + key)
	if _cancelled or not is_instance_valid(world): return result("FAIL", "action cancelled/world missing: " + key)
	var target := world.get_node_or_null(str(spec.get("path", "")))
	if target == null or not target.has_method(str(spec.get("method", ""))): return result("SKIP", "action API unavailable: " + key)
	if not spec.get("verify") is Dictionary: return result("FAIL", "action requires state acknowledgement: " + key)
	if spec.has("max_distance"):
		var actor := player_node()
		if actor == null or not target is Node3D or actor.global_position.distance_to(target.global_position) > float(spec.max_distance):
			return result("FAIL", "action out of reach: " + key)
	var args: Array = []
	for value: Variant in spec.get("args", []): args.append(player_node() if value is String and value == "$player" else value)
	target.callv(spec.method, args)
	var until := Time.get_ticks_msec() + 3000
	while not acknowledged(spec.verify, target, world) and Time.get_ticks_msec() < until and not _cancelled: await get_tree().process_frame
	return result("PASS" if acknowledged(spec.verify, target, world) else "FAIL", "action acknowledgement: " + key)


static func acknowledged(check: Dictionary, target: Node = null, root: Node = null) -> bool:
	if not check.has("equals"): return false
	if check.has("path"):
		if not is_instance_valid(root): return false
		target = root.get_node_or_null(str(check.path))
	var value: Variant
	if check.has("flag"):
		value = GameState.get_flag(StringName(check.flag), null)
	else:
		value = target
		for property: String in str(check.get("property", "")).split(":"):
			if not value is Object or not is_instance_valid(value) or property.is_empty(): return false
			value = value.get(property)
	return preload("res://scripts/debug/ch1v2_actions.gd")._same(value, check.equals)
