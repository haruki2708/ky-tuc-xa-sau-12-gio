extends VBoxContainer
## Last group message shares the phone transcript and native text editor.

var phone: CanvasLayer
var editor: VBoxContainer
var effect: CanvasLayer
var fade_elapsed := 0.0
var fade_seconds := 12.0
var fading := false
var charges := 0
var badge: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var title := Label.new()
	title.text = "UI_CH4_LAST_MESSAGE"
	title.add_theme_font_size_override("font_size", 24)
	add_child(title)
	editor = preload("res://scripts/ui/ch4_timed_entry.gd").new()
	editor.name = "Message"
	add_child(editor)
	editor.submitted.connect(func(text: String) -> void: EventBus.fade_message_typed.emit(text))
	badge = Label.new()
	badge.name = "DecoyCharges"
	badge.add_theme_font_size_override("font_size", 24)
	phone.get_node("Root/Phone/Content/Status").add_child(badge)
	badge.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	badge.position.x = -115
	badge.custom_minimum_size.x = 72
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.draw.connect(func() -> void:
		badge.draw_arc(Vector2(15, 12), 8, PI, TAU, 12, Color("c6dbd4"), 2)
		badge.draw_line(Vector2(7, 12), Vector2(6, 21), Color("c6dbd4"), 2)
		badge.draw_line(Vector2(23, 12), Vector2(24, 21), Color("c6dbd4"), 2)
		badge.draw_line(Vector2(5, 21), Vector2(25, 21), Color("c6dbd4"), 2)
		badge.draw_circle(Vector2(15, 25), 2, Color("c6dbd4")))
	effect = preload("res://ui/ch4/fade_effect.tscn").instantiate()
	phone.add_child(effect)
	EventBus.fade_message_requested.connect(_request)
	EventBus.fade_message_closed.connect(_closed)
	EventBus.phone_decoy_thrown.connect(func(_at: Vector3, left: int) -> void:
		charges = maxi(0, left)
		_refresh_badge())
	EventBus.flag_changed.connect(func(key: StringName, value: Variant) -> void:
		if key == &"ch4_phone_charges":
			charges = maxi(0, int(value))
			_refresh_badge())
	EventBus.chapter_started.connect(func(_chapter: int) -> void: reset_view())
	EventBus.checkpoint_loaded.connect(func(_id: StringName) -> void: reset_view())
	EventBus.player_death_started.connect(func(_kind: StringName) -> void: reset_view())
	EventBus.player_failed.connect(func(_reason: StringName) -> void: reset_view())
	EventBus.ch4_ending.connect(func(_kind: StringName) -> void: reset_view())
	reset_view()


func is_active() -> bool:
	return editor.active


func reset_view() -> void:
	editor.close_request()
	fading = false
	fade_elapsed = 0.0
	effect.get_node("Root").hide()
	charges = maxi(0, int(GameState.get_flag(&"ch4_phone_charges", 0)))
	_refresh_badge()
	hide()


func _refresh_badge() -> void:
	badge.visible = GameState.chapter == 4
	badge.text = tr("UI_CH4_RING_CHARGES") % charges


func _request(seconds: float) -> void:
	if GameState.chapter != 4 or not is_finite(seconds) or seconds <= 0.0:
		return
	for reader in get_tree().get_nodes_in_group("reading_overlay"):
		if reader.is_open():
			reader.close_view()
	phone.prediction.close_request()
	phone.tools_view.select_tab(0)
	EventBus.phone_raised.emit(true)
	fade_seconds = seconds
	fade_elapsed = 0.0
	fading = true
	show()
	effect.get_node("Root").show()
	editor.request(seconds)
	phone._refresh_visibility()
	editor.open_entry()


func _closed(result: StringName) -> void:
	if not editor.active or result not in [&"sent", &"timeout"]:
		return
	if result == &"sent" and editor.waiting:
		phone.state.history.append({"id": "", "sender": "trung", "name_key": "UI_CH2_TRUNG",
			"text_key": editor.last_text, "raw_text": true, "minutes": phone.state.minutes,
			"outgoing": true, "spoken": false})
		phone._render_transcript()
	editor.close_request()
	hide()
	phone._refresh_visibility()


func advance(delta: float) -> void:
	if editor.active:
		if phone._blocked() or not phone.state.raised or phone.state.battery <= 0.0:
			editor.cancel_entry()
		editor.advance(delta)
		visible = editor.active
	if fading and not get_tree().paused:
		fade_elapsed = minf(fade_seconds, fade_elapsed + delta)
	var amount := clampf(fade_elapsed / maxf(fade_seconds, 0.001), 0.0, 1.0)
	effect.get_node("Root").visible = fading and not phone._blocked()
	effect.get_node("Root/Edges").material.set_shader_parameter("amount", amount)
	effect.get_node("Root/Hands").modulate.a = 1.0 - amount


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh_badge()
