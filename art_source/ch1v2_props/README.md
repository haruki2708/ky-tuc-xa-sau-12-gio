# T-162 — Phòng 407 và đạo cụ chương 1 v2

Scene chính: `game/scenes/levels/floor4/floor4.tscn`, room tại world `(30,0,0)`.
Phòng 8 × 7 m; ban công thêm 5,2 × 1,5 m. Cửa hành lang vẫn ở X=32;
408 đã bịt. Nhà vệ sinh có cửa va chạm, vòi sen, bồn cầu, chậu rửa.
Bốn bàn, kệ, tủ lạnh/nồi cơm, ấm, giá giày, balo, gương, quạt và đồ ban công
dùng hình học ít đa giác và texture cũ; nguồn trong `art_source/CREDITS.md`.

## Anchor và API cho Lane A/core

Các đường dẫn dưới đây tương đối với `Floor4/Room407`, trừ Door407.
Các setter chỉ đổi hình ảnh/trạng thái vật thể. Core quyết định luật chơi,
thời gian chập, hồi mạng, mở khóa, thu thập, âm thanh và EventBus.

| Đường dẫn | API / ý nghĩa |
|---|---|
| `.` | `set_bathroom_door_open(bool)`, `set_desk_lamp(bool)`, `set_plugged(&"blue" hoặc &"gray", bool)` |
| `Bounds` | Area3D, mask player=2; gồm phòng, nhà vệ sinh và ban công; hành lang ở ngoài |
| `ManagerNavigation` | Navmesh cửa → lối giữa → trước giường Trung, tránh tủ lạnh; capsule bán kính 0,3 m đã kiểm tra |
| `Anchors/ManagerApproach` | Điểm đến local `(6.25,.03,-2.55)`; dùng global_position khi cấp cho agent |
| `Anchors/PowerStrip` | `set_switch(i,on)` i=1..3; `set_tripped(bool)`; `spark()` 0,18 giây |
| `Anchors/PowerStrip/Switch1..3` | Marker3D cho vùng tương tác; 2 có sơn đỏ và phích quấn băng đỏ |
| `Anchors/LanBlueEnd`, `LanGrayEnd` | Marker3D có mesh Plug; đổi vị trí khi cắm/rút, giữ nguyên node path |
| `Anchors/LanWallPort` | Ổ tường local `(5.45,.35,-.12)`; nằm cạnh bàn để tới được từ phía trước |
| `Anchors/Router/Model` | `set_power(bool)`; `set_network(&"off"/"booting"/"red"/"ok")`; LED nguồn riêng đèn mạng |
| `Anchors/VietLocker` | `set_open(bool)`; `Paper1` trên kệ giữa |
| `Anchors/PhucMattress` | `set_lifted(bool)`; `Paper2` dưới nệm; chăn, gối và Body cùng lật; màn thu lại khi mở |
| `Anchors/TrashBin/Paper3` | Mảnh vo trong sọt cạnh bàn |
| `Anchors/TeamPhoto` | Trên kệ Đạt; con `BackText` là mặt gắn nội dung mặt sau |
| `Anchors/GuitarSongbook` | Trên bàn Việt cạnh đàn; con `CodeSheet` cho bảng mã đọc được |
| `Anchors/PhucCard` | Mép sách Phúc, con `ReadSurface` cho nội dung thẻ |
| `Anchors/DeskLampSwitch` | Công tắc đèn bàn Trung; setter tắt năng lượng, hủy flicker, giữ hình chiếc đèn |
| `Anchors/WallKnock406`, `WallKnock408` | Trong tầm 1,5 m từ View giường tương ứng |
| `Floor4/Door407` | `rattle(seconds)`, `stop_rattle()`; rung nhỏ cánh/handle, không mở cửa; set_open hủy rung |

Các mảnh dùng chung `ch1v2/torn_paper.tscn`, `fragment_id` 1..3 hoặc
`set_fragment(1..3)`. Có hai mặt; mảnh 2 đỏ sẫm, mảnh 3 gấp không phẳng.
Mỗi mảnh có `ReadSurface`. Chưa có nội dung tài liệu/localization hay vùng
tương tác do Lane A/D/core phụ trách. Không tự đặt thêm manh mối.

Ổ điện tripped giữ ba công tắc tắt. `set_tripped(false)` chỉ bỏ trạng thái
ngắt, không tự bật lại. `set_switch` và `set_plugged` trả false với ID sai.
Router giữ `set_led()` cũ cho tương thích; core v2 dùng `set_power()` để đèn
nguồn sáng liên tục. Trạng thái các scene độc lập giữa các instance.

Giữ toàn bộ anchor cũ và đường dẫn `Bunks/Bunk1..4/{View,Exit}`, Corpse1/2/4,
DatLocker, DatNote, TrungChargingCable, PhucBooks, VietPhoto. Giường B chuyển
sang local X=7,35, Z=-2,7; máu, chăn, vết chém theo giường. Không dùng lại
tọa độ world cũ trong core. Các hiệu ứng T-153 vẫn gọi bằng set_blood_stage,
set_slashed, set_flicker; setter đèn bàn nên gọi sau hiệu ứng flicker chung.

## Tạo lại, kiểm tra và preview

Từ repo, dùng Python có sẵn (stdlib, không pip):

```powershell
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' art_source/ch1v2_props/build_room.py
pwsh tools/test.ps1 -Filter ch1v2
pwsh tools/test.ps1
pwsh tools/check.ps1
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game --script ../art_source/ch1v2_props/capture_room.gd
```

Generator dùng helper T-154, sinh scene native và patch các scene tầng/phòng.
Chạy trên nhánh này; không chạy lại generator T-153/T-154 sau đó vì chúng
có thể ghi đè bố cục mới. Không cần Blender GUI, plugin hay asset tải ngoài.

`previews/*.png` chụp toàn phòng và từng đạo cụ, gồm dây rời và dây đã cắm,
tủ mở, nệm lật, đèn tắt. `performance.json` ghi máy, Godot, FPS trung bình
và p95 từng góc: 1280×720 Forward+, PS1 strength=1, VSync tắt, 90 frame
warmup + 240 frame đo; cả tầng, physics người chơi/HUD/audio hoạt động.
Đây là benchmark camera đứng yên, chưa phải lượt chơi hoàn chỉnh với NPC.
F6 `room407/room407_test.tscn` để tự đi trong phòng; phím 1..7 giữ QA cũ.

## Việc tích hợp ngoài phạm vi

- Core: thay các hằng BED_EXIT/MANAGER_SPOT, tâm phòng, kiểm tra inside_room,
  điểm thoại Đạt trong `chapter1_director.gd` bằng anchor và Bounds mới;
  nối navmesh với quản lý. Không áp các tọa độ 4×5 m cũ vào phòng 8×7 m.
- Lane A/core: gắn Interactable tại anchor, gọi API theo nhiệm vụ/checkpoint,
  đồng bộ trạng thái cắm điện/mạng, khóa cửa, rung và âm thanh.
- Lane D/core: nội dung đọc ảnh/thẻ/giấy/mã gõ theo D-039 qua localization.
  Mô hình thẻ/sổ/ảnh hiện cung cấp mặt đọc, chưa tự viết chữ nội dung lên mesh.
- Khóa DatLocker kế thừa T-153 vẫn có ba vòng; D-039 cần mã bốn số. Integrator
  xác nhận/phối hợp thay API khóa và vòng hiển thị trong task gameplay.

Các điểm này là yêu cầu tích hợp, không phải xác nhận đã chạy 8 nhiệm vụ v2.
