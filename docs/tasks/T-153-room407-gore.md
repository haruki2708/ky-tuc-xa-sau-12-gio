# T-153 — Phòng 407 chi tiết, máu me, giường bị chém
- Lane: B (Môi trường và 3D) | Trạng thái: done | Agent:
- Nhánh: `lane-b/T-153-room407-gore`
- Phụ thuộc: T-112, T-121, T-138. Đọc `docs/design/STORY.md` v2 §0 (nội dung nhạy cảm), §5, và bảng số giường trong `docs/tasks/T-150-chapter1-core.md`.
- **Hạn: hết ngày 2026-10-05.** Xong thì làm T-154 ngay.

## Mục tiêu
Người chơi ở **trong phòng 407 gần như suốt 50 phút** của chương 1, nên căn phòng phải đẹp, chi tiết và kể được chuyện của ba bạn cùng phòng qua đồ đạc. Chủ dự án muốn đồ họa cải thiện nhiều; ảnh tham khảo sẽ gửi sau. Trong lúc chờ, giữ phong cách PS1 nhưng nâng chất lượng: texture đẹp hơn trong giới hạn 64–256 px, nhiều đồ hơn, ánh sáng có không khí.

Tầng 5, 6 và nhà A đối diện để sang chương 3.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/`

## Yêu cầu
1. **Đồ của từng người** (đặt trong `room_407.tscn`; có anchor để lane A gắn đồ đọc được):
   - **Phúc** (giường 1): sách giáo trình, tai nghe, poster bóng đá, mì gói.
   - **Việt** (giường 2): laptop cũ, đàn guitar, khung ảnh gia đình.
   - **Trung** (giường 3): balo, bàn học có đèn bàn, ổ cắm và dây sạc **không có cục sạc**.
   - **Đạt** (giường 4): **tủ sắt khóa số** (anchor `DatLocker`, có `set_unlocked(bool)`), thẻ sinh viên hoặc sổ tay trên bàn (anchor `DatNote`, cho manh mối mã khóa), giày thể thao.
   - **Chung:** quần áo phơi trong phòng, xô chậu, dép (4 đôi khác màu: Phúc đỏ, Việt xanh dương, Trung xanh lá, Đạt đen), **cục phát wifi nhỏ** trên tường (anchor `Router`), quạt trần (đã có).
2. **Giường và xác:**
   - 4 giường dùng được với `bunk_spot` của lane A: anchor `Anchors/Bunks/Bunk1..4`, mỗi anchor có node con `View` (camera khi nằm) và `Exit`.
   - Giường 1, 2, 4 có **chỗ đặt xác** (anchor `Corpse1`, `Corpse2`, `Corpse4`; mô hình xác làm ở T-154).
   - **Trạng thái máu** có API `set_blood_stage(stage)`:
     - 0: sạch (đầu mở đầu);
     - 1: máu thấm chăn, nhỏ giọt xuống sàn (sau khi bạn chết);
     - 2: vũng máu.
     - Dùng decal hoặc mesh phẳng, texture thấp.
   - **Giường của Trung bị chém** (`set_slashed(amount 0..1)`): nệm và chăn rách dần theo từng nhát (T-152 phát `slashed` mỗi nhát), cuối cùng nát hẳn, có mảnh vụn.
3. **Cửa phòng và ngưỡng cửa:**
   - cửa 407 giữ API cũ;
   - thêm Area3D `Threshold` ngay ngoài cửa phía hành lang để integrator làm luật "rời phòng là chết";
   - khe sáng dưới cửa (thấy bóng người đi qua bên ngoài: node `UnderDoorShadow` với `set_visible`).
4. **Ánh sáng 4 giờ sáng:** đèn chính tắt; đèn bàn, ánh xanh từ cửa sổ, ánh sáng hành lang qua khe cửa. Có API `set_flicker(bool)` cho đèn chính và đèn bàn.
5. **Tường chung với 406 và 408:** người chơi gõ tường được (anchor `WallKnock406`, `WallKnock408`, cho lane A/integrator gắn tương tác).
6. **Nhà vệ sinh chung tầng 4** (đã có): thêm vài chi tiết cho đoạn mở đầu (người chơi đi vệ sinh lúc 4 giờ).
7. **Hiệu năng:** ≥ 60 FPS khi đứng trong phòng; đo như T-112.
8. **Test và preview:**
   - test: đủ anchor; các API máu, chém, nhấp nháy chạy đúng; mọi sàn có `surface`;
   - ảnh preview: phòng sạch, phòng sau khi bạn chết, giường bị chém.
9. **Nội dung máu me:** hiển thị theo kiểu PS1 (texture thấp, màu đỏ sẫm), không làm chi tiết giải phẫu. "Giảm hù dọa" không cần xử lý ở lane B; integrator có thể gọi `set_blood_stage(0)`.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] Ảnh preview, số đo FPS
- [x] `CREDITS.md` đủ nguồn
- [x] Handoff: tên anchor và API

## Bổ sung từ integrator (2026-10-04, sau khi viết luồng chương)
- Đặt `set_blood_stage(stage)` và `set_slashed(amount)` **trên node gốc `Room407`** (script của `room_407.tscn`). Luồng chương gọi `Floor4/Room407.set_blood_stage(...)`.
- `set_unlocked(bool)` đặt trên node `Room407/Locker_Dat` (tủ có sẵn trong phòng).

## Handoff (agent điền)

### Đã làm — Lane B, 2026-10-04

- Commit triển khai `a8c7ca0`, đã push `lane-b/T-153-room407-gore`; bản gốc `origin/main` tại `37bdfa7`. Chỉ sửa vùng Lane B và checklist/Handoff card này.
- Bổ sung 14 GLB (13 đạo cụ cá nhân + biến thể giường Trung), 10 texture thủ tục 128 px, sàn/tường, áo phơi, xô/khăn, bốn đôi dép đúng màu và chi tiết nhà vệ sinh. Giữ phong cách PS1; máu đỏ sẫm, không chi tiết giải phẫu. Không có cục sạc.
- Thêm ánh sáng 4 giờ, khe sáng/bóng dưới cửa, ngưỡng cửa, anchor giường và đồ cá nhân; ba mức máu có giọt động; nệm/chăn Trung hỏng tám phần và vụn rơi, có thể khôi phục. Giữ API cửa hiện có.
- Source dựng lại, quy ước tọa độ, F6 và API đầy đủ: [README](../../art_source/room407/README.md). Nguồn và khai báo AI: [CREDITS](../../art_source/CREDITS.md). Nhị phân đã đi qua Git LFS; không thêm plugin hoặc cài công cụ.

### Anchor và API để tích hợp

Scene phòng vẫn là `res://scenes/levels/floor4/room_407.tscn`, instance `Floor4/Room407`.

| Đường dẫn dưới `Room407/Anchors` | Công dụng |
|---|---|
| `Bunks/Bunk1`, `Bunks/Bunk2`, `Bunks/Bunk3`, `Bunks/Bunk4` | Phúc A trên, Việt A dưới, Trung B dưới, Đạt B trên; mỗi node có `View` và `Exit` |
| `Corpse1`, `Corpse2`, `Corpse4` | Tâm mặt nệm, đầu hướng +Z; chờ model nằm T-154, không có Corpse3 |
| `PhucBooks`, `PhucPoster`, `VietLaptop`, `VietPhoto` | Gắn tương tác/đồ đọc được |
| `TrungChargingCable`, `DatLocker`, `DatNote`, `Router` | Dây sạc, khóa, sổ tay và router |
| `WallKnock406`, `WallKnock408` | Gắn tương tác gõ hai tường |

- `Room407.set_blood_stage(int)`: 0 sạch, 1 thấm chăn/giọt/vết nhỏ, 2 thêm vũng; clamp 0..2, gọi 0 xóa toàn bộ hình ảnh máu. Giọt dừng khi pause.
- `Room407.set_slashed(float)`: clamp 0..1, mỗi 1/8 phá thêm một phần; 1 lộ vạt giường và vụn, 0 khôi phục. NaN/INF về 0.
- `Room407.set_flicker(bool)` hoặc gọi riêng `Room407MainLight` / `Room407DeskLamp`: nhấp nháy và khôi phục energy/visible khi tắt. Đèn chính mặc định **energy=0, visible=true** để tương thích node/công tắc cũ; muốn bật sáng ổn định phải đặt energy > 0.
- `Room407/Anchors/DatLocker.set_unlocked(bool)`: nâng/xoay móc khóa; reset bằng false. Chưa tự mở cánh tủ hoặc phát tín hiệu giải đố. Ba bánh khóa là hình học trang trí, không quy định độ dài mã.
- `Floor4/Threshold`: Area3D ngay ngoài cửa, vị trí `(32,1,0.30)`, box `(0.90,2,0.36)`, layer=0/mask=2; chỉ phát tín hiệu vật lý, không tự áp luật.
- `Floor4/DoorGap/UnderDoorShadow.set_visible(bool)`: mặc định false; cả khe sáng/bóng ẩn khi cửa mở, giữ trạng thái yêu cầu khi đóng lại.
- `View` nằm trên mặt nệm 0,43 m để tránh capsule cũ; Exit của hai giường A/B lần lượt `(1.5,0.03,-2.3)` / `(2.5,0.03,-2.3)` trong phòng, đã kiểm tra capsule người chơi r=0,3 m, cao 1,75 m không mắc collision.

### Kiểm tra và preview

Đã chạy trên Godot 4.7.2, exit code 0:

```text
pwsh tools/test.ps1 -Filter room407
RESULT: 6 passed, 0 failed
pwsh tools/test.ps1
RESULT: 264 passed, 0 failed
pwsh tools/check.ps1
RESULT: check 0 error(s)
ROOM407_CAPTURE_RESULT: PASS 5 views
```

Sáu test mới kiểm tra anchor/màu dép/lối thoát, trạng thái máu và giọt chuyển động, chém và khôi phục, flicker/khóa, Threshold bằng va chạm thật/khe cửa/surface, giới hạn model/texture/PS1. `git diff --check` sạch. Các cảnh báo fixture dữ liệu sai/công tắc chưa gán trong suite hiện có không làm test fail.

| Preview | FPS trung bình | p95 frame (ms) |
|---|---:|---:|
| [Phòng sạch](../../art_source/room407/previews/room_clean.png) | 430,59 | 2,403 |
| [Máu sau khi bạn chết](../../art_source/room407/previews/room_blood.png) | 429,53 | 2,385 |
| [Giường bị chém](../../art_source/room407/previews/bed_slashed.png) | 495,16 | 2,075 |
| [Bàn học](../../art_source/room407/previews/desk_details.png) | 537,53 | 1,902 |
| [Đồ cá nhân](../../art_source/room407/previews/personal_items.png) | 449,33 | 2,703 |

[Số đo gốc](../../art_source/room407/previews/performance.json): Ryzen 5 5600H, RTX 3050 Laptop, Forward+ Vulkan, 1280×720, PS1 strength=1, VSync tắt, không fixed-fps. Mỗi góc 90 frame warm-up + 240 frame đo bằng đồng hồ thực; toàn tầng, Player physics/HUD/âm thanh hoạt động, camera đứng yên. Tất cả vượt 60 FPS trên máy này; không suy rộng sang máy khác hoặc toàn chương.

F6 `res://scenes/levels/room407/room407_test.tscn`: WASD/chuột/E/Esc; 1 reset, 2 máu thấm, 3 vũng, 4 chém 50%, 5 chém hết, 6 flicker, 7 bóng dưới cửa. Đã render/kiểm tra ảnh và chạy tự động; **chưa chơi thử thủ công hoặc thử chuỗi 50 phút với logic chương 1**. Capsule `Sleeper_*` vẫn chờ mô hình xác T-154. Không có checklist T-153 còn thiếu.

### Yêu cầu thay đổi (ngoài phạm vi, chưa tự sửa)

1. Lane A/integrator gắn `bunk_spot` vào bốn anchor với `bed_number`/`view`/`exit`; ghép xác T-154 vào Corpse1/2/4 và bỏ capsule cũ. Nối sự kiện chết/chém T-152 vào `set_blood_stage`/`set_slashed`, ánh sáng/bóng vào diễn biến chương; nối gõ tường, router, DatLocker/DatNote. Threshold chỉ áp luật ở giai đoạn thiết kế cho phép. Khôi phục các API khi tải checkpoint; chế độ giảm máu dùng `set_blood_stage(0)`.
2. Core/Lane D điền nội dung đã duyệt cho sổ tay/manh mối/mã khóa và localization; Lane B để trống, không tự đặt lời giải. Câu hỏi chuyển người phụ trách nội dung: nội dung chính thức hiển thị trên DatNote và mã khóa là gì?
3. Integrator thay luồng StoryDirector demo bằng chương 1 khi ghép. Bốn đôi dép ngoài hành lang giữ node path nhưng đã ẩn; bốn đôi mới nằm trong phòng và có đúng màu chủ nhân.
4. Core/Lane C thêm `scenes/levels/room407/room407_test*` và `assets/models/room407/room407_import.gd` vào bộ lọc loại trừ export theo quy ước cảnh QA/import script hiện có. Không sửa `export_presets.cfg` trong nhánh Lane B.

### Còn lại / bị chặn

Không bị chặn trong T-153. Ảnh tham khảo của chủ dự án chưa có; có thể chỉnh mỹ thuật sau review. T-154 là task mô hình xác/quản lý tiếp theo, chưa triển khai trong nhánh T-153. Phần chơi thử toàn chương và các kết nối gameplay ở trên chờ tích hợp, không được coi là đã kiểm thử.

### Review (integrator, 2026-10-04)
- **Đạt, đã merge.** Đúng phạm vi; 6 test mới; FPS trên 400; ảnh preview đẹp hơn hẳn demo. Handoff đầy đủ và trung thực.
- Đã ghép vào chương 1:
  - `bunk_spot` của lane A gắn làm con của `Anchors/Bunks/BunkN`, dùng `View` và `Exit` của lane B; chụp khung hình thấy nằm đúng trong giường Trung;
  - trạm khóa ở `Anchors/DatLocker`, ổ sạc ở `TrungChargingCable`;
  - sổ tay, thẻ của Đạt, ảnh của Việt, lịch thi của Phúc gắn ở `DatNote`, `VietPhoto`, `PhucBooks`;
  - đèn nhấp nháy khi quản lý ở trong phòng.
- Trả lời câu hỏi số 2: nội dung sổ tay và mã khóa có trong `docs/design/CH1_SCRIPT.md` (mã `1407`, ngày sinh trên thẻ sinh viên).
- Yêu cầu số 4 (loại scene thử khỏi bản export): integrator làm khi xuất bản build chương 1.
- Sau khi merge có một lần test demo cũ `test_reading_the_door_paper_opens_and_closes_cleanly` lỗi chập chờn; chạy lại hai lần đều PASS. Test này sẽ bị xóa cùng phần demo.
