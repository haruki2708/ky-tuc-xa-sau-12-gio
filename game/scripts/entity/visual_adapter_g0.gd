extends Node3D
## T-208 G0 experiment for the existing campus rig, not the shared G1 contract.
## Only the fixture uses this wrapper. Gameplay still owns motion and timing.

@export var body_path: NodePath = ^"Body"
@export var head_path: NodePath = ^"Body/Model/Rig/Hips/Chest/Head"

var last_issue: String = ""


func binding_issues() -> PackedStringArray:
	var issues: PackedStringArray = []
	var body: Node3D = get_node_or_null(body_path) as Node3D
	if body == null or body == self or not is_ancestor_of(body):
		issues.append("body_missing_or_outside_visual")
	elif not body.has_method("set_pose"):
		issues.append("set_pose_missing")
	var head: Node3D = get_node_or_null(head_path) as Node3D
	if head == null or body == null or not body.is_ancestor_of(head) or head.name != &"Head":
		issues.append("head_missing_or_outside_body")
	# A visual must not add another physics body or intercept InteractRay.
	if not find_children("*", "CollisionObject3D", true, false).is_empty():
		issues.append("visual_contains_collision")
	return issues


func set_pose(value: StringName) -> bool:
	var issues: PackedStringArray = binding_issues()
	if not issues.is_empty():
		last_issue = ";".join(issues)
		return false
	var body: Node3D = get_node(body_path) as Node3D
	# The existing campus wrapper returns bool. No guessed aliases or clips.
	var accepted: bool = bool(body.call("set_pose", value))
	last_issue = "" if accepted else "pose_unsupported:%s" % value
	return accepted
