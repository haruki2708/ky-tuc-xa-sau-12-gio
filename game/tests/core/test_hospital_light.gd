extends TestCase
## D-167 (owner, 13/11/2026): the chapter 4 ward in a soft, ordinary light. The campus's dawn sun and
## sky stayed on and lit the ward at y 300 too, over a ward set up far too bright, and the ending
## showed a white-out (T-248 survey, integrator probe).

var scene: Node
var director: Chapter4Director


func before_each() -> void:
	scene = load("res://scenes/main/chapter4.tscn").instantiate()
	director = scene.get_node("Chapter4Director")
	director.auto_start = false
	Chapter1Director.resume_checkpoint = &""
	GameState.reset()
	tree.root.add_child(scene)
	await wait_frames(3)


func after_each() -> void:
	tree.paused = false
	scene.queue_free()
	await wait_frames(2)
	GameState.reset()
	RuleSystem.reset()


func test_ward_has_its_own_soft_light() -> void:
	director._show_hospital()
	await wait_frames(2)
	var ward: Node3D = director._hospital
	assert_not_null(ward, "the ward is shown")
	var camera := ward.get_node("Camera_Wake") as Camera3D
	var environment: Environment = (ward.get_node("Environment") as WorldEnvironment).environment
	assert_true(camera.current, "the wake-up camera takes over")
	assert_eq(camera.environment, environment, "the ward's camera sees the ward's own environment, not the campus sky")
	for light: Node in scene.find_children("*", "DirectionalLight3D", true, false):
		if not ward.is_ancestor_of(light):
			assert_false((light as Node3D).is_visible_in_tree(), "no campus sun reaches the ward: " + String(light.name))
	assert_true(environment.ambient_light_energy <= 0.3, "an indoor ambient, not a white-out (%.2f)" % environment.ambient_light_energy)
	assert_true((ward.get_node("CeilingLight") as OmniLight3D).light_energy <= 1.0, "a soft ceiling light")
	var wall := (ward.get_node("West/Mesh") as MeshInstance3D).get_active_material(0) as BaseMaterial3D
	assert_true(wall.albedo_color.get_luminance() < 0.75, "walls painted, not paper white")
