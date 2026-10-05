class_name ShowerStall
extends Area3D

signal player_inside_changed(inside: bool)

var player_inside: bool = false
var _players: Array[Node3D] = []


func _init() -> void:
	collision_layer = 0
	collision_mask = 2


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	body_entered.connect(_entered)
	body_exited.connect(_exited)


func _entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.has_method("controls_locked") and not _players.has(body):
		_players.append(body)
		_update_inside()


func _exited(body: Node3D) -> void:
	_players.erase(body)
	_update_inside()


func _physics_process(_delta: float) -> void:
	_players = _players.filter(func(body: Node3D) -> bool: return is_instance_valid(body) and body.is_inside_tree())
	_update_inside()


func _update_inside() -> void:
	var inside: bool = not _players.is_empty()
	if inside != player_inside:
		player_inside = inside
		player_inside_changed.emit(inside)
