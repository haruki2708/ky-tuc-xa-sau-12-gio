# T-158 — Âm thanh chương 1: tòa nhà la hét, quản lý kéo dao, cuộc gọi, máu
- Lane: E (Âm thanh) | Trạng thái: done | Agent:
- Nhánh: `lane-e/T-158-ch1-audio`
- Phụ thuộc: T-131, T-133. Đọc `docs/design/STORY.md` v2 §0, §5, §9, và D-015…D-019, D-023 (chủ dự án thích nền **khẽ**).
- **Hạn: hết ngày 2026-10-05.** Xong thì làm T-159 ngay.

## Mục tiêu
Chương 1 diễn ra trong một căn phòng; âm thanh vẽ ra mọi thứ bên ngoài: tiếng la hét lan khắp tòa nhà, tiếng quản lý kéo dao từ tầng khác tới gần dần, tiếng người trong cuộc gọi nhóm chết. Nền vẫn khẽ; cú hù dựa vào độ tương phản.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`, thêm key vào `strings.csv`.

## Hợp đồng có sẵn (không sửa)
`EventBus.phone_call_incoming`, `phone_call_answered`, `phone_message_received` (`MessageData.spoken`), `chat_member_changed`, `survivor_count_changed`, `player_caught`, `player_hidden`, `breath_held`, `noise_emitted`, `puzzle_solved`, `chapter_started`.

## Yêu cầu
1. **Bộ âm quản lý** (`game/audio/entities/manager_audio.tscn`, node con của quản lý T-152):
   - API: `play_step()`, `play_drag(on: bool)`, `play_knock()`, `play_slash()`, `play_kill()`, `say(line_key: String)` (phát giọng của T-159 và trả về thời lượng).
   - **Dao kéo lê** trên gạch: liên tục, rợn, là dấu hiệu chính để biết quản lý ở đâu.
   - **Nghe qua tầng:** nguồn ở tầng khác bị lọc trầm và nhỏ hơn (mỗi tầng cao 3,3 m). Làm thành script dùng chung (ví dụ `floor_muffle.gd`) để nguồn 3D nào cũng gắn được.
   - **Nguồn "từ xa":** API để integrator đặt quản lý chỉ có âm ở một vị trí bất kỳ trong tòa nhà (khi ông ta ở phòng khác, ngoài tầm nhìn) mà không cần mô hình, ví dụ `ManagerAudio.place_at(position)`.
2. **Tòa nhà la hét:** 3–5 tiếng hét khác nhau, đặt ở nhiều vị trí và tầng, có độ trễ; một đợt cho lúc 4:00 (mở đầu), các tiếng rời cho lúc quản lý giết người ở phòng khác. API `Screams.play_wave(origin, count, spread_seconds)` hoặc tương tự.
3. **Điện thoại và cuộc gọi:**
   - chuông cuộc gọi "tít tít";
   - **bộ lọc giọng điện thoại** (band-pass, hơi rè) cho mọi câu `spoken` trong cuộc gọi;
   - tiếng mất kết nối; tiếng "rơi điện thoại, vỡ" khi một thành viên chết (nghe qua cuộc gọi).
   - Âm lượng giọng trong cuộc gọi nghe rõ, đã qua lọc.
4. **Máu và xác:** nhỏ giọt trên sàn gạch (vòng lặp, rất khẽ); tiếng sột soạt nhỏ khi xác đổi tư thế (`pose_changed` của T-152).
5. **Chém và giết:**
   - chém vào nệm hoặc gỗ (nhiều biến thể);
   - cảnh giết người chơi;
   - với "Giảm hù dọa" thì các âm này nhỏ và ít chi tiết hơn.
6. **Người chơi:**
   - tim đập rất khẽ khi nín thở, nhanh dần;
   - thở hắt khi hết hơi;
   - tiếng trèo lên giường tầng, tiếng sắt giường;
   - gõ tường sang phòng bên;
   - mở tủ khóa số; cắm sạc.
7. **Loa trường:** tiếng bật loa và nhiễu đầu câu kiểu "như trong tù" (giọng ở T-159). Giữ hệ `Speaker` hiện có.
8. **Nhạc:** drone rất thấp cho vòng 1; căng hơn khi quản lý tới gần (nghe khoảng cách tới 407, hoặc integrator đặt mức qua API); im bặt trước khi quản lý mở cửa 407.
9. **Mức âm lượng:** ghi LUFS từng âm trong Handoff. **Chủ dự án sẽ nghe và duyệt.**
10. **Scene thử** `audio/test/ch1_audio_test.tscn`: phím nghe từng âm; một nguồn quản lý đi từ tầng 6 xuống tầng 4 để nghe hiệu ứng qua tầng.
11. **Test:** đủ file, đúng bus, nguồn khác tầng bị lọc, API không lỗi khi thiếu stream.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] `CREDITS.md` đủ nguồn và công cụ
- [x] Handoff: danh sách âm và LUFS, API, cách nghe thử

## Bổ sung từ integrator (2026-10-04, sau khi viết luồng chương)
- Bộ âm quản lý "từ xa": node vào **group `manager_audio`**, có `place_at(position: Vector3)`.
- Tiếng la hét: node vào **group `screams`**, có `play_wave(origin: Vector3, count: int, spread_seconds: float)`.
- Hai node này nên được tạo sẵn trong một scene, ví dụ `res://audio/entities/ch1_audio.tscn`, để integrator instance vào `chapter1.tscn`.

## Handoff (agent điền)

### 2026-10-04 — Lane E, sẵn sàng review và nghe duyệt

- Commit triển khai **`02a7ae0`**, đã push `origin/lane-e/T-158-ch1-audio`, gồm 58 object LFS (29 WAV + 29 OGG). Nhánh đã đồng bộ `origin/main` **`47c58c2`**. Chỉ sửa vùng audio và checklist/Handoff card này; không sửa main scene, core, Player, thực thể, STATUS hoặc lời thoại.
- Tạo 29 âm gốc bằng Python/FFmpeg có sẵn, CC0, khai báo OpenAI Codex/AI-assisted trong `game/audio/CREDITS.md`. Không lấy âm từ video/game, không thêm plugin, không tải/cài công cụ. Giữ nguyên hash **154 WAV/OGG** của hai bank cũ, gồm hum/quạt/dép đã duyệt.
- Hoàn thiện rig quản lý độc lập mô hình, lọc nguồn qua tầng, đợt hét có vị trí/độ trễ, cuộc gọi có hàng đợi thoại/bộ lọc, máu/xác, Foley người chơi, profile loa chương 1 và nhạc nền/tension/im lặng. Có clip slash/kill ít chi tiết và nhỏ hơn cho giảm hù dọa, áp dụng cả khi đổi settings trong lúc đang phát.
- Pipeline: `py -3 audio_source/ch1_process.py`; tài liệu đầy đủ: [audio_source/ch1/README.md](../../audio_source/ch1/README.md). Report hash/LUFS/peak/loop/thời lượng: `audio_source/ch1/build_report.json`. Tổng bank mới **6.211.873 byte** raw + OGG; mỗi file dưới 10 MB. True peak lớn nhất **−8,60 dBTP**. Các con số dưới đây là asset trước gain bus, khoảng cách và bộ lọc, không phải LUFS tổng mix.

### Kết quả xác minh

Lượt cuối sau đồng bộ main, không lỗi engine, cả hai lệnh exit 0:

```text
pwsh tools/test.ps1
RESULT: 272 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
```

- Có **13 test T-158 mới**; lượt riêng `pwsh tools/test.ps1 -Filter ch1_audio`: `RESULT: 13 passed, 0 failed`. Kiểm tra file/decode/hash/loop/LUFS, routing qua slider, filter riêng nguồn/cùng tầng/khác tầng/âm y âm, giải phóng bus, API khi thiếu stream, FIFO thoại và thành viên chết, reduced live, tim tăng nhịp/hơi hắt, pause, nhạc giữ im, Speaker, tất cả clip trong fixture.
- Scene thử chạy headless theo thời gian thật, đủ 900 frame giới hạn 60 fps, thoát App.quit exit 0, không ERROR/WARNING. **Chưa nghe bằng tai, chưa kiểm tra bằng loa/tai nghe hoặc duyệt chất âm.** Test không chứng nhận tiếng hét tổng hợp đã giống người thật, Foley đã tự nhiên, loop đã mượt theo cảm nhận hoặc giọng qua điện thoại đã dễ nghe.
- Lượt đầu trong sandbox vướng kho chứng chỉ Windows, đã chạy lại ngoài sandbox. QA dùng `--fixed-fps` quá nhanh từng báo audio resource còn dùng khi thoát; chạy lại `--max-fps 60` theo thời gian thật sạch. Không sửa App/core để xử lý chế độ mô phỏng tăng tốc.
- `git diff --check` PASS; kiểm tra phạm vi PASS; 58 hash asset mới khớp report sau Git LFS restore. Không export/build bản game trong task này.

### Âm và LUFS đo từ OGG

File nằm dưới `game/audio/ch1/`, đuôi `.ogg`; raw tương ứng ở `audio_source/ch1/raw/`.

| File | LUFS | Ghi chú |
|---|---:|---|
| manager_step_01 | −42.01 | Bước quản lý |
| manager_step_02 | −41.96 | Biến thể bước |
| manager_drag | −34.03 | Loop 6 s, kim loại kéo trên gạch |
| manager_knock | −29.95 | Ba nhịp gõ |
| slash_mattress_01 | −28.14 | Chém nệm |
| slash_mattress_02 | −28.13 | Biến thể nệm |
| slash_wood_01 | −28.17 | Chém gỗ |
| slash_wood_02 | −28.10 | Biến thể gỗ |
| manager_kill | −26.09 | Kết liễu, 2 s |
| kill_soft | −37.94 | Giảm hù dọa: một va đập trầm |
| slash_soft | −39.99 | Giảm hù dọa: bớt lớp chi tiết |
| scream_01 | −29.97 | 2.75 s |
| scream_02 | −29.96 | 3 s |
| scream_03 | −29.94 | 3.25 s |
| scream_04 | −29.95 | 3.5 s |
| call_ring | −33.93 | Hai tít, loop 3 s |
| call_disconnect | −33.94 | Mất kết nối |
| call_drop | −30.13 | Điện thoại rơi/vỡ; runtime qua PhoneSFX |
| blood_drip | −47.94 | Loop 8 s, bus Ambience thêm −3 dB |
| corpse_rustle | −46.29 | Sột soạt khẽ |
| heartbeat | −48.00 | Hai xung, tăng nhịp qua API |
| breath_gasp | −38.31 | Hơi hắt |
| bunk_climb | −41.94 | Trèo giường |
| bunk_creak | −43.92 | Sắt giường |
| wall_knock | −37.95 | Gõ tường |
| locker_unlock | −37.97 | Khóa/tủ kim loại |
| charger_plug | −39.93 | Cắm sạc |
| pa_on | −32.32 | Bật loa chương 1 |
| pa_burst | −36.01 | Nhiễu ngắn đầu câu |

Nhạc dùng lại `music/drone_base.ogg` **−41.96 LUFS**, gain 0.65 trong Ch1Music (~−45.7 LUFS riêng layer); `music/drone_tension.ogg` **−35.99 LUFS**, gain 0–1. Không đổi file nhạc T-133. Giọng nói mới thuộc T-159, chưa sinh trong task này.

### API chính

- `ManagerAudio` (`game/audio/entities/manager_audio.tscn`): `play_step()`, `play_drag(bool)`, `play_knock()`, `play_slash(material=&"mattress")` / `&"wood"`, `play_kill()`, `say(line_key)->float`, `place_at(world_position)`. Giọng Voice, còn lại SFX qua bus riêng FloorMuffle. `say` tìm `<voice_directory>/<locale>/MGR_*.ogg`; có clip trả length+0.4, thiếu trả phụ đề 2.5 s; một subtitle/câu. Instance rig riêng dưới Node3D để đặt quản lý chỉ có âm từ xa.
- `FloorMuffle` làm con AudioStreamPlayer3D bất kỳ; export listener, floor_base_y, floor_height=3.3. Chênh mỗi tầng −8 dB, LP24 với cutoff 2200/gap (tối thiểu 450 Hz), cùng tầng dry. Bus theo nguồn, không làm đục nguồn khác, giữ gain nguồn và bus cha. Unload trả routing/xóa bus. Không mô phỏng occlusion tường/cửa.
- `BuildingScreams.play_wave(origin,count,spread_seconds)`, `play_at(position)`, `stop_emitting()`: đợt tối đa 12 tiếng, bốn biến thể, phân tán ba tầng từ origin; đợt mới hủy đợt cũ. Caller dàn vị trí/cảnh chết, không tự kích hoạt từ đồng hồ truyện.
- `PhoneCallAudio`: nối incoming/answered/message_received/member_changed; FIFO câu spoken, giọng qua PhoneVoice→Voice, rơi/ngắt qua PhoneSFX→SFX. Hai bus mới HP300/atan nhẹ/LP3400, không thêm slider/settings. `play_message(MessageData)->float`, signal `line_started(key,duration)`, `end_call(with_tone=true)`. Thiếu giọng trả 0, transcript vẫn do UI qua signal gốc. T-159 cung cấp `CHAT_CH1_*.ogg` **chưa lọc điện thoại** vào cùng bank giọng, tránh lọc hai lần.
- `CorpseAudio`: `play_drips(bool)`, `play_pose(name)`; export poser để tự nối `pose_changed` của T-152. Không bật máu sẵn lúc ready.
- `Ch1PlayerAudio`: nối breath_held, breath noise radius≥4 m, player_hidden kiểu bunk/bed, player_caught. Tim 1.1→0.66 s/nhịp trong 8 s. `play_action` cho bunk_climb/bunk_creak/wall_knock/locker_unlock/charger_plug/breath_gasp. Không tự phát gameplay noise hoặc đoán ID câu đố. Có `handle_player_caught` để tránh âm giết trùng với ManagerAudio.
- `Speaker.chapter_profile=true`: pa_on thay bật loa, bỏ chuông demo, pa_burst đầu câu, giữ API/subtitle/cancel/garbled. Bank nhận key `SPK_CH1_*` khi T-159 có clip. Mặc định false nên demo giữ nguyên.
- `Ch1Music`: `set_active(bool)`, `set_tension(0..1)`, `silence_before_door(bool)`; chốt im trong 10 ms, tension không phá im, trả nhạc 1 s; pause duck −10 dB. Nối chapter_started/finished. Gắn thay MusicDirector demo ở chương 1.
- Các rig bình thường kế thừa pause, riêng Ch1Music Always để fade/duck tiếp tục; App.quit gọi stop_emitting. Tạo node trước khi phát signal khởi động. Chi tiết giới hạn và cách khôi phục checkpoint ở README.

### Cách nghe thử

Mở **`res://audio/test/ch1_audio_test.tscn`**, F6:

- Trái/phải/Space: chọn/nghe 29 clip riêng, tên in console; 0 dừng/reset, Esc thoát App.
- F1 bước, F2 kéo dao, F3 gõ, F4/F5 chém nệm/gỗ, F6 giết; thử lại F4–F6 sau khi bật giảm hù dọa trong menu game (fixture không ghi settings).
- F7 đợt hét; F8 gọi tới, F9 nhận, F10 thành viên chết, F11 ngắt.
- **F12** nguồn quản lý đi từ tầng 6 xuống 5 xuống 4 trong 13 s, kéo dao, tới nơi gõ; nghe qua tai nghe để so vị trí và lọc qua tầng.
- B máu, C sột soạt, H giữ/thả hơi, G hơi hắt; M nền, T tension, S chốt im/trả nhạc; V loa profile mới với hai câu demo làm fixture; P chỉ giả lập duck khi pause.
- Muốn nghe trèo giường/gõ tường/mở khóa/cắm sạc, chọn các clip qua mũi tên. Phím solo phát nguyên asset; giảm hù dọa được kiểm tra qua API F4–F6.

QA đã chạy:

```powershell
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --headless --path game res://audio/test/ch1_audio_test.tscn --max-fps 60 -- --ch1-audio-preview --quit-after-frames=900
```

### Yêu cầu thay đổi ngoài phạm vi / phần cần ghép

1. **Integrator (main/core):** gắn PhoneCallAudio, Ch1PlayerAudio, BuildingScreams; thay MusicDirector demo bằng Ch1Music cho chương 1; bật chapter_profile của Speaker. Gọi đợt hét ở mốc truyện, đặt tension theo quản lý gần 407, gọi silence_before_door trước mở cửa và chủ động trả nhạc sau cảnh. Không có node/autoload/input mới được tự gắn từ lane E.
2. **Lane A / Integrator:** instance ManagerAudio và gọi API đúng bước/chém/kéo dao/hỏi; gắn CorpseAudio vào ba xác, nối pose_changed, bật máu tại mốc được dàn dựng. Gán floor_base_y đúng mặt sàn của level, dùng rig độc lập cho quản lý ở phòng khác. Tránh gọi cả ManagerAudio.play_kill và Ch1PlayerAudio qua player_caught cho cùng một lần chết.
3. **Lane A / Integrator:** nối play_action vào trèo giường/gõ tường/mở tủ/cắm sạc; gọi PhoneCallAudio.end_call khi hết pin/mất mạng/kết thúc cuộc gọi. Chưa có signal chung xác định chính xác các tương tác này nên không tự đoán từ puzzle_id. Không yêu cầu sửa EventBus bắt buộc: API hiện có đủ để nối.
4. **T-159 / câu hỏi cho Integrator:** bản thoại nháp đã lên main `47c58c2`, nhưng card T-150 còn ghi chờ chủ dự án duyệt. Khi nào bản thoại được chốt/báo sẵn sàng để bắt đầu T-159? Không tự viết, suy đoán hoặc sinh giọng cho bản nháp trong T-158. Đường nạp giọng và tra duration đã sẵn.

**Không còn blocker kỹ thuật trong phạm vi T-158; ba checklist đã đạt.** Còn chờ ghép vào chương 1 và chủ dự án nghe/duyệt chất âm; đây chưa phải xác nhận toàn chương đã tích hợp hoặc chơi thử xong.

### Review (integrator, 2026-10-04)
- **Đạt, đã merge.** Đúng phạm vi; 13 test mới; LUFS ghi đủ; Handoff ghi rõ chưa nghe bằng tai. **Chủ dự án cần nghe duyệt** qua `res://audio/test/ch1_audio_test.tscn` hoặc trong chương 1.
- Đã ghép vào `chapter1.tscn`:
  - `Ch1Music` thay `MusicDirector` demo; độ căng tăng dần qua vòng 2; im lặng trước khi quản lý mở cửa 407;
  - `PhoneCallAudio`, `Ch1PlayerAudio`;
  - `ManagerAudioFar` (group `manager_audio`): dao kéo lê ở các tầng khác, gõ cửa, chém giường khi chưa có quản lý của lane A;
  - `BuildingScreams` (group `screams`);
  - `RoomDrips` (`CorpseAudio`, group `corpse_audio`): máu nhỏ giọt bật theo `set_blood_stage`;
  - loa dùng `chapter_profile`.
- **Integrator sửa một lỗi tích hợp** trong `ch1_player_audio.gd`: khi scene bị giải phóng lúc người chơi đang nằm, `Player._exit_tree` phát `player_hidden(false)` làm `play_action` phát âm ngoài scene tree ("Playback can only happen when a node is inside the scene tree"). Đã thêm kiểm tra `is_inside_tree()`.
