extends LineEdit
## Keep native LineEdit/IME submission; only Escape is intercepted before menus.

signal cancelled
var _owns_keyboard := false


static func is_typing(tree: SceneTree) -> bool:
	for entry in tree.get_nodes_in_group("game_text_entry"):
		if entry.has_focus():
			return true
	return false


func _ready() -> void:
	add_to_group("game_text_entry")
	add_theme_font_size_override("font_size", 26)
	# Focus is explicit. Mouse motion remains available to the camera.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	context_menu_enabled = false
	keep_editing_on_text_submit = true
	focus_entered.connect(func() -> void: _set_owned(true))
	focus_exited.connect(func() -> void: _set_owned(false))


func _input(event: InputEvent) -> void:
	if has_focus() and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if not event.is_echo():
			cancelled.emit()


func _set_owned(active: bool) -> void:
	if active == _owns_keyboard:
		return
	_owns_keyboard = active
	EventBus.text_entry_changed.emit(active)


func _exit_tree() -> void:
	_set_owned(false)
