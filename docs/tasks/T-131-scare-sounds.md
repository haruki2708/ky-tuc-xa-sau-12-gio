# T-131 — Âm hù dọa và truy đuổi
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-131-scare-sounds`
- Phụ thuộc: T-130 (done). **Đọc `docs/design/RULES.md` mục 5b** (D-024: hậu quả rõ, jumpscare hiếm, 2 cảnh truy đuổi).

## Mục tiêu
Các âm làm cho lỗi sai "có cảm giác", cho 3 cú hù và 2 cảnh truy đuổi. Integrator (StoryDirector) và lane A (thực thể truy đuổi, đợt 2) sẽ phát các âm này; lane E chỉ làm âm, không viết logic khi nào phát.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/default_bus_layout.tres`, `game/tests/audio/`

## Yêu cầu
1. **Âm mới** (tự tổng hợp như trước, CC0, khai báo AI):
   | File | Loại | Dùng khi | Mô tả |
   |---|---|---|---|
   | `sfx/sting_low` | one-shot, khoảng 3 giây | Làm sai nội quy (mọi lỗi) | Một nốt trầm "ùm" kéo dài, có rung nhẹ, tắt dần. Gây cảm giác "vừa có gì không ổn", **không giật mình** |
   | `sfx/sting_hit` | one-shot, khoảng 2 giây | 3 cú jumpscare | Tiếng đánh mạnh, đột ngột (tiếng gõ kim loại méo cộng nhiễu), đuôi ngân |
   | `sfx/slipper_place` | one-shot | Đôi dép thứ năm được đặt trước cửa | Hai tiếng dép nhựa đặt nhẹ xuống gạch, sát nhau |
   | `sfx/tube_cut` | one-shot | Đèn tuýp tắt phụt | Tiếng "bụp" khô của chấn lưu nhả, kèm "tách" nhỏ |
   | `ambience/breath_close` | loop | Thực thể ở gần khi truy đuổi | Tiếng thở chậm, khàn, sát tai. Không phải giọng người nói |
   | `sfx/slipper_rush_01…04` | one-shot | Thực thể đuổi theo | Bước dép lê dồn dập, nặng hơn bước chạy của người chơi |
   | `sfx/whisper_co` | one-shot, khoảng 1,5 giây | Thua vì trả lời tên Lâm | Tiếng thì thầm hơi thở, nghe giống chữ "Có…". Không cần rõ chữ (giọng TTS làm sau, D-006); phụ đề sẽ hiện chữ |
   | `sfx/net_billow` | one-shot | Mùng phồng lên (thua ở điểm danh) | Tiếng vải lưới phồng gió "phựt" nhẹ |
2. **Độ to** (chủ dự án thích âm nhỏ, D-015…D-023; sting phải rõ):
   - `sting_low`, `slipper_place`, `tube_cut`, `net_billow`: khoảng −32 LUFS;
   - `slipper_rush`: khoảng −34;
   - `breath_close`: khoảng −36;
   - `whisper_co`: khoảng −30;
   - `sting_hit`: khoảng **−20** (cú hù phải đủ giật).
   
   Các âm đã duyệt **giữ nguyên hash**.
3. **Bus:** sting và `whisper_co` đi bus `Voice` hoặc `SFX` (lane E chọn, ghi lý do); bước chân thực thể đi `SFX`, không đi `Footsteps`, để thanh trượt bước chân của người chơi không làm mất tiếng thực thể.
4. **Test:** mọi file load được, đúng cờ loop; độ to trong `build_report.json` nằm trong ±1 LU so với mục 2; `sting_hit` to hơn `sting_low`.
5. **Nghe thử:** thêm vào `segment12_test.tscn` hoặc tạo `scare_test.tscn`, mỗi âm một phím.

## Checklist hoàn thành
- [ ] Chạy lại `process.py --regenerate-raw` ra file giống nhau; tổng audio dưới 15 MB
- [ ] Âm đã duyệt không đổi hash
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Không chạm file ngoài phạm vi; `CREDITS.md` cập nhật
- [ ] Mục Handoff đã điền, ghi rõ phần nào **chưa nghe bằng tai**

## Handoff (agent điền)
