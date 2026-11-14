extends Node3D
## T-261 round 1 stills: the stadium pilot put into chapter 3's real scene at run time, one option set at a time, same
## cameras, floodlights off and on (Stadium/Floodlights.visible, as campus.set_stadium_lights does). stadium.tscn is
## not changed in round 1: this script hides the PS1 meshes the pilot replaces (visible = false, or the MultiMesh
## instance scaled to 0 for the shared Stand_* chunks) and hangs the wave-4 glbs under Campus/Stadium. Director held,
## lights as the chapter opens, HUD and player hidden, sound muted. The new lamp glass glows only while Floodlights is
## shown (one duplicated material, energy 0 when off).
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave4.tscn -- --configs=before,a,b,c [--views=west_gate,...]
## Writes art_source/graphics_upgrade/realistic_map/previews/wave4/pilot_<config>_<view>_<off|on>[_torch].jpg
## (1920 x 1080) and prints draw calls, primitives, objects and video memory per shot.
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave4/"
const W4 := "res://assets/models/graphics_pilot/realistic_map/wave4/"
const RESOLUTION := Vector2i(1920, 1080)
const G := -9.9
const POLES := [Vector3(112, G, 122), Vector3(284, G, 122), Vector3(112, G, 210), Vector3(284, G, 210)]
const PITCH_CENTRE := Vector3(198, G, 166)
# torch: shots with the torch on (always also one without); flood: floodlight states shot.
const VIEWS := {
	"west_gate": {"eye": Vector3(100.5, -8.3, 167.5), "target": Vector3(150, -8.6, 166), "torch": false},
	"gate_in": {"eye": Vector3(115, -8.3, 166), "target": Vector3(165, -9.0, 190), "torch": false},
	"track_curve": {"eye": Vector3(117.5, -8.3, 194), "target": Vector3(150, -9.7, 206), "torch": true},
	"goal": {"eye": Vector3(163, -8.3, 157), "target": Vector3(149, -8.9, 166.5), "torch": true},
	"stand_front": {"eye": Vector3(165, -8.3, 195), "target": Vector3(178, -5.2, 221), "torch": true},
	"stand_top": {"eye": Vector3(196.5, -1.55, 226.6), "target": Vector3(196, -9.6, 172), "torch": false},
	"under_stand": {"eye": Vector3(167.5, -8.3, 231.2), "target": Vector3(162.5, -9.4, 223.5), "torch": true},
	"stand_end": {"eye": Vector3(146, -8.3, 232), "target": Vector3(160, -6.2, 219), "torch": true},
	"nw_gate": {"eye": Vector3(147, -8.3, 203), "target": Vector3(149, -8.0, 222), "torch": false},
	"pole": {"eye": Vector3(124, -8.3, 197), "target": Vector3(112, 1.5, 210), "torch": false},
}
const CONFIGS := {
	"before": {},
	"a": {"track": "rubber", "pitch": "grass", "seats": "", "pole": "steel", "fence": "b40"},
	"b": {"track": "cinder", "pitch": "turf", "seats": "blue", "pole": "concrete", "fence": "bars"},
	"c": {"track": "rubber", "pitch": "grass", "seats": "red", "pole": "steel", "fence": "b40"},
}
const C_VIEWS := ["stand_front", "stand_top", "under_stand"]

var camera: Camera3D
var torch: SpotLight3D
var stadium: Node3D
var floodlights: Node3D
var ps1_nodes: Array[Node3D] = []
var ps1_instances: Array = []  # [MultiMesh, index, original Transform3D]
var pilot := {}
var glow: StandardMaterial3D
var glow_energy := 4.0


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _instance(path: String, at: Vector3, yaw: float = 0.0) -> Node3D:
	var node := (load(W4 + path) as PackedScene).instantiate() as Node3D
	stadium.add_child(node)
	node.position = at
	node.rotation.y = yaw
	node.visible = false
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		if String(mesh.name) in ["Mesh", "Net", "Seats"]:
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node


func _surface(node: Node3D, mesh_name: String, material_name: String) -> Array:
	## [MeshInstance3D, surface index] of the surface whose material is material_name.
	for mesh: MeshInstance3D in node.find_children(mesh_name, "MeshInstance3D", true, false):
		for i in mesh.mesh.get_surface_count():
			var m := mesh.mesh.surface_get_material(i)
			if m != null and m.resource_name == material_name:
				return [mesh, i]
	return []


func _hide_rule(origin: Vector3) -> bool:
	# Main stand (everything behind the fence line on the north side between the stand's ends and the B03 pipes).
	if origin.z > 212.5 and origin.x > 156.0 and origin.x < 240.0:
		return true
	# Pilot fences and the two pilot gates: x = 110 (west), z = 212.4 from x 110 to 158 (north-west).
	if absf(origin.x - 110.0) < 0.2 and origin.z > 119.0 and origin.z < 213.0:
		return true
	if absf(origin.z - 212.4) < 0.2 and origin.x >= 109.0 and origin.x <= 158.5:
		return true
	return false


func _collect_ps1() -> void:
	for path in ["Grass/Mesh", "MainBleachers/RearParapet/Mesh", "MainBleachers/EndWest/Mesh", "MainBleachers/EndEast/Mesh"]:
		ps1_nodes.append(stadium.get_node(path) as Node3D)
	for i in 4:
		ps1_nodes.append(stadium.get_node("MainBleachers/FrontWall%d/Mesh" % i) as Node3D)
		ps1_nodes.append(stadium.get_node("Pole%d/Mesh" % i) as Node3D)
	for child in stadium.get_children():
		var name := String(child.name)
		if name == "RunningSurface" or name.begins_with("Lane") or name.begins_with("StartLane") or name.begins_with("PitchLine") \
				or name.begins_with("PitchEdge") or name.begins_with("GoalPost") or name.begins_with("GoalCross") \
				or name.begins_with("FloodHousing") or name.begins_with("GatePost110_") or name.begins_with("GatePost148_212"):
			for mesh in (child as Node3D).find_children("*", "MeshInstance3D", true, false):
				ps1_nodes.append(mesh as Node3D)
		if name.begins_with("Stand_"):
			for multi: MultiMeshInstance3D in child.find_children("*", "MultiMeshInstance3D", true, false):
				var mm := multi.multimesh
				for i in mm.instance_count:
					var t := mm.get_instance_transform(i)
					if _hide_rule(t.origin):
						ps1_instances.append([mm, i, t])
	print("T261_PS1: %d nodes, %d MultiMesh instances hidden in the pilot" % [ps1_nodes.size(), ps1_instances.size()])


func _build_pilot() -> void:
	var origin := Vector3(0, G, 0)
	pilot["field"] = [_instance("field.glb", origin)]
	pilot["goals"] = [_instance("goal.glb", Vector3(150, G, 166)), _instance("goal.glb", Vector3(246, G, 166), PI)]
	pilot["stand"] = [_instance("stand.glb", origin)]
	pilot["seats"] = [_instance("stand_seats.glb", origin)]
	for kind in ["steel", "concrete"]:
		var poles: Array = []
		for p: Vector3 in POLES:
			var to := PITCH_CENTRE - p
			poles.append(_instance("pole_%s.glb" % kind, p, atan2(-to.z, to.x)))
		pilot["pole_" + kind] = poles
	pilot["fence_b40"] = [_instance("fence_b40.glb", origin)]
	pilot["fence_bars"] = [_instance("fence_bars.glb", origin)]
	pilot["pillars"] = [_instance("gate_pillars.glb", origin)]
	glow = (load(W4 + "materials/W4FloodGlass.tres") as StandardMaterial3D).duplicate() as StandardMaterial3D
	glow_energy = glow.emission_energy_multiplier
	for kind in ["steel", "concrete"]:
		for pole: Node3D in pilot["pole_" + kind]:
			var found := _surface(pole, "*", "W4FloodGlass")
			if not found.is_empty():
				(found[0] as MeshInstance3D).set_surface_override_material(found[1], glow)


func _apply(config: Dictionary) -> void:
	var on := not config.is_empty()
	for node in ps1_nodes:
		node.visible = not on
	for entry: Array in ps1_instances:
		var t: Transform3D = entry[2]
		(entry[0] as MultiMesh).set_instance_transform(entry[1], Transform3D(Basis().scaled(Vector3.ZERO), t.origin) if on else t)
	for key: String in pilot:
		for node: Node3D in pilot[key]:
			node.visible = false
	if not on:
		return
	for key in ["field", "goals", "stand", "pillars", "pole_" + config.pole, "fence_" + config.fence]:
		for node: Node3D in pilot[key]:
			node.visible = true
	var field: Node3D = pilot["field"][0]
	var track := _surface(field, "Track", "W4TrackRubber")
	(track[0] as MeshInstance3D).set_surface_override_material(track[1],
		load(W4 + "materials/%s.tres" % ("W4TrackCinder" if config.track == "cinder" else "W4TrackRubber")))
	var infield := _surface(field, "Infield", "W4PitchGrass")
	(infield[0] as MeshInstance3D).set_surface_override_material(infield[1],
		load(W4 + "materials/%s.tres" % ("W4Turf" if config.pitch == "turf" else "W4PitchGrass")))
	var seats: Node3D = pilot["seats"][0]
	seats.visible = config.seats != ""
	if seats.visible:
		var surface := _surface(seats, "*", "W4Seat")
		(surface[0] as MeshInstance3D).set_surface_override_material(surface[1],
			load(W4 + "materials/%s.tres" % ("W4SeatRed" if config.seats == "red" else "W4Seat")))


func _set_flood(on: bool) -> void:
	floodlights.visible = on
	if glow != null:
		glow.emission_energy_multiplier = glow_energy if on else 0.0


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Capture needs a window.")
		App.quit(1)
		return
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = RESOLUTION
	get_window().size = RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
	var only := _arg("views", "")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	var scene := (load("res://scenes/main/chapter3.tscn") as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter3Director").set("auto_start", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	stadium = scene.get_node("Campus/Stadium") as Node3D
	floodlights = stadium.get_node("Floodlights") as Node3D
	_collect_ps1()
	_build_pilot()
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	camera.far = 4000.0
	torch = SpotLight3D.new()
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)
	var count := 0
	for config_name: String in _arg("configs", "before,a,b,c").split(","):
		_apply(CONFIGS[config_name])
		for view_name: String in VIEWS:
			if not only.is_empty() and not view_name in only.split(","):
				continue
			if config_name == "c" and not view_name in C_VIEWS:
				continue
			var view: Dictionary = VIEWS[view_name]
			camera.global_position = view.eye
			camera.look_at(view.target)
			camera.fov = view.get("fov", 75.0)
			for flood: bool in [false, true]:
				_set_flood(flood)
				var lits: Array = [false, true] if view.torch and not flood else [false]
				for lit: bool in lits:
					torch.visible = lit
					for frame in range(24):
						await get_tree().process_frame
					await RenderingServer.frame_post_draw
					var image: Image = get_viewport().get_texture().get_image()
					var file := "pilot_%s_%s_%s%s.jpg" % [config_name, view_name, "on" if flood else "off", "_torch" if lit else ""]
					image.save_jpg(OUTPUT + file, 0.88)
					print("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [file,
						int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
						int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
						int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
						int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
					count += 1
	_set_flood(false)
	print("RESULT: t261 capture %d images" % count)
	App.quit()
