class_name MusicDirector
extends Node
## EventBus-only score. Add before StoryDirector starts emitting segment changes.

const CLIPS: Array[AudioStream] = [
	preload("res://audio/music/drone_base.ogg"),
	preload("res://audio/music/drone_tension.ogg"),
	preload("res://audio/music/chase_pulse.ogg"),
	preload("res://audio/music/end_tone.ogg"),
]
const LAYERS: Array[StringName] = [&"base", &"tension", &"chase", &"ending"]

var _players: Dictionary = {}
var _gains: Dictionary = {&"base": 0.0, &"tension": 0.0, &"chase": 0.0, &"ending": 0.0,
	&"duck": 1.0, &"silence": 1.0, &"reduction": 1.0}
var _tweens: Dictionary = {}
var _active: bool = false
var _stopped: bool = false
var _paused: bool = false
var _reduce_scares: bool = false
var _level: int = 0
var _chase_id: StringName = &""
var _tension_remaining: float = 0.0
var _light_remaining: float = 0.0
var _scare_remaining: float = 0.0
var _ending_remaining: float = 0.0


func _ready() -> void:
	# Keep music and ducking alive while the pause menu pauses the scene tree.
	process_mode = Node.PROCESS_MODE_ALWAYS
	for index in LAYERS.size():
		var player := AudioStreamPlayer.new()
		player.name = String(LAYERS[index]).capitalize()
		player.stream = CLIPS[index]
		player.bus = &"Music"
		player.volume_linear = 0.0
		add_child(player)
		_players[LAYERS[index]] = player
	_read_settings()
	_gains[&"reduction"] = db_to_linear(-6.0) if _reduce_scares else 1.0
	_paused = get_tree().paused
	_gains[&"duck"] = db_to_linear(-10.0) if _paused else 1.0
	EventBus.segment_changed.connect(_on_segment)
	EventBus.consequence_triggered.connect(_on_consequence)
	EventBus.deviation_changed.connect(_on_deviation)
	EventBus.scare_triggered.connect(_on_scare)
	EventBus.chase_started.connect(_on_chase_started)
	EventBus.chase_ended.connect(_on_chase_ended)
	EventBus.game_paused.connect(_on_pause)
	EventBus.settings_changed.connect(_on_settings)


func _fade(key: StringName, target: float, seconds: float) -> void:
	if _tweens.has(key):
		(_tweens[key] as Tween).kill()
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tweens[key] = tween
	tween.tween_method(_set_gain.bind(key), float(_gains[key]), target, seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _set_gain(value: float, key: StringName) -> void:
	_gains[key] = value
	_apply_mix()


func _apply_mix() -> void:
	for layer: StringName in LAYERS:
		var gain: float = _gains[layer] * _gains[&"duck"] * _gains[&"silence"]
		if layer == &"chase":
			gain *= float(_gains[&"reduction"])
		(_players[layer] as AudioStreamPlayer).volume_linear = gain


func _clear_schedule() -> void:
	_tension_remaining = 0.0
	_light_remaining = 0.0
	_scare_remaining = 0.0
	_ending_remaining = 0.0
	_chase_id = &""


func _on_segment(segment: StringName) -> void:
	if _stopped:
		return
	_clear_schedule()
	_fade(&"silence", 1.0, 0.1)
	_fade(&"chase", 0.0, 0.2)
	_fade(&"ending", 0.0, 0.2)
	_active = segment in [&"seg2", &"seg3", &"seg4", &"seg5"]
	if _active:
		for layer: StringName in [&"base", &"tension", &"chase"]:
			var player: AudioStreamPlayer = _players[layer]
			if not player.playing:
				player.play()
		_fade(&"base", 1.0, 2.0)
		_refresh_tension(2.0)
	else:
		_fade(&"base", 0.0, 0.8)
		_fade(&"tension", 0.0, 0.8)
		if segment == &"end":
			_ending_remaining = 0.85


func _refresh_tension(seconds: float) -> void:
	var gain := 0.0
	if _active and _light_remaining <= 0.0:
		if _tension_remaining > 0.0:
			gain = db_to_linear(-8.0 + 2.0 * _level)
		elif _level > 0:
			gain = db_to_linear(-14.0 + 2.0 * _level)
	_fade(&"tension", gain, seconds)


func _on_consequence(consequence: StringName, _rule_id: StringName) -> void:
	if not _active or _stopped:
		return
	if consequence == &"corridor_light_flicker":
		_light_remaining = 3.0
		# A 10 ms release is perceptually immediate but avoids a sample discontinuity.
		_fade(&"silence", 0.0, 0.01)
	_tension_remaining = _light_remaining + 2.0 + 15.0
	_refresh_tension(0.01 if _light_remaining > 0.0 else 2.0)


func _on_deviation(level: int, _reason: StringName) -> void:
	if _stopped:
		return
	_level = clampi(level, 0, 4)
	_refresh_tension(2.0)


func _on_scare(_scare_id: StringName) -> void:
	if not _active or _stopped or _reduce_scares:
		return
	_scare_remaining = 1.5
	_fade(&"silence", 0.0, 0.01)


func _on_chase_started(chase_id: StringName) -> void:
	if not _active or _stopped:
		return
	_chase_id = chase_id
	_fade(&"chase", 1.0, 0.5)


func _on_chase_ended(chase_id: StringName, caught: bool) -> void:
	if not _active or _stopped or chase_id != _chase_id:
		return
	_chase_id = &""
	_fade(&"chase", 0.0, 0.01 if caught else 1.5)


func _on_pause(paused: bool) -> void:
	if _stopped:
		return
	_paused = paused
	_fade(&"duck", db_to_linear(-10.0) if paused else 1.0, 0.2)


func _read_settings() -> void:
	var config := ConfigFile.new()
	_reduce_scares = false
	if config.load("user://settings.cfg") == OK:
		var value: Variant = config.get_value("accessibility", "reduce_scares", false)
		if value is bool:
			_reduce_scares = value


func _on_settings(section: String, key: String) -> void:
	if _stopped or section != "accessibility" or key != "reduce_scares":
		return
	_read_settings()
	_fade(&"reduction", db_to_linear(-6.0) if _reduce_scares else 1.0, 0.2)
	if _reduce_scares:
		_scare_remaining = 0.0
		if _light_remaining <= 0.0:
			_fade(&"silence", 1.0, 0.2)


func _process(delta: float) -> void:
	if _stopped or _paused:
		return
	var was_silent := _light_remaining > 0.0 or _scare_remaining > 0.0
	if _light_remaining > 0.0:
		_light_remaining = maxf(0.0, _light_remaining - delta)
		if _light_remaining == 0.0:
			_refresh_tension(2.0)
	_scare_remaining = maxf(0.0, _scare_remaining - delta)
	if was_silent and _light_remaining == 0.0 and _scare_remaining == 0.0:
		_fade(&"silence", 1.0, 0.3)
	if _tension_remaining > 0.0:
		_tension_remaining = maxf(0.0, _tension_remaining - delta)
		if _tension_remaining == 0.0:
			_refresh_tension(8.0)
	if _ending_remaining > 0.0:
		_ending_remaining = maxf(0.0, _ending_remaining - delta)
		if _ending_remaining == 0.0:
			for layer: StringName in [&"base", &"tension", &"chase"]:
				(_players[layer] as AudioStreamPlayer).stop()
			_set_gain(1.0, &"ending")
			(_players[&"ending"] as AudioStreamPlayer).play()


func stop_emitting() -> void:
	_stopped = true
	_active = false
	_clear_schedule()
	for tween: Tween in _tweens.values():
		tween.kill()
	_tweens.clear()
	for player: AudioStreamPlayer in _players.values():
		player.volume_linear = 0.0
		player.stop()


func _exit_tree() -> void:
	stop_emitting()
