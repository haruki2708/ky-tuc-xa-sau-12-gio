extends TestCase
## T-267 round 1 (card sections 4, 5, 7): the five CCTV rooms as main has them (colliders, cameras, markers, lights, the
## room numbers) and the pilot's wave-10 glbs (no collider, shared materials only, VRAM-compressed textures if any,
## nothing across the manager's straight route at chest height, nothing between each room's Cam and its victim's head).
## Round 2 hangs the glbs in cctv_set.tscn; these checks then run on the scene as it ships.

const SET := "res://scenes/levels/cctv/cctv_set.tscn"
## T-256's collider print (the same rows), so the two tests read colliders the same way.
const T256 := preload("res://tests/levels/test_t256_floor4_rest.gd")
const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave10/"
const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave10/"
const ROOMS := {"102": Vector3(0, 0, 0), "306": Vector3(6, 0, 0), "209": Vector3(12, 0, 0), "106": Vector3(18, 0, 0),
	"310": Vector3(40, 0, 0)}
## main d369bf8: every room's collider print (22 shapes: shell, corridor, bunks, lockers, desk), the same in all five.
const COLLIDER_PRINT := "6686bf8d8b52f9bce03b1a8e4895ac0b"
## [path, position, rotation_degrees] in Room<n> space, main d369bf8 (Room310/Cam differs, below).
const CONTRACT := [
	["Cam", Vector3(3.72, 2.78, -4.72), Vector3(-25.8447588, 143.0694398, 0)],
	["Hall/Cam", Vector3(-0.7, 2.65, 2.2), Vector3(-23.257046, -65.3231368, 0)],
	["Hall/Start", Vector3(4.45, 0.05, 1.3), Vector3.ZERO],
	["Hall/Tube", Vector3(2.8, 2.8, 1.25), Vector3.ZERO],
	["Door", Vector3(2.45, 0.05, 1.2), Vector3.ZERO],
	["ManagerSpot", Vector3(1.55, 0.05, -2.35), Vector3(0, -60, 0)],
	["VictimBed", Vector3(0.65, 1.2, -3), Vector3.ZERO],
	["Victim", Vector3(0.65, 1.2, -3), Vector3.ZERO],
	["NumberInside", Vector3(2.45, 2.42, -0.11), Vector3(0, 180, 0)],
	["NumberOutside", Vector3(2.45, 2.42, 0.11), Vector3.ZERO],
	["NightLight", Vector3(1.5, 2.5, -2.6), Vector3.ZERO],
]
const CAM_310 := [Vector3(2, 2.6, -0.35), Vector3(-31.9081069, 0, 0)]
const CORPSES := {"Corpse1": Vector3(0.65, 0.43, -3), "Corpse2": Vector3(3.35, 0.43, -3), "Corpse4": Vector3(3.35, 1.2, -3)}
const GLBS := ["cctv_room", "cctv_hall", "cctv_light_set"]
const STORY_POSES := {"102": &"answer", "306": &"phone_lit", "209": &"cower", "106": &"sit_up", "310": &"lie_awake"}
var fixtures: Array[Node] = []


func after_each() -> void:
	for node in fixtures:
		if is_instance_valid(node):
			node.queue_free()
	fixtures.clear()
	await wait_frames(2)


func _spawn() -> Node3D:
	var set_root := (load(SET) as PackedScene).instantiate() as Node3D
	fixtures.append(set_root)
	tree.root.add_child(set_root)
	return set_root


func test_rooms_keep_main_s_colliders_cameras_and_markers() -> void:
	var set_root := _spawn()
	await wait_frames(2)
	for number: String in ROOMS:
		var room := set_root.get_node("Room" + number) as Node3D
		assert_true(room.position.is_equal_approx(ROOMS[number]), number + " room in place")
		var print_now := T256.collider_print(room)
		print("T267_COLLIDERS %s %d %s" % [number, print_now.count("\n") + 1, print_now.md5_text()])
		assert_eq(print_now.md5_text(), COLLIDER_PRINT, number + " colliders as main has them")
		for row: Array in CONTRACT:
			var node := room.get_node_or_null(String(row[0])) as Node3D
			assert_not_null(node, "%s/%s kept" % [number, row[0]])
			if node == null:
				continue
			var want_pos: Vector3 = row[1]
			var want_rot: Vector3 = row[2]
			if number == "310" and row[0] == "Cam":
				want_pos = CAM_310[0]
				want_rot = CAM_310[1]
			assert_true(node.position.is_equal_approx(want_pos), "%s/%s position %s" % [number, row[0], node.position])
			assert_true(node.rotation_degrees.distance_to(want_rot) < 0.01, "%s/%s rotation %s" % [number, row[0], node.rotation_degrees])
		for path: String in ["Cam", "Hall/Cam"]:
			var cam := room.get_node(path) as Camera3D
			assert_true(is_equal_approx(cam.fov, 66.0 if path == "Cam" else 70.0) and is_equal_approx(cam.far, 30.0), "%s/%s lens" % [number, path])
		for label: String in ["NumberInside", "NumberOutside"]:
			assert_eq((room.get_node(label) as Label3D).text, number, "%s %s reads its number" % [number, label])
		var tube := room.get_node("Hall/Tube") as OmniLight3D
		assert_true(is_equal_approx(tube.light_energy, 0.6) and is_equal_approx(tube.omni_range, 5.0), number + " corridor light as before")
		var night := room.get_node("NightLight") as OmniLight3D
		assert_true(is_equal_approx(night.light_energy, 1.1) and is_equal_approx(night.omni_range, 7.0), number + " night light as before")
	assert_not_null(set_root.get_node_or_null("Room106/DeskLamp"), "106 keeps its desk lamp")
	assert_true(set_root.get_node_or_null("Room102/DeskLamp") == null, "102 has none")
	var r310 := set_root.get_node("Room310") as Node3D
	for corpse: String in CORPSES:
		assert_true((r310.get_node(corpse) as Node3D).position.is_equal_approx(CORPSES[corpse]), corpse + " in place")


func test_wave10_glbs_are_visual_and_share_materials() -> void:
	for glb: String in GLBS:
		var root := (load(MODELS + glb + ".glb") as PackedScene).instantiate() as Node3D
		assert_true(root.find_children("*", "CollisionObject3D", true, false).is_empty(), glb + " has no collider")
		assert_true(root.find_children("*", "CollisionShape3D", true, false).is_empty(), glb + " has no collision shape")
		var triangles := 0
		for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
			triangles += mesh.mesh.get_faces().size() / 3
			for surface in mesh.mesh.get_surface_count():
				var material := mesh.mesh.surface_get_material(surface)
				var path := material.resource_path if material != null else ""
				assert_true(path.begins_with("res://assets/models/graphics_pilot/realistic_map/wave1/materials/")
					or path.begins_with("res://assets/models/graphics_pilot/realistic_map/wave2/materials/"),
					"%s/%s surface %d uses wave 1-2's material (%s)" % [glb, mesh.name, surface, path])
		print("T267_TRIANGLES %s %d" % [glb, triangles])
		assert_true(triangles < 5000, "%s under 5,000 triangles (%d)" % [glb, triangles])
		root.free()


func test_wave10_textures_import_vram_compressed() -> void:
	if not DirAccess.dir_exists_absolute(TEXTURES):
		assert_true(true, "round 1 adds no texture")
		return
	for file in DirAccess.get_files_at(TEXTURES):
		if not (file.ends_with(".png") or file.ends_with(".jpg")):
			continue
		var config := ConfigFile.new()
		assert_eq(config.load(TEXTURES + file + ".import"), OK, file + " has import settings")
		assert_eq(config.get_value("params", "compress/mode"), 2, file + " VRAM compressed")
		assert_eq(config.get_value("params", "compress/normal_map"), 1 if file.get_basename().ends_with("_normal") else 0, file + " normal-map flag")
		var image := Image.load_from_file(ProjectSettings.globalize_path(TEXTURES + file))
		assert_true(image.get_width() <= 1024 and image.get_height() <= 1024, file + " at most 1K")


## The pilot's glbs in every room (as round 2 hangs them under Real): nothing at chest height on the manager's straight
## route, nothing between Cam and the victim's head.
func test_pilot_kit_keeps_the_route_and_the_view_clear() -> void:
	var set_root := _spawn()
	await wait_frames(2)
	for number: String in ROOMS:
		var room := set_root.get_node("Room" + number) as Node3D
		var real := Node3D.new()
		real.name = "Real"
		room.add_child(real)
		for glb: String in GLBS:
			real.add_child((load(MODELS + glb + ".glb") as PackedScene).instantiate())
		var victim := room.get_node("Victim")
		victim.call("set_pose", STORY_POSES[number])
	await wait_frames(30)
	for number: String in ROOMS:
		var room := set_root.get_node("Room" + number) as Node3D
		var triangles := _world_triangles(room.get_node("Real"))
		# The route _cctv_scene() gives him: Start -> Door -> (door x, room z - 0.6) -> ManagerSpot.
		var start := (room.get_node("Hall/Start") as Node3D).global_position
		var door := (room.get_node("Door") as Node3D).global_position
		var inside := Vector3(door.x, door.y, room.global_position.z - 0.6)
		var spot := (room.get_node("ManagerSpot") as Node3D).global_position
		var blocked := ""
		for leg: Array in [[start, door], [door, inside], [inside, spot]]:
			var a: Vector3 = leg[0]
			var b: Vector3 = leg[1]
			var steps := int(ceil(a.distance_to(b) / 0.1))
			for k in range(steps + 1):
				var at := a.lerp(b, float(k) / steps) + Vector3(0, 1.25, 0)
				var hit := _box_hits(at, Vector3(0.22, 0.2, 0.22), triangles)
				if hit:
					blocked = "%s at %s" % [number, room.to_local(at)]
					break
			if not blocked.is_empty():
				break
		assert_true(blocked.is_empty(), "the manager's route stays clear at chest height " + blocked)
		var cam := (room.get_node("Cam") as Node3D).global_position
		var head := (room.get_node("Victim").find_child("Head", true, false) as Node3D).global_position
		var cut := _segment_hits(cam, head, triangles)
		assert_true(cut < 0.0, "%s: no new mesh between Cam and the victim's head (hit at %.2f)" % [number, cut])
		var hall_cam := (room.get_node("Hall/Cam") as Node3D).global_position
		var door_middle := room.to_global(Vector3(2.45, 1.4, 0.0))
		assert_true(_segment_hits(hall_cam, door_middle, triangles) < 0.0, number + ": Hall/Cam sees the doorway")


func _world_triangles(root: Node) -> PackedVector3Array:
	var result := PackedVector3Array()
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		var xform := mesh.global_transform
		for point: Vector3 in mesh.mesh.get_faces():
			result.append(xform * point)
	return result


## Whether any triangle overlaps the box (centre, half extents): separating axis test.
func _box_hits(centre: Vector3, half: Vector3, triangles: PackedVector3Array) -> bool:
	var box := AABB(centre - half, half * 2.0)
	for i in range(0, triangles.size(), 3):
		var a := triangles[i] - centre
		var b := triangles[i + 1] - centre
		var c := triangles[i + 2] - centre
		var bounds := AABB(triangles[i], Vector3.ZERO).expand(triangles[i + 1]).expand(triangles[i + 2])
		if not bounds.intersects(box):
			continue
		if _tri_box(a, b, c, half):
			return true
	return false


static func _tri_box(a: Vector3, b: Vector3, c: Vector3, half: Vector3) -> bool:
	var edges := [b - a, c - b, a - c]
	var axes: Array[Vector3] = [Vector3.RIGHT, Vector3.UP, Vector3.BACK, (b - a).cross(c - a)]
	for edge: Vector3 in edges:
		for unit: Vector3 in [Vector3.RIGHT, Vector3.UP, Vector3.BACK]:
			axes.append(unit.cross(edge))
	for axis: Vector3 in axes:
		if axis.length_squared() < 1e-12:
			continue
		var pa := a.dot(axis)
		var pb := b.dot(axis)
		var pc := c.dot(axis)
		var radius := half.x * absf(axis.x) + half.y * absf(axis.y) + half.z * absf(axis.z)
		if minf(pa, minf(pb, pc)) > radius or maxf(pa, maxf(pb, pc)) < -radius:
			return false
	return true


## The fraction along from -> to of the first triangle hit (Moller-Trumbore), -1 if none.
static func _segment_hits(from: Vector3, to: Vector3, triangles: PackedVector3Array) -> float:
	var direction := to - from
	var best := -1.0
	for i in range(0, triangles.size(), 3):
		var e1 := triangles[i + 1] - triangles[i]
		var e2 := triangles[i + 2] - triangles[i]
		var p := direction.cross(e2)
		var det := e1.dot(p)
		if absf(det) < 1e-10:
			continue
		var s := from - triangles[i]
		var u := s.dot(p) / det
		if u < 0.0 or u > 1.0:
			continue
		var q := s.cross(e1)
		var v := direction.dot(q) / det
		if v < 0.0 or u + v > 1.0:
			continue
		var t := e2.dot(q) / det
		if t > 0.0 and t < 0.97 and (best < 0.0 or t < best):
			best = t
	return best
