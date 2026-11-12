class_name HingedDoorAudio
extends AudioStreamPlayer3D
## T-244: quiet leaf-mounted sounds. Door motion remains owned by HingedDoor.

const WOOD_OPEN := preload("res://audio/hinged_doors/wood_open.ogg")
const WOOD_CLOSE := preload("res://audio/hinged_doors/wood_close.ogg")
const GLASS_OPEN := preload("res://audio/hinged_doors/aluminium_glass_open.ogg")
const GLASS_CLOSE := preload("res://audio/hinged_doors/aluminium_glass_close.ogg")
const DOORS: Array[String] = ["Extension/BathroomDoor", "Extension/BalconyDoor"]

var _open_clip: AudioStream
var _close_clip: AudioStream
var _close_pending: bool = false


## Call after Protagonist.attach. Safe to repeat; unfitted doors remain untouched.
static func attach_all(room: Node3D) -> void:
	if not is_instance_valid(room):
		return
	for path: String in DOORS:
		var door := HingedDoor.of(room.get_node_or_null(path))
		if door == null or door.has_node("HingedDoorAudio"):
			continue
		var source := HingedDoorAudio.new()
		source.name = "HingedDoorAudio"
		var wood: bool = path == DOORS[0]
		source._open_clip = WOOD_OPEN if wood else GLASS_OPEN
		source._close_clip = WOOD_CLOSE if wood else GLASS_CLOSE
		source.bus = &"SFX"
		source.volume_db = -6.0
		source.max_db = -6.0
		source.unit_size = 1.0
		source.max_distance = 8.0
		source.max_polyphony = 1
		door.add_child(source)
		# Grip markers are on the moving leaf, so a fixed local offset follows it.
		if not door.grips.is_empty():
			source.global_position = door.grips[0].global_position
		door.swung.connect(source._on_swung)
		door.settled.connect(source._on_settled)


func _on_swung(open: bool, seconds: float) -> void:
	stop()
	_close_pending = false
	# Instant chapter/reset changes and interrupted motion must never leave a latch queued.
	if not is_finite(seconds) or seconds <= 0.0:
		return
	_close_pending = not open
	if open:
		stream = _open_clip
		play()


func _on_settled(open: bool) -> void:
	stop()
	if not open and _close_pending:
		stream = _close_clip
		play()
	_close_pending = false
