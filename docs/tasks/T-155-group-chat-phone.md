# T-155 — Điện thoại và cuộc gọi nhóm, chọn chương, cảnh báo nội dung
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: done | Agent:
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
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Ảnh chụp: cuộc gọi đến, cuộc gọi nhóm có lựa chọn, chọn chương, cảnh báo (vi và en)
- [x] Handoff: API, cách gắn vào main, phần chưa thử

## Handoff (agent điền)

### Bàn giao Lane D — 2026-10-04

- Base `37bdfa7` (`origin/main` lúc bắt đầu), nhánh `lane-d/T-155-group-chat-phone`. Commit triển khai `e557350` đã push trước khi điền Handoff này. Chỉ sửa vùng được phép, thêm 30 key VI/EN; không sửa key cũ, core/player/audio/main hay `docs/STATUS.md`.
- Thêm `ui/phone/phone_screen.tscn`: thanh giờ/pin/không sóng/đèn pin, banner cuộc gọi đến khi hạ máy, bắt máy qua interact, danh sách thành viên và trạng thái chết, bản chép lời, 2–4 lựa chọn có thời gian, màn đen khi hết pin, viền tối/gợi ý nín thở. Khung máy cao 35% viewport, chừa vùng phụ đề phía dưới.
- UI không pause, không nhả chuột, không lấy input di chuyển; ẩn trên giấy/sổ/pause/câu đố. Dùng phụ đề HUD hiện có bằng `subtitle_requested`, phát đúng một lần mỗi tin `spoken`, kể cả khi hạ máy.
- Chọn chương dùng `Progress.unlocked_chapter()` và `App.start_chapter(n)`, khóa chương chưa mở, xác nhận bằng panel chung khi có save. Cảnh báo dùng key mới, có máu/chết bạo lực/xác người/động đất và gợi ý Giảm hù dọa; giữ quy tắc chỉ hiện lần đầu của T-139.

### API và cách gắn

- Instance **một** `res://ui/phone/phone_screen.tscn` dưới scene chơi, trên viewport chính. CanvasLayer 12, trên PS1 filter/HUD, dưới lớp đọc giấy/pause. Không đặt trong viewport thế giới độ phân giải thấp. Chi tiết tại [README điện thoại](../../game/ui/phone/README.md).
- `snapshot() -> Dictionary`: bản sao sâu, JSON-safe, `version = 1`. `restore(data)` gọi sau khi node vào tree; không phát lại cuộc gọi/phụ đề/lựa chọn. Lưu `history`, `members`, raised/battery/minutes/flashlight, incoming/call, choice/options/remaining/selected/disconnected_choice. Integrator sở hữu ghi/đọc checkpoint.
- `choice_seconds` export mặc định 10, `subtitle_seconds` mặc định 4. Core gửi một lựa chọn tại một thời điểm; UI không ghi đè lựa chọn đang chờ. Timer ngừng khi có modal. Hết pin thì ngắt cuộc gọi; lựa chọn bị ngắt vẫn trả -1 khi hết thời hạn còn lại, không hồi sinh khi sạc. Đây là cách xử lý kỹ thuật để không bỏ treo yêu cầu từ core.
- E/interact bắt máy khi đang giơ điện thoại. 1–4 chọn câu trả lời. Khi chuột khóa: lăn để chọn, nhấp trái xác nhận; khi chuột hiện: nhấp trực tiếp nút. Không có lựa chọn: lăn cuộn hội thoại; Shift+lăn cuộn thành viên. UI xóa trạng thái nhấn `interact` sau khi bắt máy/chọn để Player đang poll trong physics không tương tác thế giới cùng lúc.
- Auto-raise phát `phone_raised(true)`; lane A phải đồng bộ trạng thái giơ máy vật lý. UI nghe battery/light/time từ EventBus; cần phát trạng thái ban đầu và phối hợp thứ tự restore với phone item.
- Message thật đọc bằng `MessageData.load_by_id()`. Tên thành viên lấy từ `sender_name_key`; thành viên chưa có MessageData tạm hiển thị ID. Core có thể seed `members` qua restore bằng name key đã duyệt trước khi bắt đầu cuộc gọi. UI không tự đặt tên nhân vật.

### Kiểm tra và ảnh

```text
pwsh tools/test.ps1
RESULT: 270 passed, 0 failed

pwsh tools/check.ps1
RESULT: check 0 error(s)

Godot windowed, res://tests/run_tests.tscn -- --filter=test_phone
RESULT: 10 passed, 0 failed
```

- Lần full đầu: `RESULT: 269 passed, 1 failed`, tại `test_core.gd::test_reading_the_door_paper_opens_and_closes_cleanly` (đóng giấy/tiếp tục game/mở sổ). Chạy riêng core: `RESULT: 17 passed, 0 failed`; chạy lại toàn bộ: 270/270 như trên, không sửa core hay luồng giấy để làm test qua. Chưa xác định nguyên nhân lỗi phụ thuộc thời điểm này. Log cục bộ: `build/T-155/test.log`, `core-recheck.log`, `test-final.log`, `check.log` (ignored).
- Test mới bao phủ hiện/ẩn/modal, bắt máy một lần, phụ đề khi hạ máy, dịch live, thành viên chết, phím số/chuột/timeout, hết pin, JSON snapshot/restore, nín thở, khóa chương và xác nhận save. Test có cửa sổ kiểm tra cả chuột khóa thực; DisplayServer headless không hỗ trợ capture chuột.
- Đã xem đủ tám ảnh Godot 1920×1080, Git LFS, kèm `.import`: [gọi đến VI](../../game/ui/phone/previews/incoming_vi.png), [EN](../../game/ui/phone/previews/incoming_en.png); [nhóm + lựa chọn VI](../../game/ui/phone/previews/group_vi.png), [EN](../../game/ui/phone/previews/group_en.png); [chọn chương VI](../../game/ui/title/previews/chapters_vi.png), [EN](../../game/ui/title/previews/chapters_en.png); [cảnh báo VI](../../game/ui/title/previews/warning_ch1_vi.png), [EN](../../game/ui/title/previews/warning_ch1_en.png).
- F6 `ui/phone/phone_test.tscn` xem nhóm; tham số `-- --phone-capture=incoming|group|incoming_en|group_en|hidden` chọn fixture. `ui/title/title_test.tscn` nhận `-- --title-capture=chapters|chapters_en|warning|warning_en`. Tên Người thử A/B và câu thử là fixture kỹ thuật, không phải thoại/cốt truyện.

### Yêu cầu thay đổi ngoài phạm vi

1. **Integrator/T-150:** gắn PhoneScreen vào scene chương, lưu/khôi phục snapshot cùng checkpoint, cung cấp MessageData/name key/option key chính thức và điều phối lựa chọn nối tiếp. `App.start_chapter()` hiện vẫn có fallback chương 1 cho chương chưa có nội dung; lane D chỉ gọi API được giao.
2. **Lane A/T-151 + integrator:** đồng bộ auto-raise, battery/light/call khi bắt đầu và tải checkpoint; cập nhật trạng thái cuộc gọi của phone item khi answered/hết pin để hao pin đúng. Không sửa các file player trong nhánh này.
3. **Lane E/T-158:** nghe `phone_call_incoming` có sẵn để phát chuông, dừng khi answered/hết pin; phát thoại từ message. Không phát thêm cùng một `subtitle_requested`, vì PhoneScreen đã phát. UI không phát lại incoming để tránh vòng lặp signal.
4. **Integrator/QA:** theo dõi test đóng giấy chập chờn nêu trên nếu tái diễn; chưa có bằng chứng đủ để kết luận nguyên nhân hay sửa ngoài phạm vi.

### Phần chưa thử / chặn

- Chưa chơi xuyên chương với dữ liệu/thoại/chuông thật và checkpoint tích hợp; base chưa có dữ liệu `game/data/messages/` hay đầu nối T-151/T-158 hoàn chỉnh. Snapshot đã qua JSON round-trip trong test, chưa qua luồng save/load chương thực tế. Chưa xác minh giảm máu me bằng gameplay (chỉ cập nhật cảnh báo theo card).
- Không bị chặn phần triển khai Lane D; ba mục checklist đều đạt. Những đầu nối liên lane trên cần integrator/lane sở hữu thực hiện trước khi nghiệm thu gameplay. Không tự suy đoán luật chơi hay lời thoại.

### Review (integrator, 2026-10-04)
- **Đạt, đã merge.** Đúng phạm vi; 10 test mới; ảnh vi/en rõ ràng. Handoff trung thực, có báo test demo chập chờn.
- Xung đột `strings.csv` (hai bên cùng thêm dòng cuối): giữ cả hai, không trùng key.
- Đã ghép vào chương 1:
  - `PhoneScreen` có trong `chapter1.tscn`;
  - luồng chương không tự hiện phụ đề câu thoại nữa (màn hình điện thoại đã hiện);
  - lịch sử cuộc gọi (`snapshot`/`restore`), pin và trạng thái đang gọi lưu trong cờ `GameState` cùng checkpoint.
- **Integrator sửa một lỗi tích hợp** trong `phone_screen.gd`: `Player._exit_tree` (T-151) phát `player_hidden(false)` khi scene đang bị giải phóng, làm `_refresh_visibility` gọi `get_tree()` khi node đã rời tree. Đã thêm kiểm tra `is_inside_tree()`. Lỗi gốc nằm ở việc Player phát signal trong `_exit_tree`; ghi cho lane A xem lại ở task sau.
