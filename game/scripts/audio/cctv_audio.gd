class_name CctvAudio
extends Node
## UI calls set_viewing only when the Camera tab is actually visible.

@export_dir var sound_directory: String = Ch1V2AudioBank.DIRECTORY
@export_dir var chapter2_directory: String = Ch2AudioBank.DIRECTORY
var _room_loss: AudioStreamPlayer
var _background: AudioStreamPlayer
var _switch: AudioStreamPlayer
var _viewing: bool = false
var _channel: StringName = &""
var _stopped: bool = false


func _ready() -> void:
	_background = _make_player("CameraStatic")
	_switch = _make_player("ChannelSwitch")
	_room_loss = _make_player("RoomLoss")
	EventBus.phone_raised.connect(_on_raised)
	EventBus.chapter_started.connect(_reset)
	EventBus.checkpoint_loaded.connect(_reset)
	EventBus.player_death_started.connect(_reset)
	EventBus.settings_changed.connect(_on_settings)


func _make_player(node_name: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = node_name
	player.bus = &"SFX"
	add_child(player)
	return player


func set_viewing(viewing: bool) -> void:
	if _stopped or not is_node_ready() or viewing == _viewing:
		return
	_viewing = viewing
	if not viewing:
		_background.stop()
		_switch.stop()
		_room_loss.stop()
	else:
		_background.stream = Ch1V2AudioBank.clip("cctv_static", sound_directory)
		if _background.stream != null:
			_background.play()


func select_channel(camera_id: StringName) -> void:
	if _stopped or not _viewing or camera_id.is_empty() or camera_id == _channel:
		return
	_channel = camera_id
	_room_loss.stop()
	_switch.stop()
	_switch.stream = Ch1V2AudioBank.clip("cctv_switch", sound_directory)
	if _switch.stream != null:
		_switch.play()


func _on_raised(raised: bool) -> void:
	if not raised:
		set_viewing(false)


func play_room_loss(camera_id: StringName) -> bool:
	# Caller emits this at the event, never when opening the tab afterwards.
	if _stopped or not is_node_ready() or not _viewing or camera_id.is_empty() or camera_id != _channel or _room_loss.playing:
		return false
	_room_loss.stream = Ch2AudioBank.clip("camera_room_loss", chapter2_directory)
	_room_loss.volume_db = -12.0 if Ch1AudioBank.reduced() else 0.0
	if _room_loss.stream == null:
		return false
	_room_loss.play()
	return true


func _on_settings(section: String, key: String) -> void:
	if section == "accessibility" and key == "reduce_scares" and Ch1AudioBank.reduced():
		_room_loss.stop()


func _reset(_value: Variant) -> void:
	set_viewing(false)
	_channel = &""


func stop_emitting() -> void:
	set_viewing(false)
	_stopped = true
