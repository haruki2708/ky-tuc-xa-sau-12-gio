# Mixamo → thư viện động tác của game (T-268)

Đưa clip Mixamo (FBX, "Without Skin", nhân vật X Bot) vào game cho Trần Trung và quản lý. FBX gốc không bao giờ vào `game/` (D-189). Một dự án Godot tạm trong `build/mixamo_pack/` nhập FBX bằng chính bộ chuyển khung xương của Godot. Sau đó `pack_mixamo.gd` ghi mỗi nhân vật một `AnimationLibrary` `.res`, và chỉ hai file `.res` này được chép vào `game/assets/models/characters/mixamo/`.

## Chạy

```
pwsh -NoProfile -File art_source/graphics_upgrade/mixamo/pack_mixamo.ps1                     # setup, import, pack, chép vào game
pwsh -NoProfile -File art_source/graphics_upgrade/mixamo/pack_mixamo.ps1 -Stage pack -NoCopy  # chỉ đóng gói, không chép
pwsh -NoProfile -File art_source/graphics_upgrade/mixamo/pack_mixamo.ps1 -Stage probe -Who trung -Probe walk_fwd
```

- Danh sách clip: `clips.json`. Mỗi clip có các trường:
  - `file`: tên file trong `build/graphics/staging/mixamo/<who>/`;
  - `name`: tên clip trong thư viện;
  - `loop`;
  - `window` (tuỳ chọn): đoạn giữ lại, tính bằng giây;
  - `hips_xz`: `keep` (giữ hông đung đưa), `rest` (ghim hông tại chỗ) hoặc `loop` (bỏ phần trôi đi);
  - `fix_loop` + `loop_blend`: hoà đuôi đoạn cắt về khung đầu để lặp không giật.
- Mọi lần chạy Godot đều qua khoá chung (`build/integrator/godot_steps_locked.ps1 -ProjectDir`).
- Thêm clip: thêm dòng vào `clips.json`, chạy `pack_mixamo.ps1`, thêm dòng vào `CREDITS.md`. Lần setup chỉ ghi file `.import` cho FBX chưa có. Đổi thiết lập nhập thì xoá `build/mixamo_pack/` rồi chạy lại.

## Thiết lập nhập (đã thử trong T-268)

- **Bộ nhập FBX:** dùng ufbx sẵn trong Godot (`fbx/importer=0`). Dự án tạm tắt FBX2glTF; nếu không tắt, file `.import` viết tay bị chuyển sang FBX2glTF.
- **Kết quả nhập:** cảnh có `GeneralSkeleton` (65 xương) và `AnimationPlayer` với một clip tên `mixamo_com`.
  - Tên `mixamorig:Hips` thành `mixamorig_Hips`, nên `mixamo_bone_map.tres` là bảng của Trần Trung (`trung_bone_map.tres`) thêm tiền tố `mixamorig_`.
  - Đơn vị đã là mét. `motion_scale` 1,0427 (độ cao hông X Bot).
- **Chuyển khung xương:** như Trần Trung:
  - đổi tên theo `SkeletonProfileHumanoid`;
  - `retarget_method` 1 (Overwrite Axis);
  - `normalize_position_tracks`;
  - bỏ track của xương ngoài bảng (`unmapped_bones` 1).
- **`fix_silhouette` bật, ngưỡng 11°.**
  - Trần Trung tự nhập với `fix_silhouette` (vai, tay, bàn chân bị ép về dáng chuẩn).
  - X Bot là dáng chữ T, nhưng bàn chân lệch dáng chuẩn 39° và xương đòn 12°. Ở 11° thì cả hai được ép giống bên Trần Trung; cổ (9,9°) không bị ép.
  - Nếu không bật, mũi chân Trần Trung lệch khoảng 39°.
- **Không nén, không tối ưu keyframe.** `player_body.gd` sửa key hông sau khi nạp.
- **Kiểm tra trong `pack_mixamo.gd`:** mọi track phải bắt đầu bằng `%GeneralSkeleton:`, và chỉ hông có track vị trí. Sai thì in `CHECK FAIL` và lệnh thoát với mã 1.

## Quản lý: nướng lên khung xương của chính ông ta

- **Vì sao phải nướng:** khung xương quản lý trong game không được chuyển (`manager_tripo.glb.import` không có bảng xương). Tên xương `mixamorig_*` và đồ cầm theo xương (dao, chìa khoá, thẻ) đã chỉnh tay. Nên không chép được clip `%GeneralSkeleton:` sang ông ta.
- **Cách làm:** dự án tạm nhập `manager_tripo.glb` hai lần:
  - `manager_plain`: như game nhập;
  - `manager_ret`: chuyển khung xương như Trần Trung (`fix_silhouette` 15°, như `trung_tripo.glb.import`).
- **Mỗi khung hình:**
  1. Đặt clip Mixamo lên bản `manager_ret`.
  2. Với mỗi xương, tìm tư thế của bản `plain` sao cho cùng một đỉnh lưới được kéo về cùng chỗ: `G_plain = mesh_p⁻¹ · mesh_r · G_ret · bind_r · bind_p⁻¹`.
  3. Lấy tư thế cục bộ, ghi track `Armature/Skeleton3D:mixamorig_*` như clip Tripo của ông ta.
- **Kiểm tra:**
  - xương con không được rời độ dài lúc nghỉ quá 2 mm (đo được dưới 2 mm);
  - đọc lại clip đã ghi, dựng lưới bằng nó: đỉnh lưới phải trùng bản `manager_ret` (lệch 0,07 mm);
  - `max_slide` (trong `clips.json`): chân trụ của clip đánh tại chỗ không được trượt quá mức này mỗi vòng. Cú chém đặt 0,12 m, đo được 0,107 m, bằng clip gốc.
- **Hai điểm cần nhớ:**
  - Clip đi mang meta `stride_speed` (m/s chân trụ trôi). `manager.gd` phát clip đi ở `speed / stride_speed` nên chân không trượt; clip Tripo không có meta, nên vẫn phát ×1.
  - `manager_body.gd` thay clip trùng tên trên một bản sao thư viện. Thư viện nhập sẵn và thư viện nạp đều dùng chung, nên không sửa trực tiếp.

## Quay video so sánh (cũ | mới)

```
& build/integrator/godot_steps_locked.ps1 -Label t268 -Steps @(
  'rec_trung_old|900|--write-movie D:/GAME_DEMO/build/graphics/motion/t268_trung_old.avi --fixed-fps 30 res://scenes/levels/graphics_pilot/protagonist_pilot.tscn -- --motion-compare',
  'rec_trung_new|900|--write-movie D:/GAME_DEMO/build/graphics/motion/t268_trung_new.avi --fixed-fps 30 res://scenes/levels/graphics_pilot/protagonist_pilot.tscn -- --motion-compare --motion=mx')
# quản lý: res://scenes/levels/graphics_pilot/manager_preview.tscn -- --motion-compare [--motion=mx]
ffmpeg -i old.avi -i new.avi -filter_complex "[0:v]scale=960:540[a];[1:v]scale=960:540[b];[a][b]hstack=inputs=2[v]" -map "[v]" -c:v libx264 -crf 22 -pix_fmt yuv420p -an out.mp4
```

- Mỗi lần quay mất khoảng 1,5–2 phút, nhanh khoảng 20% thời gian thực.
- Đầu vào chạy theo khung vật lý nên hai lần quay khớp nhau từng khung.
- Video để trong `build/graphics/motion/`, không commit.
