extends Node
## Story flow of the demo night (docs/design/RULES.md §5, §5b, §6):
##   seg1 23:50 back to room 407 → seg2 00:00 speaker rules, knocking →
##   seg3 00:30 duty log, slippers behind you → seg4 01:00 roll call →
##   seg5 01:20 washroom tap and mirror → end 01:40 last roll call.
## Each segment starts with a checkpoint. A real loss asks Main to reload the
## scene and resume from that checkpoint (restart_requested).
##
## Optional collaborators may be missing (tests, older scenes): phone (T-129),
## Speaker (T-130), mirror (T-135). The director then falls back to subtitles
## and timers. The pursuer (T-134) and silhouette (T-135) are created here.
## Owner: integrator.

signal slice_finished
## A real loss: Main reloads the scene and calls resume from this checkpoint.
signal restart_requested(checkpoint_id: StringName)

const RULE_SET_PATH := "res://data/rules/demo.tres"
const SEGMENTS: Array[StringName] = [&"seg1", &"seg2", &"seg3", &"seg4", &"seg5", &"end"]
const ROOM_407_X := Vector2(30.0, 34.0)
const WASHROOM_MAX_X := 6.0
const PURSUER := preload("res://scenes/entity/pursuer.tscn")
const SILHOUETTE := preload("res://scenes/levels/entity/silhouette.tscn")
## Chase safe zones (RULES.md §5b) use their own physics layer 8 so the
## interaction ray (layers 1 and 3) never hits them.
const SAFE_ZONE_LAYER := 1 << 7
## Chase 1 ends where the corridor is still lit: west of light 406.
const LIT_CORRIDOR_MAX_X := 26.0
## Chase 2 starts at the washroom doorway (x 2.6–3.6), corridor side, because
## the pursuer does not path-find through doors (T-134 handoff).
const WASHROOM_DOOR := Vector3(3.1, 0.03, 0.6)
## Corridor lights that die behind each chase, in the order the pursuer passes them.
const CHASE_1_LIGHTS: Array[String] = ["CorridorLight_Desk", "CorridorLight_408", "CorridorLight_407", "CorridorLight_406"]
const CHASE_2_LIGHTS: Array[String] = ["CorridorLight_401", "CorridorLight_402", "CorridorLight_403",
	"CorridorLight_404", "CorridorLight_405", "CorridorLight_406"]
## Speaker lines: [text_key, rule_id, garbled]. Rule 3's action is lost in static.
const ANNOUNCEMENT: Array = [
	["RULE_HEADER_5", &"", false],
	["RULE_1", &"lights_genuine", false],
	["RULE_2", &"knock_genuine", false],
	["RULE_3_GARBLED", &"slippers_genuine", true],
	["RULE_4", &"rollcall_self_genuine", false],
	["RULE_5", &"tap_genuine", false],
]
## Roll call order (RULES.md §5 seg4): [speaker key, situation, net node].
const ROLL_CALL: Array = [
	["SPK_NAME_PHUC", &"roll_call_roommate", "BunkA/Net_Phuc"],
	["SPK_NAME_VIET", &"roll_call_roommate", "BunkA/Net_Viet"],
	["SPK_NAME_TRUNG", &"roll_call_self", ""],
	["SPK_NAME_DAT", &"roll_call_roommate", "BunkB/Net_Dat"],
	["SPK_NAME_LAM", &"roll_call_fifth", ""],
]

## Checkpoint to resume after a reload; kept across the scene change.
static var resume_checkpoint: StringName = &""
## Deviation earned by being caught; added back after the reload (§5b).
static var carry_deviation: int = 0

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
@export var room_light_dark_seconds: float = 4.0
@export var walk_away_steps: int = 10
@export var walk_away_step_seconds: float = 0.55
@export var slippers_max_wait_seconds: float = 20.0
## Segment 3: how long to wait for the log, how long standing still counts as
## stopping, and the overall limit of the slippers-behind-you moment.
@export var duty_log_max_seconds: float = 240.0
@export var footsteps_still_seconds: float = 8.0
@export var footsteps_max_seconds: float = 120.0
## Segment 5: how long looking at the mirror counts as "looking", and limits.
@export var mirror_look_seconds: float = 1.0
@export var washroom_max_seconds: float = 240.0
@export var end_wait_seconds: float = 60.0
## Seconds the player has to leave the washroom once the reflection stares.
@export var mirror_flee_seconds: float = 5.0
@export var mirror_path: NodePath = ^"../Floor4/Washroom/Mirror"
## Stop after this segment (tests run one stretch of the night). Empty = to the end.
@export var stop_after: StringName = &""

## [accessibility] reduce_scares (docs/SETTINGS.md, D-024).
var reduce_scares: bool = false
var finished: bool = false
var _door_opened_during_knock: bool = false
var _pending_slippers: bool = false
var _failing: bool = false
var _roll_call_active: bool = false
var _current_name: String = ""
var _answered: Dictionary[String, bool] = {}
var _tap_closed: bool = false
## Own name met with silence: the speaker calls it once more before judging.
var _recall_pending: bool = false
var _flicker_timer: Timer
var _overlay: ColorRect
var _overlay_label: Label
var _overlay_why: Label
var _pursuer: Pursuer
var _chase_result: StringName = &""
var _gaze: GazeDetector
var _gazed: bool = false
var _lit_zone: Area3D
var _room_zone: Area3D

@onready var _player: Node3D = get_node_or_null(player_path)
@onready var _floor: Node3D = get_node_or_null(floor_path)


func _ready() -> void:
	EventBus.consequence_triggered.connect(_on_consequence)
	EventBus.settings_changed.connect(_on_settings_changed)
	EventBus.deviation_changed.connect(_on_deviation_changed)
	EventBus.player_failed.connect(_on_player_failed)
	EventBus.document_opened.connect(_on_document_opened)
	EventBus.subtitle_requested.connect(_on_subtitle)
	_read_reduce_scares()
	_build_overlay()
	_build_chase()
	if auto_start:
		start.call_deferred()


## Starts the night, or resumes from resume_checkpoint after a reload.
func start() -> void:
	var errors := RuleSystem.load_rule_set(load(RULE_SET_PATH))
	if not errors.is_empty():
		push_warning("StoryDirector: demo rules invalid: %s" % ", ".join(errors))
		return
	var from := &"seg1"
	if not resume_checkpoint.is_empty():
		var restored := Checkpoint.restore()
		resume_checkpoint = &""
		if not restored.is_empty():
			from = StringName(String(restored).trim_suffix("_start"))
			_place_player_at(restored)
			# Never let the carried penalty alone reach the losing level.
			var carry := mini(carry_deviation, GameState.MAX_DEVIATION - 1 - GameState.deviation)
			if carry > 0:
				GameState.add_deviation(carry, &"caught")
		carry_deviation = 0
	else:
		GameState.reset()
		GameState.set_time(GameState.START_MINUTES)
	apply_world_state()
	await run_from(from)


## Runs the night from a segment id in SEGMENTS (tests start mid-night too).
func run_from(segment: StringName) -> void:
	var index := SEGMENTS.find(segment)
	if index < 0:
		push_warning("StoryDirector: unknown segment '%s'" % segment)
		return
	for i in range(index, SEGMENTS.size()):
		if _failing or not is_inside_tree():
			return
		match SEGMENTS[i]:
			&"seg1": await _segment_1()
			&"seg2": await _segment_2()
			&"seg3": await _segment_3()
			&"seg4": await _segment_4()
			&"seg5": await _segment_5()
			&"end": await _ending()
		if SEGMENTS[i] == stop_after:
			break
	if not _failing and is_inside_tree():
		finished = true
		slice_finished.emit()


func _begin_segment(segment: StringName, minutes: int) -> void:
	GameState.set_segment(segment)
	GameState.set_time(minutes)
	Checkpoint.save(StringName(String(segment) + "_start"))


# --- Segment 1: 23:50, tutorial -------------------------------------------

func _segment_1() -> void:
	_begin_segment(&"seg1", GameState.START_MINUTES)
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
	_begin_segment(&"seg2", 24 * 60)
	for line in ANNOUNCEMENT:
		var rule_id: StringName = line[1]
		if not rule_id.is_empty():
			RuleSystem.mark_read(rule_id, &"speaker", line[0])
	await _announce(ANNOUNCEMENT.map(func(line: Array) -> Dictionary:
		return {"text_key": line[0], "garbled": line[2]}))
	RuleSystem.resolve(&"lights_out", &"turn_off_main_light" if not _main_light_on() else &"left_on")
	await _wait(6.0)
	GameState.set_time(24 * 60 + 10)
	await _knocking()


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


# --- Segment 3: 00:30, duty log, slippers behind you ------------------------

func _segment_3() -> void:
	_begin_segment(&"seg3", 24 * 60 + 30)
	await _announce([{"text_key": "SPK_SIGN_LOG", "garbled": false}])
	await _wait_until(func() -> bool: return GameState.get_flag(&"read_duty_log", false) == true,
		duty_log_max_seconds)
	GameState.set_flag(&"signed_log", true)
	await _wait_until(func() -> bool: return _player == null or _player.global_position.x < 37.5, 30.0)
	await _footsteps_behind()


## Slippers follow a few metres behind. Rule 3 (genuine): don't turn around,
## keep walking to the light. The fake copy says: stop, turn and greet them.
func _footsteps_behind() -> void:
	if _player == null or _floor == null:
		RuleSystem.resolve(&"footsteps_behind", &"keep_walking")
		return
	_say("SUB_FOOTSTEPS_BEHIND", 4.0)
	var follower := AudioStreamPlayer3D.new()
	follower.name = "FollowerSteps"
	follower.bus = &"SFX"
	follower.volume_db = 20.0
	_floor.add_child(follower)
	var distance := 3.5
	_watch(follower, 50.0, 0.3)
	var still := 0.0
	var elapsed := 0.0
	var step_clock := 0.0
	var step_index := 0
	var action := &"keep_walking"
	while is_inside_tree() and not _failing:
		await get_tree().process_frame
		if get_tree().paused:
			continue
		var delta := get_process_delta_time()
		elapsed += delta
		var speed := Vector2((_player as CharacterBody3D).velocity.x, (_player as CharacterBody3D).velocity.z).length() \
			if _player is CharacterBody3D else 1.0
		still = still + delta if speed < 0.2 else 0.0
		# Standing still lets the slippers close in.
		distance = maxf(1.2, distance - delta * (0.35 if speed < 0.2 else 0.0))
		follower.global_position = Vector3(minf(_player.global_position.x + distance, 43.0), 0.1, 1.2)
		step_clock += delta
		if step_clock >= 0.6:
			step_clock = 0.0
			var clip := _load_sfx("slipper_tile_%02d" % ((step_index % 4) + 1))
			step_index += 1
			if clip != null:
				follower.stream = clip
				follower.play()
		if _gazed:
			action = &"turn_around"
			break
		if _player_in_room():
			action = &"keep_walking"
			break
		if still >= footsteps_still_seconds * time_scale:
			action = &"stop_and_wait"
			break
		if elapsed >= footsteps_max_seconds * time_scale:
			break
	_unwatch()
	var spawn := follower.global_position
	follower.queue_free()
	GameState.set_flag(&"footsteps_resolved", true)
	RuleSystem.resolve(&"footsteps_behind", action)
	if action == &"turn_around" and not _failing:
		await _chase_1(spawn)
	await _wait(3.0)


## Chase 1 (§5b): a glimpse of the figure where the slippers were, then it
## comes. Safe: the corridor that is still lit, or room 407 latched.
func _chase_1(spawn: Vector3) -> void:
	spawn.y = 0.03
	_play_scare_sting()
	_say("SUB_RUN_TO_LIGHT", 4.0)
	await _run_chase(spawn, CHASE_1_LIGHTS, true, 0.6)


# --- Segment 4: 01:00, roll call ----------------------------------------------

func _segment_4() -> void:
	# The handwritten note is on the board from now on (part of the checkpoint).
	GameState.set_flag(&"note_on_board", true)
	apply_world_state()
	_begin_segment(&"seg4", 25 * 60)
	await _wait(6.0)
	_say("SUB_ROLLCALL_HINT", 6.0)
	_answered.clear()
	_roll_call_active = true
	var lines: Array = [{"text_key": "SPK_ROLLCALL_INTRO", "garbled": false}]
	for entry in ROLL_CALL:
		lines.append({"text_key": entry[0], "garbled": false})
	_recall_pending = false
	await _announce(lines)
	if _recall_pending and not _failing:
		# RULES.md §5 seg4: silence on your own name gets it read again, slower.
		_recall_pending = false
		await _announce([{"text_key": "SPK_NAME_TRUNG_AGAIN", "garbled": false}])
	_roll_call_active = false
	if _failing:
		return
	await _wait(3.0)


## Called whenever a subtitle line starts: the roll call judges the previous
## name when the next line begins, so answers count only while a name is read.
func _on_subtitle(text_key: String, _duration: float) -> void:
	# Only speaker lines (SPK_*) open or close a name window; "You: Here!" and
	# hints must not.
	if not _roll_call_active or (not text_key.is_empty() and not text_key.begins_with("SPK_")):
		return
	if not _current_name.is_empty():
		_judge_name(_current_name)
	_current_name = text_key if text_key.begins_with("SPK_NAME_") else ""


func _judge_name(name_key: String) -> void:
	var answered_now: bool = _answered.get(name_key, false)
	if name_key == "SPK_NAME_TRUNG" and not answered_now:
		_recall_pending = true
		return
	if name_key == "SPK_NAME_TRUNG_AGAIN":
		RuleSystem.resolve(&"roll_call_self", &"answer" if answered_now else &"stay_silent")
		return
	for entry in ROLL_CALL:
		if entry[0] != name_key:
			continue
		var answered: bool = _answered.get(name_key, false)
		var situation: StringName = entry[1]
		var action := &"answer" if answered else &"stay_silent"
		var result := RuleSystem.resolve(situation, action)
		if result["consequence"] == &"net_stirs":
			_stir_net(entry[2])


func _input(event: InputEvent) -> void:
	if not _roll_call_active or _current_name.is_empty() or get_tree().paused:
		return
	if event.is_action_pressed("interact") and not event.is_echo():
		if not _answered.get(_current_name, false):
			_answered[_current_name] = true
			EventBus.subtitle_requested.emit("SUB_YOU_ANSWER", 1.5)


# --- Segment 5: 01:20, washroom tap and mirror --------------------------------

func _segment_5() -> void:
	_begin_segment(&"seg5", 25 * 60 + 20)
	await _announce([{"text_key": "SPK_CHECK_TAPS", "garbled": false}])
	var tap := _floor.get_node_or_null("Anchors/WashroomTapRunning/TapTrigger") as StoryTrigger if _floor else null
	GameState.set_flag(&"tap_running", true)
	var water := _start_running_water()
	_tap_closed = false
	if tap != null:
		tap.enabled = true
		tap.triggered.connect(func() -> void:
			_tap_closed = true
			tap.enabled = false
			if is_instance_valid(water):
				water.queue_free()
			GameState.set_flag(&"tap_running", false), CONNECT_ONE_SHOT)
	await _wait_until(func() -> bool: return _player_in_washroom(), washroom_max_seconds)
	GameState.set_time(25 * 60 + 30)
	var elapsed := 0.0
	var action := &""
	var mirror := _mirror()
	var look_target: Node3D = mirror if mirror != null else _anchor("WashroomMirror")
	if mirror != null:
		mirror.release()
	_watch(look_target, 25.0, mirror_look_seconds)
	while is_inside_tree() and not _failing and action.is_empty():
		await get_tree().process_frame
		if get_tree().paused:
			continue
		elapsed += get_process_delta_time()
		if _gazed and not _player_in_washroom():
			# Looked from the doorway or the corridor: does not count.
			_watch(look_target, 25.0, mirror_look_seconds)
		elif _gazed:
			action = &"look_in_mirror"
		elif not _player_in_washroom():
			action = &"close_tap_and_leave" if _tap_closed else &"leave_tap_running"
		elif elapsed >= washroom_max_seconds * time_scale:
			action = &"close_tap_and_leave" if _tap_closed else &"leave_tap_running"
	_unwatch()
	RuleSystem.resolve(&"tap_running", action)
	if action == &"look_in_mirror" and not _failing:
		await _chase_2(mirror)
	await _wait(3.0)


## Chase 2 (§5b): the reflection lags, turns to stare, steps out of the
## glass. Freeze and it takes you; run and it follows you to room 407.
func _chase_2(mirror: Node3D) -> void:
	if mirror != null:
		mirror.set_lag(0.5)
	await _wait_real(1.4)
	var figure: Node3D = null
	if not reduce_scares and mirror != null:
		mirror.stare()
	_play_scare_sting()
	if mirror != null and _floor != null:
		figure = SILHOUETTE.instantiate()
		figure.name = "MirrorFigure"
		_floor.add_child(figure)
		figure.global_position = mirror.step_out()
		var face := Vector3(_player.global_position.x, figure.global_position.y, _player.global_position.z)
		if face.distance_to(figure.global_position) > 0.05:
			figure.look_at(face, Vector3.UP)
		figure.set_visible_amount(0.0)
		figure.create_tween().tween_method(figure.set_visible_amount, 0.0, 1.0, 2.0 if reduce_scares else 0.25)
	_say("SUB_RUN_TO_ROOM", 4.0)
	var player_out := func() -> bool:
		return not _player_in_washroom() and _player.global_position.distance_to(WASHROOM_DOOR) >= 2.0
	# Real seconds, like the chase itself (_wait_until scales by time_scale).
	await _wait_until(player_out, mirror_flee_seconds / maxf(time_scale, 0.0001))
	if is_instance_valid(figure):
		figure.queue_free()
	if mirror != null:
		mirror.release()
	if _failing:
		return
	if _player_in_washroom():
		await _lose(&"SUB_CAUGHT", 1)
		return
	await _run_chase(WASHROOM_DOOR, CHASE_2_LIGHTS, false, 0.0)


# --- Chases (T-134 pursuer) ------------------------------------------------------

## Runs one chase until the pursuer catches the player or gives up. The lights
## listed die as the pursuer passes them and come back afterwards.
func _run_chase(spawn: Vector3, lights: Array[String], lit_corridor_safe: bool, hold_seconds: float) -> void:
	if _pursuer == null or _player == null or not _pursuer.is_inside_tree():
		return
	_lit_zone.monitoring = lit_corridor_safe
	_room_zone.monitoring = GameState.get_flag(&"door_locked", false) == true
	_chase_result = &""
	_pursuer.start_chase(_player, spawn)
	var figure := _pursuer_figure()
	if figure != null and reduce_scares:
		figure.set_visible_amount(0.0)
		figure.create_tween().tween_method(figure.set_visible_amount, 0.0, 1.0, 1.5)
	# A short glimpse before it moves.
	var base_speed := _pursuer.speed
	if hold_seconds > 0.0:
		_pursuer.speed = 0.0
		await _wait_real(hold_seconds)
		_pursuer.speed = base_speed
	var east_to_west := spawn.x > _player.global_position.x
	while is_inside_tree() and not _failing and _chase_result.is_empty():
		await get_tree().physics_frame
		var locked: bool = GameState.get_flag(&"door_locked", false) == true
		if _room_zone.monitoring != locked:
			_room_zone.set_deferred("monitoring", locked)
		for light_name in lights:
			var light := _floor.get_node_or_null("Corridor/" + light_name) as Light3D
			if light == null or not light.visible:
				continue
			var behind := light.global_position.x > _pursuer.global_position.x + 1.0 if east_to_west \
				else light.global_position.x < _pursuer.global_position.x - 1.0
			if behind:
				_play_at(&"tube_cut", light)
				light.visible = false
	_pursuer.speed = base_speed
	_lit_zone.set_deferred("monitoring", false)
	_room_zone.set_deferred("monitoring", false)
	if _chase_result == &"caught":
		await _lose(&"SUB_CAUGHT", 1)
		return
	GameState.set_flag(&"chase_escaped", true)
	for light_name in lights:
		var light := _floor.get_node_or_null("Corridor/" + light_name) as Light3D
		if light != null:
			light.visible = true
	apply_world_state()


func _pursuer_figure() -> Node:
	if _pursuer == null:
		return null
	for child in _pursuer.get_node("Body/Visual").get_children():
		if child.has_method("set_visible_amount"):
			return child
	return null


func _build_chase() -> void:
	if _floor == null:
		return
	_pursuer = PURSUER.instantiate() as Pursuer
	_pursuer.name = "Pursuer"
	_pursuer.body_scene = SILHOUETTE
	_floor.add_child.call_deferred(_pursuer)
	_pursuer.caught.connect(func() -> void: _chase_result = &"caught")
	_pursuer.escaped.connect(func() -> void: _chase_result = &"escaped")
	# Lit corridor west of light 406, and the inside of room 407.
	_lit_zone = _safe_zone("LitCorridorZone", Vector3(LIT_CORRIDOR_MAX_X / 2.0, 1.0, 1.2),
		Vector3(LIT_CORRIDOR_MAX_X, 2.0, 2.6))
	_room_zone = _safe_zone("Room407Zone", Vector3(32.2, 1.0, -2.6), Vector3(3.6, 2.0, 4.4))


func _safe_zone(zone_name: String, center: Vector3, size: Vector3) -> Area3D:
	var zone := Area3D.new()
	zone.name = zone_name
	zone.collision_layer = SAFE_ZONE_LAYER
	zone.collision_mask = 2
	zone.monitoring = false
	zone.add_to_group(&"safe_zone")
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	zone.add_child(collision)
	zone.position = center
	_floor.add_child.call_deferred(zone)
	return zone


## Arms a gaze check (T-134) from the player's camera at target.
func _watch(target: Node3D, degrees: float, seconds: float) -> void:
	_unwatch()
	_gazed = false
	var camera := get_viewport().get_camera_3d()
	if camera == null or target == null:
		return
	_gaze = GazeDetector.new()
	_gaze.camera = camera
	_gaze.target = target
	_gaze.max_angle_degrees = degrees
	_gaze.hold_seconds = seconds * minf(time_scale, 1.0)
	_gaze.gazed.connect(func() -> void: _gazed = true)
	add_child(_gaze)
	_gaze.reset()


func _unwatch() -> void:
	if is_instance_valid(_gaze):
		_gaze.queue_free()
	_gaze = null


func _mirror() -> Node3D:
	var mirror := get_node_or_null(mirror_path) as Node3D
	return mirror if mirror != null and mirror.has_method("stare") else null


## Strong sting for the D-024 scares; the soft one with reduce_scares.
func _play_scare_sting() -> void:
	var clip := _load_sfx(&"sting_low" if reduce_scares else &"sting_hit")
	if clip == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = clip
	player.bus = &"SFX"
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


# --- End: 01:40, the last roll call --------------------------------------------

func _ending() -> void:
	GameState.set_segment(&"end")
	GameState.set_time(25 * 60 + 40)
	await _wait_until(func() -> bool: return _player_in_room(), end_wait_seconds)
	var lines: Array = [{"text_key": "SPK_ROLLCALL_INTRO", "garbled": false},
		{"text_key": "SPK_NAME_PHUC", "garbled": false}, {"text_key": "SPK_NAME_VIET", "garbled": false}]
	if GameState.deviation >= 3:
		# The dorm has made up its mind: Lâm takes Trung's place.
		lines.append({"text_key": "SPK_NAME_LAM", "garbled": false})
		lines.append({"text_key": "SPK_NAME_DAT", "garbled": false})
		lines.append({"text_key": "SPK_AND_TRUNG", "garbled": true})
	else:
		lines.append({"text_key": "SPK_NAME_TRUNG", "garbled": false})
		lines.append({"text_key": "SPK_NAME_DAT", "garbled": false})
		lines.append({"text_key": "SPK_AND_ONE_MORE", "garbled": false})
	GameState.set_flag(&"ending_variant", 2 if GameState.deviation >= 3 else 1)
	await _announce(lines)
	await _fade_to_black(2.0)
	_show_card("SUB_TO_BE_CONTINUED")
	_say("SUB_FOLLOW_GAME", 600.0)


# --- Losing and resuming -------------------------------------------------------

## A real loss (Lâm answered, deviation 5): §5b scare 2, then reload.
func _on_player_failed(rule_id: StringName) -> void:
	if _failing:
		return
	var whisper := _play_at(&"whisper_co", _player, &"Voice")
	if whisper != null and reduce_scares:
		whisper.volume_db = -8.0
	# The net over the empty top bunk billows.
	_stir_net("BunkB/Net_Dat", 1.12)
	await _lose(&"SUB_FAIL", 0, &"SUB_FAIL_WHY_DEVIATION" if rule_id == &"deviation" else &"SUB_FAIL_WHY_FIFTH")


## Fades out, then asks Main to reload from the current segment's checkpoint,
## carrying `carry` deviation over the reload (being caught, §5b).
func _lose(card_key: StringName, carry: int, why_key: StringName = &"") -> void:
	if _failing:
		return
	_failing = true
	_roll_call_active = false
	_unwatch()
	if _pursuer != null and _pursuer.is_inside_tree():
		_pursuer.stop_chase()
	var checkpoint := StringName(String(GameState.segment) + "_start")
	carry_deviation = carry
	await _fade_to_black(0.4 if carry > 0 else 1.5)
	_show_card(card_key, why_key)
	await _wait(3.0 if why_key.is_empty() else 6.0)
	restart_requested.emit(checkpoint)


## Rebuilds the world from GameState (after a reload or a deviation change).
func apply_world_state() -> void:
	if _floor == null:
		return
	var level := GameState.deviation
	_set_corridor_flicker(level >= 1)
	for room in [402, 403, 404]:
		var light := _floor.get_node_or_null("Corridor/CorridorLight_%d" % room) as Light3D
		if light != null:
			light.visible = level < 2
	if level >= 3 or GameState.get_flag(&"fifth_slippers", false) == true:
		_place_fifth_slippers()
	if level >= 3:
		_place_extra_shirt()
	GameState.set_flag(&"fan_slow", level >= 4)
	var note := _floor.get_node_or_null("Anchors/HallBoardNote/HallBoardNoteReadable") as Node3D
	if note != null:
		var shown: bool = GameState.get_flag(&"note_on_board", false) == true
		note.visible = shown
		note.set("enabled", shown)


func _on_deviation_changed(level: int, _reason: StringName) -> void:
	apply_world_state()
	if level >= GameState.MAX_DEVIATION and not _failing:
		EventBus.player_failed.emit(&"deviation")


# --- Consequences (D-024) -------------------------------------------------------

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
		&"light_off_behind":
			# Chase 1 follows (_chase_1); it owns the lights and the sting.
			GameState.set_flag(&"lights_off_behind", true)
		&"footsteps_close_in":
			_play_sting()
			_play_at(&"slipper_rush_01", _player)
		&"mirror_delay":
			_say("SUB_MIRROR_LAG", 4.0)
		&"water_follows":
			_play_sting()
			_say("SUB_WATER_FOLLOWS", 4.0)
			_water_follows()


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
	var anchor := _anchor("Slippers407")
	if anchor != null:
		_play_at(&"slipper_place", anchor)
	_place_fifth_slippers()
	GameState.set_flag(&"fifth_slippers", true)
	_pending_slippers = false


func _water_follows() -> void:
	for i in 12:
		if not is_inside_tree() or _player == null:
			return
		_play_at(&"water_drip_%02d" % ((i % 3) + 1), _player)
		await _wait(1.6)


func _stir_net(path: String, amount: float = 1.04) -> void:
	var net := _floor.get_node_or_null("Room407/" + path) as Node3D if _floor and not path.is_empty() else null
	if net == null:
		return
	_play_at(&"net_billow", net)
	var base := net.scale
	var tween := create_tween()
	tween.tween_property(net, "scale", base * Vector3(amount, 1.0, amount), 0.35)
	tween.tween_property(net, "scale", base, 0.6)
	GameState.set_flag(&"net_stirred", true)


func _set_corridor_flicker(on: bool) -> void:
	if not on:
		if _flicker_timer != null:
			_flicker_timer.stop()
		return
	if _flicker_timer == null:
		_flicker_timer = Timer.new()
		_flicker_timer.one_shot = false
		add_child(_flicker_timer)
		_flicker_timer.timeout.connect(func() -> void:
			var light := _floor.get_node_or_null("Corridor/CorridorLight_405") as Light3D
			if light != null and light.visible and light.get_node_or_null("LightHum") != null:
				light.get_node("LightHum").flicker(0.6)
			_flicker_timer.wait_time = randf_range(3.0, 7.0))
	if _flicker_timer.is_stopped():
		_flicker_timer.start(randf_range(3.0, 7.0))


## A fifth pair of slippers outside room 407 (placeholder boxes until lane B
## models slippers). Kept in Anchors/Slippers407 so it survives into later segments.
func _place_fifth_slippers() -> void:
	var anchor := _anchor("Slippers407")
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


func _place_extra_shirt() -> void:
	var anchor := _anchor("ClotheslineExtraShirt")
	if anchor == null or anchor.has_node("ExtraShirt"):
		return
	var shirt := MeshInstance3D.new()
	shirt.name = "ExtraShirt"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.5, 0.65, 0.02)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.86, 0.86, 0.82)
	mesh.material = material
	shirt.mesh = mesh
	shirt.position = Vector3(0, -0.35, 0)
	anchor.add_child(shirt)


# --- Helpers ------------------------------------------------------------------

func _announce(lines: Array) -> void:
	var speaker := get_node_or_null(speaker_path)
	if speaker != null and speaker.has_method("play_announcement"):
		speaker.play_announcement(lines, line_seconds * time_scale)
		await speaker.announcement_finished
	else:
		for line in lines:
			_say(line["text_key"], line_seconds)
			await _wait(line_seconds)
	# Close the last roll-call name window.
	if _roll_call_active:
		_on_subtitle("", 0.0)


func _on_document_opened(document_id: StringName) -> void:
	GameState.set_flag(StringName("read_" + String(document_id)), true)


func _on_settings_changed(section: String, key: String) -> void:
	if section == "accessibility" and key == "reduce_scares":
		_read_reduce_scares()


func _read_reduce_scares() -> void:
	var config := ConfigFile.new()
	var value: Variant = false
	if config.load("user://settings.cfg") == OK:
		value = config.get_value("accessibility", "reduce_scares", false)
	reduce_scares = value if value is bool else false


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


func _wait_real(seconds: float) -> void:
	# Flicker timing is about perception; it does not follow time_scale.
	await get_tree().create_timer(seconds * minf(time_scale, 1.0), false).timeout


func _anchor(anchor_name: String) -> Node3D:
	return _floor.get_node_or_null("Anchors/" + anchor_name) as Node3D if _floor else null


func _place_player_at(checkpoint_id: StringName) -> void:
	var anchor := _anchor(String(checkpoint_id))
	if anchor != null and _player != null:
		_player.global_transform = anchor.global_transform


func _player_in_room() -> bool:
	if _player == null:
		return true
	var p := _player.global_position
	return p.x > ROOM_407_X.x and p.x < ROOM_407_X.y and p.z < -0.3


func _player_in_washroom() -> bool:
	return _player != null and _player.global_position.x < WASHROOM_MAX_X and _player.global_position.z < 0.0


func _main_light_on() -> bool:
	var light := _floor.get_node_or_null("Room407/Room407MainLight") as Light3D if _floor else null
	return light != null and light.is_visible_in_tree()


func _door() -> Node:
	return _floor.get_node_or_null("Door407") if _floor else null


func _door_is_open(door: Node) -> bool:
	return door != null and door.get("is_open") == true


func _load_sfx(file_name: StringName) -> AudioStream:
	var path := "res://audio/sfx/%s.ogg" % file_name
	return load(path) if ResourceLoader.exists(path) else null


## Non-positional mistake cue (lane E T-131).
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


func _play_at(file_name: StringName, where: Node, bus: StringName = &"SFX") -> AudioStreamPlayer3D:
	var clip := _load_sfx(file_name)
	if clip == null or where == null:
		return null
	var player := AudioStreamPlayer3D.new()
	player.stream = clip
	player.bus = bus
	where.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
	return player


## Placeholder running tap: a quick drip loop at the tap until it is closed.
func _start_running_water() -> Node:
	var tap := _anchor("WashroomTapRunning")
	if tap == null:
		return null
	var water := Node.new()
	water.name = "RunningWater"
	tap.add_child(water)
	_drip_loop(water, tap)
	return water


func _drip_loop(owner_node: Node, tap: Node3D) -> void:
	var index := 0
	while is_instance_valid(owner_node) and is_inside_tree():
		_play_at(&"water_drip_%02d" % ((index % 3) + 1), tap)
		index += 1
		await _wait(0.35)


func _play_knock(round_index: int) -> void:
	var door := _door()
	if door != null:
		_play_at(StringName("knock_%02d" % (mini(round_index, 2) + 1)), door)


func _build_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 18 # Above HUD (10) and reading views (15), below the pause menu (20).
	add_child(layer)
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_overlay)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(center)
	var lines := VBoxContainer.new()
	lines.add_theme_constant_override("separation", 28)
	center.add_child(lines)
	_overlay_label = Label.new()
	_overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_label.add_theme_font_size_override("font_size", 44)
	lines.add_child(_overlay_label)
	_overlay_why = Label.new()
	_overlay_why.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_overlay_why.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_overlay_why.custom_minimum_size.x = 900.0
	_overlay_why.add_theme_font_size_override("font_size", 26)
	_overlay_why.modulate = Color(1, 1, 1, 0.75)
	lines.add_child(_overlay_why)


func _fade_to_black(seconds: float) -> void:
	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, maxf(seconds * time_scale, 0.01))
	await tween.finished


## Text on the black card; why_key (optional) says what went wrong.
func _show_card(text_key: String, why_key: String = "") -> void:
	_overlay_label.text = text_key
	_overlay_why.text = why_key
