extends Node3D
## Main scene: floor 4 + player + UI. Story flow (T-117) will live here.

## Audio playbacks are released on the audio thread a moment after stop();
## quitting immediately leaves them "still in use at exit".
const QUIT_AUDIO_DRAIN_SECONDS: float = 0.25

var _quitting: bool = false


func _ready() -> void:
	get_tree().auto_accept_quit = false
	place_player(&"seg1_start")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--quit-after-frames="):
			_quit_after_frames(int(arg.trim_prefix("--quit-after-frames=")))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()


## Moves the player onto a checkpoint anchor of floor 4 (docs/design/LAYOUT.md §6).
func place_player(anchor_name: StringName) -> void:
	var anchor := $Floor4/Anchors.get_node_or_null(NodePath(anchor_name)) as Node3D
	if anchor == null:
		push_warning("Main: unknown spawn anchor '%s'" % anchor_name)
		return
	$Player.global_transform = anchor.global_transform


## Clean exit: silence every 3D source, let the audio thread release them, quit.
func quit_game(exit_code: int = 0) -> void:
	if _quitting:
		return
	_quitting = true
	# Pause first so self-healing sources (LightHum restarts while its light is
	# on) cannot start again during the drain; the timer ignores pause.
	get_tree().paused = true
	for node in find_children("*", "AudioStreamPlayer3D", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		(node as AudioStreamPlayer3D).stop()
	await get_tree().create_timer(QUIT_AUDIO_DRAIN_SECONDS, true, false, true).timeout
	get_tree().quit(exit_code)


func _quit_after_frames(frames: int) -> void:
	for i in maxi(frames, 1):
		await get_tree().process_frame
	quit_game()
