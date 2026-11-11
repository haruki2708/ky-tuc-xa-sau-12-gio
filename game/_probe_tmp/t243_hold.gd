extends Node
const CHAPTER := "res://scenes/main/chapter2.tscn"


func _ready() -> void:
	get_tree().create_timer(120.0, true, false, true).timeout.connect(func() -> void: get_tree().quit(1))
	AudioServer.set_bus_mute(0, true)
	var chapter := (load(CHAPTER) as PackedScene).instantiate() as Node3D
	var director := chapter.get_node("Chapter2Director") as Chapter2Director
	director.auto_start = false
	add_child(chapter)
	for i in 4:
		await get_tree().physics_frame
	var room := chapter.get_node("Floor4/Room407") as Node3D
	var player := chapter.get_node("Player") as CharacterBody3D
	var body := player.get("body") as PlayerBody
	director._bathroom_door(true)
	var rag := room.get_node("Anchors/RagSpot/Carry_rag") as CarryItem
	var look: Node3D = rag.get_meta(&"look")
	print("look ", look.get_path(), " scale ", look.global_basis.get_scale(), " meshes:")
	for mesh: MeshInstance3D in look.find_children("*", "MeshInstance3D", true, false):
		print("   ", mesh.name, " visible ", mesh.visible, " aabb ", mesh.get_aabb(), " at ", room.to_local(mesh.global_position))
	player.global_position = room.to_global(Vector3(7.5, 0.02, -5.7))
	body._stand_at(player.global_position, PlayerBody._yaw_to(player.global_position, rag.hand_target().global_position))
	for i in 3:
		await get_tree().physics_frame
	body.perform(rag)
	for frame in 90:
		await get_tree().physics_frame
		if frame % 10 == 0 or frame == 89:
			var visual := body.get("_held_visual") as Node3D
			var hand: Transform3D = body._posed_bone("RightHand")
			var palm: Vector3 = hand.origin + hand.basis.y.normalized() * PlayerBody.PALM * body._scale()
			var text := "frame %d acting %s held %s palm %s" % [frame, body.acting, body.holds(rag), room.to_local(palm).snapped(Vector3.ONE * 0.01)]
			if visual != null:
				text += " visual %s hang %s children %d" % [room.to_local(visual.global_position).snapped(Vector3.ONE * 0.01), body.get("_held_hang"), visual.get_child_count()]
				for mesh: MeshInstance3D in visual.find_children("*", "MeshInstance3D", true, false):
					var box: AABB = mesh.global_transform * mesh.get_aabb()
					text += " box %s..%s" % [room.to_local(box.position).snapped(Vector3.ONE * 0.01), room.to_local(box.end).snapped(Vector3.ONE * 0.01)]
			print(text)
	get_tree().quit()
