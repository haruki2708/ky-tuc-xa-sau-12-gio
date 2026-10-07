# T-200 — Giọng chương 4 theo lời đã duyệt; cuộc gọi chương 2–4 có tiếng
- Lane: E (Âm thanh) | Trạng thái: done | Agent: lane E
- Nhánh: `lane-e/T-200-ch4-voices-call-audio`
- Phụ thuộc: T-198 (đã merge), D-068 (lời `docs/design/CH4_SCRIPT.md` **đã duyệt**), T-137/T-186 (giọng eSpeak, loa, Minh Nhật, Ngư). Quy tắc cũ: **âm lượng nhỏ**, giữ ngưỡng của chương 3.
- **Hạn đề xuất:** 2026-10-08.

## Việc
### 1. Thu lại giọng chương 4 từ đúng lời đã duyệt
Lời lấy từ `game/localization/strings.csv` (cột `vi`), đúng từng chữ; không sửa lời. Ra file **đặt tên theo key** trong `game/audio/voice/vi/<KEY>.ogg`, như chương 3 (`CHAT_CH3_*`, `NEAR_CH3_*`, `SPK_CH3_*`). Core đã phát sẵn theo tên key, **không cần core nối thêm**:
- loa: `_announce` → `Speaker` đọc `voice/vi/SPK_CH4_REGISTERED.ogg`;
- y tá: `Chapter4Director._voice_at` phát `voice/vi/NEAR_CH4_NURSE*.ogg` tại `Nurse1`, `Nurse2` của phòng bệnh viện;
- cuộc gọi: `PhoneCallAudio` (sau khi sửa ở mục 2).

| Key | Ai đọc | Ghi chú |
|---|---|---|
| `SPK_CH4_REGISTERED` | Loa (giọng loa chương 1–3) | Sau tiếng cười `pa_laugh` đã có |
| `CHAT_CH4_NGU_GO`, `CHAT_CH4_NGU_LECTURE`, `CHAT_CH4_NGU_NO_EXIT`, `CHAT_CH4_NGU_TRUNG` | Ngư (giọng chương 3) | Nhanh ×1,25 như chương 2–3 (D-051) |
| `CHAT_CH4_N_GO`, `CHAT_CH4_N_GYM`, `CHAT_CH4_N_LINE`, `CHAT_CH4_N_WHERE`, `CHAT_CH4_N_LOST`, `CHAT_CH4_N_GOT` | Minh Nhật (giọng chương 3) | Nhanh ×1,25. `N_LOST` bị cắt giữa câu (mất sóng): lời đã có dấu "…" |
| `NEAR_CH4_NURSE1_AWAKE`, `NEAR_CH4_NURSE1_LUCKY` | Y tá 1 (nữ) | |
| `NEAR_CH4_NURSE2_QUAKE`, `NEAR_CH4_NURSE2_ALL`, `NEAR_CH4_NURSE2_ALONE` | Y tá 2 (nữ, giọng khác y tá 1) | Y tá 2 đọc câu kết ở **cả hai kết** |

- `SAY_CH4_TRUNG_ASK` **không** thu (Trung không bao giờ có giọng).
- Bản nháp cũ trong `game/audio/ch4_voice/` (thu theo `CH4_DESIGN.md`) **không còn dùng**: core không gọi `Ch4AudioRig.play_line`. Lane E tự chọn bỏ các file đó (kèm test của chúng) hoặc cho `play_line` đọc file mới; ghi lựa chọn vào Handoff.
- Cập nhật `audio_source/ch4_voice_process.py` (hoặc tương đương) để tái tạo được; report LUFS/peak như T-198; `game/audio/CREDITS.md`.

### 2. Sửa lỗi: cuộc gọi chương 2, 3, 4 không có tiếng
**Lỗi (integrator tái hiện trên cảnh thật `chapter2.tscn`, `chapter3.tscn`, 2026-10-07):** phát `EventBus.phone_message_received(&"chat_ch2_n_28")` hoặc `(&"chat_ch3_n_all_up")` thì `PhoneCallAudio/Speech` không phát, `_in_call = false`, dù `voice/vi/CHAT_CH2_*.ogg`, `CHAT_CH3_*.ogg` đã có. Hai nguyên nhân trong `game/scripts/audio/phone_call_audio.gd`:
1. `play_message` chỉ nhận key bắt đầu bằng `CHAT_CH1_` (`Ch1AudioBank.voice(message.text_key, "CHAT_CH1_", …)`).
2. Chỉ phát khi đã nhấc máy (`phone_call_answered`), mà chỉ chương 1 có cảnh nhấc máy. Từ chương 2, **cuộc gọi nhóm đã mở sẵn từ đầu chương** (theo cốt truyện), không có chuông, không nhấc máy. `chapter_started` và `checkpoint_loaded` hiện gọi `end_call(false)`.

**Yêu cầu:**
- Nhận mọi key `CHAT_CH<n>_` (n = 1…4); vẫn kiểm ký tự như hiện tại.
- Chương 2–4: coi như đang trong cuộc gọi ngay khi `chapter_started(chapter >= 2)` và sau `checkpoint_loaded` (không đổ chuông). Vẫn theo `phone_call_lost` / `phone_call_restored` như cũ.
- **Chương 1 giữ nguyên hành vi** (chuông, nhấc máy, mất sóng, thành viên chết).
- Core chờ đúng độ dài file (`_voice_seconds` đã đọc file), nên không cần sửa core.

### 3. Test (`game/tests/audio/`)
- Đủ 16 file mục 1, decode được, âm lượng trong ngưỡng chương 3.
- **Trên cảnh thật** `chapter2.tscn`, `chapter3.tscn`, `chapter4.tscn` (`auto_start = false`): phát `phone_message_received` của một lời có giọng thì `PhoneCallAudio/Speech` phát đúng file đó. Chương 1 vẫn cần nhấc máy (test cũ không đổi).

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/tests/audio/`, card này (Handoff). Không sửa `strings.csv`, core, scene chính.

## Checklist hoàn thành
- [x] 16 giọng chương 4 đúng lời đã duyệt, đặt tên theo key trong `game/audio/voice/vi/`
- [x] Bản nháp cũ `ch4_voice/` đã xử lý (bỏ hoặc thay), ghi lý do
- [ ] Cuộc gọi chương 2–4 có tiếng; chương 1 không đổi
- [x] Test trên cảnh thật chương 2, 3, 4
- [x] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [x] Handoff: bảng giọng và âm lượng, **nhờ chủ dự án nghe**

## Handoff (agent điền)

### Lane E — 2026-10-08 (triển khai/kiểm tra 2026-10-07)

- Commit triển khai **`dee725c`**, Handoff ban đầu `c07034a`, nhánh `lane-e/T-200-ch4-voices-call-audio`, base main `9d31e11`. **Đã push thành công lên origin**, LFS upload đủ 28/28 object mới (~3,0 MB). Các lượt trước gặp lỗi máy chủ HTTP 502 ở `/info/lfs/objects/batch` và `Unable to verify locks`; sau khi máy chủ phục hồi, lệnh `git push -u origin lane-e/T-200-ch4-voices-call-audio` bình thường đã thành công. Không đổi cấu hình repo và không bỏ bước upload asset. Commit Handoff tiếp theo chỉ cập nhật trạng thái push đã phục hồi.
- Tái tạo **16 câu nguyên cột vi CSV**, đúng người đọc D-068, đúng tên key tại `game/audio/voice/vi/`. Minh Nhật/Ngư dùng chính preset Ch3, 188 WPM (×1,25); hai y tá khác giọng, **y tá 2 đọc cả hai kết**. Không thu Trung, không sửa CSV/lời kịch bản. `audio_source/ch4_voice_process.py` tái tạo offline bằng công cụ D:\Tools có sẵn; report text/params/thời lượng/LUFS/peak/hash và CREDITS đã cập nhật.
- **Bỏ cả 7 bản nháp** raw/OGG/import T-198 vì có lời/người nói đã thay đổi. Không giữ alias nháp. `Ch4AudioBank.voice`/helper `play_line` và fixture chuyển sang 16 key mới; core vẫn dùng Speaker, `_voice_at`, PhoneCallAudio như có sẵn. 32 file raw/OGG hiện tại tổng 3.376.444 byte, file lớn nhất 275.414 byte, qua LFS.
- `PhoneCallAudio` nhận an toàn `CHAT_CH1_`…`CHAT_CH4_`; Ch2–4 tự ở trong cuộc gọi khi `chapter_started`, không chuông/nhấc máy. Checkpoint dùng `GameState.chapter` đã restore. Giữ loss/restore theo đúng call id, queue, member death/left, missing asset, lọc ký tự và stop vĩnh viễn. Ch1 giữ incoming/answer, các test Ch1 cũ không sửa.
- Sửa thêm trong phạm vi audio: `SpeakerVoiceBank` trước đây cũng chỉ nhận SPK/RULE Ch1, nên chỉ tạo file PA Ch4 chưa đủ. Nay nhận SPK/RULE Ch1…4, giữ kiểm ký tự, fallback vi khi UI en và chặn `RULE_3` chưa che.
- Chỉ thay 79 file triển khai trong allowlist; không sửa core, scene chính, CSV hoặc bus. Khi chuẩn bị, checkout LFS trong sandbox bị ngắt; trạng thái checkout dở được bảo toàn bằng stash `T-200: preserve partial checkout after sandbox LFS failure`, không áp lại vào nhánh T-200.

### Kiểm tra

```text
pwsh tools/test.ps1 -Filter ch4
RESULT: 52 passed, 0 failed
pwsh tools/test.ps1 -Filter audio
RESULT: 110 passed, 0 failed
pwsh tools/test.ps1
RESULT: 668 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
```

Godot 4.7.2, chạy ngoài sandbox vì Godot trong sandbox không đọc được kho chứng chỉ Windows. `git diff --check` sạch. Test mới tải scene thật Ch1…4 với `auto_start=false`, gửi giao thức start/checkpoint và message, kiểm `PhoneCallAudio/Speech` phát đúng file/bus; Ch1 vẫn phải nhấc máy. Kiểm cả PA và 5 câu y tá qua Speaker/director tại Nurse1/Nurse2 thật, fallback và khóa sai. Bank decode đủ 16, SHA256 khớp, văn bản report bằng đúng CSV kể cả dấu “…”. Không chạy bot Ch3/Ch4; chưa chơi xuyên chương, **chưa nghe bằng tai**.

### Bảng giọng và âm lượng

| Key/nhóm | Người đọc / WPM / pitch | LUFS đo OGG | Peak lớn nhất nhóm |
|---|---|---|---|
| SPK_CH4_REGISTERED | vi+m1 / 132 / 30 | −33,11 | −12,87 dBTP |
| CHAT_CH4_NGU_GO, NGU_LECTURE, NGU_NO_EXIT, NGU_TRUNG | Ngư vi+f2 / 188 / 58 | −26,08…−26,03 | −5,94 dBTP |
| CHAT_CH4_N_GO, N_GYM, N_LINE, N_WHERE, N_LOST, N_GOT | Minh Nhật vi+m2 / 188 / 46 | −26,17…−26,05 | −3,77 dBTP |
| NEAR_CH4_NURSE1_AWAKE, NURSE1_LUCKY | vi+f1 / 145 / 54 | −34,09 | −14,10 dBTP |
| NEAR_CH4_NURSE2_QUAKE, NURSE2_ALL, NURSE2_ALONE | vi+f3 / 150 / 62 | −34,07…−34,05 | −15,02 dBTP |

Tên rút gọn dùng cùng tiền tố đầu hàng. Chat trên PhoneVoice, PA/y tá trên Voice. Mục tiêu chat −26 LUFS như Ch3, PA −33/y tá −34 như ngưỡng nhỏ T-198. Limiter chặn transient trước Vorbis; đo lại mọi OGG, sai số mục tiêu ≤1 LU, peak ≤−2 dBTP. Không khẳng định mức tổng tại tai sau bus.

### Yêu cầu thay đổi ngoài phạm vi / còn dở

- **Checklist cuộc gọi giữ chưa đạt trọn vẹn vì câu kết thật N_GOT:** đường phát cuộc gọi thường Ch2–4 và start/checkpoint đã sửa, test scene thật PASS. Tuy nhiên `game/scripts/core/chapter4_director.gd` phát `phone_call_lost(&"ch4_group")` ở cầu thang (dòng 328), rồi `_ending_4` chỉ đặt `_network_up = true` trước `_line("n_got")` (dòng 476–477), **không phát `phone_call_restored`**. Theo hợp đồng loss/restore của card, audio vẫn đang mất sóng và câu cuối sẽ im dù file mới đã có.
- **Yêu cầu core:** thêm `EventBus.phone_call_restored.emit(&"ch4_group")` sau `_network_up = true`, trước `await _line("n_got")`; kiểm lại kết thật. Không tự sửa core, không cho một key thoại vượt qua trạng thái mất sóng. Test audio đã xác nhận `N_GOT` phát khi có đúng tín hiệu restored.
- **Nhờ chủ dự án nghe duyệt:** F6 `res://audio/test/ch4_audio_test.tscn`; mũi tên đi qua 29 SFX/nhạc rồi 16 câu mới, Space nghe lại, 0 dừng. Chat preview đi qua PhoneVoice. Cần nghe phát âm tên Trần Trung, độ nhanh/rõ của hai bạn, câu N_LOST dừng giữa câu, hai giọng y tá, cả hai kết và độ nhỏ. Chi tiết trong [README voice](../../audio_source/voice_ch4/README.md).
- **Blocked (một câu ở kết thật):** N_GOT chờ core bổ sung tín hiệu restored như trên. Phần triển khai Lane E đã xong, test/check PASS và đã push; lỗi máy chủ LFS đã hết. Chưa có duyệt nghe của chủ dự án.

## Review (integrator)

### 2026-10-08 — Claude (integrator, Opus): **duyệt, đã merge**
- **Đúng card, làm kỹ:** 16 giọng đặt tên theo key trong `game/audio/voice/vi/`, lời lấy đúng cột `vi` (report so khớp từng chữ, kể cả "…"), Minh Nhật và Ngư dùng preset chương 3 nhanh ×1,25, hai y tá khác giọng, y tá 2 đọc cả hai kết; bỏ 7 bản nháp cũ, `Ch4AudioBank` và fixture nghe chuyển sang key mới.
- **`PhoneCallAudio`:** nhận `CHAT_CH1_`…`CHAT_CH4_`; chương 2–4 coi như đang trong cuộc gọi `ch<n>_group` khi `chapter_started`; nạp lại điểm lưu dùng `GameState.chapter`. Integrator kiểm: mỗi lần chết cảnh được nạp lại và director luôn đặt `GameState.chapter` rồi phát `chapter_started`, nên cuộc gọi mở lại đúng. Chương 1 không đổi (test cũ giữ nguyên).
- **Lane E sửa thêm, đúng:** `SpeakerVoiceBank` trước đây cũng chỉ nhận `SPK_CH1_`/`RULE_CH1_`, nghĩa là **giọng loa chương 2 và 3 cũng chưa từng phát** (chỉ có phụ đề). Nay nhận chương 1–4.
- **Yêu cầu core của lane E (đúng, integrator đã làm):** `chapter4_director.gd` phát `phone_call_restored(&"ch4_group")` trước câu cuối `n_got` ở kết thật (trước đó câu này im vì cuộc gọi còn ở trạng thái mất sóng từ tầng 2). `test_chapter4.gd::test_slats_form_name_and_the_true_ending` kiểm trên cảnh thật: mất sóng rồi kết thật thì `PhoneCallAudio` phát `CHAT_CH4_N_GOT`; bỏ dòng sửa thì test hỏng.
- **Chưa nghe bằng tai:** nhờ chủ dự án nghe trong game (cuộc gọi chương 2–4, loa chương 2–4, y tá) hoặc fixture F6 `res://audio/test/ch4_audio_test.tscn`.
