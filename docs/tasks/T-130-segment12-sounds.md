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
- [x] Chạy lại `process.py --regenerate-raw` ra file giống nhau; tổng audio dưới 15 MB
- [x] Âm đã duyệt không đổi hash
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Không chạm file ngoài phạm vi; `CREDITS.md` cập nhật
- [x] Mục Handoff đã điền, ghi rõ phần nào **chưa nghe bằng tai**

## Handoff (agent điền)

### Phiên 2026-10-02 — Lane E / Codex

**Đã làm**
- Workspace `D:\GAME_WORK\lane-e`, nhánh `lane-e/T-130-segment12-sounds` tạo từ `origin/main` tại `6cf176c`. Đã đọc RULES mục 5. Commit **`02f991f`** (`T-130: add segment audio cues and subtitle-driven speaker playback`) đã push lên nhánh task; đủ **22 object LFS** mới (11 WAV + 11 OGG).
- Pipeline thêm 11 âm tự tổng hợp, seed cố định: knock_01…03, speaker_chime/on/off/static/static_burst, phone_vibrate, light_switch, door_latch. CC0, công cụ AI OpenAI Codex/Python/FFmpeg và từng file ghi trong `game/audio/CREDITS.md`.
- Mỗi knock có 3 cú gõ, cách nhau lần lượt 0.43/0.73/1.03 giây; bản 03 trầm và decay dài nhất. Loa static loop 6 giây; điện thoại loop 2.4 giây dù nằm trong SFX; burst dài 1.5 giây. `.import` đúng loop, có `.uid` cho script.
- `Speaker` kế thừa AudioStreamPlayer3D, bus Voice: on → chime → static nền + phụ đề từng dòng, burst chỉ ở dòng garbled → off → dừng mọi lớp âm và emit announcement_finished. Chưa có TTS. Nền static giảm 12 dB so với gain cha, burst giữ gain cha để rõ hơn nền. Có hủy/phát lại, snapshot đầu vào, pause theo scene tree và dọn playback khi unload/App.quit.
- `segment12_test.tscn`: fixture loa trên bàn với HUD có sẵn, F1–F11 nghe riêng 11 âm, Space chạy 3 dòng thử, 0 dừng, Esc thoát qua App. Dùng key dịch sẵn, gồm RULE_3_GARBLED; không sửa CSV, Player, main, luật hoặc EventBus.

**Số đo / kiểm tra đã chạy**
- Knock 01/02/03: **−29.94 / −29.95 / −29.97 LUFS**.
- Loa chime/on/off/static/burst: **−31.94 / −32.14 / −32.12 / −32.34 / −32.33 LUFS**.
- Điện thoại/công tắc/chốt: **−36.00 / −36.25 / −36.26 LUFS**. Đỉnh true peak lớn nhất của âm mới **−15.61 dBTP**, không clipping theo phép đo.
- Chênh mẫu biên loop static **0.0053427**, phone **0.0023034**, đều dưới ngưỡng pipeline 0.02. Không dùng số đo này để khẳng định chất lượng nghe bằng tai.
- Chạy lại `py -3 audio_source/process.py --regenerate-raw`: **`AUDIO RESULT: 28 assets validated; raw + OGG = 8656391 bytes`** (~8.66 MB, dưới 15 MB); file lớn nhất 2.016.044 bytes.
- Hai lượt tái tạo toàn bộ: **`REBUILD RESULT: 28 WAV + 28 OGG SHA256 identical; report identical`**.
- SHA256 thật của 34 WAV/OGG đã duyệt đối chiếu Git LFS pointer tại origin/main sau lượt cuối: **`PRESERVATION RESULT: 34 approved files match origin/main SHA256`**. Không đổi âm/gain đã được duyệt.
- `pwsh tools/test.ps1 -Filter audio`: **`RESULT: 23 passed, 0 failed`**, exit 0.
- `pwsh tools/test.ps1`: **`RESULT: 139 passed, 0 failed`**, exit 0. Chỉ có warning dự kiến của test dữ liệu sai GameState/Checkpoint; không có ERROR/script error.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0.
- Test kiểm toàn bộ 28 OGG load/decode và loop; Speaker phát on/chime/off đúng thứ tự, đủ 3 phụ đề theo thứ tự/thời lượng, burst đúng dòng, signal hoàn tất một lần và đã im tiếng; thêm restart/snapshot/pause/cancel/đầu vào sai/cancel từ subscriber và các phím fixture.
- Scene ngoài headless, Vulkan Forward+ + WASAPI 48 kHz/2 kênh, chạy lượt loa tự động và `--quit-after-frames=210`: **`SCENE RESULT: exit 0`** qua App.quit; không ERROR runtime/cleanup. Có warning Vulkan loader registry manifest của môi trường.
- `git diff --cached --check` sạch và toàn bộ file staged thuộc vùng Lane E; card này chỉ sửa checklist/Handoff. Không thêm plugin, không cài công cụ hoặc phần mềm vào ổ C; dùng Python/FFmpeg có sẵn.

**Còn dở / chưa nghe bằng tai**
- Checklist card đạt đủ. **Chưa nghe bằng tai cả 11 âm mới, độ thật của tiếng gõ/kim loại/loa và mix Speaker; chưa duyệt trên loa laptop hoặc tai nghe.** Cần chủ dự án nghe, đặc biệt khoảng gõ chậm dần, loop điện thoại/static và burst so với nền. Số đo và headless không thay cho duyệt cảm nhận.
- Chưa ghép trigger gameplay hoặc giọng TTS; đây là phần T-117/các task tiếp theo. Fixture 3 dòng chỉ để thử API, không tự quyết danh sách/thứ tự đầy đủ của đoạn 2. Phụ đề đã gửi do HUD giữ đến hết thời lượng; stop_emitting chỉ hủy âm và phụ đề chưa gửi.

**Cách kiểm tra / API**
1. Từ gốc repo chạy pipeline, `pwsh tools/test.ps1`, `pwsh tools/check.ps1` như trên.
2. Mở `res://audio/test/segment12_test.tscn`, F6. F1/F2/F3: 3 lượt gõ; F4: chime; F5/F6: on/off; F7: static loop; F8: burst; F9: phone loop; F10/F11: công tắc/chốt. Space: lượt loa 3 dòng, 0 dừng, Esc thoát sạch.
3. Gắn `speaker.gd` lên AudioStreamPlayer3D; gọi `play_announcement(lines, line_seconds=4.0)` với `{"text_key": String, "garbled": bool}`; nghe signal `announcement_finished`; hủy bằng `stop_emitting()`. Đặt node ở process mode kế thừa pause. README có đầy đủ hành vi đầu vào và phím QA.

**Yêu cầu thay đổi ngoài phạm vi**
- Integrator T-117 đặt Speaker ở loa bàn trực và gọi API bằng danh sách key của đoạn 2; dòng rè phải dùng **RULE_3_GARBLED**, không đưa chữ đầy đủ RULE_3 rồi dùng tiếng rè để che. Nối announcement_finished vào luồng phán định đã duyệt; Lane E không tự viết logic luật/sổ tay.
- Lane A/Integrator nối cue điện thoại rung, công tắc, chốt và ba lượt knock với tương tác/trigger T-129/T-117. Phone là loop nên bên sở hữu trigger dừng khi hết sự kiện; các cue này dùng SFX, phần loa dùng Voice.
- Không cần thay bus layout, autoload, signal EventBus hoặc key dịch cho T-130. Không phát sinh câu hỏi luật chơi/cốt truyện; nội dung đoạn 1–2 lấy theo thiết kế đã duyệt.

**Blocked:** Không còn chặn kỹ thuật; chờ duyệt nghe thực tế và tích hợp ở T-117. Fetch/checkout LFS/push và các lệnh kiểm tra cần quyền ngoài sandbox; đã thực hiện thành công.
