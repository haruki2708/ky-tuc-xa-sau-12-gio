extends Interactable

## D-106: the sheet is drawn as one textured quad on the front (+Z) face; the texture follows
## the readable's look, else the document's DocumentData.look, else its style (D-110).
const LOOKS := {
	&"photocopy": preload("res://assets/textures/papers/photocopy.png"),
	&"handwritten": preload("res://assets/textures/papers/handwritten.png"),
	&"stamped": preload("res://assets/textures/papers/stamped.png"),
	&"notice": preload("res://assets/textures/papers/notice.png"),
	&"log": preload("res://assets/textures/papers/log.png"),
	&"photo": preload("res://assets/textures/papers/photo.png"),
	&"photo_family": preload("res://assets/textures/papers/photo_family.png"),
}
const DEFAULT_LOOK := &"photocopy"
## The sheet floats this far off its surface (no z fighting with desks and walls).
const FACE_OFFSET := 0.0015
static var _materials: Dictionary = {}

@export var document_id: StringName:
	set(value):
		document_id = value
		if is_node_ready():
			_update_look()
@export var pick_depth: float = 0.004:
	set(value):
		pick_depth = maxf(value, 0.001)
		if is_node_ready():
			_update_size()
@export var size: Vector2 = Vector2(0.21, 0.297):
	set(value):
		size = Vector2(maxf(value.x, 0.01), maxf(value.y, 0.01))
		if is_node_ready():
			_update_size()
## Empty: the document's style. Otherwise a key of LOOKS.
@export var look: StringName = &"":
	set(value):
		look = value
		if is_node_ready():
			_update_look()


func _ready() -> void:
	prompt_key = "PROMPT_READ"
	_update_size()
	_update_look()


func _update_size() -> void:
	# Each instance owns its resources so resizing one board cannot resize another.
	var quad: QuadMesh = QuadMesh.new()
	quad.size = size
	$Mesh.mesh = quad
	$Mesh.position.z = FACE_OFFSET
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(size.x, size.y, pick_depth)
	$CollisionShape3D.shape = shape
	$CollisionShape3D.position.z = pick_depth * 0.5
	# Keep the grip on the sheet, independent of the enlarged picking depth.
	var target := get_node_or_null("HandTarget") as HandTarget
	if target != null:
		_place_edge_targets(target)


## T-239: a pinch on each edge, 1.5 cm in from it half way along; the scene's HandTarget is the
## right-hand one. Each turns with its edge (+X out across it, +Z out of the face, the pinch's fingers
## along +Y), so a body takes the edge its reach suits (HandTarget.preference). Each knows how far the
## sheet runs across from it ("sheet_across", for lifting that edge).
const EDGES := {"HandTarget": 0.0, "HandTargetTop": PI / 2.0, "HandTargetLeft": PI, "HandTargetBottom": -PI / 2.0}
const EDGE_INSET := 0.015


func _place_edge_targets(right: HandTarget) -> void:
	for edge: String in EDGES:
		var marker := get_node_or_null(edge) as HandTarget
		if marker == null:
			marker = HandTarget.new()
			marker.name = edge
			marker.grip = right.grip
			marker.pick_up = right.pick_up
			add_child(marker)
		var angle: float = EDGES[edge]
		var out := Vector2(cos(angle), sin(angle)).snapped(Vector2.ONE)
		var across: float = size.x if absf(out.x) > 0.5 else size.y
		marker.position = Vector3(out.x, out.y, 0.0) * maxf(0.0, across * 0.5 - EDGE_INSET) + Vector3(0.0, 0.0, FACE_OFFSET)
		marker.rotation = Vector3(0.0, 0.0, angle)
		marker.set_meta(&"sheet_across", across)


func paper_look() -> StringName:
	if LOOKS.has(look):
		return look
	var document: DocumentData = DocumentData.load_by_id(document_id) if document_id != &"" else null
	if document == null:
		return DEFAULT_LOOK
	if LOOKS.has(document.look):
		return document.look
	return document.style if LOOKS.has(document.style) else DEFAULT_LOOK


func _update_look() -> void:
	var key := paper_look()
	if not _materials.has(key):
		var material := StandardMaterial3D.new()
		material.albedo_texture = LOOKS[key]
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.roughness = 0.55 if String(key).begins_with("photo") else 0.9
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		_materials[key] = material
	$Mesh.material_override = _materials[key]


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
