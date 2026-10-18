# Quản lý ký túc xá — dựng lại từ file Tripo (T-219, D-118)

File gốc Tripo ở `build/graphics/staging/manager/` (không vào git; hash trong `SHA256SUMS.txt`).

## 1. Thân và động tác → `manager_tripo.glb`
```
python -I art_source/graphics_upgrade/manager/pack_tripo_manager.py --staging build/graphics/staging/manager --out game/assets/models/characters/manager/manager_tripo.glb
```
- **Gốc là một file có động tác** (`manager_idle.glb`). File `manager_body_rigged.glb` (xuất không kèm động tác) có mọi xương ở vị trí gốc, Godot sẽ dồn khung xương về một điểm, nên không dùng.
- **Bảng `CLIPS`** trong script quyết định clip nào vào game, tên clip `manager.gd` gọi, có bỏ trôi hông không, và đoạn cắt:

  | Clip game | Nguồn Tripo | Ghi chú |
  |---|---|---|
  | `stand` | idle | |
  | `walk` | walk | hông giữ tại chỗ |
  | `ask` | bow | cúi chào 90° |
  | `wait` | wait | chống nạnh; chỉ để so, game không gọi |
  | `slash` | slash 1,15–3,10 s | giơ dao, bổ, về đúng dáng đầu |
  | `lunge` | run | hông giữ tại chỗ |
  | `kill` | slash 1,15–2,30 s | một cú bổ, dừng thấp |

- **Godot import** (`manager_tripo.glb.import`): `nodes/root_scale=1.73`, để người Tripo cao 0,98 m đứng 1,70 m. Texture tự tách thành `manager_tripo_*.jpg`.
- **Scene thân** `game/scenes/entity/manager_body.tscn`:
  - xoay mô hình 180° để nhìn về −Z;
  - gắn dao, chìa khóa, thẻ đeo bằng `BoneAttachment3D`;
  - `BladeTip` ở mũi dao;
  - `HandGripModifier` co 4 ngón tay phải quanh cán dao (động tác Tripo để tay mở).
- **Vòng lặp:** `manager_body.gd` cho `stand`, `walk`, `wait`, `lunge` lặp.

## 2. Đồ đi kèm
Dao từ Tripo nằm nghiêng, nên dựng thẳng theo trục chính trước:
```
blender -b --factory-startup -P art_source/graphics_upgrade/manager/align_prop.py -- --src build/graphics/staging/manager/manager_knife.glb --out build/graphics/staging/manager/manager_knife_upright.glb
```
Sau đó giảm lưới bằng `art_source/graphics_upgrade/tripo/bake_prop.py` (`--fit height --sharp 40 --image-format JPEG`):

| Món | `--src` | `--min` | `--size` | `--tris` | `--tex` |
|---|---|---|---|---|---|
| dao | `manager_knife_upright.glb` | -0.06 0 -0.01 | 0.12 0.42 0.02 | 2500 | 1024 |
| chìa khóa | `manager_keys.glb` | -0.08 0 -0.02 | 0.16 0.16 0.04 | 2500 | 512 |
| thẻ | `manager_id_card.glb` | -0.04 0 -0.01 | 0.08 0.13 0.02 | 800 | 512 |

Dao sau khi dựng thẳng: cán ở y 0–0,17 m, sống dao phía +X, lưỡi phía −X.

## 3. Xem và chụp
- **Xem:** mở `game/scenes/levels/graphics_pilot/manager_preview.tscn`.
  - phím 1–7: đổi clip;
  - L: đổi đèn tắt / đèn pin / đèn trần;
  - C: đổi góc máy;
  - Space: dừng.
- **Chụp 14 ảnh 1080p** vào `previews/`:
  ```
  godot --path game res://scenes/levels/graphics_pilot/manager_preview.tscn -- --manager-capture
  ```

## Ngân sách (card T-219)
- **Tam giác:** thân 18.449 + dao 2.450 + chìa 2.450 + thẻ 782 = **24.131** / 25.000.
- **Vật liệu:** 4.
- **Texture:** tối đa 2048².
