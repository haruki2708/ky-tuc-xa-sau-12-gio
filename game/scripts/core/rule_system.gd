extends Node
## Autoload RuleSystem: holds the night's rule lines, what the player has read
## or marked as suspicious, and decides each ruled situation.
##
## Decision for resolve(situation, action):
##   - matches the genuine line            -> OUTCOME_CORRECT
##   - matches a fake line                 -> OUTCOME_FOLLOWED_FAKE (that line's penalty)
##   - matches nothing, a genuine line exists -> OUTCOME_BROKE_RULE (genuine line's penalty)
##   - no line governs the situation, or only fakes do and the player ignored them
##                                         -> OUTCOME_UNRULED / OUTCOME_CORRECT
## Owner: integrator. Design notes: docs/design/RULE_SYSTEM.md.

const OUTCOME_CORRECT := &"correct"
const OUTCOME_FOLLOWED_FAKE := &"followed_fake"
const OUTCOME_BROKE_RULE := &"broke_rule"
const OUTCOME_UNRULED := &"unruled"

var _rules: Dictionary[StringName, RuleData] = {}
var _order: Array[StringName] = []
var _read: Array[StringName] = []
## What the player saw, per source, in order: {rule_id, source, text_key}.
## text_key can differ from the rule's own text (e.g. garbled on the speaker).
var _entries: Array[Dictionary] = []
var _suspected: Dictionary[StringName, bool] = {}
var _outcomes: Dictionary[StringName, StringName] = {}
## Documents the player pinned to a rule line as evidence (STORY.md §4).
var _evidence: Dictionary[StringName, Array] = {}


## Replaces the current rules. Returns validation errors; on errors nothing changes.
func load_rule_set(rule_set: RuleSet, check_translations: bool = true) -> PackedStringArray:
	# Callers report errors; data mistakes must not abort the game here.
	var errors := rule_set.validate(check_translations)
	if not errors.is_empty():
		return errors
	reset()
	for rule in rule_set.rules:
		_rules[rule.id] = rule
		_order.append(rule.id)
	return errors


## Forgets rules and progress. Does not emit signals.
func reset() -> void:
	_rules.clear()
	_order.clear()
	_read.clear()
	_entries.clear()
	_suspected.clear()
	_outcomes.clear()
	_evidence.clear()


func get_rule(rule_id: StringName) -> RuleData:
	return _rules.get(rule_id)


func all_rule_ids() -> Array[StringName]:
	return _order.duplicate()


func rules_for(situation: StringName) -> Array[RuleData]:
	var found: Array[RuleData] = []
	for rule_id in _order:
		if _rules[rule_id].situation == situation:
			found.append(_rules[rule_id])
	return found


## Records that the player saw a rule line on a source (notebook entry).
## source defaults to the rule's own source; text_key defaults to its text.
## Seeing the same rule on the same source again only updates the text.
func mark_read(rule_id: StringName, source: StringName = &"", text_key: String = "") -> void:
	if not _rules.has(rule_id):
		push_warning("RuleSystem: unknown rule '%s'" % rule_id)
		return
	var rule := _rules[rule_id]
	var seen_source: StringName = source if not source.is_empty() else rule.source
	var seen_text: String = text_key if not text_key.is_empty() else rule.text_key
	var known := false
	for entry in _entries:
		if entry["rule_id"] == rule_id and entry["source"] == seen_source:
			known = true
			if entry["text_key"] == seen_text:
				return
			entry["text_key"] = seen_text
	if not known:
		_entries.append({"rule_id": rule_id, "source": seen_source, "text_key": seen_text})
	EventBus.rule_entry_added.emit(rule_id, seen_source)
	if not _read.has(rule_id):
		_read.append(rule_id)
		EventBus.rule_read.emit(rule_id)


func is_read(rule_id: StringName) -> bool:
	return _read.has(rule_id)


## Rule ids in the order the player first read them (notebook order).
func read_rules() -> Array[StringName]:
	return _read.duplicate()


## Notebook entries in the order seen: {rule_id, source, text_key}.
func read_entries() -> Array[Dictionary]:
	return _entries.duplicate(true)


func set_suspected(rule_id: StringName, suspected: bool) -> void:
	if not _rules.has(rule_id):
		push_warning("RuleSystem: unknown rule '%s'" % rule_id)
		return
	if is_suspected(rule_id) == suspected:
		return
	if suspected:
		_suspected[rule_id] = true
	else:
		_suspected.erase(rule_id)
	EventBus.rule_suspicion_changed.emit(rule_id, suspected)


func is_suspected(rule_id: StringName) -> bool:
	return _suspected.has(rule_id)


## Pins (or unpins) a document the player read as evidence for a rule line.
## Notebook (T-156) shows it under the line; order is the order pinned.
func set_evidence(rule_id: StringName, document_id: StringName, pinned: bool) -> void:
	if not _rules.has(rule_id):
		push_warning("RuleSystem: unknown rule '%s'" % rule_id)
		return
	var docs: Array = _evidence.get(rule_id, [])
	if pinned == docs.has(document_id):
		return
	if pinned:
		docs.append(document_id)
	else:
		docs.erase(document_id)
	if docs.is_empty():
		_evidence.erase(rule_id)
	else:
		_evidence[rule_id] = docs
	EventBus.rule_evidence_changed.emit(rule_id)


## Document ids pinned to a rule line, in the order pinned.
func evidence_for(rule_id: StringName) -> Array[StringName]:
	var found: Array[StringName] = []
	for document_id in _evidence.get(rule_id, []):
		found.append(document_id)
	return found


## Decides a ruled situation, applies deviation and announces consequences.
## Returns {outcome, rule_id, consequence, fatal}.
func resolve(situation: StringName, action: StringName) -> Dictionary:
	var genuine: RuleData
	var followed_fake: RuleData
	var lines := rules_for(situation)
	for rule in lines:
		if not rule.is_fake:
			genuine = rule
		elif rule.action == action and followed_fake == null:
			followed_fake = rule
	var outcome := OUTCOME_UNRULED
	var cause: RuleData
	if genuine != null and genuine.action == action:
		outcome = OUTCOME_CORRECT
		cause = genuine
	elif followed_fake != null:
		outcome = OUTCOME_FOLLOWED_FAKE
		cause = followed_fake
	elif genuine != null:
		outcome = OUTCOME_BROKE_RULE
		cause = genuine
	elif not lines.is_empty():
		outcome = OUTCOME_CORRECT
	_outcomes[situation] = outcome
	var rule_id: StringName = cause.id if cause != null else &""
	var mistake := outcome == OUTCOME_FOLLOWED_FAKE or outcome == OUTCOME_BROKE_RULE
	var consequence: StringName = cause.consequence if mistake else &""
	var fatal: bool = mistake and cause.fatal
	EventBus.rule_resolved.emit(situation, action, outcome, rule_id)
	if mistake:
		GameState.add_deviation(cause.penalty, rule_id)
		if not consequence.is_empty():
			EventBus.consequence_triggered.emit(consequence, rule_id)
		if fatal:
			EventBus.player_failed.emit(rule_id)
	return {"outcome": outcome, "rule_id": rule_id, "consequence": consequence, "fatal": fatal}


## Last outcome of a situation, or &"" if it has not happened yet.
func outcome_of(situation: StringName) -> StringName:
	return _outcomes.get(situation, &"")


## Progress only; the rule lines themselves come from the RuleSet on load.
func to_dict() -> Dictionary:
	var outcomes := {}
	for situation in _outcomes:
		outcomes[String(situation)] = String(_outcomes[situation])
	return {
		"read": _read.map(func(rule_id: StringName) -> String: return String(rule_id)),
		"entries": _entries.map(func(entry: Dictionary) -> Dictionary:
			return {"rule_id": String(entry["rule_id"]), "source": String(entry["source"]), "text_key": entry["text_key"]}),
		"suspected": _suspected.keys().map(func(rule_id: StringName) -> String: return String(rule_id)),
		"outcomes": outcomes,
		"evidence": _evidence_to_dict(),
	}


func _evidence_to_dict() -> Dictionary:
	var out := {}
	for rule_id in _evidence:
		out[String(rule_id)] = _evidence[rule_id].map(func(doc: StringName) -> String: return String(doc))
	return out


## Restores progress for the rules already loaded. Unknown ids are dropped.
func from_dict(data: Dictionary) -> void:
	_read.clear()
	_entries.clear()
	_suspected.clear()
	_outcomes.clear()
	_evidence.clear()
	var evidence: Dictionary = data.get("evidence", {})
	for rule_id: String in evidence:
		if _rules.has(StringName(rule_id)):
			_evidence[StringName(rule_id)] = evidence[rule_id].map(func(doc: String) -> StringName: return StringName(doc))
	for entry in data.get("entries", []):
		if entry is Dictionary and _rules.has(StringName(str(entry.get("rule_id", "")))):
			_entries.append({"rule_id": StringName(str(entry["rule_id"])),
				"source": StringName(str(entry.get("source", ""))), "text_key": str(entry.get("text_key", ""))})
	for rule_id in data.get("read", []):
		if _rules.has(StringName(rule_id)):
			_read.append(StringName(rule_id))
	for rule_id in data.get("suspected", []):
		if _rules.has(StringName(rule_id)):
			_suspected[StringName(rule_id)] = true
	var outcomes: Dictionary = data.get("outcomes", {})
	for situation: String in outcomes:
		_outcomes[StringName(situation)] = StringName(outcomes[situation])
