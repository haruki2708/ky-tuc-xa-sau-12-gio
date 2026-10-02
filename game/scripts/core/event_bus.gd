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

## A ruled situation was decided. outcome is one of RuleSystem.OUTCOME_*.
## rule_id is empty when no line governs the situation.
signal rule_resolved(situation: StringName, action: StringName, outcome: StringName, rule_id: StringName)

## A wrong choice triggers a world change. Level/audio/UI lanes perform it.
signal consequence_triggered(consequence: StringName, rule_id: StringName)

## A fatal line was broken. Game flow reloads the last checkpoint.
signal player_failed(rule_id: StringName)

# --- Checkpoints (Checkpoint helper) ---

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
