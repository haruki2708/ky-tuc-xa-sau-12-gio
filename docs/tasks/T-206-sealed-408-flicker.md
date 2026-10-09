# T-206 — Tầng 4: tấm bịt cửa 408 cũ nhấp nháy cạnh phòng 407
- Lane: B (Môi trường và 3D) | Trạng thái: done | Agent:
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
- [x] `Sealed408` không còn trùng mặt tường
- [x] Rà các tấm khác
- [x] Test
- [x] `pwsh tools/test.ps1`, `pwsh tools/check.ps1` PASS
- [x] Handoff: ảnh trước/sau

## Handoff (agent điền)

### 2026-10-10 — Lane B / Codex, sẵn sàng review

**Đã làm:** commit `026e725` đã push lên `origin/lane-b/T-206-sealed-408-flicker` trước khi ghi Handoff này.

- `Floor4/Corridor/Sealed408`: tâm z từ **0,075 → 0,13 m**. Mặt sau **0,105**, mặt trước **0,155**; so với mặt tường z = 0,10 thì hở lần lượt **0,005 m** và **0,055 m**. Giữ nguyên x/y, kích thước, chất liệu và va chạm tường.
- Đồng bộ vị trí trong `art_source/campus/room_doors.py` và `art_source/ch1v2_props/build_room.py` để dựng mới không tái tạo lỗi. Không chạy lại generator toàn scene, tránh ghi đè các sửa tích hợp khác.
- Rà biển, tấm và khung của tầng 4 và nhà B tầng 2–3: không phát hiện thêm trường hợp như `Sealed408`. Test đo **24 biển phòng** và **16 khung cửa tầng 2–3**. Biển tầng 4 có mặt sau cách khung 0,0125 m; biển tầng 2–3 cách 0,0025 m; khung tầng 2–3 có mặt trước lệch mặt facade/lintel 0,02 m. Chi tiết phạm vi rà: [CREDITS và ghi chú hình học](../../art_source/sealed408/CREDITS.md).

**Test và cách kiểm tra:**

```text
pwsh tools/test.ps1 -Filter test_sealed_408
RESULT: 2 passed, 0 failed

pwsh tools/test.ps1
RESULT: 719 passed, 0 failed

pwsh tools/check.ps1
RESULT: check 0 error(s)
```

Test mới: `game/tests/levels/test_sealed_408.gd`, đo bounds mesh với transform thực của scene tầng 4 và nhà B. Đã chạy trước sửa để tái hiện: test tấm bịt FAIL với khoảng cách mặt trước gần 0; sau sửa cả hai test PASS. Log tổng cục bộ: `build/t206-tests.log`, `build/t206-check.log`. Chưa viết bộ dò tổng quát mọi cặp tam giác đồng phẳng toàn tầng; phạm vi tự động là các tấm/biển/khung nêu trên.

**Ảnh trước/sau Forward+:** đã render và mở xem cả bốn ảnh, cùng camera, ánh sáng gốc, 1280×720. Ảnh trước lấy scene base `f468ffa` trước khi sửa, không mô phỏng lại bằng cách thay trạng thái khi chụp ảnh sau.

| Góc nhìn | Trước | Sau |
|---|---|---|
| Chính diện từ hành lang | [front_before.png](../../art_source/sealed408/previews/front_before.png) | [front_after.png](../../art_source/sealed408/previews/front_after.png) |
| Xiên dọc hành lang | [oblique_before.png](../../art_source/sealed408/previews/oblique_before.png) | [oblique_after.png](../../art_source/sealed408/previews/oblique_after.png) |

Ảnh trước bị cắt thành mảng/tri giác bởi tường; ảnh sau hiện đủ tấm tại cả hai góc. Script chụp: `art_source/sealed408/capture.gd`; lệnh chạy lại và nguồn CC0 trong CREDITS ở trên. Bốn PNG qua Git LFS. Chưa chơi tay trọn chương 3; đã kiểm scene tầng 4 dùng chung bằng render và toàn bộ test.

**Còn dở:** không còn mục bắt buộc của T-206.

**Yêu cầu thay đổi ngoài phạm vi:** không có.

**Chặn:** không bị chặn. Các lệnh GitHub, Godot test và renderer đã chạy được với quyền ngoài sandbox.

## Review (integrator)

### 2026-10-10 — Claude (integrator, Opus): **duyệt, đã merge**
- Đúng card: `Sealed408` z 0,075 → 0,13 (mặt sau 0,105, trước mặt tường 0,10), sửa cả hai bộ dựng (`room_doors.py`, `build_room.py`) để không tái tạo lỗi; rà 24 biển phòng và 16 khung cửa tầng 2–3, không có chỗ trùng mặt khác; 2 test mới (FAIL trước khi sửa); ảnh trước/sau rõ: trước chỉ thấy một mẩu tam giác, sau thấy đủ tấm.
- **Integrator kiểm thêm trên cả 4 cảnh** `chapter1.tscn` … `chapter4.tscn` (chủ dự án thấy lỗi ở cả 4 chương): tấm bịt z 0,105…0,155, mặt tường 0,100, hiện bình thường ở cả 4.
