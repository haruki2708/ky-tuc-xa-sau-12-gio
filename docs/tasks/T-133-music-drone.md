# T-133 — Nhạc nền và drone căng thẳng
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-133-music-drone`
- Phụ thuộc: T-131 (done), T-136 (done). Đọc `docs/design/RULES.md` mục 5b, 6 và D-024, D-025 trong `docs/DECISIONS.md`.

## Mục tiêu
Demo hiện chỉ có âm môi trường và sting. Chủ dự án đã chơi thử và thấy: "đèn tắt phụt sẽ gây bất an nếu có nhạc" (D-025). Task này thêm **một lớp nhạc nền tối giản** phản ứng theo diễn biến: drone rất nhỏ khi bình thường, căng lên khi làm sai, dồn dập khi bị đuổi, và **im bặt** ngay trước cú hù. Nhạc phải nhỏ, không lấn tiếng ù đèn hay tiếng dép (chủ dự án thích âm nhỏ, D-015…D-023).

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`

## Yêu cầu
1. **Âm mới** (tự tổng hợp như T-131, CC0, khai báo AI nếu có), bus `Music`, loop liền mạch:
   | File | Loại | Dùng khi | Độ to |
   |---|---|---|---|
   | `music/drone_base` | loop 30–60 s | Từ 00:00 đến hết đêm | khoảng −42 LUFS, gần như chỉ cảm thấy |
   | `music/drone_tension` | loop | Vài chục giây sau mỗi lần làm sai; mức "lệch" càng cao càng dày | khoảng −36 |
   | `music/chase_pulse` | loop, nhịp khoảng 100–120 bpm | Trong lúc truy đuổi | khoảng −30 |
   | `music/end_tone` | one-shot 8–12 s | Màn "Còn tiếp" | khoảng −32 |
   Không dùng giai điệu rõ ràng: chỉ tiếng trầm, tiếng rít kim loại xa, tiếng ù có nhịp. Hợp không khí PS1 và ký túc xá đêm.
2. **`game/scripts/audio/music_director.gd`** (`class_name MusicDirector`, `extends Node`): integrator sẽ thêm một node vào `main.tscn`. Chỉ nghe `EventBus`, không gọi `StoryDirector`:
   - `segment_changed`: bắt đầu `drone_base` từ `seg2`; `end` thì nhỏ dần rồi phát `end_tone`;
   - `consequence_triggered`: `drone_tension` lên trong 2 s, giữ khoảng 15 s rồi nhỏ dần trong 8 s. Riêng `corridor_light_flicker` (đèn tắt phụt, D-025) thì **cắt mọi lớp nhạc** ngay lúc đèn tắt, rồi sau 3 s đưa `drone_tension` lên lại;
   - `deviation_changed(level)`: mức nền của `drone_tension` tăng theo mức 0–4 (ví dụ +2 dB mỗi mức, giới hạn ở mức trần đã nêu);
   - `scare_triggered`: **im lặng hoàn toàn** khoảng 1,5 s (lớp im lặng của D-025) rồi trả lại;
   - `chase_started`: `chase_pulse` vào trong 0,5 s; `chase_ended(caught)`: tắt trong 1,5 s; bị bắt thì cắt ngay;
   - `game_paused(true)`: giảm 10 dB; bỏ tạm dừng thì trả lại;
   - `[accessibility] reduce_scares` (đọc theo `docs/SETTINGS.md`): `chase_pulse` nhỏ hơn 6 dB, bỏ khoảng im lặng trước cú hù.
   Các signal `scare_triggered`, `chase_started`, `chase_ended` đã có trong `game/scripts/core/event_bus.gd` (integrator thêm cho task này).
3. Mọi thay đổi âm lượng đều mượt (tween), không có tiếng "bụp". Node phải dừng âm sạch khi `App.quit()` (có `stop_emitting()` hoặc dừng player như các nguồn âm khác).
4. **Test `game/tests/audio/`:** phát đúng lớp theo từng signal; im lặng khi có `scare_triggered`; mức `drone_tension` tăng theo mức lệch; `reduce_scares` giảm `chase_pulse`; pause thì giảm âm; file mới đúng bus và lặp liền mạch.
5. **Nghe thử:** thêm phím vào scene thử âm thanh hiện có để chủ dự án nghe riêng từng lớp và giả lập chuỗi "làm sai → bị đuổi → thoát".

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Đo LUFS từng file, ghi vào Handoff
- [x] `CREDITS.md` cập nhật
- [x] Handoff: cách gắn `MusicDirector` vào main, cách nghe thử, phần chưa thử bằng tai

## Handoff (agent điền)

### Đã làm (2026-10-03)
- Tạo nhánh từ `origin/main` tại `7dbce51`, đọc AGENTS → STATUS → card, RULES 5b/6, D-024/D-025, hợp đồng SETTINGS và signal thực tế. Commit triển khai **`4ed4124`** (`T-133: add adaptive music layers and EventBus music director`) đã push cùng 8 asset LFS mới.
- Bốn waveform gốc CC0, seed 13301–13304, tự tổng hợp bằng Python/FFmpeg có sẵn; OpenAI Codex hỗ trợ mã. CREDITS ghi nguồn/tác giả/công cụ theo từng file. Không nhạc mẫu, plugin hay cài phần mềm mới.
- Thêm `MusicDirector` (`Node`) chỉ nhận EventBus, tạo bốn player trên **Music**. Base seg2–5; tension attack 2 s/hold 15 s/release 8 s; đèn tắt im 3 s; scare im 1.5 s; chase vào 0.5 s/thoát 1.5 s/caught cắt nhanh; end fade 0.8 s rồi phát end tone sau 0.85 s. Đổi đoạn hoặc stop hủy lịch cũ.
- Gain transient tension theo level 0–4: −8/−6/−4/−2/0 dB so với asset; nền level 0 im, level 1–4: −12/−10/−8/−6 dB. Clamp level 0–4, không tăng riêng layer quá target −36 LUFS. Release về 0 tuyến tính **10 ms** cho các lần cắt tức thì để giảm nguy cơ tiếng bụp; trả sau khoảng im trong 0.3 s. Hai lý do im được quản lý riêng để không khôi phục sớm khi chồng nhau.
- Pause giảm 10 dB, vẫn phát nhạc bằng process Always; các đồng hồ giữ/im/end tạm dừng, fade ngắn vẫn chạy. `reduce_scares` đọc ConfigFile đúng bool, không ghi settings: chase giảm thêm 6 dB, bỏ/hủy khoảng im scare, vẫn giữ hậu quả đèn. Mỗi thay đổi settings/pause tween 0.2 s. `stop_emitting()` khóa phát lại và dừng/tắt lịch, tương thích App.quit; unload cũng dừng.
- Mở rộng scene scare_test và thêm 7 test MusicDirector, giữ các phím âm T-131. Đã commit `.import` và `.uid` của asset/script mới. 23 file triển khai đều đúng phạm vi; chỉ checklist/Handoff card này là tài liệu ngoài thư mục lane E. Không sửa STATUS, main, core, settings, bus layout hoặc localization.

### Số đo và kiểm chứng
| File | Thời lượng OGG | LUFS đo / mục tiêu | True peak dBTP | Chênh biên loop |
|---|---|---|---|---|
| `music/drone_base.ogg` | 32 s loop | −41.96 / −42 | −30.83 | 0.0007746 |
| `music/drone_tension.ogg` | 16 s loop | −35.99 / −36 | −22.75 | 0.0015736 |
| `music/chase_pulse.ogg` | 16 s loop, 112.5 BPM | −29.96 / −30 | −13.51 | 0.0012073 |
| `music/end_tone.ogg` | 10 s one-shot | −32.49 / −32 | −21.42 | Không loop |

- Pipeline hai lần `py -3 audio_source/process.py --regenerate-raw`, đều exit 0:
  - `AUDIO RESULT: 43 assets validated; raw + OGG = 18776110 bytes`
  - `REBUILD RESULT: 43 WAV + 43 OGG SHA256 identical; report identical`
  - `PRESERVATION RESULT: 78 approved WAV/OGG files match origin/main SHA256`
- Tổng raw+OGG **18.78 MB**. Giới hạn tổng của pipeline tăng từ 15 lên **20 MB** trong phạm vi audio_source để chứa các loop dài T-133; không hạ chất lượng hoặc thay âm đã duyệt. File lớn nhất `drone_base.wav` 3,168,044 byte, dưới 10 MB/file. Raw PCM16/48 kHz, OGG mono Vorbis q4, loop crossfade 1 s.
- Test audio ban đầu (trước bổ sung hai test startup/fixture cuối): `RESULT: 30 passed, 0 failed`.
- Bản cuối `pwsh tools/test.ps1`: **`RESULT: 225 passed, 0 failed`**, exit 0. Cả 7 test mới PASS: asset/hash/LUFS/loop/bus; signal/hold/deviation; overlap silence; chase/pause/reduction; end/reset/stop; settings startup/live; phím solo và chuỗi fixture.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0. `git diff --check` sạch. Các warning trong full test là fixture flag/save/document không hợp lệ và switch không gán đèn; không có ERROR.

### Cách gắn và nghe thử
- Integrator T-141 thêm một `Node` tên `MusicDirector`, gán `res://scripts/audio/music_director.gd` vào main **trước khi StoryDirector bắt đầu emit segment**. Khi tiếp tục checkpoint, phát lại `segment_changed` và `deviation_changed` hiện tại sau khi node đã ready. Không cần autoload, bus, input action hoặc signal mới. Slider Music/Master có sẵn do Lane D áp dụng, director không chỉnh bus gain.
- F6 scene `res://audio/test/scare_test.tscn`. **1/2/3/4** nghe riêng base/tension/chase/end. **M** chạy chuỗi: base → sau 3 s làm sai level 2 → sau 4 s đuổi → sau 5 s thoát; nhạc nền tiếp tục. Trong khi M chạy: **L** đèn tắt, **H** scare, **P** giả lập signal pause/unpause, **E** end. **0** dừng solo/hủy chuỗi và fade về seg1; **Esc** qua App.quit. F1–F11 giữ âm T-131.
- Solo gain 0 dB, bus Music; chuyển từ chuỗi M sang solo có đuôi fade 0.8 s. P chỉ giả lập duck của director, không pause cả scene hoặc solo. “Giảm hù dọa” đọc giá trị đã lưu khi mở scene; fixture không ghi file settings. Nghe base và loop ít nhất 60 s, rồi thử chuỗi và mix với hum/dép trong main sau tích hợp.

### Chưa kiểm chứng bằng tai / còn dở
- **Chưa nghe bằng tai cả bốn âm nhạc mới, các loop, mix hum/dép, fade/duck, khoảnh khắc im hay chuỗi truy đuổi.** Phiên này kiểm tra headless và số đo; không chạy nghe thử GUI. Không coi test tham số tween là xác nhận không có tiếng bụp trên thiết bị thật, hoặc mix đã được chủ dự án duyệt.
- Chưa gắn vào main vì ngoài scope. Những kết quả kiểm tra director/scene độc lập không thay thế lượt chơi thật sau tích hợp. Mọi checklist của card đã đạt theo nội dung ghi rõ ở trên.

### Yêu cầu thay đổi ngoài phạm vi
1. **T-141/core:** gắn node và phát lại trạng thái khi resume như hướng dẫn trên.
2. **Thời điểm scare:** `StoryDirector._chase_1`, `_chase_2`, `_on_player_failed` hiện emit `scare_triggered` cùng frame với sting/whisper (và hình). Director im nhạc **từ khi nhận signal**, không thể tự tạo khoảng im trước một sự kiện đã phát. Integrator cần dời cue trước cú hù khoảng 1.5 s, đồng bộ hình/sting/whisper và nhánh reduce_scares. Lane E không sửa hoặc trì hoãn core, không mute SFX/Voice.
3. **Thời điểm đèn:** `corridor_light_flicker` phát lúc bắt đầu nhấp nháy; `_room_light_cutout` tắt giữ lâu sau 5 nhịp. Hiện nhạc im từ lần tắt đầu theo signal. Nếu cần tính đủ 3 s từ lần tắt giữ lâu, core cần đồng bộ cue vào thời điểm đó; không hardcode độ dài animation đèn vào MusicDirector.

### Chặn / câu hỏi
- Không có chặn kỹ thuật trong phạm vi Lane E. Sandbox có lỗi Windows 1326, các lệnh cần thiết đã chạy ngoài sandbox với quyền được cấp; test/commit/push hoạt động. Chờ tích hợp thời điểm ở core và chủ dự án duyệt bằng tai; không tự đoán thay đổi luật/cốt truyện.
