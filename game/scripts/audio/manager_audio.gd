class_name ManagerAudio
extends Node3D
## Model-free spatial sound rig. Gameplay owns position, cadence and all decisions.

@export_dir var sound_directory: String = Ch1AudioBank.DIRECTORY
@export_dir var voice_directory: String = "res://audio/voice"
@export var floor_base_y: float = 0.0
@export var listener: Node3D
@export var subtitle_fallback_seconds: float = 2.5

var _players: Dictionary = {}
var _step_index: int = 0
var _slash_index: int = 0
var _stopped: bool = false


func _ready() -> void:
	for channel in ["Step", "Drag", "Knock", "Slash", "Kill", "Speech"]:
		var player := AudioStreamPlayer3D.new()
		player.name = channel
		player.bus = &"Voice" if channel == "Speech" else &"SFX"
		player.unit_size = 4.0
		player.max_distance = 65.0
		add_child(player)
		var muffle := FloorMuffle.new()
		muffle.name = "FloorMuffle"
		muffle.floor_base_y = floor_base_y
		muffle.listener = listener
		player.add_child(muffle)
		_players[channel] = player
	EventBus.settings_changed.connect(_on_settings)


func place_at(world_position: Vector3) -> void:
	if is_inside_tree() and world_position.is_finite():
		global_position = world_position
		for player: AudioStreamPlayer3D in _players.values():
			(player.get_node("FloorMuffle") as FloorMuffle)._process(0.0)


func _play(channel: String, clip_name: String) -> void:
	if _stopped or not _players.has(channel):
		return
	var player: AudioStreamPlayer3D = _players[channel]
	player.stop()
	player.stream = Ch1AudioBank.clip(clip_name, sound_directory)
	if player.stream != null:
		player.play()


func play_step() -> void:
	_step_index = 1 - _step_index
	_play("Step", "manager_step_%02d" % (_step_index + 1))


func play_drag(on: bool) -> void:
	if not _players.has("Drag"):
		return
	var player: AudioStreamPlayer3D = _players["Drag"]
	if not on:
		player.stop()
	elif not player.playing:
		_play("Drag", "manager_drag")


func play_knock() -> void:
	_play("Knock", "manager_knock")


func play_slash(material: StringName = &"mattress") -> void:
	_slash_index = 1 - _slash_index
	var kind := "wood" if material == &"wood" else "mattress"
	_play("Slash", "slash_soft" if Ch1AudioBank.reduced() else "slash_%s_%02d" % [kind, _slash_index + 1])


func play_kill() -> void:
	_play("Kill", "kill_soft" if Ch1AudioBank.reduced() else "manager_kill")


func say(line_key: String) -> float:
	if _stopped or not _players.has("Speech") or line_key.is_empty():
		return 0.0
	var player: AudioStreamPlayer3D = _players["Speech"]
	player.stop()
	player.stream = Ch1AudioBank.voice(line_key, "MGR_", voice_directory)
	var duration := maxf(0.1, subtitle_fallback_seconds)
	if player.stream != null:
		duration = player.stream.get_length() + 0.4
		player.play()
	EventBus.subtitle_requested.emit(line_key, duration)
	return duration


func _on_settings(section: String, key: String) -> void:
	if section != "accessibility" or key != "reduce_scares" or not Ch1AudioBank.reduced():
		return
	for channel in ["Slash", "Kill"]:
		if (_players[channel] as AudioStreamPlayer3D).playing:
			_play(channel, "slash_soft" if channel == "Slash" else "kill_soft")


func stop_emitting() -> void:
	_stopped = true
	for player: AudioStreamPlayer3D in _players.values():
		player.stop()
