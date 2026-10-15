extends Node
## Copy into a temporary scene in game/tests to run; never use Godot --script.

const OUTPUT: String = "res://assets/models/characters/manager/manager_shared.tres"
const SOURCE: PackedScene = preload("res://assets/models/characters/manager/manager_motion_source.glb")

func _ready() -> void:
	var model: Node = SOURCE.instantiate()
	add_child(model)
	var player: AnimationPlayer = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	var library: AnimationLibrary = AnimationLibrary.new()
	for clip: StringName in [&"stand", &"walk", &"ask", &"slash", &"lunge", &"kill"]:
		var animation: Animation = player.get_animation(clip).duplicate(true) as Animation
		animation.resource_name = clip
		for index: int in range(animation.get_track_count() - 1, -1, -1):
			var path: NodePath = animation.track_get_path(index)
			var bone: StringName = path.get_subname(0) if path.get_subname_count() else &""
			var kind: int = animation.track_get_type(index)
			if bone == &"Root" or not kind in [Animation.TYPE_POSITION_3D, Animation.TYPE_ROTATION_3D] or (kind == Animation.TYPE_POSITION_3D and bone != &"Hips"):
				animation.remove_track(index)
				continue
			animation.track_set_path(index, NodePath("%GeneralSkeleton:" + bone))
			for key: int in animation.track_get_key_count(index):
				if kind == Animation.TYPE_POSITION_3D:
					var position: Vector3 = animation.track_get_key_value(index, key)
					# In-place locomotion. Height is normalized by Skeleton3D.motion_scale.
					position.x = 0.0
					position.z = 0.0
					animation.track_set_key_value(index, key, position)
				elif bone in [&"Spine", &"Chest"]:
					var rotation: Quaternion = animation.track_get_key_value(index, key)
					animation.track_set_key_value(index, key, rotation * Quaternion(Vector3.RIGHT, 0.055))
		animation.loop_mode = Animation.LOOP_LINEAR if clip in [&"stand", &"walk", &"lunge", &"slash"] else Animation.LOOP_NONE
		if clip == &"ask":
			var track: int = animation.find_track(NodePath("%GeneralSkeleton:Head"), Animation.TYPE_ROTATION_3D)
			for key: int in animation.track_get_key_count(track):
				var time: float = animation.track_get_key_time(track, key) / animation.length
				var rotation: Quaternion = animation.track_get_key_value(track, key)
				animation.track_set_key_value(track, key, rotation * Quaternion(Vector3.RIGHT, 0.12 + 0.2 * sin(PI * time)))
		if clip in [&"slash", &"kill"]:
			var duration: float = 0.45 if clip == &"slash" else 0.65
			var factor: float = duration / animation.length
			for index: int in animation.get_track_count():
				for key: int in animation.track_get_key_count(index):
					animation.track_set_key_time(index, key, animation.track_get_key_time(index, key) * factor)
			animation.length = duration
			# Close the repeated slash continuously: each director call restarts at zero.
			if clip == &"slash":
				for index: int in animation.get_track_count():
					animation.track_insert_key(index, duration, animation.track_get_key_value(index, 0))
		library.add_animation(clip, animation)
	assert(ResourceSaver.save(library, OUTPUT) == OK)
	print("RESULT: T219 shared library 6 clips PASS")
	model.queue_free()
	App.quit()
