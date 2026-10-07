extends TestCase

var _nodes: Array[Node] = []
var _state: Dictionary
var _rules: Dictionary
var _resume: StringName
var _mouse_mode: Input.MouseMode
var _had_settings: bool
var _settings: PackedByteArray


func before_each() -> void:
	_state = GameState.to_dict()
	_rules = RuleSystem.to_dict()
	_resume = Chapter1Director.resume_checkpoint
	_mouse_mode = Input.mouse_mode
	_had_settings = FileAccess.file_exists("user://settings.cfg")
	if _had_settings:
		_settings = FileAccess.get_file_as_bytes("user://settings.cfg")
	var config := ConfigFile.new()
	config.set_value("ui", "locale", "vi")
	assert_eq(config.save("user://settings.cfg"), OK)
	Chapter1Director.resume_checkpoint = &""
	GameState.reset()
	GameState.chapter = 1


func after_each() -> void:
	for node in _nodes:
		_stop_audio(node)
	await tree.create_timer(0.1).timeout
	for node in _nodes:
		node.queue_free()
	await wait_frames(3)
	GameState.from_dict(_state)
	RuleSystem.from_dict(_rules)
	Chapter1Director.resume_checkpoint = _resume
	Input.mouse_mode = _mouse_mode
	if _had_settings:
		var file := FileAccess.open("user://settings.cfg", FileAccess.WRITE)
		file.store_buffer(_settings)
		file.close()
	else:
		DirAccess.remove_absolute("user://settings.cfg")
	if FileAccess.file_exists("user://t200_checkpoint.json"):
		DirAccess.remove_absolute("user://t200_checkpoint.json")


func _stop_audio(node: Node) -> void:
	if node.has_method("stop_emitting"):
		node.stop_emitting()
	if node is AudioStreamPlayer or node is AudioStreamPlayer3D:
		node.stop()
	for child in node.get_children():
		_stop_audio(child)


func _add(node: Node) -> void:
	_nodes.append(node)
	tree.root.add_child(node)


func _scene(chapter: int) -> Node:
	var scene := (load("res://scenes/main/chapter%d.tscn" % chapter) as PackedScene).instantiate()
	scene.get_node("Chapter%dDirector" % chapter).auto_start = false
	_add(scene)
	return scene


func _assert_message(phone: PhoneCallAudio, message_id: StringName) -> void:
	var message := MessageData.load_by_id(message_id)
	assert_not_null(message)
	EventBus.phone_message_received.emit(message_id)
	var speech := phone.get_node("Speech") as AudioStreamPlayer
	assert_true(speech.playing, String(message_id))
	assert_eq(speech.bus, &"PhoneVoice")
	assert_eq(speech.stream.resource_path, "res://audio/voice/vi/%s.ogg" % message.text_key)
	assert_true(speech.volume_db <= 0.0)
	assert_false(phone._ring.playing or phone._remote_ring.playing, "no incoming ring on an ongoing call")


func _real_call(chapter: int, message_id: StringName) -> void:
	var scene := _scene(chapter)
	await wait_frames(3)
	var phone := scene.get_node("PhoneCallAudio") as PhoneCallAudio
	# Same protocol as Chapter1Director.start; auto_start=false skips the story.
	GameState.chapter = chapter
	EventBus.chapter_started.emit(chapter)
	assert_true(phone._in_call)
	assert_eq(phone._call_id, StringName("ch%d_group" % chapter))
	_assert_message(phone, message_id)
	EventBus.phone_call_lost.emit(phone._call_id)
	assert_false(phone._speech.playing)
	EventBus.checkpoint_loaded.emit(StringName("ch%d_audio_fixture" % chapter))
	assert_true(phone._in_call and not phone._connection_lost)
	_assert_message(phone, message_id)


func test_real_chapter2_phone_speaks_without_answer_and_after_checkpoint() -> void:
	await _real_call(2, &"chat_ch2_n_28")


func test_real_chapter3_phone_speaks_without_answer_and_after_checkpoint() -> void:
	await _real_call(3, &"chat_ch3_n_all_up")


func test_real_chapter4_phone_speaks_without_answer_and_after_checkpoint() -> void:
	await _real_call(4, &"chat_ch4_n_go")


func test_real_chapter1_still_rings_and_requires_matching_answer() -> void:
	var scene := _scene(1)
	await wait_frames(3)
	var phone := scene.get_node("PhoneCallAudio") as PhoneCallAudio
	EventBus.chapter_started.emit(1)
	EventBus.phone_message_received.emit(&"chat_ch1_kiet_306")
	assert_false(phone._in_call or phone._speech.playing)
	EventBus.phone_call_incoming.emit(&"stranger_call")
	assert_true(phone._ring.playing)
	EventBus.phone_call_answered.emit(&"wrong")
	EventBus.phone_message_received.emit(&"chat_ch1_kiet_306")
	assert_false(phone._speech.playing)
	EventBus.phone_call_answered.emit(&"stranger_call")
	_assert_message(phone, &"chat_ch1_kiet_306")
	EventBus.checkpoint_loaded.emit(&"ch1_r2")
	assert_false(phone._in_call or phone._speech.playing or phone._ring.playing)


func test_group_loss_restore_filters_and_terminal_stop_do_not_replay_queue() -> void:
	var phone := PhoneCallAudio.new()
	_add(phone)
	EventBus.chapter_started.emit(4)
	_assert_message(phone, &"chat_ch4_n_lost")
	EventBus.phone_message_received.emit(&"chat_ch4_ngu_go")
	assert_eq(phone._queue.size(), 1)
	EventBus.phone_call_lost.emit(&"wrong")
	assert_false(phone._connection_lost)
	EventBus.phone_call_lost.emit(&"ch4_group")
	assert_true(phone._connection_lost)
	assert_false(phone._speech.playing)
	assert_true(phone._queue.is_empty())
	EventBus.phone_message_received.emit(&"chat_ch4_n_go")
	EventBus.phone_call_restored.emit(&"wrong")
	assert_true(phone._connection_lost)
	EventBus.phone_call_restored.emit(&"ch4_group")
	assert_false(phone._connection_lost or phone._speech.playing)
	_assert_message(phone, &"chat_ch4_n_got")
	EventBus.chat_member_changed.emit(&"minh_nhat", &"dead")
	EventBus.phone_message_received.emit(&"chat_ch4_n_go")
	assert_false(phone._speech.playing, "dead member stays silent")
	EventBus.chat_member_changed.emit(&"minh_nhat", &"joined")
	_assert_message(phone, &"chat_ch4_n_go")
	phone.end_call(false)
	EventBus.chapter_started.emit(4)
	var message := MessageData.new()
	message.spoken = true
	message.sender = &"ngu"
	for key in ["CHAT_CH0_GO", "CHAT_CH5_GO", "CHAT_CH44_GO", "CHAT_CH4_../SPK_CH4_REGISTERED", "CHAT_CH4_N/go", "CHAT_CH4_n_go", "SAY_CH4_TRUNG_ASK", "NEAR_CH4_NURSE1_AWAKE"]:
		message.text_key = key
		assert_eq(phone.play_message(message), 0.0, key)
	EventBus.phone_message_received.emit(&"../chat_ch4_n_go")
	assert_false(phone._speech.playing)
	phone.stop_emitting()
	GameState.chapter = 4
	EventBus.chapter_started.emit(4)
	EventBus.checkpoint_loaded.emit(&"ch4_split")
	EventBus.phone_call_restored.emit(&"ch4_group")
	EventBus.phone_message_received.emit(&"chat_ch4_n_go")
	assert_false(phone._in_call or phone._speech.playing or phone._ring.playing)


func test_checkpoint_uses_restored_chapter_and_clears_previous_call_members() -> void:
	var phone := PhoneCallAudio.new()
	_add(phone)
	GameState.chapter = 2
	assert_eq(Checkpoint.save(&"ch2_audio_fixture", "user://t200_checkpoint.json"), OK)
	GameState.chapter = 4
	EventBus.chapter_started.emit(4)
	EventBus.chat_member_changed.emit(&"minh_nhat", &"dead")
	Checkpoint.restore("user://t200_checkpoint.json")
	assert_eq(phone._call_id, &"ch2_group")
	_assert_message(phone, &"chat_ch2_n_28")
	GameState.chapter = 1
	EventBus.checkpoint_loaded.emit(&"ch1_r2")
	assert_false(phone._in_call)


func test_real_chapter4_pa_and_five_nurse_lines_use_approved_key_files() -> void:
	var scene := _scene(4)
	await wait_frames(3)
	var speaker := scene.get_node("FloorSpeaker") as Speaker
	speaker.set_process(false)
	speaker.play_announcement([{"text_key": "SPK_CH4_REGISTERED"}], 0.1)
	for index in 2:
		speaker.stop()
		speaker.finished.emit()
	assert_true(speaker._voice.playing)
	assert_eq(speaker._voice.stream, Ch4AudioBank.voice("SPK_CH4_REGISTERED"))
	assert_eq(speaker._voice.bus, &"Voice")
	var director := scene.get_node("Chapter4Director") as Chapter4Director
	director.time_scale = 0.001
	var hospital := (load(Chapter4Director.HOSPITAL_SCENE) as PackedScene).instantiate()
	scene.add_child(hospital)
	for key in Ch4AudioBank.VOICES:
		if not key.begins_with("NEAR_CH4_"):
			continue
		var nurse := hospital.get_node("Nurse1" if key.begins_with("NEAR_CH4_NURSE1_") else "Nurse2") as Node3D
		director._voice_at(key, nurse)
		var voice := nurse.get_child(nurse.get_child_count() - 1) as AudioStreamPlayer3D
		assert_not_null(voice)
		if voice != null:
			assert_eq(voice.stream, Ch4AudioBank.voice(key))
			assert_true(voice.playing)
			assert_eq(voice.bus, &"Voice")
			voice.stop()
			voice.queue_free()
		await tree.create_timer(0.05).timeout


func test_chapter_pa_fallback_preserves_path_validation_and_unmasked_rule_block() -> void:
	for key in ["SPK_CH1_WARN", "SPK_CH2_R2_END", "SPK_CH3_R5_INTRO", "SPK_CH4_REGISTERED"]:
		var path := "res://audio/voice/vi/%s.ogg" % key
		assert_true(ResourceLoader.exists(path))
		assert_eq(SpeakerVoiceBank.load_clip("res://audio/voice", "en", key), load(path))
	assert_not_null(SpeakerVoiceBank.load_clip("res://audio/voice", "en", "SPK_CH4_REGISTERED"))
	for key in ["RULE_3", "SPK_CH4_../REGISTERED", "SPK_CH4_registered", "SPK_CH5_REGISTERED", "SPK_CH44_REGISTERED"]:
		assert_eq(SpeakerVoiceBank.load_clip("res://audio/voice", "vi", key), null)
	assert_eq(Ch4AudioBank.voice("SAY_CH4_TRUNG_ASK"), null)
	assert_false(FileAccess.file_exists("res://audio/voice/vi/SAY_CH4_TRUNG_ASK.ogg"))
	assert_false(FileAccess.file_exists("res://audio/ch4_voice/nurse2_quake.ogg"))
