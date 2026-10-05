extends Interactable

@export var max_hits: int = 8


func interact(player: Node) -> void:
	if not enabled or not CarryItem.player_can_use(player) or not player.has_method("give_bar"):
		return
	enabled = false
	collision_layer = 0
	hide()
	player.call("give_bar", max_hits)
	EventBus.interacted.emit(self)
	queue_free()
