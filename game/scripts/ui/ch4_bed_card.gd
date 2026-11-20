extends Node3D
## Attach below Bed_*/Card. The owner can override the inferred character explicitly.
## T-266 (D-187 point 11): the card reads from both faces (NameBack / DetailsBack copy Name / Details).

@export_enum("auto", "trung", "nhat", "ngu") var character := "auto"
@export var age_text := ""
var ending: StringName = &"alone"
var _character := "trung"


func _ready() -> void:
	_character = character
	if character == "auto":
		_character = "trung"
		var ancestor := get_parent()
		while ancestor != null:
			if ancestor.name in [&"Bed_Trung", &"Bed_Nhat", &"Bed_Ngu"]:
				_character = String(ancestor.name).trim_prefix("Bed_").to_lower()
				break
			ancestor = ancestor.get_parent()
	ending = StringName(str(GameState.get_flag(&"ch4_ending", "alone")))
	EventBus.ch4_ending.connect(_ending)
	refresh()


func _ending(kind: StringName) -> void:
	if kind not in [&"all", &"alone"]:
		return
	ending = kind
	refresh()


func refresh() -> void:
	visible = _character == "trung" or ending == &"all"
	$Name.text = tr("UI_CH4_PATIENT_" + _character.to_upper())
	$Details.text = ""
	if not age_text.is_empty():
		$Details.text = tr("UI_CH4_FORM_AGE") + ": " + age_text
	if _character != "trung":
		$Details.text += ("\n" if not age_text.is_empty() else "") + tr("UI_CH4_COMA")
	for pair: Array in [["Name", "NameBack"], ["Details", "DetailsBack"]]:
		var back := get_node_or_null(String(pair[1])) as Label3D
		if back != null:
			back.text = (get_node(String(pair[0])) as Label3D).text


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		refresh()
