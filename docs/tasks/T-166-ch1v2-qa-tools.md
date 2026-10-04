# T-166 — Công cụ thử chương 1 bản 2: nhảy tới nhiệm vụ, bot 8 nhiệm vụ, đo hiệu năng camera
- Lane: C (QA và Tools) | Trạng thái: todo | Agent:
- Nhánh: `lane-c/T-166-ch1v2-qa-tools`
- Phụ thuộc: T-157. **Đọc `docs/design/CH1_V2_MISSIONS.md`** (D-039…D-042).
- **Hạn:** phần 1 và 3 hết ngày **2026-10-06**; phần 2 chạy trên bản ghép **sáng 2026-10-07**.

## Mục tiêu
Chương 1 bản 2 dài khoảng 60 phút, độ khó Insane, chết là làm lại cả vòng. Người làm và chủ dự án cần nhảy thẳng tới đoạn muốn thử. Bot phải biết làm 8 nhiệm vụ mới. 5 camera an ninh render cùng lúc có thể làm tụt FPS, cần đo.

## Được phép sửa
`tools/` (trừ `godot-path.ps1`), `game/scripts/debug/`, `game/tests/smoke/`, `game/tests/tools/`

## Yêu cầu
1. **Menu thử nhanh** (chỉ có trong bản debug và bản chơi thử, ẩn trong bản phát hành; dùng `OS.is_debug_build()` hoặc tham số dòng lệnh `-- --qa-menu`):
   - mở bằng **F9** trong chương 1;
   - **nhảy tới:** đầu mở đầu, vòng 1, mất mạng (4:28), gõ tường (4:38), giữ cửa (4:35), vòng 2, ngay trước khi quản lý tới 407, cứu Minh Nhật. Nhảy bằng cách gọi `Chapter1Director.run_from()` hoặc API nhảy mà integrator cung cấp (ghi yêu cầu vào Handoff nếu cần thêm);
   - **bật/tắt:** bất tử (không chết, chỉ ghi log lý do), hiện đáp án (mã tủ, công tắc đúng, chữ của tiếng gõ), tua nhanh x4;
   - không lưu gì vào bản lưu thật của người chơi.
2. **Bot chương 1 bản 2:**
   - thêm thao tác: gõ tường theo mã (chuỗi số → các lần `wall_tapped` đúng nhịp), bật công tắc ổ điện, cắm dây mạng theo màu, chốt cửa, lục đồ (tủ Việt, nệm, sọt rác), tắt đèn bàn, xem tab camera, nhập mã tủ qua panel;
   - kịch bản mới:
     - `ch1v2_good`: làm đủ 8 nhiệm vụ, xong chương;
     - `ch1v2_wrong_switch`: bật công tắc 3, ổ chập, vẫn sửa được;
     - `ch1v2_door_late`: không chốt cửa kịp, chết, tải lại đầu vòng 1;
     - `ch1v2_lamp_on`: để đèn bàn sáng khi quản lý vào, chết, tải lại đầu vòng 2;
     - `ch1v2_wrong_advice`: chọn sai lời khuyên cho Minh Nhật, thua.
   - Cơ chế nào chưa merge thì `SKIP` có lý do như T-157. Profile mới `tools/ch1v2-profile.json`; integrator điền ID thật khi ghép.
3. **Đo hiệu năng:**
   - phòng 407 mới (khi T-162 merge) ở các góc: cửa, giường, nhà vệ sinh, ban công;
   - **khi tab Camera đang mở** (5 camera SubViewport);
   - ghi JSON như T-157. Mục tiêu ≥ 60 FPS.
4. **Báo cáo** trong Handoff: lệnh chạy, kết quả, thời gian, chỗ kẹt.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Menu thử nhanh dùng được trên `main` hiện tại
- [ ] Bot và đo hiệu năng chạy được (SKIP có lý do cho phần chưa ghép)
- [ ] Handoff

## Handoff (agent điền)
