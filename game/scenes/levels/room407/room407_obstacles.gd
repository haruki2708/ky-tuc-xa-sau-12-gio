class_name Room407Obstacles
extends RefCounted
## T-224 (D-134): the T-222 room's things for the manager. The owner's small props become rigid
## bodies he knocks over; his navigation mesh is baked from the room's real floors and colliders and
## from the footprints of every other Tripo prop, so he walks around the beds, desks and fridge
## instead of through them (the T-203 mesh was a few hand-drawn lanes, one through the bin).

## Props that tip over or slide when he walks into them (owner's list), with their mass in kg.
const DYNAMIC := {"TrashBin": 1.0, "TrashBag": 2.0, "Bucket": 1.5, "Towel": 0.3, "BathBucket": 1.5,
	"BathBasins": 1.0, "BasinClothes": 2.0, "SlippersPhuc": 0.3, "SlippersViet": 0.3, "SlippersTrung": 0.3,
	"SlippersDat": 0.3, "Trainers": 0.6, "BottlesCans": 0.8, "ShowerBottles": 0.8, "LaundryDetergent": 1.5,
	"Stool": 1.2}
## Tripo props that never block him: flat on the floor, soft, overhead or drawn across the room.
const PASSABLE: Array[String] = ["FloorMat", "BathTiles", "Conduits", "CurtainBalcony", "ClotheslineRoom",
	"ClotheslineBalcony", "FootballPoster", "CeilingFan"]
## A prop whose bounds start higher than this hangs over him (shelves, shirts on the line, the
## shower rose that chapter 2 stands under).
const OVERHEAD := 0.5
## A collider starting higher than this is over his head (ceiling, lintels).
const HEADROOM := 1.8
## Room-space floor of the corridor in front of 407 (he comes from the 406 side) and its wall,
## with the doorway's gap (Corridor/Doorway_407 piers).
const CORRIDOR_FLOOR := Rect2(-6.0, 0.1, 16.0, 3.8)
const CORRIDOR_WALL_Z := Vector2(-0.1, 0.1)
const DOORWAY_X := Vector2(1.55, 2.45)
## Room space: Door407's leaf opened into the room (floor4.tscn, hinged at x 2.44, 90 degrees); he
## opens it before he comes in and it stays open while he is inside.
const OPEN_ROOM_DOOR := AABB(Vector3(2.38, 0.0, -0.95), Vector3(0.12, 2.1, 0.95))
const NAV_CELL := 0.05
const NAV_CELL_HEIGHT := 0.01
## A swinging leaf (the balcony door) is kept this much further off.
const LEAF_MARGIN := 0.06
## The room's colliders are kept this much further off than his radius, so the voxels' rounding never
## brings a path into his capsule's reach (T-203's capsule test).
const COLLIDER_MARGIN := 0.04
## His capsule is 0.3 m; 5 cm more keeps his swinging arms and the cleaver off the furniture.
const NAV_RADIUS := 0.35


## Wraps DYNAMIC props of TripoProps in rigid bodies on the manager's props layer; the stool's old
## collision under its source node is switched off (the rigid stool takes its place).
static func make_dynamic(room: Node3D, props: Node3D) -> Array[RigidBody3D]:
	var bodies: Array[RigidBody3D] = []
	for prop_name: String in DYNAMIC:
		var prop := props.get_node_or_null(prop_name) as Node3D
		if prop == null:
			continue
		var index := prop.get_index()
		prop.name = "Model"
		var body := RigidBody3D.new()
		body.name = prop_name
		body.collision_layer = DormManager.PROPS_LAYER
		body.collision_mask = 1 | DormManager.PROPS_LAYER
		body.mass = DYNAMIC[prop_name]
		body.can_sleep = true
		body.sleeping = true
		body.set_meta(&"placement", prop.get_meta(&"placement"))
		body.set_meta(&"furnished", true)
		props.add_child(body)
		props.move_child(body, index)
		body.global_transform = prop.global_transform
		prop.reparent(body)
		var bounds: AABB = Room407Furnish.local_bounds(prop)
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = bounds.size.max(Vector3.ONE * 0.02)
		shape.shape = box
		shape.position = prop.transform * bounds.get_center()
		body.add_child(shape)
		var source: String = (body.get_meta(&"placement") as Dictionary).get("source_node", "")
		var old := room.get_node_or_null(source) if source.contains("/") or room.has_node(source) else null
		if old != null:
			for collision: CollisionShape3D in old.find_children("*", "CollisionShape3D", true, false):
				collision.disabled = true
		bodies.append(body)
	return bodies


## Bakes region's navigation mesh: the walkable tops of the room's and corridor's floor colliders,
## carved by every other box collider in the room (not the bathroom door, which he opens), the
## corridor wall beside the doorway and the footprint of each blocking Tripo prop.
static func bake_navigation(room: Node3D, region: NavigationRegion3D) -> void:
	var to_region := region.global_transform.affine_inverse()
	var source := NavigationMeshSourceGeometryData3D.new()
	var corridor := PackedVector3Array()
	for corner: Vector2 in [CORRIDOR_FLOOR.position, Vector2(CORRIDOR_FLOOR.end.x, CORRIDOR_FLOOR.position.y),
			CORRIDOR_FLOOR.end, Vector2(CORRIDOR_FLOOR.position.x, CORRIDOR_FLOOR.end.y)]:
		corridor.append(Vector3(corner.x, 0.0, corner.y))
	_add_floor(source, to_region * room.global_transform, corridor)
	# The doorway's threshold joins the corridor to the room through the wall's thickness.
	_add_floor(source, to_region * room.global_transform, PackedVector3Array([Vector3(DOORWAY_X.x, 0.0, -0.3),
		Vector3(DOORWAY_X.y, 0.0, -0.3), Vector3(DOORWAY_X.y, 0.0, 0.3), Vector3(DOORWAY_X.x, 0.0, 0.3)]))
	_obstruct(source, to_region * room.global_transform, OPEN_ROOM_DOOR)
	for wall: Vector2 in [Vector2(CORRIDOR_FLOOR.position.x, DOORWAY_X.x), Vector2(DOORWAY_X.y, CORRIDOR_FLOOR.end.x)]:
		_obstruct(source, to_region * room.global_transform, AABB(Vector3(wall.x, 0.0, CORRIDOR_WALL_Z.x),
			Vector3(wall.y - wall.x, 3.0, CORRIDOR_WALL_Z.y - CORRIDOR_WALL_Z.x)))
	for shape: CollisionShape3D in room.find_children("*", "CollisionShape3D", true, false):
		var body := shape.get_parent() as StaticBody3D
		if body == null or shape.disabled or not shape.shape is BoxShape3D or body.collision_layer & 1 == 0:
			continue
		if String(room.get_path_to(shape)).begins_with("Extension/BathroomDoor"):
			continue
		var size: Vector3 = (shape.shape as BoxShape3D).size
		var box := AABB(-size / 2.0, size)
		box = box.grow(LEAF_MARGIN if String(room.get_path_to(shape)).begins_with("Extension/BalconyDoor") else COLLIDER_MARGIN)
		var in_room: AABB = room.global_transform.affine_inverse() * shape.global_transform * box
		if in_room.end.y <= 0.06 and size.x * size.z > 0.25:
			_add_floor(source, to_region * shape.global_transform, _top_face(box))
		elif in_room.end.y > 0.06 and in_room.position.y < HEADROOM:
			_obstruct(source, to_region * shape.global_transform, box)
	var props := room.get_node_or_null("Furnished/TripoProps")
	if props != null:
		for prop: Node3D in props.get_children():
			if prop is RigidBody3D or String(prop.name) in PASSABLE or prop.name.begins_with("Net"):
				continue
			var row: Dictionary = prop.get_meta(&"placement", {})
			var bounds: AABB = Room407Furnish.local_bounds(prop)
			var room_box: AABB = room.global_transform.affine_inverse() * prop.global_transform * bounds
			if row.get("mount", "") == "wall" or room_box.position.y > OVERHEAD or room_box.size.y < 0.05:
				continue
			_obstruct(source, to_region * prop.global_transform, bounds)
	var mesh := NavigationMesh.new()
	mesh.cell_size = NAV_CELL
	# Fine heights keep the mesh within a centimetre of the floor his feet stand on.
	mesh.cell_height = NAV_CELL_HEIGHT
	mesh.agent_radius = NAV_RADIUS
	mesh.agent_height = 1.8
	mesh.agent_max_climb = 0.2
	mesh.region_min_size = 1.0
	# Outlines follow the voxels closely, so a path edge is never much nearer an obstacle than his radius.
	mesh.edge_max_error = 0.6
	NavigationServer3D.bake_from_source_geometry_data(mesh, source)
	var map := region.get_navigation_map()
	if map.is_valid():
		NavigationServer3D.map_set_cell_size(map, NAV_CELL)
		NavigationServer3D.map_set_cell_height(map, NAV_CELL_HEIGHT)
	region.navigation_mesh = mesh


static func _top_face(box: AABB) -> PackedVector3Array:
	var y := box.end.y
	return PackedVector3Array([Vector3(box.position.x, y, box.position.z), Vector3(box.end.x, y, box.position.z),
		Vector3(box.end.x, y, box.end.z), Vector3(box.position.x, y, box.end.z)])


## A walkable quad (corners in order, in xform's space) as two triangles facing up.
static func _add_floor(source: NavigationMeshSourceGeometryData3D, xform: Transform3D, quad: PackedVector3Array) -> void:
	source.add_faces(PackedVector3Array([quad[0], quad[1], quad[2], quad[0], quad[2], quad[3]]), xform)


## The footprint of box (in xform's space) blocks the floor under it, widened by his radius.
static func _obstruct(source: NavigationMeshSourceGeometryData3D, xform: Transform3D, box: AABB) -> void:
	var outline := PackedVector3Array()
	var low := INF
	var high := -INF
	for corner: int in [0, 1, 5, 4]:
		var point: Vector3 = xform * box.get_endpoint(corner)
		outline.append(point)
	for corner: int in 8:
		var y: float = (xform * box.get_endpoint(corner)).y
		low = minf(low, y)
		high = maxf(high, y)
	source.add_projected_obstruction(outline, minf(low, 0.0), maxf(high, 0.5) - minf(low, 0.0), false)
