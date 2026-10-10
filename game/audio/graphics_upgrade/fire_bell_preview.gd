extends Node3D
## Isolated G0 listening fixture. Never emits gameplay noise or changes settings.

const CANDIDATE := preload("res://audio/graphics_upgrade/fire_bell_soft.ogg")
const REFERENCE := preload("res://audio/ch1v2/lock_alarm.ogg")

var source_position := Vector3(0.0, 0.0, -8.0)
var player: AudioStreamPlayer3D
var _preview_paused: bool = false
var _deadline: Timer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_deadline = Timer.new()
	_deadline.process_mode = Node.PROCESS_MODE_PAUSABLE
	_deadline.one_shot = true
	add_child(_deadline)
	_deadline.timeout.connect(stop_preview)


func play_clip(reference: bool = false, looping: bool = false, seconds: float = 0.0) -> void:
	stop_preview()
	player = AudioStreamPlayer3D.new()
	player.name = "PreviewSource"
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	# A private stream keeps the imported candidate safe for await finished callers.
	var stream := (REFERENCE if reference else CANDIDATE).duplicate() as AudioStreamOggVorbis
	stream.loop = looping
	player.stream = stream
	player.bus = &"SFX"
	player.volume_db = -4.0
	player.unit_size = 8.0
	player.position = source_position
	add_child(player)
	if not looping:
		player.finished.connect(stop_preview)
	player.play()
	if seconds > 0.0:
		_deadline.start(seconds)


func stop_preview() -> void:
	if _deadline != null:
		_deadline.stop()
	if is_instance_valid(player):
		player.stop()
		remove_child(player)
		player.queue_free()
	player = null
	if _preview_paused:
		get_tree().paused = false
		_preview_paused = false


func toggle_pause() -> void:
	_preview_paused = not _preview_paused
	get_tree().paused = _preview_paused


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match (event as InputEventKey).physical_keycode:
		KEY_1: play_clip()
		KEY_2: play_clip(false, true)
		KEY_3: play_clip(true)
		KEY_4: play_clip(false, true, 20.0)
		KEY_0: stop_preview()
		KEY_P: toggle_pause()
		KEY_R:
			stop_preview()
			get_tree().reload_current_scene()
		KEY_ESCAPE:
			stop_preview()
			App.quit()
		KEY_LEFT: source_position.x = -4.0
		KEY_RIGHT: source_position.x = 4.0
		KEY_UP: source_position = Vector3(0.0, 0.0, -2.0)
		KEY_DOWN: source_position = Vector3(0.0, 0.0, -20.0)
		KEY_C: source_position = Vector3(0.0, 0.0, -8.0)
	if is_instance_valid(player):
		player.position = source_position


func _exit_tree() -> void:
	if is_instance_valid(player):
		player.stop()
	if _preview_paused:
		get_tree().paused = false
