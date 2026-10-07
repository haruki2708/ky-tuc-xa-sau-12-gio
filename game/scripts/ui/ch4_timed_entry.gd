extends VBoxContainer
## A native IME field with a presentation-only deadline. Core supplies the verdict.

signal submitted(text: String)
const TextEntry = preload("res://scripts/ui/game_text_entry.gd")
var entry: LineEdit
var clock: ProgressBar
var remaining := 0.0
var duration := 1.0
var active := false
var waiting := false
var last_text := ""


func _ready() -> void:
	entry = TextEntry.new()
	entry.name = "Entry"
	add_child(entry)
	entry.text_submitted.connect(_submit)
	entry.cancelled.connect(cancel_entry)
	clock = ProgressBar.new()
	clock.name = "Clock"
	clock.custom_minimum_size.y = 7
	clock.show_percentage = false
	clock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(clock)
	var help := Label.new()
	help.text = "UI_TEXT_ENTRY_CONTROLS"
	help.add_theme_font_size_override("font_size", 18)
	add_child(help)
	close_request()


func request(seconds: float) -> void:
	if not is_finite(seconds) or seconds <= 0.0:
		return
	close_request()
	active = true
	duration = seconds
	remaining = seconds
	waiting = false
	last_text = ""
	entry.clear()
	show()
	open_entry()
	refresh()


func open_entry() -> void:
	if not active or waiting or not is_visible_in_tree() or get_tree().paused:
		return
	if TextEntry.is_typing(get_tree()) and not entry.has_focus():
		return
	entry.show()
	entry.grab_focus()


func cancel_entry() -> void:
	entry.release_focus()
	entry.hide()


func _input(event: InputEvent) -> void:
	if active and not waiting and not event.is_echo() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER] and not TextEntry.is_typing(get_tree()):
		if is_visible_in_tree() and not get_tree().paused:
			get_viewport().set_input_as_handled()
			open_entry()


func _submit(text: String) -> void:
	if not active or waiting or remaining <= 0.0 or get_tree().paused or not is_visible_in_tree() or text.strip_edges().is_empty():
		return
	waiting = true
	last_text = text
	cancel_entry()
	submitted.emit(text)


func retry() -> void:
	if not active or not waiting or remaining <= 0.0:
		return
	waiting = false
	open_entry() # Keep the exact draft, including accents and spacing.


func close_request() -> void:
	active = false
	waiting = false
	remaining = 0.0
	cancel_entry()
	hide()


func advance(delta: float) -> void:
	if not active:
		return
	if get_tree().paused or not is_visible_in_tree():
		cancel_entry()
	if get_tree().paused:
		return
	remaining = maxf(0.0, remaining - delta)
	if remaining <= 0.0:
		close_request() # Never synthesize a verdict or an answer.
	refresh()


func refresh() -> void:
	clock.max_value = duration
	clock.value = remaining
