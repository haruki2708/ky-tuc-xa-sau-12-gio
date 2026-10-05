class_name Ch1PlayerAudio
extends Node
## Listener-local Foley; never emits gameplay noise or decides breath exhaustion.

@export_dir var sound_directory: String = Ch1AudioBank.DIRECTORY
@export var handle_player_caught: bool = true
@export_dir var mission_directory: String = Ch1V2AudioBank.DIRECTORY
@export_dir var chapter2_directory: String = Ch2AudioBank.DIRECTORY
## T-161 sets the gameplay limit; match that limit without deciding exhaustion here.
@export var heartbeat_ramp_seconds: float = 6.0
var _heart: AudioStreamPlayer
var _foley: AudioStreamPlayer
var _death: AudioStreamPlayer
var _death_kind: StringName = &""
var _manager_kill_played: bool = false
var _holding: bool = false
var _held_seconds: float = 0.0
var _until_beat: float = 0.0
var _stopped: bool = false


func _ready() -> void:
	_heart = AudioStreamPlayer.new()
	_heart.name = "Heartbeat"
	_heart.bus = &"SFX"
	add_child(_heart)
	_foley = AudioStreamPlayer.new()
	_foley.name = "Foley"
	_foley.bus = &"SFX"
	add_child(_foley)
	_death = AudioStreamPlayer.new()
	_death.name = "DeathDetail"
	_death.bus = &"SFX"
	add_child(_death)
	EventBus.breath_held.connect(_on_breath)
	EventBus.noise_emitted.connect(_on_noise)
	EventBus.player_hidden.connect(_on_hidden)
	EventBus.player_caught.connect(_on_caught)
	EventBus.player_death_started.connect(_on_death)
	EventBus.checkpoint_loaded.connect(_on_checkpoint)
	EventBus.chapter_started.connect(_on_chapter)
	EventBus.settings_changed.connect(_on_settings)


func _on_breath(holding: bool) -> void:
	if _stopped or (holding and not _death_kind.is_empty()) or holding == _holding:
		return
	_holding = holding
	_held_seconds = 0.0
	_until_beat = 0.0
	if not holding:
		_heart.stop()


func heartbeat_interval() -> float:
	var seconds := heartbeat_ramp_seconds if is_finite(heartbeat_ramp_seconds) and heartbeat_ramp_seconds > 0.0 else 6.0
	return lerpf(1.1, 0.66, clampf(_held_seconds / seconds, 0.0, 1.0))


func _process(delta: float) -> void:
	if not _holding or _stopped:
		return
	_held_seconds += delta
	_until_beat -= delta
	if _until_beat <= 0.0:
		_until_beat = heartbeat_interval()
		_heart.stream = Ch1AudioBank.clip("heartbeat", sound_directory)
		if _heart.stream != null:
			_heart.play()


func play_action(action: StringName) -> void:
	# A scene being freed can still emit player_hidden (Player._exit_tree).
	if _stopped or _foley == null or not _foley.is_inside_tree() or action not in [&"breath_gasp", &"bunk_climb", &"bunk_creak", &"wall_knock", &"locker_unlock", &"charger_plug", &"manager_kill", &"kill_soft"]:
		return
	var clip_name := String(action)
	if not _death_kind.is_empty() and action not in [&"manager_kill", &"kill_soft"]:
		return
	if action == &"manager_kill" and Ch1AudioBank.reduced():
		clip_name = "kill_soft"
	_foley.stop()
	_foley.stream = Ch1AudioBank.clip(clip_name, sound_directory)
	if _foley.stream != null:
		_foley.play()
		if action in [&"manager_kill", &"kill_soft"]:
			_manager_kill_played = true


func _on_noise(_position: Vector3, radius: float, source: StringName) -> void:
	# T-151 contract: ordinary breath = 1.5 m, mandatory gasp = 4 m.
	if source == &"breath" and radius >= 4.0:
		_on_breath(false)
		play_action(&"breath_gasp")


func _on_hidden(hidden: bool, kind: StringName) -> void:
	if not hidden:
		_on_breath(false)
	if kind in [&"bunk", &"bed"]:
		play_action(&"bunk_creak")


func _on_caught(_entity_id: StringName) -> void:
	_on_breath(false)
	if handle_player_caught and not _manager_kill_played and _death_kind in [&"", &"manager_kill"]:
		play_action(&"manager_kill")


func _on_death(kind: StringName) -> void:
	if _stopped or not is_node_ready() or not _death_kind.is_empty() or kind not in [&"fall_back", &"bed_burst", &"manager_kill", &"none", &"corpse_lunge", &"scald"]:
		return
	_death_kind = kind
	_on_breath(false)
	if kind == &"manager_kill":
		_on_caught(&"manager")
	else:
		_foley.stop()
	_play_death_detail()


func _play_death_detail() -> void:
	_death.stop()
	var reduced := Ch1AudioBank.reduced()
	var clip_name := ""
	match _death_kind:
		&"fall_back": clip_name = "death_fall_soft" if reduced else "death_fall_back"
		&"bed_burst": clip_name = "death_bed_soft" if reduced else "death_bed_burst"
		&"manager_kill": clip_name = "" if reduced else "death_flesh"
		&"corpse_lunge": clip_name = "death_corpse_soft" if reduced else "death_corpse_lunge"
		&"scald": clip_name = "death_scald_soft" if reduced else "death_scald"
	_death.stream = Ch2AudioBank.clip(clip_name, chapter2_directory) if _death_kind in [&"corpse_lunge", &"scald"] else Ch1V2AudioBank.clip(clip_name, mission_directory)
	if _death.stream != null:
		_death.play()


func _on_settings(section: String, key: String) -> void:
	if section == "accessibility" and key == "reduce_scares" and Ch1AudioBank.reduced():
		if _foley.playing and _foley.stream == Ch1AudioBank.clip("manager_kill", sound_directory):
			play_action(&"kill_soft")
		if _death.playing:
			_play_death_detail()


func _on_chapter(_chapter: int) -> void:
	_on_breath(false)
	_foley.stop()
	_death.stop()
	_death_kind = &""
	_manager_kill_played = false


func _on_checkpoint(_checkpoint: StringName) -> void:
	_on_chapter(0)


func stop_emitting() -> void:
	_stopped = true
	_holding = false
	if _heart != null:
		_heart.stop()
	if _foley != null:
		_foley.stop()
	if _death != null:
		_death.stop()
