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


## `at` (world) puts the cue on the thing that made it (T-234: the strip's click is not the
## router's); left out, the cue sounds where it last did.
func play_cue(cue_name: StringName, at: Vector3 = Vector3.INF) -> void:
	if _stopped or not is_node_ready() or cue_name not in [&"router_power_off", &"router_boot", &"router_online", &"power_switch", &"power_short", &"lock_alarm"]:
		return
	_place(_cue, at)
	_play(_cue, String(cue_name))


func _place(player: AudioStreamPlayer3D, at: Vector3) -> void:
	if at.is_finite():
		player.global_position = at


func _play(player: AudioStreamPlayer3D, clip_name: String) -> void:
	player.stop()
	player.stream = Ch1V2AudioBank.clip(clip_name, sound_directory)
	if player.stream != null:
		player.play()


## `at` (world) is the handle; the loop and its release both sound there, whatever cue plays next.
func set_handle_rattling(on: bool, at: Vector3 = Vector3.INF) -> void:
	if _stopped or not is_node_ready() or on == _rattling:
		return
	_rattling = on
	if on:
		_place(_handle, at)
		_place(_tail, at)
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
