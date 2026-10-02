extends Node3D
## F1-F11 audition isolated clips at unity gain; 0 stops and Esc quits.

const CLIPS: Array[AudioStream] = [
	preload("res://audio/sfx/sting_low.ogg"),
	preload("res://audio/sfx/sting_hit.ogg"),
	preload("res://audio/sfx/slipper_place.ogg"),
	preload("res://audio/sfx/tube_cut.ogg"),
	preload("res://audio/ambience/breath_close.ogg"),
	preload("res://audio/sfx/slipper_rush_01.ogg"),
	preload("res://audio/sfx/slipper_rush_02.ogg"),
	preload("res://audio/sfx/slipper_rush_03.ogg"),
	preload("res://audio/sfx/slipper_rush_04.ogg"),
	preload("res://audio/sfx/whisper_co.ogg"),
	preload("res://audio/sfx/net_billow.ogg"),
]


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key := (event as InputEventKey).physical_keycode
	if key >= KEY_F1 and key <= KEY_F11:
		var index := key - KEY_F1
		$Preview.stop()
		$Preview.bus = &"Voice" if index == 9 else &"SFX"
		$Preview.stream = CLIPS[index]
		$Preview.play()
	elif key == KEY_0:
		$Preview.stop()
	elif key == KEY_ESCAPE:
		App.quit()
