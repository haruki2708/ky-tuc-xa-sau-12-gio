extends Node3D
## Isolated listening fixture. All geometry is local to the Lane E test scene.


func _ready() -> void:
	# Two rooms on the Z axis, joined through 2 m wide doorways and a corridor.
	_box("Floor", Vector3(0, -0.1, 0), Vector3(8, 0.2, 22), Color(0.3, 0.32, 0.3))
	_box("Ceiling", Vector3(0, 3.6, 0), Vector3(8, 0.2, 22), Color(0.23, 0.25, 0.24))
	for z in [-11.0, 11.0]:
		_box("EndWall", Vector3(0, 1.75, z), Vector3(8, 3.5, 0.2), Color(0.32, 0.38, 0.34))
	for x in [-4.0, 4.0]:
		_box("RoomWall", Vector3(x, 1.75, -7), Vector3(0.2, 3.5, 8), Color(0.35, 0.39, 0.33))
		_box("RoomWall", Vector3(x, 1.75, 7), Vector3(0.2, 3.5, 8), Color(0.3, 0.38, 0.42))
	for x in [-1.5, 1.5]:
		_box("CorridorWall", Vector3(x, 1.75, 0), Vector3(0.2, 3.5, 6), Color(0.31, 0.34, 0.3))
	for z in [-3.0, 3.0]:
		for x in [-2.5, 2.5]:
			_box("DoorSide", Vector3(x, 1.75, z), Vector3(3, 3.5, 0.2), Color(0.32, 0.36, 0.33))
		_box("DoorLintel", Vector3(0, 3.0, z), Vector3(2, 1.0, 0.2), Color(0.32, 0.36, 0.33))
	$Player.footstep.connect($Player/Footsteps.play_footstep)


func _box(label: String, center: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = center
	body.set_meta(&"surface", &"tile")
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.95
	box_mesh.material = material
	mesh.mesh = box_mesh
	body.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match (event as InputEventKey).physical_keycode:
		KEY_L:
			$RoomLight.visible = not $RoomLight.visible
		KEY_F:
			$Hum.flicker(1.5)
