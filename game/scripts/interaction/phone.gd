extends Interactable

signal answered

@export var vibrate_stream: AudioStream

var _ringing: bool = false
var _phase: float = 0.0
var _rest_position: Vector3

@onready var mesh: MeshInstance3D = $Mesh
@onready var vibration: AudioStreamPlayer3D = $Vibration


func _ready() -> void:
	prompt_key = "PROMPT_PHONE"
	enabled = false
	_rest_position = mesh.position
	set_process(false)
	vibration.finished.connect(_repeat_vibration)


func ring() -> void:
	if _ringing:
		return
	_ringing = true
	enabled = true
	_phase = 0.0
	set_process(true)
	vibration.stream = vibrate_stream
	if vibration.stream != null:
		vibration.play()


func _process(delta: float) -> void:
	_phase = fmod(_phase + delta * TAU * 24.0, TAU)
	mesh.position = _rest_position + Vector3(sin(_phase) * 0.002, 0, 0)


func _repeat_vibration() -> void:
	if _ringing and vibration.stream != null:
		vibration.play()


func _on_interact(_player: Node) -> void:
	if not _ringing:
		return
	_ringing = false
	enabled = false
	set_process(false)
	vibration.stop()
	mesh.position = _rest_position
	GameState.set_flag(&"phone_checked", true)
	answered.emit()
	EventBus.subtitle_requested.emit("SUB_PHONE_MIDNIGHT", 4.0)


func _exit_tree() -> void:
	if is_instance_valid(vibration):
		vibration.stop()
