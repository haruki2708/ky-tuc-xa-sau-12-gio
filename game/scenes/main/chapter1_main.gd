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
## D-151: Tran Trung's full body (T-227) on the player. On in chapter1.tscn only; chapters 2-4 share
## this script and stay without a body for now. Set it before the scene enters the tree.
@export var protagonist_body := false

## Room 407 papers on lane B's anchors (T-153, under Room407/Anchors):
## [document, anchor, offset, rotation (degrees), size, optional look (D-106)]. Desk papers lie flat;
## the others face into the room (+X from the west wall).
const PAPERS: Array = [
	[&"ch1_dat_note", "DatNote", Vector3.ZERO, Vector3(-90, 15, 0), Vector2(0.15, 0.21)],
	[&"ch1_dat_card", "DatNote", Vector3(0.0, 0.0, 0.22), Vector3(-90, -10, 0), Vector2(0.09, 0.06)],
	# D-152: taped to the front edge of Phuc's shelf (it hung 10 cm further in, out of reach).
	[&"ch1_phuc_schedule", "PhucBooks", Vector3(0.226, -0.25, 0.0), Vector3(0, 90, 0), Vector2(0.21, 0.3)],
	# D-106: both photos sit in the opening of the furnished room's photo frames (frames lean back 9°).
	[&"ch1_viet_photo", "VietPhoto", Vector3(-0.001, -0.05, 0.142), Vector3(-9, 188, 0), Vector2(0.15, 0.1), &"photo_family"],
	# Chapter 1 v2 (D-039): lane B's anchors from T-162, with fallbacks below.
	# D-151/D-152: fallen off Phuc's shelf onto Viet's locker below it (it lay at 2.06 m, out of reach).
	[&"ch1_phuc_card", "PhucCard", Vector3.ZERO, Vector3(-90, 20, 0), Vector2(0.09, 0.06)],
	# D-151: the frame stands on Trung's locker, in front of Dat's shelf (it stood on the shelf, out of reach).
	[&"ch1_team_photo", "TeamPhoto", Vector3(0.062, 0.1, 0.05), Vector3(-9, -90, 0), Vector2(0.15, 0.1), &"photo"],
	# D-106: on the desk beside the furnished laptop (it floated behind the new laptop's screen).
	# T-241: 10 cm nearer the desk's front edge (it lay 34 cm in: out of a standing reach).
	[&"ch1_viet_card", "VietLaptop", Vector3(0.27, -0.148, -0.07), Vector3(-90, 20, 0), Vector2(0.09, 0.06)],
	# T-239: on top of the songbook's pages (at the anchor it lay inside the book, 0.8 to 0.8285 m).
	[&"ch1_tap_chart", "GuitarSongbook", Vector3(0.0, 0.0285, 0.0), Vector3(-90, 0, 0), Vector2(0.15, 0.21)],
]
## Where v2 papers go while lane B's new anchors are missing: anchor → fallback.
const PAPER_FALLBACKS := {"PhucCard": ["PhucBooks", Vector3(0.12, -0.2, 0.25)],
	"TeamPhoto": ["DatNote", Vector3(-0.3, 0.0, 0.0)], "GuitarSongbook": ["VietPhoto", Vector3(0.1, -0.6, 0.3)]}

var _fan_rotors: Array[Node3D] = []
var _end_card_key_pressed: bool = false


func _ready() -> void:
	_place_speaker()
	_place_papers()
	# Before the director starts (deferred), so lying in bed at the start or a resume has the body.
	if protagonist_body:
		Protagonist.attach($Player as CharacterBody3D, $Floor4 as Node3D)
	var light := $Floor4.get_node_or_null("Room407/Room407MainLight") as Node3D
	if light != null:
		light.visible = false
	_place_audio()
	_wire_room()
	for rotor in $Floor4.find_children("fan_rotor", "", true, false):
		_fan_rotors.append(rotor as Node3D)
	_director().restart_requested.connect(_on_restart_requested)
	_director().chapter_done.connect(_on_chapter_done)


## Chapters 1–3 (T-170, T-181) share this scene script; the director node
## is Chapter1Director, Chapter2Director, Chapter3Director or Chapter4Director.
func _director() -> Chapter1Director:
	for director_name in ["Chapter4Director", "Chapter3Director", "Chapter2Director"]:
		var node := get_node_or_null(director_name)
		if node != null:
			return node as Chapter1Director
	return $Chapter1Director as Chapter1Director


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
	_director().speaker_path = _director().get_path_to(speaker)


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
	# Chapter 1 v2 (T-163): blood over the screen when the player dies, and
	# lane E's alarm (T-164) when Đạt's lock jams.
	if ResourceLoader.exists("res://ui/death/blood_overlay.tscn"):
		var blood := (load("res://ui/death/blood_overlay.tscn") as PackedScene).instantiate()
		blood.name = "BloodOverlay"
		add_child(blood)
	var panel := get_node_or_null("PuzzlePanel")
	if panel != null and ResourceLoader.exists("res://audio/ch1v2/lock_alarm.ogg"):
		panel.set("alarm_sound", load("res://audio/ch1v2/lock_alarm.ogg"))
	# Chapter 1 v2 (T-164): mission cues in 407, Khoa's knocks behind the wall.
	var mission := Ch1MissionAudio.new()
	mission.name = "MissionAudio"
	add_child(mission)
	mission.global_position = Vector3(32.0, 1.0, -0.5)
	var taps := WallTaps.new()
	taps.name = "KhoaTaps"
	add_child(taps)
	taps.set_other_side(true)
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
	if anchors != null:
		place_papers(anchors, self)


## Also used by room407_g3_capture.gd to show the papers without a chapter.
static func place_papers(anchors: Node3D, parent: Node) -> void:
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
		if entry.size() > 5:
			paper.look = entry[5]
		parent.add_child(paper)
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
