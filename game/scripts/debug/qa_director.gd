extends "res://scripts/core/chapter1_director.gd"
## Only installed in a fresh isolated QA scene, never in the player's game.

var invincible: bool = false
var suppressed: Array[StringName] = []


func _die(reason_key: StringName) -> void:
	if invincible:
		if reason_key not in suppressed:
			suppressed.append(reason_key)
			print("QA_DEATH_SUPPRESSED: ", reason_key)
		return
	super._die(reason_key)


func _manager_kills(manager: Node3D, reason: StringName) -> void:
	if invincible:
		_die(reason)
		return
	await super._manager_kills(manager, reason)
