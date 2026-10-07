class_name Ch4AudioBank
extends RefCounted

const DIRECTORY := "res://audio/ch4"
const VOICE_DIRECTORY := "res://audio/voice/vi"
const NAMES: Array[String] = [
	"decoy_ring", "phone_land", "battery_empty", "door_pound", "wood_crack",
	"wood_splinters", "door_burst", "door_burst_soft", "library", "drizzle",
	"librarian_rise", "books_fall", "shelf_corpse", "back_door_hit", "knife_pull",
	"stairs_turn", "hall_lights", "door_hand", "neck_hand", "pa_laugh",
	"body_fade", "heartbeat", "monitor", "nurse_step_01", "nurse_step_02",
	"hospital_door", "music_sparse", "music_hospital", "music_end",
]
const LOOPS: Array[String] = ["decoy_ring", "library", "drizzle", "music_sparse", "music_hospital"]
const VOICES: Array[String] = [
	"SPK_CH4_REGISTERED", "CHAT_CH4_NGU_GO", "CHAT_CH4_NGU_LECTURE", "CHAT_CH4_NGU_NO_EXIT", "CHAT_CH4_NGU_TRUNG",
	"CHAT_CH4_N_GO", "CHAT_CH4_N_GYM", "CHAT_CH4_N_LINE", "CHAT_CH4_N_WHERE", "CHAT_CH4_N_LOST", "CHAT_CH4_N_GOT",
	"NEAR_CH4_NURSE1_AWAKE", "NEAR_CH4_NURSE1_LUCKY", "NEAR_CH4_NURSE2_QUAKE", "NEAR_CH4_NURSE2_ALL", "NEAR_CH4_NURSE2_ALONE",
]
const SCARES: Array[StringName] = [
	&"librarian_rise", &"books_fall", &"shelf_corpse", &"back_door_hit", &"knife_pull",
	&"stairs_turn", &"hall_lights", &"door_hand", &"neck_hand", &"monitor_skip",
]


static func clip(id: String, directory: String = DIRECTORY) -> AudioStream:
	if directory.is_empty() or not NAMES.has(id):
		return null
	return Ch1AudioBank.load_if_present(directory.path_join(id + ".ogg"))


static func voice(id: String, directory: String = VOICE_DIRECTORY) -> AudioStream:
	if directory.is_empty() or not VOICES.has(id):
		return null
	return Ch1AudioBank.load_if_present(directory.path_join(id + ".ogg"))


static func play(player: Node, id: String, directory: String = DIRECTORY) -> void:
	var stream := clip(id, directory)
	if player.stream == stream and player.playing and LOOPS.has(id):
		return
	player.stop()
	player.stream = stream
	if stream != null:
		player.play()


static func spatial(owner_node: Node, bus_name: StringName, radius: float = 30.0) -> AudioStreamPlayer3D:
	var player := AudioStreamPlayer3D.new()
	player.bus = bus_name
	player.max_distance = radius
	player.max_db = 0.0
	player.unit_size = 3.0
	owner_node.add_child(player)
	return player
