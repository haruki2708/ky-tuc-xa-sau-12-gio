class_name ShowerChoice
extends Interactable

@export var run_water: bool = true


func _init() -> void:
	enabled = false


func set_enabled(value: bool) -> void:
	enabled = value


func interact(player: Node) -> void:
	if not enabled or not CarryItem.player_can_use(player):
		return
	EventBus.shower_choice_made.emit(run_water)
	EventBus.interacted.emit(self)
