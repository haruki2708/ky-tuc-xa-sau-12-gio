extends Control
## First-run acknowledgement, title navigation and injectable core actions.

const SettingsStore = preload("res://scripts/ui/settings.gd")
const CREDIT_SECTIONS := ["KIT", "AUDIO", "FONT", "AI"]

@export var settings_path: NodePath = ^"/root/Settings"
@export var app_path: NodePath = ^"/root/App"

var _settings: SettingsStore
var _screen := ""
var _leaving := false
var _return_focus := "NewGame"


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_settings = get_node_or_null(settings_path) as SettingsStore
	if _settings == null:
		_settings = SettingsStore.new()
		add_child(_settings)
	_build_warning()
	_build_credits()
	$SettingsCard/SettingsPanel.configure(_settings)
	$SettingsCard/SettingsPanel.back_requested.connect(_back_to_menu)
	$Menu/Buttons/Continue.pressed.connect(func() -> void: _start_game(true))
	$Menu/Buttons/NewGame.pressed.connect(_new_game)
	$Menu/Buttons/Settings.pressed.connect(show_settings)
	$Menu/Buttons/Credits.pressed.connect(show_credits)
	$Menu/Buttons/Quit.pressed.connect(_quit_game)
	$Confirmation.confirmed.connect(func() -> void: _start_game(false))
	$Confirmation.cancelled.connect(_back_to_menu)
	EventBus.settings_changed.connect(_settings_changed)
	_settings_changed("accessibility", "reduce_scares")
	if _settings.get_value("ui", "content_warning_seen"):
		show_menu()
	else:
		show_warning()
	$Hum.play()


func _input(event: InputEvent) -> void:
	if _screen == "Credits" and is_visible_in_tree():
		var direction := int(event.is_action_pressed("ui_down")) - int(event.is_action_pressed("ui_up"))
		if direction != 0:
			$Credits/Content/Scroll.scroll_vertical += direction * 64
			get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		get_viewport().set_input_as_handled()
		if _screen in ["SettingsCard", "Credits", "Confirmation"]:
			_back_to_menu()
		elif _screen == "Menu":
			$Menu/Buttons/Quit.grab_focus()
		else:
			$Warning/Content/Continue.grab_focus()


func _show_screen(screen: String) -> void:
	_screen = screen
	for node_name: String in ["Menu", "Warning", "Credits", "SettingsCard", "Confirmation"]:
		get_node(node_name).visible = node_name == screen


func show_warning() -> void:
	_show_screen("Warning")
	$Warning/Content/Continue.grab_focus()


func show_menu() -> void:
	_show_screen("Menu")
	$Menu/Buttons/Continue.visible = _has_saved_game()
	if $Menu/Buttons/Continue.visible:
		$Menu/Buttons/Continue.grab_focus()
	else:
		$Menu/Buttons/NewGame.grab_focus()


func show_settings() -> void:
	_return_focus = "Settings"
	_show_screen("SettingsCard")
	$SettingsCard/SettingsPanel.refresh()
	$SettingsCard/SettingsPanel/Footer/Back.grab_focus()


func show_credits() -> void:
	_return_focus = "Credits"
	_show_screen("Credits")
	$Credits/Content/Scroll.scroll_vertical = 0
	$Credits/Content/Back.grab_focus()


func _back_to_menu() -> void:
	show_menu()
	get_node("Menu/Buttons/" + _return_focus).grab_focus()


func _acknowledge_warning(reduce_scares: bool) -> void:
	var error := OK
	if reduce_scares:
		error = _settings.set_value("accessibility", "reduce_scares", true)
	if error == OK:
		error = _settings.set_value("ui", "content_warning_seen", true)
	$Warning/Content/SaveError.visible = error != OK
	if error == OK:
		show_menu()


func _new_game() -> void:
	if _has_saved_game():
		_return_focus = "NewGame"
		_show_screen("Confirmation")
		$Confirmation.open("UI_NEW_GAME_CONFIRM")
	else:
		_start_game(false)


func _has_saved_game() -> bool:
	var app := get_node_or_null(app_path)
	return app != null and app.has_saved_game()


func _start_game(continue_saved: bool) -> void:
	if _leaving:
		return
	_leaving = true
	_request_start(continue_saved)


func _request_start(continue_saved: bool) -> void:
	var app := get_node_or_null(app_path)
	if app != null:
		app.start_game(continue_saved)


func _quit_game() -> void:
	var app := get_node_or_null(app_path)
	if app != null:
		app.quit()


func _settings_changed(section: String, key: String) -> void:
	if section == "accessibility" and key == "reduce_scares":
		$Background.material.set_shader_parameter("animate_light",
			not _settings.get_value("accessibility", "reduce_scares"))


func _build_warning() -> void:
	var content := _add_card("Warning", Rect2(0.2, 0.28, 0.6, 0.44))
	_add_label(content, "Heading", "UI_CONTENT_WARNING_TITLE", 40)
	var body := _add_label(content, "Description", "UI_CONTENT_WARNING_TEXT", 30)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_add_button(content, "Continue", "UI_TITLE_CONTINUE", _acknowledge_warning.bind(false))
	_add_button(content, "ReduceScares", "UI_WARNING_REDUCE_SCARES", _acknowledge_warning.bind(true))
	var error := _add_label(content, "SaveError", "UI_SETTINGS_SAVE_ERROR", 22)
	error.hide()


func _build_credits() -> void:
	var content := _add_card("Credits", Rect2(0.2, 0.12, 0.6, 0.76))
	_add_label(content, "Heading", "UI_TITLE_CREDITS", 40)
	var scroll := ScrollContainer.new()
	scroll.name = "Scroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.focus_mode = Control.FOCUS_ALL
	scroll.follow_focus = true
	content.add_child(scroll)
	var entries := VBoxContainer.new()
	entries.name = "Entries"
	entries.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entries.add_theme_constant_override("separation", 26)
	scroll.add_child(entries)
	for section: String in CREDIT_SECTIONS:
		_add_label(entries, section + "Heading", "UI_CREDITS_" + section + "_TITLE", 30)
		_add_label(entries, section + "Body", "UI_CREDITS_" + section + "_TEXT", 26)
	_add_button(content, "Back", "UI_SETTINGS_BACK", _back_to_menu)


func _add_card(node_name: String, area: Rect2) -> VBoxContainer:
	var card := PanelContainer.new()
	card.name = node_name
	add_child(card)
	card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card.anchor_left = area.position.x
	card.anchor_top = area.position.y
	card.anchor_right = area.end.x
	card.anchor_bottom = area.end.y
	var content := VBoxContainer.new()
	content.name = "Content"
	content.add_theme_constant_override("separation", 24)
	card.add_child(content)
	return content


func _add_label(parent: Node, node_name: String, key: String, font_size: int) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = key
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label


func _add_button(parent: Node, node_name: String, key: String, action: Callable) -> void:
	var button := Button.new()
	button.name = node_name
	button.text = key
	button.pressed.connect(action)
	parent.add_child(button)
