# Quản lý ký túc xá — dựng lại từ file Tripo (T-219, D-118…D-120)

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
  | `ask` | wait | chống nạnh (chủ dự án chọn, D-120); bow không dùng |
  | `slash` | slash 1,15–3,10 s | giơ dao, bổ, về đúng dáng đầu |
  | `lunge` | run | hông giữ tại chỗ |
  | `kill` | slash 1,15–2,30 s | một cú bổ, dừng thấp |

- **Mắt trắng đục (D-120):** texture Tripo mất mắt trắng của ảnh mẫu, nên script tô lại (`paint_milky_eyes`).
  - Bảng `EYES`: tâm, nửa rộng, nửa cao của hai hốc mắt, đo trên ảnh chụp thẳng mô hình gốc (mét Tripo, mặt nhìn +Z).
  - Từng texel của tam giác vùng mắt được đưa về vị trí trên mô hình rồi tô: lòng trắng đục, tròng xám mờ, đồng tử đục, bóng mí trên. Vùng mắt có roughness 0,25 (bóng ướt).
  - Đổi mô hình khác thì đo lại `EYES`.
- **Godot import** (`manager_tripo.glb.import`): `nodes/root_scale=1.73`, để người Tripo cao 0,98 m đứng 1,70 m. Texture tự tách thành `manager_tripo_*.jpg`.
- **Scene thân** `game/scenes/entity/manager_body.tscn`:
  - xoay mô hình 180° để nhìn về −Z;
  - gắn dao, chìa khóa, thẻ đeo bằng `BoneAttachment3D`;
  - `BladeTip` ở mũi dao;
  - `HandGripModifier` co 4 ngón tay phải quanh cán dao (động tác Tripo để tay mở);
  - `LeftArm` (`ArmReachModifier`): `manager.gd` `open_door` xoay node này, tay trái với ra trước tới tay nắm cửa.
  - `RightWristLock` (`BoneLockModifier`, T-224): cổ tay phải giữ tư thế cầm dao của `stand` qua mọi động tác (động tác Tripo xoay cổ tay như tay không, dao lật ngược);
  - `Lean` (`SpineBendModifier`, T-224): `manager.gd` `lean()` cúi người khi soi giường.
- **Vòng lặp:** `manager_body.gd` cho `stand`, `walk`, `ask`, `lunge`, `slash` lặp (T-224: các nhát chém nối liền); đứng một mình (gương chương 2) thì tự chạy `stand`.
- **Chuyển động tác:** `manager.gd` pha 0,3 s giữa hai clip (T-224, trước 0,2 s); quay người từ từ 6 rad/s.

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
  - phím 1–6: đổi clip;
  - L: đổi đèn tắt / đèn pin / đèn trần;
  - C: đổi góc máy;
  - R: với tay mở cửa;
  - Space: dừng.
- **Chụp 14 ảnh 1080p** (sau khi đổi GLB: `godot --headless --path game --import` trước) vào `previews/`:
  ```
  godot --path game res://scenes/levels/graphics_pilot/manager_preview.tscn -- --manager-capture
  ```

## Ngân sách (card T-219)
- **Tam giác:** thân 18.449 + dao 2.450 + chìa 2.450 + thẻ 782 = **24.131** / 25.000.
- **Vật liệu:** 4.
- **Texture:** tối đa 2048².
