class_name FlickerBuzz
extends AudioStreamPlayer3D
## The ballast crackle while a tube flickers for a long stretch (chapter 1, manager at the door).
## LightHum already gates its hum on the light's energy; this only adds the crackle, repeated with
## short random gaps so the 1.5 s clip does not loop audibly. Owner asked for it after T-218.

const CLIP: AudioStream = preload("res://audio/sfx/fluorescent_flicker.ogg")
const GAP_MIN := 0.25
const GAP_MAX := 1.4

var active: bool = false:
	set(value):
		active = value
		_gap = 0.0
		if not value:
			stop()
		elif is_inside_tree():
			play()
var _gap: float = 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	stream = CLIP
	finished.connect(_on_finished)
	if active:
		play()


func _on_finished() -> void:
	if active:
		_gap = _rng.randf_range(GAP_MIN, GAP_MAX)


func _process(delta: float) -> void:
	if not active or _gap <= 0.0:
		return
	_gap -= delta
	if _gap <= 0.0:
		play()
