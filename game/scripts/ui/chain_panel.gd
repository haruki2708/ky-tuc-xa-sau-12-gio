extends CanvasLayer
## Presentation only: core supplies every word and judges every answer.

const Layout = preload("res://scripts/ui/chapter_ui_layout.gd")
const NAMES := {&"phuc": "UI_CH2_PHUC", &"viet": "UI_CH2_VIET", &"dat": "UI_CH2_DAT", &"trung": "UI_CH2_TRUNG"}
@export var tick_sound: AudioStream = preload("res://audio/ch1v2/power_switch.ogg")
@export var tick_enabled := true
var _speaker: StringName = &""
var _word_speaker: StringName = &""
var _history: Array[String] = []
var _options := PackedStringArray()
var _remaining := 0.0
var _duration := 15.0
var _choosing := false
var _blocked := false
var _active := false
var _selected := 0
var _last_tick := 6
var _timed_out := false


func _ready() -> void:
	add_to_group("chain_panel")
	var content := Layout.card($Root, Rect2(0.025, 0.15, 0.37, 0.64))
	content.add_theme_constant_override("separation", 10)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Root/Card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Layout.label(content, "Title", "UI_CHAIN_TITLE", 22)
	Layout.label(content, "Speaker", "", 26)
	Layout.label(content, "Word", "", 46)
	Layout.label(content, "WordSpeaker", "", 20)
	Layout.label(content, "History", "", 22)
	Layout.label(content, "Status", "", 24)
	var timer := ProgressBar.new()
	timer.name = "Timer"
	timer.show_percentage = false
	timer.custom_minimum_size.y = 12
	timer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var red := StyleBoxFlat.new()
	red.bg_color = Color(0.75, 0.1, 0.08)
	timer.add_theme_stylebox_override("fill", red)
	content.add_child(timer)
	var options := VBoxContainer.new()
	options.name = "Options"
	content.add_child(options)
	for index in 4:
		var button := Layout.button(options, "Option%d" % (index + 1), "", _choose.bind(index))
		button.add_theme_font_size_override("font_size", 24)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.focus_mode = Control.FOCUS_NONE
	Layout.label(content, "Help", "UI_CHAIN_CONTROLS", 19)
	EventBus.chain_turn_started.connect(_on_turn)
	EventBus.chain_word_spoken.connect(_on_word)
	EventBus.chain_choice_requested.connect(_on_choice)
	EventBus.chain_choice_blocked.connect(func(blocked: bool) -> void:
		_blocked = blocked
		_refresh())
	EventBus.chain_choice_made.connect(func(_index: int) -> void:
		_choosing = false
		_refresh())
	EventBus.player_death_started.connect(func(_kind: StringName) -> void: close_panel())
	EventBus.player_failed.connect(func(_reason: StringName) -> void: close_panel())
	EventBus.checkpoint_loaded.connect(func(_id: StringName) -> void: close_panel())
	EventBus.chapter_started.connect(func(_chapter: int) -> void: close_panel())
	_refresh()


func _on_turn(speaker: StringName, _seconds: float) -> void:
	_speaker = speaker
	_active = true
	_choosing = false
	$Tick.stop()
	_timed_out = false
	_refresh()


func _on_word(speaker: StringName, word_key: String) -> void:
	if word_key.is_empty():
		return # Mumbling is not a word and must not evict an actual history entry.
	_active = true
	_word_speaker = speaker
	_history.append(word_key)
	if _history.size() > 3:
		_history.pop_front()
	_refresh()


func _on_choice(keys: PackedStringArray, seconds: float) -> void:
	if keys.size() != 4 or not is_finite(seconds) or seconds <= 0.0:
		return
	for key in keys:
		if key.is_empty():
			return
	_options = keys.duplicate()
	_speaker = &"trung"
	_duration = seconds
	_remaining = seconds
	_last_tick = 6
	_selected = 0
	_active = true
	_choosing = true
	_timed_out = false
	_refresh()


func is_choosing() -> bool:
	return _active and _choosing


func _modal() -> bool:
	if get_tree().paused:
		return true
	for reader in get_tree().get_nodes_in_group("reading_overlay"):
		if reader.is_open():
			return true
	return false


func _process(delta: float) -> void:
	$Root.visible = _active and not _modal()
	if not _choosing or _modal():
		return
	_remaining = maxf(0.0, _remaining - delta)
	var second := ceili(_remaining)
	if second > 0 and second <= 5 and second != _last_tick:
		_last_tick = second
		if tick_enabled and tick_sound != null:
			$Tick.stream = tick_sound
			$Tick.play()
	if _remaining <= 0.0:
		_finish(-1) # Out of earshot does not stop time.
	_refresh()


func _input(event: InputEvent) -> void:
	if not is_choosing() or _modal() or event.is_echo():
		return
	if event is InputEventKey and event.pressed:
		var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		if key >= KEY_1 and key <= KEY_4:
			get_viewport().set_input_as_handled()
			_choose(key - KEY_1)
	if _blocked:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			_selected = posmod(_selected + (1 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1), 4)
			get_viewport().set_input_as_handled()
			_refresh()
		elif event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_choose(_selected)


func _choose(index: int) -> void:
	if not is_choosing() or _blocked or _modal() or index < 0 or index >= _options.size():
		return
	get_viewport().set_input_as_handled()
	Input.action_release("interact") # Avoid a simultaneous world interaction in Player._physics_process.
	_finish(index)


func _finish(index: int) -> void:
	if not _choosing:
		return
	_choosing = false
	_timed_out = index == -1
	$Tick.stop()
	_refresh()
	EventBus.chain_choice_made.emit(index)


func close_panel() -> void:
	_active = false
	_speaker = &""
	_word_speaker = &""
	_choosing = false
	_blocked = false
	_remaining = 0.0
	_timed_out = false
	_history.clear()
	_options.clear()
	$Tick.stop()
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	$Root.visible = _active and not _modal()
	var content := $Root/Card/Content
	content.get_node("Speaker").text = tr("UI_CHAIN_TURN") % tr(NAMES.get(_speaker, "UI_CHAIN_UNKNOWN"))
	content.get_node("Word").text = tr(_history.back()) if not _history.is_empty() else tr("UI_CHAIN_WAITING")
	content.get_node("WordSpeaker").text = tr("UI_CHAIN_SPOKEN_BY") % tr(NAMES.get(_word_speaker, "UI_CHAIN_UNKNOWN"))
	var words := PackedStringArray()
	for key in _history:
		words.append(tr(key))
	content.get_node("History").text = tr("UI_CHAIN_HISTORY") % " → ".join(words)
	content.get_node("Status").text = tr("UI_CHAIN_BLOCKED") if _blocked and _choosing else tr("UI_CHAIN_SECONDS") % ceili(_remaining)
	if _timed_out:
		content.get_node("Status").text = tr("UI_CHAIN_TIMEOUT")
	content.get_node("Status").visible = _choosing or _timed_out
	content.get_node("Timer").visible = _choosing
	content.get_node("Timer").max_value = _duration
	content.get_node("Timer").value = _remaining
	content.get_node("Options").visible = _choosing
	content.get_node("Help").visible = _choosing
	for index in 4:
		var button: Button = content.get_node("Options").get_child(index)
		button.text = "%d. %s" % [index + 1, tr(_options[index])] if index < _options.size() else ""
		button.disabled = _blocked
		button.modulate = Color(1, 1, 1, 0.4) if _blocked else Color(1, 0.9, 0.65) if index == _selected else Color.WHITE


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()
