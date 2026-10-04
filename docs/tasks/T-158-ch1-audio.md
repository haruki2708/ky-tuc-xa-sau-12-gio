# T-158 — Âm thanh chương 1: tiếng của hai thực thể, bước chân qua tầng, im lặng theo dõi, hù hụt
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-158-ch1-audio`
- Phụ thuộc: T-131, T-133. Đọc `docs/design/STORY.md` §5 và §7, và D-015…D-019, D-023 (chủ dự án thích âm **nhỏ**).
- **Hạn: hết ngày 2026-10-05.** Xong thì làm T-159 ngay.

## Mục tiêu
Theo chủ dự án, âm thanh chủ đạo là **tiếng bước chân và tiếng động lạ**, không khí ngột ngạt và luôn bị theo dõi. Nền vẫn rất khẽ như các mức đã duyệt. Cú hù dựa vào độ tương phản, không dựa vào âm to.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`, thêm key vào `strings.csv`.

## Hợp đồng có sẵn (T-150, không sửa)
`EventBus.entity_state_changed(entity_id, state)`, `watcher_active(active, position)`, `player_caught(entity_id)`, `player_hidden(hidden, kind)`, `breath_held(holding)`, `puzzle_solved(id)`, `chapter_started(n)`.

## Yêu cầu
1. **Bộ âm Người đi dép** (`game/audio/entities/walker_audio.tscn`, node con gắn vào thực thể của T-152):
   - API: `play_step(running: bool)`, `set_breathing(on: bool)`, `play_inhale()`, `play_whisper()`.
   - **Bước chân:** tiếng "lẹp xẹp", kèm một tiếng dép lết dài; khác hẳn tiếng dép của người chơi để nhận ra ngay. Có biến thể đi và chạy.
   - **Thở:** khò khè rất khẽ, nghe trong khoảng 4 m.
   - **Hít vào:** khi nó vừa thấy người chơi (cảnh báo cuối cùng, §5.1).
   - **Thì thầm "Giường của tao"** khi bắt (key `SUB_WALKER_WHISPER`, dùng TTS và xử lý như giọng loa, ghi CREDITS).
   - **Nghe qua tầng:** nguồn ở tầng khác với người nghe thì trầm (lọc thấp) và nhỏ hơn, nhưng vẫn nghe được. Tầng xác định theo Y, mỗi tầng 3,3 m (T-153). Làm thành script dùng chung (ví dụ `floor_muffle.gd`) để các nguồn 3D khác cũng gắn được.
2. **Im lặng khi bị theo dõi:**
   - Khi `watcher_active(true, position)`: các `AmbientEmitter`, `LightHum` và vùng âm môi trường trong bán kính khoảng 8 m quanh `position` nhỏ dần về im lặng trong 1,5 giây.
   - Khi `watcher_active(false, …)` hoặc nó nhảy đi chỗ khác: trả lại như cũ. Đây là dấu hiệu duy nhất của Người thứ năm (§5.2).
3. **Hù hụt** (§7), one-shot 3D, gọi theo tên qua một API đơn giản (ví dụ `ScareLibrary.play(&"cat_railing", position)`):
   - `phone_buzz_wood` (điện thoại rung trên mặt gỗ),
   - `cat_railing` (mèo nhảy trên lan can),
   - `bunk_creak` (giường sắt kẽo kẹt như có người trở mình),
   - `far_drop` (đồ rơi xa),
   - `window_bang` (cửa sổ đập),
   - `upstairs_slippers` (dép lê ở tầng trên, cho cảnh ở tầng 6 nghe tiếng từ sân thượng đã khóa).
4. **Âm môi trường chương 1:**
   - **Xích cổng sắt:** mở, rơi xuống sàn.
   - **Bước chân trên cầu thang bê tông:** thêm bank cho `surface = &"concrete"`, cả đi, chạy và cúi; giữ đúng mức âm lượng của D-019.
   - **TV CRT:** tiếng bật, tiếng xì nhiễu nền.
   - **Cầu dao:** tiếng gạt; tiếng nhảy aptomat; đèn bật lại.
   - **Tủ khóa số:** tiếng vòng số; tiếng mở.
   - **Sân phơi:** gió; áo phần phật.
   - **Nấp:** chui gầm giường, mở/đóng tủ sắt, cài chốt buồng vệ sinh.
   - **Nín thở và thở ra:** tiếng tim đập rất khẽ khi đang nín thở.
   - **Tiếng thở của người chơi khi nấp:** đồng bộ với `noise_emitted(…, &"breath")` của T-151; nếu cần một API thì ghi vào Handoff.
5. **Nhạc** (`MusicDirector`): nghe `entity_state_changed` để vào nhạc truy đuổi khi Người đi dép đuổi; khi đang `listen` hoặc `search` thì drone căng hơn. Giữ khoảng lặng trước jumpscare như T-133.
6. **Mức âm lượng:** ghi LUFS từng âm trong Handoff. Nền giữ khẽ như đã duyệt. **Chủ dự án sẽ nghe và duyệt.**
7. **Scene thử** `audio/test/ch1_audio_test.tscn`: phím để nghe từng âm; có một nguồn ở "tầng trên" để nghe hiệu ứng qua sàn; có phím giả lập `watcher_active`.
8. **Test:** đủ file, đúng bus, API không lỗi khi thiếu stream, nguồn khác tầng bị lọc thấp, im lặng khi bị theo dõi rồi trả lại.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] `CREDITS.md` đủ nguồn và công cụ
- [ ] Handoff: danh sách âm và LUFS, API, cách nghe thử

## Handoff (agent điền)
