extends Node3D
## T-273: cheaper settings for the reference-picture look, measured against the full look and against the look
## taken fully back out ("none", about the cost of the game without it), in one Godot so the machine state is the
## same. Run with the look on (`--look=1`). Each view measures every variant in order, then in reverse order, and
## averages the two (a laptop GPU drifts as it warms). The figure is the GPU time of the frame
## (RenderingServer.viewport_get_measured_render_time_gpu): on this laptop the frame goes through the integrated
## GPU to a 120 Hz screen, and wall-clock frame time swings with that more than with the look.
##   godot --path game res://_probe_tmp/t273_variants.tscn -- --chapter=1 --look=1 --views=<id,...> --out=<json>
const FPS := preload("res://_probe_tmp/t273_fps.gd")
const LOOK := preload("res://rendering/map_look.gd")
const WARMUP := 60
const SAMPLES := 200
const OLD_TORCH := {"light_color": Color(0.9, 0.94, 1.0), "light_energy": 1.5, "spot_angle": 28.0,
	"spot_angle_attenuation": 1.0, "spot_attenuation": 1.0, "spot_range": 12.0}
## range: lamps without shadows (x original); shadow_range: the lamps that cast shadows (D-104); size: soft shadow.
const FULL := {"ssao": true, "ssao_quality": 2, "glow": true, "adjust": true, "sky": true, "surface": true,
	"range": 1.6, "shadow_range": 1.6, "size": true, "torch": true, "moon": true}
const LEAN := {"shadow_range": 1.0, "size": false, "range": 1.25, "glow": false}
const VARIANTS := {
	"full": {},
	"none": {"ssao": false, "glow": false, "adjust": false, "sky": false, "surface": false, "range": 1.0,
		"shadow_range": 1.0, "size": false, "torch": false, "moon": false},
	"a_shadow_lamps_as_before": {"shadow_range": 1.0, "size": false},
	"lean": LEAN,
	"lean_glow": {"shadow_range": 1.0, "size": false, "range": 1.25},
	"lean_range_1_0": {"shadow_range": 1.0, "size": false, "range": 1.0, "glow": false},
	"lean_range_1_6": {"shadow_range": 1.0, "size": false, "range": 1.6, "glow": false},
	"lean_ssao_low": {"shadow_range": 1.0, "size": false, "range": 1.25, "glow": false, "ssao_quality": 1},
	"lean_no_ssao": {"shadow_range": 1.0, "size": false, "range": 1.25, "glow": false, "ssao": false},
	"lean_no_surface": {"shadow_range": 1.0, "size": false, "range": 1.25, "glow": false, "surface": false},
	"lean_no_sky": {"shadow_range": 1.0, "size": false, "range": 1.25, "glow": false, "sky": false},
	"lean_old_torch": {"shadow_range": 1.0, "size": false, "range": 1.25, "glow": false, "torch": false},
}

var camera: Camera3D
var torch: SpotLight3D
var floor4: Node3D
var environments: Array[Environment] = []
var lamps: Array[OmniLight3D] = []
var moon: Node3D
var new_torch := {}


func _ready() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--%s=" % name):
			return argument.trim_prefix("--%s=" % name)
	return fallback


func _measure() -> float:
	var viewport := get_viewport().get_viewport_rid()
	for frame in range(WARMUP):
		await get_tree().process_frame
	var total := 0.0
	for frame in range(SAMPLES):
		await get_tree().process_frame
		total += RenderingServer.viewport_get_measured_render_time_gpu(viewport)
	return total / SAMPLES


func _apply(changes: Dictionary) -> void:
	var s := FULL.merged(changes, true)
	for environment in environments:
		environment.ssao_enabled = s.ssao
		environment.glow_enabled = s.glow
		environment.adjustment_enabled = s.adjust
		environment.background_mode = Environment.BG_SKY if s.sky else Environment.BG_COLOR
	RenderingServer.environment_set_ssao_quality(s.ssao_quality, true, 0.5, 2, 50.0, 300.0)
	RenderingServer.global_shader_parameter_set(&"look_age", 1.0 if s.surface else 0.0)
	RenderingServer.global_shader_parameter_set(&"look_wet", 1.0 if s.surface else 0.0)
	for lamp in lamps:
		var original: float = lamp.get_meta(&"t273_range") / LOOK.LAMP_RANGE
		var shadowed: bool = lamp.get_meta(&"t273_shadow")
		lamp.omni_range = original * (s.shadow_range if shadowed else s.range)
		lamp.light_size = lamp.get_meta(&"t273_size") if s.size else 0.0
	var values: Dictionary = new_torch if s.torch else OLD_TORCH
	for property: String in values:
		torch.set(property, values[property])
	if moon != null:
		moon.visible = s.moon


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
	for property: String in OLD_TORCH:
		torch.set(property, OLD_TORCH[property])
	torch.shadow_enabled = true
	camera.add_child(torch)
	for frame in range(5):
		await get_tree().process_frame
	for property: String in OLD_TORCH:
		new_torch[property] = torch.get(property)
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
	print("VARIANTS: %d environments, %d tuned lamps, moon %s" % [environments.size(), lamps.size(), moon != null])
	RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), true)
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
		_apply({})
		for frame in range(240):
			await get_tree().process_frame
		var row := {"view": view.id}
		var names: Array = VARIANTS.keys()
		var order: Array = names.duplicate()
		var back: Array = names.duplicate()
		back.reverse()
		order.append_array(back)
		var sums := {}
		for name: String in order:
			_apply(VARIANTS[name])
			sums[name] = sums.get(name, 0.0) + await _measure()
		var line := "VARIANTS %s gpu ms:" % view.id
		for name: String in names:
			row[name] = snappedf(sums[name] / 2.0, 0.01)
			line += "  %s %.2f" % [name, row[name]]
		_apply({})
		results.append(row)
		print(line)
	if not out.is_empty():
		var file := FileAccess.open(out, FileAccess.WRITE)
		file.store_string(JSON.stringify({"results": results}, "\t"))
		file.close()
	print("RESULT: t273 variants %d views" % results.size())
	App.quit()
