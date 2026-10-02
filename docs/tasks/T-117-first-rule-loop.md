# T-117 — Luật đầu tiên chạy trọn vòng (đoạn 1–2)
- Lane: core (Claude) | Trạng thái: todo | Agent: Claude (integrator)
- Phụ thuộc: T-110, T-112, T-113 (done); **T-129 (A), T-111 (D), T-130 (E)** cung cấp đồ vật, màn xem giấy, sổ tay và âm thanh.
- Đây là bản cho **cổng kiểm tra P1 (T-120)**: chủ dự án chơi thử cơ chế chính lần đầu.

## Mục tiêu
Chơi được đoạn 1–2 trong `docs/design/RULES.md`:
- 23:50: về phòng, khóa cửa, đọc giấy nội quy;
- 23:59: điện thoại báo 0 giờ, tắt đèn;
- 0:00: loa đọc 5 điều (điều 3 bị rè), **phán định điều 1**;
- 0:10: ba lượt gõ cửa, **phán định điều 2**;
- hậu quả nhìn thấy được, rồi màn "Hết bản thử".

## Phạm vi (core)
`game/scenes/main/`, `game/scripts/core/`, `game/data/`, `game/tests/core/`, `docs/`

## Việc của integrator
1. **Luồng game (`StoryDirector`, trong `game/scripts/core/` hoặc `main.gd`):**
   - Nạp `res://data/rules/demo.tres`. Checkpoint `seg1_start`, `seg2_start`.
   - **Đoạn 1 (23:50):** phụ đề hướng dẫn ngắn: vào phòng, chốt cửa, đọc giấy sau cửa, Tab mở sổ tay. Giờ dừng cho tới khi người chơi đã vào phòng và chốt cửa (hoặc sau tối đa khoảng 90 giây). Sau đó giờ lên 23:59, điện thoại rung.
   - **Đoạn 2 (0:00):** sau khi xem điện thoại (hoặc khoảng 20 giây), lên 0:00, loa đọc 5 điều qua `Speaker.play_announcement` (điều 3 dùng `RULE_3_GARBLED`, có rè). Mỗi dòng ghi vào sổ tay với nguồn `speaker`.
   - **Phán định điều 1** khi loa đọc xong: đèn chính tắt thì `turn_off_main_light`, còn bật thì `left_on`.
   - **0:10, phán định điều 2:** ba lượt gõ cửa (T-130), mỗi lượt chậm hơn, không ai gọi số phòng. Người chơi mở cửa trong lúc gõ hoặc trước khi hết khoảng 20 giây thì là `open_door`; im lặng đủ lâu thì là `stay_silent`. Cửa đang chốt thì phải mở chốt rồi mới mở được, vẫn tính `open_door`.
2. **Hậu quả** (nghe `EventBus.consequence_triggered`):
   - `corridor_light_flicker`: đèn hành lang trước phòng chập chờn (`LightHum.flicker` cộng nhấp nháy ánh sáng).
   - `extra_slippers`: trước cửa 407 xuất hiện **đôi dép thứ năm** (mô hình tạm ở anchor `Slippers407`).
3. **Đặt đồ vật** của lane A vào anchor của tầng 4; gắn màn xem giấy và sổ tay của lane D vào `main.tscn`; gắn `Speaker` (T-130) ở anchor `Speaker`.
4. **Hết bản thử:** sau khi phán định điều 2 và có hậu quả (nếu có), phụ đề kết đoạn, rồi màn "Hết bản thử. Cảm ơn bạn đã chơi." (key dịch), menu tạm dừng vẫn dùng được để thoát.
5. **Test core:** chạy luồng nhanh (rút ngắn thời gian chờ) cho cả hai nhánh: (a) tắt đèn, im lặng → không lệch; (b) để đèn, mở cửa → lệch 3, có đôi dép thứ năm. Sổ tay có 5 dòng từ loa, điều 3 là chữ rè.

## Handoff
