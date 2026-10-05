extends Node3D
## Editable indexed strip: track lanes retain exact metric dimensions.
@export var vertices: PackedVector3Array
@export var indices: PackedInt32Array
@export var material: Material


func _ready() -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_material(material)
	for point in vertices:
		surface.set_uv(Vector2(point.x, point.z) * .25)
		surface.add_vertex(point)
	for index in indices:
		surface.add_index(index)
	surface.generate_normals()
	var instance := MeshInstance3D.new()
	instance.mesh = surface.commit()
	add_child(instance)
