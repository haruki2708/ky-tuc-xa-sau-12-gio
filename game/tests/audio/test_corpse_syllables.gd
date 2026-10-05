extends TestCase

var _nodes: Array[Node] = []
var _bus_count: int


func before_each() -> void:
	_bus_count = AudioServer.bus_count


func after_each() -> void:
	tree.paused = false
	for node in _nodes:
		if node.has_method("stop_emitting"):
			node.stop_emitting()
		node.free()
	await tree.create_timer(0.1).timeout
	assert_eq(AudioServer.bus_count, _bus_count, "private buses cleaned")


func _corpse(id: String = "phuc") -> CorpseVoice:
	var corpse := CorpseVoice.new()
	corpse.speaker = id
	_nodes.append(corpse)
	tree.root.add_child(corpse)
	return corpse


func test_real_dictionary_word_has_both_cuts_in_order_and_pitch_duration() -> void:
	var clips := Ch2SyllableBank.clips_for("khuất bóng")
	assert_eq(clips.size(), 2)
	for id in ["phuc", "viet", "dat"]:
		var corpse := _corpse(id)
		var started := Time.get_ticks_usec()
		var seconds := corpse.play_word("khuất bóng")
		print("SYLLABLE BUILD ", id, ": ", Time.get_ticks_usec() - started, " us")
		var phrase := corpse._voice.stream as AudioStreamWAV
		assert_not_null(phrase)
		if phrase == null:
			continue
		var pitch := corpse._voice.pitch_scale
		var expected := (float(clips[0].length) + float(clips[1].length)) / pitch + 0.08
		assert_true(absf(seconds - expected) < 0.0002, "duration includes one real-time gap")
		assert_true(seconds < Ch2SyllableBank.seconds_for("khuất bóng") / 0.72 + 0.3, "fits core wait")
		assert_eq(corpse._voice.volume_db, -6.0)
		assert_eq(AudioServer.get_bus_send(AudioServer.get_bus_index(corpse._voice.bus)), &"Voice")
		assert_true(corpse._voice.playing)
		var first_count := roundi(float(clips[0].length) * phrase.mix_rate)
		var gap := roundi(0.08 * pitch * phrase.mix_rate)
		var cursor := 0
		for index in 2:
			var source: AudioStream = clips[index].stream
			var playback := source.instantiate_playback()
			playback.start(float(clips[index].start))
			var count := roundi(float(clips[index].length) * phrase.mix_rate)
			var original := playback.mix_audio(1.0, count)
			playback.stop()
			var error := 0.0
			var energy := 0.0
			# Compare interior PCM against the exact source cut, excluding fade edges.
			for frame in range(roundi(0.02 * phrase.mix_rate), count - roundi(0.02 * phrase.mix_rate), 13):
				var actual := float(phrase.data.decode_s16((cursor + frame) * 4)) / 32767.0
				error = maxf(error, absf(actual - original[frame].x))
				energy += actual * actual
			assert_true(error < 0.00004, "piece %d preserves source order and gain" % index)
			assert_true(energy > 0.001, "piece %d is not silence" % index)
			assert_eq(phrase.data.decode_s16(cursor * 4), 0, "zero at cut start")
			assert_eq(phrase.data.decode_s16((cursor + count - 1) * 4), 0, "zero at cut end")
			cursor += count + gap
		for frame in range(first_count, first_count + gap):
			assert_eq(phrase.data.decode_s16(frame * 4), 0, "silent gap")
		assert_eq(phrase.loop_mode, AudioStreamWAV.LOOP_DISABLED)


func test_fades_are_baked_at_sample_edges_and_ranges_do_not_leak() -> void:
	var source := AudioStreamWAV.new()
	source.format = AudioStreamWAV.FORMAT_16_BITS
	source.mix_rate = int(AudioServer.get_mix_rate())
	var data := PackedByteArray()
	data.resize(source.mix_rate * 2)
	for i in source.mix_rate:
		data.encode_s16(i * 2, 10000 if i < source.mix_rate / 2 else -6000)
	source.data = data
	var clips: Array[Dictionary] = [
		{"stream": source, "start": 0.1, "length": 0.2},
		{"stream": source, "start": 0.6, "length": 0.2},
	]
	var phrase := CorpseSyllablePhrase.build(clips, 1.0)
	assert_not_null(phrase)
	if phrase == null:
		return
	for index in 2:
		var start := roundi(index * 0.28 * source.mix_rate)
		var count := roundi(0.2 * source.mix_rate)
		var fade := roundi(0.005 * source.mix_rate)
		var previous := 0
		for i in range(0, fade + 1):
			var value := absi(phrase.data.decode_s16((start + i) * 4))
			assert_true(value >= previous, "fade in monotonic")
			previous = value
		var plateau := phrase.data.decode_s16((start + roundi(0.1 * source.mix_rate)) * 4)
		assert_true(plateau > 9000 if index == 0 else plateau < -5000, "distinct source segments")
		var last_tail := 0
		for i in range(0, fade + 1):
			var tail := absi(phrase.data.decode_s16((start + count - 1 - i) * 4))
			assert_true(tail >= last_tail and tail - last_tail < 100, "smooth fade out to zero")
			last_tail = tail
		var middle := absi(phrase.data.decode_s16((start + roundi(fade * 0.5)) * 4))
		assert_true(middle > absi(plateau) * 0.45 and middle < absi(plateau) * 0.55, "5 ms ramp, not a hard cut")
	assert_true(absf(phrase.get_length() - 0.48) < 0.0001, "no packed-bank tail")


func test_missing_syllable_is_atomic_and_legacy_full_word_unchanged() -> void:
	var corpse := _corpse()
	assert_true(corpse.play_word("khuất bóng") > 0.0)
	assert_eq(corpse.play_word("khuất xyz"), 0.0)
	assert_false(corpse._voice.playing)
	assert_eq(corpse._voice.stream, null)
	for key in ["xyz abc", "khuất", "khuất bóng đèn", "WORD_CH2_../bad", "WORD_CH2_MISSING"]:
		assert_eq(corpse.play_word(key), 0.0, key)
	var whole := load("res://audio/voice/vi/WORD_CH2_HOC_SINH.ogg") as AudioStream
	assert_not_null(whole)
	var seconds := corpse.play_word("WORD_CH2_HOC_SINH")
	assert_eq(corpse._voice.stream, whole, "original resource, not regenerated")
	assert_true(is_equal_approx(seconds, whole.get_length() / corpse._voice.pitch_scale))
	assert_eq(corpse._voice.volume_db, -6.0)
	assert_eq(corpse._filter.cutoff_hz, 3800.0)


func test_turn_reset_and_death_interrupt_both_speech_and_inter_syllable_gap() -> void:
	var corpse := _corpse()
	var clips := Ch2SyllableBank.clips_for("khuất bóng")
	for during_gap in [false, true]:
		for reason in ["turn", "checkpoint", "chapter", "death", "mumble_off"]:
			assert_true(corpse.play_word("khuất bóng") > 0.0)
			corpse._voice.seek(float(clips[0].length) + 0.02 if during_gap else 0.05)
			match reason:
				"turn": EventBus.chain_turn_started.emit(&"viet", 15.0)
				"checkpoint": EventBus.checkpoint_loaded.emit(&"ch2_r3")
				"chapter": EventBus.chapter_started.emit(2)
				"death": EventBus.player_death_started.emit(&"corpse_lunge")
				"mumble_off": corpse.set_mumbling(false)
			assert_false(corpse._voice.playing, reason)
			await tree.create_timer(0.12).timeout
			assert_false(corpse._voice.playing, "no delayed second syllable after " + reason)
	corpse.play_word("khuất bóng")
	corpse.stop_emitting()
	assert_false(corpse._voice.playing)
	assert_eq(corpse.play_word("khuất bóng"), 0.0)


func test_gag_mumble_and_replacement_cancel_the_old_phrase() -> void:
	var corpse := _corpse()
	corpse.play_word("khuất bóng")
	EventBus.corpse_state_changed.emit(1, &"gagged")
	assert_false(corpse._voice.playing)
	assert_eq(corpse.play_word("khuất bóng"), 0.0)
	assert_eq(corpse._voice.stream, Ch2AudioBank.clip("corpse_mumble"))
	EventBus.checkpoint_loaded.emit(&"ch2_r3")
	corpse.play_word("khuất bóng")
	var old := corpse._voice.stream
	corpse.play_word("bóng đèn")
	assert_true(corpse._voice.stream != old)
	corpse.set_mumbling(true)
	assert_eq(corpse._voice.stream, Ch2AudioBank.clip("corpse_mumble"))
	await tree.create_timer(0.15).timeout
	assert_eq(corpse._voice.stream, Ch2AudioBank.clip("corpse_mumble"), "no pending phrase callback")


func test_phrase_pause_and_finished_follow_audio_clock() -> void:
	var corpse := _corpse("viet")
	var duration := corpse.play_word("khuất bóng")
	assert_true(duration > 0.0)
	tree.paused = true
	await tree.create_timer(0.2, true).timeout
	assert_true(corpse._voice.playing)
	assert_true(corpse._voice.get_playback_position() < 0.15, "no progress while paused")
	tree.paused = false
	await tree.create_timer(duration + 0.2).timeout
	assert_false(corpse._voice.playing, "ends after second syllable, not OGG bank end")


func test_invalid_piece_ranges_never_build_partial_audio() -> void:
	var clips := Ch2SyllableBank.clips_for("khuất bóng")
	assert_eq(CorpseSyllablePhrase.build([], 1.0), null)
	assert_eq(CorpseSyllablePhrase.build(clips, NAN), null)
	assert_eq(CorpseSyllablePhrase.build(clips, 0.0), null)
	for key in ["start", "length"]:
		var bad := clips.duplicate(true)
		bad[1][key] = NAN
		assert_eq(CorpseSyllablePhrase.build(bad, 0.72), null)
	var missing := clips.duplicate(true)
	missing[1]["stream"] = null
	assert_eq(CorpseSyllablePhrase.build(missing, 0.72), null)


func test_preview_syllables_cycle_words_and_profiles() -> void:
	var scene := load("res://audio/test/ch2_audio_test.tscn") as PackedScene
	var fixture := scene.instantiate()
	_nodes.append(fixture)
	tree.root.add_child(fixture)
	for i in 9:
		fixture.audition_syllables(i)
		for j in 3:
			assert_eq(fixture.corpses[j]._voice.playing, j == i % 3)
	fixture.reset_preview()
	for corpse: CorpseVoice in fixture.corpses:
		assert_false(corpse._voice.playing)
