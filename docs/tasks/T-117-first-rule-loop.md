# T-117 — Luật đầu tiên chạy trọn vòng (đoạn 1–2)
- Lane: core (Claude) | Trạng thái: doing | Agent: Claude (integrator)
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

### Phiên 2026-10-02 (phần 1) — Claude
- `game/scripts/core/story_director.gd`, gắn vào `main.tscn` (node `StoryDirector`): chạy đủ đoạn 1–2 theo `RULES.md`. Thời gian chờ nhân `time_scale`; nhường máy khi game dừng (timer không chạy lúc tạm dừng).
- **Chạy được ngay cả khi chưa có đồ của A, D, E:**
  - chưa có điện thoại thì hiện phụ đề `SUB_PHONE_MIDNIGHT`;
  - chưa có `Speaker` thì đọc nội quy bằng phụ đề, mỗi dòng 4 giây;
  - chưa có âm gõ cửa thì chỉ hiện phụ đề `SUB_KNOCK`;
  - chưa có chốt cửa (T-129) thì đoạn 1 chờ tối đa 90 giây rồi đi tiếp.
- Sổ tay nhận 5 dòng từ nguồn `speaker`; điều 3 ghi chữ rè `RULE_3_GARBLED`.
- Phán định điều 1 theo trạng thái thật của đèn `Room407MainLight`; điều 2 theo việc cửa 407 có bị mở trong lúc gõ hoặc 20 giây sau đó không.
- Hậu quả: `corridor_light_flicker` (đèn trước phòng 407 chập chờn cùng tiếng ù), `extra_slippers` (đôi dép thứ năm, hộp tạm đỏ ở anchor `Slippers407`).
- Checkpoint `seg1_start`, `seg2_start`. Phụ đề mới: `SUB_SEG1_GO_ROOM`, `SUB_SEG1_READ_PAPER`, `SUB_PHONE_MIDNIGHT`, `SUB_KNOCK`, `SUB_KNOCK_STOPPED`, `SUB_SLICE_END`.
- Test `tests/core/test_story_director.gd`: hai nhánh (đúng: lệch 0; sai: lệch 3, có dép thứ năm, đèn chập chờn) và checkpoint. `RESULT: 137 passed, 0 failed`.

**Còn lại (phần 2, khi A, D, E xong):** đặt công tắc, chốt cửa, giấy sau cửa, điện thoại vào anchor; gắn màn xem giấy và sổ tay; gắn `Speaker` ở bàn trực; nối `phone_path`, `speaker_path`; thử chơi trọn vòng và chụp ảnh.

**Lưu ý:** `SUB_PHONE_MIDNIGHT` đã được thêm ở đây. Lane A (T-129) không cần thêm key này nữa; nếu thêm trùng thì integrator bỏ bản trùng khi merge.
