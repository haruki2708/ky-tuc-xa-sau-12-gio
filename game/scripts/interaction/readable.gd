extends Interactable

@export var document_id: StringName
@export var size: Vector2 = Vector2(0.21, 0.297):
	set(value):
		size = Vector2(maxf(value.x, 0.01), maxf(value.y, 0.01))
		if is_node_ready():
			_update_size()


func _ready() -> void:
	prompt_key = "PROMPT_READ"
	_update_size()


func _update_size() -> void:
	# Each instance owns its resources so resizing one board cannot resize another.
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(size.x, size.y, 0.004)
	$Mesh.mesh = box
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = box.size
	$CollisionShape3D.shape = shape


func interact(_player: Node) -> void:
	if not enabled:
		return
	var document: DocumentData = DocumentData.load_by_id(document_id)
	if document == null:
		push_warning("Readable document not found: %s" % document_id)
		return
	document.mark_rules_read()
	EventBus.document_opened.emit(document_id)
	EventBus.interacted.emit(self)
