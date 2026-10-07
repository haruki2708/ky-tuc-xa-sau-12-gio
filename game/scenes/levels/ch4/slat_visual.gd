extends Marker3D
## Visual only; lane A owns the hold interaction and lane D the readable scrap.
@export var bed: int = 1
var flipped: bool = false
var _turn: Tween
var _net: Node3D
var _net_visible: bool = true


func _ready() -> void:
	EventBus.bed_slat_flipped.connect(_on_flipped)
	call_deferred("_bind_net")


func _bind_net() -> void:
	var campus := get_node_or_null("../../../..")
	if campus == null or campus.get("floor4_path") == null:
		return
	var floor4 := campus.get_node_or_null(campus.floor4_path)
	if floor4 == null:
		return
	var path: String = {1: "BunkA/Net_Phuc", 2: "BunkA/Net_Viet", 4: "BunkB/Net_Dat"}.get(bed, "")
	if path.is_empty():
		return
	_net = floor4.get_node("Room407/" + path)
	_net_visible = _net.visible


func _on_flipped(number: int) -> void:
	if number == bed:
		set_flipped(true)


func set_flipped(value: bool) -> void:
	flipped = value
	if is_instance_valid(_net):
		_net.visible = _net_visible and not value
	if _turn != null and _turn.is_valid():
		_turn.kill()
	_turn = create_tween()
	var angle := deg_to_rad(-70.0 if bed == 4 else 70.0) if value else 0.0
	_turn.tween_property($Hinge, "rotation:z", angle, .45)


func _exit_tree() -> void:
	if is_instance_valid(_net):
		_net.visible = _net_visible
