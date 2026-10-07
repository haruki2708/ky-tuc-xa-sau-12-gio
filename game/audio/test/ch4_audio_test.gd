extends Node3D
## Standalone listening fixture; no gameplay or story advancement.

var rig: Ch4AudioRig
var preview: AudioStreamPlayer
var selected: int = 0
var _damage: float = 0.0


func _ready() -> void:
	var camera := Camera3D.new()
	camera.position.y = 1.5
	add_child(camera)
	camera.make_current()
	rig = Ch4AudioRig.new()
	add_child(rig)
	rig.listener = camera
	var door := Marker3D.new()
	door.position = Vector3(2, 1, -4)
	add_child(door)
	rig.register_door(&"407", door)
	rig.monitor_marker = door
	for id in Ch4AudioBank.SCARES:
		rig.scare_positions[id] = Vector3(0, 1.5, -2)
	for index in 10:
		var point := Marker3D.new()
		point.position = Vector3(index % 3 - 1, index * 0.4, -3 - index)
		add_child(point)
		rig.stair_points.append(point)
	preview = AudioStreamPlayer.new()
	add_child(preview)
	print("CH4 AUDIO: arrows/Space audition 29 sounds + 16 voices; 1 decoy; 2 door damage; 3 library; 4 stairs; 5 room407; 6 neck; 7 fade; 8 hospital; 9 monitor skip; E end; 0 reset; Esc quit.")
	print("See audio_source/ch4/README.md and audio_source/voice_ch4/README.md for measured levels.")


func audition(index: int) -> void:
	selected = posmod(index, Ch4AudioBank.NAMES.size() + Ch4AudioBank.VOICES.size())
	preview.stop()
	if selected < Ch4AudioBank.NAMES.size():
		var id := Ch4AudioBank.NAMES[selected]
		preview.bus = &"Voice" if id == "pa_laugh" else (&"Music" if id.begins_with("music_") or id == "body_fade" else &"SFX")
		preview.stream = Ch4AudioBank.clip(id)
		print("CH4 clip: ", id)
	else:
		var id := Ch4AudioBank.VOICES[selected - Ch4AudioBank.NAMES.size()]
		preview.bus = &"PhoneVoice" if id.begins_with("CHAT_CH4_") else &"Voice"
		preview.stream = Ch4AudioBank.voice(id)
		print("CH4 voice: ", id)
	if preview.stream != null:
		preview.play()


func reset_preview() -> void:
	preview.stop()
	rig._reset()
	_damage = 0.0


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_LEFT: audition(selected - 1)
		KEY_RIGHT: audition(selected + 1)
		KEY_SPACE: audition(selected)
		KEY_0: reset_preview()
		KEY_1:
			rig.decoy._reset()
			rig.decoy.enabled = true
			EventBus.phone_decoy_thrown.emit(Vector3(0, 0, -4), 0)
		KEY_2:
			_damage = minf(1.0, _damage + 0.2)
			EventBus.door_damage_changed.emit(&"407", _damage)
		KEY_3:
			rig.set_area(&"library")
			EventBus.time_changed.emit(510)
		KEY_4: rig.set_area(&"stairs")
		KEY_5: rig.set_area(&"407")
		KEY_6: EventBus.scare_triggered.emit(&"neck_hand")
		KEY_7: EventBus.fade_message_requested.emit(12.0)
		KEY_8: EventBus.ch4_ending.emit(&"all")
		KEY_9: EventBus.scare_triggered.emit(&"monitor_skip")
		KEY_E: EventBus.chapter_finished.emit(4)
		KEY_ESCAPE:
			rig.stop_emitting()
			get_tree().quit()
