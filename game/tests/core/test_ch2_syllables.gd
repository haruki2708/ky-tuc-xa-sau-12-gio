extends TestCase
## Corpse voice for dictionary words (T-176, D-051): every word the corpses
## know can be played syllable by syllable, and the cuts land on speech.


func test_every_corpse_word_has_its_syllables_recorded() -> void:
	var dictionary := Ch2Dictionary.shared()
	var missing: Array[String] = []
	for first: String in dictionary.corpse_by_first:
		for word in dictionary.corpse_by_first[first]:
			if Ch2SyllableBank.clips_for(dictionary.spelling[word]).size() != 2:
				missing.append(dictionary.spelling[word])
	assert_eq(missing.size(), 0, "missing: %s" % ", ".join(missing.slice(0, 10)))


func test_a_cut_is_speech_and_the_gap_before_it_is_silence() -> void:
	var clips := Ch2SyllableBank.clips_for("khuất bóng")
	assert_eq(clips.size(), 2, "two syllables;")
	for clip in clips:
		var stream: AudioStream = clip.stream
		var start: float = clip.start
		var length: float = clip.length
		assert_true(length > 0.1 and length < 1.5, "length %.2f" % length)
		assert_true(_peak(stream, start + 0.02, length * 0.6) > 0.02, "speech at %.2f" % start)
		assert_true(_peak(stream, start - 0.2, 0.15) < 0.02, "silence before %.2f" % start)
	assert_true(Ch2SyllableBank.seconds_for("khuất bóng") > 0.3, "duration")
	assert_eq(Ch2SyllableBank.clips_for("xyz abc").size(), 0, "unknown syllables: no clip")


func _peak(stream: AudioStream, from: float, seconds: float) -> float:
	var playback := stream.instantiate_playback()
	playback.start(maxf(from, 0.0))
	var frames := playback.mix_audio(1.0, int(seconds * 22050.0))
	playback.stop()
	var peak := 0.0
	for frame in frames:
		peak = maxf(peak, absf(frame.x))
	return peak
