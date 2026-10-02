extends CanvasLayer
## Receives Esc before gameplay's unhandled input, including while paused.

const SettingsStore = preload("res://scripts/ui/settings.gd")

@export var settings_path: NodePath = ^"/root/Settings"
var _open := false
var _previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Root.hide()
	$Root/PauseCard/Buttons/Resume.pressed.connect(close_menu)
	$Root/PauseCard/Buttons/Settings.pressed.connect(show_settings)
	$Root/PauseCard/Buttons/Quit.pressed.connect(_quit_game)
	$Root/SettingsCard/SettingsPanel.back_requested.connect(_show_pause_buttons)
	var settings := get_node_or_null(settings_path) as SettingsStore
	$Root/SettingsCard/SettingsPanel.configure(settings)
	# Integration requires the Settings autoload; the F6 scene injects a local node.
	$Root/PauseCard/Buttons/Settings.disabled = settings == null


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		for reader in get_tree().get_nodes_in_group("reading_overlay"):
			if reader.is_open():
				return
		get_viewport().set_input_as_handled()
		if _open:
			close_menu()
		else:
			open_menu()


func open_menu() -> void:
	if _open or get_tree().paused:
		return
	_previous_mouse_mode = Input.mouse_mode
	_open = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Root.show()
	_show_pause_buttons()
	EventBus.game_paused.emit(true)


func close_menu() -> void:
	if not _open:
		return
	_open = false
	$Root.hide()
	get_tree().paused = false
	Input.mouse_mode = _previous_mouse_mode
	EventBus.game_paused.emit(false)


func show_settings() -> void:
	$Root/PauseCard.hide()
	$Root/SettingsCard.show()
	$Root/SettingsCard/SettingsPanel.refresh()
	$Root/SettingsCard/SettingsPanel/Footer/Back.grab_focus()


func _show_pause_buttons() -> void:
	$Root/SettingsCard.hide()
	$Root/PauseCard.show()
	$Root/PauseCard/Buttons/Resume.grab_focus()


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
		close_menu()
