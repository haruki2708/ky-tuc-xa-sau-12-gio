extends Node3D
## T-266 round 1, step 1: what wave 9 touches, read from main's scenes at run time (headless, short).
## Chapter 4's real scene with director.run_from(&"room407") (no bot: the player is held, the door's crowd is freed),
## then: the stage's lights and environment inside room 407, every furnished prop on and around the three slat beds
## (world AABB), lane A's BedSlat areas and hand targets, the three empty search spots, the door proxy and the leaf,
## the room shell's ceiling and east wall at the fake spots, one zombie's body tree (for the hand through the door).
## The hospital room on its own (as _show_hospital places it, y 300): every mesh's world AABB and material, and where each
## lies in Camera_Wake's frame (16:9, fov 78 vertical) and for K2 (pitch 11 degrees).
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (Lượt Godot):
##   godot --headless --path game res://_probe_tmp/survey_wave9.tscn
## Writes art_source/graphics_upgrade/realistic_map/wave9/survey/*.tsv, survey_wave9.txt and plan_geometry.json.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/wave9/survey/"
const ASPECT := 16.0 / 9.0
const BED_BOX := [AABB(Vector3(30.0, -0.1, -4.3), Vector3(1.3, 2.2, 2.6)), AABB(Vector3(36.7, -0.1, -4.0), Vector3(1.3, 2.2, 2.6))]

var lines: PackedStringArray = []
var geometry := {}


func _ready() -> void:
	call_deferred("_run")


func _say(text: String) -> void:
	lines.append(text)
	print(text)


func _v(v: Vector3) -> String:
	return "(%.3f, %.3f, %.3f)" % [v.x, v.y, v.z]


func _a(v: Vector3) -> Array:
	return [snappedf(v.x, 0.001), snappedf(v.y, 0.001), snappedf(v.z, 0.001)]


func _material(mesh_instance: MeshInstance3D) -> String:
	var mat: Material = mesh_instance.material_override
	if mat == null and mesh_instance.mesh != null and mesh_instance.mesh.get_surface_count() > 0:
		mat = mesh_instance.get_active_material(0)
	if mat is StandardMaterial3D:
		var std := mat as StandardMaterial3D
		var tex := std.albedo_texture.resource_path.get_file() if std.albedo_texture != null else "-"
		return "%s %s%s" % [tex, std.albedo_color.to_html(false), " emit" if std.emission_enabled else ""]
	if mat != null and mat.resource_path != "":
		return mat.resource_path.get_file()
	return "-" if mat == null else mat.get_class()


func _world_aabb(node: Node3D, visible_only: bool = false) -> AABB:
	var out := AABB()
	var first := true
	var meshes: Array = node.find_children("*", "MeshInstance3D", true, false)
	if node is MeshInstance3D:
		meshes.append(node)
	for item: Node in meshes:
		var mesh := item as MeshInstance3D
		if mesh.mesh == null or visible_only and not mesh.is_visible_in_tree():
			continue
		var box := mesh.global_transform * mesh.get_aabb()
		out = box if first else out.merge(box)
		first = false
	return out


func _triangles(node: Node) -> int:
	var result := 0
	if node is MeshInstance3D and node.mesh != null:
		result += node.mesh.get_faces().size() / 3
	for child in node.get_children():
		result += _triangles(child)
	return result


func _box(box: AABB) -> String:
	return "%s..%s size %s" % [_v(box.position), _v(box.end), _v(box.size)]


## Where a world point lies in a camera of this transform (x, y in -1..1 of the frame; z = depth); fov vertical.
func _project(camera: Transform3D, fov: float, point: Vector3) -> Vector3:
	var local := camera.affine_inverse() * point
	var depth := -local.z
	if depth <= 0.001:
		return Vector3(99, 99, depth)
	var half := tan(deg_to_rad(fov) * 0.5)
	return Vector3(local.x / depth / (half * ASPECT), local.y / depth / half, depth)


func _frame_part(camera: Transform3D, fov: float, box: AABB) -> String:
	var inside := 0
	var lo := Vector2(9, 9)
	var hi := Vector2(-9, -9)
	for i in 8:
		var p := _project(camera, fov, box.get_endpoint(i))
		if p.z > 0.0 and absf(p.x) <= 1.0 and absf(p.y) <= 1.0:
			inside += 1
		if p.z > 0.0:
			lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
			hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	var centre := _project(camera, fov, box.get_center())
	var tag := "in" if inside == 8 else ("part" if inside > 0 or (lo.x < 1 and hi.x > -1 and lo.y < 1 and hi.y > -1) else "out")
	return "%s c(%.2f,%.2f,d%.2f) x[%.2f..%.2f] y[%.2f..%.2f]" % [tag, centre.x, centre.y, centre.z, lo.x, hi.x, lo.y, hi.y]


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	await _chapter4()
	await _hospital()
	var file := FileAccess.open(OUTPUT + "survey_wave9.txt", FileAccess.WRITE)
	file.store_string("\n".join(lines) + "\n")
	file.close()
	file = FileAccess.open(OUTPUT + "plan_geometry.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(geometry, "\t"))
	file.close()
	print("RESULT: t266 survey %d lines" % lines.size())
	App.quit()


func _chapter4() -> void:
	Chapter1Director.resume_checkpoint = &""
	GameState.reset()
	var scene := (load("res://scenes/main/chapter4.tscn") as PackedScene).instantiate() as Node3D
	var director := scene.get_node("Chapter4Director") as Chapter4Director
	director.auto_start = false
	add_child(scene)
	for frame in 3:
		await get_tree().process_frame
	var player := scene.get_node("Player") as Node3D
	director.run_from(&"room407")
	for frame in 8:
		await get_tree().process_frame
	# The door's crowd is not needed for the survey (no bot): free it so nothing bashes the door.
	for track: Dictionary in director._door_tracks:
		if is_instance_valid(track.zombie):
			(track.zombie as Node).queue_free()
	await get_tree().process_frame
	var floor4 := scene.get_node("Floor4") as Node3D
	var room := floor4.get_node("Room407") as Node3D
	var anchors := scene.get_node("Campus/Anchors/Ch4") as Node3D
	_say("== chapter 4, run_from(room407)")
	_say("segment %s, clock %s, player at %s" % [GameState.segment, GameState.clock_text(), _v(player.global_position)])
	var world := scene.get_world_3d()
	var env: Environment = world.environment if world != null else null
	for we: WorldEnvironment in scene.find_children("*", "WorldEnvironment", true, false):
		_say("WorldEnvironment %s inside=%s" % [scene.get_path_to(we), we.is_visible_in_tree() if we.has_method("is_visible_in_tree") else "-"])
	if env != null:
		_say("world env: bg %d ambient %s x%.3f src %d fog %s dens %.3f sky %s tonemap %d exposure %.2f" % [env.background_mode,
			env.ambient_light_color.to_html(false), env.ambient_light_energy, env.ambient_light_source, env.fog_enabled,
			env.fog_density, env.sky != null, env.tonemap_mode, env.tonemap_exposure])
	_say("-- lights in the chapter that are on (visible in tree, energy > 0)")
	for light: Light3D in scene.find_children("*", "Light3D", true, false):
		var on := light.is_visible_in_tree() and light.light_energy > 0.0
		var rel := String(scene.get_path_to(light))
		var near := light.global_position.distance_to(Vector3(34.0, 1.5, -3.0)) < 12.0
		if light is DirectionalLight3D or near:
			_say("%s %s on=%s energy %.3f pos %s%s" % [light.get_class(), rel, on, light.light_energy, _v(light.global_position),
				(" range %.1f" % (light as OmniLight3D).omni_range) if light is OmniLight3D else ""])
	_say("-- room407 state: blood_stage %s, desk_lamp %s" % [room.get("blood_stage"), room.get("desk_lamp_on")])
	# Furnished props on and round the slat beds.
	var props := room.call("furnished_prop", "BunkA").get_parent() as Node3D
	var rows := PackedStringArray(["name\tvisible\taabb_min\taabb_max\tsize\ttriangles\tparent_now"])
	geometry["props"] = {}
	for prop: Node3D in props.get_children():
		var box := _world_aabb(prop)
		var hit := false
		for zone: AABB in BED_BOX:
			if zone.intersects(box):
				hit = true
		if not hit and not String(prop.name).begins_with("Locker") and not String(prop.name).begins_with("Bunk"):
			continue
		rows.append("%s\t%s\t%s\t%s\t%s\t%d\t%s" % [prop.name, prop.is_visible_in_tree(), _v(box.position), _v(box.end), _v(box.size),
			_triangles(prop), scene.get_path_to(prop.get_parent())])
		geometry.props[prop.name] = {"min": _a(box.position), "max": _a(box.end)}
	var file := FileAccess.open(OUTPUT + "room407_bed_props.tsv", FileAccess.WRITE)
	file.store_string("\n".join(rows) + "\n")
	file.close()
	_say("-- %d props on/round the slat beds and lockers (room407_bed_props.tsv)" % (rows.size() - 1))
	# The bunk frame's deck: the frame's triangles whose normal points up, between the posts.
	for bunk_name in ["BunkA", "BunkB"]:
		var bunk := room.call("furnished_prop", bunk_name) as Node3D
		var decks := {}
		for item: Node in bunk.find_children("*", "MeshInstance3D", true, false):
			var mesh := item as MeshInstance3D
			var faces := mesh.mesh.get_faces()
			for i in range(0, faces.size(), 3):
				var a := mesh.global_transform * faces[i]
				var b := mesh.global_transform * faces[i + 1]
				var c := mesh.global_transform * faces[i + 2]
				var n := (b - a).cross(c - a)
				if n.length() < 1e-6:
					continue
				n = n.normalized()
				if absf(n.y) > 0.95:
					var key := snappedf((a.y + b.y + c.y) / 3.0, 0.005)
					decks[key] = decks.get(key, 0.0) + (b - a).cross(c - a).length() * 0.5
		var keys := decks.keys()
		keys.sort()
		var text := PackedStringArray()
		for key in keys:
			if decks[key] > 0.02:
				text.append("y %.3f: %.3f m2" % [key, decks[key]])
		_say("%s horizontal faces (area > 0.02 m2): %s" % [bunk_name, ", ".join(text)])
	# Lane A's slat areas and hand targets, lane B's markers.
	geometry["slats"] = {}
	for bed in [1, 2, 4]:
		var marker := anchors.get_node("Room407/Slat%d" % bed) as Node3D
		var area := marker.get_node_or_null("BedSlat%d" % bed) as Node3D
		var hinge := marker.get_node("Hinge") as Node3D
		var board := _world_aabb(hinge.get_node("Board"))
		_say("Slat%d marker %s hinge %s board %s" % [bed, _v(marker.global_position), _v(hinge.global_position), _box(board)])
		var entry := {"marker": _a(marker.global_position), "hinge": _a(hinge.global_position), "board_min": _a(board.position), "board_max": _a(board.end)}
		if area != null:
			var shape := area.get_node("CollisionShape3D") as CollisionShape3D
			var size: Vector3 = (shape.shape as BoxShape3D).size
			var hand := area.get_node("HandTarget") as Node3D
			_say("  BedSlat%d area centre %s size %s hand %s" % [bed, _v(shape.global_position), _v(size), _v(hand.global_position)])
			entry["area_centre"] = _a(shape.global_position)
			entry["area_size"] = _a(size)
		geometry.slats[str(bed)] = entry
	geometry["fake"] = {}
	for spot in ["Locker", "Ceiling", "Vent"]:
		var marker := anchors.get_node("Room407/Fake" + spot) as Node3D
		var search := marker.get_node_or_null("Search" + spot) as Node3D
		var text := "Fake%s %s" % [spot, _v(marker.global_position)]
		var entry := {"marker": _a(marker.global_position)}
		if search != null:
			for shape: CollisionShape3D in search.find_children("*", "CollisionShape3D", true, false):
				var size := Vector3.ZERO
				if shape.shape is BoxShape3D:
					size = (shape.shape as BoxShape3D).size
				elif shape.shape is SphereShape3D:
					size = Vector3.ONE * (shape.shape as SphereShape3D).radius * 2.0
				text += " shape %s at %s size %s" % [shape.shape.get_class(), _v(shape.global_position), _v(size)]
				entry["shape_centre"] = _a(shape.global_position)
				entry["shape_size"] = _a(size)
			var hand := search.get_node_or_null("HandTarget") as Node3D
			if hand != null:
				text += " hand %s" % _v(hand.global_position)
			text += " signals searched: %d" % search.get_signal_connection_list(&"searched").size()
		_say(text)
		geometry.fake[spot] = entry
	for part in ["CeilingPanel", "VentFrame", "VentSlat0", "VentSlat5"]:
		_say("%s %s" % [part, _box(_world_aabb(anchors.get_node("Room407/" + part)))])
	# The shell round the fake spots: furnished architecture meshes near the ceiling panel and the vent.
	var furnished := props.get_parent() as Node3D
	_say("-- furnished shell parts near FakeCeiling (33, 2.92, -2) and FakeVent (37.8, 2.35, -1)")
	for item: Node in furnished.find_children("*", "MeshInstance3D", true, false):
		var mesh := item as MeshInstance3D
		if props.is_ancestor_of(mesh) or not mesh.is_visible_in_tree():
			continue
		var box := mesh.global_transform * mesh.get_aabb()
		if box.grow(0.15).has_point(Vector3(33.0, 2.92, -2.0)) or box.grow(0.15).has_point(Vector3(37.8, 2.35, -1.0)):
			_say("  %s %s %s" % [furnished.get_path_to(mesh), _box(box), _material(mesh)])
	for name in ["Room407MainLight", "Room407DeskLamp"]:
		var node := room.get_node_or_null(name) as Node3D
		if node != null:
			_say("%s at %s visible %s" % [name, _v(node.global_position), node.is_visible_in_tree()])
	# The door: proxy, leaf, frame.
	var proxy := anchors.get_node("Room407/Door") as Node3D
	var door := floor4.get_node("Door407") as Node3D
	var leaf := door.get_node("Pivot/Leaf") as Node3D
	_say("Door407 %s rot %s leaf %s visible %s" % [_v(door.global_position), _v(door.global_rotation_degrees), _box(_world_aabb(leaf, true)), leaf.visible])
	_say("proxy %s blocker layer %d damage %.2f" % [_v(proxy.global_position), (proxy.get("blocker") as CollisionObject3D).collision_layer, float(proxy.get("damage_fraction"))])
	for child in ["Cracks", "Hole", "Hand"]:
		_say("  Damage/%s %s" % [child, _box(_world_aabb(proxy.get_node("Damage/" + child)))])
	var room_door := room.call("furnished_room_door") as Node3D
	if room_door != null:
		_say("furnished RoomDoor %s visible %s" % [_box(_world_aabb(room_door, true)), room_door.is_visible_in_tree()])
	for item: Node in leaf.find_children("*", "MeshInstance3D", true, false):
		_say("  leaf mesh %s %s %s" % [leaf.get_path_to(item), _box((item as MeshInstance3D).global_transform * (item as MeshInstance3D).get_aabb()), _material(item as MeshInstance3D)])
	geometry["door"] = {"pos": _a(door.global_position), "leaf_min": _a(_world_aabb(leaf, true).position), "leaf_max": _a(_world_aabb(leaf, true).end)}
	_say("triangles: Room407 branch %d, Door %d, Slat1 %d, Slat2 %d, Slat4 %d" % [_triangles(anchors.get_node("Room407")),
		_triangles(proxy), _triangles(anchors.get_node("Room407/Slat1")), _triangles(anchors.get_node("Room407/Slat2")), _triangles(anchors.get_node("Room407/Slat4"))])
	# One zombie of the chapter, for the hand's look.
	var zombie := director._make_zombie("zombie_01")
	if zombie != null:
		add_child(zombie)
		for frame in 3:
			await get_tree().process_frame
		var model := zombie.get("model") as Node3D
		if model != null:
			_say("-- zombie_01 body %s (%s)" % [model.name, model.scene_file_path])
			for item: Node in model.find_children("*", "MeshInstance3D", true, false):
				var path := String(model.get_path_to(item))
				if "Arm" in path or "Hand" in path or "Finger" in path or "Sleeve" in path or "Fore" in path:
					_say("  %s %s %s" % [path, _box((item as MeshInstance3D).global_transform * (item as MeshInstance3D).get_aabb()), _material(item as MeshInstance3D)])
		zombie.queue_free()
	scene.queue_free()
	for frame in 4:
		await get_tree().process_frame


func _hospital() -> void:
	var ward := (load("res://scenes/levels/hospital/hospital_room.tscn") as PackedScene).instantiate() as Node3D
	add_child(ward)
	ward.global_position = Vector3(0.0, 300.0, 0.0)
	await get_tree().process_frame
	var camera := ward.get_node("Camera_Wake") as Camera3D
	var k1 := camera.global_transform
	var k2 := Transform3D(Basis.from_euler(Vector3(deg_to_rad(11.0), PI, 0.0)), camera.global_position)
	_say("== hospital (y 300); Camera_Wake %s rot %s fov %.0f keep_aspect %d near %.2f" % [_v(camera.global_position),
		_v(camera.global_rotation_degrees), camera.fov, camera.keep_aspect, camera.near])
	var rows := PackedStringArray(["path\tvisible\taabb_min\taabb_max\ttriangles\tmaterial\tK1 (pitch 24)\tK2 (pitch 11)"])
	geometry["hospital"] = {}
	for item: Node in ward.find_children("*", "MeshInstance3D", true, false):
		var mesh := item as MeshInstance3D
		var box := mesh.global_transform * mesh.get_aabb()
		var rel := String(ward.get_path_to(mesh.get_parent()))
		rows.append("%s\t%s\t%s\t%s\t%d\t%s\t%s\t%s" % [rel, mesh.is_visible_in_tree(), _v(box.position - Vector3(0, 300, 0)),
			_v(box.end - Vector3(0, 300, 0)), _triangles(mesh), _material(mesh), _frame_part(k1, camera.fov, box), _frame_part(k2, camera.fov, box)])
		geometry.hospital[rel] = {"min": _a(box.position - Vector3(0, 300, 0)), "max": _a(box.end - Vector3(0, 300, 0))}
	for marker: Marker3D in ward.find_children("*", "Marker3D", true, false):
		var p := marker.global_position
		var a := _project(k1, camera.fov, p)
		var b := _project(k2, camera.fov, p)
		rows.append("%s\tmarker\t%s\t-\t0\t-\tK1 (%.2f, %.2f, d%.2f)\tK2 (%.2f, %.2f, d%.2f)" % [ward.get_path_to(marker), _v(p - Vector3(0, 300, 0)),
			a.x, a.y, a.z, b.x, b.y, b.z])
		geometry.hospital["marker:" + String(ward.get_path_to(marker))] = {"at": _a(p - Vector3(0, 300, 0))}
	var file := FileAccess.open(OUTPUT + "hospital_nodes.tsv", FileAccess.WRITE)
	file.store_string("\n".join(rows) + "\n")
	file.close()
	geometry["camera_wake"] = {"pos": _a(camera.global_position - Vector3(0, 300, 0)), "pitch": 24.0, "yaw": 180.0, "fov": camera.fov}
	for bed in ["Bed_Trung", "Bed_Nhat", "Bed_Ngu"]:
		_say("%s triangles %d" % [bed, _triangles(ward.get_node(bed))])
	_say("hospital triangles %d" % _triangles(ward))
	var env := (ward.get_node("Environment") as WorldEnvironment).environment
	_say("ward env: bg %s ambient %s x%.2f tonemap %d; CeilingLight energy %.2f range %.1f" % [env.background_color.to_html(false),
		env.ambient_light_color.to_html(false), env.ambient_light_energy, env.tonemap_mode, (ward.get_node("CeilingLight") as OmniLight3D).light_energy,
		(ward.get_node("CeilingLight") as OmniLight3D).omni_range])
	ward.queue_free()
	await get_tree().process_frame
