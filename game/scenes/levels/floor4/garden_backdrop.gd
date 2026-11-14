extends Node3D
## T-259 (D-175, A05): the light copy of the garden floor 4 looks down on in chapters 1-2, where there is no campus:
## lawn, paving, beds, far trees, lamps and the distant street lamp's pole, at the campus's world coordinates. No
## collision, no shadow. campus.gd hides it (and floor 4's old yard boxes) when the full campus is there.


func _ready() -> void:
	for mesh: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
