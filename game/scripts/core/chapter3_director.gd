class_name Chapter3Director
extends Chapter1Director
## Chapter 3 "Truy sát", 8:00–8:30 (docs/design/CH3_DESIGN.md, CH3_SCRIPT.md,
## D-052…D-055): escape building B, meet Minh Nhật and Ngư, survive the
## stadium, the gate guards, the canteen TV. Lane pieces: campus (T-183),
## zombies, bar, stamina, companions, guards (T-182), UI (T-185), audio (T-186).

const CH3_RULE_SET := "res://data/rules/ch3.tres"
const CH3_STAGES: Array[StringName] = [&"b", &"garden", &"stadium", &"gate", &"end3"]
const CH3_CHECKPOINTS := {&"b": &"ch3_b", &"garden": &"ch3_garden", &"stadium": &"ch3_stadium", &"gate": &"ch3_gate"}
const CH3_DEATH_CHECKPOINTS := {&"b": &"ch3_b", &"garden": &"ch3_garden", &"stadium": &"ch3_stadium",
	&"gate": &"ch3_gate", &"end3": &"ch3_gate"}
const CH3_DEATH_KINDS := {&"DEATH_CH3_GRABBED": &"zombie_grab", &"DEATH_CH3_SURROUNDED": &"zombie_grab",
	&"DEATH_CH3_GUARD": &"guard_shock"}
const ZOMBIE_SCENE := "res://scenes/entity/zombie.tscn"
const COMPANION_SCENE := "res://scenes/entity/companion.tscn"
const GUARD_SCENE := "res://scenes/entity/guard.tscn"
const BAR_SCENE := "res://scenes/interaction/iron_bar.tscn"
const MODELS := "res://assets/models/campus/%s.tscn"
const ZOMBIE_MODELS := 10
const STATUS_UI := "res://ui/ch3/ch3_status.tscn"
const END_CARD_UI := "res://ui/ch3/ch3_end_card.tscn"
## Stadium: survive this long (scaled) while waves pour in (CH3_DESIGN.md N7).
const STADIUM_SECONDS := 240.0
const WAVE_SECONDS := 25.0
const WAVE_SIZE := 6
const ROOMMATES := {1: "zombie_01", 2: "zombie_02", 4: "zombie_03"}
const ROOMMATE_RISE_SECONDS := 4.0
const NGU_MEET_RADIUS := 4.0
const KNIFE_RADIUS := 2.2
const GUARD_TURN_RADIUS := 12.0
## Floors of building B by height (floor 4 at y = 0, 3.3 m per floor).
const FLOOR_3_Y := -2.0
const FLOOR_2_Y := -5.3
const FLOOR_1_Y := -8.6

var _campus: Node3D
var _horde: ZombieHorde
var _horde_audio: Ch3HordeAudio
var _environment: Ch3Environment
var _ch3_music: Ch3Music
var _siren: Ch3SirenAudio
var _companions: Dictionary[StringName, Node3D] = {}
var _guards: Array[Node3D] = []
var _uses: Dictionary[String, Ch3Use] = {}
var _model_index: int = 0
var _has_key: bool = false
var _alarm_sounded: bool = false
var _scared: Dictionary[StringName, bool] = {}
var _chat_queue: Array[String] = []
var _chat_running: bool = false
var _exhausted_told: bool = false


func _ready() -> void:
	_campus = get_node_or_null("../Campus") as Node3D
	super._ready()
	if _player != null:
		_player.set("stamina_enabled", true)
	EventBus.stamina_changed.connect(_on_stamina)
	_place_ui()
	_place_audio_rigs()
	_place_horde()
	_place_guards()
	_place_uses()
	_place_bars()


func _physics_process(_delta: float) -> void:
	# Round 5 lifts "never leave the room" (no super: chapter 1's room rule).
	if _dying or _player == null or _campus == null:
		return
	var zone := _zone()
	if GameState.get_flag(&"ch3_zone", "") != zone:
		GameState.set_flag(&"ch3_zone", zone)
		_on_zone(zone)
	_watch_scares()


# --- Chapter definition ---------------------------------------------------------------

func _chapter() -> int:
	return 3


func _rule_set_path() -> String:
	return CH3_RULE_SET


func _stages() -> Array[StringName]:
	return CH3_STAGES


func _run_stage(stage: StringName) -> void:
	match stage:
		&"b": await _building_b()
		&"garden": await _garden()
		&"stadium": await _stadium()
		&"gate": await _gate()
		&"end3": await _ending_3()


func _checkpoints() -> Dictionary:
	return CH3_CHECKPOINTS


func _death_checkpoints() -> Dictionary:
	return CH3_DEATH_CHECKPOINTS


func _death_kinds() -> Dictionary:
	return CH3_DEATH_KINDS


func _on_player_caught(entity_id: StringName) -> void:
	match entity_id:
		&"zombie": _die(&"DEATH_CH3_GRABBED")
		&"guard": _die(&"DEATH_CH3_GUARD")


# --- Zone 1: building B, floor 4 down to floor 1 (8:00–8:10) -------------------------

func _building_b() -> void:
	_begin(&"b", "08:00")
	_survivors(3)
	_set_area(&"stairs")
	await _announce(["SPK_CH3_R5_INTRO", "RULE_CH3_R5_1", "RULE_CH3_R5_2", "RULE_CH3_R5_3"])
	for key in ["ch3_r5_1", "ch3_r5_2", "ch3_r5_3"]:
		RuleSystem.mark_read(StringName(key))
	_set_clock("08:01")
	_think("THINK_CH3_WHO")
	_roommates_rise()
	_story(["chat:n_all_up", "chat:n_out", "chat:ngu_garden", "think:THINK_CH3_RUN"])
	if _horde != null:
		for zone in [&"B4", &"B3", &"B2", &"B1"]:
			_horde.place_idle(zone)
	# Out of 407: the corridor turns its heads (jumpscare 2), then the stairs.
	await _wait_until(func() -> bool: return not _player_in_room(), 600.0, false)
	if _dying:
		return
	_scare(&"corridor_turn")
	_wake_near(20.0)
	_spawn(&"B4", WAVE_SIZE)
	_set_clock("08:03")
	_think("THINK_CH3_STAIRS_FULL")
	# Down the fire stairs to floor 2 (the stretch to floor 1 has collapsed).
	await _wait_until(func() -> bool: return _player.global_position.y < FLOOR_3_Y, 900.0, false)
	if _dying:
		return
	_set_clock("08:05")
	_spawn(&"B3", 4)
	await _wait_until(func() -> bool: return _player.global_position.y < FLOOR_2_Y, 900.0, false)
	if _dying:
		return
	_set_clock("08:06")
	_think("THINK_CH3_COLLAPSE")
	_story(["chat:n_trapped"])
	_scare(&"door_203")
	# Minh Nhật comes out once the corridor hears something louder (D-055: no hint).
	await _wait_until(func() -> bool: return _alarm_sounded or _player.global_position.y < FLOOR_1_Y, 900.0, false)
	if _dying:
		return
	await _wait(3.0)
	_join(&"minh_nhat", "Room203Door", 0)
	_story(["near:n_join"])
	await _wait_until(func() -> bool: return _player.global_position.y < FLOOR_1_Y, 900.0, false)
	if _dying:
		return
	_set_clock("08:09")
	_spawn(&"B1", 4)
	_story(["near:n_chained"])
	# Out through the manager's window to the garden.
	await _wait_until(func() -> bool: return _zone() == "garden", 1200.0, false)


func _roommates_rise() -> void:
	_scare(&"roommates_rise")
	for bed: int in ROOMMATES:
		var anchor := _room_anchor("Corpse%d" % bed)
		if anchor == null:
			continue
		var body := anchor.get_node_or_null("Body") as Node3D
		if body != null:
			body.visible = false
		var zombie := _make_zombie(ROOMMATES[bed])
		if zombie == null:
			continue
		add_child(zombie)
		zombie.global_position = anchor.global_position + Vector3(0.0, 0.05, 0.6)
		zombie.set_target(_player)
		zombie.sleep_pose(&"lie")
		get_tree().create_timer(ROOMMATE_RISE_SECONDS * time_scale, false).timeout.connect(func() -> void:
			if is_instance_valid(zombie):
				zombie.wake())


# --- Zone 2: the garden (8:10–8:13) --------------------------------------------------

func _garden() -> void:
	_begin(&"garden", "08:10")
	_arrive("garden", "Start_garden")
	_set_area(&"garden")
	if not _companions.has(&"minh_nhat"):
		_join(&"minh_nhat", "Start_garden", _wait_index(&"minh_nhat", "garden"))
	var bench := _anchor("NguBench")
	_join(&"ngu", "NguBench", 0)
	_story(["near:ngu_here"])
	if _horde != null:
		_horde.place_idle(&"Garden")
	await _wait_until(func() -> bool:
		return bench == null or _player.global_position.distance_to(bench.global_position) < NGU_MEET_RADIUS, 600.0, false)
	if _dying:
		return
	await _near("ngu_bars")
	# Ngư hands Trung a bar unless he already picked one up.
	var weapon: Variant = _player.get("bar_weapon") if _player != null else null
	if _player != null and _player.has_method("give_bar") and (weapon == null or int(weapon.hits_left) <= 0):
		_player.give_bar(8)
	_scare(&"flowerbed_crawl")
	_spawn(&"Garden", 4)
	_set_clock("08:12")
	_story(["near:n_stadium", "near:ngu_go"])
	await _wait_until(func() -> bool: return _zone() == "stadium", 1200.0, false)


# --- Zone 3: the stadium (8:13–8:22) -------------------------------------------------

func _stadium() -> void:
	_begin(&"stadium", "08:14")
	_arrive("stadium", "Start_stadium")
	_ensure_companions("stadium")
	_set_area(&"stadium")
	_scare(&"stadium_lights")
	if _campus != null and _campus.has_method("set_stadium_lights"):
		_campus.set_stadium_lights(true)
		get_tree().create_timer(1.5 * time_scale, false).timeout.connect(func() -> void:
			if is_instance_valid(_campus):
				_campus.set_stadium_lights(false))
	if _ch3_music != null:
		_ch3_music.set_wave(true)
	_story(["near:ngu_keep"])
	var started := Time.get_ticks_msec()
	var next_wave := 0.0
	var told_breath := false
	while not _dying and is_inside_tree():
		var elapsed := float(Time.get_ticks_msec() - started) / 1000.0 / maxf(time_scale, 0.0001)
		if elapsed >= STADIUM_SECONDS:
			break
		if elapsed >= next_wave:
			next_wave += WAVE_SECONDS
			_spawn(&"Stadium", WAVE_SIZE)
		if not told_breath and elapsed >= STADIUM_SECONDS * 0.5:
			told_breath = true
			_set_clock("08:18")
			_story(["near:n_breath"])
		_siren_check()
		await get_tree().process_frame
	if _dying:
		return
	if _ch3_music != null:
		_ch3_music.set_wave(false)
	_set_clock("08:21")
	_story(["near:n_no_dead_end", "near:ngu_gate"])
	await _wait_until(func() -> bool: return _zone() == "gate", 1200.0, false)


# --- Zone 4: the gate and the canteen (8:22–8:30) ------------------------------------

func _gate() -> void:
	_begin(&"gate", "08:23")
	_arrive("gate", "Start_gate")
	_ensure_companions("gate")
	_set_area(&"gate")
	_spawn(&"Gate", 4)
	_story(["near:ngu_dont", "near:n_no_way", "near:ngu_canteen"])
	await _wait_until(func() -> bool: return _zone() == "canteen", 1200.0, false)
	if _dying:
		return
	_set_area(&"canteen")
	_set_clock("08:26")
	_scare(&"canteen_tv")
	if _campus != null and _campus.has_method("set_canteen_tv"):
		_campus.set_canteen_tv(true)
	await _room_voice("ROOM_CH3_TV_NEWS", _anchor("CanteenTV"))
	_spawn(&"Canteen", WAVE_SIZE)
	_set_clock("08:28")
	await _near("n_nothing")
	await _near("n_split")
	await _near("ngu_ok")
	_think("THINK_CH3_LIBRARY")


func _ending_3() -> void:
	GameState.set_segment(&"end3")
	_set_clock("08:30")
	for member: StringName in _companions:
		EventBus.companion_state_changed.emit(member, &"left")
	await _wait(3.0)
	if _horde != null:
		_horde.clear_all()
	Progress.unlock(4)
	await _fade_to_black(2.0)
	EventBus.chapter_finished.emit(3)


# --- Placing lane pieces --------------------------------------------------------------

func _place_ui() -> void:
	var host := get_parent()
	if host == null:
		return
	for path: String in [STATUS_UI, END_CARD_UI]:
		if ResourceLoader.exists(path):
			host.add_child.call_deferred((load(path) as PackedScene).instantiate())


func _place_audio_rigs() -> void:
	_horde_audio = Ch3HordeAudio.new()
	_horde_audio.name = "Ch3HordeAudio"
	_horde_audio.listener = _player
	add_child(_horde_audio)
	var player_audio := Ch3PlayerAudio.new()
	player_audio.name = "Ch3PlayerAudio"
	add_child(player_audio)
	_environment = Ch3Environment.new()
	_environment.name = "Ch3Environment"
	add_child(_environment)
	_ch3_music = Ch3Music.new()
	_ch3_music.name = "Ch3Music"
	add_child(_ch3_music)
	_siren = Ch3SirenAudio.new()
	_siren.name = "Ch3SirenAudio"
	_siren.listener = _player
	_siren.high_spot = _anchor("Clues/SirenSpot")
	add_child(_siren)
	# Chapter 1's music shares this scene script (chapter1_main): keep it quiet.
	var old := get_parent().get_node_or_null("Ch1Music") if get_parent() != null else null
	if old != null and old.has_method("set_active"):
		old.set_active.call_deferred(false)


func _place_horde() -> void:
	if _campus == null or _player == null:
		return
	_horde = ZombieHorde.new()
	_horde.name = "Horde"
	_horde.anchors = _campus.get_node_or_null("Anchors") as Node3D
	_horde.target = _player
	_horde.child_entered_tree.connect(_dress_zombie)
	add_child(_horde)


## Lane B's body and lane E's voice on every zombie lane A's horde makes.
func _dress_zombie(node: Node) -> void:
	var zombie := node as Zombie
	if zombie == null:
		return
	_dress.call_deferred(zombie, "zombie_%02d" % (_model_index % ZOMBIE_MODELS + 1))
	_model_index += 1


func _dress(zombie: Zombie, model: String) -> void:
	if not is_instance_valid(zombie):
		return
	if ResourceLoader.exists(MODELS % model):
		zombie.set_body(load(MODELS % model))
	var rig := ZombieAudio.new()
	rig.name = "ZombieAudio"
	rig.zombie = zombie
	zombie.add_child(rig)
	var link := Ch3ZombieLink.new()
	link.name = "AudioLink"
	link.rig = rig
	zombie.add_child(link)
	if _horde_audio != null:
		_horde_audio.register(rig)


func _make_zombie(model: String) -> Zombie:
	if not ResourceLoader.exists(ZOMBIE_SCENE):
		return null
	var zombie := (load(ZOMBIE_SCENE) as PackedScene).instantiate() as Zombie
	_dress.call_deferred(zombie, model)
	return zombie


func _place_guards() -> void:
	var line := _anchor("GuardLine")
	if line == null or not ResourceLoader.exists(GUARD_SCENE):
		return
	for point in line.get_children():
		var guard := (load(GUARD_SCENE) as PackedScene).instantiate() as Node3D
		guard.set("player", _player)
		add_child(guard)
		guard.global_transform = (point as Node3D).global_transform
		if guard.has_method("set_body") and ResourceLoader.exists(MODELS % "guard"):
			guard.set_body(load(MODELS % "guard"))
		var audio := Ch3GuardAudio.new()
		audio.guard = guard
		guard.add_child(audio)
		_guards.append(guard)


## The fire key, the fire door and the extinguisher (CH3_DESIGN.md N2, N4).
func _place_uses() -> void:
	var key := _use("FireKey", "PROMPT_CH3_TAKE_KEY", Vector3(0.4, 0.3, 0.4))
	if key != null:
		key.used.connect(func() -> void:
			_has_key = true
			GameState.set_flag(&"ch3_has_key", true)
			_think("THINK_CH3_KEY"))
	# Lane B's door marker sits on the floor: the use covers the whole leaf,
	# from the floor to 2.2 m, or a look at eye height hits the leaf instead.
	var door := _use("FireDoor", "PROMPT_CH3_UNLOCK", Vector3(1.4, 2.2, 1.4), 1.1)
	if door != null:
		door.once = false
		door.used.connect(func() -> void:
			if not _has_key:
				_think("THINK_CH3_FIRE_LOCKED")
				return
			door.enabled = false
			GameState.set_flag(&"ch3_fire_door_open", true)
			if _campus.has_method("set_fire_door_open"):
				_campus.set_fire_door_open(true))
	var extinguisher := _use("Extinguisher2F", "PROMPT_CH3_EXTINGUISHER", Vector3(0.5, 0.8, 0.5))
	if extinguisher != null:
		extinguisher.used.connect(func() -> void:
			_alarm_sounded = true
			GameState.set_flag(&"ch3_alarm", true)
			EventBus.noise_emitted.emit(extinguisher.global_position, 25.0, &"extinguisher"))


func _use(anchor_name: String, prompt: String, size: Vector3, lift: float = 0.0) -> Ch3Use:
	var anchor := _anchor(anchor_name)
	if anchor == null:
		return null
	var use := Ch3Use.new()
	use.name = "Use_" + anchor_name
	use.prompt_key = prompt
	use.size = size
	anchor.add_child(use)
	use.position = Vector3(0.0, lift, 0.0)
	_uses[anchor_name] = use
	return use


func _place_bars() -> void:
	var spawns := _anchor("BarSpawns")
	if spawns == null or not ResourceLoader.exists(BAR_SCENE):
		return
	var bars: Array[Node3D] = []
	for point in spawns.get_children():
		var bar := (load(BAR_SCENE) as PackedScene).instantiate() as Node3D
		add_child(bar)
		bar.global_transform = (point as Node3D).global_transform
		bars.append(bar)
	_settle_bars.call_deferred(bars)


## A marker may sit inside a prop's collision (B01 in the fallen bunk): lift
## each bar onto the first surface above it, or the player could not pick it up.
func _settle_bars(bars: Array[Node3D]) -> void:
	await get_tree().physics_frame
	if not is_inside_tree() or bars.is_empty():
		return
	var state := bars[0].get_world_3d().direct_space_state
	for bar in bars:
		if not is_instance_valid(bar):
			continue
		var at := bar.global_position
		var hit := state.intersect_ray(PhysicsRayQueryParameters3D.create(at + Vector3(0, 2.0, 0), at, 1))
		if not hit.is_empty():
			bar.global_position = Vector3(at.x, hit.position.y + 0.05, at.z)


## A companion joins at an anchor and runs lane B's path from point `from`.
func _join(member: StringName, anchor_name: String, from: int) -> void:
	if _companions.has(member) or not ResourceLoader.exists(COMPANION_SCENE):
		return
	var start := _anchor(anchor_name)
	var path := _anchor("Paths/" + ("Nhat" if member == &"minh_nhat" else "Ngu"))
	var companion := (load(COMPANION_SCENE) as PackedScene).instantiate() as Node3D
	companion.set("member", member)
	companion.set("player", _player)
	add_child(companion)
	if start != null:
		companion.global_position = start.global_position
	var model := MODELS % ("nhat" if member == &"minh_nhat" else "ngu")
	if companion.has_method("set_body") and ResourceLoader.exists(model):
		companion.set_body(load(model))
	_companions[member] = companion
	if path != null and companion.has_method("follow_path"):
		companion.follow_path(_path_from(path, from))
	EventBus.companion_state_changed.emit(member, &"joined")


## Lane A's companion runs a path from its first point: a copy that starts
## at `from` (a checkpoint resumes mid-path).
func _path_from(path: Node3D, from: int) -> Node3D:
	if from <= 0:
		return path
	var copy := Node3D.new()
	copy.name = path.name + "_from_%d" % from
	add_child(copy)
	var points := path.get_children()
	for i in range(from, points.size()):
		var marker := Marker3D.new()
		marker.name = points[i].name
		copy.add_child(marker)
		marker.global_transform = (points[i] as Node3D).global_transform
	return copy


## Index of the first wait point for a zone ("P14_Wait_garden" → 13).
func _wait_index(member: StringName, zone: String) -> int:
	var path := _anchor("Paths/" + ("Nhat" if member == &"minh_nhat" else "Ngu"))
	if path == null:
		return 0
	var points := path.get_children()
	for i in points.size():
		if String(points[i].name).ends_with("_Wait_" + zone):
			return i
	return 0


## After a checkpoint mid-chapter both companions are already with Trung.
func _ensure_companions(zone: String) -> void:
	for member: StringName in [&"minh_nhat", &"ngu"]:
		if not _companions.has(member):
			_join(member, "Start_" + zone, _wait_index(member, zone))


## Resuming at a zone's checkpoint: stand at its start marker.
func _arrive(zone: String, anchor_name: String) -> void:
	if _zone() == zone:
		return
	var start := _anchor(anchor_name)
	if start != null:
		_place_player(start.global_position)


# --- Zombies --------------------------------------------------------------------------

func _spawn(zone: StringName, count: int) -> void:
	if _horde != null:
		_horde.spawn(zone, count)


## Wake the sleeping zombies near the player (the corridor turning, the 203 crowd).
func _wake_near(radius: float) -> void:
	if _horde == null or _player == null:
		return
	for actor in _horde.get_children():
		if actor is Zombie and actor.state == &"asleep" and actor.global_position.distance_to(_player.global_position) < radius:
			actor.wake()


# --- Speech, scares, zones --------------------------------------------------------------

## Lines on a beat without holding up the game, one at a time: "chat:id",
## "near:id" (a companion in person), "think:KEY".
func _story(beats: Array) -> void:
	for beat: String in beats:
		_chat_queue.append(beat)
	if _chat_running:
		return
	_chat_running = true
	while not _chat_queue.is_empty():
		if _dying or not is_inside_tree():
			_chat_queue.clear()
			break
		var beat: String = _chat_queue.pop_front()
		var kind := beat.get_slice(":", 0)
		var id := beat.get_slice(":", 1)
		match kind:
			"chat": await _line(id)
			"near": await _near(id)
			"think":
				_think(id)
				await _wait(_spoken_seconds(id))
	_chat_running = false


## A companion says a line in person: voiced at them, subtitled.
func _near(id: String) -> void:
	var key := "NEAR_CH3_" + id.to_upper()
	var member: StringName = &"ngu" if id.begins_with("ngu") else &"minh_nhat"
	var companion: Node3D = _companions.get(member)
	await _voice_at(key, companion)


func _room_voice(key: String, where: Node3D) -> void:
	await _voice_at(key, where)


func _voice_at(key: String, where: Node3D) -> void:
	var path := "res://audio/voice/vi/%s.ogg" % key
	var stream: AudioStream = load(path) if ResourceLoader.exists(path) else null
	var seconds := stream.get_length() + 0.3 if stream != null else _spoken_seconds(key)
	if stream != null and where != null and is_instance_valid(where):
		var voice := AudioStreamPlayer3D.new()
		voice.bus = &"Voice"
		voice.stream = stream
		voice.unit_size = 4.0
		where.add_child(voice)
		voice.play()
		voice.finished.connect(voice.queue_free)
	_say(key, seconds)
	await _wait(seconds)


func _scare(id: StringName) -> void:
	if _scared.get(id, false):
		return
	_scared[id] = true
	EventBus.scare_triggered.emit(id)


## Scares that wait for the player to come close (CH3_DESIGN.md jumpscares).
func _watch_scares() -> void:
	var pos := _player.global_position
	if not _scared.get(&"stair_corpse", false) and pos.y < FLOOR_3_Y + 0.5 and pos.y > FLOOR_2_Y:
		var crack := _anchor("Clues/CrackStair")
		if crack != null and pos.distance_to(crack.global_position) < 3.0:
			_scare(&"stair_corpse")
	if not _scared.get(&"knife_drag", false):
		var knife := _anchor("ManagerKnife")
		if knife != null and pos.distance_to(knife.global_position) < KNIFE_RADIUS:
			_scare(&"knife_drag")
			_think("THINK_CH3_KNIFE")
	if not _scared.get(&"guard_turn", false):
		for guard in _guards:
			if is_instance_valid(guard) and pos.distance_to(guard.global_position) < GUARD_TURN_RADIUS:
				_scare(&"guard_turn")
				if guard.has_method("turn_head_to"):
					guard.turn_head_to(pos + Vector3(0, 1.5, 0))
				break


func _on_stamina(_value: float, exhausted: bool) -> void:
	if exhausted and not _exhausted_told and GameState.segment == &"stadium":
		_exhausted_told = true
		_think("THINK_CH3_LEGS")


func _on_zone(zone: String) -> void:
	match zone:
		"garden", "stadium", "gate", "canteen", "road": _set_area(StringName(zone))
	if zone == "road" and _horde != null:
		_horde.place_idle(&"Road")


func _set_area(area: StringName) -> void:
	if _environment != null:
		_environment.set_area(area)
	if _ch3_music != null:
		_ch3_music.set_area(area)


func _siren_check() -> void:
	if _siren != null:
		_siren.set_enabled(_zone() == "bleachers" or _in_zone("Bleachers"))


func _anchor(path: String) -> Node3D:
	if _campus == null:
		return null
	return _campus.get_node_or_null("Anchors/" + path) as Node3D


## "garden", "stadium", "gate", "canteen", "road", "building_b" or "".
func _zone() -> String:
	if _campus == null or _player == null:
		return ""
	for zone_name in ["Canteen", "Gate", "Stadium", "Garden", "Road", "BuildingB"]:
		if _in_zone(zone_name):
			return "building_b" if zone_name == "BuildingB" else zone_name.to_lower()
	return ""


func _in_zone(zone_name: String) -> bool:
	var zone := _campus.get_node_or_null("Zones/" + zone_name) as Area3D if _campus != null else null
	if zone == null or _player == null:
		return false
	for shape_node in zone.find_children("*", "CollisionShape3D", true, false):
		var box := (shape_node as CollisionShape3D).shape as BoxShape3D
		if box == null:
			continue
		var local: Vector3 = (shape_node as Node3D).global_transform.affine_inverse() * (_player.global_position + Vector3(0, 0.5, 0))
		var half := box.size * 0.5
		if absf(local.x) <= half.x and absf(local.y) <= half.y and absf(local.z) <= half.z:
			return true
	return false
