extends Node
## T-243 probe: where a player can stand, look at and reach an upper-bunk corpse's mouth.
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
	GameState.segment = &"r3"
	for bed: int in [1, 2, 4]:
		director._gagged[bed] = false
		director._corpse_state(bed, &"talk")
	for i in 30:
		await get_tree().process_frame
	# Something in the hand, as the gag needs.
	var rag := room.get_node("Anchors/RagSpot/Carry_rag") as CarryItem
	rag.holder = player
	rag.collision_layer = 0
	for grip: HandTarget.Grip in [HandTarget.Grip.GRIP, HandTarget.Grip.PINCH]:
		for bed: int in [1, 4]:
			var spot := room.get_node("Anchors/Gag%d/GagSpot" % bed) as Interactable
			spot.hand_target().grip = grip
			var mouth: Vector3 = spot.hand_target().global_position
			var hits: Dictionary = {}
			var both: Array = []
			var z: float = -0.8
			while z <= 0.81:
				var x: float = -0.8
				while x <= 0.81:
					var at := Vector3(mouth.x + x, 0.02, mouth.z + z)
					x += 0.05
					if not body._fits(at):
						continue
					player.global_position = at
					player.global_rotation.y = PlayerBody._yaw_to(at, mouth)
					var to: Vector3 = mouth - (at + Vector3.UP * 1.6)
					(player.get_node("Head") as Node3D).rotation.x = clampf(atan2(to.y, Vector2(to.x, to.z).length()), deg_to_rad(-85), deg_to_rad(85))
					body._face_view()
					player.call("_update_focus")
					var ray := player.get_node("Head/Camera3D/InteractRay") as RayCast3D
					var collider: Object = ray.get_collider()
					var name: String = (collider as Node).name if collider is Node else "-"
					var reach: bool = body.can_reach(spot)
					var key: String = "%s reach=%s" % [name, reach]
					hits[key] = int(hits.get(key, 0)) + 1
					if collider == spot and reach:
						both.append(room.to_local(at).snapped(Vector3.ONE * 0.01))
				z += 0.05
			print("Gag%d grip %d mouth %s: %s" % [bed, grip, room.to_local(mouth).snapped(Vector3.ONE * 0.01), hits])
			print("   look+reach spots %d: %s" % [both.size(), both.slice(0, 12)])
	print("PROBE_DONE")
	get_tree().quit()
