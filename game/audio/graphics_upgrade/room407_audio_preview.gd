extends Node3D
## T-218 listening fixture: the furnished room 407 with every source silent on open.
## Never emits gameplay noise, never touches settings or the saved game.

const ROOM := preload("res://scenes/levels/floor4/room_407.tscn")
## Where the sources sat before T-218 (room-local), for the old/new comparison.
const OLD_FAN := Vector3(2.0, 2.4, -2.5)
const NEW_FAN := Vector3(2.0, 2.54, -2.5)
const NEW_HUM := Vector3(0.0, 0.06, 0.0)
const OLD_HUM := Vector3.ZERO
const LISTEN_CENTRE := Vector3(3.5, 1.6, -3.0)
const LISTEN_BATH_DOOR := Vector3(5.3, 1.6, -4.4)
const WATER_DEGREES := {&"cold": 1.0, &"warm": 37.0, &"boiling": 81.0}

var room: Node3D
var camera: Camera3D
var shower: ShowerAudio
var fan: AudioStreamPlayer3D
var light: OmniLight3D
var hum: LightHum
var follow_fixtures: bool = true
var fan_on: bool = false
var steam_on: bool = false
var water: StringName = &""


func _ready() -> void:
	room = ROOM.instantiate() as Node3D
	add_child(room)
	camera = Camera3D.new()
	camera.name = "Listener"
	add_child(camera)
	camera.make_current()
	fan = room.get_node("FanAmbience") as AudioStreamPlayer3D
	light = room.get_node("Room407MainLight") as OmniLight3D
	hum = light.get_node("LightHum") as LightHum
	# The room's AmbientZone only opens the fan and hum around the player body: this fixture has none.
	var zone := room.get_node("AmbientZone")
	room.remove_child(zone)
	zone.free()
	fan.stop_emitting()
	# T-226: the running standing fan's hum (room407.gd) stays off here too.
	var stand_fan := room.find_child("FanHum", true, false) as AmbientEmitter
	if stand_fan != null:
		stand_fan.stop_emitting()
	light.visible = false
	light.light_energy = 0.8
	# The director side of the rig, as chapter2_director builds it.
	shower = ShowerAudio.new()
	room.get_node("Anchors/ShowerStall").add_child(shower)
	listen_at(LISTEN_CENTRE)
	_show()


func listen_at(spot: Vector3) -> void:
	camera.position = room.to_global(spot)
	camera.look_at(room.to_global(Vector3(4.0, 1.5, -5.5)))


func toggle_fan() -> void:
	fan_on = not fan_on
	if fan_on:
		fan.start_emitting()
	else:
		fan.stop_emitting()
	_show()


## The tube lit (steady) or dark; the hum follows the light itself.
func toggle_light() -> void:
	set_flicker(false)
	light.visible = not light.visible
	_show()


## The real flicker_light.gd pulses; LightHum gates the hum on the light's energy.
func set_flicker(value: bool) -> void:
	if value:
		light.visible = true
	light.set_flicker(value)
	_show()


func toggle_flicker() -> void:
	set_flicker(not light.flickering)


func set_water(kind: StringName) -> void:
	water = kind
	if kind == &"":
		shower.set_water(0.0, false)
	else:
		shower.set_water(WATER_DEGREES[kind], true)
	_show()


func toggle_steam() -> void:
	steam_on = not steam_on
	shower.set_steam(0.6 if steam_on else 0.0)
	_show()


func play_mirror_shiver() -> void:
	shower.play_cue("mirror_shiver")


## True: T-218 placement (on the furnished fixtures). False: where the sources sat before.
func place(new_placement: bool) -> void:
	follow_fixtures = new_placement
	fan.position = NEW_FAN if new_placement else OLD_FAN
	hum.position = NEW_HUM if new_placement else OLD_HUM
	shower.follow_fixtures = new_placement
	# Re-aim the sources that are already sounding.
	if water != &"":
		shower.set_water(WATER_DEGREES[water], true)
	_show()


func stop_all() -> void:
	if fan_on:
		toggle_fan()
	set_flicker(false)
	light.visible = false
	set_water(&"")
	if steam_on:
		toggle_steam()
	(shower.get_node("Cue") as AudioStreamPlayer3D).stop()
	_show()


func _show() -> void:
	var text := "T-218 room 407 audio | placement %s | fan %s | tube %s%s | water %s | steam %s" % [
		"NEW" if follow_fixtures else "OLD", fan_on, light.visible, " flicker" if light.flickering else "",
		water if water != &"" else "off", steam_on]
	if is_inside_tree() and get_window() != null:
		get_window().title = text
	print(text)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match (event as InputEventKey).physical_keycode:
		KEY_F: toggle_fan()
		KEY_L: toggle_light()
		KEY_K: toggle_flicker()
		KEY_1: set_water(&"cold")
		KEY_2: set_water(&"warm")
		KEY_3: set_water(&"boiling")
		KEY_0: set_water(&"")
		KEY_S: toggle_steam()
		KEY_M: play_mirror_shiver()
		KEY_T: place(not follow_fixtures)
		KEY_C: listen_at(LISTEN_CENTRE)
		KEY_B: listen_at(LISTEN_BATH_DOOR)
		KEY_SPACE: stop_all()
		KEY_R: get_tree().reload_current_scene()
		KEY_ESCAPE:
			stop_all()
			App.quit()


func _exit_tree() -> void:
	if is_instance_valid(shower):
		shower.stop_emitting()
