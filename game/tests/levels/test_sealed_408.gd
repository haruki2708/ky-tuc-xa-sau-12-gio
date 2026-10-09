extends TestCase
## T-206: measure rendered mesh bounds, including imported wall transforms.

var fixture: Node3D
var corridor: Node3D
var building: Node3D


func before_each() -> void:
	fixture = Node3D.new()
	tree.root.add_child(fixture)
	var floor4 := preload("res://scenes/levels/floor4/floor4.tscn").instantiate()
	fixture.add_child(floor4)
	corridor = floor4.get_node("Corridor")
	building = preload("res://scenes/levels/campus/building_b.tscn").instantiate()
	fixture.add_child(building)


func after_each() -> void:
	fixture.queue_free()
	await wait_frames(2)
	await tree.create_timer(.4).timeout


func _bounds(node: Node3D) -> AABB:
	var meshes: Array[Node] = node.find_children("*", "MeshInstance3D", true, false)
	if node is MeshInstance3D:
		meshes.append(node)
	var bounds := AABB()
	var initialized := false
	for mesh: MeshInstance3D in meshes:
		if not mesh.is_visible_in_tree() or mesh.mesh == null:
			continue
		var world_bounds: AABB = mesh.global_transform * mesh.mesh.get_aabb()
		bounds = bounds.merge(world_bounds) if initialized else world_bounds
		initialized = true
	assert_true(initialized, "rendered mesh exists: %s" % node.get_path())
	return bounds


func test_sealed_panel_is_wholly_in_front_of_wall() -> void:
	var panel := corridor.get_node("Sealed408") as MeshInstance3D
	var panel_bounds := _bounds(panel)
	var wall_bounds := _bounds(corridor.get_node("Former408Wall"))
	var front_gap := panel_bounds.end.z - wall_bounds.end.z
	var back_gap := panel_bounds.position.z - wall_bounds.end.z
	assert_true(front_gap >= .01, "panel front must clear wall by at least 1 cm; got %f m" % front_gap)
	assert_true(back_gap > .001, "whole panel must be outside wall; back clearance %f m" % back_gap)
	assert_eq(Vector2(panel.position.x, panel.position.y), Vector2(36, 1.02))
	assert_eq((panel.mesh as BoxMesh).size, Vector3(.85, 1.7, .05))
	assert_true(panel.material_override == null and panel.mesh.material == null, "preserve original material")
	print("T206_CLEARANCE: front=%.4f m back=%.4f m" % [front_gap, back_gap])


func test_room_plates_and_lower_floor_frames_clear_their_walls() -> void:
	for number in range(401, 409):
		var plate := _bounds(corridor.get_node("RoomPlate_%d" % number))
		var frame := _bounds(corridor.get_node("Doorway_%d" % number))
		assert_true(plate.position.z > frame.end.z + .001, "floor 4 plate %d outside frame" % number)
	for floor_number in [2, 3]:
		for index in range(8):
			var detail := building.get_node("KitDetail%d" % floor_number)
			var frame := _bounds(detail.get_node("Frame%d" % index))
			var plate := _bounds(detail.get_node("Plate%d" % index))
			assert_true(plate.position.z > frame.end.z + .001, "B%d plate %d outside frame" % [floor_number, index])
			for part: String in ["Facade%dL", "Facade%dR", "Lintel%d"]:
				var wall := _bounds(building.get_node("Floor%d/%s" % [floor_number, part % index]))
				assert_true(frame.end.z > wall.end.z + .01, "B%d frame %d separated from facade" % [floor_number, index])
	print("T206_AUDIT: 24 room plates and 16 lower-floor frames clear their backing walls")
