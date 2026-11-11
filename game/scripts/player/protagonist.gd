class_name Protagonist
extends RefCounted
## T-227 (D-151): Tran Trung's full body on the player, the same in the pilot scene and in chapter 1.
## - The player gets a PlayerBody (player.set_body).
## - Door 407's Tripo levers take the hand (D-124, T-222), so the body presses the lever and the door
##   swings with it (door407.gd hand_seconds). T-239: from inside the room never the corridor lever;
##   with the open leaf's inner face turned away, its free edge (DoorHandles.sides).
## - T-242 (D-154): the bathroom and balcony doors of room 407 get a HingedDoor each: opened and
##   closed by hand the same way.
## - The room's mirrors show the body's mirror copy; their PS1 stand-in body is hidden. The mirrors
##   still follow the player (lag stays a mirror's own business).


## The hinged.gd leaves of room 407 that a hand opens and closes (T-242).
const HINGED_DOORS: Array[String] = ["Extension/BathroomDoor", "Extension/BalconyDoor"]


static func attach(player: CharacterBody3D, floor4: Node3D) -> PlayerBody:
	var body := PlayerBody.new()
	player.set_body(body)
	var door := floor4.get_node_or_null("Door407") as Node3D
	if door != null:
		# Only levers without a marker yet (the door's own latch has one of its own, nested).
		var bare: Array[Node] = []
		for lever: Node in door.find_children("Lever*", "", true, false):
			if not _has_hand_target(lever):
				bare.append(lever)
		var levers: Array[HandTarget] = DoorHandles.take(bare)
		# T-239: which lever (or the free edge) a body takes depends on its side of the doorway.
		var pivot := door.get_node_or_null("Pivot") as Node3D
		if pivot != null:
			DoorHandles.sides(pivot, levers)
	var room := floor4.get_node_or_null("Room407") as Node3D
	if room != null:
		# T-242 (D-154): the bathroom and balcony doors open and close by hand, as Door 407 does.
		for path: String in HINGED_DOORS:
			var hinged := room.get_node_or_null(path) as Node3D
			if hinged != null and HingedDoor.of(hinged) == null:
				HingedDoor.fit(hinged)
		for mirror: Node in room.find_children("*", "", true, false):
			if mirror.has_method("set_lag") and mirror.has_node("ReflectionBody"):
				mirror.set("follow", player)
				for mesh: MeshInstance3D in mirror.get_node("ReflectionBody").find_children("*", "MeshInstance3D", true, false):
					mesh.hide()
	return body


static func _has_hand_target(node: Node) -> bool:
	for child: Node in node.find_children("*", "", true, false):
		if child is HandTarget:
			return true
	return false
