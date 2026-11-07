# T-235 — Hành lang tầng 4, lượt 2: cả hành lang 44 m, cửa 401…408, biển số phòng mới
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent: tài khoản Claude lane B (D-141)
- Nhánh: `lane-b/T-235-floor4-corridor-full-shell` từ `origin/main` mới nhất.
- Quyết định giao: **D-144** (chủ dự án duyệt lượt 1 ngày 08/11). Tiếp nối [T-233](T-233-floor4-corridor-segment-pilot.md) (mẫu đoạn 406–407) và `PLAN.md` mục 7 lượt 2.
- Lượt này vẫn làm **trong cảnh thử** `corridor_g5_pilot`. Chủ dự án duyệt ảnh xong, integrator mở card đưa vào bản chơi.

## Chủ dự án chọn (08/11/2026)
- "1: tôi duyệt hướng này, 2: lan can tôi chọn A1, 3: thay luôn cùng cửa ở lượt 2."
  1. **Duyệt hướng của mẫu T-233** (tường vữa kem xám, sàn gạch 40 cm, trần, máng đèn, khung cửa kiểu 407): nhân ra cả hành lang.
  2. **Lan can A1:** song đứng cách 12,5 cm. Bỏ biến thể A2 (phím R, file `segment_railing_classic.glb`) khỏi cảnh thử và test.
  3. **Biển số phòng thay cùng cửa trong lượt này** (bỏ hộp xanh PS1).

## Việc cần làm
1. **Vỏ cả hành lang** X=0…44, Z=0…4, sàn tới trần, theo đúng kỹ thuật và vật liệu đoạn mẫu (`build_segment.py`, `segment_layout.py`, shader `room407_shell.gdshader` dùng nguyên). Chia mesh theo đoạn hoặc cụm cửa, dùng chung vật liệu; atlas bẩn mở rộng cho cả hành lang (không lặp một vết bẩn giống hệt ở mọi cửa).
2. **Cửa 401…406 và 408:** khung, nẹp, ngưỡng như cửa 406 của mẫu; cánh `door_room.glb` và tay gạt `door_lever.glb` của phòng 407 (không tiêu credit Tripo), treo vào `LockedDoor_*/Hinge` có sẵn để `RoomDoor` vẫn mở được (chương 3 mở cửa 408 cho xác sống ra). Cửa 407 giữ như mẫu.
3. **Tấm bịt cửa 408 cũ ở X=36** (`Former408Wall`, `Sealed408`): T-190 giữ có chủ đích. Dựng hình bịt hợp phong cách mới (ví dụ khung cửa cũ bị xây/ốp kín), giữ node, vị trí, va chạm. Chỗ nào chưa rõ thì đưa 2–3 lựa chọn kèm ảnh.
4. **Biển số phòng mới** cho 401…408 và tấm bịt X=36 nếu đang có biển: dựng bằng Blender (biển kim loại hoặc nhựa cũ, số in hoặc dập, hợp phong cách 407), **giữ đúng số phòng và vị trí** của `RoomPlate_*` hiện có (`PLAN.md` mục 2, T-190). Số phòng là chữ số, không cần key dịch. Đưa 2 kiểu biển kèm ảnh cận nếu chưa chắc; mặc định một kiểu, ghi lý do.
5. **Máng đèn** cho cả 9 `CorridorLight_*` như mẫu (giữ node đèn, vị trí nguồn sáng, LightHum). Lan can A1 suốt 44 m.
6. **Hai đầu hành lang** X=0 và X=44 (nối cầu thang, `WestEnd`, `EastEnd`): khép vỏ gọn ở chỗ nối; không bịt lối sang cầu thang (chương 3–4 dùng Campus). Cầu thang, bàn trực, nhà vệ sinh chung chưa làm (lượt 3, 4).
7. **Ảnh để chủ dự án duyệt** (1080p, Forward+, có cửa sổ), trước/sau cùng camera, trong `previews/`:
   - góc 01, 02 (nhìn dọc hành lang từ hai đầu), 09, 10 của T-229;
   - cận một cửa 401…406 đóng và mở; cửa 408 đóng; tấm bịt X=36;
   - cận biển số; chỗ nối hai đầu hành lang;
   - ảnh ghép `compare_overview.jpg` như lượt 1.
8. **Test** trong `game/tests/levels/` (mở rộng `test_corridor_g5.gd`): mọi node hợp đồng `PLAN.md` mục 2 giữ nguyên tên, transform, va chạm; capsule đi thông dọc Z=1 và Z=3 cả 44 m, vào cửa 407; mọi `LockedDoor_*` mở/đóng theo `RoomDoor` với cánh mới; cảnh thử load được. Ghi số tam giác, vật liệu, texture của cả hành lang trong Handoff.

## Được phép sửa
- `art_source/graphics_upgrade/floor4_corridor/` (script, `previews/`, `README.md`, `CREDITS.md`).
- `game/assets/models/graphics_pilot/floor4_corridor/`, `game/assets/textures/` (texture mới của hành lang).
- `game/scenes/levels/floor4/corridor_g5_pilot.tscn`, `.gd`, `corridor_capture.gd`, `.tscn`.
- `game/rendering/` (chỉ thêm; không đổi shader 407 đang dùng trong bản chơi).
- `game/tests/levels/`.
- Card này: chỉ Checklist và Handoff.

## Không được
- Không sửa scene chơi: `floor4.tscn`, `corridor.tscn`, `duty_desk.tscn`, `washroom.tscn`, `floor4.gd`, `door407.gd`, phòng 407, campus.
- Không tiêu credit Tripo, không tải asset chưa rõ giấy phép (chỉ CC0, CC-BY).
- Không đo FPS, không chạy bot. Integrator sẽ xin chủ dự án đo FPS trước khi đưa vào bản chơi.
- Không thêm máu, chữ, ký hiệu truyện. Không đổi số phòng, vị trí cửa, bố trí 408 (T-190).

## Checklist hoàn thành
- [ ] Script Blender tái tạo được cả hành lang; GLB mỗi file ≤ 10 MB, qua LFS, có `.import`
- [ ] Cửa 401…406, 408 dùng cánh Tripo 407, mở/đóng theo `RoomDoor`
- [ ] Biển số mới đúng số, đúng vị trí; tấm bịt X=36 hợp phong cách
- [ ] Lan can A1 suốt 44 m; bỏ biến thể A2
- [ ] Ảnh `after_*`, `compare_*`, `compare_overview.jpg` đủ các góc mục 7
- [ ] Test node hợp đồng, capsule, cửa đạt
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot)
- [ ] Handoff trung thực, có commit hash, số tam giác/vật liệu/texture

## Cách kiểm tra
- Chạy cảnh chụp có cửa sổ, Forward+ (không `--headless`). Chạy test/check dài bằng tiến trình riêng ghi log (như lượt 1) để khỏi bị dừng khi máy thiếu RAM.
- Integrator xem ảnh, đưa chủ dự án duyệt.

## Handoff (agent điền)
- Phiên YYYY-MM-DD: đã làm / còn dở / cách kiểm tra / yêu cầu thay đổi / Blocked
