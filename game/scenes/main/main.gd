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


func _ready() -> void:
	_place_interactables()
	_place_speaker()
	EventBus.interacted.connect(_on_interacted)
	place_player(&"seg1_start")


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
