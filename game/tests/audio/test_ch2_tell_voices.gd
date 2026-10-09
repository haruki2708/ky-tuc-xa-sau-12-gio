extends TestCase

const SPEAKERS := {
	"CHAT_CH2_N_HOW": "minh_nhat",
	"CHAT_CH2_NGU_HOW": "ngu",
	"CHAT_CH2_N_TOLD": "minh_nhat",
	"CHAT_CH2_NGU_TOLD": "ngu",
	"CHAT_CH2_N_CAUGHT": "minh_nhat",
}


func test_ch2_tell_voices_match_csv_decode_and_call_loudness() -> void:
	var report: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://../audio_source/voice_ch2/build_report.json"))
	var texts: Dictionary[String, String] = {}
	var csv := FileAccess.open("res://localization/strings.csv", FileAccess.READ)
	while not csv.eof_reached():
		var row := csv.get_csv_line()
		if row.size() >= 2:
			texts[row[0]] = row[1]
	csv.close()
	var found: Array[String] = []
	for entry: Dictionary in report.assets:
		if not SPEAKERS.has(entry.key):
			continue
		assert_false(found.has(entry.key), "one report entry per key")
		found.append(entry.key)
		assert_eq(entry.who, SPEAKERS[entry.key])
		assert_eq(entry.text, texts[entry.key], "verbatim approved Vietnamese")
		assert_eq(report.voices[entry.who][1], 188, "chapter 2 speed x1.25")
		assert_eq(entry.target_lufs, -26)
		assert_true(absf(entry.lufs + 26.0) <= 1.5, "chapter 2 call loudness")
		assert_true(entry.true_peak_db <= -1.0, "chapter 2 peak ceiling")
		var path := "res://audio/voice/vi/%s.ogg" % entry.key
		assert_eq(entry.file, "game/audio/voice/vi/%s.ogg" % entry.key)
		assert_eq(FileAccess.get_sha256(path), entry.sha256)
		assert_eq(FileAccess.get_sha256("res://../audio_source/voice_ch2/raw/%s.wav" % entry.key), entry.raw_sha256)
		var clip := Ch1AudioBank.voice(entry.key, "CHAT_CH2_") as AudioStreamOggVorbis
		assert_not_null(clip, path)
		if clip == null:
			continue
		assert_false(clip.loop)
		assert_true(clip.get_length() > 0.5)
		var playback := clip.instantiate_playback()
		playback.start()
		var peak := 0.0
		for frame in playback.mix_audio(1.0, ceili(clip.get_length() * 48000)):
			assert_true(is_finite(frame.x) and is_finite(frame.y))
			peak = maxf(peak, maxf(absf(frame.x), absf(frame.y)))
		playback.stop()
		assert_true(peak > 0.00001 and peak < 0.9, "audible decoded signal without clipping")
	assert_eq(found.size(), SPEAKERS.size())
	for index in range(1, 5):
		assert_false(FileAccess.file_exists("res://audio/voice/vi/CHOICE_CH2_TELL_%d.ogg" % index), "Trung has no voice")
