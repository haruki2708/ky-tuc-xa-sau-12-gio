extends HoldInteractable

signal searched(spot_id: StringName)

@export var spot_id: StringName
@export var document_id: StringName
## CH4 decoys use hold_seconds = 8 and deliberately emit no mission result.
@export var empty_result: bool = false
## The signal owns the name "searched"; use this property for saved state.
@export var is_searched: bool = false:
	set(value):
		is_searched = value
		if value:
			enabled = false


func _ready() -> void:
	super._ready()
	_place_hand_target()
	if spot_id == &"phuc_mattress":
		# The chapter places this area at the upper mattress's aisle edge.
		# Keep its front just ahead of Bunk1, and its bottom above downward
		# rays toward Viet's lower mattress. Other search spots retain their size.
		var pick: CollisionShape3D = get_node_or_null("CollisionShape3D") as CollisionShape3D
		if pick != null:
			var shape: BoxShape3D = BoxShape3D.new()
			shape.size = Vector3(0.16, 0.15, 0.2)
			pick.shape = shape
			pick.position.y = 0.075


func can_interact(user: Node) -> bool:
	return not is_searched and super.can_interact(user)


func _on_completed() -> void:
	is_searched = true
	# Latch before notifying listeners, including reentrant interactions.
	if not empty_result:
		searched.emit(spot_id)
		if not document_id.is_empty():
			EventBus.document_opened.emit(document_id)


## Chapter 1 placements use different faces of the same search area.
func _place_hand_target() -> void:
	var target := get_node_or_null("HandTarget") as HandTarget
	if target == null:
		return
	match spot_id:
		&"viet_locker":
			# Match the pilot's locker edge after the anchor's -90 degree yaw.
			target.position = Vector3(-0.06, 0.0, 0.01)
		&"phuc_mattress":
			target.position = Vector3(-0.1, -0.105, 0.0)
		&"trash_bin":
			# Take the side near the picking area's upper edge.
			target.position = Vector3(0.13, 0.18, 0.0)
