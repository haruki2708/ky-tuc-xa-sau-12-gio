extends Interactable

signal searched(spot_id: StringName)

@export var spot_id: StringName
@export var document_id: StringName
## The signal owns the name "searched"; use this property for saved state.
@export var is_searched: bool = false:
	set(value):
		is_searched = value
		if value:
			enabled = false


func interact(_player: Node) -> void:
	if not enabled or is_searched:
		return
	is_searched = true
	# Latch before notifying listeners, including reentrant interactions.
	searched.emit(spot_id)
	if not document_id.is_empty():
		EventBus.document_opened.emit(document_id)
	EventBus.interacted.emit(self)
