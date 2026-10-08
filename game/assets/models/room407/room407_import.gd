@tool
extends "res://assets/models/kit/kit_import.gd"


func _post_import(scene: Node) -> Object:
	super._post_import(scene)
	if get_source_file().get_file().get_basename() == "bunk_trung":
		var body := StaticBody3D.new()
		body.name = "WorldCollision"
		body.collision_layer = 1
		body.collision_mask = 0
		scene.add_child(body)
		body.owner = scene
		# Match build_kit.py's frame, leaving the aisle above each mattress open.
		for x: float in [-0.43, 0.43]:
			for z: float in [-0.98, 0.98]:
				_add_box(scene, body, "Post_%s_%s" % [x, z], Vector3(x, .85, z), Vector3(.04, 1.7, .04))
		for y: float in [0.34, 1.11]:
			_add_box(scene, body, "Board_%s" % y, Vector3(0, y + .028, 0), Vector3(.82, .025, 1.90))
			for x: float in [-0.43, 0.43]:
				_add_box(scene, body, "Side_%s_%s" % [y, x], Vector3(x, y, 0), Vector3(.04, .07, 1.96))
			for z: float in [-0.96, 0.96]:
				_add_box(scene, body, "End_%s_%s" % [y, z], Vector3(0, y, z), Vector3(.84, .07, .04))
	return scene
