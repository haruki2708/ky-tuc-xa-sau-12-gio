extends Node
## Global signals shared across lanes. Emit/connect here instead of coupling
## systems directly. Owner: integrator — request new signals in your task card.

## Player focused (or stopped focusing) an interactable. prompt_key is a
## translation key, empty when nothing is focused.
signal interaction_focus_changed(prompt_key: String)

## Player used an interactable.
signal interacted(target: Node)

## Show a subtitle line. text_key is a translation key; duration in seconds.
signal subtitle_requested(text_key: String, duration: float)

## The pause menu paused (true) or resumed (false) the game. Systems that
## capture the mouse or run real-time effects follow this instead of Esc.
signal game_paused(paused: bool)

## A value in user://settings.cfg changed (see docs/SETTINGS.md). Readers reload
## the key they care about; the writer saves the file before emitting.
signal settings_changed(section: String, key: String)

# --- Game state (GameState autoload) ---

## In-game clock changed. minutes counts from 00:00 of the first day and keeps
## growing past midnight (23:50 = 1430, 00:30 = 1470).
signal time_changed(minutes: int)

## Story segment changed (e.g. &"tutorial", &"roll_call").
signal segment_changed(segment: StringName)

## "Deviation" level changed. reason is usually the rule id that caused it.
signal deviation_changed(level: int, reason: StringName)

## A story flag changed (door locked, light switched off...).
signal flag_changed(flag: StringName, value: Variant)

# --- Night rules (RuleSystem autoload) ---

## The player read a rule line for the first time (notebook adds it).
signal rule_read(rule_id: StringName)

## The player saw a rule line on a source (new notebook entry, or its text
## changed). Notebook rebuilds from RuleSystem.read_entries().
signal rule_entry_added(rule_id: StringName, source: StringName)

## The player marked or unmarked a rule line as suspicious in the notebook.
signal rule_suspicion_changed(rule_id: StringName, suspected: bool)

## Documents pinned as evidence to a rule line changed (RuleSystem.evidence_for).
signal rule_evidence_changed(rule_id: StringName)

## A ruled situation was decided. outcome is one of RuleSystem.OUTCOME_*.
## rule_id is empty when no line governs the situation.
signal rule_resolved(situation: StringName, action: StringName, outcome: StringName, rule_id: StringName)

## A wrong choice triggers a world change. Level/audio/UI lanes perform it.
signal consequence_triggered(consequence: StringName, rule_id: StringName)

## A fatal line was broken. Game flow reloads the last checkpoint.
signal player_failed(rule_id: StringName)

# --- Checkpoints (Checkpoint helper) ---

## A checkpoint is about to be written: last chance to put live state (phone
## battery, call history...) into GameState flags so it is saved too.
signal checkpoint_saving(checkpoint_id: StringName)

## A checkpoint was written. id names the place the player resumes from.
signal checkpoint_saved(checkpoint_id: StringName)

## A checkpoint was restored. Scenes move the player to the matching spawn.
signal checkpoint_loaded(checkpoint_id: StringName)

# --- Documents (T-117: lane A readable objects, lane D close-up view) ---

## A readable paper/board/log was opened. Data: DocumentData.load_by_id(id).
signal document_opened(document_id: StringName)

## The close-up view of a document was closed.
signal document_closed(document_id: StringName)

# --- Scares and chases (D-024, T-136; music T-133 listens) ---

## One of the demo's scripted scares: &"corridor_glimpse" (seg3),
## &"mirror_stare" (seg5), &"lost" (a real loss: answering Lâm or deviation 5).
signal scare_triggered(scare_id: StringName)

## A chase began: &"corridor" (seg3) or &"mirror" (seg5).
signal chase_started(chase_id: StringName)

## A chase ended: caught = true when the pursuer got the player.
signal chase_ended(chase_id: StringName, caught: bool)

# --- Chapters (T-150, docs/design/STORY.md) ---

## A chapter (one night, 1..4) began or was resumed from a checkpoint.
signal chapter_started(chapter: int)

## The player reached the end of a chapter; the next one is unlocked.
signal chapter_finished(chapter: int)

# --- Survival (T-151 lane A; entities T-152 listen) ---

## Something made a sound an entity may hear. radius is how far it carries in
## metres (STORY.md §5.1: run 12, walk 5, crouch 1.5, door slam 15, drop 10).
## source names the cause: &"step", &"door", &"drop", &"breath"...
signal noise_emitted(position: Vector3, radius: float, source: StringName)

## The player entered (true) or left (false) a hiding spot. spot_kind is
## &"bed", &"locker", &"stall" or &"net" (mosquito net: STORY.md §5.1).
signal player_hidden(hidden: bool, spot_kind: StringName)

## The player started (true) or stopped holding their breath while hidden.
signal breath_held(holding: bool)

# --- Phone (T-151 item, T-155 screen; D-027) ---

## The group call dropped (network down, T-160 N2): the phone shows "lost
## connection"; spoken lines meanwhile are not shown or heard.
signal phone_call_lost(call_id: StringName)

## The group call came back after phone_call_lost.
signal phone_call_restored(call_id: StringName)

## Minh Nhật got into the dorm's security cameras (round 2, D-041): the
## phone's Camera tab opens. Feeds are nodes in group "cctv_feed" with
## camera_id: StringName, label_key: String and get_texture() -> Texture2D.
signal cctv_unlocked()

## Something happens on a camera: the phone buzzes and, when raised, shows it.
signal cctv_focus_requested(camera_id: StringName)

## The player knocked once on a shared wall (T-161). wall_id: &"wall_406",
## &"wall_408". The chapter director decodes the taps (tap code, T-160 N3).
signal wall_tapped(wall_id: StringName)

## The player raised (true) or lowered the phone (Q).
signal phone_raised(raised: bool)

## The phone flashlight was switched on or off (F).
signal flashlight_toggled(on: bool)

## Phone battery changed, 0..100. At 0 the flashlight cannot turn on.
signal phone_battery_changed(percent: float)

## A text message arrived. Data: MessageData.load_by_id(message_id).
## In the group call (STORY.md v2) every spoken line also arrives here, with
## MessageData.spoken = true; lane E plays its voice, lane D shows the text.
signal phone_message_received(message_id: StringName)

## Someone is calling (&"stranger_call": Minh Nhật's group call, ch. 1).
signal phone_call_incoming(call_id: StringName)

## The player answered the call (lane D's phone screen emits it).
signal phone_call_answered(call_id: StringName)

## A group chat member joined, went silent (dead) or left.
## state: &"joined", &"dead", &"left". Names: MessageData sender ids.
signal chat_member_changed(member_id: StringName, state: StringName)

## The story asks the player to say something in the group call. option_keys
## are translation keys; lane D shows them and emits chat_choice_made.
signal chat_choice_requested(choice_id: StringName, option_keys: PackedStringArray)

## The player picked option index (0-based), or -1 when time ran out.
signal chat_choice_made(choice_id: StringName, index: int)

## The speaker announced how many students are still alive.
signal survivor_count_changed(count: int)

# --- Puzzles (T-151 stations, T-155 close-up panels) ---

## The player opened a puzzle close-up (combination lock, fuse box...).
signal puzzle_opened(puzzle_id: StringName)

## The puzzle close-up was closed (solved or not).
signal puzzle_closed(puzzle_id: StringName)

## The puzzle was solved. Story and the station react; the panel closes.
signal puzzle_solved(puzzle_id: StringName)

# --- Entities (T-152; audio T-158 and music listen) ---

## An entity changed state. entity_id: &"walker" (Người đi dép), &"watcher"
## (Người thứ năm). state for the walker: &"idle", &"patrol", &"listen",
## &"search", &"chase", &"lost"; for the watcher: &"hidden", &"watching",
## &"closing_in".
signal entity_state_changed(entity_id: StringName, state: StringName)

## A watcher period began (true) or ended. Ambience fades out around the
## watcher while it lasts (STORY.md §5.2: silence is its only sign).
signal watcher_active(active: bool, position: Vector3)

## The player's death scene begins (D-042), before player_failed and the
## death screen. kind: &"fall_back", &"manager_kill", &"bed_burst", &"none";
## chapter 2: &"corpse_lunge" (word chain lost), &"scald" (boiling shower).
signal player_death_started(kind: StringName)

## An entity caught the player. Story adds deviation and reloads.
signal player_caught(entity_id: StringName)

# --- Chapter 2 "Trò chơi" (CH2_DESIGN.md, T-170…T-175) ---

## Round 3 word chain: a turn starts. speaker: &"phuc" (bed 1), &"viet"
## (bed 2), &"dat" (bed 4) or &"trung" (the player). seconds: time allowed.
signal chain_turn_started(speaker: StringName, seconds: float)

## A word was said in the chain. word_key: strings key (WORD_CH2_*); empty
## when a gagged or stuck corpse only mumbles.
signal chain_word_spoken(speaker: StringName, word_key: String)

## The player's turn: four word keys (one right, three traps) and the time.
## Lane D shows them with a countdown; the player answers by index.
signal chain_choice_requested(option_keys: PackedStringArray, seconds: float)

## The player picked an option (0-based) or ran out of time (-1).
signal chain_choice_made(index: int)

## The player is out of earshot (bathroom, balcony): the choice panel shows
## "Họ không nghe thấy bạn" and does not accept answers while true.
signal chain_choice_blocked(blocked: bool)

## A corpse changed state (lane B poses, lane E sounds). bed: 1, 2 or 4.
## state: &"sit" (playing), &"talk", &"gagged", &"mumble", &"fall",
## &"revive", &"lunge", &"slump" (round over).
signal corpse_state_changed(bed: int, state: StringName)

## Round 4 shower: the screen asks "Có / Không" for the next 2 minutes.
signal shower_choice_requested(seconds: float)

## The player answered on the screen (true = run the water) or let the
## countdown run out (no signal; core decides).
signal shower_choice_made(run_water: bool)

## A 2-minute slot ran: the temperature shown on the screen, whether the
## water ran, and the minutes counted so far towards 25.
signal shower_slot_finished(temperature: int, ran: bool, minutes_counted: int)

## Steam in the bathroom, 0..1 (fog on the screen, haze on the camera).
signal shower_steam_changed(level: float)

