extends Node3D
## T-262 (D-180): the realistic gate (gate.tscn Real), the south wall (campus.tscn WallSouth) and the A16 gate strip
## (campus.tscn StripGate). Visual only: no collider, light or sound. Set once when the scene loads (nothing per frame):
## the booth's interior is drawn only within 30 m (seen through its window); the wall's 3D iron bars within 45 m, a flat
## bar card from there on, crossfading over 5 m; the street props stop drawing where the PS1 props did (125 m, papers
## 80 m); flat pieces (court, lawn, walk, cracks, papers, bar cards) cast no shadow.
const INTERIOR_RANGE := 30.0
const BARS_NEAR := 45.0
const FADE := 5.0
const PROPS_RANGE := 125.0
const LITTER_RANGE := 80.0
const FLAT := ["Pavers", "Pavement", "Street", "Kerb", "Cracks", "Lawn", "Walk", "Kerbs", "Litter"]


func _ready() -> void:
	for mesh: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
		var mesh_name := String(mesh.name)
		if mesh_name == "Interior":
			mesh.visibility_range_end = INTERIOR_RANGE
			mesh.visibility_range_end_margin = FADE
			mesh.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		elif mesh_name.begins_with("BarsNear"):
			mesh.visibility_range_end = BARS_NEAR
			mesh.visibility_range_end_margin = FADE
			mesh.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		elif mesh_name.begins_with("BarsFar"):
			mesh.visibility_range_begin = BARS_NEAR
			mesh.visibility_range_begin_margin = FADE
			mesh.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		elif mesh_name in ["Cars", "Furniture", "Props", "Rubble", "Rods"] and mesh.get_parent().name == &"Props":
			mesh.visibility_range_end = PROPS_RANGE
		if mesh_name == "Litter":
			mesh.visibility_range_end = LITTER_RANGE
		if mesh_name in FLAT:
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
