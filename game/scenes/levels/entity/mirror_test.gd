extends Node3D
## Standalone visual harness: 1 normal, 2 delayed, 3 stare, 4 corridor.
## No automatic story/scare decisions are made by the environment scenes.

@onready var player: CharacterBody3D = $Playtest/Player
@onready var mirror: Node3D = $Playtest/Floor4/Washroom/Mirror


func _ready() -> void:
	mirror.follow = player
	show_washroom()


func show_washroom() -> void:
	player.global_position = Vector3(1.45, 0.03, -1.85)
	player.velocity = Vector3.ZERO
	player.rotation.y = PI / 2.0
	player.head.rotation = Vector3.ZERO
	mirror.release()


func show_corridor() -> void:
	player.global_position = Vector3(17, 0.03, 1.2)
	player.velocity = Vector3.ZERO
	player.rotation.y = PI / 2.0
	player.head.rotation = Vector3.ZERO
	for number in range(401, 405):
		var light := get_node("Playtest/Floor4/Corridor/CorridorLight_%d" % number) as Light3D
		light.light_energy = 0.0


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1: show_washroom()
		KEY_2: mirror.set_lag(0.5)
		KEY_3: mirror.stare()
		KEY_4: show_corridor()
