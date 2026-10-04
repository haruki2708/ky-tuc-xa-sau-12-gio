extends Node3D
## Routed cable geometry and movable end markers. No network or puzzle logic.
var plugged: Dictionary = {&"blue": false, &"gray": false}
var _floor_ends: Dictionary = {}
var _meshes: Dictionary = {}
var _plugs: Dictionary = {}


func _ready() -> void:
	if not has_node("../Anchors/LanBlueEnd"):
		return
	for id: StringName in [&"blue", &"gray"]:
		var endpoint := _endpoint(id)
		_floor_ends[id] = endpoint.position
		var plug := MeshInstance3D.new()
		plug.name = "Plug"
		var mesh := BoxMesh.new()
		mesh.size = Vector3(.019,.013,.034)
		plug.mesh = mesh
		endpoint.add_child(plug)
		_plugs[id] = plug
		var line := MeshInstance3D.new()
		line.name = "BlueCable" if id == &"blue" else "GrayCable"
		add_child(line)
		_meshes[id] = line
		set_plugged(id, bool(plugged[id]))
	var port := MeshInstance3D.new()
	port.name = "PortFace"
	var port_mesh := BoxMesh.new()
	port_mesh.size = Vector3(.095,.12,.025)
	port.mesh = port_mesh
	get_node("../Anchors/LanWallPort").add_child(port)
	for offset in [-.022,.022]:
		var socket := MeshInstance3D.new()
		var socket_mesh := BoxMesh.new()
		socket_mesh.size = Vector3(.025,.025,.002)
		var socket_material := StandardMaterial3D.new()
		socket_material.albedo_color = Color(.025,.025,.025)
		socket_mesh.material = socket_material
		socket.mesh = socket_mesh
		port.add_child(socket)
		socket.position = Vector3(offset,0,-.014)
	# Red-taped power lead visibly traces from router down the wall to switch 2.
	_add_fixed("RouterPower",[Vector3(4.6,1.53,-.2),Vector3(4.6,.08,-.2),Vector3(.45,.08,-.2),Vector3(.45,.04,-2.35),Vector3(.95,.14,-2.318)],Color(.04,.04,.04))
	_add_fixed("KettlePower",[Vector3(5.05,.81,-.65),Vector3(5.25,.05,-.65),Vector3(5.25,.05,-.25),Vector3(.55,.05,-.25),Vector3(.55,.05,-2.3),Vector3(1.085,.10,-2.32)],Color(.065,.065,.06))
	_add_fixed("LaptopPower",[Vector3(4.3,.81,-.6),Vector3(4.3,.04,-.28),Vector3(.65,.04,-.28),Vector3(.65,.04,-2.2),Vector3(.815,.10,-2.32)],Color(.06,.06,.06))


func _endpoint(id: StringName) -> Marker3D:
	return get_node("../Anchors/LanBlueEnd" if id == &"blue" else "../Anchors/LanGrayEnd") as Marker3D


func set_plugged(cable_id: StringName, value: bool) -> bool:
	if not plugged.has(cable_id):
		return false
	plugged[cable_id] = value
	if not is_node_ready() or not _floor_ends.has(cable_id):
		return true
	var endpoint := _endpoint(cable_id)
	var port := get_node("../Anchors/LanWallPort") as Node3D
	endpoint.position = port.position + Vector3(-.022 if cable_id == &"blue" else .022,0,-.028) if value else _floor_ends[cable_id]
	var blue := cable_id == &"blue"
	var points: Array[Vector3] = []
	points.assign([Vector3(4.62,1.53,-.19),Vector3(4.62,.12,-.22),Vector3(4.40,.025,-.85),Vector3(4.10,.025,-1.10)] if blue else [Vector3(4.5,.81,-.6),Vector3(4.95,.06,-.55),Vector3(5.15,.025,-1.10),Vector3(4.98,.025,-1.48)])
	points.append(endpoint.position - Vector3(0,0,.10))
	points.append(endpoint.position)
	_meshes[cable_id].mesh = _tube(points,Color(.035,.16,.7) if blue else Color(.39,.41,.40))
	return true


func _add_fixed(label: String, points: Array[Vector3], color: Color) -> void:
	var line := MeshInstance3D.new()
	line.name = label
	line.mesh = _tube(points,color)
	add_child(line)


func _tube(points: Array[Vector3], color: Color) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(points.size()-1):
		var axis := (points[i+1]-points[i]).normalized()
		var u := axis.cross(Vector3.UP if absf(axis.y)<.95 else Vector3.RIGHT).normalized() * .004
		var v := axis.cross(u)
		for j in range(6):
			var a := u*cos(j*TAU/6) + v*sin(j*TAU/6)
			var b := u*cos((j+1)*TAU/6) + v*sin((j+1)*TAU/6)
			for point in [points[i]+a,points[i]+b,points[i+1]+a,points[i]+b,points[i+1]+b,points[i+1]+a]:
				st.set_uv(Vector2.ZERO)
				st.add_vertex(point)
	st.generate_normals()
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://rendering/ps1_surface.gdshader")
	mat.set_shader_parameter("albedo_texture",preload("res://assets/textures/ch1_models/paper.png"))
	mat.set_shader_parameter("albedo_color",color)
	st.set_material(mat)
	return st.commit()
