extends TestCase
## T-244 (D-161): the chapter wires lane E's door sounds itself: chapter 1's bathroom and balcony doors
## have them, chapter 2 (same scene script, also with the body) has none until the owner hears them.

var chapter: Node3D
var old_mute: bool
var old_resume: StringName


func before_each() -> void:
	old_mute = AudioServer.is_bus_mute(0)
	old_resume = Chapter1Director.resume_checkpoint
	AudioServer.set_bus_mute(0, true)
	Chapter1Director.resume_checkpoint = &""


func after_each() -> void:
	tree.paused = false
	if is_instance_valid(chapter):
		chapter.queue_free()
	await wait_frames(2)
	GameState.reset()
	RuleSystem.reset()
	Chapter1Director.resume_checkpoint = old_resume
	AudioServer.set_bus_mute(0, old_mute)


func _open(path: String, director_name: String) -> Node3D:
	chapter = (load(path) as PackedScene).instantiate() as Node3D
	(chapter.get_node(director_name) as Chapter1Director).auto_start = false
	tree.root.add_child(chapter)
	await wait_frames(3)
	chapter.get_node("Player").set_physics_process(false)
	return chapter.get_node("Floor4/Room407") as Node3D


func test_chapter1_doors_have_their_sounds() -> void:
	var room: Node3D = await _open("res://scenes/main/chapter1.tscn", "Chapter1Director")
	for path: String in HingedDoorAudio.DOORS:
		var door := HingedDoor.of(room.get_node(path))
		assert_not_null(door, path)
		if door == null:
			continue
		assert_eq(_sources(door), 1, "one source: " + path)
		assert_false((door.get_node("HingedDoorAudio") as AudioStreamPlayer3D).playing, "silent at the start: " + path)


func test_chapter2_doors_stay_silent() -> void:
	var room: Node3D = await _open("res://scenes/main/chapter2.tscn", "Chapter2Director")
	assert_eq(_sources(room), 0, "chapter 2 has no door sounds yet")


func _sources(root: Node) -> int:
	return root.find_children("*", "AudioStreamPlayer3D", true, false).filter(
		func(node: Node) -> bool: return node is HingedDoorAudio).size()
