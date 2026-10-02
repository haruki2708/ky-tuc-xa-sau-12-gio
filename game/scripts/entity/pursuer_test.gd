extends Node3D
## P is a fixture-only shortcut; story code owns chase timing in the real game.


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_P:
		var player: Node3D = $Player
		var forward: Vector3 = -player.global_basis.z
		forward.y = 0.0
		$Pursuer.start_chase(player, player.global_position - forward.normalized() * 5.0)
		get_viewport().set_input_as_handled()
