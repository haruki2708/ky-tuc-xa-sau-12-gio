extends Node3D
## QA harness only: 1 clean, 2 seep, 3 pools, 4/5 damage, 6 flicker, 7 shadow.

@onready var room: Node3D = $Playtest/Floor4/Room407


func _ready() -> void:
	var player := $Playtest/Player as CharacterBody3D
	player.position = Vector3(32, .03, -1.5)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1:
			room.set_blood_stage(0)
			room.set_slashed(0)
		KEY_2: room.set_blood_stage(1)
		KEY_3: room.set_blood_stage(2)
		KEY_4: room.set_slashed(.5)
		KEY_5: room.set_slashed(1)
		KEY_6: room.set_flicker(not room.get_node("Room407MainLight").flickering)
		KEY_7:
			var shadow := $Playtest/Floor4/DoorGap/UnderDoorShadow as Node3D
			shadow.visible = not shadow.visible
