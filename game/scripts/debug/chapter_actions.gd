extends Node
## Shared semantic actions for chapter bots and frame recordings (T-157).
## Missing components are SKIP; a present component that misbehaves is FAIL.

var world: Node
var raised: bool = false
var holding: bool = false
var incoming: StringName = &""
var choices: Dictionary = {}
var _cancelled: bool = false


func _ready() -> void:
	EventBus.phone_raised.connect(func(value: bool) -> void: raised = value)
	EventBus.breath_held.connect(func(value: bool) -> void: holding = value)
	EventBus.phone_call_incoming.connect(func(id: StringName) -> void: incoming = id)
	EventBus.chat_choice_requested.connect(func(id: StringName, keys: PackedStringArray) -> void: choices[id] = keys)


static func valid(command: Dictionary) -> bool:
	var op: String = str(command.get("op", ""))
	match op:
		"bed":
			var number: Variant = command.get("number")
			return (number is float or number is int) and is_finite(float(number)) and number == floor(number) and number >= 1 and number <= 4
		"leave_bed", "answer_call": return true
		"phone": return command.get("raised") is bool
		"choice":
			var index: Variant = command.get("index")
			return command.get("id") is String and (index is float or index is int) and is_finite(float(index)) and index >= 0 and index == floor(index)
		"puzzle": return command.get("id") is String and not command.id.is_empty()
		"still", "breath":
			var seconds: Variant = command.get("seconds")
			return (seconds is int or seconds is float) and is_finite(float(seconds)) and seconds >= 0 and seconds <= 120
		"goto":
			var point: Variant = command.get("position")
			if not point is Array or point.size() != 3:
				return false
			for value: Variant in point:
				if not (value is int or value is float) or not is_finite(float(value)):
					return false
			return true
	return false


func component(file_name: String) -> Node:
	if not is_instance_valid(world):
		return null
	var nodes: Array[Node] = [world]
	nodes.append_array(world.find_children("*", "", true, false))
	for node: Node in nodes:
		var script: Script = node.get_script()
		if script != null and script.resource_path.get_file() == file_name:
			return node
	return null


func player_node() -> Node3D:
	return world.find_child("Player", true, false) as Node3D if is_instance_valid(world) else null


func bed(number: int) -> Node:
	if not is_instance_valid(world):
		return null
	for node: Node in world.find_children("*", "", true, false):
		var script: Script = node.get_script()
		if script != null and script.resource_path.get_file() == "bunk_spot.gd" and node.get("bed_number") == number:
			return node
	return null


func execute(command: Dictionary) -> Dictionary:
	if not valid(command):
		return result("FAIL", "invalid command: " + str(command))
	_cancelled = false
	var op: String = command.op
	var player := player_node()
	if player == null:
		return result("SKIP", "Player is not integrated")
	match op:
		"goto":
			var point: Array = command.position
			player.global_position = Vector3(point[0], point[1], point[2])
			if player is CharacterBody3D:
				player.velocity = Vector3.ZERO
		"bed", "leave_bed":
			if not player.has_method("lie_on"):
				return result("SKIP", "T-151 Player.lie_on is not integrated")
			var number: int = int(command.get("number", GameState.get_flag(&"player_bed", 0)))
			if op == "bed" and (number < 1 or number > 4 or float(command.number) != number):
				return result("FAIL", "bed number must be 1..4")
			if op == "leave_bed" and number == 0:
				return result("PASS", "already out of bed")
			var spot := bed(number)
			if spot == null:
				return result("SKIP", "bunk_spot %d is not integrated" % number)
			if op == "bed":
				player.lie_on(spot)
			else:
				spot.interact(player)
			var expected: int = number if op == "bed" else 0
			var deadline := Time.get_ticks_msec() + 3000
			while GameState.get_flag(&"player_bed", 0) != expected and Time.get_ticks_msec() < deadline and not _cancelled:
				await get_tree().process_frame
			if GameState.get_flag(&"player_bed", 0) != expected:
				return result("FAIL", "bed action did not update player_bed")
		"phone":
			if component("phone_item.gd") == null:
				return result("SKIP", "T-151 phone_item is not integrated")
			if raised != bool(command.raised):
				_send(&"phone", true)
				await get_tree().process_frame
				_send(&"phone", false)
				await get_tree().process_frame
			if raised != bool(command.raised):
				return result("FAIL", "phone_raised did not acknowledge toggle")
		"answer_call":
			if component("phone_screen.gd") == null:
				return result("SKIP", "T-155 phone_screen is not integrated")
			if incoming.is_empty():
				return result("FAIL", "no incoming call to answer")
			EventBus.phone_call_answered.emit(incoming)
			incoming = &""
		"choice":
			if component("phone_screen.gd") == null:
				return result("SKIP", "T-155 chat choices are not integrated")
			var id := StringName(command.id)
			var index: int = int(command.index)
			if not choices.has(id) or index < 0 or index >= choices[id].size() or float(command.index) != index:
				return result("FAIL", "choice is not pending or index is invalid")
			EventBus.chat_choice_made.emit(id, index)
			choices.erase(id)
		"puzzle":
			if component("puzzle_station.gd") == null:
				return result("SKIP", "T-151 puzzle_station is not integrated")
			var found := false
			for node: Node in world.find_children("*", "", true, false):
				var script: Script = node.get_script()
				if script != null and script.resource_path.get_file() == "puzzle_station.gd" and str(node.get("puzzle_id")) == command.id:
					found = true
			if not found:
				return result("FAIL", "puzzle station id not found: " + command.id)
			EventBus.puzzle_solved.emit(StringName(command.id))
		"still", "breath":
			if op == "breath" and not player.has_method("lie_on"):
				return result("SKIP", "T-151 breath mechanic is not integrated")
			for action: StringName in [&"move_forward", &"move_back", &"move_left", &"move_right", &"sprint"]:
				Input.action_release(action)
			var original_position := player.global_position
			var original_rotation := player.rotation
			var head := player.get_node_or_null("Head") as Node3D
			var head_rotation := head.rotation if head != null else Vector3.ZERO
			if op == "breath":
				_send(&"hold_breath", true)
				await get_tree().process_frame
			var deadline := Time.get_ticks_msec() + int(float(command.seconds) * 1000.0)
			var reason := ""
			while Time.get_ticks_msec() < deadline and not _cancelled:
				await get_tree().process_frame
				if op == "breath" and not holding:
					reason = "breath released before requested duration"
					break
				if Vector2(player.global_position.x, player.global_position.z).distance_to(Vector2(original_position.x, original_position.z)) > 0.05 or not player.rotation.is_equal_approx(original_rotation) or (head != null and not head.rotation.is_equal_approx(head_rotation)):
					reason = "player moved or camera rotated while staying still"
					break
			_send(&"hold_breath", false)
			if not reason.is_empty():
				return result("FAIL", reason)
	if _cancelled:
		return result("SKIP", "action cancelled")
	return result("PASS", op)


func cancel() -> void:
	_cancelled = true
	_send(&"hold_breath", false)
	_send(&"phone", false)


func _send(action: StringName, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)


static func result(status: String, reason: String) -> Dictionary:
	return {"status": status, "reason": reason}
