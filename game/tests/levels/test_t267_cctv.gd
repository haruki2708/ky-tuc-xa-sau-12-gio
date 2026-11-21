extends TestCase
## T-267 (card sections 4, 5, 7; D-188) wave 10: the five CCTV rooms of cctv_set.tscn as it ships. The contract stays as
## main has it (colliders, cameras with fov and far, markers, lights, the room numbers, people); Room<n>/Real draws the
## room and its corridor (the PS1 meshes are hidden, not freed; nothing new collides; no set_state under Room310); the
## nets keep each PS1 net's state; nine box occluders per room sit only in the five Room* branches (none in Corridor),
## inside the walls' thickness, out of the rooms, the corridors and the doorways; nothing new crosses the manager's
## straight route at chest height or the line from Cam to the victim's head; Hall/Cam sees the doorway; 306's phone and
## 106's desk lamp are in the frame; the ceilings (a room <= 160,000 triangles, a wave-10 glb < 5,000) hold; wave 10's
## textures import VRAM compressed, at most 512 px.

const SET := "res://scenes/levels/cctv/cctv_set.tscn"
## T-256's collider print (the same rows), so the two tests read colliders the same way.
const T256 := preload("res://tests/levels/test_t256_floor4_rest.gd")
const MODELS := "res://assets/models/graphics_pilot/realistic_map/wave10/"
const TEXTURES := "res://assets/textures/graphics_pilot/realistic_map/wave10/"
const MATERIAL_DIRS := ["res://assets/models/graphics_pilot/realistic_map/wave1/materials/",
	"res://assets/models/graphics_pilot/realistic_map/wave2/materials/",
	"res://assets/models/graphics_pilot/realistic_map/wave10/materials/"]
const ROOMS := {"102": Vector3(0, 0, 0), "306": Vector3(6, 0, 0), "209": Vector3(12, 0, 0), "106": Vector3(18, 0, 0),
	"310": Vector3(40, 0, 0)}
## main d369bf8 / 53d4d0e: every room's collider print (22 shapes: shell, corridor, bunks, lockers, desk), the same in all five.
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
const PEOPLE := ["Victim", "Corpse1", "Corpse2", "Corpse4"]
const GLBS := ["cctv_room", "cctv_hall", "cctv_net_upper_open"]
const STORY_POSES := {"102": &"answer", "306": &"phone_lit", "209": &"cower", "106": &"sit_up", "310": &"lie_awake"}
const OCCLUDERS := ["WestWall", "EastWall", "FrontWest", "FrontEast", "Lintel", "HallWallWest", "HallWallEast",
	"HallEndWest", "HallEndEast"]
## Where no occluder may reach (Room<n> metres): the room's inside, the corridor's, the doorway.
const CLEAR := [AABB(Vector3(0.1, 0.0, -4.9), Vector3(3.8, 3.0, 4.8)), AABB(Vector3(-0.85, 0.0, 0.1), Vector3(5.7, 3.0, 2.45)),
	AABB(Vector3(2.0, 0.0, -0.1), Vector3(0.9, 2.2, 0.2))]
const ROOM_TRIANGLES := 160000
const GLB_TRIANGLES := 5000
const NET_OPEN_PS1 := "res://assets/models/kit/mosquito_net_open.glb"
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
			var text := room.get_node(label) as Label3D
			assert_eq(text.text, number, "%s %s reads its number" % [number, label])
			assert_true(text.visible, "%s %s still drawn (the green board stands behind it)" % [number, label])
		var tube := room.get_node("Hall/Tube") as OmniLight3D
		assert_true(is_equal_approx(tube.light_energy, 0.6) and is_equal_approx(tube.omni_range, 5.0), number + " corridor light as before")
		var night := room.get_node("NightLight") as OmniLight3D
		assert_true(is_equal_approx(night.light_energy, 1.1) and is_equal_approx(night.omni_range, 7.0), number + " night light as before")
		var lights := 0
		for light: Node in room.find_children("*", "Light3D", true, false):
			if not String(room.get_path_to(light)).get_slice("/", 0) in PEOPLE:
				lights += 1
		assert_eq(lights, 3 if number == "106" else 2, number + " no light added (NightLight, Hall/Tube, 106's DeskLamp)")
	assert_not_null(set_root.get_node_or_null("Room106/DeskLamp"), "106 keeps its desk lamp")
	assert_true(set_root.get_node_or_null("Room102/DeskLamp") == null, "102 has none")
	var r310 := set_root.get_node("Room310") as Node3D
	for corpse: String in CORPSES:
		assert_true((r310.get_node(corpse) as Node3D).position.is_equal_approx(CORPSES[corpse]), corpse + " in place")


func test_real_hides_the_ps1_set_and_adds_no_collider() -> void:
	var set_root := _spawn()
	await wait_frames(2)
	for number: String in ROOMS:
		var room := set_root.get_node("Room" + number) as Node3D
		var real := room.get_node_or_null("Real") as Node3D
		assert_not_null(real, number + " has Real")
		if real == null:
			continue
		assert_eq(String(real.get_script().resource_path), "res://scenes/levels/cctv/cctv_room_real.gd", number + " Real's script")
		var replaced: Array = real.get("replaced")
		assert_true(replaced.size() >= 25, "%s hides its PS1 meshes (%d)" % [number, replaced.size()])
		for mesh: MeshInstance3D in replaced:
			assert_true(is_instance_valid(mesh) and mesh.is_inside_tree() and not mesh.visible, "%s %s hidden, not freed" % [number, room.get_path_to(mesh)])
		# Only the new set and the people draw.
		for node: Node in room.find_children("*", "MeshInstance3D", true, false):
			var mesh := node as MeshInstance3D
			var top := String(room.get_path_to(mesh)).get_slice("/", 0)
			if mesh.is_visible_in_tree() and top != "Real":
				assert_true(top in PEOPLE, "%s: only Real and the people draw (%s)" % [number, room.get_path_to(mesh)])
		assert_true(real.find_children("*", "CollisionObject3D", true, false).is_empty(), number + " Real has no collider")
		assert_true(real.find_children("*", "CollisionShape3D", true, false).is_empty(), number + " Real has no shape")
		assert_true(real.find_children("*", "Light3D", true, false).is_empty(), number + " Real has no light")
		for node: Node in [real] + real.find_children("*", "Node", true, false):
			assert_false(node.has_method("set_state"), "%s %s has no set_state (_cctv_310 calls it on Room310's nodes)" % [number, node.name])
		for node: Node in real.find_children("*", "GeometryInstance3D", true, false):
			assert_true((node as GeometryInstance3D).visibility_range_end > 30.0, "%s %s draws for its cameras" % [number, node.name])
		# The PS1 nets keep their nodes; the new ones keep each one's state, room 310 has none.
		var nets := 0
		for bunk: String in ["BunkA", "BunkB"]:
			for net_name: String in ["NetLower", "NetUpper"]:
				var ps1 := room.get_node_or_null("%s/%s" % [bunk, net_name]) as Node3D
				var made := real.get_node_or_null(bunk + net_name) as Node3D
				if ps1 == null:
					assert_true(made == null, "%s %s%s: no new net where main has none" % [number, bunk, net_name])
					continue
				nets += 1
				assert_not_null(made, "%s %s/%s has its room-407 net" % [number, bunk, net_name])
				if made == null:
					continue
				var open := ps1.scene_file_path == NET_OPEN_PS1
				var model := made.scene_file_path.get_file()
				assert_true(model.contains("upper" if net_name == "NetUpper" else "lower") and model.contains("open" if open else "closed"),
					"%s %s/%s: %s keeps the PS1 net's state (%s)" % [number, bunk, net_name, model, "open" if open else "closed"])
		assert_eq(nets, 0 if number == "310" else 4, number + " nets")


func test_occluders_only_in_the_rooms_and_out_of_sight() -> void:
	var set_root := _spawn()
	await wait_frames(2)
	var all := set_root.find_children("*", "OccluderInstance3D", true, false)
	assert_eq(all.size(), OCCLUDERS.size() * ROOMS.size(), "nine occluders a room, no other")
	assert_true(set_root.get_node("Corridor").find_children("*", "OccluderInstance3D", true, false).is_empty(), "none in Corridor (T-256)")
	for node: Node in all:
		var path := String(set_root.get_path_to(node))
		assert_true(path.begins_with("Room") and path.get_slice("/", 1) == "Occluders", path + " in a Room*/Occluders")
	for number: String in ROOMS:
		var room := set_root.get_node("Room" + number) as Node3D
		for name: String in OCCLUDERS:
			var occluder := room.get_node_or_null("Occluders/" + name) as OccluderInstance3D
			assert_not_null(occluder, "%s %s" % [number, name])
			if occluder == null:
				continue
			var box := occluder.occluder as BoxOccluder3D
			assert_not_null(box, "%s %s is a box" % [number, name])
			if box == null:
				continue
			var local := AABB(occluder.position - box.size / 2.0, box.size)
			for clear: AABB in CLEAR:
				# A shared face is fine (the lintel's underside is the doorway's top).
				assert_false(local.grow(-0.001).intersects(clear), "%s %s %s stays out of %s" % [number, name, local, clear])
			# test_t260_occlusion's rule: inside one solid layer-1 box (one of the room's PS1 walls).
			var inside := false
			for shape: CollisionShape3D in room.find_children("*", "CollisionShape3D", true, false):
				var body := shape.get_parent() as StaticBody3D
				if body == null or not (shape.shape is BoxShape3D) or not (body.collision_layer & 1):
					continue
				var size := (shape.shape as BoxShape3D).size
				var wall := (room.global_transform.affine_inverse() * shape.global_transform) * AABB(-size / 2.0, size)
				inside = inside or wall.grow(0.005).encloses(local)
			assert_true(inside, "%s %s inside one of the room's solid walls" % [number, name])


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
				var shared := false
				for dir: String in MATERIAL_DIRS:
					shared = shared or path.begins_with(dir)
				assert_true(shared, "%s/%s surface %d uses a shared wave 1, 2 or 10 material (%s)" % [glb, mesh.name, surface, path])
		print("T267_TRIANGLES %s %d" % [glb, triangles])
		assert_true(triangles < GLB_TRIANGLES, "%s under 5,000 triangles (%d)" % [glb, triangles])
		root.free()


func test_wave10_textures_import_vram_compressed() -> void:
	var found := 0
	for file in DirAccess.get_files_at(TEXTURES):
		if not (file.ends_with(".png") or file.ends_with(".jpg")):
			continue
		found += 1
		var config := ConfigFile.new()
		assert_eq(config.load(TEXTURES + file + ".import"), OK, file + " has import settings")
		assert_eq(config.get_value("params", "compress/mode"), 2, file + " VRAM compressed")
		assert_eq(config.get_value("params", "compress/normal_map"), 1 if file.get_basename().ends_with("_normal") else 0, file + " normal-map flag")
		var image := Image.load_from_file(ProjectSettings.globalize_path(TEXTURES + file))
		assert_true(image.get_width() <= 512 and image.get_height() <= 512, file + " at most 512 px (D-188)")
	assert_eq(found, 3, "the corridor's three masks")
	# The corridor's materials use them, not wave 2's 4096 px masks.
	for name: String in ["CWHallWall", "CWHallDado", "CWHallFloor", "CWHallCeiling"]:
		var material := load(MODELS + "materials/%s.tres" % name) as ShaderMaterial
		var mask := material.get_shader_parameter("mask") as Texture2D
		assert_true(mask.resource_path.begins_with(TEXTURES), name + " on its own small mask")


## The rooms as they ship, every victim in its story pose: nothing of Real at chest height on the manager's straight
## route, nothing of Real between Cam and the victim's head (nets too), Hall/Cam sees the doorway, the signs in frame.
func test_kit_keeps_the_route_the_view_and_the_signs() -> void:
	var set_root := _spawn()
	await wait_frames(2)
	for number: String in ROOMS:
		var victim := set_root.get_node("Room%s/Victim" % number)
		victim.call("set_pose", STORY_POSES[number])
	await wait_frames(30)
	for number: String in ROOMS:
		var room := set_root.get_node("Room" + number) as Node3D
		var real := room.get_node("Real") as Node3D
		var room_triangles := 0
		for node: Node in real.find_children("*", "MeshInstance3D", true, false):
			if (node as MeshInstance3D).is_visible_in_tree():
				room_triangles += (node as MeshInstance3D).mesh.get_faces().size() / 3
		print("T267_ROOM_TRIANGLES %s %d" % [number, room_triangles])
		assert_true(room_triangles <= ROOM_TRIANGLES, "%s at most 160,000 triangles (%d)" % [number, room_triangles])
		# The route _cctv_scene() gives him: Start -> Door -> (door x, room z - 0.6) -> ManagerSpot.
		var start := (room.get_node("Hall/Start") as Node3D).global_position
		var door := (room.get_node("Door") as Node3D).global_position
		var inside := Vector3(door.x, door.y, room.global_position.z - 0.6)
		var spot := (room.get_node("ManagerSpot") as Node3D).global_position
		var route_box := AABB(start, Vector3.ZERO).expand(door).expand(inside).expand(spot).grow(0.4)
		route_box.position.y = start.y + 0.9
		route_box.size.y = 0.8
		var near_route := _world_triangles(real, route_box)
		var blocked := ""
		for leg: Array in [[start, door], [door, inside], [inside, spot]]:
			var a: Vector3 = leg[0]
			var b: Vector3 = leg[1]
			var steps := int(ceil(a.distance_to(b) / 0.1))
			for k in range(steps + 1):
				var at := a.lerp(b, float(k) / steps) + Vector3(0, 1.25, 0)
				if _box_hits(at, Vector3(0.22, 0.2, 0.22), near_route):
					blocked = "%s at %s" % [number, room.to_local(at)]
					break
			if not blocked.is_empty():
				break
		assert_true(blocked.is_empty(), "the manager's route stays clear at chest height " + blocked)
		var cam := room.get_node("Cam") as Camera3D
		var head := (room.get_node("Victim").find_child("Head", true, false) as Node3D).global_position
		var cut := _segment_hits(cam.global_position, head, _world_triangles(real, AABB(cam.global_position, Vector3.ZERO).expand(head).grow(0.05)))
		assert_true(cut < 0.0, "%s: nothing new between Cam and the victim's head (hit at %.2f)" % [number, cut])
		var hall_cam := (room.get_node("Hall/Cam") as Node3D).global_position
		var door_middle := room.to_global(Vector3(2.45, 1.4, 0.0))
		var hall_cut := _segment_hits(hall_cam, door_middle, _world_triangles(real, AABB(hall_cam, Vector3.ZERO).expand(door_middle).grow(0.05)))
		assert_true(hall_cut < 0.0, number + ": Hall/Cam sees the doorway")
		assert_true(_feed_sees(cam, head), number + ": the victim's head in Cam's frame")
	var phone := set_root.get_node("Room306/Victim").find_child("Phone", true, false) as Node3D
	assert_true(phone.is_visible_in_tree() and _feed_sees(set_root.get_node("Room306/Cam") as Camera3D, phone.global_position),
		"306: the lit phone in the room camera's frame")
	var lamp := set_root.get_node("Room106/DeskLamp") as Node3D
	var cam106 := set_root.get_node("Room106/Cam") as Camera3D
	assert_true(_feed_sees(cam106, lamp.global_position), "106: the desk lamp in the room camera's frame")
	var lamp_model := set_root.get_node("Room106/Real").get_children().filter(func(n: Node) -> bool: return n.scene_file_path.ends_with("desk_lamp.glb"))
	assert_eq(lamp_model.size(), 1, "106: room 407's desk lamp stands on the desk")
	if lamp_model.size() == 1:
		assert_true((lamp_model[0] as Node3D).global_position.distance_to(lamp.global_position) < 0.4, "106: the lamp model under DeskLamp's light")


## Whether `point` is in the frame of a feed of `source` (the director's: a 320 x 240 SubViewport, source's fov, far).
func _feed_sees(source: Camera3D, point: Vector3) -> bool:
	var feed := SubViewport.new()
	feed.size = Vector2i(320, 240)
	feed.render_target_update_mode = SubViewport.UPDATE_DISABLED
	fixtures.append(feed)
	tree.root.add_child(feed)
	var camera := Camera3D.new()
	camera.fov = source.fov
	camera.far = source.far
	feed.add_child(camera)
	camera.global_transform = source.global_transform
	return camera.is_position_in_frustum(point)


## World-space triangles of root's visible meshes whose bounds touch `near`.
func _world_triangles(root: Node, near: AABB) -> PackedVector3Array:
	var result := PackedVector3Array()
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if not mesh.is_visible_in_tree():
			continue
		var xform := mesh.global_transform
		if not (xform * mesh.get_aabb()).intersects(near):
			continue
		var faces := mesh.mesh.get_faces()
		for i in range(0, faces.size(), 3):
			var a := xform * faces[i]
			var b := xform * faces[i + 1]
			var c := xform * faces[i + 2]
			if AABB(a, Vector3.ZERO).expand(b).expand(c).intersects(near):
				result.append(a)
				result.append(b)
				result.append(c)
	return result


## Whether any triangle overlaps the box (centre, half extents): separating axis test.
func _box_hits(centre: Vector3, half: Vector3, triangles: PackedVector3Array) -> bool:
	var box := AABB(centre - half, half * 2.0)
	for i in range(0, triangles.size(), 3):
		var bounds := AABB(triangles[i], Vector3.ZERO).expand(triangles[i + 1]).expand(triangles[i + 2])
		if not bounds.intersects(box):
			continue
		if _tri_box(triangles[i] - centre, triangles[i + 1] - centre, triangles[i + 2] - centre, half):
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
