class_name Ch3Music
extends Node

@export_dir var sound_directory: String = Ch3AudioBank.DIRECTORY
var area: StringName = &""
var running: bool = false
var wave: bool = false
var _beds: Array[AudioStreamPlayer] = []
var _gains: Array[float] = [0.0, 0.0]
var _end: AudioStreamPlayer
var _ended: bool = false
var _dead: bool = false
var _stopped: bool = false


func _ready() -> void:
	for index in 2:
		var player := AudioStreamPlayer.new()
		player.bus = &"Music"
		add_child(player)
		_beds.append(player)
	_end = AudioStreamPlayer.new()
	_end.bus = &"Music"
	add_child(_end)
	EventBus.chapter_started.connect(_reset)
	EventBus.checkpoint_loaded.connect(_reset)
	EventBus.chapter_finished.connect(_on_finished)
	EventBus.player_death_started.connect(_on_death)


func set_area(value: StringName) -> void:
	area = value
	if value == &"canteen":
		_silence_beds()


func set_running(value: bool) -> void:
	running = value


func set_wave(value: bool) -> void:
	wave = value


func _process(delta: float) -> void:
	var active := not _stopped and not _dead and not _ended and not area.is_empty() and area != &"canteen"
	var target := -1
	if active:
		if wave and area == &"stadium":
			target = 1
		elif running:
			target = 0
	for index in 2:
		_gains[index] = move_toward(_gains[index], 1.0 if target == index else 0.0, delta / 1.5)
		_beds[index].volume_linear = _gains[index]
		if _gains[index] > 0:
			Ch3AudioBank.play(_beds[index], "music_run" if index == 0 else "music_wave", sound_directory)
		else:
			_beds[index].stop()


func _silence_beds() -> void:
	for index in _beds.size():
		_beds[index].stop()
		_gains[index] = 0.0


func _on_finished(chapter: int) -> void:
	if chapter != 3 or _stopped or _dead or _ended:
		return
	_ended = true
	_silence_beds()
	Ch3AudioBank.play(_end, "music_end", sound_directory)


func _reset(_reason: Variant) -> void:
	_silence_beds()
	_end.stop()
	area = &""
	running = false
	wave = false
	_ended = false
	_dead = false


func _on_death(reason: StringName) -> void:
	_reset(reason)
	_dead = true


func stop_emitting() -> void:
	_stopped = true
	if is_node_ready():
		_reset(null)
