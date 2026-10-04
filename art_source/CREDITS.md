# Nguồn asset T-102 / T-121

Toàn bộ mesh và texture của kit được tạo mới cho dự án bằng script `kit/build_kit.py`. Không dùng ảnh tải ngoài, asset từ game khác, font hoặc plugin.

| File / nhóm | Tác giả / công cụ | Nguồn | Giấy phép asset |
|---|---|---|---|
| `game/assets/models/kit/{wall_straight,wall_door,door,bunk_bed,locker,ceiling_fan,plastic_stool,mosquito_net_closed,mosquito_net_open}.glb` | Lane B, Codex (OpenAI), Blender 5.2.2 LTS | [Script gốc](kit/build_kit.py) | CC0-1.0 |
| `game/assets/textures/kit/{plaster,green_paint,old_wood,iron,striped_mat,cloth,locker_paint,fan_paint,red_plastic,net_weave}.png` | Lane B, Codex (OpenAI), texture thủ tục bằng Python, seed 102 | [Script gốc](kit/build_kit.py) | CC0-1.0 |
| `kit/previews/*.png` | Blender Cycles CPU; riêng `kit_showcase*.png` do Godot Forward+ render | Các mô hình và texture trên; capsule hình nộm là primitive Godot | CC0-1.0 |

T-121 làm lại ghế nhựa, thêm hai mùng và texture lưới alpha scissor. Các PNG trùng trong `game/assets/models/kit/` của T-102 đã bỏ; GLB tham chiếu texture gốc trong `textures/kit/`.

URL nguồn công cụ: https://www.blender.org/ và https://godotengine.org/.
URL giấy phép asset: https://creativecommons.org/publicdomain/zero/1.0/.

**Khai báo AI:** Codex (OpenAI) viết script sinh mô hình, texture và scene. Đây là nội dung tạo bằng mã có hỗ trợ AI; giữ khai báo này để integrator tổng hợp khi phát hành (bao gồm Steam). Không sử dụng mô hình sinh ảnh hoặc nguồn hình ảnh bên ngoài.

Giấy phép phần mềm Blender/Godot độc lập với giấy phép các asset được tạo ra.

## Greybox T-112

`game/scenes/levels/floor4/*.tscn` dùng lại các model/texture kit ở trên và primitive Godot (hộp, capsule), sinh bằng `art_source/floor4/build_floor4.py`. Tác giả: Lane B, Codex (OpenAI); nguồn nội bộ là script này và bố cục đã duyệt `docs/design/LAYOUT.md`; giấy phép hình khối/ảnh mới CC0-1.0. Ảnh `art_source/floor4/previews/*.png` do Godot Forward+ render. Không dùng ảnh/asset tải ngoài. Âm thanh chỉ tham chiếu tài nguyên của Lane E; nguồn của chúng giữ ở `game/audio/CREDITS.md`.

## Bóng người và gương T-135

| File / nhóm | Tác giả / công cụ | Nguồn | Giấy phép asset |
|---|---|---|---|
| `game/assets/models/entity/silhouette.glb`, `reflection_body.glb` | Lane B, Codex (OpenAI), Blender 5.2.2 LTS | [Script gốc](entity/build_entity.py); hình khối mới, không dùng asset ngoài | CC0-1.0 |
| `entity/previews/*.png` | Godot 4.7.2 Forward+; Codex viết script chụp | [Script chụp](entity/capture_entity.gd), kit CC0 và mô hình trên | CC0-1.0 |

Shader bóng người/gương và scene là mã mới có hỗ trợ AI (Codex). Không dùng mô hình sinh ảnh, texture tải ngoài, plugin hoặc bản quét người thật. Khai báo AI và URL giấy phép ở trên tiếp tục áp dụng. Các đoạn âm phát trong scene thử giữ nguồn ở `game/audio/CREDITS.md`.

## Đạo cụ T-138 (Claude làm thay lane B)

| File / nhóm | Tác giả / công cụ | Nguồn | Giấy phép asset |
|---|---|---|---|
| `game/assets/models/props/*.glb` (13 đạo cụ: bàn, đèn bàn, điện thoại, đồ trên bàn trực, bảng tin, bồn rửa, vòi, cửa buồng vệ sinh, dép lê, áo, khăn, xô, loa nén) | Claude (Anthropic), Blender 5.2.2 LTS | [Script gốc](props/build_props.py), dùng lại hàm của `kit/build_kit.py` | CC0-1.0 |
| `game/assets/textures/props/*.png` (10 texture 128 × 128) | Claude (Anthropic), texture thủ tục bằng Python, seed 138 | [Script gốc](props/build_props.py) | CC0-1.0 |
| `game/scenes/levels/props/*`, `game/rendering/water_stream.gdshader` | Claude (Anthropic) | Mã mới | CC0-1.0 |
| `props/previews/*.png` | Blender Cycles CPU; `ingame.png` do Godot Forward+ render | Các mô hình trên | CC0-1.0 |

Các đạo cụ dùng lại texture kit (`old_wood`, `iron`, `cloth`, `green_paint`, `fan_paint`), không chép PNG trùng. **Khai báo AI:** Claude (Anthropic) viết script sinh mô hình, texture, scene và shader; nội dung tạo bằng mã có hỗ trợ AI. Không dùng mô hình sinh ảnh hay asset tải ngoài.

## Phòng 407 chương 1 — T-153

| File / nhóm | Tác giả / công cụ | Nguồn | Giấy phép asset |
|---|---|---|---|
| `game/assets/models/room407/*.glb` (13 đạo cụ cá nhân và biến thể giường Trung) | Lane B, Codex (OpenAI), Blender 5.2.2 LTS | [Script gốc](room407/build_assets.py); biến thể giường dùng lại hình khối kit CC0 | CC0-1.0 |
| `game/assets/textures/room407/*.png` (10 texture 128 px) | Lane B, Codex, texture thủ tục bằng Python, seed 153 | [Script gốc](room407/build_assets.py); không dùng ảnh tải ngoài | CC0-1.0 |
| `game/scenes/levels/room407/*`, `game/rendering/room407_surface.gdshader` | Lane B, Codex | [Generator scene](room407/build_scenes.py), mã mới; dùng lại shader PS1 và prop kit/T-138 đã ghi nguồn trên | CC0-1.0 |
| `room407/previews/*.png` | Godot 4.7.2 Forward+, Codex viết script chụp | [Script chụp](room407/capture_room407.gd) | CC0-1.0 |

Poster bóng đá là hình sân/quả bóng hình học tự dựng; khung ảnh có hình người cách điệu tự dựng, không phải ảnh người thật. Không logo, nhãn hàng, lời thoại hoặc nội dung video được đưa vào texture. Máu là mảng pixel đỏ sẫm, không chi tiết giải phẫu. **Khai báo AI:** Codex viết mã tạo model, texture, scene, shader và test; không dùng mô hình sinh ảnh. Âm thanh tham chiếu Lane E giữ nguồn trong `game/audio/CREDITS.md`.

## Mô hình chương 1 — T-154

| File / nhóm | Tác giả / công cụ | Nguồn | Giấy phép |
|---|---|---|---|
| `game/scenes/levels/ch1_models/{manager_body,corpse_phuc,corpse_viet,corpse_dat,charger,router,dat_notebook,phone_viewmodel,bed_debris,rag}.tscn` | Lane B, Codex (OpenAI), hình học và animation Godot 4.7.2 | [Generator gốc](ch1_models/build_models.py), không dùng model tải ngoài | CC0-1.0 |
| `game/assets/textures/ch1_models/*.png` (13 texture 128 px) | Lane B, Codex, Python stdlib, seed 154 | [Generator gốc](ch1_models/build_models.py) | CC0-1.0 |
| `ch1_models/previews/*.png`, script và scene hỗ trợ T-154 | Codex, Godot Forward+ | [Script chụp](ch1_models/capture_models.gd), [README](ch1_models/README.md) | CC0-1.0 |

Tái dùng shader PS1 và scene tầng/anchor T-153 đã ghi nguồn phía trên. Chữ dùng font Be Vietnam Pro theo [nguồn và SIL OFL](../game/assets/fonts/CREDITS.md); nội dung chữ preview lấy từ localization chương 1 hiện có, không thêm mã khóa, tên trường hoặc nhãn hiệu. Nhân vật là hình học hư cấu, không ảnh người thật. **Khai báo AI:** Codex viết generator model/rig/animation, texture thủ tục, runtime, test và script preview; không dùng mô hình sinh ảnh, plugin hay asset tải ngoài. Texture PNG đi Git LFS; mesh và AnimationLibrary được lưu trực tiếp trong scene văn bản Godot.
