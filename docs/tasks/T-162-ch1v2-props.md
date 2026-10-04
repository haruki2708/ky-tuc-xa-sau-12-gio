# T-162 — Chương 1 bản 2: đạo cụ và trạng thái phòng 407
- Lane: B (Môi trường và 3D) | Trạng thái: done | Agent:
- Nhánh: `lane-b/T-162-ch1v2-props`
- Phụ thuộc: T-153, T-154. **Đọc kỹ `docs/design/CH1_V2_MISSIONS.md`** (D-039).
- **Hạn: hết ngày 2026-10-06.**

## Mục tiêu
Mô hình, anchor và trạng thái trong phòng 407 cho 8 nhiệm vụ mới. Phong cách PS1 như T-153/T-154; giấy phép CC0, CC-BY hoặc tự làm; ghi `CREDITS.md`.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/tests/levels/`

## Yêu cầu
0. **Phòng 407 mới, to hơn hẳn (D-041), làm trước tiên.** Đọc mục "Phòng 407 mới" trong `CH1_V2_MISSIONS.md`.
   - Phòng chiếm luôn chỗ 408: X 30→38, sâu tới Z khoảng −7. Cửa vào giữ ở X = 32.
   - Cửa 408 ngoài hành lang bịt lại (hoặc thành tủ vòi chữa cháy).
   - **Nhà vệ sinh riêng có vòi sen**, cửa mở được (`Room407.set_bathroom_door_open(bool)`), sàn `surface = tile`.
   - **Ban công nhỏ** phía cửa sổ, vẫn tính là trong phòng.
   - Nhiều đồ đạc: bàn học từng người, kệ sách, tủ lạnh mini, nồi cơm, ấm siêu tốc, giá giày, balo, gương, quạt đứng…
   - **Giữ mọi anchor đã có** dưới `Room407/Anchors` (Bunks/Bunk1..4 có View/Exit, Corpse1/2/4, DatLocker, DatNote, Router, TrungChargingCable, PhucBooks, VietPhoto, WallKnock406…), dời theo bố cục mới.
   - **Thêm `Room407/Bounds`**: một Area3D bao trọn phòng, cả nhà vệ sinh và ban công. Core dùng nó để biết người chơi còn trong phòng.
   - Navmesh cho quản lý đi từ cửa tới trước giường Trung.
   - Dời các thứ T-153/T-154 đã đặt; giữ máu, chém, xác.
   - FPS ≥ 60.
1. **Ổ điện kéo dài** dưới giường Phúc (anchor `Anchors/PowerStrip`):
   - 3 công tắc có đèn; chữ số 1, 2, 3 đã mờ; **công tắc 2 có vệt sơn đỏ**;
   - API `set_switch(i, on)`, `set_tripped(bool)` (tắt hết đèn công tắc), `spark()` (tóe lửa ngắn);
   - mỗi công tắc có node con `Switch1..3` để lane A gắn vùng tương tác.
2. **Phích cắm cục phát** quấn **băng keo đỏ**, dây chạy từ cục phát xuống ổ điện.
3. **Hai dây mạng** dưới gầm bàn: **xanh dương** (từ cục phát) và **xám** (từ laptop của Việt).
   - Mỗi dây có đầu tuột nằm trên sàn (anchor `Anchors/LanBlueEnd`, `LanGrayEnd`).
   - **Ổ mạng trên tường** (`Anchors/LanWallPort`).
   - API `set_plugged(cable_id, plugged)`: đầu dây vào ổ hoặc nằm lại trên sàn.
4. **Cục phát:** đèn nguồn và đèn mạng riêng. API `set_power(bool)`, `set_network(state)` với state là `&"off"`, `&"booting"` (nhấp nháy), `&"red"`, `&"ok"`.
5. **Tủ Việt mở được:** `Anchors/VietLocker` có `set_open(bool)`; mảnh giấy 1 nằm trong.
6. **Nệm Phúc lật được:** `Anchors/PhucMattress` có `set_lifted(bool)`; dưới nệm có mảnh giấy 2 đẫm máu (không chi tiết giải phẫu).
7. **Sọt rác** cạnh bàn (`Anchors/TrashBin`), mảnh giấy 3 vo nằm trong.
8. **Mô hình giấy xé:** 3 mảnh (dùng chung một scene, tham số mảnh 1/2/3).
9. **Ảnh đội bóng khoa** (Đạt khoác vai Phúc), đặt trên kệ của Đạt (`Anchors/TeamPhoto`). **Sổ hợp âm guitar** của Việt cạnh cây đàn (`Anchors/GuitarSongbook`). **Thẻ sinh viên của Phúc** kẹp trong sách giáo trình của Phúc (`Anchors/PhucCard`).
10. **Tay nắm cửa 407 rung:** `Door407.rattle(seconds)`: tay nắm xoay qua lại, cánh cửa rung nhẹ trong khung (không mở). Có `stop_rattle()`.
11. **Đèn bàn của Trung:** API `set_desk_lamp(on)` trên `Room407` (tắt hẳn ánh sáng và vùng sáng). Anchor `Anchors/DeskLampSwitch` cho lane A.
12. **Anchor hai bức tường gõ** (`WallKnock406`, `WallKnock408` đã có): kiểm tra vị trí dễ bấm từ giường.
13. **Test và preview:** đủ anchor; các API trạng thái chạy đúng; ảnh preview từng món và cảnh dưới gầm bàn có ổ điện, dây mạng.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] `CREDITS.md` đủ nguồn; ảnh preview
- [x] Handoff: anchor, API

## Handoff (agent điền)

### Lane B — 2026-10-05

- Commit nội dung: `d08289a` — `T-162: expand room 407 and add chapter v2 mission props`.
  Đã push `origin/lane-b/T-162-ch1v2-props`, gồm 19 PNG qua LFS.
- Mở 407 thành 8 × 7 m (world X30→38), cửa vào X32; bịt 408, bỏ sàn/vách
  408 cũ chồng vào phòng. Có nhà vệ sinh riêng, cửa va chạm mở được, vòi sen,
  bồn rửa/cầu, ban công 5,2 × 1,5 m; bổ sung ba bàn để đủ bốn bàn và đồ đạc.
- Giữ mọi anchor cũ, dời giường B/xác/máu/chăn/vết chém về X=7,35 local.
  Bounds bao phòng, nhà vệ sinh và ban công. Navmesh nối cửa tới giường Trung,
  tránh tủ lạnh; `Anchors/ManagerApproach` local `(6.25,.03,-2.55)`.
- Đã dựng ổ điện ba công tắc, phích đỏ/dây điện, hai dây LAN và ổ tường;
  router có hai đèn; tủ Việt mở được, nệm Phúc lật cùng chăn/gối/Body; ba giấy
  xé dùng chung scene, ảnh đội trên kệ Đạt, sổ cạnh đàn Việt, thẻ ở mép sách Phúc.
  Đèn bàn có setter; tay nắm/cánh cửa rung nhỏ và khôi phục trạng thái đóng.
- Model native Godot, dùng texture CC0 cũ; từng prop mới 18–248 tam giác,
  nằm trong ngân sách. Nguồn và khai báo AI đã thêm `art_source/CREDITS.md`.

### Anchor và API

Chi tiết, tọa độ, hành vi reset và cách tái tạo:
[`art_source/ch1v2_props/README.md`](../../art_source/ch1v2_props/README.md).

- `Room407`: `set_bathroom_door_open(bool)`, `set_desk_lamp(bool)`,
  `set_plugged(&"blue" hoặc &"gray", bool)`.
- `Room407/Anchors/PowerStrip`: `set_switch(1..3,bool)`, `set_tripped(bool)`,
  `spark()`; con `Switch1..3` cho Lane A. Bỏ tripped không tự bật lại công tắc.
- `Anchors/Router/Model`: `set_power(bool)`,
  `set_network(&"off"/"booting"/"red"/"ok")`; giữ API `set_led()` cũ.
- `Anchors/VietLocker.set_open(bool)`, `Anchors/PhucMattress.set_lifted(bool)`.
  Các giấy: `VietLocker/Paper1`, `PhucMattress/Paper2`, `TrashBin/Paper3`;
  `fragment_id` 1..3, mỗi mảnh có `ReadSurface`.
- `Anchors/LanBlueEnd`, `LanGrayEnd`, `LanWallPort`, `TeamPhoto/BackText`,
  `GuitarSongbook/CodeSheet`, `PhucCard/ReadSurface`, `DeskLampSwitch`.
- `Floor4/Door407.rattle(seconds)`, `stop_rattle()`; `set_open()` hủy rung.
- Giữ `Bunks/Bunk1..4/{View,Exit}`, `Corpse1/2/4/Body`, `DatLocker`, `DatNote`,
  `PhucBooks`, `VietPhoto`, `TrungChargingCable`, hai WallKnock; test khoảng cách
  gõ tường từ View tương ứng <1,5 m.

### Kiểm tra đã chạy

```text
pwsh tools/test.ps1
RESULT: 362 passed, 0 failed

pwsh tools/check.ps1
RESULT: check 0 error(s)

Godot --path game --script ../art_source/ch1v2_props/capture_room.gd
T162_CAPTURE_RESULT: PASS 19 views
```

Test mới: Bounds với physics player, đường nav và capsule tránh đồ đạc, cửa
nhà vệ sinh/ban công/lan can, switch/trip/spark, dây/router, tủ/nệm/reset,
đèn bàn, rung cửa và ngân sách tam giác. Không có engine ERROR; cả hai lệnh
bắt buộc exit 0. Các warning kiểm thử dữ liệu sai có chủ đích của bộ test cũ
vẫn xuất hiện.

Ảnh: [`art_source/ch1v2_props/previews/`](../../art_source/ch1v2_props/previews/).
Đã xem ảnh và sửa che khuất giấy/ảnh/cáp. FPS trung bình từng góc **489,37–557,45**,
1280×720, Forward+, PS1=1, VSync off; Ryzen 5 5600H/RTX 3050 Laptop; 90 frame
warmup + 240 frame đo. Cả tầng, physics Player/HUD/audio hoạt động, camera đứng
yên. Thông số/p95 lưu trong `performance.json`. Đây không phải benchmark
toàn bộ tám nhiệm vụ với NPC; chưa chơi hoàn chỉnh chương 1 v2.

### Yêu cầu thay đổi ngoài phạm vi / việc còn lại khi tích hợp

1. **Core (`game/scripts/core/chapter1_director.gd`)**: thay BED_EXIT,
   MANAGER_SPOT, tâm/phạm vi phòng cũ, vị trí Đạt bằng anchor và Bounds mới.
   Đặc biệt nhà vệ sinh/ban công phải tính là trong phòng; Bunk3/4 đã chuyển
   sang phía đông. Quản lý dùng ManagerApproach và navmesh thay tọa độ cũ.
2. **Lane A/core**: gắn vùng Interactable, gọi setter theo nhiệm vụ/checkpoint,
   nối điện/mạng/rung cửa/đèn và âm thanh/EventBus. Các scene chỉ có trạng thái
   hình ảnh, không tự quyết thời hạn, luật chết hay hoàn thành nhiệm vụ.
3. **Lane D/core (`game/data/`, UI/localization)**: nối nội dung giấy/thẻ/ảnh/bảng
   mã theo D-039 vào các mặt đọc đã cung cấp; chưa viết nội dung truyện lên mesh.
4. **Phối hợp khóa Đạt**: model/API kế thừa T-153 vẫn ba vòng; D-039 dùng mã
   bốn số 2109. Cần tích hợp dữ liệu/logic khóa bốn số và giao tiếp vòng hiển thị
   trong task gameplay; T-162 chưa đổi cơ chế khóa.

Không còn mục checklist Lane B chưa đạt. Không bị chặn ở phần asset/API;
những yêu cầu trên cần hoàn tất trước khi nghiệm thu gameplay v2. Không sửa
file core/A/D, STATUS, main; không thêm plugin hoặc cài công cụ. Không có câu
hỏi cốt truyện mới; dùng các quyết định D-039/D-041 đã chốt.

### Review (integrator, 2026-10-05)
- **Đạt, đã merge.** Đúng phạm vi; FPS 489–557; đủ anchor và API; README rõ.
- **Ghép:**
  - core dùng `Anchors/ManagerApproach` làm chỗ quản lý đứng hỏi;
  - `Bounds` để biết người chơi còn trong phòng: kiểm tra theo vị trí trong hộp, vì lúc nằm giường va chạm thân bị tắt (T-151);
  - tâm phòng lấy từ `Bounds/Main`.
- Lưu ý: đèn bàn mặc định bật, đúng ý nhiệm vụ N6 (người chơi phải tự tắt).
