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
const GAME_SCENE := "res://scenes/main/main.tscn"
## Lane D's title screen (wave 3). Until it exists, the game starts straight in.
const TITLE_SCENE := "res://ui/title/title_screen.tscn"
const STORY_DIRECTOR := preload("res://scripts/core/story_director.gd")

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


## True when there is a checkpoint to continue from (title screen "Continue").
func has_saved_game() -> bool:
	return not Checkpoint.peek_id().is_empty()


## Starts the night from the beginning, or from the last checkpoint.
func start_game(continue_saved: bool = false) -> void:
	STORY_DIRECTOR.resume_checkpoint = Checkpoint.peek_id() if continue_saved else &""
	STORY_DIRECTOR.carry_deviation = 0
	get_tree().paused = false
	get_tree().change_scene_to_file(GAME_SCENE)


## Starts a night from its beginning (title screen chapter select, T-155).
## Chapters past 1 fall back to chapter 1 until their story exists (T-150).
func start_chapter(chapter: int) -> void:
	GameState.reset()
	GameState.chapter = clampi(chapter, 1, Progress.CHAPTER_COUNT)
	Checkpoint.clear()
	start_game(false)


## Back to the title screen (pause menu, end card), or quit if there is none.
func return_to_title() -> void:
	if not ResourceLoader.exists(TITLE_SCENE):
		quit()
		return
	get_tree().paused = false
	get_tree().change_scene_to_file(TITLE_SCENE)


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
