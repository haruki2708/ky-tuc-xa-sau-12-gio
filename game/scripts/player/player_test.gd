extends Node3D
## Shows the raw translation key for debugging, not a player-facing HUD.

@onready var prompt: Label = $Debug/Prompt


func _ready() -> void:
	EventBus.interaction_focus_changed.connect(_on_focus_changed)


func _on_focus_changed(prompt_key: String) -> void:
	prompt.text = prompt_key
