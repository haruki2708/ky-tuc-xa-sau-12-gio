# T-205 — Chương 2: giọng 5 câu gọi mới (nhắn cách qua vòng 3)
- Lane: E (Âm thanh) | Trạng thái: todo (thu sau khi chủ dự án duyệt lời) | Agent:
- Nhánh: `lane-e/T-205-ch2-tell-voices`, **tạo từ `origin/core/T-204-ch2-tell-friends-loop`** (lời mới chỉ có trên nhánh đó, chưa vào `main`)
- Phụ thuộc: D-072. Làm song song với T-204 (core, phiên web). **Chỉ thu khi lời đã được duyệt** (D-072 ghi "đã duyệt lời").
- **Hạn đề xuất:** 2026-10-10.

## Việc
1. Thu 5 câu, lời lấy đúng cột `vi` của `game/localization/strings.csv`, đặt tên theo key trong `game/audio/voice/vi/<KEY>.ogg` như các câu chương 2 đã có (`audio_source/ch2_voice_process.py`, cùng preset Minh Nhật và Ngư, nhanh ×1,25 theo D-051):
   - Minh Nhật: `CHAT_CH2_N_HOW`, `CHAT_CH2_N_TOLD`, `CHAT_CH2_N_CAUGHT` (câu cuối ngắt quãng, hoảng);
   - Ngư: `CHAT_CH2_NGU_HOW`, `CHAT_CH2_NGU_TOLD`.
   - Không thu `CHOICE_CH2_TELL_*` (Trung không có giọng).
2. Cập nhật report (LUFS/peak, như T-200) và `game/audio/CREDITS.md`.
3. Test (`game/tests/audio/`): 5 file có, decode được, âm lượng trong ngưỡng câu gọi chương 2. Trên nhánh gốc `test_all_ogg_load_and_decode_with_correct_loop_flags` FAIL vì thiếu đúng 5 file này; sau khi thu phải PASS.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/tests/audio/`, card này (Handoff).

## Checklist hoàn thành
- [x] 5 giọng đúng lời, đúng tên key
- [x] Report, CREDITS
- [x] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [x] Handoff: bảng giọng và âm lượng, nhờ chủ dự án nghe

## Handoff (agent điền)

### Lane E — 2026-10-09

- **Duyệt lời:** chủ dự án xác nhận trực tiếp trong phiên này: “Duyệt cả 5 câu hiện tại, tiến hành thu”. Xác nhận áp dụng nguyên văn 5 key trong card, từ cột `vi` tại base `13b5d68`; không sửa lời hoặc thu các lựa chọn của Trung.
- Nhánh tạo đúng từ `origin/core/T-204-ch2-tell-friends-loop` (`13b5d68`), không từ main. Commit triển khai **`a21ee0c`** (`T-205: render approved chapter two tell-friends voices`) đã push lên `origin/lane-e/T-205-ch2-tell-voices`; LFS **10/10**, khoảng 926 KB. Không thay runtime/core/CSV hoặc các asset giọng cũ.
- Thu 5 raw WAV + 5 OGG/import bằng eSpeak NG 1.52.0 và FFmpeg 9.0.2 có sẵn trên D. Minh Nhật `vi+m2`, pitch 46; Ngư `vi+f2`, pitch 58; cả hai **188 WPM**, target **−26 LUFS**, theo preset chương 2/D-051. N_CAUGHT giữ dấu ngắt và thêm rung nhẹ `vibrato=f=7:d=0.08`; sắc thái hoảng còn cần nghe duyệt.
- `ch2_voice_process.py --keys ...` tái tạo riêng các key chọn và ghép report; đã đối chiếu **302 mục report cũ giữ nguyên**, chỉ thêm 5 mục. Report mới chứa nguyên lời, filter, LUFS/peak và SHA256 raw/OGG. CREDITS và `audio_source/voice_ch2/README.md` ghi nguồn, cách tái tạo và giới hạn kiểm chứng. Mọi file nhị phân mới <200 KB/file, qua LFS.

| Key (tiền tố CHAT_CH2_) | Giọng | Giây raw | LUFS đo | True peak dBTP |
|---|---|---:|---:|---:|
| N_HOW | Minh Nhật | 4,338 | −26,15 | −5,02 |
| NGU_HOW | Ngư | 3,807 | −26,06 | −6,97 |
| N_TOLD | Minh Nhật | 3,358 | −26,10 | −5,07 |
| NGU_TOLD | Ngư | 3,231 | −26,08 | −6,96 |
| N_CAUGHT | Minh Nhật | 2,488 | −26,21 | −3,49 |

**Đã kiểm tra:**

```text
pwsh tools/test.ps1 -Filter ch2_tell_voices
RESULT: 1 passed, 0 failed

pwsh tools/test.ps1
RESULT: 706 passed, 0 failed

pwsh tools/check.ps1
RESULT: check 0 error(s)
```

- Test mới đối chiếu lời với CSV, đúng người/preset, hash, decode toàn clip, không loop/clipping và ngưỡng chương 2 (−26 ±1,5 LUFS, peak ≤−1 dBTP); không có giọng CHOICE_CH2_TELL_*.
- Test cảnh chương 2 thật (`auto_start=false`) phát lần lượt 5 message bằng EventBus, xác nhận đúng OGG qua `PhoneVoice`. `test_all_ogg_load_and_decode_with_correct_loop_flags` nay PASS. `git diff --check` PASS.
- **Chưa nghe bằng tai, chưa chơi trọn luồng T-204.** Không chạy bot chương 3–4. Nhờ chủ dự án nghe 5 file `game/audio/voice/vi/CHAT_CH2_*.ogg` trong bảng trên, kiểm tra tốc độ/phát âm và câu N_CAUGHT ngắt quãng, hoảng; khi ghép T-204 thử cả nhánh trả lời đúng và sai/hết giờ. Checklist triển khai đã đạt, nghe duyệt còn chờ.

**Yêu cầu thay đổi ngoài phạm vi:** không cần sửa code ngoài phạm vi. Nhờ integrator cập nhật D-072 trong `docs/DECISIONS.md` từ “chờ chủ dự án duyệt” sang “đã duyệt lời” theo xác nhận ngày 2026-10-09 ở trên; Lane E không sửa file này.

**Blocked:** không. Giọng và test đã hoàn thành; phần ghép/chơi thử luồng thuộc T-204.

## Review (integrator)
