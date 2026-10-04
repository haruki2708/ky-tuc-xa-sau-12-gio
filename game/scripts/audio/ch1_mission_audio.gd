class_name Ch1MissionAudio
extends Node3D
## Attach at the router, socket, lock or handle. Caller supplies interaction timing.

@export_dir var sound_directory: String = Ch1V2AudioBank.DIRECTORY
var _cue: AudioStreamPlayer3D
var _handle: AudioStreamPlayer3D
var _tail: AudioStreamPlayer3D
var _rattling: bool = false
var _stopped: bool = false


func _ready() -> void:
	_cue = _make_player("Cue")
	_handle = _make_player("HandleLoop")
	_tail = _make_player("HandleRelease")
	EventBus.chapter_started.connect(_reset)
	EventBus.checkpoint_loaded.connect(_reset)


func _make_player(node_name: String) -> AudioStreamPlayer3D:
	var player := AudioStreamPlayer3D.new()
	player.name = node_name
	player.bus = &"SFX"
	player.unit_size = 2.0
	add_child(player)
	return player


func play_cue(cue_name: StringName) -> void:
	if _stopped or not is_node_ready() or cue_name not in [&"router_power_off", &"router_boot", &"router_online", &"power_switch", &"power_short", &"lock_alarm"]:
		return
	_play(_cue, String(cue_name))


func _play(player: AudioStreamPlayer3D, clip_name: String) -> void:
	player.stop()
	player.stream = Ch1V2AudioBank.clip(clip_name, sound_directory)
	if player.stream != null:
		player.play()


func set_handle_rattling(on: bool) -> void:
	if _stopped or not is_node_ready() or on == _rattling:
		return
	_rattling = on
	if on:
		_tail.stop()
		_play(_handle, "handle_rattle")
	else:
		_handle.stop()
		_play(_tail, "handle_stop")


func _reset(_value: Variant) -> void:
	_rattling = false
	for player in [_cue, _handle, _tail]:
		if player != null:
			player.stop()


func stop_emitting() -> void:
	_stopped = true
	_reset(null)
