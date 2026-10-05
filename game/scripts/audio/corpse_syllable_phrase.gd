class_name CorpseSyllablePhrase
extends RefCounted
## Cut only the requested ranges into a short, transient PCM phrase. Baked fades
## and silence run on the audio clock, so a slow frame cannot leak the next word
## in a packed OGG. The existing 3D player owns pause, pitch and cancellation.

const GAP_SECONDS: float = 0.08
const FADE_SECONDS: float = 0.005
const MAX_PIECE_SECONDS: float = 3.0


static func build(clips: Array[Dictionary], pitch: float) -> AudioStreamWAV:
	if clips.size() != 2 or not is_finite(pitch) or pitch <= 0.0:
		return null
	var rate := int(AudioServer.get_mix_rate())
	var counts: Array[int] = []
	var total_frames := 0
	for clip in clips:
		var stream := clip.get("stream") as AudioStream
		var start := float(clip.get("start", -1.0))
		var length := float(clip.get("length", 0.0))
		if stream == null or not is_finite(start) or not is_finite(length) or start < 0.0 or length <= 0.0 or length > MAX_PIECE_SECONDS or start + length > stream.get_length() + 0.001:
			return null
		var count := maxi(2, roundi(length * rate))
		counts.append(count)
		total_frames += count
	# Gap and fades are wall-clock durations after the player's pitch adjustment.
	var gap_frames := maxi(1, roundi(GAP_SECONDS * pitch * rate))
	total_frames += gap_frames
	var pcm := PackedByteArray()
	pcm.resize(total_frames * 4) # Stereo PCM16, initialized to silence.
	pcm.fill(0)
	var cursor := 0
	for piece in clips.size():
		var stream: AudioStream = clips[piece]["stream"]
		var playback := stream.instantiate_playback()
		if playback == null:
			return null
		playback.start(float(clips[piece]["start"]))
		var frames := playback.mix_audio(1.0, counts[piece])
		playback.stop()
		if frames.size() != counts[piece]:
			return null # All-or-nothing: never speak only half a word.
		var fade_frames := maxi(1, mini(roundi(FADE_SECONDS * pitch * rate), floori(float(frames.size() - 1) / 2.0)))
		for i in frames.size():
			var gain := minf(1.0, minf(float(i), float(frames.size() - 1 - i)) / fade_frames)
			var frame := frames[i] * gain
			pcm.encode_s16((cursor + i) * 4, roundi(clampf(frame.x, -1.0, 1.0) * 32767.0))
			pcm.encode_s16((cursor + i) * 4 + 2, roundi(clampf(frame.y, -1.0, 1.0) * 32767.0))
		cursor += frames.size() + (gap_frames if piece == 0 else 0)
	var phrase := AudioStreamWAV.new()
	phrase.format = AudioStreamWAV.FORMAT_16_BITS
	phrase.mix_rate = rate
	phrase.stereo = true
	phrase.data = pcm
	return phrase
