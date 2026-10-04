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
		_add_box(scene, body, "Bounds", Vector3(0, .85, 0), Vector3(.9, 1.7, 2.0))
	return scene
