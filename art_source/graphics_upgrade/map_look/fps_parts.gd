extends Node3D
## T-273: which part of the reference-picture look costs the frame time. Run with the look on (`--look=1`); on
## each view it measures the full look, then the look with one part taken back out, then the full look again
## (to see drift, e.g. a laptop GPU warming up). Same setup and views as fps.gd in this folder.
##   godot --path game res://_probe_tmp/t273_parts.tscn -- --chapter=1 --look=1 --views=<id,...> --out=<json>
const FPS := preload("res://_probe_tmp/t273_fps.gd")
const LOOK := preload("res://rendering/map_look.gd")
const WARMUP := 60
const SAMPLES := 180
const PARTS: Array[String] = ["ssao", "glow", "adjust", "sky", "surface", "lamp_range", "lamp_size",
	"lamp_shadows", "torch", "moon"]

var camera: Camera3D
var torch: SpotLight3D
var floor4: Node3D
var environments: Array[Environment] = []
var lamps: Array[OmniLight3D] = []
var moon: Node3D


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _measure() -> float:
	for frame in range(WARMUP):
		await get_tree().process_frame
	var last := Time.get_ticks_usec()
	var start := last
	for frame in range(SAMPLES):
		await get_tree().process_frame
	return float(Time.get_ticks_usec() - start) / 1000.0 / SAMPLES


func _set_part(part: String, on: bool) -> void:
	match part:
		"ssao", "glow", "adjust":
			var property: String = {"ssao": "ssao_enabled", "glow": "glow_enabled", "adjust": "adjustment_enabled"}[part]
			for environment in environments:
				environment.set(property, on)
		"sky":
			for environment in environments:
				environment.background_mode = Environment.BG_SKY if on else Environment.BG_COLOR
		"surface":
			RenderingServer.global_shader_parameter_set(&"look_age", 1.0 if on else 0.0)
			RenderingServer.global_shader_parameter_set(&"look_wet", 1.0 if on else 0.0)
		"lamp_range":
			for lamp in lamps:
				lamp.omni_range = lamp.get_meta(&"t273_range") if on else lamp.get_meta(&"t273_range") / LOOK.LAMP_RANGE
		"lamp_size":
			for lamp in lamps:
				lamp.light_size = lamp.get_meta(&"t273_size") if on else 0.0
		"lamp_shadows":
			for lamp in lamps:
				lamp.shadow_enabled = lamp.get_meta(&"t273_shadow") if on else false
		"torch":
			var values := {"light_color": Color(1.0, 0.95, 0.86), "light_energy": 1.9, "spot_angle": 34.0,
				"spot_angle_attenuation": 2.4, "spot_attenuation": 1.25, "spot_range": 14.0} if on else {
				"light_color": Color(0.9, 0.94, 1.0), "light_energy": 1.5, "spot_angle": 28.0,
				"spot_angle_attenuation": 1.0, "spot_attenuation": 1.0, "spot_range": 12.0}
			for property: String in values:
				torch.set(property, values[property])
		"moon":
			if moon != null:
				moon.visible = on


func _run() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = FPS.RESOLUTION
	get_window().size = FPS.RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
	var chapter := _arg("chapter", "1").to_int()
	var wanted := _arg("views", "").split(",", false)
	var out := _arg("out", "")
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""
	var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate() as Node3D
	scene.get_node("Chapter%dDirector" % chapter).set("auto_start", false)
	floor4 = scene.get_node("Floor4") as Node3D
	add_child(scene)
	for frame in range(3):
		await get_tree().process_frame
	var player := scene.get_node("Player") as Node3D
	player.visible = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for layer: CanvasLayer in scene.find_children("*", "CanvasLayer", false, false):
		layer.visible = layer.name == &"PS1Filter"
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	torch = SpotLight3D.new()
	torch.name = "Flashlight"
	torch.position = Vector3(0.1, -0.08, -0.15)
	torch.light_color = Color(0.9, 0.94, 1.0)
	torch.light_energy = 1.5
	torch.spot_range = 12.0
	torch.spot_angle = 28.0
	torch.shadow_enabled = true
	camera.add_child(torch)
	for frame in range(5):
		await get_tree().process_frame
	for world: WorldEnvironment in scene.find_children("*", "WorldEnvironment", true, false):
		if world.environment != null and world.environment.has_meta(&"map_look"):
			environments.append(world.environment)
	for lamp: OmniLight3D in scene.find_children("*", "OmniLight3D", true, false):
		if lamp.has_meta(&"map_look"):
			lamp.set_meta(&"t273_range", lamp.omni_range)
			lamp.set_meta(&"t273_size", lamp.light_size)
			lamp.set_meta(&"t273_shadow", lamp.shadow_enabled)
			lamps.append(lamp)
	moon = scene.find_child("MapLookMoon", true, false) as Node3D
	var shadowed := lamps.filter(func(lamp: OmniLight3D) -> bool: return lamp.shadow_enabled).size()
	print("PARTS: %d environments, %d tuned lamps (%d with shadows), moon %s" % [environments.size(), lamps.size(),
		shadowed, moon != null])
	var results: Array[Dictionary] = []
	for view: Dictionary in FPS.VIEWS:
		if not wanted.is_empty() and not String(view.id) in wanted:
			continue
		for number: String in FPS.ALL_DOORS:
			(floor4.get_node("Corridor/LockedDoor_" + number) as RoomDoor).set_open(number in view.open, 0.01)
		camera.position = view.eye
		camera.look_at(view.target)
		camera.fov = 75.0
		torch.visible = view.get("torch", false)
		for frame in range(240):
			await get_tree().process_frame
		var full := await _measure()
		var row := {"view": view.id, "full_ms": snappedf(full, 0.01)}
		var line := "PARTS %s: full %.2f ms" % [view.id, full]
		for part in PARTS:
			_set_part(part, false)
			var without := await _measure()
			_set_part(part, true)
			row[part] = snappedf(full - without, 0.01)
			line += "  %s %+.2f" % [part, full - without]
		var again := await _measure()
		row["full_again_ms"] = snappedf(again, 0.01)
		line += "  | full again %.2f" % again
		results.append(row)
		print(line)
	if not out.is_empty():
		var file := FileAccess.open(out, FileAccess.WRITE)
		file.store_string(JSON.stringify({"results": results}, "\t"))
		file.close()
	print("RESULT: t273 parts %d views" % results.size())
	App.quit()
