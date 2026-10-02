extends Node
## Load a script with project autoloads available, without instantiating it.


func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--qa-parse="):
			var script := load(arg.trim_prefix("--qa-parse=")) as GDScript
			get_tree().quit(0 if script != null and script.can_instantiate() else 1)
			return
	get_tree().quit(1)
