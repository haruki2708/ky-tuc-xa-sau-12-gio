extends Node3D
## T-265 round 1, step 1: walks the library in chapter 4's real scene (chapter4.tscn, director held) with the chapter's own
## player body (Player: CharacterBody3D, capsule r 0.3 h 1.75, driven here by move_and_slide) and prints what the contract
## must keep: the back door closed blocks and open lets through; the walk outside -> back door -> Start_library -> the
## counter (iron bar) -> the map -> stairs to floor 2 -> the reading desk -> floor 3 -> ScareShelf3F, ThrownBook3F -> down
## and out; the nearest the feet come to each scare anchor (librarian_rise 4 m, books_fall 3 m, shelf_corpse 2.5 m); a
## loop outside 0.7 m off the walls; the six zombie spawns (capsule clear, ground under them); the stairwell's open edges
## on floors 2 and 3; the navmesh routes the zombies and test_ch4_environment use; sightlines the card keeps clear.
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (headless):
##   godot --headless --path game res://_probe_tmp/walk_wave8.tscn
const SPEED := 4.0
const F1 := -9.9
const F2 := -6.6
const F3 := -3.3
const SCARES := {"librarian_rise": ["Ch4/LibrarianSeat", 4.0], "books_fall": ["Ch4/ScareShelf3F", 3.0], "shelf_corpse": ["Ch4/ThrownBook3F", 2.5]}

var chapter: Node3D
var campus: Node3D
var player: CharacterBody3D
var map: RID
var nearest := {}


func _ready() -> void:
	call_deferred("_run")


func _anchor(path: String) -> Vector3:
	return (campus.get_node("Anchors/" + path) as Node3D).global_position


func _clear(point: Vector3, height: float = 1.75) -> Array:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = height
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.collision_mask = 1
	query.margin = 0.001
	query.transform.origin = point + Vector3(0, height / 2.0 + 0.06, 0)
	var hits: Array = []
	for hit: Dictionary in campus.get_world_3d().direct_space_state.intersect_shape(query):
		hits.append(String(campus.get_path_to(hit.collider as Node)))
	return hits


func _ground(at: Vector3) -> float:
	var query := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 0.5, at + Vector3.DOWN * 2.0, 1)
	var hit := campus.get_world_3d().direct_space_state.intersect_ray(query)
	return (hit.position as Vector3).y if not hit.is_empty() else -INF


func _note_scares() -> void:
	for id: String in SCARES:
		var d := player.global_position.distance_to(_anchor(SCARES[id][0]))
		nearest[id] = minf(float(nearest.get(id, INF)), d)


func _walk(label: String, points: Array[Vector3]) -> bool:
	player.global_position = points[0] + Vector3(0, 0.05, 0)
	player.velocity = Vector3.ZERO
	for frame in 4:
		await get_tree().physics_frame
	var lowest := INF
	var highest := -INF
	for target: Vector3 in points.slice(1):
		var frames := 240 + int(player.global_position.distance_to(target) / SPEED * 60.0 * 1.5)
		var reached := false
		for frame in frames:
			await get_tree().physics_frame
			var offset := target - player.global_position
			offset.y = 0.0
			lowest = minf(lowest, player.global_position.y)
			highest = maxf(highest, player.global_position.y)
			_note_scares()
			if offset.length() < 0.3:
				reached = true
				break
			var d := offset.normalized()
			player.velocity.x = d.x * SPEED
			player.velocity.z = d.z * SPEED
			player.velocity.y = 0.0 if player.is_on_floor() else player.velocity.y - 9.8 / 60.0
			player.move_and_slide()
		var blockers: PackedStringArray = []
		for i in player.get_slide_collision_count():
			var c := player.get_slide_collision(i).get_collider() as Node
			if c != null:
				blockers.append(String(campus.get_path_to(c)) if campus.is_ancestor_of(c) else String(c.get_path()))
		print("WALK %s -> (%.2f, %.2f, %.2f): %s, feet (%.2f, %.2f, %.2f)%s" % [label, target.x, target.y, target.z, "reached" if reached else "STUCK",
			player.global_position.x, player.global_position.y, player.global_position.z, "" if reached else " blockers %s" % blockers])
		if not reached:
			print("WALK %s stopped, feet y %.2f..%.2f" % [label, lowest, highest])
			return false
	print("WALK %s done, feet y %.2f..%.2f" % [label, lowest, highest])
	return true


func _path(label: String, a: Vector3, b: Vector3) -> void:
	var path := NavigationServer3D.map_get_path(map, a, b, true)
	var length := 0.0
	for i in range(1, path.size()):
		length += path[i - 1].distance_to(path[i])
	var ok := path.size() > 1 and path[-1].distance_to(b) < 0.3 and path[0].distance_to(a) < 0.3
	var pts: PackedStringArray = []
	for p in path:
		pts.append("(%.1f, %.1f, %.1f)" % [p.x, p.y, p.z])
	print("PATH %s %s %.1f m, %d points: %s" % [label, "ok" if ok else "BROKEN", length, path.size(), ", ".join(pts)])


func _sight(label: String, eye: Vector3, target: Vector3) -> void:
	var query := PhysicsRayQueryParameters3D.create(eye, target, 1)
	var hit := campus.get_world_3d().direct_space_state.intersect_ray(query)
	print("SIGHT %s: %s" % [label, "clear" if hit.is_empty() else "blocked by %s at %s" % [campus.get_path_to(hit.collider as Node), hit.position]])


func _run() -> void:
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	chapter = (load("res://scenes/main/chapter4.tscn") as PackedScene).instantiate() as Node3D
	chapter.get_node("Chapter4Director").set("auto_start", false)
	add_child(chapter)
	for frame in 3:
		await get_tree().physics_frame
	campus = chapter.get_node("Campus") as Node3D
	player = chapter.get_node("Player") as CharacterBody3D
	player.set_physics_process(false)
	player.set_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	print("PLAYER %s capsule r %.2f h %.2f, floor_max_angle %.1f, snap %.2f, step? %s" % [player.get_class(),
		((player.get_node("CollisionShape3D") as CollisionShape3D).shape as CapsuleShape3D).radius,
		((player.get_node("CollisionShape3D") as CollisionShape3D).shape as CapsuleShape3D).height, rad_to_deg(player.floor_max_angle),
		player.floor_snap_length, player.get_script().resource_path.get_file() if player.get_script() != null else "-"])
	map = campus.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(map)
	for attempt in 360:
		var probe := NavigationServer3D.map_get_path(map, Vector3(65, F1, 211), Vector3(65, F3, 211), true)
		if probe.size() > 1 and probe[-1].distance_to(Vector3(65, F3, 211)) < 0.3:
			break
		await get_tree().physics_frame
	var door := campus.get_node("Library/BackDoor")
	var start := _anchor("Ch4/Start_library")
	print("ANCHOR Start_library %s, door %s, hinge %s" % [start, (door as Node3D).global_position, (door.get_node("Hinge") as Node3D).global_position])
	print("CLEAR closed door at (65, -9.9, 225): %s" % [_clear(Vector3(65, F1, 225))])
	# Closed: the body from outside must stop at the leaf.
	await _walk("closed back door from outside", [Vector3(65, F1, 228), Vector3(65, F1, 222)])
	door.set_open(true)
	await get_tree().create_timer(0.5).timeout
	await get_tree().physics_frame
	print("CLEAR open door at (65, -9.9, 224.4 / 225 / 225.6): %s %s %s" % [_clear(Vector3(65, F1, 224.4)), _clear(Vector3(65, F1, 225)),
		_clear(Vector3(65, F1, 225.6))])
	var leaf := door.get_node("Hinge/Leaf") as Node3D
	print("LEAF open at %s, its mesh aabb %s" % [leaf.global_position, (leaf.get_node("Mesh") as MeshInstance3D).global_transform * (leaf.get_node("Mesh") as MeshInstance3D).get_aabb()])
	nearest.clear()
	await _walk("route 1: outside -> back door -> Start_library -> counter -> iron bar spot", [Vector3(65, F1, 228), Vector3(65, F1, 224.5), start,
		Vector3(65, F1, 211), Vector3(60, F1, 207.6), Vector3(58.3, F1, 207.3)])
	print("BAR stand (58.3, 207.3): bar at %s, %.2f m from the feet" % [(campus.get_node("Library/Counter/IronBar") as Node3D).global_position,
		player.global_position.distance_to((campus.get_node("Library/Counter/IronBar") as Node3D).global_position)])
	await _walk("route 2: counter -> map board", [Vector3(60, F1, 207.6), Vector3(60, F1, 211), Vector3(46.4, F1, 211)])
	await _walk("route 3: map -> stair foot -> floor 2", [Vector3(46.4, F1, 211), Vector3(77.5, F1, 211), Vector3(77.5, F1, 197), Vector3(81, F1, 197),
		Vector3(81, F1, 198.6), Vector3(81, F2, 209.6), Vector3(81, F2, 211.5)])
	await _walk("route 4: floor 2 stair top -> reading desk", [Vector3(81, F2, 211.5), Vector3(65, F2, 211), Vector3(61, F2, 214.5), Vector3(60.2, F2, 216)])
	await _walk("route 5: reading desk -> floor 2 stair foot -> floor 3", [Vector3(60.2, F2, 216), Vector3(65, F2, 211), Vector3(77.5, F2, 211),
		Vector3(77.5, F2, 197), Vector3(81, F2, 197), Vector3(81, F2, 198.6), Vector3(81, F3, 209.6), Vector3(81, F3, 211.5)])
	await _walk("route 6: floor 3 -> ScareShelf3F -> ThrownBook3F", [Vector3(81, F3, 211.5), Vector3(65, F3, 211), Vector3(57, F3, 215.5), Vector3(57, F3, 216.8),
		Vector3(65, F3, 216.8), Vector3(73, F3, 217.2)])
	await _walk("route 7: floor 3 -> down both flights -> out of the back door", [Vector3(73, F3, 217.2), Vector3(65, F3, 211), Vector3(81, F3, 211.5),
		Vector3(81, F3, 209.6), Vector3(81, F2, 198.6), Vector3(81, F2, 197), Vector3(77.5, F2, 197), Vector3(77.5, F2, 211), Vector3(81, F2, 211.5),
		Vector3(81, F2, 209.6), Vector3(81, F1, 198.6), Vector3(81, F1, 197), Vector3(77.5, F1, 197), Vector3(77.5, F1, 211), Vector3(65, F1, 211),
		Vector3(65, F1, 223), Vector3(65, F1, 228)])
	for id: String in SCARES:
		print("SCARE %s: nearest feet %.2f m from %s (radius %.1f) -> %s" % [id, nearest.get(id, INF), SCARES[id][0], SCARES[id][1],
			"fires" if float(nearest.get(id, INF)) <= SCARES[id][1] else "NOT reached"])
	# Outside, 0.7 m off the walls' outer faces (x 44.89 / 85.11, z 194.89 / 225.11).
	var w := 44.89 - 0.7
	var e := 85.11 + 0.7
	var s := 194.89 - 0.7
	var n := 225.11 + 0.7
	await _walk("outside: back, west of the door", [Vector3(65, F1, 226.5), Vector3(65, F1, n), Vector3(w, F1, n)])
	await _walk("outside: west side", [Vector3(w, F1, n), Vector3(w, F1, s)])
	await _walk("outside: front", [Vector3(w, F1, s), Vector3(e, F1, s)])
	await _walk("outside: front from the east", [Vector3(e, F1, s), Vector3(w, F1, s)])
	await _walk("outside: east side", [Vector3(e, F1, s), Vector3(e, F1, n)])
	await _walk("outside: back, east of the door", [Vector3(e, F1, n), Vector3(65, F1, n)])
	for x in [44.19, 50.0, 56.0, 58.0, 60.0, 65.0, 70.0, 76.0, 78.0, 80.0, 85.81]:
		print("FRONT strip x %.2f: z 194.19 %s | z 193.0 %s | z 191.0 %s" % [x, _clear(Vector3(x, F1, 194.19)), _clear(Vector3(x, F1, 193.0)),
			_clear(Vector3(x, F1, 191.0))])
	for spawn: Node3D in campus.get_node("Anchors/Ch4/LibraryZombieSpawn").get_children():
		print("SPAWN %s %s: capsule %s, ground %.3f" % [spawn.name, spawn.global_position, _clear(spawn.global_position), _ground(spawn.global_position)])
	# Stairwell edges: from the floor plate east toward the opening (x 79..85, z 199..209).
	await _walk("edge probe floor 2: west edge of the stairwell at z 205", [Vector3(77.5, F2, 205), Vector3(80.5, F2, 205)])
	await _walk("edge probe floor 3: west edge of the stairwell at z 205", [Vector3(77.5, F3, 205), Vector3(80.5, F3, 205)])
	await _walk("edge probe floor 3: north edge at x 81 (top of flight 2)", [Vector3(81, F3, 211.5), Vector3(81, F3, 207)])
	await _walk("edge probe floor 2: north edge at x 83.9 (beside flight 1's top)", [Vector3(83.5, F2, 211.5), Vector3(84.5, F2, 207)])
	# The navmesh: what the zombies and test_ch4_environment walk.
	door.set_open(true)
	_path("Start_library -> counter approach", start, Vector3(60, F1, 207.5))
	_path("Start_library -> map board", start, Vector3(46.5, F1, 211))
	_path("Start_library -> floor 2", start, Vector3(65, F2, 211))
	_path("Start_library -> reading desk", start, Vector3(60.2, F2, 216))
	_path("Start_library -> floor 3", start, Vector3(65, F3, 211))
	_path("Start_library -> ScareShelf3F side", start, Vector3(57, F3, 213))
	for spawn: Node3D in campus.get_node("Anchors/Ch4/LibraryZombieSpawn").get_children():
		_path("%s -> door (65, 226)" % spawn.name, spawn.global_position, Vector3(65, F1, 226))
		_path("%s -> floor 3" % spawn.name, spawn.global_position, Vector3(65, F3, 211))
	_path("Start_split -> Start_library", _anchor("Ch4/Start_split"), start)
	_path("Start_library -> Start_return", start, _anchor("Ch4/Start_return"))
	_sight("back door (inside) eye -> counter top", Vector3(65, F1 + 1.6, 224.3), Vector3(58, F1 + 0.9, 206.2))
	_sight("Start_library eye -> counter top", start + Vector3(0, 1.6, 0), Vector3(58, F1 + 0.9, 206.2))
	_sight("floor 2 stair top eye -> reading desk book", Vector3(81, F2 + 1.6, 210.5), Vector3(58, F2 + 0.95, 216))
	_sight("floor 2 stair top eye -> reading desk (from the access)", Vector3(78, F2 + 1.6, 212), Vector3(58, F2 + 0.95, 216))
	print("RESULT: walk_wave8 done")
	get_tree().quit()
