extends Node3D
## Routed cable geometry and movable end markers. No network or puzzle logic.
var plugged: Dictionary = {&"blue": false, &"gray": false}
var _floor_ends: Dictionary = {}
var _meshes: Dictionary = {}
var _plugs: Dictionary = {}
const BLUE := Color(.035,.16,.7)
const GRAY := Color(.39,.41,.40)
const RADIUS := .0032
const SIDES := 10
const CORNER_RADIUS := .035
const CORNER_STEPS := 5


func _ready() -> void:
	if not has_node("../Anchors/LanBlueEnd"):
		return
	for id: StringName in [&"blue", &"gray"]:
		var endpoint := _endpoint(id)
		_floor_ends[id] = endpoint.position
		# D-106: clear RJ45 body with a boot in the cable's colour.
		var plug := MeshInstance3D.new()
		plug.name = "Plug"
		var mesh := BoxMesh.new()
		mesh.size = Vector3(.014,.010,.022)
		mesh.material = _material(Color(.80,.84,.86),.25)
		plug.mesh = mesh
		endpoint.add_child(plug)
		var boot := MeshInstance3D.new()
		boot.name = "Boot"
		var boot_mesh := BoxMesh.new()
		boot_mesh.size = Vector3(.016,.012,.018)
		boot_mesh.material = _material(BLUE if id == &"blue" else GRAY,.5)
		boot.mesh = boot_mesh
		boot.position.z = -.019
		plug.add_child(boot)
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
	port_mesh.material = _material(Color(.84,.83,.78),.45)
	port.mesh = port_mesh
	get_node("../Anchors/LanWallPort").add_child(port)
	for offset in [-.022,.022]:
		var socket := MeshInstance3D.new()
		var socket_mesh := BoxMesh.new()
		socket_mesh.size = Vector3(.025,.025,.002)
		socket_mesh.material = _material(Color(.025,.025,.025),.6)
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
	_meshes[cable_id].mesh = _tube(points,BLUE if blue else GRAY)
	return true


func _add_fixed(label: String, points: Array[Vector3], color: Color) -> void:
	var line := MeshInstance3D.new()
	line.name = label
	line.mesh = _tube(points,color)
	add_child(line)


## D-106: round rubber leads. Corners bend over CORNER_RADIUS instead of folding; a ring frame
## carried along the path keeps the tube from twisting.
func _tube(points: Array[Vector3], color: Color) -> ArrayMesh:
	var path := _rounded(points)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var normal := (path[1]-path[0]).normalized().cross(Vector3.UP)
	if normal.length() < .1:
		normal = Vector3.RIGHT
	normal = normal.normalized()
	var rings: Array = []
	var length := 0.0
	for i in range(path.size()):
		var axis := (path[mini(i+1,path.size()-1)]-path[maxi(i-1,0)]).normalized()
		normal = (normal - axis*normal.dot(axis)).normalized()
		var binormal := axis.cross(normal)
		if i > 0:
			length += path[i].distance_to(path[i-1])
		var ring: Array = []
		for j in range(SIDES+1):
			var angle := j*TAU/SIDES
			ring.append(normal*cos(angle) + binormal*sin(angle))
		rings.append([path[i],ring,length])
	for i in range(rings.size()-1):
		for j in range(SIDES):
			var quad := [[i,j],[i,j+1],[i+1,j],[i,j+1],[i+1,j+1],[i+1,j]]
			for corner: Array in quad:
				var ring: Array = rings[corner[0]]
				var out: Vector3 = ring[1][corner[1]]
				st.set_normal(out)
				st.set_uv(Vector2(float(corner[1])/SIDES,ring[2]/.05))
				st.add_vertex(ring[0] + out*RADIUS)
	st.set_material(_material(color,.5))
	return st.commit()


func _rounded(points: Array[Vector3]) -> Array[Vector3]:
	var path: Array[Vector3] = [points[0]]
	for i in range(1,points.size()-1):
		var before := points[i-1]-points[i]
		var after := points[i+1]-points[i]
		var a := points[i] + before.normalized()*minf(CORNER_RADIUS,before.length()*.5)
		var b := points[i] + after.normalized()*minf(CORNER_RADIUS,after.length()*.5)
		for step in range(CORNER_STEPS+1):
			var t := float(step)/CORNER_STEPS
			path.append(a.lerp(points[i],t).lerp(points[i].lerp(b,t),t))
	path.append(points[-1])
	return path


func _material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material