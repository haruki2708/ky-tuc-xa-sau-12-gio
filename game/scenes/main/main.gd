extends Node3D
## Main scene: floor 4 + player + UI + story (T-117).

const LIGHT_SWITCH := preload("res://scenes/interaction/light_switch.tscn")
const DOOR_LATCH := preload("res://scenes/interaction/door_latch.tscn")
const READABLE := preload("res://scenes/interaction/readable.tscn")
const PHONE := preload("res://scenes/interaction/phone.tscn")
const SPEAKER_SCRIPT := preload("res://scripts/audio/speaker.gd")
const PHONE_VIBRATE := preload("res://audio/sfx/phone_vibrate.ogg")
## One-shot cues for lane A's objects (T-130), keyed by node name.
const INTERACT_CUES := {
	&"Room407LightSwitch": preload("res://audio/sfx/light_switch.ogg"),
	&"DoorLatch407": preload("res://audio/sfx/door_latch.ogg"),
}
## How far a paper's pick volume reaches out from its surface. Door 407's own
## interaction volume and leaf collision stick out ~0.13 m into the room, so a
## flush paper would never be the first thing the interaction ray hits.
const PAPER_PICK_DEPTH: float = 0.15
## Ceiling fan blade speed (rad/s), about 2.4 turns per second.
const FAN_SPEED: float = 15.0
## Deviation 4 (RULES.md §6): the fan labours.
const FAN_SLOW_FACTOR: float = 0.3
const STORY_DIRECTOR := preload("res://scripts/core/story_director.gd")

var _fan_rotors: Array[Node3D] = []


func _ready() -> void:
	_place_interactables()
	_place_story_papers()
	_place_speaker()
	$StoryDirector.restart_requested.connect(_on_restart_requested)
	EventBus.interacted.connect(_on_interacted)
	# Kit ceiling fans expose their blades as a separate "fan_rotor" node (T-102).
	for rotor in $Floor4.find_children("fan_rotor", "", true, false):
		_fan_rotors.append(rotor as Node3D)
	place_player(&"seg1_start")


func _process(delta: float) -> void:
	var speed := FAN_SPEED * (FAN_SLOW_FACTOR if GameState.get_flag(&"fan_slow", false) == true else 1.0)
	for rotor in _fan_rotors:
		rotor.rotate_y(speed * delta)


## Moves the player onto a checkpoint anchor of floor 4 (docs/design/LAYOUT.md §6).
func place_player(anchor_name: StringName) -> void:
	var anchor := $Floor4/Anchors.get_node_or_null(NodePath(anchor_name)) as Node3D
	if anchor == null:
		push_warning("Main: unknown spawn anchor '%s'" % anchor_name)
		return
	$Player.global_transform = anchor.global_transform


## Lane A's interactables (T-129) on floor 4 anchors; see the T-129 handoff.
func _place_interactables() -> void:
	var anchors := $Floor4/Anchors
	var door: Node3D = $Floor4/Door407

	var switch := LIGHT_SWITCH.instantiate()
	switch.name = "Room407LightSwitch"
	switch.light = $Floor4/Room407/Room407MainLight
	_attach(switch, anchors.get_node("Room407LightSwitch"))

	# Latch and paper ride on the door leaf so they swing with it.
	var latch := DOOR_LATCH.instantiate()
	latch.name = "DoorLatch407"
	latch.door = door
	door.get_node("Pivot").add_child(latch)

	var paper_mount := door.get_node("Pivot/RulesPaper") as Node3D
	paper_mount.get_node("Mesh").visible = false
	var paper := READABLE.instantiate()
	paper.name = "RulesPaper407"
	paper.document_id = &"room_paper_407"
	paper.rotation.y = PI # Face into the room (readable faces its local +Z).
	paper_mount.add_child(paper)
	_extend_pick_depth(paper)

	var phone := PHONE.instantiate()
	phone.name = "PhoneTrung"
	phone.vibrate_stream = PHONE_VIBRATE
	_attach(phone, anchors.get_node("Phone_Trung"))
	$StoryDirector.phone_path = $StoryDirector.get_path_to(phone)


## Papers for segments 3–5 (T-136) and the washroom tap the story watches.
func _place_story_papers() -> void:
	var anchors := $Floor4/Anchors
	# Hall board: faces the corridor (+Z) like its anchor.
	_place_readable(&"hall_board", anchors.get_node("HallBoard"), Vector2(0.42, 0.58),
		Transform3D(Basis.IDENTITY, Vector3(0, 0, 0.012)))
	# Handwritten note clipped to the frame; shown from segment 4 (StoryDirector).
	var note := _place_readable(&"hall_board_note", anchors.get_node("HallBoardNote"), Vector2(0.15, 0.2),
		Transform3D(Basis.IDENTITY, Vector3(0, 0, 0.02)))
	note.name = "HallBoardNoteReadable"
	note.visible = false
	note.enabled = false
	# Duty log lies open on the desk: readable +Z points up.
	_place_readable(&"duty_log", anchors.get_node("DutyLog"), Vector2(0.34, 0.24),
		Transform3D(Basis.from_euler(Vector3(-PI / 2.0, 0, 0)), Vector3(0, 0.03, 0)))
	# Washroom notice and room record: their anchors face the wall, turn around.
	_place_readable(&"washroom_notice", anchors.get_node("WashroomNotice"), Vector2(0.21, 0.3),
		Transform3D(Basis.from_euler(Vector3(0, PI, 0)), Vector3(0, 0, -0.02)))
	_place_readable(&"room_record_407", anchors.get_node("Locker_Trung"), Vector2(0.21, 0.3),
		Transform3D(Basis.from_euler(Vector3(0, PI, 0)), Vector3(0, 1.25, -0.27)))
	var tap := StoryTrigger.new()
	tap.name = "TapTrigger"
	tap.prompt_key = "PROMPT_CLOSE_TAP"
	tap.enabled = false
	tap.size = Vector3(0.3, 0.3, 0.3)
	anchors.get_node("WashroomTapRunning").add_child(tap)


func _place_readable(document_id: StringName, anchor: Node3D, size: Vector2, offset: Transform3D) -> Node3D:
	var paper := READABLE.instantiate()
	paper.name = String(document_id).to_pascal_case()
	paper.document_id = document_id
	paper.size = size
	anchor.add_child(paper)
	paper.transform = offset
	_extend_pick_depth(paper)
	return paper


## A real loss (StoryDirector): reload the scene and resume at the checkpoint.
## Only the running game reloads; tests that instance Main do not.
func _on_restart_requested(checkpoint_id: StringName) -> void:
	if get_tree().current_scene != self:
		return
	STORY_DIRECTOR.resume_checkpoint = checkpoint_id
	get_tree().paused = false
	get_tree().reload_current_scene()


## Lane E's PA speaker (T-130) on the duty desk; the story reads the rules through it.
func _place_speaker() -> void:
	var speaker := AudioStreamPlayer3D.new()
	speaker.name = "FloorSpeaker"
	speaker.set_script(SPEAKER_SCRIPT)
	speaker.unit_size = 10.0
	_attach(speaker, $Floor4/Anchors/Speaker)
	$StoryDirector.speaker_path = $StoryDirector.get_path_to(speaker)


func _on_interacted(target: Node) -> void:
	var cue: AudioStream = INTERACT_CUES.get(target.name)
	if cue == null or not target is Node3D:
		return
	var player := AudioStreamPlayer3D.new()
	player.stream = cue
	player.bus = &"SFX"
	add_child(player)
	player.global_position = (target as Node3D).global_position
	player.finished.connect(player.queue_free)
	player.play()


func _attach(node: Node3D, anchor: Node3D) -> void:
	add_child(node)
	node.global_transform = anchor.global_transform


func _extend_pick_depth(readable: Node) -> void:
	var collision := readable.get_node("CollisionShape3D") as CollisionShape3D
	var shape := (collision.shape as BoxShape3D).duplicate() as BoxShape3D
	shape.size.z = PAPER_PICK_DEPTH
	collision.shape = shape
	collision.position.z = PAPER_PICK_DEPTH * 0.5
