# T-163 — Chương 1 bản 2: mất kết nối, sơ đồ tòa nhà, khóa số giới hạn lần thử
- Lane: D (UI và Đa ngôn ngữ) | Trạng thái: todo | Agent:
- Nhánh: `lane-d/T-163-ch1v2-phone-map-lock`
- Phụ thuộc: T-155, T-156. **Đọc kỹ `docs/design/CH1_V2_MISSIONS.md`** (D-039), đặc biệt N1, N2, N8.
- **Hạn: hết ngày 2026-10-06.**

## Được phép sửa
`game/ui/`, `game/scripts/ui/`, `game/tests/ui/`, thêm key vào `strings.csv`.

## Hợp đồng có sẵn (core, không sửa)
`EventBus.phone_call_lost(call_id)`, `phone_call_restored(call_id)`; `PuzzleData.max_attempts`, `lockout_seconds`.

## Yêu cầu
1. **Mất kết nối** (màn hình điện thoại T-155):
   - khi `phone_call_lost`: màn cuộc gọi hiện "Mất kết nối mạng nội bộ…", danh sách thành viên mờ, biểu tượng mạng gạch chéo;
   - **các câu thoại `spoken` đến trong lúc mất kết nối không vào bản chép lời và không hiện phụ đề**;
   - khi `phone_call_restored`: trở lại bình thường, thêm một dòng hệ thống "Đã kết nối lại";
   - lưu và khôi phục trạng thái này trong `snapshot()/restore()`.
2. **Tab Sơ đồ** trên điện thoại:
   - lưới 6 tầng × 8 phòng nhà B (tầng 1 phòng 101–108 … tầng 6 phòng 601–608); phòng 407 đánh dấu "Phòng mình";
   - người chơi bấm vào một phòng để đánh dấu hoặc bỏ đánh dấu (một kiểu dấu, ví dụ chữ X đỏ); không tự hiện vị trí quản lý;
   - chuyển tab bằng phím rõ ràng, không đụng phím di chuyển hay 1–4 khi đang có lựa chọn (ví dụ Tab trái/phải trên điện thoại, hoặc lăn chuột ở thanh tab, ghi rõ trong Handoff);
   - dấu đánh lưu trong snapshot.
3. **Panel khóa số** (T-156):
   - tôn trọng `max_attempts`: sai đủ số lần thì khóa **kẹt** `lockout_seconds` giây: không nhận nhập, hiện đồng hồ đếm ngược, phát âm báo động (clip của lane E nếu có, không thì dùng âm hiện có);
   - phát `EventBus.noise_emitted(vị trí người chơi, 12.0, &"alarm")` một lần khi kẹt;
   - số lần sai lưu trong `GameState` (cờ `puzzle_attempts_<id>`) để tải lại checkpoint vẫn giữ;
   - `hint_document` rỗng thì không có nút gợi ý (đã có).
4. **Test:** mất/nối lại kết nối và câu bị bỏ lỡ; snapshot; sơ đồ đánh dấu và lưu; khóa kẹt sau 3 lần sai, đếm ngược, mở lại.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ảnh chụp: mất kết nối, sơ đồ, khóa kẹt (vi và en)
- [ ] Handoff

## Handoff (agent điền)
