extends Node3D
## T-266 (D-187 points 4-5), visual only: once the empty ceiling hatch or vent of room 407 has been searched, the room's
## own hatch (H1) drops ajar on its hinge and the vent grille hangs askew from its top-north screw. Both are drawn by the
## furnished room in all four chapters (Floor4/Room407/Wave9Fixtures, C2); this only turns them, and puts them back on exit.
## The director hangs a Search<spot> under each Fake<spot> marker when the room407 stage starts, so they are bound as they
## appear. The decoys (fake_search_spot.tscn, empty_result) finish without emitting `searched`, so the finished hold
## (EventBus.interacted, sent by HoldInteractable._finish) opens them too. Phuc's locker (FakeLocker) is open already.
const PARTS := {"FakeCeiling": "Wave9Fixtures/Hatch/HatchLeaf", "FakeVent": "Wave9Fixtures/Vent/VentGrille"}
## Degrees (Euler) each part turns to about its own origin (the hinge; the screw): the hatch's free edge drops 28 degrees,
## the grille's free corner swings down 26 degrees and its foot comes 3 cm off the wall.
const OPEN := {"FakeCeiling": Vector3(0.0, 0.0, -28.0), "FakeVent": Vector3(26.0, 0.0, -4.0)}
const SECONDS := 0.35
var opened: Dictionary[String, bool] = {}
var _parts: Dictionary[String, Node3D] = {}
var _rest: Dictionary[String, Transform3D] = {}
var _tweens: Array[Tween] = []


func _ready() -> void:
	EventBus.interacted.connect(_on_interacted)
	for marker_name: String in PARTS:
		var marker := get_parent().get_node_or_null(marker_name)
		if marker == null:
			continue
		marker.child_entered_tree.connect(_on_child.bind(marker_name))
		for child in marker.get_children():
			_on_child(child, marker_name)
	call_deferred("_bind")


func _bind() -> void:
	var campus := get_node_or_null("../../../..")
	if campus == null or campus.get("floor4_path") == null:
		return
	var floor4 := campus.get_node_or_null(campus.floor4_path)
	if floor4 == null:
		return
	for marker_name: String in PARTS:
		var part := floor4.get_node_or_null("Room407/" + String(PARTS[marker_name])) as Node3D
		if part != null:
			_parts[marker_name] = part
			_rest[marker_name] = part.transform


func _on_child(child: Node, marker_name: String) -> void:
	if child.has_signal(&"searched") and not child.is_connected(&"searched", _on_searched):
		child.connect(&"searched", _on_searched.bind(marker_name))


func _on_searched(_spot_id: StringName, marker_name: String) -> void:
	open(marker_name)


func _on_interacted(target: Node) -> void:
	if target == null or target.get_parent() == null:
		return
	var marker_name := String(target.get_parent().name)
	if PARTS.has(marker_name) and target.get_parent().get_parent() == get_parent():
		open(marker_name)


## Turn the part of `marker_name` ("FakeCeiling" or "FakeVent") to its searched pose.
func open(marker_name: String) -> void:
	if opened.get(marker_name, false) or not _parts.has(marker_name):
		return
	opened[marker_name] = true
	var part := _parts[marker_name]
	var target: Vector3 = OPEN[marker_name]
	var tween := create_tween()
	tween.tween_property(part, "rotation_degrees", target, SECONDS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tweens.append(tween)


func _exit_tree() -> void:
	for tween in _tweens:
		if tween.is_valid():
			tween.kill()
	for marker_name: String in _parts:
		var part := _parts[marker_name]
		if is_instance_valid(part):
			part.transform = _rest[marker_name]
