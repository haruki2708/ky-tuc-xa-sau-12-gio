extends Interactable
## Every interaction is one tap. Timing and decoding belong to the director.

@export var wall_id: StringName = &"wall_406"


func _ready() -> void:
	prompt_key = "PROMPT_WALL_KNOCK"


func _on_interact(_player: Node) -> void:
	EventBus.wall_tapped.emit(wall_id)
	EventBus.noise_emitted.emit(global_position, 3.0, &"knock")
