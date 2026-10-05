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
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ảnh preview vi/en
- [ ] Handoff: scene, API, đường dẫn node

## Handoff (agent điền)
