extends TestCase

const PILOT := preload("res://scenes/levels/graphics_pilot/material_pilot.tscn")
const MEASURE := preload("res://scenes/levels/graphics_pilot/measure_assets.tscn")


func test_measure_scene_has_no_side_effects_without_explicit_opt_in() -> void:
	var path := "res://../art_source/graphics_upgrade/measured_assets.json"
	var before := FileAccess.get_modified_time(path)
	var probe := MEASURE.instantiate()
	tree.root.add_child(probe)
	await wait_frames(2)
	assert_false(App.is_quitting(), "smoke inspection must not terminate the runner")
	assert_eq(FileAccess.get_modified_time(path), before, "smoke inspection must not rewrite the report")
	probe.queue_free()
	await wait_frames(2)


func test_pilot_isolates_gameplay_and_restores_materials_without_saving_settings() -> void:
	var before := FileAccess.get_file_as_bytes("user://settings.cfg") if FileAccess.file_exists("user://settings.cfg") else PackedByteArray()
	var pilot := PILOT.instantiate()
	tree.root.add_child(pilot)
	await wait_frames(2)
	for node: Node in pilot.visual.find_children("*", "", true, false):
		assert_true(node.get_script() == null, "snapshot must not execute gameplay scripts")
		assert_false(node is CollisionObject3D or node is CollisionShape3D or node is NavigationRegion3D, "snapshot cannot add gameplay physics or navigation")
		assert_false(node is AudioStreamPlayer3D, "snapshot cannot start game audio")
	assert_true(pilot.originals.size() > 4, "room study contains material samples")
	for mesh: MeshInstance3D in pilot.originals:
		var row: Dictionary = pilot.originals[mesh]
		if row.has("surfaces"):
			for surface: int in row.surfaces:
				assert_true(mesh.get_surface_override_material(surface) is StandardMaterial3D)
			for surface in range(mesh.mesh.get_surface_count()):
				if not row.surfaces.has(surface):
					assert_false(mesh.get_active_material(surface) == pilot.pbr_materials.iron, "wood and cloth must not become iron")
		else:
			assert_true(mesh.material_override is StandardMaterial3D)
	pilot.set_mode(false)
	for mesh: MeshInstance3D in pilot.originals:
		var row: Dictionary = pilot.originals[mesh]
		if row.has("surfaces"):
			for surface: int in row.surfaces:
				assert_eq(mesh.get_surface_override_material(surface), row.surfaces[surface], "before mode restores source surface materials")
		else:
			assert_eq(mesh.material_override, row.material, "before mode restores source materials")
	pilot.set_mode(true)
	assert_eq(pilot.screen.get_shader_parameter("strength"), 0.0)
	assert_eq(pilot.screen.get_shader_parameter("brightness"), float(Settings.get_value("video", "brightness")), "brightness remains active with PS1 disabled")
	pilot.set_lighting(true)
	for light: Light3D in pilot.scene_lights:
		assert_false(light.visible, "neutral comparison removes colored game lights")
	pilot.set_lighting(false)
	for light: Light3D in pilot.scene_lights:
		assert_eq(light.visible, pilot.scene_lights[light], "game comparison restores source light state")
	var after := FileAccess.get_file_as_bytes("user://settings.cfg") if FileAccess.file_exists("user://settings.cfg") else PackedByteArray()
	assert_eq(after, before, "pilot must never save settings")
	pilot.queue_free()
	await wait_frames(2)
	RenderingServer.global_shader_parameter_set(&"ps1_strength", float(Settings.get_value("video", "ps1_strength")))
