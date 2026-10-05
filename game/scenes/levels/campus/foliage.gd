extends Node3D
## Static, spatially chunked MultiMeshes; no per-tree or per-lamp processing.
@export var points: PackedVector3Array
@export_enum("tree", "lamp", "garden") var kind: String = "tree"


func _ready() -> void:
	if kind == "tree":
		_part(.16, .24, 3.6, 1.8, Color(.17, .13, .09), 6)
		_part(.2, 2.3, 4.2, 4.2, Color(.13, .20, .12), 7)
		_part(.0, 1.7, 3.0, 6.0, Color(.18, .25, .14), 7)
	else:
		var height := 3.0 if kind == "garden" else 7.0
		_part(.06, .11, height, height / 2.0, Color(.12, .17, .16), 6)
		_part(.32, .28, .16, height, Color(.62, .60, .38), 6, true)


func _part(top: float, bottom: float, height: float, offset: float, color: Color, segments: int, glow: bool = false) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	if glow:
		material.emission_enabled = true
		material.emission = color * .25
	var mesh := CylinderMesh.new()
	mesh.top_radius = top
	mesh.bottom_radius = bottom
	mesh.height = height
	mesh.radial_segments = segments
	mesh.rings = 1
	mesh.material = material
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	multi.instance_count = points.size()
	for i in points.size():
		var scale_factor := 1.0 + (i % 4) * .07 if kind == "tree" else 1.0
		var basis := Basis.IDENTITY.scaled(Vector3.ONE * scale_factor)
		multi.set_instance_transform(i, Transform3D(basis, points[i] + Vector3(0, offset * scale_factor, 0)))
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = multi
	instance.visibility_range_end = 125.0
	instance.visibility_range_end_margin = 12.0
	add_child(instance)
