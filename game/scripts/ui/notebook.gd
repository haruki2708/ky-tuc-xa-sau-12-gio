extends "res://scripts/ui/reading_overlay.gd"

const SOURCE_KEYS := {
	&"speaker": "SOURCE_SPEAKER", &"hall_board": "SOURCE_HALL_BOARD",
	&"room_paper": "SOURCE_ROOM_PAPER", &"handwritten_note": "SOURCE_HANDWRITTEN_NOTE",
	&"washroom_notice": "SOURCE_WASHROOM_NOTICE",
}
var _hint_sent := false
var _refresh_pending := false


func _ready() -> void:
	super._ready()
	_hint_sent = not RuleSystem.read_rules().is_empty()
	EventBus.rule_entry_added.connect(_on_entry_added)
	EventBus.rule_suspicion_changed.connect(_on_suspicion_changed)
	EventBus.rule_read.connect(_on_rule_read)
	$Root/Book/Content/Close.pressed.connect(close_view)
	_render()


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if _open and (event.is_action_pressed("notebook") or event.is_action_pressed("pause")):
		get_viewport().set_input_as_handled()
		close_view()
	elif not _open and event.is_action_pressed("notebook") and not get_tree().paused:
		get_viewport().set_input_as_handled()
		open_notebook()


func open_notebook() -> void:
	if _begin_reading():
		_render()
		$Root/Book/Content/Scroll.scroll_vertical = 0


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_queue_refresh()


func _on_entry_added(_rule_id: StringName, _source: StringName) -> void:
	_queue_refresh()


func _on_suspicion_changed(_rule_id: StringName, _suspected: bool) -> void:
	_queue_refresh()


func _on_rule_read(_rule_id: StringName) -> void:
	if not _hint_sent:
		_hint_sent = true
		EventBus.subtitle_requested.emit("SUB_NOTEBOOK_HINT", 3.0)


func _queue_refresh() -> void:
	if not _refresh_pending:
		_refresh_pending = true
		_render.call_deferred()


func _render() -> void:
	_refresh_pending = false
	var groups: VBoxContainer = $Root/Book/Content/Scroll/Groups
	for child in groups.get_children():
		groups.remove_child(child)
		child.queue_free()
	var entries := RuleSystem.read_entries()
	$Root/Book/Content/Empty.visible = entries.is_empty()
	var sources: Dictionary = {}
	for entry in entries:
		var source: StringName = entry["source"]
		if not sources.has(source):
			var section := VBoxContainer.new()
			section.set_meta("source", source)
			section.add_theme_constant_override("separation", 14)
			groups.add_child(section)
			var heading := Label.new()
			heading.text = tr(SOURCE_KEYS[source]) if SOURCE_KEYS.has(source) else String(source)
			heading.add_theme_font_size_override("font_size", 32)
			heading.add_theme_color_override("font_color", Color("bcd4db"))
			section.add_child(heading)
			sources[source] = section
		_add_entry(sources[source], entry)


func _add_entry(parent: VBoxContainer, entry: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.set_meta("rule_id", entry["rule_id"])
	row.add_theme_constant_override("separation", 24)
	parent.add_child(row)
	var label := Label.new()
	label.name = "Text"
	label.text = tr(entry["text_key"])
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 26)
	row.add_child(label)
	var suspected := RuleSystem.is_suspected(entry["rule_id"])
	var button := CheckButton.new()
	button.name = "Suspect"
	button.text = "UI_NOTEBOOK_SUSPECT"
	button.button_pressed = suspected
	button.custom_minimum_size = Vector2(232, 60)
	# Keep text/icon spacing stable when the shared theme switches button states.
	for state: String in ["normal", "hover", "pressed", "hover_pressed"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color("472e30") if suspected else Color("202d38")
		box.content_margin_left = 16
		box.content_margin_right = 42
		box.content_margin_top = 10
		box.content_margin_bottom = 10
		button.add_theme_stylebox_override(state, box)
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.toggled.connect(_set_suspected.bind(entry["rule_id"]))
	row.add_child(button)
	if suspected:
		label.add_theme_color_override("font_color", Color("ff9b91"))
		var marker := Label.new()
		marker.text = "UI_NOTEBOOK_MARK"
		marker.add_theme_color_override("font_color", Color("ff9b91"))
		row.add_child(marker)


func _set_suspected(value: bool, rule_id: StringName) -> void:
	RuleSystem.set_suspected(rule_id, value)
