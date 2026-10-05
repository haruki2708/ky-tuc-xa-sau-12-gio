# T-172 — Chương 2: xác chơi nối từ, đồ bịt miệng, nhà vệ sinh có vòi sen
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-172-ch2-props`
- Phụ thuộc: T-154, T-162, T-165. **Đọc kỹ `docs/design/CH2_DESIGN.md`** (D-046).
- **Hạn: hết ngày 2026-10-07.**

## Mục tiêu
Mô hình, tư thế và đồ vật cho chương 2 trong phòng 407 bản 2 (T-162). Core (T-170) điều khiển bằng API.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/tests/levels/`

## Yêu cầu
1. **Xác chơi nối từ** (mở rộng `corpse_body.gd` của T-154, giữ API cũ):
   - tư thế mới: `sit_play` (ngồi trên giường, đầu hơi nghiêng, nhìn về giữa phòng), `talk` (miệng mấp máy, lặp), `gagged` (giẻ trong miệng; mesh giẻ bật/tắt), `mumble` (bị bịt, đầu giật), `fall` (gục xuống), `revive` (bật dậy, ngắn), `lunge` (lao người về trước, tay vươn), `slump` (gục lại khi hết vòng);
   - API `set_state(state: StringName)` đúng các tên trên (core nối với `EventBus.corpse_state_changed`), `look_at_point(position)` (quay đầu);
   - thêm vào group `ch2_corpse`; dưới 1500 tam giác.
2. **Đồ bịt miệng** trong phòng 407 (anchor mới trong `room407_anchors.tscn`):
   - `RagSpot` (giẻ trên bồn rửa nhà vệ sinh, dùng `rag.tscn`);
   - `TowelSpot` (khăn tắm trên dây phơi ngoài ban công; thêm dây phơi);
   - `ShirtSpot` (áo của Việt trong tủ Việt);
   - `Gag1`, `Gag2`, `Gag4` (đầu xác ở giường 1, 2, 4: chỗ lane A gắn vùng bịt miệng).
3. **Nhà vệ sinh có vòi sen:**
   - cửa gỗ phồng nước: API `set_stuck_shake(strength)` khi bị đẩy, cảnh bật mở ở lần 3 (`Room407.set_bathroom_door_open` đã có);
   - **màn hình gắn tường** thay công tắc vòi sen: anchor `ShowerScreen` (mặt phẳng 0,4 × 0,3 m, lane D gắn nội dung), `ShowerYes`, `ShowerNo` (hai nút dưới màn hình);
   - vùng buồng tắm `Anchors/ShowerStall` (Area3D hoặc Marker3D kèm kích thước);
   - **nước và hơi nước:** API `set_water(on: bool, temperature: int)` (tia nước; nóng thì có hơi bốc), `set_steam(level: float)` 0..1 (sương trong phòng tắm, gương mờ);
   - **gương:** API `flash_reflection()`: thoáng hiện bóng quản lý một khung hình (jumpscare 7).
4. **Vùng phòng:** thêm `Zones/Bedroom`, `Zones/Bathroom`, `Zones/Balcony` (Area3D) để core biết người chơi đang ở đâu (trả lời nối từ chỉ được trong `Bedroom`).
5. **Camera an ninh vòng 3:** thêm một phòng `Room310` vào `cctv_set.tscn` (sửa generator `art_source/cctv/build_cctv.py`): ba xác ngồi, một sinh viên sống; dùng lại xác T-154 và sinh viên T-165. Anchor như các phòng cũ (`Cam`, `Hall`, `Door`, `VictimBed`, `ManagerSpot`, `Victim`).
6. **Test và preview:** đủ trạng thái xác; đủ anchor; nước/hơi nước bật tắt; ảnh từ cửa phòng, giữa phòng, buồng tắm (hơi nước 0 và 1), ban công; FPS khi hơi nước 1.

## Checklist hoàn thành
- [x] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [x] `CREDITS.md`, ảnh preview
- [x] Handoff: đường dẫn node, API, tên trạng thái

## Handoff (agent điền)

### 2026-10-05 — Lane B / Codex

**Đã làm:** commit triển khai `475dee3`, đã push lên
`origin/lane-b/T-172-ch2-props` (base `c68888b`). Làm trong
`D:\GAME_WORK\lane-b`, chỉ sửa các vùng được phép và checklist/Handoff của card.

- Giữ API pose/máu T-154; thêm `set_state(state: StringName) -> bool` cho đủ
  `sit_play`, `talk`, `gagged`, `mumble`, `fall`, `revive`, `lunge`, `slump`.
  Có `look_at_point(Vector3)` nhận tọa độ world, group `ch2_corpse`, giẻ bật/tắt
  qua `set_gagged(bool)`. Xác ngồi mép giường nhìn vào phòng; đầu xác giường dưới
  vượt ra ngoài mép ván tầng trên. 632/632/656 tam giác kể cả giẻ.
- Thêm giẻ bồn rửa, khăn/dây phơi ban công, áo sọc gấp trong tủ Việt; anchor
  miệng cập nhật theo animation. Thêm màn hình vòi sen 0.4 × 0.3 m, hai nút,
  Area buồng tắm, ba Area vùng phòng và cửa gỗ phồng rung khi đẩy.
- Nước 96 hạt CPU, hơi nước 8 mặt phẳng shader chuyển động, gương mờ theo mức
  hơi; bóng quản lý chỉ hiện một lần render rồi ẩn ở `frame_post_draw`.
- Generator CCTV có `Room310`: ba xác ngồi, một sinh viên sống, đủ anchor như
  các phòng cũ. Dùng lại mesh `student_kiet` làm diễn viên nền; không gán thêm
  danh tính/cốt truyện. Camera mới nhìn được cả bốn người.
- Cập nhật `art_source/CREDITS.md`, thêm generator/README và 21 ảnh render
  trong `art_source/ch2_props/previews/`, có `performance.json`.

**Đường dẫn/API để ghép** (tương đối với `Room407`):

| Node | Hợp đồng |
|---|---|
| `Anchors/Corpse{1,2,4}/Body` | API trạng thái, quay đầu, giẻ và máu nêu trên |
| `Anchors/Gag{1,2,4}` | Marker bám đầu; Lane A gắn vùng bịt miệng bên dưới |
| `Anchors/{RagSpot,TowelSpot,ShirtSpot}/Model` | Model vật cầm; Lane A ẩn khi lấy |
| `Anchors/ShowerScreen/Surface` | Quad hướng +Z; Lane D gắn nội dung, size 0.4 × 0.3 m |
| `Anchors/ShowerYes`, `Anchors/ShowerNo` | Marker + mesh hai nút dưới màn hình |
| `Anchors/ShowerStall/Collision` | Area với box 1.05 × 2.4 × 1.05 m |
| `Zones/{Bedroom,Bathroom,Balcony}` | Area layer 0, mask 2; Bedroom gồm hai box hình L |
| `Extension/BathroomDoor` | `set_stuck_shake(float)` và `set_open(bool)` |
| `Ch2Bathroom` | `set_water(bool,int)`, `set_steam(float)`, `flash_reflection()` |

`Room407` có wrapper cho ba API phòng tắm và `set_stuck_shake`, giữ
`set_bathroom_door_open(bool)`. Lane A/core đếm ba lần đẩy rồi gọi mở cửa;
model không tự quyết số lần đẩy, chết hoặc chuyển vòng.

`gagged`/`mumble` bật giẻ; `sit_play`/`talk` tắt; `fall`/`revive`/`lunge`/`slump`
giữ giẻ hiện tại. `set_pose` cũ reset sạch về chương 1. Trạng thái chuyển động
ngắn giữ tư thế cuối, không tự chuyển sang trạng thái game khác.
Nước >=40°C tạo hơi tối thiểu 0.35; mức hiệu lực là max với mức `set_steam`
(clamp 0..1). Reset khô bằng `set_water(false,0)` rồi `set_steam(0)`.
Group `ch2_corpse` gồm cả bản sao CCTV: core cần lọc theo phòng/node path.

`CctvSet/Room310` có `Cam`, `Hall/Cam`, `Hall/Start`, `Door`, `VictimBed`,
`ManagerSpot`, `Victim`, `Corpse1`, `Corpse2`, `Corpse4`; vị trí world mặc định
`(40,-60,0)`. Không thay danh sách feed chương 1.
Chi tiết tọa độ, thời lượng, giới hạn vùng và lệnh dựng lại:
[`art_source/ch2_props/README.md`](../../art_source/ch2_props/README.md).

**Đã kiểm tra:** chạy trên Godot 4.7.2; lệnh test và check đều exit 0.

```text
RESULT: 421 passed, 0 failed
RESULT: check 0 error(s)
RESULT: T172 capture PASS (21 previews, reflection cleared after one draw)
```

7 test mới bao phủ đủ trạng thái, reset API cũ, quay đầu world-space/anchor bám
miệng, giới hạn tam giác, anchor/kích thước màn hình, overlap Player thật ở từng
vùng, nước/hơi bật tắt và độc lập giữa instance, cửa rung/mở, Room310.
Đã xem ảnh render; ảnh gương trước/sau flash có hash giống nhau, ảnh flash khác.
Lượt test trong sandbox ban đầu bị lỗi kho chứng chỉ Windows dù 59 test cũ qua;
đã chạy lại ngoài sandbox và chạy toàn bộ test/check PASS như trên.

FPS bản cuối: Ryzen 5 5600H, RTX 3050 Laptop, Forward+, 1280×720, PS1 strength
và brightness 1, VSync tắt, không fixed FPS; warmup 90 frame, mẫu 240 frame,
full floor4 + player physics/HUD/audio đang chạy. Hơi 1: góc cửa nhà vệ sinh
**328.98 FPS**, p95 **3.237 ms**; trong buồng tắm **486.35 FPS**, p95 **2.396 ms**.
Đây là số đo scene thử môi trường, chưa phải bản chương 2 đã ghép.

**Còn dở/checklist:** không còn mục checklist nào chưa đạt trong phạm vi Lane B.
Chưa chơi/test chương 2 trọn vòng với director, interaction, UI và audio mới;
các phần đó thuộc task khác, cần integrator/lane liên quan ghép rồi QA.

**Yêu cầu thay đổi ngoài phạm vi (chưa tự sửa):**

1. T-170/core nối `EventBus.corpse_state_changed` tới API xác, điều khiển nước/hơi/
   gương, dùng các Area vùng phòng và đăng ký feed camera chương 2 trong code
   core/main. Khi capsule chạm ranh giới hai Area, core cần ưu tiên vùng hoặc
   xét tâm người chơi để quyết định nơi được trả lời.
2. T-171/Lane A gắn tương tác lấy/đặt đồ, vùng bịt miệng, đẩy cửa ba lần và
   vùng đứng tắm vào các anchor trên. T-174/Lane D gắn nội dung màn hình,
   Có/Không và lớp hơi/lau UI; model không chứa chữ hiển thị viết cứng.

**Câu hỏi thiết kế:** card yêu cầu `Room310`, nhưng `CH2_DESIGN.md` mục camera
vòng 3 ghi phòng 102. Đã dựng Room310 theo card; xin integrator/chủ dự án chốt
feed nào dùng trong kịch bản, không tự thay lựa chọn này trong core/UI.

**Blocked:** không còn chặn trong phần việc Lane B; các yêu cầu tích hợp/câu hỏi
ở trên được bàn giao, không tự sửa file ngoài phạm vi.
