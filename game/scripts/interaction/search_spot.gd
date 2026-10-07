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


func can_interact(user: Node) -> bool:
	return not is_searched and super.can_interact(user)


func _on_completed() -> void:
	is_searched = true
	# Latch before notifying listeners, including reentrant interactions.
	if not empty_result:
		searched.emit(spot_id)
		if not document_id.is_empty():
			EventBus.document_opened.emit(document_id)
