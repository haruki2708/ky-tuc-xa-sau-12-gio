extends Interactable

@export var light: Light3D
@export var flag: StringName = &"main_light_on"


func _ready() -> void:
	_place_hand_target.call_deferred()
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


## The chapter replaces the desk switch's pick box after _ready with the lamp's bounds.
func _place_hand_target() -> void:
	if flag != &"desk_lamp_on":
		return
	var target := get_node_or_null("HandTarget") as HandTarget
	var collision := get_node_or_null("CollisionShape3D") as CollisionShape3D
	if target == null or collision == null or not collision.shape is BoxShape3D:
		return
	var size := (collision.shape as BoxShape3D).size
	if size.is_equal_approx(Vector3(0.08, 0.12, 0.025)):
		return
	# Reach the front of the lamp base, rather than the obsolete separate switch anchor.
	target.global_position = collision.to_global(Vector3(0.0, -size.y * 0.5 + 0.025, 0.05))
