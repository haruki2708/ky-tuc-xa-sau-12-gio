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
	&"DEATH_CH2_SHOWER_BROKEN": &"fall_back", &"DEATH_CH2_LOST_NGU": &"none", &"DEATH_CH2_LOST_NHAT": &"none", &"DEATH_LEFT_ROOM": &"fall_back",
	&"DEATH_CH2_LOST_FRIENDS": &"none",
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
## D-072: after this many loop words in a row (all three gagged) Minh Nhật and
## Ngư ask how to pass and Trung texts them; the round ends at the second count.
const R3_TELL_LOOP_RUN := 2
const R3_LOOP_PASS := 4
## Wait for the story queue to go quiet before the friends speak, at most this long.
const TELL_QUEUE_SECONDS := 40.0
const SHOWER_CHOICE_SECONDS := 8.0
const SHOWER_SLOT_SECONDS := 20.0
## Seconds after "Có" to step into the stall before the water decides.
const SHOWER_GRACE_SECONDS := 2.0
## A corpse says one of the game's own words (horror flavour) this often
## when one fits; otherwise any dictionary word it knows (D-051).
const BANK_WORD_CHANCE := 0.6
## Story beats on Trung's turn count (CH2_SCRIPT.md).
const R3_BEATS := {2: ["n_keep_up"], 5: ["cctv_310"], 9: ["ngu_clue", "n_brave"], 13: ["n_loop", "ngu_loop"], 20: ["n_few"]}
const R4_BEATS := {1: ["n_seventy"], 5: ["ngu_pattern"], 10: ["n_steam"]}

var _bank: Dictionary = {}
var _shower: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _dictionary: Ch2Dictionary
## Bank words by canonical form (VietText.canon_word) -> strings key.
var _bank_keys: Dictionary[String, String] = {}
var _loop_canon: Array[String] = []
## Canonical syllable -> canonical word that steers toward the loop (bot, tests).
var _steer: Dictionary[String, String] = {}
## Word chain state; words are canonical forms.
var _last_word: String = ""
var _recent: Array[String] = []
var _gagged: Dictionary[int, bool] = {}
var _talking_bed: int = -1
var _turns: int = 0
var _loop_known: bool = false
var _loop_run: int = 0
## The friends have been asked once in this attempt at round 3 (D-072).
var _tell_done: bool = false
var _typed: String = ""
var _typed_sent: bool = false
var _first_stall_told: bool = false
## Story lines play one at a time without holding up the game.
var _chat_queue: Array[String] = []
var _chat_running: bool = false
## Shower state.
var _shower_choice: int = -1
var _safe_streak: int = 0
var _predicted: bool = false
var _prediction_member: StringName = &""
var _prediction_text: String = ""
var _prediction_sent: bool = false
var _in_shower_override: int = -1
var _minutes: int = 0
var _steam: float = 0.0
var _shower_lcd: Node3D
var _shower_audio: Node3D
var _ch2_music: Node
var _chain_panel: Node


func _ready() -> void:
	# Lane D's word-chain panel (T-174).
	if ResourceLoader.exists("res://ui/chain/chain_panel.tscn"):
		_chain_panel = (load("res://ui/chain/chain_panel.tscn") as PackedScene).instantiate()
		_chain_panel.name = "ChainPanel"
		add_child(_chain_panel)
	_bank = _load_json(WORD_BANK_PATH)
	_shower = _load_json(SHOWER_PATH)
	_dictionary = Ch2Dictionary.shared()
	_index_bank()
	_rng.seed = 2026
	EventBus.chain_word_typed.connect(func(text: String) -> void:
		_typed = text
		_typed_sent = true)
	EventBus.prediction_sent.connect(func(member: StringName, text: String) -> void:
		if member == _prediction_member:
			_prediction_text = text
			_prediction_sent = true)
	EventBus.shower_choice_made.connect(func(run_water: bool) -> void: _shower_choice = 1 if run_water else 0)
	super._ready()
	_place_ch2_props()
	_place_ch2_audio()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# Where the player is, for the QA bot and the menu (T-173).
	var zone := _zone()
	if GameState.get_flag(&"ch2_zone", "") != zone:
		GameState.set_flag(&"ch2_zone", zone)


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
	_bathroom_door(true)
	if _ch2_music != null:
		_ch2_music.set_round(&"chain")
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
		var key := String(_bank.opening[i])
		await _corpse_says([1, 2, 4][i], VietText.canon_word(String(_bank.words[key].text)))
	_think("THINK_CH2_VO")
	await _chain(R3_TURNS)
	if _chain_panel != null and _chain_panel.has_method("close_panel"):
		_chain_panel.close_panel()


func _index_bank() -> void:
	var words: Dictionary = _bank.get("words", {})
	for key: String in words:
		_bank_keys[VietText.canon_word(String(words[key].text))] = key
	for key: String in _bank.get("loop", []):
		_loop_canon.append(VietText.canon_word(String(words[key].text)))
	var steer: Dictionary = _bank.get("steer", {})
	for syllable: String in steer:
		var key := String(steer[syllable])
		if words.has(key):
			_steer[VietText.canon_syllable(syllable)] = VietText.canon_word(String(words[key].text))


func _reset_chain() -> void:
	_last_word = ""
	_recent.clear()
	_gagged.clear()
	_turns = 0
	_loop_known = false
	_loop_run = 0
	_tell_done = false
	_first_stall_told = false
	for bed in [1, 2, 4]:
		_gagged[bed] = false


## Turns go round until Trung has answered `turns` times, or the loop is done
## (R3_LOOP_PASS loop words in a row, D-072).
func _chain(turns: int) -> void:
	while is_inside_tree() and not _dying:
		if not await _trung_turn():
			return
		if _loop_run >= R3_TELL_LOOP_RUN and not _tell_done:
			# No turn is open here: the chain waits (and its clock) until he has chosen.
			if not await _tell_friends():
				return
		if _turns >= turns or _loop_run >= R3_LOOP_PASS:
			break
		for bed in [1, 2, 4]:
			if _dying or not is_inside_tree():
				return
			await _corpse_turn(bed)


## D-072: with all three gagged and two loop words said, Minh Nhật and Ngư ask
## how to pass; Trung has TELL_SECONDS to text them the right way (choice 1:
## gag all three, then repeat the loop). Wrong or too late: both die and he
## loses. False = dead.
func _tell_friends() -> bool:
	_tell_done = true
	# Earlier story lines finish first so the friends never talk over each other.
	await _wait_until(func() -> bool: return not _chat_running and _chat_queue.is_empty(), TELL_QUEUE_SECONDS)
	if _dying or not is_inside_tree():
		return false
	if not _loop_known:
		_loop_known = true
		GameState.set_flag(&"ch2_loop_known", true)
		await _line("n_loop")
		await _line("ngu_loop")
	await _line("n_how")
	await _line("ngu_how")
	if _dying or not is_inside_tree():
		return false
	var picked := await _choice(&"tell", 4, TELL_SECONDS, -1)
	if _dying:
		return false
	if picked == TELL_CORRECT:
		await _line("n_told")
		await _line("ngu_told")
		return true
	await _line("n_caught")
	_member_dies(&"minh_nhat", Vector3(8.0, -6.6, 2.0))
	_member_dies(&"ngu", Vector3(20.0, -6.6, -2.0))
	await _wait(1.5)
	_die(&"DEATH_CH2_LOST_FRIENDS")
	return false


## A corpse's turn: says a word, or mumbles through the gag, or stalls when
## it knows no word that follows (falls, revives and starts a new chain, N2).
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
		# Nothing it knows follows: it stalls the whole turn, falls, comes back.
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


## word: canonical form.
func _corpse_says(bed: int, word: String) -> void:
	_talking_bed = bed
	_corpse_state(bed, &"talk")
	_said(word)
	var shown := _shown(word)
	EventBus.chain_word_spoken.emit(SPEAKERS[bed], shown)
	await _wait(_word_seconds(shown))
	_talking_bed = -1
	_corpse_state(bed, &"gagged" if _gagged.get(bed, false) else &"sit")


## Trung's turn: type a word in 15 seconds, only from the bedroom (D-049).
## False = dead.
func _trung_turn() -> bool:
	_turns += 1
	_set_clock("%02d:%02d" % [6, mini(59, 2 + _turns * 2)])
	var beats: Array = R3_BEATS.get(_turns, [])
	if _loop_known:
		# The friends already read the loop to him when they asked how to pass (D-072).
		beats = beats.filter(func(beat: String) -> bool: return beat != "n_loop" and beat != "ngu_loop")
	_story(beats)
	var seconds := float(_bank.get("seconds", 15.0))
	_typed = ""
	_typed_sent = false
	EventBus.chain_turn_started.emit(&"trung", seconds)
	EventBus.chain_input_requested.emit(seconds)
	var blocked := [false]
	await _wait_until(func() -> bool:
		var deaf := not _in_bedroom()
		if deaf != blocked[0]:
			blocked[0] = deaf
			EventBus.chain_choice_blocked.emit(deaf)
		if deaf and _typed_sent:
			# Nobody hears a word said from the bathroom or the balcony.
			_typed_sent = false
		return _typed_sent, seconds)
	if blocked[0]:
		EventBus.chain_choice_blocked.emit(false)
	if not _typed_sent:
		EventBus.chain_input_closed.emit(&"timeout")
		_die(&"DEATH_CH2_CHAIN_TIMEOUT")
		return false
	if not is_valid_word(_typed):
		EventBus.chain_input_closed.emit(&"wrong")
		_die(&"DEATH_CH2_CHAIN_WRONG")
		return false
	var word := VietText.canon_word(_typed)
	EventBus.chain_input_closed.emit(&"accepted")
	_said(word)
	EventBus.chain_word_spoken.emit(&"trung", _shown(word))
	_loop_run = _loop_run + 1 if _all_gagged() and word in _loop_canon else 0
	return true


## The rule (CH2_DESIGN.md, D-049): two syllables found in the dictionary,
## starting with the last syllable (tone included), not said in the last
## three turns. text: as typed.
func is_valid_word(text: String) -> bool:
	return VietText.syllables(text).size() == 2 and _legal(VietText.canon_word(text))


## A legal word for Trung now (the bot and tests type it): once everyone is
## gagged it leads to Minh Nhật's loop (N5); otherwise a word the corpses can
## follow. Empty when there is none.
func suggest_word() -> String:
	var syllable := _last_syllable()
	if _all_gagged():
		if _last_word in _loop_canon:
			var next := _loop_canon[(_loop_canon.find(_last_word) + 1) % _loop_canon.size()]
			if _legal(next):
				return _dictionary.spelling[next]
		if _steer.has(syllable) and _legal(_steer[syllable]):
			return _dictionary.spelling[_steer[syllable]]
	var choices: Array[String] = []
	for word in _bank_keys:
		if _legal(word) and _bank_word_lives(word):
			choices.append(word)
	# Then words the corpses can follow, then any word at all.
	var any: Array[String] = []
	if choices.is_empty():
		for word in _dictionary.by_first.get(syllable, PackedStringArray()):
			if _legal(word):
				any.append(word)
				if _dictionary.corpse_by_first.has(Ch2Dictionary.last_of(word)):
					choices.append(word)
	var word := _pick(choices if not choices.is_empty() else any)
	return _dictionary.spelling.get(word, "")


## A legal word whose last syllable starts no word the corpses know: the next
## corpse stalls (N2). Empty when there is none (bot, tests).
func suggest_dead_end() -> String:
	var words: Variant = _dictionary.spelling.keys() if _last_word.is_empty() \
		else _dictionary.by_first.get(_last_syllable(), PackedStringArray())
	for word: String in words:
		if _legal(word) and not _dictionary.corpse_by_first.has(Ch2Dictionary.last_of(word)):
			return _dictionary.spelling[word]
	return ""


func _legal(word: String) -> bool:
	return _dictionary.has(word) and word not in _recent \
		and (_last_word.is_empty() or Ch2Dictionary.first_of(word) == _last_syllable())


## A bank word a corpse may say: not a dead end, and (like every corpse word)
## leaving the player enough ways on (build_dictionary.py MIN_CONTINUATIONS).
func _bank_word_lives(word: String) -> bool:
	var key: String = _bank_keys.get(word, "")
	return not key.is_empty() and not bool(_bank.words[key].dead) and _dictionary.corpse_knows(word)


## A word the corpse knows after `syllable` (canonical; empty = start a new
## chain). Prefers the game's own words. Empty when it knows none.
func _corpse_pick(syllable: String) -> String:
	var bank: Array[String] = []
	for word in _bank_keys:
		if _bank_word_lives(word) and word not in _recent and (syllable.is_empty() or Ch2Dictionary.first_of(word) == syllable):
			bank.append(word)
	if syllable.is_empty() or (not bank.is_empty() and _rng.randf() < BANK_WORD_CHANCE):
		return _pick(bank)
	var known: Array[String] = []
	for word in _dictionary.corpse_by_first.get(syllable, PackedStringArray()):
		if word not in _recent:
			known.append(word)
	return _pick(known if not known.is_empty() else bank)


func _pick(words: Array[String]) -> String:
	return words[_rng.randi_range(0, words.size() - 1)] if not words.is_empty() else ""


func _said(word: String) -> void:
	_last_word = word
	_recent.append(word)
	while _recent.size() > int(_bank.get("no_repeat_window", 3)):
		_recent.pop_front()


func _last_syllable() -> String:
	return Ch2Dictionary.last_of(_last_word) if not _last_word.is_empty() else ""


## What the chain shows and voices: the strings key of a bank word (voiced
## whole), otherwise the dictionary spelling (lane E stitches syllables).
func _shown(word: String) -> String:
	if _bank_keys.has(word):
		return _bank_keys[word]
	return _dictionary.spelling.get(word, word)


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
	_safe_streak = 0
	_predicted = false
	_bathroom_door(false)
	_set_steam(0.0)
	if _ch2_music != null:
		_ch2_music.set_round(&"shower")
	await _announce(["SPK_CH2_R3_END"])
	_survivors(5)
	for bed in [1, 2, 4]:
		_corpse_state(bed, &"slump")
	await _line("ngu_five")
	await _announce(["SPK_CH2_R4_INTRO", "RULE_CH2_R4_1", "SPK_CH2_R4_ENJOY"])
	RuleSystem.mark_read(&"ch2_r4_1")
	_set_clock("07:01")
	_think("THINK_CH2_DOOR")
	# D-051: the call goes on while the shower runs; nothing waits for it.
	_story(["ngu_must", "n_wait"])
	var temps: Array = _shower.get("player", [])
	var need := int(_shower.get("need_minutes", 25))
	for slot in temps.size():
		if _dying or not is_inside_tree():
			return
		_set_clock("07:%02d" % mini(59, 2 + slot * 2))
		# D-051: the predictions come at the latest before this slot.
		if not _predicted and slot >= int(_shower.get("predict_latest_slot", 20)):
			if not await _predictions():
				return
		_story(R4_BEATS.get(slot, []))
		if slot == 12:
			# Jumpscare 7: the manager in the steamed-up mirror, one frame.
			var room := _room()
			if room != null and room.has_method("flash_reflection"):
				room.flash_reflection()
				if _shower_audio != null:
					_shower_audio.play_cue("mirror_shiver")
		if not await _shower_slot(int(temps[slot])):
			return
		if _minutes >= need:
			break
		# D-050, D-051: three safe showers in a row, and the friends ask.
		if not _predicted and _safe_streak >= int(_shower.get("predict_streak", 3)):
			if not await _predictions():
				return
	if _minutes < need and not _dying:
		_die(&"DEATH_CH2_SHORT_SHOWER")


## One 2-minute slot: choose, then the water decides. False = dead.
func _shower_slot(temperature: int) -> bool:
	_shower_choice = -1
	_set_shower_buttons(true)
	EventBus.shower_choice_requested.emit(SHOWER_CHOICE_SECONDS)
	await _wait_until(func() -> bool: return _shower_choice != -1, SHOWER_CHOICE_SECONDS)
	_set_shower_buttons(false)
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
	GameState.set_flag(&"ch2_water_temperature", temperature if run else 0)
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
	_safe_streak = _safe_streak + 1 if run else 0
	_set_water(false, temperature)
	GameState.set_flag(&"ch2_shower_minutes", _minutes)
	EventBus.shower_slot_finished.emit(temperature, run, _minutes)
	return true


## D-050, D-051: Minh Nhật, then Ngư, text their last three temperatures and
## ask what to pick next. Trung types an answer for each; wrong or no answer
## scalds that friend and loses the round. False = lost.
func _predictions() -> bool:
	_predicted = true
	GameState.set_flag(&"ch2_predicting", true)
	var seconds := float(_shower.get("predict_seconds", 20.0))
	var lethal := int(_shower.get("lethal", 50))
	for member: String in ["minh_nhat", "ngu"]:
		var data: Dictionary = _shower.predict[member]
		var tag := "n" if member == "minh_nhat" else "ngu"
		await _line(tag + "_ask")
		if member == "ngu":
			EventBus.scare_triggered.emit(&"ngu_water")
		var history := PackedInt32Array()
		for t in data.history:
			history.append(int(t))
		_prediction_member = StringName(member)
		_prediction_text = ""
		_prediction_sent = false
		EventBus.prediction_requested.emit(_prediction_member, history, seconds)
		await _wait_until(func() -> bool: return _prediction_sent, seconds)
		var right := _prediction_sent and is_right_prediction(_prediction_text, int(data.next), lethal)
		_prediction_member = &""
		EventBus.prediction_result.emit(StringName(member), right)
		if not right:
			await _line(tag + "_scream")
			_member_dies(StringName(member), Vector3(20.0, -6.6, -2.0) if member == "ngu" else Vector3(8.0, -6.6, 2.0))
			await _wait(1.5)
			_die(&"DEATH_CH2_LOST_NHAT" if member == "minh_nhat" else &"DEATH_CH2_LOST_NGU")
			return false
		if member == "minh_nhat":
			await _line("n_ok")
		else:
			_story(["ngu_saved"])
	GameState.set_flag(&"ch2_predicting", false)
	return true


## A texted prediction (D-049): "có" / "không" (with or without tone marks),
## or the tens like "3x". next: the friend's next temperature.
static func is_right_prediction(text: String, next: int, lethal: int = 50) -> bool:
	var answer := VietText.plain(text).replace(" ", "").trim_suffix("do")
	if answer in ["co"]:
		return next < lethal
	if answer in ["khong", "ko", "k", "hong"]:
		return next >= lethal
	if answer.length() == 2 and answer.ends_with("x") and answer[0].is_valid_int():
		return int(answer[0]) == next / 10
	return false


func _ending_2() -> void:
	GameState.set_segment(&"end2")
	if _ch2_music != null:
		_ch2_music.set_round(&"")
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
	if _shower_audio != null:
		_shower_audio.set_water(float(temperature), on)
	var room := _room()
	if room != null and room.has_method("set_water"):
		room.set_water(on, temperature)
	if on and temperature >= 40:
		_set_steam(minf(1.0, _steam + 0.35))
	elif not on:
		_set_steam(maxf(0.0, _steam - 0.1))


func _set_steam(level: float) -> void:
	_steam = level
	if _shower_audio != null:
		_shower_audio.set_steam(level)
	var room := _room()
	if room != null and room.has_method("set_steam"):
		room.set_steam(level)
	EventBus.shower_steam_changed.emit(level)


# --- Shared ----------------------------------------------------------------------------

## Story lines on a turn, without holding up the game: queued, one at a time.
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
		match beat:
			"cctv_310": _cctv_310()
			"n_loop":
				_loop_known = true
				GameState.set_flag(&"ch2_loop_known", true)
				await _line(beat)
			_: await _line(beat)
	_chat_running = false


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
		# The contract says "sit"; lane B's pose is "sit_play" (T-172).
		body.set_state(&"sit_play" if state == &"sit" else state)
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
	return _inside_zone(zone)


## "bedroom", "bathroom", "balcony" or "" (lane B's zones, T-172).
func _zone() -> String:
	if _room() == null or _player == null:
		return ""
	for zone_name in ["Bathroom", "Balcony", "Bedroom"]:
		var zone := _room().get_node_or_null("Zones/" + zone_name) as Area3D
		if zone != null and _inside_zone(zone):
			return zone_name.to_lower()
	return ""


func _inside_zone(zone: Area3D) -> bool:
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
	# Things to gag with (N3): lane B's model stays put until lane A's item is taken.
	for entry: Array in [["RagSpot", &"rag", "PROMPT_CH2_TAKE_RAG"], ["TowelSpot", &"towel", "PROMPT_CH2_TAKE_TOWEL"],
			["ShirtSpot", &"shirt", "PROMPT_CH2_TAKE_SHIRT"]]:
		var anchor := _room_anchor(entry[0])
		var item := _instance_on(anchor, "res://scenes/interaction/carry_item.tscn", "Carry_" + String(entry[1]))
		if item == null:
			continue
		item.set("item_id", entry[1])
		item.set("prompt_key", entry[2])
		var model := anchor.get_node_or_null("Model") as Node3D
		var placeholder := item.get_node_or_null("Placeholder") as Node3D
		if model != null and placeholder != null:
			placeholder.visible = false
			item.picked.connect(func(_id: StringName) -> void:
				model.visible = false
				placeholder.visible = true)
			item.dropped.connect(func(_id: StringName) -> void:
				model.visible = true
				placeholder.visible = false)
	# Gag spots at the corpses' mouths (N4).
	for bed in [1, 2, 4]:
		var spot := _instance_on(_room_anchor("Gag%d" % bed), "res://scenes/interaction/gag_spot.tscn", "GagSpot")
		if spot == null:
			continue
		spot.set("bed", bed)
		_hide_placeholder(spot)
		spot.gag_requested.connect(func(b: int, item_id: StringName) -> void:
			_on_gag_requested(b, item_id, spot, CarryItem.held_by(_player)))
	# The swollen bathroom door (N6): three shoves.
	var door_model := room.get_node_or_null("Extension/BathroomDoor") as Node3D
	var door := _instance_on(door_model, "res://scenes/interaction/stuck_door.tscn", "StuckDoor")
	if door != null:
		door.set("room", room)
		_hide_placeholder(door)
		door.bashed.connect(func(count: int) -> void:
			if room.has_method("set_stuck_shake"):
				room.set_stuck_shake(0.35 * count))
		door.opened.connect(func() -> void:
			GameState.set_flag(&"ch2_bathroom_open", true)
			EventBus.scare_triggered.emit(&"bathroom_steam"))
	# Standing under the shower: lane A's area with lane B's box.
	var stall_anchor := _room_anchor("ShowerStall")
	var stall := _instance_on(stall_anchor, "res://scenes/interaction/shower_stall.tscn", "ShowerStallArea")
	var b_shape := stall_anchor.get_node_or_null("Collision") as CollisionShape3D if stall_anchor != null else null
	if stall != null and b_shape != null:
		var shape := stall.get_node("CollisionShape3D") as CollisionShape3D
		shape.shape = b_shape.shape
		shape.global_transform = b_shape.global_transform
	# Steam on the camera only inside the stall (lane D's overlay, T-174).
	var overlay := get_parent().get_node_or_null("BloodOverlay") if get_parent() != null else null
	if stall != null and overlay != null and overlay.has_method("set_shower_inside"):
		stall.player_inside_changed.connect(overlay.set_shower_inside)
	# Có / Không under the screen, and wiping the steam off it.
	for entry: Array in [["ShowerYes", true], ["ShowerNo", false]]:
		var button := _instance_on(_room_anchor(entry[0]), "res://scenes/interaction/shower_choice.tscn", "Choice")
		if button != null:
			button.set("run_water", entry[1])
			button.set("prompt_key", "PROMPT_CH2_SHOWER_YES" if entry[1] else "PROMPT_CH2_SHOWER_NO")
			_hide_placeholder(button)
	# Lane D's LCD (T-174) on lane B's screen; lane A's wipe zone in front of it.
	_shower_lcd = _instance_on(_room_anchor("ShowerScreen"), "res://ui/shower/shower_screen.tscn", "Lcd")
	var wipe := _instance_on(_room_anchor("ShowerScreen"), "res://scenes/interaction/shower_screen.tscn", "Wipe")
	if wipe != null:
		_hide_placeholder(wipe)
		wipe.wiped.connect(_on_screen_wiped)
	# Room 310 on the security cameras (D-046).
	if _cctv_set != null and _cctv_set.get_node_or_null("Room310") != null:
		var r310 := _cctv_set.get_node("Room310")
		if r310.get_node_or_null("Hall/Cam") is Camera3D:
			_add_feed(&"hall_310", "CCTV_CH2_CAM_HALL_310", r310.get_node("Hall/Cam"))
		if r310.get_node_or_null("Cam") is Camera3D:
			_add_feed(&"cam_310", "CCTV_CH2_CAM_310", r310.get_node("Cam"))


## Lane E's rigs (T-175): a voice at each corpse's mouth, the countdown,
## the shower and the chapter music.
func _place_ch2_audio() -> void:
	for bed in [1, 2, 4]:
		var mouth := _room_anchor("Gag%d" % bed)
		if mouth != null:
			var voice := CorpseVoice.new()
			voice.name = "CorpseVoice"
			voice.speaker = String(SPEAKERS[bed])
			mouth.add_child(voice)
	var countdown := Ch2Countdown.new()
	countdown.name = "Ch2Countdown"
	add_child(countdown)
	_shower_audio = ShowerAudio.new()
	_shower_audio.name = "ShowerAudio"
	var stall := _room_anchor("ShowerStall")
	if stall != null:
		stall.add_child(_shower_audio)
	else:
		add_child(_shower_audio)
	_ch2_music = Ch2Music.new()
	_ch2_music.name = "Ch2Music"
	add_child(_ch2_music)
	var door := _room().get_node_or_null("Extension/BathroomDoor/StuckDoor") if _room() != null else null
	if door != null:
		door.bashed.connect(func(count: int) -> void: _shower_audio.play_door_push(clampi(count, 1, 3)))
		door.opened.connect(func() -> void: _shower_audio.play_cue("door_burst"))


## How long a corpse takes to say a word: lane E lowers the pitch (longest .72).
func _word_seconds(key: String) -> float:
	if time_scale < 0.999:
		return CORPSE_SPEAK_SECONDS
	var path := "res://audio/voice/vi/%s.ogg" % key
	if not key.begins_with("WORD_CH2_") or not ResourceLoader.exists(path):
		# A dictionary word: lane E plays its syllables one after the other.
		return maxf(CORPSE_SPEAK_SECONDS, Ch2SyllableBank.seconds_for(key) / 0.72 + 0.3)
	return maxf(CORPSE_SPEAK_SECONDS, (load(path) as AudioStream).get_length() / 0.72 + 0.3)


## Round 3 needs the rag from the bathroom: the door stands open. Round 4 the
## steam has swollen it shut: three shoves (N6).
func _bathroom_door(open: bool) -> void:
	var room := _room()
	if room != null and room.has_method("set_bathroom_door_open"):
		room.set_bathroom_door_open(open)
	var door := room.get_node_or_null("Extension/BathroomDoor/StuckDoor") if room != null else null
	if door == null:
		return
	if open:
		door.set("enabled", false)
	elif door.has_method("reset"):
		door.reset()
	GameState.set_flag(&"ch2_bathroom_open", open)


func _instance_on(parent: Node, scene_path: String, node_name: String) -> Node3D:
	if parent == null or not ResourceLoader.exists(scene_path):
		return null
	var node := (load(scene_path) as PackedScene).instantiate() as Node3D
	node.name = node_name
	parent.add_child(node)
	return node


func _hide_placeholder(node: Node) -> void:
	var placeholder := node.get_node_or_null("Placeholder") as Node3D
	if placeholder != null:
		placeholder.visible = false


func _set_shower_buttons(enabled: bool) -> void:
	for anchor_name in ["ShowerYes", "ShowerNo"]:
		var button := _room_anchor(anchor_name + "/Choice") if _room() != null else null
		if button != null and button.has_method("set_enabled"):
			button.set_enabled(enabled)


func _on_screen_wiped() -> void:
	if _shower_lcd != null and _shower_lcd.has_method("wipe"):
		_shower_lcd.wipe()


func _load_json(path: String) -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return data if data is Dictionary else {}
