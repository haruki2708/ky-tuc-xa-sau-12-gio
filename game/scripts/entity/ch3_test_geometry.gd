class_name Ch3TestGeometry
extends Node3D
## Small authored navmesh with six physical steps and a raised landing.


func _ready() -> void:
	box(Vector3(0, -0.1, 2), Vector3(16, 0.2, 8))
	for index: int in 6:
		var height: float = (index + 1) * 0.2
		box(Vector3(0, height * 0.5, -2.25 - index * 0.5), Vector3(4, height, 0.5))
	box(Vector3(0, 0.6, -7), Vector3(16, 1.2, 4))
	var region: NavigationRegion3D = NavigationRegion3D.new()
	var mesh: NavigationMesh = NavigationMesh.new()
	var vertices: PackedVector3Array = []
	for row: Vector2 in [Vector2(6, 0), Vector2(-2, 0), Vector2(-5, 1.2), Vector2(-9, 1.2)]:
		for x: float in [-8.0, -2.0, 2.0, 8.0]:
			vertices.append(Vector3(x, row.y, row.x))
	mesh.vertices = vertices
	for row: int in 3:
		for column: int in 3:
			if row == 1 and column != 1:
				continue
			var corner: int = row * 4 + column
			mesh.add_polygon(PackedInt32Array([corner, corner + 1, corner + 5, corner + 4]))
	region.navigation_mesh = mesh
	add_child(region)


func box(at: Vector3, size: Vector3) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	var collision: CollisionShape3D = CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	var visual: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	body.add_child(visual)
	body.position = at
	add_child(body)
	return body
