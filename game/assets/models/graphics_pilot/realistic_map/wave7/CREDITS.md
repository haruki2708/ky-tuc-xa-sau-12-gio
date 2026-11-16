# Nguồn asset — `realistic_map/wave7/` (T-264, nhà nền, mặt ngoài nhà B, mặt đất và cây; lượt 1 góc mẫu; D-166)

Mọi file dưới đây do `art_source/graphics_upgrade/realistic_map/wave7/build_wave7.py` (các nhà, lượt 2) và
`build_wave7_pilot.py` (mặt đất, cây, đèn, ghế, xe máy, hàng rào; lượt 3 dựng lại) dựng (Blender 5.2.2, chỉ bmesh; cây dùng
bộ dựng thân và thẻ lá của đợt 3). Tác giả: dự án (Claude, lane B; T-264). Giấy phép: như dự án. Lượt 2 bỏ các phương án
chủ dự án không chọn (D-182): `bldga_wall`, `bldga_gallery`, `gym_r1`, `gym_r2`, `road_slab`, `verge_pavers`, `lamp_concrete`,
`fence_w1`, `W7WallGrey`, `W7RoadSlab`.

| File | Là gì |
|---|---|
| `bldga.glb` | Nhà A kiểu A2 (lượt 2): cả mặt trước 8 gian x 6 tầng, phòng giả sau mọi ô cửa, cửa chính có mái sảnh, dải tầng, trụ, bậu, song sắt, máy lạnh, quần áo phơi; hông, mặt sau, mái |
| `figure.glb` | Bóng người sau ô cửa có rèm sáng phía sau; một bản dưới mỗi `WindowSilhouette0…2` |
| `bldga_light.glb` | Nhà A bản nhẹ cho chương 1–2 (vỏ A2, kính tối; không phòng giả, song sắt, bóng người) |
| `lecture.glb` | Giảng đường R1: lớp học giả sau cửa, lam bê tông đứng, ô văng, cửa chính x −10, mái bằng sau tường chắn mái |
| `gym.glb` | Nhà thể chất R2: cửa sổ cao giữa các trụ (sân giả phía sau), cửa thép xanh có mái, mái tôn vòm |
| `b_outside.glb` | Nhà B: hành lang tầng 5–6 bị chặn sau lan can (cửa, phòng giả, gạch vụn), mặt sau tầng 1–3 và 5–6 có cửa sổ phẳng (phòng giả), máy lạnh, ống nước, mái; vỏ ngoài và mái hai tháp cầu thang |
| `road_asphalt.glb` | Đại lộ đoạn mẫu: nhựa cũ có vá, vạch mờ; vỉa quét vôi |
| `verge_grass.glb` | Lề: cỏ úa và đất |
| `tree_bang.glb`, `tree_phuong.glb`, `tree_xacu.glb` | Cây ven đường: bàng, phượng vĩ, xà cừ (thân, thẻ lá) |
| `lamp_steel.glb` | Đèn đường: cột thép mạ kẽm cần vươn |
| `bench.glb`, `moped.glb` | Ghế bê tông mặt đá mài; xe máy đổ |
| `fence_b40.glb` | Hàng rào tây: lưới B40 trên cột ống |
| `materials/*.tres`, `materials/interior.gdshader` | Vật liệu W7* (`make_wave7_materials.py`); shader phòng giả sau ô cửa (interior mapping, tự viết) |

**Không dùng Tripo, không extension Blender, không tạo ảnh bằng AI.** AI (Claude) viết script dựng hình, shader và vẽ texture
bằng code. Texture riêng: `game/assets/textures/graphics_pilot/realistic_map/wave7/` (xem `CREDITS.md` ở đó). Scan dùng lại,
đã có trong game (CC0 Poly Haven; nguồn ở `art_source/graphics_upgrade/room407_corner/CREDITS.md`, `room407_shell` và
CREDITS các đợt trước): Painted Plaster Wall, Peeling Painted Wall (tường), Plastered Wall 04 (bê tông), cỏ, đất, gạch
"con sâu" của đợt 3, nhựa đường của đợt 5; vật liệu chung của đợt 1–6 (bê tông, sắt, nhôm, kính, thép mạ kẽm, tôn, sơn
xanh cổng, lưới B40, thẻ rãnh tối).
