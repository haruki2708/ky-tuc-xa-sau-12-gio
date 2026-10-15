# T-219 — Mẫu thử quản lý, đợt 1

**C:** MPFB 2.0.18 / MakeHuman CC0, 1,70 m ở tư thế chuẩn. **A:** chưa có file Tripo. Dao, chìa, thẻ và dây đeo của C hiện là đồ tạm dựng bằng Blender.

## Xem trong Godot

Mở `game/scenes/levels/graphics_pilot/manager_compare.tscn` bằng Godot 4.7.2, Forward+. Nhân vật C ở bên phải; chỗ bên trái dành cho A. Dùng phòng 407 đủ đồ từ `floor4.tscn`, ánh sáng D-113 và gương D-105. Cảnh không chạy story/player/HUD.

| Phím | Chức năng |
|---|---|
| 1–6 | `stand`, `walk`, `ask`, `slash`, `lunge`, `kill` |
| L | Tối → đèn pin → đèn trần ở đỉnh → đèn trần nhấp nháy |
| V | Toàn cảnh → mặt C ở 1 m → góc chém → góc đo giữa phòng |
| P | Dừng/tiếp tục động tác |
| H | Ẩn/hiện chú thích |
| F12 | Chụp ảnh 1920×1080, tự ẩn chú thích |
| Esc | Thoát sạch qua `App.quit()` |

Sau khi được integrator cấp lượt Godot, có thể chạy từ gốc lane C:

```powershell
$env:APPDATA = 'D:\GAME_WORK\lane-c\build\t219\userdata'
$env:TEMP = 'D:\GAME_WORK\lane-c\build\t219\tmp'
$env:TMP = $env:TEMP
New-Item -ItemType Directory -Force $env:APPDATA, $env:TEMP | Out-Null
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game --rendering-method forward_plus --windowed --resolution 1920x1080 res://scenes/levels/graphics_pilot/manager_compare.tscn -- --manager-capture
& 'D:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe' --path game --rendering-method forward_plus --windowed --resolution 1920x1080 res://scenes/levels/graphics_pilot/manager_compare.tscn -- --manager-fps
```

Ảnh và dữ liệu đo nằm trong `previews/`. FPS: VSync tắt, không giới hạn FPS, 90 frame khởi động + 240 frame mẫu/góc; một mẫu hiện, chạy `slash`, đèn trần giữ ở đỉnh nhấp nháy như D-114. Đo cả `centre` và `door_overview` (góc thấp nhất D-114). FPS trung bình = số frame / tổng thời gian; p95 lấy phân vị gần nhất. Kết quả chỉ đại diện cảnh riêng, chưa phải chương thật có AI/story/player.

## Hợp đồng thân

- `manager_body_c.tscn`: root Node3D, một AnimationPlayer, sáu clip từ **một** `manager_shared.tres`.
- Xương nhập bằng BoneMap tường minh + `SkeletonProfileHumanoid`, đổi trục/rest và sửa A-pose sang chuẩn. Rig/GLB nội bộ theo humanoid +Z; node `Model` xoay 180° để **scene thân hướng −Z**, root scale 1, gốc ở chân. Cảnh so sánh xoay actor hướng về camera.
- AnimationPlayer lấy root `../Model`, mọi track trỏ `%GeneralSkeleton:<bone>`. Vị trí chỉ còn Hips, bỏ X/Z để không làm nhân vật đi hai lần. Không method track, không collision, không AI.
- `Model/Rig/GeneralSkeleton/KnifeAttachment`: BoneAttachment3D, `RightHand`.
- `BladeTip`: `Model/Rig/GeneralSkeleton/KnifeAttachment/Knife/BladeTip`, ở đầu mép dao.
- Vật liệu `manager_details.tres` được chia sẻ giữa mắt/đồ đeo và dao, để tổng vẫn ≤4 material.
- `slash` dùng `Sword_Attack` CC0, rút về 0,45 s và khép vòng; `kill` dùng cùng động tác gốc, 0,65 s, không lặp. Đạo diễn vẫn quyết định sáu lần chém và thời điểm kết liễu.
- **Chưa làm** `LeftArm` / `set_reach_weight`; thân này chưa dùng để nghiệm thu động tác mở cửa.

## Dựng lại

Blender portable: `D:\Tools\Blender\5.2.2`, MPFB nằm ở `portable/extensions/user_default/mpfb`. Gói được cài từ mã nguồn tag `v2.0.18`, đóng ZIP thư mục `src/mpfb` rồi chạy CLI `extension install-file ... --repo user_default --enable`. Thư mục tạm dùng `build/t219/tmp` trên D:. Bộ nguồn dùng thực tế được lưu trong `sources/makehuman/`, đủ dựng lại C mà không tải lại gói 268 MiB.

1. `pwsh art_source/graphics_upgrade/manager/run_blender.ps1 -Script art_source/graphics_upgrade/manager/build_manager.py`.
2. `godot --headless --path game --import` với APPDATA/TEMP/TMP riêng trên D:.
3. `python art_source/graphics_upgrade/manager/configure_retarget.py`, rồi import lại. File `.import` đã commit nên bước này chỉ cần khi dựng mới hoặc mất cấu hình.
4. `manager_motion_source.glb` đã chứa sáu động tác gốc cần thiết. Nếu cần trích lại, tải mirror Quaternius CC0 được ghi ở CREDITS về `build/t219/downloads/gltf-universal-animation-library-main/`, chạy `build_motion.py` qua wrapper Blender.
5. Để tạo lại `manager_shared.tres`, copy `build_library.gd` vào một scene tạm dưới `game/tests/`, chạy scene bằng Godot headless (không dùng `-s`), rồi xóa scene/script tạm cùng UID. Mẫu `.tscn`: root Node, script trỏ tới bản copy.

Godot 4.7.2 từng báo index ngoài mảng khi bật ba tùy chọn tự xóa track cùng retarget. Cấu hình đã tắt nhóm xóa track trong importer; `build_library.gd` lọc track từ cuối về đầu sau retarget. Lượt import cuối phải không có ERROR. Texture dùng chế độ nhúng; không giữ các PNG trích ra từ lượt import ban đầu vì chúng có thể che bản nhúng mới.

## Ảnh cần xem

- `previews/full_body_tube.png`: toàn thân và vị trí trống A.
- `previews/face_1m_tube.png`: mặt ở 1 m dưới đèn trần.
- `previews/full_body_flashlight.png`, `previews/face_1m_flashlight.png`: đèn pin D-113.
- `previews/slash_windup.png`, `slash_contact.png`, `slash_recovery.png`: vai/tay/áo qua ba pha chém.
- `previews/tube_flicker.png`: đèn trần nhấp nháy.

Nhận xét hình và kết quả cuối xem Handoff T-219. Mẫu này là đầu vào để chủ dự án so bằng mắt; chưa có kết luận A/C hoặc duyệt thay thân trong bản chơi.
