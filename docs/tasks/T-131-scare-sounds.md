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
- [x] Chạy lại `process.py --regenerate-raw` ra file giống nhau; tổng audio dưới 15 MB
- [x] Âm đã duyệt không đổi hash
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Không chạm file ngoài phạm vi; `CREDITS.md` cập nhật
- [x] Mục Handoff đã điền, ghi rõ phần nào **chưa nghe bằng tai**

## Handoff (agent điền)

### Đã làm (2026-10-02)
- Nhánh tạo từ `origin/main` tại `aca2d8a`; đã đọc AGENTS, STATUS, card và RULES mục 5b. Commit triển khai `13d7079` (`T-131: add synthesized scare and pursuit sounds with audition tests`) đã push lên `origin/lane-e/T-131-scare-sounds`, gồm 22 đối tượng LFS mới.
- Tạo đủ 11 WAV/OGG bằng `synthesize_scare`, seed 13101–13111. Có 2 sting, dép đặt, đèn tắt, breath loop, 4 bước rush, whisper và mùng phồng. CC0, nguồn và khai báo OpenAI Codex/Python/FFmpeg ghi từng file trong `game/audio/CREDITS.md`.
- `sting_low` attack mềm 0.5 s; `sting_hit` kim loại méo/nhiễu đột ngột; dép đặt có hai xung sát nhau. Breath là nhiễu không giọng nói, chu kỳ thở chậm; whisper dùng cộng hưởng nguyên âm trên hơi nhiễu, không TTS. Không thêm luật/thời điểm kích hoạt hoặc thay đổi chuyện kể.
- Thêm `res://audio/test/scare_test.tscn`: F1 low, F2 hit, F3 dép đặt, F4 đèn tắt, F5 breath loop, F6–F9 rush 01–04, F10 whisper, F11 mùng; 0 dừng, Esc thoát qua App. Mỗi phím dừng nguồn trước, phát tại gain 0 dB/pitch 1; scene không tự phát âm khi mở. Hướng dẫn nằm trong `audio_source/README.md`.
- Bus: **SFX** cho sting và mọi hiệu ứng/thở/bước thực thể; **Voice** cho whisper vì là hơi giọng để có điều chỉnh riêng. Bước thực thể không qua **Footsteps**. Breath lưu thư mục ambience để tạo loop nhưng bus phát chọn SFX. Không sửa bus layout hoặc player của người chơi.
- Thêm test report LUFS/hash/peak/loop và phím/bus scene; mở rộng test decode để bao phủ cả 39 OGG. Commit cả import và UID sinh bởi Godot.

### Kết quả kiểm chứng
- `py -3 audio_source/process.py --regenerate-raw` chạy hai lượt thành công:
  - `AUDIO RESULT: 39 assets validated; raw + OGG = 10791088 bytes`
  - `REBUILD RESULT: 39 WAV + 39 OGG SHA256 identical; report identical`
  - `PRESERVATION RESULT: 56 approved WAV/OGG files match origin/main SHA256`
- Đã đối chiếu hash file thực với report trên origin/main cho đủ 28 âm đã duyệt. Tổng audio 10.79 MB <15 MB; file lớn nhất 2,016,044 byte <10 MB.
- LUFS OGG đo thật: low −32.01; hit −19.93; dép đặt −32.17; tube cut −32.05; breath −36.35; rush 01/02/03 −34.19, 04 −34.08; whisper −30.20; net −32.36. Tất cả trong ±1 LU mục tiêu, hit hơn low 12.08 LU. Peak lớn nhất của bank mới −9.86 dBTP; breath loop 8 s, chênh biên 0.0072131 (<0.02). OGG rush 04 đo 0.62 s do xử lý/codec, các rush còn lại 0.6 s.
- `pwsh tools/test.ps1 -Filter audio`: `RESULT: 25 passed, 0 failed` (exit 0).
- `pwsh tools/test.ps1`: `RESULT: 170 passed, 0 failed` (exit 0). Có warning từ test cố ý đưa flag/save/document lỗi và fixture switch không gán đèn; không có engine/script ERROR.
- `pwsh tools/check.ps1`: `RESULT: check 0 error(s)` (exit 0).
- `git diff --check` sạch; 43 file triển khai đều thuộc phạm vi card. Ngoài thư mục lane E chỉ sửa checklist/Handoff của card này. Không sửa STATUS/main/localization, không thêm plugin hoặc cài phần mềm.

### Còn dở / chưa kiểm chứng bằng tai
- **Chưa nghe bằng tai cả 11 âm T-131**, chưa nghe qua loa/tai nghe và chưa kiểm tra cảm nhận trong bản chơi thật. Headless đã load/decode và thử phím; phiên này không chạy nghe thử GUI. Không khẳng định whisper đã nghe ra chữ “Có”, dép/vải đủ tự nhiên hoặc mức giật mình đã được duyệt.
- Chủ dự án cần mở scene trên, nghe F1/F2 so độ tương phản, F3 hai dép đặt, F5 ít nhất 60 giây kiểm tra loop, F6–F9 kiểm tra chất âm thực thể, F10 tiếng hơi “Có”. Đây là bước duyệt cảm nhận tiếp theo; các checklist kỹ thuật ở trên đã đạt.

### Yêu cầu thay đổi ngoài phạm vi
- Integrator/StoryDirector và Lane A gắn các file vào hậu quả/truy đuổi đúng RULES 5b, gán **SFX** cho bước thực thể (không tái dùng `FootstepPlayer` vốn chọn bus Footsteps), **Voice** cho whisper; dừng loop breath khi hết truy đuổi, unload hoặc checkpoint. OGG không chứa routing bus nên caller phải thiết lập.
- Bên tích hợp nối `reduce_scares` theo D-024: bỏ sting mạnh, giảm whisper; thời điểm/phụ đề và nhịp bước thực thể do bên tích hợp quyết định. Lane E không tự sửa core, settings, UI, level hoặc logic truy đuổi; không cần thêm autoload/signal/input action.

### Chặn / câu hỏi
- Không có chặn kỹ thuật hoặc câu hỏi thiết kế mới. Chờ chủ dự án duyệt bằng tai và các lane tích hợp các điểm nêu trên; không coi các bước đó là đã làm trong T-131.
