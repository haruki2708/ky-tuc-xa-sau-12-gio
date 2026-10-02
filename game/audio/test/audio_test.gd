extends Node3D
## Listening fixture only. Number keys isolate sources; 0 restores the room mix.

var _elapsed: float = 0.0


func _ready() -> void:
	$StepTimer.timeout.connect(_on_step)


func _process(delta: float) -> void:
	_elapsed += delta
	# Move the demo steps across the listener's field to demonstrate panning.
	$Footsteps.position.x = sin(_elapsed * 0.4) * 2.5


func _on_step() -> void:
	$Footsteps.play_footstep(&"tile")


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key := (event as InputEventKey).physical_keycode
	if key == KEY_ESCAPE:
		get_tree().quit()
	var sources: Array[AudioStreamPlayer3D] = [$Fan, $Hum, $Night, $Drips, $DoorOpen, $DoorClose, $Footsteps]
	if key >= KEY_0 and key <= KEY_7:
		var selected := key - KEY_0
		for index in sources.size():
			sources[index].volume_db = -6.0 if selected == 0 or selected == index + 1 else -80.0
			# Keep variation centered on the selected mix, without changing shared resources.
			sources[index]._base_volume = sources[index].volume_db
