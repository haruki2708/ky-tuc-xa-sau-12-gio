class_name PhoneCallAudio
extends Node
## Call audio only. MessageData and the phone UI own transcripts and story state.

signal line_started(text_key: String, duration: float)

@export_dir var sound_directory: String = Ch1AudioBank.DIRECTORY
@export_dir var voice_directory: String = "res://audio/voice"
@export_dir var mission_directory: String = Ch1V2AudioBank.DIRECTORY
var _ring: AudioStreamPlayer
var _speech: AudioStreamPlayer
var _effect: AudioStreamPlayer
var _remote_ring: AudioStreamPlayer
var _remote_member: StringName = &""
var _connection_lost: bool = false
var _call_id: StringName = &""
var _in_call: bool = false
var _stopped: bool = false
var _queue: Array[Dictionary] = []
var _dead_members: Array[StringName] = []
var _speaking_member: StringName = &""


func _ready() -> void:
	_ring = _make_player("Ring", &"SFX")
	_speech = _make_player("Speech", &"PhoneVoice")
	_effect = _make_player("CallEffect", &"PhoneSFX")
	_remote_ring = _make_player("RemoteRing", &"PhoneSFX")
	_speech.finished.connect(_next_line)
	EventBus.phone_call_incoming.connect(_on_incoming)
	EventBus.phone_call_answered.connect(_on_answered)
	EventBus.phone_call_lost.connect(_on_lost)
	EventBus.phone_call_restored.connect(_on_restored)
	EventBus.phone_message_received.connect(_on_message)
	EventBus.chat_member_changed.connect(_on_member)
	EventBus.chapter_started.connect(_on_chapter)
	EventBus.checkpoint_loaded.connect(_on_checkpoint)


func _make_player(node_name: String, audio_bus: StringName) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = node_name
	player.bus = audio_bus
	add_child(player)
	return player


func _play(player: AudioStreamPlayer, clip: AudioStream) -> void:
	player.stop()
	player.stream = clip
	if clip != null:
		player.play()


func _on_incoming(call_id: StringName) -> void:
	if _stopped or call_id.is_empty() or call_id == _call_id:
		return
	end_call(false)
	_call_id = call_id
	_play(_ring, Ch1AudioBank.clip("call_ring", sound_directory))


func _on_answered(call_id: StringName) -> void:
	if _stopped or _connection_lost or call_id != _call_id or call_id.is_empty():
		return
	_ring.stop()
	_in_call = true


func _on_message(message_id: StringName) -> void:
	if not _in_call or _connection_lost or _stopped:
		return
	# Validate the resource id before passing it to MessageData's path loader.
	if String(message_id).validate_filename() != String(message_id) or "/" in String(message_id) or ".." in String(message_id):
		return
	play_message(MessageData.load_by_id(message_id))


func play_message(message: MessageData) -> float:
	if _stopped or not _in_call or _connection_lost or message == null or not message.spoken or _dead_members.has(message.sender):
		return 0.0
	var clip := Ch1AudioBank.voice(message.text_key, "CHAT_CH1_", voice_directory)
	if clip == null or _queue.size() >= 64:
		# Text still arrives through phone_message_received; never invent spoken text.
		return 0.0
	_queue.append({"clip": clip, "key": message.text_key, "sender": message.sender})
	if not _speech.playing:
		_next_line()
	return clip.get_length()


func _next_line() -> void:
	_speaking_member = &""
	if _stopped or not _in_call or _connection_lost or _queue.is_empty():
		return
	var entry: Dictionary = _queue.pop_front()
	_speaking_member = entry["sender"]
	_play(_speech, entry["clip"])
	line_started.emit(entry["key"], _speech.stream.get_length())


func _on_member(member_id: StringName, state: StringName) -> void:
	if _stopped or not _in_call:
		return
	if state == &"joined":
		_dead_members.erase(member_id)
		return
	if state not in [&"dead", &"left"] or _dead_members.has(member_id):
		return
	_dead_members.append(member_id)
	if member_id == _remote_member:
		play_remote_ring(false)
	_queue = _queue.filter(func(entry: Dictionary) -> bool: return entry["sender"] != member_id)
	if _speaking_member == member_id:
		_speech.stop()
		_next_line()
	if _connection_lost:
		return
	_effect.volume_db = -8.0 if state == &"dead" and Ch1AudioBank.reduced() else 0.0
	_play(_effect, Ch1AudioBank.clip("call_drop" if state == &"dead" else "call_disconnect", sound_directory))


func end_call(with_tone: bool = true) -> void:
	if _ring == null:
		return
	var was_active := _in_call or not _call_id.is_empty()
	_ring.stop()
	_speech.stop()
	_effect.stop()
	_remote_ring.stop()
	_remote_member = &""
	_connection_lost = false
	_queue.clear()
	_dead_members.clear()
	_call_id = &""
	_speaking_member = &""
	_in_call = false
	if with_tone and was_active and not _stopped:
		_effect.volume_db = 0.0
		_play(_effect, Ch1AudioBank.clip("call_disconnect", sound_directory))


func _on_chapter(_chapter: int) -> void:
	end_call(false)


func _on_checkpoint(_checkpoint: StringName) -> void:
	end_call(false)


func _on_lost(call_id: StringName) -> void:
	if _stopped or not _in_call or _connection_lost or call_id != _call_id:
		return
	_connection_lost = true
	_speech.stop()
	_ring.stop()
	play_remote_ring(false)
	_queue.clear()
	_speaking_member = &""
	_effect.volume_db = 0.0
	_play(_effect, Ch1AudioBank.clip("call_disconnect", sound_directory))


func _on_restored(call_id: StringName) -> void:
	if _stopped or not _in_call or not _connection_lost or call_id != _call_id:
		return
	_connection_lost = false
	_effect.volume_db = 0.0
	_play(_effect, Ch1V2AudioBank.clip("call_reconnect", mission_directory))
	# Missed/queued lines stay discarded; only new incoming messages may speak.


func play_remote_ring(on: bool, member_id: StringName = &"kiet") -> void:
	if _remote_ring == null:
		return
	if not on:
		_remote_ring.stop()
		_remote_member = &""
	elif not _stopped and _in_call and not _connection_lost and not _dead_members.has(member_id):
		_remote_member = member_id
		if not _remote_ring.playing:
			_play(_remote_ring, Ch1V2AudioBank.clip("kiet_ring", mission_directory))


func stop_emitting() -> void:
	_stopped = true
	end_call(false)
