extends "res://scripts/debug/chapter_bot.gd"


func valid_scenarios() -> Array[String]:
	return ["ch1v2_good", "ch1v2_wrong_switch", "ch1v2_door_late", "ch1v2_lamp_on", "ch1v2_wrong_advice"]


func template_path() -> String:
	return "res://scripts/debug/ch1v2_scenarios.json"


func create_actions() -> Node:
	var helper := preload("res://scripts/debug/ch1v2_actions.gd").new()
	helper.bindings = profile.get("actions", {})
	return helper


func total_timeout() -> float:
	return 4500.0


func _process(_delta: float) -> void:
	# V2 rounds exceed demo segment limits; individual waits stay bounded.
	if finishing or started == 0: return
	if GameState.segment != segment:
		segment = GameState.segment
		visited.append(segment)
		_mark("segment " + str(segment))
	if Time.get_ticks_msec() - started > total_timeout() * 1000.0 and failure.is_empty():
		failure = "chapter v2 observer timeout"

func _step(step: Dictionary) -> void:
	if step.get("op") == "wait_flag":
		var id := StringName(str(step.get("id", "")))
		if id.is_empty() or not step.has("equals"):
			failure = "wait_flag requires an explicit flag and expected value"
			return
		await _until(func() -> bool: return GameState.get_flag(id, null) == step.equals, "flag " + id)
		_mark("flag " + id)
	else:
		await super._step(step)
