# T-200 — Giọng chương 4 theo lời đã duyệt; cuộc gọi chương 2–4 có tiếng
- Lane: E (Âm thanh) | Trạng thái: todo | Agent:
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
- [ ] 16 giọng chương 4 đúng lời đã duyệt, đặt tên theo key trong `game/audio/voice/vi/`
- [ ] Bản nháp cũ `ch4_voice/` đã xử lý (bỏ hoặc thay), ghi lý do
- [ ] Cuộc gọi chương 2–4 có tiếng; chương 1 không đổi
- [ ] Test trên cảnh thật chương 2, 3, 4
- [ ] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [ ] Handoff: bảng giọng và âm lượng, **nhờ chủ dự án nghe**

## Handoff (agent điền)

## Review (integrator)
