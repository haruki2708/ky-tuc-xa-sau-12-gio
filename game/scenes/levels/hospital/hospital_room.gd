extends Node3D
## Core chooses the ending; this API changes only the occupied-bed visuals.
## T-266 (D-187 point 10): the lonely ending's two beds show a flat sheet with the blanket folded at the foot (Empty).


func set_companions_visible(value: bool) -> void:
	$Bed_Nhat/Patient.visible = value
	$Bed_Ngu/Patient.visible = value
	for bed in ["Bed_Nhat", "Bed_Ngu"]:
		var empty := get_node_or_null(bed + "/Empty") as Node3D
		if empty != null:
			empty.visible = not value
