extends HideSpot

@export_range(1, 4, 1) var bed_number: int = 3
@export var climb_seconds: float = 0.5


func _ready() -> void:
	kind = &"bunk"
	prompt_key = "PROMPT_LIE_DOWN"


func bed_id() -> int:
	return bed_number


func entry_seconds() -> float:
	# Shared room 407 numbering: Phuc/Dat above, Viet/Trung below.
	return maxf(0.0, climb_seconds) if bed_number in [1, 4] else 0.0
