class_name LightHum
extends AmbientEmitter
## Attach this AmbientEmitter subclass to the hum player, then assign its light.
## Visibility changes stop immediately; energy/ancestor changes are checked each frame.

const ENERGY_EPSILON: float = 0.001
const FLICKER_CLIP: AudioStreamOggVorbis = preload("res://audio/sfx/fluorescent_flicker.ogg")

@export var light: Light3D

var _flicker_player: AudioStreamPlayer3D
var _flicker_remaining: float = 0.0
var _pulse_remaining: float = 0.0
var _pulse_on: bool = true


func _ready() -> void:
	start_on_ready = false
	playback_mode = PlaybackMode.LOOP
	if stream == null:
		stream = preload("res://audio/ambience/fluorescent_hum.ogg")
	super._ready()
	_flicker_player = AudioStreamPlayer3D.new()
	_flicker_player.stream = FLICKER_CLIP
	_flicker_player.bus = bus
	_flicker_player.unit_size = unit_size
	_flicker_player.max_distance = max_distance
	_flicker_player.attenuation_model = attenuation_model
	_flicker_player.max_db = max_db
	add_child(_flicker_player)
	if is_instance_valid(light):
		light.visibility_changed.connect(_sync_light)
	_sync_light()


func flicker(duration: float) -> void:
	if duration <= 0.0 or not is_finite(duration) or not _light_is_on():
		return
	_flicker_remaining = duration
	_pulse_remaining = 0.08
	_pulse_on = false
	stop_emitting()
	_flicker_player.volume_db = volume_db
	_flicker_player.play()


func _process(delta: float) -> void:
	if _flicker_remaining > 0.0:
		_flicker_remaining = maxf(0.0, _flicker_remaining - delta)
		_pulse_remaining -= delta
		if _pulse_remaining <= 0.0:
			_pulse_on = not _pulse_on
			_pulse_remaining = _rng.randf_range(0.04, 0.16)
	_sync_light()


func _light_is_on() -> bool:
	return is_instance_valid(light) and light.is_visible_in_tree() and light.light_energy > ENERGY_EPSILON


func _sync_light() -> void:
	if not is_instance_valid(_flicker_player):
		return
	if not _light_is_on():
		_flicker_remaining = 0.0
		_flicker_player.stop()
		stop_emitting()
		return
	if _flicker_remaining > 0.0:
		if _pulse_on:
			start_emitting()
		else:
			stop_emitting()
		_flicker_player.volume_db = volume_db
		if not _flicker_player.playing:
			_flicker_player.play()
	else:
		_flicker_player.stop()
		start_emitting()


func _exit_tree() -> void:
	if is_instance_valid(light) and light.visibility_changed.is_connected(_sync_light):
		light.visibility_changed.disconnect(_sync_light)
	if is_instance_valid(_flicker_player):
		_flicker_player.stop()
	super._exit_tree()
