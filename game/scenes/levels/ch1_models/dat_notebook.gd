extends Node3D
## Caller supplies already-localized, approved content. No default birthday/code.
var _content: PackedStringArray = ["", "", ""]


func _ready() -> void:
	_apply_content()


func set_content(title: String, student_name: String, birth_date: String) -> void:
	_content = PackedStringArray([title, student_name, birth_date])
	if is_node_ready():
		_apply_content()


func _apply_content() -> void:
	var labels: Array[Label3D] = [$Title, $Name, $BirthDate]
	for i in range(labels.size()):
		labels[i].text = _content[i]
