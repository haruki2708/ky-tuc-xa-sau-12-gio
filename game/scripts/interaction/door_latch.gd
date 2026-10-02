extends Interactable

@export var door: Interactable
@export var flag: StringName = &"door_locked"

var _locked: bool = false


func _ready() -> void:
	prompt_key = "PROMPT_LOCK_DOOR"
	GameState.set_flag(flag, false)


func _on_interact(_player: Node) -> void:
	if not is_instance_valid(door):
		return
	if not _locked:
		for property: Dictionary in door.get_property_list():
			if property["name"] == "is_open" and bool(door.get("is_open")):
				return
	_locked = not _locked
	door.enabled = not _locked
	prompt_key = "PROMPT_UNLOCK_DOOR" if _locked else "PROMPT_LOCK_DOOR"
	GameState.set_flag(flag, _locked)
