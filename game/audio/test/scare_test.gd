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

var _demo: Tween
var _preview_paused: bool = false


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key := (event as InputEventKey).physical_keycode
	if key >= KEY_F1 and key <= KEY_F11:
		_stop_music_demo()
		var index := key - KEY_F1
		$Preview.stop()
		$Preview.bus = &"Voice" if index == 9 else &"SFX"
		$Preview.stream = CLIPS[index]
		$Preview.play()
	elif key >= KEY_1 and key <= KEY_4:
		_stop_music_demo()
		$Preview.stop()
		$Preview.bus = &"Music"
		$Preview.stream = MusicDirector.CLIPS[key - KEY_1]
		$Preview.play()
	elif key == KEY_M:
		_stop_music_demo()
		$Preview.stop()
		EventBus.segment_changed.emit(&"seg2")
		_demo = create_tween()
		_demo.tween_interval(3.0)
		_demo.tween_callback(func() -> void:
			EventBus.deviation_changed.emit(2, &"preview")
			EventBus.consequence_triggered.emit(&"extra_slippers", &"preview"))
		_demo.tween_interval(4.0)
		_demo.tween_callback(func() -> void: EventBus.chase_started.emit(&"preview"))
		_demo.tween_interval(5.0)
		_demo.tween_callback(func() -> void: EventBus.chase_ended.emit(&"preview", false))
	elif key == KEY_L:
		EventBus.consequence_triggered.emit(&"corridor_light_flicker", &"preview")
	elif key == KEY_H:
		EventBus.scare_triggered.emit(&"preview")
	elif key == KEY_P:
		_preview_paused = not _preview_paused
		EventBus.game_paused.emit(_preview_paused)
	elif key == KEY_E:
		if _demo != null:
			_demo.kill()
		$Preview.stop()
		EventBus.segment_changed.emit(&"end")
	elif key == KEY_0:
		$Preview.stop()
		_stop_music_demo()
	elif key == KEY_ESCAPE:
		App.quit()


func _stop_music_demo() -> void:
	if _demo != null:
		_demo.kill()
	_preview_paused = false
	EventBus.game_paused.emit(false)
	EventBus.segment_changed.emit(&"seg1")
	EventBus.deviation_changed.emit(0, &"preview")
