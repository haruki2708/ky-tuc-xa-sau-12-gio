class_name ZombieAudio
extends Node3D
## Attach beneath a Zombie, then register with one Ch3HordeAudio.
## Gameplay owns hunting, movement, visibility and stun recovery.

@export var zombie: Node3D
@export var hissing: bool = false
@export_dir var sound_directory: String = Ch3AudioBank.DIRECTORY
var hunting: bool = false
var audible: bool = false
var eligible: bool = true
var _voice: AudioStreamPlayer3D
var _foley: AudioStreamPlayer3D
var _step_index: int = 0
var _door_index: int = 0
var _stopped: bool = false


func _ready() -> void:
	if zombie == null:
		zombie = get_parent() as Node3D
	_voice = _source(&"SFX")
	_foley = _source(&"Footsteps")
	EventBus.zombie_woke.connect(_on_woke)
	EventBus.zombie_stunned.connect(_on_stunned)


func _source(bus_name: StringName) -> AudioStreamPlayer3D:
	var player := AudioStreamPlayer3D.new()
	player.bus = bus_name
	player.max_distance = 60.0
	player.unit_size = 2.0
	add_child(player)
	return player


func set_hunting(value: bool) -> void:
	hunting = value and not _stopped
	if not hunting:
		set_audible(false)


func set_eligible(value: bool) -> void:
	eligible = value
	if not eligible:
		set_audible(false)


func set_audible(value: bool) -> void:
	audible = value and hunting and eligible and not _stopped
	if not is_node_ready():
		return
	if audible:
		Ch3AudioBank.play(_voice, "zombie_hiss" if hissing else "zombie_growl", sound_directory)
	else:
		_voice.stop()
		_foley.stop()


func play_step() -> void:
	if audible:
		_foley.bus = &"Footsteps"
		Ch3AudioBank.play(_foley, "zombie_drag_%02d" % (_step_index % 2 + 1), sound_directory)
		_step_index += 1


func play_door_hit() -> void:
	if audible:
		_foley.bus = &"SFX"
		Ch3AudioBank.play(_foley, "door_pound_%02d" % (_door_index % 2 + 1), sound_directory)
		_door_index += 1


func _on_woke(source: Node3D) -> void:
	if source == zombie:
		set_hunting(true)


func _on_stunned(source: Node3D, _seconds: float) -> void:
	if source == zombie:
		set_hunting(false)
	# Never predict gameplay recovery with a second timer.


func stop_emitting() -> void:
	_stopped = true
	set_hunting(false)
