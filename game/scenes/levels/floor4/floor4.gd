extends Node3D
## Keep the integration marker on the inside of the moving door leaf.


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


func sync_door_anchor() -> void:
	var paper := $Door407/Pivot/RulesPaper as Node3D
	var anchor := $Anchors/RulesPaper407 as Marker3D
	anchor.global_transform = paper.global_transform
	anchor.rotate_object_local(Vector3.UP, PI)
	$DoorGap.visible = not $Door407.is_open
