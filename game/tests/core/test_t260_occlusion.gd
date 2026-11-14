extends TestCase
## T-260 (D-173): occlusion culling. The project setting is on; every chapter carries the core occluder scenes
## (game/scenes/main/occlusion/, written by art_source/graphics_upgrade/occlusion/make_occluders.py): floor 4's in
## all four, building B's and the closed campus shells' in chapters 3-4. Each occluder must sit inside one solid
## layer-1 box of the real scene (a wall, a slab, a closed block), so that a wall moved or opened later fails here
## instead of hiding what is behind it; none may touch a door, window or railing, nor hold a start point.

const FLOOR4 := "res://scenes/main/occlusion/occluders_floor4.tscn"
const CAMPUS := "res://scenes/main/occlusion/occluders_campus.tscn"
## Nodes whose drawn box must stay clear of every occluder: doors (room, bathroom, balcony, stalls, fire, main),
## windows, railings.
const OPENINGS := "^(LockedDoor_\\d+|LockedDoor|Door407|RoomDoor|BathroomDoor|BalconyDoor|FurnishedDoor|StallDoor_\\d+|FireDoor|MainDoor|FrontDoor|BackDoor|Door\\d+|Door\\d+Leaf|ManagerDoorLeaf|Window.*|UpperWindow.*|ServeWindow.*|Railing.*|RailingTop\\d+)$"
const STARTS := "^(seg\\d+_start|Start_.*)$"
## Room for rounding: an occluder may touch its wall box's faces.
const SLACK := 0.005
## A start point's eye (crouched 1.0 m, standing 1.65 m above it) must be this far from any occluder.
const START_CLEAR := 0.3

var scene: Node3D


func after_each() -> void:
	if scene != null:
		scene.queue_free()
		scene = null
	await wait_frames(3)


func test_setting_is_on() -> void:
	assert_true(bool(ProjectSettings.get_setting("rendering/occlusion_culling/use_occlusion_culling", false)),
		"rendering/occlusion_culling/use_occlusion_culling;")


func test_every_chapter_carries_the_occluder_scenes() -> void:
	for chapter in [1, 2, 3, 4]:
		var state := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).get_state()
		var paths := []
		for i in state.get_node_count():
			var instance := state.get_node_instance(i)
			if instance != null:
				paths.append(instance.resource_path)
		assert_true(FLOOR4 in paths, "chapter %d has floor 4's occluders;" % chapter)
		assert_eq(CAMPUS in paths, chapter >= 3, "chapter %d campus occluders;" % chapter)
	for path in [FLOOR4, CAMPUS]:
		var root := (load(path) as PackedScene).instantiate() as Node3D
		var count := 0
		for node: OccluderInstance3D in root.find_children("*", "OccluderInstance3D", true, false):
			assert_true(node.occluder is BoxOccluder3D, "%s %s is a box;" % [path.get_file(), node.name])
			count += 1
		assert_true(count >= (50 if path == FLOOR4 else 100), "%s has its occluders (%d);" % [path.get_file(), count])
		root.free()


func test_chapter1_occluders_inside_walls_clear_of_openings() -> void:
	await _check_chapter(1)


func test_chapter3_occluders_inside_walls_clear_of_openings() -> void:
	await _check_chapter(3)


func _check_chapter(chapter: int) -> void:
	Chapter1Director.resume_checkpoint = &""
	scene = (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter%dDirector" % chapter).set("auto_start", false)
	tree.root.add_child(scene)
	await wait_frames(3)
	var solids := _solid_boxes()
	var occluders := _occluder_boxes()
	assert_true(occluders.size() >= (50 if chapter < 3 else 150), "chapter %d occluders (%d);" % [chapter, occluders.size()])
	var openings := _drawn_boxes(OPENINGS)
	assert_true(openings.size() > 10, "chapter %d openings found (%d);" % [chapter, openings.size()])
	var starts := []
	for node: Node3D in scene.find_children("*", "Node3D", true, false):
		if RegEx.create_from_string(STARTS).search(String(node.name)) != null:
			starts.append(node.global_position)
	starts.append((scene.get_node("Player") as Node3D).global_position)
	for name: String in occluders:
		var box: AABB = occluders[name]
		var inside := false
		for solid: AABB in solids:
			if solid.grow(SLACK).encloses(box):
				inside = true
				break
		assert_true(inside, "chapter %d: %s inside a solid layer-1 box;" % [chapter, name])
		for opening: String in openings:
			assert_false(box.intersects(openings[opening]), "chapter %d: %s %s clear of %s %s;" % [chapter, name, box, opening, openings[opening]])
		for start: Vector3 in starts:
			for height in [1.0, 1.65]:
				assert_false(box.grow(START_CLEAR).has_point(start + Vector3.UP * height),
					"chapter %d: %s clear of the start %s;" % [chapter, name, start])


## World boxes of the scene's enabled static box shapes on layer 1.
func _solid_boxes() -> Array[AABB]:
	var out: Array[AABB] = []
	for shape: CollisionShape3D in scene.find_children("*", "CollisionShape3D", true, false):
		var body := shape.get_parent() as StaticBody3D
		if body == null or shape.disabled or not (shape.shape is BoxShape3D) or not (body.collision_layer & 1):
			continue
		var size := (shape.shape as BoxShape3D).size
		out.append(shape.global_transform * AABB(-size / 2.0, size))
	return out


func _occluder_boxes() -> Dictionary:
	var out := {}
	for node: OccluderInstance3D in scene.find_children("*", "OccluderInstance3D", true, false):
		var size := (node.occluder as BoxOccluder3D).size
		out[str(scene.get_path_to(node))] = node.global_transform * AABB(-size / 2.0, size)
	return out


## Drawn world box of each node named by `pattern` (its meshes and its descendants'), skipping nodes that draw nothing.
func _drawn_boxes(pattern: String) -> Dictionary:
	var regex := RegEx.create_from_string(pattern)
	var out := {}
	for node: Node3D in scene.find_children("*", "Node3D", true, false):
		if regex.search(String(node.name)) == null:
			continue
		var meshes: Array = node.find_children("*", "MeshInstance3D", true, false)
		if node is MeshInstance3D:
			meshes.append(node)
		var box := AABB()
		var any := false
		for mesh: MeshInstance3D in meshes:
			# A mesh switched off itself is a retired part (the PS1 leaves T-250/T-253 hide for good); one under a
			# hidden parent may still show later in the chapter, so it counts.
			if mesh.mesh == null or not mesh.visible:
				continue
			var drawn := mesh.global_transform * mesh.get_aabb()
			box = drawn if not any else box.merge(drawn)
			any = true
		if any:
			out[str(scene.get_path_to(node))] = box
	return out
