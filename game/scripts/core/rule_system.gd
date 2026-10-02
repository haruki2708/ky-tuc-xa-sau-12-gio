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
var _suspected: Dictionary[StringName, bool] = {}
var _outcomes: Dictionary[StringName, StringName] = {}


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
	_suspected.clear()
	_outcomes.clear()


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


func mark_read(rule_id: StringName) -> void:
	if not _rules.has(rule_id):
		push_warning("RuleSystem: unknown rule '%s'" % rule_id)
		return
	if _read.has(rule_id):
		return
	_read.append(rule_id)
	EventBus.rule_read.emit(rule_id)


func is_read(rule_id: StringName) -> bool:
	return _read.has(rule_id)


## Rule ids in the order the player first read them (notebook order).
func read_rules() -> Array[StringName]:
	return _read.duplicate()


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
		"suspected": _suspected.keys().map(func(rule_id: StringName) -> String: return String(rule_id)),
		"outcomes": outcomes,
	}


## Restores progress for the rules already loaded. Unknown ids are dropped.
func from_dict(data: Dictionary) -> void:
	_read.clear()
	_suspected.clear()
	_outcomes.clear()
	for rule_id in data.get("read", []):
		if _rules.has(StringName(rule_id)):
			_read.append(StringName(rule_id))
	for rule_id in data.get("suspected", []):
		if _rules.has(StringName(rule_id)):
			_suspected[StringName(rule_id)] = true
	var outcomes: Dictionary = data.get("outcomes", {})
	for situation: String in outcomes:
		_outcomes[StringName(situation)] = StringName(outcomes[situation])
