class_name HoldInteractable
extends Interactable
## Optional timed use. A movement lock deliberately leaves mouse look available.

signal progress_changed(fraction: float)

@export var hold_seconds: float = 0.0
@export var decay_per_second: float = 1.0
var progress: float = 0.0
var completed: bool = false
var _player: Node3D
var _holding: bool = false
var _bar: ProgressBar


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE


func can_interact(_user: Node) -> bool:
	return enabled and not completed


func interact(user: Node) -> void:
	if not can_interact(user):
		return
	if hold_seconds <= 0:
		_finish()
		return
	if not CarryItem.player_can_use(user) or user is not Node3D or not user.has_method("acquire_movement_lock"):
		return
	if not _within_reach(user):
		return
	_release()
	_player = user
	_holding = true
	_player.call("acquire_movement_lock", self)
	if _bar == null:
		var layer: CanvasLayer = CanvasLayer.new()
		add_child(layer)
		_bar = ProgressBar.new()
		layer.add_child(_bar)
		_bar.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		_bar.offset_left = -90
		_bar.offset_right = 90
		_bar.offset_top = 78
		_bar.offset_bottom = 90
		_bar.max_value = 1.0
		_bar.step = 0.001
		_bar.show_percentage = false
		_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var background: StyleBoxFlat = StyleBoxFlat.new()
		background.bg_color = Color(0.03, 0.03, 0.04, 0.9)
		var fill: StyleBoxFlat = StyleBoxFlat.new()
		fill.bg_color = Color(0.85, 0.8, 0.65)
		_bar.add_theme_stylebox_override("background", background)
		_bar.add_theme_stylebox_override("fill", fill)
	_update_bar()


func _physics_process(delta: float) -> void:
	if get_tree().paused or completed:
		return
	if _holding and (not enabled or not CarryItem.player_can_use(_player) \
			or not Input.is_action_pressed("interact") or not _within_reach(_player)):
		_release()
	var previous: float = progress
	progress = minf(hold_seconds, progress + delta) if _holding else maxf(0, progress - delta * maxf(0, decay_per_second))
	if previous != progress:
		progress_changed.emit(progress / maxf(hold_seconds, 0.001))
	_update_bar()
	if _holding and progress >= hold_seconds - 0.000001:
		_finish()


func _within_reach(user: Node3D) -> bool:
	# Ceiling/vent targets are aimed at from eye height, not from the feet.
	var camera: Node3D = user.get_node_or_null("Head/Camera3D") as Node3D
	var origin: Vector3 = camera.global_position if camera != null else user.global_position
	return origin.distance_to(global_position) <= 3.0


func _update_bar() -> void:
	if is_instance_valid(_bar):
		_bar.value = progress / maxf(hold_seconds, 0.001)
		_bar.visible = enabled and not completed and (_holding or progress > 0) and CarryItem.player_can_use(_player)


func _finish() -> void:
	completed = true
	enabled = false
	_release()
	_update_bar()
	_on_completed()
	EventBus.interacted.emit(self)


func _on_completed() -> void:
	pass


func _release() -> void:
	_holding = false
	if is_instance_valid(_player):
		_player.call("release_movement_lock", self)


func _exit_tree() -> void:
	_release()
