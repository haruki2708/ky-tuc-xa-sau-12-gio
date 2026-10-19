extends Interactable
## Greybox toggle only. Story locks and rule consequences belong to gameplay.
## The prompt follows the state: "Open door" / "Close door" (T-138).

var is_open: bool = false
var _rattle_left: float = 0.0
var _rattle_time: float = 0.0
var _swing: Tween


func _ready() -> void:
	_update_prompt()


func _on_interact(_player: Node) -> void:
	# A hand (T-220) swings the leaf over its hold; a plain press still snaps it.
	set_open(not is_open, hand_seconds)


func set_open(value: bool, seconds: float = 0.0) -> void:
	# Preserve the current angle when a moving door is reversed or retargeted.
	var angle: float = $Pivot.rotation.y
	if _swing:
		_swing.kill()
		_swing = null
	var was_rattling: bool = _rattle_left > 0.0
	stop_rattle()
	if was_rattling:
		angle = $Pivot.rotation.y
	is_open = value
	_update_prompt()
	var target: float = -PI / 2.0 if is_open else 0.0
	if is_finite(seconds) and seconds > 0.0:
		_set_angle(angle)
		_swing = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		_swing.tween_method(_set_angle, angle, target, seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_swing.finished.connect(func() -> void: _swing = null)
	else:
		_set_angle(target)


func _set_angle(angle: float) -> void:
	$Pivot.rotation.y = angle
	var floor_root := get_parent()
	if floor_root and floor_root.has_method("sync_door_anchor"):
		floor_root.sync_door_anchor()


func rattle(seconds: float) -> void:
	if is_open or (_swing and _swing.is_running()) or not is_finite(seconds):
		return
	_rattle_left = maxf(seconds,0.0)
	_rattle_time = 0.0
	if _rattle_left == 0.0:
		stop_rattle()


func stop_rattle() -> void:
	_rattle_left = 0.0
	if not (_swing and _swing.is_running()):
		_set_angle(-PI / 2.0 if is_open else 0.0)
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
