extends Node3D
## T-264 (D-182): the realistic background buildings (shells.tscn Real: building A, the lecture hall, the gym; the three
## window figures) and building B's outside (building_b.tscn Real). Visual only: no collider, light or sound. Set once
## when the scene loads (nothing per frame): glass, fake rooms, grilles, frames and the small things on the fronts cast
## no shadow (the walls, bands and roofs still do); grilles and small things stop drawing at a range from their mesh's
## centre (a whole front's worth, so the range is long enough for the view from building B's floor-4 corridor).
const NO_SHADOW := ["Glass", "Fake", "Bars", "Extras", "Frames", "Figure"]
const RANGES := {"Bars": 90.0, "Extras": 90.0}


func _ready() -> void:
	for mesh: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
		var name := String(mesh.name)
		if name in NO_SHADOW:
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh.visibility_range_end = RANGES.get(name, 0.0)
	# The figures hang under the WindowSilhouette nodes, outside this layer.
	for k in 3:
		var figure := get_node_or_null("../WindowSilhouette%d/Figure" % k)
		if figure != null:
			for mesh: MeshInstance3D in figure.find_children("*", "MeshInstance3D", true, false):
				mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
