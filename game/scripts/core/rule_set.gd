class_name RuleSet
extends Resource
## All rule lines of a night. Authored as a .tres file under res://data/rules/.

const TEXT_KEY_PREFIX := "RULE_"

@export var rules: Array[RuleData] = []


## Returns human-readable problems; empty means the set is usable.
## check_translations also requires every text_key to exist in strings.csv.
func validate(check_translations: bool = true) -> PackedStringArray:
	var errors: PackedStringArray = []
	var ids: Dictionary[StringName, bool] = {}
	var genuine: Dictionary[StringName, RuleData] = {}
	for rule in rules:
		if rule == null:
			errors.append("null rule entry")
			continue
		var label := "rule '%s'" % rule.id
		if rule.id.is_empty():
			errors.append("rule with empty id")
		elif ids.has(rule.id):
			errors.append("%s: duplicate id" % label)
		ids[rule.id] = true
		if not rule.text_key.begins_with(TEXT_KEY_PREFIX):
			errors.append("%s: text_key must start with %s" % [label, TEXT_KEY_PREFIX])
		elif check_translations and String(TranslationServer.translate(rule.text_key)) == rule.text_key:
			errors.append("%s: text_key %s missing from strings.csv" % [label, rule.text_key])
		if rule.situation.is_empty():
			errors.append("%s: empty situation" % label)
		if rule.action.is_empty():
			errors.append("%s: empty action" % label)
		if not rule.is_fake and not rule.situation.is_empty():
			if genuine.has(rule.situation):
				errors.append("%s: second genuine line for situation '%s'" % [label, rule.situation])
			else:
				genuine[rule.situation] = rule
	# A fake line that agrees with the genuine one cannot mislead anyone.
	for rule in rules:
		if rule != null and rule.is_fake and genuine.has(rule.situation):
			if genuine[rule.situation].action == rule.action:
				errors.append("rule '%s': fake line has the same action as the genuine one" % rule.id)
	return errors
