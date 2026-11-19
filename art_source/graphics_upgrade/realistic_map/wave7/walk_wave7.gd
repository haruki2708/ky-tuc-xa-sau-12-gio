extends Node3D
## T-264 round 1, step 1: walks main's campus with the real player body (move_and_slide, no wave-7 piece in any scene
## yet): round the three background buildings close to their walls, the road north of the stadium, chapter 4's way from
## the canteen's west exit to the library's door (the navmesh path, then its corners on foot), along the north, east and
## west fences where the player can reach them, and the Avenue's two verges among the trees. Prints the navmesh paths,
## where each walk was blocked and by what, and the feet's extent (the strip's box).
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (Lượt Godot):
##   godot --headless --path game res://_probe_tmp/walk_wave7.tscn
const G := -9.9
const SPEED := 4.0

var campus: Node3D
var player: CharacterBody3D
var map: RID


func _ready() -> void:
	call_deferred("_run")


func _anchor(path: String) -> Vector3:
	return (campus.get_node("Anchors/" + path) as Node3D).global_position


func _path(label: String, a: Vector3, b: Vector3) -> PackedVector3Array:
	var path := NavigationServer3D.map_get_path(map, a, b, true)
	var length := 0.0
	var pts: PackedStringArray = []
	for i in path.size():
		if i > 0:
			length += path[i - 1].distance_to(path[i])
		pts.append("(%.1f, %.1f)" % [path[i].x, path[i].z])
	var ok := path.size() > 1 and path[-1].distance_to(b) < 0.6
	print("PATH %s %s %.0f m: %s" % [label, "ok" if ok else "BROKEN", length, ", ".join(pts)])
	return path


func _walk(label: String, points: Array[Vector3]) -> bool:
	player.global_position = points[0] + Vector3(0, 0.05, 0)
	player.velocity = Vector3.ZERO
	for frame in 4:
		await get_tree().physics_frame
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	var stuck := 0
	for target: Vector3 in points.slice(1):
		var frames := 240 + int(player.global_position.distance_to(target) / SPEED * 60.0 * 1.5)
		var reached := false
		for frame in frames:
			await get_tree().physics_frame
			var offset := target - player.global_position
			offset.y = 0.0
			var p := player.global_position
			lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.z))
			hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.z))
			if offset.length() < 0.3:
				reached = true
				break
			var d := offset.normalized()
			player.velocity.x = d.x * SPEED
			player.velocity.z = d.z * SPEED
			player.velocity.y = 0.0 if player.is_on_floor() else player.velocity.y - 9.8 / 60.0
			player.move_and_slide()
		if not reached:
			stuck += 1
			var blockers: PackedStringArray = []
			for i in player.get_slide_collision_count():
				var c := player.get_slide_collision(i).get_collider() as Node
				if c != null:
					blockers.append(String(c.get_path()).trim_prefix(String(campus.get_path())))
			print("WALK %s -> (%.1f, %.1f): STUCK at (%.2f, %.2f) blockers %s" % [label, target.x, target.z, player.global_position.x,
				player.global_position.z, blockers])
			# Carry on from the target so one blocked leg does not end the walk.
			player.global_position = target + Vector3(0, 0.05, 0)
			player.velocity = Vector3.ZERO
			for frame in 2:
				await get_tree().physics_frame
	print("WALK %s done, %d legs blocked, feet x %.1f..%.1f z %.1f..%.1f" % [label, stuck, lo.x, hi.x, lo.y, hi.y])
	return stuck == 0


func _ring(label: String, x0: float, x1: float, z0: float, z1: float, off: float) -> void:
	await _walk(label, [Vector3(x0 - off, G, z0 - off), Vector3(x1 + off, G, z0 - off), Vector3(x1 + off, G, z1 + off),
		Vector3(x0 - off, G, z1 + off), Vector3(x0 - off, G, z0 - off)])


func _run() -> void:
	campus = (load("res://scenes/levels/campus/campus.tscn") as PackedScene).instantiate() as Node3D
	add_child(campus)
	for frame in 3:
		await get_tree().physics_frame
	map = campus.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(map)
	for attempt in 360:
		if NavigationServer3D.map_get_iteration_id(map) > 0:
			break
		await get_tree().physics_frame
	for frame in 30:
		await get_tree().physics_frame
	var split := _anchor("Ch4/Start_split")
	var library := _anchor("Ch4/Start_library")
	var ch4 := _path("Start_split->Start_library", split, library)
	_path("Start_split->Library door (65, 192)", split, Vector3(65, G, 192))
	_path("Start_garden->Start_stadium", _anchor("Start_garden"), _anchor("Start_stadium"))
	_path("Start_stadium->Start_gate", _anchor("Start_stadium"), _anchor("Start_gate"))
	for idle in campus.get_node("Anchors/ZombieIdle/Road").get_children():
		print("ROAD IDLE %s (%.1f, %.1f)" % [idle.name, (idle as Node3D).global_position.x, (idle as Node3D).global_position.z])
	for spawn in campus.get_node("Anchors/ZombieSpawns/Road").get_children():
		print("ROAD SPAWN %s (%.1f, %.1f)" % [spawn.name, (spawn as Node3D).global_position.x, (spawn as Node3D).global_position.z])
	player = (load("res://scenes/player/player.tscn") as PackedScene).instantiate() as CharacterBody3D
	add_child(player)
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	await _ring("building A, 0.7 m off its walls", 0.0, 44.0, 54.0, 64.0, 0.7)
	await _ring("gym, 0.7 m off its walls", -60.0, 0.0, 90.0, 130.0, 0.7)
	await _ring("lecture hall, 0.7 m off its walls", -50.0, 30.0, 180.0, 200.0, 0.7)
	var ch4_walk: Array[Vector3] = []
	for p in ch4:
		ch4_walk.append(p)
	if ch4_walk.size() > 1:
		await _walk("chapter 4 Start_split -> Start_library (navmesh corners)", ch4_walk)
	await _walk("north of the stadium", [Vector3(100, G, 245), Vector3(200, G, 245), Vector3(300, G, 245), Vector3(300, G, 200),
		Vector3(300, G, 170), Vector3(310, G, 100)])
	await _walk("west fence (x -78.6)", [Vector3(-78.6, G, -55), Vector3(-78.6, G, 100), Vector3(-78.6, G, 285)])
	await _walk("north fence (z 288.6)", [Vector3(-75, G, 288.6), Vector3(100, G, 288.6), Vector3(250, G, 288.6), Vector3(415, G, 288.6)])
	await _walk("east fence (x 418.6)", [Vector3(418.6, G, 285), Vector3(418.6, G, 100), Vector3(418.6, G, -55)])
	await _walk("the Avenue's verges", [Vector3(0, G, -10.2), Vector3(180, G, -10.2), Vector3(180, G, -19.8), Vector3(0, G, -19.8)])
	await _walk("the East Branch", [Vector3(310, G, -28), Vector3(310, G, 165), Vector3(305.2, G, 165), Vector3(305.2, G, -28)])
	print("RESULT: walk_wave7 done")
	get_tree().quit()
