# T-153 — Cầu thang, tầng 5, tầng 6, sân phơi và nhà đối diện
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-153-stairs-floors-5-6`
- Phụ thuộc: T-112 (tầng 4), T-138 (đạo cụ). Đọc `docs/design/STORY.md` §5.1 (ánh sáng, chỗ nấp), §5.5, §6, §10 và `docs/design/LAYOUT.md`.
- **Hạn: hết ngày 2026-10-05.** Xong thì làm T-154 ngay.

## Mục tiêu
Chương 1 mở thêm cầu thang, tầng 5, tầng 6 và sân phơi. Từ hành lang nhìn được sang nhà đối diện bên kia sân. Các tầng mới **dùng lại module và generator của tầng 4**, khác nhau ở cách bày đồ và vài phòng đặc biệt. Không dựng từ đầu.

Ảnh tham khảo đồ họa chủ dự án sẽ gửi sau. Trong lúc chờ, giữ đúng phong cách PS1 và bộ kit hiện tại.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/`

## Yêu cầu
1. **Cao độ:** mỗi tầng cao 3,3 m (tầng 4 ở Y = 0, tầng 5 ở Y = 3,3, tầng 6 ở Y = 6,6). Hệ trục giống tầng 4: X tây sang đông, phòng ở −Z, sân ở +Z.
2. **Cầu thang** (`stairwell.tscn`), ở đầu đông sau cổng sắt hiện có (X khoảng 42–46):
   - Thang hai vế, có chiếu nghỉ giữa mỗi tầng. Đi được từ tầng 4 lên tầng 6.
   - **Cổng sắt kéo ở mỗi tầng** là node riêng (`StairGate4`, `StairGate5`, `StairGate6`), có API `set_open(bool)` và `is_open()`, collision đổi theo trạng thái. Cổng tầng 4 hiện đang khóa và phải mở được.
   - **Xuống tầng 3 bị chặn** bằng cổng khóa xích. **Lên sân thượng bị chặn** bằng cửa sắt có xích, trên tầng 6.
   - Đèn cầu thang: đèn tuýp nhỏ ở mỗi chiếu nghỉ, tắt mặc định, có anchor công tắc `StairLightSwitch` ở mỗi tầng. Cầu thang **không có** đèn vàng an toàn.
   - Sàn cầu thang có `metadata/surface = &"concrete"`.
3. **Tầng 5** (`floor5.tscn`): cùng khung với tầng 4.
   - Phòng 501–508 phần lớn khóa.
   - **Phòng 503 là phòng sinh hoạt chung:** TV CRT trên bàn, ghế nhựa, bảng tin.
   - **Phòng 507 mở**, cùng vị trí với 407: phòng trống, 2 giường tầng không nệm, tủ sắt mở, đồ đạc người ở trước bỏ lại.
   - Nhà vệ sinh tầng 5: buồng vệ sinh **vào được** để nấp.
   - Bàn trực tầng 5 bỏ trống. **Anchor `FakeNotice5`** trên tường gần cầu thang để dán thông báo dấu giả.
4. **Tầng 6** (`floor6.tscn`):
   - **Phòng 601 là kho:** kệ, nệm cuộn, tủ sắt lớn để nấp. Anchor `LockerCombo601` cho tủ khóa số và `Calendar601` cho lịch cũ.
   - Phòng 602–608 khóa. Anchor `OldRules2015` cho giấy cũ ở hành lang.
   - **Đầu tây không có nhà vệ sinh mà là cửa ra sân phơi:** sân ngoài trời, lan can, dây phơi có áo trắng, anchor `FuseBox6` cho hộp cầu dao. Sân phơi tối cho tới khi giải câu đố cầu dao.
   - Hành lang tầng 6 tắt đèn mặc định (mất điện); integrator bật lại theo cầu dao.
5. **Nhà đối diện bên kia sân:** mặt tiền 6 tầng, hành lang ngoài, vài đèn mờ, cách khoảng 18–22 m về +Z. Không vào được, chi phí vẽ thấp. Có Marker3D `WatcherAnchors/Opposite_*` trên lan can các tầng để Người thứ năm đứng.
6. **Ánh sáng cho thực thể (T-152):**
   - Mỗi vùng có đèn tuýp đang sáng: một Area3D trong group `lit_area`.
   - Mỗi đèn vàng sợi đốt (bàn trực mỗi tầng, đèn bàn phòng 407): một Area3D trong group **`safe_light`** và physics layer 8 (giống vùng an toàn hiện có của truy đuổi, `SAFE_ZONE_LAYER`).
   - Có API để bật/tắt từng đèn theo tên cùng với vùng `lit_area` của nó (ví dụ `set_light_on(name, on)` ở script của tầng).
7. **Chỗ nấp:**
   - Anchor `Anchors/HideSpots/<tên>`, mỗi anchor có metadata `kind` (`bed`, `locker`, `stall`, `net`), một node con `View` (vị trí camera khi nấp) và một node con `Exit`.
   - Tối thiểu: phòng 407 có gầm giường Trung và tủ Trung; phòng 507 có 2 gầm giường và 2 tủ; nhà vệ sinh tầng 4 và 5 có 3 buồng mỗi bên; kho 601 có 1 tủ lớn.
   - Gầm giường phải có khoảng trống đủ cao để camera nằm nhìn ra.
8. **Navmesh:** NavigationRegion3D cho mỗi tầng và cầu thang, nối liền nhau. Agent bán kính 0,3 m, cao 1,8 m. Phòng khóa không có navmesh bên trong.
9. **Điểm cho thực thể:**
   - `Anchors/WalkerPatrol/<tầng>_*`: lộ trình đi tuần. Thêm metadata `action = &"count"` ở giữa phòng 507 và giữa phòng 407.
   - `WatcherAnchors/*`: cuối hành lang mỗi tầng, khung cửa, góc cầu thang.
10. **Hiệu năng:**
    - Script gốc của tòa nhà có `focus_floor(n)`: ẩn đèn và tắt xử lý của các tầng không kề tầng `n`.
    - Đo FPS ở hành lang tầng 5 và cầu thang bằng cách đo của T-112. Mục tiêu ≥ 60 FPS trên máy hiện tại.
11. **Scene thử** `building_playtest.tscn`: tầng 4–6 và cầu thang, có Player, bắt đầu ở tầng 4.
12. **Test `game/tests/levels/`:**
    - các scene load được;
    - mọi sàn có `surface`;
    - đủ anchor theo tên ở trên;
    - cổng mở và đóng;
    - navmesh nối được từ cửa 407 tới cửa 507 và tới sân phơi (dùng `NavigationServer3D.map_get_path`);
    - mỗi `safe_light` ở layer 8.
13. **Ảnh preview** các góc mới trong `art_source/<thư mục mới>/previews/`.

## Checklist hoàn thành
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ảnh preview, số đo FPS
- [ ] Handoff: tên anchor, API đèn và cổng, phần chưa làm

## Handoff (agent điền)
