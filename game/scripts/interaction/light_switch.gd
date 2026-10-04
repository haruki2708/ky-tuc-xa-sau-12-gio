extends Interactable

@export var light: Light3D
@export var flag: StringName = &"main_light_on"


func _ready() -> void:
	if not is_instance_valid(light):
		push_warning("Light switch has no assigned light.")
		return
	light.visibility_changed.connect(_sync_light)
	_sync_light()


func _on_interact(_player: Node) -> void:
	if is_instance_valid(light):
		light.visible = not light.visible
		_sync_light()
		EventBus.noise_emitted.emit(global_position, 2.0, &"switch")


func _sync_light() -> void:
	if not is_instance_valid(light):
		return
	prompt_key = "PROMPT_LIGHT_OFF" if light.visible else "PROMPT_LIGHT_ON"
	GameState.set_flag(flag, light.visible)
