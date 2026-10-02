extends TestCase
## Physics checks use the same capsule envelope as the Player scene.

const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const ANCHORS: Array[String] = [
	"seg1_start", "seg2_start", "seg3_start", "seg4_start", "seg5_start",
	"Door407", "Room407LightSwitch", "RulesPaper407", "Locker_Trung", "Phone_Trung",
	"Bed_Phuc", "Bed_Viet", "Bed_Dat", "Bed_Trung", "Slippers407", "HallBoard",
	"HallBoardNote", "DutyLog", "Speaker", "WashroomTapRunning", "WashroomMirror",
	"WashroomNotice", "ClotheslineExtraShirt", "DarkSection",
]
var floor_scene: Node3D


func before_each() -> void:
	floor_scene = FLOOR.instantiate() as Node3D
	tree.root.add_child(floor_scene)
	await tree.physics_frame
	await tree.physics_frame


func after_each() -> void:
	floor_scene.queue_free()
	await wait_frames(2)
	# Lane E's scene-tree-owned reverb fade must finish before engine shutdown.
	await tree.create_timer(0.4).timeout


func _query(feet: Vector3, motion: Vector3 = Vector3.ZERO) -> PhysicsShapeQueryParameters3D:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = 1.75
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform.origin = feet + Vector3(0, 0.875, 0)
	query.motion = motion
	query.margin = 0.001
	query.collision_mask = 1
	return query


func _path(points: Array[Vector3]) -> void:
	var space := floor_scene.get_world_3d().direct_space_state
	for i in range(points.size()):
		assert_true(space.intersect_shape(_query(points[i])).is_empty(), "capsule starts clear at %s" % points[i])
		var down := PhysicsRayQueryParameters3D.create(points[i] + Vector3.UP, points[i] + Vector3.DOWN, 1)
		var hit := space.intersect_ray(down)
		assert_false(hit.is_empty(), "floor supports waypoint %s" % points[i])
		if not hit.is_empty():
			assert_eq(hit.collider.get_meta("surface", &""), &"tile", "walking floor metadata")
		if i + 1 < points.size():
			var query := _query(points[i], points[i + 1] - points[i])
			assert_true(space.cast_motion(query)[0] >= 0.999,
				"unblocked path %s -> %s" % [points[i], points[i + 1]])


func test_floor4_structure_dimensions_and_anchors() -> void:
	assert_true(floor_scene.is_inside_tree(), "floor instantiated")
	for name in ["Corridor", "Room407", "Washroom", "DutyDesk"]:
		assert_not_null(floor_scene.get_node_or_null(name), "required component " + name)
	assert_eq(floor_scene.get_node("Anchors").get_child_count(), ANCHORS.size(), "anchor inventory")
	for name in ANCHORS:
		assert_true(floor_scene.get_node_or_null("Anchors/" + name) is Marker3D, "marker " + name)
	var sizes := {"Corridor": Vector3(44, 0.2, 2.4), "Room407": Vector3(4, 0.2, 5), "Washroom": Vector3(6, 0.2, 5)}
	for name: String in sizes:
		var collider := floor_scene.get_node(name + "/Floor/Collision") as CollisionShape3D
		assert_true((collider.shape as BoxShape3D).size.is_equal_approx(sizes[name]), name + " floor dimensions")
		assert_true(absf(collider.global_position.y + 0.1) < 0.001, "floor top at Y=0")
	var start := floor_scene.get_node("Anchors/seg1_start") as Marker3D
	assert_true((-start.global_basis.z).is_equal_approx(Vector3.FORWARD), "seg1 faces north/door")
	start = floor_scene.get_node("Anchors/seg5_start") as Marker3D
	assert_true((-start.global_basis.z).is_equal_approx(Vector3.LEFT), "seg5 faces west")


func test_floors_have_tile_surface_and_world_collision() -> void:
	var count := 0
	for node in floor_scene.find_children("*", "StaticBody3D", true, false):
		var body := node as StaticBody3D
		assert_eq(body.collision_layer, 1, "world body " + str(body.get_path()))
		if str(body.name).begins_with("Floor") or body.name == &"StairLanding":
			count += 1
			assert_eq(body.get_meta("surface", &""), &"tile", "surface " + str(body.get_path()))
	assert_eq(count, 11, "hall, eight rooms, washroom, stair landing")


func test_door407_opens_and_paper_anchor_follows_leaf() -> void:
	var door := floor_scene.get_node("Door407")
	var query := _query(Vector3(32, .03, 1.15), Vector3(0, 0, -2))
	var space := floor_scene.get_world_3d().direct_space_state
	assert_true(space.cast_motion(query)[0] < 0.9, "closed door blocks passage")
	var paper := floor_scene.get_node("Anchors/RulesPaper407") as Marker3D
	var original := paper.global_position
	door.interact(null)
	await tree.physics_frame
	await tree.physics_frame
	assert_true(door.is_open, "interact opens door")
	assert_true(space.cast_motion(query)[0] >= 0.999, "open leaf clears full player capsule")
	assert_true(paper.global_position.distance_to(original) > 0.4, "paper follows hinge")
	assert_true(paper.global_position.is_equal_approx((door.get_node("Pivot/RulesPaper") as Node3D).global_position),
		"integration anchor stays on inside of leaf")
	door.interact(null)
	await tree.physics_frame
	await tree.physics_frame
	assert_false(door.is_open, "second interaction closes door")
	assert_true(space.cast_motion(query)[0] < 0.9, "closed collision restored")


func test_capsule_routes_to_room_desk_and_washroom() -> void:
	floor_scene.get_node("Door407").set_open(true)
	await tree.physics_frame
	await tree.physics_frame
	_path([Vector3(32, .03, 1.15), Vector3(32, .03, -.9), Vector3(32, .03, 1.2), Vector3(39.8, .03, 1.2)])
	_path([Vector3(32, .03, 1.15), Vector3(3, .03, 1.15), Vector3(3, .03, -1.2),
		Vector3(1.25, .03, -1.2), Vector3(1.25, .03, -2.85)])
	var tap := floor_scene.get_node("Anchors/WashroomTapRunning") as Marker3D
	assert_true(Vector3(1.25, 1.6, -2.85).distance_to(tap.global_position) < 1.3,
		"route finishes within interaction reach of tap, not inside sink")
	for name in ["seg2_start", "seg3_start", "seg4_start"]:
		var marker := floor_scene.get_node("Anchors/" + name) as Marker3D
		_path([Vector3(32, .03, -.9), Vector3(32, .03, -1.35),
			Vector3(marker.position.x, .03, -1.35), marker.global_position])


func test_railing_and_locked_exits_block_capsule() -> void:
	var space := floor_scene.get_world_3d().direct_space_state
	for x in [0.5, 8.0, 20.0, 32.0, 43.5]:
		for height in [.03, 1.0]:
			assert_true(space.cast_motion(_query(Vector3(x, height, 1.2), Vector3(0, 0, 2)))[0] < 0.9,
				"cannot cross railing at %s, feet Y=%s" % [x, height])
	for x in [8.0, 12.0, 16.0, 20.0, 24.0, 28.0, 36.0, 41.95]:
		assert_true(space.cast_motion(_query(Vector3(x, .03, 1.2), Vector3(0, 0, -2)))[0] < 0.9,
			"locked door/gate blocks entry at " + str(x))


func test_lights_audio_zones_and_sleepers() -> void:
	var corridor := floor_scene.get_node("Corridor")
	var lights := corridor.find_children("CorridorLight_*", "OmniLight3D", true, false)
	assert_eq(lights.size(), 9, "nine corridor tubes")
	for i in range(8):
		var lamp := corridor.get_node("CorridorLight_%d" % (401 + i)) as Light3D
		assert_true(absf(lamp.position.x - (8 + 4 * i)) < 0.001, "4 m tube spacing")
	for path in ["Corridor/CorridorLight_Desk", "Room407/Room407MainLight", "Washroom/WashroomLight"]:
		lights.append(floor_scene.get_node(path))
	for lamp in lights:
		var hum := lamp.get_node("LightHum") as LightHum
		assert_not_null(hum, "tube hum")
		assert_eq(hum.light, lamp, "hum references its own light")
	for component in ["Corridor", "Room407", "Washroom", "DutyDesk"]:
		assert_true(floor_scene.get_node(component + "/AmbientZone") is AmbientZone, "ambient " + component)
		assert_true(floor_scene.get_node(component + "/ReverbZone") is ReverbZone, "reverb " + component)
	assert_true(floor_scene.get_node("DutyDesk/SpeakerIdle") is AmbientEmitter, "quiet idle-speaker placeholder")
	assert_eq(floor_scene.find_children("Sleeper_*", "MeshInstance3D", true, false).size(), 3, "three sleeping placeholders")
	assert_not_null(floor_scene.get_node_or_null("Room407/BunkB/Net_Trung"), "Trung's open net")
