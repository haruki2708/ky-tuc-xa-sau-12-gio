class_name Ch4AudioRig
extends Node3D

# Scene-owned entry point. Core supplies real scene anchors and story timing.
var listener: Node3D
var monitor_marker: Node3D
var stair_points: Array[Node3D] = []
var decoy: Ch4DecoyAudio
var music: Ch4Music
var hospital: Ch4HospitalAudio
var doors: Dictionary[StringName, Ch4DoorAudio] = {}
var scare_positions: Dictionary[StringName, Vector3] = {}
var _door_anchors: Dictionary[StringName, Node3D] = {}
var _scare: AudioStreamPlayer3D
var _pa: AudioStreamPlayer3D
var _crowd: Array[AudioStreamPlayer3D] = []
var _seen: Dictionary[StringName, bool] = {}
var _neck_wait: float = -1.0
var _last_door: StringName = &""
var _active: bool = true
var _disabled: bool = false
var _hushed: bool = false
var _area: StringName = &""


func _ready() -> void:
	decoy = Ch4DecoyAudio.new()
	add_child(decoy)
	music = Ch4Music.new()
	add_child(music)
	hospital = Ch4HospitalAudio.new()
	add_child(hospital)
	_scare = Ch4AudioBank.spatial(self, &"SFX", 25.0)
	_pa = Ch4AudioBank.spatial(self, &"Voice", 30.0)
	for index in 3:
		var player := Ch4AudioBank.spatial(self, &"Ambience", 24.0)
		player.volume_db = -18.0
		_crowd.append(player)
	EventBus.scare_triggered.connect(_on_scare)
	EventBus.door_damage_changed.connect(_remember_door)
	EventBus.fade_message_requested.connect(_begin_fade)
	EventBus.ch4_ending.connect(_on_hospital)
	EventBus.chapter_finished.connect(_on_finished)
	EventBus.player_death_started.connect(_on_death)
	EventBus.checkpoint_loaded.connect(_reset)


func register_door(id: StringName, anchor: Node3D) -> Ch4DoorAudio:
	if _disabled or id.is_empty() or not is_instance_valid(anchor):
		return null
	if doors.has(id):
		_door_anchors[id] = anchor
		return doors[id]
	var door := Ch4DoorAudio.new()
	door.door_id = id
	add_child(door)
	door.global_position = anchor.global_position
	door.enabled = _active and not _hushed
	doors[id] = door
	_door_anchors[id] = anchor
	return door


func _remember_door(id: StringName, fraction: float) -> void:
	if _active and doors.has(id) and is_finite(fraction) and fraction > 0.0:
		_last_door = id


func play_door_burst(id: StringName) -> void:
	if _active and not _disabled and doors.has(id):
		_last_door = id
		doors[id].play_burst()


func set_area(value: StringName) -> void:
	if not _active or _disabled:
		return
	_area = value
	_hushed = false
	_neck_wait = -1.0
	decoy.enabled = value != &"407" and value != &"hospital"
	music.set_muted(false)
	music.set_area(value)
	for door in doors.values():
		door.enabled = true
	if value == &"407":
		decoy._reset()
		_scare.stop()
		_pa.stop()
		hospital.reset()
	if value == &"hospital" and is_instance_valid(monitor_marker):
		hospital.enter_hospital(monitor_marker.global_position)
	_update_crowd()


func _process(delta: float) -> void:
	for id in doors.keys():
		if is_instance_valid(_door_anchors[id]):
			doors[id].global_position = _door_anchors[id].global_position
		else:
			doors[id].suspend()
	_update_crowd()
	if _neck_wait >= 0.0 and _active:
		_neck_wait -= delta
		if _neck_wait <= 0.000001:
			_neck_wait = -1.0
			_play_scare(&"neck_hand")


func _update_crowd() -> void:
	var points: Array[Node3D] = []
	if _active and not _hushed and _area == &"stairs" and is_instance_valid(listener):
		for point in stair_points:
			if is_instance_valid(point) and point.global_position.distance_to(listener.global_position) < 24.0:
				points.append(point)
		points.sort_custom(func(a: Node3D, b: Node3D) -> bool:
			return a.global_position.distance_squared_to(listener.global_position) < b.global_position.distance_squared_to(listener.global_position))
	for index in _crowd.size():
		var player := _crowd[index]
		if index >= points.size():
			player.stop()
		else:
			player.global_position = points[index].global_position
			Ch3AudioBank.play(player, "horde" if index == 0 else "zombie_growl")


func _on_scare(id: StringName) -> void:
	if not _active or _disabled or _seen.has(id) or not Ch4AudioBank.SCARES.has(id):
		return
	if id == &"monitor_skip" and not hospital._hospital:
		return
	_seen[id] = true
	if id == &"monitor_skip":
		hospital.skip_monitor()
	elif id == &"neck_hand":
		_hushed = true
		_silence(false)
		_neck_wait = 0.8
	else:
		_play_scare(id)


func _play_scare(id: StringName) -> void:
	_scare.global_position = scare_positions.get(id, global_position)
	_scare.volume_db = -10.0 if Ch1AudioBank.reduced() else 0.0
	Ch4AudioBank.play(_scare, String(id))


func play_pa_laugh(at: Vector3) -> void:
	if not _active or _disabled or _seen.has(&"pa_laugh") or not at.is_finite():
		return
	_seen[&"pa_laugh"] = true
	_pa.global_position = at
	Ch4AudioBank.play(_pa, "pa_laugh")


func play_line(id: String, at: Vector3) -> float:
	if not _active or _disabled:
		return 0.0
	return hospital.play_line(id, at)


func _begin_fade(seconds: float) -> void:
	if not _active or _disabled or not is_finite(seconds) or seconds <= 0.0:
		return
	if hospital._fade_length > 0.0:
		return
	_hushed = true
	_silence(false)
	_neck_wait = -1.0
	hospital.begin_fade(seconds)


func _on_hospital(_kind: StringName) -> void:
	if _active:
		set_area(&"hospital")


func _on_finished(chapter: int) -> void:
	if chapter != 4 or not _active or _disabled:
		return
	_silence(false)
	_active = false
	music.play_ending()


func _on_death(kind: StringName) -> void:
	if not _active or _disabled:
		return
	# fraction=1 / explicit burst / death may arrive together: one audible burst.
	if kind == &"door_burst" and doors.has(_last_door):
		doors[_last_door].play_burst()
	_silence(kind == &"door_burst")
	if kind == &"door_burst" and not doors.has(_last_door):
		_scare.volume_db = 0.0
		Ch4AudioBank.play(_scare, "door_burst_soft" if Ch1AudioBank.reduced() else "door_burst")
	_active = false
	_neck_wait = -1.0


func _silence(keep_burst: bool) -> void:
	music.set_muted(true)
	decoy._reset()
	decoy.enabled = false
	hospital.reset()
	_scare.stop()
	_pa.stop()
	for door in doors.values():
		door.suspend(keep_burst)
	for player in _crowd:
		player.stop()


func _reset(_reason: Variant = null) -> void:
	_silence(false)
	music.reset()
	_seen.clear()
	_last_door = &""
	_neck_wait = -1.0
	_area = &""
	_hushed = false
	_active = not _disabled
	decoy.enabled = _active
	for door in doors.values():
		door._reset()
		door.enabled = _active


func stop_emitting() -> void:
	_disabled = true
	_reset()
