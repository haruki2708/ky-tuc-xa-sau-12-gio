extends TestCase
## T-216: real furnished bounds, sight lines and chapter-2 interaction reach.

const ROOM := preload("res://scenes/levels/floor4/room_407.tscn")
const RAG := "res://assets/models/graphics_pilot/room407_furnished/cleaning_rag.glb"
const EYES: Array[Vector3] = [Vector3(6.18, 1.6, -5.6), Vector3(6.0, 1.6, -4.35)]
var room: Node3D


func before_each() -> void:
	room = ROOM.instantiate() as Node3D
	tree.root.add_child(room)


func after_each() -> void:
	Input.action_release("interact")
	room.queue_free()
	await wait_frames(2)


func _bounds(node: Node3D) -> AABB:
	return room.global_transform.affine_inverse() * node.global_transform * Room407Furnish.local_bounds(node)


func test_rag_is_visible_on_rack_and_clear_of_sink() -> void:
	var rag := room.get_node("Anchors/RagSpot/Model") as Node3D
	assert_eq(rag.scene_file_path, RAG)
	assert_eq(room.get_node("Details/CleaningRag").scene_file_path, RAG)
	var box := _bounds(rag)
	var sink := _bounds(room.get_node("Furnished/TripoProps/Sink"))
	assert_false(box.intersects(sink), "entire cloth clears the basin, not only the pickup point")
	assert_false(sink.has_point(room.get_node("Anchors/RagSpot").position))
	var rack := _bounds(room.get_node("Furnished/TripoProps/TowelRack"))
	assert_true(absf(box.position.y - rack.end.y) < 0.015, "cloth rests at the rack top")
	assert_true(box.end.x < 7.892, "cloth stays in front of east wall tiles")
	for mesh: MeshInstance3D in rag.find_children("*", "MeshInstance3D", true, false):
		assert_true(mesh.is_visible_in_tree(), "furnishing does not hide the carry model")
	var carry := preload("res://scenes/interaction/carry_item.tscn").instantiate() as Area3D
	room.get_node("Anchors/RagSpot").add_child(carry)
	await tree.physics_frame
	await tree.physics_frame
	var eye := Vector3(6.85, 1.6, -5.3)
	var hit := _hit(eye, carry.global_position)
	assert_eq(hit.get("collider"), carry, "rag can be picked through the real room collision")
	assert_true(eye.distance_to(carry.global_position) < 2.0, "standard player reach")


func _hit(eye: Vector3, target: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(eye, target, 1 | 4)
	query.collide_with_areas = true
	return room.get_world_3d().direct_space_state.intersect_ray(query)


func test_panel_and_buttons_clear_shower_and_keep_surface_contract() -> void:
	var panel := room.get_node("Anchors/ShowerScreen") as Node3D
	var shower := _bounds(room.get_node("Furnished/TripoProps/Shower"))
	assert_eq(panel.get_meta("size"), Vector2(.4, .3))
	assert_eq((panel.get_node("Surface").mesh as QuadMesh).size, Vector2(.4, .3))
	assert_true(panel.basis.z.dot(Vector3.RIGHT) > .999, "surface faces into bathroom")
	var gap := panel.position.x - 5.383
	assert_true(gap >= .003 and gap <= .005, "3-5 mm from west tile face")
	for offset in [Vector3.ZERO, Vector3(-.2, -.15, 0), Vector3(.2, -.15, 0),
			Vector3(-.2, .15, 0), Vector3(.2, .15, 0)]:
		var target: Vector3 = panel.transform * offset
		for eye in EYES:
			assert_eq(shower.intersects_segment(eye, target), null, "whole screen clear of shower")
	for entry in [["ShowerYes", -.11], ["ShowerNo", .11]]:
		var button := room.get_node("Anchors/" + entry[0]) as Node3D
		var relative := panel.transform.affine_inverse() * button.position
		assert_true(relative.is_equal_approx(Vector3(entry[1], -.25, .02)), "Yes left, No right, below LCD")
		assert_true(button.basis.is_equal_approx(panel.basis), "button follows panel facing")


func test_real_wipe_and_choices_are_reachable_from_stall_and_entry() -> void:
	var panel := room.get_node("Anchors/ShowerScreen") as Node3D
	var wipe := preload("res://scenes/interaction/shower_screen.tscn").instantiate() as ShowerScreen
	panel.add_child(wipe)
	var player := Node3D.new()
	room.add_child(player)
	var head := Node3D.new()
	head.name = "Head"
	player.add_child(head)
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	head.add_child(camera)
	var ray := RayCast3D.new()
	ray.name = "InteractRay"
	ray.target_position = Vector3(0, 0, -2)
	ray.collision_mask = 1 | 4
	ray.collide_with_areas = true
	camera.add_child(ray)
	var buttons: Array[Area3D] = []
	for name in ["ShowerYes", "ShowerNo"]:
		var button := preload("res://scenes/interaction/shower_choice.tscn").instantiate() as Area3D
		room.get_node("Anchors/" + name).add_child(button)
		buttons.append(button)
	await tree.physics_frame
	await tree.physics_frame
	var wiped: Array[int] = [0]
	wipe.wiped.connect(func() -> void: wiped[0] += 1)
	for eye in EYES:
		player.position = eye
		camera.look_at(panel.global_position)
		ray.force_raycast_update()
		assert_eq(ray.get_collider(), wipe, "2 m ray reaches wipe surface through real walls")
		wipe.interact(player)
		Input.action_press("interact")
		wipe._physics_process(1.0)
		Input.action_release("interact")
		wipe._physics_process(0.0)
		for button in buttons:
			camera.look_at(button.global_position)
			ray.force_raycast_update()
			assert_eq(ray.get_collider(), button, "choice is not hidden by wall or wipe collision")
	assert_eq(wiped[0], 2, "one complete wipe from each position")


func test_tile_caps_have_no_overlapping_volume() -> void:
	var tiles := room.get_node("Furnished/TripoProps/BathTiles") as Node3D
	var caps: Array[AABB] = []
	for name in ["CapWest", "CapEast", "CapBack", "CapFront"]:
		var cap := tiles.find_child(name, true, false) as MeshInstance3D
		assert_not_null(cap, name)
		if cap:
			caps.append(room.global_transform.affine_inverse() * cap.global_transform * cap.get_aabb())
	assert_eq(caps.size(), 4)
	for i in caps.size():
		for j in range(i + 1, caps.size()):
			assert_false(caps[i].intersects(caps[j]), "cap pair %d/%d must not share top faces" % [i, j])


## D-124 (owner: the bathroom door vanished once opened): its hinge sits inside the west wall's
## thickness, so at 90 degrees the leaf sank into the wall. Open, the far half of the leaf must
## stand clear of the wall (only the strip at the hinge may stay in it), clear the basin (set
## back 22 cm for it), and leave the doorway passable.
func test_open_bathroom_door_stands_clear_of_the_west_wall() -> void:
	var door := room.get_node("Extension/BathroomDoor")
	door.set_open(true)
	var leaf := room.get_node("Extension/BathroomDoor/Pivot/BathroomDoor") as MeshInstance3D
	var wall_mesh := room.get_node("Furnished/architecture/BathroomSide") as MeshInstance3D
	var wall: AABB = room.global_transform.affine_inverse() * wall_mesh.global_transform * wall_mesh.get_aabb()
	var pivot: Vector3 = room.to_local((room.get_node("Extension/BathroomDoor/Pivot") as Node3D).global_position)
	var box: AABB = leaf.get_aabb()
	var clear: int = 0
	var far: int = 0
	for corner: int in 8:
		var point: Vector3 = room.to_local(leaf.global_transform * box.get_endpoint(corner))
		if Vector2(point.x - pivot.x, point.z - pivot.z).length() < 0.5:
			continue
		far += 1
		if point.x > wall.end.x + 0.02:
			clear += 1
	assert_true(far >= 4)
	assert_eq(clear, far, "the far half of the open leaf stands out of the wall")
	assert_true(door.get_node("Pivot").rotation.y > deg_to_rad(70.0), "still opens wide")
	# Nor does it swing into the basin on the same wall: sample the leaf's whole face.
	var sink := _bounds(room.get_node("Furnished/TripoProps/Sink"))
	var inside: int = 0
	for u: int in 11:
		for v: int in 11:
			var local := box.position + Vector3(box.size.x * u / 10.0, box.size.y * v / 10.0, box.size.z * 0.5)
			if sink.has_point(room.to_local(leaf.global_transform * local)):
				inside += 1
	assert_eq(inside, 0, "the open leaf clears the basin")
	# The player's capsule (0.6 m) passes between the open leaf and the far jamb.
	var jamb_x: float = room.to_local((room.get_node("Extension/BathroomDoor/Pivot") as Node3D).global_position).x + 0.98
	var leaf_x: float = -INF
	for corner: int in 8:
		leaf_x = maxf(leaf_x, room.to_local(leaf.global_transform * box.get_endpoint(corner)).x)
	assert_true(jamb_x - leaf_x > 0.65, "the doorway stays %.2f m wide" % (jamb_x - leaf_x))
