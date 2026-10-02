extends Node3D
## Main scene: floor 4 + player + UI. Story flow (T-117) will live here.


func _ready() -> void:
	place_player(&"seg1_start")


## Moves the player onto a checkpoint anchor of floor 4 (docs/design/LAYOUT.md §6).
func place_player(anchor_name: StringName) -> void:
	var anchor := $Floor4/Anchors.get_node_or_null(NodePath(anchor_name)) as Node3D
	if anchor == null:
		push_warning("Main: unknown spawn anchor '%s'" % anchor_name)
		return
	$Player.global_transform = anchor.global_transform
