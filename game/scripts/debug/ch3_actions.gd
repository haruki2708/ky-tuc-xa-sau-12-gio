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
	var target := world.get_node_or_null(str(point.anchor)) as Node3D
	if actor == null or target == null: return result("SKIP", "Player/route anchor missing: " + str(point.anchor))
	var map := actor.get_world_3d().navigation_map
	if NavigationServer3D.map_get_iteration_id(map) == 0: return result("SKIP", "T-183 navigation map not synchronized")
	var path := NavigationServer3D.map_get_path(map, actor.global_position, target.global_position, true)
	if not POLICY.path_reaches(path, target.global_position): return result("FAIL", "navmesh cannot reach " + str(point.anchor))
	for guard_path: String in profile.get("bindings", {}).get("guard_paths", []):
		if world.get_node_or_null(guard_path) == null: return result("SKIP", "guard binding missing: " + guard_path)
	if not allow_guard and not POLICY.avoids_guards(path, guard_positions()): return result("FAIL", "route enters guard warning radius")
	var deadline := Time.get_ticks_msec() + int(float(point.get("timeout", 180.0)) * 1000.0)
	for next: Vector3 in path:
		while is_instance_valid(actor) and actor.global_position.distance_to(next) > 0.6:
			if _cancelled or Time.get_ticks_msec() >= deadline:
				release_movement()
				return result("FAIL", "walk cancelled/timed out: " + str(point.anchor))
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
	return result("PASS", "navmesh reached " + str(point.anchor))


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
	var target := world.get_node_or_null(str(spec.get("path", "")))
	if target == null or not target.has_method(str(spec.get("method", ""))): return result("SKIP", "action API unavailable: " + key)
	if not spec.get("verify") is Dictionary: return result("FAIL", "action requires state acknowledgement: " + key)
	var args: Array = []
	for value: Variant in spec.get("args", []): args.append(player_node() if value is String and value == "$player" else value)
	target.callv(spec.method, args)
	var until := Time.get_ticks_msec() + 3000
	while not acknowledged(spec.verify, target) and Time.get_ticks_msec() < until and not _cancelled: await get_tree().process_frame
	return result("PASS" if acknowledged(spec.verify, target) else "FAIL", "action acknowledgement: " + key)


static func acknowledged(check: Dictionary, target: Node = null) -> bool:
	if not check.has("equals"): return false
	var value: Variant = GameState.get_flag(StringName(check.flag), null) if check.has("flag") else target.get(str(check.get("property", ""))) if is_instance_valid(target) else null
	return preload("res://scripts/debug/ch1v2_actions.gd")._same(value, check.equals)
