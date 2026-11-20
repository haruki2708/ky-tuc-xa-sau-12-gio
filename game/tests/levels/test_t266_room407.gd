extends TestCase
## T-266 round 2 (D-187 points 1-6): room 407 in chapter 4 and its fixtures in all four chapters.
## Room407 space below = the furnished room's own (Floor4/Room407, x 0 at its west wall), as slat_visual.gd uses.

const ANCHORS := "res://scenes/levels/ch4/ch4_anchors.tscn"
## md5 of ch4_anchors.tscn from its root node to the line before the Room407 branch, as main has it (81b17b3): every node
## outside the branch (Start_*, library anchors, LibraryZombieSpawn, StairCrowd) unchanged, line for line.
const OUTSIDE_MD5 := "9d31aab440a937f863f651ffa7244e26"
const MARKERS := {"Slat1": Vector3(0.65, 1.18, -3), "Slat2": Vector3(0.65, 0.41, -3), "Slat4": Vector3(7.35, 1.18, -2.7),
	"FakeLocker": Vector3(0.65, 1.1, -0.45), "FakeCeiling": Vector3(3, 2.92, -2), "FakeVent": Vector3(7.8, 2.35, -1)}
const PS1_HIDDEN := ["Slat1/Hinge/Board/Mesh", "Slat1/Hinge/Ink", "Slat2/Hinge/Board/Mesh", "Slat2/Hinge/Ink", "Slat4/Hinge/Board/Mesh",
	"Slat4/Hinge/Ink", "CeilingPanel", "VentFrame", "VentSlat0", "VentSlat1", "VentSlat2", "VentSlat3", "VentSlat4", "VentSlat5",
	"Door/Damage/Hole/Left", "Door/Damage/Hole/Right", "Door/Damage/Hole/Top", "Door/Damage/Hole/Bottom"]
## Bunk frames, Room407 space (T-266 probe of the Tripo bunks): the room-side bars and corner posts each path must clear.
## (x0, x1, y0, y1, z0, z1)
const BARS := {
	"A": [[1.02, 1.09, 0.28, 0.38, -3.99, -2.01], [1.02, 1.09, 1.06, 1.14, -3.99, -2.01], [1.02, 1.09, 1.3, 1.34, -3.99, -2.01]],
	"B": [[6.91, 6.98, 0.28, 0.38, -3.69, -1.71], [6.91, 6.98, 1.06, 1.14, -3.69, -1.71], [6.91, 6.98, 1.3, 1.34, -3.69, -1.71]]}
const POSTS := {"A": [[1.02, 1.09, 0.0, 1.5, -3.99, -3.9], [1.02, 1.09, 0.0, 1.5, -2.1, -2.01]],
	"B": [[6.91, 6.98, 0.0, 1.5, -3.69, -3.6], [6.91, 6.98, 0.0, 1.5, -1.8, -1.71]]}
## The upper deck's underside over bed 2 (survey: horizontal faces of BunkA, y 1.075).
const UPPER_DECK_UNDERSIDE := 1.075
var fixture: Node3D
var floor4: Node3D
var campus: Node3D
var anchors: Node3D
var room: Node3D


func before_each() -> void:
	fixture = Node3D.new()
	tree.root.add_child(fixture)
	floor4 = load("res://scenes/levels/floor4/floor4.tscn").instantiate()
	fixture.add_child(floor4)
	campus = load("res://scenes/levels/campus/campus.tscn").instantiate()
	fixture.add_child(campus)
	anchors = campus.get_node("Anchors/Ch4/Room407")
	room = floor4.get_node("Room407")
	await wait_frames(4)


func after_each() -> void:
	fixture.queue_free()
	await wait_frames(3)


func _to_room(node: Node3D) -> Transform3D:
	return room.global_transform.affine_inverse() * node.global_transform


func test_anchors_branch_keeps_markers_blocker_scripts_and_the_rest_as_main() -> void:
	var text := FileAccess.get_file_as_string(ANCHORS).replace("\r\n", "\n")
	var lines := text.split("\n")
	var start := -1
	var branch := -1
	for index in lines.size():
		if start < 0 and lines[index].begins_with("[node ") and not "parent=" in lines[index]:
			start = index
		if lines[index].begins_with("[node name=\"Room407\""):
			branch = index
			break
	assert_eq("\n".join(lines.slice(start, branch)).md5_text(), OUTSIDE_MD5, "outside the Room407 branch the file is main's")
	var scene: Node3D = load(ANCHORS).instantiate()
	fixture.add_child(scene)
	var branch_node := scene.get_node("Room407") as Node3D
	assert_eq(branch_node.position, Vector3(30, 0, 0))
	for marker_name: String in MARKERS:
		var marker := branch_node.get_node(marker_name) as Node3D
		assert_true(marker is Marker3D, marker_name + " is a Marker3D")
		assert_true(marker.position.is_equal_approx(MARKERS[marker_name]), marker_name + " where main has it")
	for bed in [1, 2, 4]:
		var slat := branch_node.get_node("Slat%d" % bed)
		assert_eq((slat.get_script() as Script).resource_path, "res://scenes/levels/ch4/slat_visual.gd")
		assert_eq(int(slat.bed), bed)
		assert_not_null(slat.get_node_or_null("Hinge/Real"), "Slat%d/Hinge/Real (V2b)" % bed)
	var door := branch_node.get_node("Door") as Node3D
	assert_eq((door.get_script() as Script).resource_path, "res://scenes/levels/ch4/door407_proxy.gd")
	var blocker := door.get_node("Blocker") as StaticBody3D
	assert_true(blocker.position.is_equal_approx(Vector3(-0.44, 1.05, 0)), "Blocker where main has it")
	assert_true(((blocker.get_node("Collision") as CollisionShape3D).shape as BoxShape3D).size.is_equal_approx(Vector3(0.88, 2.1, 0.08)))
	for path: String in PS1_HIDDEN:
		assert_false((branch_node.get_node(path) as Node3D).visible, "PS1 hidden, node kept: " + path)
	for layer in ["Cracks", "Hole", "Hand"]:
		for item: Node in door.get_node("Damage/" + layer).get_children():
			if item.name != &"Real":
				assert_false((item as Node3D).visible, "PS1 damage hidden: %s/%s" % [layer, item.name])
	scene.queue_free()


## Every bed: the planks lift on the hinge (> 1 rad, bed 2 stays under the upper deck), the net hides, the mattress, blanket
## and pillow land on their spots on the floor whichever order the beds are flipped in, and all of it goes back.
func test_slats_lift_and_bedding_lands_apart_in_either_order() -> void:
	for order: Array in [[1, 2, 4], [2, 1, 4]]:
		var rests := {}
		for bed in [1, 2, 4]:
			for thing: Dictionary in anchors.get_node("Slat%d" % bed)._things:
				rests[thing.name] = (thing.node as Node3D).global_transform
		assert_eq(rests.size(), 9, "nine furnished things found (order %s)" % [order])
		for bed: int in order:
			EventBus.bed_slat_flipped.emit(bed)
			await tree.create_timer(0.62).timeout
		var landed := {}
		for bed in [1, 2, 4]:
			var slat := anchors.get_node("Slat%d" % bed)
			var hinge := slat.get_node("Hinge") as Node3D
			assert_true(absf(hinge.rotation.z) > 1.0, "bed %d lifted past 1 rad" % bed)
			var angle := float(_const(slat, "ANGLES")[bed])
			assert_true(absf(rad_to_deg(hinge.rotation.z) - angle) < 0.5, "bed %d at its own angle (%.1f)" % [bed, angle])
			if bed == 2:
				var top := _box(slat.get_node("Hinge/Real") as Node3D).end.y
				assert_true(top < UPPER_DECK_UNDERSIDE, "bed 2's planks stop under the upper deck (%.3f)" % top)
			for thing: Dictionary in slat._things:
				var node := thing.node as Node3D
				var landing: Array = _const(slat, "LANDING")[thing.name]
				var pose := _to_room(node)
				assert_true(pose.origin.distance_to(landing[0]) < 0.002, "%s on its spot (order %s)" % [thing.name, order])
				var box := pose * (slat.box_of(thing.name) as AABB)
				landed[thing.name] = {"bed": bed, "box": box, "pose": pose, "local": slat.box_of(thing.name)}
		for name: String in landed:
			var entry: Dictionary = landed[name]
			var bottom: float = entry.box.position.y
			if not name.begins_with("Mattress") and float(_const(anchors.get_node("Slat%d" % entry.bed), "LANDING")[name][0].y) > 0.01:
				var own := "Mattress" + name.trim_prefix("Blanket").trim_prefix("Pillow")
				assert_true(absf(bottom - landed[own].box.end.y) < 0.012, "%s lies on its own bed's mattress (%.3f)" % [name, bottom])
			else:
				assert_true(bottom > -0.004 and bottom < 0.012, "%s lies on the floor (%.3f)" % [name, bottom])
			for other: String in landed:
				if other <= name or landed[other].bed == entry.bed:
					continue
				assert_false(_overlap(entry, landed[other]), "%s and %s (different beds) do not overlap" % [name, other])
		# The hand rays of test_chapter4 (and the three decoys): no camera spot inside a fallen thing.
		for target: Vector3 in _hand_targets():
			for direction: Vector3 in [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]:
				for distance: float in [0.8, 1.2]:
					for eye_y: float in [1.6, 1.0]:
						var eye := target + direction * distance
						eye.y = eye_y
						for name: String in landed:
							assert_false((landed[name].box as AABB).grow(0.05).has_point(eye), "eye %s not inside %s" % [eye, name])
		for bed in [1, 2, 4]:
			anchors.get_node("Slat%d" % bed).set_flipped(false)
		await wait_frames(2)
		for bed in [1, 2, 4]:
			for thing: Dictionary in anchors.get_node("Slat%d" % bed)._things:
				assert_true((thing.node as Node3D).global_transform.is_equal_approx(rests[thing.name]), "%s back in the bed" % thing.name)


## The fall paths (the same keys slat_visual.gd plays): above the floor all the way; once the thing has left its rest pose
## it does not cross the bunk's room-side bars or corner posts (oriented boxes, SAT); and no hand-use eye of that bed (the
## player is there) is ever inside it. Bed 2's mattress (1.90 m) is longer than the 1.80 m between the posts: it leaves
## tipped 18.8 degrees and its ends brush the posts' inner 8 mm (allowed below, README).
func test_fall_paths_clear_the_bunk_bars_and_the_player() -> void:
	for bed in [1, 2, 4]:
		var slat := anchors.get_node("Slat%d" % bed)
		var bunk := "B" if bed == 4 else "A"
		var target: Vector3 = MARKERS["Slat%d" % bed] + Vector3(0, 0, 0.45)
		var eyes: Array[Vector3] = []
		for direction: Vector3 in [Vector3.RIGHT, Vector3.LEFT, Vector3.FORWARD, Vector3.BACK]:
			for distance: float in [0.8, 1.2]:
				for eye_y: float in [1.6, 1.0]:
					var eye := target + direction * distance
					eye.y = eye_y
					# Only where a player can stand: in the room, outside the bunk's frame.
					var in_bunk := eye.z > (-4.02 if bunk == "A" else -3.72) and eye.z < (-1.98 if bunk == "A" else -1.68) 							and eye.x > (0.18 if bunk == "A" else 6.88) and eye.x < (1.12 if bunk == "A" else 7.82)
					if not in_bunk and eye.x > 0.1 and eye.x < 7.9:
						eyes.append(eye)
		assert_true(eyes.size() >= 4, "bed %d: hand-use eyes in the room (%d)" % [bed, eyes.size()])
		for thing: Dictionary in slat._things:
			var keys: Array = slat.fall_keys(thing.name, _to_room(thing.node as Node3D))
			var local: AABB = slat.box_of(thing.name)
			var leave := float(keys[1][0])
			for step in 201:
				var t := step / 200.0
				var pose: Transform3D = slat.pose_at(keys, t)
				var box: AABB = pose * local
				assert_true(box.position.y > -0.005, "%s above the floor at t %.3f (%.3f)" % [thing.name, t, box.position.y])
				for eye in eyes:
					assert_false(local.grow(0.02).has_point(pose.affine_inverse() * eye), "bed %d's eye %s not inside %s at t %.3f" % [bed, eye, thing.name, t])
				if t < leave:
					continue
				for bar: Array in BARS[bunk]:
					assert_false(_obb_hits(pose, local, _bar_box(bar)), "%s clears bar %s at t %.3f" % [thing.name, bar, t])
				for post: Array in POSTS[bunk]:
					var post_box := _bar_box(post)
					if thing.name == "MattressViet":
						post_box = post_box.grow(-0.01)
					assert_false(_obb_hits(pose, local, post_box), "%s clears post %s at t %.3f" % [thing.name, post, t])
		var turn := float(_const(slat, "TURN_DELAY")) + float(_const(slat, "TURN_SECONDS"))
		assert_true(turn <= 0.6 and float(_const(slat, "FALL_SECONDS")) <= 0.6, "bed %d done within 0.6 s" % bed)


## An oriented box (local box at pose) and an axis-aligned box overlap (separating axes; touching is not overlap).
func _obb_hits(pose: Transform3D, local: AABB, box: AABB) -> bool:
	var centre := pose * local.get_center()
	var axes: Array[Vector3] = [pose.basis.x.normalized(), pose.basis.y.normalized(), pose.basis.z.normalized()]
	var half := local.size / 2.0
	var box_centre := box.get_center()
	var box_half := box.size / 2.0
	var world: Array[Vector3] = [Vector3.RIGHT, Vector3.UP, Vector3.BACK]
	var tests: Array[Vector3] = world + axes
	for a in axes:
		for w in world:
			var cross := a.cross(w)
			if cross.length() > 0.0001:
				tests.append(cross.normalized())
	var delta := box_centre - centre
	for axis in tests:
		var r_obb := half.x * absf(axes[0].dot(axis)) + half.y * absf(axes[1].dot(axis)) + half.z * absf(axes[2].dot(axis))
		var r_box := box_half.x * absf(axis.x) + box_half.y * absf(axis.y) + box_half.z * absf(axis.z)
		if absf(delta.dot(axis)) >= r_obb + r_box - 0.0005:
			return false
	return true


func test_panel_text_hidden_until_lifted() -> void:
	for bed in [1, 2, 4]:
		var real := anchors.get_node("Slat%d/Hinge/Real" % bed) as Node3D
		var box := _box(real)
		var deck_top := 1.155 if bed != 2 else 0.385
		# Flat: the panel lies in the Tripo deck under the mattress (deck 1.075..1.155 / 0.32..0.385, mattress 4.9 cm above).
		assert_true(box.position.y > deck_top - 0.06 and box.end.y < deck_top + 0.045, "bed %d's panel inside the deck and mattress (%s)" % [bed, box])
		var mattress := {1: Vector2(0.25, 1.05), 2: Vector2(0.25, 1.05), 4: Vector2(6.95, 7.75)}[bed] as Vector2
		assert_true(box.position.x >= mattress.x - 0.03 and box.end.x <= mattress.y + 0.03, "bed %d's panel under its mattress in x" % bed)


## D-187 points 4-5: searching the decoy hatch / vent turns the room's own parts (the decoys finish with EventBus.interacted,
## `searched` is heard too), and both go back on exit.
func test_search_feedback_turns_hatch_and_grille_and_restores() -> void:
	var leaf := room.get_node("Wave9Fixtures/Hatch/HatchLeaf") as Node3D
	var grille := room.get_node("Wave9Fixtures/Vent/VentGrille") as Node3D
	var rest_leaf := leaf.transform
	var rest_grille := grille.transform
	var feedback := anchors.get_node("SearchFeedback")
	var ceiling: Node = load("res://scenes/interaction/fake_search_spot.tscn").instantiate()
	ceiling.name = "SearchCeiling"
	anchors.get_node("FakeCeiling").add_child(ceiling)
	var vent: Node = load("res://scenes/interaction/fake_search_spot.tscn").instantiate()
	vent.name = "SearchVent"
	anchors.get_node("FakeVent").add_child(vent)
	await wait_frames(2)
	ceiling.emit_signal(&"searched", &"")
	vent.call("_finish")
	await tree.create_timer(0.5).timeout
	assert_true(feedback.opened.get("FakeCeiling", false) and feedback.opened.get("FakeVent", false), "both opened")
	assert_true(absf(leaf.rotation_degrees.z + 28.0) < 0.5, "the hatch hangs 28 degrees open (%s)" % leaf.rotation_degrees)
	assert_true(grille.rotation_degrees.is_equal_approx(Vector3(26, 0, -4)), "the grille hangs from one screw (%s)" % grille.rotation_degrees)
	assert_true(leaf.position.is_equal_approx(rest_leaf.origin), "the hatch turns on its hinge")
	# The open hatch stays clear of the ceiling fan's blades (D-187 point 5).
	var blades := room.get_node("Furnished/TripoProps/CeilingFan").find_child("Blades", true, false) as MeshInstance3D
	var fan := (room.global_transform.affine_inverse() * blades.global_transform) * blades.get_aabb()
	var hatch_box := _box(room.get_node("Wave9Fixtures/Hatch") as Node3D)
	assert_false(hatch_box.grow(0.1).intersects(fan), "the open hatch 10 cm clear of the fan (%s / %s)" % [hatch_box, fan])
	campus.queue_free()
	await wait_frames(3)
	assert_true(leaf.transform.is_equal_approx(rest_leaf), "the hatch back on exit")
	assert_true(grille.transform.is_equal_approx(rest_grille), "the grille back on exit")


## C2 (D-187 point 5): the fixtures are part of room 407 in every chapter (Floor4 alone = chapters 1-2), visual only; in
## chapters 3-4 the PS1 panel, frame and blades of ch4_anchors are hidden so nothing is drawn twice.
func test_vent_and_hatch_in_every_chapter_visual_only() -> void:
	var fixtures := room.get_node("Wave9Fixtures") as Node3D
	assert_true(fixtures.is_visible_in_tree(), "drawn with Campus (chapters 3-4)")
	for path in ["CeilingPanel", "VentFrame", "VentSlat0", "VentSlat5"]:
		assert_false((anchors.get_node(path) as Node3D).is_visible_in_tree(), "PS1 %s not drawn twice" % path)
	var alone: Node3D = load("res://scenes/levels/floor4/floor4.tscn").instantiate()
	fixture.add_child(alone)
	await wait_frames(3)
	var mine := alone.get_node("Room407/Wave9Fixtures") as Node3D
	assert_true(mine.is_visible_in_tree(), "drawn in chapters 1-2 (Floor4 without Campus)")
	var meshes := mine.find_children("*", "MeshInstance3D", true, false)
	assert_true(meshes.size() >= 4, "vent and hatch meshes (%d)" % meshes.size())
	for mesh: MeshInstance3D in meshes:
		assert_true(mesh.is_visible_in_tree(), "visible: " + String(mesh.name))
	assert_eq(mine.find_children("*", "CollisionObject3D", true, false).size(), 0, "no collider")
	assert_eq(mine.find_children("*", "Interactable", true, false).size(), 0, "no prompt")
	var vent := _box(mine.get_node("Vent") as Node3D)
	assert_true(vent.position.x > 7.85 and vent.end.x <= 7.905, "the vent on the east wall (%s)" % vent)
	assert_true(vent.has_point(Vector3(7.88, 2.35, -1.0)), "at FakeVent")
	var hatch := _box(mine.get_node("Hatch") as Node3D)
	assert_true(hatch.has_point(Vector3(3.0, 2.99, -2.0)) and hatch.end.y <= 3.001, "at FakeCeiling, under the ceiling (%s)" % hatch)


## D-187 point 6: the damage draws on the Tripo leaf; from 60 % no part of the whole leaf is drawn, all of it back on exit.
func test_door_damage_on_the_tripo_leaf() -> void:
	var proxy := anchors.get_node("Door")
	var original := floor4.get_node("Door407")
	var room_door := original.get_node("Pivot/RoomDoor") as Node3D
	for layer in ["Cracks", "Hole", "Hand"]:
		assert_true((proxy.get_node("Damage/%s/Real" % layer) as Node3D).transform.is_equal_approx(room_door.transform), layer + " at RoomDoor")
	var broken := _box(proxy.get_node("Damage/Hole/Real") as Node3D, room_door.global_transform.affine_inverse())
	var whole := (room_door as MeshInstance3D).get_aabb()
	# Same outline in the doorway (x, y); in z the splinters bend up to 9 cm into the room.
	var outline := Vector4(broken.position.x, broken.position.y, broken.end.x, broken.end.y)
	var leaf_outline := Vector4(whole.position.x, whole.position.y, whole.end.x, whole.end.y)
	assert_true((outline - leaf_outline).length() < 0.01, "the broken leaf fills the doorway (%s / %s)" % [broken, whole])
	assert_true(broken.position.z <= whole.position.z and broken.end.z >= whole.end.z - 0.001, "and keeps the leaf's thickness")
	for fraction in [0.0, 0.3, 0.6, 0.8, 1.0, 0.0]:
		EventBus.door_damage_changed.emit(&"407", fraction)
		assert_eq((proxy.get_node("Damage/Cracks/Real") as Node3D).is_visible_in_tree(), fraction >= 0.3, "cracks at %s" % fraction)
		assert_eq((proxy.get_node("Damage/Hole/Real") as Node3D).is_visible_in_tree(), fraction >= 0.6, "hole at %s" % fraction)
		assert_eq((proxy.get_node("Damage/Hand/Real") as Node3D).is_visible_in_tree(), fraction >= 0.8, "hand at %s" % fraction)
		assert_eq(room_door.visible, fraction < 0.6, "Tripo leaf at %s" % fraction)
		assert_eq(original.get_node("Pivot/Leaf").visible, fraction < 0.6, "kit leaf at %s" % fraction)
		if fraction >= 0.6:
			for box in ["Left", "Right", "Top", "Bottom"]:
				assert_false((proxy.get_node("Damage/Hole/" + box) as Node3D).is_visible_in_tree(), "PS1 hole box %s" % box)
			assert_false((proxy.get_node("Damage/Cracks/Real/CracksInner") as Node3D).visible, "inner splits give way to the hole")
	EventBus.door_damage_changed.emit(&"407", 0.8)
	campus.queue_free()
	await wait_frames(3)
	assert_true(room_door.visible, "Tripo leaf back on exit")
	assert_true(original.get_node("Pivot/Leaf").visible, "kit leaf back on exit")


func _const(node: Node, name: String) -> Variant:
	return (node.get_script() as Script).get_script_constant_map()[name]


func _hand_targets() -> Array[Vector3]:
	var result: Array[Vector3] = []
	# BedSlat<n> areas: marker + (0, 0, 0.45) (survey); the three decoys at their markers. Room407 space.
	for marker in ["Slat1", "Slat2", "Slat4"]:
		result.append(MARKERS[marker] + Vector3(0, 0, 0.45))
	for marker in ["FakeLocker", "FakeCeiling", "FakeVent"]:
		result.append(MARKERS[marker])
	return result


func _bar_box(bar: Array) -> AABB:
	return AABB(Vector3(bar[0], bar[2], bar[4]), Vector3(bar[1] - bar[0], bar[3] - bar[2], bar[5] - bar[4]))


func _box(node: Node3D, space: Transform3D = Transform3D()) -> AABB:
	var to := space if space != Transform3D() else room.global_transform.affine_inverse()
	var box := AABB()
	var first := true
	for mesh: MeshInstance3D in node.find_children("*", "MeshInstance3D", true, false):
		var bb := (to * mesh.global_transform) * mesh.get_aabb()
		box = bb if first else box.merge(bb)
		first = false
	return box


## Two landed things overlap: their footprints (yaw only) cross and their heights overlap.
func _overlap(a: Dictionary, b: Dictionary) -> bool:
	var ya: AABB = a.box
	var yb: AABB = b.box
	if ya.end.y <= yb.position.y + 0.001 or yb.end.y <= ya.position.y + 0.001:
		return false
	var pa := _footprint(a.pose, a.local)
	var pb := _footprint(b.pose, b.local)
	for poly: PackedVector2Array in [pa, pb]:
		for i in poly.size():
			var edge := poly[(i + 1) % poly.size()] - poly[i]
			var axis := Vector2(-edge.y, edge.x).normalized()
			var min_a := INF
			var max_a := -INF
			var min_b := INF
			var max_b := -INF
			for p in pa:
				min_a = minf(min_a, p.dot(axis))
				max_a = maxf(max_a, p.dot(axis))
			for p in pb:
				min_b = minf(min_b, p.dot(axis))
				max_b = maxf(max_b, p.dot(axis))
			if max_a <= min_b or max_b <= min_a:
				return false
	return true


func _footprint(pose: Transform3D, local: AABB) -> PackedVector2Array:
	var result := PackedVector2Array()
	for corner: Vector3 in [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 0, 1), Vector3(0, 0, 1)]:
		var p := pose * (local.position + local.size * corner)
		result.append(Vector2(p.x, p.z))
	return result
