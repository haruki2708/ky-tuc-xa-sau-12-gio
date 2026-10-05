extends Node3D
## Standalone audition; controls documented in audio_source/ch2/README.md.

var corpses: Array[CorpseVoice] = []
var shower: ShowerAudio
var clock: Ch2Countdown
var music: Ch2Music
var death: Ch1PlayerAudio
var cctv: CctvAudio
var preview: AudioStreamPlayer
var selected: int = 0
var word_keys: Array[String] = []
var word_index: int = 0


func _ready() -> void:
	var camera := Camera3D.new()
	camera.position = Vector3(0, 1.5, 4)
	add_child(camera)
	camera.make_current()
	for id in ["phuc", "viet", "dat"]:
		var corpse := CorpseVoice.new()
		corpse.speaker = id
		corpse.position = Vector3(corpses.size() * 1.5 - 1.5, 1.5, 0)
		add_child(corpse)
		corpses.append(corpse)
	shower = ShowerAudio.new()
	add_child(shower)
	clock = Ch2Countdown.new()
	add_child(clock)
	music = Ch2Music.new()
	add_child(music)
	death = Ch1PlayerAudio.new()
	add_child(death)
	cctv = CctvAudio.new()
	add_child(cctv)
	preview = AudioStreamPlayer.new()
	add_child(preview)
	for filename in DirAccess.get_files_at("res://audio/voice/vi"):
		if filename.begins_with("WORD_CH2_") and filename.ends_with(".ogg"):
			word_keys.append(filename.trim_suffix(".ogg"))
	word_keys.sort()
	if "--ch2-audio-preview" in OS.get_cmdline_user_args():
		audition(0)


func reset_preview() -> void:
	preview.stop()
	for corpse in corpses:
		corpse._reset(null)
	shower._reset(null)
	clock.cancel()
	music._reset(null)
	death._on_chapter(2)
	cctv._reset(null)


func audition(index: int) -> void:
	reset_preview()
	selected = posmod(index, Ch2AudioBank.NAMES.size())
	var clip_name: String = Ch2AudioBank.NAMES[selected]
	preview.bus = &"Music" if clip_name.begins_with("music_") else (&"Ambience" if clip_name.begins_with("water_") or clip_name == "steam_hiss" else &"SFX")
	preview.stream = Ch2AudioBank.clip(clip_name)
	preview.play()
	print("CH2 audition: ", selected + 1, "/", Ch2AudioBank.NAMES.size(), " ", clip_name, " -> ", preview.bus)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match (event as InputEventKey).physical_keycode:
		KEY_LEFT: audition(selected - 1)
		KEY_RIGHT: audition(selected + 1)
		KEY_SPACE: audition(selected)
		KEY_0: reset_preview()
		KEY_1, KEY_2, KEY_3:
			var index := (event as InputEventKey).physical_keycode - KEY_1
			corpses[index].set_mumbling(true)
		KEY_V:
			reset_preview()
			if word_keys.is_empty():
				print("CH2: core WORD_CH2 voice bank is not available; no placeholder words generated.")
			else:
				var corpse := corpses[posmod(word_index, 3)]
				var key := word_keys[posmod(floori(float(word_index) / 3.0), word_keys.size())]
				print("CH2 voice: ", corpse.speaker, " ", key, " ", corpse.play_word(key), " seconds")
				word_index += 1
		KEY_T: EventBus.chain_turn_started.emit(&"trung", 15.0)
		KEY_F1: shower.set_water(5.0, true)
		KEY_F2: shower.set_water(37.0, true)
		KEY_F3: shower.set_water(81.0, true)
		KEY_F4: shower.set_steam(1.0)
		KEY_F5: EventBus.shower_choice_requested.emit(8.0)
		KEY_F6: shower.play_cue("door_burst")
		KEY_F7: shower.play_cue("mirror_shiver")
		KEY_L, KEY_S:
			reset_preview()
			EventBus.player_death_started.emit(&"corpse_lunge" if (event as InputEventKey).physical_keycode == KEY_L else &"scald")
		KEY_C:
			cctv.set_viewing(true)
			cctv.select_channel(&"room102")
			cctv.play_room_loss(&"room102")
		KEY_M: music.set_round(&"chain")
		KEY_N: music.set_round(&"shower")
		KEY_ESCAPE: App.quit()
