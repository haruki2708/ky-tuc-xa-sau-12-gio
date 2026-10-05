# T-173 — Chương 2: bot, menu nhảy tới đoạn, đo hiệu năng hơi nước
- Lane: C (QA và Tools) | Trạng thái: todo | Agent:
- Nhánh: `lane-c/T-173-ch2-qa`
- Phụ thuộc: T-166. **Đọc `docs/design/CH2_DESIGN.md`** (D-046).
- **Hạn:** phần khung hết ngày 2026-10-07; chạy trên bản ghép ngày 2026-10-08.

## Mục tiêu
Kiểm thử chương 2 tự động như chương 1 bản 2 (T-166).

## Được phép sửa
`tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`

## Yêu cầu
1. **Bot chương 2** (`-Chapter 2`, profile `tools/ch2-profile.json`, integrator điền ID thật khi ghép). Thao tác mới:
   - trả lời nối từ: chọn phương án theo luật (tiếng đầu khớp đúng dấu, không lặp trong 3 lượt), chọn từ cụt để gài bẫy, chọn theo vòng lặp;
   - cầm đồ, bịt miệng xác, đẩy cửa, đứng trong / ra khỏi buồng tắm, lau màn hình, chọn Có/Không theo quy luật nhiệt độ.
2. **Kịch bản:**
   - `ch2_good`: hết chương;
   - `ch2_chain_timeout`: để hết 15 giây, chết, tải lại đầu vòng 3;
   - `ch2_chain_wrong`: chọn từ sai dấu, chết;
   - `ch2_scald`: chọn Có ở lượt 81 độ, chết bỏng, tải lại đầu vòng 4;
   - `ch2_leave_shower`: chọn Có rồi bước ra, chết;
   - `ch2_lost_ngu`: trả lời sai cho Ngư, thua.
   Cơ chế nào chưa ghép thì `SKIP` có lý do như T-166.
3. **Menu F9:** nhảy tới đầu vòng 3, đầu vòng 4, và các mốc giữa vòng mà core cung cấp; hiện đáp án (từ đúng, Có/Không đúng theo quy luật).
4. **Đo hiệu năng:** nhà vệ sinh với hơi nước 0 và 1, nước nóng đang chảy; mục tiêu ≥ 60 FPS. JSON như T-166.
5. **Báo cáo** trong Handoff: lệnh chạy, kết quả, thời gian.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Bot và đo hiệu năng chạy được (SKIP có lý do cho phần chưa ghép)
- [ ] Handoff

## Handoff (agent điền)
