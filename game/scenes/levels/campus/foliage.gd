extends Node3D
## Static, spatially chunked MultiMeshes; no per-tree or per-lamp processing.
@export var points: PackedVector3Array
@export_enum("tree", "lamp", "garden") var kind: String = "tree"
## T-259 (garden only): the realistic garden lamp hung at each point. The PS1 post and head are still built, hidden;
## each lamp's globe glows with the Flicker light standing over its point (no light is added or changed).
@export var real_lamp: PackedScene
var _glows: Array = []


func _ready() -> void:
	set_process(false)
	if kind == "tree":
		_part(.16, .24, 3.6, 1.8, Color(.17, .13, .09), 6)
		_part(.2, 2.3, 4.2, 4.2, Color(.13, .20, .12), 7)
		_part(.0, 1.7, 3.0, 6.0, Color(.18, .25, .14), 7)
	else:
		var height := 3.0 if kind == "garden" else 7.0
		_part(.06, .11, height, height / 2.0, Color(.12, .17, .16), 6)
		_part(.32, .28, .16, height, Color(.62, .60, .38), 6, true)
		if kind == "garden" and real_lamp != null:
			_hang_real_lamps()


func _hang_real_lamps() -> void:
	for child in get_children():
		if child is MultiMeshInstance3D:
			(child as MultiMeshInstance3D).visible = false
	var lights: Array[OmniLight3D] = []
	if get_parent() != null:
		for sibling in get_parent().get_children():
			if sibling is OmniLight3D:
				lights.append(sibling)
	for point in points:
		var lamp := real_lamp.instantiate() as Node3D
		lamp.name = "RealLamp"
		add_child(lamp, true)
		lamp.position = point
		var globe := lamp.find_child("Globe", true, false) as MeshInstance3D
		if globe == null:
			continue
		for light in lights:
			if Vector2(light.position.x - point.x, light.position.z - point.z).length() < 0.1:
				var source := globe.mesh.surface_get_material(0) as StandardMaterial3D
				var material := source.duplicate() as StandardMaterial3D
				globe.set_surface_override_material(0, material)
				_glows.append([light, material, source.emission_energy_multiplier])
				break
	set_process(not _glows.is_empty())


func _process(_delta: float) -> void:
	for glow: Array in _glows:
		var light := glow[0] as OmniLight3D
		var on := light.is_visible_in_tree() and light.light_energy > 0.0
		(glow[1] as StandardMaterial3D).emission_energy_multiplier = glow[2] * light.light_energy / 0.35 if on else 0.0


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
