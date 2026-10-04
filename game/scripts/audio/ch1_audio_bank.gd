class_name Ch1AudioBank
extends RefCounted
## Original T-158 Foley. Missing banks are intentionally safe for staged integration.

const DIRECTORY := "res://audio/ch1"
const NAMES: Array[String] = [
	"manager_step_01", "manager_step_02", "manager_drag", "manager_knock",
	"slash_mattress_01", "slash_mattress_02", "slash_wood_01", "slash_wood_02",
	"manager_kill", "kill_soft", "slash_soft", "scream_01", "scream_02", "scream_03", "scream_04",
	"call_ring", "call_disconnect", "call_drop", "blood_drip", "corpse_rustle", "heartbeat",
	"breath_gasp", "bunk_climb", "bunk_creak", "wall_knock", "locker_unlock", "charger_plug",
	"pa_on", "pa_burst",
]
const LOOPS: Array[String] = ["manager_drag", "call_ring", "blood_drip"]


static func clip(clip_name: String, directory: String = DIRECTORY) -> AudioStream:
	if directory.is_empty() or not NAMES.has(clip_name):
		return null
	return load_if_present(directory.path_join(clip_name + ".ogg"))


static func load_if_present(path: String) -> AudioStream:
	if not ResourceLoader.exists(path, "AudioStream"):
		return null
	return load(path) as AudioStream


static func locale() -> String:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var value: Variant = config.get_value("ui", "locale", "vi")
		if value is String and value in ["vi", "en"]:
			return value
	return "vi"


static func reduced() -> bool:
	var config := ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var value: Variant = config.get_value("accessibility", "reduce_scares", false)
		return value is bool and value
	return false


static func voice(key: String, prefix: String, directory: String = "res://audio/voice") -> AudioStream:
	if directory.is_empty() or not key.begins_with(prefix):
		return null
	# Translation keys only; reject traversal, separators and invalid filenames.
	for character in key:
		if not character in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_":
			return null
	return load_if_present(directory.path_join(locale()).path_join(key + ".ogg"))
