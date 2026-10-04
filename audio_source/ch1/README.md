# T-158 — âm thanh chương 1

29 âm Foley tổng hợp gốc, không dùng bản thu người thật, model hoặc âm từ video/game. Code do Lane E/OpenAI Codex tạo (AI-assisted), waveform CC0 1.0; nguồn ở `game/audio/CREDITS.md`. **Chưa nghe bằng tai**: tiếng hét formant, Foley, loop và mix cần chủ dự án nghe/duyệt.

## Dựng lại

Từ gốc repo: `py -3 audio_source/ch1_process.py`. Python sẵn có và FFmpeg đầu tiên dưới `D:/Tools/ffmpeg`; không tải/cài gì. Raw PCM16 mono 48 kHz trong `audio_source/ch1/raw/`, OGG mono q4 trong `game/audio/ch1/`. Seed 15801–15829 theo `ASSETS`. HP35/LP8500, fade one-shot, crossfade1 s và chọn biên yên cho loop. Bản soft có ít lớp âm và LP700. Gain tuyến tính từ đo loudnorm, đo lại OGG: sai số ≤1 LU, peak ≤−2 dBTP, biên loop <0.01. Report có LUFS, target, peak, thời lượng, seed, hash WAV/OGG. Ngân sách riêng raw+OGG <15 MB; file <10 MB. LUFS trong report là **asset trước gain/bus/filter/khoảng cách**, không phải tổng mix tại tai.

43 âm/nhạc và 34 giọng cũ giữ nguyên; không cần chạy lại hai pipeline cũ. Nhạc chương 1 dùng lại `drone_base` (−41.96 LUFS) và `drone_tension` (−35.99 LUFS).

Test: `pwsh tools/test.ps1 -Filter audio`, `pwsh tools/test.ps1`, `pwsh tools/check.ps1`. Headless không thay thế nghe thật.

## API và tích hợp

- **ManagerAudio:** instance `res://audio/entities/manager_audio.tscn` làm con quản lý hoặc Node3D độc lập chỉ có âm. `play_step()` xen kẽ 2 biến thể; `play_drag(on)` giữ loop khi gọi true nhiều lần; `play_knock()`; `play_slash(material=&"mattress")` hoặc `&"wood"`, mỗi loại 2 biến thể; `play_kill()`; `place_at(world_position)`. `say(line_key) -> float` tra `res://audio/voice/<vi|en>/MGR_*.ogg`, trả độ dài+0.4 s và phụ đề một lần. Thiếu giọng: phụ đề 2.5 s (export `subtitle_fallback_seconds`). T-159 sẽ cung cấp giọng. Giọng Voice, âm khác SFX, unit_size4/max_distance65 m. Caller quyết định bước/chém/di chuyển; không có luật hoặc AI trong rig. Giảm hù dọa thay clip slash/kill bằng clip soft, kể cả khi đổi settings lúc đang phát. `stop_emitting()` khóa rig; lượt mới tạo node mới.
- **FloorMuffle:** node con của bất kỳ AudioStreamPlayer3D. Ưu tiên export `listener`, sau đó AudioListener3D hoặc camera hiện hành; không có listener thì dry. `floor_base_y` là độ cao mặt sàn chuẩn, chung cho mọi nguồn; chỉ số tầng = floor((y−base)/3.3). Mỗi tầng chênh giảm8 dB và LP24 cutoff2200/gap Hz, tối thiểu450 Hz; cùng tầng bypass/gain0. Bus riêng từng nguồn gửi về bus gốc, giữ pan/slider/reverb; unload trả routing/xóa bus. Không đổi bus player sau khi gắn. API `update_listener_position(position)` cho listener thủ công. Không raycast tường/cửa; thông số đổi tại ranh tầng. [LowPassFilter](https://docs.godotengine.org/en/stable/classes/class_audioeffectlowpassfilter.html), [Viewport](https://docs.godotengine.org/en/stable/classes/class_viewport.html).
- **BuildingScreams:** Node3D, `play_wave(origin,count=4,spread_seconds=6)` thay đợt trước, tối đa12 nguồn, trễ từ0 tới spread. Phân tán ±9 m ngang/±7 m sâu, tầng origin+[0,3.3,6.6] m: dùng origin tầng4 cho đợt phủ4–6. `play_at(position)` cho phòng cụ thể. Bốn biến thể không lặp liền, FloorMuffle từng nguồn; giảm hù dọa hạ8 dB lúc tạo. `stop_emitting()` hủy lịch/nguồn, cho phép đợt mới. Core quyết định khi nào hét, không tự phát ở chapter_started.
- **PhoneCallAudio:** Node trước tín hiệu truyện; nối incoming/answered cùng call_id, phone_message_received chỉ phát MessageData.spoken, chat_member_changed. Incoming mới hủy cuộc gọi cũ; answered dừng chuông. Thoại `CHAT_CH1_*` cùng thư mục/locale như ManagerAudio. `play_message(message)->float` trả độ dài clip hoặc0 nếu thiếu/chưa trong cuộc gọi/queue64 đầy. FIFO; signal `line_started(key,duration)` báo thời điểm thực phát. Locale chốt lúc nhận tin. UI hiển thị transcript qua signal gốc; audio không gửi phụ đề trùng. Dead ngắt/xóa lời của người chết rồi phát điện thoại rơi; left phát ngắt; joined cho nói lại. Callback dead/left lặp không phát lại. `end_call(with_tone=true)` dùng khi mất mạng/hết pin/kết thúc vì chưa có signal ngắt; chapter_started reset im lặng. `stop_emitting()` khóa phát lại.
- **Bus điện thoại:** PhoneVoice→Voice→Master; PhoneSFX→SFX→Master. HP300, atan nhẹ, LP3400. T-159 xuất giọng **chưa lọc điện thoại**, khoảng−26 LUFS để tránh lọc đôi; cần nghe mix sau khi có giọng. Chuông SFX khô, rơi/ngắt PhoneSFX. Slider hiện có tiếp tục tác động, không thêm settings. [Distortion API](https://docs.godotengine.org/en/stable/classes/class_audioeffectdistortion.html).
- **CorpseAudio:** Node3D tại xác; `play_drips(on)`, `play_pose(name)`. Export `poser` tự nối pose_changed(name) của T-152 nếu có, hoặc caller connect. Drip Ambience (asset−47.94 LUFS, bus thêm−3 dB); rustle SFX. Có FloorMuffle, không tự bật máu lúc ready.
- **Ch1PlayerAudio:** Node nghe tại listener, SFX. breath_held bật tim từ1.1 xuống0.66 s/nhịp trong8 s, mức asset−48 LUFS giữ nguyên. Thả sớm chỉ dừng tim. Theo T-151, noise_emitted(breath,radius≥4) phát thở hắt; hơi thường1.5 m không coi là hết hơi. Không tự quyết stamina/phát gameplay noise. player_hidden kiểu bunk/bed phát sắt giường. `play_action(&"bunk_climb"|&"bunk_creak"|&"wall_knock"|&"locker_unlock"|&"charger_plug"|&"breath_gasp")` do Lane A/core gọi đúng tương tác, không đoán puzzle_id. player_caught mặc định phát kill/soft; đặt `handle_player_caught=false` nếu đã gọi ManagerAudio.play_kill để tránh phát đôi. chapter_started dừng âm. Shutdown khóa phát lại.
- **Speaker.chapter_profile=true:** pa_on thay bật loa demo, bỏ chuông cũ, nhiễu ngắn đầu dòng. Giữ API/thời lượng/phụ đề/garbled/cancel; nạp SPK_CH1_* khi T-159 có clip. Mặc định false giữ demo. Không tự viết thoại; fixture dùng RULE_1/RULE_2 chỉ thử âm.
- **Ch1Music:** Node **thay MusicDirector demo ở chương1** để tránh nhạc đôi. chapter_started(1) bật nền, chapter_finished fade out. `set_active(bool)`, `set_tension(0..1)` để core đặt mức gần407, `silence_before_door(true)` về0 trong10 ms và giữ tới false (trả trong1 s). Core gọi trước mở cửa; tăng tension không phá khoảng im. Base gain0.65 (~−45.7 LUFS), tension tối đa unity (~−36 LUFS); fade nền2 s/tension1.5 s; pause duck10 dB/0.2 s. Không đổi bus. Shutdown hủy tween/loop và khóa phát lại.

Node bình thường kế thừa pause; riêng Ch1Music Always để duck tiếp tục. Tạo node trước tín hiệu khởi động, checkpoint do core phát lại trạng thái cần thiết, không replay mọi tiếng chết. Chỉ gắn rig trong chương1, không thêm autoload. Lane E không sửa main/Player/quản lý/dữ liệu truyện.

## Nghe thử

F6 scene `res://audio/test/ch1_audio_test.tscn`, hoặc:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://audio/test/ch1_audio_test.tscn --windowed --resolution 960x540
```

| Phím | Âm/API |
|---|---|
| Space / trái / phải | Nghe lại / trước / sau trong29 âm; in tên ở console, dừng mix trước |
| F1 / F2 / F3 | Bước / bật-tắt kéo dao / gõ quản lý |
| F4 / F5 / F6 | Chém nệm / gỗ / giết; theo settings giảm hù dọa |
| F7 | Đợt8 tiếng hét, trễ7 s, tầng4–6 |
| F8 / F9 / F10 / F11 | Gọi tới / nhận / thành viên chết / ngắt; F10 cần nhận trước |
| F12 | Quản lý có âm đi tầng6→5→4 trong13 s, kéo dao/gõ lúc đến |
| B / C | Bật-tắt máu / xác đổi tư thế |
| H / G | Bật-tắt giữ hơi / hơi hắt hết hơi |
| M / T / S | Nhạc vòng1 / tension tối đa / chốt im hoặc trả nhạc |
| V | Speaker profile chương1 với hai câu demo có sẵn |
| P | Giả lập signal pause cho duck, không pause cả cây |
| 0 / Esc | Reset/dừng / thoát App.quit |

F12: listener tầng 4, nguồn từ y=6.6 tới y=0, tầng cách 3.3 m. Có marker nguồn và ba mặt sàn, không model quản lý. QA headless dùng `--headless --max-fps 60 -- --ch1-audio-preview --quit-after-frames=900` để chạy đủ hành trình và thoát App. Không dùng `--fixed-fps` ở đây: headless có thể chạy quá nhanh, thời gian mô phỏng xả audio không đủ cho luồng âm thanh thật trước khi thoát. Đây là kiểm tra khởi chạy, không chứng nhận nghe. Đổi giảm hù dọa ở menu game trước khi mở fixture; fixture không ghi settings. Solo mũi tên phát nguyên asset; thử reduced bằng F4–F6.
