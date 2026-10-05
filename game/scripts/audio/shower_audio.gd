class_name ShowerAudio
extends Node3D
## Core supplies the revealed temperature at slot start; no temperature prediction.

@export_dir var sound_directory: String = Ch2AudioBank.DIRECTORY
var _water: AudioStreamPlayer3D
var _steam: AudioStreamPlayer3D
var _cue: AudioStreamPlayer3D
var _clock: Ch2Countdown
var _stopped: bool = false


func _ready() -> void:
	_water = _make_player("Water", &"Ambience")
	_steam = _make_player("Steam", &"Ambience")
	_cue = _make_player("Cue", &"SFX")
	_clock = Ch2Countdown.new()
	_clock.listen_chain = false
	_clock.clip_name = "shower_beep"
	_clock.sound_directory = sound_directory
	add_child(_clock)
	EventBus.shower_choice_requested.connect(_on_choice)
	EventBus.shower_choice_made.connect(_on_answer)
	EventBus.shower_slot_finished.connect(_on_finished)
	EventBus.shower_steam_changed.connect(set_steam)
	EventBus.chapter_started.connect(_reset)
	EventBus.chapter_finished.connect(_reset)
	EventBus.checkpoint_loaded.connect(_reset)
	EventBus.player_death_started.connect(_reset)


func _make_player(node_name: String, bus: StringName) -> AudioStreamPlayer3D:
	var player := AudioStreamPlayer3D.new()
	player.name = node_name
	player.bus = bus
	player.unit_size = 2.5
	add_child(player)
	return player


func _play(player: AudioStreamPlayer3D, clip_name: String) -> void:
	var clip := Ch2AudioBank.clip(clip_name, sound_directory)
	if player.playing and player.stream == clip and Ch2AudioBank.LOOPS.has(clip_name):
		return
	player.stop()
	player.stream = clip
	if clip != null:
		player.play()


func set_water(temperature: float, running: bool) -> void:
	if _stopped or not is_node_ready():
		return
	if not running:
		_water.stop()
	elif is_finite(temperature):
		_play(_water, "water_cold" if temperature < 10.0 else ("water_warm" if temperature < 50.0 else "water_boiling"))


func set_steam(level: float) -> void:
	if _stopped or not is_node_ready() or not is_finite(level):
		return
	level = clampf(level, 0.0, 1.0)
	_steam.volume_linear = level
	if level == 0.0:
		_steam.stop()
	else:
		_play(_steam, "steam_hiss")


func play_door_push(level: int) -> void:
	if not _stopped and is_node_ready() and level >= 1 and level <= 3:
		_cue.volume_db = 0.0
		_play(_cue, "door_push_%02d" % level)


func play_cue(clip_name: String) -> void:
	if not _stopped and is_node_ready() and clip_name in ["door_burst", "mirror_shiver"]:
		_cue.volume_db = -10.0 if Ch1AudioBank.reduced() else 0.0
		_play(_cue, clip_name)


func _on_choice(seconds: float) -> void:
	if not _stopped:
		_water.stop()
		_clock.start(seconds)


func _on_answer(running: bool) -> void:
	_clock.cancel()
	if not running:
		_water.stop()


func _on_finished(_temperature: int, _ran: bool, _minutes: int) -> void:
	_water.stop()
	_clock.cancel()


func _reset(_value: Variant) -> void:
	for player in [_water, _steam, _cue]:
		player.stop()
	_clock.cancel()


func stop_emitting() -> void:
	_stopped = true
	if is_node_ready():
		_reset(null)
