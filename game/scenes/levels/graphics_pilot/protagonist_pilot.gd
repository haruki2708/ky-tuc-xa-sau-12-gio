extends Node3D
## T-220 step 1 (D-121, D-124): the player with a full body in the playable room 407 (D-113
## lighting). Free play: walk, crouch, look down at the feet, see the body in the mirrors; E by
## hand on Door 407 and the bathroom door (lever handles on both faces), Viet's locker and Dat's
## note (one second each, within reach only). F lights the phone, held in the left hand (Q
## raises it). L cycles night/torch/tube.
## Opt-in captures: -- --body-capture (needs Forward+). Scripted walk-through for a video:
## -- --body-demo (record with Godot's --write-movie).

const CHAPTER := preload("res://scenes/main/chapter1_main.gd")
const OUTPUT := "res://../art_source/graphics_upgrade/protagonist/previews/"
const ORIGIN := Vector3(30, 0, 0)
const LIGHTS: Array[String] = ["night", "torch", "tube"]
## Door 407's handle spindle at mid-thickness of the leaf (world, closed), and the bathroom door's.
const DOOR_HANDLE := Vector3(31.71, 1.065, -0.085)
const BATH_HANDLE := Vector3(36.19, 1.0, -4.0)
## Viet's locker door: the outer edge at hand height, world space at the closed angle.
const LOCKER_EDGE := Vector3(30.61, 1.0, -1.31)
const PAPER := "Ch1DatNote"
## Where the player stands for each action: position, yaw (radians), head pitch (degrees),
## and an eye inside the room for the third-person shots. "mirror" is set in front of the
## full mirror at start.
var spots := {
	"door": [Vector3(31.72, 0.02, -0.55), PI, -42.0, Vector3(31.0, 1.6, -2.4)],
	"locker": [Vector3(31.18, 0.02, -1.35), PI * 0.5, -22.0, Vector3(32.6, 1.5, -2.6)],
	"paper": [Vector3(31.28, 0.02, -3.98), 0.0, -45.0, Vector3(32.9, 1.7, -2.9)],
	"open": [Vector3(32.6, 0.02, -2.0), 0.0, 0.0, Vector3(33.9, 1.5, -3.9)],
	"bath_door": [Vector3(36.02, 0.02, -3.45), 0.0, -35.0, Vector3(34.6, 1.6, -2.6)],
	"mirror": [Vector3.ZERO, 0.0, -18.0, Vector3.ZERO],
	"bath_mirror": [Vector3.ZERO, 0.0, -8.0, Vector3.ZERO],
}
## id, spot, light, extra: pitch override, "walk" seconds, action + seconds into it, third person.
const SHOTS := [
	{"id": "look_down_tube", "spot": "open", "light": "tube", "pitch": -75.0},
	{"id": "look_down_night", "spot": "open", "light": "torch", "pitch": -75.0},
	{"id": "look_down_walk_tube", "spot": "open", "light": "tube", "pitch": -60.0, "walk": 0.55},
	{"id": "look_down_crouch_tube", "spot": "open", "light": "tube", "pitch": -65.0, "crouch": true},
	{"id": "mirror_tube", "spot": "mirror", "light": "tube"},
	{"id": "bath_mirror_tube", "spot": "bath_mirror", "light": "tube"},
	{"id": "body_side_tube", "spot": "open", "light": "tube", "third": true},
	{"id": "body_walk_side_tube", "spot": "open", "light": "tube", "third": true, "walk": 0.55},
	{"id": "door_reach_tube", "spot": "door", "light": "tube", "action": "door", "at": 0.45},
	{"id": "door_press_tube", "spot": "door", "light": "tube", "action": "door", "at": 0.6},
	{"id": "door_pull_tube", "spot": "door", "light": "tube", "action": "door", "at": 0.75},
	{"id": "door_side_tube", "spot": "door", "light": "tube", "action": "door", "at": 0.5, "third": true},
	{"id": "door_hand_close_tube", "spot": "door", "light": "tube", "action": "door", "at": 0.45, "third": true,
		"eye": Vector3(32.25, 1.25, -0.75), "look": Vector3(31.75, 1.05, -0.1)},
	{"id": "bath_door_press_tube", "spot": "bath_door", "light": "tube", "action": "bath_door", "at": 0.6},
	{"id": "bath_door_side_tube", "spot": "bath_door", "light": "tube", "action": "bath_door", "at": 0.6, "third": true},
	{"id": "lever_close_tube", "spot": "door", "light": "tube", "action": "door", "at": 0.6, "third": true,
		"eye": Vector3(32.15, 1.3, -0.62), "look": Vector3(31.76, 1.05, -0.13)},
	{"id": "phone_torch_tube", "spot": "open", "light": "torch", "pitch": -20.0},
	{"id": "phone_raised_tube", "spot": "open", "light": "tube", "pitch": -10.0, "phone": true},
	{"id": "phone_torch_side", "spot": "open", "light": "torch", "third": true},
	{"id": "locker_reach_tube", "spot": "locker", "light": "tube", "action": "locker", "at": 0.45},
	{"id": "locker_side_tube", "spot": "locker", "light": "tube", "action": "locker", "at": 0.6, "third": true},
	{"id": "paper_reach_tube", "spot": "paper", "light": "tube", "action": "paper", "at": 0.45},
	{"id": "paper_lift_tube", "spot": "paper", "light": "tube", "action": "paper", "at": 0.95},
	{"id": "paper_side_tube", "spot": "paper", "light": "tube", "action": "paper", "at": 0.6, "third": true},
	{"id": "paper_hold_close_tube", "spot": "paper", "light": "tube", "action": "paper", "at": 0.98, "third": true,
		"eye": Vector3(31.85, 1.6, -3.7), "look": Vector3(31.3, 1.5, -4.25)},
	{"id": "paper_hold_back_tube", "spot": "paper", "light": "tube", "action": "paper", "at": 0.98, "third": true,
		"eye": Vector3(30.85, 1.75, -3.35), "look": Vector3(31.3, 1.45, -4.2)},
]

var floor4: Node3D
var room: Node3D
var player: CharacterBody3D
var body: PlayerBody
var phone: Node3D
var targets: Dictionary = {}
var light_index: int = 2
var third_camera: Camera3D
## Pilot-only lamp over the bathroom sink (the room has no bathroom light), lit with the tube,
## so the mirror shots show the body.
var bath_lamp: OmniLight3D
var _spot: String = "open"


## Opens and closes a hinged.gd thing by hand (Viet's locker, the bathroom door): the leaf swings
## over the hold. Its HandTargets ride on the leaf (the hand follows the edge or lever); the one
## nearest the player is taken.
class HandHinge:
	extends Interactable
	var hinged: Node3D
	var edges: Array[HandTarget] = []

	func hand_target(from: Vector3 = Vector3.INF) -> HandTarget:
		var best: HandTarget = null
		for edge: HandTarget in edges:
			if best == null or (from.is_finite()
					and edge.global_position.distance_squared_to(from) < best.global_position.distance_squared_to(from)):
				best = edge
		return best

	func _on_interact(_player: Node) -> void:
		var pivot := hinged.get_node("Pivot") as Node3D
		var opening: bool = not bool(hinged.get("is_open"))
		# The bathroom door stops short of its wall (D-124); other hinges open square.
		var open: float = hinged.call("open_angle") if hinged.has_method("open_angle") else PI / 2.0
		var angle: float = open if opening else 0.0
		hinged.set("is_open", opening)
		if hand_seconds > 0.0:
			var swing := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			swing.tween_property(pivot, "rotation:y", angle, hand_seconds).set_trans(Tween.TRANS_SINE)
		else:
			pivot.rotation.y = angle


func _ready() -> void:
	floor4 = $Floor4 as Node3D
	room = floor4.get_node("Room407") as Node3D
	player = $Player as CharacterBody3D
	CHAPTER.place_papers(room.get_node("Anchors") as Node3D, self)
	body = PlayerBody.new()
	player.set_body(body)
	_add_targets()
	# The mirrors show the body's mirror mesh; their PS1 stand-in body stays hidden here.
	for mirror: Node in room.find_children("*", "", true, false):
		if mirror.has_method("set_lag"):
			mirror.set("follow", player)
			for mesh: MeshInstance3D in mirror.get_node("ReflectionBody").find_children("*", "MeshInstance3D", true, false):
				mesh.hide()
	# 1.4 m in front of the full mirror (its +Z faces the room), looking at it.
	var glass := room.get_node("ReflectiveFullMirror") as Node3D
	var front: Vector3 = glass.global_basis.z.normalized()
	front.y = 0.0
	var stand: Vector3 = glass.global_position + front.normalized() * 1.1
	stand.y = 0.02
	spots["mirror"][0] = stand
	spots["mirror"][1] = atan2(front.x, front.z)
	# 0.9 m in front of the bathroom mirror over the sink: head and shoulders.
	glass = room.get_node("ReflectiveMirrorSmall") as Node3D
	front = glass.global_basis.z.normalized()
	front.y = 0.0
	stand = glass.global_position + front.normalized() * 0.9
	stand.y = 0.02
	spots["bath_mirror"][0] = stand
	spots["bath_mirror"][1] = atan2(front.x, front.z)
	# The phone's own light is the torch (D-104 brightens the room for a "Flashlight" under the camera).
	phone = player.get_node("Head/Camera3D/PhoneItem") as Node3D
	bath_lamp = OmniLight3D.new()
	bath_lamp.light_color = Color(1.0, 0.93, 0.82)
	bath_lamp.light_energy = 1.2
	bath_lamp.omni_range = 3.5
	bath_lamp.shadow_enabled = true
	add_child(bath_lamp)
	bath_lamp.global_position = (spots["bath_mirror"][0] as Vector3) + Vector3.UP * 2.2
	third_camera = Camera3D.new()
	third_camera.fov = 50.0
	add_child(third_camera)
	_set_light(LIGHTS[light_index])
	_place("open")
	var args := OS.get_cmdline_user_args()
	if "--body-capture" in args:
		await _capture()
	elif "--body-demo" in args:
		await _demo()


func _add_targets() -> void:
	# D-124: lever handles on both faces; on Door 407 they hang on its HandlePivot, so the rattle
	# from the corridor shakes them too. The PS1 box handles go.
	var door := floor4.get_node("Door407") as Interactable
	DoorHandles.fit(floor4.get_node("Door407/Pivot/HandlePivot") as Node3D, DOOR_HANDLE, Vector3.FORWARD, Vector3.RIGHT, 0.02)
	(floor4.get_node("Door407/Pivot/HandlePivot/Grip") as Node3D).hide()
	targets["door"] = door
	var bath := room.get_node("Extension/BathroomDoor") as Node3D
	var bath_door := HandHinge.new()
	bath_door.name = "BathroomDoorHand"
	bath_door.hinged = bath
	bath_door.prompt_key = "PROMPT_OPEN_DOOR"
	add_child(bath_door)
	bath_door.global_position = Vector3(35.85, 1.05, -4.0)
	var leaf := CollisionShape3D.new()
	leaf.shape = BoxShape3D.new()
	(leaf.shape as BoxShape3D).size = Vector3(0.98, 2.0, 0.12)
	bath_door.add_child(leaf)
	for edge: HandTarget in DoorHandles.fit(bath.get_node("Pivot") as Node3D, BATH_HANDLE, Vector3.BACK, Vector3.LEFT, 0.02):
		bath_door.edges.append(edge)
	(bath.get_node("Pivot/Handle") as Node3D).hide()
	targets["bath_door"] = bath_door
	var hinged := room.get_node("Anchors/VietLocker") as Node3D
	var locker := HandHinge.new()
	locker.name = "VietLockerHand"
	locker.hinged = hinged
	locker.prompt_key = "PROMPT_CH1_SEARCH_LOCKER"
	add_child(locker)
	locker.global_position = LOCKER_EDGE
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	(shape.shape as BoxShape3D).size = Vector3(0.1, 1.5, 0.34)
	shape.position = Vector3(0.0, -0.2, -0.15)
	locker.add_child(shape)
	var edge := HandTarget.new()
	edge.name = "HandTarget"
	edge.grip = HandTarget.Grip.HOOK
	(hinged.get_node("Pivot") as Node3D).add_child(edge)
	edge.global_position = LOCKER_EDGE
	locker.edges.append(edge)
	targets["locker"] = locker
	var paper := get_node(PAPER) as Interactable
	var pinch := HandTarget.new()
	pinch.name = "HandTarget"
	pinch.grip = HandTarget.Grip.PINCH
	pinch.pick_up = true
	paper.add_child(pinch)
	# Just inside the sheet's right-hand edge (+X lying face up on the desk), half way up.
	pinch.position = Vector3((paper.get("size") as Vector2).x * 0.5 - 0.015, 0.0, 0.002)
	targets["paper"] = paper


func _set_light(light: String) -> void:
	phone.set_flashlight(light == "torch")
	var tube := room.get_node("Room407MainLight") as OmniLight3D
	tube.visible = light == "tube"
	tube.light_energy = tube.flicker_energy if light == "tube" else 0.0
	bath_lamp.visible = light == "tube"


func _place(spot: String, pitch: float = INF) -> void:
	_spot = spot
	var entry: Array = spots[spot]
	player.global_position = entry[0]
	player.rotation.y = entry[1]
	player.velocity = Vector3.ZERO
	(player.get_node("Head") as Node3D).rotation.x = deg_to_rad(entry[2] if pitch == INF else pitch)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and (event as InputEventKey).keycode == KEY_L:
		light_index = (light_index + 1) % LIGHTS.size()
		_set_light(LIGHTS[light_index])


func _reset_things() -> void:
	(targets["door"] as Node).call("set_open", false)
	var hinged := room.get_node("Anchors/VietLocker") as Node3D
	hinged.call("set_open", false)
	(room.get_node("Extension/BathroomDoor") as Node).call("set_open", false)
	phone.set_raised(false)
	var view := get_node_or_null("DocumentView")
	if view != null and view.has_method("close_view"):
		view.call("close_view")


func _walk(seconds: float) -> void:
	Input.action_press("move_forward")
	var left: float = seconds
	while left > 0.0:
		await get_tree().physics_frame
		left -= get_physics_process_delta_time()
	Input.action_release("move_forward")


func _show_third_person(on: bool) -> void:
	var camera := player.get_node("Head/Camera3D") as Camera3D
	if not on:
		camera.make_current()
		return
	# From inside the room, looking at the chest: both meshes show (the mirror mesh carries
	# the head this camera would otherwise not see).
	third_camera.global_position = spots[_spot][3]
	third_camera.look_at(player.global_position + Vector3.UP * 1.0)
	third_camera.set_cull_mask_value(PlayerBody.MIRROR_LAYER, true)
	third_camera.make_current()


func _aim_third_person(eye: Vector3, look: Vector3) -> void:
	third_camera.global_position = eye
	third_camera.look_at(look)


func _capture() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Body capture requires Forward+ renderer")
		App.quit(1)
		return
	get_window().content_scale_size = Vector2i(1920, 1080)
	get_window().size = Vector2i(1920, 1080)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var report := {"godot": Engine.get_version_info().string,
		"renderer": RenderingServer.get_current_rendering_method(), "gpu": RenderingServer.get_video_adapter_name(),
		"resolution": [1920, 1080], "stride_speeds": body.stride_speeds, "images": []}
	for shot: Dictionary in SHOTS:
		_reset_things()
		_set_light(shot.light)
		_place(shot.spot, shot.get("pitch", INF))
		_show_third_person(false)
		Input.action_release("crouch")
		for frame in range(20):
			await get_tree().physics_frame
		if shot.get("phone", false):
			phone.set_raised(true)
			for frame in range(30):
				await get_tree().physics_frame
		if shot.get("crouch", false):
			Input.action_press("crouch")
			for frame in range(30):
				await get_tree().physics_frame
		if shot.has("walk"):
			await _walk(shot.walk)
		if shot.has("action"):
			var target := targets[shot.action] as Interactable
			body.perform(target)
			var left: float = shot.at
			while left > 0.0:
				await get_tree().physics_frame
				left -= get_physics_process_delta_time()
		_show_third_person(shot.get("third", false))
		if shot.has("eye"):
			_aim_third_person(shot.eye, shot.look)
		get_tree().paused = shot.has("action") or shot.has("walk")
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var file := "%s.png" % shot.id
		if get_viewport().get_texture().get_image().save_png(OUTPUT + file) != OK:
			push_error("Cannot save body capture: " + file)
			App.quit(1)
			return
		get_tree().paused = false
		while body.acting:
			await get_tree().physics_frame
			if body.get("_reading"):
				_reset_things()
		Input.action_release("crouch")
		report.images.append({"file": file, "shot": shot})
	var out := FileAccess.open(OUTPUT + "capture_report.json", FileAccess.WRITE)
	out.store_string(JSON.stringify(report, "\t") + "\n")
	print("RESULT: body capture %d images PASS" % report.images.size())
	App.quit()


## A short walk-through for a video: walking with the phone's light in the left hand, the
## bathroom mirror, then the locker, Dat's note (read for two seconds), Door 407 and the bathroom
## door (lever handles), first as the player sees them and again from inside the room.
func _demo() -> void:
	_set_light("torch")
	_place("open", -25.0)
	await _wait(1.0)
	await _walk(1.4)
	await _wait(0.8)
	_set_light("tube")
	_place("bath_mirror")
	await _wait(2.5)
	for third: bool in [false, true]:
		for spot: String in ["locker", "paper", "door", "bath_door"]:
			_reset_things()
			_place(spot)
			_show_third_person(third)
			await _wait(0.8)
			body.perform(targets[spot])
			while body.acting:
				await get_tree().physics_frame
				if body.get("_reading"):
					await _wait(2.0)
					_reset_things()
			await _wait(1.0)
	_show_third_person(false)
	print("RESULT: body demo PASS")
	App.quit()


func _wait(seconds: float) -> void:
	var left: float = seconds
	while left > 0.0:
		await get_tree().physics_frame
		left -= get_physics_process_delta_time()
