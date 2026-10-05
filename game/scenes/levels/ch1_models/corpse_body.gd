extends Node3D
## Visual poses only. Unseen poser and chapter rules remain with Lane A/core.
const POSES: Array[StringName] = [&"dead_a", &"dead_b", &"head_turn", &"eyes_open", &"sit_up"]
const STATES: Array[StringName] = [&"sit_play", &"talk", &"gagged", &"mumble", &"fall", &"revive", &"lunge", &"slump"]
const RAG := preload("res://scenes/levels/ch1_models/rag.tscn")
@export var initial_state: StringName = &""
## +1 = left bunk facing +X; -1 = right bunk facing -X; 0 = model default.
@export_range(-1.0, 1.0, 1.0) var seat_side: float = 0.0
var current_pose: StringName = &"dead_a"
var blood_visible: bool = false
var current_state: StringName = &""
var gagged: bool = false
var _time: float = 0.0
var _gag: Node3D
var _look_target: Vector3
var _has_target: bool = false


func _ready() -> void:
	add_to_group(&"ch2_corpse")
	_gag = RAG.instantiate() as Node3D
	_gag.name = "Gag"
	_gag.position = Vector3(0, .005, -.115)
	_gag.rotation.x = PI / 2.0
	_gag.scale = Vector3(.65, 1.5, .40)
	$Rig/Hips/Chest/Head.add_child(_gag)
	var requested := current_state if current_state != &"" else initial_state
	set_pose(current_pose)
	set_blood_visible(blood_visible)
	if requested != &"":
		set_state(requested)


func set_pose(pose: StringName) -> bool:
	if pose not in POSES:
		return false
	current_pose = pose
	current_state = &""
	_has_target = false
	gagged = false
	set_process(false)
	if is_node_ready():
		_gag.visible = false
		$Rig.rotation = Vector3(PI / 2.0, 0, 0)
		$Rig/Hips/LeftLeg/Knee.rotation = Vector3.ZERO
		$Rig/Hips/RightLeg/Knee.rotation = Vector3.ZERO
		$Rig/Hips/Chest/Head/Mouth.scale = Vector3.ONE
		var player := $AnimationPlayer as AnimationPlayer
		player.play(pose)
		player.advance(0.0)
		player.pause()
	return true


func set_state(state: StringName) -> bool:
	if state not in STATES:
		return false
	current_state = state
	_time = 0.0
	if state in [&"gagged", &"mumble"]:
		gagged = true
	elif state in [&"sit_play", &"talk"]:
		gagged = false
	if not is_node_ready():
		return true
	$AnimationPlayer.pause()
	set_process(true)
	_process(0.0)
	return true


func set_gagged(value: bool) -> void:
	# Independent visual channel: survives fall/revive/slump. No inventory logic.
	gagged = value
	if is_node_ready():
		_gag.visible = value


func look_at_point(point: Vector3) -> void:
	# World-space target, including when the whole room is moved/rotated.
	if point.is_finite():
		_look_target = point
		_has_target = true
		if is_node_ready() and current_state != &"":
			_process(0.0)


func _process(delta: float) -> void:
	if current_state == &"":
		return
	_time += maxf(delta, 0.0)
	var rig := $Rig as Node3D
	var chest := $Rig/Hips/Chest as Node3D
	var head := $Rig/Hips/Chest/Head as Node3D
	var mouth := head.get_node("Mouth") as Node3D
	var side := seat_side
	if is_zero_approx(side):
		side = -1.0 if scene_file_path.contains("corpse_dat") else 1.0
	# Sit on the long mattress edge; knees hang into the aisle. The slight lean
	# puts the lower-bunk head beyond the upper board instead of through it.
	rig.position = Vector3(side * 1.25, .145, 0)
	rig.rotation = Vector3(PI / 2.0, -side * PI / 2.0, 0)
	chest.rotation = Vector3(-PI / 2.0 - .25, 0, 0)
	head.rotation = Vector3(.08, 0, .12)
	$Rig/Hips/Chest/LeftArm.rotation = Vector3(-.30, 0, -.12)
	$Rig/Hips/Chest/RightArm.rotation = Vector3(-.30, 0, .12)
	$Rig/Hips/LeftLeg.rotation = Vector3.ZERO
	$Rig/Hips/RightLeg.rotation = Vector3.ZERO
	$Rig/Hips/LeftLeg/Knee.rotation.x = -PI / 2.0
	$Rig/Hips/RightLeg/Knee.rotation.x = -PI / 2.0
	$Rig/Hips/Chest/Head/Eyes.visible = true
	mouth.scale = Vector3.ONE
	_gag.visible = gagged
	match current_state:
		&"talk":
			mouth.scale.y = 1.0 + 3.5 * absf(sin(_time * 19.0))
			head.rotation.z += sin(_time * 8.0) * .035
		&"mumble":
			head.rotation.z += sin(_time * 27.0) * .09
			head.rotation.x += sin(_time * 19.0) * .07
		&"fall", &"slump":
			var progress := smoothstep(0.0, .40 if current_state == &"fall" else .65, _time)
			chest.rotation.x = lerpf(-PI / 2.0 - .25, -.20, progress)
			head.rotation.z = lerpf(.12, .65, progress)
		&"revive":
			chest.rotation.x = lerpf(-.20, -PI / 2.0 - .25, smoothstep(0.0, .22, _time))
		&"lunge":
			var progress := smoothstep(0.0, .28, _time)
			rig.position.x += side * .65 * progress
			chest.rotation.x -= .45 * progress
			$Rig/Hips/Chest/LeftArm.rotation.x = (PI / 2.0 + .70) * progress
			$Rig/Hips/Chest/RightArm.rotation.x = (PI / 2.0 + .70) * progress
			mouth.scale.y = 4.0
	if _has_target:
		var direction := chest.global_basis.inverse() * (_look_target - head.global_position)
		if direction.length_squared() > .0001:
			head.rotation.y = clampf(atan2(-direction.x, -direction.z), -1.4, 1.4)
			head.rotation.x += clampf(atan2(direction.y, Vector2(direction.x, direction.z).length()), -.45, .45)


func set_blood_visible(value: bool) -> void:
	blood_visible = value
	if is_node_ready():
		$Rig/Hips/Chest/Blood.visible = value
