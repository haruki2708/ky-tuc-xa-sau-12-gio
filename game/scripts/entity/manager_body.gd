extends Node3D
## Visual body for DormManager.body_scene (T-219): the Tripo model, its clips and props.
## manager.gd finds the AnimationPlayer, BladeTip and LeftArm (door reach) by name. On its own
## (chapter 2's mirror flash) the body stands breathing instead of in its bind pose.

## Clips that repeat while their state lasts (ask is Tripo "wait", hand on hip, D-120); kill
## restarts per call. T-224 (D-134): slash loops too, one chop per cycle, instead of snapping
## back to its start at each chop.
const LOOPING: Array[StringName] = [&"stand", &"walk", &"ask", &"lunge", &"slash"]


func _ready() -> void:
	for node: Node in find_children("*", "AnimationPlayer", true, false):
		var player: AnimationPlayer = node as AnimationPlayer
		for clip: StringName in LOOPING:
			if player.has_animation(clip):
				player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
		if not player.is_playing() and player.has_animation(&"stand"):
			player.play(&"stand")
		# T-224: the right wrist keeps its "stand" grip on the cleaver through every clip.
		var lock := find_child("RightWristLock", true, false) as BoneLockModifier
		if lock != null and player.has_animation(&"stand"):
			var grip: Variant = BoneLockModifier.clip_rotation(player.get_animation(&"stand"), lock.bone)
			if grip is Quaternion:
				lock.locked_rotation = grip
