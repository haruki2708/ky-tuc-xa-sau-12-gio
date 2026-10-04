extends Node3D
## Chapter 1 scene: floor 4, room 407 at 4 a.m., the PA speaker, room 407's
## papers, and the Chapter1Director (T-150). The old demo night stays in
## main.tscn until it is removed after chapter 1.

const READABLE := preload("res://scenes/interaction/readable.tscn")
const SPEAKER_SCRIPT := preload("res://scripts/audio/speaker.gd")
const DIRECTOR := preload("res://scripts/core/chapter1_director.gd")
const MANAGER_AUDIO := preload("res://audio/entities/manager_audio.tscn")
## Ceiling fan blade speed (rad/s), as in the demo.
const FAN_SPEED: float = 15.0
const PAPER_PICK_DEPTH: float = 0.15
const END_CARD_MIN_SECONDS: float = 4.0
const END_CARD_MAX_SECONDS: float = 40.0

## Room 407 papers on lane B's anchors (T-153, under Room407/Anchors):
## [document, anchor, offset, rotation (degrees), size]. Desk papers lie flat;
## the others face into the room (+X from the west wall).
const PAPERS: Array = [
	[&"ch1_dat_note", "DatNote", Vector3.ZERO, Vector3(-90, 15, 0), Vector2(0.15, 0.21)],
	[&"ch1_dat_card", "DatNote", Vector3(0.0, 0.0, 0.22), Vector3(-90, -10, 0), Vector2(0.09, 0.06)],
	[&"ch1_phuc_schedule", "PhucBooks", Vector3(0.12, -0.25, 0.0), Vector3(0, 90, 0), Vector2(0.21, 0.3)],
	[&"ch1_viet_photo", "VietPhoto", Vector3(0.05, 0.0, 0.0), Vector3(0, 90, 0), Vector2(0.15, 0.1)],
	# Chapter 1 v2 (D-039): lane B's anchors from T-162, with fallbacks below.
	[&"ch1_phuc_card", "PhucCard", Vector3.ZERO, Vector3(-90, 0, 0), Vector2(0.09, 0.06)],
	[&"ch1_team_photo", "TeamPhoto", Vector3.ZERO, Vector3(0, -90, 0), Vector2(0.15, 0.1)],
	[&"ch1_viet_card", "VietLaptop", Vector3(0.0, 0.03, 0.18), Vector3(-90, 0, 0), Vector2(0.09, 0.06)],
	[&"ch1_tap_chart", "GuitarSongbook", Vector3.ZERO, Vector3(-90, 0, 0), Vector2(0.15, 0.21)],
]
## Where v2 papers go while lane B's new anchors are missing: anchor → fallback.
const PAPER_FALLBACKS := {"PhucCard": ["PhucBooks", Vector3(0.12, -0.2, 0.25)],
	"TeamPhoto": ["DatNote", Vector3(-0.3, 0.0, 0.0)], "GuitarSongbook": ["VietPhoto", Vector3(0.1, -0.6, 0.3)]}

var _fan_rotors: Array[Node3D] = []
var _end_card_key_pressed: bool = false


func _ready() -> void:
	_place_speaker()
	_place_papers()
	var light := $Floor4.get_node_or_null("Room407/Room407MainLight") as Node3D
	if light != null:
		light.visible = false
	_place_audio()
	_wire_room()
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
	speaker.set("chapter_profile", true)
	add_child(speaker)
	speaker.global_transform = anchor.global_transform
	$Chapter1Director.speaker_path = $Chapter1Director.get_path_to(speaker)


## Lane E's chapter 1 rigs (T-158). They must exist before the director
## starts (it emits chapter_started deferred).
func _place_audio() -> void:
	var music := Ch1Music.new()
	music.name = "Ch1Music"
	add_child(music)
	var call := PhoneCallAudio.new()
	call.name = "PhoneCallAudio"
	add_child(call)
	var player_audio := Ch1PlayerAudio.new()
	player_audio.name = "Ch1PlayerAudio"
	add_child(player_audio)
	# The manager heard from elsewhere in the building (Chapter1Director moves it).
	var far := MANAGER_AUDIO.instantiate()
	far.name = "ManagerAudioFar"
	far.listener = $Player
	far.add_to_group(&"manager_audio")
	add_child(far)
	var screams := BuildingScreams.new()
	screams.name = "BuildingScreams"
	screams.listener = $Player
	screams.add_to_group(&"screams")
	add_child(screams)
	# Blood dripping from the three beds once the roommates are dead.
	var drips := CorpseAudio.new()
	drips.name = "RoomDrips"
	drips.add_to_group(&"corpse_audio")
	add_child(drips)
	drips.global_position = Vector3(32.0, 0.3, -3.0)


## Lane B's bodies (T-154) get lane A's UnseenPoser (T-152) and lane E's
## CorpseAudio (T-158); the router blinks (the call runs over it).
func _wire_room() -> void:
	var anchors := $Floor4.get_node_or_null("Room407/Anchors") as Node3D
	if anchors == null:
		return
	for corpse in ["Corpse1", "Corpse2", "Corpse4"]:
		var body := anchors.get_node_or_null(corpse + "/Body") as Node3D
		if body == null:
			continue
		var poser := UnseenPoser.new()
		poser.name = "UnseenPoser"
		poser.enabled = false
		poser.add_to_group(&"corpse_poser")
		body.add_child(poser)
		var rustle := CorpseAudio.new()
		rustle.name = "CorpseAudio"
		rustle.poser = poser
		body.add_child(rustle)
	var router := anchors.get_node_or_null("Router/Model")
	if router != null and router.has_method("set_led"):
		router.set_led(true)


func _place_papers() -> void:
	var anchors := $Floor4.get_node_or_null("Room407/Anchors") as Node3D
	if anchors == null:
		return
	for entry: Array in PAPERS:
		var anchor := anchors.get_node_or_null(String(entry[1])) as Node3D
		var offset: Vector3 = entry[2]
		if anchor == null and PAPER_FALLBACKS.has(entry[1]):
			anchor = anchors.get_node_or_null(String(PAPER_FALLBACKS[entry[1]][0])) as Node3D
			offset = PAPER_FALLBACKS[entry[1]][1]
		if anchor == null:
			continue
		var paper := READABLE.instantiate()
		paper.name = String(entry[0]).to_pascal_case()
		paper.document_id = entry[0]
		paper.size = entry[4]
		add_child(paper)
		paper.global_position = anchor.global_position + offset
		paper.rotation_degrees = entry[3]
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
