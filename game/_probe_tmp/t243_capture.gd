extends Node
## T-243 preview shots: chapter 2's hand things done by Tran Trung, seen from outside, and the
## carrying pose seen through his own eyes.
const CHAPTER := "res://scenes/main/chapter2.tscn"
const OUTPUT := "res://../build/integrator/t243/"

var room: Node3D
var anchors: Node3D
var player: CharacterBody3D
var body: PlayerBody
var director: Chapter2Director
var camera: Camera3D
var own: Camera3D
var lamp: OmniLight3D
var shots_only: bool = false


func _ready() -> void:
	get_tree().create_timer(400.0, true, false, true).timeout.connect(func() -> void:
		print("CAPTURE_TIMEOUT")
		get_tree().quit(1))
	get_window().size = Vector2i(960, 540)
	AudioServer.set_bus_mute(0, true)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var chapter := (load(CHAPTER) as PackedScene).instantiate() as Node3D
	director = chapter.get_node("Chapter2Director") as Chapter2Director
	director.auto_start = false
	add_child(chapter)
	for i in 6:
		await get_tree().physics_frame
	room = chapter.get_node("Floor4/Room407")
	anchors = room.get_node("Anchors")
	player = chapter.get_node("Player")
	body = player.get("body")
	own = player.get_node("Head/Camera3D")
	var tube := room.get_node("Room407MainLight") as OmniLight3D
	tube.visible = true
	tube.light_energy = 1.0
	camera = Camera3D.new()
	camera.fov = 55.0
	add_child(camera)
	camera.set_cull_mask_value(PlayerBody.MIRROR_LAYER, true)
	lamp = OmniLight3D.new()
	lamp.light_color = Color(1.0, 0.94, 0.85)
	lamp.light_energy = 1.6
	lamp.omni_range = 6.0
	add_child(lamp)
	GameState.segment = &"r3"
	for bed: int in [1, 2, 4]:
		director._gagged[bed] = false
		director._corpse_state(bed, &"talk")
	director._bathroom_door(true)
	for i in 20:
		await get_tree().physics_frame

	await _use("1_lay_gie", anchors.get_node("RagSpot/Carry_rag"), Vector3(7.5, 0.02, -5.7), Vector3(6.3, 1.75, -6.6))
	await _walk_and_look("1_lay_gie")
	await _use("2_nhet_mieng_viet", anchors.get_node("Gag2/GagSpot"), Vector3(1.44, 0.02, -2.31), Vector3(2.9, 1.7, -1.3))
	await _use("3_lay_khan", anchors.get_node("TowelSpot/Carry_towel"), Vector3(2.8, 0.02, -7.45), Vector3(1.6, 1.6, -6.7))
	await _use("4_nhet_mieng_phuc", anchors.get_node("Gag1/GagSpot"), Vector3(1.44, 0.02, -3.25), Vector3(2.9, 1.9, -4.3))
	await _use("5_lay_ao", anchors.get_node("ShirtSpot/Carry_shirt"), Vector3(0.91, 0.02, -0.9), Vector3(2.1, 1.7, -2.0))
	await _use("6_nhet_mieng_dat", anchors.get_node("Gag4/GagSpot"), Vector3(6.51, 0.02, -2.9), Vector3(5.0, 1.9, -1.6))
	director._bathroom_door(false)
	for i in 3:
		await _use("7_hich_cua_%d" % (i + 1), room.get_node("Extension/BathroomDoor/StuckDoor"), Vector3(5.75, 0.02, -3.45), Vector3(4.3, 1.6, -2.4))
	director._bathroom_door(true)
	director._set_shower_buttons(true)
	await _use("8_bam_nut_co", anchors.get_node("ShowerYes/Choice"), Vector3(5.85, 0.02, -5.3), Vector3(7.2, 1.7, -4.7))
	await _use("9_lau_man", anchors.get_node("ShowerScreen/Wipe"), Vector3(5.85, 0.02, -5.45), Vector3(7.2, 1.7, -4.7), 1.6)
	print("CAPTURE_DONE")
	get_tree().quit()


func _aim_at(target: Vector3) -> void:
	var spot: Vector3 = player.global_position
	player.global_rotation.y = PlayerBody._yaw_to(spot, target)
	var to: Vector3 = target - (spot + Vector3.UP * 1.6)
	(player.get_node("Head") as Node3D).rotation.x = atan2(to.y, Vector2(to.x, to.z).length())


## Stand on `spot` (room), look at `thing`, press E (held for `hold` seconds), shoot as it goes.
func _use(name: String, thing: Interactable, spot: Vector3, eye: Vector3, hold: float = 0.0) -> void:
	player.set_physics_process(false)
	player.global_position = room.to_global(spot)
	player.velocity = Vector3.ZERO
	var target: HandTarget = thing.hand_target()
	var look: Vector3 = target.global_position if target != null else thing.global_position
	if thing is StuckDoor:
		look = (thing.get_node("CollisionShape3D") as Node3D).global_position
	_aim_at(look)
	body._face_view()
	camera.global_position = room.to_global(eye)
	camera.look_at(player.global_position + Vector3.UP * 1.25 + (look - player.global_position) * 0.4)
	lamp.global_position = room.to_global(eye.lerp(spot, 0.5) + Vector3.UP * 0.8)
	camera.make_current()
	player.set_physics_process(true)
	for i in 12:
		await get_tree().physics_frame
	var focus: Variant = player.get("_target")
	var reach: bool = body.can_reach(thing) if target != null else false
	await _shot(name, 0)
	await get_tree().process_frame
	Input.action_press("interact")
	player._physics_process(1.0 / 60.0)
	if hold <= 0.0:
		Input.action_release("interact")
	var started: bool = body.acting
	var frames: int = 0
	var took: Dictionary = {}
	while frames < 300:
		await get_tree().physics_frame
		frames += 1
		if hold > 0.0 and frames >= int(hold * 60.0):
			Input.action_release("interact")
		var time: float = body.get("_time")
		if body.acting and thing is StuckDoor:
			if time >= 0.2 and not took.has(1):
				took[1] = true
				await _shot(name, 1)
			elif time >= PlayerBody.SHOVE_HIT and not took.has(2):
				took[2] = true
				await _shot(name, 2)
		elif body.acting:
			if time >= 0.3 and not took.has(1):
				took[1] = true
				await _shot(name, 1)
			elif time >= 0.47 and not took.has(2):
				took[2] = true
				await _shot(name, 2)
			elif hold > 0.0 and frames == int(hold * 30.0) and not took.has(3):
				took[3] = true
				await _shot(name, 3)
		elif frames > 20 and not took.has(4):
			for i in 15:
				await get_tree().physics_frame
			took[4] = true
			await _shot(name, 4)
			break
	Input.action_release("interact")
	print("CASE %s focus=%s reach=%s started=%s held=%s shots=%s" % [name, focus == thing, reach, started,
		body.holds(body.get("_held_item")) if body.get("_held_item") != null else false, took.keys()])


## Walk a few steps carrying, and look down through his own eyes.
func _walk_and_look(name: String) -> void:
	Input.action_press("move_forward")
	for i in 40:
		await get_tree().physics_frame
	await _shot(name, 5)
	Input.action_release("move_forward")
	for i in 30:
		await get_tree().physics_frame
	# In the room's open middle, facing along it, looking down.
	player.set_physics_process(false)
	player.global_position = room.to_global(Vector3(4.0, 0.02, -2.0))
	player.global_rotation.y = 0.0
	body._face_view()
	player.set_physics_process(true)
	for i in 20:
		await get_tree().physics_frame
	(player.get_node("Head") as Node3D).rotation.x = deg_to_rad(-40.0)
	for i in 5:
		await get_tree().physics_frame
	own.make_current()
	await _shot(name, 6)
	(player.get_node("Head") as Node3D).rotation.x = deg_to_rad(-60.0)
	for i in 5:
		await get_tree().physics_frame
	await _shot(name, 7)
	camera.make_current()


func _shot(case: String, index: int) -> void:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(OUTPUT + "%s_%d.png" % [case, index])
