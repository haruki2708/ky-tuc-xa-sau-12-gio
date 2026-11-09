class_name Protagonist
extends RefCounted
## T-227 (D-151): Tran Trung's full body on the player, the same in the pilot scene and in chapter 1.
## - The player gets a PlayerBody (player.set_body).
## - Door 407's Tripo levers take the hand (D-124, T-222), so the body presses the lever and the door
##   swings with it (door407.gd hand_seconds).
## - The room's mirrors show the body's mirror copy; their PS1 stand-in body is hidden. The mirrors
##   still follow the player (lag stays a mirror's own business).


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
		DoorHandles.take(bare)
	var room := floor4.get_node_or_null("Room407") as Node3D
	if room != null:
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
