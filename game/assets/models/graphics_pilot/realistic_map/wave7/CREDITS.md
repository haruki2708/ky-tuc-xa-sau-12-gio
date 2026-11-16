# Nguồn asset — `realistic_map/wave7/` (T-264, nhà nền, mặt ngoài nhà B, mặt đất và cây; lượt 1 góc mẫu; D-166)

Mọi file dưới đây do `art_source/graphics_upgrade/realistic_map/wave7/build_wave7_pilot.py` dựng (Blender 5.2.2, chỉ bmesh;
cây dùng bộ dựng thân và thẻ lá của đợt 3). Tác giả: dự án (Claude, lane B; T-264). Giấy phép: như dự án. Lượt 1 chưa scene
nào dùng; lượt 2, 3 bỏ các phương án không chọn.

| File | Là gì |
|---|---|
| `bldga_wall.glb` / `bldga_gallery.glb` | Nhà A kiểu A2 (tường có cửa sổ từng phòng) / A1 (hành lang hở có lan can); cửa chính có mái sảnh, dải tầng, trụ, bậu, song sắt, máy lạnh, quần áo phơi; các lớp lấp ô cửa theo phương án nội thất; hình người sau ô cửa tầng 3 (`WindowSilhouette1`) |
| `gym_r1.glb` / `gym_r2.glb` | Nhà thể chất: mái bằng, lam bê tông / mái tôn vòm; cửa sổ cao giữa các trụ, cửa chính có mái |
| `b_outside.glb` | Nhà B: hành lang tầng 5–6 bị chặn sau lan can, mặt sau tầng 1–3 có cửa sổ, máy lạnh, ống nước |
| `road_asphalt.glb` / `road_slab.glb` | Đại lộ đoạn mẫu: nhựa cũ có vá, vạch mờ / bê tông tấm; vỉa quét vôi |
| `verge_grass.glb` / `verge_pavers.glb` | Lề: cỏ úa và đất / lát block |
| `tree_bang.glb`, `tree_phuong.glb`, `tree_xacu.glb` | Cây ven đường: bàng, phượng vĩ, xà cừ (thân, thẻ lá) |
| `lamp_steel.glb` / `lamp_concrete.glb` | Đèn đường: cột thép mạ kẽm cần vươn / cột bê tông ly tâm |
| `bench.glb`, `moped.glb` | Ghế bê tông mặt đá mài; xe máy đổ |
| `fence_w1.glb` / `fence_b40.glb` | Hàng rào tây: W1 như tường rào nam / lưới B40 trên cột ống |
| `materials/*.tres`, `materials/interior.gdshader` | Vật liệu W7* (`make_wave7_materials.py`); shader phòng giả sau ô cửa (interior mapping, tự viết) |

**Không dùng Tripo, không extension Blender, không tạo ảnh bằng AI.** AI (Claude) viết script dựng hình, shader và vẽ texture
bằng code. Texture riêng: `game/assets/textures/graphics_pilot/realistic_map/wave7/` (xem `CREDITS.md` ở đó). Scan dùng lại,
đã có trong game (CC0 Poly Haven; nguồn ở `art_source/graphics_upgrade/room407_corner/CREDITS.md`, `room407_shell` và
CREDITS các đợt trước): Painted Plaster Wall, Peeling Painted Wall (tường), Plastered Wall 04 (bê tông), cỏ, đất, gạch
"con sâu" của đợt 3, nhựa đường của đợt 5; vật liệu chung của đợt 1–6 (bê tông, sắt, nhôm, kính, thép mạ kẽm, tôn, sơn
xanh cổng, lưới B40, thẻ rãnh tối).
