class_name MapLook
extends Node
## T-273 (R0 of docs/design/MAP_REALISM_PLAN.md, D-200): the look of the 208 reference pictures the owner
## approved, laid over the scenes as the ten waves built them. One node per chapter scene (chapter1_main.gd
## adds it). It changes light and surface response only: night ambient, contact shadow, glow, warm lamps, a
## soft torch, and, through two shader globals, age on painted plaster and damp gloss on tiled floors
## (rendering/room407_shell.gdshader). Geometry, collision and every story state stay as they are.
## Off until the owner approves it in game: `-- --look=1` turns it on, `--look-ssr=1` adds screen reflections.

const ARG := "--look="
const SSR_ARG := "--look-ssr="
## Shader globals at full look (0 when off).
const AGE := 1.0
const WET := 1.0
## The night as the pictures have it. "indoor" is chapters 1-2 (floor 4 alone), "campus" chapters 3-4: the
## pictures keep the grounds about as bright as they were (walls readable from afar) and darken the rooms.
const WORLDS := {
	"indoor": {"background_color": Color(0.004, 0.006, 0.010), "ambient_light_color": Color(0.36, 0.42, 0.56),
		"ambient_light_energy": 0.10, "fog_light_color": Color(0.020, 0.028, 0.036), "adjustment_saturation": 0.86},
	"campus": {"background_color": Color(0.006, 0.008, 0.014), "ambient_light_color": Color(0.40, 0.44, 0.52),
		"ambient_light_energy": 0.62, "fog_light_color": Color(0.016, 0.020, 0.030), "adjustment_saturation": 0.93},
}
const SCREEN := {"ssao_enabled": true, "ssao_radius": 1.2, "ssao_intensity": 2.2, "ssao_power": 1.6,
	"ssao_detail": 0.5, "ssao_light_affect": 0.25, "glow_enabled": true, "glow_intensity": 0.12,
	"glow_bloom": 0.02, "glow_hdr_threshold": 1.1, "glow_blend_mode": Environment.GLOW_BLEND_MODE_SCREEN,
	"tonemap_exposure": 1.05, "tonemap_white": 4.0, "adjustment_enabled": true, "adjustment_contrast": 1.1,
	"fog_sky_affect": 0.25}
const REFLECTIONS := {"ssr_enabled": true, "ssr_max_steps": 48, "ssr_fade_in": 0.15, "ssr_fade_out": 2.0,
	"ssr_depth_tolerance": 0.3}
## Lamps: tubes and bulbs turn from green-white to plain white and reach further.
const LAMP_TINT := Color(1.0, 0.98, 0.94)
const LAMP_TINT_WEIGHT := 0.85
const LAMP_ENERGY := 1.3
const LAMP_RANGE := 1.6
const LAMP_ATTENUATION := 1.2
const LAMP_SIZE := 0.12
## Glossy floors answer every lamp with a glare; at full strength the glare burns out.
const LAMP_SPECULAR := 0.3
## Coloured lights (the moon through a window, LEDs) keep their colour: saturation above this is left alone.
const LAMP_MAX_SATURATION := 0.34
## Chapter 3-4's shadowless "Dawn" sun: the pictures have it plain white on the walls, not blue. It still reaches into rooms
## (no shadow): each indoor wave has to deal with that for its own rooms.
const DAWN_ENERGY := 1.0
const DAWN_COLOR := Color(0.72, 0.72, 0.70)
const SKY_SHADER := preload("res://rendering/night_sky.gdshader")
const SKY_NOISE := preload("res://assets/textures/graphics_pilot/room407_shell/noise.png")
## The phone torch: a bright core with a soft, wide edge (D-133 keeps it no brighter overall).
const TORCH := {"light_color": Color(1.0, 0.95, 0.86), "light_energy": 1.9, "spot_angle": 34.0,
	"spot_angle_attenuation": 2.4, "spot_attenuation": 1.25, "spot_range": 14.0}
## Chapters 1-2 see the garden and house A from floor 4 as a backdrop that only ambient light reached. With the
## night ambient it would be black: a moon that lights the backdrop alone (its own render layer) keeps it.
const BACKDROP_LAYER := 1 << 10
const MOON := {"light_color": Color(0.62, 0.68, 0.82), "light_energy": 0.55, "light_specular": 0.1,
	"rotation_degrees": Vector3(-32, 150, 0)}
## Room 407 keeps its own lighting (D-113, D-133) until its wave (R1).
const KEEP_UNDER: Array[StringName] = [&"Room407"]

static var enabled := false
static var ssr := false


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(ARG):
			enabled = arg.trim_prefix(ARG).to_int() != 0
		elif arg.begins_with(SSR_ARG):
			ssr = arg.trim_prefix(SSR_ARG).to_int() != 0
	RenderingServer.global_shader_parameter_set(&"look_age", AGE if enabled else 0.0)
	RenderingServer.global_shader_parameter_set(&"look_wet", WET if enabled else 0.0)
	if not enabled:
		return
	var scene := get_parent()
	var world_name := "campus" if scene.has_node("Campus") else "indoor"
	for world: WorldEnvironment in scene.find_children("*", "WorldEnvironment", true, false):
		_world(world, world_name)
	for light: Light3D in scene.find_children("*", "Light3D", true, false):
		tune_light(light)
	if world_name == "indoor":
		_moon(scene)
	get_tree().node_added.connect(_on_node_added)


func _exit_tree() -> void:
	RenderingServer.global_shader_parameter_set(&"look_age", 0.0)
	RenderingServer.global_shader_parameter_set(&"look_wet", 0.0)


## Lights that the directors build after the scene is up (the CCTV set, a capture rig's torch).
func _on_node_added(node: Node) -> void:
	if node is Light3D:
		tune_light.call_deferred(node)


func _moon(scene: Node) -> void:
	var corridor := scene.get_node_or_null("Floor4/Corridor")
	if corridor == null:
		return
	var found := false
	for child in corridor.get_children():
		if child.name != &"GardenBackdrop" and not String(child.name).begins_with("YardTree_"):
			continue
		found = true
		if child is VisualInstance3D:
			(child as VisualInstance3D).layers |= BACKDROP_LAYER
		for visual: VisualInstance3D in child.find_children("*", "VisualInstance3D", true, false):
			visual.layers |= BACKDROP_LAYER
	if not found:
		return
	var moon := DirectionalLight3D.new()
	moon.name = "MapLookMoon"
	moon.set_meta(&"map_look", true)
	moon.shadow_enabled = false
	moon.light_cull_mask = BACKDROP_LAYER
	for property: String in MOON:
		moon.set(property, MOON[property])
	add_child(moon)


static func _world(world: WorldEnvironment, world_name: String) -> void:
	if world.environment == null or world.environment.has_meta(&"map_look"):
		return
	var source := world.environment
	var environment := source.duplicate() as Environment
	# room407.gd blends the shared resource toward its own night and keeps the outside values in meta.
	if source.has_meta(&"outside_lighting"):
		var outside: Dictionary = source.get_meta(&"outside_lighting")
		for property: String in outside:
			environment.set(property, outside[property])
		for key: StringName in [&"outside_lighting", &"outside_ssao", &"outside_ssao_radius"]:
			environment.remove_meta(key)
	var values: Dictionary = WORLDS[world_name].merged(SCREEN)
	if ssr:
		values.merge(REFLECTIONS)
	for property: String in values:
		environment.set(property, values[property])
	var material := ShaderMaterial.new()
	material.shader = SKY_SHADER
	material.set_shader_parameter(&"noise", SKY_NOISE)
	var sky := Sky.new()
	sky.sky_material = material
	sky.radiance_size = Sky.RADIANCE_SIZE_64
	sky.process_mode = Sky.PROCESS_MODE_QUALITY
	environment.sky = sky
	environment.background_mode = Environment.BG_SKY
	environment.set_meta(&"map_look", true)
	world.environment = environment


static func tune_light(light: Light3D) -> void:
	if not is_instance_valid(light) or light.has_meta(&"map_look"):
		return
	var node: Node = light
	while node != null:
		if node.name in KEEP_UNDER:
			return
		node = node.get_parent()
	light.set_meta(&"map_look", true)
	if light is SpotLight3D and light.name == &"Flashlight":
		for property: String in TORCH:
			light.set(property, TORCH[property])
	elif light is DirectionalLight3D:
		light.light_energy *= DAWN_ENERGY
		light.light_color = DAWN_COLOR
	elif light is OmniLight3D and light.light_color.s <= LAMP_MAX_SATURATION:
		var omni := light as OmniLight3D
		omni.light_color = omni.light_color.lerp(LAMP_TINT, LAMP_TINT_WEIGHT)
		omni.light_energy *= LAMP_ENERGY
		omni.omni_range *= LAMP_RANGE
		omni.omni_attenuation = LAMP_ATTENUATION
		omni.light_size = maxf(omni.light_size, LAMP_SIZE)
		omni.light_specular = LAMP_SPECULAR
