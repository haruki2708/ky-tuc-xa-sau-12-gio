extends CanvasLayer
## Presentation only: core supplies every word and judges every answer.

const TextEntry = preload("res://scripts/ui/game_text_entry.gd")
const Layout = preload("res://scripts/ui/chapter_ui_layout.gd")
const NAMES := {&"phuc": "UI_CH2_PHUC", &"viet": "UI_CH2_VIET", &"dat": "UI_CH2_DAT", &"trung": "UI_CH2_TRUNG"}
@export var tick_sound: AudioStream = preload("res://audio/ch1v2/power_switch.ogg")
@export var tick_enabled := true
var _speaker: StringName = &""
var _word_speaker: StringName = &""
var _history: Array[String] = []
var _entry: LineEdit
var _remaining := 0.0
var _duration := 15.0
var _choosing := false
var _blocked := false
var _active := false
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
	_entry = TextEntry.new()
	_entry.name = "Entry"
	_entry.hide()
	content.add_child(_entry)
	_entry.text_submitted.connect(_submit)
	_entry.cancelled.connect(_close_entry)
	Layout.label(content, "Help", "UI_CHAIN_TYPE_OPEN", 19)
	EventBus.chain_turn_started.connect(_on_turn)
	EventBus.chain_word_spoken.connect(_on_word)
	EventBus.chain_input_requested.connect(_on_request)
	EventBus.chain_input_closed.connect(_on_closed)
	EventBus.chain_choice_blocked.connect(func(blocked: bool) -> void:
		_blocked = blocked
		_refresh())
	EventBus.player_death_started.connect(func(_kind: StringName) -> void: close_panel())
	EventBus.player_failed.connect(func(_reason: StringName) -> void: close_panel())
	EventBus.checkpoint_loaded.connect(func(_id: StringName) -> void: close_panel())
	EventBus.chapter_started.connect(func(_chapter: int) -> void: close_panel())
	_refresh()


func _on_turn(speaker: StringName, _seconds: float) -> void:
	_close_entry()
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


func _on_request(seconds: float) -> void:
	if not is_finite(seconds) or seconds <= 0.0:
		return
	_close_entry()
	_entry.clear()
	_speaker = &"trung"
	_duration = seconds
	_remaining = seconds
	_last_tick = 6
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
	if _modal():
		_close_entry()
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
		_on_closed(&"timeout") # Core owns the consequence; never synthesize an answer.
	_refresh()


func _input(event: InputEvent) -> void:
	if not is_choosing() or _modal() or event.is_echo() or TextEntry.is_typing(get_tree()):
		return
	if event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
		open_entry()


func open_entry() -> void:
	if not is_choosing() or _modal() or TextEntry.is_typing(get_tree()):
		return
	_entry.show()
	_entry.grab_focus()
	_refresh()


func _close_entry() -> void:
	if not is_instance_valid(_entry):
		return
	_entry.release_focus()
	_entry.hide()
	_refresh()


func _submit(text: String) -> void:
	if not is_choosing() or _modal() or _blocked or text.strip_edges().is_empty():
		return
	# Preserve whitespace, casing and tone marks for core normalization.
	_choosing = false
	_close_entry()
	$Tick.stop()
	_refresh()
	EventBus.chain_word_typed.emit(text)


func _on_closed(result: StringName) -> void:
	_choosing = false
	_timed_out = result == &"timeout"
	_close_entry()
	$Tick.stop()
	_refresh()


func close_panel() -> void:
	_active = false
	_close_entry()
	_speaker = &""
	_word_speaker = &""
	_choosing = false
	_blocked = false
	_remaining = 0.0
	_timed_out = false
	_history.clear()
	$Tick.stop()
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	$Root.visible = _active and not _modal()
	var content := $Root/Card/Content
	content.get_node("Speaker").text = tr("UI_CHAIN_TURN") % tr(NAMES.get(_speaker, "UI_CHAIN_UNKNOWN"))
	content.get_node("Word").text = _word_text(_history.back()) if not _history.is_empty() else tr("UI_CHAIN_WAITING")
	content.get_node("WordSpeaker").text = tr("UI_CHAIN_SPOKEN_BY") % tr(NAMES.get(_word_speaker, "UI_CHAIN_UNKNOWN"))
	var words := PackedStringArray()
	for key in _history:
		words.append(_word_text(key))
	content.get_node("History").text = tr("UI_CHAIN_HISTORY") % " → ".join(words)
	content.get_node("Status").text = tr("UI_CHAIN_BLOCKED") if _blocked and _choosing else tr("UI_CHAIN_SECONDS") % ceili(_remaining)
	if _timed_out:
		content.get_node("Status").text = tr("UI_CHAIN_TIMEOUT")
	content.get_node("Status").visible = _choosing or _timed_out
	content.get_node("Timer").visible = _choosing
	content.get_node("Timer").max_value = _duration
	content.get_node("Timer").value = _remaining
	content.get_node("Help").visible = _choosing
	content.get_node("Help").text = tr("UI_TEXT_ENTRY_CONTROLS" if _entry.visible else "UI_CHAIN_TYPE_OPEN")


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()


func _word_text(key: String) -> String:
	# English labels must never translate the Vietnamese word being played.
	var translated: String = preload("res://localization/strings.vi.translation").get_message(key)
	return key if translated.is_empty() else translated
