extends TestCase

const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
var floor_scene: Node3D
var room: Node3D


func before_each() -> void:
	floor_scene = FLOOR.instantiate()
	tree.root.add_child(floor_scene)
	room = floor_scene.get_node("Room407")
	await tree.physics_frame
	await tree.physics_frame


func after_each() -> void:
	floor_scene.queue_free()
	await wait_frames(2)
	await tree.create_timer(.4).timeout


func test_chapter_anchors_bed_numbers_and_clear_exits() -> void:
	var anchors := room.get_node("Anchors")
	for name in ["DatLocker", "DatNote", "Router", "WallKnock406", "WallKnock408", "Corpse1", "Corpse2", "Corpse4", "PhucBooks", "PhucPoster", "VietLaptop", "VietPhoto", "TrungChargingCable"]:
		assert_true(anchors.get_node_or_null(name) is Marker3D, name)
	var owners := ["Phuc", "Viet", "Trung", "Dat"]
	var capsule := CapsuleShape3D.new()
	capsule.height = 1.75
	capsule.radius = .3
	for i in range(1, 5):
		var bunk := anchors.get_node("Bunks/Bunk%d" % i) as Node3D
		assert_eq(bunk.get_meta("bed_number"), i)
		assert_eq(String(bunk.get_meta("owner_name")), owners[i - 1])
		assert_true(bunk.get_node("View") is Marker3D)
		assert_true(bunk.get_node("View").position.y > .35, "camera above blanket/body placeholder")
		var point: Vector3 = bunk.get_node("Exit").global_position
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = capsule
		query.transform.origin = point + Vector3(0,.875,0)
		query.collision_mask = 1
		assert_true(room.get_world_3d().direct_space_state.intersect_shape(query).is_empty(), "exit %d is clear" % i)
	assert_true(anchors.get_node("Bunks/Bunk3").position.y < anchors.get_node("Bunks/Bunk4").position.y)
	assert_true(anchors.get_node_or_null("Corpse3") == null, "no corpse on Trung's bed")
	var colors := [Color(.55,.055,.045), Color(.055,.20,.55), Color(.08,.35,.14), Color(.04,.045,.05)]
	for i in range(4):
		assert_eq(PropTint.current(room.get_node("Details/Slippers/" + owners[i])), colors[i], "slippers ownership color")


func test_blood_stages_reset_and_drip_motion() -> void:
	assert_eq(room.blood_stage, 0)
	assert_false(room.get_node("Details/BloodSeep").visible)
	room.set_blood_stage(1)
	assert_true(room.get_node("Details/BloodSeep").visible)
	assert_false(room.get_node("Details/BloodPools").visible)
	var drop := room.get_node("Details/BloodSeep/Droplet1") as Node3D
	room._process(.1)
	var first_y := drop.position.y
	room._process(.15)
	assert_true(drop.position.y != first_y, "drops move between blanket and floor")
	room.set_blood_stage(9)
	assert_eq(room.blood_stage, 2)
	assert_true(room.get_node("Details/BloodPools").visible)
	room.set_blood_stage(-3)
	assert_eq(room.blood_stage, 0)
	assert_false(room.get_node("Details/BloodPools").visible)
	assert_false(room.get_node("Details/BloodSeep").visible)


func test_slash_progress_is_monotonic_and_reversible() -> void:
	var previous := 9
	for amount in [0.0, .125, .5, 1.0]:
		room.set_slashed(amount)
		var count := 0
		for node: Node3D in room.get_node("Details/TrungBedding").get_children():
			count += 1 if node.visible else 0
		assert_true(count < previous, "more damage removes more bedding")
		previous = count
	assert_eq(previous, 0, "fully destroyed exposes wooden board")
	assert_true(room.get_node("Details/Debris").visible)
	assert_false(room.get_node("Details/TrungPillow").visible)
	room.set_slashed(NAN)
	assert_eq(room.slashed_amount, 0.0)
	assert_false(room.get_node("Details/Debris").visible)
	assert_true(room.get_node("Details/TrungPillow").visible)


func test_flicker_preserves_off_and_on_states_and_lock_api() -> void:
	var main := room.get_node("Room407MainLight") as Light3D
	var desk := room.get_node("Room407DeskLamp") as Light3D
	assert_eq(main.light_energy, 0.0, "4 AM main light off")
	assert_true(desk.light_energy > 0)
	var energy := desk.light_energy
	room.set_flicker(true)
	main._process(.02)
	assert_true(main.light_energy > 0)
	main._process(.08)
	assert_eq(main.light_energy, 0.0)
	room.set_flicker(false)
	assert_eq(main.light_energy, 0.0, "restore initially off lamp")
	assert_eq(desk.light_energy, energy, "restore desk energy")
	var locker := room.get_node("Anchors/DatLocker")
	locker.set_unlocked(true)
	assert_true(locker.unlocked)
	assert_true(locker.get_node("Shackle").position.y > 0)
	locker.set_unlocked(false)
	assert_false(locker.unlocked)
	assert_eq(locker.get_node("Shackle").position.y, 0.0)


func test_threshold_shadow_and_all_floor_surfaces() -> void:
	var threshold := floor_scene.get_node("Threshold") as Area3D
	assert_eq(threshold.collision_layer, 0, "does not block any movement")
	assert_eq(threshold.collision_mask, 2, "Player only")
	assert_true(threshold.position.z > 0, "hallway side")
	var body := CharacterBody3D.new()
	body.collision_layer = 2
	body.collision_mask = 0
	var collider := CollisionShape3D.new()
	collider.shape = CapsuleShape3D.new()
	body.add_child(collider)
	floor_scene.add_child(body)
	body.global_position = Vector3(32,1,.3)
	for i in range(3):
		await tree.physics_frame
	assert_true(threshold.overlaps_body(body), "threshold detects a Player-layer body outside door")
	body.global_position.z = -1.0
	for i in range(3):
		await tree.physics_frame
	assert_false(threshold.overlaps_body(body), "inside room does not trigger threshold")
	body.queue_free()
	var shadow := floor_scene.get_node("DoorGap/UnderDoorShadow") as Node3D
	shadow.set_visible(true)
	assert_true(shadow.is_visible_in_tree())
	floor_scene.get_node("Door407").set_open(true)
	assert_false(shadow.is_visible_in_tree(), "slit effect hides with open door")
	floor_scene.get_node("Door407").set_open(false)
	assert_true(shadow.is_visible_in_tree())
	for node in floor_scene.find_children("*", "StaticBody3D", true, false):
		if node.get_meta("is_floor", false):
			assert_eq(node.get_meta("surface", &""), &"tile")


func test_room_props_budgets_materials_and_texture_imports() -> void:
	for file in DirAccess.get_files_at("res://assets/models/room407"):
		if not file.ends_with(".glb"):
			continue
		var model := (load("res://assets/models/room407/" + file) as PackedScene).instantiate()
		var triangles := 0
		for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
			triangles += mesh.mesh.get_faces().size() / 3
			for surface in mesh.mesh.get_surface_count():
				assert_true(mesh.mesh.surface_get_material(surface) is ShaderMaterial, "PS1 material " + file)
		assert_true(triangles < (1500 if file == "bunk_trung.glb" else 500), "budget " + file)
		model.free()
	for file in DirAccess.get_files_at("res://assets/textures/room407"):
		if not file.ends_with(".png"):
			continue
		var texture := load("res://assets/textures/room407/" + file) as Texture2D
		assert_eq(texture.get_size(), Vector2(128,128))
		var config := ConfigFile.new()
		config.load("res://assets/textures/room407/" + file + ".import")
		assert_eq(config.get_value("params", "compress/mode"), 0)
		assert_eq(config.get_value("params", "mipmaps/generate"), false)
