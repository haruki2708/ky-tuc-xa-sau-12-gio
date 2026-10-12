extends VBoxContainer
## Transient request; only sent text persists in PhoneState history.

const TextEntry = preload("res://scripts/ui/game_text_entry.gd")
const NAMES := {&"minh_nhat": "NAME_CH1_MINH_NHAT", &"ngu": "NAME_CH1_NGU"}
var phone: CanvasLayer
var member: StringName = &""
var remaining := 0.0
var _sent := false
var _history := PackedInt32Array()
var _recipient: Label
var _clock: Label
var _help: Label
var entry: LineEdit


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_recipient = _label("Recipient", 24)
	_clock = _label("Countdown", 24)
	entry = TextEntry.new()
	entry.name = "Entry"
	add_child(entry)
	entry.text_submitted.connect(_submit)
	entry.cancelled.connect(cancel_entry)
	_help = _label("Help", 24)
	EventBus.prediction_requested.connect(_request)
	EventBus.prediction_result.connect(func(id: StringName, _correct: bool) -> void:
		if id == member:
			close_request())
	EventBus.player_death_started.connect(func(_kind: StringName) -> void: close_request())
	EventBus.player_failed.connect(func(_reason: StringName) -> void: close_request())
	EventBus.checkpoint_loaded.connect(func(_id: StringName) -> void: close_request())
	EventBus.chapter_started.connect(func(_chapter: int) -> void: close_request())
	close_request()


func _label(node_name: String, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.add_theme_font_size_override("font_size", font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label


func _request(id: StringName, history: PackedInt32Array, seconds: float) -> void:
	if not NAMES.has(id) or not is_finite(seconds) or seconds <= 0.0:
		return
	close_request()
	member = id
	_history = history.duplicate()
	remaining = seconds
	_sent = false
	entry.clear()
	phone.tools_view.select_tab(0)
	EventBus.phone_raised.emit(true)
	refresh()
	phone._refresh_visibility()
	open_entry()


func open_entry() -> void:
	if member.is_empty() or _sent or not is_visible_in_tree() or TextEntry.is_typing(get_tree()):
		return
	entry.show()
	entry.grab_focus()
	refresh()


func cancel_entry() -> void:
	entry.release_focus()
	entry.hide()
	refresh()


func close_request() -> void:
	member = &""
	remaining = 0.0
	_sent = false
	entry.release_focus()
	entry.hide()
	refresh()


func _submit(text: String) -> void:
	if member.is_empty() or _sent or phone._blocked() or phone.state.battery <= 0.0 or text.strip_edges().is_empty():
		return
	_sent = true
	var recipient := member
	# add_text renders literal text, never BBCode or a translation key.
	phone.state.history.append({"id": "", "sender": "trung", "name_key": "UI_CH2_TRUNG",
		"text_key": text, "raw_text": true, "recipient": String(recipient),
		"minutes": phone.state.minutes, "outgoing": true, "spoken": false})
	phone._render_transcript()
	cancel_entry()
	EventBus.prediction_sent.emit(recipient, text)


func advance(delta: float) -> void:
	if member.is_empty():
		return
	if not is_visible_in_tree() or phone._blocked() or phone.state.battery <= 0.0:
		cancel_entry()
	if get_tree().paused:
		return
	remaining = maxf(0.0, remaining - delta)
	if remaining <= 0.0:
		close_request() # Core alone judges silence; no synthetic message.
	refresh()


func refresh() -> void:
	visible = not member.is_empty()
	if member.is_empty():
		return
	var temperatures := PackedStringArray()
	for value in _history:
		temperatures.append(str(value))
	_recipient.text = tr("UI_PREDICTION_RECIPIENT") % tr(NAMES[member])
	_clock.text = tr("UI_PREDICTION_HISTORY") % [", ".join(temperatures), ceili(remaining)]
	_help.text = tr("UI_PREDICTION_SENT" if _sent else "UI_TEXT_ENTRY_CONTROLS" if entry.visible else "UI_PREDICTION_OPEN")


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		refresh()
