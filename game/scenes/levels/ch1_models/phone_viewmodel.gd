extends Node3D
## Screen is an independent QuadMesh facing local -Z, +Y is top.


func set_screen_texture(texture: Texture2D) -> void:
	var screen := get_node("Screen") as MeshInstance3D
	var material := screen.get_active_material(0).duplicate() as StandardMaterial3D
	material.albedo_texture = texture
	material.albedo_color = Color.WHITE if texture else Color(.035, .06, .07)
	screen.material_override = material
