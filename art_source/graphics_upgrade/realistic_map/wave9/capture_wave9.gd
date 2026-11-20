extends Node3D
## T-266 round 1 stills, survey part (card section 2, step 1): room 407 and the hospital ward as main has them.
## Chapter 4's real scene, director.run_from(&"room407") (the stage's own lights and checkpoint; no bot: the player is held
## and hidden, the door's crowd is freed so nothing bashes the door, HUD hidden, sound muted). The slats are flipped with
## Slat<n>.set_flipped(true) (what bed_slat_flipped does to lane B's visual, without opening lane D's notebook) and the
## door's damage with the proxy's set_damage_fraction() (what door_damage_changed does). The phone's torch is the
## camera's own (the player's: 12 m, 28 degrees, named Flashlight so room407.gd widens it inside the room as in play);
## no other light is added. Same camera in chapters 3 and 1 (start of chapter, director held).
## The ward: director._show_hospital() for both endings (its cards get ch4_ending), through Camera_Wake exactly, at
## brightness 1.0 and 1.45 (the PS1Filter's screen multiply, as the setting), and from a corner of the room.
## Copy this file to game/_probe_tmp/ with a scene whose root has it, then (one Godot at a time, Lượt Godot):
##   godot --path game res://_probe_tmp/capture_wave9.tscn -- [--parts=s407,ward,ch3,ch1] [--views=...]
##   (or $env:T266_PARTS / T266_VIEWS / T266_SECTIONS: PowerShell drops the "--")
## Writes art_source/graphics_upgrade/realistic_map/previews/wave9/survey_*.jpg (1600 x 900) and prints draw calls,
## primitives, objects and video memory per shot (CAPTURE lines).
const OUTPUT := "res://../art_source/graphics_upgrade/realistic_map/previews/wave9/"
const RESOLUTION := Vector2i(1600, 900)
const WARD_Y := 300.0
# Room 407 in world space (Room407 at x 30). eye/target world points; fov (player's 70 by default); low: crouched eye.
const VIEWS := {
	"room_door": {"eye": Vector3(32.0, 1.6, -0.35), "target": Vector3(34.3, 0.85, -4.6), "fov": 80.0},
	"bed1": {"eye": Vector3(32.0, 1.6, -1.95), "target": Vector3(30.7, 1.2, -3.0)},
	"bed2": {"eye": Vector3(31.95, 1.6, -1.85), "target": Vector3(30.7, 0.45, -3.0)},
	"bed2_low": {"eye": Vector3(31.9, 1.0, -1.9), "target": Vector3(30.6, 0.55, -3.0)},
	"bed4": {"eye": Vector3(36.0, 1.6, -1.75), "target": Vector3(37.3, 1.2, -2.75)},
	"fake_locker": {"eye": Vector3(31.75, 1.6, -1.35), "target": Vector3(30.55, 1.05, -0.45)},
	"fake_ceiling": {"eye": Vector3(33.6, 1.6, -0.75), "target": Vector3(33.0, 2.95, -2.0)},
	"fake_vent": {"eye": Vector3(35.7, 1.6, -1.45), "target": Vector3(37.85, 2.35, -1.0)},
	"door_in": {"eye": Vector3(33.3, 1.6, -2.9), "target": Vector3(32.0, 1.05, -0.05)},
	"door_corridor": {"eye": Vector3(31.0, 1.6, 2.6), "target": Vector3(32.0, 1.05, 0.0)},
	"vent_ceiling": {"eye": Vector3(31.4, 1.6, -0.6), "target": Vector3(35.2, 2.55, -1.8), "fov": 80.0},
}
const DOOR_LEVELS := [0.0, 0.3, 0.6, 0.8]
# Camera_Wake (K1) as in hospital_room.tscn; K2 the same eye at a lower pitch (card step 3).
const WARD_CORNER := {"eye": Vector3(2.15, 2.35, 2.65), "target": Vector3(-0.7, 0.55, -1.2), "fov": 75.0}

var camera: Camera3D
var torch: SpotLight3D
var filter_screen: CanvasItem
var count := 0
var log_lines: PackedStringArray = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	# PowerShell drops the "--" before the user arguments: T266_<NAME> in the environment does the same.
	var from_env := OS.get_environment("T266_" + name.to_upper())
	return from_env if not from_env.is_empty() else fallback


func _note(text: String) -> void:
	log_lines.append(text)
	print(text)


func _load_chapter(path: String, director_name: String) -> Node3D:
	Chapter1Director.resume_checkpoint = &""
	GameState.reset()
	var scene := (load(path) as PackedScene).instantiate() as Node3D
	scene.get_node(director_name).set("auto_start", false)
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	var filter := scene.get_node_or_null("PS1Filter")
	filter_screen = filter.get_node("Screen") as CanvasItem if filter != null else null
	_brightness(1.0)
	return scene


## The video setting "brightness" as the PS1 filter applies it (a multiply of the whole 3D image); strength 0.
func _brightness(value: float) -> void:
	if filter_screen == null:
		return
	var material := (filter_screen as CanvasItem).material as ShaderMaterial
	material.set_shader_parameter("strength", 0.0)
	material.set_shader_parameter("brightness", value)
	filter_screen.visible = not is_equal_approx(value, 1.0)


func _snap(file: String) -> void:
	for frame in range(24):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.save_jpg(OUTPUT + file, 0.88)
	_note("CAPTURE: %s draws %d prims %d objects %d vram %d MB" % [file,
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)),
		int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0)])
	count += 1


func _look(view: Dictionary) -> void:
	camera.make_current()
	camera.global_position = view.eye
	camera.look_at(view.target)
	camera.fov = view.get("fov", 70.0)


func _shoot(file: String, view: Dictionary, lit: bool) -> void:
	_look(view)
	torch.visible = lit
	await _snap(file)


func _camera() -> void:
	camera = Camera3D.new()
	add_child(camera)
	camera.far = 4000.0
	camera.near = 0.05
	torch = SpotLight3D.new()
	torch.name = "Flashlight"
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)


func _wanted(only: String, name: String) -> bool:
	return only.is_empty() or name in only.split(",")


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Capture needs a window.")
		App.quit(1)
		return
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = RESOLUTION
	get_window().size = RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	AudioServer.set_bus_mute(0, true)
	var only := _arg("views", "")
	var parts := _arg("parts", "s407,ward,ch3,ch1").split(",")
	_camera()
	if "s407" in parts or "ward" in parts:
		var scene := await _load_chapter("res://scenes/main/chapter4.tscn", "Chapter4Director")
		if "s407" in parts:
			await _survey_407(scene, only)
		if "ward" in parts:
			await _survey_ward(scene)
		scene.queue_free()
		for frame in range(6):
			await get_tree().process_frame
	for chapter: int in [3, 1]:
		if not "ch%d" % chapter in parts:
			continue
		var scene := await _load_chapter("res://scenes/main/chapter%d.tscn" % chapter, "Chapter%dDirector" % chapter)
		await _shoot("survey_ch%d_vent_ceiling_torch.jpg" % chapter, VIEWS.vent_ceiling, true)
		await _shoot("survey_ch%d_room_door_torch.jpg" % chapter, VIEWS.room_door, true)
		await _shoot("survey_ch%d_room_door.jpg" % chapter, VIEWS.room_door, false)
		scene.queue_free()
		for frame in range(6):
			await get_tree().process_frame
	var file := FileAccess.open(OUTPUT + "../../wave9/survey/capture_survey.txt", FileAccess.WRITE)
	file.store_string("\n".join(log_lines) + "\n")
	file.close()
	print("RESULT: t266 survey capture %d images" % count)
	App.quit()


func _start_407(scene: Node3D) -> void:
	var director := scene.get_node("Chapter4Director") as Chapter4Director
	director.run_from(&"room407")
	for frame in range(8):
		await get_tree().process_frame
	for track: Dictionary in director._door_tracks:
		if is_instance_valid(track.zombie):
			(track.zombie as Node).queue_free()
	director._door_tracks.clear()
	await get_tree().process_frame


func _survey_407(scene: Node3D, only: String) -> void:
	await _start_407(scene)
	var anchors := scene.get_node("Campus/Anchors/Ch4/Room407") as Node3D
	var pivot := scene.get_node("Floor4/Door407/Pivot") as Node3D
	var names := PackedStringArray()
	for child: Node in pivot.get_children():
		var meshes := child.find_children("*", "MeshInstance3D", true, false).filter(func(m: Node) -> bool:
			return (m as MeshInstance3D).is_visible_in_tree())
		names.append("%s(%s, visible %s, %d meshes drawn)" % [child.name, child.get_class(), (child as Node3D).visible, meshes.size()])
	_note("Door407/Pivot children: %s" % ", ".join(names))
	if _wanted(only, "room_door"):
		await _shoot("survey_407_room_door.jpg", VIEWS.room_door, false)
		await _shoot("survey_407_room_door_torch.jpg", VIEWS.room_door, true)
	for bed in [1, 2, 4]:
		var key := "bed%d" % bed
		if _wanted(only, key):
			await _shoot("survey_407_%s_before_torch.jpg" % key, VIEWS[key], true)
			if bed == 2:
				await _shoot("survey_407_bed2_low_before_torch.jpg", VIEWS.bed2_low, true)
	for spot in ["fake_locker", "fake_ceiling", "fake_vent"]:
		if _wanted(only, spot):
			await _shoot("survey_407_%s_torch.jpg" % spot, VIEWS[spot], true)
	if _wanted(only, "vent_ceiling"):
		await _shoot("survey_ch4_vent_ceiling_torch.jpg", VIEWS.vent_ceiling, true)
	for bed in [1, 2, 4]:
		(anchors.get_node("Slat%d" % bed)).call("set_flipped", true)
	await get_tree().create_timer(0.6).timeout
	for bed in [1, 2, 4]:
		var key := "bed%d" % bed
		if _wanted(only, key):
			await _shoot("survey_407_%s_after_torch.jpg" % key, VIEWS[key], true)
			if bed == 2:
				await _shoot("survey_407_bed2_low_after_torch.jpg", VIEWS.bed2_low, true)
	var proxy := anchors.get_node("Door")
	for level: float in DOOR_LEVELS:
		proxy.call("set_damage_fraction", level)
		if _wanted(only, "door_in"):
			await _shoot("survey_407_door_%02d_torch.jpg" % int(level * 100.0), VIEWS.door_in, true)
	if _wanted(only, "door_corridor"):
		await _shoot("survey_407_door_80_corridor.jpg", VIEWS.door_corridor, false)
	# Draws: from the door, all three flipped and the door at 80 % (card section 5).
	if _wanted(only, "room_door"):
		await _shoot("survey_407_room_door_flipped_80_torch.jpg", VIEWS.room_door, true)
	proxy.call("set_damage_fraction", 0.0)
	for bed in [1, 2, 4]:
		(anchors.get_node("Slat%d" % bed)).call("set_flipped", false)
	await get_tree().create_timer(0.6).timeout


func _survey_ward(scene: Node3D) -> void:
	var director := scene.get_node("Chapter4Director") as Chapter4Director
	for kind: StringName in [&"all", &"alone"]:
		if director._hospital != null:
			director._hospital.queue_free()
			director._hospital = null
			await get_tree().process_frame
		GameState.set_flag(&"ch4_ending", String(kind))
		director._ending_kind = kind
		director._show_hospital()
		EventBus.ch4_ending.emit(kind)
		for frame in range(3):
			await get_tree().process_frame
		var ward := director._hospital
		var wake := ward.get_node("Camera_Wake") as Camera3D
		for level: float in [1.0, 1.45]:
			_brightness(level)
			wake.make_current()
			await _snap("survey_ward_%s_wake_%s.jpg" % [kind, "145" if level > 1.0 else "100"])
		_brightness(1.0)
		var env := (ward.get_node("Environment") as WorldEnvironment).environment
		camera.environment = env
		var corner := {"eye": WARD_CORNER.eye + Vector3(0, WARD_Y, 0), "target": WARD_CORNER.target + Vector3(0, WARD_Y, 0), "fov": WARD_CORNER.fov}
		await _shoot("survey_ward_%s_corner.jpg" % kind, corner, false)
		camera.environment = null
