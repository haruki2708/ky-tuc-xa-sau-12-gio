extends Node3D
## T-263 round 1, step 1: walks the canteen on main's campus (no wave-6 piece is in any scene yet) and prints what the
## contract and the A16 box must hold: the navmesh paths (Start_gate -> P30_Wait_canteen -> CanteenExit, the canteen
## horde's spawns and idles -> the player's spots, chapter 4's Start_split -> the hall and -> Start_library), the
## companions' and the bot's anchor walk (tools/ch3-profile.json route "gate"; Paths/Nhat P28..P33 through the store and
## out of the back door) done by the real player body with move_and_slide, a loop through the kitchen to the clock and
## the store's shelves, chapter 4's walk from Start_split in through the west exit, and the sightline from the main
## door and from the middle of the hall to the TV.
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (Lượt Godot):
##   godot --headless --path game res://_probe_tmp/walk_canteen.tscn
const G := -9.9
const SPEED := 4.0
const AREA := Rect2(160, 8, 66, 58)  # x 160..226, z 8..66: the part of each path printed in full

var campus: Node3D
var player: CharacterBody3D
var map: RID
var box_min := Vector2(INF, INF)
var box_max := Vector2(-INF, -INF)


func _ready() -> void:
	call_deferred("_run")


func _anchor(path: String) -> Vector3:
	return (campus.get_node("Anchors/" + path) as Node3D).global_position


func _note(p: Vector3) -> void:
	if AREA.has_point(Vector2(p.x, p.z)):
		box_min = Vector2(minf(box_min.x, p.x), minf(box_min.y, p.z))
		box_max = Vector2(maxf(box_max.x, p.x), maxf(box_max.y, p.z))


func _path(label: String, a: Vector3, b: Vector3) -> void:
	var path := NavigationServer3D.map_get_path(map, a, b, true)
	var pts: PackedStringArray = []
	var length := 0.0
	for i in path.size():
		if i > 0:
			length += path[i - 1].distance_to(path[i])
		if AREA.has_point(Vector2(path[i].x, path[i].z)):
			pts.append("(%.1f, %.1f)" % [path[i].x, path[i].z])
			_note(path[i])
	var ok := path.size() > 1 and path[-1].distance_to(b) < 0.6
	print("PATH %s %s %.0f m, %d points; in x160..226 z8..66: %s" % [label, "ok" if ok else "BROKEN", length, path.size(), ", ".join(pts)])


func _walk(label: String, points: Array[Vector3]) -> bool:
	player.global_position = points[0] + Vector3(0, 0.05, 0)
	player.velocity = Vector3.ZERO
	for frame in 4:
		await get_tree().physics_frame
	var lowest := INF
	for target: Vector3 in points.slice(1):
		var frames := 240 + int(player.global_position.distance_to(target) / SPEED * 60.0 * 1.5)
		var reached := false
		for frame in frames:
			await get_tree().physics_frame
			var offset := target - player.global_position
			offset.y = 0.0
			_note(player.global_position)
			lowest = minf(lowest, player.global_position.y)
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
				blockers.append(String(c.get_path()).trim_prefix(String(campus.get_path())))
		print("WALK %s -> (%.1f, %.1f): %s, feet (%.2f, %.2f, %.2f)%s" % [label, target.x, target.z, "reached" if reached else "STUCK",
			player.global_position.x, player.global_position.y, player.global_position.z, "" if reached else " blockers %s" % blockers])
		if not reached:
			return false
	print("WALK %s done, lowest feet %.2f" % [label, lowest])
	return true


func _sight(label: String, eye: Vector3, target: Vector3) -> void:
	var space := campus.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(eye, target, 1)
	var hit := space.intersect_ray(query)
	print("SIGHT %s: %s" % [label, "clear" if hit.is_empty() else "blocked by %s at %s" % [(hit.collider as Node).get_path(), hit.position]])


func _run() -> void:
	campus = (load("res://scenes/levels/campus/campus.tscn") as PackedScene).instantiate() as Node3D
	add_child(campus)
	for frame in 3:
		await get_tree().physics_frame
	map = campus.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(map)
	for attempt in 360:
		if NavigationServer3D.map_get_iteration_id(map) > 0 \
				and NavigationServer3D.map_get_closest_point(map, Vector3(190, G, 32)).distance_to(Vector3(190, G, 32)) < 0.1:
			break
		await get_tree().physics_frame
	var wait := _anchor("Paths/Nhat/P30_Wait_canteen")
	var split := _anchor("Ch4/Start_split")
	_path("Start_gate->P30_Wait_canteen", _anchor("Start_gate"), wait)
	_path("P30_Wait_canteen->CanteenExit", wait, _anchor("CanteenExit"))
	_path("P30_Wait_canteen->KitchenClock", wait, Vector3(192, G, 49.5))
	for i in range(1, 7):
		_path("Canteen/S%02d->P30" % i, _anchor("ZombieSpawns/Canteen/S%02d" % i), wait)
		_path("Canteen/I%02d->P30" % i, _anchor("ZombieIdle/Canteen/I%02d" % i), wait)
		_path("Canteen/S%02d->CanteenExit" % i, _anchor("ZombieSpawns/Canteen/S%02d" % i), _anchor("CanteenExit"))
	_path("Start_split->P30 (west exit)", split, wait)
	_path("Start_split->Start_library", split, _anchor("Ch4/Start_library"))
	print("NAVBOX paths x %.1f..%.1f, z %.1f..%.1f" % [box_min.x, box_max.x, box_min.y, box_max.y])
	var tv := _anchor("CanteenTV")
	_sight("main door eye -> TV", Vector3(190, G + 1.6, 21.5), tv + Vector3(0.12, 0, 0))
	_sight("hall middle eye -> TV", Vector3(190, G + 1.6, 32), tv + Vector3(0.12, 0, 0))
	_sight("P30 eye -> kitchen clock", Vector3(190, G + 1.6, 32), _anchor("CanteenClock") + Vector3(0, 0, -0.1))
	player = (load("res://scenes/player/player.tscn") as PackedScene).instantiate() as CharacterBody3D
	add_child(player)
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	var nhat: Array[Vector3] = []
	for name in ["P28", "P29", "P30_Wait_canteen", "P31", "P32", "P33"]:
		nhat.append(_anchor("Paths/Nhat/" + name))
	await _walk("companions P28..P33 (front door, hall, store, back door)", nhat)
	var ngu: Array[Vector3] = []
	for name in ["P18", "P19", "P20_Wait_canteen", "P21", "P22", "P23"]:
		ngu.append(_anchor("Paths/Ngu/" + name))
	await _walk("Ngu P18..P23", ngu)
	await _walk("bot gate route Start_gate->P28->P29->P30", [_anchor("Start_gate"), _anchor("Paths/Nhat/P28"), _anchor("Paths/Nhat/P29"), wait])
	await _walk("kitchen loop", [wait, Vector3(192, G, 42.5), Vector3(192, G, 45.5), Vector3(192, G, 49.6), Vector3(196.5, G, 49.6),
		Vector3(196.5, G, 47.5), Vector3(190.5, G, 47.5), Vector3(190.5, G, 49.9), Vector3(192, G, 45.5), Vector3(192, G, 42.5), wait])
	await _walk("store loop", [wait, Vector3(202, G, 42.5), Vector3(202, G, 46), Vector3(205, G, 46), Vector3(207.5, G, 50.5),
		Vector3(202, G, 50.5), Vector3(202, G, 53.5), Vector3(202, G, 57)])
	await _walk("hall aisles", [Vector3(190, G, 21.5), Vector3(176, G, 24.8), Vector3(176, G, 40), Vector3(190, G, 40), Vector3(190, G, 39.6),
		Vector3(205, G, 40), Vector3(205, G, 24.8), Vector3(190, G, 21.5)])
	await _walk("counter front and tray return", [Vector3(186, G, 40.2), Vector3(171.5, G, 40.2), Vector3(171.5, G, 21), Vector3(208.2, G, 21),
		Vector3(208.2, G, 37), Vector3(208.2, G, 42.5), Vector3(200, G, 42.5)])
	await _walk("chapter 4 Start_split in through the west exit and back", [split, Vector3(171.5, G, 40.5), Vector3(176, G, 39.8),
		Vector3(182, G, 32), Vector3(176, G, 39.8), Vector3(171.5, G, 40.5), split])
	await _walk("chapter 4 Start_split round the west side", [split, Vector3(166, G, 30), Vector3(166, G, 18), Vector3(190, G, 17)])
	await _walk("front yard to the back (east side)", [Vector3(190, G, 15), Vector3(213, G, 15), Vector3(213, G, 57), Vector3(202, G, 57)])
	await _walk("back yard west", [Vector3(202, G, 57), Vector3(185, G, 55), Vector3(168, G, 50), Vector3(167, G, 40.5)])
	print("WALKBOX feet x %.1f..%.1f, z %.1f..%.1f" % [box_min.x, box_max.x, box_min.y, box_max.y])
	print("RESULT: walk_canteen done")
	get_tree().quit()
