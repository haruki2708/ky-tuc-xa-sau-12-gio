class_name Ch1Music
extends Node
## Chapter score reuses the approved quiet drones. No story timing inferred here.

@export var base_stream: AudioStream = preload("res://audio/music/drone_base.ogg")
@export var tension_stream: AudioStream = preload("res://audio/music/drone_tension.ogg")
var _base: AudioStreamPlayer
var _tension: AudioStreamPlayer
var _active: bool = false
var _stopped: bool = false
var _level: float = 0.0
var _silence: float = 1.0
var _duck: float = 1.0
var _base_gain: float = 0.0
var _tension_gain: float = 0.0
var _tweens: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_base = _make_player("Base", base_stream)
	_tension = _make_player("Tension", tension_stream)
	EventBus.chapter_started.connect(_on_chapter)
	EventBus.chapter_finished.connect(_on_finished)
	EventBus.game_paused.connect(_on_pause)
	_duck = db_to_linear(-10.0) if get_tree().paused else 1.0


func _make_player(node_name: String, clip: AudioStream) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = node_name
	player.bus = &"Music"
	player.stream = clip
	player.volume_linear = 0.0
	add_child(player)
	return player


func set_active(active: bool) -> void:
	if _stopped or _base == null:
		return
	_active = active
	if active:
		for player in [_base, _tension]:
			if player.stream != null and not player.playing:
				player.play()
	_fade("_base_gain", 0.65 if active else 0.0, 2.0)
	_fade("_tension_gain", _level if active else 0.0, 2.0)


func set_tension(level: float) -> void:
	if _stopped or not is_finite(level):
		return
	_level = clampf(level, 0.0, 1.0)
	_fade("_tension_gain", _level if _active else 0.0, 1.5)


func silence_before_door(silent: bool = true) -> void:
	if not _stopped:
		# Latched independently: proximity updates cannot undo this silence.
		_fade("_silence", 0.0 if silent else 1.0, 0.01 if silent else 1.0)


func _fade(property_name: String, target: float, seconds: float) -> void:
	if not is_inside_tree():
		return
	if _tweens.has(property_name):
		(_tweens[property_name] as Tween).kill()
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tweens[property_name] = tween
	tween.tween_property(self, property_name, target, seconds)


func _process(_delta: float) -> void:
	_base.volume_linear = _base_gain * _silence * _duck
	_tension.volume_linear = _tension_gain * _silence * _duck


func _on_chapter(chapter: int) -> void:
	if _stopped:
		return
	set_tension(0.0)
	silence_before_door(false)
	set_active(chapter == 1)


func _on_finished(_chapter: int) -> void:
	set_active(false)


func _on_pause(paused: bool) -> void:
	if not _stopped:
		_fade("_duck", db_to_linear(-10.0) if paused else 1.0, 0.2)


func stop_emitting() -> void:
	_stopped = true
	for tween: Tween in _tweens.values():
		tween.kill()
	_tweens.clear()
	_base_gain = 0.0
	_tension_gain = 0.0
	for player in [_base, _tension]:
		if player != null:
			player.volume_linear = 0.0
			player.stop()


func _exit_tree() -> void:
	stop_emitting()
