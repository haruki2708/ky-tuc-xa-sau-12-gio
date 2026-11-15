extends Node3D
## T-262 round 1, step 1: walks the stadium -> gate -> canteen stretch of chapter 3 on main's campus (no wave-5 piece is
## in any scene yet) and prints what the A16 gate box must hold: the navmesh paths (Start_stadium -> Start_gate,
## Start_gate -> CanteenExit, the gate horde's spawns and idles -> Start_gate), the companions' and the bot's anchor
## walk (tools/ch3-profile.json routes "stadium" and "gate") done by the real player body with move_and_slide, the
## walk from Start_gate to the edge of the guards' 12 m turn radius, and the sightlines from Start_gate (eye 1.6 m) to
## the twelve guards' chests (1.3 m) against the world colliders.
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (Lượt Godot):
##   godot --headless --path game res://_probe_tmp/walk_route.tscn
const G := -9.9
const SPEED := 4.0
const AREA := Rect2(170, -70, 100, 90)  # x 170..270, z -70..20: the part of each path printed in full

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
	print("PATH %s %s %.0f m, %d points; in x170..270 z-70..20: %s" % [label, "ok" if ok else "BROKEN", length, path.size(), ", ".join(pts)])


func _walk(label: String, points: Array[Vector3]) -> void:
	player.global_position = points[0] + Vector3(0, 0.05, 0)
	player.velocity = Vector3.ZERO
	for frame in 4:
		await get_tree().physics_frame
	for target: Vector3 in points.slice(1):
		var frames := 240 + int(player.global_position.distance_to(target) / SPEED * 60.0 * 1.5)
		var reached := false
		for frame in frames:
			await get_tree().physics_frame
			var offset := target - player.global_position
			offset.y = 0.0
			_note(player.global_position)
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
			return


func _sightlines() -> void:
	var space := campus.get_world_3d().direct_space_state
	var eye := _anchor("Start_gate") + Vector3(0, 1.6, 0)
	var blocked: PackedStringArray = []
	for guard in campus.get_node("Anchors/GuardLine").get_children():
		var chest := (guard as Node3D).global_position + Vector3(0, 1.3, 0)
		var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(eye, chest, 1))
		if not hit.is_empty():
			blocked.append("%s by %s" % [guard.name, (hit.collider as Node).name])
	print("SIGHT Start_gate eye -> 12 guards' chests: %s" % ("all clear" if blocked.is_empty() else ", ".join(blocked)))


func _run() -> void:
	campus = (load("res://scenes/levels/campus/campus.tscn") as PackedScene).instantiate() as Node3D
	add_child(campus)
	for frame in 3:
		await get_tree().physics_frame
	map = campus.get_world_3d().navigation_map
	NavigationServer3D.map_force_update(map)
	for attempt in 360:
		if NavigationServer3D.map_get_iteration_id(map) > 0 \
				and NavigationServer3D.map_get_closest_point(map, Vector3(115, G, 166)).distance_to(Vector3(115, G, 166)) < 0.1:
			break
		await get_tree().physics_frame
	_path("Start_stadium->Start_gate", _anchor("Start_stadium"), _anchor("Start_gate"))
	_path("Start_gate->CanteenExit", _anchor("Start_gate"), _anchor("CanteenExit"))
	for i in range(1, 7):
		_path("Gate/S%02d->Start_gate" % i, _anchor("ZombieSpawns/Gate/S%02d" % i), _anchor("Start_gate"))
		_path("Gate/I%02d->Start_gate" % i, _anchor("ZombieIdle/Gate/I%02d" % i), _anchor("Start_gate"))
	_path("Start_gate->Canteen/S01", _anchor("Start_gate"), _anchor("ZombieSpawns/Canteen/S01"))
	print("NAVBOX paths x %.1f..%.1f, z %.1f..%.1f" % [box_min.x, box_max.x, box_min.y, box_max.y])
	_sightlines()
	player = (load("res://scenes/player/player.tscn") as PackedScene).instantiate() as CharacterBody3D
	add_child(player)
	player.set_physics_process(false)
	player.set_process_input(false)
	player.set_process_unhandled_input(false)
	var nhat: Array[Vector3] = []
	for name in ["P24", "P25", "P26", "P27_Wait_gate", "P28", "P29", "P30_Wait_canteen"]:
		nhat.append(_anchor("Paths/Nhat/" + name))
	# Companions (and the bot's "stadium" + "gate" routes): from the stadium's west gate down WestBranch, east along the
	# Avenue, into the court, then up to the canteen. Only the stretch from P25 is walked (the rest was T-261's).
	await _walk("companions P25..P30", nhat.slice(1))
	await _walk("bot stadium end P26->Start_gate", [_anchor("Paths/Nhat/P26"), _anchor("Start_gate")])
	await _walk("bot gate route", [_anchor("Start_gate"), _anchor("Paths/Nhat/P28"), _anchor("Paths/Nhat/P29"), _anchor("Paths/Nhat/P30_Wait_canteen")])
	# Toward the guard line, stopping 12 m short of the nearest guard (G06/G07 at z -54).
	await _walk("Start_gate -> guard turn edge", [_anchor("Start_gate"), Vector3(220, G, -41.5)])
	# Round the court between the parked cars, the rubble at (214, -22.7) and the moped at (225, -25).
	await _walk("court round", [Vector3(220, G, -41.5), Vector3(196, G, -44), Vector3(196, G, -29.5), Vector3(246, G, -29.5),
		Vector3(246, G, -46), Vector3(232, G, -46), Vector3(220, G, -41.5)])
	# From the court's north-east corner to the Avenue's end and west along it to x 180.
	await _walk("court to Avenue", [Vector3(246, G, -29.5), Vector3(246, G, -15), Vector3(180, G, -15)])
	print("WALKBOX feet x %.1f..%.1f, z %.1f..%.1f" % [box_min.x, box_max.x, box_min.y, box_max.y])
	print("RESULT: walk_route done")
	get_tree().quit()
