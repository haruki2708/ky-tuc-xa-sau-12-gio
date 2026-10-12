# Tripo đợt 1 — đồ phòng 407 (D-087)

> Integrator (Claude, Opus 5.5), 12/10/2026. Chủ dự án chọn: chưa thay balo vào bản chơi; làm thêm đồ phòng 407 bằng Tripo rồi **thay cả nhóm cùng lúc (G3)**. Người bấm tạo: **chủ dự án**. Cách làm, lưu điều khoản, ghi phiếu: như `TRIPO_STUDIO_HUONG_DAN_BALO.md`.

## Cách làm chung
- Tripo Studio, **Text to 3D**, model **H3.1**, Triangle, **PBR bật**, **Remove lighting bật**; Ultra mesh, 8K texture, Generate in parts **tắt**. Polycount theo bảng.
- **Tối đa 3 lượt mỗi món** (D-087). Ghi credit trước và sau mỗi lượt.
- Tải GLB về `D:\GAME_DEMO\build\graphics\staging\room407_batch1\`, đặt tên theo bảng; lượt sau thêm `_r2`, `_r3`.
- Kiểm nhanh trên Tripo: có đáy, không chữ/logo, không mảnh rời. Kích thước và hướng không cần đúng: integrator chuẩn hóa sau.

| # | Món | Polycount | Tên file | Đồ cũ trong game (đo bằng probe C, root-local) |
|---|---|---|---|---|
| 1 | Ghế nhựa đỏ | 1500 | `stool_r1.glb` | `kit/plastic_stool.glb` 0,36 × 0,30 × 0,36 m; dùng ở phòng 407, bàn trực ban, CCTV; đối xứng |
| 2 | Tủ lạnh mini | 1500 | `fridge_r1.glb` | `ch1v2/extension.tscn` `MiniFridge` (khối 0,58 × 0,84 × 0,58 m + `FridgeHandle`), cửa quay về phía balo (world −X); giữ khối va chạm |
| 3 | Nồi cơm điện | 1500 | `rice_cooker_r1.glb` | `Extension/RiceCooker` + `CookerLid` + `CookerGrip` trên nóc tủ lạnh (thân 0,33 × 0,28 × 0,38 m, cao tới khoảng 1,2 m) |
| 4 | Xô nhựa | 1500 | `bucket_r1.glb` | `props/bucket.glb` 0,324 × 0,494 × 0,324 m (cả quai); 3 chỗ: góc phòng, nhà vệ sinh, hành lang |
| 5 | Khăn gấp | 800 | `towel_r1.glb` | `Details/FoldedTowel` hiện là khăn treo `props/towel.glb` xoay nằm, scale 0,5 (≈ 0,21 × 0,02 × 0,33 m) trên xô; khăn gấp mới là asset riêng, không thay khăn treo |
| 6 | Dép | 1000 | `slippers_r1.glb` | `props/slippers_pair.glb` 0,233 × 0,066 × 0,257 m, mũi −Z; 8 đôi (4 trong phòng, 4 hành lang), code tô màu từng đôi (`PropTint`) nên dùng màu xám nhạt |
| 7 | Giày thể thao | 1500 | `trainers_r1.glb` | `room407/trainers.glb` 0,295 × 0,134 × 0,27 m; 2 chỗ (giày Đạt, giày ở phần mở rộng) |

Trần kỹ thuật mỗi món (đề xuất integrator, như balo D-079): dưới 3001 tam giác, ≤ 2 vật liệu, texture ≤ 1024², file ≤ 10 MiB. Bản chơi chưa đổi cho tới G3.

## Prompt (dán nguyên đoạn)

**1. Ghế nhựa đỏ**
```text
A low red plastic stool common in Vietnam, about 30 cm tall, square seat with rounded corners and a small hand slot in the middle of the seat, four splayed legs with arched cutouts on each side. Slightly faded and scuffed plastic. No logos, no text. Realistic, game-ready, PBR textures.
```

**2. Tủ lạnh mini**
```text
A small white mini fridge about 85 cm tall with near cube proportions, single front door with a vertical handle along one side, slightly yellowed and scuffed plastic, small dark vent grille at the bottom front. No logos, no text, no stickers. Realistic, game-ready, PBR textures.
```

**3. Nồi cơm điện**
```text
A small electric rice cooker for a student dorm, rounded white body with a domed lid, a carry handle on top of the lid, a small front panel with one switch lever, slightly worn and stained. No logos, no text. Realistic, game-ready, PBR textures.
```

**4. Xô nhựa**
```text
A blue plastic household bucket about 50 cm tall, tapered round body with a rolled rim and a thin metal wire carry handle, slightly scratched and water-stained. Empty. No logos, no text. Realistic, game-ready, PBR textures.
```

**5. Khăn gấp**
```text
A neatly folded cotton bath towel lying flat, folded into a rectangle about 33 by 21 centimeters and 4 centimeters thick, light beige with a thin blue stripe near one edge, slightly worn. Realistic, game-ready, PBR textures.
```

**6. Dép** (game tự tô màu từng đôi, nên chọn xám nhạt)
```text
A pair of cheap foam slide slippers placed side by side, toes pointing forward, each with one wide strap over the top, plain light gray foam, slightly dirty soles. No logos, no text. Realistic, game-ready, PBR textures.
```

**7. Giày thể thao**
```text
A pair of worn canvas sneakers placed side by side, toes pointing forward, black canvas uppers with white laces and off-white rubber soles, scuffed and dusty. No logos, no text. Realistic, game-ready, PBR textures.
```

## Phiếu đợt 1 (integrator điền theo báo cáo của chủ dự án)

| Món | Lượt | Credit trước → sau | File | Ghi chú |
|---|---|---|---|---|
| | | | | |
