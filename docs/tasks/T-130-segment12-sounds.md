# T-130 — Âm thanh cho đoạn 1–2
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-130-segment12-sounds`
- Phụ thuộc: T-126 (done). Đọc `docs/design/RULES.md` mục 5 (đoạn 1–2). Làm song song với T-129 (lane A) và T-111 (lane D).

## Mục tiêu
Các âm mà đoạn 1–2 cần: tiếng gõ cửa, loa phát thanh (chuông báo, tiếng rè, tiếng bật/tắt loa), điện thoại rung, công tắc đèn, chốt cửa. Giọng đọc của loa làm sau (TTS, D-006); task này chỉ làm phần "loa cũ, rè" bao quanh giọng đọc.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`

## Yêu cầu
1. **Âm mới** (tự tổng hợp như các âm trước, CC0, khai báo AI):
   | File | Loại | Mô tả |
   |---|---|---|
   | `sfx/knock_01…03` | one-shot | **Ba tiếng gõ** lên cửa gỗ cũ bằng đốt ngón tay. Bản 01 bình thường, 02 chậm hơn, 03 chậm và nặng nhất (dùng cho ba lượt gõ ngày càng chậm) |
   | `sfx/speaker_chime` | one-shot | Chuông báo "tinh-tong" của loa phát thanh cũ, có méo và rè |
   | `sfx/speaker_on`, `sfx/speaker_off` | one-shot | Tiếng "bụp" bật và tắt loa, kèm rè ngắn |
   | `ambience/speaker_static` | loop | Tiếng rè nền khi loa đang mở, để chạy dưới giọng đọc |
   | `sfx/speaker_static_burst` | one-shot | Tiếng rè to, khoảng 1,5 giây, che chỗ điều 3 bị rè |
   | `sfx/phone_vibrate` | loop ngắn | Điện thoại rung trên giường tầng sắt (rè rè có tiếng lạch cạch kim loại) |
   | `sfx/light_switch` | one-shot | Công tắc nhựa cũ "tách" |
   | `sfx/door_latch` | one-shot | Chốt cửa sắt kéo "cạch" |
2. **Độ to:** chủ dự án thích âm nhỏ (D-015…D-019). Đề xuất:
   - gõ cửa khoảng −30 LUFS: nghe rõ nhưng không giật;
   - loa (chuông, rè) khoảng −32 LUFS;
   - điện thoại, công tắc, chốt khoảng −36 LUFS.
   
   Các âm đã duyệt **phải giữ nguyên hash** (đối chiếu như T-126).
3. **Script `game/scripts/audio/speaker.gd`** (`class_name Speaker`, kế thừa `AudioStreamPlayer3D`, đặt ở loa bàn trực):
   - `play_announcement(lines: Array, line_seconds: float = 4.0)`: phát `speaker_on`, `speaker_chime`, bật `speaker_static` ở nền; với mỗi phần tử gửi `EventBus.subtitle_requested(text_key, line_seconds)`. Phần tử là `{"text_key": ..., "garbled": bool}`; nếu `garbled` thì phát thêm `speaker_static_burst`. Cuối cùng phát `speaker_off`, tắt nền rè, emit signal `announcement_finished`.
   - Chưa có giọng TTS: mỗi dòng giữ `line_seconds` giây để người chơi kịp đọc phụ đề.
   - Bus: `Voice` cho phần loa.
4. **Test:** mọi file load được, đúng cờ loop; `Speaker.play_announcement` gửi đúng số phụ đề theo thứ tự, phát burst đúng dòng `garbled`, cuối cùng emit `announcement_finished` (dùng `line_seconds` nhỏ để test nhanh).
5. **Nghe thử:** thêm phím vào `audio_test.tscn` hoặc tạo `segment12_test.tscn` để nghe từng âm và một lượt loa đọc thử 3 dòng.

## Checklist hoàn thành
- [ ] Chạy lại `process.py --regenerate-raw` ra file giống nhau; tổng audio dưới 15 MB
- [ ] Âm đã duyệt không đổi hash
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Không chạm file ngoài phạm vi; `CREDITS.md` cập nhật
- [ ] Mục Handoff đã điền, ghi rõ phần nào **chưa nghe bằng tai**

## Handoff (agent điền)
