extends SceneTree

var destination: String
var shots: int = 0


func _initialize() -> void:
	call_deferred("capture")


func save_shot(name: String) -> void:
	for i in range(12):
		await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png(destination.path_join(name+".png"))
	if error != OK:
		push_error("Capture failed: "+name)
		root.get_node("App").quit(1)
	shots += 1
	print("CH1_MODEL_PREVIEW: ", name)


func capture() -> void:
	root.size = Vector2i(1280,720)
	root.content_scale_size = root.size
	destination = ProjectSettings.globalize_path("res://../art_source/ch1_models/previews")
	DirAccess.make_dir_recursive_absolute(destination)
	var showroom := load("res://scenes/levels/ch1_models/models_test.tscn").instantiate() as Node3D
	root.add_child(showroom)
	var report: Dictionary = {}
	for i in range(showroom.MODELS.size()):
		showroom.show_model(i)
		var model: Node3D = showroom.subject
		var triangles := 0
		for mesh: MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
			triangles += mesh.mesh.get_faces().size()/3
		report[showroom.MODELS[i]] = {"triangles":triangles}
		await save_shot(showroom.MODELS[i])
		if i == 0:
			var player := model.get_node("AnimationPlayer") as AnimationPlayer
			showroom.get_node("Camera3D").position = Vector3(2.8,1.9,-4.5)
			showroom.get_node("Camera3D").look_at(Vector3(0,1.30,0))
			for clip in ["walk","ask","slash","lunge","kill"]:
				player.play(clip)
				player.seek(.4 if clip != "kill" else .25,true)
				player.pause()
				await save_shot("manager_"+clip)
		elif i in [1,2,3]:
			model.set_pose(&"eyes_open")
			model.set_blood_visible(true)
			await save_shot(showroom.MODELS[i]+"_eyes_open")
			model.set_pose(&"sit_up")
			showroom.get_node("Camera3D").position = Vector3(1.5,1.4,-1.6)
			showroom.get_node("Camera3D").look_at(Vector3(0,.5,.05))
			await save_shot(showroom.MODELS[i]+"_sit_up")
	showroom.queue_free()
	await process_frame
	var scene := load("res://scenes/levels/room407/room407_test.tscn").instantiate() as Node3D
	root.add_child(scene)
	var room := scene.get_node("Playtest/Floor4/Room407") as Node3D
	var player := scene.get_node("Playtest/Player") as CharacterBody3D
	player.set_process_unhandled_input(false)
	player.global_position = Vector3(32,0,-.9)
	var camera := player.get_node("Head/Camera3D") as Camera3D
	camera.look_at(Vector3(32,1.1,-3.15))
	room.set_blood_stage(2)
	for number in [1,2,4]:
		room.get_node("Anchors/Corpse%d/Body" % number).set_pose(&"eyes_open")
	await save_shot("room_all_corpses")
	for number in [1,2,4]:
		var anchor := room.get_node("Anchors/Bunks/Bunk%d/View" % number) as Node3D
		camera.global_transform = anchor.global_transform
		await save_shot("bed_view_%d" % number)
	var file := FileAccess.open(destination.path_join("manifest.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"models":report,"godot":Engine.get_version_info().string,"resolution":"1280x720","ps1_strength":1,"shots":shots},"\t")+"\n")
	file.close()
	print("CH1_MODELS_CAPTURE_RESULT: PASS ",shots," views")
	root.get_node("App").quit()
