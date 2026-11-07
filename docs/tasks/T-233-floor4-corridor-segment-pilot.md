# T-233 — Hành lang tầng 4, lượt 1: mẫu đoạn 406–407 dựng bằng Blender theo phong cách phòng 407
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent: tài khoản Claude lane B (D-141)
- Nhánh: `lane-b/T-233-floor4-corridor-segment-pilot` từ `origin/main` mới nhất.
- Quyết định giao: **D-142** (chủ dự án chọn 07/11). Tiếp nối [T-229](T-229-floor4-corridor-survey.md): khảo sát, ảnh hiện trạng và kế hoạch 4 lượt ở `art_source/graphics_upgrade/floor4_corridor/PLAN.md`.
- Lượt này làm **mẫu trong cảnh thử riêng**. Không thay scene chơi được. Chủ dự án duyệt ảnh xong mới nhân rộng (lượt 2).

## Chủ dự án chọn (07/11/2026)
- "Hành lang tầng 4 thì thiết kế trong **Blender** sao cho **giống kiểu đồ họa trong phòng 407**, làm xong **kèm ảnh** để tôi duyệt."
- **Phương án A cả 4 mục** của `PLAN.md` mục 4:
  1. **Tường:** kem xám, bẩn nhẹ theo chân tường và quanh chỗ tay chạm, nối bảng màu vỏ phòng 407. Không tự thêm máu hay ký hiệu truyện.
  2. **Cửa phòng:** dùng lại mẫu cửa Tripo phòng 407 (`game/assets/models/graphics_pilot/room407_shell/doors/door_room.glb`, tay gạt `door_lever.glb`), giữ bản lề và khẩu độ từng cửa.
  3. **Mặt ngoài:** giữ hành lang mở, lan can dựng bằng Blender. Không thêm cửa sổ, kính.
  4. **Đồ trang trí:** giữ đúng đồ đang có (bảng tin, loa, đồ phơi, dép, xô). Lượt này chưa thay đồ.

## Việc cần làm
1. **Đoạn mẫu:** hành lang quanh cửa 406 (X=28) và 407 (X=32), khoảng X=26…34 trên toàn bề ngang Z=0…4, sàn tới trần:
   - tường phía phòng và nẹp chân tường, khung cửa, ngưỡng cửa;
   - sàn gạch có ron, trần, máng đèn tuýp (giữ nguyên node đèn và vị trí nguồn sáng);
   - lan can và thanh đứng phía ngoài;
   - cửa 406 dùng mẫu cửa Tripo 407, gắn đúng `Hinge`/`Leaf` hiện có (chiều mở cửa phòng khác cửa 407: xem `PLAN.md` mục 5).
2. **Cách dựng:** script Blender tái tạo được, đặt trong `art_source/graphics_upgrade/floor4_corridor/` (ví dụ `build_segment.py`), theo kỹ thuật vỏ phòng 407 (`art_source/graphics_upgrade/room407_shell/README.md`): UV theo mét, bản đồ bẩn, shader `game/rendering/room407_shell.gdshader` (bản tối ưu D-132), texture CC0 đã có trong `room407_shell/texture_sources.json`, `room407_corner/texture_sources.json`. Atlas bẩn riêng cho hành lang, không dùng lại atlas định vị giường và nhà tắm của 407.
3. **Cảnh thử:** `game/scenes/levels/floor4/corridor_g5_pilot.tscn` + `.gd`. Instance `floor4.tscn` nguyên vẹn, trong cảnh thử ẩn hình PS1 của đoạn mẫu và đặt hình mới vào. **Không sửa `floor4.tscn`, `corridor.tscn`** và các scene chơi khác.
4. **Giữ hợp đồng gameplay:** mọi node trong bảng "không được đổi tên hoặc dời" (`PLAN.md` mục 2) giữ nguyên tên, transform, khối va chạm. Hình mới nằm đúng trong khối va chạm cũ; không thêm vật cản trên lối đi (capsule 0,3 m, `test_wide_corridors`).
5. **Ảnh để chủ dự án duyệt** (1080p, Forward+, có cửa sổ), cùng góc với ảnh hiện trạng T-229 để so:
   - góc 03 và 04 (trước cửa 407: đêm và đèn pin);
   - góc 01 (đầu tây nhìn dọc hành lang), để thấy đoạn mẫu nằm giữa phần PS1;
   - cận mép cửa 406, cận lan can, cận chân tường;
   - mỗi góc một ảnh `after_*.jpg` và một ảnh ghép trước/sau `compare_*.jpg` trong `art_source/graphics_upgrade/floor4_corridor/previews/`.
   Mở rộng `corridor_capture.gd` (thêm chế độ cảnh thử) hoặc viết cảnh chụp mới, theo mẫu `room407_g3_capture.gd`.
6. **Test** trong `game/tests/levels/`: cảnh thử load được; mọi node hợp đồng trong `PLAN.md` mục 2 còn đủ, đúng transform; lối đi capsule vẫn thông.

## Được phép sửa
- `art_source/graphics_upgrade/floor4_corridor/` (script, `.blend` nếu cần, `previews/`, `README.md`, `CREDITS.md`).
- `game/assets/models/graphics_pilot/floor4_corridor/` (mới), `game/assets/textures/` (texture mới của hành lang).
- `game/scenes/levels/floor4/corridor_g5_pilot.tscn`, `.gd` (mới), `corridor_capture.gd`, `.tscn`.
- `game/rendering/` (chỉ thêm; không đổi shader 407 đang dùng trong bản chơi).
- `game/tests/levels/` (test mới).
- Card này: chỉ Checklist và Handoff.

## Không được
- Không sửa scene chơi được: `floor4.tscn`, `corridor.tscn`, `duty_desk.tscn`, `washroom.tscn`, `floor4.gd`, `door407.gd`, phòng 407, campus.
- Không tiêu credit Tripo (lượt này dùng lại cửa 407). Không tải asset chưa rõ giấy phép (chỉ CC0, CC-BY).
- Không đo FPS, không chạy bot. Ghi số tam giác, số vật liệu, kích thước texture của đoạn mẫu để lượt sau ước tính.
- Không tự quyết thêm về hình dáng ngoài phương án A: chỗ nào phương án A chưa nói rõ thì đưa 2–3 lựa chọn kèm ảnh trong Handoff.

## Checklist hoàn thành
- [ ] Script Blender tái tạo được đoạn mẫu; GLB mỗi file ≤ 10 MB, qua LFS, có `.import`
- [ ] Cảnh thử `corridor_g5_pilot` có đoạn mẫu 406–407, phần còn lại giữ PS1
- [ ] Ảnh `after_*` và `compare_*` 1080p đủ các góc mục 5
- [ ] Node hợp đồng giữ nguyên, có test; lối đi thông
- [ ] `CREDITS.md` ghi nguồn texture, mẫu cửa Tripo (D-084)
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot)
- [ ] Handoff trung thực, có commit hash, số tam giác/vật liệu/texture

## Cách kiểm tra
- Chạy cảnh chụp có cửa sổ, Forward+ (không `--headless`).
- Integrator xem ảnh, đưa chủ dự án duyệt. Duyệt xong mở lượt 2 (nhân rộng cả hành lang, cửa 401…408) theo `PLAN.md` mục 7.

## Handoff (agent điền)
- Phiên YYYY-MM-DD: đã làm / còn dở / cách kiểm tra / yêu cầu thay đổi / Blocked
