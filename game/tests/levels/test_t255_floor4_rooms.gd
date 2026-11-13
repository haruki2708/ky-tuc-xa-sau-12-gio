extends TestCase
## T-255 (D-168): rooms 401-406 and 408 as deep as room 407, each with its bathroom and balcony, furnished (each room
## different), opened by hand in every chapter, their interiors drawn only while wanted (floor4_rooms.gd). The
## corridor, its doors, the stairs and the zombies' way out of each room stay as they were.

const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const CAMPUS := preload("res://scenes/levels/campus/campus.tscn")
const ROOMS: Array[String] = ["401", "402", "403", "404", "405", "406", "408"]
const CHAPTERS: Array[String] = ["res://scenes/main/chapter1.tscn", "res://scenes/main/chapter2.tscn",
	"res://scenes/main/chapter3.tscn", "res://scenes/main/chapter4.tscn"]
## Room 407's depths (rooms_layout.py): its back wall's inner face, the parapet's outer face, the ceiling.
const BACK_IN := -6.925
const PARAPET_OUT := -8.55
const CEILING := 3.0
## Chapter 3 (D-061): where a room's zombies stand and walk out (rooms_layout.SPAWN_CLEAR), x from the door.
const SPAWN_BOX := Vector4(-0.7, 0.95, -2.6, -0.15)
## The body that walks in: the player's capsule.
const RADIUS := 0.3
const HEIGHT := 1.8
const WALK_SPEED := 6.0
var fixtures: Array[Node] = []


func after_each() -> void:
	for node in fixtures:
		if is_instance_valid(node):
			node.queue_free()
	fixtures.clear()
	await wait_frames(2)


func _spawn(upgraded := true) -> Node3D:
	var floor4 := FLOOR.instantiate() as Node3D
	floor4.set("upgraded_rooms", upgraded)
	fixtures.append(floor4)
	tree.root.add_child(floor4)
	return floor4


func _rooms(floor4: Node3D) -> Floor4Rooms:
	return floor4.get_node("Rooms") as Floor4Rooms


func _layout(rooms: Floor4Rooms, number: String) -> Dictionary:
	return (rooms.get("_data") as Dictionary).rooms[number].layout


func _space(floor4: Node3D) -> PhysicsDirectSpaceState3D:
	return floor4.get_world_3d().direct_space_state


func _ray(floor4: Node3D, from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(floor4.to_global(from), floor4.to_global(to), 1)
	return _space(floor4).intersect_ray(query)


func test_every_room_is_built_as_deep_as_407() -> void:
	var floor4 := _spawn()
	await wait_frames(3)
	var rooms := _rooms(floor4)
	assert_not_null(rooms, "floor 4 builds its rooms")
	assert_eq(Floor4Rooms.build(floor4), rooms, "a second build keeps the one set of rooms")
	for number: String in ROOMS:
		var room := rooms.get_node_or_null("Room" + number) as Node3D
		assert_not_null(room, "room " + number)
		for path: String in ["Interior/Shell", "Outdoor/Shell", "Interior/BathroomDoor", "Outdoor/BalconyDoor", "Floor", "Collision"]:
			assert_not_null(room.get_node_or_null(path), "%s has %s" % [number, path])
		var inside: AABB = (room.get_node("Interior/Shell") as MeshInstance3D).get_aabb()
		var outside: AABB = (room.get_node("Outdoor/Shell") as MeshInstance3D).get_aabb()
		# Inside: to the back wall (its door's and window's reveals reach its outside face, 0.15 further).
		assert_true(inside.position.z > BACK_IN - 0.16 and inside.position.z < BACK_IN + 0.01,
			"%s goes back to 407's back wall (%.3f)" % [number, inside.position.z])
		assert_true(absf(inside.end.y - CEILING) < 0.01, "%s ceiling at 3 m" % number)
		# Outside: to the parapet (the drain spout pokes 10 cm through it).
		assert_true(outside.position.z > PARAPET_OUT - 0.11 and outside.position.z < PARAPET_OUT + 0.01,
			"%s balcony out to 407's parapet (%.3f)" % [number, outside.position.z])
		var floor_body := room.get_node("Floor") as StaticBody3D
		assert_eq(floor_body.get_meta(&"surface", &""), &"tile", number + " floor sounds as tile")
		assert_true(floor_body.get_meta(&"is_floor", false), number + " floor is a floor")
		# The back wall stands where 407's does, the balcony's parapet where 407's does (rays above the furniture).
		var layout := _layout(rooms, number)
		var s_x: float = float(layout.x0) + 0.95 if layout.bath_side == "east" else float(layout.x1) - 0.95
		var hit := _ray(floor4, Vector3(s_x, 2.6, -1.0), Vector3(s_x, 2.6, -9.0))
		assert_true(not hit.is_empty() and absf(floor4.to_local(hit.position).z - BACK_IN) < 0.02,
			"%s back wall at z %.3f" % [number, BACK_IN])
		var balcony_x: float = (float(layout.balcony_door[0]) + float(layout.balcony_door[1])) / 2.0
		hit = _ray(floor4, Vector3(balcony_x, 0.6, -7.3), Vector3(balcony_x, 0.6, -9.5))
		assert_true(not hit.is_empty() and absf(floor4.to_local(hit.position).z - (-8.45)) < 0.02, number + " parapet")
		hit = _ray(floor4, Vector3(balcony_x, 1.0, -5.0), Vector3(balcony_x, -1.0, -5.0))
		assert_true(not hit.is_empty() and absf(floor4.to_local(hit.position).y) < 0.01, number + " floor under the back of the room")


func test_bathroom_and_balcony_doors_open_by_hand() -> void:
	var floor4 := _spawn()
	await wait_frames(3)
	var rooms := _rooms(floor4)
	for number: String in ROOMS:
		for path: String in ["Interior/BathroomDoor", "Outdoor/BalconyDoor"]:
			var door := rooms.get_node("Room%s/%s" % [number, path]) as Node3D
			var hand := HingedDoor.of(door)
			assert_not_null(hand, "%s %s has a hand" % [number, path])
			if hand == null:
				continue
			assert_false(hand.is_open, "%s %s shut when a chapter starts" % [number, path])
			assert_eq(hand.grips.size(), 3, "%s %s: two levers and the free edge" % [number, path])
			hand.interact(null)
			assert_true(bool(door.get("is_open")), "%s %s opens" % [number, path])
			var leaf := door.get_node("Pivot/Leaf") as Node3D
			var leaf_at: Vector3 = floor4.to_local(leaf.global_position)
			var layout := _layout(rooms, number)
			if path.begins_with("Interior"):
				# Into the bathroom, along its partition.
				assert_true(leaf_at.z < -4.4, "%s bathroom door swings in (%.2f)" % [number, leaf_at.z])
			else:
				# Out and back against the facade, on the bathroom's side.
				assert_true(leaf_at.z < -7.075 and leaf_at.z > -7.4, "%s balcony door flat on the facade (%.2f)" % [number, leaf_at.z])
				var door_mid: float = (float(layout.balcony_door[0]) + float(layout.balcony_door[1])) / 2.0
				var toward_bath: float = signf(float(layout.bath[0]) - door_mid)
				assert_true((leaf_at.x - door_mid) * toward_bath > 0.5, number + " balcony leaf lies toward the bathroom")
			hand.interact(null)
			assert_false(bool(door.get("is_open")), "%s %s shuts" % [number, path])


func test_room_doors_open_and_shut_by_hand() -> void:
	var floor4 := _spawn()
	await wait_frames(3)
	for number: String in ROOMS:
		var door := floor4.get_node("Corridor/LockedDoor_" + number) as RoomDoor
		var hand := door.get_node_or_null("Hinge/Hand") as RoomDoorHand
		assert_not_null(hand, number + " door has a hand")
		if hand == null:
			continue
		assert_true(hand.enabled and hand.collision_layer == Interactable.LAYER_INTERACTABLE, number + " usable")
		assert_eq(hand.grips.size(), 3, number + ": the Tripo leaf's two levers and its free edge")
		assert_not_null(hand.hand_target(floor4.to_global(Vector3(door.position.x, 1.6, 1.5))), number + " lever from the corridor")
		assert_eq(hand.pivot(), door.get_node("Hinge"), number + " pivot")
		assert_true(is_equal_approx(hand.swing_angle(), PI / 2.0), number + " opens out into the corridor")
		hand.interact_by_hand(null, 0.4)
		assert_true(door.is_open, number + " opens by hand")
		assert_eq(hand.prompt_key, "PROMPT_CLOSE_DOOR", number + " prompt follows")
	await tree.create_timer(0.6).timeout
	await tree.physics_frame
	for number: String in ROOMS:
		var door := floor4.get_node("Corridor/LockedDoor_" + number) as RoomDoor
		assert_true(is_equal_approx((door.get_node("Hinge") as Node3D).rotation.y, PI / 2.0), number + " swung right open")
		assert_eq(door.blocker.collision_layer, 0, number + " doorway free")
		var hand := door.get_node("Hinge/Hand") as RoomDoorHand
		hand.interact(null)
		assert_false(door.is_open, number + " shuts by hand")
	await tree.create_timer(0.5).timeout
	await tree.physics_frame
	for number: String in ROOMS:
		var door := floor4.get_node("Corridor/LockedDoor_" + number) as RoomDoor
		assert_eq(door.blocker.collision_layer, 1, number + " doorway shut again")


func test_a_door_with_a_story_belongs_to_the_chapter() -> void:
	var floor4 := _spawn()
	await wait_frames(3)
	var camera := Camera3D.new()
	fixtures.append(camera)
	tree.root.add_child(camera)
	camera.make_current()
	camera.global_position = floor4.to_global(Vector3(20.0, 1.6, 3.0))
	var door := floor4.get_node("Corridor/LockedDoor_401") as RoomDoor
	var hand := door.get_node("Hinge/Hand") as RoomDoorHand
	hand.interact(null)
	assert_true(door.is_open, "401 opened by hand before the chapter needs it")
	# Chapter 3 (core): the zombies inside get the door.
	var adapter := ZombieDoor.new()
	adapter.door = door
	adapter.blocker = door.blocker
	door.add_child(adapter)
	await tree.physics_frame
	await tree.physics_frame
	assert_false(hand.enabled, "no hand on a door with a story")
	assert_eq(hand.collision_layer, 0, "no prompt on it")
	assert_false(door.is_open, "left open by hand, it is shut again for the zombies to break")
	assert_true(adapter.is_closed(), "the zombies have a shut door")
	# Somebody in the doorway: the door waits.
	var other := floor4.get_node("Corridor/LockedDoor_402") as RoomDoor
	var other_hand := other.get_node("Hinge/Hand") as RoomDoorHand
	other_hand.interact(null)
	camera.global_position = floor4.to_global(Vector3(12.0, 1.6, 0.0))
	var other_adapter := ZombieDoor.new()
	other_adapter.door = other
	other_adapter.blocker = other.blocker
	other.add_child(other_adapter)
	await tree.physics_frame
	await tree.physics_frame
	assert_true(other.is_open, "not shut on the player in the doorway")
	camera.global_position = floor4.to_global(Vector3(12.0, 1.6, 2.5))
	await tree.physics_frame
	await tree.physics_frame
	assert_false(other.is_open, "shut once the doorway is clear")


func test_interiors_drawn_only_while_wanted() -> void:
	var floor4 := _spawn()
	await wait_frames(3)
	var rooms := _rooms(floor4)
	var camera := Camera3D.new()
	fixtures.append(camera)
	tree.root.add_child(camera)
	camera.make_current()
	camera.global_position = floor4.to_global(Vector3(20.0, 1.6, 2.0))
	await wait_frames(2)
	for number: String in ROOMS:
		assert_false((rooms.get_node("Room%s/Interior" % number) as Node3D).visible, number + " hidden behind its shut door")
		assert_true((rooms.get_node("Room%s/Outdoor" % number) as Node3D).visible, number + " facade always drawn")
	var door := floor4.get_node("Corridor/LockedDoor_404") as RoomDoor
	door.set_open(true)
	await wait_frames(2)
	assert_true((rooms.get_node("Room404/Interior") as Node3D).visible, "404 drawn through its open door")
	assert_false((rooms.get_node("Room403/Interior") as Node3D).visible, "403 still hidden")
	door.set_open(false)
	await tree.create_timer(0.5).timeout
	await wait_frames(2)
	assert_false((rooms.get_node("Room404/Interior") as Node3D).visible, "404 hidden once its door has shut")
	camera.global_position = floor4.to_global(Vector3(40.0, 1.6, -6.0))
	await wait_frames(2)
	assert_true((rooms.get_node("Room408/Interior") as Node3D).visible, "408 drawn with the player inside")
	camera.global_position = floor4.to_global(Vector3(40.0, 1.6, -7.9))
	await wait_frames(2)
	assert_true((rooms.get_node("Room408/Interior") as Node3D).visible, "408 drawn with the player on its balcony")


func test_each_room_is_furnished_its_own_way() -> void:
	var floor4 := _spawn()
	await wait_frames(3)
	var rooms := _rooms(floor4)
	var looks: Dictionary = {}
	for number: String in ROOMS:
		var props := rooms.get_node("Room%s/Interior/Props" % number) as Node3D
		var outdoor := rooms.get_node("Room%s/Outdoor/Props" % number) as Node3D
		assert_true(props.get_child_count() + outdoor.get_child_count() >= 50, "%s furnished (%d)" % [number, props.get_child_count()])
		var kinds: Dictionary = {}
		var fabrics: Array[String] = []
		for prop: Node in props.get_children() + outdoor.get_children():
			var row: Dictionary = prop.get_meta(&"placement", {})
			kinds[String(row.get("model", "")).get_file()] = true
			if row.has("fabric"):
				fabrics.append(String(row.fabric))
		for model: String in ["bunk_frame.glb", "bunk_mattress.glb", "toilet.glb", "sink.glb", "shower.glb", "curtain_balcony.glb",
				"ceiling_fan_split.glb", "wall_socket.glb", "shirt_hanging.glb"]:
			assert_true(kinds.has(model), "%s has a %s" % [number, model])
		fabrics.sort()
		var signature := "%s|%s" % [",".join(kinds.keys()), ",".join(fabrics)]
		assert_false(looks.has(signature), "%s differs from %s" % [number, looks.get(signature, "")])
		looks[signature] = number
	# A recoloured blanket really wears its room's colour.
	var blanket := rooms.get_node("Room401/Interior/Props/BlanketALower") as Node3D
	var surface := (blanket.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D).get_surface_override_material(0)
	assert_true(surface is BaseMaterial3D and (surface as BaseMaterial3D).albedo_texture.resource_path.ends_with("blanket_folded_blue.jpg"),
		"401's lower bunk A in blue")


func test_ps1_rooms_retired_corridor_kept() -> void:
	var floor4 := _spawn()
	await wait_frames(3)
	for number: String in ROOMS:
		for pattern: String in ["Corridor/Floor_%s", "Corridor/Ceiling_%s", "Corridor/RoomInterior_%s"]:
			var node := floor4.get_node(pattern % number) as Node3D
			assert_false(node.visible, (pattern % number) + " hidden")
			for shape: CollisionShape3D in node.find_children("*", "CollisionShape3D", true, false):
				assert_true(shape.disabled, (pattern % number) + " collision off")
		var door := floor4.get_node("Corridor/LockedDoor_" + number) as RoomDoor
		assert_eq(door.blocker.collision_layer, 1, number + " door still blocks shut")
		assert_false((door.blocker.get_node("Collision") as CollisionShape3D).disabled, number + " blocker kept")
	assert_true((floor4.get_node("Corridor/Room408BackWall/Collision") as CollisionShape3D).disabled, "408 PS1 back wall off")
	for partition: String in ["6", "10", "14", "18", "22", "26", "38"]:
		var shape := floor4.get_node("Corridor/RoomPartition_%s/Collision" % partition) as CollisionShape3D
		assert_false(shape.disabled, "partition %s kept" % partition)
	# Off: the PS1 rooms as they were.
	var ps1 := _spawn(false)
	await wait_frames(2)
	assert_true(ps1.get_node_or_null("Rooms") == null, "no rooms when switched off")
	assert_false((ps1.get_node("Corridor/BackWall_401/Collision") as CollisionShape3D).disabled, "PS1 back wall when off")


func test_zombies_way_out_stays_clear() -> void:
	var floor4 := _spawn()
	await wait_frames(3)
	await tree.physics_frame
	for number: String in ROOMS:
		var door := floor4.get_node("Corridor/LockedDoor_" + number) as RoomDoor
		var x: float = door.position.x
		var box := BoxShape3D.new()
		box.size = Vector3(SPAWN_BOX.y - SPAWN_BOX.x, 1.7, SPAWN_BOX.w - SPAWN_BOX.z)
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = box
		query.collision_mask = 1
		query.transform = Transform3D(floor4.global_basis, floor4.to_global(Vector3(x + (SPAWN_BOX.x + SPAWN_BOX.y) / 2.0, 0.95,
			(SPAWN_BOX.z + SPAWN_BOX.w) / 2.0)))
		var hits := _space(floor4).intersect_shape(query, 8)
		var names: Array[String] = []
		for hit: Dictionary in hits:
			names.append(String((hit.collider as Node).get_path()))
		assert_true(hits.is_empty(), "%s: nothing in the zombies' way out %s" % [number, names])


## Walks the player's capsule through `points` (Floor4 metres, on the floor); false where it gets stuck.
func _walk(floor4: Node3D, body: CharacterBody3D, points: Array) -> String:
	for point: Vector3 in points:
		var goal := floor4.to_global(point + Vector3(0, HEIGHT / 2.0 + 0.02, 0))
		var frames := int(ceilf(body.global_position.distance_to(goal) / WALK_SPEED * 60.0)) + 40
		for frame in frames:
			var to := goal - body.global_position
			to.y = 0.0
			if to.length() < 0.06:
				break
			body.velocity = to.normalized() * minf(WALK_SPEED, to.length() * 60.0)
			body.move_and_slide()
			await tree.physics_frame
		var left := goal - body.global_position
		left.y = 0.0
		if left.length() > 0.12:
			return "stuck at %s on the way to %s" % [floor4.to_local(body.global_position), point]
	return ""


func test_the_player_walks_in_to_bathroom_and_balcony() -> void:
	var floor4 := _spawn()
	await wait_frames(3)
	var rooms := _rooms(floor4)
	var body := CharacterBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = RADIUS
	capsule.height = HEIGHT
	shape.shape = capsule
	body.add_child(shape)
	fixtures.append(body)
	tree.root.add_child(body)
	for number: String in ROOMS:
		var layout := _layout(rooms, number)
		var door := floor4.get_node("Corridor/LockedDoor_" + number) as RoomDoor
		(door.get_node("Hinge/Hand") as RoomDoorHand).interact(null)
		HingedDoor.of(rooms.get_node("Room%s/Interior/BathroomDoor" % number)).interact(null)
		HingedDoor.of(rooms.get_node("Room%s/Outdoor/BalconyDoor" % number)).interact(null)
		await tree.create_timer(0.4).timeout
		await tree.physics_frame
		var x: float = door.position.x
		var bath: float = (float(layout.bath_door[0]) + float(layout.bath_door[1])) / 2.0
		var balcony: float = (float(layout.balcony_door[0]) + float(layout.balcony_door[1])) / 2.0
		# Back from the bath door's line on the room's side, the way to the balcony door.
		var back_lane: float = balcony
		body.global_position = floor4.to_global(Vector3(x, HEIGHT / 2.0 + 0.02, 1.4))
		await tree.physics_frame
		var stuck := await _walk(floor4, body, [Vector3(x, 0, 0.6), Vector3(x, 0, -1.0), Vector3(bath, 0, -3.6),
			Vector3(bath, 0, -4.6), Vector3(bath, 0, -5.4)])
		assert_eq(stuck, "", number + " into the bathroom")
		# Out of the bathroom, across the room's back and out through the balcony door.
		stuck = await _walk(floor4, body, [Vector3(bath, 0, -3.6), Vector3(back_lane, 0, -3.65),
			Vector3(back_lane, 0, -5.0), Vector3(back_lane, 0, -6.4), Vector3(back_lane, 0, -7.7)])
		assert_eq(stuck, "", number + " through the room onto the balcony")


func test_campus_fits_the_deeper_rooms() -> void:
	# Chapters 3-4: building B stands round floor 4. No campus collider may stand in a room, its bathroom or balcony.
	var campus := CAMPUS.instantiate() as Node3D
	fixtures.append(campus)
	tree.root.add_child(campus)
	var floor4 := _spawn()
	await wait_frames(3)
	await tree.physics_frame
	var rooms := _rooms(floor4)
	for number: String in ROOMS:
		var layout := _layout(rooms, number)
		var box := BoxShape3D.new()
		var x0: float = float(layout.x0) + 0.05
		var x1: float = float(layout.x1) - 0.05
		box.size = Vector3(x1 - x0, 2.6, 8.3)
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = box
		query.collision_mask = 1
		query.transform = Transform3D(Basis(), floor4.to_global(Vector3((x0 + x1) / 2.0, 1.45, -0.25 - 8.3 / 2.0)))
		var foreign: Array[String] = []
		for hit: Dictionary in _space(floor4).intersect_shape(query, 64):
			var collider := hit.collider as Node
			if campus.is_ancestor_of(collider):
				foreign.append(String(campus.get_path_to(collider)))
		assert_true(foreign.is_empty(), "%s clear of building B's colliders %s" % [number, foreign])


func test_every_chapter_uses_the_floor_with_its_rooms() -> void:
	for path: String in CHAPTERS:
		var state := (load(path) as PackedScene).get_state()
		var found := false
		for index in state.get_node_count():
			var instance := state.get_node_instance(index)
			if state.get_node_name(index) == &"Floor4" and instance != null:
				found = instance.resource_path == FLOOR.resource_path
				for property in state.get_node_property_count(index):
					if state.get_node_property_name(index, property) in [&"upgraded_rooms"]:
						found = found and bool(state.get_node_property_value(index, property))
		assert_true(found, path + " has floor 4 with its rooms")
