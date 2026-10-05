class_name Ch2Music
extends Node
## Quiet chapter score. Core may set_round explicitly after restoring a checkpoint.

@export_dir var sound_directory: String = Ch2AudioBank.DIRECTORY
var _beds: Array[AudioStreamPlayer] = []
var _turn: AudioStreamPlayer
var _round: StringName = &""
var _stopped: bool = false
var _gains: Array[float] = [0.0, 0.0]
var _pulse_gain: float = 0.0


func _ready() -> void:
	for clip_name in ["music_chain", "music_shower", "music_turn"]:
		var player := AudioStreamPlayer.new()
		player.bus = &"Music"
		player.stream = Ch2AudioBank.clip(clip_name, sound_directory)
		player.volume_linear = 0.0
		add_child(player)
		if clip_name == "music_turn":
			_turn = player
		else:
			_beds.append(player)
	EventBus.chapter_started.connect(_on_chapter)
	EventBus.chapter_finished.connect(_reset)
	EventBus.checkpoint_loaded.connect(_reset)
	EventBus.player_death_started.connect(_reset)
	EventBus.chain_turn_started.connect(_on_turn)
	EventBus.shower_choice_requested.connect(_on_shower)


func set_round(round_id: StringName) -> void:
	if _stopped or round_id not in [&"", &"chain", &"shower"]:
		return
	_round = round_id
	if is_node_ready():
		for i in _beds.size():
			if round_id == [&"chain", &"shower"][i] and _beds[i].stream != null and not _beds[i].playing:
				_beds[i].play()
		if round_id != &"chain":
			_turn.stop()


func _process(delta: float) -> void:
	if _stopped:
		return
	for i in _beds.size():
		var target := 1.0 if _round == [&"chain", &"shower"][i] else 0.0
		_gains[i] = move_toward(_gains[i], target, delta / 1.5)
		_beds[i].volume_linear = _gains[i]
		if _gains[i] == 0.0:
			_beds[i].stop()
	_pulse_gain = move_toward(_pulse_gain, 0.0, delta / 1.2)
	_turn.volume_linear = _pulse_gain


func _on_turn(_speaker: StringName, seconds: float) -> void:
	if not _stopped and _round == &"chain" and is_finite(seconds) and seconds > 0.0 and _turn.stream != null:
		_pulse_gain = 1.0
		_turn.volume_linear = 1.0
		_turn.play()


func _on_shower(_seconds: float) -> void:
	if not _round.is_empty():
		set_round(&"shower")


func _on_chapter(chapter: int) -> void:
	_reset(null)
	if chapter == 2:
		set_round(&"chain")


func _reset(_value: Variant) -> void:
	_round = &""
	_gains = [0.0, 0.0]
	_pulse_gain = 0.0
	for player in _beds + [_turn]:
		player.stop()
		player.volume_linear = 0.0


func stop_emitting() -> void:
	_stopped = true
	if is_node_ready():
		_reset(null)
