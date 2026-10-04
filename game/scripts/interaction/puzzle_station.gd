extends Interactable

signal solved

@export var puzzle_id: StringName
var is_solved: bool = false
var _player: CharacterBody3D


func _ready() -> void:
	prompt_key = "PROMPT_PUZZLE_OPEN"
	EventBus.puzzle_closed.connect(_on_closed)
	EventBus.puzzle_solved.connect(_on_solved)


func interact(player: Node) -> void:
	if not enabled or is_solved or is_instance_valid(_player):
		return
	if not is_instance_valid(player) or not player.has_method("acquire_control_lock"):
		return
	if player.call("controls_locked"):
		return
	if PuzzleData.load_by_id(puzzle_id) == null:
		push_warning("Puzzle station has no valid PuzzleData: %s" % puzzle_id)
		return
	_player = player as CharacterBody3D
	if _player == null:
		return
	_player.call("acquire_control_lock", self)
	EventBus.puzzle_opened.emit(puzzle_id)
	EventBus.interacted.emit(self)


func _on_closed(id: StringName) -> void:
	if id == puzzle_id:
		_release_player()


func _on_solved(id: StringName) -> void:
	if id != puzzle_id or is_solved:
		return
	is_solved = true
	enabled = false
	_release_player()
	solved.emit()


func _release_player() -> void:
	if is_instance_valid(_player):
		_player.call("release_control_lock", self)
	_player = null


func _exit_tree() -> void:
	_release_player()
