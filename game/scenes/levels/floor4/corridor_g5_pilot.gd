extends Node3D
## T-235 (D-144): the whole floor-4 corridor in room 407's style, walked with the player over Floor4. Since T-237
## (D-148) floor4.gd builds the corridor itself with corridor_shell.gd; this pilot uses that same corridor and adds
## the variants the owner did not pick, so they can still be compared here (never in the playable build).
## G switches between the new corridor and the PS1 one, N between the two room plates (aluminium, chosen / blue
## enamel), M between the two looks of the old 408 doorway (walled up, chosen / boarded over).
## Sources: art_source/graphics_upgrade/floor4_corridor/.

const VARIANTS: Array[String] = ["plates_enamel", "seal_board"]
const PLATE_STYLES: Array[String] = ["alu", "enamel"]
const SEAL_LOOKS: Array[String] = ["walled", "boarded"]

@export var start_upgraded := true
var floor4: Node3D
var corridor: Node3D


func _ready() -> void:
	floor4 = $Floor4
	corridor = add_variants(floor4)
	Floor4CorridorShell.set_upgraded(floor4, start_upgraded)


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode == KEY_G:
		Floor4CorridorShell.set_upgraded(floor4, not corridor.visible)
	elif key.keycode == KEY_N:
		set_plates(floor4, "enamel" if (corridor.get_node("plates_alu") as Node3D).visible else "alu")
	elif key.keycode == KEY_M:
		set_seal(floor4, "walled" if (corridor.get_node("seal_board") as Node3D).visible else "boarded")


## The floor's corridor (built if the floor has none) with the unpicked variants added, hidden: the chosen looks.
static func add_variants(floor4: Node3D) -> Node3D:
	var root := Floor4CorridorShell.build(floor4)
	for part: String in VARIANTS:
		if not root.has_node(part):
			Floor4CorridorShell.add_part(root, part).visible = false
	return root


## "alu" (D-148): anodised aluminium with raised black digits; "enamel": blue enamel, white digits.
static func set_plates(floor4: Node3D, style: String) -> void:
	var root := floor4.get_node(Floor4CorridorShell.ROOT)
	for each: String in PLATE_STYLES:
		(root.get_node("plates_" + each) as Node3D).visible = each == style


## "walled" (D-148): the old 408 doorway bricked up and plastered inside its old frame; "boarded": planks over it.
static func set_seal(floor4: Node3D, look: String) -> void:
	(floor4.get_node(Floor4CorridorShell.ROOT + "/seal_board") as Node3D).visible = look == "boarded"
