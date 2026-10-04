extends "res://scripts/ui/reading_overlay.gd"
## Combination only. Pause ownership matches the document reader.

const Layout = preload("res://scripts/ui/chapter_ui_layout.gd")
@export var wrong_sound: AudioStream = preload("res://audio/sfx/door_latch.ogg")
@export_range(0.1, 3.0) var solved_delay := 0.8
@export var player_path: NodePath = ^"../Player"
@export var alarm_sound: AudioStream = preload("res://audio/sfx/door_latch.ogg")
var _puzzle: PuzzleData
var _digits: Array[int] = []
var _solved := false
var _close_remaining := 0.0
var _shake_remaining := 0.0
var _hint: DocumentData
var _feedback_key := "UI_PUZZLE_INSTRUCTIONS"
var _lockouts: Dictionary[StringName, float] = {}


func _ready() -> void:
	super._ready()
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.015, 0.02, 0.93)
	$Root.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var content := Layout.card($Root, Rect2(0.18, 0.18, 0.64, 0.64))
	Layout.label(content, "Title", "", 40)
	Layout.label(content, "Help", "UI_PUZZLE_HELP", 24)
	var scroll := ScrollContainer.new()
	scroll.name = "DialScroll"
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	var dials := HBoxContainer.new()
	dials.name = "Dials"
	dials.add_theme_constant_override("separation", 24)
	dials.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dials.alignment = BoxContainer.ALIGNMENT_CENTER
	scroll.add_child(dials)
	Layout.label(content, "Feedback", _feedback_key, 26)
	Layout.button(content, "Submit", "UI_PUZZLE_SUBMIT", _submit)
	Layout.button(content, "Hint", "UI_PUZZLE_HINT", _show_hint)
	var hint_scroll := ScrollContainer.new()
	hint_scroll.name = "HintScroll"
	hint_scroll.custom_minimum_size.y = 170
	hint_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(hint_scroll)
	var hint_text := Layout.label(hint_scroll, "Text", "", 28)
	hint_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint_scroll.hide()
	Layout.button(content, "Close", "UI_PUZZLE_CLOSE", close_view)
	var sound := AudioStreamPlayer.new()
	sound.name = "WrongSound"
	sound.bus = &"SFX"
	# Reuse the clip's authored level; SFX settings still control its volume.
	sound.volume_db = 0.0
	add_child(sound)
	EventBus.puzzle_opened.connect(_on_opened)
	EventBus.checkpoint_loaded.connect(_on_checkpoint)
	EventBus.chapter_started.connect(func(_chapter: int) -> void: _load_lockouts())
	_load_lockouts()


func _on_opened(id: StringName) -> void:
	if _open:
		if _puzzle.id != id:
			EventBus.puzzle_closed.emit(id)
		return
	var data := PuzzleData.load_by_id(id)
	if not open_puzzle(data):
		EventBus.puzzle_closed.emit(id) # Release the station's control lock on refusal.


func open_puzzle(data: PuzzleData) -> bool:
	if data == null or data.kind != &"combination" or data.solution.is_empty():
		return false
	for character in data.solution:
		if character not in "0123456789":
			return false
	if not _begin_reading():
		return false
	_puzzle = data
	_hint = DocumentData.load_by_id(data.hint_document) if not data.hint_document.is_empty() else null
	_digits.clear()
	_digits.resize(data.solution.length())
	_digits.fill(-1) # No answer until the player has set every dial.
	_solved = false
	_close_remaining = 0.0
	_shake_remaining = 0.0
	_feedback_key = "UI_PUZZLE_INSTRUCTIONS"
	$Root/Card/Content/HintScroll.hide()
	_build_dials()
	_refresh()
	$Root/Card/Content/DialScroll/Dials.get_child(0).get_node("Up").grab_focus()
	return true


func _build_dials() -> void:
	var parent := $Root/Card/Content/DialScroll/Dials
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
	for index in _digits.size():
		var dial := VBoxContainer.new()
		dial.name = "Dial%d" % index
		dial.custom_minimum_size.x = 132
		dial.add_theme_constant_override("separation", 12)
		parent.add_child(dial)
		Layout.button(dial, "Up", "UI_PUZZLE_UP", _turn.bind(index, 1))
		var number := Layout.label(dial, "Value", "—", 64)
		number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number.size_flags_vertical = Control.SIZE_EXPAND_FILL
		number.mouse_filter = Control.MOUSE_FILTER_STOP
		Layout.button(dial, "Down", "UI_PUZZLE_DOWN", _turn.bind(index, -1))
		for control in [dial, dial.get_node("Up"), number, dial.get_node("Down")]:
			control.gui_input.connect(_dial_input.bind(index))


func _dial_input(event: InputEvent, index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			get_viewport().set_input_as_handled()
			_turn(index, 1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1)


func _turn(index: int, direction: int) -> void:
	if not _open or _solved or _locked() or index < 0 or index >= _digits.size():
		return
	_digits[index] = (0 if direction > 0 else 9) if _digits[index] < 0 else posmod(_digits[index] + direction, 10)
	$Root/Card/Content/DialScroll/Dials.get_child(index).get_node("Value").text = str(_digits[index])
	if _puzzle.max_attempts > 0:
		_refresh()
		return # Limited locks count confirmed combinations, not intermediate dial positions.
	_submit()


func _submit() -> void:
	if not _open or _solved or _locked():
		return
	if _digits.has(-1):
		return
	var answer := ""
	for digit in _digits:
		answer += str(digit)
	if _puzzle.check(answer):
		_solved = true
		_close_remaining = solved_delay
		_feedback_key = "UI_PUZZLE_SOLVED"
		for dial in $Root/Card/Content/DialScroll/Dials.get_children():
			dial.get_node("Up").disabled = true
			dial.get_node("Down").disabled = true
		EventBus.puzzle_solved.emit(_puzzle.id)
	else:
		_feedback_key = "UI_PUZZLE_WRONG"
		var attempts := maxi(0, int(GameState.get_flag(_attempts_key(_puzzle.id), 0))) + 1
		GameState.set_flag(_attempts_key(_puzzle.id), attempts)
		var settings := get_node_or_null("/root/Settings")
		var reduce: bool = settings != null and settings.get_value("accessibility", "reduce_scares")
		_shake_remaining = 0.0 if reduce else 0.24
		$WrongSound.stream = wrong_sound
		if wrong_sound != null:
			$WrongSound.play()
		if _puzzle.max_attempts > 0 and attempts >= _puzzle.max_attempts:
			_lockouts[_puzzle.id] = maxf(0.0, _puzzle.lockout_seconds)
			GameState.set_flag(_lockout_key(_puzzle.id), _lockouts[_puzzle.id])
			$WrongSound.stream = alarm_sound
			if alarm_sound != null:
				$WrongSound.play()
			var player := get_node_or_null(player_path) as Node3D
			if player != null:
				EventBus.noise_emitted.emit(player.global_position, 12.0, &"alarm")
	_refresh()


func _process(delta: float) -> void:
	# The panel owns the pause while open. Other menus suspend the countdown.
	if _open or not get_tree().paused:
		for id: StringName in _lockouts.keys():
			_lockouts[id] = maxf(0.0, _lockouts[id] - delta)
			GameState.set_flag(_lockout_key(id), _lockouts[id])
			if _lockouts[id] <= 0.0:
				_lockouts.erase(id)
				GameState.set_flag(_attempts_key(id), 0)
				if _puzzle != null and _puzzle.id == id:
					_feedback_key = "UI_PUZZLE_INSTRUCTIONS"
	if not _open:
		return
	_refresh()
	if _shake_remaining > 0.0:
		_shake_remaining = maxf(0.0, _shake_remaining - delta)
		$Root.position.x = sin(_shake_remaining * 90.0) * 5.0 if _shake_remaining > 0.0 else 0.0
	if _solved:
		_close_remaining -= delta
		if _close_remaining <= 0.0:
			close_view()


func _input(event: InputEvent) -> void:
	if _open and event.is_action_pressed("pause") and not event.is_echo():
		get_viewport().set_input_as_handled()
		close_view()


func _show_hint() -> void:
	if _hint == null or _solved:
		return
	_hint.mark_rules_read()
	$Root/Card/Content/HintScroll.visible = not $Root/Card/Content/HintScroll.visible
	_refresh()


func _refresh() -> void:
	if _puzzle == null:
		return
	$Root/Card/Content/Title.text = tr(_puzzle.title_key)
	$Root/Card/Content/Feedback.text = tr(_feedback_key)
	var locked := _locked()
	if locked:
		$Root/Card/Content/Feedback.text = tr("UI_PUZZLE_LOCKED") % ceili(_lockouts[_puzzle.id])
	elif _puzzle.max_attempts > 0 and not _solved:
		$Root/Card/Content/Feedback.text += "  " + tr("UI_PUZZLE_ATTEMPTS") % [int(GameState.get_flag(_attempts_key(_puzzle.id), 0)), _puzzle.max_attempts]
	$Root/Card/Content/Submit.visible = _puzzle.max_attempts > 0
	$Root/Card/Content/Submit.disabled = locked or _solved or _digits.has(-1)
	for dial in $Root/Card/Content/DialScroll/Dials.get_children():
		dial.get_node("Up").disabled = locked or _solved
		dial.get_node("Down").disabled = locked or _solved
	$Root/Card/Content/Hint.visible = _hint != null and not _solved
	if _hint != null:
		var paragraphs: PackedStringArray = [tr(_hint.title_key)]
		for id in _hint.rule_ids:
			var rule := RuleSystem.get_rule(id)
			if rule != null:
				paragraphs.append(tr(rule.text_key))
		for key in _hint.text_keys:
			paragraphs.append(tr(key))
		$Root/Card/Content/HintScroll/Text.text = "\n\n".join(paragraphs)


func close_view() -> void:
	if not _open:
		return
	var id := _puzzle.id
	_puzzle = null
	$WrongSound.stop()
	$Root.position.x = 0.0
	super.close_view()
	EventBus.puzzle_closed.emit(id)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()


func _locked() -> bool:
	return _puzzle != null and _lockouts.get(_puzzle.id, 0.0) > 0.0


func _attempts_key(id: StringName) -> StringName:
	return StringName("puzzle_attempts_" + String(id))


func _lockout_key(id: StringName) -> StringName:
	return StringName("puzzle_lockout_" + String(id))


func _load_lockouts() -> void:
	_lockouts.clear()
	var flags: Dictionary = GameState.to_dict().get("flags", {})
	for key: String in flags:
		if key.begins_with("puzzle_lockout_"):
			var remaining := maxf(0.0, float(GameState.get_flag(StringName(key), 0.0)))
			if is_finite(remaining) and remaining > 0.0:
				_lockouts[StringName(key.trim_prefix("puzzle_lockout_"))] = remaining


func _on_checkpoint(_id: StringName) -> void:
	close_view()
	_load_lockouts()
