class_name CorpseVoice
extends Node3D
## One rig at each corpse's head. No words are invented if core's bank is absent.

@export_enum("phuc", "viet", "dat") var speaker: String = "phuc"
@export_dir var voice_directory: String = "res://audio/voice/vi"
@export_dir var sound_directory: String = Ch2AudioBank.DIRECTORY
var _voice: AudioStreamPlayer3D
var _foley: AudioStreamPlayer3D
var _private_bus: StringName
var _filter: AudioEffectLowPassFilter
var _state: StringName = &""
var _gagged: bool = false
var _stopped: bool = false


func _ready() -> void:
	_voice = AudioStreamPlayer3D.new()
	_voice.name = "Voice"
	_voice.unit_size = 3.0
	_voice.volume_db = -6.0
	_voice.pitch_scale = {"phuc": 0.82, "viet": 0.72, "dat": 0.91}.get(speaker, 0.82)
	add_child(_voice)
	_private_bus = StringName("CorpseVoice_%d" % get_instance_id())
	AudioServer.add_bus()
	var index := AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, _private_bus)
	AudioServer.set_bus_send(index, &"Voice")
	var distortion := AudioEffectDistortion.new()
	distortion.mode = AudioEffectDistortion.MODE_ATAN
	distortion.drive = {"phuc": 0.25, "viet": 0.35, "dat": 0.18}.get(speaker, 0.25)
	distortion.pre_gain = 6.0
	distortion.post_gain = -6.0
	AudioServer.add_bus_effect(index, distortion)
	_filter = AudioEffectLowPassFilter.new()
	_filter.cutoff_hz = 3800.0
	AudioServer.add_bus_effect(index, _filter)
	_voice.bus = _private_bus
	_foley = AudioStreamPlayer3D.new()
	_foley.name = "Body"
	_foley.bus = &"SFX"
	_foley.unit_size = 2.0
	add_child(_foley)
	EventBus.chain_word_spoken.connect(_on_word)
	EventBus.chain_turn_started.connect(_on_turn)
	EventBus.corpse_state_changed.connect(_on_state)
	EventBus.chapter_started.connect(_reset)
	EventBus.checkpoint_loaded.connect(_reset)
	EventBus.chapter_finished.connect(_reset)
	EventBus.player_death_started.connect(_on_death)


func play_word(key: String) -> float:
	if _stopped or not is_node_ready():
		return 0.0
	if key.is_empty() or _gagged or _state == &"mumble":
		set_mumbling(true)
		return 0.0
	_voice.stop()
	_filter.cutoff_hz = 3800.0
	_voice.stream = null
	if key.begins_with("WORD_CH2_"):
		for character in key:
			if not character in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_":
				return 0.0
		_voice.stream = null if voice_directory.is_empty() else Ch1AudioBank.load_if_present(voice_directory.path_join(key + ".ogg"))
	elif VietText.syllables(key).size() == 2:
		_voice.stream = CorpseSyllablePhrase.build(Ch2SyllableBank.clips_for(key), _voice.pitch_scale)
	if _voice.stream == null:
		return 0.0
	_voice.play()
	return _voice.stream.get_length() / _voice.pitch_scale


func set_mumbling(on: bool) -> void:
	if _stopped or not is_node_ready():
		return
	if not on:
		_voice.stop()
		return
	var clip := Ch2AudioBank.clip("corpse_mumble", sound_directory)
	_filter.cutoff_hz = 650.0
	if _voice.stream == clip and _voice.playing:
		return
	_voice.stop()
	_voice.stream = clip
	if clip != null:
		_voice.play()


func _on_word(who: StringName, key: String) -> void:
	if who == StringName(speaker):
		play_word(key)


func _on_turn(_who: StringName, _seconds: float) -> void:
	# A new turn cuts off the previous turn's voice, including gagged mumbling.
	if is_node_ready():
		_voice.stop()


func _on_state(bed: int, state: StringName) -> void:
	if _stopped or bed != {"phuc": 1, "viet": 2, "dat": 4}.get(speaker, -1) or state == _state:
		return
	_state = state
	if state == &"gagged":
		_gagged = true
	_voice.stop()
	if state == &"mumble":
		set_mumbling(true)
	var clip_name: String = {&"sit": "corpse_revive", &"revive": "corpse_revive", &"fall": "corpse_fall", &"slump": "corpse_fall", &"gagged": "corpse_gag"}.get(state, "")
	_foley.stop()
	_foley.stream = Ch2AudioBank.clip(clip_name, sound_directory)
	_foley.volume_db = -8.0 if Ch1AudioBank.reduced() else 0.0
	if _foley.stream != null:
		_foley.play()


func _reset(_value: Variant) -> void:
	_voice.stop()
	_foley.stop()
	_state = &""
	_gagged = false


func _on_death(_kind: StringName) -> void:
	_reset(null)


func stop_emitting() -> void:
	_stopped = true
	if is_node_ready():
		_reset(null)


func _exit_tree() -> void:
	_voice.stop()
	_voice.bus = &"Voice"
	var index := AudioServer.get_bus_index(_private_bus)
	if index >= 0:
		AudioServer.remove_bus(index)
