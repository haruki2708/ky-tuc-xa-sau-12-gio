class_name Chapter4Director
extends Chapter3Director
## Chapter 4 "Người sống sót", 8:30–9:00 and the ending (docs/design/CH4_DESIGN.md,
## CH4_SCRIPT.md, D-067; contract in docs/tasks/T-194-ch4-core.md): the walk to the
## library, the "Đối chiếu" underline, back to building B, up the crowded stairs,
## room 407: slats, the survivor form, the name in blood, the last message, the
## hospital. Reuses chapter 3's horde, bar, stamina, zones and voices. Lane pieces
## (T-195 A, T-196 B, T-197 D, T-198 E) plug in by name; until they merge the flow
## still runs on fallbacks (start points, no library door, no hospital room).

const CH4_RULE_SET := "res://data/rules/ch4.tres"
const CH4_STAGES: Array[StringName] = [&"split", &"library", &"return", &"room407", &"end4"]
const CH4_CHECKPOINTS := {&"split": &"ch4_split", &"library": &"ch4_library", &"return": &"ch4_return",
	&"room407": &"ch4_407"}
const CH4_DEATH_CHECKPOINTS := {&"split": &"ch4_split", &"library": &"ch4_library", &"return": &"ch4_return",
	&"room407": &"ch4_407", &"end4": &"ch4_407"}
const CH4_DEATH_KINDS := {&"DEATH_CH4_GRABBED": &"zombie_grab", &"DEATH_CH4_STAIRS": &"zombie_grab",
	&"DEATH_CH4_LIBRARY": &"zombie_grab", &"DEATH_CH4_DOOR": &"door_burst", &"DEATH_CH3_GUARD": &"guard_shock"}
const HOSPITAL_SCENE := "res://scenes/levels/hospital/hospital_room.tscn"
const BED_SLAT_SCENE := "res://scenes/interaction/bed_slat.tscn"
const FAKE_SEARCH_SCENE := "res://scenes/interaction/fake_search_spot.tscn"
const BED_CARD_SCENE := "res://ui/ch4/bed_card.tscn"
## The survivor form already matches Trung (D-067: only the name is blank).
## Lane D shows these on the survivor form (owner's choice, D-068).
const FORM_FIELDS := {&"ch4_form_sex": "Nam", &"ch4_form_age": "20", &"ch4_form_dob": "11/03/2006"}
const CH4_END_CARD_UI := "res://ui/ch4/ch4_end_card.tscn"
## D-067 numbers (CH4_DESIGN.md): how long the doors hold, the decoy phone, the last message.
const LIBRARY_DOOR_SECONDS := 75.0
const ROOM407_DOOR_SECONDS := 90.0
const PHONE_CHARGES := 3
const FINAL_MESSAGE_SECONDS := 12.0
const REDUNDANT_RULE := &"ch3_r5_2"
const TRUE_NAME := "tran trung"
const TRUE_MESSAGE := "vat giuong"
const SLAT_BEDS: Array[int] = [1, 2, 4]
const LIBRARY_WAVE := 6
## Zombies jammed on the main stairs crawl (a third slower than walking ones).
const STAIR_SPEED := 1.0
const STAIR_TURN_RADIUS := 4.0
## The crowd that comes for room 407 starts at the far end of the corridor, so
## Trung has a few seconds to shut and latch the door (offsets from the door).
const CROWD_407 := [Vector3(-12.0, 0.0, 1.6), Vector3(-13.0, 0.0, 2.6), Vector3(-14.0, 0.0, 1.4), Vector3(-15.0, 0.0, 2.4)]
const INSIDE_407 := Vector3(0.0, 0.0, -1.5)
## Building footprints (lane B coordinates; library shell from shells.tscn).
const LIBRARY_MIN := Vector3(45.0, -10.5, 195.0)
const LIBRARY_MAX := Vector3(85.0, 0.5, 225.0)
const BUILDING_B_MIN := Vector3(-5.5, -10.5, -8.2)
const BUILDING_B_MAX := Vector3(49.5, 1.5, 4.2)
## Until lane B's Ch4 start markers exist (T-196), checkpoints start here.
const FALLBACK_STARTS := {&"split": Vector3(168.5, -9.85, 32.0), &"library": Vector3(65.0, -9.85, 223.0),
	&"return": Vector3(19.25, -9.85, 1.5), &"room407": Vector3(31.0, 0.05, -2.2)}

var _first_stage: StringName = &""
var _compare_done: bool = false
var _slats: Dictionary[int, bool] = {}
var _form_ready: bool = false
var _signed: bool = false
var _message_result: StringName = &""
var _message_ok: bool = false
var _ending_kind: StringName = &""
var _door_tracks: Array[Dictionary] = []
var _doors: Dictionary[StringName, ZombieDoor] = {}
var _door_seconds: Dictionary[StringName, float] = {}
var _stair_crowd: Array[Zombie] = []
var _hospital: Node3D
var _audio: Ch4AudioRig
var _room_props_placed: bool = false


func _ready() -> void:
	super._ready()
	EventBus.ch4_sentence_marked.connect(_on_sentence_marked)
	EventBus.bed_slat_flipped.connect(_on_bed_slat_flipped)
	EventBus.blood_name_typed.connect(_on_blood_name_typed)
	EventBus.fade_message_typed.connect(_on_fade_message_typed)
	_place_ch4_uses()
	_place_ch4_audio()


func run_from(stage: StringName) -> void:
	_first_stage = stage
	await super.run_from(stage)


# --- Chapter definition ---------------------------------------------------------------

func _chapter() -> int:
	return 4


func _rule_set_path() -> String:
	return CH4_RULE_SET


func _stages() -> Array[StringName]:
	return CH4_STAGES


func _run_stage(stage: StringName) -> void:
	match stage:
		&"split": await _split()
		&"library": await _library()
		&"return": await _return()
		&"room407": await _room407()
		&"end4": await _ending_4()


func _checkpoints() -> Dictionary:
	return CH4_CHECKPOINTS


func _death_checkpoints() -> Dictionary:
	return CH4_DEATH_CHECKPOINTS


func _death_kinds() -> Dictionary:
	return CH4_DEATH_KINDS


func _on_player_caught(entity_id: StringName) -> void:
	if entity_id == &"guard":
		_die(&"DEATH_CH3_GUARD")
		return
	match GameState.segment:
		&"library": _die(&"DEATH_CH4_LIBRARY")
		&"room407", &"end4": _die(&"DEATH_CH4_DOOR")
		&"return": _die(&"DEATH_CH4_STAIRS" if _on_stairs() else &"DEATH_CH4_GRABBED")
		_: _die(&"DEATH_CH4_GRABBED")


# --- Zone 1: the canteen to the library (8:30–8:40) -----------------------------------

func _split() -> void:
	_begin(&"split", "08:30")
	_survivors(3)
	_prepare_chapter()
	_arrive_at("Ch4/Start_split", &"split")
	_audio_area(&"road")
	if _horde != null:
		_horde.place_idle(&"Road")
	_story(["chat:ngu_go", "chat:n_go"])
	_calls_after([[60.0, "chat:ngu_lecture"], [240.0, "chat:n_gym"]], &"split")
	await _wait_until(_in_library, 1800.0, false)


## Round 5 still holds; the fire door is open since chapter 3 (key used); a new
## bar (D-067) and three rings of the decoy phone (T-195 reads the flag).
func _prepare_chapter() -> void:
	GameState.chapter = _chapter()
	for field: StringName in FORM_FIELDS:
		GameState.set_flag(field, FORM_FIELDS[field])
	_has_key = true
	GameState.set_flag(&"ch3_has_key", true)
	GameState.set_flag(&"ch3_fire_door_open", true)
	if _campus != null and _campus.has_method("set_fire_door_open"):
		_campus.set_fire_door_open(true)
	var door: Ch3Use = _uses.get("FireDoor")
	if door != null:
		door.enabled = false
	if int(GameState.get_flag(&"ch4_phone_charges", -1)) < 0:
		GameState.set_flag(&"ch4_phone_charges", PHONE_CHARGES)
	var weapon: Variant = _player.get("bar_weapon") if _player != null else null
	if _player != null and _player.has_method("give_bar") and (weapon == null or int(weapon.hits_left) <= 0):
		_player.give_bar(8)


# --- Zone 2: the library (8:40–8:50) --------------------------------------------------

func _library() -> void:
	_begin(&"library", "08:40")
	_arrive_at("Ch4/Start_library", &"library")
	_audio_area(&"library")
	_compare_done = bool(GameState.get_flag(&"ch4_compare_done", false))
	_arm_door(&"library_back", LIBRARY_DOOR_SECONDS, _markers("Ch4/LibraryZombieSpawn", LIBRARY_WAVE), Vector3.ZERO)
	_door_loop(&"library")
	_calls_after([[60.0, "chat:ngu_no_exit"], [240.0, "chat:n_line"], [420.0, "chat:ngu_trung"]], &"library")
	await _wait_until(func() -> bool: return _compare_done, 3600.0, false)
	if _dying:
		return
	# Nobody says "go": the back door is about to give, the player leaves.
	await _wait_until(func() -> bool: return not _in_library(), 1800.0, false)


## The reading desk opens the rule book with its "Đối chiếu" tab (lane D).
## Lane E's chapter rig (T-198): decoy ring, door hits, scares, stair crowd, hospital,
## music. It does the voices too once the script is approved and recorded.
func _place_ch4_audio() -> void:
	if get_parent() == null:
		return
	_audio = Ch4AudioRig.new()
	_audio.name = "Ch4AudioRig"
	_audio.listener = _player
	# The scene is still setting up its children: add the rig right after.
	get_parent().add_child.call_deferred(_audio)
	_audio.set_area.call_deferred(&"road")


## Chapter 3's music stays quiet here; the ambience still follows the zone.
func _set_area(area: StringName) -> void:
	if _environment != null:
		_environment.set_area(area)


func _scare(id: StringName) -> void:
	if _audio != null and not _scared.get(id, false):
		_audio.scare_positions[id] = _scare_position(id)
	super._scare(id)


## Where a jumpscare sounds: its place when it has one, else at Trung.
func _scare_position(id: StringName) -> Vector3:
	var here := _player.global_position if _player != null else Vector3.ZERO
	var anchors := {&"librarian_rise": "Ch4/LibrarianSeat", &"books_fall": "Ch4/ScareShelf3F",
		&"shelf_corpse": "Ch4/ThrownBook3F", &"knife_pull": "ManagerKnife", &"stairs_turn": "Ch4/StairCrowd/L1_01"}
	if anchors.has(id):
		var anchor := _anchor(anchors[id])
		if anchor != null:
			return anchor.global_position
	if id == &"back_door_hit" or id == &"door_hand":
		var door := _room_door(&"library_back" if id == &"back_door_hit" else &"407")
		if door != null:
			return door.global_position
	if id == &"monitor_skip" and _audio != null and is_instance_valid(_audio.monitor_marker):
		return _audio.monitor_marker.global_position
	return here


func _audio_area(area: StringName) -> void:
	if _audio == null:
		return
	# The rig joins the scene deferred: until it is ready, set the area after.
	if _audio.is_node_ready():
		_audio.set_area(area)
	else:
		_audio.set_area.call_deferred(area)


func _place_ch4_uses() -> void:
	var desk := _ch4_use("Ch4/ReadingDesk", "PROMPT_CH4_DESK", Vector3(1.2, 0.8, 0.8))
	if desk != null:
		desk.once = false
		desk.used.connect(_open_compare)
	_place_back_door_use()
	for spot: Array in [["Ch4/MapBoard", "PROMPT_CH4_MAP", &"ch4_map"], ["Ch4/LibrarianSeat", "PROMPT_CH4_DIARY", &"ch4_diary"]]:
		var use := _ch4_use(spot[0], spot[1], Vector3(1.0, 1.2, 0.6))
		if use == null:
			continue
		use.once = false
		var document_id: StringName = spot[2]
		use.used.connect(func() -> void: EventBus.document_opened.emit(document_id))


## Like chapter 3's _use, for anchors one level down (Ch4/...): node names
## cannot hold "/".
func _ch4_use(anchor_name: String, prompt: String, size: Vector3) -> Ch3Use:
	var anchor := _anchor(anchor_name)
	if anchor == null:
		return null
	var use := Ch3Use.new()
	use.name = "Use_" + anchor_name.get_file()
	use.prompt_key = prompt
	use.size = size
	anchor.add_child(use)
	_uses[anchor_name] = use
	return use


## The library's back door is the only way in (T-196): E opens and shuts it, so
## Trung can get in and close it behind him; once broken it stays open.
func _place_back_door_use() -> void:
	var door := _room_door(&"library_back")
	if door == null:
		return
	var use := Ch3Use.new()
	use.name = "Use_BackDoor"
	use.prompt_key = "PROMPT_CH4_BACK_DOOR"
	use.size = Vector3(1.6, 2.2, 0.8)
	use.once = false
	door.add_child(use)
	use.position = Vector3(0.0, 1.1, 0.0)
	_uses["LibraryBackDoor"] = use
	use.used.connect(func() -> void:
		var adapter: ZombieDoor = _doors.get(&"library_back")
		if adapter != null and adapter.is_broken:
			return
		door.set_open(not bool(door.get("is_open"))))


func _open_compare() -> void:
	GameState.set_flag(&"ch4_compare_enabled", true)
	var notebook := get_parent().get_node_or_null("Notebook") if get_parent() != null else null
	if notebook != null and notebook.has_method("open_notebook"):
		notebook.open_notebook()


## Lane D's underline: only the redundant line of round 5 counts. A wrong pick
## costs nothing and says nothing (D-067, D-038).
func _on_sentence_marked(rule_key: StringName) -> void:
	var matched := rule_key == REDUNDANT_RULE
	if matched and not _compare_done:
		_compare_done = true
		GameState.set_flag(&"ch4_compare_done", true)
	EventBus.ch4_compare_result.emit(rule_key, matched)


# --- Zone 3: back to building B and up the stairs (8:50–8:58) -------------------------

func _return() -> void:
	_begin(&"return", "08:50")
	_arrive_at("Ch4/Start_return", &"return")
	_audio_area(&"return_b")
	if _horde != null:
		_horde.place_idle(&"Road")
	_calls_after([[120.0, "chat:n_where"]], &"return")
	await _wait_until(_in_building_b, 1800.0, false)
	if _dying:
		return
	_place_stair_crowd()
	_audio_area(&"stairs")
	# Up one floor (chapter 3's FLOOR_*_Y mark the way down; floor 2 is above floor 1's).
	await _wait_until(func() -> bool: return _player.global_position.y > FLOOR_1_Y + 0.5, 1800.0, false)
	if _dying:
		return
	_set_clock("08:56")
	await _line("n_lost")
	# The call drops for good: from here Trung is alone (the ending text is the last word).
	_network_up = false
	EventBus.phone_call_lost.emit(&"ch4_group")
	await _wait_until(func() -> bool: return _player.global_position.y > -1.0, 1800.0, false)
	if _dying:
		return
	_scare(&"hall_lights")
	await _wait_until(_player_in_room, 1800.0, false)


## Lane B's StairCrowd markers: a slow, jammed crowd on the main stairs (D-067:
## the decoy phone, the bar, or the floor-2 corridor to the fire stairs).
func _place_stair_crowd() -> void:
	_stair_crowd.clear()
	if _audio != null:
		_audio.stair_points.assign(_markers("Ch4/StairCrowd", 16))
	for marker in _markers("Ch4/StairCrowd", 16):
		var zombie := _make_zombie("zombie_%02d" % (_stair_crowd.size() % ZOMBIE_MODELS + 1))
		if zombie == null:
			return
		zombie.speed = STAIR_SPEED
		add_child(zombie)
		# Lane B turns each marker the way that zombie faces (up the stairs), so
		# they do not see Trung coming before the whole flight turns (stairs_turn).
		zombie.global_transform = marker.global_transform.translated(Vector3(0.0, 0.05, 0.0))
		zombie.set_target(_player)
		zombie.sleep_pose(&"idle")
		_stair_crowd.append(zombie)


# --- Zone 4: room 407, the form, the name in blood (8:58–9:00) ------------------------

func _room407() -> void:
	_begin(&"room407", "08:58")
	_arrive_at("Ch4/Start_407", &"room407")
	_audio_area(&"407")
	_place_room_props()
	_slats.clear()
	_form_ready = false
	_signed = false
	GameState.set_flag(&"ch4_slats_found", 0)
	var door := _room_door(&"407")
	var crowd: Array[Vector3] = []
	if door != null:
		for offset: Vector3 in CROWD_407:
			crowd.append(door.global_position + offset)
	_arm_door(&"407", ROOM407_DOOR_SECONDS, crowd, INSIDE_407)
	var adapter: ZombieDoor = _doors.get(&"407")
	if adapter != null:
		adapter.broken.connect(_on_407_broken)
	_door_loop(&"room407")
	await _wait_until(func() -> bool: return _signed, 3600.0, false)
	if _dying:
		return
	_freeze_zombies()
	_scare(&"neck_hand")
	_set_clock("09:00")
	if _audio != null and _player != null:
		_audio.play_pa_laugh(_player.global_position + Vector3(0.0, 2.0, 0.0))
	await _announce(["SPK_CH4_REGISTERED"])


## Lane A's hold-E slats (beds 1, 2, 4) and the three empty search spots on lane
## B's Room407 markers. Lane B flips its own slat models on bed_slat_flipped,
## so lane A's stand-in plank stays hidden.
func _place_room_props() -> void:
	if _room_props_placed:
		return
	_room_props_placed = true
	if ResourceLoader.exists(BED_SLAT_SCENE):
		for bed in SLAT_BEDS:
			var anchor := _anchor("Ch4/Room407/Slat%d" % bed)
			if anchor == null:
				continue
			var slat := (load(BED_SLAT_SCENE) as PackedScene).instantiate()
			slat.set("bed", bed)
			slat.name = "BedSlat%d" % bed
			anchor.add_child(slat)
			var plank := slat.get_node_or_null("SlatPivot") as Node3D
			if plank != null:
				plank.visible = false
	if ResourceLoader.exists(FAKE_SEARCH_SCENE):
		for spot in ["FakeLocker", "FakeCeiling", "FakeVent"]:
			var anchor := _anchor("Ch4/Room407/" + spot)
			if anchor != null:
				var search := (load(FAKE_SEARCH_SCENE) as PackedScene).instantiate()
				search.name = "Search" + spot.trim_prefix("Fake")
				anchor.add_child(search)


func _on_407_broken() -> void:
	if _signed or _dying:
		return
	EventBus.blood_name_closed.emit(&"timeout")
	await _wait(1.0)
	if not _signed:
		_die(&"DEATH_CH4_DOOR")


func _on_bed_slat_flipped(bed: int) -> void:
	if GameState.segment != &"room407" or not bed in SLAT_BEDS or _slats.has(bed):
		return
	_slats[bed] = true
	GameState.set_flag(&"ch4_slats_found", _slats.size())
	if _slats.size() == SLAT_BEDS.size() and not _form_ready:
		_form_ready = true
		GameState.set_flag(&"ch4_form_ready", true)
		EventBus.survivor_form_assembled.emit()
		# Lane D shows "Cắn ngón tay"; the box counts down with the door.
		EventBus.blood_name_requested.emit(_door_seconds_left(&"407"))


## The name, typed with the system IME: "Trần Trung", any case, tone marks or not.
func _on_blood_name_typed(text: String) -> void:
	if not _form_ready or _signed or _dying:
		return
	if VietText.plain(text) == TRUE_NAME:
		_signed = true
		GameState.set_flag(&"ch4_signed", true)
		EventBus.blood_name_closed.emit(&"accepted")
	else:
		EventBus.blood_name_closed.emit(&"wrong")


## The registered survivor is no target any more: every zombie crouches where it is.
func _freeze_zombies() -> void:
	var scene := get_parent()
	for node in get_tree().get_nodes_in_group(&"ch3_zombie"):
		var zombie := node as Zombie
		if zombie != null and scene != null and scene.is_ancestor_of(zombie):
			zombie.set_target(null)
			zombie.sleep_pose(&"sit")
	_door_tracks.clear()


# --- The ending (9:00) ---------------------------------------------------------------

func _ending_4() -> void:
	GameState.set_segment(&"end4")
	_set_clock("09:00")
	_message_result = &""
	EventBus.fade_message_requested.emit(FINAL_MESSAGE_SECONDS)
	await _wait_until(func() -> bool: return _message_result != &"", FINAL_MESSAGE_SECONDS)
	if _message_result == &"":
		_message_result = &"timeout"
		EventBus.fade_message_closed.emit(&"timeout")
	_ending_kind = &"all" if _message_ok else &"alone"
	GameState.set_flag(&"ch4_ending", String(_ending_kind))
	if _message_ok:
		# One last line gets through before the call is gone for good: the call
		# audio (lane E) stays silent until the signal comes back (T-200).
		_network_up = true
		EventBus.phone_call_restored.emit(&"ch4_group")
		await _line("n_got")
	await _fade_to_black(2.0)
	_show_hospital()
	EventBus.ch4_ending.emit(_ending_kind)
	await _clear_black(1.5)
	await _hospital_voice("NEAR_CH4_NURSE1_AWAKE", "Nurse1")
	await _hospital_voice("NEAR_CH4_NURSE2_QUAKE", "Nurse2")
	_scare(&"monitor_skip")
	await _hospital_voice("NEAR_CH4_NURSE1_LUCKY", "Nurse1")
	_say("SAY_CH4_TRUNG_ASK", 2.5)
	await _wait(2.5)
	await _hospital_voice("NEAR_CH4_NURSE2_ALL" if _ending_kind == &"all" else "NEAR_CH4_NURSE2_ALONE", "Nurse2")
	await _wait(2.0)
	await _fade_to_black(2.0)
	finished = true
	# Lane D's end card takes over; gameplay stops under it.
	if _player != null and _player.has_method("acquire_control_lock"):
		_player.acquire_control_lock(self)
	EventBus.chapter_finished.emit(4)


func _on_fade_message_typed(text: String) -> void:
	if GameState.segment != &"end4" or _message_result != &"":
		return
	_message_ok = VietText.plain(text).contains(TRUE_MESSAGE)
	GameState.set_flag(&"ch4_message_ok", _message_ok)
	_message_result = &"sent"
	EventBus.fade_message_closed.emit(&"sent")


## Lane B's hospital room (T-196): its wake-up camera takes over. Without it the
## ending still plays (subtitles over black), so the flow is testable early.
func _show_hospital() -> void:
	if not ResourceLoader.exists(HOSPITAL_SCENE) or get_parent() == null:
		return
	_hospital = (load(HOSPITAL_SCENE) as PackedScene).instantiate() as Node3D
	get_parent().add_child(_hospital)
	_hospital.global_position = Vector3(0.0, 300.0, 0.0)
	var camera := _hospital.get_node_or_null("Camera_Wake") as Camera3D
	if camera != null:
		camera.make_current()
	if _audio != null:
		_audio.monitor_marker = _hospital.get_node_or_null("MonitorAudio") as Node3D
	if _hospital.has_method("set_companions_visible"):
		_hospital.set_companions_visible(_ending_kind == &"all")
	# Lane D's bed cards on lane B's Card markers; they answer ch4_ending themselves.
	if ResourceLoader.exists(BED_CARD_SCENE):
		for bed in ["Bed_Trung", "Bed_Nhat", "Bed_Ngu"]:
			var mark := _hospital.get_node_or_null(bed + "/Card")
			if mark != null:
				mark.add_child((load(BED_CARD_SCENE) as PackedScene).instantiate())


func _hospital_voice(key: String, where: String) -> void:
	var anchor := _hospital.get_node_or_null(where) as Node3D if _hospital != null else null
	await _voice_at(key, anchor)


func _clear_black(seconds: float) -> void:
	if _overlay == null:
		return
	var tween := create_tween()
	tween.tween_property(_overlay, "color:a", 0.0, maxf(seconds * time_scale, 0.01))
	await tween.finished
	_overlay.visible = false


# --- Doors under attack (library back door, 407) --------------------------------------

## Attach lane A's ZombieDoor to lane B's door `room` and set `spots` zombies on
## it. `through` (from the door) is where they want to go: the far side for 407,
## the door itself for the library (they bash it from outside).
func _arm_door(room: StringName, seconds: float, spots: Array, through: Vector3) -> void:
	var door := _room_door(room)
	if door == null:
		return
	var adapter: ZombieDoor = _doors.get(room)
	if adapter == null:
		adapter = ZombieDoor.new()
		adapter.door = door
		adapter.blocker = door.get("blocker") as CollisionObject3D
		# Lane A (T-195): a fixed hold time, not each zombie's own bash time.
		adapter.set("durability_seconds", seconds)
		door.add_child(adapter)
		_doors[room] = adapter
		if _audio != null:
			_audio.register_door(room, door)
	_door_seconds[room] = seconds
	for spot in spots:
		var at: Vector3 = (spot as Node3D).global_position if spot is Node3D else spot
		var zombie := _make_zombie("zombie_%02d" % (_room_zombie_count % ZOMBIE_MODELS + 1))
		_room_zombie_count += 1
		if zombie == null:
			return
		zombie.door_bash_seconds = seconds
		add_child(zombie)
		zombie.global_position = at + Vector3(0.0, 0.05, 0.0)
		zombie.set_target(_player)
		zombie.wake()
		_door_tracks.append({"zombie": zombie, "door": adapter, "through": door.global_position + through, "room": room})


## While a door holds, its zombies aim straight through it (they slide along it
## otherwise); once it gives, they know where Trung is. Runs during `stage`.
func _door_loop(stage: StringName) -> void:
	while GameState.segment == stage and not _dying and is_inside_tree():
		await get_tree().process_frame
		if get_tree().paused or _player == null:
			continue
		for i in range(_door_tracks.size() - 1, -1, -1):
			var track: Dictionary = _door_tracks[i]
			var zombie := track["zombie"] as Zombie
			var adapter := track["door"] as ZombieDoor
			if not is_instance_valid(zombie) or not is_instance_valid(adapter):
				_door_tracks.remove_at(i)
				continue
			zombie.set("_goal", track["through"] if adapter.is_closed() else _player.global_position)
		_watch_door_scares()


func _door_seconds_left(room: StringName) -> float:
	var adapter: ZombieDoor = _doors.get(room)
	var total: float = _door_seconds.get(room, ROOM407_DOOR_SECONDS)
	if adapter == null:
		return total
	return maxf(5.0, total - adapter.damage_seconds)


func _door_fraction(room: StringName) -> float:
	var adapter: ZombieDoor = _doors.get(room)
	var total: float = _door_seconds.get(room, 0.0)
	if adapter == null or total <= 0.0:
		return 0.0
	return adapter.damage_seconds / total


func _watch_door_scares() -> void:
	if _door_fraction(&"library_back") >= 0.3:
		_scare(&"back_door_hit")
	if _door_fraction(&"407") >= 0.8:
		_scare(&"door_hand")


# --- Scares, places, helpers ---------------------------------------------------------

## Chapter 4's scares that wait for the player to come close (CH4_DESIGN.md).
func _watch_scares() -> void:
	var pos := _player.global_position
	_scare_near(&"librarian_rise", "Ch4/LibrarianSeat", 4.0, pos)
	_scare_near(&"books_fall", "Ch4/ScareShelf3F", 3.0, pos)
	_scare_near(&"shelf_corpse", "Ch4/ThrownBook3F", 2.5, pos)
	if GameState.segment == &"return":
		_scare_near(&"knife_pull", "ManagerKnife", KNIFE_RADIUS, pos)
		if not _scared.get(&"stairs_turn", false) and _scare_near(&"stairs_turn", "Ch4/StairCrowd/L1_01", STAIR_TURN_RADIUS, pos):
			for zombie in _stair_crowd:
				if is_instance_valid(zombie):
					zombie.face(pos)
					zombie.wake()


func _scare_near(id: StringName, anchor_name: String, radius: float, pos: Vector3) -> bool:
	if _scared.get(id, false):
		return false
	var anchor := _anchor(anchor_name)
	if anchor == null or pos.distance_to(anchor.global_position) > radius:
		return false
	_scare(id)
	return true


## Lines on beats after real delays, only while still in `stage`.
func _calls_after(beats: Array, stage: StringName) -> void:
	var elapsed := 0.0
	for beat: Array in beats:
		await _wait(float(beat[0]) - elapsed)
		elapsed = float(beat[0])
		if _dying or GameState.segment != stage:
			return
		_story([beat[1]])


## A checkpoint start: only when the chapter (re)starts at this stage.
func _arrive_at(anchor_name: String, stage: StringName) -> void:
	if _first_stage != stage:
		return
	var anchor := _anchor(anchor_name)
	_place_player(anchor.global_position if anchor != null else FALLBACK_STARTS[stage])


func _markers(path: String, limit: int) -> Array:
	var root := _anchor(path)
	var out: Array = []
	if root == null:
		return out
	for child in root.get_children():
		if child is Node3D and out.size() < limit:
			out.append(child)
	return out


func _in_box(low: Vector3, high: Vector3) -> bool:
	if _player == null:
		return false
	var p := _player.global_position
	return p.x >= low.x and p.x <= high.x and p.y >= low.y and p.y <= high.y and p.z >= low.z and p.z <= high.z


func _in_library() -> bool:
	return _in_box(LIBRARY_MIN, LIBRARY_MAX)


func _in_building_b() -> bool:
	return _in_box(BUILDING_B_MIN, BUILDING_B_MAX)


func _on_stairs() -> bool:
	if not _in_building_b():
		return false
	var x := _player.global_position.x
	return x < 0.3 or x > 43.7


func _place_ui() -> void:
	super._place_ui()
	var host := get_parent()
	if host != null and ResourceLoader.exists(CH4_END_CARD_UI):
		host.add_child.call_deferred((load(CH4_END_CARD_UI) as PackedScene).instantiate())
