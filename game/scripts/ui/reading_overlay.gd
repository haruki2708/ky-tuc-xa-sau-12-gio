extends CanvasLayer
## Shared pause ownership for the document viewer and notebook.

var _open := false
var _previous_mouse_mode: Input.MouseMode


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("reading_overlay")
	$Root.hide()


func is_open() -> bool:
	return _open


func _begin_reading() -> bool:
	if _open or get_tree().paused:
		return false
	_previous_mouse_mode = Input.mouse_mode
	_open = true
	$Root.show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	EventBus.game_paused.emit(true)
	return true


func close_view() -> void:
	if not _open:
		return
	_open = false
	$Root.hide()
	get_tree().paused = false
	Input.mouse_mode = _previous_mouse_mode
	EventBus.game_paused.emit(false)


func _exit_tree() -> void:
	if _open:
		close_view()
