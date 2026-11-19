extends Node3D
## T-265 round 2 (D-185): the realistic library (library.tscn Real: the three floors' insides, the stairs and the railing
## along the well, the counter, the librarian's chair, the map, the reading tables, the stacks and books, the loose pieces
## and the mess, the doors, the barricade, the facade) and the ring of ground round it (campus.tscn StripLibrary). Visual
## only: the added colliders are Real/Added's own bodies; no light or sound here.
## - Books: each cluster's near mesh (Books_*, one quad per spine) draws within NEAR metres of its centre, its far mesh
##   (BooksFar_*, a block per board) beyond, so exactly one of them draws.
## - Floors: what furnishes a floor (FLOORS) draws while the camera is in the library on that floor or one floor away
##   (the well and the stairs see one floor up or down; nothing appears late on the stairs), and floor 1's for a camera
##   outside within OUTSIDE metres of the walls (the doors' glass); the windows are dark glass and curtains. With no
##   camera (tests) everything draws.
## - Small and flat things cast no shadow (the library's lights cast none; the torch does).
const FLOORS := {"Counter": 0, "LibrarianChair": 0, "Map": 0, "Shelves_F1": 0, "Fill_F1": 0, "Tables": 1, "Shelves_F2": 1,
	"Fill_F2": 1, "Shelves_F3N": 2, "Shelves_F3S": 2, "Fill_F3": 2}
const LEVELS := [-9.9, -6.6, -3.3]
const FLOOR_H := 3.3
## The library's walls (world x 45..85, z 195..225).
const WALLS := Rect2(45.0, 195.0, 40.0, 30.0)
const OUTSIDE := 12.0
const NEAR := 14.0
const NO_SHADOW := ["Mess", "Fill", "Floor", "Ceiling", "Battens", "Sills", "Windows", "WellEdge", "CurtainGlass", "Grilles", "Roof",
	"Extras", "Bands", "RuleBook", "MapPrint", "MapGlass", "BackLeafGlass", "FrontDoorGlass", "Verge", "Apron", "Paved", "Drains"]

var _groups: Array[Array] = [[], [], []]


func _ready() -> void:
	for child in get_children():
		var level: int = FLOORS.get(String(child.name), -1)
		if level >= 0:
			_groups[level].append(child)
	for mesh: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
		var name := String(mesh.name)
		if name.begins_with("BooksFar_"):
			mesh.visibility_range_begin = NEAR
		elif name.begins_with("Books_"):
			mesh.visibility_range_end = NEAR
		if name.begins_with("Books") or name in NO_SHADOW:
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# The new back leaf hangs under BackDoor/Hinge (room_door.gd swings it), outside this node.
	var leaf := get_node_or_null("../BackDoor/Hinge/LeafReal")
	if leaf != null:
		for mesh: MeshInstance3D in leaf.find_children("*", "MeshInstance3D", true, false):
			if String(mesh.name) in NO_SHADOW:
				mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	set_process(not _groups[0].is_empty())


## Which floors' furnishings draw for a camera at `at` (world).
static func floors_shown(at: Vector3) -> Array[bool]:
	var flat := Vector2(at.x, at.z)
	var shown: Array[bool] = [false, false, false]
	if WALLS.has_point(flat):
		for level in 3:
			shown[level] = at.y >= LEVELS[level] - FLOOR_H - 0.3 and at.y < LEVELS[level] + 2.0 * FLOOR_H + 0.3
	else:
		var gap := maxf(maxf(WALLS.position.x - flat.x, flat.x - WALLS.end.x), maxf(WALLS.position.y - flat.y, flat.y - WALLS.end.y))
		shown[0] = gap < OUTSIDE and at.y < LEVELS[1] + 1.0
	return shown


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var shown := floors_shown(camera.global_position)
	for level in 3:
		for node: Node3D in _groups[level]:
			if node.visible != shown[level]:
				node.visible = shown[level]
