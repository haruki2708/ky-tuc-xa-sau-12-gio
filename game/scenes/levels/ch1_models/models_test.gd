extends Node3D
## F6 visual showroom. Arrows cycle assets; 1..6 select clips/poses.
const MODELS := ["manager_body", "corpse_phuc", "corpse_viet", "corpse_dat", "charger", "router", "dat_notebook", "phone_viewmodel", "bed_debris", "rag"]
var subject: Node3D
var index: int = 0


func _ready() -> void:
	show_model(0)


func show_model(value: int) -> void:
	index = posmod(value,MODELS.size())
	if subject:
		remove_child(subject)
		subject.queue_free()
	subject = (load("res://scenes/levels/ch1_models/" + MODELS[index] + ".tscn") as PackedScene).instantiate()
	add_child(subject)
	var eye := Vector3(2.4,1.6,-3.5)
	var target := Vector3(0,.95,0)
	var camera := $Camera3D as Camera3D
	camera.near = .01
	if index in [1,2,3]:
		eye = Vector3(1.4,1.6,1.5)
		target = Vector3(0,.15,0)
	elif index >= 4:
		eye = Vector3(.25,.28,-.35)
		target = Vector3(0,.04,0)
	if index == 6:
		eye = Vector3(0,.29,.21)
		target = Vector3(0,0,0)
		subject.set_content(tr("DOC_CH1_DAT_CARD_TITLE"),tr("DOC_CH1_DAT_CARD_1"),tr("DOC_CH1_DAT_CARD_2"))
	elif index == 5:
		eye = Vector3(.40,.45,-.60)
		target = Vector3(0,.14,0)
	elif index == 7:
		eye = Vector3(.09,.04,-.25)
		target = Vector3.ZERO
		$Stage.visible = false
	else:
		$Stage.visible = true
	if index in [8,9]:
		eye = Vector3(.48,.65,.5)
	camera.position = eye
	camera.look_at(target)


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_RIGHT:
		show_model(index+1)
	elif event.keycode == KEY_LEFT:
		show_model(index-1)
	elif event.keycode >= KEY_1 and event.keycode <= KEY_6:
		var clips := ["stand","walk","ask","slash","lunge","kill"] if index == 0 else ["dead_a","dead_b","head_turn","eyes_open","sit_up"]
		var clip := int(event.keycode-KEY_1)
		if clip < clips.size() and subject.has_node("AnimationPlayer"):
			if index == 0:
				subject.get_node("AnimationPlayer").play(clips[clip])
			else:
				subject.set_pose(clips[clip])
