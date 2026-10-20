# Nhân vật chính có thân và tay thật — bước 1, cảnh thử (T-220, D-121…D-124)

Bản chơi chưa đổi. Mọi thứ chạy trong cảnh thử `game/scenes/levels/graphics_pilot/protagonist_pilot.tscn`. Thân hiện là thân tạm CC0 (`game/assets/models/characters/standin/`), sẽ thay bằng Trần Trung từ Tripo.

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
`game/tests/player/test_protagonist_body.gd`, 14 test:
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
