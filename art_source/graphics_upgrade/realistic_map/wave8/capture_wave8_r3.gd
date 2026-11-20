extends "capture_wave8_r2.gd"
## T-265 round 3 stills (card 1.14, D-186): the well's new railings in chapter 4's real scene as patched, night as the
## chapter opens, with and without the torch (round 2's camera, torch and loading; after only).
## Copy this file and capture_wave8_r2.gd to game/_probe_tmp/ with a scene whose root has this one, then (Lượt Godot)
##   godot --path game --log-file <log> res://_probe_tmp/capture_wave8_r3.tscn [-- --views=f3_south_edge,...]
## Writes previews/wave8/r3_<view>[_torch].jpg; make_wave8_sheets.py round3 puts them in r3_well.jpg.
const R3_VIEWS := {
	# Floor 3 from StairFoot2: WellRail_F3S across the south edge, the drop to flight two behind it, WellRail_F3NE far right.
	"f3_south_edge": {"eye": Vector3(79.6, -1.7, 196.0), "target": Vector3(82.6, -4.2, 203.0), "torch": true, "fov": 80.0},
	# Floor 2 at the foot of flight two: WellRail_F2SE closing the east slot beside the open way up.
	"f2_flight_two": {"eye": Vector3(80.4, -5.0, 196.0), "target": Vector3(84.0, -6.3, 200.5), "torch": true, "fov": 80.0},
	# Floor 2 at flight one's top, looking south down the east slot: WellRail_F2NE.
	"f2_east_slot": {"eye": Vector3(82.6, -5.0, 211.9), "target": Vector3(84.5, -6.6, 206.5), "torch": true, "fov": 80.0},
}


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Capture needs a window.")
		App.quit(1)
		return
	get_window().mode = Window.MODE_WINDOWED
	get_window().content_scale_size = RESOLUTION
	get_window().size = RESOLUTION
	get_viewport().scaling_3d_scale = 1.0
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	AudioServer.set_bus_mute(0, true)
	_camera()
	await _load_chapter("res://scenes/main/chapter4.tscn", "Chapter4Director")
	_apply(true)
	await _shoot("r3", R3_VIEWS, _pick(R3_VIEWS, _arg("views", "")), true)
	print("RESULT: t265 round 3 capture %d images" % count)
	App.quit()
