extends RefCounted
## QA strategy only. Gameplay rules and acknowledgements stay in lane A/core.

const STAGES := ["b", "garden", "stadium", "gate"]
const CASES := ["ch3_good", "ch3_grabbed", "ch3_guard"]


static func preflight(profile: Dictionary, performance: bool = false, count: int = 0) -> Array[String]:
	var missing: Array[String] = []
	var scene: Variant = profile.get("campus_scene" if performance else "scene")
	if not scene is String or not ResourceLoader.exists(scene): missing.append("T-183 Campus missing" if performance else "T-181 chapter3 scene missing")
	if performance:
		var perf: Dictionary = profile.get("performance", {})
		if not valid_route(perf.get("route")): missing.append("T-183 measured route anchors not bound")
		else:
			var zones: Array = []
			for point: Dictionary in perf.route: zones.append(point.zone)
			if zones[0] != "b" or zones[-1] != "canteen": missing.append("benchmark route must run from room 407 to canteen")
			for zone in ["b", "garden", "stadium", "gate", "canteen"]:
				if zone not in zones: missing.append("benchmark route missing zone: " + zone)
		if not ResourceLoader.exists(str(profile.get("floor4_scene", ""))): missing.append("Floor4 scene missing from benchmark")
		if count > 0:
			if not ResourceLoader.exists(str(profile.get("zombie_scene", ""))): missing.append("T-182 Zombie missing")
			for key in ["active_property", "active_value", "spawn_paths"]:
				if perf.get(key) == null: missing.append("T-182/T-183 performance binding missing: " + key)
			if perf.get("spawn_paths") is Array:
				var unique: Dictionary = {}
				for path: Variant in perf.spawn_paths: unique[path] = true
				if unique.size() < count: missing.append("not enough distinct zombie spawn anchors")
	else:
		for stage: String in STAGES:
			if not valid_route(profile.get("routes", {}).get(stage)): missing.append("T-181/T-183 route missing: " + stage)
		for key in ["key_taken", "noise_203", "stadium_survived", "death_ui", "bar_head_path", "guard_paths", "grab_stage"]:
			if profile.get("bindings", {}).get(key) == null: missing.append("T-181/T-182 binding missing: " + key)
	return missing


static func valid_route(value: Variant) -> bool:
	if not value is Array or value.is_empty(): return false
	for point: Variant in value:
		if not point is Dictionary or not point.get("anchor") is String or point.anchor.is_empty() or not point.get("zone") is String: return false
	return true


static func path_reaches(path: PackedVector3Array, target: Vector3, tolerance: float = 0.8) -> bool:
	return not path.is_empty() and path[-1].distance_to(target) <= tolerance


static func path_point(path: PackedVector3Array, fraction: float) -> Vector3:
	if path.is_empty(): return Vector3.ZERO
	var length := 0.0
	for i in range(1, path.size()): length += path[i - 1].distance_to(path[i])
	var remaining := length * clampf(fraction, 0.0, 1.0)
	for i in range(1, path.size()):
		var leg := path[i - 1].distance_to(path[i])
		if remaining <= leg and leg > 0.0: return path[i - 1].lerp(path[i], remaining / leg)
		remaining -= leg
	return path[-1]


static func avoids_guards(path: PackedVector3Array, guards: Array[Vector3], radius: float = 3.3) -> bool:
	for guard: Vector3 in guards:
		for i in path.size():
			var point := path[i]
			if i > 0: point = Geometry3D.get_closest_point_to_segment(guard, path[i - 1], path[i])
			if point.distance_to(guard) < radius: return false
	return true


static func should_strike(distance: float, facing: float, stunned: bool, guard: bool, hits: int, stamina: float) -> bool:
	return not guard and not stunned and hits > 0 and stamina > 0.0 and distance >= 0.0 and distance <= 1.5 and facing > 0.7


static func summary(times: Array[float]) -> Dictionary:
	var result := preload("res://scripts/debug/performance_bot.gd").statistics(times)
	if result.is_empty(): return result
	result["min_fps"] = 1000.0 / result.max_frame_ms
	result["target_met"] = result.mean_fps >= 60.0 and result.min_fps >= 30.0
	return result
