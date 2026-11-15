extends Node3D
## T-263 (D-181): the realistic canteen (canteen.tscn Real: hall, kitchen, store, the outside walls and roof, the bikes)
## and the A16 strip round it (campus.tscn StripCanteen). Visual only: no collider, light or sound. Set once when the
## scene loads (nothing per frame): what is only seen in or near the canteen stops drawing at a range from its mesh's
## centre (the tables and the tableware, the counter, the kitchen, the store, the east side's fixtures, the bikes, the
## strip's dropped things); small and flat things cast no shadow (the canteen's own lights cast none; the torch does).
const RANGES := {"Tables": 60.0, "Tableware": 40.0, "Counter": 50.0, "PriceBoards": 50.0, "LightsFans": 60.0, "KitchenRoom": 45.0,
	"Stove": 45.0, "Clock": 45.0, "HallEast": 45.0, "Store": 40.0, "Bikes": 80.0, "Props": 80.0}
const NO_SHADOW := ["Trays", "Ware", "PanFood", "SneezeGlass", "PriceBoards", "PriceChains", "Battens", "Tubes", "Fans", "Clock",
	"EastSmall", "Mirrors", "Posters", "ACIndoor", "Thresholds", "StoreThings", "KitchenThings", "Pots", "OutsideSmall", "Bikes",
	"Lawn", "Pavers", "Yard", "Kerbs", "Gutters", "Litter", "Dropped", "StripTrays", "Screen"]


func _ready() -> void:
	for layer in get_children():
		var far: float = RANGES.get(String(layer.name), 0.0)
		for mesh: MeshInstance3D in layer.find_children("*", "MeshInstance3D", true, false):
			if far > 0.0:
				mesh.visibility_range_end = far
			if String(mesh.name) in NO_SHADOW:
				mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# The TV's lit screen hangs under TV/Screen (campus.gd toggles that node), outside this layer.
	var lit := get_node_or_null("../TV/Screen/Lit")
	if lit != null:
		for mesh: MeshInstance3D in lit.find_children("*", "MeshInstance3D", true, false):
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
