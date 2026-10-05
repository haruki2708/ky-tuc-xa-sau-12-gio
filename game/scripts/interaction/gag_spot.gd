class_name GagSpot
extends Interactable

signal gag_requested(bed: int, item_id: StringName)

@export_enum("Bed 1:1", "Bed 2:2", "Bed 4:4") var bed: int = 1
var gagged: bool = false


func can_interact(player: Node) -> bool:
	return enabled and not gagged and bed in [1, 2, 4] and CarryItem.held_by(player) != null


func interact(player: Node) -> void:
	if not can_interact(player) or not CarryItem.player_can_use(player):
		return
	var item: CarryItem = CarryItem.held_by(player)
	gag_requested.emit(bed, StringName(item.item_id))
	EventBus.interacted.emit(self)


func set_gagged(value: bool) -> void:
	gagged = value
	enabled = not value
