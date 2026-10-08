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
- [ ] 5 giọng đúng lời, đúng tên key
- [ ] Report, CREDITS
- [ ] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [ ] Handoff: bảng giọng và âm lượng, nhờ chủ dự án nghe

## Handoff (agent điền)

## Review (integrator)
