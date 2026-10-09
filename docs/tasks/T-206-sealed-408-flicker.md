# T-206 — Tầng 4: tấm bịt cửa 408 cũ nhấp nháy cạnh phòng 407
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-206-sealed-408-flicker`
- Phụ thuộc: D-074 (chủ dự án chơi thử chương 3: "bên cạnh phòng 407 có 1 cửa sáng nhấp nháy").
- **Hạn đề xuất:** 2026-10-10.

## Bối cảnh (integrator đo trên cảnh thật `chapter3.tscn`)
- `Floor4/Corridor/Sealed408` (`game/scenes/levels/floor4/corridor.tscn`, `position = Vector3(36, 1.02, 0.075)`, tấm dày 0,05 m) có mặt trước ở **z = 0,10**.
- `Floor4/Corridor/Former408Wall` (tường 4 × 3 × 0,2 m, tâm (36; 1,5; 0)) có mặt hành lang cũng ở **z = 0,10**.
- Hai mặt phẳng trùng nhau nên bị z-fighting: tấm bịt chập chờn sáng tối khi nhìn từ hành lang. Tầng 4 dùng chung ở chương 1–4.

## Việc
1. Đưa `Sealed408` ra hẳn trước mặt tường (ví dụ tâm z ≈ 0,13: mặt sau 0,105, mặt trước 0,155), không đổi x, y, kích thước, chất liệu.
2. Rà nhanh các tấm bịt, biển, khung cửa khác của tầng 4 và nhà B (tầng 2, 3) xem có mặt nào trùng mặt tường như vậy không; có thì sửa luôn, ghi vào Handoff.
3. **Test (`game/tests/levels/`):** trên `chapter3.tscn` (hoặc cảnh tầng 4), mặt trước `Sealed408` cách mặt tường `Former408Wall` ít nhất 0,01 m về phía hành lang. Nếu làm được tổng quát: không có hai mesh tầng 4 song song cùng mặt phẳng chồng lên nhau trong vùng hành lang.
4. Ảnh chụp trước/sau nhìn từ hành lang (Forward+).

## Được phép sửa
`art_source/`, `game/scenes/levels/`, `game/tests/levels/`, card này (Handoff).

## Checklist hoàn thành
- [ ] `Sealed408` không còn trùng mặt tường
- [ ] Rà các tấm khác
- [ ] Test
- [ ] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [ ] Handoff: ảnh trước/sau

## Handoff (agent điền)

## Review (integrator)
