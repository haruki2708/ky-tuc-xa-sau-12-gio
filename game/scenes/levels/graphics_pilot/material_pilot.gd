extends Node3D
## Isolated visual snapshot. Never runs chapter scripts or writes settings.

const FLOOR := preload("res://scenes/levels/floor4/floor4.tscn")
const SCREEN_SHADER := preload("res://rendering/ps1_screen.gdshader")
const ROOM_SHADER := preload("res://rendering/room407_surface.gdshader")
const OUTPUT := "res://../art_source/graphics_upgrade/previews"
const VIEWS := [
	{"id": "room", "eye": Vector3(34.2, 1.65, -0.65), "target": Vector3(36.6, 0.95, -3.15)},
	{"id": "materials", "eye": Vector3(35.75, 1.35, -1.7), "target": Vector3(37.4, 0.65, -2.85)},
	{"id": "corridor", "eye": Vector3(28, 1.65, 2.5), "target": Vector3(40, 1.45, 0.9)},
]

var visual: Node3D
var camera: Camera3D
var screen: ShaderMaterial
var environment: WorldEnvironment
var inspection_light: OmniLight3D
var originals: Dictionary = {}
var pbr_materials: Dictionary = {}
var scene_lights: Dictionary = {}
var brightness: float = 1.0


func _ready() -> void:
	# Copy render nodes only; no source node ever enters the running scene tree.
	var source := FLOOR.instantiate()
	visual = snapshot(source) as Node3D
	source.free()
	add_child(visual)
	for light: Light3D in visual.find_children("*", "Light3D", true, false):
		scene_lights[light] = light.visible
	_restore_room_surfaces()
	# These are runtime-hidden by room scripts in the playable scene.
	for path: String in ["Room407/Details/BloodSeep", "Room407/Details/BloodPools",
			"Room407/Details/SlashRips", "Room407/Details/Debris", "Room407/Extension/ShowerMixer"]:
		(visual.get_node(path) as Node3D).hide()
	environment = visual.get_node("Environment") as WorldEnvironment
	camera = Camera3D.new()
	camera.fov = 65.0
	add_child(camera)
	camera.make_current()
	inspection_light = OmniLight3D.new()
	inspection_light.omni_range = 10.0
	inspection_light.light_energy = 0.8
	camera.add_child(inspection_light)
	var layer := CanvasLayer.new()
	layer.layer = 5
	var rect := ColorRect.new()
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen = ShaderMaterial.new()
	screen.shader = SCREEN_SHADER
	rect.material = screen
	add_child(layer)
	layer.add_child(rect)
	brightness = float(Settings.get_value("video", "brightness"))
	EventBus.settings_changed.connect(_settings_changed)
	_build_materials()
	set_mode(true)
	set_lighting(false)
	set_view(VIEWS[0])
	if "--pilot-capture" in OS.get_cmdline_user_args():
		await _capture()


static func snapshot(source: Node) -> Node:
	var copy: Node
	if source is MeshInstance3D:
		var mesh := MeshInstance3D.new()
		mesh.mesh = source.mesh
		mesh.material_override = source.material_override
		for index in range(source.get_surface_override_material_count()):
			mesh.set_surface_override_material(index, source.get_surface_override_material(index))
		mesh.cast_shadow = source.cast_shadow
		copy = mesh
	elif source is Light3D:
		copy = source.duplicate(0)
		copy.set_script(null)
		for child in copy.get_children():
			child.free()
	elif source is WorldEnvironment:
		var world := WorldEnvironment.new()
		world.environment = source.environment.duplicate()
		copy = world
	elif source is Node3D:
		copy = Node3D.new()
	else:
		copy = Node.new()
	copy.name = source.name
	if source is Node3D:
		(copy as Node3D).transform = source.transform
		(copy as Node3D).visible = source.visible
	for child in source.get_children():
		copy.add_child(snapshot(child))
	return copy


func _restore_room_surfaces() -> void:
	for item: Array in [["Floor", "room_tile", Vector2(20, 12)],
			["WestWall", "room_wall", Vector2(2, 1)], ["EastWall", "room_wall", Vector2(2, 1)]]:
		var material := ShaderMaterial.new()
		material.shader = ROOM_SHADER
		material.set_shader_parameter("albedo_texture", load("res://assets/textures/room407/%s.png" % item[1]))
		material.set_shader_parameter("uv_scale", item[2])
		(visual.get_node("Room407/%s/Mesh" % item[0]) as MeshInstance3D).material_override = material


func _build_materials() -> void:
	for kind: String in ["wall", "tile", "iron", "cloth"]:
		var material := StandardMaterial3D.new()
		material.albedo_texture = load("res://assets/textures/graphics_pilot/%s_albedo.png" % kind)
		material.roughness_texture = load("res://assets/textures/graphics_pilot/%s_roughness.png" % kind)
		material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
		material.normal_enabled = true
		material.normal_texture = load("res://assets/textures/graphics_pilot/%s_normal.png" % kind)
		material.normal_scale = 0.35
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		material.uv1_triplanar = true
		material.uv1_world_triplanar = true
		material.uv1_scale = Vector3.ONE * (2.0 if kind == "cloth" else 1.0)
		material.metallic = 0.8 if kind == "iron" else 0.0
		pbr_materials[kind] = material
	for mesh: MeshInstance3D in visual.find_children("*", "MeshInstance3D", true, false):
		var path := String(visual.get_path_to(mesh))
		var kind := ""
		if path in ["Room407/WestWall/Mesh", "Room407/EastWall/Mesh", "Room407/Ceiling/Mesh"]:
			kind = "wall"
		elif path == "Room407/Floor/Mesh":
			kind = "tile"
		elif path.begins_with("Room407/Details/TrungBedding/") or path.begins_with("Room407/Details/TrungPillow/"):
			kind = "cloth"
		elif path.begins_with("Room407/Bunk") and not ("Net_" in path or "Sleeper_" in path):
			var surfaces: Dictionary = {}
			for surface in range(mesh.mesh.get_surface_count()):
				var material := mesh.get_active_material(surface)
				if material is ShaderMaterial:
					var texture: Variant = material.get_shader_parameter("albedo_texture")
					if texture is Texture2D:
						# build_assets.py aliases iron to ink for bunk_trung only.
						var is_bunk_ink: bool = path.begins_with("Room407/BunkB/") and texture.resource_path == "res://assets/textures/room407/ink.png"
						if "metal" in texture.resource_path or "iron" in texture.resource_path or is_bunk_ink:
							surfaces[surface] = mesh.get_surface_override_material(surface)
			if not surfaces.is_empty():
				originals[mesh] = {"surfaces": surfaces, "kind": "iron"}
		if not kind.is_empty():
			originals[mesh] = {"material": mesh.material_override, "kind": kind}


func set_mode(pbr: bool) -> void:
	for mesh: MeshInstance3D in originals:
		var row: Dictionary = originals[mesh]
		if row.has("surfaces"):
			for surface: int in row.surfaces:
				mesh.set_surface_override_material(surface, pbr_materials[row.kind] if pbr else row.surfaces[surface])
		else:
			mesh.material_override = pbr_materials[row.kind] if pbr else row.material
	screen.set_shader_parameter("strength", 0.0 if pbr else 1.0)
	screen.set_shader_parameter("brightness", brightness)
	RenderingServer.global_shader_parameter_set(&"ps1_strength", 0.0 if pbr else 1.0)


func _settings_changed(section: String, key: String) -> void:
	if section == "video" and key == "brightness":
		brightness = float(Settings.get_value("video", "brightness"))
		screen.set_shader_parameter("brightness", brightness)


func set_lighting(neutral: bool) -> void:
	inspection_light.visible = neutral
	for light: Light3D in scene_lights:
		light.visible = false if neutral else scene_lights[light]
	environment.environment.ambient_light_color = Color(0.75, 0.75, 0.75) if neutral else Color(0.30, 0.39, 0.47)
	environment.environment.ambient_light_energy = 0.55 if neutral else 0.40
	environment.environment.fog_enabled = not neutral


func set_view(view: Dictionary) -> void:
	camera.position = view.eye
	camera.look_at(view.target)


func _capture() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Pilot capture requires a real renderer")
		App.quit(1)
		return
	# Keep review captures at the declared render size despite project UI stretch.
	get_window().content_scale_size = Vector2i(1280, 720)
	get_window().size = Vector2i(1280, 720)
	await get_tree().process_frame
	var destination := ProjectSettings.globalize_path(OUTPUT)
	DirAccess.make_dir_recursive_absolute(destination)
	var report: Dictionary = {"renderer": RenderingServer.get_current_rendering_method(),
		"adapter": RenderingServer.get_video_adapter_name(), "godot": Engine.get_version_info().string, "brightness": brightness,
		"viewport": [get_viewport().get_visible_rect().size.x, get_viewport().get_visible_rect().size.y],
		"scope": "Static visual fixture, no chapter gameplay, no FPS measurement", "material_bindings": {}, "images": []}
	for mesh: MeshInstance3D in originals:
		report.material_bindings[String(visual.get_path_to(mesh))] = originals[mesh].kind
	for view: Dictionary in VIEWS:
		set_view(view)
		for neutral: bool in [true, false]:
			set_lighting(neutral)
			for pbr: bool in [false, true]:
				set_mode(pbr)
				for frame in range(12):
					await get_tree().process_frame
				await RenderingServer.frame_post_draw
				var filename := "%s_%s_%s.png" % [view.id, "neutral" if neutral else "game", "after" if pbr else "before"]
				var frame_image := get_viewport().get_texture().get_image()
				if frame_image.save_png(destination.path_join(filename)) != OK:
					push_error("Cannot save pilot capture")
					App.quit(1)
					return
				report.images.append({"file": filename, "eye": [view.eye.x, view.eye.y, view.eye.z],
					"target": [view.target.x, view.target.y, view.target.z], "fov": camera.fov,
					"image_size": [frame_image.get_width(), frame_image.get_height()]})
	var file := FileAccess.open(OUTPUT.path_join("capture_report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	print("RESULT: graphics pilot capture 12 images PASS")
	App.quit()
