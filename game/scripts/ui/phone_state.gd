extends RefCounted
## Serializable presentation state. Gameplay remains owned by the core/player.

var history: Array[Dictionary] = []
var members: Dictionary = {}
var raised := false
var battery := 100.0
var minutes := 0
var flashlight := false
var incoming := ""
var call := ""
var choice := ""
var options := PackedStringArray()
var remaining := 0.0
var selected := 0
var disconnected_choice := false


func snapshot() -> Dictionary:
	return {"version": 1, "history": history.duplicate(true), "members": members.duplicate(true),
		"raised": raised, "battery": battery, "minutes": minutes, "flashlight": flashlight,
		"incoming": incoming, "call": call, "choice": choice, "options": Array(options),
		"remaining": remaining, "selected": selected, "disconnected_choice": disconnected_choice}


func restore(data: Dictionary) -> void:
	if data.get("version", 0) != 1:
		return
	history.clear()
	members.clear()
	var saved_history: Variant = data.get("history", [])
	if saved_history is Array:
		for entry: Variant in saved_history:
			if entry is Dictionary and entry.get("text_key", "") is String and not entry.get("text_key", "").is_empty():
				history.append({"id": str(entry.get("id", "")), "sender": str(entry.get("sender", "")),
					"name_key": str(entry.get("name_key", "")), "text_key": entry["text_key"],
					"minutes": maxi(0, int(entry.get("minutes", 0))),
					"outgoing": entry.get("outgoing", false) == true, "spoken": entry.get("spoken", false) == true})
	var saved_members: Variant = data.get("members", {})
	if saved_members is Dictionary:
		for id: Variant in saved_members:
			var entry: Variant = saved_members[id]
			if entry is Dictionary and entry.get("state", "") in ["joined", "dead", "left"]:
				members[str(id)] = {"state": entry["state"], "name_key": str(entry.get("name_key", ""))}
	raised = data.get("raised", false) == true
	var percent: float = float(data.get("battery", 100.0))
	battery = clampf(percent, 0.0, 100.0) if is_finite(percent) else 100.0
	minutes = maxi(0, int(data.get("minutes", 0)))
	flashlight = data.get("flashlight", false) == true and battery > 0.0
	incoming = str(data.get("incoming", "")) if battery > 0.0 else ""
	call = str(data.get("call", "")) if battery > 0.0 else ""
	choice = str(data.get("choice", ""))
	options.clear()
	var saved_options: Variant = data.get("options", [])
	if saved_options is Array:
		for key: Variant in saved_options.slice(0, 4):
			if key is String and not key.is_empty():
				options.append(key)
	remaining = maxf(0.0, float(data.get("remaining", 0.0)))
	if not is_finite(remaining):
		remaining = 0.0
	selected = clampi(int(data.get("selected", 0)), 0, maxi(0, options.size() - 1))
	disconnected_choice = data.get("disconnected_choice", false) == true or battery <= 0.0
	if options.size() < 2:
		choice = ""
		options.clear()
