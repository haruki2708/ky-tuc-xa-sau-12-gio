# T-239 — Sửa 4 lỗi tay Trần Trung (chủ dự án chơi thử 09/11)
- Lane: B | Trạng thái: todo | Agent: tài khoản Claude lane B (D-141), **Opus 5.5, effort max** (chủ dự án yêu cầu, D-153)
- Nhánh: `lane-b/T-239-protagonist-hand-fixes` từ `origin/main` mới nhất (có `ae7496d`, `35b8759`).
- Quyết định giao: **D-153** (09/11/2026). Chủ dự án chơi bản `KyTucXa.exe` 09/11 15:50 (thân Trần Trung trong chương 1, D-151/D-152) và báo 4 lỗi tay, yêu cầu **"sửa dứt điểm"**.
- Bối cảnh: [T-227](T-227-protagonist-tripo-body-motions.md) (thân Tripo, mục cuối "Thân Trần Trung vào chương 1"), [T-220](T-220-protagonist-body-hands-pilot.md) (D-121: mỗi thao tác tay 1 giây; D-124: tay trái cầm điện thoại, phải đứng gần, tay nắm cửa hai mặt).

## 4 lỗi (ảnh 1080p trong `D:\GAME_DEMO\anh_chup_sua_loi\`, thư mục không có trong git: integrator sao sang `art_source/graphics_upgrade/protagonist/previews/t239/before_*.png`)
1. **`tay_cam_dien_thoai.png`: tay trái xuyên qua điện thoại.** Các ngón nằm đè lên/xuyên mặt màn hình, điện thoại chìm trong lòng bàn tay.
   - **Đúng:** cầm như người thật, điện thoại nằm trong lòng bàn tay trái, ngón cái ở cạnh trái, bốn ngón ôm cạnh phải và mặt sau. Không ngón nào che hay xuyên màn hình, không phần nào của tay xuyên thân máy, ở cả hai tư thế (giơ lên đọc, cầm thấp bật đèn).
   - Code: `player_body.gd` `_tick_phone` (khoảng dòng 774), hằng số tư thế điện thoại (khoảng dòng 104–112), `_phone_half`.
2. **`tay_cam_nam_cua.png`: đóng cửa 407 từ trong phòng thì tay nắm tay nắm phía ngoài hành lang, động tác sai.**
   - Nguyên nhân có thể: `Interactable.hand_target(from)` (`game/scripts/core/interactable.gd:39`) chọn marker **gần nhất**. Khi cánh đã mở vào trong, mặt ngoài cánh quay về phía người chơi nên tay nắm ngoài gần hơn. Lane B tự xác nhận nguyên nhân trước khi sửa.
   - **Đúng:**
     - đứng trong phòng thì dùng tay nắm mặt trong, đứng ngoài thì dùng mặt ngoài, dù cánh đang mở hay đóng;
     - động tác như người thật: nắm tay nắm, kéo hoặc đẩy cánh theo cung quay, bàn tay **đi theo tay nắm** suốt lúc cánh quay (không đứng yên giữa không trung, không xuyên cánh), rồi buông;
     - mở cửa như hiện tại vẫn phải đúng (nhấn tay nắm xuống rồi mới quay).
   - Code: `game/scripts/interaction/door_handles.gd`, `player_body.gd` (`perform`, các pha REACH/HOLD/LET_GO), `door407.gd` chỉ đọc (xem mục Không được).
3. **`tay_cam_giay.png`: tay phải xuyên tờ giấy đang cầm đọc** (thẻ sinh viên, giấy Đạt…). Tay nắm thành nắm đấm, các ngón cắm xuyên qua giấy.
   - **Đúng:** kẹp mép giấy, ngón cái ở mặt trước, các ngón khác đỡ mặt sau. Giấy không bị ngón nào xuyên, mép giấy nằm giữa ngón cái và ngón trỏ. Giữ khung đọc như hiện tại.
   - Code: `player_body.gd` khoảng dòng 750 ("Holding a paper up by its right-hand edge…"), dòng 1035–1060 (giấy theo tay), `_hold_gap`.
4. **`tay_lay_giay.png`: tay lấy giấy sai, không giống người thật.** Tay chọc ngón trỏ xuống, với ngang qua cuốn sổ, bàn tay úp thẳng.
   - **Đúng:** bàn tay đến gần giấy, các ngón khép lại, ngón cái và ngón trỏ kẹp mép giấy (hoặc vài ngón trượt dưới mép) rồi nhấc lên. Không xuyên bàn hay đồ trên bàn. Giấy rời bàn đúng lúc ngón đã kẹp, không phải trước đó.
   - Code: `perform` pha REACH/HOLD, `HandTarget.Grip` (`GRIP`, `PINCH`, `HOOK` trong `game/scripts/interaction/hand_target.gd`), `HandAlignModifier`, điểm đặt tay của giấy trong `chapter1_main.gd` `PAPERS`.

## Yêu cầu chung
- **Sửa tận gốc, áp cho mọi đồ cùng loại**, không chỉ món trong ảnh: mọi tờ giấy, thẻ, ảnh của chương 1; cả cửa 407 và cửa nhà vệ sinh (đều có tay nắm hai mặt); cả hai tư thế điện thoại.
- **Ngón tay:** thân Tripo có xương ngón không, ngón đang lấy tư thế từ clip nào? Cần tư thế ngón riêng cho mỗi kiểu cầm (kẹp giấy, nắm tay nắm, cầm điện thoại). Có thể dùng `SkeletonModifier3D` đặt xương ngón, clip tư thế tay của Quaternius UAL/UAL2 (CC0, đã có trong `assets/models/characters/standin/`), hoặc dựng tư thế bằng Blender trên rig Tripo. Ghi cách chọn và lý do trong Handoff.
- **Giữ nguyên:** mỗi thao tác 1 giây (D-121, `HAND_SECONDS`, `CONTACT`); luật phải đứng gần và cách với D-152 (đứng, nhón chân, rướn, quỳ); thời gian luật; hành vi khi chết (D-151 thả giấy, giấu thân); gương hiện thân.
- **Kiểm bằng hình, không chỉ test:** chụp ảnh 1080p (hoặc video ngắn) trong cảnh chương 1 thật, trước và sau, mỗi lỗi ít nhất 2 góc (góc người chơi và góc bên), lưu `art_source/graphics_upgrade/protagonist/previews/t239/`. Xem lại từng ảnh trước khi báo xong; ngón tay không được xuyên vật.
- **Test tự động mới** trong `game/tests/player/`, ví dụ:
  - điểm trên các xương ngón không lọt vào trong hộp của điện thoại hay tờ giấy trong suốt lúc cầm;
  - đóng cửa 407 từ trong phòng: marker được chọn nằm ở mặt trong; tay đi theo tay nắm suốt lúc cánh quay;
  - giấy rời chỗ cũ chỉ sau khi ngón đã chạm mép.
- Lưu ý cũ: khi chụp ảnh có cửa sổ, đọc mẩu giấy của Khoa từng bị treo hai lần (D-152, chưa tái hiện headless). Gặp lại thì ghi cách tái hiện vào Handoff.

## Được phép sửa
- `game/scripts/player/player_body.gd`, `hand_align_modifier.gd`, các modifier trong `game/scripts/player/` (thêm mới được), `protagonist.gd`.
- `game/scripts/interaction/door_handles.gd`, `hand_target.gd`.
- `game/scripts/core/interactable.gd`: **chỉ hàm `hand_target()`**. Mọi thay đổi khác của file này ghi "Yêu cầu thay đổi".
- `game/scenes/main/chapter1_main.gd`: chỉ điểm đặt tay/kiểu cầm trong `PAPERS`.
- `game/scenes/levels/graphics_pilot/protagonist_pilot.*` (cảnh thử).
- `game/assets/models/characters/protagonist/` (import, tư thế ngón mới), `art_source/graphics_upgrade/protagonist/`.
- `game/tests/player/` (thêm, sửa test liên quan).
- Card này: chỉ Checklist và Handoff.

## Không được
- Không sửa `door407.gd`, director, rule, `game/scripts/core/` (trừ `hand_target()`), không đổi vị trí đồ trong phòng 407.
- Không tiêu credit Tripo (cần thì ghi đề xuất cho chủ dự án), không chạy bot, không đo FPS.
- Không sửa STATUS, DECISIONS.

## Checklist hoàn thành
- [ ] Lỗi 1 điện thoại: không xuyên ở cả hai tư thế; ảnh trước/sau
- [ ] Lỗi 2 cửa: đúng mặt tay nắm theo phía người chơi, tay đi theo tay nắm khi đóng và mở, cả cửa 407 và cửa nhà vệ sinh; ảnh/video
- [ ] Lỗi 3 cầm giấy đọc: kẹp mép, không xuyên; ảnh trước/sau
- [ ] Lỗi 4 lấy giấy: kẹp rồi nhấc như người thật; ảnh trước/sau
- [ ] Test tự động mới cho cả 4 lỗi
- [ ] Mọi test cũ về thân, tầm với và chương 1 đạt (`protagonist`, `hand_targets`, `ch1_bunks`, `room407`, `player_death`)
- [ ] Full `pwsh tools/test.ps1` và `pwsh tools/check.ps1` đạt (luật Lượt Godot)
- [ ] Handoff trung thực: cách sửa từng lỗi, commit hash, phần chưa kiểm

## Cách kiểm tra
- Integrator xem ảnh, chạy full test và check, build `KyTucXa.exe` để chủ dự án chơi thử lại.

## Handoff (agent điền)
