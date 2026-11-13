class_name Floor4Rooms
extends Node3D
## T-255 (D-168): rooms 401-406 and 408 as deep as room 407, each with its bathroom and balcony, furnished like room
## 407 (its Tripo and Blender props, set out differently in each room, the students' fabrics recoloured), opened by
## hand in every chapter. floor4.gd adds this as node "Rooms" at the floor's origin (Floor4 metres throughout).
## - Shell: art_source/graphics_upgrade/floor4_rooms/ (build_rooms.py: room_<n>.glb, Interior and Exterior).
## - What stands where: game/data/floor4_rooms/rooms.json (make_placements.py; layout and props per room).
## - Collision: boxes for the walls, floors, bathroom, balcony and the solid furniture (built here, world layer).
##   The PS1 rooms (corridor.tscn: Floor_, BackWall_, Ceiling_, RoomInterior_, the 408 boxes) are retired, hidden
##   with their collision off; the partitions, the doors (RoomDoor, Blocker) and the corridor stay as they were.
## - Doors: RoomDoorHand on each RoomDoor; the bathroom and balcony doors are room_hinge.gd leaves (room 407's
##   Tripo leaves and levers) with lane A's HingedDoor.
## - Drawing: a room's interior (its shell inside, its furniture, its bathroom door) only while its door is open or
##   the camera is in the room; the facade, balcony and what stands on the balcony always.

const DATA := "res://data/floor4_rooms/rooms.json"
const SHELLS := "res://assets/models/graphics_pilot/floor4_rooms/room_"
const FABRICS := "res://assets/textures/graphics_pilot/floor4_rooms/"
const DOORS := "res://assets/models/graphics_pilot/room407_shell/doors/"
const HINGE := preload("res://scenes/levels/floor4/room_hinge.gd")
## A model's cloth by its file: the kind of recoloured texture it takes (make_room_textures.py).
const FABRIC_KINDS := {"blanket_messy": "blanket_messy", "blanket_folded": "blanket_folded", "pillow": "pillow",
	"shirt_hanging": "shirt", "curtain_balcony": "curtain"}
## A solid prop's box sits this far inside its bounds (room 407's SOLID_INSET).
const SOLID_INSET := 0.05
## The Tripo leaves: size, and the lever (from the free edge, height) as on room 407's doors.
const BATH_LEAF := {"model": "door_bathroom.glb", "size": Vector3(0.98, 2.2, 0.04)}
const BALCONY_LEAF := {"model": "door_balcony.glb", "size": Vector3(0.92, 2.24, 0.05)}
const LEVER_FROM_EDGE := 0.075
const LEVER_HEIGHT := 1.05
const LEVER_SCALE := 1.2
## The balcony door opens out and back against the facade (room 407's open_degrees), clear of the way out.
const BALCONY_OPEN_DEGREES := 172.0
## The PS1 room nodes in corridor.tscn this replaces (per room; the 408 ones by their own names).
const RETIRED := ["Floor_%s", "BackWall_%s", "Ceiling_%s", "RoomInterior_%s"]
const RETIRED_408: Array[String] = ["Room408BackWall"]
const HIDDEN_408: Array[String] = ["Room408EastWall"]
## The camera counts as in a room this far past its walls (standing in the doorway, on the balcony).
const INSIDE_MARGIN := 0.15

## Every interior drawn whatever the doors (captures, tests).
@export var show_all_interiors := false

var rooms: Dictionary[String, Dictionary] = {}
var _data: Dictionary
var _cache: Dictionary = {}
var _fabric_cache: Dictionary = {}


## Builds node "Rooms" under floor4 (in the tree) and retires the PS1 rooms; a floor that has it keeps it.
static func build(floor4: Node3D) -> Floor4Rooms:
	var existing := floor4.get_node_or_null("Rooms") as Floor4Rooms
	if existing != null:
		return existing
	var node := Floor4Rooms.new()
	node.name = "Rooms"
	floor4.add_child(node)
	node.assemble(floor4)
	return node


func assemble(floor4: Node3D) -> void:
	_data = JSON.parse_string(FileAccess.get_file_as_string(DATA))
	var depths: Dictionary = _data.depths
	for number: String in _data.rooms:
		var entry: Dictionary = _data.rooms[number]
		var layout: Dictionary = entry.layout
		var room := Node3D.new()
		room.name = "Room" + number
		add_child(room)
		var interior := Node3D.new()
		interior.name = "Interior"
		room.add_child(interior)
		var outdoor := Node3D.new()
		outdoor.name = "Outdoor"
		room.add_child(outdoor)
		var shell := (_load(SHELLS + number + ".glb") as PackedScene).instantiate() as Node3D
		for part: String in ["Interior", "Exterior"]:
			var mesh := shell.get_node(part) as MeshInstance3D
			shell.remove_child(mesh)
			mesh.owner = null
			mesh.name = "Shell"
			(interior if part == "Interior" else outdoor).add_child(mesh)
		shell.free()
		var props := Node3D.new()
		props.name = "Props"
		interior.add_child(props)
		var outdoor_props := Node3D.new()
		outdoor_props.name = "Props"
		outdoor.add_child(outdoor_props)
		var body := StaticBody3D.new()
		body.name = "Collision"
		body.collision_mask = 0
		room.add_child(body)
		_walls(body, layout, depths)
		_floors(room, layout, depths)
		for row: Dictionary in entry.props:
			_place(row, outdoor_props if row.get("outdoor", false) else props)
		var bath := _hinged(interior, "BathroomDoor", layout, depths, true)
		var balcony := _hinged(outdoor, "BalconyDoor", layout, depths, false)
		var door := floor4.get_node_or_null("Corridor/LockedDoor_" + number) as RoomDoor
		var hand: RoomDoorHand = RoomDoorHand.fit(door) if door != null else null
		for mesh: MeshInstance3D in room.find_children("*", "MeshInstance3D", true, false):
			mesh.gi_mode = GeometryInstance3D.GI_MODE_STATIC
		rooms[number] = {"node": room, "interior": interior, "outdoor": outdoor, "door": door, "hand": hand,
			"bath_door": bath, "balcony_door": balcony, "inside": _inside_box(layout, depths)}
		_retire(floor4, number)
	_update_interiors()


## The room's box in Floor4 metres, for the camera (room, bathroom, balcony; the doorway's depth in front).
func _inside_box(layout: Dictionary, depths: Dictionary) -> AABB:
	var x0: float = float(layout.x0) - INSIDE_MARGIN
	var x1: float = float(layout.x1) + INSIDE_MARGIN
	var z0: float = float(depths.parapet_out) - INSIDE_MARGIN
	return AABB(Vector3(x0, -1.0, z0), Vector3(x1 - x0, float(depths.ext_h) + 1.0, float(depths.wall_room) - z0))


func _process(_delta: float) -> void:
	_update_interiors()


func _update_interiors() -> void:
	var camera := get_viewport().get_camera_3d() if is_inside_tree() else null
	var eye := to_local(camera.global_position) if camera != null else Vector3.INF
	for number: String in rooms:
		var room: Dictionary = rooms[number]
		(room.interior as Node3D).visible = show_all_interiors or interior_wanted(number, eye)


## Whether room `number`'s interior is drawn with the eye at `eye` (Floor4 metres): its door open or swinging, or
## the eye in the room.
func interior_wanted(number: String, eye: Vector3) -> bool:
	var room: Dictionary = rooms[number]
	var door := room.door as RoomDoor
	if door != null and (door.is_open or absf((door.get_node("Hinge") as Node3D).rotation.y) > 0.001):
		return true
	return (room.inside as AABB).has_point(eye)


# --------------------------------------------------------------------------- collision

func _box(body: StaticBody3D, name: String, lo: Vector3, hi: Vector3) -> CollisionShape3D:
	var shape := CollisionShape3D.new()
	shape.name = name
	var box := BoxShape3D.new()
	box.size = (hi - lo).abs()
	shape.shape = box
	shape.position = (lo + hi) / 2.0
	body.add_child(shape)
	return shape


## Side walls, back wall round the balcony door, the bathroom's partition and front wall round its door, the
## balcony's parapet and dividers, the ceiling (Floor4 metres; the corridor wall and partitions keep their own).
func _walls(body: StaticBody3D, layout: Dictionary, depths: Dictionary) -> void:
	var x0: float = layout.x0
	var x1: float = layout.x1
	var west: float = layout.west
	var east: float = layout.east
	var front: float = depths.wall_room
	var back_in: float = depths.back_in
	var back_out: float = depths.back_out
	var top: float = depths.ceiling
	_box(body, "WestWall", Vector3(x0 - 0.2, 0.0, back_out), Vector3(x0, top, front))
	_box(body, "EastWall", Vector3(x1, 0.0, back_out), Vector3(x1 + 0.2, top, front))
	var balcony_door: Array = layout.balcony_door
	var door_top: float = depths.balcony_door_top
	_box(body, "BackWallWest", Vector3(x0, 0.0, back_out), Vector3(balcony_door[0], top, back_in))
	_box(body, "BackWallEast", Vector3(balcony_door[1], 0.0, back_out), Vector3(x1, top, back_in))
	_box(body, "BackWallLintel", Vector3(balcony_door[0], door_top, back_out), Vector3(balcony_door[1], top, back_in))
	var bath: Array = layout.bath
	var bath_wall: float = layout.bath_wall
	var bath_front_room: float = depths.bath_front_room
	var bath_front_in: float = depths.bath_front_in
	var partition := Vector2(bath_wall, bath_wall + 0.1) if layout.bath_side == "east" else Vector2(bath_wall - 0.1, bath_wall)
	_box(body, "BathPartition", Vector3(partition.x, 0.0, back_in), Vector3(partition.y, top, bath_front_room))
	var bath_door: Array = layout.bath_door
	var bath_top: float = depths.bath_door_top
	var lo: float = minf(bath[0], partition.x)
	var hi: float = maxf(bath[1], partition.y)
	_box(body, "BathFrontA", Vector3(lo, 0.0, bath_front_in), Vector3(bath_door[0], top, bath_front_room))
	_box(body, "BathFrontB", Vector3(bath_door[1], 0.0, bath_front_in), Vector3(hi, top, bath_front_room))
	_box(body, "BathFrontLintel", Vector3(bath_door[0], bath_top, bath_front_in), Vector3(bath_door[1], top, bath_front_room))
	var balcony_out: float = depths.balcony_out
	var parapet_out: float = depths.parapet_out
	_box(body, "Parapet", Vector3(west - 0.06, 0.0, parapet_out), Vector3(east + 0.06, 1.15, balcony_out))
	_box(body, "DividerWest", Vector3(west - 0.06, 0.0, parapet_out), Vector3(west + 0.06, 2.0, back_out))
	if layout.east > 43.0:
		_box(body, "DividerEast", Vector3(east - 0.06, 0.0, parapet_out), Vector3(east + 0.06, 2.0, back_out))
	_box(body, "Ceiling", Vector3(x0, top, back_out), Vector3(x1, top + 0.15, front))
	_box(body, "BalconyRoof", Vector3(west - 0.06, top, parapet_out), Vector3(east + 0.06, float(depths.ext_h), back_out))


## The room's floor (to the back wall's outside face; tile, for the footsteps) and the balcony's, 2 cm lower.
func _floors(room: Node3D, layout: Dictionary, depths: Dictionary) -> void:
	var floor_body := StaticBody3D.new()
	floor_body.name = "Floor"
	floor_body.collision_mask = 0
	floor_body.set_meta(&"surface", &"tile")
	floor_body.set_meta(&"is_floor", true)
	room.add_child(floor_body)
	# To the corridor wall's middle, as the PS1 floors (the corridor's floor takes the doorway's other half).
	_box(floor_body, "Room", Vector3(float(layout.x0), -0.2, float(depths.back_out)), Vector3(float(layout.x1), 0.0, 0.0))
	_box(floor_body, "Balcony", Vector3(float(layout.west) + 0.06, -0.22, float(depths.balcony_out)),
		Vector3(float(layout.east) - 0.06, -0.02, float(depths.back_out)))


## Hides a PS1 room's meshes and switches off its collision (nothing is freed: tests and the corridor's
## before/after still find the nodes).
func _retire(floor4: Node3D, number: String) -> void:
	var paths: Array[String] = []
	for pattern: String in RETIRED:
		paths.append("Corridor/" + pattern % number)
	if number == "408":
		for path: String in RETIRED_408:
			paths.append("Corridor/" + path)
	for path: String in paths:
		var node := floor4.get_node_or_null(path)
		if node == null:
			continue
		for shape: CollisionShape3D in node.find_children("*", "CollisionShape3D", true, false):
			shape.disabled = true
		if node is Node3D:
			(node as Node3D).visible = false
		node.set_meta(&"t255_retired", true)
	if number == "408":
		for path: String in HIDDEN_408:
			var node := floor4.get_node_or_null("Corridor/" + path)
			if node != null:
				for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
					mesh.visible = false


# --------------------------------------------------------------------------- props

func _load(path: String) -> Resource:
	if not _cache.has(path):
		_cache[path] = load(path)
	return _cache[path]


func _place(row: Dictionary, parent: Node3D) -> Node3D:
	var model := (_load(row.model) as PackedScene).instantiate() as Node3D
	model.name = row.name
	model.position = Vector3(row.position[0], row.position[1], row.position[2])
	model.rotation_degrees = Vector3(row.get("rot_x", 0.0), row.yaw, 0.0)
	if row.has("scale"):
		model.scale = Vector3(row.scale[0], row.scale[1], row.scale[2])
	if row.get("mount", "") == "wall":
		# The row's position is a point on the wall: the model's back (+Z) goes onto it.
		model.position += model.basis * Vector3(0, 0, -Room407Furnish.local_bounds(model).end.z)
	model.set_meta(&"placement", row)
	parent.add_child(model)
	if row.has("fabric"):
		_dress(model, String(row.model).get_file().get_basename(), String(row.fabric))
	if row.get("solid", false):
		_solid(model)
	return model


## The model's cloth in this room's colour: every textured surface takes <kind>_<colour>.jpg (own material copies,
## shared between models of a kind and colour).
func _dress(model: Node3D, file: String, colour: String) -> void:
	var kind: String = FABRIC_KINDS.get(file, "")
	if kind.is_empty():
		return
	var texture := _load(FABRICS + "%s_%s.jpg" % [kind, colour]) as Texture2D
	if texture == null:
		return
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		for surface in mesh.mesh.get_surface_count():
			var source := mesh.get_active_material(surface) as BaseMaterial3D
			if source == null or source.albedo_texture == null:
				continue
			var key := "%s|%s|%d" % [kind, colour, source.get_instance_id()]
			if not _fabric_cache.has(key):
				var copy := source.duplicate() as BaseMaterial3D
				copy.albedo_texture = texture
				_fabric_cache[key] = copy
			mesh.set_surface_override_material(surface, _fabric_cache[key])


## A static box (world layer) inside a solid prop's bounds, as the prop's child "Solid" (room 407's make_solid).
func _solid(model: Node3D) -> StaticBody3D:
	var bounds: AABB = Room407Furnish.local_bounds(model)
	var body := StaticBody3D.new()
	body.name = "Solid"
	body.collision_mask = 0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = (bounds.size - Vector3(SOLID_INSET, 0.0, SOLID_INSET) * 2.0).max(Vector3.ONE * 0.02)
	shape.shape = box
	shape.position = bounds.get_center()
	body.add_child(shape)
	model.add_child(body)
	return body


# --------------------------------------------------------------------------- bathroom and balcony doors

## A room_hinge.gd door with room 407's Tripo leaf and two levers, and lane A's HingedDoor on it. The bathroom door
## hangs on the jamb by the bathroom's partition and opens in along it; the balcony door on the jamb on the
## bathroom's side, and opens out against the facade.
func _hinged(parent: Node3D, name: String, layout: Dictionary, depths: Dictionary, bathroom: bool) -> Node3D:
	var spec: Dictionary = BATH_LEAF if bathroom else BALCONY_LEAF
	var size: Vector3 = spec.size
	var east: bool = layout.bath_side == "east"
	var opening: Array = layout.bath_door if bathroom else layout.balcony_door
	# The leaf runs from the hinge along +x (dir 1) or -x (dir -1).
	var dir: float
	var hinge_x: float
	var hinge_z: float
	var degrees: float
	if bathroom:
		dir = 1.0 if east else -1.0
		hinge_x = float(opening[0]) + 0.02 if east else float(opening[1]) - 0.02
		hinge_z = float(depths.bath_front_in) + size.z / 2.0 + 0.005
		degrees = 90.0 * dir
	else:
		dir = -1.0 if east else 1.0
		hinge_x = float(opening[1]) - 0.04 if east else float(opening[0]) + 0.04
		hinge_z = float(depths.back_out) - size.z / 2.0
		degrees = BALCONY_OPEN_DEGREES * dir
	var door := Marker3D.new()
	door.set_script(HINGE)
	door.name = name
	door.set("open_degrees", degrees)
	door.position = Vector3(hinge_x, 0.0 if bathroom else 0.02, hinge_z)
	var pivot := Node3D.new()
	pivot.name = "Pivot"
	door.add_child(pivot)
	var leaf := StaticBody3D.new()
	leaf.name = "Leaf"
	leaf.collision_mask = 0
	leaf.position = Vector3(dir * size.x / 2.0, size.y / 2.0, 0.0)
	pivot.add_child(leaf)
	var collision := CollisionShape3D.new()
	collision.name = "Collision"
	collision.shape = BoxShape3D.new()
	(collision.shape as BoxShape3D).size = size
	leaf.add_child(collision)
	var model := (_load(DOORS + spec.model) as PackedScene).instantiate() as Node3D
	model.name = "Model"
	model.position = Vector3(dir * size.x / 2.0, 0.0, 0.0)
	pivot.add_child(model)
	var lever_scene := _load(DOORS + "door_lever.glb") as PackedScene
	for side: float in [-1.0, 1.0]:
		# Lever axes (room 407's): X the bar toward the hinge, Z out of the face.
		var out := Vector3(0, 0, side)
		var bar := Vector3(-dir, 0, 0)
		var lever := lever_scene.instantiate() as Node3D
		lever.name = "LeverFront" if side > 0.0 else "LeverBack"
		pivot.add_child(lever)
		lever.transform = Transform3D(Basis(bar, out.cross(bar), out).scaled(Vector3.ONE * LEVER_SCALE),
			Vector3(dir * (size.x - LEVER_FROM_EDGE), LEVER_HEIGHT, side * size.z / 2.0))
	parent.add_child(door)
	HingedDoor.fit(door)
	return door
