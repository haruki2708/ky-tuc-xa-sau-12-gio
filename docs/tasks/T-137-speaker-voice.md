# T-137 — Giọng đọc của loa phát thanh (TTS offline)
- Lane: E (Âm thanh) | Trạng thái: done | Agent:
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
- [x] Giấy phép công cụ và giọng ghi trong `CREDITS.md`, có khai báo AI
- [x] LUFS ghi vào Handoff
- [x] Handoff: công cụ đã chọn, lệnh tạo lại giọng, phần chưa nghe bằng tai

## Handoff (agent điền)

**Blocked: chưa đạt toàn bộ test PASS.** Có 4 test core đoạn 1–2 hết hạn chờ 30 giây sau khi thêm giọng. File test nằm ngoài scope Lane E, không tự sửa. Phần triển khai và asset đã push để Integrator review; không coi task là hoàn tất hoặc sẵn sàng merge.

### Đã làm (2026-10-03)
- Nhánh từ `origin/main` tại `25da80b`; đã đọc AGENTS, STATUS, card và handoff lane E. Commit triển khai **`9517ad8`** (`T-137: add offline bilingual PA voices and duration-aware playback`) đã push lên `origin/lane-e/T-137-speaker-voice`; LFS tải đủ 62 object duy nhất cho 68 file raw/OGG (raw tên Việt trùng giữa hai locale được deduplicate).
- Tạo đủ **17 key × vi/en = 34 file OGG**, kèm WAV thô, import, report, pipeline và test. Text lấy CSV, bỏ tiền tố/chỉ dẫn ngoặc. Tên riêng ở cả hai locale dùng giọng Việt; `SPK_AND_TRUNG` bản Anh ghép phần tên bằng giọng Việt. Trung gọi lại dùng tốc độ 95 WPM thay vì 145, giữ dấu ba chấm.
- `RULE_3_GARBLED`: raw đọc đầy đủ RULE_3, chia tiền đề/hành động để lấy mốc chính xác. Bản game thay toàn bộ lời từ mốc hành động bằng nhiễu, hệ số speech bằng 0; không chỉ chồng noise lên giọng còn rõ. Không xuất `RULE_3.ogg` vào game. Burst hiện có vẫn phát khi `garbled=true`.
- Speaker thêm player 3D con `Speech` bus Voice, đồng bộ vị trí/gain/pitch/attenuation. Đọc `[ui] locale` đúng hợp đồng ở đầu mỗi dòng; thiếu/sai kiểu/không hỗ trợ → vi. Thời lượng `max(clip.get_length() + 0.4, line_seconds)`. Giữ một subtitle lúc bắt đầu, completion sau power-off; stop/restart/unload và subscriber hủy reentrant đều dừng voice. Thiếu file/key quay về tiếng rè + phụ đề.
- F6 `res://audio/test/segment12_test.tscn`: **V** thử 17 câu Việt, **B** 17 câu Anh; Space chuỗi cũ theo settings; 0 dừng, Esc App.quit; F1–F11 giữ hiệu ứng. V/B không ghi settings, phụ đề vẫn theo locale UI. Có thể chọn ngôn ngữ trong menu game rồi mở fixture để chữ/giọng khớp. Toàn bộ hướng dẫn ở `audio_source/voice/README.md`.
- 118 file triển khai đều trong vùng được phép. Ngoài ra chỉ sửa checklist/Handoff card này. Không sửa core, main, UI, CSV, STATUS hoặc test ngoài `game/tests/audio/`. Không đổi hash âm đã duyệt, không thêm plugin.

### Công cụ, giọng, giấy phép
- Chọn **eSpeak NG 1.52.0**, giọng tích hợp **vi (Vietnamese Northern, nam)** và **en-gb (English Great Britain)**; tổng hợp formant/quy tắc, không neural/không clone giọng người, không MBROLA. Engine và dữ liệu giọng cùng **GPL-3.0-or-later**, cho phép dùng thương mại; chỉ dùng công cụ build offline, không đóng gói engine/data vào game. Waveform/processing gốc của dự án CC0; CREDITS phân biệt rõ giấy phép công cụ và output.
- Nguồn: [release eSpeak NG](https://github.com/espeak-ng/espeak-ng/releases/tag/1.52.0), [README/giấy phép](https://github.com/espeak-ng/espeak-ng/blob/1.52.0/README.md), [COPYING](https://github.com/espeak-ng/espeak-ng/blob/1.52.0/COPYING), [giọng vi](https://github.com/espeak-ng/espeak-ng/blob/1.52.0/espeak-ng-data/lang/aav/vi), [giọng en](https://github.com/espeak-ng/espeak-ng/blob/1.52.0/espeak-ng-data/lang/gmw/en). Ghi đầy đủ tác giả/URL/giấy phép/mọi key ở `game/audio/CREDITS.md`.
- Khai báo **nội dung âm thanh tạo bằng quy trình có AI hỗ trợ**: OpenAI Codex viết mã xử lý/tích hợp; eSpeak là TTS formant, không gọi nhầm thành giọng neural. Chất máy cần chủ dự án nghe duyệt.
- Đã xét Piper 2023.11.14-2 (MIT) và vais1000 (model card ghi dataset CC BY 4.0), nhưng vais1000 fine-tune Lessac và model card Lessac dẫn tới giấy phép nghiên cứu; chưa đủ cơ sở xác nhận chuỗi giọng cho thương mại nên không tải/dùng model đó. Liên kết bằng chứng trong CREDITS.
- Công cụ nằm ở `D:\Tools\espeak-ng\1.52.0\portable\SourceDir\eSpeak NG\`; lessmsi 2.12.9 (MIT) ở `D:\Tools\lessmsi\2.12.9` chỉ để giải nén. MSI administrative extraction thử đầu bị Windows 1625; đã chuyển sang đọc/giải nén archive, không chạy installer trong quy trình chính thức. Không cài vào C:. Phải chỉ định đường dẫn dữ liệu D:; thiếu path khiến bản portable lỗi khởi động, pipeline đã xử lý bằng `--path` và `ESPEAK_DATA_PATH`.

### Tạo lại và số đo
Từ gốc repo:
```powershell
pwsh audio_source/voice/setup.ps1       # Lần đầu tải/giải nén công cụ vào D:\Tools
py -3 audio_source/voice_process.py    # Tạo giọng và xử lý hoàn toàn offline
py -3 audio_source/test_voice_process.py
pwsh tools/test.ps1 -Filter audio
```
`setup.ps1` ghim SHA256 archive. `voice_process.py` dùng Python/FFmpeg 9.0.2 đã có: 300–3400 Hz, soft clip tanh, vang 47/89/137 ms, hiss nhỏ, fade và normalize −26 LUFS, mono Vorbis q4/48 kHz. WAV thô 22,050 Hz. Report riêng ở `audio_source/voice/build_report.json`.

| KEY | LUFS vi | LUFS en |
|---|---:|---:|
| RULE_HEADER_5 | −26.04 | −26.19 |
| RULE_1 | −26.06 | −26.12 |
| RULE_2 | −26.04 | −26.11 |
| RULE_3_GARBLED | −26.42 | −26.45 |
| RULE_4 | −26.05 | −26.13 |
| RULE_5 | −26.10 | −26.11 |
| SPK_SIGN_LOG | −26.02 | −26.12 |
| SPK_ROLLCALL_INTRO | −26.10 | −26.12 |
| SPK_CHECK_TAPS | −26.07 | −26.14 |
| SPK_NAME_PHUC | −26.05 | −26.05 |
| SPK_NAME_VIET | −26.03 | −26.06 |
| SPK_NAME_TRUNG | −26.08 | −26.08 |
| SPK_NAME_DAT | −26.13 | −26.09 |
| SPK_NAME_LAM | −26.04 | −26.04 |
| SPK_NAME_TRUNG_AGAIN | −26.04 | −26.04 |
| SPK_AND_ONE_MORE | −26.02 | −26.15 |
| SPK_AND_TRUNG | −26.06 | −26.18 |

Tất cả trong ±1 LU; peak cao nhất −7.62 dBTP. Khác biệt nhỏ ở tên cùng giọng do seed hiss theo locale; hash WAV thô của các tên giống nhau giữa vi/en đã test.

### Kiểm chứng đã chạy
- Hai lần tạo lại giọng thành công: `VOICE RESULT: 34 assets validated; raw + OGG = 6028731 bytes`.
- `VOICE REBUILD RESULT: 34 WAV + 34 OGG SHA256 identical; report identical`.
- `PRESERVATION RESULT: 86 approved WAV/OGG files match origin/main SHA256` (43 âm cũ).
- Voice raw 4,852,406 byte + OGG 1,176,325 byte; file raw lớn nhất 374,108 byte. Bank voice <20 MB, bank âm cũ <20 MB, tổng hiện tại 24,804,841 byte <40 MB. `process.py` chỉ tính bank 43 âm của nó, voice có budget/report riêng; không giảm chất lượng hoặc sửa âm đã duyệt.
- Python test pipeline: **3 tests OK**; bao gồm thay mọi mẫu lời ẩn mà output mask không đổi.
- Audio cuối cùng: **`RESULT: 37 passed, 0 failed`**, exit 0. Đủ 34 file load/decode/hash/loop/LUFS, locale, timing, một subtitle/dòng, fallback, spatial routing, garble và phím V/B.
- `pwsh tools/check.ps1`: **`RESULT: check 0 error(s)`**, exit 0. `git diff --check` sạch.
- **Toàn bộ `pwsh tools/test.ps1`: `RESULT: 247 passed, 4 failed`**, exit 1; launcher còn in `RESULT: test FAIL (engine error or missing successful runner result)`. Đây là 4 assertion timeout core, không phải SCRIPT ERROR. Chưa có lượt full test PASS với giọng mới.

### Yêu cầu thay đổi ngoài phạm vi / chỗ bị chặn
**Integrator sửa `game/tests/core/test_story_director.gd`**: fixture đặt `time_scale=0.01` nhưng chờ tối đa 30,000 ms ở `_run_slice()` và lượt chờ knock. Theo hợp đồng mới, Speaker không rút giọng theo `line_seconds`; riêng 6 câu nội quy + padding + on/chime/off đã khoảng **35.6 s vi / 38.1 s en**, nên hết hạn trước phán định. Bốn test fail:
1. `test_lights_off_and_silence_keep_the_dorm_calm`
2. `test_light_left_on_and_opened_door_change_the_dorm`
3. `test_fifth_pair_waits_for_the_door_to_close`
4. `test_checkpoints_saved_at_segment_starts`

Đề xuất tăng deadline dựa trên thời lượng thật (ví dụ 90 s), hoặc cấu hình **riêng fixture chạy nhanh** dùng `Speaker.voice_directory = ""` trước khi vào cây, đồng thời giữ các test giọng đầy đủ của Lane E. Không tắt giọng mặc định trong game, không đổi công thức duration để né test. Sau thay đổi của Integrator cần chạy lại full suite. Lane E chưa sửa file ngoài quyền sở hữu.

Không cần thêm node/autoload/bus mới vào main: Speaker hiện hữu tự tìm giọng sau khi import. Giao diện `play_announcement(lines, line_seconds)` và tín hiệu subtitle/completion không đổi. Caller dựa vào signal nhận duration thật; không nên giả định mọi dòng vẫn dài 4 s.

### Chưa nghe bằng tai / còn dở
**Chưa nghe bằng tai** cả 34 file, phát âm/dấu Việt/Anh/tên riêng, câu Trung chậm, tiền đề điều 3 và chuyển rè, chất loa/vang hoặc mix trong main. Không chạy GUI nghe thử trong phiên này; chỉ headless/đo tín hiệu. Cần chủ dự án nghe V/B và chơi thử điểm danh sau khi test core được điều chỉnh. Không có câu hỏi cốt truyện mới; **task vẫn Blocked ở full-test gate**, không đánh dấu checklist đầu là đạt.

### Review (integrator, 2026-10-03)
- Đạt, đã merge. Chọn eSpeak NG là hợp lý khi chưa chứng minh được giấy phép thương mại của giọng Piper tiếng Việt; GPL áp dụng cho công cụ, không đóng gói vào game. Điều 3 bị nhiễu che hẳn phần hành động, đúng câu đố.
- Integrator sửa 4 test core timeout: fixture chạy nhanh tắt giọng (`FloorSpeaker.voice_directory = ""`), test giọng của lane E giữ nguyên. Full suite 253/253 PASS; bot 3 kịch bản PASS với giọng thật.
- Ghi công trong game (`UI_CREDITS_AUDIO_TEXT`) thêm nhạc nền và eSpeak NG.
- **Chờ chủ dự án nghe:** giọng formant nghe khá "máy"; nếu không hợp, phương án khác là chủ dự án tự thu âm (đã hỏi trước đây) hoặc tìm giọng neural có giấy phép rõ.
