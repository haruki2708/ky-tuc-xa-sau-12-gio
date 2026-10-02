extends Node
## Autoload App: one clean way to quit for every scene.
## Audio playbacks are released on the audio thread a moment after stop();
## quitting at once leaves "resources still in use at exit". So quit() pauses
## the tree (self-healing sources such as LightHum cannot restart), stops every
## player, waits briefly, then quits. Owner: integrator.
##
## Window close (X) goes through here. Tools and the pause menu call
## App.quit(); headless/QA runs pass `-- --quit-after-frames=N` instead of the
## engine's --quit-after, which bypasses this drain.

const AUDIO_DRAIN_SECONDS: float = 0.25
const QUIT_AFTER_ARG := "--quit-after-frames="

var _quitting: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().auto_accept_quit = false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(QUIT_AFTER_ARG):
			_quit_after_frames(int(arg.trim_prefix(QUIT_AFTER_ARG)))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit()


func is_quitting() -> bool:
	return _quitting


func quit(exit_code: int = 0) -> void:
	if _quitting:
		return
	_quitting = true
	get_tree().paused = true
	for node in get_tree().root.find_children("*", "", true, false):
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
			node.stop()
	await get_tree().create_timer(AUDIO_DRAIN_SECONDS, true, false, true).timeout
	get_tree().quit(exit_code)


func _quit_after_frames(frames: int) -> void:
	for i in maxi(frames, 1):
		await get_tree().process_frame
	quit()
