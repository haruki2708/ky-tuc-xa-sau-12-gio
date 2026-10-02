class_name PropTint
extends RefCounted
## Tints imported PS1 prop materials per instance (T-138). The kit import turns
## surfaces into ShaderMaterials with an `albedo_color` parameter. Each tinted
## instance gets its own copy of the (tiny) mesh and its materials, so other
## instances keep their colour. Surface override materials are avoided: the
## headless renderer used by tests reports errors for them.


static func apply(root: Node, color: Color) -> void:
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := node as MeshInstance3D
		if not mesh_instance.has_meta(&"prop_tint_own_mesh"):
			mesh_instance.mesh = mesh_instance.mesh.duplicate()
			mesh_instance.set_meta(&"prop_tint_own_mesh", true)
		var mesh := mesh_instance.mesh
		for surface in mesh.get_surface_count():
			var material := mesh.surface_get_material(surface) as ShaderMaterial
			if material == null:
				continue
			if not material.has_meta(&"prop_tint_own"):
				material = material.duplicate() as ShaderMaterial
				material.set_meta(&"prop_tint_own", true)
				mesh.surface_set_material(surface, material)
			material.set_shader_parameter("albedo_color", color)


## The tint currently shown on the first tinted surface (tests).
static func current(root: Node) -> Color:
	for node in root.find_children("*", "MeshInstance3D", true, false):
		var material := (node as MeshInstance3D).mesh.surface_get_material(0) as ShaderMaterial
		if material != null and material.has_meta(&"prop_tint_own"):
			return material.get_shader_parameter("albedo_color")
	return Color(1, 1, 1)
