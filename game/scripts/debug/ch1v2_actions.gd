extends "res://scripts/debug/chapter_actions.gd"
## Semantic actions call real interactables/UI. Profiles bind unpublished
## lane A/D node paths and APIs; no action writes completion flags.

var bindings: Dictionary = {}


static func valid_v2(command: Dictionary) -> bool:
	match str(command.get("op", "")):
		"wall_taps":
			return command.get("code") is String and not tap_schedule(command.code).is_empty()
		"power_switch":
			# JSON numbers arrive as floats (integrator, T-166 review).
			var index: Variant = command.get("index")
			return (index is int or index is float) and float(index) in [1.0, 2.0, 3.0] and command.get("on") is bool
		"cable": return command.get("color") in ["blue", "gray"]
		"latch", "desk_lamp": return command.get("on") is bool
		"search": return command.get("spot") in ["viet_locker", "phuc_mattress", "trash"]
		"camera_tab", "map_tab", "charge", "close_document": return true
		"keypad":
			var code: Variant = command.get("code")
			if not code is String or code.length() != 4: return false
			for digit: String in code:
				if digit not in "0123456789": return false
			return true
	return valid(command)


## Rows/columns 1..5, two digits per letter; 0.18 s between taps,
## 1 s between coordinates, 2.5 s between letters (D-039 N3).
static func tap_schedule(code: String) -> Array[float]:
	var compact := code.replace(" ", "")
	var times: Array[float] = []
	if compact.is_empty() or compact.length() % 2 != 0: return times
	var at := 0.0
	for i in compact.length():
		if compact[i] not in "12345": return []
		for tap in int(compact[i]):
			if tap > 0: at += 0.18
			times.append(at)
		at += 1.0 if i % 2 == 0 else 2.5
	return times


func execute(command: Dictionary) -> Dictionary:
	if not valid_v2(command): return result("FAIL", "invalid v2 command: " + str(command))
	var op: String = command.op
	if valid(command): return await super.execute(command)
	_cancelled = false
	if op == "close_document":
		# The assembled form opens itself and pauses the world (N5); a player
		# closes it (integrator, T-166 review).
		await get_tree().process_frame
		var reader := component("document_view.gd")
		if reader == null: return result("SKIP", "document view not integrated")
		reader.close_view()
		return result("PASS", "document closed")
	var key: String = op
	if op == "search": key += "_" + str(command.spot)
	if op == "cable": key += "_" + str(command.color)
	if op == "power_switch": key += "_" + str(int(command.index))
	var spec: Variant = bindings.get(key)
	if not spec is Dictionary or not spec.get("path") is String:
		return result("SKIP", "T-161/T-163 action binding missing: " + key)
	var target := world.get_node_or_null(spec.path) if is_instance_valid(world) else null
	if target == null: return result("SKIP", "component not integrated: " + spec.path)
	var actor := player_node()
	if actor == null: return result("SKIP", "Player missing")
	if op == "wall_taps":
		if not target.has_method("interact"): return result("FAIL", "wall has no interact()")
		var observed: Array[int] = []
		var wall_id: StringName = target.get("wall_id")
		var listen := func(id: StringName) -> void:
			if id == wall_id: observed.append(Time.get_ticks_msec())
		EventBus.wall_tapped.connect(listen)
		var began := Time.get_ticks_msec()
		for at: float in tap_schedule(command.code):
			while Time.get_ticks_msec() - began < int(at * 1000) and not _cancelled:
				await get_tree().process_frame
			if _cancelled: break
			target.interact(actor)
		EventBus.wall_tapped.disconnect(listen)
		if _cancelled: return result("SKIP", "wall taps cancelled")
		if observed.size() != tap_schedule(command.code).size(): return result("FAIL", "wall_tapped count did not match code")
		return result("PASS", "wall_tapped acknowledged code=" + command.code)
	if op == "keypad":
		if not target.has_method("interact"): return result("FAIL", "puzzle station has no interact()")
		target.interact(actor)
		await get_tree().process_frame
		var panel := component("puzzle_panel.gd")
		if panel == null: return result("SKIP", "puzzle panel not integrated")
		var dials := panel.get_node_or_null("Root/Card/Content/DialScroll/Dials")
		if dials == null or dials.get_child_count() != 4: return result("FAIL", "four keypad dials did not open")
		var solved := [false]
		var observe := func(id: StringName) -> void:
			if id == target.get("puzzle_id"): solved[0] = true
		EventBus.puzzle_solved.connect(observe)
		for index in 4:
			var up := dials.get_child(index).get_node("Up") as BaseButton
			for turn in int(command.code[index]) + 1:
				if up.disabled: break
				up.pressed.emit()
		# Limited locks (T-163) check only on "Thử mở" (integrator, T-166 review).
		var submit := panel.get_node_or_null("Root/Card/Content/Submit") as BaseButton
		if not solved[0] and submit != null and submit.visible and not submit.disabled:
			submit.pressed.emit()
		EventBus.puzzle_solved.disconnect(observe)
		if not solved[0]:
			panel.close_view()
			return result("FAIL", "panel did not accept code " + command.code)
		panel.close_view()
		return result("PASS", "code accepted through panel buttons")
	# A real node method plus a state acknowledgement is required. Integrator
	# binds API names/arguments after merge; missing APIs SKIP, wrong state FAIL.
	if not spec.get("method") is String or not spec.get("verify") is Dictionary:
		return result("SKIP", "method/state acknowledgement not bound: " + key)
	if not spec.verify.has("equals") or not (spec.verify.get("flag") is String or spec.verify.get("property") is String):
		return result("FAIL", "invalid state acknowledgement binding: " + key)
	if not target.has_method(spec.method): return result("SKIP", "API not integrated: " + key + "." + spec.method)
	var params: Array = []
	for argument: Variant in spec.get("args", []):
		if _same(argument, "$player"): params.append(actor)
		elif _same(argument, "$on"): params.append(command.get("on"))
		else: params.append(argument)
	var expected: Variant = spec.verify.get("equals")
	if _same(expected, "$on"): expected = command.get("on")
	if not _same(_observed(target, spec.verify), expected):
		target.callv(spec.method, params)
	var deadline := Time.get_ticks_msec() + 3000
	while not _same(_observed(target, spec.verify), expected) and Time.get_ticks_msec() < deadline and not _cancelled:
		await get_tree().process_frame
	if _cancelled: return result("SKIP", "action cancelled")
	if not _same(_observed(target, spec.verify), expected): return result("FAIL", "state acknowledgement failed: " + key)
	if op == "search":
		var reader := component("document_view.gd")
		if reader != null: reader.close_view()
	return result("PASS", key)


## Type-safe equality: GDScript 4 errors on bool == String (integrator, T-166 review).
static func _same(a: Variant, b: Variant) -> bool:
	if (a is String or a is StringName) and (b is String or b is StringName):
		return String(a) == String(b)
	if (a is int or a is float) and (b is int or b is float):
		return float(a) == float(b)
	return typeof(a) == typeof(b) and a == b


func _observed(target: Node, check: Dictionary) -> Variant:
	if check.get("flag") is String: return GameState.get_flag(StringName(check.flag), null)
	if check.get("property") is String: return target.get(check.property)
	return null
