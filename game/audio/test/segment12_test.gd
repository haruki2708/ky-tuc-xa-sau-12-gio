extends Node3D
## F1-F11 preview individual clips, Space previews three subtitle lines, 0 stops.

const CLIPS: Array[AudioStream] = [
	preload("res://audio/sfx/knock_01.ogg"),
	preload("res://audio/sfx/knock_02.ogg"),
	preload("res://audio/sfx/knock_03.ogg"),
	preload("res://audio/sfx/speaker_chime.ogg"),
	preload("res://audio/sfx/speaker_on.ogg"),
	preload("res://audio/sfx/speaker_off.ogg"),
	preload("res://audio/ambience/speaker_static.ogg"),
	preload("res://audio/sfx/speaker_static_burst.ogg"),
	preload("res://audio/sfx/phone_vibrate.ogg"),
	preload("res://audio/sfx/light_switch.ogg"),
	preload("res://audio/sfx/door_latch.ogg"),
]
const DEMO_LINES: Array = [
	{"text_key": "RULE_1", "garbled": false},
	{"text_key": "RULE_3_GARBLED", "garbled": true},
	{"text_key": "RULE_2", "garbled": false},
]


func _ready() -> void:
	if "--segment12-preview" in OS.get_cmdline_user_args():
		$Speaker.play_announcement(DEMO_LINES, 0.6)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var key := (event as InputEventKey).physical_keycode
	if key >= KEY_F1 and key <= KEY_F11:
		$Speaker.stop_emitting()
		$Preview.stop()
		var index := key - KEY_F1
		$Preview.bus = &"Voice" if index >= 3 and index <= 7 else &"SFX"
		$Preview.stream = CLIPS[index]
		$Preview.play()
	elif key == KEY_SPACE:
		$Preview.stop()
		$Speaker.play_announcement(DEMO_LINES)
	elif key == KEY_0:
		$Preview.stop()
		$Speaker.stop_emitting()
	elif key == KEY_ESCAPE:
		App.quit()
