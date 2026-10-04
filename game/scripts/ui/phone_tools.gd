extends VBoxContainer
## Phone-only navigation; never captures the mouse or pauses the world.

var phone: CanvasLayer
var _room_index := 30
var _tabs: HBoxContainer
var _map: VBoxContainer
var _camera: VBoxContainer
var _grid: GridContainer
var _feed: TextureRect
var _caption: Label
var _notice: Label
var _network: Control
var _static_left := 0.0
var _notice_left := 0.0
var _buzz_left := 0.0
## Read-only for QA (lane C bot): 0 call, 1 map, 2 camera (integrator, T-163 review).
var current_tab: int:
	get:
		return phone.state.tab if phone != null else 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tabs = HBoxContainer.new()
	add_child(_tabs)
	for index in 3:
		var button := _button(_tabs, ["UI_PHONE_TAB_CALL", "UI_PHONE_TAB_MAP", "UI_PHONE_TAB_CAMERA"][index], select_tab.bind(index))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_notice = _label(self, "")
	_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_notice.hide()
	_map = VBoxContainer.new()
	add_child(_map)
	_grid = GridContainer.new()
	_grid.columns = 8
	_grid.add_theme_constant_override("h_separation", 4)
	_grid.add_theme_constant_override("v_separation", 1)
	_map.add_child(_grid)
	for index in 48:
		var room := (index / 8 + 1) * 100 + index % 8 + 1
		var button := _button(_grid, str(room), toggle_room.bind(room))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 18)
	_label(_map, "UI_PHONE_MAP_HELP")
	_camera = VBoxContainer.new()
	_camera.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_camera)
	var nav := HBoxContainer.new()
	_camera.add_child(nav)
	_button(nav, "UI_CCTV_PREVIOUS", cycle_camera.bind(-1))
	_caption = _label(nav, "")
	_caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button(nav, "UI_CCTV_NEXT", cycle_camera.bind(1))
	_feed = TextureRect.new()
	_feed.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_feed.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_feed.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_feed.custom_minimum_size.y = 175
	_feed.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = preload("res://ui/phone/cctv.gdshader")
	_feed.material = material
	_camera.add_child(_feed)
	_network = Control.new()
	_network.custom_minimum_size = Vector2(24, 24)
	_network.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tabs.add_child(_network)
	_network.draw.connect(_draw_network)
	EventBus.cctv_unlocked.connect(func() -> void:
		phone.state.camera_unlocked = true
		refresh())
	EventBus.cctv_focus_requested.connect(_focus_camera)
	EventBus.scare_triggered.connect(_on_scare)
	EventBus.settings_changed.connect(func(section: String, key: String) -> void:
		if section == "accessibility" and key == "reduce_scares" and _reduce():
			phone.get_node("Root/Phone").position.x -= phone.get_node("Root/Phone").get_meta("buzz_offset", 0.0)
			phone.get_node("Root/Phone").set_meta("buzz_offset", 0.0))
	refresh()


func _button(parent: Node, key: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = key
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 19)
	# Compact phone controls must fit above the HUD subtitle strip.
	for state_name in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.12, 0.16, 0.21) if state_name == "normal" else Color(0.2, 0.28, 0.35)
		style.content_margin_left = 6
		style.content_margin_right = 6
		style.content_margin_top = 3
		style.content_margin_bottom = 3
		style.set_corner_radius_all(3)
		button.add_theme_stylebox_override(state_name, style)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _label(parent: Node, key: String) -> Label:
	var label := Label.new()
	label.text = key
	label.add_theme_font_size_override("font_size", 18)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func select_tab(index: int) -> void:
	if index == 2 and not phone.state.camera_unlocked:
		return
	phone.state.tab = index
	refresh()


func toggle_room(room: int) -> void:
	if room / 100 not in range(1, 7) or room % 100 not in range(1, 9):
		return
	if phone.state.marked_rooms.has(room):
		phone.state.marked_rooms.erase(room)
	else:
		phone.state.marked_rooms.append(room)
	refresh()


func handle_input(event: InputEvent) -> bool:
	if not (event is InputEventKey) or not event.pressed:
		return false
	var code: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
	if code in [KEY_BRACKETLEFT, KEY_BRACKETRIGHT]:
		select_tab(posmod(phone.state.tab + (1 if code == KEY_BRACKETRIGHT else -1), 3 if phone.state.camera_unlocked else 2))
		return true
	if phone.state.tab == 1:
		match code:
			KEY_LEFT: _room_index = posmod(_room_index - 1, 48)
			KEY_RIGHT: _room_index = posmod(_room_index + 1, 48)
			KEY_UP: _room_index = posmod(_room_index - 8, 48)
			KEY_DOWN: _room_index = posmod(_room_index + 8, 48)
			KEY_ENTER, KEY_KP_ENTER:
				toggle_room((_room_index / 8 + 1) * 100 + _room_index % 8 + 1)
			_: return false
		refresh()
		return true
	if phone.state.tab == 2 and code in [KEY_COMMA, KEY_PERIOD]:
		cycle_camera(-1 if code == KEY_COMMA else 1)
		return true
	return false


func _feeds() -> Array[Node]:
	return get_tree().get_nodes_in_group("cctv_feed")


func cycle_camera(direction: int) -> void:
	var feeds := _feeds()
	if feeds.is_empty():
		return
	var index := -1
	for current in feeds.size():
		if str(feeds[current].camera_id) == phone.state.camera_id:
			index = current
	phone.state.camera_id = str(feeds[posmod(index + direction, feeds.size())].camera_id)
	_refresh_feed()


func _focus_camera(id: StringName) -> void:
	if not phone.state.camera_unlocked or phone.state.battery <= 0.0:
		return
	var name_key := ""
	for node in _feeds():
		if node.camera_id == id:
			name_key = node.label_key
	_notice.set_meta("camera_label", name_key)
	_notice.set_meta("camera_id", String(id))
	_notice_left = 5.0
	_buzz_left = 0.4
	if phone.state.raised:
		phone.state.camera_id = String(id)
		phone.state.tab = 2
	refresh()


func _reduce() -> bool:
	return bool(Settings.get_value("accessibility", "reduce_scares"))


func _on_scare(id: StringName) -> void:
	if id == &"cctv_kill" and _reduce():
		_static_left = 1.5
		_feed.material.set_shader_parameter("obscured", true)


func advance(delta: float) -> void:
	_static_left = maxf(0.0, _static_left - delta)
	_feed.material.set_shader_parameter("obscured", _static_left > 0.0)
	_notice_left = maxf(0.0, _notice_left - delta)
	_notice.visible = _notice_left > 0.0 and phone.state.battery > 0.0
	_buzz_left = maxf(0.0, _buzz_left - delta)
	var panel: Control = phone.get_node("Root/Phone")
	var offset := sin(_buzz_left * 100.0) * 3.0 if _buzz_left > 0.0 and not _reduce() else 0.0
	panel.position.x += offset - float(panel.get_meta("buzz_offset", 0.0))
	panel.set_meta("buzz_offset", offset)
	if phone.state.tab == 2 and phone.state.raised:
		_refresh_feed()


func refresh_network() -> void:
	_network.queue_redraw()


func _draw_network() -> void:
	var color := Color(0.9, 0.3, 0.25) if phone.state.connection_lost else Color(0.5, 0.85, 0.65)
	for index in 3:
		_network.draw_rect(Rect2(2 + index * 6, 17 - index * 5, 4, 6 + index * 5), color)
	if phone.state.connection_lost:
		_network.draw_line(Vector2(0, 0), Vector2(23, 24), color, 3.0)


func refresh() -> void:
	if not is_node_ready():
		return
	var tab: int = phone.state.tab
	for index in 3:
		_tabs.get_child(index).modulate = Color(1, 0.85, 0.5) if index == tab else Color.WHITE
	_tabs.get_child(2).disabled = not phone.state.camera_unlocked
	for name in ["Call", "MembersScroll", "Transcript", "ScrollHint"]:
		phone.get_node("Root/Phone/Content/" + name).visible = tab == 0
	_map.visible = tab == 1
	_camera.visible = tab == 2
	size_flags_vertical = Control.SIZE_EXPAND_FILL if tab != 0 else Control.SIZE_FILL
	for index in 48:
		var room := (index / 8 + 1) * 100 + index % 8 + 1
		var button: Button = _grid.get_child(index)
		var marked: bool = phone.state.marked_rooms.has(room)
		button.text = str(room) + (" ×" if marked else " *" if room == 407 else "")
		button.modulate = Color(1, 0.4, 0.35) if marked else Color(1, 0.85, 0.5) if index == _room_index else Color.WHITE
		button.tooltip_text = tr("UI_PHONE_MY_ROOM") if room == 407 else str(room)
	if _notice_left > 0.0:
		var key: String = _notice.get_meta("camera_label", "")
		_notice.text = tr("UI_CCTV_MOVEMENT") % (tr(key) if not key.is_empty() else str(_notice.get_meta("camera_id", "")))
	_notice.visible = _notice_left > 0.0
	_refresh_feed()
	refresh_network()


func _refresh_feed() -> void:
	var feeds := _feeds()
	var selected: Node
	for node in feeds:
		if str(node.camera_id) == phone.state.camera_id:
			selected = node
	if selected == null and phone.state.camera_id.is_empty() and not feeds.is_empty():
		selected = feeds[0]
		phone.state.camera_id = str(selected.camera_id)
	_feed.texture = selected.get_texture() if selected != null else null
	var clock := "%02d:%02d" % [(phone.state.minutes / 60) % 24, phone.state.minutes % 60]
	_caption.text = tr("UI_CCTV_CAPTION") % [tr(selected.label_key), clock] if selected != null else tr("UI_CCTV_NO_FEED")
	_caption.add_theme_color_override("font_color", Color(1, 0.4, 0.35))
