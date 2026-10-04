class_name PowerStrip
extends Node3D
## Switch indices are zero-based (0..2). The director assigns their meaning.

signal switch_toggled(index: int, on: bool)

var switches: Array[bool] = [false, false, false]
var lock_remaining: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE


func _physics_process(delta: float) -> void:
	lock_remaining = maxf(0.0, lock_remaining - delta)


func toggle(index: int) -> void:
	if index < 0 or index >= switches.size() or get_tree().paused:
		return
	if lock_remaining > 0.0 and not switches[index]:
		return
	switches[index] = not switches[index]
	switch_toggled.emit(index, switches[index])


func trip() -> void:
	# Commit all state first so listeners cannot observe a half-tripped strip.
	var previous: Array[bool] = switches.duplicate()
	switches.fill(false)
	for index: int in previous.size():
		if previous[index]:
			switch_toggled.emit(index, false)


func set_locked(seconds: float) -> void:
	lock_remaining = maxf(0.0, seconds) if is_finite(seconds) else 0.0
