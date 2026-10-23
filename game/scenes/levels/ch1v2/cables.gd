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
## T-226 (D-136): Blender plugs and faceplate (build_electrics.py) in place of the D-106 boxes.
const RJ45 := preload("res://assets/models/graphics_pilot/room407_electrics/rj45_plug.glb")
const PORT := preload("res://assets/models/graphics_pilot/room407_electrics/lan_wall_port.glb")
const MAINS_PLUG := preload("res://assets/models/graphics_pilot/room407_electrics/mains_plug.glb")
## Plug space: where a network cable enters an RJ45 plug's boot, and where a mains cord leaves its plug.
const RJ45_TAIL := Vector3(0,0,-.028)
const PLUG_CORD := Vector3(0,.022,.0325)
## A loose RJ45 plug lies on the floor tiles.
const RJ45_REST_Y := .0045
## The faceplate's back sits on the wall this far behind LanWallPort; a plugged RJ45 rests in its jack
## (x mirrored for the gray cable).
const PORT_BACK := .0125
const JACK := Vector3(-.022,-.0065,-.001)
## Room space: the socket holes of the Tripo wall sockets (placements.json SocketStrip, SocketFan) where the
## strip's and the standing fan's plugs go in, and the wall's normal into the room.
const WALL_PLUGS := {"StripPlug": [Vector3(.155,.358,-2.78),Vector3(1,0,0)],
	"FanPlug": [Vector3(5.17,.358,-4.62),Vector3(-1,0,0)]}


func _ready() -> void:
	if not has_node("../Anchors/LanBlueEnd"):
		return
	for id: StringName in [&"blue", &"gray"]:
		var endpoint := _endpoint(id)
		endpoint.position.y = RJ45_REST_Y
		_floor_ends[id] = endpoint.position
		# D-106: clear RJ45 body with a boot in the cable's colour.
		var plug := RJ45.instantiate() as Node3D
		plug.name = "Plug"
		endpoint.add_child(plug)
		(plug.get_node("Boot") as MeshInstance3D).material_override = _material(BLUE if id == &"blue" else GRAY,.5)
		_plugs[id] = plug
		var line := MeshInstance3D.new()
		line.name = "BlueCable" if id == &"blue" else "GrayCable"
		add_child(line)
		_meshes[id] = line
		set_plugged(id, bool(plugged[id]))
	var port := PORT.instantiate() as Node3D
	port.name = "PortFace"
	get_node("../Anchors/LanWallPort").add_child(port)
	port.position.z = PORT_BACK
	# Leads into the strip's plugs (power_strip.tscn on Anchors/PowerStrip at (1.35, .02, -2.35)): each
	# leaves its plug's relief towards +Z, drops to the floor and runs to the west wall.
	# Red-taped power lead visibly traces from router down the wall to switch 2.
	_add_fixed("RouterPower",[Vector3(4.6,1.53,-.2),Vector3(4.6,.08,-.2),Vector3(.45,.08,-.2),Vector3(.45,.006,-2.205),Vector3(1.35,.006,-2.205),Vector3(1.35,.08,-2.27),Vector3(1.35,.09,-2.297)],Color(.04,.04,.04))
	_add_fixed("KettlePower",[Vector3(5.05,.81,-.65),Vector3(5.25,.05,-.65),Vector3(5.25,.05,-.25),Vector3(.55,.05,-.25),Vector3(.55,.006,-2.215),Vector3(1.485,.006,-2.215),Vector3(1.485,.07,-2.262),Vector3(1.485,.082,-2.2935)],Color(.065,.065,.06))
	_add_fixed("LaptopPower",[Vector3(4.3,.81,-.6),Vector3(4.3,.04,-.28),Vector3(.65,.04,-.28),Vector3(.65,.006,-2.225),Vector3(1.215,.006,-2.225),Vector3(1.215,.07,-2.262),Vector3(1.215,.082,-2.2935)],Color(.06,.06,.06))
	# T-226 (D-136): the strip itself (its lead passes north of Phuc's football) and the standing fan are
	# plugged into wall sockets.
	var strip_cord := _wall_plug("StripPlug")
	_add_fixed("StripPower",[Vector3(1.128,.036,-2.35),Vector3(1.08,.006,-2.3),Vector3(.22,.006,-2.3),Vector3(.2,.006,-2.74),strip_cord-Vector3(0,.06,0),strip_cord],Color(.82,.8,.74))
	var fan_cord := _wall_plug("FanPlug")
	_add_fixed("FanPower",[Vector3(4.69,.015,-4.46),Vector3(4.8,.006,-4.52),Vector3(5.12,.006,-4.6),fan_cord-Vector3(0,.06,0),fan_cord],Color(.82,.8,.74))


## A mains plug in a wall socket (WALL_PLUGS); returns the room-space point where its cord leaves.
func _wall_plug(label: String) -> Vector3:
	var entry: Array = WALL_PLUGS[label]
	var plug := MAINS_PLUG.instantiate() as Node3D
	plug.name = label
	add_child(plug)
	# Pins (-Y) into the wall, cord relief (+Z) hanging down.
	var out: Vector3 = entry[1]
	plug.transform = Transform3D(Basis(out.cross(Vector3.DOWN), out, Vector3.DOWN), entry[0])
	var white := StandardMaterial3D.new()
	white.albedo_color = Color(.82,.8,.74)
	white.roughness = .5
	(plug.get_node("Body") as MeshInstance3D).material_override = white
	return plug.transform * PLUG_CORD


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
	var jack := JACK * Vector3(1 if cable_id == &"blue" else -1,1,1)
	endpoint.position = port.position + jack if value else _floor_ends[cable_id]
	var blue := cable_id == &"blue"
	var points: Array[Vector3] = []
	points.assign([Vector3(4.62,1.53,-.19),Vector3(4.62,.12,-.22),Vector3(4.40,.006,-.85),Vector3(4.10,.006,-1.10)] if blue else [Vector3(4.5,.81,-.6),Vector3(4.95,.06,-.55),Vector3(5.15,.006,-1.10),Vector3(4.98,.006,-1.48)])
	var tail := endpoint.position + RJ45_TAIL
	points.append(tail - Vector3(0,0,.08))
	points.append(tail)
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