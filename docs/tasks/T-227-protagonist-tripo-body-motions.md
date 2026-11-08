# T-227 — Nhân vật chính Trần Trung trên Tripo: thân thật và đủ động tác
- Lane: **chủ dự án + Claude** (như T-219: chủ dự án tạo trên Tripo, Claude làm phần còn lại, ghi "Claude làm thay A/B") | Trạng thái: **lượt 1 trong cảnh thử xong (24/10/2026), chờ chủ dự án duyệt video** | Agent: chủ dự án + Claude Code ở máy (Opus 5.5)
- Quyết định: **D-137**. **D-142 (07/11/2026): chủ dự án duyệt lượt 1 ("tôi duyệt hết"); integrator làm lượt 2: động tác còn thiếu, giường và nấp, sợ, chết trong cảnh thử có video duyệt, rồi đưa vào chương 1 (T-220 bước 5).**
- Phiếu Tripo: [`TRIPO_NHAN_VAT_CHINH.md`](../handoff/TRIPO_NHAN_VAT_CHINH.md).
- Nối tiếp [T-220](T-220-protagonist-body-hands-pilot.md):
  - bước 1 xong trên thân tạm CC0 (D-123, D-124): thấy chân, bóng, gương; 3 thao tác tay 1 giây bằng IK;
  - D-130: tự mở/đóng cửa ban công làm cùng bước 5.

## Chủ dự án chọn (23/10/2026)
> "Làm nhân vật chính có thân, có thể dùng tripo AI: đầy đủ động tác như người bình thường"

**D-137:**
- Trần Trung làm trên Tripo, như quản lý.
- Nguồn chuyển động chính đổi sang **động tác có sẵn của Tripo** (trước là CC0 trên thân tạm, D-121 cách c). Thiếu động tác nào thì Claude bù bằng IK hoặc CC0.
- **Ngoại hình:**
  - đồ ngủ: áo phông xám cũ, quần đùi tối màu, dép tổ ong;
  - nam khoảng 20 tuổi, 1,70 m, gầy vừa, tóc đen ngắn hơi rối, mặt mệt mỏi, quầng thâm, không kính.
- **Giữ nguyên D-121:**
  - thấy cả người: chân, bóng, gương;
  - mỗi thao tác tay 1 giây, hiện đủ động tác;
  - 1 giây đó tính vào thời gian luật.

## Việc của chủ dự án
**D-138:** tạo ảnh Trần Trung trên Gemini trước (trước, nghiêng, sau), rồi Tripo dựng từ ảnh (phiếu mục 2b). Lưu ảnh gốc và prompt làm bằng chứng (D-084).
- **Ảnh Gemini xong (23/10/2026, khoảng 23:10):**
  - chủ dự án tạo 3 ảnh trên Gemini Argon 4, gói trả phí Google AI Pro: `trung_ref_front.png`, `trung_ref_left.png`, `trung_ref_back.png`;
  - Claude viết `trung_ref_gemini.txt` cùng thư mục staging: prompt theo phiếu mục 2b, giờ lưu và SHA256 từng ảnh;
  - Claude xem ảnh: chữ A khớp giữa ảnh trước và sau, tay mở, áo trơn, dép tổ ong, không hình mờ. Mặt hơi tươi, chưa rõ quầng thâm; đầu ẩn khi chơi nên dùng được, nếu cần thì sửa sau bằng Magic Brush;
  - 3 tệp đuôi `.png` nhưng nội dung là JPEG 687×1024; giữ nguyên bản gốc.
- Tiếp theo: Tripo Multiview to 3D với 3 ảnh.
- **Tripo xong (23/10/2026, khoảng 23:20–23:55):** chủ dự án tải về staging:
  - thân `trung_body.glb` (bản gốc khoảng 2 triệu tam giác);
  - 9 động tác (bản gắn xương khoảng 19.000 tam giác, 65 xương có ngón): idle, walk, run, look_around, scared, hit_to_body, jump, climb, sit;
  - điện thoại `trung_phone.glb` (máy dày khoảng 2,5 cm, chủ dự án ghi "trong game cần chỉnh lại");
  - chủ dự án báo Tripo không có đủ động tác, cần làm thêm.
  - Còn thiếu: link tác vụ Tripo và tài khoản đã dùng (D-084), ảnh chụp danh sách động tác.

## Lượt 1: Trần Trung trong cảnh thử (24/10/2026, Claude làm)
Chi tiết kỹ thuật: [`art_source/graphics_upgrade/protagonist/README.md`](../../art_source/graphics_upgrade/protagonist/README.md) mục 0.
1. **Đóng gói:** `pack_tripo_protagonist.py` gom 9 động tác Tripo vào `game/assets/models/characters/protagonist/trung_tripo.glb` (5 MiB):
   - đứng thở chỉ lấy 0–5,6 s, phát qua lại: sau 6 s Tripo dồn trọng tâm, đầu lệch camera 10 cm;
   - bỏ trôi hông cho đi, chạy, giật mình, trúng đòn, nhảy; leo giữ chuyển động.
2. **Thân trong cảnh thử:** `player_body.gd` dùng Trần Trung thay thân tạm:
   - cao khoảng 1,74 m để mắt đúng 1,6 m của camera;
   - mắt đo trên mô hình, tầm với đo từ xương tay (tay ngắn hơn thân tạm).
3. **Động tác bù CC0 (D-137):** lấy từ thư viện Quaternius đã có, chạy trên khung xương Trần Trung:
   - đang dùng: ngồi xổm, đi khom, với tay mở cửa, cúi nhặt;
   - có sẵn cho bước sau: đẩy, ngồi xuống, đứng dậy, trúng đầu, ngã chết, vung gậy;
   - hông Quaternius đứng lùi 8 cm, nên mỗi clip được dời cho khớp.
4. **Sửa trong lúc ghép:**
   - động tác chạy theo khung vật lý: trước đó bàn chân thỉnh thoảng nhảy theo thân;
   - tốc độ sải chân lấy trung bình mọi bước (bước đi Tripo dài ngắn không đều): bàn chân trượt dưới 2 cm;
   - ánh sáng kiểu "wrap" cho vải và da: đèn trần sau lưng làm ngực đen kịt khi cúi nhìn.
5. **Điện thoại:** ép còn 7,6 × 14,5 × 0,9 cm, khoảng 2.900 tam giác, thay khối hộp trong tay trái.
6. **Xem:**
   - 28 ảnh 1080p `art_source/graphics_upgrade/protagonist/previews/` (tóm tắt `summary.jpg`);
   - video đi một vòng `build/graphics/protagonist/t227_demo.mp4`;
   - video từng động tác có chú thích nhóm và nguồn `build/graphics/protagonist/t227_clips.mp4`.
7. **Test:** `test_protagonist_body.gd` 15 test (thêm 1: thân Trần Trung, đủ clip, hông CC0 khớp, điện thoại mỏng).
8. **Còn lại sau khi chủ dự án duyệt:**
   - động tác chưa có nguồn: nằm, ngồi dậy từ giường, bò, ngã, lên xuống cầu thang, ôm đồ, xoay tại chỗ (Claude làm bằng IK hoặc dựng tay);
   - giường và nấp, sợ, chết trong game;
   - đưa vào 4 chương (T-220 bước 5, cửa ban công D-130), chạy bot và đo FPS (hỏi trước);
   - mặt: vệt tóc lem trên trán và gò má (chỉ thấy trong gương).

Tạo theo phiếu, tải về `build/graphics/staging/protagonist/`, báo lại kèm ảnh chụp danh sách động tác Tripo:
- thân;
- động tác nhóm 1 bắt buộc, các nhóm 2–5 càng nhiều càng tốt;
- điện thoại.

## Việc của Claude (sau khi có file)
1. **Đóng gói** (`art_source/graphics_upgrade/protagonist/pack_tripo_protagonist.py`, theo `pack_tripo_manager.py`):
   - gom động tác vào một GLB;
   - đặt tên clip theo game;
   - bỏ trôi hông cho đi, chạy, đi khom;
   - cắt đoạn;
   - cao 1,70 m, nhìn −Z, texture ≤ 2048².
2. **Thân trong game:** thay thân tạm CC0 của `protagonist_pilot.tscn` (cùng hợp đồng `body_scene` của T-220):
   - đầu ẩn với camera chính, vẫn đổ bóng và hiện trong gương;
   - camera ở giữa hai mắt;
   - tay trái cầm điện thoại Tripo; đèn pin theo điện thoại.
3. **Chuyển động:**
   - **đi lại:** trộn đứng, đi, chạy, đi khom theo tốc độ thật (2,2 / 3,6 / 1,2 m/s), chân không trượt, xoay tại chỗ, đi lùi, bước ngang;
   - **bước chân:** tiếng dép (`slipper_*`) khớp lúc bàn chân chạm đất;
   - **thao tác tay** (T-220): với tới, nhặt, mở cửa, đẩy cửa kẹt, bấm công tắc, cầm điện thoại. Động tác Tripo cho thân và đầu, IK đặt tay đúng `HandTarget`, vẫn 1 giây;
   - **giường và nấp:** leo lên giường tầng, nằm, ngồi dậy, khom nấp; giữ `View`/`Exit` của chỗ nấp (T-208);
   - **sợ, ngã, chết:** giật mình, trúng đòn, ngã chết. Camera chết hiện tại giữ nguyên trừ khi chủ dự án muốn đổi.
4. **Cảnh thử trước, bản chơi sau:**
   - ảnh 1080p và video Movie Maker từng nhóm động tác để chủ dự án duyệt;
   - duyệt xong mới đưa vào 4 chương (T-220 bước 5, cửa ban công D-130);
   - chạy lại 4 chương cần chạy bot, phải hỏi chủ dự án trước.
5. **Test** (mở rộng `test_protagonist_body.gd`):
   - đủ clip theo bảng, độ cao camera, đầu ẩn và gương;
   - chân không trượt, thao tác 1 giây ± 1 khung;
   - interactable chưa có `HandTarget` vẫn chạy.
6. **FPS:** đo phòng 407 có thân người chơi. Hỏi chủ dự án trước khi đo.

## Lượt 2 (integrator làm, từ 08/11/2026)
- **Nguồn động tác bù (D-143):** Quaternius UAL2 bản Standard miễn phí (CC0). Chủ dự án đã tải 08/11 (`build/graphics/staging/protagonist/ual2/Universal Animation Library 2[Standard].zip`, 18,7 MB; License.txt CC0 1.0, tác giả Quaternius; integrator giải nén `UAL2_Standard.glb` vào `ual2/extracted/`). Có **43 động tác**; dùng cho Trần Trung: `LayToIdle` (nằm ngửa rồi ngồi dậy đứng lên; khung đầu làm tư thế nằm), `ClimbUp_1m` (trèo lên giường tầng, bục), `Hit_Knockback` (trúng đòn), `Walk_Carry_Loop` (bê đồ khi đi), `Chest_Open`, `Consume`, `Idle_TalkingPhone_Loop`, `Idle_No_Loop`, `Yes`; `Zombie_Idle_Loop`, `Zombie_Walk_Fwd_Loop`, `Zombie_Scratch` để dành cho xác sống (T-221). **Gói không có** nằm yên (loop), đứng bê đồ, ngã, cầu thang, xoay tại chỗ, bò: integrator làm bằng IK hoặc keyframe. Xương đặt tên kiểu Unreal (`clavicle_l`, `calf_l`, `foot_l`, `ball_l`), khác UAL1, nên cần một bản đồ xương riêng khi ghép vào thư viện động tác.
- **Xong — nhón chân với chỗ cao** (08/11): đồ cao hơn tầm tay duỗi thẳng thì Trần Trung đứng yên, nhón chân (gót nhấc tối đa 8 cm, mũi chân giữ trên sàn), khuỷu tay mở sang bên, ngón tay duỗi theo cánh tay; không cúi người. Cao hơn mức nhón thì không hiện gợi ý dùng tay.
  - Code: `game/scripts/player/tiptoe_modifier.gd` (mới, nghiêng bàn chân quanh mắt cá, trả ngón chân về phẳng), `player_body.gd` (`TIPTOE`, `_rise_for`, `_weigh`, `_high`).
  - Lúc với cao không dùng clip `ual/Interact` (clip này bước chân, nhấc gót) mà đứng yên `idle`.
  - Test `test_protagonist_body.gd::test_a_high_target_is_reached_on_tiptoe`: tay chạm đúng điểm, gót nhấc, mũi chân lệch dưới 2,5 cm, xong thì hạ gót.
- **Xong — nhô vai và với tới đầu ngón tay** (08/11): với cao thì xương đòn nâng vai 25° (`shoulder_raise_modifier.gd`, chạy sau cúi người, trước IK tay); kiểu nắm PINCH và HOOK lấy đồ bằng đầu ngón (`finger_reach` đo trên xương ngón giữa), GRIP vẫn bằng lòng bàn tay. Tầm với khi nhón, giơ thẳng tay: **lòng bàn tay 1,95 m, đầu ngón 2,05 m** (trước 1,90 m). Test `test_a_high_pinch_is_taken_at_the_fingertips`.
- **Xong — xoay tại chỗ** (08/11): đứng yên mà xoay camera thì chân giữ hướng, ngực xoay theo 60% (`SpineTwist`); lệch quá 50° thì bước vòng (clip đi, nhịp 0,7) với 3 rad/s tới khi thẳng hướng nhìn; nhảy hướng quá 135° (hồi sinh, dịch chuyển) thì quay ngay không bước. Bắt đầu thao tác tay thì thân quay thẳng hướng nhìn; `can_reach` tính như thân đã quay thẳng. Test `test_standing_the_feet_keep_their_heading_until_the_view_turns_far`. Chân còn trượt nhẹ khi bước vòng vì dùng clip đi: xem lại khi quay video duyệt.
- **Phát hiện khi đo (cần xử lý trước khi đưa thân vào chương):** vai phải Trần Trung (thân Tripo, mắt 1,6 m) ở khoảng 1,29 m, tầm với lòng bàn tay 0,53 m: với tới khoảng **1,82 m** khi đứng, **1,90 m** khi nhón (sau khi nhô vai và tính đầu ngón: **2,05 m**). Các đồ chủ dự án đã cho giữ ở chỗ cao (D-142, T-228/T-231) cao hơn mức này: `Ch1PhucCard`, `Ch1TeamPhoto` 2,0–2,1 m (chương 1), `Carry_towel` 2,17 m (chương 2), `SearchVent` 2,35 m, `SearchCeiling` 2,92 m (chương 4). Người thật cao chừng ấy với được khoảng 2,1–2,2 m (vai nhô lên khi giơ tay, tính tới đầu ngón). Đã thêm nhô vai và đầu ngón (2,05 m); thân Tripo vai thấp, tay ngắn hơn người thật khoảng 10%, không kéo dài tay ảo. **08/11 đã hỏi chủ dự án:** A (đề xuất) hạ 3 món chương 1–2 xuống ≤ 2,0 m, khe gió và trần giả chương 4 thì trèo lên giường/bàn (`ClimbUp_1m`); B giữ độ cao, trèo mỗi lần; C hạ cả 5 chỗ. Chờ trả lời.
- **D-146:** lên giường 1 giây, ngồi dậy rời giường 1,5 giây; cờ `player_bed` giữ đúng lúc như cũ.
- Còn lại: giường (nằm, ngồi dậy: UAL2 `LayToIdle`, trèo `ClimbUp_1m`), nấp, sợ, chết; cầu thang, ôm đồ, bò; video duyệt; đưa vào chương 1 (T-220 bước 5, D-130).
