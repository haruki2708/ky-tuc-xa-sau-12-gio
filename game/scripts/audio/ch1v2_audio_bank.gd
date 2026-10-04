class_name Ch1V2AudioBank
extends RefCounted

const DIRECTORY := "res://audio/ch1v2"
const NAMES: Array[String] = [
	"wall_tap_01", "wall_tap_02", "wall_tap_03", "router_power_off", "router_boot",
	"router_online", "power_switch", "power_short", "handle_rattle", "handle_stop",
	"lock_alarm", "kiet_ring", "call_reconnect", "death_fall_back", "death_bed_burst",
	"death_flesh", "death_fall_soft", "death_bed_soft", "cctv_static", "cctv_switch",
]
const LOOPS: Array[String] = ["handle_rattle", "kiet_ring", "cctv_static"]


static func clip(clip_name: String, directory: String = DIRECTORY) -> AudioStream:
	if directory.is_empty() or not NAMES.has(clip_name):
		return null
	return Ch1AudioBank.load_if_present(directory.path_join(clip_name + ".ogg"))
