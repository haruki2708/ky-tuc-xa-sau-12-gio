extends Node3D
## Static MultiMesh of scaled unit primitives (stand treads and seats, fence
## pickets, street props). One node and one draw call per material and chunk.
## `data` holds 16 floats per instance: the three basis columns (rotation and
## scale folded together), the origin, then an RGBA colour that tints the texture.
const STRIDE := 16
@export var data: PackedFloat32Array
@export var texture: Texture2D
@export_enum("box", "cylinder", "cone", "quad") var kind: String = "box"
@export var cull_distance: float = 0.0


func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.vertex_color_use_as_albedo = true
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.roughness = 0.9
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3(0.5, 0.5, 0.5)
	var mesh: Mesh
	match kind:
		"cylinder", "cone":
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = 0.5 if kind == "cylinder" else 0.0
			cylinder.bottom_radius = 0.5
			cylinder.height = 1.0
			cylinder.radial_segments = 6
			cylinder.rings = 1
			cylinder.material = material
			mesh = cylinder
		"quad":
			var plane := PlaneMesh.new()
			plane.size = Vector2.ONE
			plane.material = material
			mesh = plane
		_:
			var box := BoxMesh.new()
			box.size = Vector3.ONE
			box.material = material
			mesh = box
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	multi.use_colors = true
	@warning_ignore("integer_division")
	var count: int = data.size() / STRIDE
	multi.instance_count = count
	for i in count:
		var o := i * STRIDE
		var basis := Basis(
				Vector3(data[o], data[o + 1], data[o + 2]),
				Vector3(data[o + 3], data[o + 4], data[o + 5]),
				Vector3(data[o + 6], data[o + 7], data[o + 8]))
		multi.set_instance_transform(i, Transform3D(basis, Vector3(data[o + 9], data[o + 10], data[o + 11])))
		multi.set_instance_color(i, Color(data[o + 12], data[o + 13], data[o + 14], data[o + 15]))
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = multi
	if cull_distance > 0.0:
		instance.visibility_range_end = cull_distance
		instance.visibility_range_end_margin = 12.0
	add_child(instance)
