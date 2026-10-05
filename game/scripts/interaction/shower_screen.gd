class_name ShowerScreen
extends Interactable
## Only continuous held input while looking at this region counts as wiping.

signal wiped

const WIPE_SECONDS: float = 1.0
var progress: float = 0.0
var _player: Node
var _completed: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE


func interact(player: Node) -> void:
	if enabled and CarryItem.player_can_use(player) and _focused_by(player):
		_player = player


func _focused_by(player: Node) -> bool:
	var ray: RayCast3D = player.get_node_or_null("Head/Camera3D/InteractRay") as RayCast3D
	if ray == null:
		return false
	ray.force_raycast_update()
	return ray.get_collider() == self


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	if not enabled or not CarryItem.player_can_use(_player) \
			or not Input.is_action_pressed("interact") or not _focused_by(_player):
		progress = 0.0
		_completed = false
		_player = null
		return
	if _completed:
		return
	progress = minf(WIPE_SECONDS, progress + delta)
	if progress >= WIPE_SECONDS - 0.000001:
		_completed = true
		wiped.emit()
		EventBus.interacted.emit(self)
