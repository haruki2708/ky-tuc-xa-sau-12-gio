class_name SpeakerVoiceBank
extends RefCounted
## Allowlist prevents arbitrary paths and never exposes an unmasked RULE_3 clip.

const KEYS: Array[String] = [
	"RULE_HEADER_5", "RULE_1", "RULE_2", "RULE_3_GARBLED", "RULE_4", "RULE_5",
	"SPK_SIGN_LOG", "SPK_ROLLCALL_INTRO", "SPK_CHECK_TAPS",
	"SPK_NAME_PHUC", "SPK_NAME_VIET", "SPK_NAME_TRUNG", "SPK_NAME_DAT", "SPK_NAME_LAM",
	"SPK_NAME_TRUNG_AGAIN", "SPK_AND_ONE_MORE", "SPK_AND_TRUNG",
]


static func load_clip(directory: String, locale: String, key: String) -> AudioStream:
	if not KEYS.has(key) or locale not in ["vi", "en"] or directory.is_empty():
		return null
	var path := directory.path_join(locale).path_join(key + ".ogg")
	if not ResourceLoader.exists(path, "AudioStream"):
		return null
	return load(path) as AudioStream
