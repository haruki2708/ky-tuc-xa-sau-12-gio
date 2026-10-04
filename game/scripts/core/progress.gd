class_name Progress
extends RefCounted
## Progress across chapters (D-029, T-150): which nights are unlocked, and
## story facts that outlive one night (who was replaced on night 2, total
## deviation for the ending, clues found). The checkpoint file only covers the
## night in progress. Owner: integrator.

const DEFAULT_PATH := "user://progress.json"
const VERSION := 1
const CHAPTER_COUNT := 4


## Highest chapter the player may start from the title screen (at least 1).
static func unlocked_chapter(path: String = DEFAULT_PATH) -> int:
	return clampi(int(_read(path).get("unlocked", 1)), 1, CHAPTER_COUNT)


## Unlocks chapters up to and including this one. Never locks anything.
static func unlock(chapter: int, path: String = DEFAULT_PATH) -> void:
	var data := _read(path)
	data["unlocked"] = clampi(maxi(chapter, int(data.get("unlocked", 1))), 1, CHAPTER_COUNT)
	_write(data, path)


## A fact that lasts across nights. Only bool/int/float/String are kept.
static func set_fact(key: StringName, value: Variant, path: String = DEFAULT_PATH) -> void:
	if not (value is bool or value is int or value is float or value is String):
		push_warning("Progress fact '%s' must be bool, int, float or String" % key)
		return
	var data := _read(path)
	var facts: Dictionary = data.get("facts", {})
	facts[String(key)] = {"type": typeof(value), "value": value}
	data["facts"] = facts
	_write(data, path)


static func get_fact(key: StringName, default: Variant = null, path: String = DEFAULT_PATH) -> Variant:
	var facts: Dictionary = _read(path).get("facts", {})
	if not facts.has(String(key)):
		return default
	var entry: Dictionary = facts[String(key)]
	# JSON turns every number into float; restore the original type.
	return type_convert(entry.get("value"), int(entry.get("type", TYPE_NIL)))


static func clear(path: String = DEFAULT_PATH) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


static func _read(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary or int(parsed.get("version", 0)) != VERSION:
		push_warning("Progress: unreadable or old file at " + path)
		return {}
	return parsed


static func _write(data: Dictionary, path: String) -> void:
	data["version"] = VERSION
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("Progress: cannot write " + path)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
