extends Marker3D
## One reusable mesh; text and evidence collection are supplied by integrator.
@export_range(1, 3) var fragment_id: int = 1


func _ready() -> void:
	set_fragment(fragment_id)


func set_fragment(value: int) -> void:
	fragment_id = clampi(value, 1, 3)
	if not is_node_ready():
		return
	var builder := SurfaceTool.new()
	builder.begin(Mesh.PRIMITIVE_TRIANGLES)
	var edge: Array[Vector3] = [Vector3(-.09,0,-.12),Vector3(.07,0,-.10),Vector3(.05,0,-.065),Vector3(.095,0,-.02),Vector3(.065,0,.025),Vector3(.08,0,.11),Vector3(-.075,0,.10),Vector3(-.06,0,.025),Vector3(-.095,0,-.015)]
	for i in range(edge.size()):
		# Paper has two visible sides, including the folded waste-paper fragment.
		var points: Array[Vector3] = [Vector3.ZERO, edge[i], edge[(i + 1) % edge.size()], Vector3.ZERO, edge[(i + 1) % edge.size()], edge[i]]
		for point in points:
			if fragment_id == 3:
				point.y = .018 * sin(point.x * 91.0) + .012 * cos(point.z * 73.0)
			builder.set_uv(Vector2(point.x / .2 + .5, point.z / .26 + .5))
			builder.add_vertex(point)
	builder.generate_normals()
	# D-106: the torn inspection form uses the photocopy sheet of the readable papers.
	var material := StandardMaterial3D.new()
	material.albedo_texture = preload("res://assets/textures/papers/photocopy.png")
	material.albedo_color = Color(.62,.22,.20) if fragment_id == 2 else Color.WHITE
	material.roughness = .9
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	builder.set_material(material)
	$Mesh.mesh = builder.commit()
