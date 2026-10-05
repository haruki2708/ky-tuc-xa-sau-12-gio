# T-175 — âm thanh chương 2

23 âm tổng hợp gốc CC0 bằng Python/FFmpeg có sẵn, code có OpenAI Codex hỗ trợ. Không dùng bản thu, model giọng, âm game/video hoặc lời thoại tự bịa. Giọng eSpeak đọc từ `WORD_CH2_*` thuộc core/T-170; **chưa có trong main tại c68888b**. Không sinh lời thay thế. **Chưa nghe bằng tai**; test headless và LUFS không thay duyệt chất âm.

## Pipeline và số đo

Chạy `py -3 audio_source/ch2_process.py` từ gốc repo. Chỉ ghi bank ch2, dùng helper có sẵn từ process.py, không chạy lại các bank cũ. Seed 17501–17523; raw PCM16 mono 48 kHz ở `raw/`, OGG mono q4 ở `game/audio/ch2/`. FFmpeg HP35/LP7500, fade đầu/đuôi cho one-shot; loop crossfade 1 giây và khớp đường biên. Soft/mumble LP700; camera band-pass 350–3000. Đo lại sau encode, sai số ≤1 LU, true peak ≤−2 dBTP, chênh mẫu đầu/cuối loop <0.01. `build_report.json` ghi LUFS, peak, thời lượng, seed, hash WAV/OGG. Raw + OGG: 7.981.108 byte, từng file <10 MB; binary qua Git LFS.

| OGG basename | LUFS |
|---|---:|
| corpse_mumble | -40.02 |
| corpse_fall | -38.10 |
| corpse_revive | -38.20 |
| corpse_gag | -40.04 |
| chain_tick | -47.95 |
| shower_beep | -46.05 |
| door_push_01 | -41.97 |
| door_push_02 | -40.01 |
| door_push_03 | -37.98 |
| door_burst | -34.20 |
| water_cold | -46.32 |
| water_warm | -44.34 |
| water_boiling | -40.22 |
| steam_hiss | -48.34 |
| mirror_shiver | -37.97 |
| death_corpse_lunge | -32.03 |
| death_scald | -32.20 |
| death_corpse_soft | -41.99 |
| death_scald_soft | -42.22 |
| camera_room_loss | -42.13 |
| music_chain | -48.01 |
| music_shower | -50.14 |
| music_turn | -48.02 |

Đây là loudness asset trước gain nguồn, bus và khoảng cách. Mức giọng nói sau xử lý chưa đo được khi core chưa giao voice bank. Âm rất nhỏ theo yêu cầu chủ dự án, cần nghe cùng mix thực tế.

## Rig và hợp đồng tích hợp

Các rig chỉ phát âm, không quyết định câu đúng, nhiệt độ, cảnh chết, thời gian gameplay hoặc emit noise_emitted. Tất cả kế thừa pause, có stop_emitting cho App.quit. Chapter/checkpoint/death dừng âm và lịch; core cần phục hồi trạng thái sau reset. Không thêm bus cố định, autoload, setting, input action hay sửa file ngoài audio.

### CorpseVoice — mỗi đầu xác một Node3D

- Đặt export `speaker` trước add_child: phuc/giường1, viet/giường2, dat/giường4. Voice 3D unit_size3m, gain−6dB, pitch_scale lần lượt .82/.72/.91. Hạ pitch bằng tốc độ nên thời lượng dài thêm; `play_word(key) -> float` trả thời lượng thực sau pitch (0 nếu thiếu clip/mumble). Core phải đợi đủ thời lượng trước lượt tiếp theo.
- Chỉ đọc `voice_directory/WORD_CH2_*.ogg`, mặc định `res://audio/voice/vi`; chặn path traversal và prefix khác. Tiếng Việt dùng độc lập locale vì đây là nối từ tiếng Việt. Không có clip thì im, không tự tạo/phát câu khác; không tự emit phụ đề.
- Mỗi rig có bus tạm riêng gửi **Voice**: distortion ATAN, drive .25/.35/.18, pre+6/post−6dB, LP3800. Bus bị xóa khi node được giải phóng; không ảnh hưởng giọng loa/điện thoại. Tham chiếu API: [AudioEffectDistortion của Godot](https://docs.godotengine.org/en/stable/classes/class_audioeffectdistortion.html).
- Nghe chain_word_spoken đúng speaker; key rỗng hoặc xác bị bịt dùng loop corpse_mumble, LP650. `set_mumbling(on)` cho fixture/caller. Trạng thái gagged giữ qua fall/revive/talk, chỉ reset mới bỏ; không làm mất đồ bịt ở gameplay.
- corpse_state_changed đúng giường: sit/revive phát xương bật dậy; fall/slump phát gục; gagged phát rên; mumble bắt đầu ú ớ; trạng thái mới cắt voice trước đó. Lượt mới dừng voice/mumble của lượt cũ. Phát lại cùng state không restart. Body gửi SFX; giảm hù dọa hạ 8dB cho body. `lunge` không tự rít để tránh chồng tiếng với Ch1PlayerAudio.

### Ch2Countdown — tích tắc lượt nối từ

Tạo một Node, nghe chain_turn_started, chain_word_spoken và chain_choice_made. `start(seconds)` / `cancel()`, signal `ticked(remaining)` dành kiểm tra. Tick SFX mỗi 1s, khi còn ≤5s mỗi .5s, không tick đúng lúc hết giờ. Với 15s là 19 tick ở 14…5, 4.5…0.5s. Câu nói không rỗng của đúng người hoặc người chơi chọn thì dừng; key rỗng giữ tick tới hết lượt. Thiếu file vẫn giữ đồng hồ. Hữu hạn, >0, tối đa 120s; frame bị trễ bỏ tick quá hạn để tránh tiếng chồng. Không phát tín hiệu chọn sai/chết.

### ShowerAudio — đặt Node3D ở vòi sen/cửa

- **Core gọi `set_water(temperature, running)` ngay khi lượt bắt đầu, sau khi nhiệt độ được công bố.** Chuyển ngay lạnh (<10), ấm (10–<50), sôi (≥50); chỉ khác màu âm, không tự xử lý chết. Cùng loại nước không restart loop; running=false tắt.
- Event shower_choice_requested bắt đầu beep và dừng nước lượt cũ; choice_made dừng beep (false tắt nước). **Không bật nước ở choice_made(true)** khi chưa biết nhiệt độ, tránh tiết lộ nhiệt độ trước lựa chọn. shower_slot_finished chỉ dừng vì hợp đồng ghi sự kiện cuối lượt; không dùng kết quả đó để bật nước muộn. Tới scene trước lượt đầu đang có nước, caller cũng dùng set_water theo trạng thái core.
- `set_steam(level)` / shower_steam_changed: clamp0…1, nhân gain tuyến tính, 0 dừng. Nước/hơi → **Ambience**, 3D unit_size2.5m. Beep màn hình → SFX, không gian người nghe; countdown8s do signal cung cấp.
- `play_door_push(level)` nhận1/2/3, không tự tăng số lần đẩy. `play_cue("door_burst")` gồm cửa bật + hơi nóng; `play_cue("mirror_shiver")` cho jumpscare7; **SFX**. Hai cue giảm10dB khi giảm hù dọa. Caller chọn đúng thời điểm; mỗi rig có một cue player, dùng rig riêng cửa/vòi nếu cần không gian khác hoặc phát đồng thời.

### Cảnh chết — mở rộng Ch1PlayerAudio sẵn có

player_death_started thêm corpse_lunge/scald, source SFX tại người nghe; mỗi clip3s. Corpse_lunge trộn ba tiếng rít lệch tông, tác động cắn/xé; scald nước sôi và tiếng nghẹn tổng hợp. Soft giảm lớp chi tiết và LP700. Bật giảm hù dọa giữa cảnh đổi ngay sang soft; chốt một cảnh mỗi lượt sống và chặn manager_kill cũ phát theo sau. Không tạo death-audio thứ hai. Reset checkpoint/chapter xóa chốt; thiếu bank an toàn. Không đồng bộ hoạt cảnh hay tự chuyển màn chết ở audio.

### Camera — mở rộng CctvAudio sẵn có

`play_room_loss(camera_id) -> bool` phát camera_room_loss chỉ nếu Camera đang xem và kênh trùng. ID không khớp/ẩn/thiếu clip/clip còn chạy trả false. Đổi kênh/hạ máy/reset dừng, xem lại không tự phát lại sự kiện cũ. Core/UI gọi đúng thời điểm phòng thua; không phát từ cctv_focus_requested. SFX, asset đã lọc như loa camera; giảm hù dọa hạ12dB và bật tùy chọn giữa cảnh dừng clip. Tránh gọi thêm từ phone member death cho cùng sự kiện khi ghép nếu không muốn chồng mix.

### Ch2Music — Node riêng chương 2

Music bus: `set_round(&"chain" / &"shower" / &"")`, fade chuyển nền1.5s. Nhạc chain nền thấp và pulse music_turn đúng mỗi chain_turn_started; nhạc shower nhiễu thấp ẩm nóng. chapter_started(2) bật chain; shower_choice_requested chuyển shower nếu đang hoạt động. Checkpoint/death/chapter_finished dừng; sau tải ch2_r4 core gọi set_round(shower) sau reset để tránh nền chain sai vòng. Tạm dừng đóng băng nhạc/đồng hồ. Không đổi cài đặt nhạc của người chơi.

## Scene nghe và QA

Mở F6 `res://audio/test/ch2_audio_test.tscn`. Trái/phải/Space chọn/nghe riêng23clip (tên ở console, không chỉnh gain cài đặt); 0 reset; Esc thoát qua App.quit. Solo dùng gain asset nguyên bản, không áp dụng reduced.

| Phím | Thử rig |
|---|---|
| 1/2/3 | Mumble của Phúc/Việt/Đạt |
| V | Luân phiên từng từ thật qua ba giọng, sau khi core thêm WORD_CH2; chưa có thì chỉ báo console |
| T | Lượt Trung15s, tick; có pulse nếu đã bật nhạc chain |
| F1/F2/F3 | Nước5/37/81độ |
| F4/F5 | Hơi mức1 / lựa chọn vòi sen8s |
| F6/F7 | Cửa bật / gương |
| L/S | corpse_lunge/scald qua signal |
| C | Xem room102 và phát sự kiện phòng thua |
| M/N | Nhạc nối từ / nhạc phòng tắm |

Đổi Giảm hù dọa trong game trước khi chạy fixture, thử L/S để so sánh; fixture không ghi settings. Bấm0 trước mỗi nhóm nếu cần nghe riêng. Các clip gục/bật/đẩy cửa đều nghe qua chế độ solo.

```powershell
pwsh tools/test.ps1 -Filter ch2_audio
pwsh tools/test.ps1
pwsh tools/check.ps1
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path game res://audio/test/ch2_audio_test.tscn --max-fps 60 -- --ch2-audio-preview --quit-after-frames=180
```

Test lời dùng resource cache với clip phi ngôn ngữ để xác nhận lookup/độ dài/pitch, không thay kiểm tra giọng đọc từ thật. Core cần sinh bank từ kịch bản đã duyệt, Lane E/integrator nghe lại độ rõ dấu tiếng Việt, thời lượng sau pitch và loudness đầu ra trên bản ghép.
