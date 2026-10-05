class_name Ch2AudioBank
extends RefCounted

const DIRECTORY := "res://audio/ch2"
const NAMES: Array[String] = [
	"corpse_mumble", "corpse_fall", "corpse_revive", "corpse_gag", "chain_tick", "shower_beep",
	"door_push_01", "door_push_02", "door_push_03", "door_burst",
	"water_cold", "water_warm", "water_boiling", "steam_hiss", "mirror_shiver",
	"death_corpse_lunge", "death_scald", "death_corpse_soft", "death_scald_soft",
	"camera_room_loss", "music_chain", "music_shower", "music_turn",
]
const LOOPS: Array[String] = ["corpse_mumble", "water_cold", "water_warm", "water_boiling", "steam_hiss", "music_chain", "music_shower"]


static func clip(clip_name: String, directory: String = DIRECTORY) -> AudioStream:
	if directory.is_empty() or not NAMES.has(clip_name):
		return null
	return Ch1AudioBank.load_if_present(directory.path_join(clip_name + ".ogg"))
