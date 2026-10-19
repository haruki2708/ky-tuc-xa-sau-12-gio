extends CharacterBody3D
## Test stand-in for the player that PlayerBody follows: velocity and crouch are set by the
## test, and the test moves it.

var crouched: bool = false
var locks: Array[Node] = []


func is_hidden() -> bool:
	return false


func acquire_movement_lock(owner: Node) -> void:
	if not locks.has(owner):
		locks.append(owner)


func release_movement_lock(owner: Node) -> void:
	locks.erase(owner)
