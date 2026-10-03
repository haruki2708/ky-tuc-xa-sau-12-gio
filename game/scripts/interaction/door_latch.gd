extends Interactable

@export var door: Interactable
@export var flag: StringName = &"door_locked"

var _locked: bool = false
@onready var blocked_sound: AudioStreamPlayer3D = $BlockedSound


func _ready() -> void:
	EventBus.interacted.connect(_on_object_interacted)
	_update_prompt()
	GameState.set_flag(flag, false)


func _physics_process(_delta: float) -> void:
	_update_prompt()


func _on_object_interacted(_object: Node) -> void:
	_update_prompt()


func _door_is_open() -> bool:
	if is_instance_valid(door):
		for property: Dictionary in door.get_property_list():
			if property["name"] == "is_open":
				return bool(door.get("is_open"))
	return false


func _update_prompt() -> void:
	if _locked:
		prompt_key = "PROMPT_UNLOCK_DOOR"
	else:
		prompt_key = "PROMPT_CLOSE_DOOR_FIRST" if _door_is_open() else "PROMPT_LOCK_DOOR"


func interact(player: Node) -> void:
	if not enabled or not is_instance_valid(door):
		return
	_update_prompt()
	if not _locked and _door_is_open():
		blocked_sound.play()
		# No successful interaction: Main must not also play the normal latch cue.
		return
	super.interact(player)


func _on_interact(_player: Node) -> void:
	if not is_instance_valid(door):
		return
	blocked_sound.stop()
	_locked = not _locked
	door.enabled = not _locked
	_update_prompt()
	GameState.set_flag(flag, _locked)
