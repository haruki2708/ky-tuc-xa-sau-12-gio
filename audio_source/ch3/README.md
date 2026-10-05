# T-186 — Âm thanh chương 3

35 âm tự tổng hợp CC0, không dùng lời thoại hoặc sample bên ngoài. **Chưa nghe bằng tai; chưa duyệt cảm nhận/mix và chưa playtest trong campus thật.** Kiểm tra tự động không thay thế việc này. Nguồn/giấy phép ở `game/audio/CREDITS.md`; seed, hash raw/OGG, LUFS, peak, thời lượng và biên loop ở `build_report.json`.

## Tạo lại

Tại gốc repo: `py -3 audio_source/ch3_process.py`. Dùng Python stdlib và FFmpeg có sẵn dưới `D:/Tools/ffmpeg`; không tải/cài gì. PCM nguồn mono 48 kHz/16-bit → HP35/LP7500, bản chết nhẹ thêm LP700, fade đầu/đuôi one-shot, nối chéo 1 giây cho loop → OGG Vorbis q4. Gain tuyến tính được hiệu chỉnh theo phép đo loudnorm trên OGG đã mã hóa; không dùng loudnorm để nén động học. Report kiểm tra sai số LUFS ≤1 dB, peak ≤−2 dBTP, biên loop <0,01. Giới hạn riêng bộ raw+OGG là 20 MB, thực tế 11.981.062 byte; mỗi file vẫn dưới 10 MB và đi qua LFS.

LUFS là của từng file trước bus, vị trí 3D và cộng nhiều nguồn, **không phải loudness tổng mix tại tai**. Không nâng âm lượng hệ thống chỉ để nghe còi: còi chủ ý rất khẽ. Tim và bước chân gạch dùng asset CC0 cũ, không sửa waveform của chúng.

## Rig/API cho core và Lane A/B

Tất cả script ở `game/scripts/audio/`. Tạo `.new()`, gán tham chiếu/export trước `add_child`, rồi gọi API sau khi node đã ready. Tạo các rig trong scope chương 3; gọi `stop_emitting()` trước tháo scene. Các rig mới mặc định im cho tới khi được cấp trạng thái; pause theo SceneTree. Không phát `noise_emitted`, không quyết định AI/stamina/luật chơi.

| Rig | Cách ghép |
|---|---|
| `Ch3HordeAudio` | Một instance cho chương, `listener = player` (root ở chân), `register(rig)` sau khi tạo từng xác; `unregister(rig)` khi pool trả xác. Tự dọn tham chiếu freed/out-of-tree. `voice_limit = 8`, clamp runtime 1..8; có thể đặt 6. Xác ngoài 60 m không phát nguồn riêng. Sắp theo khoảng cách 3D mỗi frame, tie theo instance id, tắt nguồn cũ trước khi mở nguồn mới. |
| `ZombieAudio` | Child mỗi `Zombie` (hoặc gán `zombie` trước add). Tự nhận `zombie_woke`/`zombie_stunned` đúng identity. Gameplay gọi `set_hunting(false)` khi ngủ; **`set_hunting(true)` khi hồi stun nếu không phát lại `zombie_woke`**. Không tự đặt timer hồi sinh. `set_eligible(false)` khi khuất/cập nhật thưa, `true` khi lại hợp lệ. `play_step()` theo nhịp bước thật; `play_door_hit()` đúng thời điểm đập cửa 407/203. `hissing = true` chọn thở rít, false gầm khàn. |
| Nền bầy | Một player Ambience chung trong manager; gain `clamp(hunting_count / 40, 0, 1)`. Đếm cả xác săn bị loại khỏi nguồn riêng. Mỗi xác được chọn tối đa **2 player** (1 loop giọng, 1 Foley bước/đập thay nhau), tức tối đa 16 player riêng + 1 nền bầy, không phải 8 channel. Xác ngủ/stun im; không dự đoán vị trí/tiếng phá cửa. |
| `Ch3PlayerAudio` | Một instance listener-local, tự nhận stamina/bar/death/checkpoint. Pant nặng/gấp theo stamina 0..1, chu kỳ 1,35–2,8 s; exhausted 1,05 s và heartbeat 0,65 s. Bản thân clip pitch 0,95–1,35; hồi ≥0,95 và hết exhausted thì im. Bar vung + hit/miss; chỉ hit còn 1–2 độ bền mới cong; `bar_broken` thay lớp cong bằng gãy. |
| `FootstepPlayer` | Giữ API `play_footstep(surface, intensity)`, nối signal `Player.footstep`. Thêm `grass`, `concrete` (4 mẫu mỗi loại, không lặp liền); `tile` giữ bank đi/chạy cũ. Grass/concrete dùng cùng texture bước nhưng giảm gain theo intensity khi đi. Lane A phải chọn surface từ collider/khu thực tế. Bus Footsteps → SFX. |
| `Ch3Environment` | Gán `insect_emitters` là **tất cả AmbientEmitter côn trùng cũ còn sống** và `scream_points` là các Node3D vị trí xa do core chọn. `set_area(&"stairs"/"stadium"/"canteen"/"garden"/"road"/"gate")`; ba khu đầu có nền riêng, ba khu cuối gió. Ngoài trời hét mỗi 30–55 s (lần đầu 35 s), một source 3D; không có điểm hợp lệ thì im. `play_far_scream()` hỗ trợ nghe thử. Côn trùng vẫn tắt khi chết/checkpoint; thoát chương, `set_area(&"")`, hoặc dỡ rig mới khôi phục trạng thái trước đó. |
| `ReverbZone` | Thêm preset `STADIUM` (0,95/0,65/0,12), `CANTEEN` (0,45/0,8/0,10), `STAIRS` (0,75/0,4/0,24): room_size/damping/wet. Lane B/core đặt volume collision phù hợp; dùng cơ chế ưu tiên/fade/restore bus có sẵn. Không sửa layout bus toàn cục. |
| `Ch3SirenAudio` | Gán `listener = player` root ở chân, `high_spot = campus.get_anchor("Clues/SirenSpot")`. Marker phải ở **sàn chỗ nghe cao**. `set_enabled(true)` khi vào vùng Stadium/Bleachers, false khi ra. Chỉ phát nếu cách marker theo xz ≤2,5 m, lệch y ≤0,6 m và tốc độ đo từ dịch chuyển root ≤0,12 m/s. Không hardcode cao độ campus, không nghe dưới khán đài/cao ở nơi khác/đang đi. Reset/death/end tắt; core bật lại sau nạp checkpoint. Còi −56,96 LUFS, không thêm UI/hint. |
| `Ch3GuardAudio` | Child từng guard hoặc gán `guard`. Chỉ nhận `guard_warned` đúng node; true chạy loop spatial SFX ≤10 m, false tắt. Death/end khóa cho tới checkpoint/chapter reset. |
| `Ch3Music` | `set_area` theo khu; `set_running(bool)` từ trạng thái chạy thật; `set_wave(bool)` từ đợt sân vận động. Crossfade 1,5 s, wave chỉ khi area=`stadium`; canteen tắt ngay cả khi running/wave còn true. `chapter_finished(3)` chơi nốt dài đúng một lần; death/reset dừng. Sau reset core truyền lại area/running/wave. |
| `Ch1PlayerAudio` đã có | Dùng lại **một owner cảnh chết**: thêm `chapter3_directory`, `zombie_grab`/`guard_shock`. Không tạo bản thứ hai nếu core đã có. `player_caught(zombie/guard)` không phát nhầm manager kill kể cả signal đến trước death. Bản nhẹ giảm ~11 dB, bỏ lớp xé/điện gắt, LP700; chuyển sang nhẹ ngay nếu bật setting lúc đang phát. |

Horde, guard và music ngăn signal muộn làm phát lại sau death/end. `stop_emitting()` là khóa vĩnh viễn của instance; dùng instance mới cho scene mới. Checkpoint reset không tự suy đoán khu hay khởi chạy lại đám xác: core cấp lại trạng thái từ save. Nếu dùng lại rig pooled, gọi `set_hunting(false)`/`unregister` thay vì `stop_emitting()`.

### Yêu cầu tích hợp ngoài phạm vi

- Core gắn rig theo bảng, truyền lại trạng thái sau checkpoint, giữ một owner cảnh chết; loại âm/nhạc chương cũ khi chuyển chương. Không có sửa core/scene campus trong nhánh này.
- Lane A nối bước/chạm cửa, hồi stun, eligibility khuất/ticking thưa, surface bước chân và trạng thái chạy. Không phát thêm gameplay noise từ audio. Không cho Ch1PlayerAudio xử lý gasp cũ đồng thời với pant chương 3 nếu gameplay vẫn dùng nguồn `breath` bán kính ≥4 m.
- Lane B/core gắn marker nghe ở chân khán đài cao, vùng siren và ReverbZone, cung cấp điểm hét xa và danh sách emitter côn trùng cần tắt.
- Không tự ánh xạ `scare_triggered` sang ID chưa được thống nhất, không sinh lời thoại cho `companion_state_changed`, không gắn tiếng hét vào sự kiện cốt truyện tự đoán. Câu hỏi cho integrator: có cần ánh xạ cue vào scare ID cụ thể ngoài bước/đập cửa/death đã có hay không? Các tiếng mô tả trong card đều có API/asset để gọi.

## Nghe thử và xác minh

Mở `game/audio/test/ch3_audio_test.tscn` trong Godot, chạy scene hoặc:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game res://audio/test/ch3_audio_test.tscn
```

Đây là fixture âm thanh (camera, 40 node giả, không phải bản đồ gameplay); tên âm/log ở console, không thêm chữ hardcode vào UI game.

| Phím | Nhóm |
|---|---|
| ← / → / Space | Lần lượt 35 clip / phát lại; console in tên và thứ tự |
| 1 / D | Thức 40 xác, log số nguồn xác ≤8 / một xác được chọn đập cửa |
| 2 / M / B | Bar trúng còn 2 hit + cong / trượt / gãy |
| 3 / 4 / R | Stamina 50% / cạn + tim / hồi đầy |
| T / Y / U | Chạy gạch / cỏ / bê tông |
| 5 / F | Gió ngoài trời / hét xa tại điểm fixture |
| 6 / G | Đưa listener lên marker cao + còi / xuống đất cùng xz để kiểm tra im |
| 7 | Điện dùi cui |
| 8 / 9 / C / S / E | Nhạc chạy / đợt sân vận động + nền / nhà ăn im nhạc / nền cầu thang / nốt cuối chương |
| Z / X | Chết zombie / guard; bật “Giảm hù dọa” trong cài đặt để so bản nhẹ |
| 0 / Esc | Reset các nhóm / thoát |

Sau cảnh chết hoặc nốt kết, bấm 0 trước nhóm tiếp theo. Arrow audition là nghe asset thô nên không áp dụng vị trí/eligibility; dùng 1/6/G để kiểm tra rig thực sự. Preset vang kiểm tra bằng test ReverbZone; fixture không dựng volume kiến trúc giả.

```powershell
pwsh tools/test.ps1 -Filter ch3_audio
pwsh tools/test.ps1
pwsh tools/check.ps1
```

Test gồm 40 xác/nearest/hard cap 8, occlusion flag/60 m/stun/free/reset, pant/heartbeat/pause, bar không phát gameplay noise, còi cao–thấp–xa–đang đi, tắt côn trùng cả khi chết/checkpoint, guard identity, hai death/reduced/signal order, canteen/ending, footsteps, reverb restore, bank thiếu, asset hash/decode/LUFS và fixture teardown.

## Mức đo từng file

| Tên | LUFS | dBTP | Giây | Loop |
|---|---:|---:|---:|---|
| zombie_growl | -43.05 | -28.25 | 4.00 | Có |
| zombie_hiss | -44.34 | -29.41 | 4.00 | Có |
| zombie_drag_01 | -43.24 | -24.16 | 0.80 | Không |
| zombie_drag_02 | -43.20 | -22.10 | 0.80 | Không |
| horde | -46.08 | -32.42 | 7.00 | Có |
| door_pound_01 | -36.94 | -16.75 | 1.00 | Không |
| door_pound_02 | -38.01 | -19.63 | 1.00 | Không |
| bar_swing | -39.30 | -26.85 | 0.55 | Không |
| bar_hit | -34.94 | -16.28 | 0.80 | Không |
| bar_miss | -43.35 | -29.83 | 0.60 | Không |
| bar_bend | -42.04 | -23.39 | 1.00 | Không |
| bar_break | -36.18 | -17.36 | 1.40 | Không |
| pant | -43.35 | -30.80 | 1.30 | Không |
| run_grass_01 | -39.06 | -15.13 | 0.55 | Không |
| run_grass_02 | -39.07 | -17.98 | 0.55 | Không |
| run_grass_03 | -39.14 | -16.27 | 0.55 | Không |
| run_grass_04 | -39.06 | -17.94 | 0.55 | Không |
| run_concrete_01 | -38.98 | -18.25 | 0.55 | Không |
| run_concrete_02 | -39.07 | -17.94 | 0.55 | Không |
| run_concrete_03 | -39.13 | -16.85 | 0.55 | Không |
| run_concrete_04 | -39.01 | -17.95 | 0.55 | Không |
| wind | -53.25 | -37.96 | 7.00 | Có |
| stadium | -52.22 | -37.11 | 7.00 | Có |
| canteen | -54.01 | -43.07 | 7.00 | Có |
| stairs | -52.19 | -36.85 | 7.00 | Có |
| far_scream | -47.96 | -38.56 | 3.00 | Không |
| rescue_siren | -56.96 | -53.12 | 8.00 | Có |
| baton_buzz | -41.97 | -34.42 | 3.00 | Có |
| death_zombie_grab | -33.10 | -16.06 | 3.00 | Không |
| death_zombie_soft | -44.19 | -23.87 | 3.00 | Không |
| death_guard_shock | -32.99 | -16.47 | 3.00 | Không |
| death_guard_soft | -44.11 | -24.83 | 3.00 | Không |
| music_run | -50.97 | -39.76 | 8.00 | Có |
| music_wave | -47.97 | -35.29 | 8.00 | Có |
| music_end | -48.79 | -38.36 | 7.00 | Không |
