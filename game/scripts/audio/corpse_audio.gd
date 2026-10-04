class_name CorpseAudio
extends Node3D
## One rig per corpse. Connect pose_changed(name) or assign poser before ready.

@export var poser: Node
@export_dir var sound_directory: String = Ch1AudioBank.DIRECTORY
@export var floor_base_y: float = 0.0
var _drip: AudioStreamPlayer3D
var _rustle: AudioStreamPlayer3D
var _stopped: bool = false


func _ready() -> void:
	_drip = _make_player("Drip", &"Ambience")
	_rustle = _make_player("Rustle", &"SFX")
	if is_instance_valid(poser) and poser.has_signal("pose_changed"):
		poser.connect("pose_changed", play_pose)


func _make_player(node_name: String, audio_bus: StringName) -> AudioStreamPlayer3D:
	var player := AudioStreamPlayer3D.new()
	player.name = node_name
	player.bus = audio_bus
	player.unit_size = 2.0
	add_child(player)
	var muffle := FloorMuffle.new()
	muffle.floor_base_y = floor_base_y
	player.add_child(muffle)
	return player


func play_drips(on: bool) -> void:
	if _drip == null or _stopped:
		return
	if not on:
		_drip.stop()
	elif not _drip.playing:
		_drip.stream = Ch1AudioBank.clip("blood_drip", sound_directory)
		if _drip.stream != null:
			_drip.play()


func play_pose(_pose_name: StringName = &"") -> void:
	if _rustle == null or _stopped:
		return
	_rustle.stop()
	_rustle.stream = Ch1AudioBank.clip("corpse_rustle", sound_directory)
	if _rustle.stream != null:
		_rustle.play()


func stop_emitting() -> void:
	_stopped = true
	if _drip != null:
		_drip.stop()
	if _rustle != null:
		_rustle.stop()
