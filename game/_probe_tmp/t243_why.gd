extends Node
## T-243 probe: why the towel, the shirt and the upper-bunk mouths are out of reach.
const CHAPTER := "res://scenes/main/chapter2.tscn"

var room: Node3D
var player: CharacterBody3D
var body: PlayerBody
var director: Chapter2Director


func _ready() -> void:
	get_tree().create_timer(300.0, true, false, true).timeout.connect(func() -> void:
		print("PROBE_TIMEOUT")
		get_tree().quit(1))
	AudioServer.set_bus_mute(0, true)
	var chapter := (load(CHAPTER) as PackedScene).instantiate() as Node3D
	director = chapter.get_node("Chapter2Director") as Chapter2Director
	director.auto_start = false
	add_child(chapter)
	for i in 4:
		await get_tree().physics_frame
	room = chapter.get_node("Floor4/Room407")
	player = chapter.get_node("Player")
	body = player.get("body")
	player.set_physics_process(false)
	var anchors := room.get_node("Anchors")
	print("standing shoulder y ", body._standing_shoulder().y, " lifted ", body._lifted_shoulder().y, " TIPTOE ", PlayerBody.TIPTOE, " arm ", body.arm_reach * body._scale(), " fingers ", body.finger_reach * body._scale())
	for bed: int in [1, 4]:
		director._corpse_state(bed, &"talk")
	for i in 30:
		await get_tree().process_frame
	var goals: Dictionary = {
		"towel": anchors.get_node("TowelSpot/Carry_towel").hand_target().global_position,
		"shirt": anchors.get_node("ShirtSpot/Carry_shirt").hand_target().global_position,
		"gag1_talk": anchors.get_node("Gag1/GagSpot").global_position,
		"gag4_talk": anchors.get_node("Gag4/GagSpot").global_position,
	}
	for key: String in goals:
		var goal: Vector3 = goals[key]
		print("== ", key, " goal ", room.to_local(goal).snapped(Vector3.ONE * 0.01))
		# Grid of spots round it: what stops each.
		var reasons: Dictionary = {}
		var best: Array = []
		var z: float = -1.2
		while z <= 1.21:
			var x: float = -1.2
			while x <= 1.21:
				var spot := Vector3(goal.x + x, 0.02, goal.z + z)
				x += 0.1
				var flat: float = Vector2(x - 0.1, z).length()
				if flat > 1.2:
					continue
				if not body._fits(spot):
					reasons["no fit"] = int(reasons.get("no fit", 0)) + 1
					continue
				body._stand_at(spot, PlayerBody._yaw_to(spot, goal))
				var rise: float = body._rise_for(goal, HandTarget.Grip.PINCH)
				var up_lean: float = body._up_lean(goal, HandTarget.Grip.PINCH)
				var lean: float = body._lean_for(&"near", goal, body.finger_reach, PlayerBody.MAX_BEND)
				var kind: StringName = body._judge_goal(goal, HandTarget.Grip.PINCH)
				var reason: String = "ok " + String(kind) if kind != &"" else ("rise %.2f" % rise if is_finite(rise) else "too far sideways")
				var key2: String = reason.split(" ")[0] + (" " + reason.split(" ")[1] if reason.begins_with("ok") else "")
				reasons[key2] = int(reasons.get(key2, 0)) + 1
				if best.is_empty() or (is_finite(rise) and rise < best[0]):
					best = [rise, room.to_local(spot).snapped(Vector3.ONE * 0.01), up_lean, lean, flat]
			z += 0.1
		print("   reasons ", reasons)
		print("   least rise %s at %s (up lean %s, near lean %s, flat %.2f)" % best)
	print("PROBE_DONE")
	get_tree().quit()
