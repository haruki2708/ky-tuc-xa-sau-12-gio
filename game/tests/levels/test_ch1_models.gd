extends TestCase

const BASE := "res://scenes/levels/ch1_models/"
const MODELS := ["manager_body", "corpse_phuc", "corpse_viet", "corpse_dat", "charger", "router", "dat_notebook", "phone_viewmodel", "bed_debris", "rag"]
var fixtures: Array[Node] = []


func spawn(model: String) -> Node3D:
	var node := (load(BASE + model + ".tscn") as PackedScene).instantiate() as Node3D
	fixtures.append(node)
	tree.root.add_child(node)
	return node


func after_each() -> void:
	for node in fixtures:
		node.queue_free()
	fixtures.clear()
	await wait_frames(2)
	await tree.create_timer(.4).timeout


func test_mesh_budgets_materials_and_texture_imports() -> void:
	for model in MODELS:
		var node := spawn(model)
		var count := 0
		for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
			count += mesh.mesh.get_faces().size() / 3
			var material := mesh.get_active_material(0)
			assert_true(material is ShaderMaterial or mesh.name in ["Screen", "LED", "NetworkLED"], model + " PS1 surface")
		assert_true(count > 20 and count < (1500 if model.begins_with("corpse") or model == "manager_body" else 500), "%s has %d triangles" % [model, count])
		print("MODEL_TRIANGLES: %s %d" % [model,count])
	for file in DirAccess.get_files_at("res://assets/textures/ch1_models"):
		if not file.ends_with(".png"):
			continue
		var path := "res://assets/textures/ch1_models/" + file
		assert_eq((load(path) as Texture2D).get_size(),Vector2(128,128))
		var cfg := ConfigFile.new()
		assert_eq(cfg.load(path + ".import"),OK)
		assert_eq(cfg.get_value("params","compress/mode"),0)
		assert_eq(cfg.get_value("params","mipmaps/generate"),false)


func sample(player: AnimationPlayer, clip: StringName, at: float) -> void:
	player.play(clip)
	player.seek(at,true)
	player.pause()


func test_manager_clips_move_blade_and_return_to_rest() -> void:
	var manager := spawn("manager_body")
	var player := manager.get_node("AnimationPlayer") as AnimationPlayer
	var tip := manager.get_node("BladeTip") as Marker3D
	for clip in ["walk","stand","ask","slash","lunge","kill"]:
		assert_true(player.has_animation(clip),clip)
		var animation := player.get_animation(clip)
		for track in animation.get_track_count():
			var path := String(animation.track_get_path(track)).get_slice(":",0)
			assert_not_null(manager.get_node_or_null(path),clip+" valid target "+path)
	sample(player,&"stand",0)
	tip._process(0)
	assert_true(absf(tip.position.y-.015)<.002,"knife tip touches floor")
	for time in [.0,.4,.8,1.2,1.6]:
		sample(player,&"walk",time)
		tip._process(0)
		assert_true(tip.position.y >= 0 and tip.position.y < .03,"blade stays on floor throughout walk")
	sample(player,&"slash",.4)
	tip._process(0)
	assert_true(tip.position.y > 1.5,"blade lifts overhead")
	var raised := tip.position
	sample(player,&"slash",.77)
	tip._process(0)
	assert_true(tip.position.distance_to(raised) > .5,"downstroke moves blade")
	sample(player,&"slash",1.2)
	tip._process(0)
	assert_true(absf(tip.position.y-.015)<.002,"clip repeat begins from same rest")
	sample(player,&"lunge",.35)
	assert_true(manager.get_node("Rig").position.z < -.2)
	sample(player,&"stand",0)
	assert_eq(manager.get_node("Rig").position,Vector3.ZERO,"switching clips resets displacement")


func test_corpse_poses_are_distinct_reversible_and_blood_independent() -> void:
	for who in ["phuc","viet","dat"]:
		var body := spawn("corpse_"+who)
		var head := body.get_node("Rig/Hips/Chest/Head") as Node3D
		var eyes := head.get_node("Eyes") as Node3D
		var arm := body.get_node("Rig/Hips/Chest/" + ("LeftArm" if who == "dat" else "RightArm")) as Node3D
		assert_false(eyes.visible)
		assert_true(body.set_pose(&"dead_b"))
		assert_true(arm.rotation.length() > 1)
		body.set_pose(&"head_turn")
		assert_true(head.rotation.y > .5 if who == "dat" else head.rotation.y < -.5)
		body.set_pose(&"eyes_open")
		assert_true(eyes.visible)
		body.set_blood_visible(true)
		body.set_pose(&"sit_up")
		assert_true(body.get_node("Rig/Hips/Chest").rotation.x < -1)
		assert_true(body.get_node("Rig/Hips/Chest/Blood").visible)
		body.set_pose(&"dead_a")
		assert_eq(arm.rotation,Vector3.ZERO)
		assert_eq(head.rotation,Vector3.ZERO)
		assert_false(eyes.visible)
		assert_false(body.set_pose(&"missing"))
		body.set_blood_visible(false)
		assert_false(body.get_node("Rig/Hips/Chest/Blood").visible)


func test_router_notebook_and_screen_are_independent_instances() -> void:
	var router := spawn("router")
	router.set_led(false)
	router._process(.1)
	assert_false(router.get_node("LED").visible)
	router.set_led(true)
	assert_true(router.get_node("LED").visible)
	router._process(.9)
	assert_false(router.get_node("LED").visible)
	router._process(.2)
	assert_true(router.get_node("LED").visible)
	var notebook := spawn("dat_notebook")
	notebook.set_content("QA", "Đạt", "__/__/____")
	assert_eq(notebook.get_node("BirthDate").text,"__/__/____")
	assert_eq(notebook.get_node("Name").text,"Đạt")
	var other_note := spawn("dat_notebook")
	assert_eq(other_note.get_node("BirthDate").text,"")
	var phone := spawn("phone_viewmodel")
	var other := spawn("phone_viewmodel")
	var texture := GradientTexture2D.new()
	phone.set_screen_texture(texture)
	assert_eq(phone.get_node("Screen").get_active_material(0).albedo_texture,texture)
	assert_eq(other.get_node("Screen").get_active_material(0).albedo_texture,null)
	phone.set_screen_texture(null)
	assert_eq(phone.get_node("Screen").get_active_material(0).albedo_texture,null)


func test_room_placement_clean_reset_and_no_extra_colliders() -> void:
	var room := (load("res://scenes/levels/floor4/room_407.tscn") as PackedScene).instantiate() as Node3D
	fixtures.append(room)
	tree.root.add_child(room)
	for entry in [[1,"A","Phuc"],[2,"A","Viet"],[4,"B","Dat"]]:
		var body := room.get_node("Anchors/Corpse%d/Body" % entry[0]) as Node3D
		assert_eq(body.position,Vector3.ZERO,"body origin matches mattress anchor")
		assert_false(room.get_node("Bunk%s/Sleeper_%s" % [entry[1],entry[2]]).visible)
		assert_true(body.find_children("*","CollisionObject3D",true,false).is_empty())
		assert_false(body.blood_visible)
	room.set_blood_stage(2)
	assert_true(room.get_node("Anchors/Corpse1/Body").blood_visible)
	room.set_blood_stage(0)
	assert_false(room.get_node("Anchors/Corpse1/Body").blood_visible)
	assert_not_null(room.get_node("Anchors/DatLocker/Charger"))
	assert_true(room.get_node("Anchors/DatLocker/Charger").global_position.x > 3.5,"charger inside east locker")
	assert_not_null(room.get_node("Anchors/Router/Model"))
	assert_false(room.get_node("Details/Router").visible)
	assert_false(room.get_node("Details/Dat/Notebook").visible)
	room.set_slashed(1)
	assert_true(room.get_node("Details/Debris/RichDebris").is_visible_in_tree())
	room.set_slashed(0)
	assert_false(room.get_node("Details/Debris/RichDebris").is_visible_in_tree())
