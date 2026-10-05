class_name CampusGuard
extends Ch3Actor

@export var player: Node3D
@export var warning_radius: float = 3.0
@export var kill_radius: float = 1.5
var warned: bool = false
var _caught: bool = false


func _ready() -> void:
	super._ready()
	add_to_group(&"ch3_guard")


func _physics_process(_delta: float) -> void:
	if get_tree().paused or not is_instance_valid(player) or _caught:
		return
	var distance: float = global_position.distance_to(player.global_position)
	var visible_player: bool = clear_line(head_position(), player.global_position + Vector3.UP * 1.4)
	var next_warned: bool = distance <= warning_radius and visible_player
	if next_warned != warned:
		warned = next_warned
		$Visual/Baton.rotation.x = -1.1 if warned else 0.0
		play_pose(&"warn" if warned else &"idle")
		EventBus.guard_warned.emit(self, warned)
	if distance <= kill_radius and visible_player:
		struck()


func struck() -> void:
	if _caught or get_tree().paused:
		return
	_caught = true
	EventBus.player_caught.emit(&"guard")


func turn_head_to(point: Vector3) -> void:
	if is_instance_valid(model) and model.has_method("turn_head_to"):
		model.call("turn_head_to", point)
	else:
		var head: Node3D = $Visual/Fallback/Head
		var direction: Vector3 = point - head.global_position
		if direction.length() > 0.01 and absf(direction.normalized().dot(Vector3.UP)) < 0.999:
			head.look_at(point)
