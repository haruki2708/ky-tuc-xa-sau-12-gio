# T-159 — Giọng loa chương 1: bác Tư thật và giọng giả
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
- Nhánh: `lane-e/T-159-ch1-speaker-voice`
- Phụ thuộc: T-137 (pipeline giọng TTS), T-158 (làm ngay sau). Đọc `docs/design/STORY.md` §3 (bác Tư đã bị quên) và §5.3.
- **Hạn: hết ngày 2026-10-06.**

## Mục tiêu
Trên loa có hai giọng giống hệt nhau: giọng thật của bác Tư và Giọng loa giả. Người chơi phân biệt bằng **lời nói và thói quen**, không phải bằng chất giọng:
- bác Tư thật luôn mở đầu "A lô, a lô. Phòng trực thông báo." kèm **2 tiếng gõ micro**, xưng "bác", gọi "các cháu";
- giọng giả thiếu câu mở đầu hoặc tiếng gõ, gọi "sinh viên".

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/tests/audio/`

## Câu thoại (key đã có trong `strings.csv`, integrator viết)
| Key | Ai nói | Ghi chú |
|---|---|---|
| `SPK_CH1_RULES_INTRO` | Bác Tư thật | Mở đầu đọc nội quy lúc 0 giờ. Có 2 tiếng gõ micro trước câu |
| `RULE_CH1_HEADER` | Bác Tư thật | "gồm 6 điều" |
| `RULE_CH1_1` … `RULE_CH1_6` | Bác Tư thật | 6 điều nội quy thật, đọc chậm, rõ |
| `SPK_CH1_ROOF_ERRAND` | Bác Tư thật | Nhờ lên tầng 6 đóng cửa sân phơi |
| `SPK_CH1_FAKE_INSPECTION` | **Giọng giả** | Không "a lô", không gõ micro, gọi "sinh viên" |
| `SPK_CH1_ROLLCALL_INTRO` | Bác Tư thật | Mở đầu điểm danh |
| `SPK_CH1_CHECK_TAPS` | Bác Tư thật | Nhờ kiểm tra vòi nước |
| `SPK_NAME_*`, `SPK_NAME_TRUNG_AGAIN`, `SPK_AND_ONE_MORE` | Đã có | Dùng lại bản T-137 |

## Yêu cầu
1. Sinh giọng cho các key mới bằng **đúng công cụ và giọng của T-137**, để giọng thật và giọng giả **giống hệt nhau**. Bản tiếng Anh dùng giọng Việt kèm phụ đề (D-006).
2. **Tiếng gõ micro** là một clip riêng (`mic_tap`). API của `Speaker` cho phép phát "gõ 2 lần rồi đọc" hoặc "đọc thẳng" (giọng giả).
3. **Tiếng rè đặc trưng của loa** giữ như cũ cho cả hai giọng. Không làm giọng giả nghe khác: đây là quy tắc thiết kế.
4. Thời lượng từng câu có sẵn cho integrator, như `speaker_voice_bank.gd` hiện có.
5. Ghi công cụ TTS vào `CREDITS.md` (đã có từ T-137; thêm danh sách câu mới).
6. **Test:** mọi key ở bảng trên có clip `vi` (và `en` nếu pipeline có); API gõ micro chạy đúng thứ tự; thiếu clip thì rơi về phụ đề, không lỗi.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Handoff: danh sách câu, thời lượng, LUFS, cách nghe thử

## Handoff (agent điền)
