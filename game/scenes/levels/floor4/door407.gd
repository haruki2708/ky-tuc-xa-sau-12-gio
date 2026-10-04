extends Interactable
## Greybox toggle only. Story locks and rule consequences belong to gameplay.
## The prompt follows the state: "Open door" / "Close door" (T-138).

var is_open: bool = false
var _rattle_left: float = 0.0
var _rattle_time: float = 0.0


func _ready() -> void:
	_update_prompt()


func _on_interact(_player: Node) -> void:
	set_open(not is_open)


func set_open(value: bool) -> void:
	stop_rattle()
	is_open = value
	$Pivot.rotation.y = -PI / 2.0 if is_open else 0.0
	_update_prompt()
	var floor_root := get_parent()
	if floor_root.has_method("sync_door_anchor"):
		floor_root.sync_door_anchor()


func rattle(seconds: float) -> void:
	if is_open or not is_finite(seconds):
		return
	_rattle_left = maxf(seconds,0.0)
	_rattle_time = 0.0
	if _rattle_left == 0.0:
		stop_rattle()


func stop_rattle() -> void:
	_rattle_left = 0.0
	$Pivot.rotation.y = -PI / 2.0 if is_open else 0.0
	var handle := get_node_or_null("Pivot/HandlePivot") as Node3D
	if handle:
		handle.rotation.z = 0.0
	var floor_root := get_parent()
	if floor_root and floor_root.has_method("sync_door_anchor"):
		floor_root.sync_door_anchor()


func _process(delta: float) -> void:
	if _rattle_left <= 0.0:
		return
	_rattle_left = maxf(0.0,_rattle_left-delta)
	_rattle_time += delta
	if _rattle_left == 0.0:
		stop_rattle()
		return
	$Pivot.rotation.y = sin(_rattle_time*39.0)*.008
	$Pivot/HandlePivot.rotation.z = sin(_rattle_time*27.0)*.24
	get_parent().sync_door_anchor()


func _update_prompt() -> void:
	prompt_key = "PROMPT_CLOSE_DOOR" if is_open else "PROMPT_OPEN_DOOR"
