class_name Ch3AudioBank
extends RefCounted

const DIRECTORY := "res://audio/ch3"
const NAMES: Array[String] = [
	"zombie_growl", "zombie_hiss", "zombie_drag_01", "zombie_drag_02", "horde",
	"door_pound_01", "door_pound_02", "bar_swing", "bar_hit", "bar_miss", "bar_bend", "bar_break", "pant",
	"run_grass_01", "run_grass_02", "run_grass_03", "run_grass_04",
	"run_concrete_01", "run_concrete_02", "run_concrete_03", "run_concrete_04",
	"wind", "stadium", "canteen", "stairs", "far_scream", "rescue_siren", "baton_buzz",
	"death_zombie_grab", "death_zombie_soft", "death_guard_shock", "death_guard_soft",
	"music_run", "music_wave", "music_end",
]
const LOOPS: Array[String] = [
	"zombie_growl", "zombie_hiss", "horde", "wind", "stadium", "canteen", "stairs",
	"rescue_siren", "baton_buzz", "music_run", "music_wave",
]


static func clip(clip_name: String, directory: String = DIRECTORY) -> AudioStream:
	if directory.is_empty() or not NAMES.has(clip_name):
		return null
	return Ch1AudioBank.load_if_present(directory.path_join(clip_name + ".ogg"))


static func play(player: Node, clip_name: String, directory: String = DIRECTORY) -> void:
	var stream := clip(clip_name, directory)
	if player.stream == stream and player.playing and LOOPS.has(clip_name):
		return
	player.stop()
	player.stream = stream
	if stream != null:
		player.play()
