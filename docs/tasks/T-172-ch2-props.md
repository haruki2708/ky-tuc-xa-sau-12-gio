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
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] `CREDITS.md`, ảnh preview
- [ ] Handoff: đường dẫn node, API, tên trạng thái

## Handoff (agent điền)
