class_name ManagerBody
extends Node3D
## Visual body for DormManager.body_scene (T-219): the Tripo model, its clips and props.
## manager.gd finds the AnimationPlayer, BladeTip and LeftArm (door reach) by name. On its own
## (chapter 2's mirror flash) the body stands breathing instead of in its bind pose.

## Clips that repeat while their state lasts (ask is Tripo "wait", hand on hip, D-120); kill
## restarts per call. T-224 (D-134): slash loops too, one chop per cycle, instead of snapping
## back to its start at each chop.
const LOOPING: Array[StringName] = [&"stand", &"walk", &"ask", &"lunge", &"slash"]
## T-268 (motion pilot, D-189): &"mx" puts the Mixamo clips packed for the manager (MX_PATH, baked
## onto his own skeleton by art_source/graphics_upgrade/mixamo/) over his Tripo ones of the same
## names (the pilot packs walk and slash). Set before the body's _ready. Off (&"") by default.
static var motion: StringName = &""
const MX_MOTION: StringName = &"mx"
const MX_PATH := "res://assets/models/characters/mixamo/manager_mixamo.res"


func _ready() -> void:
	for node: Node in find_children("*", "AnimationPlayer", true, false):
		var player: AnimationPlayer = node as AnimationPlayer
		if motion == MX_MOTION:
			_use_mx_clips(player)
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


## A copy of the model's own library with the packed clips over it (the imported library and the
## loaded one are both shared, so neither is changed).
func _use_mx_clips(player: AnimationPlayer) -> void:
	var packed := load(MX_PATH) as AnimationLibrary
	if packed == null or not player.has_animation_library(&""):
		push_warning("T-268 motion pilot: no %s, keeping the Tripo clips" % MX_PATH)
		return
	var own := player.get_animation_library(&"")
	var library := AnimationLibrary.new()
	for clip: StringName in own.get_animation_list():
		library.add_animation(clip, own.get_animation(clip))
	for clip: StringName in packed.get_animation_list():
		library.add_animation(clip, packed.get_animation(clip).duplicate() as Animation)
	player.remove_animation_library(&"")
	player.add_animation_library(&"", library)
