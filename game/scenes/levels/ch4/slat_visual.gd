extends Marker3D
## Visual only; lane A owns the hold interaction and lane D the readable scrap.
## T-266 (D-187 points 1-3): the V2b panel (Hinge/Real) lifts on its wall-side hinge, each bed by its own angle (bed 2 stops
## at 62 degrees under the upper bunk's deck, 1.075 m); the bed's three furnished Tripo things (mattress, blanket, pillow) are
## thrown onto the floor beside the bunk while it lifts (N2, no collider), each to a spot of its own, and go back on exit
## like the nets. Room407 space below = the furnished room's own space (Floor4/Room407, x 0 at its west wall).
@export var bed: int = 1
var flipped: bool = false
## Degrees about z; bed 4's hinge is on the east wall.
const ANGLES := {1: 70.0, 2: 62.0, 4: -70.0}
## The panel waits a beat so the bedding is out of the bunk before the planks sweep up; done at 0.5 s (contract: <= 0.6 s).
const TURN_DELAY := 0.08
const TURN_SECONDS := 0.42
const FALL_SECONDS := 0.55
## Each bed's things in Room407's placements (Phuc's three ride Anchors/PhucMattress/Pivot).
const BEDDING := {1: ["MattressPhuc", "BlanketPhuc", "PillowPhuc"], 2: ["MattressViet", "BlanketViet", "PillowViet"],
	4: ["MattressDat", "BlanketDat", "PillowDat"]}
## Where each lands, Room407 space: origin (x, y, z) and yaw in degrees (the props' origins are their bottom centres).
## Beds 1 and 2 share bunk A. The floor in front of it is 1.36 m wide between the bunk (x 1.10) and the floor mat (x 2.49),
## with the power strip (x 1.13..1.55, z -2.40..-2.29) and the desk (z -4.23) at its ends: room for one mattress only.
## Phuc's (upper) things slide off over the guard rail and drop beside the bunk onto that spot, his pillow and folded
## blanket on his mattress; Viet's (lower) mattress is shoved out low across the floor in front of the mat's foot
## (x 2.59..4.51, z -1.55..-0.69, 0.17 m clear of the door's swing), his blanket on it, his pillow beside it. Dat's three
## land in front of bunk B the same way as Phuc's. Clearances: wave9/README.md.
const LANDING := {
	"MattressPhuc": [Vector3(2.025, 0.002, -3.2), 2.0], "BlanketPhuc": [Vector3(2.05, 0.051, -3.7), 15.0],
	"PillowPhuc": [Vector3(2.0, 0.051, -2.65), 70.0],
	"MattressViet": [Vector3(3.55, 0.002, -1.12), 92.0], "BlanketViet": [Vector3(3.45, 0.051, -1.12), 92.0],
	"PillowViet": [Vector3(4.78, 0.002, -1.1), 80.0],
	"MattressDat": [Vector3(6.43, 0.002, -2.62), -2.0], "BlanketDat": [Vector3(6.45, 0.051, -3.15), -12.0],
	"PillowDat": [Vector3(6.4, 0.051, -2.05), 75.0]}
const BUNK_ROOM_SIDE := {1: 1.10, 2: 1.10, 4: 6.90}
const POSTS_TOP := 1.5
const LOWER_RAIL_TOP := 0.38
## Bed 2's mattress (1.90 m) is longer than the 1.80 m between the bunk's corner posts: it leaves tipped 18.8 degrees
## (foot end up, 1 cm over the deck rail and 1 cm under the upper deck's rail), its ends brushing the posts' inner 8 mm.
const LOWER_PITCH := -18.8
const LOWER_TIP_SHIFT := 0.007
## Bed 2's things then go low across the floor (bottom at most this high), under a crouching player's eye (1.0 m).
const LOWER_ARC_BOTTOM := 0.2
## Upper bunks: the thing slides over the guard rail (bottom 3 cm over the posts' tops) and tips down over the bunk's edge
## to this angle, hanging within 0.2 m of the bunk side (the hand-use eyes stand 0.8 m and more from the slat), then drops
## upright to the floor and falls over onto its spot.
const TIP_DEGREES := 80.0

var _turn: Tween
var _fall: Tween
var _net: Node3D
var _net_visible: bool = true
var _room: Node3D
var _things: Array[Dictionary] = []
## The bed's lowest thing at rest (its mattress's underside), Room407 space: the blanket and pillow ride on the mattress.
var _bed_bottom: float = 0.0


func _ready() -> void:
	EventBus.bed_slat_flipped.connect(_on_flipped)
	call_deferred("_bind_net")


func _bind_net() -> void:
	var campus := get_node_or_null("../../../..")
	if campus == null or campus.get("floor4_path") == null:
		return
	var floor4 := campus.get_node_or_null(campus.floor4_path)
	if floor4 == null:
		return
	var path: String = {1: "BunkA/Net_Phuc", 2: "BunkA/Net_Viet", 4: "BunkB/Net_Dat"}.get(bed, "")
	if path.is_empty():
		return
	_net = floor4.get_node("Room407/" + path)
	_net_visible = _net.visible
	_room = floor4.get_node("Room407") as Node3D
	for prop_name: String in BEDDING.get(bed, []):
		var prop := _find_prop(prop_name)
		if prop != null:
			_things.append({"node": prop, "name": prop_name, "rest": prop.transform, "box": _local_box(prop)})
	_bed_bottom = INF
	for thing: Dictionary in _things:
		var pose := _room.global_transform.affine_inverse() * (thing.node as Node3D).global_transform
		_bed_bottom = minf(_bed_bottom, (pose * (thing.box as AABB)).position.y)


func _find_prop(prop_name: String) -> Node3D:
	var prop: Node3D = _room.call("furnished_prop", prop_name) if _room.has_method("furnished_prop") else null
	if prop == null:
		# The room carries Phuc's three on its mattress anchor (room407.gd FOLLOW).
		prop = _room.get_node_or_null("Anchors/PhucMattress/Pivot/" + prop_name) as Node3D
	return prop


func _on_flipped(number: int) -> void:
	if number == bed:
		set_flipped(true)


func set_flipped(value: bool) -> void:
	flipped = value
	if is_instance_valid(_net):
		_net.visible = _net_visible and not value
	if _turn != null and _turn.is_valid():
		_turn.kill()
	_turn = create_tween()
	var hinge := $Hinge as Node3D
	if value:
		_turn.tween_interval(TURN_DELAY)
		_turn.tween_property(hinge, "rotation:z", deg_to_rad(ANGLES.get(bed, 70.0)), TURN_SECONDS) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_throw_bedding()
	else:
		_turn.tween_property(hinge, "rotation:z", 0.0, .45)
		_restore_bedding()


## N2: every thing of this bed flies on its own path (lift, out over the bunk's side, down onto its spot).
func _throw_bedding() -> void:
	if _things.is_empty() or not is_instance_valid(_room):
		return
	if _fall != null and _fall.is_valid():
		_fall.kill()
	var paths: Array = []
	for thing: Dictionary in _things:
		var node := thing.node as Node3D
		if not is_instance_valid(node):
			continue
		node.transform = thing.rest
		paths.append({"node": node, "keys": fall_keys(String(thing.name), _room.global_transform.affine_inverse() * node.global_transform)})
	_fall = create_tween()
	_fall.tween_method(_pose_bedding.bind(paths), 0.0, 1.0, FALL_SECONDS)


func _pose_bedding(t: float, paths: Array) -> void:
	for path: Dictionary in paths:
		var node := path.node as Node3D
		if is_instance_valid(node):
			node.global_transform = _room.global_transform * pose_at(path.keys, t)


## Room407-space keys [time, Transform3D, ease of the leg ending there: "s" smooth, "l" linear, "i" falling] from a thing's
## rest pose to its landing (the tests sample the same path).
func fall_keys(prop_name: String, rest: Transform3D) -> Array:
	var landing: Array = LANDING[prop_name]
	var end := Transform3D(Basis(Vector3.UP, deg_to_rad(landing[1])), landing[0])
	var side := 1.0 if bed != 4 else -1.0
	var room_side: float = BUNK_ROOM_SIDE[bed]
	var box := box_of(prop_name)
	if bed == 2:
		# Lower bunk: tip (the mattress only), slide out under the upper deck, then low across the floor to the spot.
		var tipped := rest
		if prop_name.begins_with("Mattress"):
			tipped.basis = rest.basis * Basis(Vector3.RIGHT, deg_to_rad(LOWER_PITCH))
			tipped.origin.z += LOWER_TIP_SHIFT
		tipped.origin.y += LOWER_RAIL_TOP + 0.01 - (tipped * box).position.y
		var out := tipped
		out.origin.x += room_side + 0.08 - (tipped * box).position.x
		var mid := Transform3D(Basis(out.basis.get_rotation_quaternion().slerp(end.basis.get_rotation_quaternion(), 0.5)),
				out.origin.lerp(end.origin, 0.5))
		mid.origin.y += LOWER_ARC_BOTTOM - (mid * box).position.y
		return [[0.0, rest, "s"], [0.09, tipped, "s"], [0.33, out, "s"], [0.62, mid, "s"], [1.0, end, "i"]]
	# Upper bunks: off the wall-side rail a little, up over the posts, out flat until the middle is over the edge, tip down
	# over it, drop upright, fall over onto the spot.
	var ride := maxf(0.0, (rest * box).position.y - _bed_bottom) if is_finite(_bed_bottom) else 0.0
	var pivot := Vector3(room_side + side * 0.01, POSTS_TOP + 0.03 + ride, 0.0)
	var nudged := rest.translated(Vector3(-side * 0.035, 0.02, 0.0))
	var lifted := nudged
	lifted.origin.y += pivot.y - (nudged * box).position.y
	var centred := lifted
	centred.origin.x += pivot.x - (lifted * box).get_center().x
	var keys: Array = [[0.0, rest, "s"], [0.09, nudged, "s"], [0.25, lifted, "s"], [0.33, centred, "s"]]
	var width := box.size.x
	for step in range(1, 9):
		var f := step / 8.0
		var inside := width / 2.0 * (1.0 - f)
		var tip := deg_to_rad(TIP_DEGREES) * minf(1.0, f / 0.4)
		keys.append([0.33 + 0.17 * f, _over_edge(lifted, box, pivot, side, inside, tip), "l"])
	var hanging: Transform3D = keys[-1][1]
	var dropped := hanging
	dropped.origin.y += 0.002 - (hanging * box).position.y
	keys.append([0.72, dropped, "i"])
	# Falls over away from the bunk, its lowest point on the floor, turning to the spot's yaw.
	var start_yaw := lifted.basis.get_rotation_quaternion()
	for step in range(1, 7):
		var f := step / 6.0
		var tip := deg_to_rad(TIP_DEGREES) * (1.0 - f)
		# The middle moves out ahead of the fall, so the upper edge never swings back over the bunk's side.
		var out := 1.0 - (1.0 - f) * (1.0 - f)
		var pose := Transform3D(Basis(Vector3.BACK, -side * tip) * Basis(start_yaw.slerp(end.basis.get_rotation_quaternion(), f)),
				dropped.origin.lerp(end.origin, out))
		pose.origin.y += end.origin.y * f + 0.002 * (1.0 - f) - (pose * box).position.y
		keys.append([0.72 + 0.28 * f, pose, "i" if step == 1 else "l"])
	keys[-1][1] = end
	return keys


## A thing tipped `tip` radians down over the bunk's edge (`pivot`, outward `side`), `inside` metres of it still in.
static func _over_edge(lifted: Transform3D, box: AABB, pivot: Vector3, side: float, inside: float, tip: float) -> Transform3D:
	var basis := Basis(Vector3.BACK, -side * tip) * lifted.basis
	var centre := box.get_center()
	var contact := Vector3(centre.x - side * box.size.x / 2.0 + side * inside, box.position.y, centre.z)
	var origin := pivot - basis * contact
	origin.z = lifted.origin.z
	return Transform3D(basis, origin)


## The pose at t (0..1) on keys, each leg eased as its end key says.
static func pose_at(keys: Array, t: float) -> Transform3D:
	t = clampf(t, 0.0, 1.0)
	for index in range(keys.size() - 1):
		var a: Array = keys[index]
		var b: Array = keys[index + 1]
		if t > float(b[0]) and index < keys.size() - 2:
			continue
		var u := clampf((t - float(a[0])) / maxf(float(b[0]) - float(a[0]), 0.0001), 0.0, 1.0)
		match String(b[2]):
			"s":
				u = u * u * (3.0 - 2.0 * u)
			"i":
				u = u * u
		var from: Transform3D = a[1]
		var to: Transform3D = b[1]
		var basis := Basis(from.basis.get_rotation_quaternion().slerp(to.basis.get_rotation_quaternion(), u))
		return Transform3D(basis, from.origin.lerp(to.origin, u))
	return keys[-1][1]


## A thing's mesh bounds in its own space (taken once, at rest).
func box_of(prop_name: String) -> AABB:
	for thing: Dictionary in _things:
		if thing.name == prop_name:
			return thing.box
	return AABB()


static func _local_box(prop: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for mesh: MeshInstance3D in prop.find_children("*", "MeshInstance3D", true, false):
		var bb := (prop.global_transform.affine_inverse() * mesh.global_transform) * mesh.get_aabb()
		box = bb if first else box.merge(bb)
		first = false
	return box


func _restore_bedding() -> void:
	if _fall != null and _fall.is_valid():
		_fall.kill()
	for thing: Dictionary in _things:
		var node := thing.node as Node3D
		if is_instance_valid(node):
			node.transform = thing.rest


func _exit_tree() -> void:
	if is_instance_valid(_net):
		_net.visible = _net_visible
	_restore_bedding()
