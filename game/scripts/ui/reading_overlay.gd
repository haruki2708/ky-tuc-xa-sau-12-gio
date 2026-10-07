extends CanvasLayer
## Shared pause ownership for the document viewer and notebook.

var _open := false
var _previous_mouse_mode: Input.MouseMode
@export var pause_gameplay := true
@export var reader_player_path: NodePath = ^"../Player"
var _paused_game := false
var _locked_player: Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("reading_overlay")
	$Root.hide()


func is_open() -> bool:
	return _open


func _begin_reading() -> bool:
	if _open or get_tree().paused:
		return false
	for death in get_tree().get_nodes_in_group("death_screen"):
		if death.is_open():
			return false
	for reader in get_tree().get_nodes_in_group("reading_overlay"):
		if reader != self and reader.is_open():
			return false
	_previous_mouse_mode = Input.mouse_mode
	_open = true
	$Root.show()
	_paused_game = pause_gameplay
	if _paused_game:
		get_tree().paused = true
	else:
		_locked_player = get_node_or_null(reader_player_path)
		if is_instance_valid(_locked_player) and _locked_player.has_method("acquire_control_lock"):
			_locked_player.acquire_control_lock(self)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if _paused_game:
		EventBus.game_paused.emit(true)
	return true


func close_view() -> void:
	if not _open:
		return
	_open = false
	$Root.hide()
	# Player polls actions in physics, even if the UI handled the input event.
	Input.action_release("interact")
	if _paused_game:
		get_tree().paused = false
	Input.mouse_mode = _previous_mouse_mode
	if is_instance_valid(_locked_player) and _locked_player.has_method("release_control_lock"):
		_locked_player.release_control_lock(self)
	_locked_player = null
	if _paused_game:
		EventBus.game_paused.emit(false)
	_paused_game = false


func _exit_tree() -> void:
	if _open:
		close_view()
