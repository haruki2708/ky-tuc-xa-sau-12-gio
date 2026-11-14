extends Node3D
## T-259 (D-175): a realistic-graphics layer (the garden, A12; the B-to-garden strip, A16). Visual only: garden.tscn's
## and props.tscn's PS1 nodes, colliders, anchors and lights stay as they were, their meshes hidden. Leaf, flower and
## litter cards cast no shadow; each tree shows its far version (BarkFar, LeavesFar) beyond FAR_FROM metres.

const FAR_FROM := 40.0
const FAR_MARGIN := 4.0
const NO_SHADOW := ["Leaves", "LeavesFar", "Planting", "Litter"]


func _ready() -> void:
	for mesh: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
		var part := String(mesh.name)
		if part in NO_SHADOW:
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if part == "Bark" or part == "Leaves":
			mesh.visibility_range_end = FAR_FROM
			mesh.visibility_range_end_margin = FAR_MARGIN
		elif part == "BarkFar" or part == "LeavesFar":
			mesh.visibility_range_begin = FAR_FROM
			mesh.visibility_range_begin_margin = FAR_MARGIN
