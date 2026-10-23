# Nhân vật chính có thân và tay thật — cảnh thử (T-220, D-121…D-124; T-227, D-137, D-138)

Bản chơi chưa đổi. Mọi thứ chạy trong cảnh thử `game/scenes/levels/graphics_pilot/protagonist_pilot.tscn`. Từ T-227 thân là **Trần Trung làm trên Tripo** (mục 0); thân tạm CC0 chỉ còn cho mượn động tác.

## 0. Trần Trung từ Tripo (T-227)
File gốc ở `build/graphics/staging/protagonist/` (không vào git; hash trong `SHA256SUMS.txt`): 3 ảnh Gemini và tệp ghi prompt (D-138), thân, 9 động tác, điện thoại.

### Thân và động tác → `game/assets/models/characters/protagonist/trung_tripo.glb`
```
python -I art_source/graphics_upgrade/protagonist/pack_tripo_protagonist.py --staging build/graphics/staging/protagonist --out game/assets/models/characters/protagonist/trung_tripo.glb
```
- Cách làm như quản lý (`../manager/pack_tripo_manager.py`, script dùng lại các hàm đọc/ghi GLB ở đó):
  - gốc là `trung_idle.glb` (file có động tác, mang dáng đứng gốc của xương);
  - bỏ tiền tố `mixamorig:` ở tên xương;
  - bỏ các kênh không đổi (Tripo ghi vị trí và tỉ lệ cho mọi xương);
  - texture thu về 2048 JPEG.
- **Bảng `CLIPS`:**

  | Clip game | Nguồn Tripo | Ghi chú |
  |---|---|---|
  | `idle` | idle 0–5,6 s | sau 6 s Tripo dồn trọng tâm sang một bên, đầu lệch camera 10 cm; game phát qua lại |
  | `walk`, `run` | walk, run | hông giữ tại chỗ |
  | `look_around` | look_around | |
  | `scared` | scared_01 | hông giữ tại chỗ |
  | `hit` | hit_to_body_02 | hông giữ tại chỗ |
  | `jump` | jump | hông giữ tại chỗ |
  | `climb` | climb | giữ chuyển động: trèo lên gờ cao khoảng 1,7 m |
  | `sit` | sit | ngồi suốt clip |

- **Godot import** (`trung_tripo.glb.import`):
  - `root_scale=1.74` (người Tripo cao 0,98 m);
  - nối xương qua `trung_bone_map.tres` (tên Mixamo → `SkeletonProfileHumanoid`), khung xương `GeneralSkeleton`;
  - bật `fix_silhouette`: Tripo gắn xương ở dáng chữ A, thân tạm ở dáng chữ T. Không bật thì tay dang ra khi phát động tác CC0.
- **Động tác bù (CC0):** động tác Tripo không có thì `player_body.gd` lấy từ thư viện Quaternius của thân tạm (thư viện `ual/`, cùng tên xương nên dùng chung được):
  - ngồi xổm, đi khom, với tay, cúi nhặt (đang dùng);
  - đẩy, ngồi xuống, đứng dậy, trúng đầu, ngã chết, vung gậy (có sẵn cho các bước sau);
  - hông Quaternius đứng lùi 8 cm so với Trần Trung, nên mỗi clip được dời hông cho khớp, không thì cả người giật lùi lúc bắt đầu với tay.
- **Thân trong game (`player_body.gd`):**
  - cao khoảng 1,74 m, để mắt đúng 1,6 m của camera;
  - mắt cách xương đầu (−1,7; 8; 9) cm, đo trên mô hình;
  - tầm với đo từ xương tay (tay Trần Trung ngắn hơn thân tạm);
  - động tác chạy theo khung vật lý, cùng nhịp với người chơi;
  - tốc độ sải chân lấy trung bình mọi bước chạm đất (bước đi Tripo dài ngắn không đều);
  - vật liệu dùng ánh sáng kiểu "wrap" cho vải và da: đèn trần sau lưng không còn làm ngực đen kịt khi cúi nhìn.
- **Điện thoại:** `trung_phone.glb` (Tripo, lượt 1 dày 2,5 cm) qua `../tripo/bake_prop.py`:
  ```
  blender -b --factory-startup -P art_source/graphics_upgrade/tripo/bake_prop.py -- --src build/graphics/staging/protagonist/trung_phone.glb --out game/assets/models/props/phone/phone_tripo.glb --name phone --min -0.038 -0.0725 -0.0045 --size 0.076 0.145 0.009 --fit box --tris 3000 --tex 1024 --sharp 40 --image-format JPEG
  ```
  - ép còn 7,6 × 14,5 × 0,9 cm, khoảng 2.900 tam giác, normal nướng từ bản gốc;
  - thay khối hộp `Model/Body` trong `scenes/player/phone_item.tscn`; màn hình sáng `Screen` giữ nguyên, thu cho vừa mặt kính.
- **Xem:**
  - ảnh 1080p: `--body-capture` (mục "Xem và chụp");
  - video đi một vòng: `build/graphics/protagonist/t227_demo.mp4`;
  - video từng động tác có chú thích nhóm và nguồn (không vào git, quay như `--body-demo`):
    ```
    godot --path game --write-movie build/graphics/protagonist/t227_clips.avi --fixed-fps 30 --resolution 1280x720 res://scenes/levels/graphics_pilot/protagonist_pilot.tscn -- --clip-gallery
    ```

## Cách hoạt động
- **`PlayerBody`** (`game/scripts/player/player_body.gd`), gắn bằng `player.set_body(PlayerBody.new())`:
  - **Hai lớp lưới trên cùng một khung xương:**
    - lớp nhìn: camera người chơi thấy, không đổ bóng, đầu thu lại một điểm nên không thấy bên trong đầu;
    - lớp gương: layer 20, có đầu, đổ bóng, hiện trong gương. Camera người chơi bỏ layer 20.
  - **Mắt đặt dưới camera** theo từng động tác: đứng, đi, chạy, ngồi xổm.
  - **Cúi nhìn xuống:** đầu nhô ra trước tối đa 14 cm, nên thấy được chân.
  - **Chân không trượt:** tốc độ phát động tác bằng tốc độ đi thật chia cho tốc độ lùi của bàn chân đang chạm đất (đo lúc nạp).
    - Bước đi của thân tạm chỉ khoảng 0,9 m/s mà người chơi đi 2,2 m/s, nên nhịp chân nhanh khoảng 2,4 lần. Bước 2 sẽ giãn sải chân.
- **Thao tác bằng tay, đúng 1,0 s** (D-121, luật giữ nguyên thời gian):
  - **0–0,45 s:** tay đi tới `HandTarget` của đồ vật.
    - `TwoBoneIK3D` kéo tay, `HandAlignModifier` xoay cổ tay theo kiểu cầm, `HandGripModifier` khép ngón.
    - Nếu tay không đủ dài thì cúi lưng (`SpineBendModifier`), camera theo đầu 60%.
  - **0,45 s:** dùng đồ.
    - Cửa 407 và tủ Việt quay theo tay (`Interactable.interact_by_hand`).
    - Tờ giấy rời khỏi bàn, nằm trong tay.
  - **0,8–1,0 s:** tay đi về đúng chỗ động tác gốc đang giữ nó, rồi IK mới buông. Tay không vung qua người.
  - **Giấy:**
    - nhấc lên trước mắt rồi mới mở khung đọc;
    - đọc xong, tay đưa giấy xuống đặt lại đúng chỗ (0,5 s) rồi thu về bên hông (0,35 s).
- **Kiểu cầm theo phản hồi của chủ dự án (19/10):**
  - cầm giấy ở **mép phải**, giấy đứng bên trái bàn tay;
  - mép giấy **kẹp giữa ngón cái (phía trước) và các ngón (phía sau)**, dừng sát mặt lòng bàn tay, **không xuyên qua lòng bàn tay**;
  - không vung tay ra sau khi đặt giấy xuống.
- **D-124 (chủ dự án chốt 20/10):**
  - **camera nhìn theo tay:** khi thao tác camera quay về phía tay (85% quãng, tối đa 40°) rồi trả lại;
  - **phải đứng gần:** đồ dùng bằng tay chỉ hiện "[E]" khi tay với tới;
  - **tay trái cầm điện thoại:** bật đèn pin (F) hoặc giơ máy (Q) thì tay trái cầm máy, đèn phát từ máy;
  - **tay nắm cửa gạt** hai mặt (`door_lever.glb`, dựng bằng `build_door_lever.py`, gắn bằng `DoorHandles.fit`): tay nắm cần, vặn xuống 35°, rồi cửa mới quay; buông tay thì cần bật về. Đã gắn cho cửa 407 và cửa nhà vệ sinh trong cảnh thử.
- **`HandTarget`** (`game/scripts/interaction/hand_target.gd`) đặt trên từng đồ vật:
  - đặt ngay chỗ cầm: thanh nắm cửa, mép tủ, giấy thì sát mép phải;
  - `grip` = `GRIP` (nắm), `PINCH` (kẹp), `HOOK` (móc);
  - `pick_up` cho đồ được cầm lên;
  - `lever` / `lever_axis` / `lever_degrees` cho tay nắm cần (đặt `HandTarget` dưới cần để tay đi theo);
  - đồ dùng được từ hai phía có một `HandTarget` mỗi phía, lấy cái gần người chơi.
  - Đồ chưa có `HandTarget` vẫn chạy như cũ (bấm là xong).

## Xem và chụp
- **Tự đi trong cảnh:** mở `protagonist_pilot.tscn` rồi chạy.
  - E: dùng cửa 407, cửa nhà vệ sinh, tủ Việt, tờ ghi chú của Đạt;
  - F: đèn pin điện thoại, Q: giơ điện thoại;
  - L: đổi đèn (tắt / đèn pin / đèn trần).
  - Nhà tắm có thêm một đèn phụ (chỉ có trong cảnh thử) để soi gương.
- **Chụp 26 ảnh 1080p** vào `previews/`:
  ```
  godot --path game res://scenes/levels/graphics_pilot/protagonist_pilot.tscn -- --body-capture
  ```
- **Video đi một vòng** (không đưa vào git):
  ```
  godot --path game --write-movie build/graphics/protagonist/t220_demo.avi --fixed-fps 30 --resolution 1280x720 res://scenes/levels/graphics_pilot/protagonist_pilot.tscn -- --body-demo
  ffmpeg -i build/graphics/protagonist/t220_demo.avi -c:v libx264 -crf 24 -pix_fmt yuv420p -an build/graphics/protagonist/t220_demo.mp4
  ```

## Test
`game/tests/player/test_protagonist_body.gd`, 15 test:
- T-227: thân là Trần Trung (khoảng 1,7 m), đủ clip, hông clip CC0 khớp, điện thoại Tripo mỏng;
- đầu ẩn với camera, có trong gương;
- mắt ở dưới camera;
- chân không trượt quá 3 cm;
- mỗi thao tác đúng 1 giây, dùng đồ đúng một lần;
- cúi lưng để với tới;
- đồ không có `HandTarget` vẫn chạy như cũ;
- cửa quay theo tay;
- giấy được nhấc lên, đọc, rồi đặt lại;
- không vung tay ra sau;
- giấy kẹp ở mép phải, không xuyên lòng bàn tay;
- đứng xa thì không hiện "[E]" (D-124);
- camera nhìn theo tay rồi trả lại;
- vặn cần gạt trước khi cửa quay, buông thì cần bật về;
- tay trái cầm điện thoại khi bật đèn pin.

Ảnh trong `previews/` chụp trong phòng 407 của bản chơi. Đồ Tripo trong phòng giữ nguồn ở các hồ sơ graphics upgrade trước (D-084).
