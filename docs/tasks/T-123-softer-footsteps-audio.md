# T-123 — Âm bước chân dép lê nhẹ và tự nhiên hơn
- Lane: E (Âm thanh) | Trạng thái: done | Agent: Claude (integrator, làm thay theo yêu cầu chủ dự án)
- Nhánh: `lane-e/T-123-softer-footsteps`
- Phụ thuộc: T-114 (done). Làm song song với T-122 của lane A (nhịp bước). **Integrator merge T-123 trước T-122.**

## Mục tiêu
Chủ dự án nghe trong hành lang chính và nhận xét: tiếng bước chân **"khá to, kiểu robot"**, muốn **"nhẹ nhàng như con người hơn"**, cả lúc đi lẫn lúc chạy. Các âm khác giữ nguyên, đã được duyệt.

Phần nhịp bước (bước thưa hơn, không đều tăm tắp) do lane A làm ở T-122. Task này chỉ lo **chất âm, độ to và giao diện hàm**.

## Được phép sửa
`audio_source/`, `game/audio/`, `game/scripts/audio/`, `game/tests/audio/`

## Yêu cầu
1. **Làm lại 4 âm đi bộ `slipper_tile_01…04`** trong `process.py`:
   - Nghe như dép tổ ong hoặc dép lào trên gạch men, bước nhẹ: một tiếng "lẹp" mềm khi chạm gót, rồi tiếng "xẹp" nhẹ của đế dép đập vào gót chân khi nhấc lên.
   - Bỏ tiếng "bộp" trầm gắt và cú bùng nhiễu ở đầu âm của bản hiện tại. Không có tiếng click cứng.
   - Ngắn, khoảng 0,25–0,4 giây. Mỗi biến thể khác nhau rõ về thời điểm và độ mạnh giữa "lẹp" và "xẹp".
   - Chuẩn hóa khoảng **−26 LUFS**, nhỏ hơn rõ rệt so với tiếng cửa (−18 LUFS).
2. **Thêm 4 âm chạy `slipper_run_01…04`:** cùng chất liệu nhưng bước dồn hơn, tiếng "xẹp" mạnh hơn, khoảng **−22 LUFS**. Vẫn là người chạy nhẹ trong ký túc xá ban đêm, không phải chạy rầm rầm.
3. **`FootstepPlayer`:**
   - Đổi hàm thành `play_footstep(surface: StringName, intensity: float = 0.5)`. **Phải giữ tham số mặc định** để code đang gọi một tham số vẫn chạy.
   - `intensity` từ 0 đến 1: 0 là đi chậm, khoảng 0,6 là đi bình thường, 1 là chạy hết tốc.
   - `intensity >= 0.8` thì dùng bank chạy, dưới mức đó dùng bank đi. Âm lượng tăng nhẹ theo `intensity`, khoảng ±3 dB quanh mức chuẩn của bank.
   - Giữ quy tắc không lặp lại biến thể vừa phát, áp dụng cho từng bank.
   - Biến thiên ngẫu nhiên: cao độ ±4%, âm lượng ±1,5 dB.
4. **Mức chuẩn:** trong `main.tscn` integrator đang tạm giảm `Footsteps.volume_db = -8`. Sau khi merge task này và T-122, integrator sẽ đặt lại về 0. Hãy chọn độ to sao cho ở `volume_db = 0`, tiếng bước đi bộ nghe nhẹ, nằm dưới tiếng ù đèn và tiếng côn trùng khi đứng gần chúng.
5. **Giữ nguyên các âm đã duyệt** (quạt, đèn, côn trùng, nước, cửa, flicker): báo cáo phải cho thấy hash không đổi, như ở T-114.
6. **Test `game/tests/audio/`:**
   - Gọi `play_footstep(&"tile")` với một tham số vẫn chạy.
   - `intensity` thấp chọn bank đi, cao chọn bank chạy. Mỗi bank không lặp biến thể liên tiếp và dùng đủ 4 biến thể.
   - Âm lượng khi `intensity = 1` lớn hơn khi `intensity = 0`.
   - Độ to của bank đi thấp hơn bank chạy (đọc từ `build_report.json`).

## Checklist hoàn thành
- [x] Chạy lại `process.py --regenerate-raw` ra file giống nhau; tổng audio dưới 15 MB
- [x] Các âm đã duyệt không đổi hash
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Không chạm file ngoài phạm vi; `CREDITS.md` cập nhật
- [x] Mục Handoff đã điền, ghi rõ phần nào **chưa nghe bằng tai**

## Cách kiểm tra
```
py -3 audio_source/process.py --regenerate-raw
pwsh tools/test.ps1 -Filter audio
```
Nghe thử: `res://audio/test/zones_test.tscn` (F6), đi bộ rồi giữ Shift để chạy.

## Handoff (agent điền)

### Phiên 2026-10-02 — Claude (integrator làm thay lane E)
**Đã làm**
- `process.py`: thêm `synthesize_slipper()` thay cho công thức cũ. Mỗi bước gồm tiếng "lẹp" gót chạm sàn (noise lọc thấp, attack 4 ms, thân 170–230 Hz rất nhẹ), tiếng "xẹp" đế dép đập lại gót (noise dải 1,2–4,5 kHz, có rung kép) và ma sát nhẹ ở giữa. Đi bộ: "xẹp" sau 0,13–0,19 s, nhẹ hơn. Chạy: sau 0,075–0,105 s, mạnh hơn.
- Bước chân **không qua compressor** (compressor làm phẳng hai nhịp). Độ to riêng: đi bộ **−26 LUFS**, chạy **−23 LUFS**. Chạy không đạt −22 như card đề xuất vì âm ngắn, đỉnh nhọn, vướng giới hạn −2 dBTP; −23 vẫn hơn đi bộ 3 LU.
- Thêm 4 âm `slipper_run_01…04`. Làm lại `slipper_tile_01…04` (seed mới 12301–12304).
- `FootstepPlayer.play_footstep(surface, intensity = 0.5)`: dưới 0,8 dùng bank đi, từ 0,8 dùng bank chạy. Âm lượng −3…+3 dB theo intensity; mỗi bank nhớ biến thể vừa phát riêng.

**Kiểm tra**
- `py -3 audio_source/process.py --regenerate-raw`: `AUDIO RESULT: 17 assets validated; raw + OGG = 6325740 bytes`. Chạy lại lần hai: `build_report.json` giống hệt.
- So với report trước task: **9/9 âm đã duyệt giữ nguyên hash** (quạt, hum, flicker, côn trùng, 3 giọt nước, 2 cửa).
- `pwsh tools/test.ps1`: `RESULT: 65 passed, 0 failed`. `pwsh tools/check.ps1`: `RESULT: check 0 error(s)`.
- Đã xem dạng sóng: hai nhịp "lẹp"/"xẹp" rõ, bản chạy sát và mạnh hơn.
- **Chưa nghe bằng tai** (Claude không nghe được). Chờ chủ dự án nghe trong hành lang chính.

**Yêu cầu thay đổi ngoài phạm vi:** integrator đặt lại `Footsteps.volume_db = 0` trong `main.tscn` sau khi merge (làm ngay trong cùng đợt).

### Phiên 2026-10-02 (lần 2) — Claude
- Chủ dự án nghe bản đầu: "ổn rồi, cả bước chân lẫn chạy", nhưng muốn **nhỏ và nhẹ nhàng hơn nữa**.
- Giảm độ to: đi bộ **−30 LUFS**, chạy **−27 LUFS** (−4 dB so với lần 1). Làm mềm: attack gót 4 → 7 ms, lọc thấp gót 1,8 → 1,4 kHz (chạy 2,4 → 1,9 kHz), dải "xẹp" 4,5 → 3,5 kHz, "xẹp" nhẹ hơn khoảng 30%.
- `process.py --regenerate-raw`: `AUDIO RESULT: 17 assets validated`. 9/9 âm đã duyệt giữ nguyên hash.

### Phiên 2026-10-02 (lần 3) — Claude
- Chủ dự án muốn nhỏ hơn nữa. Giảm thêm 4 dB: đi bộ **−34 LUFS**, chạy **−31 LUFS**; chất âm giữ nguyên. 9/9 âm đã duyệt giữ nguyên hash.
