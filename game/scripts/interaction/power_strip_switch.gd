extends Interactable

@export_range(0, 2) var index: int = 0
@export var strip: PowerStrip


func _ready() -> void:
	if strip == null:
		strip = get_parent() as PowerStrip
	if strip != null:
		strip.switch_toggled.connect(_sync_prompt)
		_sync_prompt(index, strip.switches[index])


func _on_interact(_player: Node) -> void:
	if is_instance_valid(strip):
		strip.toggle(index)


func _sync_prompt(_index: int, _on: bool) -> void:
	prompt_key = "PROMPT_POWER_OFF" if strip.switches[index] else "PROMPT_POWER_ON"
