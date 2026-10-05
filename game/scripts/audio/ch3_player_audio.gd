class_name Ch3PlayerAudio
extends Node
## Local stamina and bar Foley; does not emit gameplay noise.

@export_dir var sound_directory: String = Ch3AudioBank.DIRECTORY
var stamina: float = 1.0
var exhausted: bool = false
var _pant: AudioStreamPlayer
var _heart: AudioStreamPlayer
var _swing: AudioStreamPlayer
var _impact: AudioStreamPlayer
var _metal: AudioStreamPlayer
var _until_pant: float = 0.0
var _until_beat: float = 0.0
var _dead: bool = false
var _stopped: bool = false


func _ready() -> void:
	_pant = _source()
	_heart = _source()
	_swing = _source()
	_impact = _source()
	_metal = _source()
	EventBus.stamina_changed.connect(set_stamina)
	EventBus.bar_swung.connect(_on_swing)
	EventBus.bar_broken.connect(_on_break)
	EventBus.bar_picked.connect(_on_pick)
	EventBus.player_death_started.connect(_on_death)
	EventBus.checkpoint_loaded.connect(_reset)
	EventBus.chapter_started.connect(_reset)
	EventBus.chapter_finished.connect(_on_death)


func _source() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = &"SFX"
	add_child(player)
	return player


func set_stamina(value: float, is_exhausted: bool) -> void:
	if _stopped or _dead:
		return
	stamina = clampf(value, 0.0, 1.0) if is_finite(value) else 1.0
	exhausted = is_exhausted and is_finite(value)
	_pant.pitch_scale = 1.35 if exhausted else lerpf(1.2, 0.95, stamina)
	_pant.volume_db = lerpf(0.0, -12.0, stamina)
	if stamina >= 0.95 and not exhausted:
		_pant.stop()
		_until_pant = 0.0
	if not exhausted:
		_heart.stop()
		_until_beat = 0.0
	_until_pant = minf(_until_pant, pant_interval())


func pant_interval() -> float:
	return 1.05 if exhausted else lerpf(1.35, 2.8, stamina)


func _process(delta: float) -> void:
	if _stopped or _dead:
		return
	if stamina < 0.95 or exhausted:
		_until_pant -= delta
		if _until_pant <= 0:
			_until_pant = pant_interval()
			Ch3AudioBank.play(_pant, "pant", sound_directory)
	if exhausted:
		_until_beat -= delta
		if _until_beat <= 0:
			_until_beat = 0.65
			_heart.stream = Ch1AudioBank.clip("heartbeat")
			_heart.volume_db = -8.0
			if _heart.stream != null:
				_heart.play()


func _on_swing(hit: bool, hits_left: int) -> void:
	if _stopped or _dead:
		return
	Ch3AudioBank.play(_swing, "bar_swing", sound_directory)
	Ch3AudioBank.play(_impact, "bar_hit" if hit else "bar_miss", sound_directory)
	if hit and hits_left in [1, 2]:
		Ch3AudioBank.play(_metal, "bar_bend", sound_directory)


func _on_break() -> void:
	if not _stopped and not _dead:
		Ch3AudioBank.play(_metal, "bar_break", sound_directory)


func _on_pick(_hits_left: int) -> void:
	# No invented pickup sound; cancel the previous bar's lingering fracture.
	_metal.stop()


func _reset(_reason: Variant) -> void:
	_dead = false
	stamina = 1.0
	exhausted = false
	_until_pant = 0.0
	_until_beat = 0.0
	for player in [_pant, _heart, _swing, _impact, _metal]:
		if player != null:
			player.stop()


func _on_death(reason: Variant) -> void:
	_reset(reason)
	_dead = true


func stop_emitting() -> void:
	_stopped = true
	_reset(null)
