# T-260 — Occlusion culling: không vẽ những gì bị tường, sàn kín che (chương 1–4)
- Lane: core, **HARU làm** (chủ dự án giao 14/11/2026, D-173) | Trạng thái: **xong trên nhánh, chờ chủ dự án quyết bật** (14/11/2026) | Nhánh: `integrator/T-260-occlusion-culling` từ `origin/main` mới nhất.
- Nguồn: yêu cầu thay đổi 2 của [T-253](T-253-realistic-graphics-wave2.md) ("bật `rendering/occlusion_culling/use_occlusion_culling`, rồi thêm `OccluderInstance3D` theo sàn, tường kín; nên làm khi có số đo FPS"); số đo đã có ở [T-255-rooms-fps](../../tools/reports/T-255-rooms-fps.md), [T-237](../../tools/reports/T-237-chapter-fps.md).

## Vì sao
- Chương 3: nhìn dọc hành lang tầng 4 ra khuôn viên thì 1% khung chậm nhất 36–53 FPS (có từ trước, do khuôn viên); mở cả bảy cửa phòng tầng 4 thì vẽ tới 4,0–4,4 triệu tam giác, kể cả nội thất bị tường che.
- Godot chỉ bỏ vật **ngoài khung nhìn** (frustum) và vật **quá tầm** (`visibility_range`). Vật **nằm sau tường** vẫn được gửi đi vẽ. Occlusion culling bỏ chúng, nhưng chỉ khi có occluder đặt trong các khối kín.
- Sắp có đợt 3 (vườn hoa, T-259) và các đợt khuôn viên sau: nên có occluder trước để đo được lợi ích thật.

## Việc
1. **Đọc tài liệu Godot 4.7 về occlusion culling trước khi làm** (trang "Occlusion culling" của docs.godotengine.org, lớp `OccluderInstance3D`, `BoxOccluder3D`, `QuadOccluder3D`, `PolygonOccluder3D`, cài đặt `rendering/occlusion_culling/*`). Ghi lại điều đã kiểm (không đoán): cách bật, chi phí CPU, nút "Bake Occluders" chỉ có trong editor (dự án làm không cửa sổ, nên dùng occluder hình khối đặt bằng tay hoặc bằng script).
2. **Khảo sát khối kín** (ghi bảng trong Handoff, toạ độ thế giới): sàn giữa các tầng nhà B; tường sau các phòng tầng 4 (T-255) và vách giữa các phòng; tường hành lang phía phòng ở các tầng 1–3; tường giếng hai cầu thang; khối nhà A, giảng đường, nhà thể chất (vỏ kín); tường phòng 407. **Không đặt occluder** ở: lỗ cửa (cửa phòng, cửa nhà tắm, ban công, cửa thoát hiểm, cửa chính), cửa sổ, kính, lan can, phía hành lang hở, cánh cửa đang mở, tán cây, hàng rào, chỗ có lỗ nhìn xuyên.
3. **Bật và đặt occluder trong nhánh riêng:**
   - `game/project.godot`: `rendering/occlusion_culling/use_occlusion_culling=true` (core).
   - Occluder để trong **cảnh riêng của core**, ví dụ `game/scenes/main/occlusion/occluders_floor4.tscn` (dùng ở cả 4 chương) và `occluders_campus.tscn` (chương 3–4), gắn vào `chapter1.tscn`…`chapter4.tscn`. **Không sửa cảnh của lane B** (`game/scenes/levels/`): lane B đang làm T-258 (`building_b.tscn`) và sắp làm T-259 (`garden.tscn`, `campus.tscn`).
   - Mỗi occluder nằm **trong** khối tường/sàn, mỏng hơn khối đó, lùi khỏi mép lỗ cửa ít nhất 0,1 m.
4. **Kiểm hình (không được có vật biến mất hay nhấp nháy):** ảnh cùng camera bật/tắt occlusion culling ở chương 1 và 3, gồm: dọc hành lang tầng 4 cả hai đầu, cửa phòng tầng 4 mở và đóng, trong phòng 402, 408, ban công, cầu thang chính và thoát hiểm (mở cửa), hành lang tầng 1–3, sảnh, nhìn từ tầng 4 xuống vườn, từ vườn nhìn lên nhà B. Thêm một lượt camera **di chuyển chậm** qua cửa phòng và góc cầu thang để bắt chỗ vật hiện trễ (chụp chuỗi khung, xem các khung liền nhau).
5. **Đo FPS trước/sau** (cách đo của [T-255-rooms-fps](../../tools/reports/T-255-rooms-fps.md), script `build/integrator/t255_fps.gd`; thêm `--occlusion=on/off`): chương 1 và 3, 1080p, 11 góc của T-255 cộng các góc khuôn viên, 2 vòng. Ghi cả số tam giác, số lần vẽ, thời gian khung. Occlusion culling tốn CPU: nếu FPS **không tăng** ở góc nặng hoặc **giảm** ở góc nhẹ, ghi rõ.
6. **Báo cáo** `tools/reports/T-260-occlusion-culling.md`; ảnh `art_source/graphics_upgrade/occlusion/previews/` (ảnh ghép bật/tắt). **Chủ dự án quyết có bật trong bản chơi không** (D-xxx): nếu có lợi rõ và không lỗi hình thì đề xuất bật; nếu không thì giữ nhánh, không merge.

## Kiểm
- Test mới `game/tests/core/test_t260_occlusion.gd`: cài đặt bật; mỗi chương có cảnh occluder; **không occluder nào giao với lỗ cửa, cửa sổ, lan can, lối đi** (danh sách hộp lỗ cửa lấy từ node cửa thật: `LockedDoor_*`, `Door407`, cửa nhà tắm và ban công T-255, `FireDoor`, `MainDoor`, `Window*`, `Railing*`), không occluder nào chứa camera ở các điểm xuất phát (`seg*_start`, `Start_*`).
- Full `pwsh tools/test.ps1`, `pwsh tools/check.ps1`, `git checkout -- game/default_bus_layout.tres`.

## Lưu ý
- Lane B chạy song song (T-258, T-259): mọi lần chạy Godot theo luật Lượt Godot, nhường khoá khi lane B cần, không tắt Godot của lane B.
- Máy ít RAM: việc nền bị dừng vì thiếu RAM thì không tự chạy lại, báo chủ dự án.
- Nếu occluder cần nằm trong cảnh của lane B mới đúng chỗ, ghi "Yêu cầu thay đổi" cho lane B, không tự sửa cảnh đó.

## Checklist
- [x] Đọc tài liệu, ghi điều đã kiểm
- [x] Bảng khối kín, chỗ không đặt
- [x] Bật cài đặt, cảnh occluder, gắn vào bốn chương (nhánh riêng)
- [x] Ảnh bật/tắt, lượt camera di chuyển, không lỗi hình
- [x] Đo FPS trước/sau, báo cáo
- [x] Test mới, full test, check
- [ ] Chủ dự án quyết bật hay không

## Handoff
- **14/11/2026 15:55, lane HARU.** Nhánh `integrator/T-260-occlusion-culling` (đã đẩy, **chưa merge**). [Báo cáo](../../tools/reports/T-260-occlusion-culling.md) (điều đã kiểm trong tài liệu Godot 4.7, bảng khối kín, chỗ không đặt, ảnh, FPS).
- `project.godot` bật; `game/scenes/main/occlusion/occluders_floor4.tscn` (53 hộp, 4 chương), `occluders_campus.tscn` (106 hộp, chương 3–4); sinh bằng `art_source/graphics_upgrade/occlusion/make_occluders.py` từ khảo sát cảnh thật. Không sửa cảnh lane B.
- Ảnh tắt/bật 28 góc chương 1, 3: giống hệt từng điểm ảnh (trừ mép cánh quạt); 5 lượt camera di chuyển: không vật nào hiện trễ. Ảnh ghép `art_source/graphics_upgrade/occlusion/previews/compare_ch1.jpg`, `compare_ch3.jpg`.
- FPS 1080p (2 vòng): góc nặng nhanh hơn rõ (chương 3 sảnh 69 → 98, cả bảy cửa mở 62 → 75, trong 406 nhìn ra 82 → 118, ban công 72 → 100; góc chậm nhất chương 3 62 → 70); 3 góc nhẹ (đã > 95 FPS) chậm đi khoảng 5% (0,4–0,5 ms, chi phí CPU).
- Test `game/tests/core/test_t260_occlusion.gd` (mỗi occluder nằm trong hộp va chạm đặc, tránh cửa, cửa sổ, lan can, điểm xuất phát); full test 988/0, check 0.
- **Đề xuất bật trong bản chơi** (chủ dự án quyết, ghi D-xxx). Nếu bật: merge nhánh, build. Nếu không: giữ nhánh.
- Lượt sau (nếu muốn thêm): tường hậu nhà B (kiểm cửa sổ), giếng thang; khuôn viên còn nặng do cây, đồ nhìn từ xa (`visibility_range`).
