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
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Đo LUFS từng file, ghi vào Handoff
- [ ] `CREDITS.md` cập nhật
- [ ] Handoff: cách gắn `MusicDirector` vào main, cách nghe thử, phần chưa thử bằng tai

## Handoff (agent điền)
