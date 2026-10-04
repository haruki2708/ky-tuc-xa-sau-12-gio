extends Node3D
## Chapter 1 scene: floor 4, room 407 at 4 a.m., the PA speaker, room 407's
## papers, and the Chapter1Director (T-150). The old demo night stays in
## main.tscn until it is removed after chapter 1.

const READABLE := preload("res://scenes/interaction/readable.tscn")
const SPEAKER_SCRIPT := preload("res://scripts/audio/speaker.gd")
const DIRECTOR := preload("res://scripts/core/chapter1_director.gd")
## Ceiling fan blade speed (rad/s), as in the demo.
const FAN_SPEED: float = 15.0
const PAPER_PICK_DEPTH: float = 0.15
const END_CARD_MIN_SECONDS: float = 4.0
const END_CARD_MAX_SECONDS: float = 40.0

## Room 407 papers until lane B's anchors (T-153) exist: [document, position,
## rotation (degrees), size]. Desk papers lie flat; locker papers face the room.
const PAPERS: Array = [
	[&"ch1_dat_card", Vector3(32.25, 0.79, -4.45), Vector3(-90, 0, 0), Vector2(0.09, 0.06)],
	[&"ch1_dat_note", Vector3(31.85, 0.79, -4.4), Vector3(-90, 15, 0), Vector2(0.15, 0.21)],
	[&"ch1_phuc_schedule", Vector3(30.58, 1.35, -0.45), Vector3(0, 90, 0), Vector2(0.21, 0.3)],
	[&"ch1_viet_photo", Vector3(30.58, 1.3, -1.25), Vector3(0, 90, 0), Vector2(0.15, 0.1)],
]

var _fan_rotors: Array[Node3D] = []
var _end_card_key_pressed: bool = false


func _ready() -> void:
	_place_speaker()
	_place_papers()
	var light := $Floor4.get_node_or_null("Room407/Room407MainLight") as Node3D
	if light != null:
		light.visible = false
	var music := MusicDirector.new()
	music.name = "MusicDirector"
	add_child(music)
	for rotor in $Floor4.find_children("fan_rotor", "", true, false):
		_fan_rotors.append(rotor as Node3D)
	$Chapter1Director.restart_requested.connect(_on_restart_requested)
	$Chapter1Director.chapter_done.connect(_on_chapter_done)


func _process(delta: float) -> void:
	for rotor in _fan_rotors:
		rotor.rotate_y(FAN_SPEED * delta)


func _place_speaker() -> void:
	var anchor := $Floor4.get_node_or_null("Anchors/Speaker") as Node3D
	if anchor == null:
		return
	var speaker := AudioStreamPlayer3D.new()
	speaker.name = "FloorSpeaker"
	speaker.set_script(SPEAKER_SCRIPT)
	speaker.unit_size = 10.0
	add_child(speaker)
	speaker.global_transform = anchor.global_transform
	$Chapter1Director.speaker_path = $Chapter1Director.get_path_to(speaker)


func _place_papers() -> void:
	for entry: Array in PAPERS:
		var paper := READABLE.instantiate()
		paper.name = String(entry[0]).to_pascal_case()
		paper.document_id = entry[0]
		paper.size = entry[3]
		add_child(paper)
		paper.global_position = entry[1]
		paper.rotation_degrees = entry[2]
		paper.pick_depth = PAPER_PICK_DEPTH


## A death: reload the scene and resume at the checkpoint. Only the running
## game reloads; tests that instance the scene do not.
func _on_restart_requested(checkpoint_id: StringName) -> void:
	if get_tree().current_scene != self:
		return
	DIRECTOR.resume_checkpoint = checkpoint_id
	get_tree().paused = false
	get_tree().reload_current_scene()


## After the end card: back to the title on any key (after a short beat) or by
## itself after a while. Chapter 2 is unlocked; the night's checkpoint is done.
func _on_chapter_done() -> void:
	if get_tree().current_scene != self:
		return
	Checkpoint.clear()
	await get_tree().create_timer(END_CARD_MIN_SECONDS).timeout
	var deadline := Time.get_ticks_msec() + int(END_CARD_MAX_SECONDS * 1000.0)
	_end_card_key_pressed = false
	while not _end_card_key_pressed and Time.get_ticks_msec() < deadline:
		await get_tree().process_frame
	App.return_to_title()


func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		_end_card_key_pressed = true
