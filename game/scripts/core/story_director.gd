extends Node
## Story flow for segments 1–2 (T-117, docs/design/RULES.md §5):
## 23:50 back to room 407 → 23:59 phone → 00:00 speaker reads the 5 rules
## (rule 3 garbled) → rule 1 judged → 00:10 knocking → rule 2 judged →
## consequences → end of the prototype slice.
##
## Optional collaborators are found by path and may be missing until their lane
## delivers: the phone (T-129), the Speaker (T-130). Without them the director
## falls back to subtitles and timers. Owner: integrator.

signal slice_finished

const RULE_SET_PATH := "res://data/rules/demo.tres"
const ROOM_407_X := Vector2(30.0, 34.0)
## Speaker lines: [text_key, rule_id, garbled]. Rule 3's action is lost in static.
const ANNOUNCEMENT: Array = [
	["RULE_HEADER_5", &"", false],
	["RULE_1", &"lights_genuine", false],
	["RULE_2", &"knock_genuine", false],
	["RULE_3_GARBLED", &"slippers_genuine", true],
	["RULE_4", &"rollcall_self_genuine", false],
	["RULE_5", &"tap_genuine", false],
]

## Multiplies every wait; tests use a small value.
@export var time_scale: float = 1.0
@export var auto_start: bool = true
@export var player_path: NodePath = ^"../Player"
@export var floor_path: NodePath = ^"../Floor4"
@export var phone_path: NodePath = ^""
@export var speaker_path: NodePath = ^""
## Seconds per announcement line while there is no voice yet (subtitles only).
@export var line_seconds: float = 4.0
@export var segment1_max_seconds: float = 90.0
@export var phone_max_seconds: float = 20.0
@export var knock_rounds: int = 3
@export var knock_gap_seconds: float = 4.0
@export var knock_silence_seconds: float = 20.0

## Seconds the room light stays dark after the rule-1 cut-out.
@export var room_light_dark_seconds: float = 4.0
## Steps of the visitor walking away after the door was opened (rule 2).
@export var walk_away_steps: int = 10
@export var walk_away_step_seconds: float = 0.55
## Max wait for the player to close the door before the fifth pair appears anyway.
@export var slippers_max_wait_seconds: float = 20.0

var finished: bool = false
var _door_opened_during_knock: bool = false
var _pending_slippers: bool = false

@onready var _player: Node3D = get_node_or_null(player_path)
@onready var _floor: Node3D = get_node_or_null(floor_path)


func _ready() -> void:
	EventBus.consequence_triggered.connect(_on_consequence)
	if auto_start:
		start.call_deferred()


func start() -> void:
	var errors := RuleSystem.load_rule_set(load(RULE_SET_PATH))
	if not errors.is_empty():
		push_warning("StoryDirector: demo rules invalid: %s" % ", ".join(errors))
		return
	GameState.reset()
	GameState.set_time(GameState.START_MINUTES)
	await _segment_1()
	await _segment_2()
	_finish()


# --- Segment 1: 23:50, tutorial -------------------------------------------

func _segment_1() -> void:
	GameState.set_segment(&"seg1")
	Checkpoint.save(&"seg1_start")
	_say("SUB_SEG1_GO_ROOM", 6.0)
	await _wait_until(func() -> bool: return _player_in_room(), segment1_max_seconds)
	_say("SUB_SEG1_READ_PAPER", 6.0)
	await _wait_until(func() -> bool: return GameState.get_flag(&"door_locked", false) == true,
		segment1_max_seconds)
	GameState.set_time(23 * 60 + 59)
	var phone := get_node_or_null(phone_path)
	if phone != null and phone.has_method("ring"):
		phone.ring()
		await _wait_until(func() -> bool: return GameState.get_flag(&"phone_checked", false) == true,
			phone_max_seconds)
	else:
		_say("SUB_PHONE_MIDNIGHT", 4.0)
		await _wait(4.0)


# --- Segment 2: 00:00, rules over the speaker, first rulings -----------------

func _segment_2() -> void:
	GameState.set_time(24 * 60)
	GameState.set_segment(&"seg2")
	Checkpoint.save(&"seg2_start")
	await _announce_rules()
	RuleSystem.resolve(&"lights_out", &"turn_off_main_light" if not _main_light_on() else &"left_on")
	await _wait(6.0)
	GameState.set_time(24 * 60 + 10)
	await _knocking()


func _announce_rules() -> void:
	for line in ANNOUNCEMENT:
		var rule_id: StringName = line[1]
		if not rule_id.is_empty():
			RuleSystem.mark_read(rule_id, &"speaker", line[0])
	var speaker := get_node_or_null(speaker_path)
	if speaker != null and speaker.has_method("play_announcement"):
		var lines: Array = ANNOUNCEMENT.map(func(line: Array) -> Dictionary:
			return {"text_key": line[0], "garbled": line[2]})
		speaker.play_announcement(lines, line_seconds * time_scale)
		await speaker.announcement_finished
	else:
		for line in ANNOUNCEMENT:
			_say(line[0], line_seconds)
		await _wait(line_seconds * ANNOUNCEMENT.size())


func _knocking() -> void:
	var door := _door()
	_door_opened_during_knock = false
	for round_index in knock_rounds:
		_play_knock(round_index)
		_say("SUB_KNOCK", 3.0)
		# Each round waits a little longer: the knocker is patient.
		await _wait_until(func() -> bool: return _door_is_open(door), knock_gap_seconds * (1.0 + round_index * 0.5))
		if _door_is_open(door):
			_door_opened_during_knock = true
			break
	if not _door_opened_during_knock:
		await _wait_until(func() -> bool: return _door_is_open(door), knock_silence_seconds)
		_door_opened_during_knock = _door_is_open(door)
	var action := &"open_door" if _door_opened_during_knock else &"stay_silent"
	if action == &"stay_silent":
		_say("SUB_KNOCK_STOPPED", 4.0)
	RuleSystem.resolve(&"knock_at_door", action)
	if _pending_slippers:
		await _slippers_aftermath()
	await _wait(4.0)


func _finish() -> void:
	finished = true
	_say("SUB_SLICE_END", 30.0)
	slice_finished.emit()


# --- Consequences (D-024: clear and unsettling, no jump scares in segments 1–2) ---

func _on_consequence(consequence: StringName, _rule_id: StringName) -> void:
	match consequence:
		&"corridor_light_flicker":
			_play_sting()
			_flicker_corridor_light()
			_room_light_cutout()
		&"extra_slippers":
			_play_sting()
			_pending_slippers = true
			_walk_away()


func _flicker_corridor_light() -> void:
	var light := _floor.get_node_or_null("Corridor/CorridorLight_407") as Light3D if _floor else null
	if light == null:
		return
	var hum := light.get_node_or_null("LightHum")
	if hum != null and hum.has_method("flicker"):
		hum.flicker(1.5)
	var base_energy := light.light_energy
	var tween := create_tween()
	for i in 6:
		tween.tween_property(light, "light_energy", base_energy * 0.15, 0.06)
		tween.tween_property(light, "light_energy", base_energy, 0.09 + 0.05 * (i % 2))
	GameState.set_flag(&"corridor_light_flickering", true)


## Rule 1 broken: the room's own tube stutters and dies, its hum cut with it,
## then comes back after a few silent seconds.
func _room_light_cutout() -> void:
	var light := _floor.get_node_or_null("Room407/Room407MainLight") as Light3D if _floor else null
	if light == null or not light.visible:
		return
	for i in 5:
		light.visible = false
		await _wait_real(0.05 + 0.04 * (i % 3))
		light.visible = true
		await _wait_real(0.08 + 0.05 * (i % 2))
	_play_at(&"tube_cut", light)
	light.visible = false
	GameState.set_flag(&"room_light_cut", true)
	await _wait(room_light_dark_seconds)
	light.visible = true


## Rule 2 broken: the empty corridor answers with slippers walking away west.
func _walk_away() -> void:
	var door := _door() as Node3D
	if door == null or _floor == null:
		return
	GameState.set_flag(&"visitor_walked_away", true)
	var steps := AudioStreamPlayer3D.new()
	steps.name = "VisitorSteps"
	steps.bus = &"SFX"
	# Lane E's slipper takes are mastered very quiet for the player (D-019);
	# the visitor must be heard from inside the room.
	steps.volume_db = 20.0
	_floor.add_child(steps)
	steps.global_position = door.global_position + Vector3(-0.4, 0.1, 1.2)
	for i in walk_away_steps:
		var clip := _load_sfx("slipper_tile_%02d" % ((i % 4) + 1))
		if clip != null:
			steps.stream = clip
			steps.play()
		await _wait(walk_away_step_seconds)
		if not is_instance_valid(steps):
			return
		steps.global_position += Vector3(-0.9, 0, 0)
	steps.queue_free()


## After the door was opened: once it is shut again (or after a while), a pair
## of slippers is set down outside and the fifth pair is there for good.
func _slippers_aftermath() -> void:
	var door := _door()
	await _wait_until(func() -> bool: return not _door_is_open(door), slippers_max_wait_seconds)
	await _wait(1.5)
	var anchor := _floor.get_node_or_null("Anchors/Slippers407") as Node3D if _floor else null
	if anchor != null:
		_play_at(&"slipper_place", anchor)
	_place_fifth_slippers()
	_pending_slippers = false


## A fifth pair of slippers outside room 407 (placeholder boxes until lane B
## models slippers). Kept in Anchors/Slippers407 so it survives into later segments.
func _place_fifth_slippers() -> void:
	var anchor := _floor.get_node_or_null("Anchors/Slippers407") as Node3D if _floor else null
	if anchor == null or anchor.has_node("FifthPair"):
		return
	var pair := Node3D.new()
	pair.name = "FifthPair"
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.55, 0.09, 0.07)
	for side in [-0.06, 0.06]:
		var sole := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.09, 0.025, 0.26)
		mesh.material = material
		sole.mesh = mesh
		sole.position = Vector3(side, 0.0125, 0.0)
		pair.add_child(sole)
	pair.position = Vector3(0.45, 0.0, 0.0)
	anchor.add_child(pair)
	GameState.set_flag(&"fifth_slippers", true)


# --- Helpers ------------------------------------------------------------------

func _say(text_key: String, seconds: float) -> void:
	EventBus.subtitle_requested.emit(text_key, maxf(seconds * time_scale, 0.05))


func _wait(seconds: float) -> void:
	await get_tree().create_timer(maxf(seconds * time_scale, 0.0), false).timeout


## Waits until condition() is true or max_seconds pass (scaled). Pausable.
func _wait_until(condition: Callable, max_seconds: float) -> void:
	var limit := maxf(max_seconds * time_scale, 0.0)
	var elapsed := 0.0
	while not condition.call() and elapsed < limit:
		await get_tree().process_frame
		if not get_tree().paused:
			elapsed += get_process_delta_time()


func _player_in_room() -> bool:
	if _player == null:
		return true
	var p := _player.global_position
	return p.x > ROOM_407_X.x and p.x < ROOM_407_X.y and p.z < -0.3


func _main_light_on() -> bool:
	var light := _floor.get_node_or_null("Room407/Room407MainLight") as Light3D if _floor else null
	return light != null and light.is_visible_in_tree()


func _door() -> Node:
	return _floor.get_node_or_null("Door407") if _floor else null


func _door_is_open(door: Node) -> bool:
	return door != null and door.get("is_open") == true


func _wait_real(seconds: float) -> void:
	# Flicker timing is about perception; it does not follow time_scale.
	await get_tree().create_timer(seconds * minf(time_scale, 1.0), false).timeout


func _load_sfx(file_name: StringName) -> AudioStream:
	var path := "res://audio/sfx/%s.ogg" % file_name
	return load(path) if ResourceLoader.exists(path) else null


## Non-positional mistake cue (lane E T-131); silent until the asset exists.
func _play_sting() -> void:
	var clip := _load_sfx(&"sting_low")
	if clip == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = clip
	player.bus = &"SFX"
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func _play_at(file_name: StringName, where: Node3D) -> void:
	var clip := _load_sfx(file_name)
	if clip == null or where == null:
		return
	var player := AudioStreamPlayer3D.new()
	player.stream = clip
	player.bus = &"SFX"
	where.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func _play_knock(round_index: int) -> void:
	var door := _door()
	if door == null:
		return
	var stream := load("res://audio/sfx/knock_%02d.ogg" % (mini(round_index, 2) + 1)) \
		if ResourceLoader.exists("res://audio/sfx/knock_%02d.ogg" % (mini(round_index, 2) + 1)) else null
	if stream == null:
		return
	var player := AudioStreamPlayer3D.new()
	player.stream = stream
	player.bus = &"SFX"
	door.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
