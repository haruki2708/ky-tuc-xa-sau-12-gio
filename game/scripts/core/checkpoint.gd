class_name Checkpoint
extends RefCounted
## Saves and restores GameState + RuleSystem progress as JSON.
## The checkpoint id names where the player resumes; scenes listen to
## EventBus.checkpoint_loaded and move the player to the matching spawn.

const DEFAULT_PATH := "user://checkpoint.json"
const VERSION := 1


static func save(checkpoint_id: StringName, path: String = DEFAULT_PATH) -> Error:
	var data := {
		"version": VERSION,
		"id": String(checkpoint_id),
		"game_state": GameState.to_dict(),
		"rules": RuleSystem.to_dict(),
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	EventBus.checkpoint_saved.emit(checkpoint_id)
	return OK


## Returns the restored checkpoint id, or &"" if there is no usable save.
static func restore(path: String = DEFAULT_PATH) -> StringName:
	if not FileAccess.file_exists(path):
		return &""
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary or int(parsed.get("version", 0)) != VERSION:
		push_warning("Checkpoint: unreadable or old save at " + path)
		return &""
	var checkpoint_id := StringName(str(parsed.get("id", "")))
	GameState.from_dict(parsed.get("game_state", {}))
	RuleSystem.from_dict(parsed.get("rules", {}))
	EventBus.checkpoint_loaded.emit(checkpoint_id)
	return checkpoint_id


## The id of a usable save without restoring it, or &"" (title screen).
static func peek_id(path: String = DEFAULT_PATH) -> StringName:
	if not FileAccess.file_exists(path):
		return &""
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary or int(parsed.get("version", 0)) != VERSION:
		return &""
	return StringName(str(parsed.get("id", "")))


static func exists(path: String = DEFAULT_PATH) -> bool:
	return FileAccess.file_exists(path)


static func clear(path: String = DEFAULT_PATH) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
