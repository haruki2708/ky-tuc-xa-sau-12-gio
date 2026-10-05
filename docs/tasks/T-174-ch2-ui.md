# T-174 — Chương 2: bảng nối từ, màn hình vòi sen, lớp hơi nước và bỏng
- Lane: D (UI) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-174-ch2-ui`
- Phụ thuộc: T-155, T-163. **Đọc kỹ `docs/design/CH2_DESIGN.md`** (D-046).
- **Hạn: hết ngày 2026-10-07.**

## Mục tiêu
Giao diện cho hai trò chơi của chương 2 và hiệu ứng màn hình cho hai cảnh chết mới.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/tests/ui/`, thêm key vào `strings.csv`

## Hợp đồng có sẵn (core, không sửa)
`EventBus.chain_turn_started`, `chain_word_spoken`, `chain_choice_requested`, `chain_choice_made`, `chain_choice_blocked`, `shower_choice_requested`, `shower_choice_made`, `shower_slot_finished`, `shower_steam_changed`, `player_death_started` (`corpse_lunge`, `scald`). Đọc chú thích trong `event_bus.gd`.

**Chuỗi chữ core đã có (dùng lại, không tạo trùng):** `UI_CH2_SHOWER_RULE`, `UI_CH2_SHOWER_YES`, `UI_CH2_SHOWER_NO`, `UI_CH2_SHOWER_TEMP` (`%d`), `UI_CH2_SHOWER_PROGRESS` (`%d`), `UI_CH2_CHAIN_DEAF`. Từ nối là key `WORD_CH2_*` (tiếng Anh hiện "từ (nghĩa)"). Thử với dữ liệu thật: `res://data/ch2/word_bank.json`, `res://data/ch2/shower.json`; scene `res://scenes/main/chapter2.tscn` chạy được luồng (T-170).

## Yêu cầu
1. **Bảng nối từ** (`ui/chain/chain_panel.tscn`):
   - hiện **từ vừa nói** (to), người nói, và **3 từ gần nhất** (để người chơi tự kiểm tra lặp);
   - lượt của Trung: **4 phương án** và đồng hồ **15 giây** (vạch đỏ chạy, tích tắc 5 giây cuối); chọn bằng phím **1–4** hoặc chuột; phát `chain_choice_made(index)`, hết giờ phát `-1`;
   - `chain_choice_blocked(true)`: phương án mờ, dòng "Họ không nghe thấy bạn", không nhận phím;
   - **không pause game, không bắt chuột** (người chơi vừa đi vừa trả lời);
   - không có gợi ý đúng sai (Insane).
2. **Màn hình vòi sen** (`ui/shower/shower_screen.tscn`, SubViewport gắn lên anchor `ShowerScreen` của lane B, kiểu màn hình LCD cũ):
   - dòng luật: "Chọn có xả nước trong 2 phút tới hay không. Đã chọn thì bắt buộc làm theo. Nếu không, chết.";
   - đếm ngược khi `shower_choice_requested`; chữ **CÓ / KHÔNG** khớp hai nút của lane A;
   - sau mỗi lượt: "Nhiệt độ: NN °C"; **toàn bộ lịch sử nhiệt độ** từ lượt đầu (D-046), thành lưới nhỏ;
   - thanh "Đã tắm X/25 phút";
   - **hơi nước phủ mờ** theo `shower_steam_changed`, API `wipe()` xóa mờ (lane A gọi khi lau).
3. **Lớp màn hình** (cùng lớp với `blood_overlay` T-163):
   - hơi nước trên camera khi đứng trong buồng tắm có nước nóng (theo steam level);
   - **`scald`:** trắng xóa, viền đỏ phồng, rung;
   - **`corpse_lunge`:** máu như `manager_kill`;
   - tôn trọng "Giảm hù dọa".
4. **Thông báo trong điện thoại:** tin nhắn vòng lặp từ của Minh Nhật hiện như tin nhắn chat có sẵn (dùng `MessageData`), giữ trong lịch sử để đọc lại.
5. **Test và preview:** bảng nối từ (lượt xác, lượt Trung, bị chặn, hết giờ), màn hình vòi sen (đếm ngược, lịch sử dài 30 lượt, mờ và lau), hai lớp chết; ảnh vi/en.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Ảnh preview vi/en
- [x] Handoff: scene, API, đường dẫn node

## Handoff (agent điền)

### Đã làm (2026-10-05, Lane D)
- Base `c68888b` (`origin/main`). Commit triển khai `6162bc7` đã push lên `lane-d/T-174-ch2-ui` trước khi cập nhật Handoff. Chỉ sửa UI, script UI, test UI và thêm 33 key vi/en; không sửa core, STATUS, dữ liệu chương hay scene của lane khác.
- Bảng nối từ: từ mới nhất cỡ lớn, người vừa nói, người đang có lượt, ba từ gần nhất theo thứ tự; âm ú ớ (`word_key` rỗng) không chiếm chỗ trong lịch sử. Chỉ hiển thị key do core cung cấp, không xét đúng/sai, không tô màu đáp án đúng.
- Lượt Trung có 4 lựa chọn, đồng hồ theo tham số `seconds` (15 giây theo đặc tả), thanh đỏ, tích tắc mỗi giây trong 5 giây cuối. Chọn/hết giờ chỉ phát một `chain_choice_made(index/-1)`. Bị chặn thì làm mờ lựa chọn, hiện đúng dòng không nghe thấy, không nhận đáp án nhưng thời gian vẫn chạy. Pause/menu đọc thì ẩn UI và dừng đồng hồ; UI không tự pause hoặc đổi mouse mode.
- Điều khiển: 1–4; khi chuột đang captured, lăn để chọn rồi bấm trái trả lời; khi con trỏ visible, bấm trực tiếp nút. Không dùng WASD/E. Chặn một sự kiện trả lời đồng thời điện thoại và bảng nối từ; thao tác trả lời không kích hoạt tương tác thế giới ở physics frame kế tiếp.
- LCD vòi sen: SubViewport 1024×768, quad 0,4×0,3 m, màu LCD đơn sắc, đủ dòng luật, CÓ/KHÔNG, đếm ngược, nhiệt độ đã nhận, lưới lịch sử 6 cột và X/25 phút. 30 lượt vừa màn hình; không tô màu an toàn/nguy hiểm, không sinh hay đoán nhiệt độ tiếp theo. UI chỉ nhận đáp án từ lane A; hết giờ **không** tự phát `shower_choice_made(false)`.
- Hơi nước trên LCD theo level 0–1; `wipe()` làm sạch kính, không xóa lịch sử hoặc hơi nước camera. Sự kiện hơi nước tiếp theo có thể làm kính mờ lại. Camera chỉ có hơi nước khi đang ở trong buồng tắm.
- Mở rộng BloodOverlay layer 29: `corpse_lunge` dùng hiệu ứng máu của manager_kill; `scald` trắng xóa, viền đỏ phồng và rung lớp phủ. Giảm hù dọa chỉ viền tối, không máu/trắng/rung. Reset khi checkpoint/chương bắt đầu.
- Tin vòng lặp dùng nguyên luồng `MessageData`/`phone_message_received` đã có; test xác nhận giữ trong lịch sử qua snapshot JSON và đổi locale, không phát phụ đề cho tin `spoken=false`. Không tự thêm MessageData sản xuất ngoài phạm vi; fixture dùng đúng vòng từ trong CH2_DESIGN.

### Scene, API và đường dẫn node

| Scene | API / hợp đồng | Node phục vụ ghép hoặc QA |
|---|---|---|
| `res://ui/chain/chain_panel.tscn` (CanvasLayer 13) | Nghe các `chain_*`; core phát `chain_turn_started` trước `chain_choice_requested`. `is_choosing() -> bool`; `close_panel()` dọn UI/lịch sử khi hết vòng 3 | `Root/Card/Content/Word`, `WordSpeaker`, `Speaker`, `History`, `Status`, `Timer`, `Options/Option1` … `Option4`; âm tại `Tick` |
| `res://ui/shower/shower_screen.tscn` (Node3D) | Instance dưới anchor `ShowerScreen`; `get_texture() -> Texture2D`, `wipe()`, `reset_display()`; nghe `shower_choice_requested/made`, `shower_slot_finished`, `shower_steam_changed` | `Display` là quad hướng local +Z, lệch +0,002 m tránh trùng mặt; `Viewport/Root/Card/Content/{Countdown,Choice,Temperature,HistoryScroll/History,ProgressText,Progress}`; `Viewport/Root/Condensation` |
| `res://ui/death/blood_overlay.tscn` (scene cũ, mở rộng) | `set_shower_inside(bool)`; hoặc đặt `shower_stall_path` trước `_ready` để tự nối signal `player_inside_changed` và đọc `player_inside` ban đầu | `CameraSteam` (tạo trong `_ready`), `Root` (máu/bỏng); vẫn dưới DeathScreen layer 30 |

### Kiểm thử / preview
- `pwsh tools/test.ps1`: **`RESULT: 422 passed, 0 failed`**, exit 0.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0.
- 8 test mới trong `game/tests/ui/test_ch2_ui.gd` đều PASS: lịch sử từ, locale, input/điện thoại/di chuyển, blocked/timeout/tick/pause, LCD/30 lượt/countdown, lau/vùng đứng, hai cảnh chết/accessibility và tin vòng lặp. Log ignored: `build/T-174/test.log`, `check.log`, `ch2.log`.
- 24 ảnh tại `game/ui/ch2_previews/` (LFS, kèm `.import` và CREDITS): lượt xác, lượt Trung, bị chặn, hết giờ; vòi sen đếm ngược, lịch sử 30 lượt, mờ/lau; corpse_lunge, scald; điện thoại vi/en; thêm scald_reduced và hơi nước camera. Đã kiểm tra bố cục render, bản tiếng Anh và chế độ giảm hù dọa.
- Scene thử: `res://ui/ch2_ui_preview.tscn`, đối số `-- --ch2-ui=chain_player_vi` (mode khác theo tên ảnh, xem CREDITS). Chụp frame 4, `--fixed-fps 30 --quit-after-frames=8`; APPDATA riêng trên D: vì preview đặt setting accessibility.
- Ảnh vòi sen phóng texture SubViewport để đọc rõ; **chưa kiểm tra khả năng đọc ở khoảng cách thực trong nhà vệ sinh đã ghép**, chưa chơi trọn chương 2, chưa chạy bot/export/package hay nghe duyệt chất lượng âm tích tắc. Fixture dùng ví dụ đã chốt để thử trình bày, không phải bộ phương án được core chấm đúng/sai.

### Yêu cầu thay đổi ngoài phạm vi
1. **Core T-170:** instance ChainPanel, ShowerScreen và BloodOverlay vào chương 2; gọi `ChainPanel.close_panel()` khi rời vòng 3. Cấp các key `WORD_CH2_*` và bốn lựa chọn/seconds qua signal; UI không tạo kho từ hoặc tự chấm đáp án.
2. **Core + A/B:** gắn ShowerScreen dưới anchor tương ứng của phòng; nối signal `wiped()` của vùng lau tới `ShowerScreen.wipe`; nối vùng buồng tắm tới `BloodOverlay.set_shower_inside` hoặc cấu hình `shower_stall_path`. Hơi nước chỉ báo độ đậm, UI không tự suy ra người chơi đứng trong buồng tắm.
3. **Core T-170:** tạo tin vòng lặp Minh Nhật trong `game/data/messages/` bằng `MessageData`, `spoken=false`, phát `phone_message_received(id)` đúng beat; snapshot điện thoại dùng cơ chế hiện có. Dữ liệu lời thoại/word và scene chương 2 chưa có trên base, không được tạo ngoài phạm vi lane D.
4. **Lane E T-175 / core:** gán clip tích tắc chuyên dụng vào `ChainPanel.tick_sound` nếu muốn UI phát 5 giây cuối. Hiện dùng `power_switch.ogg` của T-164 ở −12 dB/SFX. Nếu rig E đã phát countdown thì đặt `tick_enabled=false` để không phát đôi; chưa thay hay tạo waveform.
5. **Core export:** loại `ui/ch2_previews/*`, `ui/ch2_ui_preview*`, `scripts/ui/ch2_ui_preview.gd*`, `scripts/ui/ch2_phone_preview.gd*` khỏi bản phát hành. **Lane C T-173:** dùng các đường dẫn node/API trong bảng để ghép bot trên scene chương 2.

### Còn dở / chặn
- Không còn mục checklist chưa đạt trong phạm vi Lane D; không bị chặn triển khai. Các bước ghép và kiểm thử trên chương 2 đầy đủ thuộc T-170 cùng các lane liên quan như trên.
- Không thêm luật, cốt truyện hoặc gợi ý quy luật nhiệt độ. Không có câu hỏi thiết kế mới.
