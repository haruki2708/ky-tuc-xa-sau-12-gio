extends Node3D
## Tripo batch 2 (D-093) isolated visual study: the whole room 407 furnished with the approved
## shell of T-213, the Blender mattress (D-095) and every Tripo prop. Source gameplay nodes never
## enter the tree. Opt-in capture: -- --furnished-capture; default scene opens a lit overview.
## Split props (split_animated.py): F spins the ceiling fan rotor, O opens Viet's locker door.

const ROOM := preload("res://scenes/levels/floor4/room_407.tscn")
const SNAPSHOT := preload("res://scenes/levels/graphics_pilot/material_pilot.gd")
const OUTPUT := "res://../art_source/graphics_upgrade/room407_furnished/previews/"
const ORIGIN := Vector3(30, 0, 0)
## Same blade speed as the playable scenes (main.gd, chapter1_main.gd).
const FAN_SPEED := 15.0
# Room-local eye/target; ids "before" also render the PS1 room for comparison.
const VIEWS := [
	{"id": "door_overview", "eye": Vector3(2.1, 1.65, -0.35), "target": Vector3(4.0, 0.9, -4.8), "fov": 80.0, "before": true},
	{"id": "back_overview", "eye": Vector3(4.7, 1.65, -3.75), "target": Vector3(1.4, 0.8, -1.0), "fov": 80.0, "before": true},
	{"id": "bunk_a", "eye": Vector3(2.5, 1.5, -1.5), "target": Vector3(0.65, 0.7, -3.0), "fov": 70.0, "before": false},
	{"id": "bunk_b", "eye": Vector3(5.5, 1.5, -1.5), "target": Vector3(7.35, 0.7, -2.9), "fov": 70.0, "before": false},
	{"id": "study_desk", "eye": Vector3(2.7, 1.45, -3.2), "target": Vector3(1.6, 0.7, -4.8), "fov": 72.0, "before": true},
	{"id": "viet_desk", "eye": Vector3(4.3, 1.55, -2.3), "target": Vector3(4.5, 0.8, -0.4), "fov": 72.0, "before": false},
	{"id": "lying_lower_bunk", "eye": Vector3(0.65, 0.86, -2.36), "target": Vector3(0.65, 1.13, -3.36), "fov": 75.0, "before": false},
	{"id": "bathroom", "eye": Vector3(6.0, 1.6, -4.35), "target": Vector3(7.0, 0.7, -6.6), "fov": 82.0, "before": false},
	{"id": "room_centre", "eye": Vector3(5.6, 1.6, -0.9), "target": Vector3(2.8, 0.35, -3.0), "fov": 75.0, "before": false},
	{"id": "bath_sink", "eye": Vector3(6.95, 1.55, -4.55), "target": Vector3(5.4, 0.95, -5.4), "fov": 75.0, "before": false},
	{"id": "balcony_side", "eye": Vector3(4.6, 1.5, -3.5), "target": Vector3(1.8, 0.9, -6.6), "fov": 75.0, "before": false},
	{"id": "viet_locker_open", "eye": Vector3(2.0, 1.45, -1.2), "target": Vector3(0.35, 0.95, -1.15), "fov": 70.0, "before": false, "locker_open": true},
]

var before: Node3D
var after: Node3D
var props: Node3D
var camera: Camera3D
var environment: Environment
var shader_override: ShaderGlobalsOverride
var screen: ShaderMaterial
var lights: Array[Light3D] = []
var torch: SpotLight3D
var tube_materials: Array[StandardMaterial3D] = []
var bindings: Array = []
var after_mode := true
var lights_on := true
var decals: Node3D
var fan_rotor: Node3D
var locker_door: Node3D
var fan_spinning := false


func _ready() -> void:
	bindings = Room407Furnish.placements()
	var source := ROOM.instantiate()
	source.furnished = false
	before = SNAPSHOT.snapshot(source) as Node3D
	source.free()
	before.name = "BeforePS1"
	before.position = ORIGIN
	add_child(before)
	for light: Light3D in before.find_children("*", "Light3D", true, false):
		light.visible = false
	for path: String in ["Details/BloodSeep", "Details/BloodPools", "Details/SlashRips", "Details/Debris", "Extension/ShowerMixer"]:
		(before.get_node(path) as Node3D).hide()
	after = Room407Furnish.build()
	after.name = "AfterFurnished"
	after.position = ORIGIN
	add_child(after)
	props = after.get_node("TripoProps") as Node3D
	decals = after.get_node("Decals") as Node3D
	fan_rotor = props.get_node("CeilingFan").find_child("fan_rotor", true, false) as Node3D
	locker_door = props.get_node("LockerViet").find_child("DoorPivot", true, false) as Node3D
	tube_materials = Room407Furnish.tube_materials(after)
	var world := WorldEnvironment.new()
	environment = Environment.new()
	world.environment = environment
	add_child(world)
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.012, 0.016, 0.023)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.48, 0.57, 0.7)
	environment.ambient_light_energy = 0.12
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.ssao_radius = 0.35
	environment.ssil_radius = 2.0
	environment.ssil_intensity = 0.6
	environment.sdfgi_cascades = 4
	environment.sdfgi_min_cell_size = 0.1
	environment.sdfgi_read_sky_light = false
	environment.sdfgi_use_occlusion = true
	environment.sdfgi_bounce_feedback = 0.5
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.25, 0.30, 0.36)
	environment.fog_density = 0.004
	environment.fog_sky_affect = 0.0
	environment.glow_enabled = true
	environment.glow_intensity = 0.25
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	# Same lamps as the corner pilot, plus the bathroom bulb of extension.tscn.
	_light(Vector3(2, 2.76, -1.2), Color(0.88, 0.94, 0.80), 2.6, 9.0, 0.25)
	_light(Vector3(1.85, 1.0, -4.62), Color(1, 0.78, 0.53), 0.55, 2.1, 0.07)
	_light(Vector3(6.6, 2.5, -5.5), Color(0.95, 0.93, 0.85), 1.2, 4.5, 0.1)
	torch = SpotLight3D.new()
	torch.position = Vector3(0.09, -0.12, 0)
	torch.light_color = Color(0.83, 0.9, 1)
	torch.light_energy = 5.0
	torch.spot_range = 10.0
	torch.spot_angle = 38.0
	torch.spot_angle_attenuation = 1.3
	torch.shadow_enabled = true
	torch.light_size = 0.025
	camera.add_child(torch)
	shader_override = ShaderGlobalsOverride.new()
	add_child(shader_override)
	var layer := CanvasLayer.new()
	add_child(layer)
	var rect := ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen = ShaderMaterial.new()
	screen.shader = preload("res://rendering/ps1_screen.gdshader")
	screen.set_shader_parameter("brightness", 1.0)
	rect.material = screen
	layer.add_child(rect)
	set_view(VIEWS[0])
	set_mode(true, true)
	if "--furnished-capture" in OS.get_cmdline_user_args():
		await _capture()


func _light(pos: Vector3, color: Color, energy: float, radius: float, size: float) -> void:
	var light := OmniLight3D.new()
	light.position = ORIGIN + pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = radius
	light.light_size = size
	light.shadow_enabled = true
	light.light_bake_mode = Light3D.BAKE_DYNAMIC
	add_child(light)
	lights.append(light)


func set_view(view: Dictionary) -> void:
	camera.position = ORIGIN + view.eye
	camera.fov = view.fov
	camera.look_at(ORIGIN + view.target)


func set_mode(improved: bool, lit: bool) -> void:
	after_mode = improved
	lights_on = lit
	before.visible = not improved
	after.visible = improved
	for light in lights:
		light.visible = lit
	torch.visible = not lit
	for material in tube_materials:
		material.emission_energy_multiplier = 1.2 if lit else 0.0
	environment.sdfgi_enabled = improved and DisplayServer.get_name() != "headless"
	environment.ssao_enabled = improved
	environment.ssil_enabled = improved
	shader_override.set("params/ps1_strength", 0.0 if improved else 1.0)
	screen.set_shader_parameter("strength", 0.0 if improved else 1.0)


## Like hinged.gd of ch1v2/viet_locker.tscn: +90 degrees about Y swings the door out.
func set_locker_open(value: bool) -> void:
	locker_door.rotation.y = PI / 2.0 if value else 0.0


func _process(delta: float) -> void:
	if fan_spinning:
		fan_rotor.rotate_y(FAN_SPEED * delta)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_L:
			set_mode(after_mode, not lights_on)
		elif event.keycode == KEY_B:
			set_mode(not after_mode, lights_on)
		elif event.keycode == KEY_F:
			fan_spinning = not fan_spinning
		elif event.keycode == KEY_O:
			set_locker_open(locker_door.rotation.y == 0.0)
		elif event.keycode >= KEY_1 and event.keycode < KEY_1 + VIEWS.size():
			set_view(VIEWS[event.keycode - KEY_1])


func _capture() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Furnished capture requires Forward+ renderer")
		App.quit(1)
		return
	get_window().content_scale_size = Vector2i(1280, 720)
	get_window().size = Vector2i(1280, 720)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var report := {"godot": Engine.get_version_info().string,
		"renderer": RenderingServer.get_current_rendering_method(), "gpu": RenderingServer.get_video_adapter_name(),
		"resolution": [1280, 720], "placements": bindings.size(), "images": []}
	for view: Dictionary in VIEWS:
		set_view(view)
		set_locker_open(view.get("locker_open", false))
		var states: Array = [[true, true], [true, false]]
		if view.before:
			states.append([false, true])
		for state: Array in states:
			set_mode(state[0], state[1])
			var file := "%s_%s_%s.png" % [view.id, "tube" if state[1] else "torch", "after" if state[0] else "before"]
			await _save(file)
			report.images.append({"file": file, "eye": [view.eye.x, view.eye.y, view.eye.z], "fov": view.fov,
				"sha256": FileAccess.get_sha256(OUTPUT + file)})
	var file := FileAccess.open(OUTPUT + "capture_report.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("RESULT: room407 furnished capture %d images PASS" % report.images.size())
	App.quit()


func _save(file: String) -> void:
	for frame in range(100):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png(OUTPUT + file) != OK:
		push_error("Cannot save furnished capture: " + file)
		App.quit(1)
