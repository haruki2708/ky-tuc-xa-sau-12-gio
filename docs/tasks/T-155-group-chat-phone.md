# T-155 — Điện thoại và cuộc gọi nhóm, chọn chương, cảnh báo nội dung
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-155-group-chat-phone`
- Phụ thuộc: T-150 phần 1 (đã có trên `main`). Đọc `docs/design/STORY.md` v2 §0, §2, §5.
- **Hạn: hết ngày 2026-10-05.** Xong thì làm T-156 ngay.

## Mục tiêu
Trong chương 1, người chơi bị giam trong phòng. Gần như mọi thông tin đến từ **cuộc gọi nhóm** trên điện thoại: Minh Nhật lập nhóm, các thành viên nói chuyện, lần lượt chết, và người chơi trả lời bằng lựa chọn. Đây là giao diện quan trọng nhất của chương.

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/assets/fonts/`, `game/tests/ui/`, thêm key vào `game/localization/strings.csv`.

## Hợp đồng có sẵn (T-150, không sửa)
- Signal:
  - `phone_raised(raised)`, `phone_battery_changed(percent)`, `flashlight_toggled(on)`, `time_changed(minutes)`;
  - `phone_call_incoming(call_id)`, `phone_call_answered(call_id)` (lane D phát khi người chơi bắt máy);
  - `phone_message_received(message_id)`;
  - `chat_member_changed(member_id, state)` (`joined`, `dead`, `left`);
  - `chat_choice_requested(choice_id, option_keys)`, `chat_choice_made(choice_id, index)` (lane D phát; −1 khi hết giờ);
  - `player_hidden`, `breath_held`.
- `MessageData`: `sender`, `sender_name_key`, `text_key`, `minutes`, `outgoing`, `spoken`, `clock_text()`.
- `Progress.unlocked_chapter()`, `App.start_chapter(n)`, key `CH_1_TITLE`…`CH_4_TITLE` (tên chương sẽ đổi theo v2; lane D chỉ dùng key).

## Yêu cầu
1. **Màn hình điện thoại** (`ui/phone/phone_screen.tscn`):
   - Hiện khi `phone_raised(true)`: khung điện thoại góc dưới phải, khoảng 35% chiều cao, chữ to rõ, không bị filter PS1.
   - **Thanh trên:** giờ, % pin, sóng điện thoại (luôn "Không có sóng"), biểu tượng đèn pin.
   - **Không chặn di chuyển**, không nhả chuột. Ẩn khi mở sổ quy tắc, xem giấy, menu tạm dừng hoặc panel câu đố.
2. **Cuộc gọi đến:**
   - Khi `phone_call_incoming(id)`: chuông "tít tít" (lane E làm âm, lane D phát signal hoặc gọi API âm có sẵn), banner lớn "Người lạ muốn bắt đầu cuộc gọi với bạn" kể cả khi đang hạ điện thoại.
   - Phím `interact` khi đang giơ điện thoại thì bắt máy, phát `phone_call_answered(id)`.
3. **Màn cuộc gọi nhóm:**
   - **Danh sách thành viên:** tên, chấm trạng thái. Người `dead` thì xám, gạch tên, ảnh đại diện tối.
   - **Bản chép lời trực tiếp:** mỗi `phone_message_received` có `spoken = true` hiện thành một dòng "Tên: câu nói", dòng mới nhất ở dưới, cuộn được bằng lăn chuột.
   - **Phụ đề:** câu đang nói cũng hiện ở dưới màn hình như phụ đề thường, kể cả khi hạ điện thoại (dùng `subtitle_requested` hoặc phụ đề riêng; chọn cách không trùng với HUD hiện có).
   - **Lựa chọn trả lời:** khi `chat_choice_requested`, hiện các lựa chọn (2–4) to, rõ, chọn bằng phím số 1–4 hoặc chuột, có thanh thời gian (mặc định 10 giây, export).
     - Hết giờ thì `chat_choice_made(id, -1)`.
     - Lựa chọn hiện được cả khi đang hạ điện thoại (tự giơ lên).
   - Điện thoại hết pin thì màn đen, mất cuộc gọi.
4. **Lịch sử** khôi phục được sau checkpoint: `snapshot() -> Dictionary` và `restore(data)`; integrator gọi khi lưu và khi tải.
5. **Lớp phủ khi nằm hoặc nấp:** khi `player_hidden(true, …)`, viền tối và gợi ý `PROMPT_HOLD_BREATH` (đã có). Khi `breath_held(true)`, viền co lại.
6. **Màn hình chính:** thêm "Chọn chương": 4 chương, chương chưa mở thì khóa (theo `Progress.unlocked_chapter()`). Chọn thì `App.start_chapter(n)`; đang có bản lưu thì hỏi xác nhận (`confirm_panel`).
7. **Cảnh báo nội dung** (màn của T-139): sửa câu chữ cho đúng nội dung mới. Game có **máu, cảnh chết bạo lực, xác người**, và nhắc tới **thảm họa động đất**. Gợi ý bật "Giảm hù dọa" để giảm máu me. Viết lại key hiện có hoặc thêm key mới, đủ `vi` và `en`.
8. **Test:**
   - điện thoại hiện và ẩn;
   - cuộc gọi đến, bắt máy;
   - bản chép lời; thành viên chết thì xám;
   - lựa chọn và hết giờ phát đúng signal;
   - snapshot/restore;
   - chọn chương khóa đúng (dùng file progress tạm).

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ảnh chụp: cuộc gọi đến, cuộc gọi nhóm có lựa chọn, chọn chương, cảnh báo (vi và en)
- [ ] Handoff: API, cách gắn vào main, phần chưa thử

## Handoff (agent điền)
