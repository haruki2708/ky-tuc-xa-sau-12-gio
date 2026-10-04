extends Interactable

signal plugged(cable_id: StringName)
signal unplugged(cable_id: StringName)

var cable: LanCable


func _ready() -> void:
	prompt_key = "PROMPT_CABLE_PLUG"


func interact(player: Node) -> void:
	if not enabled or get_tree().paused:
		return
	if is_instance_valid(cable):
		cable.interact(player)
		return
	for candidate: Node in get_tree().get_nodes_in_group(&"lan_cable"):
		if candidate is LanCable and candidate.holder == player:
			cable = candidate
			if not cable.unplugged.is_connected(_on_unplugged):
				cable.unplugged.connect(_on_unplugged, CONNECT_ONE_SHOT)
			if cable.plug_into(self, player):
				prompt_key = "PROMPT_CABLE_UNPLUG"
				plugged.emit(candidate.cable_id)
				EventBus.interacted.emit(self)
			else:
				cable.unplugged.disconnect(_on_unplugged)
				cable = null
			return


func _on_unplugged(id: StringName) -> void:
	prompt_key = "PROMPT_CABLE_PLUG"
	unplugged.emit(id)
