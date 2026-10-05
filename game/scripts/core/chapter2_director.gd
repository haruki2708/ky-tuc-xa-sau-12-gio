class_name Chapter2Director
extends Chapter1Director
## Chapter 2 "Trò chơi", 6:00–8:00 (docs/design/CH2_DESIGN.md, CH2_SCRIPT.md):
## round 3 word chain with the dead roommates, round 4 the shower. Reuses the
## chapter-1 flow helpers (call, speaker, choices, deaths, checkpoints, room).
## Lane pieces (T-171…T-175) plug in by name and degrade to no-ops when absent.

const CH2_RULE_SET := "res://data/rules/ch2.tres"
const CH2_STAGES: Array[StringName] = [&"r3", &"r4", &"end2"]
const CH2_CHECKPOINTS := {&"r3": &"ch2_r3", &"r4": &"ch2_r4"}
const CH2_DEATH_CHECKPOINTS := {&"r3": &"ch2_r3", &"r4": &"ch2_r4", &"end2": &"ch2_r4"}
const CH2_DEATH_KINDS := {
	&"DEATH_CH2_CHAIN_WRONG": &"corpse_lunge", &"DEATH_CH2_CHAIN_TIMEOUT": &"corpse_lunge",
	&"DEATH_CH2_SCALDED": &"scald", &"DEATH_CH2_NO_CHOICE": &"scald", &"DEATH_CH2_SHORT_SHOWER": &"scald",
	&"DEATH_CH2_SHOWER_BROKEN": &"fall_back", &"DEATH_CH2_LOST_NGU": &"none", &"DEATH_LEFT_ROOM": &"fall_back",
}
const WORD_BANK_PATH := "res://data/ch2/word_bank.json"
const SHOWER_PATH := "res://data/ch2/shower.json"
## Clockwise from Trung: Phúc (bed 1), Việt (bed 2), Đạt (bed 4), then Trung (0).
const TURN_ORDER: Array[int] = [1, 2, 4, 0]
const SPEAKERS := {0: &"trung", 1: &"phuc", 2: &"viet", 4: &"dat"}
const CORPSE_SPEAK_SECONDS := 2.6
const CORPSE_MUMBLE_SECONDS := 4.0
const CORPSE_REVIVE_SECONDS := 10.0
## Round 3 lasts this many of Trung's turns unless the loop ends it early (D-040).
const R3_TURNS := 28
const SHOWER_CHOICE_SECONDS := 8.0
const SHOWER_SLOT_SECONDS := 20.0
## Seconds after "Có" to step into the stall before the water decides.
const SHOWER_GRACE_SECONDS := 2.0
const NGU_SECONDS := 10.0
const NGU_CORRECT := 0
## Story beats on Trung's turn count (CH2_SCRIPT.md).
const R3_BEATS := {2: ["n_keep_up"], 5: ["cctv_310"], 9: ["ngu_clue", "n_brave"], 13: ["n_loop", "ngu_loop"], 20: ["n_few"]}
const R4_BEATS := {1: ["n_seventy"], 5: ["ngu_pattern"], 10: ["n_steam"]}

var _bank: Dictionary = {}
var _shower: Dictionary = {}
var _rng := RandomNumberGenerator.new()
## Word chain state.
var _last_word: String = ""
var _recent: Array[String] = []
var _gagged: Dictionary[int, bool] = {}
var _talking_bed: int = -1
var _turns: int = 0
var _loop_known: bool = false
var _loop_run: int = 0
var _chain_options: PackedStringArray = PackedStringArray()
var _chain_answer: int = -2
var _first_stall_told: bool = false
## Shower state.
var _shower_choice: int = -1
var _in_shower_override: int = -1
var _minutes: int = 0
var _steam: float = 0.0


func _ready() -> void:
	_bank = _load_json(WORD_BANK_PATH)
	_shower = _load_json(SHOWER_PATH)
	_rng.seed = 2026
	EventBus.chain_choice_made.connect(func(index: int) -> void: _chain_answer = index)
	EventBus.shower_choice_made.connect(func(run_water: bool) -> void: _shower_choice = 1 if run_water else 0)
	super._ready()
	_place_ch2_props()


# --- Chapter definition ---------------------------------------------------------------

func _chapter() -> int:
	return 2


func _rule_set_path() -> String:
	return CH2_RULE_SET


func _stages() -> Array[StringName]:
	return CH2_STAGES


func _run_stage(stage: StringName) -> void:
	match stage:
		&"r3": await _round_3()
		&"r4": await _round_4()
		&"end2": await _ending_2()


func _checkpoints() -> Dictionary:
	return CH2_CHECKPOINTS


func _death_checkpoints() -> Dictionary:
	return CH2_DEATH_CHECKPOINTS


func _death_kinds() -> Dictionary:
	return CH2_DEATH_KINDS


# --- Round 3: the word chain (6:00–7:00) ----------------------------------------------

func _round_3() -> void:
	_begin(&"r3", "06:00")
	_rules_live = true
	_set_blood(1)
	_set_corpses_watching(false)
	_place_player(Vector3(32.6, 0.05, -1.4))
	_reset_chain()
	await _announce(["SPK_CH2_R2_END"])
	_survivors(28)
	await _line("n_28")
	await _announce(["SPK_CH2_R3_INTRO", "RULE_CH2_R3_1", "RULE_CH2_R3_2", "RULE_CH2_R3_3"])
	for key in ["ch2_r3_1", "ch2_r3_2", "ch2_r3_3"]:
		RuleSystem.mark_read(StringName(key))
	await _line("ngu_four")
	# The three dead roommates sit up (jumpscare 1).
	for bed in [1, 2, 4]:
		_corpse_state(bed, &"sit")
	EventBus.scare_triggered.emit(&"corpses_sit_up")
	await _wait(1.5)
	await _line("n_sat_up")
	await _line("ngu_sat_up")
	_set_clock("06:02")
	# Scripted opening (N1): Phúc, Việt, Đạt, then Trung on "vở".
	for i in 3:
		await _corpse_says([1, 2, 4][i], String(_bank.opening[i]))
	_think("THINK_CH2_VO")
	await _chain(R3_TURNS)


func _reset_chain() -> void:
	_last_word = ""
	_recent.clear()
	_gagged.clear()
	_turns = 0
	_loop_known = false
	_loop_run = 0
	_first_stall_told = false
	for bed in [1, 2, 4]:
		_gagged[bed] = false


## Turns go round until Trung has answered `turns` times, or the loop is done.
func _chain(turns: int) -> void:
	while is_inside_tree() and not _dying:
		if not await _trung_turn():
			return
		if _turns >= turns or _loop_run >= (_bank.get("loop", []) as Array).size():
			break
		for bed in [1, 2, 4]:
			if _dying or not is_inside_tree():
				return
			await _corpse_turn(bed)


## A corpse's turn: says a word, or mumbles through the gag, or stalls on a
## dead end (falls, revives and starts a new chain, N2).
func _corpse_turn(bed: int) -> void:
	var speaker: StringName = SPEAKERS[bed]
	EventBus.chain_turn_started.emit(speaker, float(_bank.get("seconds", 15.0)))
	if _gagged.get(bed, false):
		_corpse_state(bed, &"mumble")
		EventBus.chain_word_spoken.emit(speaker, "")
		await _wait(CORPSE_MUMBLE_SECONDS)
		await _corpse_falls(bed, 2.0)
		return
	var word := _corpse_pick(_last_syllable())
	if word.is_empty():
		# Nothing in the bank follows: it stalls the whole turn, falls, comes back.
		_corpse_state(bed, &"mumble")
		EventBus.chain_word_spoken.emit(speaker, "")
		await _wait(float(_bank.get("seconds", 15.0)))
		await _corpse_falls(bed, CORPSE_REVIVE_SECONDS)
		if not _first_stall_told:
			_first_stall_told = true
			_story(["ngu_cheat", "n_hour"])
		word = _corpse_pick("")
	await _corpse_says(bed, word)


func _corpse_falls(bed: int, revive_seconds: float) -> void:
	_corpse_state(bed, &"fall")
	EventBus.scare_triggered.emit(&"corpse_fall")
	await _wait(revive_seconds)
	_corpse_state(bed, &"revive")
	await _wait(0.6)
	_corpse_state(bed, &"gagged" if _gagged.get(bed, false) else &"sit")


func _corpse_says(bed: int, key: String) -> void:
	_talking_bed = bed
	_corpse_state(bed, &"talk")
	_said(key)
	EventBus.chain_word_spoken.emit(SPEAKERS[bed], key)
	await _wait(CORPSE_SPEAK_SECONDS)
	_talking_bed = -1
	_corpse_state(bed, &"gagged" if _gagged.get(bed, false) else &"sit")


## Trung's turn: four options, 15 seconds, only from the bedroom. False = dead.
func _trung_turn() -> bool:
	_turns += 1
	_set_clock("%02d:%02d" % [6, mini(59, 2 + _turns * 2)])
	_story(R3_BEATS.get(_turns, []))
	var seconds := float(_bank.get("seconds", 15.0))
	_chain_options = _options_for(_last_syllable())
	_chain_answer = -2
	EventBus.chain_turn_started.emit(&"trung", seconds)
	EventBus.chain_choice_requested.emit(_chain_options, seconds)
	var blocked := [false]
	await _wait_until(func() -> bool:
		var deaf := not _in_bedroom()
		if deaf != blocked[0]:
			blocked[0] = deaf
			EventBus.chain_choice_blocked.emit(deaf)
		if deaf and _chain_answer != -2:
			_chain_answer = -2
		return _chain_answer != -2, seconds)
	if blocked[0]:
		EventBus.chain_choice_blocked.emit(false)
	if _chain_answer < 0 or _chain_answer >= _chain_options.size():
		EventBus.chain_choice_made.emit(-1)
		_die(&"DEATH_CH2_CHAIN_TIMEOUT")
		return false
	var key := _chain_options[_chain_answer]
	if not is_valid_answer(key):
		_die(&"DEATH_CH2_CHAIN_WRONG")
		return false
	_said(key)
	EventBus.chain_word_spoken.emit(&"trung", key)
	_loop_run = _loop_run + 1 if _all_gagged() and key in _bank.loop else 0
	return true


## The rule (CH2_DESIGN.md): a bank word starting with the last syllable,
## tone included, not said in the last three turns.
func is_valid_answer(key: String) -> bool:
	var words: Dictionary = _bank.get("words", {})
	if not words.has(key) or key in _recent:
		return false
	return _last_word.is_empty() or String(words[key].first) == _last_syllable()


## One right word (two when a dead end is on offer, N2) and traps: wrong tone
## or near-miss start, a recent repeat, anything else.
func _options_for(syllable: String) -> PackedStringArray:
	var words: Dictionary = _bank.get("words", {})
	var traps: Dictionary = _bank.get("traps", {})
	var right := _right_word(syllable)
	var picked: Array[String] = [right]
	var count := int(_bank.get("options", 4))
	if not _all_gagged() and _rng.randf() < 0.4:
		for key: String in words:
			if words[key].dead and words[key].first == syllable and key not in _recent:
				picked.append(key)
				break
	var near: Array[String] = []
	var other: Array[String] = []
	for source: Dictionary in [words, traps]:
		for key: String in source:
			if key in picked or (source == words and is_valid_answer(key)):
				continue
			var first := String(source[key].first)
			if first != syllable and _toneless(first) == _toneless(syllable):
				near.append(key)
			else:
				other.append(key)
	for key in _recent:
		if words.has(key) and String(words[key].first) == syllable and key not in picked:
			near.push_front(key)
	near.shuffle()
	other.shuffle()
	for key in near + other:
		if picked.size() >= count:
			break
		if key not in picked:
			picked.append(key)
	var shuffled := picked.duplicate()
	shuffled.shuffle()
	return PackedStringArray(shuffled)


func _right_word(syllable: String) -> String:
	var words: Dictionary = _bank.get("words", {})
	var steer: Dictionary = _bank.get("steer", {})
	# Minh Nhật's loop (N5): once everyone is gagged, the steering word leads to it.
	if _loop_known and _all_gagged():
		var loop: Array = _bank.loop
		if _last_word in loop:
			var next: String = loop[(loop.find(_last_word) + 1) % loop.size()]
			if is_valid_answer(next):
				return next
		if steer.has(syllable) and is_valid_answer(String(steer[syllable])):
			return String(steer[syllable])
	var choices: Array[String] = []
	for key: String in words:
		if not words[key].dead and is_valid_answer(key):
			choices.append(key)
	if choices.is_empty():
		return ""
	return choices[_rng.randi_range(0, choices.size() - 1)]


func _corpse_pick(syllable: String) -> String:
	var words: Dictionary = _bank.get("words", {})
	var choices: Array[String] = []
	for key: String in words:
		if words[key].dead or key in _recent:
			continue
		if syllable.is_empty() or String(words[key].first) == syllable:
			choices.append(key)
	if choices.is_empty():
		return ""
	return choices[_rng.randi_range(0, choices.size() - 1)]


func _said(key: String) -> void:
	_last_word = key
	_recent.append(key)
	while _recent.size() > int(_bank.get("no_repeat_window", 3)):
		_recent.pop_front()


func _last_syllable() -> String:
	var words: Dictionary = _bank.get("words", {})
	return String(words[_last_word].last) if words.has(_last_word) else ""


static func _toneless(syllable: String) -> String:
	const MARKS := {"à": "a", "á": "a", "ả": "a", "ã": "a", "ạ": "a", "ằ": "ă", "ắ": "ă", "ẳ": "ă", "ẵ": "ă", "ặ": "ă",
		"ầ": "â", "ấ": "â", "ẩ": "â", "ẫ": "â", "ậ": "â", "è": "e", "é": "e", "ẻ": "e", "ẽ": "e", "ẹ": "e",
		"ề": "ê", "ế": "ê", "ể": "ê", "ễ": "ê", "ệ": "ê", "ì": "i", "í": "i", "ỉ": "i", "ĩ": "i", "ị": "i",
		"ò": "o", "ó": "o", "ỏ": "o", "õ": "o", "ọ": "o", "ồ": "ô", "ố": "ô", "ổ": "ô", "ỗ": "ô", "ộ": "ô",
		"ờ": "ơ", "ớ": "ơ", "ở": "ơ", "ỡ": "ơ", "ợ": "ơ", "ù": "u", "ú": "u", "ủ": "u", "ũ": "u", "ụ": "u",
		"ừ": "ư", "ứ": "ư", "ử": "ư", "ữ": "ư", "ự": "ư", "ỳ": "y", "ý": "y", "ỷ": "y", "ỹ": "y", "ỵ": "y"}
	var out := ""
	for c in syllable:
		out += MARKS.get(c, c)
	return out


func _all_gagged() -> bool:
	for bed in [1, 2, 4]:
		if not _gagged.get(bed, false):
			return false
	return true


## N4: gag a corpse (lane A's gag spot asks; the bot and tests call it too).
## Gagging the one that is talking makes it stare at you (jumpscare 2).
func gag(bed: int) -> bool:
	if not _gagged.has(bed) or _gagged[bed] or GameState.segment != &"r3":
		return false
	_gagged[bed] = true
	GameState.set_flag(StringName("ch2_gagged_%d" % bed), true)
	if _talking_bed == bed:
		EventBus.scare_triggered.emit(&"corpse_stare")
		var body := _corpse_body(bed)
		if body != null and body.has_method("look_at_point") and _player != null:
			body.look_at_point(_player.global_position + Vector3(0, 1.5, 0))
	_corpse_state(bed, &"gagged")
	return true


func _on_gag_requested(bed: int, _item_id: StringName, spot: Node, item: Node) -> void:
	if gag(bed):
		if item != null and item.has_method("consume"):
			item.consume()
		if spot != null and spot.has_method("set_gagged"):
			spot.set_gagged(true)


# --- Round 4: the shower (7:00–8:00) --------------------------------------------------

func _round_4() -> void:
	_begin(&"r4", "07:00")
	_rules_live = true
	_minutes = 0
	_set_steam(0.0)
	await _announce(["SPK_CH2_R3_END"])
	_survivors(5)
	for bed in [1, 2, 4]:
		_corpse_state(bed, &"slump")
	await _line("ngu_five")
	await _announce(["SPK_CH2_R4_INTRO", "RULE_CH2_R4_1", "SPK_CH2_R4_ENJOY"])
	RuleSystem.mark_read(&"ch2_r4_1")
	_set_clock("07:01")
	_think("THINK_CH2_DOOR")
	await _line("ngu_must")
	await _line("n_wait")
	var temps: Array = _shower.get("player", [])
	var need := int(_shower.get("need_minutes", 25))
	for slot in temps.size():
		if _dying or not is_inside_tree():
			return
		_set_clock("07:%02d" % mini(59, 2 + slot * 2))
		if slot == int(_shower.get("ngu_slot", 20)):
			if not await _save_ngu():
				return
		_story(R4_BEATS.get(slot, []))
		if not await _shower_slot(int(temps[slot])):
			return
		if _minutes >= need:
			break
	if _minutes < need and not _dying:
		_die(&"DEATH_CH2_SHORT_SHOWER")


## One 2-minute slot: choose, then the water decides. False = dead.
func _shower_slot(temperature: int) -> bool:
	_shower_choice = -1
	EventBus.shower_choice_requested.emit(SHOWER_CHOICE_SECONDS)
	await _wait_until(func() -> bool: return _shower_choice != -1, SHOWER_CHOICE_SECONDS)
	if _shower_choice == -1:
		_die(&"DEATH_CH2_NO_CHOICE")
		return false
	var run := _shower_choice == 1
	if run:
		await _wait(SHOWER_GRACE_SECONDS)
		if not _in_shower():
			_die(&"DEATH_CH2_SHOWER_BROKEN")
			return false
	_set_water(run, temperature)
	if run and temperature >= int(_shower.get("lethal", 50)):
		await _wait(1.2)
		_die(&"DEATH_CH2_SCALDED")
		return false
	var left := SHOWER_SLOT_SECONDS - SHOWER_CHOICE_SECONDS - (SHOWER_GRACE_SECONDS if run else 0.0)
	var broke := [false]
	await _wait_until(func() -> bool:
		broke[0] = run and not _in_shower()
		return broke[0], maxf(left, 1.0))
	if broke[0]:
		_die(&"DEATH_CH2_SHOWER_BROKEN")
		return false
	if run:
		_minutes += int(_shower.get("slot_minutes", 2))
	_set_water(false, temperature)
	GameState.set_flag(&"ch2_shower_minutes", _minutes)
	EventBus.shower_slot_finished.emit(temperature, run, _minutes)
	return true


## N10: Ngư asks what to pick next; ten seconds, the wrong advice loses her.
func _save_ngu() -> bool:
	await _line("ngu_help")
	EventBus.scare_triggered.emit(&"ngu_water")
	var picked := await _choice(&"ngu", 2, NGU_SECONDS, -1)
	if picked != NGU_CORRECT:
		await _line("ngu_scream")
		_member_dies(&"ngu", Vector3(20.0, -6.6, -2.0))
		await _wait(1.5)
		_die(&"DEATH_CH2_LOST_NGU")
		return false
	await _line("ngu_saved")
	return true


func _ending_2() -> void:
	GameState.set_segment(&"end2")
	_set_water(false, 0)
	_set_clock("08:00")
	await _announce(["SPK_CH2_R4_END"])
	_survivors(3)
	await _line("n_three")
	_think("THINK_CH2_END")
	await _wait(4.0)
	_rules_live = false
	Progress.unlock(3)
	EventBus.chapter_finished.emit(2)
	await _fade_to_black(2.0)
	_show_card("UI_CH2_END", "CH_2_TITLE")


# --- Shower helpers -------------------------------------------------------------------

## Tests and the bot can stand the player in the stall without lane A's area.
func set_in_shower(inside: bool) -> void:
	_in_shower_override = 1 if inside else 0


func _in_shower() -> bool:
	if _in_shower_override != -1:
		return _in_shower_override == 1
	var stall := _find_component("shower_stall.gd")
	return stall != null and stall.get("player_inside") == true


func _set_water(on: bool, temperature: int) -> void:
	var room := _room()
	if room != null and room.has_method("set_water"):
		room.set_water(on, temperature)
	if on and temperature >= 40:
		_set_steam(minf(1.0, _steam + 0.35))
	elif not on:
		_set_steam(maxf(0.0, _steam - 0.1))


func _set_steam(level: float) -> void:
	_steam = level
	var room := _room()
	if room != null and room.has_method("set_steam"):
		room.set_steam(level)
	EventBus.shower_steam_changed.emit(level)


# --- Shared ----------------------------------------------------------------------------

## Story lines fired on a turn without holding up the game (one after another).
func _story(beats: Array) -> void:
	for beat: String in beats:
		if _dying or not is_inside_tree():
			return
		match beat:
			"cctv_310": _cctv_310()
			"n_loop":
				_loop_known = true
				GameState.set_flag(&"ch2_loop_known", true)
				await _line(beat)
			_: await _line(beat)


## D-046: the security camera shows room 310 losing the game (jumpscare 4).
func _cctv_310() -> void:
	EventBus.cctv_focus_requested.emit(&"cam_310")
	EventBus.scare_triggered.emit(&"cctv_kill")
	if _cctv_set == null:
		return
	var room := _cctv_set.get_node_or_null("Room310")
	if room == null:
		return
	for body in room.find_children("*", "", true, false):
		if body.has_method("set_state"):
			body.set_state(&"lunge")
	var victim := room.get_node_or_null("Victim")
	if victim != null and victim.has_method("set_pose"):
		get_tree().create_timer(0.8 * time_scale, false).timeout.connect(_set_pose_ref.bind(weakref(victim), &"dead"))


func _corpse_state(bed: int, state: StringName) -> void:
	EventBus.corpse_state_changed.emit(bed, state)
	var body := _corpse_body(bed)
	if body == null:
		return
	if body.has_method("set_state"):
		body.set_state(state)
	elif body.has_method("set_pose"):
		# Before lane B's states (T-172): sitting up is the closest pose.
		body.set_pose(&"sit_up" if state in [&"sit", &"talk", &"gagged", &"mumble", &"revive", &"lunge"] else &"dead_a")


func _corpse_body(bed: int) -> Node:
	var anchor := _room_anchor("Corpse%d" % bed)
	return anchor.get_node_or_null("Body") if anchor != null else null


## The bedroom of 407, where the dead can hear Trung (not the bathroom or balcony).
func _in_bedroom() -> bool:
	var zone := _room().get_node_or_null("Zones/Bedroom") as Area3D if _room() != null else null
	if zone == null or _player == null:
		return true
	for shape_node in zone.find_children("*", "CollisionShape3D", true, false):
		var box := (shape_node as CollisionShape3D).shape as BoxShape3D
		if box == null:
			continue
		var local: Vector3 = (shape_node as Node3D).global_transform.affine_inverse() * (_player.global_position + Vector3(0, 0.5, 0))
		var half := box.size * 0.5
		if absf(local.x) <= half.x and absf(local.y) <= half.y and absf(local.z) <= half.z:
			return true
	return false


## Lane A's pieces (T-171) on lane B's anchors (T-172), when they exist.
func _place_ch2_props() -> void:
	var room := _room()
	if room == null:
		return
	var carry_scene := "res://scenes/interaction/carry_item.tscn"
	for entry: Array in [["RagSpot", &"rag", "PROMPT_CH2_TAKE_RAG"], ["TowelSpot", &"towel", "PROMPT_CH2_TAKE_TOWEL"],
			["ShirtSpot", &"shirt", "PROMPT_CH2_TAKE_SHIRT"]]:
		var anchor := _room_anchor(entry[0])
		if anchor != null and ResourceLoader.exists(carry_scene):
			var item := load(carry_scene).instantiate() as Node3D
			item.name = "Carry_" + String(entry[1])
			item.set("item_id", entry[1])
			item.set("prompt_key", entry[2])
			anchor.add_child(item)
	var gag_scene := "res://scenes/interaction/gag_spot.tscn"
	for bed in [1, 2, 4]:
		var anchor := _room_anchor("Gag%d" % bed)
		if anchor != null and ResourceLoader.exists(gag_scene):
			var spot := load(gag_scene).instantiate() as Node3D
			spot.name = "GagSpot"
			spot.set("bed", bed)
			anchor.add_child(spot)
			if spot.has_signal("gag_requested"):
				spot.gag_requested.connect(func(b: int, item_id: StringName) -> void:
					_on_gag_requested(b, item_id, spot, _held_item()))


func _held_item() -> Node:
	for item in _find_components("carry_item.gd"):
		if item.get("is_held") == true or item.get("held") == true:
			return item
	return null


func _load_json(path: String) -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return data if data is Dictionary else {}
