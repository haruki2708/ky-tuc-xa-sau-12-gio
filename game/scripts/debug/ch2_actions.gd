extends "res://scripts/debug/chapter_actions.gd"
## Observe before the chapter starts. Answers use the published EventBus
## contract; physical actions require real components plus acknowledgements.

const POLICY := preload("res://scripts/debug/ch2_policy.gd")
const SAME := preload("res://scripts/debug/ch1v2_actions.gd")
var profile: Dictionary = {}
var dictionary: Ch2Dictionary = Ch2Dictionary.shared()
var bank: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/ch2/word_bank.json")).words
var prediction_pending: Dictionary = {}
var prediction_answers: Dictionary = {}
var prediction_results: Dictionary = {}
var chain_submitted: bool = false
var trap_accepted: bool = false
var trap_confirmed: bool = false
var _submitted_mode: String = ""
var recent: Array = []
var chain_pending: bool = false
var chain_blocked: bool = false
var chain_requested_at: int = 0
var chain_seconds: float = 0.0
var shower_pending: bool = false
var temperatures: Array = []
var counted_minutes: int = 0
var gagged: Array[int] = []
var loop_streak: int = 0
var loop_completed: bool = false
var _last_loop_index: int = -1


func _ready() -> void:
	super._ready()
	EventBus.chapter_started.connect(func(number: int) -> void:
		if number == 2:
			recent.clear()
			prediction_pending.clear()
			prediction_answers.clear()
			prediction_results.clear()
			chain_submitted = false
			trap_accepted = false
			trap_confirmed = false
			temperatures.clear()
			gagged.clear()
			chain_pending = false
			shower_pending = false
			chain_blocked = false
			counted_minutes = 0
			loop_streak = 0
			loop_completed = false
			_last_loop_index = -1)
	EventBus.chain_input_requested.connect(func(seconds: float) -> void:
		chain_pending = true
		chain_submitted = false
		chain_seconds = seconds
		chain_requested_at = Time.get_ticks_msec())
	EventBus.chain_input_closed.connect(func(outcome: StringName) -> void:
		chain_pending = false
		if outcome == &"accepted" and chain_submitted and _submitted_mode == "trap": trap_accepted = true)
	EventBus.chain_choice_blocked.connect(func(value: bool) -> void: chain_blocked = value)
	EventBus.chain_word_spoken.connect(_word_spoken)
	EventBus.corpse_state_changed.connect(func(bed_number: int, state: StringName) -> void:
		if state == &"fall" and trap_accepted and bed_number not in gagged: trap_confirmed = true
		if state == &"gagged" and bed_number not in gagged: gagged.append(bed_number))
	EventBus.prediction_requested.connect(func(member: StringName, history: PackedInt32Array, _seconds: float) -> void:
		prediction_pending[member] = Array(history))
	EventBus.prediction_result.connect(func(member: StringName, correct: bool) -> void:
		if prediction_answers.has(member): prediction_results[member] = correct
		prediction_pending.erase(member))
	EventBus.shower_choice_requested.connect(func(_seconds: float) -> void: shower_pending = true)
	EventBus.shower_choice_made.connect(func(_yes: bool) -> void: shower_pending = false)
	EventBus.shower_slot_finished.connect(func(temperature: int, _ran: bool, minutes: int) -> void:
		temperatures.append(temperature)
		counted_minutes = minutes)


func recommendation(mode: String = "legal") -> Dictionary:
	if recent.is_empty(): return result("SKIP", "no observed chain word")
	var word := POLICY.choose_word(recent[-1], recent, mode)
	return {"status": "PASS" if not word.is_empty() else "UNAVAILABLE", "reason": mode, "word": word}


func answer_chain(mode: String = "legal") -> Dictionary:
	if not chain_pending or chain_submitted: return result("FAIL", "chain input is not pending or already submitted")
	if chain_blocked: return result("FAIL", "cannot answer outside bedroom")
	var answer := recommendation(mode)
	if answer.status != "PASS": return answer
	chain_submitted = true
	_submitted_mode = mode
	EventBus.chain_word_typed.emit(str(answer.word))
	return answer


func _word_spoken(who: StringName, key: String) -> void:
	if key.is_empty(): return
	var word := str(bank[key].text) if bank.has(key) else key
	if who == &"trung" and gagged.size() == 3:
		var index := POLICY.LOOP.find(word)
		loop_streak = loop_streak + 1 if index >= 0 and index == (_last_loop_index + 1) % 8 else 1 if index >= 0 else 0
		_last_loop_index = index
		loop_completed = loop_completed or loop_streak >= 8
	elif who != &"trung":
		trap_accepted = false
	recent.append(word)
	if recent.size() > 3: recent.pop_front()


func answer_prediction(member: StringName, wrong: bool = false, as_range: bool = false) -> Dictionary:
	if not prediction_pending.has(member) or prediction_answers.has(member): return result("FAIL", "prediction not pending or already sent")
	var text := POLICY.prediction(prediction_pending[member], wrong, as_range)
	if text.is_empty(): return result("FAIL", "prediction requires three valid observed temperatures")
	prediction_answers[member] = text
	EventBus.prediction_sent.emit(member, text)
	return result("PASS", "prediction sent to " + str(member) + ": " + text)


func both_predictions_correct() -> bool:
	return prediction_results.get(&"minh_nhat", false) == true and prediction_results.get(&"ngu", false) == true


func physical(key: String) -> Dictionary:
	var binding: Variant = profile.get("actions", {}).get(key)
	if not binding is Dictionary: return result("SKIP", "T-171 action not bound: " + key)
	# A sequence supports moving to the object then interacting, or holding E.
	var steps: Array = binding.get("steps", [binding])
	for step: Dictionary in steps:
		var outcome := await _physical_step(step)
		if outcome.status != "PASS": return outcome
	return result("PASS", key)


func _physical_step(step: Dictionary) -> Dictionary:
	if not is_instance_valid(world): return result("FAIL", "chapter scene was replaced during action")
	var target: Node = world.get_node_or_null(str(step.get("path", "")))
	if target == null: return result("SKIP", "component not integrated: " + str(step.get("path")))
	var check: Variant = step.get("verify")
	if not check is Dictionary: return result("FAIL", "physical action needs acknowledgement")
	var state_check: bool = check.get("flag") is String or check.get("property") is String
	var signal_name := StringName(str(check.get("signal", "")))
	if not state_check and signal_name.is_empty() or state_check and check.get("equals") == null:
		return result("FAIL", "physical action needs explicit state or signal acknowledgement")
	if not signal_name.is_empty() and not target.has_signal(signal_name):
		return result("SKIP", "signal not integrated: " + str(signal_name))
	var seen := [false]
	var listen := func(_a: Variant = null, _b: Variant = null, _c: Variant = null) -> void: seen[0] = true
	if not signal_name.is_empty(): target.connect(signal_name, listen)
	var invoked := await _invoke(target, step)
	var deadline := Time.get_ticks_msec() + 3000
	while invoked.status == "PASS" and is_instance_valid(target) and not _verified(target, check, seen[0]) and Time.get_ticks_msec() < deadline and not _cancelled:
		await get_tree().process_frame
	if is_instance_valid(target) and not signal_name.is_empty(): target.disconnect(signal_name, listen)
	if invoked.status != "PASS": return invoked
	if _cancelled: return result("SKIP", "action cancelled")
	if not is_instance_valid(target) or not _verified(target, check, seen[0]): return result("FAIL", "physical action not acknowledged: " + str(step.get("path")))
	return result("PASS", "physical acknowledgement")


func _verified(target: Node, check: Dictionary, seen: bool) -> bool:
	if check.has("signal") and not seen: return false
	if check.has("flag") or check.has("property"): return SAME._same(_read(target, check), check.equals)
	return seen


func _invoke(target: Node, step: Dictionary) -> Dictionary:
	if step.has("aim"):
		if not valid({"op": "goto", "position": step.aim}): return result("FAIL", "invalid aim coordinates")
		var camera := world.get_viewport().get_camera_3d()
		if camera == null: return result("SKIP", "active player camera missing")
		camera.look_at(Vector3(step.aim[0], step.aim[1], step.aim[2]))
		await get_tree().physics_frame
		await get_tree().physics_frame
	if step.has("position"):
		return await super.execute({"op": "goto", "position": step.position})
	if step.has("hold_action"):
		var action := StringName(str(step.hold_action))
		var duration := float(step.get("seconds", 1.05))
		if not InputMap.has_action(action) or not is_finite(duration) or duration < 1.0 or duration > 5.0:
			return result("FAIL", "invalid hold action/duration")
		_send(action, true)
		var until := Time.get_ticks_msec() + int(duration * 1000)
		while Time.get_ticks_msec() < until and not _cancelled:
			await get_tree().process_frame
		_send(action, false)
	else:
		var method := str(step.get("method", "interact"))
		if not target.has_method(method): return result("SKIP", "API not integrated: " + method)
		var args: Array = []
		for value: Variant in step.get("args", ["$player"]):
			if SAME._same(value, "$player") and player_node() == null: return result("SKIP", "Player not integrated")
			args.append(player_node() if SAME._same(value, "$player") else value)
		target.callv(method, args)
	return result("PASS", "invoked")

func _read(target: Node, check: Dictionary) -> Variant:
	return GameState.get_flag(StringName(check.flag), null) if check.has("flag") else target.get(str(check.property))


func acknowledged(key: String) -> bool:
	var spec: Variant = profile.get("actions", {}).get(key)
	if not spec is Dictionary or not is_instance_valid(world): return false
	var steps: Array = spec.get("steps", [spec])
	if steps.is_empty(): return false
	var step: Dictionary = steps[-1]
	var target := world.get_node_or_null(str(step.get("path", "")))
	var check: Variant = step.get("verify")
	return target != null and check is Dictionary and check.has("equals") and (check.has("flag") or check.has("property")) and SAME._same(_read(target, check), check.equals)
