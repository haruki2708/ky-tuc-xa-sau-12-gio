class_name BedSlat
extends HoldInteractable

@export var bed: int = 1
@export var slat_visual: NodePath = ^"SlatPivot"


func _init() -> void:
	hold_seconds = 5.0
	prompt_key = "PROMPT_CH4_FLIP_SLAT"


func can_interact(user: Node) -> bool:
	return bed in [1, 2, 4] and super.can_interact(user)


func _on_completed() -> void:
	var pivot: Node3D = get_node_or_null(slat_visual) as Node3D
	if pivot != null:
		create_tween().tween_property(pivot, "rotation:x", -PI * 0.48, 0.45)
	EventBus.bed_slat_flipped.emit(bed)
