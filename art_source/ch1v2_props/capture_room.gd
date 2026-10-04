extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	root.size = Vector2i(1280,720)
	root.content_scale_size = root.size
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var scene := load("res://scenes/levels/room407/room407_test.tscn").instantiate() as Node3D
	root.add_child(scene)
	var room := scene.get_node("Playtest/Floor4/Room407") as Node3D
	var player := scene.get_node("Playtest/Player") as CharacterBody3D
	player.global_position = Vector3(32,0,-1)
	player.set_process_unhandled_input(false)
	var camera := Camera3D.new()
	camera.near = .012
	camera.fov = 70
	scene.add_child(camera)
	camera.make_current()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var destination := ProjectSettings.globalize_path("res://../art_source/ch1v2_props/previews")
	DirAccess.make_dir_recursive_absolute(destination)
	var views: Array[Dictionary] = []
	var shots: Array = [
		["room_wide",Vector3(2,1.6,-.8),Vector3(5,1,-4)],
		["room_beds",Vector3(4,1.6,-5),Vector3(4,1.1,-2.2)],
		["bathroom",Vector3(6.85,1.55,-4.45),Vector3(6.65,1.1,-6.5)],
		["balcony",Vector3(2.8,1.6,-6.4),Vector3(2.8,1.2,-8.25)],
		["under_desk_cables",Vector3(4.55,.32,-1.8),Vector3(4.65,.16,-.65)],
		["floor_wiring_overview",Vector3(2.7,.32,-3.7),Vector3(3,.16,-1.0)],
		["power_strip",Vector3(1.43,.27,-1.95),Vector3(.95,.10,-2.35)],
		["power_strip_tripped",Vector3(1.43,.27,-1.95),Vector3(.95,.10,-2.35)],
		["router",Vector3(4.6,1.65,-1),Vector3(4.6,1.57,-.17)],
		["viet_locker_open",Vector3(1.2,1.0,-1.4),Vector3(.3,.85,-1.25)],
		["phuc_mattress_lifted",Vector3(1.65,1.65,-2.5),Vector3(.65,1.2,-3.1)],
		["trash_paper",Vector3(3.1,.58,-4.95),Vector3(2.9,.16,-5.4)],
		["team_photo",Vector3(7.0,2.15,-1.1),Vector3(7.67,2.08,-1.3)],
		["guitar_songbook",Vector3(3.9,1.35,-1.4),Vector3(4.05,.82,-.85)],
		["phuc_card",Vector3(.85,2.3,-1.5),Vector3(.45,2.055,-1.86)],
		["kitchen",Vector3(5.55,1.5,-2.2),Vector3(4.9,.8,-3.3)],
		["desk_lamp_off",Vector3(2,1.55,-3.5),Vector3(1.8,.8,-4.55)],
		["door_handle",Vector3(2.6,1.25,-.8),Vector3(2.32,1.05,-.08)],
		["blue_plugged",Vector3(5.5,.7,-.8),Vector3(5.45,.35,-.12)]
	]
	room.set_bathroom_door_open(true)
	room.get_node("Anchors/Router/Model").set_power(true)
	room.get_node("Anchors/Router/Model").set_network(&"red")
	for entry: Array in shots:
		var name: String = entry[0]
		camera.fov = 95 if name == "floor_wiring_overview" else 70
		var strip := room.get_node("Anchors/PowerStrip")
		strip.set_tripped(name == "power_strip_tripped")
		if name != "power_strip_tripped":
			strip.set_switch(1,true)
			strip.set_switch(2,true)
		room.get_node("Anchors/VietLocker").set_open(name == "viet_locker_open")
		room.get_node("Anchors/PhucMattress").set_lifted(name == "phuc_mattress_lifted")
		room.set_blood_stage(2 if name == "phuc_mattress_lifted" else 0)
		room.set_desk_lamp(name != "desk_lamp_off")
		room.set_plugged(&"blue",name == "blue_plugged")
		camera.global_position = room.to_global(entry[1])
		camera.look_at(room.to_global(entry[2]))
		for i in range(90):
			await process_frame
		await RenderingServer.frame_post_draw
		var times: Array[float] = []
		var start := Time.get_ticks_usec()
		var last := start
		for frame in range(240):
			await process_frame
			await RenderingServer.frame_post_draw
			var now := Time.get_ticks_usec()
			times.append(float(now-last)/1000)
			last = now
		var fps := 240000000.0 / float(Time.get_ticks_usec()-start)
		times.sort()
		views.append({"view":name,"mean_fps":fps,"p95_ms":times[227]})
		var error := root.get_texture().get_image().save_png(destination.path_join(name+".png"))
		if error != OK:
			push_error("Preview save failed")
			root.get_node("App").quit(1)
			return
		print("T162_PREVIEW: ",name," FPS ",fps)
	var file := FileAccess.open(destination.path_join("performance.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"godot":Engine.get_version_info().string,"cpu":OS.get_processor_name(),"gpu":RenderingServer.get_video_adapter_name(),"resolution":"1280x720","ps1_strength":1,"warmup_frames":90,"sample_frames":240,"vsync":false,"fixed_fps":false,"scenario":"Full floor4, Player physics/HUD/audio active, static preview camera","views":views},"\t")+"\n")
	file.close()
	print("T162_CAPTURE_RESULT: PASS ",views.size()," views")
	root.get_node("App").quit()
