extends Node3D
## Core chooses the ending; this API changes only the occupied-bed visuals.


func set_companions_visible(value: bool) -> void:
	$Bed_Nhat/Patient.visible = value
	$Bed_Ngu/Patient.visible = value
