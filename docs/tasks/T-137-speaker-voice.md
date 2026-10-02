# T-137 — Giọng đọc của loa phát thanh (TTS offline)
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-137-speaker-voice`
- Phụ thuộc: T-130 (loa, done), T-136 (done). Làm sau T-133 hoặc song song nếu tách nhánh. Chủ dự án chọn **giọng máy TTS chạy offline** (2026-10-03), đúng với D-006.

## Mục tiêu
Loa hiện chỉ có tiếng rè và phụ đề. Kế hoạch P3 cần "điểm danh có giọng đọc". Task này tạo giọng đọc cho mọi câu của loa, **tiếng Việt và tiếng Anh**, nghe như loa phát thanh cũ của ký túc xá.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`

## Yêu cầu
1. **Chọn công cụ TTS:**
   - chạy offline trên máy, cài vào `D:\Tools\` (không cài vào ổ C:), miễn phí;
   - **giấy phép của cả công cụ lẫn mô hình giọng phải cho phép dùng thương mại**. Ví dụ Piper (engine MIT): phải kiểm tra riêng giấy phép từng giọng tiếng Việt và tiếng Anh, vì có giọng chỉ cho nghiên cứu.
   Ghi rõ tên công cụ, phiên bản, giọng, URL và giấy phép vào `CREDITS.md`, đánh dấu là **nội dung tạo bằng AI** (itch.io/Steam yêu cầu khai báo). Không tìm được giọng tiếng Việt có giấy phép phù hợp thì ghi `Blocked: <lý do>` vào Handoff kèm các lựa chọn đã xét, và dừng. Không dùng giọng không rõ giấy phép.
2. **Câu cần đọc:** mỗi key một file `game/audio/voice/<locale>/<KEY>.ogg`, `<locale>` là `vi` hoặc `en`. Nội dung lấy từ `game/localization/strings.csv`, **bỏ tiền tố "Loa:", "Speaker:", "Loa (chậm hơn):" và phần trong ngoặc**:
   - nội quy: `RULE_HEADER_5`, `RULE_1`, `RULE_2`, `RULE_3_GARBLED`, `RULE_4`, `RULE_5`;
   - `SPK_SIGN_LOG`, `SPK_ROLLCALL_INTRO`, `SPK_CHECK_TAPS`;
   - tên: `SPK_NAME_PHUC`, `SPK_NAME_VIET`, `SPK_NAME_TRUNG`, `SPK_NAME_DAT`, `SPK_NAME_LAM`. Tên riêng giữ cách đọc tiếng Việt ở cả bản `en`;
   - `SPK_NAME_TRUNG_AGAIN`: đọc **chậm và kéo dài** "Trần… Trung.";
   - kết: `SPK_AND_ONE_MORE`, `SPK_AND_TRUNG`.
   **`RULE_3_GARBLED`:** đọc đầy đủ điều 3 (`RULE_3`), rồi tiếng rè **che kín** phần hành động "không quay lại, đi tiếp tới chỗ có đèn", sao cho không nghe ra chữ. Đây là điểm mấu chốt của câu đố (điều 3 thật bị loa nuốt mất).
3. **Xử lý cho giống loa phát thanh:** lọc dải khoảng 300–3400 Hz, méo nhẹ, vang hành lang ngắn, nhiễu nền rất nhỏ; nhịp đọc chậm, đều, hơi vô cảm. Độ to khoảng −26 LUFS trên bus `Voice`. Script xử lý để trong `audio_source/` để làm lại được.
4. **`speaker.gd`:** khi có file giọng cho locale hiện tại (đọc `[ui] locale` theo `docs/SETTINGS.md`) thì phát giọng ở từng dòng:
   - thời lượng dòng = `max(độ dài giọng + 0,4 s, line_seconds)`;
   - **giữ nguyên hợp đồng hiện tại:** mỗi dòng phát **đúng một** `EventBus.subtitle_requested(text_key, duration)` lúc dòng bắt đầu, và `announcement_finished` sau dòng cuối. Phần điểm danh của `StoryDirector` dựa vào thời điểm phụ đề để biết người chơi trả lời tên nào;
   - dòng có `garbled = true` vẫn chồng tiếng rè như hiện tại;
   - không có file giọng thì giữ cách cũ (tiếng rè + phụ đề);
   - giọng phát ở vị trí loa (3D), có vang như tiếng rè hiện có.
5. **Test `game/tests/audio/`:** đủ file cho cả hai locale; `speaker.gd` chọn đúng file theo locale; dòng có giọng kéo dài đúng; mỗi dòng đúng một phụ đề; thiếu file thì quay về cách cũ.
6. **Nghe thử:** thêm phím vào scene thử âm thanh để phát lần lượt các thông báo của loa ở cả hai ngôn ngữ.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Giấy phép công cụ và giọng ghi trong `CREDITS.md`, có khai báo AI
- [ ] LUFS ghi vào Handoff
- [ ] Handoff: công cụ đã chọn, lệnh tạo lại giọng, phần chưa nghe bằng tai

## Handoff (agent điền)
