extends Node3D
## Standalone fixture: the real story flow decides when to ring the phone.


func _ready() -> void:
	var errors: PackedStringArray = RuleSystem.load_rule_set(load("res://data/rules/demo.tres"))
	for error: String in errors:
		push_warning(error)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R:
		$Phone.ring()
		get_viewport().set_input_as_handled()
