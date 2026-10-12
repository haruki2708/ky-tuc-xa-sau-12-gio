extends CanvasLayer
## Receives Esc before gameplay's unhandled input, including while paused.

const SettingsStore = preload("res://scripts/ui/settings.gd")
const Motion = preload("res://scripts/ui/ui_motion.gd")

@export var settings_path: NodePath = ^"/root/Settings"
var _open := false
var _previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Root.hide()
	$Root/PauseCard/Buttons/Resume.pressed.connect(close_menu)
	$Root/PauseCard/Buttons/Settings.pressed.connect(show_settings)
	$Root/PauseCard/Buttons/Quit.pressed.connect(_quit_game)
	$Root/PauseCard/Buttons/ReturnTitle.pressed.connect(_confirm_return_to_title)
	$Root/Confirmation.cancelled.connect(_show_pause_buttons)
	$Root/Confirmation.confirmed.connect(_return_to_title)
	$Root/SettingsCard/SettingsPanel.back_requested.connect(_show_pause_buttons)
	var settings := get_node_or_null(settings_path) as SettingsStore
	$Root/SettingsCard/SettingsPanel.configure(settings)
	# Integration requires the Settings autoload; the F6 scene injects a local node.
	$Root/PauseCard/Buttons/Settings.disabled = settings == null


func _input(event: InputEvent) -> void:
	if preload("res://scripts/ui/game_text_entry.gd").is_typing(get_tree()):
		return
	if event.is_action_pressed("pause") and not event.is_echo():
		for reader in get_tree().get_nodes_in_group("reading_overlay"):
			if reader.is_open():
				return
		get_viewport().set_input_as_handled()
		if $Root/Confirmation.visible:
			_show_pause_buttons()
			return
		if _open:
			close_menu()
		else:
			open_menu()


func open_menu() -> void:
	if _open or get_tree().paused:
		return
	for death in get_tree().get_nodes_in_group("death_screen"):
		if death.is_open():
			return
	_previous_mouse_mode = Input.mouse_mode
	_open = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Root.show()
	_show_pause_buttons()
	EventBus.game_paused.emit(true)


func close_menu(animate: bool = true) -> void:
	if not _open:
		return
	_open = false
	$Root/Confirmation.hide()
	if animate:
		Motion.closing_copy($Root, self)
	$Root.hide()
	get_tree().paused = false
	Input.mouse_mode = _previous_mouse_mode
	EventBus.game_paused.emit(false)


func show_settings() -> void:
	$Root/PauseCard.hide()
	$Root/SettingsCard.show()
	Motion.reveal($Root/SettingsCard)
	$Root/SettingsCard/SettingsPanel.refresh()
	$Root/SettingsCard/SettingsPanel/Footer/Back.grab_focus()


func _show_pause_buttons() -> void:
	$Root/Confirmation.hide()
	$Root/SettingsCard.hide()
	$Root/PauseCard.show()
	Motion.reveal($Root/PauseCard)
	$Root/PauseCard/Buttons/Resume.grab_focus()


func _confirm_return_to_title() -> void:
	$Root/PauseCard.hide()
	$Root/Confirmation.open("UI_RETURN_TITLE_CONFIRM")


func _return_to_title() -> void:
	close_menu()
	_request_title()


func _request_title() -> void:
	# Separate the scene transition so tests can intercept it.
	var app := get_node_or_null("/root/App")
	if app != null:
		app.return_to_title()


func _quit_game() -> void:
	var app := get_node_or_null("/root/App")
	if app != null:
		app.quit()
	else:
		_quit_tree()


func _quit_tree() -> void:
	# Keep the standalone fallback separate so tests can intercept the exit.
	get_tree().quit()


func _exit_tree() -> void:
	# Removing an open menu must not leave a permanently paused SceneTree.
	if _open:
		close_menu(false)
