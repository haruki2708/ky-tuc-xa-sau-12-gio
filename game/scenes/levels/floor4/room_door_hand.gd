class_name RoomDoorHand
extends Interactable
## T-255 (D-168): the door of rooms 401-406 and 408 opened and closed by hand in every chapter, as Door 407 is. It
## rides the RoomDoor's leaf on its Hinge (the player looks at the leaf to use it); the leaf's Tripo levers take the
## hand (DoorHandles, lane A: which lever or the free edge from which side). The leaf still opens out into the
## corridor, as the chapters and the zombies open it.
## A door with a story (chapter 3-4: core hangs lane A's ZombieDoor on it, the zombies inside hammer it down) is
## the chapter's from then on: no hand, and a door left open by hand is shut again, once nobody stands in the
## doorway, so the zombies have a door to break.

## The leaf (room 407's Tripo leaf, corridor_shell.gd) from the hinge, its middle; its size, and how thick the look
## box is (as HingedDoor's).
const LEAF_CENTRE := Vector3(-0.445, 1.04, -0.025)
const LEAF_SIZE := Vector3(0.89, 2.1, 0.04)
const LOOK_THICKNESS := 0.12
## RoomDoor's own swing time (a plain press, chapter 4 without the body).
const PRESS_SECONDS := 0.3
## The doorway from the door's origin (x either side, z from the room to the corridor through the open leaf's
## sweep): a door is not shut on someone standing there.
const DOORWAY := AABB(Vector3(-0.65, -0.5, -0.6), Vector3(1.3, 3.0, 1.6))

var door: RoomDoor
var grips: Array[HandTarget] = []
var _shut_for_story := false


## Hangs a RoomDoorHand on `door`'s Hinge; its levers (if the corridor has hung room 407's leaf) take the hand.
static func fit(room_door: RoomDoor) -> RoomDoorHand:
	var hinge := room_door.get_node("Hinge") as Node3D
	var angle := hinge.rotation.y
	hinge.rotation.y = 0.0
	var hand := RoomDoorHand.new()
	hand.name = "Hand"
	hand.door = room_door
	hinge.add_child(hand)
	hand.position = LEAF_CENTRE
	var face := CollisionShape3D.new()
	face.shape = BoxShape3D.new()
	(face.shape as BoxShape3D).size = Vector3(LEAF_SIZE.x, LEAF_SIZE.y, LOOK_THICKNESS)
	hand.add_child(face)
	var leaf := hinge.get_node_or_null("G5Leaf")
	if leaf != null:
		var levers: Array[HandTarget] = DoorHandles.take(leaf.find_children("Lever*", "", false, false))
		hand.grips.append_array(levers)
		for edge: HandTarget in DoorHandles.sides(hinge, levers):
			# The free edge's grip rides the corridor's leaf (it turns with the hinge all the same), so the
			# RoomDoor keeps exactly the nodes it had (test_corridor_g5: gameplay nodes untouched).
			edge.reparent(leaf, true)
			hand.grips.append(edge)
	hinge.rotation.y = angle
	hand._update_prompt()
	return hand


func hand_target(from: Vector3 = Vector3.INF, rank: Callable = Callable()) -> HandTarget:
	return HandTarget.best(grips, from, rank)


func _on_interact(player: Node) -> void:
	var opening := not door.is_open
	if not opening and player is Node3D and _in_doorway((player as Node3D).global_position):
		return
	door.set_open(opening, hand_seconds if hand_seconds > 0.0 else PRESS_SECONDS)
	_update_prompt()


## Where the leaf turns to when it is used next (radians about the hinge's Y), and the hinge (DoorSwing, lane A: a
## body in the leaf's way steps clear first).
func swing_angle() -> float:
	return 0.0 if door.is_open else PI / 2.0


func pivot() -> Node3D:
	return door.get_node("Hinge") as Node3D


## Whether core has given this door a story (a ZombieDoor on it).
func has_story() -> bool:
	for child: Node in door.get_children():
		if child is ZombieDoor:
			return true
	return false


func _physics_process(_delta: float) -> void:
	if not has_story():
		_update_prompt()
		return
	if enabled:
		enabled = false
		collision_layer = 0
	if _shut_for_story or not door.is_open:
		return
	for child: Node in door.get_children():
		if child is ZombieDoor and (child as ZombieDoor).is_broken:
			_shut_for_story = true
			return
	# The player is where the camera is (their head; the doorway box is as high as a door).
	var camera := get_viewport().get_camera_3d()
	if camera == null or not _in_doorway(camera.global_position):
		_shut_for_story = true
		door.set_open(false)


func _in_doorway(point: Vector3) -> bool:
	return DOORWAY.has_point(door.global_transform.affine_inverse() * point)


func _update_prompt() -> void:
	prompt_key = "PROMPT_CLOSE_DOOR" if door != null and door.is_open else "PROMPT_OPEN_DOOR"
