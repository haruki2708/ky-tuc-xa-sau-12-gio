@tool
extends EditorScenePostImport
## Bake reflection-only layers and PS1 materials, like the existing kit import.

const SURFACE := preload("res://rendering/ps1_surface.gdshader")


func _post_import(scene: Node) -> Object:
	var materials: Dictionary = {}
	for node in scene.find_children("*", "MeshInstance3D", true, false):
		var instance := node as MeshInstance3D
		instance.layers = 1 << 19
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for surface in instance.mesh.get_surface_count():
			var source := instance.mesh.surface_get_material(surface) as StandardMaterial3D
			if not source:
				continue
			if not materials.has(source):
				var material := ShaderMaterial.new()
				material.shader = SURFACE
				material.set_shader_parameter("albedo_color", source.albedo_color)
				material.set_shader_parameter("roughness", 1.0)
				materials[source] = material
			instance.mesh.surface_set_material(surface, materials[source])
	return scene
