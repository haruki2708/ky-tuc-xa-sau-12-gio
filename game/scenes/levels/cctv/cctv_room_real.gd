extends Node3D
## T-267 (D-166, D-188) wave 10: one CCTV room of cctv_set.tscn (this node is Room<n>/Real) and the corridor before its
## door, in building B's style, furnished as room 407 is (D2: room 407's Tripo bunks, lockers, desk, stool, fan,
## bedding and nets, as T-255's rooms). Visual only: every PS1 mesh of the room hides (visible = false, never freed);
## no collider, light, camera, marker, label, character or occluder is moved, added or renamed (card section 4). The
## props stand where the PS1 set has them; the things that tell the rooms apart stay in their places (102: shirt,
## slippers, poster; 306: towel, bucket, things on the desk; 209: the row of books, the laundry; 106: the desk lamp
## round DeskLamp's light, things on the desk; 310: the three bodies, unchanged).
## No set_state() here: Chapter2Director._cctv_310 calls it on every node under Room310 that has one.
## - cctv_room.glb / cctv_hall.glb (art_source/graphics_upgrade/realistic_map/wave10/build_wave10.py): shell, W2 back
##   wall (balcony door, window), door frame and the green boards behind NumberInside / NumberOutside, the night lamp;
##   the corridor (H1) with the balustrade on floors 2-3 or the parapet on floor 1, the batten, the night outside.
## - wave 2's room door leaf stands open into the room along the doorway's east jamb.
## - The nets keep each PS1 net's state: closed, or open (bunk A's upper deck, where the victim lies:
##   cctv_net_upper_open.glb, room 407's builder). Room 310 has none.
## Every mesh draws only within VISIBLE_TO metres of a camera: the feeds' cameras stand inside the set, the player is
## always more than 60 m above it, so the set never costs the player's view (nor its shadow passes) anything.

const P := "res://assets/models/graphics_pilot/"
const W10 := "res://assets/models/graphics_pilot/realistic_map/wave10/"
const VISIBLE_TO := 40.0
## Under Room<n>, the nodes whose meshes stay: this one and the people (the manager comes later, at run time).
const KEEP: Array[String] = ["Real", "Victim", "Corpse1", "Corpse2", "Corpse4"]
const FLOOR_ONE: Array[String] = ["102", "106"]
## [model under P, position, yaw] in Room<n> metres. Bunks, lockers, desk, stool, fan where the PS1 ones stand (the
## lockers against the walls as T-255's, their doors to the room), the bedding as T-255's on 407's bunk frame.
const FURNITURE := [
	["room407_batch2/bunk_frame.glb", Vector3(0.65, 0.0, -3.0), 0.0],
	["room407_batch2/bunk_frame.glb", Vector3(3.35, 0.0, -3.0), 0.0],
	["room407_batch2/locker_closed.glb", Vector3(0.406, 0.0, -0.45), -90.0],
	["room407_batch2/locker_closed.glb", Vector3(0.406, 0.0, -1.25), -90.0],
	["room407_batch2/locker_closed.glb", Vector3(3.594, 0.0, -0.45), 90.0],
	["room407_batch2/locker_closed.glb", Vector3(3.594, 0.0, -1.25), 90.0],
	["room407_batch2/desk.glb", Vector3(1.8, 0.0, -4.55), 180.0],
	["room407_batch1/stool.glb", Vector3(2.95, 0.0, -4.5), 0.0],
	["room407_furnished/ceiling_fan_split.glb", Vector3(2.0, 3.0, -2.5), 0.0],
	["room407_furnished/bunk_mattress.glb", Vector3(0.65, 0.38, -3.0), 0.0],
	["room407_furnished/bunk_mattress.glb", Vector3(0.65, 1.15, -3.0), 0.0],
	["room407_furnished/bunk_mattress.glb", Vector3(3.35, 0.38, -3.0), 0.0],
	["room407_furnished/bunk_mattress.glb", Vector3(3.35, 1.15, -3.0), 0.0],
	["room407_batch2/pillow.glb", Vector3(0.65, 0.43, -2.33), 4.0],
	["room407_batch2/pillow.glb", Vector3(0.65, 1.2, -2.33), -3.0],
	["room407_batch2/pillow.glb", Vector3(3.35, 0.43, -2.33), 2.0],
	["room407_batch2/pillow.glb", Vector3(3.35, 1.2, -2.33), -5.0],
	["room407_batch2/blanket_folded.glb", Vector3(0.65, 0.43, -3.68), 2.0],
	["room407_batch2/blanket_folded.glb", Vector3(0.65, 1.2, -3.68), 3.0],
	["room407_batch2/blanket_folded.glb", Vector3(3.35, 0.43, -3.68), -3.0],
	["room407_batch2/blanket_folded.glb", Vector3(3.35, 1.2, -3.68), -4.0],
]
## Each room's own things (PLAN A24-A27), room 407's models at the PS1 ones' places.
const ITEMS := {
	# Shirt on its hanger over bunk B's head rail, slippers between the bunks, the poster on the east wall.
	"102": [["room407_batch2/shirt_hanging.glb", Vector3(3.35, 0.75, -1.89), 0.0],
		["room407_batch1/slippers.glb", Vector3(1.4, 0.0, -3.4), 30.0],
		# poster_football.glb is drawn in room 407's space (on its west wall): turned to face west from the east wall.
		["room407_furnished/poster_football.glb", Vector3(3.997, -0.56, -6.42), 180.0]],
	"306": [["room407_batch3/towel_draped.glb", Vector3(3.58, 0.92, -4.83), 180.0],
		["room407_batch1/bucket.glb", Vector3(3.4, 0.0, -4.4), 0.0],
		["room407_batch2/notebook.glb", Vector3(1.45, 0.76, -4.6), -12.0],
		["room407_batch2/noodles.glb", Vector3(2.38, 0.76, -4.45), 30.0]],
	"209": [["room407_batch2/books_row.glb", Vector3(1.44, 0.76, -4.66), 180.0],
		["room407_batch3/basin_clothes.glb", Vector3(3.0, 0.0, -1.72), 15.0]],
	# The lamp stands under DeskLamp's light (1.3, 1.02, -4.4): the bulb just under its shade.
	"106": [["room407_batch2/desk_lamp.glb", Vector3(1.3, 0.76, -4.4), 160.0],
		["room407_batch2/notebook.glb", Vector3(1.85, 0.76, -4.5), 8.0],
		["room407_batch2/books.glb", Vector3(2.3, 0.76, -4.68), -6.0],
		["room407_batch3/pen_cup.glb", Vector3(1.62, 0.76, -4.74), 0.0]],
	"310": [],
}
const NETS := {
	"lower_closed": P + "room407_furnished/mosquito_net_lower_closed.glb",
	"upper_closed": P + "room407_furnished/mosquito_net_upper_closed.glb",
	"upper_open": W10 + "cctv_net_upper_open.glb",
}
const NET_OPEN_PS1 := "res://assets/models/kit/mosquito_net_open.glb"
const LEAF := "res://assets/models/graphics_pilot/realistic_map/wave2/room_door_leaf.glb"
## The leaf on its hinge at the doorway's east jamb, swung in against the room's side of the wall.
const LEAF_AT := [Vector3(2.875, 0.0, -0.1), -90.0]

## Off only to compare with the PS1 room: set it before the room enters the tree.
@export var upgraded := true
## The PS1 meshes this room hides (tests and captures read it).
var replaced: Array[MeshInstance3D] = []
var number := ""


func _ready() -> void:
	var room := get_parent() as Node3D
	number = String(room.name).trim_prefix("Room")
	if not upgraded:
		return
	for node: Node in room.find_children("*", "MeshInstance3D", true, false):
		var top := String(room.get_path_to(node)).get_slice("/", 0)
		if top in KEEP:
			continue
		var mesh := node as MeshInstance3D
		if not mesh.visible:
			continue
		replaced.append(mesh)
		mesh.visible = false
	var shell := _add(W10 + "cctv_room.glb", Vector3.ZERO, 0.0, "Room")
	var hall := _add(W10 + "cctv_hall.glb", Vector3.ZERO, 0.0, "Hall")
	(hall.find_child("Parapet", true, false) as Node3D).visible = number in FLOOR_ONE
	(hall.find_child("Balustrade", true, false) as Node3D).visible = not number in FLOOR_ONE
	_add(LEAF, LEAF_AT[0], LEAF_AT[1], "Leaf")
	for row: Array in FURNITURE:
		_add(P + String(row[0]), row[1], row[2])
	for row: Array in ITEMS.get(number, []):
		_add(P + String(row[0]), row[1], row[2])
	for bunk_name: String in ["BunkA", "BunkB"]:
		var bunk := room.get_node_or_null(bunk_name) as Node3D
		if bunk == null:
			continue
		for net_name: String in ["NetLower", "NetUpper"]:
			var net := bunk.get_node_or_null(net_name) as Node3D
			if net == null:
				continue
			var key := ("upper_" if net_name == "NetUpper" else "lower_") + ("open" if net.scene_file_path == NET_OPEN_PS1 else "closed")
			_add(NETS[key], Vector3(bunk.position.x, 0.0, bunk.position.z), 0.0, bunk_name + net_name)
	for node: Node in find_children("*", "GeometryInstance3D", true, false):
		(node as GeometryInstance3D).visibility_range_end = VISIBLE_TO
	if shell == null:
		push_error("cctv_room_real: no shell")


func _add(path: String, at: Vector3, yaw: float, node_name := "") -> Node3D:
	var node := (load(path) as PackedScene).instantiate() as Node3D
	if not node_name.is_empty():
		node.name = node_name
	add_child(node)
	node.position = at
	node.rotation_degrees.y = yaw
	return node
