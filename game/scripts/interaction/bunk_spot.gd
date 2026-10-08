extends HideSpot

@export_range(1, 4, 1) var bed_number: int = 3
@export var climb_seconds: float = 0.5


func _ready() -> void:
	kind = &"bunk"
	prompt_key = "PROMPT_LIE_DOWN"
	# Upper mattresses need a small lip above the board: a downward ray aimed
	# at the lower bed must pass beneath the upper interaction volume.
	if bed_number in [1, 4]:
		$CollisionShape3D.position.y = 0.3
	# Later chapters reuse these anchors for other props (notably CH4 slats).
	# Preserve their original pick volume. Read the owning scene's director,
	# not GameState.chapter, which can still refer to the previous scene here.
	var ancestor: Node = get_parent()
	while ancestor != null:
		if ancestor.has_method("_director"):
			var director: Node = ancestor.call("_director") as Node
			if director != null and director.has_method("_chapter") and int(director.call("_chapter")) > 1:
				var shape: BoxShape3D = BoxShape3D.new()
				shape.size = Vector3(0.8, 0.5, 0.2)
				$CollisionShape3D.shape = shape
				$CollisionShape3D.position = Vector3(0, 0.7, 0)
			break
		ancestor = ancestor.get_parent()


func bed_id() -> int:
	return bed_number


func entry_seconds() -> float:
	# Shared room 407 numbering: Phuc/Dat above, Viet/Trung below.
	return maxf(0.0, climb_seconds) if bed_number in [1, 4] else 0.0
