extends Node3D
## Keep the integration marker on the inside of the moving door leaf.

## Corridor meshes lying in the same plane as a wall of the furnished room (D-113: the 407/408
## partition flickered against the furnished east wall above the bathroom tiles). The furnished
## wall draws them; their collision stays.
const DRAWN_BY_FURNISHED_ROOM: Array[String] = ["Corridor/RoomPartition_38/Mesh"]


func _ready() -> void:
	_hang_furnished_door()
	sync_door_anchor()


## T-215: the furnished room's door leaf swings on Door407 in place of the PS1 leaf.
func _hang_furnished_door() -> void:
	var leaf: Node3D = $Room407.furnished_room_door()
	if leaf == null:
		return
	var pivot := $Door407/Pivot as Node3D
	var angle := pivot.rotation.y
	pivot.rotation.y = 0.0
	leaf.set_meta(&"furnished", true)
	var pose := leaf.global_transform
	leaf.get_parent().remove_child(leaf)
	pivot.add_child(leaf)
	leaf.global_transform = pose
	pivot.rotation.y = angle
	for mesh: MeshInstance3D in $Door407/Pivot/Leaf.find_children("*", "MeshInstance3D", true, false):
		mesh.visible = false
	# T-222: a leaf with its own levers (the Tripo door) turns them on HandlePivot, so the corridor
	# rattle shakes them about their spindle; the box grip hides.
	var levers := leaf.find_children("Lever*", "", false, false)
	if not levers.is_empty():
		var handle := $Door407/Pivot/HandlePivot as Node3D
		var spindle := Vector3.ZERO
		for lever: Node3D in levers:
			spindle += lever.global_position / levers.size()
		handle.global_position = spindle
		for lever: Node3D in levers:
			lever.reparent(handle)
		($Door407/Pivot/HandlePivot/Grip as Node3D).visible = false
	for path: String in DRAWN_BY_FURNISHED_ROOM:
		(get_node(path) as Node3D).visible = false
	# D-104: corridor lights reaching into the furnished room cast shadows so its walls keep them out.
	var room := $Room407 as Node3D
	var inside: AABB = room.global_transform * room.INSIDE
	for light: OmniLight3D in $Corridor.find_children("*", "OmniLight3D", true, false):
		var nearest := light.global_position.clamp(inside.position, inside.end)
		if light.global_position.distance_to(nearest) < light.omni_range:
			light.shadow_enabled = true


func sync_door_anchor() -> void:
	var paper := $Door407/Pivot/RulesPaper as Node3D
	var anchor := $Anchors/RulesPaper407 as Marker3D
	anchor.global_transform = paper.global_transform
	anchor.rotate_object_local(Vector3.UP, PI)
	$DoorGap.visible = not $Door407.is_open
