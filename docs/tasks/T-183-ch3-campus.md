# T-183 — Chương 3: khuôn viên trường (nhà B tầng 1–4, vườn hoa, sân vận động, cổng, nhà ăn)
- Lane: B (Môi trường và 3D) | Trạng thái: todo | Agent:
- Nhánh: `lane-b/T-183-ch3-campus`
- Phụ thuộc: T-162, T-165, T-172. **Đọc kỹ `docs/design/CH3_DESIGN.md`**, nhất là mục "Quy mô map" (D-054).
- **Hạn đề xuất:** greybox cả khuôn viên **hết ngày 2026-10-07** (push sớm để lane A, C thử); mô hình thật hết ngày 2026-10-08.

## Mục tiêu
Dựng khuôn viên trường gần kích thước thật (khoảng 500 × 350 m), đi lại và chơi được, đúng phong cách PS1, giữ FPS. Đây là việc lớn nhất của chương 3. **Làm greybox trước**: khối hộp đúng kích thước, có collision và navmesh, các anchor đúng tên. Sau đó thay mô hình thật theo thứ tự nhà B → vườn hoa → sân vận động → đường và cổng → nhà ăn. Hết giờ mà chưa xong thì phần sau cùng để greybox, ghi rõ trong Handoff.

## Được phép sửa
`art_source/`, `game/assets/models/`, `game/assets/textures/`, `game/scenes/levels/`, `game/rendering/`, `game/tests/levels/`

## Hợp đồng (core, không đổi tên)
- **Scene:** `res://scenes/levels/campus/campus.tscn`, gốc `Node3D` tên `Campus`. Core đặt Campus **cạnh** `Floor4` có sẵn (tầng 4 và phòng 407 bản 2 giữ nguyên, không sửa).
- **Hệ tọa độ** (khớp tầng 4 hiện có): hành lang tầng 4 chạy theo trục x từ 0 tới 44, sàn tầng 4 ở **y = 0**, phía **+z là lan can** nhìn ra vườn hoa; phòng ở phía −z. Mỗi tầng cao **3,3 m**: sàn tầng 3 ở y = −3,3, tầng 2 ở y = −6,6, **tầng 1 và mặt đất ở y = −9,9**. Nhà A đối diện nhà B qua vườn hoa (phía +z).
- **Collision layer 1 = world.** Có **NavigationRegion3D** phủ mọi chỗ xác đi được (gồm cầu thang), để lane A dùng.
- **Anchor** (`Marker3D` dưới `Campus/Anchors`):
  - chỗ bắt đầu từng checkpoint: `Start_garden`, `Start_stadium`, `Start_gate` (`ch3_b` bắt đầu trong phòng 407, đã có);
  - nhà B: `FireDoor` (cửa cầu thang thoát hiểm tầng 4, khóa), `FireKey` (chìa trong ngăn kéo bàn trực tầng 4, cạnh bàn trực có sẵn), `Collapse2F` (đoạn cầu thang sập tầng 2), `Room203Door`, `Extinguisher2F` (bình cứu hỏa để gây tiếng động), `MainDoor1F` (cửa chính xích khóa), `ManagerWindow` (cửa sổ vỡ để trèo ra), `ManagerKnife`;
  - đồng đội: `Paths/Nhat` và `Paths/Ngu`, mỗi cái là `Node3D` chứa các `Marker3D` đánh số `P01, P02…` theo thứ tự chạy; điểm hẹn (dừng chờ) đặt tên có tiền tố `Wait_`, ví dụ `P07_Wait_garden`;
  - xác: `ZombieSpawns/<Khu>/S01…` với `<Khu>` là `B4`, `B3`, `B2`, `B1`, `Road`, `Garden`, `Stadium`, `Gate`, `Canteen` (ít nhất 6 điểm mỗi khu; sân vận động đặt ở 4 cổng); `ZombieIdle/<Khu>/I01…` cho xác rải rác đứng, ngồi, nằm dọc đường;
  - thanh sắt: `BarSpawns/B01…` (giường tầng đổ trong vườn hoa, gầm khán đài, vài chỗ khác; tối thiểu 6), `NguBench` (ghế đá Ngư đứng);
  - cổng: `GuardLine/G01…G12`, `GuardBooth`;
  - nhà ăn: `CanteenTV`, `CanteenClock`, `CanteenExit` (cửa kho);
  - manh mối động đất: `Clues/Clock4F` (đồng hồ bàn trực dừng lúc 4:00), `Clues/CrackStair`, `Clues/SirenSpot` (chỗ cao khán đài nghe còi), `Clues/GatePillar`.
- **Vùng** (`Area3D` dưới `Campus/Zones`, hộp `BoxShape3D`): `BuildingB`, `Road`, `Garden`, `Stadium`, `Gate`, `Canteen`, `GuardRadius` (bán kính 3 m trước hàng bảo vệ), `Bleachers`.
- **API cho core** (script gốc của Campus):
  - `set_fire_door_open(open: bool)`, `set_main_door_chained(bool)`;
  - `set_canteen_tv(on: bool)`;
  - `set_stadium_lights(on: bool)` (một lần bật sáng, jumpscare 7);
  - `get_anchor(name: String) -> Node3D`.

## Yêu cầu
1. **Nhà B** (44 × 10 m, đủ 6 tầng mặt ngoài):
   - **cầu thang chính** ở đầu x = 0 và **cầu thang thoát hiểm** ở đầu x = 44, nối tầng 4 xuống tầng 1. Tầng 4 hiện có thì chỉ mở thêm lối vào hai cầu thang, không sửa phòng 407;
   - tầng 3, 2, 1: nhân bản từ kit tầng 4. Phòng đóng cửa, trừ **phòng 203** (vào được); 2–3 cửa phòng mỗi tầng để xác tràn ra;
   - **cầu thang thoát hiểm từ tầng 2 xuống tầng 1 sập**: bê tông đổ, thép lòi, không đi được;
   - tầng 1: **sảnh**, **cửa chính xích khóa**, **phòng quản lý** có cửa sổ vỡ trèo ra được (cao khoảng 1 m, dùng chiều cao cúi), con dao cắm trên bàn;
   - tầng 5–6 chỉ là mặt ngoài, cầu thang lên tầng 5 bị đổ chắn.
2. **Nhà A:** mặt ngoài 6 tầng, đối diện nhà B; vài cửa sổ có bóng người (billboard).
3. **Vườn hoa** 44 × 40 m: lối lát gạch, 10–12 bồn hoa, ghế đá, cây thấp, đèn vườn chập chờn, một giường tầng đổ (chỗ thanh sắt).
4. **Sân vận động thật 176 × 92 m:**
   - đường chạy vòng 400 m, sân cỏ;
   - **khán đài chính 80 m × 10 bậc** (lên được) và một khán đài phụ thấp;
   - 4 cổng vào, cột đèn;
   - ống sắt dưới gầm khán đài.
5. **Đường nội bộ:** đại lộ khoảng 200 m nối nhà B, sân vận động, cổng, nhà ăn; đèn đường, hàng cây, xe máy đổ, ghế đá.
6. **Cổng trường:** sân 60 × 40 m, cổng sắt rộng 20 m, chốt bảo vệ, cột cổng nghiêng, biển tên trường rơi nửa, đường nứt.
7. **Nhà ăn** 40 × 24 m, thêm bếp 12 × 8 m và kho: bàn ghế đổ, quầy, khay, nồi đổ, tivi treo tường, đồng hồ (dừng lúc 4:00), cửa kho thoát ra ngoài.
8. **Vỏ các tòa chương 4** (không vào được): giảng đường 80 × 20 m, 5 tầng; thư viện 40 × 30 m, 3 tầng; nhà thi đấu 60 × 40 m. Đặt đúng chỗ theo sơ đồ trong thiết kế, cửa khóa hoặc bị đổ chắn.
9. **Tường rào và cây** bao quanh khuôn viên. **Sương mù** (WorldEnvironment trong Campus hoặc ghi rõ để core gắn) che xa khoảng 80–120 m, trời đêm sắp sáng (8 giờ sáng nhưng trời âm u đỏ, như thế giới lưng chừng).
10. **Mô hình nhân vật** (PS1, dưới 1500 tam giác):
    - **Minh Nhật** (thư sinh, áo sơ mi trắng), **Ngư** (buộc tóc đuôi ngựa, cầm thanh sắt), **bảo vệ** (đồng phục, dùi cui điện);
    - **8–10 biến thể xác sống**: dùng lại 4 sinh viên của phần camera và xác 3 bạn cùng phòng, đổi màu áo và tóc, **mắt đỏ phát sáng nhẹ**, máu;
    - bộ tư thế cho lane A: `idle`, `walk`, `stunned` (gục), `grab` (vồ), `sit` / `lie` (xác rải rác), `wake`. Ghi đường dẫn và cách gọi trong Handoff.
11. **Hiệu năng:** cây và đèn dùng MultiMesh; texture 64–256 px; chia khối để bị cắt khi khuất. Ghi số tam giác từng khu vào Handoff.
12. **Test:** scene load được; mọi anchor và vùng có đủ tên; navmesh phủ từ phòng 407 (tầng 4) tới nhà ăn, đi được hết (lane A, C cần); cầu thang tầng 2 sập chặn đúng; cửa sổ phòng quản lý trèo qua được khi cúi; ảnh chụp từng khu.

## Checklist hoàn thành
- [ ] Greybox cả khuôn viên push trước (ghi commit vào Handoff)
- [ ] `pwsh tools/test.ps1` và `pwsh tools/check.ps1` PASS
- [ ] Ảnh chụp từng khu, số tam giác
- [ ] Handoff: anchor, vùng, API, tư thế mô hình

## Handoff (agent điền)

### Ghi chú integrator (2026-10-06): khung khối hộp đã merge sớm
- Commit khung `18661fc` merge vào `main` để lane A, C dùng. Kiểm headless: đủ mọi anchor và vùng trong hợp đồng, mỗi khu 6 điểm xác, 12 bảo vệ, 6 chỗ thanh sắt, đủ 5 hàm API, có navmesh; `test_campus` 3/3; cả bộ test 537/537.
- Lane B làm tiếp mô hình thật trên cùng nhánh; integrator sẽ merge phần còn lại khi lane B báo xong.
