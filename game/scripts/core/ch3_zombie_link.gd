class_name Ch3ZombieLink
extends Node
## Core glue between lane A's Zombie (T-182) and lane E's ZombieAudio (T-186):
## the zombie does not call the audio itself, so this node mirrors its state
## (hunting, eligible = not sparse/hidden) and plays a step every stride.

const STRIDE := 0.8

var zombie: Zombie
var rig: ZombieAudio
var _last: Vector3
var _walked: float = 0.0


func _ready() -> void:
	zombie = get_parent() as Zombie
	if zombie != null:
		_last = zombie.global_position


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(zombie) or not is_instance_valid(rig):
		return
	var hunting := zombie.state == &"hunting"
	if rig.hunting != hunting:
		rig.set_hunting(hunting)
	if rig.eligible != zombie.audio_enabled:
		rig.set_eligible(zombie.audio_enabled)
	var here := zombie.global_position
	if hunting:
		_walked += Vector2(here.x - _last.x, here.z - _last.z).length()
		if _walked >= STRIDE:
			_walked = 0.0
			rig.play_step()
	_last = here
