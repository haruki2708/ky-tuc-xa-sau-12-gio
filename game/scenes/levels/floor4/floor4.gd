extends Node3D
## Keep the integration marker on the inside of the moving door leaf.


func _ready() -> void:
	sync_door_anchor()


func sync_door_anchor() -> void:
	var paper := $Door407/Pivot/RulesPaper as Node3D
	var anchor := $Anchors/RulesPaper407 as Marker3D
	anchor.global_transform = paper.global_transform
	anchor.rotate_object_local(Vector3.UP, PI)
	$DoorGap.visible = not $Door407.is_open
