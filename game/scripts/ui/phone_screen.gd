extends CanvasLayer
## Non-modal phone: never changes mouse mode, pauses gameplay or consumes movement.

const PhoneState = preload("res://scripts/ui/phone_state.gd")
const MemberView = preload("res://scripts/ui/phone_member.gd")
const ToolsView = preload("res://scripts/ui/phone_tools.gd")

@export_range(0.1, 60.0) var choice_seconds := 10.0
@export_range(0.1, 30.0) var subtitle_seconds := 4.0

var state := PhoneState.new()
var _paused := false
var _documents: Dictionary = {}
var _puzzles: Dictionary = {}
var _hidden := false
var _holding := false
var _contraction := 0.0
var tools_view: Control
var prediction: VBoxContainer
var ch4: VBoxContainer


func _ready() -> void:
	state.minutes = GameState.minutes
	EventBus.phone_raised.connect(_on_raised)
	EventBus.phone_battery_changed.connect(_on_battery)
	EventBus.flashlight_toggled.connect(func(on: bool) -> void:
		state.flashlight = on and state.battery > 0.0
		_refresh_status())
	EventBus.time_changed.connect(func(minutes: int) -> void:
		state.minutes = minutes
		_refresh_status())
	EventBus.phone_call_incoming.connect(_on_incoming)
	EventBus.phone_call_answered.connect(_on_answered)
	EventBus.phone_call_lost.connect(_on_connection_lost)
	EventBus.phone_call_restored.connect(_on_connection_restored)
	EventBus.phone_message_received.connect(_on_message)
	EventBus.chat_member_changed.connect(_on_member)
	EventBus.chat_choice_requested.connect(_on_choice)
	EventBus.game_paused.connect(func(paused: bool) -> void:
		_paused = paused
		_refresh_visibility())
	EventBus.document_opened.connect(func(id: StringName) -> void:
		_documents[id] = true
		_refresh_visibility())
	EventBus.document_closed.connect(func(id: StringName) -> void:
		_documents.erase(id)
		_refresh_visibility())
	EventBus.puzzle_opened.connect(func(id: StringName) -> void:
		_puzzles[id] = true
		_refresh_visibility())
	EventBus.puzzle_closed.connect(_close_puzzle)
	EventBus.puzzle_solved.connect(_close_puzzle)
	EventBus.player_hidden.connect(func(hidden: bool, _kind: StringName) -> void:
		_hidden = hidden
		if not hidden:
			_holding = false
		_refresh_visibility())
	EventBus.breath_held.connect(func(holding: bool) -> void: _holding = holding and _hidden)
	var paper := StyleBoxFlat.new()
	paper.bg_color = Color(0.018, 0.037, 0.041, 1)
	paper.set_border_width_all(10)
	paper.border_color = Color(0.07, 0.085, 0.086, 1)
	paper.set_corner_radius_all(30)
	paper.shadow_color = Color(0, 0, 0, 0.7)
	paper.shadow_size = 12
	paper.content_margin_left = 24
	paper.content_margin_right = 24
	paper.content_margin_top = 18
	paper.content_margin_bottom = 18
	$Root/Phone.add_theme_stylebox_override("panel", paper)
	$Root/Phone.draw.connect(_draw_phone_shell)
	# D-133: the choices lie over the top of the larger phone's chat, opaque so its lines don't show through.
	var sheet := StyleBoxFlat.new()
	sheet.bg_color = Color(0.03, 0.06, 0.066, 1)
	sheet.set_border_width_all(2)
	sheet.border_color = Color("788776")
	sheet.set_corner_radius_all(16)
	sheet.shadow_color = Color(0, 0, 0, 0.6)
	sheet.shadow_size = 10
	sheet.content_margin_left = 24
	sheet.content_margin_right = 24
	sheet.content_margin_top = 16
	sheet.content_margin_bottom = 16
	$Root/Choices.add_theme_stylebox_override("panel", sheet)
	var battery := Control.new()
	battery.name = "BatteryIcon"
	battery.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Root/Phone/Content/Status.add_child(battery)
	battery.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	battery.position = Vector2(-162, 6)
	battery.size = Vector2(36, 22)
	battery.draw.connect(func() -> void:
		var ink := Color("c8d9c9") if state.battery > 15.0 else Color("ebaa85")
		battery.draw_rect(Rect2(0, 1, 29, 16), ink, false, 1.5)
		battery.draw_rect(Rect2(30, 5, 3, 8), ink)
		battery.draw_rect(Rect2(3, 4, 23.0 * clampf(state.battery / 100.0, 0, 1), 10), ink))
	var light := Control.new()
	light.name = "Flashlight"
	light.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Root/Phone/Content/Status.add_child(light)
	light.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	light.position.x -= 28
	light.size = Vector2(28, 26)
	light.draw.connect(func() -> void:
		var color := Color(1, 0.9, 0.55) if state.flashlight else Color(0.3, 0.35, 0.4)
		light.draw_rect(Rect2(2, 10, 12, 8), color)
		light.draw_line(Vector2(14, 10), Vector2(20, 6), color, 3)
		light.draw_line(Vector2(14, 18), Vector2(20, 22), color, 3)
		light.draw_line(Vector2(20, 6), Vector2(20, 22), color, 3))
	tools_view = ToolsView.new()
	tools_view.name = "Tools"
	tools_view.phone = self
	$Root/Phone/Content.add_child(tools_view)
	$Root/Phone/Content.move_child(tools_view, 1)
	prediction = preload("res://scripts/ui/phone_prediction.gd").new()
	prediction.name = "Prediction"
	prediction.phone = self
	$Root/Phone/Content.add_child(prediction)
	ch4 = preload("res://scripts/ui/ch4_phone.gd").new()
	ch4.name = "Chapter4"
	ch4.phone = self
	$Root/Phone/Content.add_child(ch4)
	_render()


func _draw_phone_shell() -> void:
	var panel: PanelContainer = $Root/Phone
	var edge := StyleBoxFlat.new()
	edge.bg_color = Color(0, 0, 0, 0)
	edge.set_border_width_all(1)
	edge.border_color = Color(0.48, 0.58, 0.57, 0.65)
	edge.set_corner_radius_all(27)
	panel.draw_style_box(edge, Rect2(Vector2(3, 3), panel.size - Vector2(6, 6)))
	panel.draw_line(Vector2(panel.size.x * 0.43, 9), Vector2(panel.size.x * 0.57, 9), Color("03080a"), 4, true)
	panel.draw_circle(Vector2(panel.size.x * 0.6, 9), 2.5, Color("263c40"))
	panel.draw_line(Vector2(panel.size.x * 0.42, panel.size.y - 9), Vector2(panel.size.x * 0.58, panel.size.y - 9), Color(0.7, 0.8, 0.76, 0.4), 3, true)
	panel.draw_colored_polygon(PackedVector2Array([Vector2(14, 25), Vector2(panel.size.x * 0.7, 14), Vector2(14, panel.size.y * 0.75)]), Color(0.62, 0.82, 0.82, 0.025))


func _process(delta: float) -> void:
	_refresh_visibility()
	prediction.advance(delta)
	ch4.advance(delta)
	if _blocked():
		return
	tools_view.advance(delta)
	_contraction = move_toward(_contraction, 1.0 if _holding else 0.0, delta * 2.0)
	$Root/HiddenVignette.material.set_shader_parameter("contraction", _contraction)
	if not state.choice.is_empty():
		state.remaining = maxf(0.0, state.remaining - delta)
		$Root/Choices/Content/Timer.value = state.remaining
		if state.remaining <= 0.0:
			_finish_choice(-1)


func _input(event: InputEvent) -> void:
	if _blocked() or not state.raised or state.battery <= 0.0 or event.is_echo():
		return
	if preload("res://scripts/ui/game_text_entry.gd").is_typing(get_tree()):
		return
	if ch4.is_active():
		return
	if not prediction.member.is_empty():
		if event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
			get_viewport().set_input_as_handled()
			prediction.open_entry()
		return
	if not state.incoming.is_empty() and event.is_action_pressed("interact"):
		_consume_interact()
		EventBus.phone_call_answered.emit(StringName(state.incoming))
		return
	if tools_view.handle_input(event):
		get_viewport().set_input_as_handled()
		return
	if not state.choice.is_empty() and not state.disconnected_choice:
		if event is InputEventKey and event.pressed:
			var code: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
			if code >= KEY_1 and code <= KEY_4:
				get_viewport().set_input_as_handled()
				_choose(code - KEY_1)
				return
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				_consume_interact()
				_choose(state.selected)
				return
	if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		var direction := 1 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1
		if event.shift_pressed:
			$Root/Phone/Content/MembersScroll.scroll_horizontal += direction * 100
		elif not state.choice.is_empty() and not state.disconnected_choice:
			state.selected = posmod(state.selected + direction, state.options.size())
			_render_choices()
		elif state.tab == 0:
			$Root/Phone/Content/Transcript.get_v_scroll_bar().value += direction * 64
		get_viewport().set_input_as_handled()


func _consume_interact() -> void:
	get_viewport().set_input_as_handled()
	# Player currently polls interact in physics; handled events alone do not suppress it.
	Input.action_release("interact")


func _blocked() -> bool:
	if _paused or get_tree().paused or not _documents.is_empty() or not _puzzles.is_empty():
		return true
	for overlay in get_tree().get_nodes_in_group("reading_overlay"):
		if overlay.is_open():
			return true
	return false


func _refresh_visibility() -> void:
	# The scene may be freeing (Player._exit_tree still emits player_hidden).
	if not is_inside_tree():
		return
	var blocked := _blocked()
	var predicting: bool = is_instance_valid(prediction) and not prediction.member.is_empty()
	predicting = predicting or (is_instance_valid(ch4) and ch4.is_active())
	$Root/Phone/Content/MembersScroll.visible = not predicting and state.tab == 0
	$Root/Phone/Content/ScrollHint.visible = not predicting and state.tab == 0
	tools_view.visible = not predicting
	if predicting:
		state.tab = 0
		$Root/Phone/Content/Transcript.show()
		if blocked or not state.raised or state.battery <= 0.0:
			prediction.cancel_entry()
			if is_instance_valid(ch4):
				ch4.editor.cancel_entry()
	$Root/Phone.visible = state.raised and not blocked
	$Root/Phone/Content.visible = state.battery > 0.0
	$Root/Phone/BlackScreen.visible = state.battery <= 0.0
	$Root/Incoming.visible = not state.incoming.is_empty() and state.battery > 0.0 and not blocked
	$Root/Choices.visible = not state.choice.is_empty() and state.raised and state.battery > 0.0 and not state.disconnected_choice and not blocked
	$Root/HiddenVignette.visible = _hidden and not blocked
	$Root/BreathHint.visible = _hidden and not blocked


func _on_raised(raised: bool) -> void:
	state.raised = raised
	_refresh_status()
	_refresh_visibility()


func _on_battery(percent: float) -> void:
	if not is_finite(percent):
		return
	state.battery = clampf(percent, 0.0, 100.0)
	if state.battery <= 0.0:
		state.incoming = ""
		state.call = ""
		state.connection_lost = false
		state.flashlight = false
		state.disconnected_choice = true
	_refresh_status()
	_refresh_visibility()


func _on_incoming(id: StringName) -> void:
	if state.battery <= 0.0 or id.is_empty():
		return
	state.incoming = String(id)
	# Lane E listens to this same incoming signal; never re-emit it recursively.
	_refresh_status()
	_refresh_visibility()


func _on_answered(id: StringName) -> void:
	if state.battery <= 0.0 or String(id) != state.incoming:
		return
	state.call = String(id)
	state.incoming = ""
	state.connection_lost = false
	_refresh_status()
	_refresh_visibility()


func _load_message(id: StringName) -> MessageData:
	return MessageData.load_by_id(id)


func _on_connection_lost(id: StringName) -> void:
	if String(id) != state.call or state.call.is_empty():
		return
	state.connection_lost = true
	_refresh_status()


func _on_connection_restored(id: StringName) -> void:
	if String(id) != state.call or not state.connection_lost or state.battery <= 0.0:
		return
	state.connection_lost = false
	state.history.append({"id": "", "sender": "", "name_key": "UI_PHONE_SYSTEM",
		"text_key": "UI_PHONE_RECONNECTED", "minutes": state.minutes, "outgoing": false, "spoken": false})
	_render_transcript()
	_refresh_status()


func _on_message(id: StringName) -> void:
	if state.battery <= 0.0:
		return
	var message := _load_message(id)
	if message == null or message.text_key.is_empty():
		return
	if message.spoken and state.connection_lost:
		return
	state.history.append({"id": String(id), "sender": String(message.sender),
		"name_key": message.sender_name_key, "text_key": message.text_key, "minutes": message.minutes,
		"outgoing": message.outgoing, "spoken": message.spoken})
	var sender := String(message.sender)
	if not state.members.has(sender):
		state.members[sender] = {"state": "joined", "name_key": message.sender_name_key}
	else:
		state.members[sender]["name_key"] = message.sender_name_key
	_render_members()
	_render_transcript()
	if message.spoken:
		EventBus.subtitle_requested.emit(message.text_key, subtitle_seconds)


func _on_member(id: StringName, member_state: StringName) -> void:
	if id.is_empty() or member_state not in [&"joined", &"dead", &"left"]:
		return
	var name_key: String = state.members.get(String(id), {}).get("name_key", "")
	state.members[String(id)] = {"state": String(member_state), "name_key": name_key}
	_render_members()


func _on_choice(id: StringName, option_keys: PackedStringArray) -> void:
	if id.is_empty() or option_keys.size() < 2 or option_keys.size() > 4:
		return
	for key in option_keys:
		if key.is_empty():
			return
	if not state.choice.is_empty():
		return # Core issues one prompt at a time; do not silently replace an unanswered prompt.
	state.choice = String(id)
	state.options = option_keys.duplicate()
	state.remaining = maxf(0.1, choice_seconds)
	state.selected = 0
	state.disconnected_choice = state.battery <= 0.0
	EventBus.phone_raised.emit(true)
	_render_choices()
	_refresh_visibility()


func _choose(index: int) -> void:
	if _blocked() or state.disconnected_choice or state.battery <= 0.0 or index < 0 or index >= state.options.size():
		return
	_consume_interact()
	_finish_choice(index)


func _finish_choice(index: int) -> void:
	if state.choice.is_empty():
		return
	var id := StringName(state.choice)
	state.choice = ""
	state.options.clear()
	state.remaining = 0.0
	_refresh_visibility()
	EventBus.chat_choice_made.emit(id, index)


func _close_puzzle(id: StringName) -> void:
	_puzzles.erase(id)
	_refresh_visibility()


func snapshot() -> Dictionary:
	return state.snapshot()


func restore(data: Dictionary) -> void:
	prediction.close_request()
	ch4.reset_view()
	state.restore(data)
	_render() # No replay of speech, incoming calls or player-choice signals.


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_render()


func _render() -> void:
	_refresh_status()
	_render_members()
	_render_transcript()
	_render_choices()
	_refresh_visibility()
	tools_view.refresh()


func _refresh_status() -> void:
	var clock := "%02d:%02d" % [(state.minutes / 60) % 24, state.minutes % 60]
	$Root/Phone/Content/Status.text = tr("UI_PHONE_STATUS") % [clock, int(state.battery), tr("UI_PHONE_NO_SIGNAL")]
	$Root/Phone/Content/Status/Flashlight.tooltip_text = tr("UI_PHONE_LIGHT_ON" if state.flashlight else "UI_PHONE_LIGHT_OFF")
	$Root/Phone/Content/Status/Flashlight.queue_redraw()
	$Root/Phone/Content/Status/BatteryIcon.queue_redraw()
	$Root/Phone/Content/Call.text = tr("UI_PHONE_GROUP_CALL" if not state.call.is_empty() else "UI_PHONE_HISTORY")
	if state.connection_lost:
		$Root/Phone/Content/Call.text = tr("UI_PHONE_CONNECTION_LOST")
	$Root/Phone/Content/MembersScroll.modulate.a = 0.35 if state.connection_lost else 1.0
	if is_instance_valid(tools_view):
		tools_view.refresh_network()
	$Root/Incoming/Content/Hint.text = tr("UI_PHONE_ANSWER" if state.raised else "UI_PHONE_RAISE_ANSWER")


func _render_members() -> void:
	var parent := $Root/Phone/Content/MembersScroll/Members
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
	for id: String in state.members:
		var entry: Dictionary = state.members[id]
		var member := MemberView.new()
		member.configure(id, tr(entry["name_key"]) if not entry["name_key"].is_empty() else id, entry["state"])
		parent.add_child(member)


func _render_transcript() -> void:
	var transcript: RichTextLabel = $Root/Phone/Content/Transcript
	transcript.clear()
	if state.history.is_empty():
		transcript.add_text(tr("UI_PHONE_EMPTY"))
	for entry in state.history:
		var minutes: int = entry["minutes"]
		var clock := "%02d:%02d" % [(minutes / 60) % 24, minutes % 60]
		var sender: String = tr(entry["name_key"]) if not entry["name_key"].is_empty() else entry["sender"]
		transcript.push_paragraph(HORIZONTAL_ALIGNMENT_RIGHT if entry["outgoing"] else HORIZONTAL_ALIGNMENT_LEFT)
		transcript.add_text(tr("UI_PHONE_TRANSCRIPT_LINE") % [clock, sender, entry["text_key"] if entry.get("raw_text", false) else tr(entry["text_key"])])
		transcript.add_text("\n")
		transcript.pop()


func _render_choices() -> void:
	var parent := $Root/Choices/Content/Options
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()
	for index in state.options.size():
		var button := Button.new()
		button.name = "Option%d" % (index + 1)
		button.text = tr("UI_PHONE_OPTION") % [index + 1, tr(state.options[index])]
		button.add_theme_font_size_override("font_size", 24)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.focus_mode = Control.FOCUS_NONE
		button.modulate = Color(1, 0.88, 0.58) if index == state.selected else Color.WHITE
		button.pressed.connect(_choose.bind(index))
		parent.add_child(button)
	$Root/Choices/Content/Timer.max_value = maxf(choice_seconds, state.remaining)
	$Root/Choices/Content/Timer.value = state.remaining
