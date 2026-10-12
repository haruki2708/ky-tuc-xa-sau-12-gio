extends Node3D
## T-213 isolated visual study. Source gameplay nodes never enter the tree.
## Opt-in capture: -- --corner-capture; default scene opens a lit comparison view.

const ROOM := preload("res://scenes/levels/floor4/room_407.tscn")
const SNAPSHOT := preload("res://scenes/levels/graphics_pilot/material_pilot.gd")
const PROBE := preload("res://scripts/debug/graphics_asset_probe.gd")
const ROOT := "res://assets/models/graphics_pilot/room407_corner/"
const SOURCE := "res://../art_source/graphics_upgrade/room407_corner/"
const OUTPUT := SOURCE + "previews/"
const VIEWS := [
	{"id": "room_far", "eye": Vector3(32.18, 1.57, -4.02), "target": Vector3(33.78, 0.24, -4.52), "fov": 70.0},
	{"id": "room_near", "eye": Vector3(33.03, 0.97, -4.27), "target": Vector3(33.78, 0.24, -4.52), "fov": 70.0},
	{"id": "door_wide", "eye": Vector3(32.1, 1.6, -0.3), "target": Vector3(32.5, 1.0, -4.1), "fov": 75.0},
	{"id": "bed_eye", "eye": Vector3(33.45, 1.6, -2.1), "target": Vector3(30.7, 0.88, -3.1), "fov": 70.0},
	{"id": "tripo_comparison", "eye": Vector3(35.35, 1.6, -1.15), "target": Vector3(32.2, 0.85, -3.65), "fov": 78.0},
]

var before: Node3D
var after: Node3D
var props: Node3D
var camera: Camera3D
var environment: Environment
var shader_override: ShaderGlobalsOverride
var screen: ShaderMaterial
var tube_light: OmniLight3D
var desk_light: OmniLight3D
var torch: SpotLight3D
var tube_materials: Array[StandardMaterial3D] = []
var bindings: Array = []
var after_mode := true
var lights_on := true


func _ready() -> void:
	bindings = JSON.parse_string(FileAccess.get_file_as_string(SOURCE + "placements.json"))
	var source := ROOM.instantiate()
	before = SNAPSHOT.snapshot(source) as Node3D
	source.free()
	before.name = "BeforePS1"
	before.position = Vector3(30, 0, 0)
	add_child(before)
	for light: Light3D in before.find_children("*", "Light3D", true, false):
		light.visible = false
	for path: String in ["Details/BloodSeep", "Details/BloodPools", "Details/SlashRips", "Details/Debris", "Extension/ShowerMixer"]:
		(before.get_node(path) as Node3D).hide()
	for row: Array in [["Floor", "room_tile", Vector2(20, 12)], ["WestWall", "room_wall", Vector2(2, 1)], ["EastWall", "room_wall", Vector2(2, 1)]]:
		var material := ShaderMaterial.new()
		material.shader = preload("res://rendering/room407_surface.gdshader")
		material.set_shader_parameter("albedo_texture", load("res://assets/textures/room407/%s.png" % row[1]))
		material.set_shader_parameter("uv_scale", row[2])
		(before.get_node("%s/Mesh" % row[0]) as MeshInstance3D).material_override = material
	after = Node3D.new()
	after.name = "AfterCorner"
	after.position = Vector3(30, 0, 0)
	add_child(after)
	for part: String in ["floor", "architecture", "bunk_a", "bunk_a_bedding", "study_desk", "fixtures"]:
		var model := (load(ROOT + part + ".glb") as PackedScene).instantiate() as Node3D
		model.name = part
		after.add_child(model)
	props = Node3D.new()
	props.name = "ApprovedProps"
	after.add_child(props)
	for row: Dictionary in bindings:
		var model := (load(row.model) as PackedScene).instantiate() as Node3D
		model.name = row.name
		model.position = Vector3(row.position[0], row.position[1], row.position[2])
		model.rotation_degrees.y = row.yaw
		props.add_child(model)
	for mesh: MeshInstance3D in after.find_children("*", "MeshInstance3D", true, false):
		mesh.gi_mode = GeometryInstance3D.GI_MODE_STATIC
		if String(mesh.name).begins_with("FluorescentTube"):
			var material := mesh.get_active_material(0).duplicate() as StandardMaterial3D
			material.emission_enabled = true
			material.emission = Color(0.88, 0.94, 0.80)
			mesh.material_override = material
			tube_materials.append(material)
	_add_decals()
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
	environment.tonemap_exposure = 1.0
	environment.ssao_enabled = true
	environment.ssao_radius = 0.35
	environment.ssao_intensity = 1.0
	environment.ssil_enabled = true
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
	environment.fog_sky_affect = 0.0  # night outside the balcony stays dark, not fog-blue
	environment.glow_enabled = true
	environment.glow_intensity = 0.25
	camera = Camera3D.new()
	add_child(camera)
	camera.make_current()
	tube_light = _light(Vector3(32, 2.76, -1.2), Color(0.88, 0.94, 0.80), 2.6, 9.0, 0.25)
	desk_light = _light(Vector3(31.85, 1.00, -4.52), Color(1, 0.78, 0.53), 0.55, 2.1, 0.07)
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
	set_view(VIEWS[4])
	set_mode(true, true)
	if "--corner-capture" in OS.get_cmdline_user_args():
		await _capture()


func _light(pos: Vector3, color: Color, energy: float, radius: float, size: float) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = radius
	light.light_size = size
	light.shadow_enabled = true
	light.light_bake_mode = Light3D.BAKE_DYNAMIC
	add_child(light)
	return light


func _add_decals() -> void:
	for row: Array in [[Vector3(0.11, 0.8, -4.45), Vector3(0.75, 0.15, 1.1), Vector3(0, 0, 90)],
			[Vector3(1.3, 0.65, -6.914), Vector3(1.5, 0.15, 1.1), Vector3(-90, 0, 0)],
			[Vector3(0.11, 2.55, -3.0), Vector3(1.3, 0.15, 0.65), Vector3(0, 0, 90)]]:
		var decal := Decal.new()
		decal.texture_albedo = load(ROOT + "textures/water_stain.png")
		decal.position = row[0]
		decal.size = row[1]
		decal.rotation_degrees = row[2]
		after.add_child(decal)


func set_view(view: Dictionary) -> void:
	camera.position = view.eye
	camera.fov = view.fov
	camera.look_at(view.target)


func set_mode(improved: bool, lit: bool) -> void:
	after_mode = improved
	lights_on = lit
	before.visible = not improved
	after.visible = improved
	tube_light.visible = lit
	desk_light.visible = lit
	torch.visible = not lit
	for material in tube_materials:
		material.emission_energy_multiplier = 1.2 if lit else 0.0
	environment.sdfgi_enabled = improved and DisplayServer.get_name() != "headless"
	environment.ssao_enabled = improved
	environment.ssil_enabled = improved
	shader_override.set("params/ps1_strength", 0.0 if improved else 1.0)
	screen.set_shader_parameter("strength", 0.0 if improved else 1.0)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_L:
			set_mode(after_mode, not lights_on)
		elif event.keycode == KEY_B:
			set_mode(not after_mode, lights_on)
		elif event.keycode >= KEY_1 and event.keycode <= KEY_5:
			set_view(VIEWS[event.keycode - KEY_1])


func _capture() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Corner capture requires Forward+ renderer")
		App.quit(1)
		return
	get_window().content_scale_size = Vector2i(1280, 720)
	get_window().size = Vector2i(1280, 720)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var report := {"godot": Engine.get_version_info().string,
		"renderer": RenderingServer.get_current_rendering_method(), "gpu": RenderingServer.get_video_adapter_name(),
		"resolution": [1280, 720], "brightness": 1.0, "images": [],
		"geometry": JSON.parse_string(FileAccess.get_file_as_string(SOURCE + "geometry_report.json")),
		"textures": JSON.parse_string(FileAccess.get_file_as_string(SOURCE + "texture_sources.json")),
		"placements": bindings, "measured_after": PROBE.measure(after),
		"environment": {"tonemap": "Filmic", "exposure": 1.0, "ambient": 0.12, "fog_density": 0.004,
			"sdfgi_cascades": 4, "sdfgi_cell_m": 0.1, "sdfgi_occlusion": true, "sdfgi_bounce": 0.5,
			"ssao_radius": 0.35, "ssil_radius": 2.0, "ssil_intensity": 0.6,
			"tube_position": [32, 2.76, -1.2], "tube_energy": 2.6, "tube_range": 9.0,
			"desk_energy": 0.55, "torch_energy": 5.0, "torch_angle": 38.0},
		"comparison_policy": "Source PS1 render-only snapshot; identical cameras/direct lights/exposure. After adds SDFGI/SSIL/SSAO, PBR geometry and approved props. No gameplay runs."}
	for view: Dictionary in VIEWS:
		set_view(view)
		for lit: bool in [true, false]:
			for improved: bool in [false, true]:
				set_mode(improved, lit)
				var file := "%s_%s_%s.png" % [view.id, "tube" if lit else "torch", "after" if improved else "before"]
				await _save(file)
				report.images.append({"file": file, "eye": _vec(camera.position), "target": _vec(view.target),
					"fov": camera.fov, "state": "tube" if lit else "torch", "after": improved,
					"sdfgi": environment.sdfgi_enabled, "sha256": FileAccess.get_sha256(OUTPUT + file)})
	# A/B GI comparison holds camera, materials, exposure and direct lights fixed.
	set_view(VIEWS[4])
	set_mode(true, true)
	environment.sdfgi_enabled = false
	await _save("tripo_comparison_tube_after_sdfgi_off.png")
	report["gi_control"] = "tripo_comparison_tube_after_sdfgi_off.png"
	var file := FileAccess.open(OUTPUT + "capture_report.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("RESULT: room407 corner capture 21 images PASS")
	App.quit()


func _save(file: String) -> void:
	for frame in range(100):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result := get_viewport().get_texture().get_image().save_png(OUTPUT + file)
	if result != OK:
		push_error("Cannot save corner capture: " + file)
		App.quit(1)


func _vec(value: Vector3) -> Array:
	return [value.x, value.y, value.z]
