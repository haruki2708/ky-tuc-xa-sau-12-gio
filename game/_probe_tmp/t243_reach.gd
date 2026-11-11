extends Node
## T-243 probe: from where, and how, Tran Trung reaches chapter 2's hand things.
const CHAPTER := "res://scenes/main/chapter2.tscn"
const RINGS: Array[float] = [1.0, 0.9, 0.8, 0.75, 0.7, 0.65, 0.6, 0.55, 0.5, 0.45, 0.4, 0.35, 0.3, 0.25]
const RING_STEPS := 48

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
	var things: Dictionary = {
		"Carry_rag": anchors.get_node("RagSpot/Carry_rag"),
		"Carry_towel": anchors.get_node("TowelSpot/Carry_towel"),
		"Carry_shirt": anchors.get_node("ShirtSpot/Carry_shirt"),
		"Wipe": anchors.get_node("ShowerScreen/Wipe"),
		"ShowerYes": anchors.get_node("ShowerYes/Choice"),
		"ShowerNo": anchors.get_node("ShowerNo/Choice"),
		"StuckDoor": room.get_node("Extension/BathroomDoor/StuckDoor"),
	}
	for key: String in things:
		var thing: Interactable = things[key]
		thing.enabled = true
		print("%-12s target %s  %s" % [key, room.to_local(thing.hand_target().global_position).snapped(Vector3.ONE * 0.01), _survey(thing)])
	# The mouths: lying, and sitting up talking.
	for state: StringName in [&"", &"talk"]:
		for bed: int in [1, 2, 4]:
			if state != &"":
				director._corpse_state(bed, state)
		for i in 30:
			await get_tree().process_frame
		for bed: int in [1, 2, 4]:
			var spot := anchors.get_node("Gag%d/GagSpot" % bed) as Interactable
			var mark: HandTarget = spot.hand_target()
			spot.enabled = true
			print("Gag%d %-5s mouth %s  %s" % [bed, "lying" if state == &"" else "talk", room.to_local(mark.global_position).snapped(Vector3.ONE * 0.01), _survey(spot)])
	print("PROBE_DONE")
	get_tree().quit()


func _fits(spot: Vector3) -> bool:
	return body._fits(spot)


## The kinds of reach found round `thing` and the furthest spot for each.
func _survey(thing: Interactable) -> String:
	var goal: Vector3 = thing.hand_target().global_position
	var kinds: Dictionary = {}
	var count: int = 0
	for radius: float in RINGS:
		for step: int in RING_STEPS:
			var heading: float = TAU * step / RING_STEPS
			var spot := Vector3(goal.x + radius * sin(heading), 0.02, goal.z + radius * cos(heading))
			if not _fits(spot):
				continue
			body._stand_at(spot, PlayerBody._yaw_to(spot, goal))
			if not body.can_reach(thing):
				continue
			count += 1
			var kind: StringName = body._reach_kind(thing.hand_target(body._reach_from(), body._reach_rank))
			if not kinds.has(kind):
				kinds[kind] = [radius, room.to_local(spot).snapped(Vector3.ONE * 0.01)]
	return "spots %d kinds %s" % [count, kinds]
