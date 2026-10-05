# T-172 — đạo cụ và môi trường chương 2

Chỉ cung cấp hình ảnh, anchor và vùng va chạm. Core/Lane A/Lane D nối luật chơi,
inventory, EventBus, nội dung màn hình và camera điện thoại.

## Dựng lại và kiểm tra

Từ gốc repo, dùng Python có sẵn trong Blender portable:

```powershell
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' art_source/ch2_props/build_props.py
& 'D:\Tools\Blender\5.2.2\5.2\python\bin\python.exe' art_source/cctv/build_cctv.py
pwsh tools/test.ps1
pwsh tools/check.ps1
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game --script ../art_source/ch2_props/capture_props.gd --windowed --resolution 1280x720
```

Nếu chạy lại generator T-162, chạy generator T-172 **sau đó** để phục hồi các
addition trong scene phòng, anchor và cửa. Generator T-172 chạy lặp không thêm node
trùng. Trạng thái xác sinh bằng GDScript trên rig T-154, không cần dựng lại rig.

## Hợp đồng node/API

Các đường dẫn dưới đây tương đối với `Room407`:

| Node | Dùng để |
|---|---|
| `Anchors/Corpse{1,2,4}/Body` | `set_state(StringName) -> bool`, `look_at_point(Vector3)` tọa độ world |
| `Anchors/Gag{1,2,4}` | Marker bám miệng mỗi frame, chạy sau animation; gắn Area của Lane A bên dưới |
| `Anchors/RagSpot/Model` | Giẻ T-154 trên bồn rửa, local anchor `(5.65,.88,-5)` |
| `Anchors/TowelSpot/Model` | Khăn trên dây phơi `(2.8,1.8,-8.12)` |
| `Anchors/ShirtSpot/Model` | Áo sọc của Việt trên kệ tủ `(.3,.87,-1.25)` |
| `Clothesline` | Dây và cọc, không chặn lối đi |
| `Anchors/ShowerScreen/Surface` | Quad 0.4 × 0.3 m, mặt hướng +Z; thay texture bằng nội dung Lane D |
| `Anchors/ShowerYes`, `Anchors/ShowerNo` | Hai marker có mesh nút; chưa có chữ/UI hay interaction |
| `Anchors/ShowerStall/Collision` | Box 1.05 × 2.4 × 1.05 m; tâm `(6.18,1.2,-6.32)` |
| `Zones/Bedroom` | Area gồm 2 box cho phòng ngủ hình L, không bao nhà vệ sinh/ban công |
| `Zones/Bathroom`, `Zones/Balcony` | Area cho phần phòng tương ứng |
| `Extension/BathroomDoor` | `set_stuck_shake(float)` 0..1; `set_open(bool)` kế thừa API cũ |
| `Ch2Bathroom` | `set_water(bool,int)`, `set_steam(float)`, `flash_reflection()` |

`Room407` có wrapper cho ba API phòng tắm và `set_stuck_shake`; giữ
`set_bathroom_door_open(bool)`. Va chạm vùng: layer 0, mask 2 (Player), không cản
chuyển động. Người đứng sát ranh giới có thể chạm hai Area do bán kính capsule;
core nên dùng vị trí tâm hoặc quy định ưu tiên vùng khi tích hợp.

Trạng thái xác: `sit_play`, `talk`, `gagged`, `mumble`, `fall`, `revive`, `lunge`,
`slump`. `talk`/`mumble` lặp; `fall` 0.40 s, `revive` 0.22 s, `lunge` 0.28 s,
`slump` 0.65 s rồi giữ tư thế cuối. Không tự chuyển lượt, hồi sinh hay gây chết.
`set_pose` cũ giữ nguyên tên/API và reset sạch mọi biến đổi chương 2.

Mỗi xác vào group `ch2_corpse`; group có cả bản sao CCTV, nên core lọc theo room
hoặc dùng node path. `set_gagged(bool)` bật/tắt giẻ độc lập; `gagged`/`mumble`
bật giẻ, `sit_play`/`talk` bỏ giẻ, các trạng thái khác giữ nguyên giẻ. Máu dùng
`set_blood_visible` cũ, độc lập. `initial_state` dùng cho scene CCTV;
`seat_side` +1 ngồi bên trái nhìn +X, -1 bên phải nhìn -X, 0 lấy mặc định model.
Xác có 632/632/656 tam giác kể cả giẻ; khăn 108, áo 48, dây phơi 60.

Nước dùng 96 hạt CPU. Khi nước bật ở >=40°C, hơi có mức tối thiểu 0.35;
`set_steam` đặt mức ngưng tụ trong phòng (clamp 0..1, NaN/Inf về 0), mức hiệu lực
là max của hai nguồn. Reset khô: `set_water(false,0)` rồi `set_steam(0)`.
Material hơi/gương độc lập giữa các instance. Hơi là lớp 3D trong phòng tắm;
lớp che UI/lau màn hình do Lane D xử lý.

`flash_reflection()` hiện model quản lý đã ép mỏng trong mặt gương cho đúng một
lần render, ẩn ở `RenderingServer.frame_post_draw`; gọi lặp trong cùng frame
không tạo callback trùng. Bộ ảnh `mirror_before/flash/after` ghi cả ba thời điểm.

Cửa chỉ rung nhẹ rồi trở lại góc đóng; `set_bathroom_door_open(true)` hủy rung
và bật mở ngay. Lane A/core đếm đủ 3 lần đẩy rồi gọi API, không đếm trong model.

`res://scenes/levels/cctv/cctv_set.tscn/Room310` ở `(40,-60,0)` trong world mặc
định. Có `Cam`, `Hall/Cam`, `Hall/Start`, `Door`, `VictimBed`, `ManagerSpot`,
`Victim`, `Corpse1`, `Corpse2`, `Corpse4`. Ba xác ngồi, `Victim` sống ở tư thế
`lie_awake`, dùng lại mesh `student_kiet` làm diễn viên nền, không gán Kiệt là
người của phòng 310 trong cốt truyện. Các phòng/feed chương 1 không đổi.

## Preview và hiệu năng

21 PNG trong `previews/`: cửa phòng, giữa phòng, phòng tắm/buồng tắm mức hơi 0/1,
ban công, giẻ, áo, 8 trạng thái ba xác, gương trước/trong/sau flash, Room310.
`performance.json` lưu cấu hình máy, renderer, mean FPS và p95 frame time.
Đo với full floor4, player physics/HUD/audio và PS1 strength/brightness 1,
1280×720, VSync tắt, không fixed FPS, warmup 90 frame + lấy mẫu 240 frame.
Đây là scene thử môi trường, chưa phải chương 2 đã ghép với director/UI/audio mới.
