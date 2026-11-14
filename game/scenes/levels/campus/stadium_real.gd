extends Node3D
## T-261 (D-178): the stadium's realistic-graphics layer (A13). Visual only: stadium.tscn's PS1 nodes, colliders,
## Floodlights and its four lights stay as they were, their meshes hidden. The floodlight lamps' glass glows only while
## Floodlights is shown (campus.set_stadium_lights): one shared material whose emission follows the node's
## visibility_changed signal, no per-frame processing. Net, chain-link, litter and lines cast no shadow; small props
## fade out with distance as the PS1 props did.

const NO_SHADOW := ["Net", "Mesh", "Litter", "Marks", "Kerb"]
const FADE := {"Props": 125.0, "Crates": 125.0, "Litter": 80.0, "Pipes": 80.0}
const GLASS := "W4FloodGlass"

var glow: StandardMaterial3D
var _energy := 0.0
var _floodlights: Node3D


func _ready() -> void:
	for mesh: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
		var part := String(mesh.name)
		if part in NO_SHADOW:
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if FADE.has(part):
			mesh.visibility_range_end = FADE[part]
			mesh.visibility_range_end_margin = 10.0
	_floodlights = get_parent().get_node_or_null("Floodlights") as Node3D
	for mesh: MeshInstance3D in get_node("Poles").find_children("*", "MeshInstance3D", true, false):
		for surface in mesh.mesh.get_surface_count():
			var material := mesh.mesh.surface_get_material(surface)
			if material == null or material.resource_name != GLASS:
				continue
			if glow == null:
				glow = (material as StandardMaterial3D).duplicate() as StandardMaterial3D
				_energy = glow.emission_energy_multiplier
			mesh.set_surface_override_material(surface, glow)
	if _floodlights != null:
		_floodlights.visibility_changed.connect(_update_glow)
	_update_glow()


func _update_glow() -> void:
	if glow != null:
		glow.emission_energy_multiplier = _energy if _floodlights != null and _floodlights.visible else 0.0
